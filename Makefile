PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)
ARCHS = armv7 armv7s arm64
SDKVERSION = 9.3
SYSROOT = $(THEOS)/sdks/iPhoneOS9.3.sdk
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SmartLowPower
SmartLowPower_FILES = Tweak.xm
SmartLowPower_PRIVATE_FRAMEWORKS = CoreDuet

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += smartlowpowerprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
