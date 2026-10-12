#!/usr/bin/bash

test -v bashutils_sourced && return
declare -r bashutils_version='1.0.0'
declare bashutils_bash_source
declare -i bashutils_line_number
declare bashutils_function_name
declare -i bashutils_return_code
declare bashutils_stdout_path
declare bashutils_stderr_path
declare -ax bashutils_commands
declare -ax bashutils_errors
declare -a bashutils_temp_paths
declare -a bashutils_errors_snapshot
declare -i bashutils_fd_id=3
declare -ir bashutils_variable_true=1
declare -ir bashutils_variable_false=0
declare -ir bashutils_function_true=0
declare -ir bashutils_function_false=1
declare -r bashutils_sourced

declare -a bashsible::secrets

######################################################################################
## append every password you get in prompts to the bashsible::secrets list
## forget about _sensetive alternative of commands . search for elements of secrets list
## in every log and error entry in EXIT and ERR traps before printing them to terminal
## switch from file descriptor to process substitution for supplying passwords
## also store output of stdout and stderr to variables instead of temp files .
## also empty every secret variable name in the secrets list in the EXIT trap .
## use run_command for subprocesses 

# secret variable with sudo passing paradigm :
# secret_variable_name='xyz' ( prompted )
# command='command < <(printf "%s\n" "$secret_variable_name")'
# run_command_sudo_sensetive secret_variable_name command

# run_command_sudo_sensetive() {
#   export secret_variable_name
#   sudo --stdin --preserve-env bash -c $command < <(printf '%s\n' "$sudo_password")
#}

# process substitution is secure from ps
# convert stdin to process substitution : echo $var | command -> command < <(echo $var)
# add ( sudo --remove-timestamp 2>/dev/null || true ) to the error handler script


# curl --url "https://example.com" --config <(cat <<-EOF
# user = "${user}:${password}"
# header = "X-API-Key: ${api_key}"
# EOF
# )

# curl --url "https://example.com" --config <(printf 'user = "%s:%s"\n' "$username" "$password")

# use gpg --no-permission-warning if warning
# gpg --batch --passphrase-file <(echo "$password")

## openssl -pass file:<(echo "$password")

## mkpasswd < <(echo "$password")

# run_command_sudo() {
#     sudo --stdin "$@" < <(printf '%s\n' "$password")
#     sudo -n true 2>/dev/null && sudo --reset-timestamp
# }

######################################################################################


# check_fqdn
# check_port
# run_command_sudo
# run_command_handler

# is_terminal_interactive 

is_terminal_interactive() {
	[[ -e /dev/tty ]]
}

# are_characters_invalid_sensetive input_var

are_characters_valid_sensetive() {
	parameter_count 1 "$@"
	declare -n bashutils_input_ref=$1
	declare LC_ALL="C" 
	check_condition_sensetive [[ "$bashutils_input_ref" =~ ^[!-~]+$ ]]
}

# has_lowercase_character_sensetive input_var

has_character_lowercase_sensetive() {
	parameter_count 1 "$@"
	declare -n bashutils_input_ref=$1
	check_condition_sensetive [[ "$bashutils_input_ref" =~ [a-z] ]]
}

# has_uppercase_character_sensetive input_var

has_character_uppercase_sensetive() {
	parameter_count 1 "$@"
	declare -n bashutils_input_ref=$1
	check_condition_sensetive [[ "$bashutils_input_ref" =~ [A-Z] ]]
}

# has_number_character_sensetive input_var

has_character_number_sensetive() {
	parameter_count 1 "$@"
	declare -n bashutils_input_ref=$1
	check_condition_sensetive [[ "$bashutils_input_ref" =~ [0-9] ]]
}

# has_character_symbol_sensetive input_var

has_character_symbol_sensetive() {
	parameter_count 1 "$@"
	declare -n bashutils_input_ref=$1
	check_condition_sensetive [[ "$bashutils_input_ref" =~ [^a-zA-Z0-9] ]]
}

# prompt_user example_data_var prompt_banner validator_function_name

prompt_user() {
	parameter_count 3 "$@"
	declare -n bashutils_data_ref="$1"
	declare bashutils_prompt_banner="$2"
	declare bashutils_validator_func="$3"
	check_condition_error "Script is not run interactively" is_terminal_interactive
	declare bashutils_user_input=''
	until $bashutils_validator_func && bashutils_data_ref="$bashutils_user_input" || return 1
	do
		printf '%s' "$bashutils_prompt_banner" >/dev/tty
		read -r bashutils_user_input </dev/tty
		printf '\n' >/dev/tty
	done
}



# user_managment::is_group_member group_name
# user_managment::is_sudo_password password


id --user --real : user id 
id --user : user id effective
id --user --name --real : user name
id --user --name : user name effective


id --group : group id effective
id --group --name : group name effective
id --groups : group ids
id --groups --name : group names




# declare -i current_user_id
# user_managment::get_current_user_id current_user_id

user_managment::get_current_user_id() {
	parameter_count 1 "$@"
	declare -n current_user_id_ref=$1
	current_user_id_ref=$UID
}

# declare -i current_user_id_effective
# user_managment::get_current_user_id_effective current_user_id_effective

user_managment::get_current_user_id_effective() {
	parameter_count 1 "$@"
	declare -n current_user_id_ref=$1
	current_user_id_ref=$EUID
}

# declare current_user_name
# user_managment::get_current_user_name current_user_name

user_managment::get_current_user_name() {
	parameter_count 1 "$@"
	declare -n current_user_name_ref=$1
	current_user_name_ref="$(id --user --name --real)"
}

# declare current_user_name
# user_managment::get_current_user_name current_user_name

user_managment::get_current_user_name_effective() {
	parameter_count 1 "$@"
	declare -n current_user_name_effective_ref=$1
	current_user_name_effective_ref="$(id --user --name)"
}

# declare -i current_user_group_id
# user_managment::get_current_user_group_id current_user_group_id

user_managment::get_current_user_group_id() {
	parameter_count 1 "$@"
	declare -n current_user_group_id_ref=$1
	current_user_group_id_ref=$(id --group)
}

# declare current_user_group_name
# user_managment::get_current_user_group_name current_user_group_name

user_managment::get_current_user_group_name() {
	parameter_count 1 "$@"
	declare -n current_user_group_name_ref=$1
	current_user_group_name_ref="$(id --group --name)"
}

# declare -a current_user_group_ids
# user_managment::get_current_user_group_ids current_user_group_ids

user_managment::get_current_user_group_ids() {
	parameter_count 1 "$@"
	declare -n current_user_group_ids_ref=$1
	read -r -a current_user_group_ids_ref < <(id --groups)
}

# declare -a current_user_group_names
# user_managment::get_current_user_group_names current_user_group_names

user_managment::get_current_user_group_names() {
	parameter_count 1 "$@"
	declare -n current_user_group_names_ref=$1
	read -r -a current_user_group_names_ref < <(id --groups --name)
}

# declare other_user_name="root"
# declare -i other_user_id
# user_managment::get_other_user_id other_user_name other_user_id

user_managment::get_other_user_id() {
	parameter_count 2 "$@"
	declare -n other_user_name_ref=$1
	declare -n other_user_id_ref=$2
	other_user_id_ref=$(id --user -- $other_user_name_ref)
}

# declare -i other_user_id=0
# declare other_user_name
# user_managment::get_other_user_name other_user_id other_user_name


##################################################################################
	# run_command_pipe_output ( like this getent , check return code , if successful redirect stdout )
	# run_command_pipe_secret ( for password , < <(echo $password) )
	# run_command_pipe_file ( like curl --config , ssh file )
###################################################################################

user_managment::get_other_user_name() {
	parameter_count 2 "$@"
	declare -n other_user_id_ref=$1
	declare -n other_user_name_ref=$2




	# i need a helper that checks return code and captures stdout of the command in a variable 
	declare passwd_file_entry

	other_user_name_ref="$(getent passwd $other_user_id_ref | cut -d: -f1)"
}



IFS=: read -r username password uid gid gecos home shell < <(getent passwd "$user_id")


IFS=: read -r other_user_name_ref _ _ _ _ _ < <(getent passwd $other_user_id_ref)







# user_managment::get_user_name
# user_managment::get_user_name_effective

# user_managment::get_group_id
# user_managment::get_group_name
# user_managment::get_group_ids
# user_managment::get_group_names


remove_sudo_cache() {
	sudo --reset-timestamp
}

# is_sudo_password bashutils_user_input

is_sudo_password() {
	parameter_count 1 "$@"
	declare -n password_ref="$1"
	remove_sudo_cache
	check_condition_error "Sudo Authentication Failed With Supplied Password" sudo --stdin --validate < <(printf '%s\n' "$password_ref")
	remove_sudo_cache
}








if [[ " $(id -nG) " == *" sudo "* ]]

first check being in sudo group . if not : not authorized
if in group , then check password



password incorrect OR sudo not authorized


# bashutils_check_password 

bashutils_check_password() {
	check_condition_error "Password should be at least 12 characters" is_string_length_min bashutils_user_input 12
	check_condition_error "Password contains SPACE or non ENGLISH characters" are_characters_valid_sensetive bashutils_user_input
	check_condition_error "Password does NOT contain lower case letters" has_lowercase_character_sensetive bashutils_user_input
	check_condition_error "Password does NOT contain upper case letters" has_uppercase_character_sensetive bashutils_user_input
	check_condition_error "Password does NOT contain numbers" has_number_character_sensetive bashutils_user_input
	check_condition_error "Password does NOT contain symbols" has_character_symbol_sensetive bashutils_user_input
}

# prompt_user_password example_password_var prompt_banner 

prompt_user_password() {
	parameter_count 2 "$@"
	declare -n bashutils_password_ref="$1"
	declare bashutils_prompt_banner="$2"
	check_condition_error "Script is not run interactively" is_terminal_interactive
	declare bashutils_user_input=''
	until bashutils_check_password && bashutils_password_ref="$bashutils_user_input" || return 1
	do
		printf '%s' "$bashutils_prompt_banner" >/dev/tty
		read -r -s bashutils_user_input </dev/tty
		printf '\n' >/dev/tty
	done
}

# declare -i example_password_fd
# create_password_fd example_password_var example_password_fd

set_password_fd() {
	parameter_count 2 "$@"
	declare example_password_var="$1"
	declare -n example_password_fd_ref=$2
	example_password_fd_ref=$bashutils_fd_id
	execute_command_sensetive exec $bashutils_fd_id<<< "$example_password_var"
	(( bashutils_fd_id++ ))
}

# declare bashutils_log_entry
# mask_command_line bashutils_log_entry "$*"

mask_command_line() {
	parameter_count 2 "$@"
	declare -n masked_ref=$1
    declare command_line="$2"
	[[ "$command_line" == *=~* ]] && {
		declare regex_pattern="${command_line#* =~ }"
		regex_pattern="${regex_pattern% ]]*}"
		masked_ref="[[ ******** =~ $regex_pattern ]]"
	} || {
		masked_ref="${command_line% *} ********"
	}
}

# log_command "$*"

log_command() {
	parameter_count 1 "$@"
	append_list_elements bashutils_commands "$1"
}

# log_command_sensetive "$*"

log_command_sensetive() {
	parameter_count 1 "$@"
	declare command_line_masked
	mask_command_line command_line_masked "$1"
	log_command "$command_line_masked"
}

# create_temp_path temp_path_variable

create_temp_path() {
	parameter_count 1 "$@"
	declare $ref_opt path_ref=$1
	path_ref=$(mktemp)
	append_list_elements bashutils_temp_paths $path_ref
}

# get_errors_snapshot

get_errors_snapshot() {
	copy_list bashutils_errors bashutils_errors_snapshot
}

# set_errors_snapshot || return $function_false

set_errors_snapshot() {
	copy_list bashutils_errors_snapshot bashutils_errors
}

# get_execution_context

get_execution_context() {
	declare $int_opt nest_level
	for_each_function() {
		(( list_index > 0 )) && \
		[[ "$list_element" != execute_command* && "$list_element" != run_command_* && "$list_element" != check_condition* ]] && {
			nest_level=$list_index
			break_loop
		}
	}
	for_loop FUNCNAME for_each_function
	get_list_element FUNCNAME $nest_level bashutils_function_name
	get_list_element BASH_SOURCE $nest_level bashutils_bash_source
	get_list_element BASH_LINENO $(( nest_level - 1 )) bashutils_line_number
	create_temp_path bashutils_stdout_path
	create_temp_path bashutils_stderr_path
}

# log_error "$*"

log_error() {
	bashutils_return_code=$?
	parameter_count 1 "$@"
	declare bashutils_command_line="$1"
	declare bashutils_error_entry
	declare bashutils_error_timestamp="$(date -u +'%Y/%m/%d %H:%M:%S')"
	declare bashutils_standard_output=$(<"$bashutils_stdout_path")
	declare bashutils_standard_error=$(<"$bashutils_stderr_path")
	assign_text bashutils_error_entry <<-EOF
		Time Stamp      : $bashutils_error_timestamp
		Script Name     : $bashutils_bash_source
		Line Number     : $bashutils_line_number
		Function Name   : $bashutils_function_name
		Command Line    : $bashutils_command_line
		Return Code     : $bashutils_return_code
		Standard Error  : $bashutils_standard_error
		Standard Output : $bashutils_standard_output
	EOF
	append_list_elements bashutils_errors_list bashutils_error_entry
}

# log_error_message error_message_value "$*"

log_error_message() {
	bashutils_return_code=$?
	parameter_count 2 "$@"
	declare bashutils_script_error="$1"
	declare bashutils_command_line="$2"
	declare bashutils_error_entry
	declare bashutils_error_timestamp="$(date -u +'%Y/%m/%d %H:%M:%S')"
	declare bashutils_standard_output=$(<"$bashutils_stdout_path")
	declare bashutils_standard_error=$(<"$bashutils_stderr_path")
	assign_text bashutils_error_entry <<-EOF
		Time Stamp      : $bashutils_error_timestamp
		Script Name     : $bashutils_bash_source
		Line Number     : $bashutils_line_number
		Function Name   : $bashutils_function_name
		Command Line    : $bashutils_command_line
		Return Code     : $bashutils_return_code
		Standard Error  : $bashutils_standard_error
		Standard Output : $bashutils_standard_output
		Script Error    : $bashutils_script_error
	EOF
	append_list_elements bashutils_errors_list bashutils_error_entry
}

# execute_script script_name script_arguments...

execute_script() {
	parameter_count_minimum 1 "$@"
	get_execution_context
	"$@" || log_context "$*"
	return $bashutils_return_code
}

# execute_script_error error_message_value script_name script_arguments...

execute_script_error() {
	parameter_count_minimum 2 "$@"
	declare bashutils_script_error="$1"
	shift
	get_execution_context
	"$@" || log_context_message "$bashutils_script_error" "$*"
	return $bashutils_return_code
}

# execute_command "$@"

execute_command() {
	parameter_count_minimum 1 "$@"
	get_execution_context
	"$@" 1>$bashutils_stdout_path 2>$bashutils_stderr_path || log_error "$*"
	return $bashutils_return_code
}

# execute_command_sensetive "$@"

execute_command_sensetive() {
	parameter_count_minimum 1 "$@"
	declare command_line_masked
	mask_command_line command_line_masked "$*"
	get_execution_context
	"$@" 1>$bashutils_stdout_path 2>$bashutils_stderr_path || log_error "$command_line_masked"
	return $bashutils_return_code
}

# execute_command_error error_message_value "$@"

execute_command_error() {
	parameter_count_minimum 2 "$@"
	declare bashutils_script_error="$1"
	shift 
	get_execution_context
	"$@" 1>$bashutils_stdout_path 2>$bashutils_stderr_path || log_error "$bashutils_script_error" "$*"
	return $bashutils_return_code
}

# execute_command_sensetive_error error_message_value "$@"

execute_command_sensetive_error() {
	parameter_count_minimum 2 "$@"
	declare bashutils_script_error="$1"
	shift
	declare command_line_masked
	mask_command_line command_line_masked "$*"
	get_execution_context
	"$@" 1>$bashutils_stdout_path 2>$bashutils_stderr_path || log_error "$bashutils_script_error" "$command_line_masked"
	return $bashutils_return_code
}

# run_command command_line_value

run_command() {
	parameter_count_minimum 1 "$@"
	log_command "$*"
	execute_command "$@"
}

# run_command_error error_message_value command_line_value

run_command_error() {
	parameter_count_minimum 2 "$@"
	declare bashutils_script_error="$1"
	shift
	log_command "$*"
	execute_command_error "$bashutils_script_error" "$@"
}

# run_command_sensetive command_line_value

run_command_sensetive() {
	parameter_count_minimum 1 "$@"
	log_command_sensetive "$*"
	execute_command_sensetive "$@"
}

# run_command_sensetive_error error_message_value command_line_value

run_command_sensetive_error() {
	parameter_count_minimum 2 "$@"
	declare bashutils_script_error="$1"
	shift
	log_command_sensetive "$*"
	execute_command_sensetive_error "$bashutils_script_error" "$@"
}

# check_condition_required condition_line

check_condition() {
	parameter_count_minimum 1 "$@"
	execute_command "$@" || return 1
}

# check_condition_required_inverted condition_line

check_condition_inverted() {
	parameter_count_minimum 1 "$@"
	! execute_command "$@"
}

# check_condition_required_sensetive condition_line

check_condition_sensetive() {
	parameter_count_minimum 1 "$@"
	execute_command_sensetive "$@" || return 1
}

# check_condition_required_error error_message_value condition_line

check_condition_error() {
	parameter_count_minimum 2 "$@"
	declare bashutils_script_error="$1"
	shift
	execute_command_error "$bashutils_script_error" "$@" || return 1
}

# check_condition_required_sensetive_error error_message_value condition_line

check_condition_sensetive_error() {
	parameter_count_minimum 2 "$@"
	declare bashutils_script_error="$1"
	shift
	execute_command_sensetive_error "$bashutils_script_error" "$@" || return 1
}

# bashutils_error_handler() {}

# trap 'bashutils_error_handler $? $LINENO $BASH_COMMAND' ERR

# for loop through bashutils_temp_paths and delete each
# bashutils_exit_handler() {}

# trap bashutils_exit_handler EXIT



















# declare bashutils_library_path
# get_bashutils_library_path bashutils_library_path

get_bashutils_library_path() {
	declare -n 
}


# get_parent_path()

# $(dirname "$path")

# get_bashutils_library_dir() : get_parent_path bashutils_library_dir

# declare -r bashutils_directory_path=$(dirname "${BASH_SOURCE[0]}")





# get path , loop and source every file in same dir as bashutils.bash file like "$bashutils_library_dir/bashutils_validation.bash" in the bashutils.bash file itself
# only source bashutils.bash in init function of bashutils . other files are sourced by the bashutils.bash itself
# include run_command , check_condition in bashutils.bash , seperate area specific functions in their own file













is_file_executable() {
	parameter_count 1 "$@"
	declare bashutils_file_path="$1"
	[[ -x "$bashutils_file_path" ]]
}

set_file_executable() {
	parameter_count 1 "$@"
	declare bashutils_file_path="$1"
	run_command_error "failed to make file ( ${bashutils_file_path} ) executable" chmod +x "$bashutils_file_path"
}

ensure_file_executable() {
	parameter_count 1 "$@"
	declare bashutils_file_path="$1"
	is_file_executable "$bashutils_file_path" && return $bashutils_function_true
	run_command set_file_executable "$bashutils_file_path"
	check_condition_error "failed to make file ( ${bashutils_file_path} ) executable" is_file_readable "$bashutils_file_path"
}

# is_file_permissions
# set_file_permissions
# ensure_file_permissions

# is_package_installed
# install_package_deb
# ensure_package_deb


# parameter_count 1 "$@"

parameter_count() {
	true_condition=$(($# >= 2))
	expect_error "function ( parameter_count ) requires at least 2 parameters" [[ $true_condition ]]
	expect_error "function ( parameter_count ) first parameter ( $1 ) should be a positive number" is_value_integer_natural "$1"
	declare "$integer_opt" target_parameter_count=$1
	declare "$integer_opt" parameter_count=$#
	parameter_count=$(( parameter_count - 1 ))
	true_condition=$(( parameter_count == target_parameter_count ))
	declare "$string_opt" parent_function_name="${FUNCNAME[1]}"
	expect_error "function ( ${parent_function_name} ) requires ${target_parameter_count} parameter(s)" [[ $true_condition ]]
}

# parameter_count_minimum 1 "$@"

parameter_count_minimum() {
	true_condition=$(($# >= 2))
	expect_error "function ( parameter_count ) requires at least 2 parameters" [[ $true_condition ]]
	expect_error "function ( parameter_count ) first parameter ( $1 ) should be a positive number" is_value_integer_natural "$1"
	declare "$integer_opt" minimum_parameter_count=$1
	declare "$integer_opt" parameter_count=$#
	parameter_count=$(( parameter_count - 1 ))
	true_condition=$(( parameter_count >= minimum_parameter_count ))
	declare "$string_opt" parent_function_name="${FUNCNAME[1]}"
	expect_error "function ( ${parent_function_name} ) requires at least ${target_parameter_count} parameter(s)" [[ $true_condition ]]
}

# ||||||||||||||||| FINAL PATTERN ||||||||||||||||||||||||||| 


# expect_error "variable ( $1 ) is not declared" is_variable_declared "$1"

# is_variable_declared variable_name

is_variable_declared() {
	parameter_count 1 "$@"
	[[ -v "$1" ]]
}

# get_variable_type variable_name variable_type

get_variable_type() {
	parameter_count 2 "$@"
	declare "$string_opt" variable_name="$1"
	declare "$reference_opt" type_reference="$2"
	declare "$string_opt" variable_declaration
	variable_declaration="$(declare -p "$variable_name" 2>/dev/null)"
	declare "$list_opt" variable_types
	append_list_elements variable_types string integer list dictionary
	declare "$list_opt" declaration_regexes
	append_list_elements declaration_regexes '[^[:space:]aAi]*' '[^[:space:]]*i' '[^[:space:]]*a' '[^[:space:]]*A'
	for_each_declaration_regex() {
		declare "$string_opt" declaration_regex
		declaration_regex='^declare[[:space:]]-'"$list_element"'[[:space:]]'
		if [[ "$variable_declaration" =~ $declaration_regex ]]
		then
			get_list_element variable_types $list_index type_reference
			break_loop
		fi
	}
	for_loop declaration_regexes for_each_declaration_regex
}

# is_variable_type { string | integer | list | dictionary } variable_name

# is_variable_type() {}













# is_value_integer integer_value ( -1 : true , 0 : true , 1 : true )

is_value_integer() {
	parameter_count 1 "$@"
	expect_error "value ( $1 ) is not an integer" [[ "$1" =~ ^-?[0-9]+$ ]]
}

# is_value_integer_whole integer_value ( -1 : false , 0 : true , 1 : true ) 

is_value_integer_whole() {
	parameter_count 1 "$@"
	expect_error "value ( $1 ) is not a whole number" [[ "$1" =~ ^[0-9]+$ ]]
}

# is_vlaue_integer_natural integer_value ( -1 : false , 0 : false , 1 : true ) 

is_value_integer_natural() {
	parameter_count 1 "$@"
	expect_error "value ( $1 ) is not a natural number" [[ "$1" =~ ^[1-9][0-9]*$ ]]
}

# is_value_boolean boolean_value

is_value_boolean() {
	parameter_count 1 "$@"
	expect_error "value ( $1 ) is not a boolean" [[ "$1" =~ ^[01]$ ]]
}



# is_value_assigned value 

is_value_assigned() {
	parameter_count 1 "$@"
	expect_error "variable ( $1 ) is not assigned" [[ -n "$1" ]]
}


assign_text() {
	parameter_count 1 "$@"
	declare -n variable_ref=$1
    read -r -d '' variable_ref
	variable_ref+=$'\n'
}


# declare -i string_length_var
# get_string_length string_var string_length_var  

get_string_length() {
	parameter_count 2 "$@"
	declare -n bashutils_length_ref="$1"
	declare -n bashutils_string_ref="$2"
	bashutils_length_ref=${#bashutils_string_ref}
}

# is_string_length_min string_var min_length_value

is_string_length_min() {
	parameter_count 2 "$@"
	declare bashutils_string_var="$1"
	declare -i bashutils_length_min=$2
	declare -i bashutils_string_length
	get_string_length bashutils_string_var bashutils_string_length
	[[ $bashutils_string_length -ge $bashutils_length_min ]]	 
}

# is_string variable_name

is_string() {
	parameter_count 1 "$@"
	declare "$reference_opt" variable_reference="$1"
	declare "$list_opt" is_string_true_conditions
	is_variable_declared "$1"
	append_list_elements is_string_true_conditions $?
	is_value_assigned "$variable_reference"
	append_list_elements is_string_true_conditions $?

}

# is_integer variable_name

# is_integer_() {}




is_list_assigned() {
	[[ -v "$1" && -v "${1}[0]" ]]
}

# -n "${array[0]}"

# -n ( value )
# ref then -n ( variable )

# is_scalar_variable_assigned() {}

# ${#var[@]} -gt 0

# is_list_assigned

# is_value_list ???

# is variable_assigned variable_name



# append_string variable_name string_value

append_string() {
	parameter_count 2 "@"
	delare $ref_opt variable_ref=$1
	declare string_suffix="$2"
	variable_ref+="$string_suffix"
}

# copy_list list_name dest_variable

copy_list() {
	parameter_count 2 "$@"
	declare $ref_opt list_ref=$1
	declare $ref_opt dest_variable_ref=$2
	dest_variable_ref=("${list_ref[@]}")
}

# get_list_element list_name list_index list_element

get_list_element() {
	parameter_count 3 "$@"
	declare "$reference_opt" list_reference=$1
	declare "$integer_opt" list_index=$2
	declare "$reference_opt" element_reference=$3
	element_reference=${list_reference[list_index]}
}

# is_list_element list_name value

is_list_element() {
	parameter_count 2 "$@"
	declare "$string_opt" list_name=$1
	declare "$string_opt" input_value=$2
	declare "$boolean_opt" return_code=$function_false 
	for_each_value() {
		if [[ "$list_element" == "$input_value" ]]
		then
			return_code=$function_true
			break_loop
		fi
	}
	for_loop $list_name for_each_value
	return $return_code
}

# get_list_length list_name list_length

get_list_size() {
	parameter_count 2 "$@"
	declare "$reference_opt" list_reference="$1"
	declare "$reference_opt" list_length="$2"
	list_length=${#list_reference[@]}
}

# is_length_same list_1_name list_2_name

are_lists_same_size() {
	parameter_count 2 "$@"
	declare list_1_name=$1
	declare list_2_name=$2
	declare $int_opt list_1_length
	declare $int_opt list_2_length
	get_list_size $list_1_name list_1_length
	get_list_size $list_2_name list_2_length
	(( list_1_length != list_2_length )) && return 1
}

# are_lists_same list_1_name list_2_name

are_lists_same() {
	parameter_count 2 "$@"
	declare list_1_name=$1
	declare list_2_name=$2
	are_lists_same_size $list_1_name $list_2_name
	declare $int_opt are_same=$function_true
	for_each_element() {
		declare list_2_element
		get_list_element $list_2_name $list_index list_2_element 
		[[ "$list_element" != "$list_2_element" ]] && {
			are_same=$function_false
			break_loop
		}
	}
	for_loop $list_1_name for_each_element
	(( are_same == function_false )) && return 1
}

# append_list_elements list_name list_element_value ...

append_list_elements() {
	parameter_count_minimum 2 "$@"
	declare "$reference_opt" list_reference="$1"
	shift
	list_reference+=("$@")
}

break_loop() {
	loop_break_reference=$variable_true
}

for_loop() {
	declare "$reference_opt" list_reference="$1"
	declare "$string_opt" function_name="$2"
	declare "$integer_opt" loop_break=$variable_false
	declare "$integer_opt" list_index
	for list_index in "${!list_reference[@]}"
	do
		declare "$reference_opt" list_element="list_reference[$list_index]"
		declare "$reference_opt" loop_break_reference=loop_break
		$function_name
		(( loop_break == $variable_false )) || {
			break
		}
	done
}

for_loop_reverse() {
	declare "$reference_opt" list_reference=$1
	declare "$string_opt" function_name=$2
	declare "$integer_opt" loop_break=$variable_false
	declare "$integer_opt" list_index
	declare "$string_opt" list_name=$1
	declare "$integer_opt" list_length
	get_list_length $list_name list_length
	for (( list_index=list_length - 1 ; list_index >= 0 ; list_index-- ))
	do
		declare "$reference_opt" list_element="list_reference[$list_index]"
		declare "$reference_opt" loop_break_reference=loop_break
		$function_name
		(( loop_break == $variable_false )) || {
			break
		}
	done
}










# undefined_function() { :; }
# assign_integer
# assign_list variable_name 'abc' 'xyz'










