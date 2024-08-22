#!/usr/bin/env bash

usage() {
	local old_xtrace
	old_xtrace="$(shopt -po xtrace || :)"
	set +o xtrace

	{
		echo "${script_name} - Setup a named pipe."
		echo "Usage: ${script_name} [flags]"
		echo "Option flags:"
		echo "  -t --test       - Run tests. Default: '${do_tests}'."
		echo "  -h --help       - Show this help and exit."
		echo "  -v --verbose    - Verbose execution."
		echo "  -g --debug      - Extra verbose execution."
		echo "Pipe Name = '${pipe_name}'"
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

	rm -vf "${pipe_name}"
	if [[ ${verbose} ]]; then
		local sec="${SECONDS}"
		echo "${script_name}: Done: ${result}, ${sec} sec." >&2
	fi
}

on_err() {
	local f_name=${1}
	local line_no=${2}
	local err_no=${3}

	rm -vf "${pipe_name}"
	echo "${script_name}: ERROR: function=${f_name}, line=${line_no}, result=${err_no}" >&2

	exit "${err_no}"
}

on_test_exit() {
	local result="${1}"

	echo "${script_name}: Done: ${result}, ${SECONDS} sec." >&2
}

run_tests() {
	verbose=1
	echo "=== ${FUNCNAME[0]} start ===" >&2

	if [[ ! -p "${pipe_name}" ]]; then
		echo "No pipe found: '${pipe_name}'" >&2
		trap "on_test_exit 'Error'" EXIT
		exit 1
	fi

	echo 'aaaa' > "${pipe_name}"
	sleep 0.1
	echo 'a/aa\a' > "${pipe_name}"
	sleep 0.1
	echo 'aaa\a' > "${pipe_name}"
	sleep 0.1
	echo 'abcd' > "${pipe_name}"
	sleep 0.1
	echo 'quit' > "${pipe_name}"

	echo "=== ${FUNCNAME[0]} end ===" >&2
	echo >&2

	trap "on_test_exit 'Success'" EXIT
	exit 0
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
pipe_name='/tmp/that-pipe'

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
	if [[ ! -p "${pipe_name}" ]]; then
		rm -f "${pipe_name}"
		mkfifo "${pipe_name}"
	fi

	while read -r pipe_in < "${pipe_name}"; do
		echo "pipe = '${pipe_in}'" >&2

		if [[ "${pipe_in}" == 'quit' ]]; then
			break
		fi
	done
fi

trap "on_exit 'Success'" EXIT
exit 0

