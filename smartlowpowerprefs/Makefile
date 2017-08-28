include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SmartLowPowerPrefs
SmartLowPowerPrefs_FILES = $(wildcard *.m)
SmartLowPowerPrefs_INSTALL_PATH = /Library/PreferenceBundles
SmartLowPowerPrefs_FRAMEWORKS = CoreGraphics UIKit
SmartLowPowerPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SmartLowPowerPrefs.plist$(ECHO_END)
