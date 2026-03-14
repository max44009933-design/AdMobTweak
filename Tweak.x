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

// --- 模組 2：激勵廣告 (Rewarded Ad) 管理器 ---
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
    
    __weak typeof(self) weakSelf = self;
    [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus *status) {
        [weakSelf loadRewardedAd];
    }];
}

- (void)loadRewardedAd {
    GADRequest *request = [GADRequest request];
    __weak typeof(self) weakSelf = self;
    
    [GADRewardedAd loadWithAdUnitID:@"ca-app-pub-3940256099942544/1712485313" // 官方測試廣告 ID
                            request:request
                  completionHandler:^(GADRewardedAd *ad, NSError *error) {
        if (error) {
            NSLog(@"[AdMob Tweak] 載入失敗: %@", error.localizedDescription);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [weakSelf loadRewardedAd];
            });
            return;
        }
        
        NSLog(@"[AdMob Tweak] 載入成功！");
        weakSelf.rewardedAd = ad;
        weakSelf.rewardedAd.fullScreenContentDelegate = weakSelf;
        [weakSelf showRewardedAd];
    }];
}

- (void)showRewardedAd {
    if (self.rewardedAd) {
        // 安全獲取當前活躍的 UIWindow (支援 iOS 13+，消除棄用警告)
        UIWindow *keyWindow = nil;
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in scene.windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        break;
                    }
                }
            }
        }
        
        // 降級相容保護
        if (!keyWindow) {
            keyWindow = [[UIApplication sharedApplication].windows firstObject];
        }

        UIViewController *rootVC = keyWindow.rootViewController;
        while (rootVC.presentedViewController) { 
            rootVC = rootVC.presentedViewController; 
        }
        
        if (rootVC) {
            self.isRewardEarned = NO;
            __weak typeof(self) weakSelf = self;
            [self.rewardedAd presentFromRootViewController:rootVC userDidEarnRewardHandler:^{
                NSLog(@"[AdMob Tweak] 玩家獲得獎勵！");
                weakSelf.isRewardEarned = YES;
            }];
        }
    }
}

// --- GADFullScreenContentDelegate 協議實作 ---
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    NSLog(@"[AdMob Tweak] 廣告展示失敗: %@", error.localizedDescription);
    self.rewardedAd = nil;
    [self loadRewardedAd]; 
}

- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"[AdMob Tweak] 廣告已關閉");
    self.rewardedAd = nil; 
    if (!self.isRewardEarned) {
        NSLog(@"[AdMob Tweak] 玩家未完成觀看...");
    }
    // 無論有沒有獲得獎勵，都預先載入下一支廣告備用
    [self loadRewardedAd]; 
}
@end

// --- Tweak 進入點 ---
__attribute__((constructor)) static void init_tweak() {
    // Hook Info.plist 攔截
    Method orig = class_getInstanceMethod([NSBundle class], @selector(objectForInfoDictionaryKey:));
    Method hook = class_getInstanceMethod([NSBundle class], @selector(hook_objectForInfoDictionaryKey:));
    method_exchangeImplementations(orig, hook);
    
    // 監聽 App 進入活躍狀態
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification 
                                                      object:nil 
                                                       queue:[NSOperationQueue mainQueue] 
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            // 延遲 5 秒啟動，避免卡住遊戲開局載入畫面
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [[IPA918_AdMobManager shared] startAdMobEngine];
            });
        });
    }];
}
