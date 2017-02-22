# Board-at-Desk Single-Developer Kernel CI & LAVA VM Setup & Configuration #

This repository creates a Virtual Machine that contains Kernel CI and LAVA. 
Kernel CI is used to build, boot and report results where LAVA is used to offer 
a robust automated testing language, a testing engine and reporting results. 
This project is tailored to the needs of the Civil Infrastructure Platform 
(http://www.cip-platform.org).

## Setting up the LAVA2 Server for testing custom Linux kernels ##

1.) Clone the ```board-at-desk-single-dev``` repository

```user@host ~$ git clone https://gitlab.com/cip-project/board-at-desk-single-dev.git```

```user@host ~$ cd board-at-desk-single-dev```

```user@host ~/board-at-desk-single-dev$```

2.) Start the Virtual Machine

```user@host ~/board-at-desk-single-dev$ vagrant up```

3.) SSH into the Virtual Machine

```user@host ~/board-at-desk-single-dev$ vagrant ssh``

## Create a Superuser Account ##

4.) Set up a Superuser for Lava Job maintenance. 

```vagrant@guest:~$ sudo lava-server manage createsuperuser --username lavauser --email=lavauser@lava.co.uk```

```Password: mylava1234```

```Password (again): mylava1234```

```Superuser created successfully.```

*Note: Replace <lavauser> with your desired username and replace <lavauser@lava.co.uk> with that user’s email address. Select a password and enter it twice.*

## Set Connection to Board ##

5.) Change localhost to host's IP (Machine that is connected serially to board): 

```vagrant@guest:~$ sed -i 's/localhost/<host_ip>/g' mybbb.dat```

6.) Update device dictionary: 

```vagrant@guest:~$ sudo lava-server manage device-dictionary –hostname bbb01 –import mybbb.dat```

## Navigate to the LAVA Homepage ##

7.) On your host machine, open a web browser and enter the following in the address box:

http://localhost:8080


8.) The LAVA Home Page is displayed in your web browser. Log in to the web server as the superuser:

   a.) Click the login link in the upper right-hand corner of the Lava Server website

   b.) Enter the username: lavauser

   c.) Enter the password: mylava1234


## Create the Heath Check Job for both Devices##

9.) Click on **Device Types** under lava_scheduler_app

10.) Click on the **qemu** device type

11.) Copy and past the contents of the file ```/vagrant/device-types/qemu-health-check.yaml``` into the Health check job textbox.

12.) Click on the **Save** button in the lower right-hand corner of the page

*Note: Once the health-check job is saved to the device type, the job is automatically started by LAVA.*

13.) Click on the **bbb01** device type

14.) Copy and past the contents of the file ```/vagrant/device-types/beaglebone-black-health-check.yaml``` into the Health check job textbox.

15.) Click on the **Save** button in the lower right-hand corner of the page

## Building and Testing the CIP Kernel ##

### Get CIP Kernel using git ##

16.) Change to the git-repos directory

```vagrant@guest:~$ cd git-repos```

17.) Clone the CIP Linux Kernel

```vagrant@guest:~/git-repos$ git clone git://git.kernel.org/pub/scm/linux/kernel/git/bwh/linux-cip.git```

18.) Find the branch of the kernel version you want (i.e. 4.4.27)

```vagrant@guest:~/git-repos$ cd linux-cip```

```vagrant@guest:~/git-repos/linux-cip$ git tag -l | grep 4.4.y```

19.) Create a new branch using that tag.

```vagrant@guest:~/git-repos/linux-cip$ git checkout -b cip_v4.4.27 v4.4.27```


## Compile CIP Kernel ##

20.) Set the environment variables. You can create a tree name that describes your project. Select the Architecture of the target device (i.e. arm, arm64, mips, i386, amd64, etc...). Choose the cross compiler you need for that architecture.

```vagrant@guest:~/git-repos/linux-cip$ export TREE_NAME=cip-test```

```vagrant@guest:~/git-repos/linux-cip$ export ARCH=arm```

```vagrant@guest:~/git-repos/linux-cip$ export CROSS_COMPILE=arm-linux-gnueabihf-```

*Note: Don't forget the dash (-) at the end of the ```CROSS_COMPILE``` line!*

21.) Execute the build.py command, passing in the configuration you require for your project.

```vagrant@guest:~/git-repos/linux-cip$ ~/kernelci-build/build.py -c tinyconfig -p CIP-KernelCI```

22.) Start the Kernel CI Web Server with the following command:

```vagrant@guest:~$ /vagrant/scripts/start_webserver.sh &```

23.) On your host machine, open a web browser and enter the following in the address box:

http://localhost:5000

24.) You will see the KernelCI Website home page from which, you can navigate to the different builds and Trees that you've created (see Example Builds below)


25.) Click on the Jobs button at the top of the page and you will see all of the available Trees 


26.) Click on the Tree name (cip-tyrannosaurus) and you will see the list of available builds, or kernel versions for that tree.


27.) Click on the v4.4.27 kernel and you will see the list of build configurations. The tinyconfig configuration is shown below, but the allnoconfig is also available.


28.) The files that resulted from the build are available in the KernelCI website by navigating to the Tree Name, Kernel version, and Configuration. They are stored on the hard drive at:

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

29.) Included in the /vagrant/scripts directory, there is a script named create_builds.sh. It clones the CIP Kernel and builds it with the following: Three different tree names and two different build configurations each.

* TREE_NAME=cip-tyrannosaurus
   * tinyconfig
   * allnoconfig

* TREE_NAME=cip-stegosaurus
   * sunxi_defconfig
   * axm55xx_defconfig

* TREE_NAME=cip-triceratops
   * tinyconfig
   * allnoconfig

