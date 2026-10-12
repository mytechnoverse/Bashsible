






namespace-like prefix :

bashsible::ensure_directory




bashsible project directory :

/DEBIAN/control :



/usr/bin :

link everything inside bin to here

/usr/lib/bashsible/ :

lib
bin
doc
README.md
VERSION



in end script : 

source /usr/lib/bashsible/lib/bashsible.bash

getting version :

#!/bin/bash
set -Eeuo pipefail

set_file_permission() {
	declare permission_mode="$1" 
	declare file_dir_path="$2"
	chmod "$permission_mode" "$file_dir_path" || {
		printf "Setting permission mode ( %s ) on file or directory path ( %s ) failed !\n" "$permission_mode" "$file_dir_path" >&2
		return 1
	}
}
export -f set_file_permission






bashsible_root_path="./bashsible/"
test -d "$bashsible_root_path" || {
	printf "Bashsible root path ( %s ) not found" "./bashsible/" >&2
	return 1
}

bashsible_version_file_path="./bashsible/usr/lib/bashsible/VERSION"
test -f "$bashsible_version_file_path" || {
	printf "Bashsible version file not found" >&2
	return 1
}
test -r "$bashsible_version_file_path" || {
	if [[ $(stat -c '%u' "$bashsible_version_file_path") -ne $EUID ]]
	then
		printf "Bashsible version file ( %s ) does NOT have READ access for current user ! ( sudo chmod +r %s )\n" "$bashsible_version_file_path" "$bashsible_version_file_path" >&2
		return 1
	else
		sudo -v
		declare -i current_user_id=$(id -un)
		declare -i current_group_id=$(id -gn)
		sudo chown ":" "$bashsible_version_file_path"
		sudo chmod +r "$bashsible_version_file_path"
		sudo -k
	fi
}

regex check x.y.z for version

chmod 0644 "$bashsible_version_file_path" || {
	printf "Setting permission mode ( 0644 ) on file path ( %s ) failed !\n" "$bashsible_version_file_path" >&2
	return 1
}
bashsible_version=$(<"$bashsible_version_file_path")

bashsible_control_file_path="./bashsible/DEBIAN/control"
test -f "$bashsible_control_file_path" && rm "$bashsible_control_file_path"
cat > "$bashsible_control_file_path" <<-EOF
	Package: bashsible
	Version: ${bashsible_version}
	Architecture: amd64
	Maintainer: Debian Repo <info@bashsible.com>
	Description: Bashsible Automation Library
EOF



find "$bashsible_root_path" -type d -exec bash -c '
	for directory_name in "$@"
	do
		set_file_permission 0755 "$directory_name" || exit 1
	done
' bash {} +

bashsible_bin_path="./bashsible/usr/lib/bashsible/bin"
find "$bashsible_bin_path" -type d -exec bash -c '
	for script_name in "$@"
	do
		set_file_permission 0755 "$script_name" || exit 1
	done
' bash {} +




bashsible_lib_path="./bashsible/usr/lib/bashsible/lib"
find "$bashsible_lib_path" -type f -exec chmod 0644 {} \;
bashsible_doc_path="./bashsible/usr/lib/bashsible/doc"
find "$bashsible_doc_path" -type f -exec chmod 0644 {} \;
bashsible_readme="./bashsible/README.md"
test -f "./bashsible/README.md" && chmod 0644 "./bashsible/README.md"

bashsible_path="./bashsible/usr/lib/bashsible/"
find "$bashsible_path" -type f -name "*.bash" -exec bash -c '
    for bash_file in "$@"
	do
        bash -n "$bash_file" || {
			printf "bash file ( %s ) has syntax error\n" "$bash_file" >&2
			exit 1
		}
    done
' bash {} +







dpkg-deb --root-owner-group --compression=zstd --build "$project_dir_path" ./bashsible_${bashsible}_amd64.deb





#!/bin/bash
set -Eeuo pipefail

=== Syntax :

declare    : string variable
declare -l : lower case string variable
declare -u : upper case string variable
declare -i : integer variable
declare -a : list variable ( bash indexed array )
declare -A : dictionary variable ( bash associative array )
declare -n : nameref variable
declare -g : global variable
declare -x : exported variable
declare -r : readonly variable

=== Functions Variable Definition Methods :

1. No Declaration : Global READ + GLOBAL WRITE

Global List & Status Tracking Functions
Global & Parent Scope Variables Override Vulnerable
Log & Error Safe : use check_condition() or run_command() for both normal and sensetive conditions or commands

declare variable_name

function_name() {
	variable_name=123
	echo $variable_name
}

function_name

1. Redeclaration : Global READ + Local WRITE

Local Isolated Functions ( Loops )
Global & Parent Scope Variable Override Safe 
Log & Error Vulnerable : use check_condition_sensetive() or run_command_sensetive() for sensetive conditions or commands 

function_name() {
	declare variable_name=$1
	variable_name=123
	echo $variable_name
}

function_name 123
function_name $variable_name

2. Reference : Global READ + Parent WRITE

Sensetive , Validation , Processing Functions
Global Variable Override Safe
Log & Error Safe : use check_condition() or run_command() for both normal and sensetive conditions or commands

function_name() {
	declare -n variable_ref=$1
	variable_ref=123
	echo $variable_ref
}

declare variable_name
function_name variable_name

===

# bashutils_user_input

=== Heredoc : ( TAB Indentation )

assign_text variable_name <<-EOF
	value
 	$variable_name
# EOF

=== Syntax :

[[ string == string ]]
[[ string != string ]]

(( integer == integer ))
(( integer != integer ))
(( integer <= integer ))
(( integer >= integer ))
(( integer < integer ))
(( integer > integer ))

[[ $integer -eq $integer ]]
[[ $integer -ne $integer ]]
[[ $integer -lt $integer ]]
[[ $integer -le $integer ]]
[[ $integer -gt $integer ]]
[[ $integer -ge $integer ]]

(( boolean ))
(( ! boolean ))
(( boolean && boolean ))
(( boolean || boolean ))

=== Prompt Validator Function :

# bashutils_user_input

=== Password File Descriptor :

# exec 3<<< printf 'user = "%s:%s"\n' "$user_name" "$password"
# exec 3<<-EOF
# user = "${user}:${password}"
# EOF
# curl --config /dev/fd/3 https://api.example.com
# exec 3<<< printf '%s' "$password"
# mkpasswd --stdin <&3
# gpg --batch --passphrase-fd $bashutils_fd_id
# sudo -v -S <&3
# sudo -k

=== For Loop :

for_each_element() {
	# list_element
	# list_index
	# break_loop
}

for_loop list_name for_each_element

=== Conditions :

1 liner THEN : condition && { ... }
1 liner ELSE : condition || { ... }
Multi line THEN ELSE : if condition then ... else ... fi

=== Sufficient Conditions :

get_errors_snapshot

check_condition sufficient_condition_X || {
    check_condition sufficient_condition_Y && set_errors_snapshot || {
        check_condition sufficient_condition_Z && set_errors_snapshot || return $function_false
    }
}
