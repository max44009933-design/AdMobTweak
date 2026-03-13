export ARCHS = arm64
export TARGET = iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

TWEAK_NAME = IPA918_AdMobNative
IPA918_AdMobNative_FILES = Tweak.x
IPA918_AdMobNative_CFLAGS = -fobjc-arc -Wno-error

# 🌟 告訴 Mac 去旁邊的 Frameworks 資料夾找 SDK
IPA918_AdMobNative_LDFLAGS += -F./Frameworks

IPA918_AdMobNative_FRAMEWORKS = UIKit Foundation CoreGraphics CoreTelephony SystemConfiguration StoreKit
IPA918_AdMobNative_EXTRA_FRAMEWORKS = GoogleMobileAds UserMessagingPlatform

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk