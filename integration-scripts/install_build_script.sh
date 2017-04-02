#! /bin/sh
# Copyright (C) 2016, Siemens AG, Wolfgang Mauerer <wolfgang.mauerer@siemens.com>
# SPDX-License-Identifier:	AGPL-3.0
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

echo "START: install_build_script.sh"

set -e

cd $HOME 
git clone https://github.com/kernelci/kernelci-build.git
cd kernelci-build

MASTER_KEY=`cat $HOME/backend-admin-token.txt`
sed -i build.py -e 's/^install = False/install = True/'
sed -i build.py -e 's/^publish = False/publish = True/'
sed -i build.py -e 's/^url = None/url = "http:\/\/localhost:8888"/'
sed -i build.py -e "s/^token = None/token = \"${MASTER_KEY}\"/"

echo "END: install_build_script.sh"
