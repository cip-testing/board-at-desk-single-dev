#! /bin/sh -u
# Copyright (C) 2017, Codethink, Ltd., Don Brown <don.brown@codethink.co.uk>
# SPDX-License-Identifier:	AGPL-3.0
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
BRANCH=`git rev-parse --abbrev-ref HEAD`
BRANCH=buildKernel
#TAG=`git describe --match=v[234]\*`
TAG=0.9
if [ $# -ne 2 ]
then    
    echo "Usage: create_test.sh <inputFile> <outputFile>"  
    exit 1
fi
TREENAME=$TREE
INP=$1
OUP=$2
cp $INP $OUP
sed -i $OUP -e 's/TREE/'"$TREENAME"'/' 
sed -i $OUP -e 's/TAG/'"$TAG"'/' 
sed -i $OUP -e 's/BRANCH/'"$BRANCH"'/' 

# check they're yaml?
