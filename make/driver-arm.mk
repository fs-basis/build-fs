#
# driver
#
ifeq ($(BOXTYPE), bre2ze4k)
DRIVER_DATE = 20191120
DRIVER_VER = 4.10.12-$(DRIVER_DATE)
DRIVER_SRC = bre2ze4k-drivers-$(DRIVER_VER).zip
#DRIVER_URL = http://source.mynonpublic.com/gfutures
DRIVER_URL = $(GITHUB)/$(GIT_NAME)/driver-arm/raw/refs/heads/master/driver/$(BOXTYPE)

$(ARCHIVE)/$(DRIVER_SRC):
	$(DOWNLOAD) $(DRIVER_URL)/$(DRIVER_SRC)
endif

ifeq ($(BOXTYPE), hd51)
#DRIVER_DATE = 20180424
#DRIVER_DATE = 20191031
#DRIVER_DATE = 20191101
DRIVER_DATE = 20191120
DRIVER_VER = 4.10.12-$(DRIVER_DATE)
DRIVER_SRC = hd51-drivers-$(DRIVER_VER).zip
#DRIVER_URL = http://source.mynonpublic.com/gfutures
DRIVER_URL = $(GITHUB)/$(GIT_NAME)/driver-arm/raw/refs/heads/master/driver/$(BOXTYPE)

$(ARCHIVE)/$(DRIVER_SRC):
	$(DOWNLOAD) $(DRIVER_URL)/$(DRIVER_SRC)
endif

ifeq ($(BOXTYPE), h7)
#DRIVER_DATE = 20190405
#DRIVER_DATE = 20191110
DRIVER_DATE = 20191123
DRIVER_VER = 4.10.12-$(DRIVER_DATE)
DRIVER_SRC = h7-drivers-$(DRIVER_VER).zip
#DRIVER_URL = http://source.mynonpublic.com/zgemma
DRIVER_URL = $(GITHUB)/$(GIT_NAME)/driver-arm/raw/refs/heads/master/driver/$(BOXTYPE)

$(ARCHIVE)/$(DRIVER_SRC):
	$(DOWNLOAD) $(DRIVER_URL)/$(DRIVER_SRC)
endif

ifeq ($(BOXTYPE), e4hdultra)
DRIVER_DATE = 20191101
DRIVER_VER = 4.10.12-$(DRIVER_DATE)
DRIVER_SRC = e4hd-drivers-$(DRIVER_VER).zip
#DRIVER_URL = http://source.mynonpublic.com/ceryon
DRIVER_URL = $(GITHUB)/$(GIT_NAME)/driver-arm/raw/refs/heads/master/driver/$(BOXTYPE)

$(ARCHIVE)/$(DRIVER_SRC):
	$(DOWNLOAD) $(DRIVER_URL)/$(DRIVER_SRC)
endif

driver-clean:
	rm -f $(D)/driver $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra/$(KERNEL_TYPE)*

ifeq ($(BOXTYPE), $(filter $(BOXTYPE), bre2ze4k hd51 h7 e4hdultra))
driver: $(D)/driver
$(D)/driver: $(ARCHIVE)/$(DRIVER_SRC) $(D)/bootstrap $(D)/kernel
	$(START_BUILD)
	install -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	unzip -o $(ARCHIVE)/$(DRIVER_SRC) -d $(TARGET_DIR)/lib/modules/$(KERNEL_VER)/extra
	$(TOUCH)
endif
