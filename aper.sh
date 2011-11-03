#!/bin/bash

while read line ;do

# Must be LHS@RHS
# Must not be a comment
# Must not be @something.yale.edu
a=$(echo $line |\
  awk -F, '$1 ~ \
  /\w.*@\w/ && \
  !/^#/ && \
  !/@.*\.yale\.edu/ \
  {print tolower($1)}')

# match @yale.edu and skip if found in directory
if [[ $( echo $a | awk '/@.*\<yale\.edu/' ) ]]; then 

	# search the directory and fail open if the search fails
	b=$( ldapsearch -LLL -x -h xdirectory.yale.edu -b \
            o=yale.edu mail="$a" ) || continue

        # if there's a mail entry that matches, skip
	if [[ $b =~ "mail: $a" ]]; then
                continue	
	fi
fi

# print what remains
if [[ $a ]]; then
	echo "From:$a  ERROR: Sender blocked for phishing APER"
        echo "To:$a  ERROR: Recipient blocked for phishing APER" 
fi

done < $1
