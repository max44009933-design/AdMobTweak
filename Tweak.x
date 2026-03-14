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

    // 🌟 1. 初始化 StartApp SDK
    STAStartAppSDK *sdk = [STAStartAppSDK sharedInstance];
    sdk.appID = @"你的_STARTAPP_ID"; // <--- ⚠️ 把這行換成你在後台拿到的數字 ID ⚠️
    
    // 🌟 2. 建立廣告物件並開始載入
    self.rewardedVideoAd = [[STAStartAppAd alloc] init];
    [self loadAd];
}

- (void)loadAd {
    // 指定載入「激勵影片」
    [self.rewardedVideoAd loadRewardedVideoAdWithDelegate:self];
}

- (void)showAd {
    if (self.rewardedVideoAd.isReady) {
        NSLog(@"[StartApp Tweak] 準備展示激勵影片...");
        [self.rewardedVideoAd showAd];
    } else {
        NSLog(@"[StartApp Tweak] 影片尚未載入完成");
    }
}

// --- StartApp 委派回調 (STADelegateProtocol) ---

- (void)didLoadAd:(STAAbstractAd*)ad {
    NSLog(@"[StartApp Tweak] 🎉 影片載入成功！自動彈出");
    [self showAd];
}

- (void)failedLoadAd:(STAAbstractAd*)ad withError:(NSError *)error {
    NSLog(@"[StartApp Tweak] ❌ 載入失敗: %@", error.localizedDescription);
    // 失敗的話，10 秒後重新嘗試載入
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self loadAd];
    });
}

- (void)didShowAd:(STAAbstractAd*)ad {
    NSLog(@"[StartApp Tweak] 廣告正在畫面上播放");
}

- (void)failedShowAd:(STAAbstractAd*)ad withError:(NSError *)error {
    NSLog(@"[StartApp Tweak] ❌ 廣告播放失敗");
    [self loadAd]; // 重新載入
}

- (void)didCloseAd:(STAAbstractAd*)ad {
    NSLog(@"[StartApp Tweak] 玩家關閉了廣告");
    // 關閉後立刻預先載入下一支廣告備用
    [self loadAd]; 
}
@end

// --- Tweak 進入點 ---
__attribute__((constructor)) static void init_tweak() {
    // 監聽遊戲進入活躍狀態
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification 
                                                      object:nil 
                                                       queue:[NSOperationQueue mainQueue] 
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            // 延遲 5 秒啟動，讓遊戲先載入畫面
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [[IPA918_StartAppManager shared] startEngine];
            });
        });
    }];
}
