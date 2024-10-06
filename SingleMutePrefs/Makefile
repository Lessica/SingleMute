ifeq ($(THEOS_DEVICE_SIMULATOR),1)
TARGET := simulator:clang:latest:14.0
INSTALL_TARGET_PROCESSES := Preferences
ARCHS := arm64 x86_64
else
TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES := Preferences
ARCHS := arm64 arm64e
endif

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME := SingleMutePrefs

SingleMutePrefs_FILES += SingleMuteRootListController.m
SingleMutePrefs_CFLAGS += -fobjc-arc

ifeq ($(THEOS_DEVICE_SIMULATOR),1)
SingleMutePrefs_LDFLAGS += -FFrameworks/_Simulator
SingleMutePrefs_LDFLAGS += -rpath /opt/simject
else
SingleMutePrefs_LDFLAGS += -FFrameworks
endif

SingleMutePrefs_FRAMEWORKS += UIKit
SingleMutePrefs_PRIVATE_FRAMEWORKS += Preferences
SingleMutePrefs_INSTALL_PATH += /Library/PreferenceBundles

include $(THEOS_MAKE_PATH)/bundle.mk