#!/bin/bash -

# - on #! line means no more option processing

# START PREAMBLE
# Preamble IFS, unsets, utility functions etc. adapted from 'Classic Shell Scripting'
#  available at http://safari.oreilly.com

# Reset IFS. Even though ksh doesn't import IFS from the environment,
# $ENV could set it.  This uses special bash and ksh93 notation,
# not in POSIX.
IFS=$' \t\n'

# Make sure unalias is not a function, since it's a regular built-in.
# unset is a special built-in, so it will be found before functions.
unset -f unalias

# Unset all aliases and quote unalias so it's not alias-expanded.
\unalias -a

# Set PATH
PATH=/bin:/usr/bin
export PATH

# Include standard reusable functions for all scripts
source dcsunix_shell_lib_1 || exit 1
# END PREAMBLE

# Usage function is script specific, but you MUST have one for the library
#  functions to work.
usage( )
{
    echo "Usage: $PROGRAM [--?] [--help] [--version] phishing_reply_addresses"
}

# Program and version are used by library functions
PROGRAM=`basename $0`
VERSION=1.0

EXITCODE=0

# Command line parsing is script specific
while test $# -gt 0
do
    case $1 in
    --help | --hel | --he | --h | '--?' | -help | -hel | -he | -h | '-?' )
        usage_and_exit 0
        ;;
    --version | --versio | --versi | --vers | --ver | --ve | --v | \
    -version | -versio | -versi | -vers | -ver | -ve | -v )
        version
        exit 0
        ;;
    -*)
        error "Unrecognized option: $1"
        ;;
    *)
        break
        ;;
    esac
    shift
done
# Test for commmand line parsing is script specific
test $# = 1 || usage_and_exit 1

while read line ;do

# Set $a to just the address and filter
# Must be LHS@RHS
# Must not be a comment
# Must not be @something.yale.edu
a=$(echo ${line} |\
  /usr/bin/awk -F, '$1 ~ \
  /\w.*@\w/ && \
  !/^#/ && \
  !/@.*\.yale\.edu/ \
  {print tolower($1)}')

# match @yale.edu and skip if found in directory
if [[ ${a} =~ "@yale.edu"  ]]; then 

	# search the directory and fail open if the search fails
	b=$( /usr/bin/ldapsearch -LLL -x -h directory.yale.edu -b \
            o=yale.edu mail="$a" ) || continue

        # if there's a mail entry that matches, skip
	if [[ ${b} =~ "mail: ${a}" ]]; then
                continue	
	fi

fi

# print what remains
if [[ -n ${a} ]]; then
	echo "From:${a}  ERROR: Sender blocked for phishing APER"
        echo "To:${a}  ERROR: Recipient blocked for phishing APER" 
fi

done < ${1}

test ${EXITCODE} -gt 125 && EXITCODE=125
exit ${EXITCODE}
