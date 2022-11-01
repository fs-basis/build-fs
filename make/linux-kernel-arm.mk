#
# makefile to build kernel arm
#

#
# Patches Kernel
#
HD51_PATCHES = \
		armbox/hd51_TBS-fixes-for-4.10-kernel.patch \
		armbox/hd51_0001-Support-TBS-USB-drivers-for-4.6-kernel.patch \
		armbox/hd51_0001-TBS-fixes-for-4.6-kernel.patch \
		armbox/hd51_0001-STV-Add-PLS-support.patch \
		armbox/hd51_0001-STV-Add-SNR-Signal-report-parameters.patch \
		armbox/hd51_blindscan2.patch \
		armbox/hd51_dvbs2x.patch \
		armbox/hd51_0001-stv090x-optimized-TS-sync-control.patch \
		armbox/hd51_reserve_dvb_adapter_0.patch \
		armbox/hd51_blacklist_mmc0.patch \
		armbox/hd51_export_pmpoweroffprepare.patch \
		armbox/4_10_fix-multiple-defs-yyloc.patch

E4HDULTRA_PATCHES = \
		armbox/hd51_TBS-fixes-for-4.10-kernel.patch \
		armbox/hd51_0001-Support-TBS-USB-drivers-for-4.6-kernel.patch \
		armbox/hd51_0001-TBS-fixes-for-4.6-kernel.patch \
		armbox/hd51_0001-STV-Add-PLS-support.patch \
		armbox/hd51_0001-STV-Add-SNR-Signal-report-parameters.patch \
		armbox/hd51_blindscan2.patch \
		armbox/hd51_dvbs2x.patch \
		armbox/hd51_0001-stv090x-optimized-TS-sync-control.patch \
		armbox/hd51_reserve_dvb_adapter_0.patch \
		armbox/hd51_blacklist_mmc0.patch \
		armbox/hd51_export_pmpoweroffprepare.patch \
		armbox/4_10_fix-multiple-defs-yyloc.patch \
		armbox/e4hdultra_v3-1-3-media-si2157-Add-support-for-Si2141-A10.patch \
		armbox/e4hdultra_v3-2-3-media-si2168-add-support-for-Si2168-D60.patch \
		armbox/e4hdultra_v3-3-3-media-dvbsky-MyGica-T230C-support.patch \
		armbox/e4hdultra_v3-3-4-media-dvbsky-MyGica-T230C-support.patch \
		armbox/e4hdultra_v3-3-5-media-dvbsky-MyGica-T230C-support.patch \
		armbox/e4hdultra_0002-cp1emu-do-not-use-bools-for-arithmetic.patch \
		armbox/e4hdultra_move-default-dialect-to-SMB3.patch \
		armbox/e4hdultra_add-more-devices-rtl8xxxu.patch \
		armbox/e4hdultra_0005-xbox-one-tuner-4.10.patch \
		armbox/e4hdultra_0006-dvb-media-tda18250-support-for-new-silicon-tuner.patch \

#
# KERNEL
#
KERNEL_PATCHES = $(KERNEL_PATCHES_ARM)

$(ARCHIVE)/$(KERNEL_SRC):
	$(DOWNLOAD) $(KERNEL_URL)/$(KERNEL_SRC)

$(D)/kernel.do_prepare: $(ARCHIVE)/$(KERNEL_SRC) $(PATCHES)/armbox/$(KERNEL_CONFIG)
	$(START_BUILD)
	rm -rf $(KERNEL_DIR)
	$(UNTAR)/$(KERNEL_SRC)
	set -e; cd $(KERNEL_DIR); \
		for i in $(KERNEL_PATCHES); do \
			echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $$i"; \
			$(PATCH)/$$i; \
		done
	install -m 644 $(PATCHES)/armbox/$(KERNEL_CONFIG) $(KERNEL_DIR)/.config
ifeq ($(OPTIMIZATIONS), $(filter $(OPTIMIZATIONS), kerneldebug debug))
	@echo "Using kernel debug"
	@grep -v "CONFIG_PRINTK" "$(KERNEL_DIR)/.config" > $(KERNEL_DIR)/.config.tmp
	cp $(KERNEL_DIR)/.config.tmp $(KERNEL_DIR)/.config
	@echo "CONFIG_PRINTK=y" >> $(KERNEL_DIR)/.config
	@echo "CONFIG_PRINTK_TIME=y" >> $(KERNEL_DIR)/.config
endif
	@touch $@

$(D)/kernel.do_compile: $(D)/kernel.do_prepare
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k hd51 h7))
	set -e; cd $(KERNEL_DIR); \
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm oldconfig
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- $(KERNEL_DTB_VER) zImage modules
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- DEPMOD=$(DEPMOD) INSTALL_MOD_PATH=$(TARGET_DIR) modules_install
	@touch $@
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), e4hdultra))
	set -e; cd $(KERNEL_DIR); \
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm oldconfig
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- zImage modules
		$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- DEPMOD=$(DEPMOD) INSTALL_MOD_PATH=$(TARGET_DIR) modules_install
	@touch $@
endif

KERNEL = $(D)/kernel
$(D)/kernel: $(D)/bootstrap $(D)/kernel.do_compile
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k hd51 h7))
	install -m 644 $(KERNEL_DIR)/arch/arm/boot/zImage $(BOOT_DIR)/vmlinux.ub
	install -m 644 $(KERNEL_DIR)/vmlinux $(TARGET_DIR)/boot/vmlinux-arm-$(KERNEL_VER)
	install -m 644 $(KERNEL_DIR)/System.map $(TARGET_DIR)/boot/System.map-arm-$(KERNEL_VER)
	cp $(KERNEL_DIR)/arch/arm/boot/zImage $(TARGET_DIR)/boot/
	cat $(KERNEL_DIR)/arch/arm/boot/zImage $(KERNEL_DIR)/arch/arm/boot/dts/$(KERNEL_DTB_VER) > $(TARGET_DIR)/boot/zImage.dtb
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/build || true
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/source || true
	$(TOUCH)
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), e4hdultra))
	install -m 644 $(KERNEL_DIR)/arch/arm/boot/zImage $(BOOT_DIR)/vmlinux
	install -m 644 $(KERNEL_DIR)/vmlinux $(TARGET_DIR)/boot/vmlinux-arm-$(KERNEL_VER)
	install -m 644 $(KERNEL_DIR)/System.map $(TARGET_DIR)/boot/System.map-arm-$(KERNEL_VER)
	cp $(KERNEL_DIR)/arch/arm/boot/zImage $(TARGET_DIR)/boot/
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/build || true
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/source || true
	$(TOUCH)
endif

kernel-distclean:
	rm -f $(D)/kernel
	rm -f $(D)/kernel.do_compile
	rm -f $(D)/kernel.do_prepare

kernel-clean:
	-$(MAKE) -C $(KERNEL_DIR) clean
	rm -f $(D)/kernel
	rm -f $(D)/kernel.do_compile

#
# Helper
#
kernel.menuconfig kernel.xconfig: \
kernel.%: $(D)/kernel
	$(MAKE) -C $(KERNEL_DIR) ARCH=arm CROSS_COMPILE=$(TARGET)- $*
	@echo ""
	@echo "You have to edit $(PATCHES)/armbox/$(KERNEL_CONFIG) m a n u a l l y to make changes permanent !!!"
	@echo ""
	diff $(KERNEL_DIR)/.config.old $(KERNEL_DIR)/.config
	@echo ""
