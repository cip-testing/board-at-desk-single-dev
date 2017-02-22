#! /bin/sh
# Copyright (C) 2016, Codethink, Ltd., Don Brown <don.brown@codethink.co.uk>
# SPDX-License-Identifier:	Apache-2.0
cd ~
cd git-repos
git clone git://git.kernel.org/pub/scm/linux/kernel/git/bwh/linux-cip.git
cd linux-cip
git checkout -b cip_v4.4.27 v4.4.27
echo "Building ARMhf cip-tyrannosaurus Tree"
export TREE_NAME=cip-tyrannosaurus
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
~/kernelci-build/build.py -c tinyconfig -p CIP-KernelCI
~/kernelci-build/build.py -c allnoconfig -p CIP-KernelCI
echo "Building ARMhf cip-stegosaurus Tree"
export TREE_NAME=cip-stegosaurus
~/kernelci-build/build.py -c sunxi_defconfig -p CIP-KernelCI
~/kernelci-build/build.py -c axm55xx_defconfig -p CIP-KernelCI
echo "Building ARMhf cip-triceratops Tree"
export TREE_NAME=cip-triceratops
~/kernelci-build/build.py -c tinyconfig -p CIP-KernelCI
~/kernelci-build/build.py -c allnoconfig -p CIP-KernelCI

