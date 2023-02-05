pacman -S base-devel
pacman -S git

useradd -m user
passwd user
usermod -aG wheel user
sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g" /etc/sudoers

chmod 777 makepkgs.sh
su -c ./makepkgs.sh user

cp -r etc/* /etc/

if [[ $(cat /sys/class/tpm/tpm0/active) != "1" ]]
then
	echo "Activate TPM"
	exit 1
fi

if [[ $(cat /sys/class/tpm/tpm0/enable) != "1" ]]
then
	echo "Enable TPM"
	exit 1
fi

tcsd
tpm_takeownership -z

dd bs=1 count=256 if=/dev/urandom of=/etc/tpm-secret/secret_key.bin
chmod 0700 /etc/tpm-secret/secret_key.bin
cryptsetup luksAddKey /dev/sda4 /etc/tpm-secret/secret_key.bin
chmod +x /etc/tpm-secret/tpm_storesecret.sh
chmod +x /etc/tpm-secret/tpm_getsecret.sh

sed -i "s|^MODULES=.*|MODULES=(quota_v2 quota_tree tpm tpm_tis)|g" /etc/mkinitcpio.conf
sed -i "s|^HOOKS=.*|HOOKS=(base systemd autodetect modconf kms keyboard sd-vconsole block tpm sd-encrypt lvm2 filesystems fsck)|g" /etc/mkinitcpio.conf

BLKID=$(blkid | grep sda4 | cut -d '"' -f 2)
echo "cryptlvm1      UUID=${BLKID}    /secret_key.bin" > /etc/crypttab.initramfs

cp /boot/initramfs-linux-lts.img /boot/initramfs-linux-lts.img.orig
mkinitcpio -P
/etc/tpm-secret/tpm_storesecret.sh --no-seal
echo Reboot the system and run /etc/tpm-secret/tpm_storesecret.sh to seal the key to new boot sequence. 