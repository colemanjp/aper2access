all: sample aper

sample:
	time ./aper.sh sample_list.txt > aper.sample
	wc -l aper.sample
aper:
	time ./aper.sh phishing_reply_addresses > aper
	wc -l aper

