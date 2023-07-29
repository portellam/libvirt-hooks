# libvirt-hooks

## Contents
* [About](#About)
* [How-to](#How-to)
* [Features](#Features)
* [References](#References)
* [Disclaimer](#Disclaimer)

## About
### Description:
Scripts (hooks) for Libvirt domains (virtual machines) which run in the background. Scripts which extend and enhance the functionality of a Libvirt domain. See [Features](#Features) for more information.

#### Useful links
* [About VFIO](https://www.kernel.org/doc/html/latest/driver-api/vfio.html)
* [About](https://libvirt.org/hooks.html)

## How-to
### To install:

        sudo bash installer.bash -i

### To uninstall:

        sudo bash installer.bash -u

## Features
### cfscpu [1]
  * Set CPU thread priority in CPU scheduler.
### ddcutil [1]
  * Switch active monitor input at domain start.
### dohibernate
  * Hibernate domain at host hibernation.
  * Stops *nosleep* service.
### dosleep
  * Sleep domain at host sleep.
  * Stops *nosleep* service.
### hugepages [1] [3]
  * Allocate host RAM to pages for domain(s).
### isolcpu [1]
  * Isolate CPU threads from host, to allocate to domain(s).
### nosleep [4]
  * Prevent host sleep if given domain is running.

## References
#### 1.
<sub>Libvirt hooks | **[VFIO-Tools source (GitHub)](https://github.com/PassthroughPOST/VFIO-Tools)**</sub>

#### 2.
<sub>Hugepages | **[Arch wiki](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Huge_memory_pages)**</sub>

#### 3.
<sub>Isolcpu | **[Arch wiki](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#CPU_pinning)**</sub>

#### 4.
<sub>Nosleep **[libvirt-nosleep (Arch wiki)](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Host_lockup_if_Guest_is_left_running_during_sleep)**</sub>