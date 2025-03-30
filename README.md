# Libvirt Hooks
### v1.0.2
Install scripts (hooks) of which extend and enhance the functionality of Libvirt
Virtual Machines (VMs). Hooks may run at either VM start or stop, and/or be
VM-specific. Develop your own, too!

## [Download](#4-download)
#### View this repository on [Codeberg][01], [GitHub][02].
[01]: https://codeberg.org/portellam/libvirt-hooks
[02]: https://github.com/portellam/libvirt-hooks
##

## Table of Contents
- [1. Why?](#1-why)
- [2. Related Projects](#2-related-projects)
- [3. Documentation](#3-documentation)
- [4. Download](#4-download)
- [5. Usage](#5-usage)
- [6. Current Features](#6-current-features)
- [7. Planned Features](#7-planned-features)
- [8. Credits](#8-credits)
- [9. Disclaimer](#9-disclaimer)
- [10. Contact](#10-contact)
- [11. References](#11-references)

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
To view other relevant projects, visit [Codeberg][21]
or [GitHub][22].

[21]: https://codeberg.org/portellam/vfio-collection
[22]: https://github.com/portellam/vfio-collection

### 3. Documentation
- What is VFIO?[<sup>[9]</sup>](#9)
- VFIO Discussion and Support[<sup>[8]</sup>](#8)
- Hardware-Passthrough Guide[<sup>[7]</sup>](#7)

### 4. Download
- Download the Latest Release:&ensp;[Codeberg][51], [GitHub][52]

- Download the `.zip` file:
    1. Viewing from the top of the repository's (current) webpage, click the
        drop-down icon:
        - `···` on Codeberg.
        - `<> Code ` on GitHub.
    2. Click `Download ZIP` and save.
    3. Open the `.zip` file, then extract its contents.

- Clone the repository:
    1. Open a Command Line Interface (CLI) or Terminal.
        - Open a console emulator (for Debian systems: Konsole).
        - **Linux only:** Open an existing console: press `CTRL` + `ALT` + `F2`,
        `F3`, `F4`, `F5`, or `F6`.
            - **To return to the desktop,** press `CTRL` + `ALT` + `F7`.
            - `F1` is reserved for debug output of the Linux kernel.
            - `F7` is reserved for video output of the desktop environment.
            - `F8` and above are unused.
    2. Change your directory to your home folder or anywhere safe:
        - `cd ~`
    3. Clone the repository:
        - `git clone https://www.codeberg.org/portellam/libvirt-hooks`
        - `git clone https://www.github.com/portellam/libvirt-hooks`

[51]: https://codeberg.org/portellam/libvirt-hooks/releases/latest
[52]: https://github.com/portellam/libvirt-hooks/releases/latest

### 5. Usage
#### 5.1. Verify Installer is Executable
1. Open the CLI (see [Download](#4-download)).

2. Go to the directory of where the cloned/extracted repository folder is:
`cd name_of_parent_folder/libvirt-hooks//`

3. Make the installer script file executable: `chmod +x installer.bash`
    - Do **not** make any other script files executable. The installer will perform
  this action.
    - Do **not** make any non-script file executable. This is not necessary and
  potentially dangerous.

#### 5.2. `installer.bash`
- From within project folder, execute: `sudo bash installer.bash`

  ```xml
  -h, --help               Print this help and exit.
  -i, --install            Install Libvirt Hooks to system.
  -u, --uninstall          Uninstall Libvirt Hooks from system.
  ```
  - The installer will place Libvirt Hooks in `/etc/libvirt/hooks/`.
  - The installer will place all project script files in `/usr/local/bin/`.

### 6. Current Features
#### 7.1. `cfscpu`
- Set CPU thread priority in CPU scheduler.
- [Source](#6)

#### 6.2. `hugepages`
- Allocate Host RAM to pages for Guest(s).
- [Documentation](#5)
- [Source](#6)

#### 6.3. `isolcpu`
- Isolate CPU threads from Host, to allocate to Guest(s).
- [Documentation](#2)

#### 6.4. `nosleep`
- Prevent Host sleep if Guest is running.
- [Documentation](#3)

#### 6.5. `dosleep`
- Sleep Guest at Host sleep.
- Stops [`nosleep`] service.

### 7. Planned Features
#### 7.1. `ddcutil`
- Switch active monitor input at VM start.
- [Source](#6)

#### 7.2. `beforeoff-dohibernate`
- Hibernate Guest at Host shutdown.
- Stops [`nosleep`] service.

#### 7.3. `dohibernate`
- Hibernate Guest at Host sleep.
- Stops [`nosleep`] service.

#### 7.4. `virtual-nas`
- Share designated Host directory storage to Guest, on a file server over a
Libvirt virtual network.
- Helpful for circumstances where a given Guest cannot be trusted with direct
access to storage.
    - For Read-Write permissions: ensure file system integrity.
    - For Read-only permissions: preventing malware transmission.
    - Virtualizing an untrusted or legacy OS (example: Windows XP).

[`nosleep`]: #64-nosleep

### 8. Credits
Some of what you see here is directly inspired by others' work, from either the
[Arch Wiki](#7) or the [Reddit forum](#8).

### 9. Disclaimer
Use at your own risk. As stated in [this article](#4), avoid recursion in
your Hooks. This can lead to at worst a deadlock of the Host (and all Guests) or
at best the failure of a single Guest to start.

### 10. Contact
Do you need help? Please visit the [Issues][101] page.

[101]: https://github.com/portellam/libvirt-hooks/issues

### 11. References
#### 1.
&nbsp;&nbsp;**Calling libvirt functions from within a hook script**. Hooks for Specific
System Management - libvirt. Accessed June 14, 2024.

&nbsp;&nbsp;&nbsp;&nbsp;<sup>https://libvirt.org/hooks.html#calling-libvirt-functions-from-within-a-hook-script.</sup>

#### 2.
&nbsp;&nbsp;**CPU Pinning**. PCI passthrough via OVMF - ArchWiki. Accessed June 14, 2024.

&nbsp;&nbsp;&nbsp;&nbsp;<sup>https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#CPU_pinning.</sup>

#### 3.
&nbsp;&nbsp;**Hooks for Specific System Management**. libvirt. Accessed June 14, 2024.

&nbsp;&nbsp;&nbsp;&nbsp;<sup>https://libvirt.org/hooks.html.</sup>

#### 4.
&nbsp;&nbsp;**Host lockup if Guest is left running during sleep**. PCI passthrough via OVMF
ArchWiki. Accessed June 14, 2024.

&nbsp;&nbsp;&nbsp;&nbsp;<sup>https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Host_lockup_if_Guest_is_left_running_during_sleep.</sup>

#### 5.
&nbsp;&nbsp;**Huge memory pages**. PCI passthrough via OVMF - ArchWiki. Accessed June 14,
2024.

&nbsp;&nbsp;&nbsp;&nbsp;<sup>https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Huge_memory_pages.</sup>

#### 6.
&nbsp;&nbsp;**PassthroughPOST/VFIO-Tools: A Collection of Tools and Scripts That Aim to**
**MakePCI Passthrough a Little Easier**. GitHub. Accessed June 14, 2024.

&nbsp;&nbsp;&nbsp;&nbsp;<sup>https://github.com/PassthroughPOST/VFIO-Tools.</sup>

#### 7.
&nbsp;&nbsp;**PCI passthrough via OVMF**. ArchWiki. Accessed June 14, 2024.

&nbsp;&nbsp;&nbsp;&nbsp;<sup>https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF.</sup>

#### 8.
&nbsp;&nbsp;**r/VFIO**. Accessed June 14, 2024.

&nbsp;&nbsp;&nbsp;&nbsp;<sup>https://www.reddit.com/r/VFIO/.</sup>

#### 9.
&nbsp;&nbsp;**VFIO - ‘Virtual Function I/O’ - The Linux Kernel Documentation**.
The linux kernel. Accessed June 14, 2024.

&nbsp;&nbsp;&nbsp;&nbsp;<sup>https://www.kernel.org/doc/html/latest/driver-api/vfio.html.</sup>
##

#### Click [here](#libvirt-hooks) to return to the top of this document.