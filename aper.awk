BEGIN { FS=","; IGNORECASE=1;}

  $1 ~				   \
  /\w.*@\w/			&& \
  !/^#/				&& \
  !/@.*yale\.edu/ 		&& \
  !/^whitelist@example\.com/	   \
                                   \
  { print \
    "From:"$1," ERROR: Sender blocked for phishing APER",\
    "\n"\
    "To:"$1," ERROR: Recipient blocked for phishing APER" \
  }
