#!/bin/bash

### This script switches between booting the overlayRoot.sh and /sbin/init
### Its only useful in conjunction with overlayRoot.sh on a Raspberry Pi.
### Copyright 2019, Walter Hüttenmeyer
###
###  This program is free software: you can redistribute it and/or modify
###     it under the terms of the GNU General Public License as published by
###     the Free Software Foundation, either version 3 of the License, or
###     (at your option) any later version.
### 
###     This program is distributed in the hope that it will be useful,
###     but WITHOUT ANY WARRANTY; without even the implied warranty of
###     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
###     GNU General Public License for more details.
### 
###     You should have received a copy of the GNU General Public License
###     along with this program.  If not, see <http://www.gnu.org/licenses/>.
###

CMDLINE="/boot/cmdline.txt"
INIT_DEFAULT="/sbin/init"
INIT_OVERLAY="/sbin/overlayRoot.sh"

 #Prepare directories for sed (masking)
SED_INIT_DEFAULT=$(echo "${INIT_DEFAULT}" | sed 's/\//\\\//g')
SED_INIT_OVERLAY=$(echo "${INIT_OVERLAY}" | sed 's/\//\\\//g')

 #Error and info message reporting
msg_err(){
	echo -e "ERROR:\t ${1}"
	help
	exit 1
}

msg_info(){
	echo -e "INFO:\t ${1}"
}

 #Check errorlevel of previous command and let us know
checkfail(){
	if [ $? -ne 0 ]; then
		msg_err "${1}"
	else
		msg_info "${1}: success"
	fi
}

 #Check if a file exists, if not exit with error
file_check(){
	if [ ! -f ${1} ]; then
		msg_err "The file ${1} does not exist!"
		exit 1
	fi
}
 
 #Print help for options
help(){
	echo -e "\n\rThis script will switch your cmdline.txt to either boot with (RO) or without (RW) the overlayRoot.sh script.\n
	\rOptions are as follows:
	\r-a <ACTION>\thalt / reboot\tshutdown and power off or reboot.
	\r-m <MODE>\tro / rw\t\tselect read-only or read-write mode."
	exit 1
}

 #Option handling
while getopts "a: m:" option; do
	case "${option}"
	in
		a) ACTION=${OPTARG};;
		m) MODE=${OPTARG};;
		*) msg_err "Invalid option specified";;
	esac
done

 #Construct sed commands to save everything including init= until we hit a whitespace, a newline or anything else at the end.
 #Save that and what's coming after, just leaving the value of init exposed. Now we can change it to whatever we like.
case "${MODE}"
in
	rw)	SED_CMD=$(sed -i "s/\(.*init=\)[^ ]*\|\n\|.*$ \(.*\)/\1$SED_INIT_DEFAULT\2/" "${CMDLINE}");;
	ro)	SED_CMD=$(sed -i "s/\(.*init=\)[^ ]*\|\n\|.*$ \(.*\)/\1$SED_INIT_OVERLAY\2/" "${CMDLINE}");;
	*) 	msg_err "Specify a mode (-m) please"
		help;;
esac

case "${ACTION}"
in
	halt)	PWR_CMD="/sbin/shutdown -h now";;
	reboot)	PWR_CMD="/sbin/shutdown -r now";;
	*)	msg_err "Specify an action (-a) please"
		help;;
esac

 #Check if cmdline.txt exists
file_check "${CMDLINE}"

 #Remount boot read-write
mount -o remount,rw /boot
checkfail "Remounting /boot RW"

 #Sed-magic the desired boot script
case "${MODE}"
in
	rw)	eval "${SED_CMD}";;
	ro)	eval "${SED_CMD}";;
	*)	help;;
esac

cat "${CMDLINE}"

msg_info "Sleeping for 5 seconds before reboot..."
sleep 5

 #Execute the desired action - reboot or shutdown
eval "${PWR_CMD}"

exit 0
