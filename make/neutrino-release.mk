#
# auxiliary targets for model-specific builds
#

#
# ufs910
#
neutrino-release-ufs910:
	install -m 0755 $(SKEL_ROOT)/release/halt_ufs $(RELEASE_DIR)/etc/init.d/halt
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/vfd/vfd.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-stx7100.ko $(RELEASE_DIR)/lib/modules/
	cp $(SKEL_ROOT)/boot/video_7100.elf $(RELEASE_DIR)/lib/firmware/video.elf
	cp $(SKEL_ROOT)/boot/audio_7100.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	cp $(SKEL_ROOT)/firmware/dvb-fe-cx21143.fw $(RELEASE_DIR)/lib/firmware/dvb-fe-cx24116.fw
	cp -dp $(SKEL_ROOT)/release/lircd_ufs910.conf $(RELEASE_DIR)/etc/lircd.conf

#
# ufs912
#
neutrino-release-ufs912:
	install -m 0755 $(SKEL_ROOT)/release/halt_ufs912 $(RELEASE_DIR)/etc/init.d/halt
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/micom/micom.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7111.ko $(RELEASE_DIR)/lib/modules/
	cp $(SKEL_ROOT)/boot/video_7111.elf $(RELEASE_DIR)/lib/firmware/video.elf
	cp $(SKEL_ROOT)/boot/audio_7111.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	[ -e $(SKEL_ROOT)/boot/audio_dts.elf ] && cp $(SKEL_ROOT)/boot/audio_dts.elf $(RELEASE_DIR)/lib/firmware/audio_dts.elf || true
	cp $(SKEL_ROOT)/firmware/component_7111_mb618.fw $(RELEASE_DIR)/lib/firmware/component.fw

#
# ufs913
#
neutrino-release-ufs913:
	install -m 0755 $(SKEL_ROOT)/release/halt_ufs912 $(RELEASE_DIR)/etc/init.d/halt
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/micom/micom.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/multituner/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-sti7105.ko $(RELEASE_DIR)/lib/modules/
	cp $(SKEL_ROOT)/boot/video_7105.elf $(RELEASE_DIR)/lib/firmware/video.elf
	cp $(SKEL_ROOT)/boot/audio_7105.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	[ -e $(SKEL_ROOT)/boot/audio_dts.elf ] && cp $(SKEL_ROOT)/boot/audio_dts.elf $(RELEASE_DIR)/lib/firmware/audio_dts.elf || true
	cp $(SKEL_ROOT)/firmware/component_7105_pdk7105.fw $(RELEASE_DIR)/lib/firmware/component.fw
	cp $(SKEL_ROOT)/firmware/dvb-fe-avl6222.fw $(RELEASE_DIR)/lib/firmware/

#
# ufs922
#
neutrino-release-ufs922:
	install -m 0755 $(SKEL_ROOT)/release/halt_ufs $(RELEASE_DIR)/etc/init.d/halt
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontcontroller/micom/micom.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/frontends/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmcore-display-stx7109c3.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/ufs922_fan/fan_ctrl.ko $(RELEASE_DIR)/lib/modules/
	cp $(SKEL_ROOT)/boot/video_7109.elf $(RELEASE_DIR)/lib/firmware/video.elf
	cp $(SKEL_ROOT)/boot/audio_7100.elf $(RELEASE_DIR)/lib/firmware/audio.elf
	cp $(SKEL_ROOT)/firmware/dvb-fe-avl2108.fw $(RELEASE_DIR)/lib/firmware/
	cp $(SKEL_ROOT)/firmware/dvb-fe-avl6222.fw $(RELEASE_DIR)/lib/firmware/
	cp $(SKEL_ROOT)/firmware/dvb-fe-cx21143.fw $(RELEASE_DIR)/lib/firmware/
	cp $(SKEL_ROOT)/firmware/dvb-fe-stv6306.fw $(RELEASE_DIR)/lib/firmware/

#
# WWIO Bre2ze4k
#
neutrino-release-bre2ze4k:
	install -m 0755 $(SKEL_ROOT)/release/halt_hd51 $(RELEASE_DIR)/etc/init.d/halt
	install -m 0755 $(SKEL_ROOT)/etc/init.d/mmcblk-by-name_hd51 $(RELEASE_DIR)/etc/init.d/mmcblk-by-name
ifeq ($(SWAPDATA), $(filter $(SWAPDATA), 1 2))
	cp -f $(SKEL_ROOT)/release/fstab_hd51 $(RELEASE_DIR)/etc/fstab
else
	cp -f $(SKEL_ROOT)/release/fstab_hd51_swap_off $(RELEASE_DIR)/etc/fstab
endif
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/boot/zImage.dtb $(RELEASE_DIR)/boot/

#
# Mutant HD51
#
neutrino-release-hd51:
	install -m 0755 $(SKEL_ROOT)/release/halt_hd51 $(RELEASE_DIR)/etc/init.d/halt
	install -m 0755 $(SKEL_ROOT)/etc/init.d/mmcblk-by-name_hd51 $(RELEASE_DIR)/etc/init.d/mmcblk-by-name
ifeq ($(SWAPDATA), $(filter $(SWAPDATA), 1 2))
	cp -f $(SKEL_ROOT)/release/fstab_hd51 $(RELEASE_DIR)/etc/fstab
else
	cp -f $(SKEL_ROOT)/release/fstab_hd51_swap_off $(RELEASE_DIR)/etc/fstab
endif
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/boot/zImage.dtb $(RELEASE_DIR)/boot/

#
# Zgemma H7
#
neutrino-release-h7:
	install -m 0755 $(SKEL_ROOT)/release/halt_hd51 $(RELEASE_DIR)/etc/init.d/halt
	install -m 0755 $(SKEL_ROOT)/etc/init.d/mmcblk-by-name_hd51 $(RELEASE_DIR)/etc/init.d/mmcblk-by-name
ifeq ($(SWAPDATA), $(filter $(SWAPDATA), 1 2))
	cp -f $(SKEL_ROOT)/release/fstab_hd51 $(RELEASE_DIR)/etc/fstab
else
	cp -f $(SKEL_ROOT)/release/fstab_hd51_swap_off $(RELEASE_DIR)/etc/fstab
endif
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/boot/zImage.dtb $(RELEASE_DIR)/boot/

#
# E4HD 4K Ultra
#
neutrino-release-e4hdultra:
	install -m 0755 $(SKEL_ROOT)/release/halt_hd51 $(RELEASE_DIR)/etc/init.d/halt
	install -m 0755 $(SKEL_ROOT)/etc/init.d/mmcblk-by-name_hd51 $(RELEASE_DIR)/etc/init.d/mmcblk-by-name
ifeq ($(SWAPDATA), $(filter $(SWAPDATA), 1 2 81 82))
	cp -f $(SKEL_ROOT)/release/fstab_e4hd $(RELEASE_DIR)/etc/fstab
else
	cp -f $(SKEL_ROOT)/release/fstab_e4hd_swap_off $(RELEASE_DIR)/etc/fstab
endif
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/*.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/boot/zImage $(RELEASE_DIR)/boot/
	install -m 0644 $(SKEL_ROOT)/release/lcdsplash.bmp $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/

#
# neutrino-release-base
#
# the following target creates the common file base
neutrino-release-base:
	rm -rf $(RELEASE_DIR) || true
	install -d $(RELEASE_DIR)
	install -d $(RELEASE_DIR)/{bin,boot,dev,dev.static,etc,hdd,lib,media,mnt,proc,ram,root,sbin,swap,sys,tmp,usr,var}
ifeq ($(BOXARCH), $(filter $(BOXARCH), arm))
	install -d $(RELEASE_DIR)/var/{bin,boot,emu,epg,httpd,keys,lib,tuxbox}
else
	install -d $(RELEASE_DIR)/var/{bin,boot,emu,etc,epg,httpd,keys,lib,tuxbox}
endif
	install -d $(RELEASE_DIR)/var/tuxbox/{config,control,icons,locale,plugins,themes,webscripts,webchannels}
	install -d $(RELEASE_DIR)/var/tuxbox/config/zapit
#
	install -d $(RELEASE_DIR)/etc/{init.d,network,mdev,ssl}
	install -d $(RELEASE_DIR)/etc/network/if-{post-{up,down},pre-{up,down},up,down}.d
	install -d $(RELEASE_DIR)/lib/{modules,udev,firmware}
	install -d $(RELEASE_DIR)/media/{dvd,nfs,usb,sda1,sdb1}
	ln -sf /hdd $(RELEASE_DIR)/media/hdd
	install -d $(RELEASE_DIR)/mnt/{hdd,nfs,usb}
	install -d $(RELEASE_DIR)/mnt/nfs{0..7}
	install -d $(RELEASE_DIR)/usr/{bin,lib,sbin,share}

	install -d $(RELEASE_DIR)/usr/share/{fonts,tuxbox,udhcpc,zoneinfo,lua}
	install -d $(RELEASE_DIR)/usr/share/tuxbox/neutrino
	install -d $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/logo
	install -d $(RELEASE_DIR)/usr/share/lua/5.2
#
#ifeq ($(BOXARCH), $(filter $(BOXARCH), arm))
#	install -d $(RELEASE_DIR)/var/lib/{nfs,modules,opkg}
#else
	install -d $(RELEASE_DIR)/var/lib/{nfs,modules}
#endif
#
	mkdir -p $(RELEASE_DIR)/etc/rc.d/rc0.d
	ln -s ../init.d/sendsigs $(RELEASE_DIR)/etc/rc.d/rc0.d/S20sendsigs
	ln -s ../init.d/umountfs $(RELEASE_DIR)/etc/rc.d/rc0.d/S40umountfs
	ln -s ../init.d/halt $(RELEASE_DIR)/etc/rc.d/rc0.d/S90halt
	mkdir -p $(RELEASE_DIR)/etc/rc.d/rc6.d
	ln -s ../init.d/sendsigs $(RELEASE_DIR)/etc/rc.d/rc6.d/S20sendsigs
	ln -s ../init.d/umountfs $(RELEASE_DIR)/etc/rc.d/rc6.d/S40umountfs
	ln -s ../init.d/reboot $(RELEASE_DIR)/etc/rc.d/rc6.d/S90reboot
	ln -sf /usr/share $(RELEASE_DIR)/share
	ln -sf /usr/share/tuxbox/neutrino/icons/logo $(RELEASE_DIR)/logos
	ln -sf /usr/share/tuxbox/neutrino/icons/logo $(RELEASE_DIR)/var/httpd/logos
ifeq ($(BOXARCH), $(filter $(BOXARCH), arm))
	touch $(RELEASE_DIR)/etc/.firstboot
else
	touch $(RELEASE_DIR)/var/etc/.firstboot
endif
	cp -a $(TARGET_DIR)/bin/* $(RELEASE_DIR)/bin/
	cp -a $(TARGET_DIR)/usr/bin/* $(RELEASE_DIR)/usr/bin/
	cp -a $(TARGET_DIR)/sbin/* $(RELEASE_DIR)/sbin/
	cp -a $(TARGET_DIR)/usr/sbin/* $(RELEASE_DIR)/usr/sbin/
	cp -dp $(TARGET_DIR)/.version $(RELEASE_DIR)/
ifeq ($(BOXARCH), $(filter $(BOXARCH), arm))
	cp -dp $(TARGET_DIR)/.version $(RELEASE_DIR)/etc
else
	ln -sf /.version $(RELEASE_DIR)/var/etc/.version
endif
	cp $(TARGET_DIR)/boot/$(KERNELNAME) $(RELEASE_DIR)/boot/
	ln -sf /proc/mounts $(RELEASE_DIR)/etc/mtab
	cp -dp $(SKEL_ROOT)/sbin/MAKEDEV $(RELEASE_DIR)/sbin/
	ln -sf ../sbin/MAKEDEV $(RELEASE_DIR)/dev/MAKEDEV
	ln -sf ../../sbin/MAKEDEV $(RELEASE_DIR)/lib/udev/MAKEDEV
	cp -aR $(SKEL_ROOT)/etc/mdev/* $(RELEASE_DIR)/etc/mdev/
	cp -aR $(SKEL_ROOT)/etc/mdev_$(BOXARCH).conf $(RELEASE_DIR)/etc/mdev.conf
	cp -aR $(SKEL_ROOT)/usr/share/udhcpc/* $(RELEASE_DIR)/usr/share/udhcpc/
	cp -aR $(SKEL_ROOT)/usr/share/zoneinfo/* $(RELEASE_DIR)/usr/share/zoneinfo/
	cp $(SKEL_ROOT)/bin/autologin $(RELEASE_DIR)/bin/
	cp $(SKEL_ROOT)/usr/sbin/fw_printenv $(RELEASE_DIR)/usr/sbin/
	cp -aR $(TARGET_DIR)/etc/init.d/* $(RELEASE_DIR)/etc/init.d/
	cp -aR $(TARGET_DIR)/etc/* $(RELEASE_DIR)/etc/
	echo "$(BOXTYPE)" > $(RELEASE_DIR)/etc/hostname
	ln -sf ../../bin/busybox $(RELEASE_DIR)/usr/bin/ether-wake
	ln -sf ../../bin/showiframe $(RELEASE_DIR)/usr/bin/showiframe
	ln -sf ../../usr/sbin/fw_printenv $(RELEASE_DIR)/usr/sbin/fw_setenv
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), ufs910 ufs912 ufs913 ufs922))
	cp $(SKEL_ROOT)/release/fw_env.config_$(BOXTYPE) $(RELEASE_DIR)/etc/fw_env.config
endif
	install -m 0755 $(SKEL_ROOT)/release/rcS_neutrino_$(BOXTYPE) $(RELEASE_DIR)/etc/init.d/rcS
#
#
################################################################################
ifeq ($(BOXARCH), sh4)
################################################################################
#
# player
#
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stm_v4l2.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stm_v4l2.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmfb.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/stgfb/stmfb/stmfb.ko $(RELEASE_DIR)/lib/modules/ || true
	cd $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra && \
	for mod in \
		sound/pseudocard/pseudocard.ko \
		sound/silencegen/silencegen.ko \
		stm/mmelog/mmelog.ko \
		stm/monitor/stm_monitor.ko \
		media/dvb/stm/dvb/stmdvb.ko \
		sound/ksound/ksound.ko \
		media/dvb/stm/mpeg2_hard_host_transformer/mpeg2hw.ko \
		media/dvb/stm/backend/player2.ko \
		media/dvb/stm/h264_preprocessor/sth264pp.ko \
		media/dvb/stm/allocator/stmalloc.ko \
		stm/platform/platform.ko \
		stm/platform/p2div64.ko \
		media/sysfs/stm/stmsysfs.ko \
	;do \
		if [ -e player2/linux/drivers/$$mod ]; then \
			cp player2/linux/drivers/$$mod $(RELEASE_DIR)/lib/modules/; \
			$(TARGET)-strip --strip-unneeded $(RELEASE_DIR)/lib/modules/`basename $$mod`; \
		else \
			touch $(RELEASE_DIR)/lib/modules/`basename $$mod`; \
		fi; \
	done
#
# modules
#
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/avs/avs.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/avs/avs.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/bpamem/bpamem.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/bpamem/bpamem.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/boxtype/boxtype.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/boxtype/boxtype.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/compcache/ramzswap.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/compcache/ramzswap.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/e2_proc/e2_proc.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/e2_proc/e2_proc.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/net/ipv6/ipv6.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/net/ipv6/ipv6.ko $(RELEASE_DIR)/lib/modules/ || true
#
# multicom 324
#
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/embxshell/embxshell.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/embxshell/embxshell.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/embxmailbox/embxmailbox.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/embxmailbox/embxmailbox.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/embxshm/embxshm.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/embxshm/embxshm.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/mme/mme_host.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/multicom/mme/mme_host.ko $(RELEASE_DIR)/lib/modules/ || true
#
#
#
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/simu_button/simu_button.ko $(RELEASE_DIR)/lib/modules/
	cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/cic/*.ko $(RELEASE_DIR)/lib/modules/

	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/button/button.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/button/button.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/cec/cec.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/cec/cec.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/cpu_frequ/cpu_frequ.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/cpu_frequ/cpu_frequ.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/led/led.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/led/led.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/pti/pti.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/pti/pti.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/pti_np/pti.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/pti_np/pti.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/smartcard/smartcard.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/smartcard/smartcard.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/sata_switch/sata.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/sata_switch/sata.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/mini_fo/mini_fo.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/mini_fo/mini_fo.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/autofs4/autofs4.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/autofs4/autofs4.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/tun.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/net/tun.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/fuse/fuse.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/fuse/fuse.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/ntfs/ntfs.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/ntfs/ntfs.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/cifs/cifs.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/cifs/cifs.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/jfs/jfs.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/jfs/jfs.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/nfsd/nfsd.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/nfsd/nfsd.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/exportfs/exportfs.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/exportfs/exportfs.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/nfs_common/nfs_acl.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/nfs_common/nfs_acl.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/nfs/nfs.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/fs/nfs/nfs.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/usbserial.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/usbserial.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/ftdi_sio.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/ftdi_sio.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/pl2303.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/pl2303.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/ch341.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/ch341.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/cp210x.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/cp210x.ko $(RELEASE_DIR)/lib/modules/ || true
endif
#
#
################################################################################
ifeq ($(BOXARCH), $(filter $(BOXARCH), arm))
################################################################################
#
#
#
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/usbserial.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/usbserial.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/ftdi_sio.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/ftdi_sio.ko $(RELEASE_DIR)/lib/modules/ftdi_sio.ko || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/pl2303.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/pl2303.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/ch341.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/ch341.ko $(RELEASE_DIR)/lib/modules/ || true
	[ -e $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/cp210x.ko ] && cp $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/kernel/drivers/usb/serial/cp210x.ko $(RELEASE_DIR)/lib/modules/ || true
#
endif
#
#
################################################################################

#
# modules.available
#
	cp -aR $(SKEL_ROOT)/release/modules.available_$(BOXARCH) $(RELEASE_DIR)/etc/modules.available
#
# lib usr/lib
#
	cp -R $(TARGET_DIR)/lib/* $(RELEASE_DIR)/lib/
	rm -f $(RELEASE_DIR)/lib/*.{a,o,la}
	chmod 755 $(RELEASE_DIR)/lib/*
ifeq ($(BOXARCH), $(filter $(BOXARCH), sh4))
	ln -s /var/tuxbox/plugins/libfx2.so $(RELEASE_DIR)/lib/libfx2.so
endif
	cp -R $(TARGET_LIB_DIR)/* $(RELEASE_DIR)/usr/lib/
	rm -rf $(RELEASE_DIR)/usr/lib/{engines,gconv,libxslt-plugins,pkgconfig,python$(PYTHON_VER),sigc++-2.0}
	rm -f $(RELEASE_DIR)/usr/lib/*.{a,o,la}
	chmod 755 $(RELEASE_DIR)/usr/lib/*
#
# fonts
#
	if [ -e $(TARGET_DIR)/usr/share/fonts/HandelGotD.ttf ]; then \
		cp -aR $(TARGET_DIR)/usr/share/fonts/HandelGotD.ttf $(RELEASE_DIR)/usr/share/fonts; \
	fi
	if [ -e $(TARGET_DIR)/usr/share/fonts/neutrino.ttf ]; then \
		cp -aR $(TARGET_DIR)/usr/share/fonts/neutrino.ttf $(RELEASE_DIR)/usr/share/fonts; \
	fi
	if [ -e $(TARGET_DIR)/usr/share/fonts/tuxtxt.ttf ]; then \
		cp -aR $(TARGET_DIR)/usr/share/fonts/tuxtxt.ttf $(RELEASE_DIR)/usr/share/fonts; \
	fi

#
# backgrounds / config / control / webchannels
#
	cp -aR $(TARGET_DIR)/var/boot/* $(RELEASE_DIR)/var/boot
	cp -aR $(TARGET_DIR)/var/tuxbox/config/* $(RELEASE_DIR)/var/tuxbox/config
	cp -aR $(TARGET_DIR)/var/tuxbox/control/* $(RELEASE_DIR)/var/tuxbox/control
	cp -aR $(TARGET_DIR)/var/tuxbox/webchannels/* $(RELEASE_DIR)/var/tuxbox/webchannels
#
# copy root_neutrino
#
	cp -aR $(SKEL_ROOT)/root_neutrino/* $(RELEASE_DIR)/
ifneq ($(BOXTYPE), $(filter $(BOXTYPE), hd51 h7 e4hdultra))
	rm -f $(RELEASE_DIR)/var/tuxbox/config/cables.xml
	rm -f $(RELEASE_DIR)/var/tuxbox/config/terrestrial.xml
endif
#
# iso-codes
#
	[ -e $(TARGET_DIR)/usr/share/iso-codes ] && cp -aR $(TARGET_DIR)/usr/share/iso-codes $(RELEASE_DIR)/usr/share/ || true
	[ -e $(TARGET_DIR)/usr/share/tuxbox/iso-codes ] && cp -aR $(TARGET_DIR)/usr/share/tuxbox/iso-codes $(RELEASE_DIR)/usr/share/tuxbox/ || true
#
# httpd/icons/locale/themes
#
	cp -aR $(TARGET_DIR)/usr/share/tuxbox/neutrino/* $(RELEASE_DIR)/usr/share/tuxbox/neutrino
#
# lcd4linux
#
ifeq ($(EXTERNAL_LCD), $(filter $(EXTERNAL_LCD), lcd4linux both))
		cp -aR $(SKEL_ROOT)/var/tuxbox/lcd $(RELEASE_DIR)/var/tuxbox
		ln -s /var/tuxbox/lcd $(RELEASE_DIR)/usr/share/tuxbox/lcd
endif
#
# alsa
#
	if [ -e $(TARGET_DIR)/usr/share/alsa ]; then \
		mkdir -p $(RELEASE_DIR)/usr/share/alsa/; \
		mkdir $(RELEASE_DIR)/usr/share/alsa/cards/; \
		mkdir $(RELEASE_DIR)/usr/share/alsa/ctl/; \
		mkdir $(RELEASE_DIR)/usr/share/alsa/pcm/; \
		cp -dp $(TARGET_DIR)/usr/share/alsa/alsa.conf $(RELEASE_DIR)/usr/share/alsa/alsa.conf; \
		cp $(TARGET_DIR)/usr/share/alsa/cards/aliases.conf $(RELEASE_DIR)/usr/share/alsa/cards/; \
		cp $(TARGET_DIR)/usr/share/alsa/ctl/default.conf $(RELEASE_DIR)/usr/share/alsa/ctl/; \
		cp $(TARGET_DIR)/usr/share/alsa/pcm/default.conf $(RELEASE_DIR)/usr/share/alsa/pcm/; \
		cp $(TARGET_DIR)/usr/share/alsa/pcm/dmix.conf $(RELEASE_DIR)/usr/share/alsa/pcm/; \
		cp $(TARGET_DIR)/usr/share/alsa/pcm/dsnoop.conf $(RELEASE_DIR)/usr/share/alsa/pcm/; \
	fi
#
# mc
#
	if [ -e $(TARGET_DIR)/usr/bin/mc ]; then \
		cp -aR $(TARGET_DIR)/usr/share/mc $(RELEASE_DIR)/usr/share/; \
		cp -af $(TARGET_DIR)/usr/libexec $(RELEASE_DIR)/usr/; \
	fi
#
# lua
#
	if [ -d $(TARGET_DIR)/usr/share/lua ]; then \
		cp -aR $(TARGET_DIR)/usr/share/lua $(RELEASE_DIR)/usr/share; \
	fi
#
# plugins
#
	if [ -d $(TARGET_DIR)/var/tuxbox/plugins ]; then \
		cp -af $(TARGET_DIR)/var/tuxbox/plugins $(RELEASE_DIR)/var/tuxbox/; \
	fi
	if [ -d $(TARGET_DIR)/var/tuxbox/webscripts ]; then \
		cp -af $(TARGET_DIR)/var/tuxbox/webscripts $(RELEASE_DIR)/var/tuxbox/; \
	fi
	if [ -e $(RELEASE_DIR)/var/tuxbox/plugins/tuxwetter.so ]; then \
		cp -rf $(TARGET_DIR)/var/tuxbox/config/tuxwetter $(RELEASE_DIR)/var/tuxbox/config; \
	fi
	if [ -e $(RELEASE_DIR)/var/tuxbox/plugins/sokoban.so ]; then \
		cp -rf $(TARGET_DIR)/usr/share/tuxbox/sokoban $(RELEASE_DIR)/var/tuxbox/plugins; \
		ln -s /var/tuxbox/plugins/sokoban $(RELEASE_DIR)/usr/share/tuxbox/sokoban; \
	fi

#
# minisatip
#
	if [ -e $(TARGET_DIR)/usr/bin/minisatip -a -d $(TARGET_DIR)/usr/share/minisatip/html ]; then \
		mkdir -p $(RELEASE_DIR)/usr/share/minisatip; \
		cp -aR $(TARGET_DIR)/usr/share/minisatip/html $(RELEASE_DIR)/usr/share/minisatip; \
		rm -f $(RELEASE_DIR)/usr/lib/libdvbcsa*; \
	fi

#
# dropbear
#
	if [ -d $(RELEASE_DIR)/etc/dropbear ]; then \
		mkdir -p $(RELEASE_DIR)/.ssh; \
		chmod 700 $(RELEASE_DIR)/.ssh; \
		ln -s /etc/dropbear/authorized_keys $(RELEASE_DIR)/.ssh/authorized_keys; \
	fi

#
# delete unnecessary files
#
ifeq ($(BOXARCH), $(filter $(BOXARCH), sh4))
	rm -f $(RELEASE_DIR)/etc/mdev/ttyUSB-check.sh
endif
ifeq ($(BOXARCH), $(filter $(BOXARCH), sh4))
	rm -f $(RELEASE_DIR)/etc/mdev/mdev-mount-mmc-boot.sh
	rm -f $(RELEASE_DIR)/etc/mdev/mdev-mount-mmc.sh
	rm -f $(RELEASE_DIR)/sbin/fsck.ext4
	rm -f $(RELEASE_DIR)/sbin/mkfs.ext4
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), ufs910 ufs922))
	rm -f $(RELEASE_DIR)/sbin/jfs_fsck
	rm -f $(RELEASE_DIR)/sbin/fsck.jfs
	rm -f $(RELEASE_DIR)/sbin/jfs_mkfs
	rm -f $(RELEASE_DIR)/sbin/mkfs.jfs
	rm -f $(RELEASE_DIR)/sbin/jfs_tune
	rm -f $(RELEASE_DIR)/etc/ssl/certs/ca-certificates.crt
	rm -f $(RELEASE_DIR)/usr/share/tuxbox/neutrino/httpd/images/rc_913.jpg
endif
	rm -f $(RELEASE_DIR)/etc/ssl/misc/*
	rm -f $(RELEASE_DIR)/usr/lib/lua/5.2/*.la
	rm -rf $(RELEASE_DIR)/lib/autofs
	rm -f $(RELEASE_DIR)/lib/libSegFault*
	rm -f $(RELEASE_DIR)/lib/libstdc++.*-gdb.py
	rm -f $(RELEASE_DIR)/lib/libthread_db*
	rm -f $(RELEASE_DIR)/lib/libanl*
	rm -rf $(RELEASE_DIR)/lib/modules/$(KERNEL_VER)
	rm -rf $(RELEASE_DIR)/lib/modules/$(KERNEL_VER)-$(BOXTYPE)
	rm -rf $(RELEASE_DIR)/usr/lib/alsa
	rm -rf $(RELEASE_DIR)/usr/lib/glib-2.0
	rm -rf $(RELEASE_DIR)/usr/lib/cmake
	rm -f $(RELEASE_DIR)/usr/lib/*.py
	rm -f $(RELEASE_DIR)/usr/lib/libc.so
	rm -f $(RELEASE_DIR)/usr/lib/xml2Conf.sh
	rm -f $(RELEASE_DIR)/usr/lib/libfontconfig*
	rm -f $(RELEASE_DIR)/usr/lib/libdvdcss*
	rm -f $(RELEASE_DIR)/usr/lib/libdvdnav*
	rm -f $(RELEASE_DIR)/usr/lib/libdvdread*
	rm -f $(RELEASE_DIR)/usr/lib/libcurses.so
	[ ! -e $(RELEASE_DIR)/usr/bin/mc ] && rm -f $(RELEASE_DIR)/usr/lib/libncurses* || true
	rm -f $(RELEASE_DIR)/usr/lib/libthread_db*
	rm -f $(RELEASE_DIR)/usr/lib/libanl*
	rm -f $(RELEASE_DIR)/usr/lib/libopkg*
	rm -f $(RELEASE_DIR)/bin/gitVCInfo
	rm -f $(RELEASE_DIR)/bin/evtest
	rm -f $(RELEASE_DIR)/bin/meta
	rm -f $(RELEASE_DIR)/bin/streamproxy
	rm -f $(RELEASE_DIR)/bin/libstb-hal-test
	rm -f $(RELEASE_DIR)/sbin/ldconfig
	rm -f $(RELEASE_DIR)/usr/bin/axfer
	rm -f $(RELEASE_DIR)/usr/bin/compile_et
	rm -f $(RELEASE_DIR)/usr/bin/pic2m2v
	rm -f $(RELEASE_DIR)/usr/bin/mk_cmds
	rm -f $(RELEASE_DIR)/usr/bin/{gdbus-codegen,glib-*,gtester-report}
	rm -f $(RELEASE_DIR)/usr/bin/nhlt-dmic-info
	rm -f $(RELEASE_DIR)/usr/bin/hb-*
ifeq ($(BOXARCH), $(filter $(BOXARCH), arm))
	rm -rf $(RELEASE_DIR)/dev.static
	rm -rf $(RELEASE_DIR)/ram
	rm -rf $(RELEASE_DIR)/root
endif
#
# The main target depends on the model.
# IMPORTANT: it is assumed that only one variable is set. Otherwise the target name won't be resolved.
#
$(D)/neutrino-release: neutrino-release-base neutrino-release-$(BOXTYPE)
	$(TUXBOX_CUSTOMIZE)
	@touch $@
#
# FOR YOUR OWN CHANGES use these folder in own_build/neutrino-hd
#
#	default for all receiver
	find $(OWN_BUILD)/neutrino-hd/ -mindepth 1 -maxdepth 1 -exec cp -at$(RELEASE_DIR)/ -- {} +
#	receiver specific (only if directory exist)
	[ -d "$(OWN_BUILD)/neutrino-hd.$(BOXTYPE)" ] && find $(OWN_BUILD)/neutrino-hd.$(BOXTYPE)/ -mindepth 1 -maxdepth 1 -exec cp -at$(RELEASE_DIR)/ -- {} + || true
	echo $(BOXTYPE) > $(RELEASE_DIR)/etc/model
#
# nicht die feine Art, aber funktioniert ;)
#
ifeq ($(BOXARCH), $(filter $(BOXARCH), arm))
	ln -sf /etc $(RELEASE_DIR)/var
else
	cp -dpfr $(RELEASE_DIR)/etc $(RELEASE_DIR)/var
	rm -fr $(RELEASE_DIR)/etc
	ln -sf /var/etc $(RELEASE_DIR)/etc
#DD	ln -sf var/etc $(RELEASE_DIR)/etc
#
#
endif
	ln -sf /var/tuxbox/webscripts $(RELEASE_DIR)/var/webtv

	ln -s /tmp $(RELEASE_DIR)/lib/init
	ln -s /tmp $(RELEASE_DIR)/var/lib/urandom
	ln -s /tmp $(RELEASE_DIR)/var/lock
	ln -s /tmp $(RELEASE_DIR)/var/log
	ln -s /tmp $(RELEASE_DIR)/var/run
	ln -s /tmp $(RELEASE_DIR)/var/tmp
#
#	rm -f $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/mp3-?.jpg
#	rm -f $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/mp3.jpg
#	rm -f $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/shutdown.jpg
#	rm -f $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/radiomode.jpg
#	rm -f $(RELEASE_DIR)/usr/share/tuxbox/neutrino/icons/start.jpg
#
#	ln -sf /var/tuxbox/plugins $(RELEASE_DIR)/var/plugins
#	ln -sf /var/tuxbox/webchannels $(RELEASE_DIR)/var/webchannels
#	ln -sf /var/tuxbox/webscripts $(RELEASE_DIR)/var/webscripts
#	ln -sf /var/tuxbox $(RELEASE_DIR)/lib/tuxbox

#
# linux-strip all
#
ifneq ($(OPTIMIZATIONS), $(filter $(OPTIMIZATIONS), kerneldebug debug normal))
	find $(RELEASE_DIR)/ -name '*' -exec $(TARGET)-strip --strip-unneeded {} &>/dev/null \;
ifeq ($(OPTIMIZE_PICS), 1)
	find $(RELEASE_DIR)/ -iname '*.jpg' -exec jpegoptim --strip-all -q {} \;
	find $(RELEASE_DIR)/ -iname '*.png' -exec optipng -nb -nc -o7 -quiet {} \;
endif
endif
	@echo "***************************************************************"
	@echo -e "\033[01;32m"
	@echo " Build of Neutrino for $(BOXTYPE) successfully completed."
	@echo -e "\033[00m"
	@echo "***************************************************************"
#
# neutrino-release-clean
#
neutrino-release-clean:
	rm -f $(D)/neutrino-release
