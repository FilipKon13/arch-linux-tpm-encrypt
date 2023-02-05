# Disc encryption via TPM 1.2 and LUKS

## Introduction

Encrypted LUKS containers provide safe way of securing data on hard drive. The whole system is agreed to be impenetrable using straight-up brute force attack. However, to be used, container has be decrypted after every boot. Typical means of decrypting consist of providing a password, however, human created passphases tend to be word-based to be easier to remember, which renders them vulnerable to dictionary attacks. Alternative is to create complex password and store it in some removable memory, like pendrive, and provide it this way on every boot, which in turn is inconvenient.

The aim of this repo is to get encrypted with complex password LUKS container and being able to decrypt it in a safe way without need to provide password manually. It is achieved by the use of TPM (Trusted Platform Module) to store the key to the container. During the boot and decryption process TPM will release the key only if the boot process wasn't compromised. This way, when login screen is loaded we can expect that system hadn't been tampered with. From the perspective of attackers, they should not be able to brute-force dictionary attack system because of software timeout and should not be able to directly decrypt the hard drive because of the complex key. Simirarly, after try to overwrite the bootloader, the TPM will not release the key, because the boot process didn't match the expected one. More about the whole process can be found in Details section.

## Installation

You need to make sure that you have cleared and ready-to-take-ownership-of TPM 1.2 module on your machine (this should be archievable is BIOS settings provided appropriate hardware). The scripts available in this repo assume freshly installed ArchLinux distribution - they wipe out whole hard drive and create they own partitions. In case of more specific needs, parts of the scripts can be modyfied to match situation, e.g. when you have already set up LUKS container and want only to store the key to it in the TPM.

To start installation, copy this repo on your machine (e.g. by mounting pendrive with this repo), connect to the internet, run the scripts named `install*.sh` in the order and follow instructions - some parts are not fully automated, like connecting to the internet or making sure that TPM is appropriate state.

## Details

## Credits