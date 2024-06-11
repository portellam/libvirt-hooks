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
    STR_PREFIX_PROMPT="$( basename "${0}" ): "

    STR_PREFIX_ERROR="${STR_PREFIX_PROMPT}${SET_COLOR_YELLOW}An error occurred:"\
      "${RESET_COLOR} "

    STR_PREFIX_FAIL="${STR_PREFIX_PROMPT}${SET_COLOR_RED}Failure:${RESET_COLOR} "
    STR_PREFIX_PASS="${STR_PREFIX_PROMPT}${SET_COLOR_GREEN}Success:${RESET_COLOR} "

  declare -r LIBVIRTD_SERVICE="libvirtd"

  declare -r BIN_DEST_PATH="/usr/local/bin/libvirt-hooks/"
  declare -r BIN_SOURCE_PATH="${WORKING_DIR}bin/"
  declare -r SCRIPT_DEST_PATH="/etc/libvirt/hooks/"
  declare -r SCRIPT_SOURCE_RELATIVE_PATH="hooks/"
  declare -r SERVICE_DEST_PATH="/etc/systemd/system/"
  declare -r SERVICE_SOURCE_PATH="${WORKING_DIR}systemd/"

  declare -ar BIN_LIST=( $( find -L "${BIN_SOURCE_PATH}" -maxdepth 1 -type f ) )
  declare -ar SCRIPT_LIST=( $( find -L "${SCRIPT_SOURCE_RELATIVE_PATH}" -type f ) )

  declare -a SCRIPT_SUBDIR_LIST=( \
    $( find -L "${SCRIPT_SOURCE_RELATIVE_PATH}" -type d ) \
  )

  unset SCRIPT_SUBDIR_LIST[0]
  readonly SCRIPT_SUBDIR_LIST

  declare -ar SERVICE_LIST=( \
    $( find -L "${SERVICE_SOURCE_PATH}" -maxdepth 1 -type f ) \
  )

#
# logic
#
  #
  # DESC:   Main execution.
  # RETURN: If successful, return 0.
  #         If not, return 1.
  #
    function main
    {
      if ! is_user_superuser \
        || ! get_option \
        || ! prompt_install \
        || ( \
          "${DO_UNINSTALL}" \
          && ! uninstall \
        ) \
        || ! are_dependencies_installed \
        || ( \
          "${DO_INSTALL}" \
          && ! install \
        ) \
        || ! update_services; then
        exit 1
      fi

      exit 0
    }

  #
  # DESC:   Set the flags given the option passed.
  # RETURN: If option is valid, return 0.
  #         If not, return 1.
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

      return 0
    }

  #
  # DESC:   Print usage.
  # RETURN: Always return 0.
  #
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
      return 0
    }

  #
  # DESC:   Reset internal field separator.
  # RETURN: Always return 0.
  #
    function reset_ifs
    {
      IFS="${SAVEIFS}"
      return 0
    }

  #
  # DESC:   Exit on error.
  # RETURN: Always exit 1.
  #
    function catch_error
    {
      exit 1
    }

  #
  # DESC:   Execute logic on exit.
  # RETURN: Always return 0.
  #
    function catch_exit
    {
      reset_ifs
      return 0
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
        echo -e "${STR_PREFIX_ERROR}${1}" >&2
        return 0
      }

    #
    # DESC:   Log the output as a fail.
    # $1:     the output as a string.
    # RETURN: Always return 0.
    #
      function log_fail
      {
        echo -e "${STR_PREFIX_FAIL}${1}" >&2
        return 0
      }

    #
    # DESC:   Log the output as a fail.
    # $1:     the output as a string.
    # RETURN: Always return 0.
    #
      function log_output
      {
        echo -e "${STR_PREFIX_PROMPT}${1}" >&1
        return 0
      }

    #
    # DESC:   Log the output as a pass.
    # $1:     the output as a string.
    # RETURN: Always return 0.
    #
      function log_pass
      {
        echo -e "${STR_PREFIX_PASS}${1}" >&1
        return 0
      }

  #
  # DESC: compatibility checks
  #
    #
    # DESC:   Are dependencies installed.
    # RETURN: If true, return 0.
    #         If false, return 1.
    #
      function are_dependencies_installed
      {
        local -r str_package="systemd"

        if ! command -v "${str_package}" &> /dev/null; then
          log_error "Required dependency '${str_package}' is not installed."
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

    #
    # DESC:   Is user sudo or root.
    # RETURN: If true, return 0.
    #         If false, return 1.
    #
      function is_user_superuser
      {
        if [[ $( whoami ) != "root" ]]; then
          log_error "User is not sudo or root."
          return 1
        fi

        log_output "User is sudo or root."
        return 0
      }

  #
  # DESC:   Prompt a yes or no question.
  # $1:     the output as a string.
  # RETURN: If answer is yes, return 0.
  #         If answer is no, return 255.
  #         If answer is not valid, return 1.
  #
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
  # DESC:   Prompt to install or uninstall.
  # RETURN: If selected to install or uninstall, return 0.
  #         If not, return 1.
  #
    function prompt_install
    {
      if "${DO_INSTALL}" \
        || "${DO_UNINSTALL}"; then
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

      return 0
    }

  #
  # DESC:   Install.
  # RETURN: If successful, return 0.
  #         If not, return 1.
  #
    function install
    {
      if ! do_source_files_exist \
        || ! create_destination_directories \
        || ! copy_files_to_destination \
        || ! set_destination_files_permissions; then
        log_fail "Could not install ${REPO_NAME}."
        return 1
      fi

      log_pass "Installed ${REPO_NAME}."
    }

  #
  # DESC:   Uninstall.
  # RETURN: If successful, return 0.
  #         If not, return 1.
  #
    function uninstall
    {
      if ! delete_destination_files; then
        log_fail "Could not uninstall ${REPO_NAME}."
        return 1
      fi

      log_pass "Uninstalled ${REPO_NAME}."
    }

    #
    # DESC:   Copy services to destination.
    # RETURN: If successful, return 0.
    #         If not, return 1.
    #
      function copy_files_to_destination
      {
        if ! copy_binaries_to_destination \
          || ! copy_scripts_to_destination \
          || ! copy_services_to_destination; then
          log_error "Could not copy one or more file(s) to destination."
          return 1
        fi

        log_output "Copied files to destination."
        return 0
      }

    #
    # DESC:   Copy services to destination.
    # RETURN: If successful, return 0.
    #         If not, return 1.
    #
      function copy_binaries_to_destination
      {
        for str_bin in "${BIN_LIST[@]}"; do
          local str_bin_name="$( basename "${str_bin}" )"
          local str_bin_path="${BIN_DEST_PATH}${str_bin_name}"

          if ! sudo cp --force "${str_bin}" "${str_bin_path}" &> /dev/null; then
            log_error "Could not copy binaries '${str_script_source_file}' to "\
              "destination."
            return 1
          fi
        done

        log_output "Copied binaries to destination."
        return 0
      }

    #
    # DESC:   Copy script to destination.
    # RETURN: If successful, return 0.
    #         If not, return 1.
    #
      function copy_scripts_to_destination
      {
        for str_script in "${SCRIPT_LIST[@]}"; do
          local str_script_source_file="${WORKING_DIR}${str_script}"
          local str_script_dest_file="${SCRIPT_DEST_PATH}${str_script:6}"
          local str_script_dest_dir="$( dirname "${str_script_dest_file}" )/"

          if ! create_directory "${str_script_dest_dir}" \
            || ! sudo rsync --archive --recursive --verbose \
              "${str_script_source_file}" "${str_script_dest_dir}" &> /dev/null; then
            log_error "Could not copy script '${str_script_source_file}' to "\
              "destination."

            return 1
          fi
        done

        log_output "Copied scripts to destination."
        return 0
      }

    #
    # DESC:   Copy services to destination.
    # RETURN: If successful, return 0.
    #         If not, return 1.
    #
      function copy_services_to_destination
      {
        for str_service in "${SERVICE_LIST[@]}"; do
          local str_service_name="$( basename "${service}" )"
          local str_service_path="${SERVICE_DEST_PATH}/${str_service_name}"

          if ! sudo cp --force "${str_service}" "${str_service_path}" \
              &> /dev/null; then
            log_error "Could not copy service '${str_service}' to destination."
            return 1
          fi
        done

        log_output "Copied services to destination."
        return 0
      }

    #
    # DESC:   Do files exist.
    # RETURN: If true, return 0.
    #         If false, return 1.
    #
      function do_source_files_exist
      {
        if ! do_binary_files_exist \
          || ! do_script_files_exist \
          || ! do_service_files_exist; then
          log_error "One or more file(s) do not exist."
          return 1
        fi

        log_output "Files exist."
        return 0
      }

    #
    # DESC:   Delete destination files.
    # RETURN: If successful, return 0.
    #         If not, return 1.
    #
      function delete_destination_files
      {
        if ! delete_directory "${BIN_DEST_PATH}" \
          || ! delete_directory "${SCRIPT_DEST_PATH}" \
          || ! delete_destination_services; then
          log_error "Could not delete one or more destination file(s)."
          return 1
        fi

        log_output "Deleted destination files."
        return 0
      }

    #
    # DESC:   Delete directory.
    # $1:     the directory as a string.
    # RETURN: If successful, return 0.
    #         If not, return 1.
    #
      function delete_directory
      {
        local -r str_directory="${1}"

        if [[ -z "${str_directory}" ]] \
          || [[ ! -d "${str_directory}" ]]; then
          log_output "Directory is deleted."
          return 0
        fi

        if ! rm --force --recursive "${str_directory}" &> /dev/null; then
          log_error "Could not delete directory."
          return 1
        fi

        log_output "Deleted directory."
        return 0
      }

    #
    # DESC:   Delete directory.
    # RETURN: If successful, return 0.
    #         If not, return 1.
    #
      function delete_destination_services
      {
        if [[ ! -d "${SERVICE_DEST_PATH}" ]]; then
          log_output "Services are deleted."
          return 0
        fi

        for str_service in "${SERVICE_LIST[@]}"; do
          local str_service_name="$( basename "${str_service}" )"
          local str_service_path="${SERVICE_DEST_PATH}${str_service_name}"

          if ! rm --force --recursive "${str_service_path}" &> /dev/null; then
            log_error "Could not delete service '${str_service_path}'."
            return 1
          fi
        done

        log_output "Deleted services."
        return 0
      }

    #
    # DESC:   Do binary files exist.
    # RETURN: If true, return 0.
    #         If false, return 1.
    #
      function do_binary_files_exist
      {
        for str_binary in "${BIN_LIST[@]}"; do
          if [[ ! -e "${str_binary}" ]]; then
            log_error "Binary file '${str_binary}' does not exist."
            return 1
          fi
        done

        log_output "Binary files exist."
        return 0
      }

    #
    # DESC:   Do script files exist.
    # RETURN: If true, return 0.
    #         If false, return 1.
    #
      function do_script_files_exist
      {
        for str_script in "${SCRIPT_LIST[@]}"; do
          if [[ ! -e "${str_script}" ]]; then
            log_error "Script file '${script}' does not exist."
            return 1
          fi
        done

        log_output "Script files exist."
        return 0
      }

    #
    # DESC:   Do service files exist.
    # RETURN: If true, return 0.
    #         If false, return 1.
    #
      function do_service_files_exist
      {
        for str_service in "${SERVICE_LIST[@]}"; do
          if [[ ! -e "${str_service}" ]]; then
            log_error "Service file '${str_service}' does not exist."
            return 1
          fi
        done

        log_output "Service files exist."
        return 0
      }

    #
    # DESC:   Create destination directories.
    # RETURN: If successful, return 0.
    #         If not, return 1.
    #
      function create_destination_directories
      {
        if ! create_directory "${BIN_DEST_PATH}" \
          || ! create_directory "${SERVICE_DEST_PATH}" \
          || ! create_directory "${SCRIPT_DEST_PATH}" \
          || ! create_script_directories; then
          log_error "One or more destination directories do not exist."
          return 1
        fi

        log_output "Destination directories exist."
        return 0
      }

    #
    # DESC:   Create the directory.
    # $1:     the directory as a string.
    # RETURN: If successful, return 0.
    #         If not, return 1.
    #
      function create_directory
      {
        local -r str_directory="${1}"

        if [[ -z "${str_directory}" ]]; then
          log_error "Directory does not exist."
          return 2
        fi

        if [[ ! -d "${str_directory}" ]] \
          && ! sudo mkdir --parents "${str_directory}" &> /dev/null; then
          log_error "Could not create directory '${str_directory}'."
          return 1
        fi

        log_output "Directory '${str_directory}' exists."
        return 0
      }

    #
    # DESC:   Create script directories.
    # RETURN: If successful, return 0.
    #         If not, return 1.
    #
      function create_script_directories
      {
        for str_script_subdir in "${SCRIPT_SUBDIR_LIST[@]}"; do
          str_script_subdir="${str_script_subdir:6}"
          str_script_subdir="${SCRIPT_DEST_PATH}${str_script_subdir}"

          if ! create_directory "${str_script_subdir}"; then
            log_error "Script directory '${str_directory}' does not exist."
            return 1
          fi
        done

        log_output "Script directory '${str_directory}' exists."
        return 0
      }

    #
    # DESC:   Set permissions for destination files.
    # RETURN: If successful, return 0.
    #         If not, return 1.
    #
      function set_destination_files_permissions
      {
        if ! set_file_owner "${BIN_DEST_PATH}" "root" \
          || ! set_file_execute_permission "${BIN_DEST_PATH}" \
          || ! set_file_owner "${SCRIPT_DEST_PATH}" "root" \
          || ! set_file_execute_permission "${SCRIPT_DEST_PATH}" \
          || ! set_file_owner "${SERVICE_DEST_PATH}" "root" \
          || ! set_services_execute_permissions; then
          log_error "Could not set file permissions for destination files."
          return 1
        fi

        log_output "Set permissions for destination files."
        return 0
      }

    #
    # DESC:   Set user as the owner of the file.
    # $1:     the file name as a string.
    # $2:     the user name as a string.
    # RETURN: If successful, return 0.
    #         If not, return 1.
    #
      function set_file_owner
      {
        local -r str_user="${2}"

        if [[ -z "${str_user}" ]]; then
          log_error "User does not exist."
          return 2
        fi

        if ! id "${str_user}" >/dev/null 2>&1; then
          log_error "User '${str_user}' does not exist."
          return 2
        fi

        local -r str_file="${1}"

        if [[ -z "${str_file}" ]]; then
          log_error "File does not exist."
          return 2
        fi

        if [[ ! -e "${str_file}" ]]; then
          log_error "File '${str_file}' does not exist."
          return 2
        fi

        if ! sudo chown --recursive --silent ${str_user}:${str_user} \
            "${str_file}"; then
          log_fail "Could not set '${str_user}' as owner of file '${str_file}'."
          return 1
        fi

        log_output "Set '${str_user}' as owner of file '${str_file}'."
        return 0
      }

    #
    # DESC:   Set execute permission for file.
    # $1:     the file name as a string.
    # $2:     the user name as a string.
    # RETURN: If successful, return 0.
    #         If not, return 1.
    #
      function set_file_execute_permission
      {
        local -r str_file="${1}"

        if [[ -z "${str_file}" ]]; then
          log_error "File does not exist."
          return 2
        fi

        if [[ ! -e "${str_file}" ]]; then
          log_error "File '${str_file}' does not exist."
          return 2
        fi

        if ! sudo chmod --recursive --silent +x "${str_file}"; then
          log_fail "Could set execute permission for file '${str_file}'."
          return 1
        fi

        log_output "Set execute permission for file '${str_file}'."
        return 0
      }

    #
    # DESC:   Set execute permissions for services.
    # RETURN: If successful, return 0.
    #         If not, return 1.
    #
      function set_services_execute_permissions
      {
        for str_service in "${SERVICE_LIST[@]}"; do
          local str_service_path="${SERVICE_DEST_PATH}$( basename "${service}" )"

          if ! set_file_execute_permission "${str_service_path}" ; then
            log_error "Could not set file permissions for service '${str_service}'."
            return 1
          fi
        done

        log_output "Set execute permission for service '${str_service}'."
        return 0
      }

    #
    # DESC:   Update services.
    # RETURN: If successful, return 0.
    #         If not, return 1.
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

        log_output "Updated services."
        return 0
      }

#
# main
#
  trap 'catch_error' SIGINT SIGTERM ERR
  trap 'catch_exit' EXIT
  main