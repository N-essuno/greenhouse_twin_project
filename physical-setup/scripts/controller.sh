#!/bin/bash
# TODO: add some echoes

git clone https://www.github.com/N-essuno/greenhouse-data-collector

sudo apt update
sudo apt install -y \
    python3-pip \
    python3-spidev \
    python3-pyqt5 \
    python3-opengl \
    python3-picamera2 --no-install-recommends \
    opencv-python \
    libg11 \
    libatlas-base-dev

pip3 install opencv-python numpy

# Modifies boot config to enable the camera
sudo sed -i 's/# start_x=1/start_x=1/g' /boot/config.txt
sudo sed -i 's/# gpu_mem=128/gpu_mem=128/g' /boot/config.txt

sudo pip3 install --upgrade setuptools

# Install adafruit-circuitpython-dht library (we avoid using the deprecated Adafruit_DHT one)
git clone https://github.com/donskytech/raspberrypi-projects
cd raspberrypi-projects/dht22

# Install circuitpython dependecies
sudo pip3 install --upgrade adafruit-python-shell
# TODO: check if we can modify the script to avoid having to reboot
wget https://raw.githubusercontent.com/adafruit/Raspberry-Pi-Installer-Scripts/master/raspi-blinka.py

echo "When prompted for reboot select yes, afterwards you should install the library \
    with 'pip3 install adafruit-circuitpython-dht'"
sudo python3 raspi-blinka.py

exit 1
