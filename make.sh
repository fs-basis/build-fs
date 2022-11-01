#!/bin/bash

##############################################

if [ "$(id -u)" = "0" ]; then
	echo ""
	echo "You are running as root. Do not do this, it is dangerous."
	echo "Aborting the build. Log in as a regular user and retry."
	echo ""
	exit 1
fi

##############################################
# check for link sh to bash instead of dash on Ubuntu (and possibly others)
/bin/sh --version 2>/dev/null | grep bash -s -q
if [ ! "$?" -eq "0" ]; then
	echo -e "\033[01;31m=========================================================="
	echo -e "===> ERROR - prepare-for-bs.sh not executet -> EXIT ! <==="
	echo -e "==========================================================\033[0m"
	exit
fi

##############################################

if [ "$1" == -h ] || [ "$1" == --help ]; then
	echo "Parameter 1                    : Target system (1-70)"
	echo "Parameter 2 (not UFS910/UFS922 : FFMPEG Version (1-3)"
	echo "Parameter 2                    : Optimization (1-6)"
	echo "Parameter 3                    : Neutrino variant (1-2)"
	echo "Parameter 4                    : External LCD support (1-4)"
	echo "Parameter 5 (HD51/H7/BRE2ZE4K) : Swap Data and Linux Swap (1-2)"
	echo "Parameter 6 (ARM)              : GCC Version (1-7)"
	exit
fi

##############################################

case $1 in
	[1-9] | 1[0-9] | 2[0-9] | 3[0-9] | 4[0-9] | 5[0-9] | 6[0-9] | 7[0-9]) REPLY=$1;;
	*)
		clear
		echo "Target receivers:"
		echo
		echo "  sh4-based receivers"
		echo "  Kathrein"
		echo "    1)  UFS-910"
		echo "    2)  UFS-912"
		echo "    3)  UFS-913"
		echo "    4)  UFS-922"
		echo
		echo "  AX/Mut@nt              Air Digital              WWIO"
		echo -e "   \033[01;32m51)  HD51\033[00m              57)  ZGEMMA H7           58)  WWIO BRE2ZE 4K"
		echo
		echo "  AXAS"
		echo "   66)  AXAS E4HD 4K Ultra"
		echo
		read -p "Select target (1-70)? ";;
esac

case "$REPLY" in
	 1) BOXARCH="sh4";BOXTYPE="ufs910";;
	 2) BOXARCH="sh4";BOXTYPE="ufs912";;
	 3) BOXARCH="sh4";BOXTYPE="ufs913";;
	 4) BOXARCH="sh4";BOXTYPE="ufs922";;

	51) BOXARCH="arm";BOXTYPE="hd51";;
	57) BOXARCH="arm";BOXTYPE="h7";;
	58) BOXARCH="arm";BOXTYPE="bre2ze4k";;

	66) BOXARCH="arm";BOXTYPE="e4hdultra";;

	 *) BOXARCH="arm";BOXTYPE="hd51";;
esac
echo "BOXARCH=$BOXARCH" > config
echo "BOXTYPE=$BOXTYPE" >> config

##############################################

if [ $BOXARCH == "sh4" ]; then
	CURDIR=`pwd`
	echo -ne "\n    Checking the .elf files in $CURDIR/root/boot..."
	set='audio_7100 audio_7105 audio_7111 video_7100 video_7105 video_7109 video_7111'
	for i in $set;
	do
		if [ ! -e $CURDIR/root/boot/$i.elf ]; then
			echo -e "\n    ERROR: One or more .elf files are missing in ./root/boot!"
			echo "           ($i.elf is one of them)"
			echo
			echo "    Correct this and retry."
			echo
			exit
		fi
	done
	echo " [OK]"
	echo
	echo "KERNEL_STM=p0217" >> config
fi

##############################################

if [ "$BOXARCH" == "sh4" ]; then
	LOCAL_FFMPEG_BOXTYPE_LIST='ufs912 ufs913'
	for i in $LOCAL_FFMPEG_BOXTYPE_LIST; do
		if [ "$BOXTYPE" == "$i" ]; then
			LOCAL_FFMPEG_BOXTYPE_LIST=$BOXTYPE
			echo "LOCAL_FFMPEG_BOXTYPE_LIST=$LOCAL_FFMPEG_BOXTYPE_LIST" >> config
		fi
	done
fi

if [ "$LOCAL_FFMPEG_BOXTYPE_LIST" == "$BOXTYPE" -o "$BOXARCH" == "arm" ]; then
	case $2 in
		[1-3]) REPLY=$2;;
		*)	echo -e "\nFFMPEG version:"
			echo -e "   \033[01;32m1)  FFMPEG 4.4\033[00m"
			echo "   2)  FFMPEG 4.4.2 [experimental]"
			echo "   3)  FFMPEG 5.1   [git snapshot]"
			read -p "Select optimization (1-3)? ";;
	esac

	case "$REPLY" in
		1)  FFMPEG_EXPERIMENTAL="0"
		    FFMPEG_SNAPSHOT="0";;
		2)  FFMPEG_EXPERIMENTAL="1"
		    FFMPEG_SNAPSHOT="0";;
		3)  FFMPEG_EXPERIMENTAL="0"
		    FFMPEG_SNAPSHOT="1";;
		*)  FFMPEG_EXPERIMENTAL="0"
		    FFMPEG_SNAPSHOT="0";;
	esac
	echo "FFMPEG_EXPERIMENTAL=$FFMPEG_EXPERIMENTAL" >> config
	echo "FFMPEG_SNAPSHOT=$FFMPEG_SNAPSHOT" >> config
fi

##############################################

case $3 in
	[1-6]) REPLY=$3;;
	*)	echo -e "\nOptimization:"
		echo -e "   \033[01;32m1)  optimization for size\033[00m"
		echo "   2)  optimization normal (current only SH4 or ARM with GCC 6)"
		echo "   3)  optimization for size, incl. PNG/JPG"
		echo "   4)  optimization normal (current only SH4 or ARM with GCC 6), incl. PNG/JPG"
		echo "   5)  Kernel debug"
		echo "   6)  debug (includes Kernel debug)"
		read -p "Select optimization (1-6)? ";;
esac

case "$REPLY" in
	1)  OPTIMIZATIONS="size"
	    OPTIMIZE_PICS="0";;
	2)  OPTIMIZATIONS="normal"
	    OPTIMIZE_PICS="0";;
	3)  OPTIMIZATIONS="size"
	    OPTIMIZE_PICS="1";;
	4)  OPTIMIZATIONS="normal"
	    OPTIMIZE_PICS="1";;
	5)  OPTIMIZATIONS="kerneldebug"
	    OPTIMIZE_PICS="0";;
	6)  OPTIMIZATIONS="debug"
	    OPTIMIZE_PICS="0";;
	*)  OPTIMIZATIONS="size"
	    OPTIMIZE_PICS="0";;
esac
echo "OPTIMIZATIONS=$OPTIMIZATIONS" >> config
echo "OPTIMIZE_PICS=$OPTIMIZE_PICS" >> config

##############################################

case $4 in
	[1-4]) REPLY=$4;;
	*)	echo -e "\nWhich Neutrino variant do you want to build:"
		echo -e "   \033[01;32m1)  neutrino-fs-master         [ arm/sh4 ]\033[00m"
		echo "   2)  neutrino-fs-test           [ arm/sh4 ]  !! NO LCD4L GLCD SUPPORT"
		read -p "Select Image to build   (1-2)? ";;
esac

case "$REPLY" in
	1)  FLAVOUR="FS_MASTER";;
	2)  FLAVOUR="FS_TEST";;
	*)  FLAVOUR="FS_MASTER";;
esac
echo "FLAVOUR=$FLAVOUR" >> config

##############################################

case $5 in
	[1-4]) REPLY=$5;;
	*)	echo -e "\nExternal LCD support:"
		echo -e "   \033[01;32m1)  No external LCD\033[00m"
		echo "   2)  graphlcd for external LCD"
		echo "   3)  lcd4linux for external LCD"
		echo "   4)  graphlcd and lcd4linux for external LCD (both)"
		read -p "Select external LCD support (1-4)? ";;
esac

case "$REPLY" in
	1) EXTERNAL_LCD="none";;
	2) EXTERNAL_LCD="graphlcd";;
	3) EXTERNAL_LCD="lcd4linux";;
	4) EXTERNAL_LCD="both";;
	*) EXTERNAL_LCD="none";;
esac
echo "EXTERNAL_LCD=$EXTERNAL_LCD" >> config

##############################################

# dataswap linuxswap hd51/h7/bre2ze4k/e4hdultra

if [ $BOXTYPE == 'hd51' -o $BOXTYPE == 'h7' -o $BOXTYPE == 'bre2ze4k' -o $BOXTYPE == 'e4hdultra' ]; then
	case $6 in
		[1-2]) REPLY=$6;;
		*)	echo -e "\nSelect Swap Data and Linux Swap:"
			echo -e "   1)  Swap OFF"
			echo -e "   \033[01;32m2)  Swap ON\033[00m"
			read -p "Select SWAP support (1-2)? ";;
	esac

case "$REPLY" in
	1) SWAPDATA="0";;
	2) SWAPDATA="1";;
	*) SWAPDATA="1";;
esac
echo "SWAPDATA=$SWAPDATA" >> config
fi
##############################################

# gcc version for ARM
if [ $BOXARCH == 'arm' ]; then
	case $7 in
		[1-7]) REPLY=$7;;
		*)	echo -e "\nSelect GCC version:"
			echo "   1)  GCC version  6.5.0"
			echo "   2)  GCC version  7.5.0"
			echo -e "   \033[01;32m3)  GCC version  8.5.0\033[00m"
			echo "   4)  GCC version  9.5.0"
			echo "   5)  GCC version 10.4.0"
			echo "   6)  GCC version 11.3.0"
			echo "   7)  GCC version 12.2.0 (not yet ready)"
			read -p "Select GCC version (1-7)? ";;
	esac

	case "$REPLY" in
		1) BS_GCC_VER="6.5.0";;
		2) BS_GCC_VER="7.5.0";;
		3) BS_GCC_VER="8.5.0";;
		4) BS_GCC_VER="9.5.0";;
		5) BS_GCC_VER="10.4.0";;
		6) BS_GCC_VER="11.3.0";;
		7) BS_GCC_VER="12.2.0";;
		*) BS_GCC_VER="8.5.0";;
	esac
	echo "BS_GCC_VER=$BS_GCC_VER" >> config
else
	echo "BS_GCC_VER=4.8.4" >> config
fi
##############################################

echo " "
make printenv
##############################################
echo "Your next step could be:"
case "$FLAVOUR" in
	FS*)
		echo "  make neutrino / make mp"
		echo "  make neutrino-plugins / make mpp";;
	*)
		echo "  make flashimage"
		echo "  make ofgimage";;
esac
echo " "
