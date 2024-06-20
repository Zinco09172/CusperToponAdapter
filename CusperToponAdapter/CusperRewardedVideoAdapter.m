//
//  CusperRewardedVideoAdapter.m
//  CusperDemoRelease
//
//  Created by Zinco on 2024/6/18.
//

#import <Foundation/Foundation.h>
#import "CusperRewardedVideoAdapter.h"
#import <AnyThinkRewardedVideo/AnyThinkRewardedVideo.h>
#import <Cusper/CusperRewardAd.h>
#import <Cusper/Cusper.h>
#import "CPRewardVideoCustomEvent.h"
#import "ATCPBiddingManager.h"
#import "ATCPBiddingRequest.h"



@interface CusperRewardedVideoAdapter()

@end

@implementation CusperRewardedVideoAdapter

/// Adapter initialization method
/// - Parameters:
///   - serverInfo: Data from the server
///   - localInfo: Data from the local
- (instancetype)initWithNetworkCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
        self = [super init];
        if (self != nil) {
        
        }
        return self;
}


- (void)loadADWithInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo completion:(void (^)(NSArray<NSDictionary *> * _Nonnull, NSError * _Nonnull))completion {
    
    NSLog(@"loadADWithInfo");

    CPRewardVideoCustomEvent *event = [[CPRewardVideoCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    event.requestCompletionBlock = completion;
    event.delegate = self.delegateToBePassed;
    
    ATCPBiddingManager *biddingManager = [ATCPBiddingManager sharedInstance];
    ATCPBiddingRequest *bidingRequest = [biddingManager getRequestItemWithUnitID:serverInfo[@"unitid"]];
    
    //如果有bidId,代表是header bidding广告源
    if (bidingRequest && bidingRequest.customObject) {
        CusperRewardAd *cusperRv = bidingRequest.customObject;
        cusperRv.adDelegate = event;
        [event trackRewardedVideoAdLoaded:cusperRv adExtra:nil];
        [biddingManager removeRequestItmeWithUnitID:serverInfo[@"unitid"]];
        return;
    }
}

+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary *)info {
    NSLog(@"adReadyWithCustomObject");
    if (customObject) {
        return YES;
    }
    return NO;
}


+ (void)showRewardedVideo:(ATRewardedVideo *)rewardedVideo inViewController:(UIViewController *)viewController delegate:(id<ATRewardedVideoDelegate>)delegate {
    NSLog(@"showRewardedVideo");
    CusperRewardAd *cusperRvAd = rewardedVideo.customObject;
    
    [cusperRvAd presentFromRootViewController:viewController];
}




#pragma mark - Header bidding
#pragma mark - c2s
+(void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    NSLog(@"bidRequestWithPlacementModel");
    dispatch_async(dispatch_get_main_queue(), ^{
        [Cusper initConfig:^(BOOL success, NSString *error) {
          NSLog(@"sdk init success = %@",[Cusper getSdkVersion]);

            [CusperRewardAd loadAdWithAdUnitId:info[@"unitid"] loadCallback:^(CusperRewardAd *rvAd, NSString *error) {
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
                    NSString *price = [NSString stringWithFormat:@"%f", [rvAd getPrice]];
                    NSLog(@"load ad success %@", price);
                  
                   // 需要确认一下传入的货币单位 currencyType
                   ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:placementModel.placementID
                                                            unitGroupUnitID:unitGroupModel.unitID
                                                            adapterClassString:@"CusperRewardedVideoAdapter"
                                                            price:price
                                                            currencyType:ATBiddingCurrencyTypeUS
                                                            expirationInterval:unitGroupModel.networkTimeout
                                                            customObject:rvAd];
               
                
                ATCPBiddingManager *biddingManager = [ATCPBiddingManager sharedInstance];
                ATCPBiddingRequest *request = [ATCPBiddingRequest new];
                           request.unitGroup = unitGroupModel;
                           request.placementID = placementModel.placementID;
                           request.bidCompletion = completion;
                           request.unitID = info[@"unitid"];
                           request.extraInfo = info;
                           request.adType = ESCAdFormatReward;
                request.customObject = rvAd;
                [biddingManager startWithRequestItem:request];
                // 4. 调用completion block，并将ATBidInfo对象传入
                completion(bidInfo, nil);
            }];
            
        }];
    });
}


+ (void)sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    NSLog(@"sendWinnerNotifyWithCustomObject");
    CusperRewardAd *cusperRvAd = (CusperRewardAd *)customObject;
    [cusperRvAd notifyBidWin:cusperRvAd.getPrice];
}

+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    NSLog(@"sendLossNotifyWithCustomObject");
}
@end
