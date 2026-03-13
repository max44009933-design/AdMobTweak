export ARCHS = arm64
export TARGET = iphone:clang:latest:14.0

TWEAK_NAME = IPA918_AdMobNative
IPA918_AdMobNative_FILES = Tweak.x

# 🌟 關鍵路徑設定：-I 指向 include 資料夾，-F 指向 Frameworks 資料夾
IPA918_AdMobNative_CFLAGS = -fobjc-arc -I$(THEOS_PROJECT_DIR)/include
IPA918_AdMobNative_LDFLAGS = -F$(THEOS_PROJECT_DIR)/Frameworks

# 指定框架
IPA918_AdMobNative_FRAMEWORKS = UIKit Foundation GoogleMobileAds UserMessagingPlatform GoogleAppMeasurement

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
