################################################################################
#
# libiio
#
################################################################################

LIBIIO_VERSION = 0.16
LIBIIO_SITE = $(call github,analogdevicesinc,libiio,v$(LIBIIO_VERSION))

#LIBIIO_VERSION = 60063cb20312c2f06cb8b33e8692e4a0a3546738
#LIBIIO_SITE = https://github.com/analogdevicesinc/libiio.git
#LIBIIO_SITE_METHOD = git

LIBIIO_INSTALL_STAGING = YES
LIBIIO_LICENSE = LGPL-2.1+
LIBIIO_LICENSE_FILES = COPYING.txt

LIBIIO_CONF_OPTS = -DENABLE_IPV6=ON \
	-DWITH_LOCAL_BACKEND=$(if $(BR2_PACKAGE_LIBIIO_LOCAL_BACKEND),ON,OFF) \
	-DWITH_LOCAL_CONFIG=$(if $(BR2_PACKAGE_LIBIIO_LOCAL_CONFIG),ON,OFF) \
	-DWITH_NETWORK_BACKEND=$(if $(BR2_PACKAGE_LIBIIO_NETWORK_BACKEND),ON,OFF) \
	-DWITH_MATLAB_BINDINGS_API=OFF \
	-DMATLAB_BINDINGS=OFF \
	-DINSTALL_UDEV_RULE=$(if $(BR2_PACKAGE_HAS_UDEV),ON,OFF) \
	-DWITH_TESTS=$(if $(BR2_PACKAGE_LIBIIO_TESTS),ON,OFF) \
	-DWITH_DOC=OFF

#	-DLIBIIO_VERSION_GIT=60063cb \

ifeq ($(BR2_PACKAGE_LIBIIO_LOCAL_BACKEND),y)
LIBIIO_DEPENDENCIES += libini
endif

ifeq ($(BR2_PACKAGE_LIBIIO_XML_BACKEND),y)
LIBIIO_DEPENDENCIES += libxml2
LIBIIO_CONF_OPTS += -DWITH_XML_BACKEND=ON
else
LIBIIO_CONF_OPTS += -DWITH_XML_BACKEND=OFF
endif

ifeq ($(BR2_PACKAGE_LIBIIO_USB_BACKEND),y)
LIBIIO_DEPENDENCIES += libusb
LIBIIO_CONF_OPTS += -DWITH_USB_BACKEND=ON
else
LIBIIO_CONF_OPTS += -DWITH_USB_BACKEND=OFF
endif

ifeq ($(BR2_PACKAGE_LIBIIO_SERIAL_BACKEND),y)
LIBIIO_DEPENDENCIES += libserialport
LIBIIO_CONF_OPTS += -DWITH_SERIAL_BACKEND=ON
else
LIBIIO_CONF_OPTS += -DWITH_SERIAL_BACKEND=OFF
endif

ifeq ($(BR2_PACKAGE_LIBIIO_IIOD),y)
LIBIIO_DEPENDENCIES += host-flex host-bison libaio
LIBIIO_CONF_OPTS += -DWITH_IIOD=ON -DWITH_AIO=ON
else
LIBIIO_CONF_OPTS += -DWITH_IIOD=OFF
endif

ifeq ($(BR2_PACKAGE_LIBIIO_IIOD_USBD),y)
LIBIIO_DEPENDENCIES += libaio
LIBIIO_CONF_OPTS += -DWITH_IIOD_USBD=ON
else
LIBIIO_CONF_OPTS += -DWITH_IIOD_USBD=OFF
endif

# Avahi support in libiio requires avahi-client, which needs avahi-daemon and dbus
ifeq ($(BR2_PACKAGE_AVAHI_DAEMON)$(BR2_PACKAGE_DBUS),yy)
LIBIIO_DEPENDENCIES += avahi
endif

ifeq ($(BR2_PACKAGE_LIBIIO_BINDINGS_PYTHON),y)
ifeq ($(BR2_PACKAGE_PYTHON),y)
LIBIIO_DEPENDENCIES += python
else ifeq ($(BR2_PACKAGE_PYTHON3),y)
LIBIIO_DEPENDENCIES += python3
endif
LIBIIO_CONF_OPTS += -DPYTHON_BINDINGS=ON
else
LIBIIO_CONF_OPTS += -DPYTHON_BINDINGS=OFF
endif

ifeq ($(BR2_PACKAGE_LIBIIO_BINDINGS_CSHARP),y)
define LIBIIO_INSTALL_CSHARP_BINDINGS_TO_TARGET
	rm $(TARGET_DIR)/usr/lib/cli/libiio-sharp-$(LIBIIO_VERSION)/libiio-sharp.dll.mdb
	$(HOST_DIR)/bin/gacutil -root $(TARGET_DIR)/usr/lib -i \
		$(TARGET_DIR)/usr/lib/cli/libiio-sharp-$(LIBIIO_VERSION)/libiio-sharp.dll
endef
define LIBIIO_INSTALL_CSHARP_BINDINGS_TO_STAGING
	$(HOST_DIR)/bin/gacutil -root $(STAGING_DIR)/usr/lib -i \
		$(STAGING_DIR)/usr/lib/cli/libiio-sharp-$(LIBIIO_VERSION)/libiio-sharp.dll
endef
LIBIIO_POST_INSTALL_TARGET_HOOKS += LIBIIO_INSTALL_CSHARP_BINDINGS_TO_TARGET
LIBIIO_POST_INSTALL_STAGING_HOOKS += LIBIIO_INSTALL_CSHARP_BINDINGS_TO_STAGING
LIBIIO_DEPENDENCIES += mono
LIBIIO_CONF_OPTS += -DCSHARP_BINDINGS=ON
else
LIBIIO_CONF_OPTS += -DCSHARP_BINDINGS=OFF
endif

ifeq ($(BR2_PACKAGE_LIBIIO_IIOD),y)
define LIBIIO_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 package/libiio/S99iiod \
		$(TARGET_DIR)/etc/init.d/S99iiod
endef
endif

$(eval $(cmake-package))
