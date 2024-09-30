#!/usr/bin/env bash

usage() {
	local old_xtrace
	old_xtrace="$(shopt -po xtrace || :)"
	set +o xtrace

	{
		echo "${script_name} - Reverse the case of the input string."
		echo "Usage: ${script_name} [flags] <input string>"
		echo "Option flags:"
		echo "  -t --test       - Run tests. Default: '${do_tests}'."
		echo "  -h --help       - Show this help and exit."
		echo "  -v --verbose    - Verbose execution."
		echo "  -g --debug      - Extra verbose execution."
		echo "Input string      = '${input_str}'"
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

	if [[ ${verbose} ]]; then
		local sec="${SECONDS}"
		echo "${script_name}: Done: ${result}, ${sec} sec." >&2
	fi
}

on_err() {
	local f_name=${1}
	local line_no=${2}
	local err_no=${3}

	echo "${script_name}: ERROR: function=${f_name}, line=${line_no}, result=${err_no}" >&2

	exit "${err_no}"
}

to_upper() {
	local input_str="${1}"
	local output_str=''

	output_str="${input_str^^}"
	echo "${output_str}"
}

to_lower() {
	local input_str="${1}"
	local output_str=''

	output_str="${input_str,,}"
	echo "${output_str}"
}

reverse_case() {
	local input_str="${1}"
	local output_str=''

	output_str="${input_str~~}"
	echo "${output_str}"
}

run_tests() {
	local input_str=''
	local output_str=''
	verbose=1

	echo "=== ${FUNCNAME[0]} start ===" >&2

	input_str='aabbccd12.5+55.3ccdd23eeffeee45.6hyhj '
	echo "${FUNCNAME[0]}: Input string   = '${input_str}'" >&2
	output_str="$(reverse_case "${input_str}")"
	echo "${FUNCNAME[0]}: Reverse string = '${output_str}'" >&2
	output_str="$(to_upper "${input_str}")"
	echo "${FUNCNAME[0]}: Upper string   = '${output_str}'" >&2
	output_str="$(to_lower "${input_str}")"
	echo "${FUNCNAME[0]}: Lower string   = '${output_str}'" >&2
	echo  >&2

	input_str='65'
	echo "${FUNCNAME[0]}: Input string   = '${input_str}'" >&2
	output_str="$(reverse_case "${input_str}")"
	echo "${FUNCNAME[0]}: Reverse string = '${output_str}'" >&2
	output_str="$(to_upper "${input_str}")"
	echo "${FUNCNAME[0]}: Upper string   = '${output_str}'" >&2
	output_str="$(to_lower "${input_str}")"
	echo "${FUNCNAME[0]}: Lower string   = '${output_str}'" >&2
	echo  >&2

	input_str='eeeeeeeeeeeeeeeeeeeEeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr6'
	echo "${FUNCNAME[0]}: Input string   = '${input_str}'" >&2
	output_str="$(reverse_case "${input_str}")"
	echo "${FUNCNAME[0]}: Reverse string = '${output_str}'" >&2
	output_str="$(to_upper "${input_str}")"
	echo "${FUNCNAME[0]}: Upper string   = '${output_str}'" >&2
	output_str="$(to_lower "${input_str}")"
	echo "${FUNCNAME[0]}: Lower string   = '${output_str}'" >&2
	echo  >&2

	input_str='77.777777777777777ft4gfgggfd+6.88888888888hhh'
	echo "${FUNCNAME[0]}: Input string   = '${input_str}'" >&2
	output_str="$(reverse_case "${input_str}")"
	echo "${FUNCNAME[0]}: Reverse string = '${output_str}'" >&2
	output_str="$(to_upper "${input_str}")"
	echo "${FUNCNAME[0]}: Upper string   = '${output_str}'" >&2
	output_str="$(to_lower "${input_str}")"
	echo "${FUNCNAME[0]}: Lower string   = '${output_str}'" >&2
	echo  >&2

	input_str='-77.7a6.8'
	echo "${FUNCNAME[0]}: Input string   = '${input_str}'" >&2
	output_str="$(reverse_case "${input_str}")"
	echo "${FUNCNAME[0]}: Reverse string = '${output_str}'" >&2
	output_str="$(to_upper "${input_str}")"
	echo "${FUNCNAME[0]}: Upper string   = '${output_str}'" >&2
	output_str="$(to_lower "${input_str}")"
	echo "${FUNCNAME[0]}: Lower string   = '${output_str}'" >&2
	echo >&2

	input_str='aabbccd12.5+55.3ccdd23eeffeee45.6hyhj '
	echo "${FUNCNAME[0]}: Input string   = '${input_str}'" >&2
	output_str="$(reverse_case "${input_str}")"
	echo "${FUNCNAME[0]}: Reverse string = '${output_str}'" >&2
	output_str="$(to_upper "${input_str}")"
	echo "${FUNCNAME[0]}: Upper string   = '${output_str}'" >&2
	output_str="$(to_lower "${input_str}")"
	echo "${FUNCNAME[0]}: Lower string   = '${output_str}'" >&2
	echo >&2

	input_str='aabbccd12.5+55.3ccc dd23eeffeee45.6hyhj '
	echo "${FUNCNAME[0]}: Input string   = '${input_str}'" >&2
	output_str="$(reverse_case "${input_str}")"
	echo "${FUNCNAME[0]}: Reverse string = '${output_str}'" >&2
	output_str="$(to_upper "${input_str}")"
	echo "${FUNCNAME[0]}: Upper string   = '${output_str}'" >&2
	output_str="$(to_lower "${input_str}")"
	echo "${FUNCNAME[0]}: Lower string   = '${output_str}'" >&2

	echo "=== ${FUNCNAME[0]} end ===" >&2
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

input_str=''
do_tests=''
usage=''
verbose=''
debug=''

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

	echo "${script_name}: Input string   = '${input_str}'" >&2
	output_str="$(reverse_case "${input_str}")"
	echo "${script_name}: Reverse string = '${output_str}'" >&2
	output_str="$(to_upper "${input_str}")"
	echo "${script_name}: Upper string   = '${output_str}'" >&2
	output_str="$(to_lower "${input_str}")"
	echo "${script_name}: Lower string   = '${output_str}'" >&2
fi

trap "on_exit 'Success'" EXIT
exit 0
