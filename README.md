# IOx App: Filehosting

With this application you can easily deploy a web-server and SMB file-server on your IOx network device.

This is a functioning sample code which you can modify to your needs.

Features:

* **Nginx**: Copy your files to /www inside the container and access/modify them on the IOx device (for example index.html)
* **Samba**: Copy your files to /samba inside the container and access/modify them via SMB.
	* username: smbuser
	* password: samba123!
* **Add other applications**: Simply install with the alpine Linux packet manager other applications and add them to the entrypoint.sh to start them when the container starts.

## Getting Started

### Prerequisites

You will need to have installed on your computer:

* Docker
* [ioxclient](https://developer.cisco.com/docs/iox/#!iox-resource-downloads) (only needed with IOx classic / LXC IOx applications)
* git

### Installing

#### 1. Repository
Clone the repository to your local computer:

```
git clone https://github.com/flopach/iox-filehosting
```

#### 2. Select Platform

Check the CPU architecture on your hardware (for example: ARM for IR1101, x86 for IC3000 and IR829/IR809) and edit the configuration files. With the character # we are commenting the other architecture out.

> Check out the [IOx Platform Support Matrix](https://developer.cisco.com/docs/iox/#!platform-support-matrix) for more information!

**ARM-based IOx devices**

Dockerfile:

```
# ARM or x86
#FROM alpine:latest
FROM arm64v8/alpine:latest
```

package.yaml:

```
app:
  #cpuarch: "x86_64"
  cpuarch: "aarch64"
```

**x86-based IOx devices**

Dockerfile:

```
# ARM or x86
FROM alpine:latest
#FROM arm64v8/alpine:latest
```

package.yaml:

```
app:
  cpuarch: "x86_64"
  #cpuarch: "aarch64"
```

#### 3. Edit Configuration files (optional)

You may edit the configuration files:

* **smb.conf**: Configure SMB access
* **nginx.conf**: Configure your nginx server
* **index.html**: Change the default website running on the server
* **entrypoint.sh**: Configure other applications which should run when the container starts

#### 4. Building the Package file

Build the package file (.tar) for your IOx device. Open a terminal where you cloned the repository.

**Docker native (IOx 2.0)**

The docker runtime runs on the IOx device. You don not need the ioxclient for packaging.

```
Computer:iox-filehosting$ docker build -t iox-filehosting .
Computer:iox-filehosting$ docker save iox-filehosting > iox-filehosting_dockernative.tar
```

**IOx classic (IOx 1.9 and earlier)**

The package will be built with a Dockerfile (and Docker image) and the ioxclient will package it to an IOx application.

```
Computer:iox-filehosting$ docker build -t iox-filehosting .
Computer:iox-filehosting$ ioxclient docker package iox-filehosting .
```

#### 5. Network-Configuration  

Before installing the IOx app on some devices you need to configure some network settings (e.g. this is not neccessary on the IC3000). This depends as well on the device. Here only the configuration for IOS XE based devices (specifcally IR1101) is given as an example.

For further information please visit the [IOx Documentation](https://developer.cisco.com/docs/iox).

**Example: Configuration with IOS XE (IR1101)**

> Also visit the documentation page: [IOx Application Hosting on IR1101](https://www.cisco.com/c/en/us/td/docs/routers/access/1101/software/configuration/guide/b_IR1101config/b_IR1101config_chapter_010001.html)

Config Information / IP addresses:

* IOx App: 192.168.1.2
* Virtual Port Group: 192.168.1.1
* VLAN88 on IR1101: 10.0.0.1

**1. Configuring the interfaces**

All IOx applications are bundeled together with the Virtual Port Group 0 where 192.168.1.x is defined for the network.

In order to access this network and the IOx application outside of the IR1101, a NAT is created to the VLAN interface (you can also use the Gigabit Ethernet 0/0/0 interface for that):

```
interface VirtualPortGroup0
ip address 192.168.1.1 255.255.255.0
ip nat inside
ip virtual-reassembly

interface Vlan88
ip address 10.0.0.1 255.255.255.0
ip nat outside
ip virtual-reassembly
```

Then we configure the network for the deployed application named "ioxfilehosting".

There we create a virtual interface (app-vnic) and give it the IP address 192.168.1.2. Also the default-gateway to the Virtual Port Group 0 is created:

```
app-hosting appid ioxfilehosting
 app-vnic gateway0 virtualportgroup 0 guest-interface 0
  guest-ipaddress 192.168.1.2 netmask 255.255.255.0
 app-default-gateway 192.168.1.1 guest-interface 0
```

Lastly, NAT rules are created so that the user can access the IOx application on the specific ports.

In the IOx application we use port 80 for nginx, however on the IR1101 the web ui (if enabled) is already using this port. Therefore, port 8000 is written in the configuration below. You can change it to any port you like.

```
ip nat inside source static udp 192.168.1.2 137 interface Vlan88 137
ip nat inside source static udp 192.168.1.2 445 interface Vlan88 445
ip nat inside source static udp 192.168.1.2 138 interface Vlan88 138
ip nat inside source static tcp 192.168.1.2 445 interface Vlan88 445
ip nat inside source static tcp 192.168.1.2 139 interface Vlan88 139
ip nat inside source static tcp 192.168.1.2 80 interface Vlan88 8000
```

Now you should be able to access ```nginx on http://10.0.0.1:8000``` and the SMB server on ```smb://10.0.0.1/samba```

#### 6. Installation

Simply install the application via Local Manager (UI), ioxclient, Field Network Director (FND) or Kinetic GMM.

For further information please visit the [IOx Documentation](https://developer.cisco.com/docs/iox).

## Hardware

This software can run on:

* Cisco IR1101
* Cisco IC3000
* Cisco IR829/IR809
* Catalyst 9300
* Catalyst 9400
* other selected IOx enabled devices

## Used Software

* Samba - SMB File Server 
* Nginx - HTTP File Server

## Versioning

**1.0** - Added basic functionality with Nginx, Samba and working configuration files

## Authors

* **Florian Pachinger** - *Initial work* - [flopach](https://github.com/flopach)

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE.md](LICENSE.md) file for details

## Further Links

* [Cisco DevNet Website](https://developer.cisco.com)