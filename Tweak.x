#import <UIKit/UIKit.h>
#import <StartApp/StartApp.h>

@interface IPA918_StartAppManager : NSObject <STADelegateProtocol>
@property (nonatomic, strong) STAStartAppAd *rewardedVideoAd;
@property (nonatomic, assign) BOOL hasInitialized;
+ (instancetype)shared;
- (void)startEngine;
- (void)loadAd;
- (void)showAd;
@end

@implementation IPA918_StartAppManager
+ (instancetype)shared {
    static IPA918_StartAppManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (void)startEngine {
    if (self.hasInitialized) return;
    self.hasInitialized = YES;

    // 🌟 1. 尋找遊戲最頂層的畫面
    UIWindow *window = [UIApplication sharedApplication].keyWindow ?: [[UIApplication sharedApplication].windows firstObject];
    UIViewController *rootVC = window.rootViewController;
    while (rootVC.presentedViewController) { rootVC = rootVC.presentedViewController; }

    // 🌟 2. 彈出提示框，證明外掛有活著！(測試用，成功後可以刪掉)
    if (rootVC) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🚀 外掛載入成功" 
                                                                       message:@"正在向 Start.io 請求廣告..." 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:nil]];
        [rootVC presentViewController:alert animated:YES completion:nil];
    }

    // 🌟 3. 初始化 StartApp SDK
    STAStartAppSDK *sdk = [STAStartAppSDK sharedInstance];
    sdk.appID = @"205271531"; // <--- ⚠️ 確保這裡換成了純數字 ID！
    
    self.rewardedVideoAd = [[STAStartAppAd alloc] init];
    [self loadAd];
}

- (void)loadAd {
    [self.rewardedVideoAd loadRewardedVideoAdWithDelegate:self];
}

- (void)showAd {
    if (self.rewardedVideoAd.isReady) {
        [self.rewardedVideoAd showAd];
    }
}

// --- StartApp 回調 ---
- (void)didLoadAd:(STAAbstractAd*)ad {
    // 廣告載入成功，立刻播放
    [self showAd];
}

- (void)failedLoadAd:(STAAbstractAd*)ad withError:(NSError *)error {
    // 失敗的話，10 秒後重新嘗試載入
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self loadAd];
    });
}

- (void)didCloseAd:(STAAbstractAd*)ad {
    // 關閉後立刻預先載入下一支廣告備用
    [self loadAd]; 
}
@end

// --- Tweak 進入點 ---
__attribute__((constructor)) static void init_tweak() {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification 
                                                      object:nil 
                                                       queue:[NSOperationQueue mainQueue] 
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            // 延遲 6 秒，確保 Pokémon GO 遊戲畫面已經出來
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [[IPA918_StartAppManager shared] startEngine];
            });
        });
    }];
}
