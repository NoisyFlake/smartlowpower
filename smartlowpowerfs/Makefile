ARCHS = armv7 armv7s arm64
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SmartLowPowerFS
SmartLowPowerFS_FILES = Switch.xm
SmartLowPowerFS_FRAMEWORKS = UIKit
SmartLowPowerFS_PRIVATE_FRAMEWORKS = CoreDuet
SmartLowPowerFS_LIBRARIES = flipswitch
SmartLowPowerFS_INSTALL_PATH = /Library/Switches

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)if [ -f Preferences.plist ]; then mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SmartLowPowerFS; cp Preferences.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SmartLowPowerFS/; fi$(ECHO_END)

after-install::
	install.exec "killall -9 SpringBoard"
