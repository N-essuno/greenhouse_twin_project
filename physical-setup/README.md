# Physical Setup

This documents serves to provide step by step instructions to exactly reproduce our setup.

In our greenhouse we use a total of 4 Raspberry Pi 4 but in theory only one is strictly necessary.
The responsibility that each pc has is as follows:

- a _Controller_
- an _Actuator_
- a Router
- a Host

As we can see the Router - used for the local network we're setting up - does not have to be a Raspberry and if you want to reproduce we would strongly recommend using a standard off-the-shelf router instead. Nonetheless this tutorial will also provide a basic guide on how to setup a raspberry as a wireless access point. The host computer can also act as the AP.

We can use whichever computer we want as the host, this guide will assume your host computer runs a Debian based linux distribution but any OS should work with minimal changes.

The _Controller_ and _Actuator_ can be run on the same raspberry with minimal changes.

For each computer we provide a bash script to help quickly setting up the computers. You will need to connect the computers to the internet before. If you're struggling like us with eduroam we can refer you to the [tutorial](https://inrg.soe.ucsc.edu/howto-connect-raspberry-to-eduroam/) made by the University of California :)

## OS Choice

We used the, at the time, latest distribution of `Raspberry Pi OS 64bit`. Any compatible operating system will work in practice, use the 32bit version if your raspberry is not compatible with 64bit operating systems (older than the Pi 4 and the Pi 4 with 4GB of RAM). It is also recommended to have a desktop environment at least on the host computer for a simpler data analysis.

We recommend using the [Raspberry Pi Imager](https://www.raspberrypi.com/software) which can also be installed with apt: `sudo apt install rpi-imager`

## Host Setup

On the host computer we will need to install InfluxDB, in our project we used versions 2.X

> **NOTE** if you use a Raspberry for this step it has to have a 64bit architecture

You can follow the [official guide](https://docs.influxdata.com/influxdb/v2.7/install/?t=Raspberry+Pi) or the [`bash` script](scripts/host.sh) we provide.

We will also need to clone the [Smol Scheduler](https://www.github.com/N-essuno/smol-scheduler) repo, the script above will also do that.

## Router Setup

1. If you have a cable connection connect the Ethernet cable to the Raspberry
2. Make sure the system is up to date
    - `sudo apt update && sudo apt upgrade -y`
3. Use raspi-config to open the network manager
    - `sudo raspi-config`
    - navigate to "Advanced Options"
    - navigate to "Network COnfig"
    - select "Network Manager" and click "Ok"
    - select "Yes" when asked for reboot
4. From the Desktop, click on the Network icon, select "Advanced Options" and then "Create Wireless Hotspot"
5. Set the Network name, security to "WPA2" and set a password
6. Reboot the Raspberry

### Making it start on boot

1. Click on the Network icon and go to "Advanced Options" and navigate to "Edit Connections"
2. Select you access point network and click on the gear icon in the bottom left corner of the window
3. Under the general tab, check "Connect automatically with priority" and set the priority to 0
4. Click save

<!-- TODO: fix images, make your own -->

## Controller setup

A step by step guide on how to set up each sensor is provided [here](controller-instructions.md), if you have installed everything hardware-wise, a simple script is provided [here](scripts/controller.sh) to aid you in the installation of all the libraries and packages. Note that you will still need to install the adafruit library after the computer reboots with `pip3 install adafruit-circuitpython-dht`

## Actuator setup

As for the controller we provide a simple guide [here](actuator-instructions.md) and a script [here](scripts/actuator.sh).

---

You are more than welcome to contribute - by opening a PR - to these guides in case you found yourself using some other sensors. This is meant to be as much as possible an all-encompassing guide for anyone that wishes to recreate this setup.
