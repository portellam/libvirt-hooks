# libvirt-hooks
## TODO:
- what is the installer doing? Is `/usr/local/bin/` necessary? Maybe use it as an updater?
- explain how to extend functionality using this project as a guide.

## Table of Contents
- [1. About](#1-about)
- [2. Why?](#2-why)
- [3. Download](#3-download)
- [4. Usage](#5-usage)
- [5. Current Features](#5-current-features)
  - [5.0. Description](#50-description)
  - [5.1. `cfscpu`](#51-cfscpu)
  - [5.2. `hugepages`](#52-hugepages)
  - [5.3. `isolcpu`](#53-isolcpu)
  - [5.4. `nosleep`](#54-nosleep)
  - [5.5. `dosleep`](#55-dosleep)
- [6. Planned Features](#6-planned-features)
  - [6.0. Description](#60-description)
  - [6.1. `ddcutil`](#61-ddcutil)
  - [6.2. `beforeoff-dohibernate`](#62-beforeoff-dohibernate)
  - [6.3. `dohibernate`](#63-dohibernate)
  - [6.4. `virtual-nas`](#64-virtual-nas)
- [7. How to Develop Custom Features](#7-how-to-develop-custom-features)
  - [7.1. How a Hook Works](#71-how-a-hook-works)
  - [7.2. How to Implement a New Hook within this Project](#72-how-to-implement-a-new-hook-within-this-project)
- [8. References](#8-references)
  - [8.1. Hook](#81-hook)
  - [8.2. Hugepages](#82-hugepages)
  - [8.3. `isolcpu`](#83-isolcpu)
  - [8.4. `nosleep`](#84-nosleep)
  - [8.5. VFIO](#85-vfio)
  - [8.6. VFIO-Tools](#86-vfio-tools)
- [9. Credits](#9-credits)
- [10. Disclaimer](#10-disclaimer)
- [11. Contact](#11-contact)

## 1. About
Install scripts (hooks) of which extend and enhance the functionality of Libvirt Virtual Machines (VM). Hooks may run at either VM start or stop, and be VM-specific. Develop your own Hooks by reviewing the existing hooks as a reference guide. See [Features](#features) for more information.

## 2. Why?
Libvirt is a tool which manages VMs (Guests) and the platforms which run those Guests (example: QEMU, KVM, etc). Libvirt includes logic to watch for specific events on the Host OS (ex: Linux) to allow for script execution.

Scripts are not available out-of-the-box in Libvirt, but are possible if you understand Linux, `systemd`, and a scripting language (ex: Bash, Python). **This is not acceptable,** should we as a [community](#9-credits) wish to attract newcomers to VMs, [VFIO](#85-vfio), and Linux as a whole.

To assist beginners (and others), included are some incredibly necessary scripts for Guests.
To assist eager enthusiasts who wish to develop new Hooks, [see below](#7-how-to-develop-custom-features).

## 3. Download
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

## 4. Usage
### `installer.bash`
- From within project folder, execute: `sudo bash installer.bash`

  ```xml
  -h, --help               Print this help and exit.
  -i, --install            Install Libvirt Hooks to system.
  -u, --uninstall          Uninstall Libvirt Hooks from system.
  ```
  - The installer will place Libvirt Hooks in `/etc/libvirt/hooks/`.
  - The installer will place all project script files in `/usr/local/bin/`.

## 5. Current Features
### 5.0. Description
References are either links to technical documentation or original sources.

### 5.1. `cfscpu`
- Set CPU thread priority in CPU scheduler.<sup>[6](#96-vfio-tools)</sup>

### 5.2. `hugepages`
- Allocate Host RAM to pages for Guest(s).<sup>[2](#92-hugepages)</sup> <sup>[6](#96-vfio-tools)</sup>

### 5.3. `isolcpu`
- Isolate CPU threads from Host, to allocate to Guest(s).<sup>[3](#93-isolcpu)</sup> <sup>[6](#96-vfio-tools)</sup>

### 5.4. `nosleep`
- Prevent Host sleep if Guest is running.<sup>[4](#94-nosleep)</sup>

### 5.5. `dosleep`
- Sleep Guest at Host sleep.<sup>[4](#94-nosleep)</sup>
- Stops `nosleep` service.

## 6. Planned Features
### 6.0. Description
References are either links to technical documentation or original sources.

### 6.1. `ddcutil`
- Switch active monitor input at VM start.<sup>[6](#96-vfio-tools)</sup>

### 6.2. `beforeoff-dohibernate`
- Hibernate Guest at Host shutdown.
- Stops `nosleep` service.

### 6.3. `dohibernate`
- Hibernate Guest at Host sleep.
- Stops `nosleep` service.

### 6.4. `virtual-nas`
- Share designated Host directory storage to Guest, on a file server over a Libvirt virtual network.
- Helpful for circumstances where a given Guest cannot be trusted with direct access to storage.
    - For Read-Write permissions: ensure file system integrity.
    - For Read-only permissions: preventing malware transmission.
    - Virtualizing an untrusted or legacy OS (example: Windows XP).

## 7. How to Develop Custom Features
### 7.1. How a Hook Works
Review [this article](#91-hook) before continuing.

### 7.2. How to Implement a New Hook within this Project
Lorem ipsum.

#### 7.2.a. `set-hooks`
Lorem ipsum.

#### 7.2.b. `set-service`
Lorem ipsum.

#### 7.2.c. Copying new Hook to some or all Guests
Lorem ipsum.

## 8. References
#### 8.1. Hook
&ensp;<sub>**[Hooks article (Libvirt.org)](https://libvirt.org/hooks.html)**</sub>

#### 8.2. Hugepages
&ensp;<sub>**[Arch Wiki article](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Huge_memory_pages)**</sub>

#### 8.3. `isolcpu`
&ensp;<sub>**[Arch Wiki article](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#CPU_pinning)**</sub>

#### 8.4. `nosleep`
&ensp;<sub>**[libvirt-nosleep (Arch Wiki article)](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Host_lockup_if_Guest_is_left_running_during_sleep)**</sub>

#### 8.5. VFIO
&ensp;<sub>**[VFIO article (Linux kernel documentation)](https://www.kernel.org/doc/html/latest/driver-api/vfio.html)**</sub>

#### 8.6. VFIO-Tools
&ensp;<sub>**[VFIO-Tools source (GitHub)](https://github.com/PassthroughPOST/VFIO-Tools)**</sub>

## 9. Credits
Some of what you see here is directly inspired by others' work, from either the [Arch Wiki](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF) or the [Reddit forum](https://old.reddit.com/r/VFIO).

## 10. Disclaimer
Use at your own risk. As stated in [this article](#91-hook), avoid recursion in your Hooks. This can lead to at worst a deadlock or at best the failure of a single Guest to start.

## 11. Contact
Did you encounter a bug? Do you need help? Notice any dead links? Please contact by [raising an issue](https://github.com/portellam/libvirt-hooks/issues) with the project itself.