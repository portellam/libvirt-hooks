#!/bin/bash/env bash

#
# Filename:       installer.bash
# Description:    Manages libvirt-hooks binaries, scripts and services.
# Author(s):      Alex Portell <codeberg.org/portellam> <github.com/portellam>
# Maintainer(s):  Alex Portell <codeberg.org/portellam> <github.com/portellam>
# Version:        1.0.0
#

#
# params
#
  declare -r SCRIPT_VERSION="1.0.0"
  declare -r REPO_NAME="libvirt-hooks"
  declare -r WORKING_DIR="$( dirname $( realpath "${0}" ) )/"
  declare -r OPTION="${1}"

  SAVEIFS="${IFS}"
  IFS=$'\n'

  #
  # DESC: Execution Flags
  #
    DO_INSTALL=false
    DO_UNINSTALL=false

  #
  # DESC: Color coding
  # Reference URL: 'https://www.shellhacks.com/bash-colors'
  #
    SET_COLOR_GREEN='\033[0;32m'
    SET_COLOR_RED='\033[0;31m'
    SET_COLOR_YELLOW='\033[0;33m'
    RESET_COLOR='\033[0m'

  #
  # DESC: append output
  #
    PREFIX_PROMPT="$( basename "${0}" ): "

    PREFIX_ERROR="${PREFIX_PROMPT}${SET_COLOR_YELLOW}An error occurred:"\
      "${RESET_COLOR} "

    PREFIX_FAIL="${PREFIX_PROMPT}${SET_COLOR_RED}Failure:${RESET_COLOR} "
    PREFIX_PASS="${PREFIX_PROMPT}${SET_COLOR_GREEN}Success:${RESET_COLOR} "

  declare -r LIBVIRTD_SERVICE="libvirtd"

  declare -r BIN_DEST_PATH="/usr/local/bin/libvirt-hooks/"
  declare -r BIN_SOURCE_PATH="${WORKING_DIR}bin/"
  declare -r SCRIPT_DEST_PATH="/etc/libvirt/hooks/"
  declare -r SCRIPT_SOURCE_RELATIVE_PATH="hooks/"
  declare -r SERVICE_DEST_PATH="/etc/systemd/system/"
  declare -r SERVICE_SOURCE_PATH="${WORKING_DIR}systemd/"

  declare -a BIN_LIST=( )
  declare -a SCRIPT_LIST=( )
  declare -a SCRIPT_SUBDIR_LIST=( )
  declare -a SERVICE_LIST=( )

  DO_INSTALL_AUDIO_LOOPBACK=false
  AUDIO_LOOPBACK_HOOK_NAME="audio-loopback"

#
# logic
#
  function main
  {
    is_user_superuser || exit 1

    if ! is_user_superuser; then
      exit 1
    fi

    add_to_lists &> /dev/null

    if ! get_option \
      || ! prompt_install; then
      exit 1
    fi

    is_pulseaudio_installed
    do_install_audio_loopback

    if ! "${DO_INSTALL}"; then
      if ! uninstall; then
        exit 1
      fi
    fi

    if ! are_dependencies_installed \
      || ! install \
      || ! update_services; then
      exit 1
    fi

    exit 0
  }

  function add_to_lists
  {
    BIN_LIST=( $( find -L "${BIN_SOURCE_PATH}" -maxdepth 1 -type f ) )
    SCRIPT_LIST=( $( find -L "${SCRIPT_SOURCE_RELATIVE_PATH}" -type f ) )
    SCRIPT_SUBDIR_LIST=( $( find -L "${SCRIPT_SOURCE_RELATIVE_PATH}" -type d ) )
    unset SCRIPT_SUBDIR_LIST[0]
    readonly SCRIPT_SUBDIR_LIST
    SERVICE_LIST=( $( find -L "${SERVICE_SOURCE_PATH}" -maxdepth 1 -type f ) )
  }

  #
  # DESC: business logic
  #
    function prompt_install
    {
      if "${DO_INSTALL}" ||
        "${DO_UNINSTALL}"; then
        return 0
      fi

      yes_no_prompt "Install '${REPO_NAME}'?"

      case "${?}" in
        0 )
          DO_INSTALL=true ;;

        1 )
          return 1 ;;

        255 )
          DO_UNINSTALL=true ;;
      esac
    }

    function install
    {
      if ! do_source_files_exist \
        || ! does_destination_path_exist \
        || ! copy_source_files_to_destination \
        || ! set_permissions_for_destination_files; then
        log_fail"Could not install ${REPO_NAME}."
        return 1
      fi

      log_pass "Installed ${REPO_NAME}."
    }

    function uninstall
    {
      if ! delete_destination_files; then
        log_fail"Could not uninstall ${REPO_NAME}."
        return 1
      fi

      log_pass "Uninstalled ${REPO_NAME}."
    }

  #
  # DESC: clean up
  #
    function reset_ifs
    {
      IFS="${SAVEIFS}"
    }

  #
  # DESC: data-type validation
  #
    function is_string
    {
      if [[ "${1}" == "" ]]; then
        return 1
      fi
    }

  #
  # DESC: handlers
  #
    function catch_error {
      exit 1
    }

    function catch_exit {
      reset_ifs
    }

  function is_user_superuser
  {
    if [[ $( whoami ) != "root" ]]; then
      print_to_error_log "User is not sudo or root."
      return 1
    fi

    return 0
  }

  function yes_no_prompt
  {
    local str_output="${1}"
    is_string "${str_output}" && output+=" "

    for counter in $( seq 0 2 ); do
      echo -en "${output}[Y/n]: "
      read -r -p "" answer

      case "${answer}" in
        [Yy]* )
          return 0 ;;

        [Nn]* )
          return 255 ;;

        * )
          echo "Please answer 'Y' or 'N'." ;;
      esac
    done

    return 1
  }

  #
  # DESC: loggers
  #
    #
    # DESC:   Log the output as an error.
    # $1:     the output as a string.
    # RETURN: Always return 0.
    #
      function log_error
      {
        echo -e "${PREFIX_ERROR}${1}" >&2
        return 0
      }

    #
    # DESC:   Log the output as a fail.
    # $1:     the output as a string.
    # RETURN: Always return 0.
    #
      function log_fail
      {
        echo -e "${PREFIX_FAIL}${1}" >&2
        return 0
      }

    #
    # DESC:   Log the output as a fail.
    # $1:     the output as a string.
    # RETURN: Always return 0.
    #
      function log_output
      {
        echo -e "${PREFIX_PROMPT}${1}" >&1
        return 0
      }

    #
    # DESC:   Log the output as a pass.
    # $1:     the output as a string.
    # RETURN: Always return 0.
    #
      function log_pass
      {
        echo -e "${PREFIX_PASS}${1}" >&1
        return 0
      }

    function print_usage
    {
      IFS=$'\n'

      local -a str_output=(
        "Usage:\tbash libvirt-hooks [OPTION]"
        "Manages ${REPO_NAME} binaries, scripts, and services."
        "Version ${SCRIPT_VERSION}.\n"
        "  -h, --help\t\tPrint this help and exit."
        "  -i, --install\t\tInstall ${REPO_NAME} to system."
        "  -u, --uninstall\tUninstall ${REPO_NAME} from system."
      )

      echo -e "${output[*]}"
      unset IFS
    }

  #
  # DESC: Options logic
  #
    function get_option
    {
      case "${OPTION}" in
        "-u" | "--uninstall" )
          DO_UNINSTALL=true ;;

        "-i" | "--install" )
          DO_INSTALL=true ;;

        "" )
          return 0 ;;

        "-h" | "--help" | * )
          print_usage
          return 1 ;;
      esac
    }

  #
  # DESC: Copy Source Files to Destination
  #
    function copy_source_files_to_destination
    {
      copy_binary_files_to_destination || return 1
      copy_script_files_to_destination || return 1
      copy_service_files_to_destination

      if ! copy_binary_files_to_destination \
        || ! copy_script_files_to_destination \
        || ! copy_service_files_to_destination; then
        return 1
      fi

      return 0
    }

    function copy_binary_files_to_destination
    {
      for bin in "${BIN_LIST[@]}"; do
        local bin_name="$( basename "${bin}" )"
        local bin_path="${BIN_DEST_PATH}${bin_name}"

        if ! sudo cp --force "${bin}" "${bin_path}" &> /dev/null; then
          log_error "Failed to copy project binaries."
          return 1
        fi
      done

      return 0
    }

    function copy_script_files_to_destination
    {
      for script in "${SCRIPT_LIST[@]}"; do
        local script_source_file="${WORKING_DIR}${script}"
        local script_dest_file="${SCRIPT_DEST_PATH}${script:6}"
        local script_dest_dir="$( dirname "${script_dest_file}" )/"

        if ! does_path_exist "${script_dest_dir}" \
          || ! sudo rsync --archive --recursive --verbose "${script_source_file}" \
            "${script_dest_dir}" &> /dev/null; then
          log_error "Failed to copy project script(s)."
          return 1
        fi
      done

      return 0
    }

    function copy_service_files_to_destination
    {
      for service in "${SERVICE_LIST[@]}"; do
        local service_name="$( basename "${service}" )"
        local service_path="${SERVICE_DEST_PATH}/${service_name}"

        if ! sudo cp --force "${service}" "${service_path}" &> /dev/null; then
          log_error "Failed to copy project service(s)."
          return 1
        fi
      done
    }

  #
  # DESC: Delete Destination Files
  #
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

      if ! rm --force --recursive "${BIN_DEST_PATH}" &> /dev/null; then
        log_error "Failed to delete project binaries."
        return 1
      fi
    }

    function delete_script_files
    {
      if [[ ! -d "${SCRIPT_DEST_PATH}" ]]; then
        return 0
      fi

      if ! rm --force --recursive ${SCRIPT_DEST_PATH}* &> /dev/null; then
        log_error "Failed to delete project script(s)."
        return 1
      fi
    }

    function delete_service_files
    {
      if [[ ! -d "${SERVICE_DEST_PATH}" ]]; then
        return 0
      fi

      for service in "${SERVICE_LIST[@]}"; do
        local service_name="$( basename "${service}" )"
        local service_path="${SERVICE_DEST_PATH}${service_name}"

        if ! rm --force "${service_path}" &> /dev/null; then
          log_error "Failed to delete project service(s)."
          return 1
        fi
      done
    }

  #
  # DESC: Do source files exist
  #
    function do_source_files_exist
    {
      if ! do_binary_files_exist \
        || ! do_script_files_exist \
        || ! do_service_files_exist; then
        return 1
      fi

      return 0
    }

    function do_binary_files_exist
    {
      for bin in "${BIN_LIST[@]}"; do
        if [[ ! -e "${bin}" ]]; then
          log_error "Missing project binaries."
          return 1
        fi
      done

      return 0
    }

    function do_script_files_exist
    {
      for script in "${SCRIPT_LIST[@]}"; do
        if [[ ! -e "${script}" ]]; then
          log_error "Missing project scripts."
          return 1
        fi
      done

      return 0
    }

    function do_service_files_exist
    {
      for service in "${SERVICE_LIST[@]}"; do
        if [[ ! -e "${service}" ]]; then
          log_error "Missing project services."
          return 1
        fi
      done

      return 0
    }

  #
  # DESC: Dependency validation
  #
    function are_dependencies_installed
    {
      local -r systemd_app="systemd"

      if ! command -v "${systemd_app}" &> /dev/null; then
        log_error "Required dependency '${systemd_app}' is not installed."
        return 1
      fi

      local -r str_output="$( systemctl status "${LIBVIRTD_SERVICE}" )"

      if [[ \
        "${str_output}" == "Unit ${LIBVIRTD_SERVICE}.service could not be found." \
        ]]; then
        log_error "Required service '${LIBVIRTD_SERVICE}' is not installed."
        return 1
      fi

      log_pass "Dependencies are installed."
      return 0
    }

    function do_install_audio_loopback
    {
      for key in "${!SCRIPT_LIST[@]}"; do
        local script="${SCRIPT_LIST["${key}"]}"

        if ! "${DO_INSTALL_AUDIO_LOOPBACK}" \
          && is_file_for_pulseaudio "${script}"; then
          unset SCRIPT_LIST["${key}"]
        fi
      done

      for key in "${!SERVICE_LIST[@]}"; do
        local service="${SERVICE_LIST["${key}"]}"
        local service_name="$( basename "${service}" )"

        if ! "${DO_INSTALL_AUDIO_LOOPBACK}" \
          && is_file_for_pulseaudio "${service_name}"; then
          unset SERVICE_LIST["${key}"]
        fi
      done

      return 0
    }

    function is_pulseaudio_installed
    {
      if command -v "pulseaudio" &> /dev/null \
        && command -v "pactl" &> /dev/null; then
        DO_INSTALL_AUDIO_LOOPBACK=true
      fi

      return 0
    }

    function is_file_for_pulseaudio
    {
      case "${1}" in
        *"${AUDIO_LOOPBACK_HOOK_NAME}"* )
          return 0 ;;
      esac

      return 1
    }

  #
  # DESC: Do Destination Paths Exist
  #
    function does_destination_path_exist
    {
      if ! does_path_exist "${BIN_DEST_PATH}" \
        || ! does_script_path_exist \
        || ! does_path_exist "${SERVICE_DEST_PATH}"; then
        return 1
      fi

      return 0
    }

    function does_path_exist
    {
      local -r path="${1}"

      if [[ ! -d "${path}" ]] \
        && ! sudo mkdir --parents "${path}" &> /dev/null; then
        log_error "Could not create directory '${path}'."
        return 1
      fi

      return 0
    }

    function does_script_path_exist
    {
      does_path_exist "${SCRIPT_DEST_PATH}" || return 1

      for script_subdir in "${SCRIPT_SUBDIR_LIST[@]}"; do
        script_subdir="${script_subdir:6}"
        script_subdir="${SCRIPT_DEST_PATH}${script_subdir}"
        does_path_exist "${script_subdir}" || return 1
      done

      return 0
    }

  #
  # DESC: Services logic
  #
    function update_services
    {
      if ! systemctl daemon-reload &> /dev/null; then
        log_error "Could not update services."
        return 1
      fi

      if ! systemctl enable "${LIBVIRTD_SERVICE}" &> /dev/null; then
        log_error "Could not enable ${LIBVIRTD_SERVICE}."
        return 1
      fi

      if ! systemctl restart "${LIBVIRTD_SERVICE}" &> /dev/null; then
        log_error "Could not start ${LIBVIRTD_SERVICE}."
        return 1
      fi

      log_pass "Updated services."
      return 0
    }

  #
  # DESC: Set Permissions For Destination Files
  #
    function set_permissions_for_destination_files
    {
      if ! set_permissions_for_binary_files \
        || ! set_permissions_for_script_files \
        || ! set_permissions_for_service_files; then
        return 1
      fi

      return 0
    }

    function set_permissions_for_binary_files
    {
      if ! sudo chown --recursive --silent root:root "${BIN_DEST_PATH}" \
        || ! sudo chmod --recursive --silent +x "${BIN_DEST_PATH}"; then
        log_error "Failed to set file permissions for binaries."
        return 1
      fi

      return 0
    }

    function set_permissions_for_script_files
    {
      if ! sudo chown --recursive --silent root:root "${SCRIPT_DEST_PATH}" \
        || ! sudo chmod --recursive --silent +x "${SCRIPT_DEST_PATH}"; then
        log_error "Failed to set file permissions for script(s)."
        return 1
      fi

      return 0
    }

    function set_permissions_for_service_files
    {
      if ! sudo chown --recursive --silent root:root "${SERVICE_DEST_PATH}"; then
        log_error "Failed to set file permissions for service(s)."
        return 1
      fi

      for service in "${SERVICE_LIST[@]}"; do
        local this_service_path="${SERVICE_DEST_PATH}$( basename "${service}" )"

        if ! sudo chmod --recursive --silent +x "${this_service_path}"; then
          log_error "Failed to set file permissions for service '${service}'."
          return 1
        fi
      done

      return 0
    }

#
# main
#
  trap 'catch_error' SIGINT SIGTERM ERR
  trap 'catch_exit' EXIT
  main