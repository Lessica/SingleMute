@import UIKit;

#import <HBLog.h>

@interface SBRingerControl : NSObject
- (BOOL)isRingerMuted;
@end

@interface _UIStatusBarDataQuietModeEntry : NSObject
@property(nonatomic, copy) NSString *focusName;
@end

@interface _UIStatusBarData : NSObject
@property(nonatomic, copy) _UIStatusBarDataQuietModeEntry *quietModeEntry;
@end

@interface _UIStatusBarItemUpdate : NSObject
@property(nonatomic, strong) _UIStatusBarData *data;
@end

@interface UIStatusBar_Base : UIView
- (void)forceUpdateData:(BOOL)arg1;
@end

@interface SMWeakContainer : NSObject
@property(nonatomic, weak) id object;
@end

@implementation SMWeakContainer
@end

static SBRingerControl *_ringerControl = nil;
static NSMutableSet<SMWeakContainer *> *_weakContainers = nil;

// this is enough for the status bar legacy data
static unsigned char _sharedData[5000] = {0};

%hook _UIStatusBarIndicatorQuietModeItem

- (id)systemImageNameForUpdate:(_UIStatusBarItemUpdate *)update {
    BOOL isRingerMuted = [_ringerControl isRingerMuted];
    BOOL isQuietModeEnabled = ![update.data.quietModeEntry.focusName isEqualToString:@"!Mute"];
    if (isRingerMuted && !isQuietModeEnabled) {
        return @"bell.slash.fill";
    }
    return %orig;
}

%end

%hook _UIStatusBarDataQuietModeEntry

- (id)initFromData:(unsigned char *)arg1 type:(int)arg2 focusName:(const char *)arg3 maxFocusLength:(int)arg4 imageName:(const char*)arg5 maxImageLength:(int)arg6 boolValue:(BOOL)arg7 {
    BOOL isQuietMode = arg1[2];
    if (!isQuietMode) {
        _sharedData[2] = [_ringerControl isRingerMuted];
        return %orig(_sharedData, arg2, "!Mute", arg4, arg5, arg6, arg7);
    }
    return %orig;
}

%end

%hook _UIStatusBarDataLocationEntry

- (id)initFromData:(unsigned char *)arg1 type:(int)arg2 {
    BOOL isRingerMuted = [_ringerControl isRingerMuted];
    if (isRingerMuted) {
        _sharedData[21] = 0;
        return %orig(_sharedData, arg2);
    }
    return %orig;
}

%end

%hook SBRingerControl

// iOS 15
- (id)initWithHUDController:(id)arg1 soundController:(id)arg2 {
	_ringerControl = %orig;
	return _ringerControl;
}

// iOS 16+
- (id)initWithBannerManager:(id)arg1 soundController:(id)arg2 {
	_ringerControl = %orig;
	return _ringerControl;
}

- (void)setRingerMuted:(BOOL)arg1 {
    %orig;
    for (SMWeakContainer *container in _weakContainers) {
        UIStatusBar_Base *statusBar = (UIStatusBar_Base *)container.object;
        [statusBar forceUpdateData:YES];
    }
}

// iOS 17
- (void)setRingerMuted:(BOOL)arg1 withFeedback:(BOOL)arg2 reason:(id)arg3 clientType:(unsigned)arg4 {
    %orig;
    for (SMWeakContainer *container in _weakContainers) {
        UIStatusBar_Base *statusBar = (UIStatusBar_Base *)container.object;
        [statusBar forceUpdateData:YES];
    }
}

%end

%hook UIStatusBar_Base

- (instancetype)_initWithFrame:(CGRect)frame showForegroundView:(BOOL)showForegroundView wantsServer:(BOOL)wantsServer inProcessStateProvider:(id)inProcessStateProvider {
    SMWeakContainer *container = [SMWeakContainer new];
    container.object = self;
    [_weakContainers addObject:container];
    return %orig;
}

%end

%ctor {
    _weakContainers = [NSMutableSet set];
}