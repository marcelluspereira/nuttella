#!/bin/bash
 ############################################################################
 # apps/nuttella.sh
 #
 #  under one or more
 # contributor license agreements.  See the NOTICE file distributed with
 # this work for additional information regarding copyright ownership.  The
 # ASF licenses this file to you under the Apache License, Version 2.0 (the
 # "License"); you may not use this file except in compliance with the
 # License.  You may obtain a copy of the License at
 #
 #   http://www.apache.org/licenses/LICENSE-2.0
 #
 # Unless required by applicable law or agreed to in writing, software
 # distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 # WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
 # License for the specific language governing permissions and limitations
 # under the License.
 #
 ############################################################################/
#! Nuttella
#\brief Simple script to setup the environment to new applications in NuttX
#\author Marcellus Pereira <marcellus.pereira@gmail.com>
#\version 0.1
#\date 11/01/2021
#\copyright Copyright 2021 Marcellus Pereira <marcellus.pereira@gmail.com>
#\license Licensed to the Apache Software Foundation (ASF)
#/

### Definitions

## Version
VERSION=0.2

## Author
AUTHOR="Marcellus Pereira" 
AUTHORS_EMAIL="marcellus.pereiraATgmail.com"

## Defaults
DESCRIPTION="This is my first program"
NAME="My first program"

## Directories
NUTTX_ROOT="$HOME/nuttxspace"
#NUTTX_ROOT="/tmp/"
SUBDIR="apps/examples"

## Verbosity
VERBOSE_OUTPUT=1

## Colors
RED='\033[1;31m'
NC='\033[0m'
YELLOW='\033[1;33m'


############################################################
# Help                                                     #
############################################################ 
Help()
{
   # Display Help
   echo "Configures the scripts for you application's source code."
   echo
   echo "Syntax: nuttella [-a|d|D|e|h|N|s|t|v] <name_of_your_application>"
   echo "options:"
   echo " -a	author's name."
   echo " -e	author's email."
   echo " -d	full path to your nuttx directory. Default is <~/nuttxspace/>."
   echo " -D	program's description for Kconfig file. Default is \"This is my first program\""
   echo " -h	print this Help."
   echo " -N	program's name for Kconfig file. Default is \"My first program\""
   echo " -t	create a subdirectory under [a]pps | [e]xamples directory."
   echo " -s	shh..."
   echo " -v	version information."
   echo
}


###
# Version
###
Version()
{
   echo "Nuttella version $VERSION, 2021, by Marcellus Pereira <marcellus.pereiraATgmail.com>." 
}

###
# Main function
###
while getopts ":a:t:d:e:hsD:N:v" option; do
    case $option in
	a) AUTHOR=$OPTARG;;
    t) Type=$OPTARG
       # Type = a (application) | e (example)
       if [[ "$Type" = "a" ]]; then
    	SUBDIR="apps"
       elif [[ "$Type" = "e" ]]; then
    	SUBDIR="apps/examples"
       else
    	echo -e "${RED}Error!${YELLOW} -$OPTARG${NC} invalid option."
       exit
       fi;;
    d) NUTTX_ROOT=$OPTARG;;
    D) DESCRIPTION=$OPTARG;;
	e) AUTHORS_EMAIL=$OPTARG;;
    h) # Show help
	   Help
	   exit;;
    N) NAME=$OPTARG
	   if [ -z "$NAME" ] || [[ ${NAME:0:1} == "-" ]]; then
		echo -e "${RED}Error!${YELLOW} -N invalid option."
		exit
	   fi;;
	s) VERBOSE_OUTPUT=0;;
    v) Version
	   exit;;
    \?) printf "${RED}Error:${NC} Invalid option. Try -h, please.\n"
	    exit;;
    :) echo -e "${RED}Invalid option!${NC} -$OPTARG needs an argument."
	       exit;;
    esac
done
shift $((OPTIND -1))

# Extract file name

if [ -z "$1" ]
then
    printf "${RED}Error:${NC} a script needs a name. Try -h, please.\n"
    exit
else
    FILENAME=$1
fi

DIRECTORY=$NUTTX_ROOT/$SUBDIR/$FILENAME

#Creates files on choosen directories
if [ ! -d "$DIRECTORY" ]
then 
   mkdir -p $DIRECTORY
fi

#Creates main skeleton file
cat << EOF >$DIRECTORY/$FILENAME"_main.c"
/****************************************************************************
 * $SUBDIR/$FILENAME_main.c
 *
 *   Copyright (C) `date +'%Y'` $AUTHOR. All rights reserved.
 *   Author: $AUTHOR <$AUTHORS_EMAIL>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 * 3. Neither the name NuttX nor the names of its contributors may be
 *    used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 ****************************************************************************/

/****************************************************************************
 * Included Files
 ****************************************************************************/

#include <nuttx/config.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>

/****************************************************************************
 * Public Functions
 ****************************************************************************/

/****************************************************************************
 * custom_app_main
 ****************************************************************************/

#ifdef CONFIG_BUILD_KERNEL
int main(int argc, FAR char *argv[])
#else
int ${FILENAME}_main(int argc, char *argv[])
#endif
{

  return 0;
}

EOF
#### END OF MAIN FILE


cat << EOF >$DIRECTORY/Kconfig
#
# For a description of the syntax of this configuration file,
# see the file kconfig-language.txt in the NuttX tools repository.
#

config EXAMPLES_${FILENAME^^}
	bool "${NAME}"
	default n
	---help---
		${DESCRIPTION}

if EXAMPLES_${FILENAME^^}

config EXAMPLES_${FILENAME^^}_PROGNAME
	string "Program name"
	default "${NAME}"
	depends on BUILD_KERNEL
	---help---
		This is the name of the program that will be use when the NSH ELF
		program is installed.

config EXAMPLES_${FILENAME^^}_PRIORITY
	int "${NAME} task priority"
	default 100

config EXAMPLES_${FILENAME^^}_STACKSIZE
	int "${NAME} stack size"
	default 2048

endif
EOF
### END OF KCONFIG FILE

#### CREATE Make.defs
cat << EOF >$DIRECTORY/Make.defs
############################################################################
# $SUBDIR/Make.defs
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.
#
############################################################################

ifneq (\$(CONFIG_EXAMPLES_${FILENAME^^}),)
CONFIGURED_APPS += \$(APPDIR)/examples/${FILENAME}
endif
EOF
### END OF MAKE.DEFS FILE

#### CREATE Makefile
cat << EOF >$DIRECTORY/Makefile
############################################################################
# $SUBDIR/$FILENAME/Makefile
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.  The
# ASF licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations
# under the License.
#
############################################################################

include \$(APPDIR)/Make.defs

# User application info

PROGNAME = ${FILENAME}
PRIORITY = \$(CONFIG_EXAMPLES_${FILENAME^^}_PRIORITY)
STACKSIZE = \$(CONFIG_EXAMPLES_${FILENAME^^}_STACKSIZE)
MODULE = \$(CONFIG_EXAMPLES_${FILENAME^^})

MAINSRC = ${FILENAME}_main.c

include \$(APPDIR)/Application.mk
EOF

###
# Update Kconfig on examples directory
###
printf '$-0i\nsource \"'$NUTTX_ROOT/$SUBDIR/$FILENAME/'Kconfig\"\n.\nw\n' | ed -s $NUTTX_ROOT/$SUBDIR/Kconfig
#echo $NUTTX_ROOT/$SUBDIR/Kconfig

###
# Print output information
###
if [ $VERBOSE_OUTPUT -eq 1 ];
then
	echo "Minimum framework for NuttX programs compilation was created in:"
	echo $DIRECTORY;
	echo "Have a nice day."
fi



