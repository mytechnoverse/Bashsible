
#!/usr/bin/bash
set -o errtrace
set -o errexit
set -o nounset
set -o noglob
set -o pipefail
shopt -s inherit_errexit

bashsible_bash_error_trap() {
    (( $# == 3 ))
	local -i bash_error_code=$1
	local -i bash_error_line=$2
	local bash_error_command=$3
	local bash_error_message
    local -i bash_functions_nest_levels
    local -i bash_function_index
    local bash_this_function_name
	local bash_this_source_name
	local -i bash_this_source_line_number
	read -r -d $'\x1c' bash_error_message <<-EOF
	
	Bashsible Error Message :
	
	Error Code : $bash_error_code
	Line Number : $bash_error_line
	Bash Command : $bash_error_command
	$(printf '\x1c')
	EOF
	bash_functions_nest_levels=${#FUNCNAME[@]}
	(( bash_functions_nest_levels < 3 )) || {
        bash_error_message+=$'\n\n'
		bash_error_message+="Function Hierarchy :"
		bash_error_message+=$'\n\n'
		for (( bash_function_index = 1 ; bash_function_index < bash_functions_nest_levels - 1 ; bash_function_index++ ))
		do
			bash_this_function_name=${FUNCNAME[$bash_function_index]}
			bash_this_source_name=${BASH_SOURCE[$bash_function_index]}
			bash_this_source_line_number=${BASH_LINENO[$bash_function_index - 1 ]}
			bash_error_message+="${bash_this_function_name} [ ${bash_this_source_name} : ${bash_this_source_line_number} ]"
			bash_error_message+=$'\n'
		done
	}
	printf '%s\n' "$bash_error_message" >&2
}

trap 'bashsible_bash_error_trap $? $LINENO "$BASH_COMMAND"' ERR

trap 'bashsible_bash_exit_trap' EXIT



bashsible_bash_silent_error() on success ...

bashsible_bash_is_function_defined() {
    (( $# == 1 ))
    declare -F $1 &>/dev/null
}

bashsible_bash_is_variable_defined() {
    (( $# == 1 ))
    declare -p $1 &>/dev/null
}

bashsible_bash_undefine_variable() {
    (( $# == 1 ))
    unset $1
}

bashsible_bash_is_variable_assigned() {
    (( $# == 1 ))
    bashsible_bash_is_variable_defined $1
    [[ -v $1 ]]
}

bash_get_variable_definition() {
    (( $# == 2 ))
    local bash_variable_name=$1
    local -n bash_variable_definition_ref=$2
    local bash_variable_declaration
    bashsible_bash_is_variable_defined $bash_variable_name
    bash_variable_declaration=$(declare -p $1)
    read -r _ bash_variable_definition_ref _ < <(printf '%s\n' "$bash_variable_declaration")
}

bashsible_bash_is_variable_type_readonly() {
    (( $# == 1 ))
    local bash_variable_definition
    bash_get_variable_definition $1 bash_variable_definition
    [[ $bash_variable_definition == *r* ]]
}

bashsible_bash_is_variable_type_integer() {
    (( $# == 1 ))
    local bash_variable_definition
    bash_get_variable_definition $1 bash_variable_definition
    [[ $bash_variable_definition == *i* ]]
}

bashsible_bash_is_variable_type_list() {
    (( $# == 1 ))
    local bash_variable_definition
    bash_get_variable_definition $1 bash_variable_definition
    [[ $bash_variable_definition == *a* ]]
}

bashsible_bash_is_variable_type_dictionary() {
    (( $# == 1 ))
    local bash_variable_definition
    bash_get_variable_definition $1 bash_variable_definition
    [[ $bash_variable_definition == *A* ]]
}

bashsible_is_dictionary_key_present()








bashsible_bash_cli_parser






script_cli_parser() {
    (( $# >= 3 ))
    local script_this_variable_name
    local script_this_variable_option
    local script_this_variable_attributes
    local script_this_variable_declaration
    local script_this_option
    local -A bash_value_options_dictionary
    local -A bash_switch_options_dictionary
    local -A bash_list_options_dictionary
    while (( $# )) && [[ $1 != -- ]]
    do
        script_this_variable_name=$1
        shift
        script_this_variable_declaration=$(declare -p $script_this_variable_name 2>/dev/null) || return 1
        script_this_variable_attributes=${script_this_variable_declaration#declare -}
        script_this_variable_attributes=${script_this_variable_attributes%% *}
        script_this_variable_option="--${script_this_variable_name//_/-}"
        [[ ! $script_this_variable_attributes == *a* ]] || {
            bash_list_options_dictionary[$script_this_variable_option]=$script_this_variable_name
            continue
        }
        local -n script_this_variable_value=$script_this_variable_name
        [[ ! $script_this_variable_value == '' ]] || {
            bash_value_options_dictionary[$script_this_variable_option]=$script_this_variable_name
            unset -n script_this_variable_value
            continue
        }
        [[ ! $script_this_variable_value == 0 ]] || {
            bash_switch_options_dictionary[$script_this_variable_option]=$script_this_variable_name
            unset -n script_this_variable_value
            continue
        }
        return 1
    done
    if (( ! $# )) || [[ $1 != -- ]]
    then
        return 1
    fi
    shift
    while (( $# ))
    do
        script_this_option=$1
        [[ ! -v "script_value_options_dictionary[$script_this_option]" ]] || {
            if (( $# < 2 )) || [[ $2 == --* ]]
            then
                return 1
            fi
            printf -v "${script_value_options_dictionary[$script_this_option]}" '%s' $2
            shift 2
            continue
        }
        [[ ! -v "script_switch_options_dictionary[$script_this_option]" ]] || {
            printf -v "${script_switch_options_dictionary[$script_this_option]}" '%s' '1'
            shift
            continue
        }
        [[ ! -v "script_list_options_dictionary[$script_this_option]" ]] || {
            local -n script_list_variable_ref=${script_list_options_dictionary[$script_this_option]}
            shift
            while (( $# )) && [[ $1 != --* ]]
            do
                script_list_variable_ref+=( $1 )
                shift
            done
            unset -n script_list_variable_ref
            continue
        }
        return 1
    done
}




when checking , use || return 0 ????







: <<'COMMENT'
#!/usr/bin/bash
source sources/bash.bash
bashsible_bash_exit_trap() {:}

user_name=''
groups=()
with_option=0

script_cli_parser user_name groups with_option -- "$@"

[[ -n $user_name ]]
(( ${#groups[@]} > 0 ))
(( with_option ))

use bashsible_ prefix for bashsible variables and functions
use local for every function variable
unset -n for every nameref after use


COMMENT








???????????




