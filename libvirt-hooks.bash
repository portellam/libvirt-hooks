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

    readonly LIBVIRTD_SERVICE="libvirtd"

    readonly BIN_DEST_PATH="/usr/local/bin/libvirt-hooks/"
    readonly BIN_SOURCE_PATH="bin"
    readonly SERVICE_DEST_PATH="/etc/systemd/system/"
    readonly SERVICE_SOURCE_PATH="systemd"
    readonly SCRIPT_DEST_PATH="/etc/libvirt/hooks/"
    readonly SCRIPT_SOURCE_PATH="hooks"

    declare -ar BIN_LIST=(
      "libvirt-dohibernate"
      "libvirt-dosleep"
    )

    declare -ar SCRIPT_LIST=(
      "cfscpu"
      # "ddcutil"                       # <note>To be implemented in a future release.</note>
      # "dohibernate"                   # <note>To be implemented in a future release.</note>
      # "dosleep"                       # <note>To be implemented in a future release.</note>
      "hugepages"
      "isolcpu"
      "nosleep"
      "qemu"
      "set-hooks"
    )

    declare -ar SERVICE_LIST=(
      # "libvirt-dohibernate@.service"  # <note>To be implemented in a future release.</note>
      # "libvirt-dosleep@.service"      # <note>To be implemented in a future release.</note>
      "libvirt-nosleep@.service"
    )
# </params>

# <functions>
  function get_option
  {
    case "${OPTION}" in
      "-u" | "--uninstall" )
        DO_INSTALL=false ;;

      "-i" | "--install" )
        DO_INSTALL=true ;;

      "-h" | "--help" | * )
        print_usage
        return 1 ;;
    esac
  }

  function main
  {
    if [[ $( whoami ) != "root" ]]; then
      echo -e "${PREFIX_ERROR} User is not sudo/root."
      exit 1
    fi

    get_option || exit 1

    if ! "${DO_INSTALL}"; then
      uninstall || exit 1
    else
      are_dependencies_installed || exit 1
      install || exit 1
    fi

    update_services || exit 1
    exit 0
  }

  function are_dependencies_installed
  {
    local systemd_app="systemd"

    if ! command -v "${systemd_app}" &> /dev/null; then
      echo -e "${PREFIX_ERROR} Required dependency '${systemd_app}' is not installed."
      return 1
    fi

    local output="$( systemctl status "${LIBVIRTD_SERVICE}" )"

    if [[ "${output}" == "Unit ${LIBVIRTD_SERVICE}.service could not be found." ]]; then
      echo -e "${PREFIX_ERROR} Required service '${LIBVIRTD_SERVICE}' is not installed."
      return 1
    fi

    echo -e "${PREFIX_PASS} Dependencies are installed."
  }

  function update_services
  {
    if ! systemctl daemon-reload &> /dev/null; then
      echo -e "${PREFIX_ERROR} Could not update services."
      return 1
    fi

    if ! systemctl enable "${LIBVIRTD_SERVICE}" &> /dev/null; then
      echo -e "${PREFIX_ERROR} Could not enable ${LIBVIRTD_SERVICE}."
      return 1
    fi

    if ! systemctl restart "${LIBVIRTD_SERVICE}" &> /dev/null; then
      echo -e "${PREFIX_ERROR} Could not start ${LIBVIRTD_SERVICE}."
      return 1
    fi

    echo -e "${PREFIX_PASS} Updated services."
  }

  # <summary>Copy Source Files to Destination</summary>
    function copy_source_files_to_destination
    {
      # copy_binary_files_to_destination || return 1    # <note>To be implemented in a future release.</note>
      copy_script_files_to_destination || return 1
      copy_service_files_to_destination
    }

    # function copy_binary_files_to_destination         # <note>To be implemented in a future release.</note>
    # {
    #   cd ..
    #   cd "${BIN_SOURCE_PATH}" || return 1

    #   for bin in "${BIN_LIST[@]}"; do
    #     if ! sudo cp --force "${bin}" "${BIN_DEST_PATH}" &> /dev/null; then
    #       echo -e "${PREFIX_ERROR} Failed to copy project binaries."
    #       return 1
    #     fi
    #   done

    # }

    function copy_script_files_to_destination
    {
      cd ..
      cd "${SCRIPT_SOURCE_PATH}" || return 1

      for script in "${SCRIPT_LIST[@]}"; do
        if ! sudo cp --force "${script}" "${SCRIPT_DEST_PATH}" &> /dev/null; then
          echo -e "${PREFIX_ERROR} Failed to copy project script(s)."
          return 1
        fi
      done

    }

    function copy_service_files_to_destination
    {
      cd .. || return 1
      cd "${SERVICE_SOURCE_PATH}" || return 1

      for service in "${SERVICE_LIST[@]}"; do
        if ! sudo cp --force "${service}" "${SERVICE_DEST_PATH}" &> /dev/null; then
          echo -e "${PREFIX_ERROR} Failed to copy project service(s)."
          return 1
        fi
      done

    }

  function install
  {
    if ! do_source_files_exist \
      || ! does_destination_path_exist \
      || ! copy_source_files_to_destination \
      || ! set_permissions_for_destination_files; then
      echo -e "${PREFIX_FAIL} Could not install ${REPO_NAME}."
      return 1
    fi

    echo -e "${PREFIX_PASS} installed ${REPO_NAME}."
  }

  function print_usage
  {
    IFS=$'\n'

    local -a output=(
      "Usage:\tbash libvirt-hooks [OPTION]"
      "Manages ${REPO_NAME} binaries, scripts, and services.\n"
      "  -h, --help\t\tPrint this help and exit."
      "  -i, --install\t\tInstall ${REPO_NAME} to system."
      "  -u, --uninstall\tUninstall ${REPO_NAME} from system."
    )

    echo -e "${output[*]}"
    unset IFS
  }

  # <summary>Delete Destination Files</summary>
    function delete_destination_files
    {
      delete_binary_files || return 1
      delete_script_files || return 1
      delete_service_files
    }

    function delete_binary_files
    {
      if [[ ! -d "${BIN_DEST_PATH}" ]]; then
        return 0
      fi

      cd "${BIN_DEST_PATH}"

      for bin in "${BIN_LIST[@]}"; do
        if ! rm --force "${bin}" &> /dev/null; then
          echo -e "${PREFIX_ERROR} Failed to delete project binaries."
          return 1
        fi
      done

    }

    function delete_script_files
    {
      if [[ ! -d "${SCRIPT_DEST_PATH}" ]]; then
        return 0
      fi

      cd "${SCRIPT_DEST_PATH}"

      for script in "${SCRIPT_LIST[@]}"; do
        if ! rm --force "${script}" &> /dev/null; then
          echo -e "${PREFIX_ERROR} Failed to delete project script(s)."
          return 1
        fi
      done

    }

    function delete_service_files
    {
      if [[ ! -d "${SERVICE_DEST_PATH}" ]]; then
        return 0
      fi

      cd "${SERVICE_DEST_PATH}"

      for service in "${SERVICE_LIST[@]}"; do
        if ! rm --force "${service}" &> /dev/null; then
          echo -e "${PREFIX_ERROR} Failed to delete project service(s)."
          return 1
        fi
      done

    }

  # <summary>Do Source Files Exist</summary>
    function do_source_files_exist
    {
      # do_binary_files_exist || return 1
      do_script_files_exist || return 1
      do_service_files_exist
    }

    function do_binary_files_exist
    {
      cd "${WORKING_DIR}"
      cd "${BIN_SOURCE_PATH}" || return 1

      for bin in "${BIN_LIST[@]}"; do
        if [[ ! -e "${bin}" ]]; then
          echo -e "${PREFIX_ERROR} Missing project binaries."
          return 1
        fi
      done

    }

    function do_script_files_exist
    {
      cd "${WORKING_DIR}"
      cd "${SCRIPT_SOURCE_PATH}" || return 1

      for script in "${SCRIPT_LIST[@]}"; do
        if [[ ! -e "${script}" ]]; then
          echo -e "${PREFIX_ERROR} Missing project scripts."
          return 1
        fi
      done

    }

    function do_service_files_exist
    {
      cd "${WORKING_DIR}"
      cd "${SERVICE_SOURCE_PATH}" || return 1

      for service in "${SERVICE_LIST[@]}"; do
        if [[ ! -e "${service}" ]]; then
          echo -e "${PREFIX_ERROR} Missing project services."
          return 1
        fi
      done

    }

  # <summary>Do Destination Paths Exist</summary>
    function does_destination_path_exist
    {
      # does_binary_path_exist || return 1
      does_script_path_exist || return 1
      does_service_path_exist
    }

    function does_binary_path_exist
    {
      if [[ ! -d "${BIN_DEST_PATH}" ]] \
        && ! sudo mkdir --parents "${BIN_DEST_PATH}" &> /dev/null; then
        echo -e "${PREFIX_ERROR} Could not create directory '${BIN_DEST_PATH}'."
        return 1
      fi

    }

    function does_script_path_exist
    {
      if [[ ! -d "${SCRIPT_DEST_PATH}" ]] \
        && ! sudo mkdir --parents "${SCRIPT_DEST_PATH}" &> /dev/null; then
        echo -e "${PREFIX_ERROR} Could not create directory '${SCRIPT_DEST_PATH}'."
        return 1
      fi

    }

    function does_service_path_exist
    {
      if [[ ! -d "${SERVICE_DEST_PATH}" ]]; then
        echo -e "${PREFIX_ERROR} Could not find directory '${SERVICE_DEST_PATH}'."
        return 1
      fi

    }

  # <summary>Set Permissions For Destination Files</summary>
    function set_permissions_for_destination_files
    {
      # set_permissions_for_binary_files || return 1
      set_permissions_for_script_files || return 1
      set_permissions_for_service_files
    }

    function set_permissions_for_binary_files
    {
      if ! sudo chown --recursive --silent root:root "${BIN_DEST_PATH}" \
        || ! sudo chmod --recursive --silent +x "${BIN_DEST_PATH}"; then
        echo -e "${PREFIX_ERROR} Failed to set file permissions for binaries."
        return 1
      fi

    }

    function set_permissions_for_script_files
    {
      if ! sudo chown --recursive --silent root:root "${SCRIPT_DEST_PATH}"; then
        echo -e "${PREFIX_ERROR} Failed to set file permissions for script(s)."
        return 1
      fi

    }

    function set_permissions_for_service_files
    {
      if ! sudo chown --recursive --silent root:root "${SERVICE_DEST_PATH}"; then
        echo -e "${PREFIX_ERROR} Failed to set file permissions for service(s)."
        return 1
      fi

    }

  function uninstall
  {
    if ! delete_destination_files; then
      echo -e "${PREFIX_FAIL} Could not uninstall ${REPO_NAME}."
      return 1
    fi

    echo -e "${PREFIX_PASS} Uninstalled ${REPO_NAME}."
  }
# </functions>

main