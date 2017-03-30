#! /bin/sh
# Copyright (C) 2016, Siemens AG, Wolfgang Mauerer <wolfgang.mauerer@siemens.com>
# SPDX-License-Identifier:	Apache-2.0
echo "START: install_build_script.sh"

set -e

cd $HOME 
git clone https://github.com/kernelci/kernelci-build.git
cd kernelci-build
git checkout f60fce159179b186dbb16c72f78f0d59db576aa7

MASTER_KEY=`cat $HOME/backend-admin-token.txt`
sed -i build.py -e 's/^install = False/install = True/'
sed -i build.py -e 's/^publish = False/publish = True/'
sed -i build.py -e 's/^url = None/url = "http:\/\/localhost:8888"/'
sed -i build.py -e "s/^token = None/token = \"${MASTER_KEY}\"/"

echo "END: install_build_script.sh"
