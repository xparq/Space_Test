export SPACE_TEST_VERSION=0.06

#
# Stuff here (still) depends on some settings prepared by `run_case`!
#

FATAL(){
# E.g. FATAL "Boops! Someone else did it!" 9
# The exit code is optional (default: 1).
# Obviously, only call this from where it's OK to catapult without cleanup!
	ERROR $1
	exit ${2:-1}
}
ERROR(){
	echo "- ERROR: $*" >&2
}
WARNING(){
	echo "- WARNING: $*" >&2
}
DEBUG(){
	test -n "$SPACE_DEBUG" && echo "----DBG: $*" >&2
}

# DEFAULTS
#-----------------------------------------------------------------------------

# This one should come preset:
if [ "${TEST_DIR}" == "" ]; then
	ERROR "TEST_DIR not defined! Do it before init'ing the rest!"
	return 6
fi

# Load (optional) config:
test -e "${TEST_DIR}/ .cfg" && . "${TEST_DIR}/ .cfg"

# Temp. dir:
export TMP_DIR="${TEST_DIR}/tmp"
#!! Fall back on $TMP, $TEMP, /tmp etc...
if [ ! -d "${TMP_DIR}" ]; then
	mkdir -p  "${TMP_DIR}"
	if [ ! -d "${TMP_DIR}" ]; then
		ERROR "Couldn't create tmp dir '${TMP_DIR}'!:"
		return 1
	fi
	WARNING "${TMP_DIR} did not exist, created."
fi

# Set some "hard" defaults:
EXPECT_FILE_NAME=${EXPECT_FILE_NAME:-EXPECT}


#-----------------------------------------------------------------------------
get_case_path(){
	#!!Shouldn't we use $@ here too, as in the main runner loop?!
	case_path=${TEST_DIR}/$*
	# Not enough just to check for empty $1...:
	if [[ "`realpath \"${case_path}\"`" == "`realpath \"${TEST_DIR}\"`" ]]; then
		ERROR "Invalid test case path '${case_path}'!"
		return 1
	fi
	if [[ ! -e "${case_path}" ]]; then
		if [[ -e "${case_path}.case" ]]; then
#DEBUG a
			echo "${case_path}.case"
			return 0
		else
			ERROR "Test case \"$*\" not found!"
			return 1
		fi
	fi
	# Exists; check if test case: if file -> ends with .case, if dir -> dir/case exists
	if [[ -e "${case_path}/case" ]]; then
		# Fine, path is already a case dir.
#DEBUG b
		echo "${case_path}"
		return 0
	else
		if [[ "${case_path%.case}" != "${case_path}" ]]; then
#DEBUG "Existing test case file identified: ${case_path}"
			echo "${case_path}"
			return 0
		fi
	fi

	ERROR "Test case \"$*\" not found!"
	return 1
}

get_case_name(){
	name=`basename "${*%.case}"`
	echo ${name}
}

#-----------------------------------------------------------------------------
RUN(){
	if [ "${CASE}" == "" ]; then
		ERROR 'test case name not set (via CASE=...)!'
		return 3
	fi

	if [ "${case_variant_counter}" != "" ]; then
		case_variant_counter=$(($case_variant_counter + 1))
		echo "  Test [${case_variant_counter}]: $*" >&2
	else
		echo "  Test: $*" >&2
	fi

	# $* is the whole command to run, as is, but, alas, that won't work
	# if $1 contains spaces, so we need to take care of that here.
	# (Note: if $1 was pre-quoted, that would fail in even more hurtful ways! ;) )
	cmd=$1
	shift
	args=$*

	# Kludge to prepend ./ if no dir in cmd:
	normalized_dirpath=`dirname "${cmd}"`
	cmd=${normalized_dirpath}/${cmd}

	savecd=`pwd`
	cd "${TEST_CASE_DIR}"
	"$cmd" $args >> "${TMP_DIR}/${CASE}.out" 2>> "${TMP_DIR}/${CASE}.err"
	echo $? >> "${TMP_DIR}/${CASE}.retval"
	cd "${savecd}"
}

#-----------------------------------------------------------------------------
SH(){
#!!	run sh -c \"$*\"
#!!	run sh -c "$*"
#!!	- didn't work, maybe due to quoting problems?!

	if [ "${CASE}" == "" ]; then
		ERROR 'test case name not set (via CASE=...)!'
		return 3
	fi
	echo "  Testing: $*"

	# $* is the whole command to run, as is, but, alas, that won't work
	# if $1 contains spaces, so we need to take care of that here.
	# (Note: if $1 was pre-quoted, that would fail in even more hurtful ways! ;) )
	cmd=$1
	shift
	args=$*

	savecd=`pwd`
	cd "${TEST_CASE_DIR}"
#	echo "sh -c \"$cmd $args\"" >> "${TMP_DIR}/${CASE}.cmd"
	sh -c "$cmd $args" >> "${TMP_DIR}/${CASE}.out" 2>> "${TMP_DIR}/${CASE}.err"
	echo $? >> "${TMP_DIR}/${CASE}.retval"
	cd "${savecd}"
}

#-----------------------------------------------------------------------------
EXPECT(){
	# Reset by the test case runner (run_case)!
	EXPECT=${EXPECT}$*
}

EXCEPT(){
	ERROR "Well, well... Been there, done that! ;)"
}

check_make_flavor(){
	if [[ -n "${MAKE}" ]]; then echo "${MAKE}"; return 0; fi

	#! Must also check upper-cased, BusyBox(?) sometimes(?) converts env var names!...
	if [[ -n "${VisualStudioVersion}" || -n "${VISUALSTUDIOVERSION}" ]]; then
		echo nmake
			# `/nologo` will be applied implicitly
	else
		echo gnumake
			# Can't share Makefiles tho, so this dispatching is XOR, not OR... :-/
	fi
}


normalize_crlf(){
	dos2unix -u "$1" 2> /dev/null
}

#-----------------------------------------------------------------------------
# LESSONS...:

# NOTE: this "thoughtful precaution" actually made it impossible to ever execute it...:
#	case_exe="\"./issue 10.exe\""
# E.g. an earlier comment from run_cmd:
#	$* didn't work, despite a) apparently proper-looking quoting in the echoed output,
#	and also b) running the exact same command successfully from the sh command line...
#	and even c) running it directly from here:
#	"./issue 10.exe" --long
# (Neither did any quoting, shift+quoting, backticking, $()ing, whatever... Which is now
# understandable, in hinsight, but was a nightmare with a dual CMD / sh mindset! :) )
