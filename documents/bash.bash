
script_error_trap() {
    local script_exit_code=$1 script_line_number=$2 script_bash_command=$3
    printf 'Error : Line %s : %s [ %s ]\n' $script_line_number "$script_bash_command" $script_exit_code >&2
}

script_run_exit_trap() {
    ! declare -F script_exit_trap &>/dev/null || script_exit_trap
}

script_install_traps() {
    trap 'script_error_trap $? $LINENO "$BASH_COMMAND"' ERR
    trap 'script_run_exit_trap' EXIT
}

script_cli_parser() {
    local script_this_variable_name
    local script_this_variable_option
    local script_this_variable_attributes
    local script_this_variable_declaration
    local script_this_option
    local -A script_value_options_dictionary=()
    local -A script_switch_options_dictionary=()
    local -A script_list_options_dictionary=()
    while (( $# )) && [[ $1 != -- ]]
    do
        script_this_variable_name=$1
        shift
        script_this_variable_declaration=$(declare -p $script_this_variable_name 2>/dev/null) || return 1
        script_this_variable_attributes=${script_this_variable_declaration#declare -}
        script_this_variable_attributes=${script_this_variable_attributes%% *}
        script_this_variable_option="--${script_this_variable_name//_/-}"
        [[ ! $script_this_variable_attributes == *a* ]] || {
            script_list_options_dictionary[$script_this_variable_option]=$script_this_variable_name
            continue
        }
        local -n script_this_variable_value=$script_this_variable_name
        [[ ! $script_this_variable_value == '' ]] || {
            script_value_options_dictionary[$script_this_variable_option]=$script_this_variable_name
            unset -n script_this_variable_value
            continue
        }
        [[ ! $script_this_variable_value == 0 ]] || {
            script_switch_options_dictionary[$script_this_variable_option]=$script_this_variable_name
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
        [[ ! ${script_value_options_dictionary[$script_this_option]+present} ]] || {
            if (( $# < 2 )) || [[ -z $2 || $2 == --* ]]
            then
                return 1
            fi
            printf -v "${script_value_options_dictionary[$script_this_option]}" '%s' $2
            shift 2
            continue
        }
        [[ ! ${script_switch_options_dictionary[$script_this_option]+present} ]] || {
            printf -v "${script_switch_options_dictionary[$script_this_option]}" '%s' '1'
            shift
            continue
        }
        [[ ! ${script_list_options_dictionary[$script_this_option]+present} ]] || {
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

: <<'COMMENT'
#!/usr/bin/bash
set -Eeuo pipefail
shopt -s inherit_errexit
source bash.bash
script_exit_trap() {}
script_install_traps

user_name=''
groups=()
with_option=0

script_cli_parser user_name groups with_option -- "$@"

[[ -n $user_name ]]
(( ${#groups[@]} > 0 ))
(( with_option ))
COMMENT