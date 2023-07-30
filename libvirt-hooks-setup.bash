#!/bin/bash/env bash

#
# Filename:       libvirt-hooks-setup.bash
# Description:    Manages libvirt-hooks binaries, scripts and services.
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

    readonly BIN_DEST_PATH="/usr/local/bin/libvirt-hooks/"
    readonly BIN_SOURCE_PATH="bin"
    readonly SERVICE_DEST_PATH="/etc/systemd/system/"
    readonly SERVICE_SOURCE_PATH="systemd"
    readonly HOOK_DEST_PATH="/etc/libvirt/hooks/"
    readonly HOOK_SOURCE_PATH="hooks"

    declare -ar BIN_LIST=(
      "libvirt-dohibernate"
      "libvirt-dosleep"
    )

    declare -ar HOOK_LIST=(
      "cfscpu"
      "ddcutil"
      # "dohibernate"
      # "dosleep"
      "hugepages"
      "isolcpu"
      "nosleep"
      "qemu"
      "set-hooks"
    )

    declare -ar SERVICE_LIST=(
      # "libvirt-dohibernate@.service"
      # "libvirt-dosleep@.service"
      "libvirt-nosleep@.service"
    )
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

    if ! "${DO_INSTALL}"; then
      Uninstall
      exit "${?}"
    fi

    Install
    exit "${?}"
  }

  # <summary>Copy Source Files to Destination</summary>
    function CopySourceFilesToDestination
    {
      # CopyBinaryFilesToDestination || return 1
      CopyScriptFilesToDestination || return 1
      CopyServiceFilesToDestination || return 1
      return 0
    }

    function CopyBinaryFilesToDestination
    {
      cd ..
      cd "${BIN_SOURCE_PATH}" || return 1

      if ! sudo cp --recursive --force * "${BIN_DEST_PATH}" &> /dev/null; then
        echo -e "${PREFIX_ERROR} Failed to copy project binaries."
        return 1
      fi

      return 0
    }

    function CopyScriptFilesToDestination
    {
      cd ..
      cd "${HOOK_SOURCE_PATH}" || return 1

      if ! sudo cp --recursive --force * "${HOOK_DEST_PATH}" &> /dev/null; then
        echo -e "${PREFIX_ERROR} Failed to copy project script(s)."
        return 1
      fi

      return 0
    }

    function CopyServiceFilesToDestination
    {
      cd .. || return 1
      cd "${SERVICE_SOURCE_PATH}" || return 1

      if ! sudo cp --recursive --force * "${SERVICE_DEST_PATH}" &> /dev/null; then
        echo -e "${PREFIX_ERROR} Failed to copy project service(s)."
        return 1
      fi

      return 0
    }

  function Install
  {
    if ! DoSourceFilesExist \
      || ! DoesDestinationPathExist \
      || ! CopySourceFilesToDestination \
      || ! SetPermissionsForDestinationFiles; then
      echo -e "${PREFIX_FAIL} Could not install ${REPO_NAME}."
      return 1
    fi

    echo -e "${PREFIX_PASS} Installed ${REPO_NAME}."
    return 0
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

  # <summary>Delete Destination Files</summary>
    function DeleteDestinationFiles
    {
      DeleteBinaryFiles || return 1
      DeleteScriptFiles || return 1
      DeleteServiceFiles || return 1
    }

    function DeleteBinaryFiles
    {
      if [[ ! -d "${BIN_DEST_PATH}" ]]; then
        return 0
      fi

      cd "${BIN_DEST_PATH}"

      for BIN in "${BIN_LIST[@]}"; do
        if ! rm --recursive --force "${BIN}" &> /dev/null; then
          echo -e "${PREFIX_ERROR} Failed to delete project binaries."
          return 1
        fi
      done

      return 0
    }

    function DeleteScriptFiles
    {
      if [[ ! -d "${HOOK_DEST_PATH}" ]]; then
        return 0
      fi

      cd "${HOOK_DEST_PATH}"

      for HOOK in "${HOOK_LIST[@]}"; do
        if ! rm --recursive --force "${HOOK}" &> /dev/null; then
          echo -e "${PREFIX_ERROR} Failed to delete project script(s)."
          return 1
        fi
      done

      return 0
    }

    function DeleteServiceFiles
    {
      if [[ ! -d "${SERVICE_DEST_PATH}" ]]; then
        return 0
      fi

      cd "${SERVICE_DEST_PATH}"

      for SERVICE in "${SERVICE_LIST[@]}"; do
        if ! rm --recursive --force "${SERVICE}" &> /dev/null; then
          echo -e "${PREFIX_ERROR} Failed to delete project service(s)."
          return 1
        fi
      done

      return 0
    }

  # <summary>Do Source Files Exist</summary>
    function DoSourceFilesExist
    {
      # DoBinaryFilesExist || return 1
      DoScriptFilesExist || return 1
      DoServiceFilesExist || return 1
    }

    function DoBinaryFilesExist
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

    function DoScriptFilesExist
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

    function DoServiceFilesExist
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

  # <summary>Do Destination Paths Exist</summary>
    function DoesDestinationPathExist
    {
      # DoesBinaryPathExist || return 1
      DoesScriptPathExist || return 1
      DoesServicePathExist || return 1
      return 0
    }

    function DoesBinaryPathExist
    {
      if [[ ! -d "${BIN_DEST_PATH}" ]] \
        && ! sudo mkdir --parents "${BIN_DEST_PATH}" &> /dev/null; then
        echo -e "${PREFIX_ERROR} Could not create directory '${BIN_DEST_PATH}'."
        return 1
      fi

      return 0
    }

    function DoesScriptPathExist
    {
      if [[ ! -d "${HOOK_DEST_PATH}" ]]; then
        echo -e "${PREFIX_ERROR} Could not find directory '${HOOK_DEST_PATH}'."
        return 1
      fi
      return 0
    }

    function DoesServicePathExist
    {
      if [[ ! -d "${SERVICE_DEST_PATH}" ]]; then
        echo -e "${PREFIX_ERROR} Could not find directory '${SERVICE_DEST_PATH}'."
        return 1
      fi

      return 0
    }

  # <summary>Set Permissions For Destination Files</summary>
    function SetPermissionsForDestinationFiles
    {
      # SetPermissionsForBinaryFiles || return 1
      SetPermissionsForScriptFiles || return 1
      SetPermissionsForServiceFiles || return 1
    }

    function SetPermissionsForBinaryFiles
    {
      if ! sudo chown --recursive --silent root:root "${BIN_DEST_PATH}" \
        || ! sudo chmod --recursive --silent +x "${BIN_DEST_PATH}"; then
        echo -e "${PREFIX_ERROR} Failed to set file permissions for binaries."
        return 1
      fi

      return 0
    }

    function SetPermissionsForScriptFiles
    {
      if ! sudo chown --recursive --silent root:root "${HOOK_DEST_PATH}"; then
        echo -e "${PREFIX_ERROR} Failed to set file permissions for script(s)."
        return 1
      fi

      return 0
    }

    function SetPermissionsForServiceFiles
    {
      if ! sudo chown --recursive --silent root:root "${SERVICE_DEST_PATH}"; then
        echo -e "${PREFIX_ERROR} Failed to set file permissions for service(s)."
        return 1
      fi

      return 0
    }

  function Uninstall
  {
    if ! DeleteDestinationFiles; then
      echo -e "${PREFIX_FAIL} Could not uninstall ${REPO_NAME}."
      return 1
    fi

    echo -e "${PREFIX_PASS} Uninstalled ${REPO_NAME}."
    return 0
  }
# </functions>

Main