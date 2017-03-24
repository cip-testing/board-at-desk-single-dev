#!/bin/sh

# Vagrant 1.6 expects ifup/ifdown to return 0 despite (most) failures,
# which is no longer true since ifupdown 0.8.  Work around this.

set -eu

echo "START: install_ifupdown_workaround.sh"

# ifdown should be a symlink to ifup, so we need one wrapper for both
if [ "$(readlink /sbin/ifdown)" != ifup ]; then
    echo "ERROR: /sbin/ifdown is not a symlink to ifup as expected"
    exit 1
fi

# Divert ifup if not already done.  Assert that it hasn't been
# diverted by a package.
diverter="$(sudo dpkg-divert --listpackage /sbin/ifup)"
if [ -z "$diverter" ]; then
    sudo dpkg-divert --local --divert /sbin/ifup.real --rename /sbin/ifup
elif [ "$diverter" != LOCAL ]; then
    echo "ERROR: /sbin/ifup already diverted by package $diverter"
    exit 1
fi

# Create/update wrapper.  As ifup and ifdown use the same binary, we
# have to pass the command name through using bash's exec -a option.
sudo tee /sbin/ifup << EOT
#!/bin/bash
(exec -a "\$0" /sbin/ifup.real "\$@")
exit 0
EOT
sudo chmod 755 /sbin/ifup

echo "END: install_ifupdown_workaround.sh"
