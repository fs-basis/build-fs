#
# makefile to build kernel sh4
#

#
# Patches Kernel 24
#
COMMON_PATCHES_24 = \
		linux-sh4-makefile_stm24.patch \
		linux-stm-gpio-fix-build-CONFIG_BUG.patch \
		linux-kbuild-generate-modules-builtin_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-linuxdvb_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-sound_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-time_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-init_mm_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-copro_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-strcpy_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-ext23_as_ext4_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-bpa2_procfs_stm24_$(KERNEL_LABEL).patch \
		linux-ftdi_sio.c_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-lzma-fix_stm24_$(KERNEL_LABEL).patch \
		linux-tune_stm24.patch \
		linux-net_stm24.patch \
		linux-sh4-permit_gcc_command_line_sections_stm24.patch \
		linux-sh4-mmap_stm24.patch \
		linux-defined_is_deprecated_timeconst.pl_stm24_$(KERNEL_LABEL).patch \
		linux-patch_swap_notify_core_support_stm24_$(KERNEL_LABEL).patch

UFS910_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-stx7100_fdma_fix_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-sata_32bit_fix_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-sata_stx7100_B4Team_fix_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-ufs910_setup_stm24_$(KERNEL_LABEL).patch \
		linux-usbwait123_stm24.patch \
		linux-sh4-ufs910_reboot_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-smsc911x_dma_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-i2c-st40-pio_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-pcm_noise_fix_stm24_$(KERNEL_LABEL).patch

UFS912_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-ufs912_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-stmmac_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-lmb_stm24_$(KERNEL_LABEL).patch

UFS913_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-ufs913_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-lmb_stm24_$(KERNEL_LABEL).patch

UFS922_PATCHES_24 = $(COMMON_PATCHES_24) \
		linux-sh4-ufs922_setup_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-stmmac_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-i2c-st40-pio_stm24_$(KERNEL_LABEL).patch \
		linux-sh4-fortis_hdbox_i2c_st40_stm24_$(KERNEL_LABEL).patch

#
# KERNEL
#
KERNEL_PATCHES = $(KERNEL_PATCHES_24)
KERNEL_CONFIG = linux-sh4-$(subst _stm24_,_,$(KERNEL_VER))_$(BOXTYPE).config

$(D)/kernel.do_prepare: $(PATCHES)/$(BUILD_CONFIG)/$(KERNEL_CONFIG) \
	$(if $(KERNEL_PATCHES),$(KERNEL_PATCHES:%=$(PATCHES)/$(BUILD_CONFIG)/%))
	$(START_BUILD)
	rm -rf $(KERNEL_DIR)
	REPO=https://github.com/Duckbox-Developers/linux-sh4-2.6.32.71.git;protocol=https;branch=stmicro; \
	[ -d "$(ARCHIVE)/linux-sh4-2.6.32.71.git" ] && \
	(echo "Updating STlinux kernel source"; cd $(ARCHIVE)/linux-sh4-2.6.32.71.git; git pull || true;); \
	[ -d "$(ARCHIVE)/linux-sh4-2.6.32.71.git" ] || \
	(echo "Getting STlinux kernel source"; git clone -n $$REPO $(ARCHIVE)/linux-sh4-2.6.32.71.git); \
	(echo "Copying kernel source code to build environment"; cp -ra $(ARCHIVE)/linux-sh4-2.6.32.71.git $(KERNEL_DIR)); \
	(echo "Applying patch level P$(KERNEL_LABEL)"; cd $(KERNEL_DIR); git checkout -q $(KERNEL_REVISION))
	set -e; cd $(KERNEL_DIR); \
		for i in $(KERNEL_PATCHES); do \
			echo -e "==> $(TERM_RED)Applying Patch:$(TERM_NORMAL) $$i"; \
			$(PATCH)/$(BUILD_CONFIG)/$$i; \
		done
	install -m 644 $(PATCHES)/$(BUILD_CONFIG)/$(KERNEL_CONFIG) $(KERNEL_DIR)/.config
	sed -i "s#^\(CONFIG_EXTRA_FIRMWARE_DIR=\).*#\1\"$(BASE_DIR)/integrated_firmware\"#" $(KERNEL_DIR)/.config
	-rm $(KERNEL_DIR)/localversion*
	echo "$(KERNEL_STM_LABEL)" > $(KERNEL_DIR)/localversion-stm
ifeq ($(OPTIMIZATIONS), $(filter $(OPTIMIZATIONS), kerneldebug debug))
	@echo "Configuring kernel for debug."
	@grep -v "CONFIG_PRINTK" "$(KERNEL_DIR)/.config" > $(KERNEL_DIR)/.config.tmp
	cp $(KERNEL_DIR)/.config.tmp $(KERNEL_DIR)/.config
	@echo "CONFIG_PRINTK=y" >> $(KERNEL_DIR)/.config
	@echo "CONFIG_PRINTK_TIME=y" >> $(KERNEL_DIR)/.config
endif
	@touch $@

$(D)/kernel.do_compile: $(D)/kernel.do_prepare
	set -e; cd $(KERNEL_DIR); \
		$(MAKE) -C $(KERNEL_DIR) ARCH=sh oldconfig
		$(MAKE) -C $(KERNEL_DIR) ARCH=sh include/asm
		$(MAKE) -C $(KERNEL_DIR) ARCH=sh include/linux/version.h
		$(MAKE) -C $(KERNEL_DIR) ARCH=sh CROSS_COMPILE=$(TARGET)- uImage modules
		$(MAKE) -C $(KERNEL_DIR) ARCH=sh CROSS_COMPILE=$(TARGET)- DEPMOD=$(DEPMOD) INSTALL_MOD_PATH=$(TARGET_DIR) modules_install
	@touch $@

KERNEL = $(D)/kernel
$(D)/kernel: $(D)/bootstrap host_u_boot_tools $(D)/kernel.do_compile
	install -m 644 $(KERNEL_DIR)/arch/sh/boot/uImage $(BOOT_DIR)/vmlinux.ub
	install -m 644 $(KERNEL_DIR)/vmlinux $(TARGET_DIR)/boot/vmlinux-sh4-$(KERNEL_VER)
	install -m 644 $(KERNEL_DIR)/System.map $(TARGET_DIR)/boot/System.map-sh4-$(KERNEL_VER)
	cp $(KERNEL_DIR)/arch/sh/boot/uImage $(TARGET_DIR)/boot/
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/build || true
	rm $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/source || true
	$(TOUCH)

kernel-distclean:
	rm -f $(D)/kernel
	rm -f $(D)/kernel.do_compile
	rm -f $(D)/kernel.do_prepare

kernel-clean:
	-$(MAKE) -C $(KERNEL_DIR) clean
	rm -f $(D)/kernel
	rm -f $(D)/kernel.do_compile

#
# u-boot
#
UBOOT_VER = 1.3.1
UBOOT_PATCH  =  u-boot-$(UBOOT_VER).patch

$(ARCHIVE)/u-boot-$(UBOOT_VER).tar.bz2:
	$(DOWNLOAD) ftp://ftp.denx.de/pub/u-boot/u-boot-$(UBOOT_VER).tar.bz2

$(D)/uboot: $(D)/bootstrap $(ARCHIVE)/u-boot-$(UBOOT_VER).tar.bz2
	$(START_BUILD)
	$(REMOVE)/u-boot-$(UBOOT_VER)
	$(UNTAR)/u-boot-$(UBOOT_VER).tar.bz2
	set -e; cd $(BUILD_TMP)/u-boot-$(UBOOT_VER); \
		$(call apply_patches,$(UBOOT_PATCH)); \
		$(MAKE) $(BOXTYPE)_config; \
		$(MAKE)
#	$(REMOVE)/u-boot-$(UBOOT_VER)
	$(TOUCH)

#
# Helper
#
kernel.menuconfig kernel.xconfig: \
kernel.%: $(D)/kernel
	$(MAKE) -C $(KERNEL_DIR) ARCH=sh CROSS_COMPILE=$(TARGET)- $*
	@echo ""
	@echo "You have to edit $(PATCHES)/$(BUILD_CONFIG)/$(KERNEL_CONFIG) m a n u a l l y to make changes permanent !!!"
	@echo ""
	diff $(KERNEL_DIR)/.config.old $(KERNEL_DIR)/.config
	@echo ""
