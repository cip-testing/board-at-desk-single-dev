# Kernel CI for the Civil Infrastructure Platform #

This repository provides the vagrant infrastructure that allows users/labs
to easily set up a Kernel CI frontend and backend tailored to the needs
of the Civil Infrastructure Platform (http://www.cip-platform.org).

## KernelCI Virtual Machine Setup & Configuration ##

The current setup requires (2) Virtual Machines; one for KernelCI and the other for LAVA v2

### Setting up the Debian Jessie KernelCI VM ###

1.) Install Vagrant

```[user@host ~] $ sudo apt-get install vagrant```

2.) Install Oracle Virtualbox

```[user@host ~] $ sudo apt-get install virtualbox```

OR, if you downloaded Virtualbox from the Oracle website
Note: This assumes you are running Ubuntu Xenial(16.04) 64-bit
```[user@host ~] $ cd Downloads```
```[user@host Downloads] $ sudo dpkg -i virtualbox-5.1_5.1.8-111374-Ubuntu-xenial_amd64.deb```

3.) Get the CIP Debian Jessie KernelCI Project

```[user@host ~/git] $ git clone https://gitlab.com/cip-project/kernelci-debian.git```

4.) Change to the kernelci-debian directory

```[user@host ~/git] $ cd kernelci-debian```

5.) Launch the KernelCI Virtual Machine

```[user@host ~/git/kernelci-debian] $ vagrant up```

Note: Please ignore any warnings such as “GetPassWarning: Can not control echo on the terminal.” or “Warning: Password input may be echoed.” - These do not affect the operation of the KernelCI VM.

6.) Connect to the KernelCI VM through ssh using vagrant

```[user@host ~] $ vagrant ssh```

### Get CIP Kernel using git ###

7.) Change to the git-repos directory

```vagrant@guest:~$ cd git-repos```

8.) Clone the Linux Kernel

```vagrant@guest:~/git-repos$ git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git```

9.) Find the branch of the kernel version you want (i.e. 4.4.27)

```vagrant@guest:~/git-repos$ cd linux-stable```

```vagrant@guest:~/git-repos/linux-stable$ git tag -l | grep 4.4.y```

10.) Create a new branch using that tag.

```vagrant@guest:~/git-repos/linux-stable$ git checkout -b cip_v4.4.27 v4.4.27```

### Compile CIP Kernel ###

11.) Set the environment variables

```vagrant@guest:~/git-repos/linux-stable$ export TREE_NAME=cip-test```

```vagrant@guest:~/git-repos/linux-stable$ export ARCH=arm```

```vagrant@guest:~/git-repos/linux$ export CROSS_COMPILE=arm-linux-gnueabi-```

Note: Don't forget the dash (-) at the end of the CROSS_COMPILE line!

12.) Execute the build.py command

```vagrant@guest:~/git-repos/linux-stable$ ~/kernelci-build/build.py -c tinyconfig -p CIP-KernelCI```

13.) The Web Server is already running in the background. when you navigate from page to page the logs are written to the screen. To get back to the command line, simply press Enter

14.) On your host machine, open a web browser and enter the following in the address box:

http://localhost:5000

15.) You will see the KernelCI Website home page from which, you can navigate to the different builds and trees that you've created
 

