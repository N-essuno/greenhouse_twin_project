# Steps to set up a raspberry pi as a wifi access point

1. Update the system:
    - `sudo apt-get update`
    - `sudo apt full-upgrade`
2. Install hostapd and dnsmasq:
    - `sudo apt-get install hostapd dnsmasq`
3. Configure dnsmasq:
    <!-- TODO -->
4. Set up static ip address for the raspberry pi:
    - `sudo nano /etc/dhcpcd.conf`
    - add `dhcp-host=ab:cd:ef:12:34:56,example-host,192.168.0.10,infinite`, where `ab:cd:ef:12:34:56` is the mac address of the raspberry pi, `example-host` is the hostname of the raspberry pi, and `infinite` is the lease time`

## Solve hostapd service being masked (inactive)

1. `sudo systemctl unmask hostapd`
2. `sudo systemctl enable hostapd`
3. `sudo systemctl start hostapd`
