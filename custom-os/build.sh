#!/bin/bash
set -e

# Enter directory
cd "$(dirname "$0")/buildroot-2024.02.1"

echo "--------------------------------------------------------"
echo "Starting Buildroot Compiliation for Custom Clean Server"
echo "Target: x86_64, Musl, Preempt Kernel, BBR TCP"
echo "--------------------------------------------------------"
echo "Use 'tail -f build.log' to monitor progress if you run this in background."
echo "Approximate time: 30-60 minutes."
echo "--------------------------------------------------------"

# Run make with all cores + 1
CPUS=$(nproc)
make -j$(($CPUS + 1)) 2>&1 | tee ../build.log

echo "--------------------------------------------------------"
echo "Build Complete!"
echo "Kernel: output/images/bzImage"
echo "RootFS: output/images/rootfs.ext2"
echo "Run './run.sh' to test it."
echo "--------------------------------------------------------"
