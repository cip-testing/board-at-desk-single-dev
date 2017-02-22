#! /bin/sh

# Start file server
cd /var/www/images/kernel-ci
python -m SimpleHTTPServer 8010 &
cd ~

# Start web server
. /srv/.venv/kernelci-frontend/bin/activate
/srv/kernelci-frontend/app/server.py &
