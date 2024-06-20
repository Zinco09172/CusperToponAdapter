//
//  CusperInterstitialVideoAdapter.m
//  CusperDemoRelease
//
//  Created by Zinco on 2024/6/19.
//

#import <Foundation/Foundation.h>
#import "CusperInterstitialVideoAdapter.h"
#import <Cusper/Cusper.h>
#import "ATCPBiddingManager.h"
#import "ATCPBiddingRequest.h"
#import <Cusper/CusperInterstitialAd.h>
#import "CPInterstitialVideoCustomEvent.h"


@implementation CusperInterstitialVideoAdapter

- (instancetype)initWithNetworkCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    self = [super init];
    if (self != nil) {
    }
    return self;
}

- (void)loadADWithInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo completion:(void (^)(NSArray<NSDictionary *> * _Nonnull, NSError * _Nonnull))completion {
    NSLog(@"loadADWithInfo");

    CPInterstitialVideoCustomEvent *event = [[CPInterstitialVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    event.requestCompletionBlock = completion;
    event.delegate = self.delegateToBePassed;
    
    ATCPBiddingManager *biddingManager = [ATCPBiddingManager sharedInstance];
    ATCPBiddingRequest *bidingRequest = [biddingManager getRequestItemWithUnitID:serverInfo[@"unitid"]];
    
    
    if (bidingRequest && bidingRequest.customObject) {
        CusperInterstitialAd *cusperIV = bidingRequest.customObject;
        cusperIV.adDelegate = event;
        [event trackInterstitialAdLoaded:cusperIV adExtra:nil];
        [biddingManager removeRequestItmeWithUnitID:serverInfo[@"unitid"]];
        return;
    }
}


+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary *)info {
    return customObject?YES:NO;
}

+ (void)showInterstitial:(ATInterstitial *)interstitial inViewController:(UIViewController *)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    NSLog(@"showInterstitial");
    CusperInterstitialAd *interstitialAd = interstitial.customObject;
    
    [interstitialAd presentFromRootViewController:viewController];
}

#pragma mark - Header bidding
#pragma mark - c2s
+(void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    NSLog(@"bidRequestWithPlacementModel");
    dispatch_async(dispatch_get_main_queue(), ^{
        [Cusper initConfig:^(BOOL success, NSString *error) {
          NSLog(@"sdk init success = %@",[Cusper getSdkVersion]);
            [CusperInterstitialAd loadAdWithAdUnitId:info[@"unitid"] loadCallback:^(CusperInterstitialAd *ivAd, NSString *error) {
                    if (error) {
                        NSLog(@"load error %@",error);
                        NSDictionary *userInfo = @{
                            NSLocalizedDescriptionKey: NSLocalizedString(@"bid load fail", nil),
                            NSLocalizedFailureReasonErrorKey: NSLocalizedString(error, nil),
                        };

                        completion(nil,[NSError errorWithDomain:@"com.ky.cusper" code:-1 userInfo:userInfo]);
                        return;
                    }
                // 3. 获取广告源C2S header bidding返回的价格，并构造出ATBidInfo对象。
                NSString *price = [NSString stringWithFormat:@"%f", [ivAd getPrice]];
                NSLog(@"load ad success %@", price);
              
               // 需要确认一下传入的货币单位 currencyType
               ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:placementModel.placementID
                                                        unitGroupUnitID:unitGroupModel.unitID
                                                        adapterClassString:@"CusperInterstitialVideoAdapter"
                                                        price:price
                                                        currencyType:ATBiddingCurrencyTypeUS
                                                        expirationInterval:unitGroupModel.networkTimeout
                                                        customObject:ivAd];
           
            
            ATCPBiddingManager *biddingManager = [ATCPBiddingManager sharedInstance];
            ATCPBiddingRequest *request = [ATCPBiddingRequest new];
                       request.unitGroup = unitGroupModel;
                       request.placementID = placementModel.placementID;
                       request.bidCompletion = completion;
                       request.unitID = info[@"unitid"];
                       request.extraInfo = info;
                       request.adType = ESCAdFormatReward;
            request.customObject = ivAd;
            [biddingManager startWithRequestItem:request];
            // 4. 调用completion block，并将ATBidInfo对象传入
            completion(bidInfo, nil);
                }];
        }];
    });
}


+ (void)sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    NSLog(@"sendWinnerNotifyWithCustomObject");
    CusperInterstitialAd *cusperInterstitial = (CusperInterstitialAd *)customObject;
    [cusperInterstitial notifyBidWin:cusperInterstitial.getPrice];
}

+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    NSLog(@"sendLossNotifyWithCustomObject");
}


@end
