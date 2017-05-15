#! /bin/sh -u
# Copyright (C) 2017, Codethink, Ltd., Robert Marshall <robert.marshall@codethink.co.uk>
# SPDX-License-Identifier:	AGPL-3.0
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

# assumes that we're running from somewhere controlled by git
BRANCH=`git rev-parse --abbrev-ref HEAD`
# too prescriptive?
TAG=`git describe --match=v[234]\*`
if [ $# -ne 2 ]
then    
    echo "Usage: create_test.sh <inputFile> <outputFile>"  
    exit 1
fi
TREENAME=$TREE
# check they're yaml?
INP=$1
OUP=$2
cp $INP $OUP
# assumes the kernel is held in localhost:8010, if not need to swap out
# http://localhost:8010/TREE/BRANCH/TAG/ with the http address of the git repos
# or clone it and copy the files to /var/www/images
sed -i $OUP -e 's/TREE/'"$TREENAME"'/' 
sed -i $OUP -e 's/TAG/'"$TAG"'/' 
sed -i $OUP -e 's/BRANCH/'"$BRANCH"'/' 


echo now run lava-tool submit-job http://lavauser@localhost:8080/RPC2 $OUP
