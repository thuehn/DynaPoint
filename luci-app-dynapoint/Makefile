#
# Copyright (C) 2016 LEDE project (Tobias Ilte)
#
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-dynapoint
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Tobias Ilte <tobias.ilte@campus.tu-berlin.de>
PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
    SECTION:=LuCI
    CATEGORY:=LuCI
    SUBMENU:=3. Applications
    TITLE:=LuCI Support for DynaPoint
    DEPENDS:=+lua +luci-base +dynapoint
    MAINTAINER:=Tobias Ilte <tobias.ilte@campus.tu-berlin.de>
    PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
Makes access point ssids dependable on certain network conditions.
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./root/etc/uci-defaults/40_luci-dynapoint $(1)/etc/uci-defaults/40_luci-dynapoint
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/dynapoint
	$(INSTALL_DATA) ./luasrc/model/cbi/dynapoint.lua $(1)/usr/lib/lua/luci/model/cbi/dynapoint/dynapoint.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/dynapoint.lua $(1)/usr/lib/lua/luci/controller/dynapoint.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/dynapoint
	$(INSTALL_DATA) ./luasrc/view/dynapoint/cbi_checkbox.htm $(1)/usr/lib/lua/luci/view/dynapoint/cbi_checkbox.htm
	$(INSTALL_DATA) ./luasrc/view/dynapoint/cbi_color.htm $(1)/usr/lib/lua/luci/view/dynapoint/cbi_color.htm
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
