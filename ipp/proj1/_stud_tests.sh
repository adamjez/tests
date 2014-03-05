#!/usr/bin/env bash

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# IPP - xqr - veřejné testy - 2013/2014
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Činnost: 
# - vytvoří výstupy studentovy úlohy v daném interpretu na základě sady testů
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

TASK=../xqr
if [ "`hostname`" == "merlin.fit.vutbr.cz" ] ; then
    INTERPRETER="php -d open_basedir=\"\""
else
    INTERPRETER="php"
fi

EXTENSION=php
#INTERPRETER=python3
#EXTENSION=py

# cesty ke vstupním a výstupním souborům
LOCAL_IN_PATH="./tests/"
#LOCAL_IN_PATH="" #Alternative 1
#LOCAL_IN_PATH=`pwd`"/" #Alternative 2
LOCAL_OUT_PATH="./tests/"
#LOCAL_OUT_PATH="" #Alternative 1
#LOCAL_OUT_PATH=`pwd`"/" #Alternative 2
# cesta pro ukládání chybového výstupu studentského skriptu
LOG_PATH="./logs/"


if [ ! -d $LOG_PATH ]; then
	mkdir $LOG_PATH;
fi;

#upravy
green='\e[0;32m' 
endGreen='\e[0m'
red='\e[0;31m' 
endRed='\e[0m'

declare -a tests=(test01 test02 test03 test04 test05 test06 test07 test08 test09 test10 test11 test12 test13 test14 test15 test16 test17 test18 test19 test20 test21 test22);
declare -A params

for TEST in "${tests[@]}"
do
	IFS=$'\n' OPTIONS=($(cat ${LOCAL_IN_PATH}${TEST}  | grep -E '^[^#].+'))
	for option in ${OPTIONS[@]}; do
    item1=${option%% *}  # Delete longest substring match from back
   	item2=${option#*=} 
   	#item2=${item2%%[![:space:]]*} 
  	params[${item1}]=$item2; 
  	#echo $item1;
  	#echo $item2;
	done
	
	echo "Probiha test: ${TEST}";

  eval "$INTERPRETER $TASK.$EXTENSION ${params[CommandLine]} 2> ${LOG_PATH}${TEST}.err > ${LOG_PATH}${TEST}.out"
	RC=$?;
	result=0;

	if [[ "${params[ExpectedReturnValue]//[[:blank:]]/}" -ne "$RC" ]]
	then
			echo -e "${red}Hodnota return code se neshoduji!${endRed}";
			echo -e "${red}Ocekaval jsem ${params[ExpectedReturnValue]//[[:blank:]]/}	Dostal jsem $RC${endRed}";
			result=1;
	fi
	
	if [[ ${params[CheckStderr]} == *"1"* ]]
	then
		if [ -s ${LOG_PATH}${TEST}.err ]; then
			echo -e "${red}Standartni chybovy vystup neni prazdny!${endRed}";
			result=1;
		fi
	fi
	
	if [[ ${params[CheckStdout]} == *"1"* ]]
	then
		if [ ! -s ${LOG_PATH}${TEST}.out ]; then
			echo -e "${red}Standartni vystup je prazdny!${endRed}"	;
			result=1;
		fi
	fi
	
	if [[ ${params[CheckStdoutNot]} == *"1"* ]]
	then
		if [ -s ${LOG_PATH}${TEST}.out ]; then
			echo -e "${red}Standartni vystup neni prazdny!${endRed}"	;
			result=1;
		fi
	fi
	
	if [[ ${params[CmpStdout]} == *"1"* ]]
	then
		java -jar ./java/jexamxml.jar ${LOG_PATH}${TEST}.out ${LOCAL_OUT_PATH}${TEST}.out ${LOG_PATH}${TEST}.delta /D xqr_options >/dev/null
		if [ $? -ne 0 ]; then 
				echo -e "${red}Vysledky nejsou identicke${endRed}"
				result=1;
			else
				echo -e "${green}Vysledky jsou identicke${endGreen}"
		fi
	fi
	
	if [ $result -eq 0 ]; then
		echo -e "${green}Test probehl uspesne${endGreen}";
	fi;


#	$INTERPRETER $TASK.$EXTENSION --help > ${LOG_PATH}${TEST}.out1 2> ${LOG_PATH}${TEST}.err


done

