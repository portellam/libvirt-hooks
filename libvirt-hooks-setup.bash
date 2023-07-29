#!/bin/bash/env bash

#
# Filename:       libvirt-hooks-setup.bash
# Description:    Manages libvirt-hooks binaries and files.
# Author(s):      Alex Portell <github.com/portellam>
# Maintainer(s):  Alex Portell <github.com/portellam>
#

# <params>
  readonly REPO_NAME="libvirt-hooks"
  readonly WORKING_DIR=$( pwd )
  readonly OPTION="${1}"

  # <summary>Execution Flags</summary>
    DO_INSTALL=true

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

    local -r BIN_DEST_PATH="/usr/local/bin/libvirt-hooks/"
    local -r BIN_SOURCE_PATH="bin"
    local -r SERVICE_DEST_PATH="/etc/systemd/system/"
    local -r SERVICE_SOURCE_PATH="systemd"
    local -r HOOK_DEST_PATH="/etc/libvirt/hooks/"
    local -r HOOK_SOURCE_PATH="hooks"

    local -ar BIN_LIST=(
      "libvirt-dohibernate"
      "libvirt-dosleep"
    )

    local -ar HOOK_LIST=(
      "cfscpu"
      "ddcutil"
      "dohibernate"
      "dosleep"
      "hugepages"
      "isolcpu"
      "nosleep"
      "qemu"
      "set-hooks"
    )

    local -ar SERVICE_LIST=(
      "libvirt-dohibernate@.service"
      "libvirt-dosleep@.service"
      "libvirt-nosleep@.service"
    )

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

  function DeleteDestinationBinaries
  {
    if [[ ! -d "${BIN_DEST_PATH}" ]]; then
      return 0
    fi

    cd "${BIN_DEST_PATH}"

    for BIN in "${BIN_LIST[@]}"; do
      if ! rm -rf "${BIN}" &> /dev/null; then
        echo -e "${PREFIX_ERROR} Failed to delete project binaries."
        return 1
      fi
    done

    return 0
  }

  function DeleteDestinationScripts
  {
    if [[ ! -d "${HOOK_DEST_PATH}" ]]; then
      return 0
    fi

    cd "${HOOK_DEST_PATH}"

    for HOOK in "${HOOK_LIST[@]}"; do
      if ! rm -rf "${HOOK}" &> /dev/null; then
        echo -e "${PREFIX_ERROR} Failed to delete project script(s)."
        return 1
      fi
    done

    return 0
  }

  function DeleteDestinationServices
  {
    if [[ ! -d "${SERVICE_DEST_PATH}" ]]; then
      return 0
    fi

    cd "${SERVICE_DEST_PATH}"

    for SERVICE in "${SERVICE_LIST[@]}"; do
      if ! rm -rf "${SERVICE}" &> /dev/null; then
        echo -e "${PREFIX_ERROR} Failed to delete project service(s)."
        return 1
      fi
    done

    return 0
  }

  function DoBinariesExist
  {
    cd "${WORKING_DIR}"
    cd "${BIN_SOURCE_PATH}" || return 1

    for BIN in "${BIN_LIST[@]}"; do
      if [[ ! -e "${BIN}" ]]; then
        echo -e "${PREFIX_ERROR} Missing project binaries."
        return 1
      fi
    done

    return 0
  }

  function DoScriptsExist
  {
    cd "${WORKING_DIR}"
    cd "${HOOK_SOURCE_PATH}" || return 1

    for HOOK in "${HOOK_LIST[@]}"; do
      if [[ ! -e "${HOOK}" ]]; then
        echo -e "${PREFIX_ERROR} Missing project scripts."
        return 1
      fi
    done

    return 0
  }

  function DoServicesExist
  {
    cd "${WORKING_DIR}"
    cd "${SERVICE_SOURCE_PATH}" || return 1

    for SERVICE in "${SERVICE_LIST[@]}"; do
      if [[ ! -e "${SERVICE}" ]]; then
        echo -e "${PREFIX_ERROR} Missing project services."
        return 1
      fi
    done

    return 0
  }

  function DoesDestinationPathExist
  {
    if [[ ! -d "${BIN_DEST_PATH}" ]] \
      && ! sudo mkdir -p "${BIN_DEST_PATH}"; then
      echo -e "${PREFIX_ERROR} Could not create directory '${BIN_DEST_PATH}'."
      return 1
    fi

    if [[ ! -d "${HOOK_DEST_PATH}" ]]; then
      echo -e "${PREFIX_ERROR} Could not find directory '${HOOK_DEST_PATH}'."
      return 1
    fi

    if [[ ! -d "${SERVICE_DEST_PATH}" ]]; then
      echo -e "${PREFIX_ERROR} Could not find directory '${SERVICE_DEST_PATH}'."
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
    cd "${HOOK_SOURCE_PATH}" || return 1

    if ! sudo cp -rf * "${HOOK_DEST_PATH}" &> /dev/null; then
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
    DoScriptsExist || return 1
    DoServicesExist || return 1
    DoesDestinationPathExist || return 1
    CopyFilesToDesination || return 1
    SetFilePermissions || return 1
  }

  function PrintUsage
  {
    IFS=$'\n'

    local -a OUTPUT=(
      "Usage:\tbash libvirt-hooks-setup [OPTION]"
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
    DeleteDestinationBinaries || return 1
    DeleteDestinationScripts || return 1
    DeleteDestinationServices || return 1
    return 0
  }
# </functions>

Main