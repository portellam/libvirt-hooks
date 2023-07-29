#!/bin/bash/env bash

#
# Filename:       installer.bash
# Description:    Manages libvirt-hooks binaries and files.
# Author(s):      Alex Portell <github.com/portellam>
# Maintainer(s):  Alex Portell <github.com/portellam>
#

# <params>
  readonly REPO_NAME="libvirt-hooks"
  readonly OPTION="${1}"

  # <summary>Execution Flags</summary>
    readonly DO_INSTALL=true

  # <summary>
  # Color coding
  # Reference URL: 'https://www.shellhacks.com/bash-colors'
  # </summary>
    readonly SET_COLOR_GREEN='\033[0;32m'
    readonly SET_COLOR_RED='\033[0;31m'
    readonly SET_COLOR_YELLOW='\033[0;33m'
    readonly RESET_COLOR='\033[0m'

  # <summary>Append output</summary>
    readonly PREFIX_ERROR="${SET_COLOR_YELLOW}An error occurred:${RESET_COLOR}"
    readonly PREFIX_FAIL="${SET_COLOR_RED}Failure:${RESET_COLOR}"
    readonly PREFIX_PASS="${SET_COLOR_GREEN}Success:${RESET_COLOR}"
# </params>

# <functions>
  function GetOption
  {
    case "${OPTION}" in
      "-u" | "--uninstall" )
        DO_INSTALL=false ;;

      "-i" | "--install" )
        DO_INSTALL=true ;;

      "-h" | "--help" | * )
        PrintUsage
        return 1 ;;
    esac

    return 0
  }

  function Main
  {
    if [[ $( whoami ) != "root" ]]; then
      echo -e "${PREFIX_ERROR} User is not sudo/root."
      exit 1
    fi

    GetOption || exit 1

    local BIN_DEST_PATH="/usr/local/bin/"
    local BIN_SOURCE_PATH="bin"
    local SERVICE_DEST_PATH="/etc/systemd/system/"
    local SERVICE_SOURCE_PATH="systemd"
    local HOOK_DEST_PATH="/etc/libvirt/hooks/"
    local HOOK_SOURCE_PATH="hooks"

    if "${DO_INSTALL}"; then
      if ! Install; then
        echo -e "${PREFIX_FAIL} Could not install ${REPO_NAME}."
        exit 1
      else
        echo -e "${PREFIX_PASS} Installed ${REPO_NAME}."
      fi
    else
      if ! Uninstall; then
        echo -e "${PREFIX_FAIL} Could not uninstall ${REPO_NAME}."
        exit 1
      else
        echo -e "${PREFIX_PASS} Uninstalled ${REPO_NAME}."
      fi

    fi

    exit 0
  }

  function DoBinariesExist
  {
    cd "${BIN_SOURCE_PATH}" || return 1

    if  [[ ! -e "libvirt-dohibernate" ]] \
      || [[ ! -e "libvirt-dosleep" ]]; then
      echo -e "${PREFIX_ERROR} Missing project binaries."
      return 1
    fi

    return 0
  }

  function DoHooksExist
  {
    cd "${HOOK_SOURCE_PATH}" || return 1

    if  [[ ! -e "cfscpu" ]] \
      || [[ ! -e "ddcutil" ]] \
      || [[ ! -e "dohibernate" ]] \
      || [[ ! -e "dosleep" ]] \
      || [[ ! -e "hugepages" ]] \
      || [[ ! -e "isolcpu" ]] \
      || [[ ! -e "nosleep" ]] \
      || [[ ! -e "qemu" ]] \
      || [[ ! -e "set-hooks" ]]; then
      echo -e "${PREFIX_ERROR} Missing project scripts."
      return 1
    fi

    return 0
  }

  function DoServicesExist
  {
    cd "${SERVICE_SOURCE_PATH}" || return 1

    if [[ ! -e "libvirt-dohibernate@.service" ]] \
      || [[ ! -e "libvirt-dosleep@.service" ]] \
      || [[ ! -e "libvirt-nosleep@.service" ]]; then
      echo -e "${PREFIX_ERROR} Missing project services."
      return 1
    fi

    return 0
  }

  function DoesDestinationPathExist
  {
    if [[ ! -d "${BIN_DEST_PATH}" ]]; then
      echo -e "${PREFIX_ERROR} Could not find directory '${BIN_DEST_PATH}'."
      return 1
    fi

    if [[ ! -d "${HOOK_DEST_PATH}" ]]; then
      echo -e "${PREFIX_ERROR} Could not find directory '${HOOK_DEST_PATH}'."
      return 1
    fi

    if [[ ! -d "${SERVICE_DEST_PATH}" ]] \
      && ! sudo mkdir -p "${SERVICE_DEST_PATH}"; then
      echo -e "${PREFIX_ERROR} Could not create directory '${SERVICE_DEST_PATH}'."
      return 1
    fi

    return 0
  }

  function CopyFilesToDesination
  {
    cd ..
    cd "${BIN_SOURCE_PATH}" || return 1

    if ! sudo cp -rf * "${BIN_DEST_PATH}" &> /dev/null; then
      echo -e "${PREFIX_ERROR} Failed to copy project binaries."
      return 1
    fi

    cd ..
    cd "${SCRIPT_SOURCE_PATH}" || return 1

    if ! sudo cp -rf * "${SCRIPT_DEST_PATH}" &> /dev/null; then
      echo -e "${PREFIX_ERROR} Failed to copy project script(s)."
      return 1
    fi

    cd .. || return 1
    cd "${SERVICE_SOURCE_PATH}" || return 1

    if ! sudo cp -rf * "${SERVICE_DEST_PATH}" &> /dev/null; then
      echo -e "${PREFIX_ERROR} Failed to copy project service(s)."
      return 1
    fi

    return 0
  }

  function Install
  {
    DoBinariesExist || return 1
    cd ..
    DoScriptsExist || return 1
    cd ..
    DoServicesExist || return 1
    DoesDestinationPathExist || return 1
    CopyFilesToDesination || return 1
    SetFilePermissions || return 1
  }

  function PrintUsage
  {
    IFS=$'\n'

    local -a OUTPUT=(
      "Usage:\tbash installer [OPTION]"
      "Manages ${REPO_NAME} binaries, scripts, and services.\n"
      "  -h, --help\t\tPrint this help and exit."
      "  -i, --install\t\tInstall project to system."
      "  -u, --uninstall\tUninstall project from system."
    )

    echo -e "${OUTPUT[*]}"
    unset IFS
    return 0
  }

  function SetFilePermissions
  {
    if ! sudo chown -R root:root "${BIN_DEST_PATH}" &> /dev/null \
      || ! sudo chmod -R +x "${BIN_DEST_PATH}" &> /dev/null \
      || ! sudo chmod -R +x "${HOOK_DEST_PATH}" &> /dev/null \
      || ! sudo chown -R root:root "${SERVICE_DEST_PATH}" &> /dev/null; then
      echo -e "${PREFIX_ERROR} Failed to set file permissions."
      return 1
    fi

    return 0
  }

  function Uninstall
  {
    if [[ -d "${BIN_DEST_PATH}" ]] \
      && ! rm -rf "${BIN_DEST_PATH}" &> /dev/null; then
      echo -e "${PREFIX_ERROR} Failed to delete project binaries."
      return 1
    fi

    if [[ -d "${HOOK_DEST_PATH}" ]] \
      && ! rm -rf "${HOOK_DEST_PATH}" &> /dev/null; then
      echo -e "${PREFIX_ERROR} Failed to delete project script(s)."
      return 1
    fi

    if [[ -d "${SERVICE_DEST_PATH}" ]] \
      && ! rm -rf "${SERVICE_DEST_PATH}" &> /dev/null; then
      echo -e "${PREFIX_ERROR} Failed to delete project service(s)."
      return 1
    fi

    return 0
  }
# </functions>

Main