#!/bin/bash

INPUT_MODEL="20dv200"
# input files
INPUT_BOOT_FILE="openwrt-hi35xx-${INPUT_MODEL}-u-boot.bin"
INPUT_KERNEL_FILE="openwrt-hi35xx-${INPUT_MODEL}-default-uImage"
INPUT_ROOTFS_FILE="openwrt-hi35xx-${INPUT_MODEL}-default-root.squashfs"

# flash layout
let "FLASH_SIZE=8*1024*1024"
let "BOOT_MTD_SIZE=256*1024"
let "ENV_MTD_SIZE=64*1024"
let "KERNEL_MTD_SIZE=2048*1024"
let "ROOTFS_MTD_SIZE=5120*1024"

let "ROOTFS_DATA_MTD_SIZE=$FLASH_SIZE-$ROOTFS_MTD_SIZE-$KERNEL_MTD_SIZE-$ENV_MTD_SIZE-$BOOT_MTD_SIZE"

append_zeroes () {
    FILESIZE=$(stat -c%s $1)
    let "ZEROS_SIZE=$2 - $FILESIZE"
    dd conv=sync if=/dev/zero bs=$ZEROS_SIZE count=1 >> $1
}

remove_mtd_files() {
    rm -f mtd0.bin
    rm -f mtd1.bin
    rm -f mtd2.bin
    rm -f mtd3.bin
    rm -f mtd4.bin
}

remove_mtd_files

# create mtd files
cp ${INPUT_BOOT_FILE} mtd0.bin
touch mtd1.bin
cp ${INPUT_KERNEL_FILE} mtd2.bin
cp ${INPUT_ROOTFS_FILE} mtd3.bin
touch mtd4.bin

# add zeroes to mtd files
append_zeroes mtd0.bin $BOOT_MTD_SIZE
append_zeroes mtd1.bin $ENV_MTD_SIZE
append_zeroes mtd2.bin $KERNEL_MTD_SIZE
append_zeroes mtd3.bin $ROOTFS_MTD_SIZE
append_zeroes mtd4.bin $ROOTFS_DATA_MTD_SIZE

rm -f result_dump.bin
cat mtd0.bin mtd1.bin mtd2.bin mtd3.bin mtd4.bin > result_dump.bin

remove_mtd_files
