#!/usr/bin/perl


while (<>) {
    #$_=lc;
    ($Fld1) = split(/,/, $_, 2);
    if (
       $Fld1 =~ /\w.*@\w/ &&
       $Fld1 !~ /^#/ &&
       $Fld1 !~ /\@yale\.edu/i &&
       $Fld1 !~ /\@.*\.yale\.edu/i &&
       $Fld1 !~ /^whitelist\@example\.com/i
       ) 
    {
      print 'From:',$Fld1, '  ERROR: Sender blocked for phishing APER ',

       "\n" ,'To:' ,$Fld1, '  ERROR: Recipient blocked for phishing APER',"\n";
    }
}
