#!/bin/bash/env bash

#
# Filename:       installer.bash
# Description:    Manages libvirt-hooks binaries, scripts and services.
# Author(s):      Alex Portell <github.com/portellam>
# Maintainer(s):  Alex Portell <github.com/portellam>
#

# <params>
  readonly REPO_NAME="libvirt-hooks"
  readonly WORKING_DIR="$( dirname $( realpath "${0}" ) )/"
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
  readonly BIN_SOURCE_PATH="${WORKING_DIR}bin/"
  readonly SCRIPT_DEST_PATH="/etc/libvirt/hooks/"
  readonly SCRIPT_SOURCE_RELATIVE_PATH="hooks/"
  readonly SERVICE_DEST_PATH="/etc/systemd/system/"
  readonly SERVICE_SOURCE_PATH="${WORKING_DIR}systemd/"

  declare -ar BIN_LIST=( $( find -L "${BIN_SOURCE_PATH}" -maxdepth 1 -type f ) )
  declare -ar SCRIPT_LIST=( $( find -L "${SCRIPT_SOURCE_RELATIVE_PATH}" -type f ) )
  declare -a SCRIPT_SUBDIR_LIST=( $( find -L "${SCRIPT_SOURCE_RELATIVE_PATH}" -type d ) )
  unset SCRIPT_SUBDIR_LIST[0]
  readonly SCRIPT_SUBDIR_LIST
  declare -ar SERVICE_LIST=( $( find -L "${SERVICE_SOURCE_PATH}" -maxdepth 1 -type f ) )
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
      print_error "User is not sudo/root."
      exit 1
    fi

    get_option || exit 1

    if ! "${DO_INSTALL}"; then
      uninstall || exit 1
    else
      are_dependencies_installed || exit 1
      install || exit 1
    fi

    update_services
    exit "${?}"
  }

  function are_dependencies_installed
  {
    local systemd_app="systemd"

    if ! command -v "${systemd_app}" &> /dev/null; then
      print_error "Required dependency '${systemd_app}' is not installed."
      return 1
    fi

    local -r output="$( systemctl status "${LIBVIRTD_SERVICE}" )"

    if [[ "${output}" == "Unit ${LIBVIRTD_SERVICE}.service could not be found." ]]; then
      print_error "Required service '${LIBVIRTD_SERVICE}' is not installed."
      return 1
    fi

    print_pass "Dependencies are installed."
  }

  function update_services
  {
    if ! systemctl daemon-reload &> /dev/null; then
      print_error "Could not update services."
      return 1
    fi

    if ! systemctl enable "${LIBVIRTD_SERVICE}" &> /dev/null; then
      print_error "Could not enable ${LIBVIRTD_SERVICE}."
      return 1
    fi

    if ! systemctl restart "${LIBVIRTD_SERVICE}" &> /dev/null; then
      print_error "Could not start ${LIBVIRTD_SERVICE}."
      return 1
    fi

    print_pass "Updated services."
  }

  # <summary>Copy Source Files to Destination</summary>
    function copy_source_files_to_destination
    {
      copy_binary_files_to_destination || return 1
      copy_script_files_to_destination || return 1
      copy_service_files_to_destination
    }

    function copy_binary_files_to_destination
    {
      for bin in "${BIN_LIST[@]}"; do
        local bin_name="$( basename "${bin}" )"
        local bin_path="${BIN_DEST_PATH}${bin_name}"

        if ! sudo cp --force "${bin}" "${bin_path}" &> /dev/null; then
          print_error "Failed to copy project binaries."
          return 1
        fi
      done
    }

    function copy_script_files_to_destination
    {
      for script in "${SCRIPT_LIST[@]}"; do
        local script_source_file="${WORKING_DIR}${script}"
        local script_dest_file="${SCRIPT_DEST_PATH}${script:6}"
        local script_dest_dir="$( dirname "${script_dest_file}" )/"

        if ! does_path_exist "${script_dest_dir}" \
          || ! sudo rsync --archive --recursive --verbose "${script_source_file}" "${script_dest_dir}" &> /dev/null; then
          print_error "Failed to copy project script(s)."
          return 1
        fi
      done
    }

    function copy_service_files_to_destination
    {
      for service in "${SERVICE_LIST[@]}"; do
        local service_name="$( basename "${service}" )"
        local service_path="${SERVICE_DEST_PATH}/${service_name}"

        if ! sudo cp --force "${service}" "${service_path}" &> /dev/null; then
          print_error "Failed to copy project service(s)."
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
      print_fail "Could not install ${REPO_NAME}."
      return 1
    fi

    print_pass "installed ${REPO_NAME}."
  }

  function print_error
  {
    echo -e "${PREFIX_ERROR} ${1}"
  }

  function print_fail
  {
    echo -e "${PREFIX_FAIL} ${1}"
  }

  function print_pass
  {
    echo -e "${PREFIX_PASS} ${1}"
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

      for bin in "${BIN_LIST[@]}"; do
        local bin_path="${BIN_DEST_PATH}${bin}"

        if ! rm --force "${bin_path}" &> /dev/null; then
          print_error "Failed to delete project binaries."
          return 1
        fi
      done
    }

    function delete_script_files
    {
      if [[ ! -d "${SCRIPT_DEST_PATH}" ]]; then
        return 0
      fi

      if ! rm --force --recursive ${SCRIPT_DEST_PATH}* &> /dev/null; then
        print_error "Failed to delete project script(s)."
        return 1
      fi
    }

    function delete_service_files
    {
      if [[ ! -d "${SERVICE_DEST_PATH}" ]]; then
        return 0
      fi

      for service in "${SERVICE_LIST[@]}"; do
        local service_path="${SERVICE_DEST_PATH}${service}"

        if ! rm --force "${service_path}" &> /dev/null; then
          print_error "Failed to delete project service(s)."
          return 1
        fi
      done
    }

    function do_source_files_exist
    {
      do_binary_files_exist || return 1
      do_script_files_exist || return 1
      do_service_files_exist
    }

    function do_binary_files_exist
    {
      for bin in "${BIN_LIST[@]}"; do
        if [[ ! -e "${bin}" ]]; then
          print_error "Missing project binaries."
          return 1
        fi
      done
    }

    function do_script_files_exist
    {
      for script in "${SCRIPT_LIST[@]}"; do
        if [[ ! -e "${script}" ]]; then
          print_error "Missing project scripts."
          return 1
        fi
      done
    }

    function do_service_files_exist
    {
      for service in "${SERVICE_LIST[@]}"; do
        if [[ ! -e "${service}" ]]; then
          print_error "Missing project services."
          return 1
        fi
      done
    }

  # <summary>Do Destination Paths Exist</summary>
    function does_destination_path_exist
    {
      does_path_exist "${BIN_DEST_PATH}" || return 1
      does_script_path_exist || return 1
      does_path_exist "${SERVICE_DEST_PATH}" || return 1
    }

    function does_path_exist
    {
      local -r path="${1}"

      if [[ ! -d "${path}" ]] \
        && ! sudo mkdir --parents "${path}" &> /dev/null; then
        print_error "Could not create directory '${path}'."
        return 1
      fi
    }

    function does_script_path_exist
    {
      does_path_exist "${SCRIPT_DEST_PATH}" || return 1

      for script_subdir in "${SCRIPT_SUBDIR_LIST[@]}"; do
        script_subdir="${script_subdir:6}"
        script_subdir="${SCRIPT_DEST_PATH}${script_subdir}"
        does_path_exist "${script_subdir}" || return 1
      done
    }

  # <summary>Set Permissions For Destination Files</summary>
    function set_permissions_for_destination_files
    {
      set_permissions_for_binary_files || return 1
      set_permissions_for_script_files || return 1
      set_permissions_for_service_files
    }

    function set_permissions_for_binary_files
    {
      if ! sudo chown --recursive --silent root:root "${BIN_DEST_PATH}" \
        || ! sudo chmod --recursive --silent +x "${BIN_DEST_PATH}"; then
        print_error "Failed to set file permissions for binaries."
        return 1
      fi
    }

    function set_permissions_for_script_files
    {
      if ! sudo chown --recursive --silent root:root "${SCRIPT_DEST_PATH}" \
        || ! sudo chmod --recursive --silent +x "${SCRIPT_DEST_PATH}"; then
        print_error "Failed to set file permissions for script(s)."
        return 1
      fi
    }

    function set_permissions_for_service_files
    {
      if ! sudo chown --recursive --silent root:root "${SERVICE_DEST_PATH}"; then
        print_error "Failed to set file permissions for service(s)."
        return 1
      fi

      for service in "${SERVICE_LIST[@]}"; do
        local this_service_path="${SERVICE_DEST_PATH}$( basename "${service}" )"

        if ! sudo chmod --recursive --silent +x "${this_service_path}"; then
          print_error "Failed to set file permissions for service '${service}'."
          return 1
        fi
      done
    }

  function uninstall
  {
    if ! delete_destination_files; then
      echo -e "${PREFIX_FAIL} Could not uninstall ${REPO_NAME}."
      return 1
    fi

    print_pass "Uninstalled ${REPO_NAME}."
  }

  function set_ifs_to_newline
  {
    IFS=$'\n'
  }

  function unset_ifs
  {
    unset IFS
  }
# </functions>

# <code>
  main
# </code>