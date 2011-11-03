all: sample aper

sample:
	time awk -f aper.awk sample_list.txt > old
	time ./aper.sh sample_list.txt > new
	wc -l old new
	diff -i -w old new | grep -v whitelist@example.com
aper:
	time awk -f aper.awk phishing_reply_addresses > old2
	time ./aper.sh phishing_reply_addresses > new2
	wc -l old2 new2
	diff -i -w old2 new2 | grep -v whitelist@example.com

