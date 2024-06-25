# Libvirt Hooks
### v1.0.1
Install scripts (hooks) of which extend and enhance the functionality of Libvirt
Virtual Machines (VMs). Hooks may run at either VM start or stop, and/or be
VM-specific. Develop your own, too!

## [Download](#5-download)

## Table of Contents
- [1. Why?](#1-why)
- [2. Related Projects](#2-related-projects)
- [3. Documentation](#3-documentation)
- [4. Host Requirements](#4-host-requirements)
    - [4.1. Operating System](#41-operating-system)
    - [4.2. Software](#42-software)
    - [4.3. Hardware](#43-hardware)
- [5. Download](#5-download)
- [6. Usage](#6-usage)
    - [6.1. Verify Installer is Executable](#61-verify-script-is-executable)
    - [6.2. `installer.bash`](#61-installerbash)
- [7. Features](#7-features)
    - [7.1. `cfscpu`](#71-cfscpu)
    - [7.2. `hugepages`](#72-hugepages)
    - [7.3. `isolcpu`](#73-isolcpu)
    - [7.4. `nosleep`](#74-nosleep)
    - [7.5. `dosleep`](#75-dosleep)
- [8. Planned Features](#8-planned-features)
    - [8.1. `ddcutil`](#81-ddcutil)
    - [8.2. `beforeoff-dohibernate`](#82-beforeoff-dohibernate)
    - [8.3. `dohibernate`](#83-dohibernate)
    - [8.4. `virtual-nas`](#84-virtual-nas)
- [9. Credits](#9-credits)
- [10. Disclaimer](#10-disclaimer)
- [11. Contact](#11-contact)
- [12. References](#12-references)

## Contents
### 1. Why?
Libvirt is a tool which manages guests (VMs) and the platforms which run those
VMs (example: QEMU, KVM). Libvirt includes logic to watch for specific events
on the Host OS (ex: Linux) to allow for script execution.

Scripts are not available out-of-the-box in Libvirt, but are possible if you
understand Linux, `systemd`, and a scripting language (ex: Bash, Python).
**This is not acceptable** should we as a community wish to attract newcomers to
VMs, VFIO, and Linux as a whole.

To assist beginners (and others), included are some useful scripts for VMs.

### 2. Related Projects
| Project                             | Codeberg          | GitHub          |
| :---                                | :---:             | :---:           |
| Deploy VFIO                         | [link][codeberg1] | [link][github1] |
| Auto X.Org                          | [link][codeberg2] | [link][github2] |
| Generate Evdev                      | [link][codeberg3] | [link][github3] |
| Guest Machine Guide                 | [link][codeberg4] | [link][github4] |
| **Libvirt Hooks**                   | [link][codeberg5] | [link][github5] |
| Power State Virtual Machine Manager | [link][codeberg6] | [link][github6] |

[codeberg1]: https://codeberg.org/portellam/deploy-VFIO
[github1]:   https://github.com/portellam/deploy-VFIO
[codeberg2]: https://codeberg.org/portellam/auto-xorg
[github2]:   https://github.com/portellam/auto-xorg
[codeberg3]: https://codeberg.org/portellam/generate-evdev
[github3]:   https://github.com/portellam/generate-evdev
[codeberg4]: https://codeberg.org/portellam/guest-machine-guide
[github4]:   https://github.com/portellam/guest-machine-guide
[codeberg5]: https://codeberg.org/portellam/libvirt-hooks
[github5]:   https://github.com/portellam/libvirt-hooks
[codeberg6]: https://codeberg.org/portellam/powerstate-virtmanager
[github6]:   https://github.com/portellam/powerstate-virtmanager

### 3. Documentation
- [What is VFIO?](#8)
- [VFIO Discussion and Support](#9)
- [Hardware-Passthrough Guide](#7)
- [Virtual Machine XML Format Guide](#10)

### 4. Host Requirements
#### 4.1. Operating System
Linux.

#### 4.2. Software
- `Libvirt`
- `QEMU`

#### 4.3. Hardware
The following firmware options are supported and enabled (motherboard and CPU):
- IOMMU
    - For AMD machines:&nbsp;`AMD-Vi`
    - For Intel machines:&ensp;&nbsp;`VT-d`
    - For ARM architectures:&nbsp;`SMMU`

### 5. Download
- Download the Latest Release:&ensp;[Codeberg][codeberg-releases],
[GitHub][github-releases]

- Download the `.zip` file:
    1. Viewing from the top of the repository's (current) webpage, click the
        drop-down icon:
        - `···` on Codeberg.
        - `<> Code ` on GitHub.
    2. Click `Download ZIP` and save.
    3. Open the `.zip` file, then extract its contents.

- Clone the repository:
    1. Open a Command Line Interface (CLI).
        - Open a console emulator (for Debian systems: Konsole).
        - Open a existing console: press `CTRL` + `ALT` + `F2`, `F3`, `F4`, `F5`,  or
        `F6`.
            - **To return to the desktop,** press `CTRL` + `ALT` + `F7`.
            - `F1` is reserved for debug output of the Linux kernel.
            - `F7` is reserved for video output of the desktop environment.
            - `F8` and above are unused.
    2. Change your directory to your home folder or anywhere safe:
        - `cd ~`
    3. Clone the repository:
        - `git clone https://www.codeberg.org/portellam/libvirt-hooks`
        - `git clone https://www.github.com/portellam/libvirt-hooks`

[codeberg-releases]: https://codeberg.org/portellam/libvirt-hooks/releases/latest
[github-releases]:   https://github.com/portellam/libvirt-hooks/releases/latest

### 6. Usage
#### 6.1. Verify Installer is Executable
1. Open the CLI (see [Download](#5-download)).

2. Go to the directory of where the cloned/extracted repository folder is:
`cd name_of_parent_folder/libvirt-hooks/`

3. Make the installer script file executable: `chmod +x installer.bash`
    - Do **not** make any other script files executable. The installer will perform
  this action.
    - Do **not** make any non-script file executable. This is not necessary and
  potentially dangerous.

#### 6.2. `installer.bash`
- From within project folder, execute: `sudo bash installer.bash`

  ```xml
  -h, --help               Print this help and exit.
  -i, --install            Install Libvirt Hooks to system.
  -u, --uninstall          Uninstall Libvirt Hooks from system.
  ```
  - The installer will place Libvirt Hooks in `/etc/libvirt/hooks/`.
  - The installer will place all project script files in `/usr/local/bin/`.

### 7. Features
#### 7.1. `cfscpu`
- Set CPU thread priority in CPU scheduler.
- [Source](#6)

#### 7.2. `hugepages`
- Allocate Host RAM to pages for Guest(s).
- [Documentation](#5)
- [Source](#6)

#### 7.3. `isolcpu`
- Isolate CPU threads from Host, to allocate to Guest(s).
- [Documentation](#2)

#### 7.4. `nosleep`
- Prevent Host sleep if Guest is running.
- [Documentation](#3)

#### 7.5. `dosleep`
- Sleep Guest at Host sleep.
- Stops [`nosleep`] service.

### 8. Planned Features
#### 8.1. `ddcutil`
- Switch active monitor input at VM start.
- [Source](#6)

#### 8.2. `beforeoff-dohibernate`
- Hibernate Guest at Host shutdown.
- Stops [`nosleep`] service.

#### 8.3. `dohibernate`
- Hibernate Guest at Host sleep.
- Stops [`nosleep`] service.

#### 8.4. `virtual-nas`
- Share designated Host directory storage to Guest, on a file server over a
Libvirt virtual network.
- Helpful for circumstances where a given Guest cannot be trusted with direct
access to storage.
    - For Read-Write permissions: ensure file system integrity.
    - For Read-only permissions: preventing malware transmission.
    - Virtualizing an untrusted or legacy OS (example: Windows XP).

[`nosleep`]: #5-nosleep

### 9. Credits
Some of what you see here is directly inspired by others' work, from either the
[Arch Wiki](#7) or the [Reddit forum](#8).

### 10. Disclaimer
Use at your own risk. As stated in [this article](#4), avoid recursion in
your Hooks. This can lead to at worst a deadlock of the Host (and all Guests) or
at best the failure of a single Guest to start.

### 11. Contact
Did you encounter a bug? Do you need help? Please visit the
**Issues page** ([Codeberg][codeberg-issues], [GitHub][github-issues]).

[codeberg-issues]: https://codeberg.org/portellam/libvirt-hooks/issues
[github-issues]:   https://github.com/portellam/libvirt-hooks/issues

### 12. References
#### 1.
**Calling libvirt functions from within a hook script**. Hooks for Specific
System Management - libvirt. Accessed June 14, 2024.
<sup>https://libvirt.org/hooks.html#calling-libvirt-functions-from-within-a-hook-script.</sup>

#### 2.
**CPU Pinning**. PCI passthrough via OVMF - ArchWiki. Accessed June 14, 2024.
<sup>https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#CPU_pinning.</sup>

#### 3.
**Hooks for Specific System Management**. libvirt. Accessed June 14, 2024.
<sup>https://libvirt.org/hooks.html.</sup>

#### 4.
**Host lockup if Guest is left running during sleep**. PCI passthrough via OVMF
ArchWiki. Accessed June 14, 2024.
<sup>https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Host_lockup_if_Guest_is_left_running_during_sleep.</sup>

#### 5.
**Huge memory pages**. PCI passthrough via OVMF - ArchWiki. Accessed June 14,
2024.
<sup>https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Huge_memory_pages.</sup>

#### 6.
**PassthroughPOST/VFIO-Tools**. GitHub. Accessed June 14, 2024.
<sup>https://github.com/PassthroughPOST/VFIO-Tools.</sup>

#### 7.
**PCI passthrough via OVMF**. ArchWiki. Accessed June 14, 2024.
<sup>https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF.</sup>

#### 8.
**VFIO - ‘Virtual Function I/O’ - The Linux Kernel Documentation**.
The linux kernel. Accessed June 14, 2024.
<sup>https://www.kernel.org/doc/html/latest/driver-api/vfio.html.</sup>

#### 9.
**VFIO Discussion and Support**. Reddit. Accessed June 14, 2024.
<sup>https://www.reddit.com/r/VFIO/.</sup>

#### 10.
**XML Design Format**. GitHub - libvirt/libvirt. Accessed June 18, 2024.
<sup>https://github.com/libvirt/libvirt/blob/master/docs/formatdomain.rst.</sup>