#! /bin/sh
# Copyright (C) 2017, Codethink, Ltd., Robert Marshall <robert.marshall@codethink.co.uk>
# SPDX-License-Identifier:	Apache-2.0

. /srv/.venv/kernelci-frontend/bin/activate
/srv/kernelci-frontend/app/server.py
