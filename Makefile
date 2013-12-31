TARGET = :clang

include theos/makefiles/common.mk

TWEAK_NAME = ScreenFade
ScreenFade_FILES = Tweak.xm
ScreenFade_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
