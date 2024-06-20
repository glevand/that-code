#!/usr/bin/env bash

declare -a input_array=()
usage() {
	local old_xtrace
	old_xtrace="$(shopt -po xtrace || :)"
	set +o xtrace

	{
		echo "${script_name} - Find the overlap of the input string."
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

get_input_array() {
	local str_in="${1}"
	local -n get_input_array_input_array="${2}"

	local i
	local length=${#str_in}

	local range_start
	local range_end

	get_input_array_input_array=()

	for ((i = 0; i < length; )); do
		range_start='0'
		range_end='0'

		if [[ "${str_in:i:1}" != '[' ]]; then
			echo "${FUNCNAME[0]}: ERROR: No match ${i} '${str_in}'" >&2
			exit 1
		fi
		i=$((i+1))

		if [[ "${str_in:i:1}" != '[' ]]; then
			echo "${FUNCNAME[0]}: ERROR: No match ${i} '${str_in}'" >&2
			exit 1
		fi
		i=$((i+1))

		while  [ "${str_in:i:1}" != '-' ]; do
			range_start=$((10 * range_start + ${str_in:i:1}))
			i=$((i+1))
		done

		i=$((i+1))
		while  [ "${str_in:i:1}" != ']' ]; do
			range_end=$((10 * range_end + ${str_in:i:1}))
			i=$((i+1))
		done

		if [[ "${str_in:i:1}" != ']' ]]; then
			echo "${FUNCNAME[0]}: ERROR: No match ${i} '${str_in}'" >&2
			exit 1
		fi
		i=$((i+1))

		if [[ "${str_in:i:1}" != ']' ]]; then
			echo "${FUNCNAME[0]}: ERROR: No match ${i} '${str_in}'" >&2
			exit 1
		fi
		i=$((i+1))

		get_input_array_input_array=("${get_input_array_input_array[@]}" "${range_start}")
		get_input_array_input_array=("${get_input_array_input_array[@]}" "${range_end}")
	done
}

get_overlap() {
	local input_str="${1}"
	local -a input_array

	local output_str=''
	local i

	get_input_array "${input_str}" input_array
	local length=${#input_array[@]}

	if [[ ${verbose} ]]; then
		echo "${FUNCNAME[0]}: input_array = ${input_array[*]}" >&2
	fi

	local range_start=${input_array[0]}
	local range_end=${input_array[1]}

	for ((i = 0; i < length-2; i=$((i+2)))); do
		if (( ${input_array[i+1]} >= ${input_array[i+2]} )); then
			if (( ${input_array[i+1]} >= ${input_array[i+3]} ));  then
				range_end=${input_array[i+1]}
			else
				range_end=${input_array[i+3]}
			fi
			if [[ ${verbose} ]]; then
				echo "${FUNCNAME[0]}: i=${i} = ${range_start} ${range_end} = overlap" >&2
			fi
		else
			output_str="${output_str}[[${range_start}-${range_end}]]"
			if [[ ${verbose} ]]; then
				echo "${FUNCNAME[0]}: i=${i} = ${input_array[i+1]} ${input_array[i+2]} = no overlap" >&2
				echo "${FUNCNAME[0]}: i=${i} range = ${range_start} ${range_end}" >&2
				echo "${FUNCNAME[0]}: output_str = '${output_str}'" >&2	
			fi
			range_start=${input_array[i+2]}
			range_end=${input_array[i+3]}
		fi
	done
	output_str="${output_str}[[${range_start}-${range_end}]]"

	if [[ ${verbose} ]]; then
		echo "${FUNCNAME[0]}: output_str = '${output_str}'" >&2
	fi
	echo "${output_str}"
}

run_tests() {
	local input_str=''
	local output_str=''

	verbose=1
	echo >&2
	echo "=== ${FUNCNAME[0]} start ===" >&2

	input_str='[[1-3]][[2-4]][[8-9]]'
	output_str="$(get_overlap  "${input_str}")"
	echo "Input string  = '${input_str}'" >&2
	echo "Output string = '${output_str}'" >&2

	echo '--------' >&2
	input_str='[[10-13]][[14-15]][[18-19]]'
	output_str="$(get_overlap  "${input_str}")"
	echo "Input string  = '${input_str}'" >&2
	echo "Output string = '${output_str}'" >&2
	echo '--------' >&2
	input_str='[[215-218]][[301-425]][[426-666]]'
	output_str="$(get_overlap  "${input_str}")"
	echo "Input string  = '${input_str}'" >&2
	echo "Output string = '${output_str}'" >&2

	echo '--------' >&2
	input_str='[[1-3]][[3-4]][[4-8]][[8-10]][[10-12]]'
	output_str="$(get_overlap  "${input_str}")"
	echo "Input string  = '${input_str}'" >&2
	echo "Output string = '${output_str}'" >&2

	echo '--------' >&2
	input_str='[[1-5]][[3-4]][[7-8]]'
	output_str="$(get_overlap  "${input_str}")"
	echo "Input string  = '${input_str}'" >&2
	echo "Output string = '${output_str}'" >&2

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

do_tests=''
usage=''
verbose=''
debug=''
input_str='[[1-4]][[2-5]][[9-10]]'

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
	if [[ ${verbose} ]]; then
		echo "Input string = '${input_str}'" >&2
	fi
	output_str="$(get_overlap "${input_str}")"

	echo "${script_name}: Input string  = '${input_str}'" >&2
	echo "${script_name}: Output string = '${output_str}'" >&2
fi

trap "on_exit 'Success'" EXIT
exit 0
