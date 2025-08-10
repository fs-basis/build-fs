########################################################################
#
# Makefile to build FS NEUTRINO-PLUGINS
#
########################################################################
#
NEUTRINO_PLUGINS  = $(D)/neutrino-plugin
NEUTRINO_PLUGINS += $(LOCAL_NEUTRINO_PLUGINS)
NMPP_PATCHES  = $(NEUTRINO_PLUGINS_PATCHES)

NP_OBJDIR = $(BUILD_TMP)/neutrino-plugins

ifeq ($(BOXARCH), sh4)
EXTRA_CPPFLAGS_MP_PLUGINS = -DMARTII
endif

$(D)/neutrino-plugin.do_prepare:
	$(START_BUILD)
	rm -rf $(SOURCE_DIR)/neutrino-plugins
	rm -rf $(SOURCE_DIR)/neutrino-plugins.org
	set -e; if [ -d $(ARCHIVE)/plugins.git ]; \
		then cd $(ARCHIVE)/plugins.git; git pull || true; \
		else cd $(ARCHIVE); git clone https://github.com/fs-basis/plugins.git plugins.git; \
		fi
	cp -ra $(ARCHIVE)/plugins.git $(SOURCE_DIR)/neutrino-plugins
ifeq ($(BOXARCH), $(filter $(BOXARCH), arm))
	sed -i -e 's#getrc fx2#getrc#g' $(SOURCE_DIR)/neutrino-plugins/Makefile.am
endif
	cp -ra $(SOURCE_DIR)/neutrino-plugins $(SOURCE_DIR)/neutrino-plugins.org
	set -e; cd $(SOURCE_DIR)/neutrino-plugins; \
		$(call apply_patches, $(NMPP_PATCHES))
	@touch $@

$(D)/neutrino-plugin.config.status: $(D)/bootstrap
	rm -rf $(NP_OBJDIR); \
	test -d $(NP_OBJDIR) || mkdir -p $(NP_OBJDIR); \
	cd $(NP_OBJDIR); \
		$(SOURCE_DIR)/neutrino-plugins/autogen.sh $(SILENT_OPT) && automake --add-missing $(SILENT_OPT); \
		$(BUILDENV) \
		$(SOURCE_DIR)/neutrino-plugins/configure $(SILENT_OPT) \
			--host=$(TARGET) \
			--build=$(BUILD) \
			--prefix= \
			--enable-silent-rules \
			--with-target=cdk \
			--include=/usr/include \
			--enable-maintainer-mode \
			--with-boxtype=$(BOXTYPE) \
			--with-plugindir=/var/tuxbox/plugins \
			--with-libdir=/usr/lib \
			--with-datadir=/usr/share/tuxbox \
			--with-fontdir=/usr/share/fonts \
			PKG_CONFIG=$(PKG_CONFIG) \
			PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
			CPPFLAGS="$(N_CPPFLAGS) $(EXTRA_CPPFLAGS_MP_PLUGINS) -DNEW_LIBCURL" \
			LDFLAGS="$(TARGET_LDFLAGS) -L$(NP_OBJDIR)/fx2/lib/.libs"
	@touch $@

$(D)/neutrino-plugin.do_compile: $(D)/neutrino-plugin.config.status
	$(MAKE) -C $(NP_OBJDIR) DESTDIR=$(TARGET_DIR)
	@touch $@

$(D)/neutrino-plugin: $(D)/neutrino-plugin.do_prepare $(D)/neutrino-plugin.do_compile
	$(MAKE) -C $(NP_OBJDIR) install DESTDIR=$(TARGET_DIR)
	$(TOUCH)

neutrino-plugin-clean:
	rm -f $(D)/neutrino-plugins
	rm -f $(D)/neutrino-plugin
	rm -f $(D)/neutrino-plugin.config.status
	cd $(NP_OBJDIR); \
		$(MAKE) -C $(NP_OBJDIR) clean

neutrino-plugin-distclean:
	rm -rf $(NP_OBJDIR)
	rm -f $(D)/neutrino-plugin*

#
# bestbitrate
#
$(D)/bestbitrate:
	$(START_BUILD)
	$(REMOVE)/plugins-lua
	set -e; if [ -d $(ARCHIVE)/plugins-lua.git ]; \
		then cd $(ARCHIVE)/plugins-lua.git; git pull || true; \
		else cd $(ARCHIVE); git clone https://github.com/fs-basis/plugins-lua.git plugins-lua.git; \
		fi
	cp -ra $(ARCHIVE)/plugins-lua.git $(BUILD_TMP)/plugins-lua
	install -d $(TARGET_DIR)/var/tuxbox/webscripts
	$(CHDIR)/plugins-lua; \
		install -d $(TARGET_DIR)/var/tuxbox/webscripts
		cp -R $(BUILD_TMP)/plugins-lua/bestbitrate/* $(TARGET_DIR)/var/tuxbox/webscripts/
	$(REMOVE)/plugins-lua
	$(TOUCH)

#
# annie's settingsupdater
#
$(D)/neutrino-plugin-settings-update:
	$(START_BUILD)
	$(REMOVE)/settings-update
	set -e; if [ -d $(ARCHIVE)/settings-update.git ]; \
		then cd $(ARCHIVE)/settings-update.git; git pull || true; \
		else cd $(ARCHIVE); git clone https://github.com/horsti58/lua-data.git settings-update.git; \
		fi
	cp -ra $(ARCHIVE)/settings-update.git $(BUILD_TMP)/settings-update
	cp -R $(BUILD_TMP)/settings-update/lua/* $(TARGET_DIR)/var/tuxbox/plugins/
	$(REMOVE)/settings-update
	$(TOUCH)

#
# mediathek
#
$(D)/mediathek:
	$(START_BUILD)
	$(REMOVE)/plugins-lua
	set -e; if [ -d $(ARCHIVE)/plugins-lua.git ]; \
		then cd $(ARCHIVE)/plugins-lua.git; git pull || true; \
		else cd $(ARCHIVE); git clone https://github.com/fs-basis/plugins-lua.git plugins-lua.git; \
		fi
	cp -ra $(ARCHIVE)/plugins-lua.git $(BUILD_TMP)/plugins-lua
	install -d $(TARGET_DIR)/var/tuxbox/plugins
	$(CHDIR)/plugins-lua; \
		install -d $(TARGET_DIR)/var/tuxbox/plugins
		cp -R $(BUILD_TMP)/plugins-lua/mediathek/* $(TARGET_DIR)/var/tuxbox/plugins/
		rm -f $(TARGET_DIR)/var/tuxbox/plugins/neutrino-mediathek/livestream.lua
	$(REMOVE)/plugins-lua
	$(TOUCH)

#
# mtv
#
$(D)/mtv:
	$(START_BUILD)
	$(REMOVE)/plugins-lua
	set -e; if [ -d $(ARCHIVE)/plugins-lua.git ]; \
		then cd $(ARCHIVE)/plugins-lua.git; git pull || true; \
		else cd $(ARCHIVE); git clone https://github.com/fs-basis/plugins-lua.git plugins-lua.git; \
		fi
	cp -ra $(ARCHIVE)/plugins-lua.git $(BUILD_TMP)/plugins-lua
	install -d $(TARGET_DIR)/var/tuxbox/plugins
	$(CHDIR)/plugins-lua; \
		install -d $(TARGET_DIR)/var/tuxbox/plugins
		cp -R $(BUILD_TMP)/plugins-lua/mtv/* $(TARGET_DIR)/var/tuxbox/plugins/
	$(REMOVE)/plugins-lua
	$(TOUCH)

#
# n24
#
$(D)/n24: $(D)/bootstrap
	$(START_BUILD)
	$(REMOVE)/plugins-lua
	set -e; if [ -d $(ARCHIVE)/plugins-lua.git ]; \
		then cd $(ARCHIVE)/plugins-lua.git; git pull || true; \
		else cd $(ARCHIVE); git clone https://github.com/fs-basis/plugins-lua.git plugins-lua.git; \
		fi
	cp -ra $(ARCHIVE)/plugins-lua.git $(BUILD_TMP)/plugins-lua
	$(CHDIR)/plugins-lua; \
		install -d $(TARGET_DIR)/var/tuxbox/plugins
		cp -R $(BUILD_TMP)/plugins-lua/n24/* $(TARGET_DIR)/var/tuxbox/plugins/
		rm -rf $(TARGET_DIR)/var/tuxbox/plugins//N24\ DOKU.png
	$(REMOVE)/plugins-lua
	$(TOUCH)

#
# netzkino
#
$(D)/netzkino: $(D)/bootstrap
	$(START_BUILD)
	$(REMOVE)/plugins-lua
	set -e; if [ -d $(ARCHIVE)/plugins-lua.git ]; \
		then cd $(ARCHIVE)/plugins-lua.git; git pull || true; \
		else cd $(ARCHIVE); git clone https://github.com/fs-basis/plugins-lua.git plugins-lua.git; \
		fi
	cp -ra $(ARCHIVE)/plugins-lua.git $(BUILD_TMP)/plugins-lua
	$(CHDIR)/plugins-lua; \
		install -d $(TARGET_DIR)/var/tuxbox/plugins
		cp -R $(BUILD_TMP)/plugins-lua/netzkino/* $(TARGET_DIR)/var/tuxbox/plugins/
	$(REMOVE)/plugins-lua
	$(TOUCH)

#
# spiegel
#
$(D)/spiegel:
	$(START_BUILD)
	$(REMOVE)/plugins-lua
	set -e; if [ -d $(ARCHIVE)/plugins-lua.git ]; \
		then cd $(ARCHIVE)/plugins-lua.git; git pull || true; \
		else cd $(ARCHIVE); git clone https://github.com/fs-basis/plugins-lua.git plugins-lua.git; \
		fi
	cp -ra $(ARCHIVE)/plugins-lua.git $(BUILD_TMP)/plugins-lua
	$(CHDIR)/plugins-lua; \
		install -d $(TARGET_DIR)/var/tuxbox/plugins
		cp -R $(BUILD_TMP)/plugins-lua/spiegel/* $(TARGET_DIR)/var/tuxbox/plugins/
		rm -rf $(TARGET_DIR)/var/tuxbox/plugins/SpiegelTV.png
	$(REMOVE)/plugins-lua
	$(TOUCH)

#
# tierwelt
#
$(D)/tierwelt:
	$(START_BUILD)
	$(REMOVE)/plugins-lua
	set -e; if [ -d $(ARCHIVE)/plugins-lua.git ]; \
		then cd $(ARCHIVE)/plugins-lua.git; git pull || true; \
		else cd $(ARCHIVE); git clone https://github.com/fs-basis/plugins-lua.git plugins-lua.git; \
		fi
	cp -ra $(ARCHIVE)/plugins-lua.git $(BUILD_TMP)/plugins-lua
	$(CHDIR)/plugins-lua; \
		install -d $(TARGET_DIR)/var/tuxbox/plugins
		cp -R $(BUILD_TMP)/plugins-lua/tierwelt/* $(TARGET_DIR)/var/tuxbox/plugins/
		rm -rf $(TARGET_DIR)/var/tuxbox/plugins/Tierwelt\ TV.png
	$(REMOVE)/plugins-lua
	$(TOUCH)
# END FS PLUGINS
