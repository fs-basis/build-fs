#
# flashimage
#

mdo \
flashimage:
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), ufs910 ufs922))
	cd $(BASE_DIR)/flash/nor_flash && echo "$(SUDOPASSWD)" | sudo -S ./make_flash.sh $(MAINTAINER)
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), ufs912 ufs913))
	cd $(BASE_DIR)/flash/$(BOXTYPE) && $(SUDOCMD) ./$(BOXTYPE).sh $(MAINTAINER)
endif
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k hd51 h7 e4hdultra))
	$(MAKE) flash-image-$(BOXTYPE)-multi-disk flash-image-$(BOXTYPE)-multi-rootfs
endif
	$(TUXBOX_CUSTOMIZE)

ofg \
ofgimage:
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k hd51 h7 e4hdultra))
	$(MAKE) flash-image-$(BOXTYPE)-multi-rootfs
endif
	$(TUXBOX_CUSTOMIZE)

oi \
online-image:
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k hd51 h7 e4hdultra))
	$(MAKE) flash-image-$(BOXTYPE)-online
endif
	$(TUXBOX_CUSTOMIZE)

disk \
diskimage:
ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k hd51 h7 e4hdultra))
	$(MAKE) flash-image-$(BOXTYPE)-multi-disk flash-image-$(BOXTYPE)-disk-image
endif
	$(TUXBOX_CUSTOMIZE)

flash-clean:
	cd $(BASE_DIR)/flash/nor_flash && $(SUDOCMD) rm -rf ./tmp ./out
	cd $(BASE_DIR)/flash/ufs912 && $(SUDOCMD) rm -rf ./tmp ./out
	cd $(BASE_DIR)/flash/ufs913 && $(SUDOCMD) rm -rf ./tmp ./out
	cd $(RELEASE_IMAGE_DIR) && rm -rf *
	echo ""

# general
IMAGE_BUILD_DIR = $(BUILD_TMP)/image-build

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k hd51 h7 e4hdultra))
### armbox bre2ze4k hd51 h7 e4hdultra
# general
$(BOXTYPE)_IMAGE_NAME = disk
$(BOXTYPE)_BOOT_IMAGE = boot.img
$(BOXTYPE)_IMAGE_LINK = $($(BOXTYPE)_IMAGE_NAME).ext4
$(BOXTYPE)_IMAGE_ROOTFS_SIZE = 294912

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k hd51))
	IMAGEDIR = $(BOXTYPE)
endif
ifeq ($(BOXTYPE), h7)
	IMAGEDIR = zgemma/$(BOXTYPE)
endif
ifeq ($(BOXTYPE), e4hdultra)
	IMAGEDIR = e4hd
endif

# emmc image
ifeq ($(SWAPDATA), $(filter $(SWAPDATA), 80 81 82))
EMMC_IMAGE_SIZE = 7634944
else
EMMC_IMAGE_SIZE = 3817472
endif
EMMC_IMAGE = $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_IMAGE_NAME).img

# partition sizes
BLOCK_SIZE = 512
BLOCK_SECTOR = 2
IMAGE_ROOTFS_ALIGNMENT = 1024
BOOT_PARTITION_SIZE = 1024
KERNEL_PARTITION_OFFSET = $(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \+ $(BOOT_PARTITION_SIZE))
KERNEL_PARTITION_SIZE = 8192
ROOTFS_PARTITION_OFFSET = $(shell expr $(KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))

# partition sizes multi
ifeq ($(SWAPDATA), 0)
ROOTFS_PARTITION_SIZE_MULTI = 945152
endif
ifeq ($(SWAPDATA), 1)
ROOTFS_PARTITION_SIZE_MULTI = 879616
SWAP_DATA_PARTITION_SIZE = 131072
endif
ifeq ($(SWAPDATA), 2)
ROOTFS_PARTITION_SIZE_MULTI = 912384
SWAP_DATA_PARTITION_SIZE = 131072
endif
ifeq ($(SWAPDATA), 80)
ROOTFS_PARTITION_SIZE_MULTI = 1899520
endif
ifeq ($(SWAPDATA), 81)
ROOTFS_PARTITION_SIZE_MULTI = 1506304
SWAP_DATA_PARTITION_SIZE = 786432
endif
ifeq ($(SWAPDATA), 82)
ROOTFS_PARTITION_SIZE_MULTI = 1702912
SWAP_DATA_PARTITION_SIZE = 786432
endif

# partition sizes multi
# without swap data partition 819200
#ROOTFS_PARTITION_SIZE_MULTI = 768000
# 51200 * 4
#SWAP_DATA_PARTITION_SIZE = 204800

SECOND_KERNEL_PARTITION_OFFSET = $(shell expr $(ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
SECOND_ROOTFS_PARTITION_OFFSET = $(shell expr $(SECOND_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))

THIRD_KERNEL_PARTITION_OFFSET = $(shell expr $(SECOND_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
THIRD_ROOTFS_PARTITION_OFFSET = $(shell expr $(THIRD_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))

FOURTH_KERNEL_PARTITION_OFFSET = $(shell expr $(THIRD_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
FOURTH_ROOTFS_PARTITION_OFFSET = $(shell expr $(FOURTH_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))

ifeq ($(SWAPDATA), $(filter $(SWAPDATA), 1 2 81 82))
SWAP_DATA_PARTITION_OFFSET = $(shell expr $(FOURTH_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
SWAP_PARTITION_OFFSET = $(shell expr $(SWAP_DATA_PARTITION_OFFSET) \+ $(SWAP_DATA_PARTITION_SIZE))
endif

flash-image-$(BOXTYPE)-multi-disk: $(D)/host_resize2fs $(D)/host_parted
	rm -rf $(IMAGE_BUILD_DIR)
	mkdir -p $(IMAGE_BUILD_DIR)/$(IMAGEDIR)
	# lcd flashlogo for e4hdultra
	@if [ "$(BOXTYPE)" == "e4hdultra" ]; then \
		cp $(SKEL_ROOT)/release/lcdflashing.bmp $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/; \
	fi
	# move kernel files from $(RELEASE_DIR)/boot to $(IMAGE_BUILD_DIR)
	mv -f $(RELEASE_DIR)/boot/zImage* $(IMAGE_BUILD_DIR)/
	# Create a sparse image block
	dd if=/dev/zero of=$(IMAGE_BUILD_DIR)/$($(BOXTYPE)_IMAGE_LINK) seek=$(shell expr $($(BOXTYPE)_IMAGE_ROOTFS_SIZE) \* $(BLOCK_SECTOR)) count=0 bs=$(BLOCK_SIZE)
	$(HOST_DIR)/bin/mkfs.ext4 -F $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_IMAGE_LINK) -d $(RELEASE_DIR)
	# move kernel files back to $(RELEASE_DIR)/boot
	mv -f $(IMAGE_BUILD_DIR)/zImage* $(RELEASE_DIR)/boot/
	# Error codes 0-3 indicate successfull operation of fsck (no errors or errors corrected)
	$(HOST_DIR)/bin/fsck.ext4 -pvfD $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_IMAGE_LINK) || [ $? -le 3 ]
	dd if=/dev/zero of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) count=0 seek=$(shell expr $(EMMC_IMAGE_SIZE) \* $(BLOCK_SECTOR))
	parted -s $(EMMC_IMAGE) mklabel gpt
	parted -s $(EMMC_IMAGE) unit KiB mkpart boot fat16 $(IMAGE_ROOTFS_ALIGNMENT) $(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \+ $(BOOT_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel1 $(KERNEL_PARTITION_OFFSET) $(shell expr $(KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs1 ext4 $(ROOTFS_PARTITION_OFFSET) $(shell expr $(ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel2 $(SECOND_KERNEL_PARTITION_OFFSET) $(shell expr $(SECOND_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs2 ext4 $(SECOND_ROOTFS_PARTITION_OFFSET) $(shell expr $(SECOND_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel3 $(THIRD_KERNEL_PARTITION_OFFSET) $(shell expr $(THIRD_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs3 ext4 $(THIRD_ROOTFS_PARTITION_OFFSET) $(shell expr $(THIRD_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
	parted -s $(EMMC_IMAGE) unit KiB mkpart kernel4 $(FOURTH_KERNEL_PARTITION_OFFSET) $(shell expr $(FOURTH_KERNEL_PARTITION_OFFSET) \+ $(KERNEL_PARTITION_SIZE))
ifeq ($(SWAPDATA), $(filter $(SWAPDATA), 1 2 81 82))
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs4 ext4 $(FOURTH_ROOTFS_PARTITION_OFFSET) $(shell expr $(FOURTH_ROOTFS_PARTITION_OFFSET) \+ $(ROOTFS_PARTITION_SIZE_MULTI))
ifeq ($(SWAPDATA), $(filter $(SWAPDATA), 2 82))
	parted -s $(EMMC_IMAGE) unit KiB mkpart swap linux-swap $(SWAP_DATA_PARTITION_OFFSET) $(shell expr $(EMMC_IMAGE_SIZE) \- 1024)
else
	parted -s $(EMMC_IMAGE) unit KiB mkpart swap linux-swap $(SWAP_DATA_PARTITION_OFFSET) $(shell expr $(SWAP_DATA_PARTITION_OFFSET) \+ $(SWAP_DATA_PARTITION_SIZE))
	parted -s $(EMMC_IMAGE) unit KiB mkpart swapdata ext4 $(SWAP_PARTITION_OFFSET) $(shell expr $(EMMC_IMAGE_SIZE) \- 1024)
endif
else
	parted -s $(EMMC_IMAGE) unit KiB mkpart rootfs4 ext4 $(FOURTH_ROOTFS_PARTITION_OFFSET) $(shell expr $(EMMC_IMAGE_SIZE) \- 1024)
endif
	dd if=/dev/zero of=$(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) bs=$(BLOCK_SIZE) count=$(shell expr $(BOOT_PARTITION_SIZE) \* $(BLOCK_SECTOR))
	mkfs.msdos -S 512 $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE)
	@if [ "$(BOXTYPE)" == "e4hdultra" ]; then \
		echo "boot emmcflash0.kernel1 'root=/dev/mmcblk0p3 rw rootwait 8100s_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP; \
		echo "boot emmcflash0.kernel1 'root=/dev/mmcblk0p3 rw rootwait 8100s_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP_1; \
		echo "boot emmcflash0.kernel2 'root=/dev/mmcblk0p5 rw rootwait 8100s_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP_2; \
		echo "boot emmcflash0.kernel3 'root=/dev/mmcblk0p7 rw rootwait 8100s_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP_3; \
		echo "boot emmcflash0.kernel4 'root=/dev/mmcblk0p9 rw rootwait 8100s_4.boxmode=5'" > $(IMAGE_BUILD_DIR)/STARTUP_4; \
		cp $(SKEL_ROOT)/release/lcdsplash.bmp $(IMAGE_BUILD_DIR)/; \
	else \
		echo "boot emmcflash0.kernel1 'root=/dev/mmcblk0p3 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(IMAGE_BUILD_DIR)/STARTUP; \
		echo "boot emmcflash0.kernel1 'root=/dev/mmcblk0p3 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(IMAGE_BUILD_DIR)/STARTUP_1; \
		echo "boot emmcflash0.kernel2 'root=/dev/mmcblk0p5 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(IMAGE_BUILD_DIR)/STARTUP_2; \
		echo "boot emmcflash0.kernel3 'root=/dev/mmcblk0p7 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(IMAGE_BUILD_DIR)/STARTUP_3; \
		echo "boot emmcflash0.kernel4 'root=/dev/mmcblk0p9 rw rootwait $(BOXTYPE)_4.boxmode=1'" > $(IMAGE_BUILD_DIR)/STARTUP_4; \
	fi
	mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP ::
	mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_1 ::
	mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_2 ::
	mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_3 ::
	mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/STARTUP_4 ::
	@if [ "$(BOXTYPE)" == "e4hdultra" ]; then \
		mcopy -i $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) -v $(IMAGE_BUILD_DIR)/lcdsplash.bmp ::; \
	fi
	dd conv=notrunc if=$(IMAGE_BUILD_DIR)/$($(BOXTYPE)_BOOT_IMAGE) of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(IMAGE_ROOTFS_ALIGNMENT) \* $(BLOCK_SECTOR))
	@if [ "$(BOXTYPE)" == "e4hdultra" ]; then \
		dd conv=notrunc if=$(RELEASE_DIR)/boot/zImage of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(KERNEL_PARTITION_OFFSET) \* $(BLOCK_SECTOR)); \
	else \
		dd conv=notrunc if=$(RELEASE_DIR)/boot/zImage.dtb of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(KERNEL_PARTITION_OFFSET) \* $(BLOCK_SECTOR)); \
	fi
	$(HOST_DIR)/bin/resize2fs $(IMAGE_BUILD_DIR)/$($(BOXTYPE)_IMAGE_LINK) 131072k
	# Truncate on purpose
	dd if=$(IMAGE_BUILD_DIR)/$($(BOXTYPE)_IMAGE_LINK) of=$(EMMC_IMAGE) bs=$(BLOCK_SIZE) seek=$(shell expr $(ROOTFS_PARTITION_OFFSET) \* $(BLOCK_SECTOR))
	mv $(IMAGE_BUILD_DIR)/disk.img $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/
	cd $(IMAGE_BUILD_DIR)/$(IMAGEDIR); \
	md5sum -b disk.img | awk -F " " '{print $$1}' > disk.img.md5; \

flash-image-$(BOXTYPE)-multi-rootfs:
	# Create final USB-image
	mkdir -p $(IMAGE_BUILD_DIR)/$(IMAGEDIR)
	@if [ "$(BOXTYPE)" == "e4hdultra" ]; then \
		cp $(SKEL_ROOT)/release/lcdflashing.bmp $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/; \
		cp $(RELEASE_DIR)/boot/zImage $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/kernel.bin; \
	else \
		cp $(RELEASE_DIR)/boot/zImage.dtb $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/kernel.bin; \
	fi
	cd $(IMAGE_BUILD_DIR)/$(IMAGEDIR); \
	md5sum -b kernel.bin | awk -F " " '{print $$1}' > kernel.bin.md5; \
	cd $(RELEASE_DIR); \
	tar -cvf $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/rootfs.tar --exclude=zImage* . > /dev/null 2>&1; \
	bzip2 $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/rootfs.tar
	cd $(IMAGE_BUILD_DIR)/$(IMAGEDIR); \
	md5sum -b rootfs.tar.bz2 | awk -F " " '{print $$1}' > rootfs.tar.bz2.md5; \
	echo $(BOXTYPE)_$(FLAVOUR)_multi_usb_$(shell date '+%d%m%Y-%H%M%S') > $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/imageversion
	@if [ "$(BOXTYPE)" == "e4hdultra" ]; then \
		cd $(IMAGE_BUILD_DIR) && \
		zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_multi_usb_$(shell date '+%d.%m.%Y-%H.%M').zip $(IMAGEDIR)/rootfs.tar.bz2 $(IMAGEDIR)/rootfs.tar.bz2.md5 $(IMAGEDIR)/kernel.bin $(IMAGEDIR)/kernel.bin.md5 $(IMAGEDIR)/disk.img $(IMAGEDIR)/disk.img.md5 $(IMAGEDIR)/imageversion $(IMAGEDIR)/lcdflashing.bmp; \
	else \
		cd $(IMAGE_BUILD_DIR) && \
		zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_multi_usb_$(shell date '+%d.%m.%Y-%H.%M').zip $(IMAGEDIR)/rootfs.tar.bz2 $(IMAGEDIR)/rootfs.tar.bz2.md5 $(IMAGEDIR)/kernel.bin $(IMAGEDIR)/kernel.bin.md5 $(IMAGEDIR)/disk.img $(IMAGEDIR)/disk.img.md5 $(IMAGEDIR)/imageversion; \
	fi
	# cleanup
	rm -rf $(IMAGE_BUILD_DIR)

flash-image-$(BOXTYPE)-online:
	# Create final USB-image
	mkdir -p $(IMAGE_BUILD_DIR)/$(BOXTYPE)
	@if [ "$(BOXTYPE)" == "e4hdultra" ]; then \
		cp $(RELEASE_DIR)/boot/zImage $(IMAGE_BUILD_DIR)/$(BOXTYPE)/kernel.bin; \
		cd $(IMAGE_BUILD_DIR)/$(BOXTYPE); \
		md5sum -b kernel.bin | awk -F " " '{print $$1}' > kernel.bin.md5; \
	else \
		cp $(RELEASE_DIR)/boot/zImage.dtb $(IMAGE_BUILD_DIR)/$(BOXTYPE)/kernel.bin; \
		cd $(IMAGE_BUILD_DIR)/$(BOXTYPE); \
		md5sum -b kernel.bin | awk -F " " '{print $$1}' > kernel.bin.md5; \
	fi
	cd $(RELEASE_DIR); \
	tar -cvf $(IMAGE_BUILD_DIR)/$(BOXTYPE)/rootfs.tar --exclude=zImage* . > /dev/null 2>&1; \
	bzip2 $(IMAGE_BUILD_DIR)/$(BOXTYPE)/rootfs.tar
	cd $(IMAGE_BUILD_DIR)/$(BOXTYPE); \
	md5sum -b rootfs.tar.bz2 | awk -F " " '{print $$1}' > rootfs.tar.bz2.md5; \
	echo $(BOXTYPE)_$(FLAVOUR)_flash_$(shell date '+%d%m%Y-%H%M%S') > $(IMAGE_BUILD_DIR)/$(BOXTYPE)/imageversion
	cd $(IMAGE_BUILD_DIR)/$(BOXTYPE) && \
	tar -cvzf $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_multi_usb_$(shell date '+%d.%m.%Y-%H.%M').tgz rootfs.tar.bz2 rootfs.tar.bz2.md5 kernel.bin kernel.bin.md5 imageversion
	# cleanup
	rm -rf $(IMAGE_BUILD_DIR)

# disk image
flash-image-$(BOXTYPE)-disk-image:
	# Create final USB-image
	mkdir -p $(IMAGE_BUILD_DIR)/$(IMAGEDIR)
	cd $(RELEASE_DIR); \
	echo $(BOXTYPE)_$(FLAVOUR)_usb_$(shell date '+%d%m%Y-%H%M%S') > $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/imageversion
	@if [ "$(BOXTYPE)" == "e4hdultra" ]; then \
		cp $(SKEL_ROOT)/release/lcdflashing.bmp $(IMAGE_BUILD_DIR)/$(IMAGEDIR)/; \
		cd $(IMAGE_BUILD_DIR) && \
		zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_multi_disk_img_$(shell date '+%d.%m.%Y-%H.%M').zip $(IMAGEDIR)/disk.img $(IMAGEDIR)/disk.img.md5 $(IMAGEDIR)/imageversion $(IMAGEDIR)/lcdflashing.bmp; \
	else \
		cd $(IMAGE_BUILD_DIR) && \
		zip -r $(RELEASE_IMAGE_DIR)/$(BOXTYPE)_$(FLAVOUR)_multi_disk_img_$(shell date '+%d.%m.%Y-%H.%M').zip $(IMAGEDIR)/disk.img $(IMAGEDIR)/disk.img.md5 $(IMAGEDIR)/imageversion; \
	fi
	# cleanup
	rm -rf $(IMAGE_BUILD_DIR)
endif
