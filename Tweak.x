#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

// --- 模組 1：繞過 Info.plist 檢查 ---
@implementation NSBundle (AdMobHack)
- (id)hook_objectForInfoDictionaryKey:(NSString *)key {
    if ([key isEqualToString:@"GADApplicationIdentifier"]) {
        return @"ca-app-pub-3940256099942544~1458002511"; // 官方測試 App ID
    }
    return [self hook_objectForInfoDictionaryKey:key];
}
@end

// --- 模組 2：原生 AdMob 管理器 ---
@interface IPA918_AdMobManager : NSObject <GADFullScreenContentDelegate>
@property(nonatomic, strong) GADRewardedAd *rewardedAd;
@property(nonatomic, assign) BOOL isRewardEarned;
@property(nonatomic, assign) BOOL hasStarted;
+ (instancetype)shared;
- (void)startAdMobEngine;
- (void)loadRewardedAd;
- (void)showRewardedAd;
@end

@implementation IPA918_AdMobManager
+ (instancetype)shared {
    static IPA918_AdMobManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (void)startAdMobEngine {
    if (self.hasStarted) return;
    self.hasStarted = YES;
    [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status) {
        [self loadRewardedAd];
    }];
}

- (void)loadRewardedAd {
    GADRequest *request = [GADRequest request];
    [GADRewardedAd loadWithAdUnitID:@"ca-app-pub-3940256099942544/1712485313" // 官方測試廣告 ID
                            request:request
                  completionHandler:^(GADRewardedAd *ad, NSError *error) {
        if (error) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self loadRewardedAd];
            });
            return;
        }
        self.rewardedAd = ad;
        self.rewardedAd.fullScreenContentDelegate = self;
        [self showRewardedAd];
    }];
}

- (void)showRewardedAd {
    if (self.rewardedAd) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow ?: [[UIApplication sharedApplication].windows firstObject];
        UIViewController *rootVC = window.rootViewController;
        while (rootVC.presentedViewController) { rootVC = rootVC.presentedViewController; }
        
        if (rootVC) {
            self.isRewardEarned = NO;
            [self.rewardedAd presentFromRootViewController:rootVC userDidEarnRewardHandler:^{
                self.isRewardEarned = YES;
            }];
        }
    }
}

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    self.rewardedAd = nil;
    [self loadRewardedAd]; 
}

- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    self.rewardedAd = nil; 
    if (!self.isRewardEarned) {
        [self loadRewardedAd];
    }
}
@end

// --- Tweak 進入點 ---
__attribute__((constructor)) static void init_tweak() {
    Method orig = class_getInstanceMethod([NSBundle class], @selector(objectForInfoDictionaryKey:));
    Method hook = class_getInstanceMethod([NSBundle class], @selector(hook_objectForInfoDictionaryKey:));
    method_exchangeImplementations(orig, hook);
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [[IPA918_AdMobManager shared] startAdMobEngine];
            });
        });
    }];
}