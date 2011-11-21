#!/bin/bash -
# - on #! line means no more option processing

# ignore case in tests
shopt -s nocasematch

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
source /usr/local/etc/dcsunix_shell_lib_1 || exit 1
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

# Make sure the line is comma delimited
if [[ ${line} =~ , ]]; then
	:
else
	continue
fi

# Chomp first comma to the end of the line
line=${line%%,*}

# Skip commented lines
if [[ ${line} =~ ^# ]]; then
	continue
fi

# Test for something@something. dot and _ appear in LHS
if [[ ${line} =~ [[:alnum:]\._]@[[:alnum:]] ]]; then
    # Skip @something.yale.edu since we cant verify it
    if [[ ${line} =~ "@*\.yale\.edu" ]]; then
        continue
    fi
    # match @yale.edu and search ldap and skip if found in directory
    if [[ ${line} =~ @yale\.edu  ]]; then 
    
    	# strip + off LHS before search
    	b=${line/+*@/@}
    
    	# search the directory and fail open if the search fails
    	c=$( /usr/bin/ldapsearch -LLL -x -h directory.yale.edu -b \
                o=yale.edu mail="${b}" ) || continue
    
            # if there's a mail entry that matches, skip
    	if [[ ${c} =~ "mail: ${b}" ]]; then
                    continue	
    	fi
    fi
else
	continue
fi

# print what remains
if [[ ${line} ]]; then
	echo "From:${line}  ERROR: Sender blocked for phishing APER"
        echo "To:${line}  ERROR: Recipient blocked for phishing APER" 
fi

done < ${1}

test ${EXITCODE} -gt 125 && EXITCODE=125
exit ${EXITCODE}
