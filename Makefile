TARGET = :clang
ARCHS = armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = ScreenFade
ScreenFade_FILES = ScreenFade.xm
ScreenFade_FRAMEWORKS = UIKit 

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += SFPreferences
include $(THEOS_MAKE_PATH)/aggregate.mk