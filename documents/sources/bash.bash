
#!/usr/bin/bash
set -o errtrace
set -o errexit
set -o nounset
set -o noglob
set -o pipefail
shopt -s inherit_errexit

bash::on_error() {
    (( $# == 2 ))
	local -i bash_error_code=$1
	local bash_error_cmd=$2
	local bash_error_msg
    local -i bash_error_funcs_count=${#FUNCNAME[@]}
    local -i bash_error_func_index
	read -r -d $'\x1c' bash_error_msg <<-EOF
	
	Error Code : $bash_error_code
	Bash Command : $bash_error_cmd
	$(printf '\x1c')
	EOF
    bash_error_msg+=$'\n\n'
    for (( bash_error_func_index = 1 ; bash_error_func_index < bash_error_funcs_count ; bash_error_func_index++ ))
    do
        local bash_error_this_func_name=${FUNCNAME[$bash_error_func_index]:-main}
        local bash_error_this_src_name=${BASH_SOURCE[$bash_error_func_index]:-main}
        local -i bash_error_this_src_line_number=${BASH_LINENO[$bash_error_func_index - 1 ]}
        bash_error_msg+="${bash_error_this_func_name} [ ${bash_error_this_src_name} : ${bash_error_this_src_line_number} ]"
        bash_error_msg+=$'\n'
    done
	printf '%s\n' "$bash_error_msg" >&2
}

trap 'bash::on_error $? "$BASH_COMMAND"' ERR

bash::on_exit() { :; }

trap 'bash::on_exit' EXIT

bash::run_drop_output() {
    (( $# >= 1 ))
    "$@" &>/dev/null || return $?
}

bash::run_drop_stderr() {
    (( $# >= 1 ))
    "$@" 2>/dev/null || return $?
}

bash::run_drop_stdout() {
    (( $# >= 1 ))
    "$@" 1>/dev/null || return $?
}

bash::run_capture_output() {
    (( $# >= 1 ))
    local bash_cmd_std
    local -i bash_cmd_code=0
    bash_cmd_std=$("$@" 2>&1) || {
        bash_cmd_code=$?
        printf '%s\n' "$bash_cmd_std" >&2
        return $bash_cmd_code
    }
}

bash::run_capture_stderr() {
    (( $# >= 1 ))
    local bash_cmd_stderr
    local -i bash_cmd_code=0
    { bash_cmd_stderr=$("$@" 2>&1 1>&3 3>&-) || bash_cmd_code=$?; } 3>&1
    (( ! bash_cmd_code )) || {
        printf '%s\n' "$bash_cmd_stderr" >&2
        return $bash_cmd_code
    }
}

bash::run_capture_stdout() {
    (( $# >= 1 ))
    local bash_cmd_stdout
    local -i bash_cmd_code=0
    bash_cmd_stdout=$("$@") || bash_cmd_code=$?
    (( ! bash_cmd_code )) || {
        printf '%s\n' "$bash_cmd_stdout"
        return $bash_cmd_code
    }
}

bash::is_func_def() {
    (( $# == 1 ))
    local bash_function_name=$1
    declare -F $bash_function_name &>/dev/null
}

bash::is_var_def() {
    (( $# == 1 ))
    local bash_var_name=$1
    declare -p $bash_var_name &>/dev/null
}

bash::undef_var() {
    (( $# == 1 ))
    local bash_var_name=$1
    unset -v $bash_var_name
}

bash::undef_var_ref() {
    (( $# == 1 ))
    local bash_var_ref=$1
    unset -n $bash_var_ref
}

bash::get_var_def() {
    (( $# == 2 ))
    local bash_var_name=$1
    local -n bash_var_def_ref=$2
    local bash_var_declaration
    bash::is_var_def $bash_var_name
    bash_var_declaration=$(declare -p $bash_var_name)
    read -r _ bash_var_def_ref _ < <(printf '%s\n' "$bash_var_declaration")
}

bash::is_var_type_ref() {
    (( $# == 1 ))
    local bash_var_name=$1
    local bash_var_def
    bash::get_var_def $bash_var_name bash_var_def
    [[ $bash_var_def == *n* ]]
}

bash::is_var_type_readonly() {
    (( $# == 1 ))
    local bash_var_name=$1
    local bash_var_def
    bash::get_var_def $bash_var_name bash_var_def
    [[ $bash_var_def == *r* ]]
}

bash::is_var_type_int() {
    (( $# == 1 ))
    local bash_var_name=$1
    local bash_var_def
    bash::get_var_def $bash_var_name bash_var_def
    [[ $bash_var_def == *i* ]]
}

bash::is_var_type_list() {
    (( $# == 1 ))
    local bash_var_name=$1
    local bash_var_def
    bash::get_var_def $bash_var_name bash_var_def
    [[ $bash_var_def == *a* ]]
}

bash::is_var_type_dict() {
    (( $# == 1 ))
    local bash_var_name=$1
    local bash_var_def
    bash::get_var_def $bash_var_name bash_var_def
    [[ $bash_var_def == *A* ]]
}

bash::get_list_len() {
    (( $# == 2 ))
    local bash_list_name=$1
    local -n bash_list_len_ref=$2
    local -n bash_list_ref=$bash_list_name
    bash::is_var_type_list $bash_list_name
    bash_list_len_ref=${#bash_list_ref[@]}
}

bash::is_var_ass() {
    (( $# == 1 ))
    local bash_var_name=$1
    bash::is_var_def $bash_var_name
    if bash::is_var_type_list $bash_var_name || bash::is_var_type_dict $bash_var_name
    then
        local -i bash_var_len
        bash::get_list_len $bash_var_name bash_var_len
        (( bash_var_len ))
    else
        local -n bash_var_ref=$bash_var_name
        [[ -n $bash_var_ref ]]
    fi
}

bash::is_dict_key_def() {
    (( $# == 2 ))
    local bash_dict_name=$1
    local bash_dict_key=$2
    bash::is_var_type_dict $bash_dict_name
    [[ -v $bash_dict_name[$bash_dict_key] ]]
}

bash::get_script_opts() {
    (( $# >= 2 ))
    local -a bash_arg_list=("$@")
    local -i bash_arg_index=0
    local -i bash_args_count
    local -A bash_value_opts_dict
    local -A bash_switch_opts_dict
    local -A bash_list_opts_dict
    bash::get_list_len bash_arg_list bash_args_count
    while (( bash_arg_index < bash_args_count )) && [[ ${bash_arg_list[$bash_arg_index]} != -- ]]
    do
        local bash_this_var_name=${bash_arg_list[$bash_arg_index]}
        local bash_this_var_option="--${bash_this_var_name//_/-}"
        bash_arg_index=$(( bash_arg_index + 1 ))
        if bash::is_var_type_readonly $bash_this_var_name || bash::is_var_type_dict $bash_this_var_name
        then
            false
        fi
        ! bash::is_var_type_list $bash_this_var_name || {
            bash::is_var_ass $bash_this_var_name || {
                bash_list_opts_dict[$bash_this_var_option]=$bash_this_var_name
                continue
            }
            false
        }
        local -n bash_this_variable_ref=$bash_this_var_name
        ! bash::is_var_type_int $bash_this_var_name || {
            ! [[ $bash_this_variable_ref == 0 ]] || {
                bash_switch_opts_dict[$bash_this_var_option]=$bash_this_var_name
                bash::undef_var_ref bash_this_variable_ref
                continue
            }
            false
        }
        [[ ! $bash_this_variable_ref == '' ]] || {
            bash_value_opts_dict[$bash_this_var_option]=$bash_this_var_name
            bash::undef_var_ref bash_this_variable_ref
            continue
        }
        false
    done
    if (( bash_arg_index >= bash_args_count )) || [[ ${bash_arg_list[$bash_arg_index]} != -- ]]
    then
        false
    fi
    bash_arg_index=$(( bash_arg_index + 1 ))
    while (( bash_arg_index < bash_args_count ))
    do
        local bash_this_script_option=${bash_arg_list[$bash_arg_index]}
        ! bash::is_dict_key_def bash_value_opts_dict $bash_this_script_option || {
            local -n bash_this_variable_ref=${bash_value_opts_dict[$bash_this_script_option]}
            local -i bash_this_script_option_value_index=$(( bash_arg_index + 1 ))
            (( bash_this_script_option_value_index < bash_args_count ))
            local bash_this_script_option_value="${bash_arg_list[$bash_this_script_option_value_index]}"
            [[ $bash_this_script_option_value != --* ]]
            bash_this_variable_ref=$bash_this_script_option_value
            bash::undef_var_ref bash_this_variable_ref
            bash_arg_index=$(( bash_arg_index + 2 ))
            continue
        }
        ! bash::is_dict_key_def bash_switch_opts_dict $bash_this_script_option || {
            local -n bash_this_variable_ref=${bash_switch_opts_dict[$bash_this_script_option]}
            bash_this_variable_ref=1
            bash::undef_var_ref bash_this_variable_ref
            bash_arg_index=$(( bash_arg_index + 1 ))
            continue
        }
        ! bash::is_dict_key_def bash_list_opts_dict $bash_this_script_option || {
            local -n bash_this_variable_ref=${bash_list_opts_dict[$bash_this_script_option]}
            bash_arg_index=$(( bash_arg_index + 1 ))
            while (( bash_arg_index < bash_args_count )) && [[ ${bash_arg_list[$bash_arg_index]} != --* ]]
            do
                bash_this_variable_ref+=( "${bash_arg_list[$bash_arg_index]}" )
                bash_arg_index=$(( bash_arg_index + 1 ))
            done
            bash::undef_var_ref bash_this_variable_ref
            continue
        }
        false
    done
}











bash::check_bash_syntax : bash -n


bash::print_line : printf '%s\n'
bash::read_text : read 1c
bash::read_lines readarray
bash::get_line_props line prop1 prop1 -----> print_line | read -d \n _ _ _ 




bash::ensure
bash::prompt
bash::prompt_secret













: <<'COMMENT'

#!/usr/bin/bash
source bashsible/sources/bash.bash
bashsible_bash_exit_trap() {:;}

user_name=''
declare -i with_option=0
declare -a groups=()

bash::get_script_opts user_name groups with_option -- "$@"

bash::is_var_ass user_name
bash::is_var_ass groups
(( with_option ))

use bashsible_ prefix for bashsible variables and functions
use local for every function variable
unset -n for every nameref after use inside a loop
running other scripts from this script : bashsible/scripts/script-name  


keep lines with ( local , declare , ... ) and =$(cmd) seperate 


module api ????

compgen -A function | grep '^module_name::' ????

COMMENT


