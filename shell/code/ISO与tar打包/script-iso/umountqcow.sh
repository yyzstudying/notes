#!/bin/bash

umount /mnt/rcdc/data
umount /mnt/rcdc/

qemu-nbd -d /dev/nbd0
