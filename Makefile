include $(TOPDIR)/rules.mk

PKG_NAME:=dynapoint
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Tobias Ilte <tobias.ilte@campus.tu-berlin.de>
PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/dynapoint
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+libubus +libuci +pingcheck
	MAINTAINER:=Tobias Ilte <tobias.ilte@campus.tu-berlin.de>
	TITLE:=Dynamic access point validator and creator
	MENU:=1
endef

define Package/dynapoint/description
Makes access point ssids dependable on certain network conditions.
endef

define Package/dynapoint/conffiles
/etc/config/dynapoint
endef

define Build/Compile
	true
endef

define Package/dynapoint/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./src/dynapoint.lua $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./src/dynapoint.init $(1)/etc/init.d/dynapoint
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./src/dynapoint.config $(1)/etc/config/dynapoint
	mkdir -p $(1)/etc/pingcheck/offline.d
	mkdir -p $(1)/etc/pingcheck/online.d
	$(CP) ./src/pingcheck_offline $(1)/etc/pingcheck/offline.d/dynapoint_offline
	$(CP) ./src/pingcheck_online $(1)/etc/pingcheck/online.d/dynapoint_online
	
endef

$(eval $(call BuildPackage,dynapoint))