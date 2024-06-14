# Libvirt Hooks
### v1.0.1
Install scripts (hooks) of which extend and enhance the functionality of Libvirt
Virtual Machines (VMs). Hooks may run at either VM start or stop, and/or be
VM-specific. Develop your own, too!

**Download the Latest Release:**&ensp;[Codeberg][codeberg-releases],
[GitHub][github-releases]

[codeberg-releases]: https://codeberg.org/portellam/libvirt-hooks/releases/latest
[github-releases]:   https://github.com/portellam/libvirt-hooks/releases/latest

## Table of Contents
- [Why?](#why)
- [Related Projects](#related-projects)
- [Documentation](#documentation)
- [Download](#download)
- [Usage](#usage)
- [Current Features](#current-features)
- [Planned Features](#planned-features)
- [Credits](#credits)
- [Disclaimer](#disclaimer)
- [Contact](#contact)
- [References](#references)

## Contents
### Why?
Libvirt is a tool which manages guests (VMs) and the platforms which run those
VMs (example: QEMU, KVM). Libvirt includes logic to watch for specific events
on the Host OS (ex: Linux) to allow for script execution.

Scripts are not available out-of-the-box in Libvirt, but are possible if you
understand Linux, `systemd`, and a scripting language (ex: Bash, Python).
**This is not acceptable** should we as a community wish to attract newcomers to
VMs, VFIO, and Linux as a whole.

To assist beginners (and others), included are some useful scripts for VMs.

### Related Projects
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

### Documentation
- [What is VFIO?](#9)
- [VFIO Forum](#8)
- [PCI Passthrough Guide](#7)

### Download
- To download this script, you may:
  - Download the ZIP file:
    1. Viewing from the top of the repository's (current) webpage, click the
       drop-down icon:
      - `···` on Codeberg.
      - `<> Code ` on GitHub.
    2. Click `Download ZIP`. Save this file.
    3. Open the `.zip` file, then extract its contents.

  - Clone the repository:
    1. Open a Command Line Interface (CLI).
      - Open a console emulator (for Debian systems: Konsole).
      - Open a existing console: press `CTRL` + `ALT` + `F2`, `F3`, `F4`, `F5`,
      or `F6`.
        - **To return to the desktop,** press `CTRL` + `ALT` + `F7`.
        - `F1` is reserved for debug output of the Linux kernel.
        - `F7` is reserved for video output of the desktop environment.
        - `F8` and above are unused.

    2. Change your directory to your home folder or anywhere safe: `cd ~`
    3. Clone the repository:
      - `git clone https://www.codeberg.org/portellam/libvirt-hooks`
      - `git clone https://www.github.com/portellam/libvirt-hooks`

- To make this script executable, you must:
  1. Open the CLI (see above).
  2. Go to the directory of where the cloned/extracted repository folder is: `cd name_of_parent_folder/libvirt-hooks/`
  3. Make the installer script file executable: `chmod +x installer.bash`
    - Do **not** make any other script files executable. The installer will perform
    this action.
    - Do **not** make any non-script file executable. This is not necessary and
    potentially dangerous.

### Usage
#### `installer.bash`
- From within project folder, execute: `sudo bash installer.bash`

  ```xml
  -h, --help               Print this help and exit.
  -i, --install            Install Libvirt Hooks to system.
  -u, --uninstall          Uninstall Libvirt Hooks from system.
  ```
  - The installer will place Libvirt Hooks in `/etc/libvirt/hooks/`.
  - The installer will place all project script files in `/usr/local/bin/`.

### Current Features
#### 1. `cfscpu`
- Set CPU thread priority in CPU scheduler.
- [Source](#6)

#### 2. `hugepages`
- Allocate Host RAM to pages for Guest(s).
- [Documentation](#5)
- [Source](#6)

#### 3. `isolcpu`
- Isolate CPU threads from Host, to allocate to Guest(s).
- [Documentation](#2)

#### 4. `nosleep`
- Prevent Host sleep if Guest is running.
- [Documentation](#3)

#### 5. `dosleep`
- Sleep Guest at Host sleep.
- Stops [`nosleep`] service.

### Planned Features
#### 1. `ddcutil`
- Switch active monitor input at VM start.
- [Source](#6)

#### 2. `beforeoff-dohibernate`
- Hibernate Guest at Host shutdown.
- Stops [`nosleep`] service.

#### 3. `dohibernate`
- Hibernate Guest at Host sleep.
- Stops [`nosleep`] service.

#### 4. `virtual-nas`
- Share designated Host directory storage to Guest, on a file server over a
Libvirt virtual network.
- Helpful for circumstances where a given Guest cannot be trusted with direct
access to storage.
    - For Read-Write permissions: ensure file system integrity.
    - For Read-only permissions: preventing malware transmission.
    - Virtualizing an untrusted or legacy OS (example: Windows XP).

[`nosleep`]: #5-nosleep

### Credits
Some of what you see here is directly inspired by others' work, from either the
[Arch Wiki](#7) or the [Reddit forum](#8).

### Disclaimer
Use at your own risk. As stated in [this article](#4), avoid recursion in
your Hooks. This can lead to at worst a deadlock of the Host (and all Guests) or
at best the failure of a single Guest to start.

### Contact
Did you encounter a bug? Do you need help? Please visit the
**Issues page** ([Codeberg][codeberg-issues], [GitHub][github-issues]).

[codeberg-issues]: https://codeberg.org/portellam/libvirt-hooks/issues
[github-issues]:   https://github.com/portellam/libvirt-hooks/issues

### References
#### 1.
**Calling libvirt functions from within a hook script**. Hooks for Specific System Management - libvirt. Accessed June 14, 2024.
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
**Huge memory pages**. PCI passthrough via OVMF - ArchWiki. Accessed June 14, 2024.
<sup>https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Huge_memory_pages.</sup>

#### 6.
**PassthroughPOST/VFIO-Tools: A Collection of Tools and Scripts That Aim to**
**MakePCI Passthrough a Little Easier**. GitHub. Accessed June 14, 2024.
<sup>https://github.com/PassthroughPOST/VFIO-Tools.</sup>

#### 7.
**PCI passthrough via OVMF**. ArchWiki. Accessed June 14, 2024.
<sup>https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF.</sup>

#### 8.
**r/VFIO**. Accessed June 14, 2024.
<sup>https://www.reddit.com/r/VFIO/.</sup>

#### 9.
**VFIO - ‘Virtual Function I/O’ - The Linux Kernel Documentation**.
The linux kernel. Accessed June 14, 2024.
<sup>https://www.kernel.org/doc/html/latest/driver-api/vfio.html.</sup>