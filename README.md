# libvirt-hooks

## Contents
* [About](#about)
* [How-to](#how-to)
* [Features](#features)
* [References](#references)
* [Disclaimer](#disclaimer)

## About
### Description:
Install Libvirt hooks (scripts) which extend and enhance the functionality of Libvirt domains (virtual machines). See [Features](#features) for more information.

#### Useful links
* [About VFIO](https://www.kernel.org/doc/html/latest/driver-api/vfio.html)
* [About](https://libvirt.org/hooks.html)

## How-to
#### To download, execute:

        git clone https://github.com/portellam/libvirt-hooks

### To install:

        sudo bash installer.bash -i

### To uninstall:

        sudo bash installer.bash -u

## Features
### cfscpu
  * Set CPU thread priority in CPU scheduler. <sup>[1](#1)</sup>
### ddcutil *(to be implemented in a future release)*
  * Switch active monitor input at domain start. <sup>[1](#1)</sup>
### beforeoff-dohibernate *(to be implemented in a future release)*
  * Hibernate domain at Host shutdown.
  * Stops *nosleep* service.
### dohibernate *(to be implemented in a future release)*
  * Hibernate domain at Host sleep.
  * Stops *nosleep* service.
### dosleep *(to be implemented in a future release)*
  * Sleep domain at Host sleep.
  * Stops *nosleep* service.
### hugepages
  * Allocate Host RAM to pages for domain(s). <sup>[1](#1)</sup> <sup>[2](#2)</sup>
### isolcpu
  * Isolate CPU threads from Host, to allocate to domain(s). <sup>[1](#1)</sup> <sup>[3](#3)</sup>
### nosleep
  * Prevent Host sleep if domain is running. <sup>[4](#4)</sup>

## References
#### 1.
<sub>Libvirt hooks | **[VFIO-Tools source (GitHub)](https://github.com/PassthroughPOST/VFIO-Tools)**</sub>

#### 2.
<sub>Hugepages | **[Arch wiki](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Huge_memory_pages)**</sub>

#### 3.
<sub>Isolcpu | **[Arch wiki](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#CPU_pinning)**</sub>

#### 4.
<sub>Nosleep | **[libvirt-nosleep (Arch wiki)](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Host_lockup_if_Guest_is_left_running_during_sleep)**</sub>

## Disclaimer:
Use at your own risk.