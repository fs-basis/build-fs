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
	echo "Parameter 1                             : Target system (1-70)"
	echo "Parameter 2 (not UFS910/UFS922)         : FFMPEG Version (1-6)"
	echo "Parameter 3                             : Optimization (1-6)"
	echo "Parameter 4                             : Neutrino variant (1-2)"
	echo "Parameter 5                             : External LCD support (1-4)"
	echo "Parameter 6 (HD51/H7/BRE2ZE4K/E4HDULTRA): Swap Data and Linux Swap (1-3, 81-83)"
	echo "Parameter 7 (HD51/H7/BRE2ZE4K/E4HDULTRA): Kernel size in MB (default: 8)"
	echo "Parameter 8 (HD51/H7/BRE2ZE4K/E4HDULTRA): Swap size in MB (default: 128)"
	echo "Parameter 9 (ARM)                       : GCC Version (1-6)"
	exit
fi

##############################################

if [ "$1" != "" ]; then
	# defaults
	echo "BOXTYPE=$1" > config
	echo "OPTIMIZATIONS=size" >> config
	echo "OPTIMIZE_PICS=1" >> config
	echo "EXTERNAL_LCD=none" >> config
	echo "FLAVOUR=neutrino-fs" >> config
	echo "SWAPDATA=0" >> config
	case $1 in
		ufs910|ufs912|ufs913|ufs922)
			echo "BOXARCH=sh4" >> config
			echo "BS_GCC_VER=4.8.4" >> config
			[ "$1" == "ufs910" -o "$1" == "ufs922" ] && echo "FFMPEG_VER=2.8" >> config || echo "FFMPEG_VER=4.4" >> config
			make printenv
			exit
		;;
		hd51|h7|bre2ze4k|e4hdultra)
			echo "BOXARCH=arm" >> config
			echo "BS_GCC_VER=8.5.0" >> config
			echo "FFMPEG_VER=4.4" >> config
			make printenv
			exit
		;;
	esac
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
			case $2 in
				[1-3]) REPLY=$2;;
				*)	echo -e "\nFFMPEG version:"
					echo "   1)  FFMPEG 3.4 GIT"
					echo -e "   \033[01;32m2)  FFMPEG 4.4 GIT\033[00m"
					echo "   3)  FFMPEG 5.1 GIT [experimental]"
					read -p "Select FFMPEG version (1-3)? "
					;;
			esac

			case "$REPLY" in
				1)  FFMPEG_VER="3.4";;
				2)  FFMPEG_VER="4.4";;
				3)  FFMPEG_VER="5.1";;
				*)  FFMPEG_VER="4.4";;
			esac
			echo "FFMPEG_VER=$FFMPEG_VER" >> config
		fi
	done
	[ -z "$FFMPEG_VER" ] && echo "FFMPEG_VER=2.8" >> config
elif [ "$BOXARCH" == "arm" ]; then
	CNT=0
	case $2 in
		[1-6]) REPLY=$2;;
		*)	echo -e "\nFFMPEG version:"
			echo -e "   \033[01;32m1)  FFMPEG 4.4    GIT\033[00m" && CNT=$(($CNT+1))
			echo "   2)  FFMPEG 6.1    GIT [experimental]" && CNT=$(($CNT+1))
			echo "   3)  FFMPEG 7.1    GIT [experimental]" && CNT=$(($CNT+1))
			echo "   4)  FFMPEG 8.0    GIT [experimental]" && CNT=$(($CNT+1))
			echo "   5)  FFMPEG 8.1    GIT [experimental]" && CNT=$(($CNT+1))
			echo "   6)  FFMPEG MASTER GIT [experimental]" && CNT=$(($CNT+1))
			read -p "Select FFMPEG version (1-$CNT)? "
			;;
	esac

	case "$REPLY" in
		1)  FFMPEG_VER="4.4";;
		2)  FFMPEG_VER="6.1";;
		3)  FFMPEG_VER="7.1";;
		4)  FFMPEG_VER="8.0";;
		5)  FFMPEG_VER="8.1";;
		6)  FFMPEG_VER="master";;
		*)  FFMPEG_VER="4.4";;
	esac
	echo "FFMPEG_VER=$FFMPEG_VER" >> config
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
		echo -e "   \033[01;32m1)  neutrino-fs                [ arm/sh4 ]\033[00m"
		echo "   2)  neutrino-fs-test           [ arm/sh4 ]  !! NO LCD4L GLCD SUPPORT"
		read -p "Select Image to build   (1-2)? ";;
esac

case "$REPLY" in
	1)  FLAVOUR="neutrino-fs";;
	2)  FLAVOUR="neutrino-fs-test";;
	*)  FLAVOUR="neutrino-fs";;
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
		[1-3] | 8[1-3]) REPLY=$6;;
		*)	echo -e "\nSelect Swap Data and Linux Swap:"
			echo -e "   \033[01;32m 1)  Swap OFF\033[00m"
			echo -e "    2)  Swap ON (1x linux swap, 1x ext4 swap)"
			echo -e "    3)  Swap ON (1x linux swap)"
			if [ $BOXTYPE == 'e4hdultra' ]; then
				echo ""
				echo    "   AXAS E4HD 4K Ultra - 8 GB FLASH version:"
				echo -e "   81)  Swap OFF"
				echo -e "   82)  Swap ON (1x linux swap, 1x ext4 swap)"
				echo -e "   83)  Swap ON (1x linux swap)"
				read -p "Select SWAP support (1-3, 81-83)? "
			else
				read -p "Select SWAP support (1-3)? "
			fi;;
	esac

	case "$REPLY" in
		1)  SWAPDATA="0"
		    SWPCNT=0;;
		2)  SWAPDATA="1"
		    SWPCNT=2;;
		3)  SWAPDATA="2"
		    SWPCNT=1;;
		81) SWAPDATA="80"
		    SWPCNT=0;;
		82) SWAPDATA="81"
		    SWPCNT=2;;
		83) SWAPDATA="82"
		    SWPCNT=1;;
		*)  SWAPDATA="0"
		    SWPCNT=0;;
	esac
	echo "SWAPDATA=$SWAPDATA" >> config

	[ $SWAPDATA -gt 79 -a $SWAPDATA -lt 83 ] && EMMC_IMAGE_SIZE=7634944 || EMMC_IMAGE_SIZE=3817472
	echo "EMMC_IMAGE_SIZE=$EMMC_IMAGE_SIZE" >> config

	case $7 in
		[6-9]|1[0-9]) REPLY=$7;;
		*)	echo ""
			read -p $'Kernelsize in MB, 6..19 \033[01;32m(default: 8)\033[00m? ' REPLY;;
	esac
	[ ! -z $REPLY ] && KERNEL_PARTITION_SIZE=$(($REPLY*1024)) || KERNEL_PARTITION_SIZE=8192
	echo "KERNEL_PARTITION_SIZE=$KERNEL_PARTITION_SIZE" >> config

	if [ $SWPCNT -gt 0 ]; then
		case $8 in
			[1-9][0-9]|[1-9][0-9][0-9]|10[0-2][0-4]) REPLY=$8;;
			*)	echo ""
				read -p $'Swapsize in MB, 10..1024 \033[01;32m(default: 128)\033[00m? ' REPLY;;
		esac
		[ ! -z $REPLY ] && SWAP_DATA_PARTITION_SIZE=$(($REPLY*1024)) || SWAP_DATA_PARTITION_SIZE=131072
		echo "SWAP_DATA_PARTITION_SIZE=$SWAP_DATA_PARTITION_SIZE" >> config
	else
		SWAP_DATA_PARTITION_SIZE=0
		echo "SWAP_DATA_PARTITION_SIZE=$SWAP_DATA_PARTITION_SIZE" >> config
	fi

	BOOT_PARTITION_SIZE=1024
	ROOTFS_PARTITION_SIZE_MULTI=`expr $EMMC_IMAGE_SIZE \- $BOOT_PARTITION_SIZE \- $SWAP_DATA_PARTITION_SIZE \* $SWPCNT \- $KERNEL_PARTITION_SIZE \* 4`
	ROOTFS_PARTITION_SIZE_MULTI=`expr $ROOTFS_PARTITION_SIZE_MULTI \/ 4 \- 768`
	echo "ROOTFS_PARTITION_SIZE_MULTI=$ROOTFS_PARTITION_SIZE_MULTI" >> config

	echo ""
	echo "---------------------------------------------------------"
	echo "Using flashsize                 : $EMMC_IMAGE_SIZE	($(($EMMC_IMAGE_SIZE/1024)) MB)"
	echo "---------------------------------------------------------"
	echo "BOOT_PARTITION_SIZE         (1x): $BOOT_PARTITION_SIZE		($(($BOOT_PARTITION_SIZE/1024)) MB)"
	echo "KERNEL_PARTITION_SIZE       (4x): $KERNEL_PARTITION_SIZE		($(($KERNEL_PARTITION_SIZE/1024)) MB)"
	[ $SWPCNT -gt 0 ] && echo "SWAP_DATA_PARTITION_SIZE    (${SWPCNT}x): $SWAP_DATA_PARTITION_SIZE	($(($SWAP_DATA_PARTITION_SIZE/1024)) MB)"
	echo "ROOTFS_PARTITION_SIZE_MULTI (4x): $ROOTFS_PARTITION_SIZE_MULTI	($(($ROOTFS_PARTITION_SIZE_MULTI/1024)) MB)"
	echo "---------------------------------------------------------"
fi
##############################################

# gcc version for ARM
if [ $BOXARCH == 'arm' ]; then
	case $9 in
		[1-6]) REPLY=$9;;
		*)	echo -e "\nSelect GCC version:"
			echo "   1)  GCC version  6.5.0"
			echo "   2)  GCC version  7.5.0"
			echo -e "   \033[01;32m3)  GCC version  8.5.0\033[00m"
			echo "   4)  GCC version  9.5.0"
			echo "   5)  GCC version 10.5.0"
			echo "   6)  GCC version 11.5.0"
			read -p "Select GCC version (1-6)? ";;
	esac

	case "$REPLY" in
		1) BS_GCC_VER="6.5.0";;
		2) BS_GCC_VER="7.5.0";;
		3) BS_GCC_VER="8.5.0";;
		4) BS_GCC_VER="9.5.0";;
		5) BS_GCC_VER="10.5.0";;
		6) BS_GCC_VER="11.5.0";;
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
