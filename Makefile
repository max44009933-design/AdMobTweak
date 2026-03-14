export ARCHS = arm64
export TARGET = iphone:clang:latest:14.0

# 名字我幫你改成 StartApp 專屬了
TWEAK_NAME = IPA918_StartAppNative
IPA918_StartAppNative_FILES = Tweak.x Dummy.swift

IPA918_StartAppNative_CFLAGS = -fobjc-arc -I$(THEOS_PROJECT_DIR)/include
IPA918_StartAppNative_LDFLAGS = -F$(THEOS_PROJECT_DIR)/Frameworks -lc++ -rpath /usr/lib/swift

# 🌟 載入 StartApp 與蘋果系統底層庫
IPA918_StartAppNative_FRAMEWORKS = UIKit Foundation StartApp AVFoundation CoreMedia StoreKit SystemConfiguration AdSupport WebKit CoreGraphics CoreTelephony

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
