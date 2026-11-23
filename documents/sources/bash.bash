
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
    unset $bash_variable_name
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
    bashsible_bash_get_variable_definition $bash_variable_name $bash_variable_definition
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

bashsible_bash_is_dictionary_key_present() {
    (( $# == 2 ))
    local bash_dictionary_name=$1
    local bash_dictionary_key=$2
    bashsible_bash_is_variable_type_dictionary $bash_dictionary_name
    [[ -v bash_dictionary_name[$bash_dictionary_key] ]]
}






bashsible_bash_is_dictionary_key_present 

bashsible_bash_is_variable_type_list 









    











bashsible_bash_get_cli_options() {
    (( $# >= 3 ))
    local -a bash_cli_arguments_list
    local -i bash_cli_argument_index
    local -i bash_cli_arguments_count
    local -A bash_value_options_dictionary
    local -A bash_switch_options_dictionary
    local -A bash_list_options_dictionary
    local bash_this_variable_name
    local bash_this_variable_option
    local bash_this_option

    bash_cli_arguments_list=("$@")
    bashsible_bash_argument_index=0
    bashsible_bash_get_list_length bash_cli_arguments_list bash_cli_arguments_count

    while (( bash_cli_argument_index < bash_cli_arguments_count )) && [[ ${bash_cli_arguments_list[$bash_cli_argument_index]} != -- ]]
    do
        bash_this_variable_name=${bash_cli_arguments_list[$bash_cli_argument_index]}
        bash_cli_argument_index=$(( bash_cli_argument_index + 1 ))



        ....


        bashsible_bash_is_variable_type_readonly bash_this_variable_name

        shift
        bash_this_variable_option="--${bash_this_variable_name//_/-}"
        [[ ! $script_this_variable_attributes == *a* ]] || {
            bash_list_options_dictionary[$bash_this_variable_option]=$bash_this_variable_name
            continue
        }
        local -n script_this_variable_value=$bash_this_variable_name
        [[ ! $script_this_variable_value == '' ]] || {
            bash_value_options_dictionary[$bash_this_variable_option]=$bash_this_variable_name
            unset -n script_this_variable_value
            continue
        }
        [[ ! $script_this_variable_value == 0 ]] || {
            bash_switch_options_dictionary[$bash_this_variable_option]=$bash_this_variable_name
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
        bash_this_option=$1
        [[ ! -v "script_value_options_dictionary[$bash_this_option]" ]] || {
            if (( $# < 2 )) || [[ $2 == --* ]]
            then
                return 1
            fi
            printf -v "${script_value_options_dictionary[$bash_this_option]}" '%s' $2
            shift 2
            continue
        }
        [[ ! -v "script_switch_options_dictionary[$bash_this_option]" ]] || {
            printf -v "${script_switch_options_dictionary[$bash_this_option]}" '%s' '1'
            shift
            continue
        }
        [[ ! -v "script_list_options_dictionary[$bash_this_option]" ]] || {
            local -n script_list_variable_ref=${script_list_options_dictionary[$bash_this_option]}
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


-------------------------------



bashsible_bash_get_cli_options() {
    local -a bash_this_arguments=("$@")
    local -i bash_this_index=0
    local -i bash_this_count=${#bash_this_arguments[@]}
    local -A bash_value_options_dictionary
    local -A bash_switch_options_dictionary
    local -A bash_list_options_dictionary
    local bash_this_variable_name
    local bash_this_variable_option
    local bash_this_variable_declaration
    local bash_this_variable_attributes
    local bash_this_option

    (( bash_this_count >= 3 )) || return 1

    # Phase 1: collect variable names up to the literal --
    while (( bash_this_index < bash_this_count )) \
        && [[ ${bash_this_arguments[$bash_this_index]} != -- ]]
    do
        bash_this_variable_name=${bash_this_arguments[$bash_this_index]}
        bash_this_index=$(( bash_this_index + 1 ))

        bash_this_variable_declaration=$(declare -p "$bash_this_variable_name" 2>/dev/null) || return 1
        bash_this_variable_attributes=${bash_this_variable_declaration#declare -}
        bash_this_variable_attributes=${bash_this_variable_attributes%% *}
        bash_this_variable_option="--${bash_this_variable_name//_/-}"

        if [[ $bash_this_variable_attributes == *a* ]]; then
            bash_list_options_dictionary[$bash_this_variable_option]=$bash_this_variable_name
            continue
        fi
        if [[ $bash_this_variable_attributes == *A* ]]; then
            return 1
        fi

        local -n bash_this_variable_value=$bash_this_variable_name
        if [[ ${bash_this_variable_value-} == '' ]]; then
            bash_value_options_dictionary[$bash_this_variable_option]=$bash_this_variable_name
            unset -n bash_this_variable_value
            continue
        fi
        if [[ ${bash_this_variable_value-} == 0 ]]; then
            bash_switch_options_dictionary[$bash_this_variable_option]=$bash_this_variable_name
            unset -n bash_this_variable_value
            continue
        fi
        unset -n bash_this_variable_value
        return 1
    done

    if (( bash_this_index >= bash_this_count )) \
        || [[ ${bash_this_arguments[$bash_this_index]} != -- ]]
    then
        return 1
    fi
    bash_this_index=$(( bash_this_index + 1 ))

    # Phase 2: parse the CLI arguments
    while (( bash_this_index < bash_this_count ))
    do
        bash_this_option=${bash_this_arguments[$bash_this_index]}

        if [[ -v "bash_value_options_dictionary[$bash_this_option]" ]]; then
            (( bash_this_index + 1 < bash_this_count )) || return 1
            [[ ${bash_this_arguments[$(( bash_this_index + 1 ))]} != --* ]] || return 1
            printf -v "${bash_value_options_dictionary[$bash_this_option]}" '%s' \
                "${bash_this_arguments[$(( bash_this_index + 1 ))]}"
            bash_this_index=$(( bash_this_index + 2 ))
            continue
        fi

        if [[ -v "bash_switch_options_dictionary[$bash_this_option]" ]]; then
            printf -v "${bash_switch_options_dictionary[$bash_this_option]}" '%s' '1'
            bash_this_index=$(( bash_this_index + 1 ))
            continue
        fi

        if [[ -v "bash_list_options_dictionary[$bash_this_option]" ]]; then
            local -n bash_list_variable_ref=${bash_list_options_dictionary[$bash_this_option]}
            bash_this_index=$(( bash_this_index + 1 ))
            while (( bash_this_index < bash_this_count )) \
                && [[ ${bash_this_arguments[$bash_this_index]} != --* ]]
            do
                bash_list_variable_ref+=( "${bash_this_arguments[$bash_this_index]}" )
                bash_this_index=$(( bash_this_index + 1 ))
            done
            unset -n bash_list_variable_ref
            continue
        fi
        return 1
    done
}















































script_this_variable_attributes=${script_this_variable_declaration#declare -}
script_this_variable_attributes=${script_this_variable_attributes%% *}
local script_this_variable_attributes
local script_this_variable_declaration






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




