#!/bin/bash

green='\e[0;32m' 
endGreen='\e[0m'

red='\e[0;31m' 
endRed='\e[0m'

succes=0


declare -a argument=('ftp://anonymous:secret@ftp.fit.vutbr.cz:21/pub/systems/centos' 'ftp.ubuntu.com/ubuntu/dists/' 'ftp.fit.vutbr.cz/' 'ftp.linux.cz/pub/local/' 'ftp://atrey.karlin.mff.cuni.cz/pub/' 'ftp://ftp.eunet.cz/' 'ftp://ftp.muni.cz/pub' 'ftp://anonymous:heslo%3a@ftp.fit.vutbr.cz');


echo "Spoustim testy" > logfile

for i in "${argument[@]}"
do
   echo "Spoustim ftpclient s argumentem: ${i}" | tee -a logfile 1>&1
   ./ftpclient "${i}" >> logfile

	if [ $? -ne 0 ]; then 
		echo -e "${red}Neuspech${endRed}"
		printf "Neuspech\n\n" >> logfile
	else
		((succes++));
		echo -e "${green}Uspech${endGreen}"
		printf "Uspech\n\n" >> logfile 
	fi
done


echo "VYSLEDKY TESTU:" | tee -a logfile 1>&1
echo "Uspesne probehlo ${succes} / ${#argument[@]} spojeni" | tee -a logfile 1>&1



exit 0
