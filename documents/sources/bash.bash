
#!/usr/bin/bash
set -o errtrace
set -o errexit
set -o nounset
set -o noglob
set -o pipefail
shopt -s inherit_errexit

bashsible_bash_error_trap() {
    (( $# == 2 ))
	local -i bash_error_code=$1
	local bash_error_command=$2
	local bash_error_message
    local -i bash_error_functions_count=${#FUNCNAME[@]}
    local -i bash_error_function_index
	read -r -d $'\x1c' bash_error_message <<-EOF
	
	Bashsible Error Message :
	
	Error Code : $bash_error_code
	Bash Command : $bash_error_command
    
    Function Hierarchy :
	$(printf '\x1c')
	EOF
    bash_error_message+=$'\n\n'
    for (( bash_error_function_index = 1 ; bash_error_function_index < bash_error_functions_count ; bash_error_function_index++ ))
    do
        local bash_error_this_function_name=${FUNCNAME[$bash_error_function_index]:-main}
        local bash_error_this_source_name=${BASH_SOURCE[$bash_error_function_index]:-main}
        local -i bash_error_this_source_line_number=${BASH_LINENO[$bash_error_function_index - 1 ]}
        bash_error_message+="${bash_error_this_function_name} [ ${bash_error_this_source_name} : ${bash_error_this_source_line_number} ]"
        bash_error_message+=$'\n'
    done
	printf '%s\n' "$bash_error_message" >&2
}

trap 'bashsible_bash_error_trap $? "$BASH_COMMAND"' ERR

trap 'bashsible_bash_exit_trap' EXIT

bashsible_bash_is_function_defined() {
    (( $# == 1 ))
    local bash_function_name=$1
    declare -F $bash_function_name &>/dev/null
}

bashsible_bash_is_variable_defined() {
    (( $# == 1 ))
    local bash_variable_name=$1
    declare -p $bash_variable_name &>/dev/null
}

bashsible_bash_undefine_variable() {
    (( $# == 1 ))
    local bash_variable_name=$1
    unset -v $bash_variable_name
}

bashsible_bash_undefine_variable_reference() {
    (( $# == 1 ))
    local bash_variable_ref=$1
    unset -n $bash_variable_ref
}

bashsible_bash_is_variable_assigned() {
    (( $# == 1 ))
    local bash_variable_name=$1
    bashsible_bash_is_variable_defined $bash_variable_name
    [[ -v $bash_variable_name ]]
}

bashsible_bash_get_variable_definition() {
    (( $# == 2 ))
    local bash_variable_name=$1
    local -n bash_variable_definition_ref=$2
    local bash_variable_declaration
    bashsible_bash_is_variable_defined $bash_variable_name
    bash_variable_declaration=$(declare -p $bash_variable_name)
    read -r _ bash_variable_definition_ref _ < <(printf '%s\n' "$bash_variable_declaration")
}

bashsible_bash_is_variable_type_reference() {
    (( $# == 1 ))
    local bash_variable_name=$1
    local bash_variable_definition
    bashsible_bash_get_variable_definition $bash_variable_name bash_variable_definition
    [[ $bash_variable_definition == *n* ]]
}

bashsible_bash_is_variable_type_readonly() {
    (( $# == 1 ))
    local bash_variable_name=$1
    local bash_variable_definition
    bashsible_bash_get_variable_definition $bash_variable_name bash_variable_definition
    [[ $bash_variable_definition == *r* ]]
}

bashsible_bash_is_variable_type_integer() {
    (( $# == 1 ))
    local bash_variable_name=$1
    local bash_variable_definition
    bashsible_bash_get_variable_definition $bash_variable_name bash_variable_definition
    [[ $bash_variable_definition == *i* ]]
}

bashsible_bash_is_variable_type_list() {
    (( $# == 1 ))
    local bash_variable_name=$1
    local bash_variable_definition
    bashsible_bash_get_variable_definition $bash_variable_name bash_variable_definition
    [[ $bash_variable_definition == *a* ]]
}

bashsible_bash_is_variable_type_dictionary() {
    (( $# == 1 ))
    local bash_variable_name=$1
    local bash_variable_definition
    bashsible_bash_get_variable_definition $bash_variable_name bash_variable_definition
    [[ $bash_variable_definition == *A* ]]
}

bashsible_bash_get_list_length() {
    (( $# == 2 ))
    local bash_list_name=$1
    local -n bash_list_length_ref=$2
    local -n bash_list_ref=$bash_list_name
    bashsible_bash_is_variable_type_list $bash_list_name
    bash_list_length_ref=${#bash_list_ref[@]}
}

bashsible_bash_is_dictionary_key_defined() {
    (( $# == 2 ))
    local bash_dictionary_name=$1
    local bash_dictionary_key=$2
    bashsible_bash_is_variable_type_dictionary $bash_dictionary_name
    [[ -v $bash_dictionary_name[$bash_dictionary_key] ]]
}

bashsible_bash_get_cli_options() {
    (( $# >= 3 ))
    local -a bash_cli_arguments_list=("$@")
    local -i bash_cli_argument_index=0
    local -i bash_cli_arguments_count
    local -A bash_value_options_dictionary
    local -A bash_switch_options_dictionary
    local -A bash_list_options_dictionary
    bashsible_bash_get_list_length bash_cli_arguments_list bash_cli_arguments_count
    while (( bash_cli_argument_index < bash_cli_arguments_count )) && [[ ${bash_cli_arguments_list[$bash_cli_argument_index]} != -- ]]
    do
        local bash_this_variable_name=${bash_cli_arguments_list[$bash_cli_argument_index]}
        local bash_this_variable_option="--${bash_this_variable_name//_/-}"
        bash_cli_argument_index=$(( bash_cli_argument_index + 1 ))
        ! bashsible_bash_is_variable_type_readonly $bash_this_variable_name || false
        ! bashsible_bash_is_variable_type_list $bash_this_variable_name || {
            bash_list_options_dictionary[$bash_this_variable_option]=$bash_this_variable_name
            continue
        }
        local -n bash_this_variable_ref=$bash_this_variable_name
        [[ ! $bash_this_variable_ref == '' ]] || {
            bash_value_options_dictionary[$bash_this_variable_option]=$bash_this_variable_name
            bashsible_bash_undefine_variable_reference bash_this_variable_ref
            continue
        }
        [[ ! $bash_this_variable_ref == 0 ]] || {
            bash_switch_options_dictionary[$bash_this_variable_option]=$bash_this_variable_name
            bashsible_bash_undefine_variable_reference bash_this_variable_ref
            continue
        }
        false
    done
    (( bash_cli_argument_index < bash_cli_arguments_count ))
    [[ ${bash_cli_arguments_list[$bash_cli_argument_index]} == -- ]]
    bash_cli_argument_index=$(( bash_cli_argument_index + 1 ))
    while (( bash_cli_argument_index < bash_cli_arguments_count ))
    do
        local bash_this_script_option=${bash_cli_arguments_list[$bash_cli_argument_index]}
        ! bashsible_bash_is_dictionary_key_defined bash_value_options_dictionary $bash_this_script_option || {
            local -n bash_this_variable_ref=${bash_value_options_dictionary[$bash_this_script_option]}
            local -i bash_this_script_option_value_index=$(( bash_cli_argument_index + 1 ))
            (( bash_this_script_option_value_index < bash_cli_arguments_count ))
            local bash_this_script_option_value="${bash_cli_arguments_list[$bash_this_script_option_value_index]}"
            [[ $bash_this_script_option_value != --* ]]
            bash_this_variable_ref=$bash_this_script_option_value
            bashsible_bash_undefine_variable_reference bash_this_variable_ref
            bash_cli_argument_index=$(( bash_cli_argument_index + 2 ))
            continue
        }
        ! bashsible_bash_is_dictionary_key_defined bash_switch_options_dictionary $bash_this_script_option || {
            local -n bash_this_variable_ref=${bash_switch_options_dictionary[$bash_this_script_option]}
            bash_this_variable_ref=1
            bashsible_bash_undefine_variable_reference bash_this_variable_ref
            bash_cli_argument_index=$(( bash_cli_argument_index + 1 ))
            continue
        }
        ! bashsible_bash_is_dictionary_key_defined bash_list_options_dictionary $bash_this_script_option || {
            local -n bash_this_variable_ref=${bash_list_options_dictionary[$bash_this_script_option]}
            bash_cli_argument_index=$(( bash_cli_argument_index + 1 ))
            while (( bash_cli_argument_index < bash_cli_arguments_count )) && [[ ${bash_cli_arguments_list[$bash_cli_argument_index]} != --* ]]
            do
                bash_this_variable_ref+=( "${bash_cli_arguments_list[$bash_cli_argument_index]}" )
                bash_cli_argument_index=$(( bash_cli_argument_index + 1 ))
            done
            bashsible_bash_undefine_variable_reference bash_this_variable_ref
            continue
        }
        false
    done
}





: <<'COMMENT'



bashsible_bash_silent_error() on success ...




#!/usr/bin/bash
source bashsible/sources/bash.bash
bashsible_bash_exit_trap() {:;}

user_name=''
groups=()
with_option=0

bashsible_bash_get_cli_options user_name groups with_option -- "$@"

[[ -n $user_name ]]
(( ${#groups[@]} > 0 ))
(( with_option ))

use bashsible_ prefix for bashsible variables and functions
use local for every function variable
unset -n for every nameref after use inside a loop
running other scripts from this script : bashsible/scripts/script-name  
COMMENT


