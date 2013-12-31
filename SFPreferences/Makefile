TARGET = :clang
ARCHS = armv7 arm64
include theos/makefiles/common.mk

BUNDLE_NAME = SFPreferences
SFPreferences_FILES = SFPreferences.xm
SFPreferences_INSTALL_PATH = /Library/PreferenceBundles
SFPreferences_FRAMEWORKS = UIKit Twitter
SFPreferences_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SFPreferences.plist$(ECHO_END)
