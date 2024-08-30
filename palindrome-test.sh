#!/usr/bin/env bash

usage() {
	local old_xtrace
	old_xtrace="$(shopt -po xtrace || :)"
	set +o xtrace

	{
		echo "${script_name} - Test if the input string is a palindrome."
		echo "Usage: ${script_name} [flags] <input string>"
		echo "Option flags:"
		echo "  -t --test       - Run tests. Default: '${do_tests}'."
		echo "  -h --help       - Show this help and exit."
		echo "  -v --verbose    - Verbose execution."
		echo "  -g --debug      - Extra verbose execution."
		echo "Input string = '${input_str}'"
	} >&2
	eval "${old_xtrace}"
}

process_opts() {
	local short_opts="thvg"
	local long_opts="test,help,verbose,debug"

	local opts
	opts=$(getopt --options ${short_opts} --long ${long_opts} -n "${script_name}" -- "$@")

	eval set -- "${opts}"

	while true ; do
		# echo "${FUNCNAME[0]}: (${#}) '${*}'"
		case "${1}" in
		-t | --test)
			do_tests=1
			shift
			;;
		-h | --help)
			usage=1
			shift
			;;
		-v | --verbose)
			verbose=1
			shift
			;;
		-g | --debug)
			verbose=1
			debug=1
			set -x
			shift
			;;
		--)
			shift
			if [[ "${1:-}" ]]; then
				input_str="${1:-}"
				shift
			fi
			extra_args="${*}"
			break
			;;
		*)
			echo "${script_name}: ERROR: Internal opts: '${*}'" >&2
			exit 1
			;;
		esac
	done
}

on_exit() {
	local result=${1}

	echo "${script_name}: Done: ${result}, ${SECONDS} sec." >&2
}

on_err() {
	local f_name=${1}
	local line_no=${2}
	local err_no=${3}

	echo "${script_name}: ERROR: function=${f_name}, line=${line_no}, result=${err_no}" >&2

	exit "${err_no}"
}

remove_space() {
	local input_str="${1}"
	local input_len=${#input_str}
	local output_str=''
	local i

	for (( i = 0; i < input_len; i++ )); do
		if [[ ${input_str:$i:1} != ' ' ]]; then
			output_str="${output_str}${input_str:$i:1}"
		fi
	done

# 	if [[ ${verbose} ]]; then
# 		echo "${FUNCNAME[0]}: input string   = '${input_str}'" >&2
# 		echo "${FUNCNAME[0]}: output string  = '${output_str}'" >&2
# 	fi

	echo "${output_str}"
}

palindrome_test() {
	local input_str="${1}"
	local test_str="$(remove_space "${input_str}")"
	local test_len=${#test_str}
	local end=$(( 1 + test_len / 2 ))
	local i
	local j

	test_str="${test_str,,}"

# 	if [[ ${verbose} ]]; then
# 		echo "${FUNCNAME[0]}: Input string = '${input_str}'" >&2
# 		echo "${FUNCNAME[0]}: end = '${end}'" >&2
# 		echo "${FUNCNAME[0]}: len = '${test_len}'" >&2
# 	fi

	for (( i = 0, j = test_len - 1; i <= end; i++, j-- )); do
# 		echo "str_i[${i}] = '${test_str:$i:1}'" >&2
# 		echo "str_j[${j}] = '${test_str:$j:1}'" >&2
		if [[ ${test_str:$i:1} != ${test_str:$j:1} ]]; then
			if [[ ${verbose} ]]; then
				echo "${FUNCNAME[0]}: '${input_str}' BAD" >&2
			fi
			echo 'BAD'
			return
		fi
	done

	if [[ ${verbose} ]]; then
		echo "${FUNCNAME[0]}: '${input_str}' OK" >&2
	fi
	echo 'OK'
}

run_tests() {
	local result 
	verbose=1
	echo >&2
	echo "=== ${script_name}: ${FUNCNAME[0]} start ===" >&2

	result="$(palindrome_test 'wow')"
# 	echo "${FUNCNAME[0]} 'wow' = ${result}" >&2

	result="$(palindrome_test 'kayak')"
# 	echo "${FUNCNAME[0]} 'kayak' = ${result}" >&2

	result="$(palindrome_test '12345')"
# 	echo "${FUNCNAME[0]} '12345' = ${result}" >&2

	result="$(palindrome_test '12321')"
# 	echo "${FUNCNAME[0]} '12321' = ${result}" >&2

	result="$(palindrome_test 'never odd or even')"
# 	echo "${FUNCNAME[0]} 'never odd or even' = ${result}" >&2

	result="$(palindrome_test 'Never odd or even')"
# 	echo "${FUNCNAME[0]} 'never odd or even' = ${result}" >&2

	result="$(palindrome_test 'two plus four')"
# 	echo "${FUNCNAME[0]} 'two plus four' = ${result}" >&2

	echo "=== ${script_name}: ${FUNCNAME[0]} end ===" >&2
	echo >&2
}

#===============================================================================
export PS4='\[\e[0;33m\]+ ${BASH_SOURCE##*/}:${LINENO}:(${FUNCNAME[0]:-main}):\[\e[0m\] '

script_name="${0##*/}"

SECONDS=0
start_time="$(date +%Y.%m.%d-%H.%M.%S)"

real_source="$(realpath "${BASH_SOURCE}")"
SCRIPT_TOP="$(realpath "${SCRIPT_TOP:-${real_source%/*}}")"

trap "on_exit 'Failed'" EXIT
trap 'on_err ${FUNCNAME[0]:-main} ${LINENO} ${?}' ERR
trap 'on_err SIGUSR1 ? 3' SIGUSR1

set -eE
set -o pipefail
set -o nounset

do_tests=''
usage=''
verbose=''
debug=''
input_str=''

process_opts "${@}"

if [[ ${usage} ]]; then
	usage
	trap - EXIT
	exit 0
fi

if [[ ${extra_args} ]]; then
	set +o xtrace
	echo "${script_name}: ERROR: Got extra args: '${extra_args}'" >&2
	usage
	exit 1
fi

if [[ ${verbose} ]]; then
	echo "${script_name}" >&2
fi

if [[ ${do_tests} ]]; then
	run_tests
else
	if [[ ! ${input_str} ]]; then
		echo "${script_name}: ERROR: No input string given." >&2
		usage
		exit 1
	fi
	result="$(palindrome_test "${input_str}")"
	echo "'${input_str}' = ${result}" >&2
fi

trap "on_exit 'Success'" EXIT
exit 0
