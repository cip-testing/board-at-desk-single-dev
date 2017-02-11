#! /usr/bin/which python
# Obtain an administrative token for the kernel ci backend
# (C) 2016 Siemens AG, Wolfgang Mauerer <wolfgang.mauerer@siemens.com>
# SPDX-License-Identifier:	Apache-2.0

import simplejson
import requests
import argparse

parser = argparse.ArgumentParser(description='Obtain kernel ci admin token.')
parser.add_argument('master_key', help='Master key')
args = parser.parse_args()

headers = { "Content-Type": "application/json",
            "Authorization": args.master_key }
payload = { "email": "ci@cip-project.org", "admin": 1 } 
response = requests.post("http://localhost:8888/token",
                         data=simplejson.dumps(payload), headers=headers)
print(response.json().get("result")[0]["token"])
