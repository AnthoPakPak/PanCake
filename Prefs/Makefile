ifeq ($(FINALPACKAGE),1)
	ARCHS = arm64 arm64e
else
	ARCHS = arm64
endif
TARGET = iphone:clang:11.2:11.0 #12.2 my Xcode SDK, 11.0 my iOS target

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PanCakePrefs
$(BUNDLE_NAME)_FILES = Preferences.m
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_FRAMEWORKS = UIKit
$(BUNDLE_NAME)_LIBRARIES = applist
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences
$(BUNDLE_NAME)_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

before-all::
	chmod 644 ./Resources/*.png

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(BUNDLE_NAME).plist$(ECHO_END)