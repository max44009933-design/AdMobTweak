export ARCHS = arm64
export TARGET = iphone:clang:latest:14.0

TWEAK_NAME = IPA918_AdMobNative

IPA918_AdMobNative_FILES = Tweak.x

# 🌟 關鍵：強制讓編譯器去找我們剛才建立的 include 目錄
IPA918_AdMobNative_CFLAGS = -fobjc-arc -I$(THEOS_PROJECT_DIR)/include
IPA918_AdMobNative_LDFLAGS = -F$(THEOS_PROJECT_DIR)/Frameworks

IPA918_AdMobNative_FRAMEWORKS = UIKit Foundation GoogleMobileAds UserMessagingPlatform

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
