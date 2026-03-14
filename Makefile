export ARCHS = arm64
export TARGET = iphone:clang:latest:14.0

TWEAK_NAME = IPA918_AdMobNative
# 🌟 關鍵 1：加入 Dummy.swift，強迫編譯器掛載 Swift 運行環境
IPA918_AdMobNative_FILES = Tweak.x Dummy.swift

# 🌟 關鍵 2：加入 -lc++ 來掛載 C++ 標準庫，並指定 Swift 路徑
IPA918_AdMobNative_CFLAGS = -fobjc-arc -I$(THEOS_PROJECT_DIR)/include
IPA918_AdMobNative_LDFLAGS = -F$(THEOS_PROJECT_DIR)/Frameworks -lc++ -rpath /usr/lib/swift

IPA918_AdMobNative_FRAMEWORKS = UIKit Foundation GoogleMobileAds UserMessagingPlatform

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
