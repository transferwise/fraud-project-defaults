#!/bin/bash

CURR_DIR=$( pwd )
BASE_DIR=../
PROJECT_FILTER=fraud-.*
EDITORCONFIG_FILE=.editorconfig
CHECKSTYLE_FILE=checkstyle.xml
PROJECT_DEFAULTS_DIR=fraud-project-defaults/

### Colors ###

RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PRUPLE='\033[0;35m'

LIGHT_GREY='\033[0;37m'

DARK_GREY='\033[1;30m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHT_BLUE='\033[1;34m'
LIGHT_PRUPLE='\033[1;35m'
LIGHT_CYAN='\033[1;36m'

NC='\033[0m' # No Color


function compareProjects() {
    PROJECTA=$1
    PROJECTB=$2

    printf "Comparing ${LIGHT_BLUE}${1}${LIGHT_CYAN}${EDITORCONFIG_FILE}${NC} to ${LIGHT_BLUE}${2}${LIGHT_CYAN}${EDITORCONFIG_FILE}${NC} ..."
    compareFiles $PROJECTA$EDITORCONFIG_FILE $PROJECTB$EDITORCONFIG_FILE
    
#    printf "Comparing ${LIGHT_BLUE}${1}${LIGHT_CYAN}${CHECKSTYLE_FILE}${NC} to ${LIGHT_BLUE}${2}${LIGHT_CYAN}${CHECKSTYLE_FILE}${NC} ..."
#    compareFiles $PROJECTA$CHECKSTYLE_FILE $PROJECTB$CHECKSTYLE_FILE
    
}

function compareFiles() {
    FILE1=$1 #$EDITORCONFIG_FILE
    FILE2=$2 #$EDITORCONFIG_FILE
    
    DIFFERENCE=$(diff $FILE1 $FILE2 2>&1)
    EXITCODE=$?
    if [ $EXITCODE == 0 ]; then
        printf "${GREEN} ✓ Identical ${NC}"
    elif [ $EXITCODE == 1 ]; then
	diff $FILE1 $FILE2
	printf "diffs"
    elif [ $EXITCODE == 2 ]; then
	printf "${RED}Missing file!${NC}"
    fi
    #echo "called with exit code: $?"
    
    echo ""
}

### Scan projects ###

#echo "Working dir: $BASE_DIR"
cd $BASE_DIR


PROJECTSSTRING=$( ls -d */ | cat | grep "^$PROJECT_FILTER" )
printf "${DARK_GREY}Scanning the following projects (${LIGHT_CYAN}$PROJECT_FILTER${DARK_GREY}):${NC} in ${LIGHT_BLUE}${BASE_DIR}${NC}\n"
PROJECTS=()

#Add project defaults dir at first place
PROJECTS+=( $PROJECT_DEFAULTS_DIR )
printf "Add project defaults dir: ${LIGHT_GREEN}${PROJECT_DEFAULTS_DIR}${NC}\n"
	
for PROJECT in $PROJECTSSTRING
do
    if [ $PROJECT != $PROJECT_DEFAULTS_DIR ]; then 
	#Project defaults dir already added
	printf "Found project: ${LIGHT_GREEN}${PROJECT}${NC}\n"
	PROJECTS+=( $PROJECT)
    fi
done



PROJ_NUM=${#PROJECTS[@]} 

echo ""

for A in $(seq $PROJ_NUM)
do

    NEXT=$(( $A + 1 ))
    for B in $(seq $NEXT $PROJ_NUM)
    do
	if [ $A == $B ]; then
	    continue
	fi
	if [ $B -ge $PROJ_NUM ]; then
	    continue
	fi
	FILE_A=${PROJECTS[ $(( $A - 1 )) ]}
	FILE_B=${PROJECTS[ $(( $B - 1 )) ]}
	compareProjects $FILE_A $FILE_B
    done
    echo ""
done

printf "${GREEN}Comparision completed${NC}\n"