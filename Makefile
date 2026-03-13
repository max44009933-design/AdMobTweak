export ARCHS = arm64
export TARGET = iphone:clang:latest:14.0

TWEAK_NAME = IPA918_AdMobNative
IPA918_AdMobNative_FILES = Tweak.x

# 🌟 關鍵修正：-I 指向 include (標頭檔)，-F 指向 Frameworks (庫檔案)
IPA918_AdMobNative_CFLAGS = -fobjc-arc -I$(PWD)/include
IPA918_AdMobNative_LDFLAGS = -F$(PWD)/Frameworks

# 指定要連結的框架
IPA918_AdMobNative_FRAMEWORKS = UIKit Foundation GoogleMobileAds UserMessagingPlatform

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
