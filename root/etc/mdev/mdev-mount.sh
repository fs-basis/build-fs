#!/bin/sh
# no 'add' action if comes from kernel when symlink in /media is absent
[ "$ACTION" == "add" -a -z "$(readlink /media/mnt)" ] && exit 0
[ -f /var/etc/msettings.conf ] && . /var/etc/msettings.conf || ( HDDSYM=0 && AUTOFS=0 && NFSD=0 )
ENABLE_LOG=1
LOG="/tmp/mdev.log"
DEV=""
LAB=""
LINK=""
RMREC=0
RMDEV=""
AUTO_TOKEN="/tmp/.autofs-starting"
AUTO_MOUNTBASE="/mnt/usb"
MEDIA_MOUNTBASE="/media"
ROOTDEV=$(readlink /dev/root)
NTFSOPTS="-o big_writes,noatime"
#
loginfo()
{
OUT=$1
logleft="[$ACTION] $(date +'%H:%M:%S') [$MDEV]"
if [ "$ENABLE_LOG" == "1" ];then
	echo "$logleft $OUT" >> $LOG
else
	echo "$logleft $OUT"
fi
}
#
# do not add or remove root device again...
[ "$ROOTDEV" == "$MDEV" ] && loginfo "no action on /dev/$MDEV --> do not add or remove root device again..." && exit 0
#
[ -e /tmp/.nomdevmount ] && loginfo "no action on /dev/$MDEV --> /tmp/.nomdevmount exists" && exit 0
#
BLKID=$(blkid -c /dev/null /dev/$MDEV)
eval ${BLKID#*:}
[ "$TYPE" == "swap" ] && loginfo "no action on /dev/$MDEV --> Linux-swap device" && exit 0
[ "$LABEL" == "SWAP" -a "$AUTOFS" == "0" ] && loginfo "no action on /dev/$MDEV --> device with LABEL=$LABEL no hard mount" && exit 0
#
VAL=${MDEV:3:1}
[ ! $VAL > 0 ] &&  exit 0
VAL=$((VAL-1))
[ "$AUTOFS" == "0" ] && NTFSMOUNT=$(which ntfs-3g) && [ "$VAL" != "0" ] && VAL=1
#
read_auto_dir() {
	FOUND=0
	for i in `ls $AUTO_MOUNTBASE`;do
		DEV=`echo $i | grep $MDEV | cut -d "-" -f2`
		LAB=`echo $i | grep $MDEV | cut -d "-" -f1`
		[ "$DEV" == "$MDEV" ] && FOUND=1 && break
	done
}
#
read_media_dir() {
	FOUND=0
	OLDPWD=$PWD
	cd $MEDIA_MOUNTBASE
	for i in `ls ./`;do
		[ "$i" == "$LINK" ] && FOUND=1 && break
	done
	cd $OLDPWD
}
#
remove_mountpoint() {
	OLDPWD=$PWD
	cd $MEDIA_MOUNTBASE
	for i in `ls ./`; do
		if [ -L "$i" ];then
			[ -n "`echo $i | grep '-' | grep $MDEV`" ] && rm -f $i
		else
			[ -n "`echo $i | grep '-' | grep $MDEV`" ] && rmdir $i
		fi
	done
	cd $OLDPWD
}
#
umount_other_records() {
	RET=1
	OLDPWD=$PWD
	cd $MEDIA_MOUNTBASE
	for i in `ls ./`; do
		if [ ! -L "$i" ];then
			RMDEV=`echo $i | grep $LAB | cut -d "-" -f2`
			if [ -n "$RMDEV" ];then
#				umount -lf /dev/$RMDEV
				umount -lf $MEDIA_MOUNTBASE/$LAB-$RMDEV
				RET=$?
				[ $RET = 0 ] && rmdir $i || break
			fi
		fi
	done
	cd $OLDPWD
}
#
case "$ACTION" in
	add)
		[ -z "$TYPE" ] && loginfo "no action on /dev/$MDEV --> no blkid entry" && exit 0
		[ -z "$LABEL" ] && LABEL="NOLABEL"
		sleep $VAL
# mount with cmds
		if [ "$AUTOFS" == "1" ];then
			# wait if cmds during system start is finished
			while [ -e /tmp/.cmds-start ];do sleep 1;done
			# wait if autofs actions are running from another script instance
			while [ -e $AUTO_TOKEN ];do sleep 1;done
			read_auto_dir
			if [ "$FOUND" != "1" ];then
				loginfo "mounting /dev/$MDEV to $AUTO_MOUNTBASE/$LABEL-$MDEV"
				if [ "$LABEL" == "RECORD" ];then
					touch $AUTO_TOKEN
					[ "$HDDSYM" == "0" -o "$NFSD" == "1" ] && echo "`date +'%H:%M:%S'` HDD --> mount hard" >> /tmp/cmds.log && cmds checkhdd >> /tmp/cmds.log
					[ "$HDDSYM" == "1" -a "$NFSD" == "0" ] && echo "`date +'%H:%M:%S'` HDD --> mount weak" >> /tmp/cmds.log && cmds checkhdd sym >> /tmp/cmds.log
					rm -f $AUTO_TOKEN
					exit 0
				else
					touch $AUTO_TOKEN
					if [ -n "`pidof automount`" ];then
						echo "`date +'%H:%M:%S'` Restart --> autofs" >> /tmp/cmds.log
				       		cmds autofs restart >> /tmp/cmds.log
					else
						echo "`date +'%H:%M:%S'` Start --> autofs" >> /tmp/cmds.log
						cmds autofs start >> /tmp/cmds.log
					fi
					rm -f $AUTO_TOKEN
				fi
			else
				loginfo "/dev/$MDEV already mounted - not mounting again"
			fi
# mount with busybox
		else
			LINK=$LABEL"-"$MDEV
			MOUNTPOINT=$MEDIA_MOUNTBASE"/"$LINK
			read_media_dir
			if [ "$FOUND" != "1" ];then
				loginfo "mounting /dev/$MDEV to $MEDIA_MOUNTBASE/$LABEL-$MDEV"
				if [ "$LABEL" == "RECORD" -a -z "`ls $MEDIA_MOUNTBASE | grep RECORD-sd`" ];then
					ln -sf /hdd $MOUNTPOINT
					[ -n "`mount | grep /dev/$MDEV | grep /hdd`" ] && loginfo "/dev/$MDEV already mounted - not mounting again" && exit 0
					for i in 1 2;do
						( [ -n "$NTFSMOUNT" ] && [ "$TYPE" == "ntfs" ] ) && $NTFSMOUNT $NTFSOPTS /dev/$MDEV /hdd || mount -t auto /dev/$MDEV /hdd
						RET=$?
						[ $RET == 0 ] && break || loginfo "mount error $LABEL $MDEV"
						[ $RET != 0 -a "$TYPE" == "jfs" ] && fsck.jfs -a /dev/$MDEV && loginfo "fsck.jfs /dev/$MDEV"
					done
					[ $RET != 0 ] && rm -f $MOUNTPOINT
				else
					mkdir -p $MOUNTPOINT
					for i in 1 2;do
						( [ -n "$NTFSMOUNT" ] && [ "$TYPE" == "ntfs" ] ) && $NTFSMOUNT $NTFSOPTS /dev/$MDEV $MOUNTPOINT || mount -t $TYPE /dev/$MDEV $MOUNTPOINT
						RET=$?
						[ $RET == 0 ] && break || loginfo "mount error $LABEL $MDEV"
						[ $RET != 0 -a "$TYPE" == "jfs" ] && fsck.jfs -a /dev/$MDEV && loginfo "fsck.jfs /dev/$MDEV"
					done
					[ $RET != 0 ] && rmdir $MOUNTPOINT
				fi
			else
				loginfo "/dev/$MDEV already mounted - not mounting again"
			fi
		fi
		;;
	remove)
# umount with cmds
		if [ "$AUTOFS" == "1" ];then
			read_auto_dir
			[ -z "$LAB" ] && exit 0
			if [ "$HDDSYM" == "0" -o "$NFSD" == "1" ];then
				cmds check /dev/$MDEV /hdd
				RET=$?
				[ $RET == 1 ] && loginfo "umount /hdd --> /dev/$MDEV" && umount -lf /dev/$MDEV
			fi
			sleep $VAL
			while [ -e $AUTO_TOKEN ];do sleep 1;done
			read_auto_dir
			if [ "$FOUND" == "1" ];then
				touch $AUTO_TOKEN
				if [ -z "`blkid -c /dev/null | grep sd`" ];then
					echo "`date +'%H:%M:%S'` Stop --> autofs" >> /tmp/cmds.log
					loginfo "umounting /dev/$MDEV from $MEDIA_MOUNTBASE/$LAB-$MDEV"
					cmds autofs stop >> /tmp/cmds.log
				else
					echo "`date +'%H:%M:%S'` Restart --> autofs" >> /tmp/cmds.log
					loginfo "umounting /dev/$MDEV from $MEDIA_MOUNTBASE/$LAB-$MDEV"
					cmds autofs restart >> /tmp/cmds.log
					cmds mnt /hdd
					RET=$?
					if [ $RET == 0 ];then
						[ "$HDDSYM" == "0" -o "$NFSD" == "1" ] && cmds checkhdd >> /tmp/cmds.log
					fi
					[ "$HDDSYM" == "1" -a "$NFSD" == "0" ] && cmds checkhdd sym >> /tmp/cmds.log
				fi
				rm -f $AUTO_TOKEN
			fi
# umount with busybox
		else
			sleep $VAL
			LAB=`ls $MEDIA_MOUNTBASE | grep $MDEV | cut -d "-" -f1`
			if [ -n "$LAB" ];then
				loginfo "umounting device /dev/$MDEV from $MEDIA_MOUNTBASE/$LAB-$MDEV"
				umount -lf $MEDIA_MOUNTBASE/$LAB-$MDEV
				RET=$?
				[ $RET == 0 ] && remove_mountpoint || exit 0
				if [ "$LAB" == "RECORD" ];then
					umount_other_records
					[ $RET == 0 ] && mdev -s
				fi
			else
				loginfo "no action on /dev/$MDEV --> not mounted"
			fi
		fi
		;;
esac
exit 0
