# Board-at-Desk Single-Developer Kernel CI & LAVA VM Setup & Configuration #

This repository creates a Virtual Machine that contains Kernel CI and LAVA. 
Kernel CI is used to build, boot and report results where LAVA is used to offer 
a robust automated testing language, a testing engine and reporting results. 
This project is tailored to the needs of the Civil Infrastructure Platform 
(http://www.cip-platform.org).

## Setting up the LAVA2 Server for testing custom Linux kernels ##

1.) Clone the ```board-at-desk-single-dev``` repository

```user@host ~$ https://gitlab.com/cip-project/board-at-desk-single-dev.git```

```user@host ~$ cd board-at-desk-single-dev```

```user@host ~/board-at-desk-single-dev$```

2.) Start the Virtual Machine

```user@host ~/board-at-desk-single-dev$ vagrant up```

3.) SSH into the Virtual Machine

```user@host ~/board-at-desk-single-dev$ vagrant ssh``

## Create a Superuser Account ##

4.) Set up a Superuser for Lava Job maintenance. 

```vagrant@jessie:~$ sudo lava-server manage createsuperuser --username lavauser --email=lavauser@lava.co.uk```

```Password: mylava1234```

```Password (again): mylava1234```

```Superuser created successfully.```

*Note: Replace <lavauser> with your desired username and replace <lavauser@lava.co.uk> with that user’s email address. Select a password and enter it twice.*

5.) On your host machine, open a web browser and enter the following in the address box:

http://localhost:8080

*Note: Replace localhost with the IP Address of the Lava Server Virtual Machine.*

6.) The LAVA Home Page is displayed in your web browser. Log in to the web server as the superuser:

   a.) Click the login link in the upper right-hand corner of the Lava Server website

   b.) Enter the username: lavauser

   c.) Enter the password: mylava1234

## Add the QEMU Device Type and Device ##

7.) Add a Device Type ```qemu``` and Device ```qemu01``` for the QEMU VM 

```vagrant@guest: ~$ cd /etc/lava-server/dispatcher-config/device-types/```

```vagrant@guest: /etc.../device-types/$ sudo lava-server manage add-device-type qemu```

```vagrant@guest: /etc.../device-types/$ sudo lava-server manage add-device --device-type qemu qemu01```

```Adding the device types:```

```qemu01 [OK] qemu01 (Idle, heath Unknown)```

```Remember to import a device dictionary before submitting test jobs or running health checks on qemu01 (Idle, health Unknown)```

## Create & Import the QEMU Device Dictionary ##

8.) Create the Device Dictionary file for a QEMU VM

```vagrant@guest: /etc.../device-types/$ cd ~```

```vagrant@guest: ~$ echo {% extends 'qemu.jinja2' %}” > myqemu.dat```

```vagrant@guest: ~$ echo {% set mac_addr = '52:54:00:12:34:59' %} <nowiki>>></nowiki> myqemu.dat```

```vagrant@guest: ~$ echo {% set memory = '1024' %}\n” <nowiki>>></nowiki> myqemu.dat```

9.) Import the QEMU Device Dictionary file into the LAVA2 Server

```vagrant@guest: ~$ sudo lava-server manage device-dictionary --hostname qemu01 --import myqemu.dat```

## Add the Beaglebone Black Device Type and Device ##

10.) Add a Device Type beaglebone-black and Device bbb01 for the Beaglebone Black

```vagrant@guest: ~$ cd /etc/lava-server/dispatcher-config/device-types/```

```vagrant@guest: ~$ sudo lava-server manage add-device-type beaglebone-black```

```vagrant@guest: ~$ sudo lava-server manage add-device --device-type beaglebone-black bbb01```

```Adding the device types:```

```bbb01 [OK] bbb01 (Idle, heath Unknown)```

```Remember to import a device dictionary before submitting test jobs or running health checks on bbb01 (Idle, health Unknown)```

## Create & Import the Beaglebone Black Device Dictionary ##

11.) Create the Device Dictionary file for a Beaglebone Black

```vagrant@guest: ~$ echo “{% extends 'beaglebone-black.jinja2' %}” > mybbb.dat```

```vagrant@guest: ~$ echo “{% set ssh_host = '<ip_address>' %}” >> mybbb.dat```

```vagrant@guest: ~$ echo “{% set connection_command = 'telnet localhost 6000' %}” >> mybbb.dat```

*Note: Where <ip_address> is the IP Address of the Beaglebone Black without the <> symbols*

12.) Import the Beaglebone Black Device Dictionary file into the LAVA2 Server

```vagrant@guest: ~$ sudo lava-server manage device-dictionary --hostname bbb01 --import mybbb.dat```

## Assign the 'jessie.raw' Worker Host to the Devices ##

13.) Login to the Lava Server Frontend with user **lavauser** and the password you set

14.) Click on the lavauser menu and select **Administration**

15.) Click on **Devices** under lava_scheduler_app

16.) Click on the **qemu01** device

17.) For the Worker Host: select **jessie-raw** from the pulldown box

18.) Click the **Save** button at the bottom of the page

19.) Click on the **bbb01** device

20.) For the Worker Host: select **jessie-raw** from the pulldown box

21.) Click the **Save** button at the bottom of the page

22.) Click on **View site** in the upper right-hand corner of the page


## Create the Heath Check Job for both Devices##

23.) Click on **Device Types** under lava_scheduler_app

24.) Click on the **qemu** device type

25.) Copy and past the contents of the file ```/vagrant/device-types/qemu-health-check.yaml``` into the Health check job textbox.

26.) Click on the **Save** button in the lower right-hand corner of the page

*Note: Once the health-check job is saved to the device type, the job is automatically started by LAVA.*

27.) Click on the **bbb01** device type

28.) Copy and past the contents of the file ```/vagrant/device-types/beaglebone-black-health-check.yaml``` into the Health check job textbox.

29.) Click on the **Save** button in the lower right-hand corner of the page

## Building and Testing the CIP Kernel ##

### Get CIP Kernel using git ##

30.) Change to the git-repos directory

```vagrant@guest:~$ cd git-repos```

31.) Clone the CIP Linux Kernel

```vagrant@guest:~/git-repos$ git clone git://git.kernel.org/pub/scm/linux/kernel/git/bwh/linux-cip.git```

32.) Find the branch of the kernel version you want (i.e. 4.4.27)

```vagrant@guest:~/git-repos$ cd linux-cip```

```vagrant@guest:~/git-repos/linux-cip$ git tag -l | grep 4.4.y```

33.) Create a new branch using that tag.

```vagrant@guest:~/git-repos/linux-cip$ git checkout -b cip_v4.4.27 v4.4.27```


## Compile CIP Kernel ##

34.) Set the environment variables. You can create a tree name that describes your project. Select the Architecture of the target device (i.e. arm, arm64, mips, i386, amd64, etc...). Choose the cross compiler you need for that architecture.

```vagrant@guest:~/git-repos/linux-cip$ export TREE_NAME=cip-test```

```vagrant@guest:~/git-repos/linux-cip$ export ARCH=arm```

```vagrant@guest:~/git-repos/linux-cip$ export CROSS_COMPILE=arm-linux-gnueabihf-```

*Note: Don't forget the dash (-) at the end of the ```CROSS_COMPILE``` line!*

35.) Execute the build.py command, passing in the configuration you require for your project.

```vagrant@guest:~/git-repos/linux-cip$ ~/kernelci-build/build.py -c tinyconfig -p CIP-KernelCI```

36.) Start the Kernel CI Web Server with the following command:

```vagrant@guest:~$ /vagrant/scripts/start_webserver.sh```

37.) On your host machine, open a web browser and enter the following in the address box:

http://localhost:5000

38.) You will see the KernelCI Website home page from which, you can navigate to the different builds and Trees that you've created (see Example Builds below)


39.) Click on the Jobs button at the top of the page and you will see all of the available Trees 


40.) Click on the cip-tyrannosaurus Tree and you will see the list of available builds, or kernel versions.


41.) Click on the v4.4.27 kernel and you will see the list of build configurations. The tinyconfig configuration is shown below, but the allnoconfig is also available.


42.) The files that resulted from the build are available in the KernelCI website by navigating to the Tree Name, Kernel version, and Configuration. They are stored on the hard drive at:

``` /var/www/images/kernel-ci/TREE_NAME/KERNEL_VERSION/ARCH_CONFIG ```

For instance, for the build with the following parameters: 

   * TREE_NAME: **cip-tyrannosaurus**
   * KERNEL_VERSION: **v4.4.27**
   * ARCH_CONFIG: **arm_tinyconfig**

The files will be located at:

``` /var/www/images/kernel-ci/cip-tyrannosaurus/v4.4.27/arm-tinyconfig ```

Kernel CI generates the following files:
* ```build.log``` shows the output of the build process to help track down any issues in compilation.
* ```kernel.config``` holds the configuration of which features the kernel was built with.
* ```system.map``` is the kernel's symbol table that is used to debug kernel runtime errors
* ```zImage``` is the compressed kernel image to be installed on target device
* ```dtbs``` directory which holds all of the generated Device Tree Binary's


## Example Builds ##

43.) Included in the /vagrant/scripts directory, there is a script named create_builds.sh. It clones the CIP Kernel and builds it with the following: Three different tree names and two different build configurations each.

* TREE_NAME=cip-tyrannosaurus
   * tinyconfig
   * allnoconfig

* TREE_NAME=cip-stegosaurus
   * sunxi_defconfig
   * axm55xx_defconfig

* TREE_NAME=cip-triceratops
   * tinyconfig
   * allnoconfig

