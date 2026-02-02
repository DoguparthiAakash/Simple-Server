#!/bin/bash
set -e

# Enter directory
cd "$(dirname "$0")/buildroot-2024.02.1"

IMAGE_DIR="output/images"

if [ ! -f "$IMAGE_DIR/bzImage" ]; then
    echo "Error: Kernel image not found. Did you run build.sh?"
    exit 1
fi

echo "Starting QEMU..."
echo "Press Ctrl+A, then X to exit QEMU."

qemu-system-x86_64 \
    -M pc \
    -kernel $IMAGE_DIR/bzImage \
    -drive file=$IMAGE_DIR/rootfs.ext2,if=virtio,format=raw \
    -append "rootwait root=/dev/vda console=tty1 console=ttyS0" \
    -serial stdio \
    -net nic,model=virtio -net user \
    -m 512M \
    -enable-kvm
