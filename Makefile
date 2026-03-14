export ARCHS = arm64
export TARGET = iphone:clang:latest:14.0

TWEAK_NAME = IPA918_AdMobNative
IPA918_AdMobNative_FILES = Tweak.x Dummy.swift

IPA918_AdMobNative_CFLAGS = -fobjc-arc -I$(THEOS_PROJECT_DIR)/include
IPA918_AdMobNative_LDFLAGS = -F$(THEOS_PROJECT_DIR)/Frameworks -lc++ -rpath /usr/lib/swift

# 🌟 關鍵補強：除了 AdMob，還要加入它所依賴的 Apple 官方底層框架
IPA918_AdMobNative_FRAMEWORKS = UIKit Foundation GoogleMobileAds UserMessagingPlatform JavaScriptCore WebKit AVFoundation StoreKit SystemConfiguration AdSupport

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
