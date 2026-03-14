export ARCHS = arm64
export TARGET = iphone:clang:latest:14.0

TWEAK_NAME = IPA918_AdMobNative
IPA918_AdMobNative_FILES = Tweak.x

IPA918_AdMobNative_CFLAGS = -fobjc-arc -I$(THEOS_PROJECT_DIR)/include
IPA918_AdMobNative_LDFLAGS = -F$(THEOS_PROJECT_DIR)/Frameworks

# 🌟 關鍵修改：移除了 GoogleAppMeasurement
IPA918_AdMobNative_FRAMEWORKS = UIKit Foundation GoogleMobileAds UserMessagingPlatform

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
