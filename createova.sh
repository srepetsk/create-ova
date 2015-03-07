#!/bin/bash
#Prompt for:
#  VM Name
#  Disk ID (full path)
#
# Use the supplied Disk ID to find the "old" disk in the old datastor

# Directory to export contents to for tar creation
# Change this to wherever you want the creation to happen
EXPORT="/data/convert"
# The datastore which we want to search drives for
DATASTOR="/mnt/Glustor"
# Location of where this script and files reside
ROOT="/root/create"

# DO NOT EDIT BELOW THIS LINE
# Help contents
HELP="./createovf <VM_NAME> <PATH_TO_DATA_DISK>"
# Template ovf file to use
TEMPLATE_OVA="template.ovf"
# Disk ID to replace:
TEMPLATE_DISK="b094aefc-c3cb-4a52-a0f0-af27f1f63da7"
TEMPLATE_NAME="srepetsk-test"
# Where to export the ova
EXPORT_LOC=""
# Take in the Disk ID and determine a location for the disk on...disk
# Once we get a location, run it through sed below to replace in the ovf
FIND_DISK="find ${DATASTOR} -type f -name"

if [ "$1" == "" ]; then
        echo "Requires VM name"
        echo $HELP
fi
if [ "$2" == "" ]; then
        echo "Supply the ID of the VM you want to package"
        echo $HELP
fi

# Echo out the config options to verify before tar gets too far
echo "----------------------------------------"
echo -e "Export data to:\t\t${EXPORT}"
echo -e "Search for disks in:\t${DATASTOR}"
echo -e ""
echo -e "Create VM named:\t${1}"
echo -e "Disk ID:\t\t${2}"
echo -e ""
echo -e "I don't know who you are. I don't know what you want. If you are looking"
echo -e "for Xen, I can tell you that we don't have the platform. But what I do"
echo -e "have are a very particular set of commands, commands I have acquired over"
echo -e "a very long career. Commands that make me a nightmare for OVAs like you."
echo -e "If you let my disk go now, that'll be the end of it. I will not extract you,"
echo -e "I will not rm you. But if you don't, I will look for you, I will find you,"
echo -e "and I will rm -f you."
echo "----------------------------------------"
echo ""

# Use the input parameters to find the data disk
DATA_DIR=$(find ${DATASTOR} -name ${2})
DATA_DISK=$(/bin/ls ${DATA_DIR}|awk '{print $1}'|head -n1)
DATA_LOC="${DATA_DIR}/${DATA_DISK}"
if [ -f ${DATA_LOC} ]; then
        echo "Disk found at ${DATA_DIR}/${DATA_DISK}"
else
        echo "No data disk in ${DATASTOR} was found. Please try again."
        exit
fi

echo "Replacing template ovf file with vm information"
sed -e 's/'${TEMPLATE_NAME}'/'${1}'/g' -e 's/'${TEMPLATE_DISK}'/'${DATA_DISK}'/g' "${ROOT}/${TEMPLATE_OVA}" > ${EXPORT}/${1}.ovf
chown vdsm:kvm ${EXPORT}/export.ovf
chmod u+w ${EXPORT}/export.ovf
echo ""
echo "Tarring up VM information:"
tar -cvzf ${EXPORT}/${1}.ova -C ${DATA_DIR} ${DATA_DISK} ${DATA_DISK}.meta -C ${EXPORT} ${1}.ovf

