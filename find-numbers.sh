#!/usr/bin/env bash

usage() {
	local old_xtrace
	old_xtrace="$(shopt -po xtrace || :)"
	set +o xtrace

	{
		echo "${script_name} - Find numbers or letters in the input string."
		echo "Usage: ${script_name} [flags] <input string>"
		echo "Option flags:"
		if [[ "${find_type}" == 'find_numbers' ]]; then
			echo "  -n --numbers    - Find numbers. Default: '1'."
			echo "  -l --letters    - Find letters. Default: ''."
		elif [[ "${find_type}" == 'find_letters' ]]; then
			echo "  -n --numbers    - Find numbers. Default: ''."
			echo "  -l --letters    - Find letters. Default: '1'."
		else
			echo "${script_name}: ERROR: Bad find_type: '${find_type}'." >&2
			exit 1
		fi
		echo "  -t --test       - Run tests. Default: '${do_tests}'."
		echo "  -h --help       - Show this help and exit."
		echo "  -v --verbose    - Verbose execution."
		echo "  -g --debug      - Extra verbose execution."
		echo "Input string      = '${input_str}'"
	} >&2
	eval "${old_xtrace}"
}

process_opts() {
	local short_opts="nlthvg"
	local long_opts="numbers,letters,test,help,verbose,debug"

	local opts
	opts=$(getopt --options ${short_opts} --long ${long_opts} -n "${script_name}" -- "$@")

	eval set -- "${opts}"

	while true ; do
		# echo "${FUNCNAME[0]}: (${#}) '${*}'"
		case "${1}" in
		-l | --letters)
			find_type='find_letters'
			shift
			;;
		-n | --numbers)
			find_type='find_numbers'
			shift
			;;
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

run_find() {
	local input_str="${1}"
	local output_str=''
	local input_len=${#input_str}
	local regex

	if [[ ${verbose} ]]; then
		echo "input_len ${input_len} " >&2
	fi

	if [[ "${find_type}" == 'find_numbers' ]]; then
		regex='^([+-]?)([0-9]+\.?|[0-9]*\.[0-9]+)'
	elif [[ "${find_type}" == 'find_letters' ]]; then
		regex='^([a-zA-Z]+)()'
	else
		echo "${script_name}: ERROR: Bad find_type: '${find_type}'." >&2
		exit 1
	fi

	local i
	local end
	local test
	local found
	local first_out='1'

	for (( i = 0; i < input_len; i++ )); do
		end=$(( input_len - i ))
		test="${input_str:${i}:${end}}"

		if [[ ${verbose} ]]; then
			echo "str[${i}][${end}] = '${test}'" >&2
		fi
		if [[ ! "${test}" =~ ${regex} ]]; then
			if [[ ${verbose} ]]; then
				echo "No match '${test}'" >&2
			fi
		else
			found="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"

			if [[ "${first_out}" == '1' ]]; then
				first_out='0'
				output_str="${found}"
			else
				output_str="${output_str} ${found}"
			fi

			i=$(( i + ${#found} - 1 ))

			if [[ ${verbose} ]]; then
				echo "Match '${test}' = '${found}'; output_str' = '${output_str}'" >&2
			fi
		fi
	done

	echo "${output_str}"
}

run_tests() {
	local input_str=''
	verbose=1

	echo "=== ${FUNCNAME[0]} start ===" >&2

	if [[ "${find_type}" == 'find_numbers' ]]; then
		local expected_1='12.5 +55.3 23 45.6'
		local expected_2='65'
		local expected_3='4 6'
		local expected_4='77.777777777777777 4 +6.88888888888'
		local expected_5='-77.7 6.8'
		local expected_6='-12.5 +23 -66.6 45.6'
	else
		local expected_1='aabb ccdd eeffeee hyhj'
		local expected_2=''
		local expected_3='eeeeeeeeeeeeeeeeeeeEeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr'
		local expected_4='ft gfgggfd hhh'
		local expected_5='a'
		local expected_6='aabb ccdd eeffeee hyhj'
	fi

	input_str='aabb12.5+55.3ccdd23eeffeee45.6hyhj '
	output_str="$(run_find "${input_str}")"
	echo "${FUNCNAME[0]}: input_str  = '${input_str}'" >&2
	echo "${FUNCNAME[0]}: expected   = '${expected_1}'" >&2
	echo "${FUNCNAME[0]}: output_str = '${output_str}'" >&2

	input_str='65'
	output_str="$(run_find "${input_str}")"
	echo "${FUNCNAME[0]}: input_str  = '${input_str}'" >&2
	echo "${FUNCNAME[0]}: expected   = '${expected_2}'" >&2
	echo "${FUNCNAME[0]}: output_str = '${output_str}'" >&2

	input_str='eeeeeeeeeeeeeeeeeeeEeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee4rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr6'
	output_str="$(run_find "${input_str}")"
	echo "${FUNCNAME[0]}: input_str  = '${input_str}'" >&2
	echo "${FUNCNAME[0]}: expected   = '${expected_3}'" >&2
	echo "${FUNCNAME[0]}: output_str = '${output_str}'" >&2

	input_str='77.777777777777777ft4gfgggfd+6.88888888888hhh'
	output_str="$(run_find "${input_str}")"
	echo "${FUNCNAME[0]}: input_str  = '${input_str}'" >&2
	echo "${FUNCNAME[0]}: expected   = '${expected_4}'" >&2
	echo "${FUNCNAME[0]}: output_str = '${output_str}'" >&2

	input_str='-77.7a6.8'
	output_str="$(run_find "${input_str}")"
	echo "${FUNCNAME[0]}: input_str  = '${input_str}'" >&2
	echo "${FUNCNAME[0]}: expected   = '${expected_5}'" >&2
	echo "${FUNCNAME[0]}: output_str = '${output_str}'" >&2

	input_str='aabb -12.5 ccdd+23-66.6eeffeee 45.6 hyhj'
	output_str="$(run_find "${input_str}")"
	echo "${FUNCNAME[0]}: input_str  = '${input_str}'" >&2
	echo "${FUNCNAME[0]}: expected   = '${expected_6}'" >&2
	echo "${FUNCNAME[0]}: output_str = '${output_str}'" >&2

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

find_type='find_numbers'
do_tests=''
usage=''
verbose=''
debug=''
input_str='aabb12.5ccdd23eeffeee45.6hyhj'
output_str=''

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

if [[ ! ${input_str} ]]; then
	echo "${script_name}: ERROR: No input string given." >&2
	usage
	exit 1
fi

if [[ ${verbose} ]]; then
	echo "${script_name}" >&2
fi

if [[ ${do_tests} ]]; then
	run_tests
else
	output_str="$(run_find "${input_str}")"

	echo "${script_name}: Input string  = '${input_str}'" >&2
	echo "${script_name}: Output string = '${output_str}'" >&2
fi

trap "on_exit 'Success'" EXIT
exit 0
