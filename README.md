# libvirt-hooks
Install scripts (hooks) of which extend and enhance the functionality of Libvirt Virtual Machines (VM). Hooks may run at either VM start or stop, and be VM-specific. Develop your own!

**[View master branch...](https://github.com/portellam/libvirt-hooks/tree/master)**

#### Related Projects:
**[Auto X.Org](https://github.com/portellam/auto-xorg) | [Deploy VFIO](https://github.com/portellam/deploy-vfio) | [Generate Evdev](https://github.com/portellam/generate-evdev) | [Guest Machine Guide](https://github.com/portellam/guest-machine-guide) | [Power State Virtual Machine Manager](https://github.com/portellam/powerstate-virtmanager)**

## Table of Contents
- [Why?](#why)
- [Download](#download)
- [Usage](#usage)
- [Current Features](#current-features)
  - [1. `cfscpu`](#1-cfscpu)
  - [2. `hugepages`](#2-hugepages)
  - [3. `isolcpu`](#3-isolcpu)
  - [4. `nosleep`](#4-nosleep)
  - [5. `dosleep`](#5-dosleep)
- [Planned Features](#planned-features)
  - [1. `ddcutil`](#1-ddcutil)
  - [2. `beforeoff-dohibernate`](#2-beforeoff-dohibernate)
  - [3. `dohibernate`](#3-dohibernate)
  - [4. `virtual-nas`](#4-virtual-nas)
- [How to Develop Custom Features](#how-to-develop-custom-features)
  - [1. How a Hook Works](#how-a-hook-works)
  - [2. How to Implement a New Hook](#how-to-implement-a-new-hook)
    - [2.a. `set-hooks`](#2a-set-hooks)
    - [2.b. `set-service`](#2b-set-service)
    - [2.c. Copying a New Hook to Some or All Guests](#2c-copying-a-new-hook-to-some-or-all-guests)
  - [References](#references)
  - [Hook](#hook)
  - [Hugepages](#hugepages)
  - [`isolcpu`](#isolcpu)
  - [`nosleep`](#nosleep)
  - [VFIO](#vfio)
  - [VFIO-Tools](#vfio-tools)
- [Credits](#credits)
- [Disclaimer](#disclaimer)
- [Contact](#contact)

## Contents
### Why?
Libvirt is a tool which manages VMs (Guests) and the platforms which run those Guests (example: QEMU, KVM). Libvirt includes logic to watch for specific events on the Host OS (ex: Linux) to allow for script execution.

Scripts are not available out-of-the-box in Libvirt, but are possible if you understand Linux, `systemd`, and a scripting language (ex: Bash, Python). **This is not acceptable,** should we as a [community](#9-credits) wish to attract newcomers to VMs, [VFIO](#vfio), and Linux as a whole.

To assist beginners (and others), included are some incredibly necessary scripts for Guests.
To assist eager enthusiasts who wish to develop new Hooks, [see below](#7-how-to-develop-custom-features).

### Download
- To download this script, you may:
  - Download the ZIP file:
    1. Viewing from the top of the repository's (current) webpage, click the green `<> Code ` drop-down icon.
    2. Click `Download ZIP`. Save this file.
    3. Open the `.zip` file, then extract its contents.

  - Clone the repository:
    1. Open a Command Line Interface (CLI).
      - Open a console emulator (for Debian systems: Konsole).
      - Open a existing console: press `CTRL` + `ALT` + `F2`, `F3`, `F4`, `F5`, or `F6`.
        - **To return to the desktop,** press `CTRL` + `ALT` + `F7`.
        - `F1` is reserved for debug output of the Linux kernel.
        - `F7` is reserved for video output of the desktop environment.
        - `F8` and above are unused.

    2. Change your directory to your home folder or anywhere safe: `cd ~`
    3. Clone the repository: `git clone https://www.github.com/portellam/libvirt-hooks`

- To make this script executable, you must:
  1. Open the CLI (see above).
  2. Go to the directory of where the cloned/extracted repository folder is: `cd name_of_parent_folder/libvirt-hooks/`
  3. Make the installer script file executable: `chmod +x installer.bash`
    - Do **not** make any other script files executable. The installer will perform this action.
    - Do **not** make any non-script file executable. This is not necessary and potentially dangerous.

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
References are either links to technical documentation or original sources.

#### 1. `cfscpu`
- Set CPU thread priority in CPU scheduler.<sup>[6](#vfio-tools)</sup>

#### 2. `hugepages`
- Allocate Host RAM to pages for Guest(s).<sup>[2](#hugepages)</sup> <sup>[6](#vfio-tools)</sup>

#### 3. `isolcpu`
- Isolate CPU threads from Host, to allocate to Guest(s).<sup>[3](#isolcpu)</sup> <sup>[6](#vfio-tools)</sup>

#### 4. `nosleep`
- Prevent Host sleep if Guest is running.<sup>[4](#nosleep)</sup>

#### 5. `dosleep`
- Sleep Guest at Host sleep.<sup>[4](#nosleep)</sup>
- Stops `nosleep` service.

### Planned Features
References are either links to technical documentation or original sources.

#### 1. `ddcutil`
- Switch active monitor input at VM start.<sup>[6](#vfio-tools)</sup>

#### 2. `beforeoff-dohibernate`
- Hibernate Guest at Host shutdown.
- Stops `nosleep` service.

#### 3. `dohibernate`
- Hibernate Guest at Host sleep.
- Stops `nosleep` service.

#### 4. `virtual-nas`
- Share designated Host directory storage to Guest, on a file server over a Libvirt virtual network.
- Helpful for circumstances where a given Guest cannot be trusted with direct access to storage.
    - For Read-Write permissions: ensure file system integrity.
    - For Read-only permissions: preventing malware transmission.
    - Virtualizing an untrusted or legacy OS (example: Windows XP).

### How to Develop Custom Features
#### 1. How a Hook Works
Review [this article](#91-hook) before continuing.

#### 2. How to Implement a New Hook
Lorem ipsum.

##### 2.a. `set-hooks`
Lorem ipsum.

##### 2.b. `set-service`
Lorem ipsum.

##### 2.c. Copying a New Hook to Some or All Guests
Lorem ipsum.

### References
#### Hook
&ensp;<sub>**[Hooks article (Libvirt.org)](https://libvirt.org/hooks.html)**</sub>

#### Hugepages
&ensp;<sub>**[Arch Wiki article](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Huge_memory_pages)**</sub>

#### `isolcpu`
&ensp;<sub>**[Arch Wiki article](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#CPU_pinning)**</sub>

#### `nosleep`
&ensp;<sub>**[libvirt-nosleep (Arch Wiki article)](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Host_lockup_if_Guest_is_left_running_during_sleep)**</sub>

#### VFIO
&ensp;<sub>**[VFIO article (Linux kernel documentation)](https://www.kernel.org/doc/html/latest/driver-api/vfio.html)**</sub>

#### VFIO-Tools
&ensp;<sub>**[VFIO-Tools source (GitHub)](https://github.com/PassthroughPOST/VFIO-Tools)**</sub>

### Credits
Some of what you see here is directly inspired by others' work, from either the [Arch Wiki](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF) or the [Reddit forum](https://old.reddit.com/r/VFIO).

### Disclaimer
Use at your own risk. As stated in [this article](#hook), avoid recursion in your Hooks. This can lead to at worst a deadlock of all Guests or at best the failure of a single Guest to start.

### Contact
Did you encounter a bug? Do you need help? Notice any dead links? Please contact by [raising an issue](https://github.com/portellam/libvirt-hooks/issues) with the project itself.

## TODO:
- [ ] what is the installer doing? Is `/usr/local/bin/` necessary? Maybe use it as an updater?
- [ ] explain how to extend functionality using this project as a guide.
