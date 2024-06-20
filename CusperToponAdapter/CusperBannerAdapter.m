//
//  CusperBannerAdapter.m
//  CusperDemoRelease
//
//  Created by Zinco on 2024/6/19.
//

#import <Foundation/Foundation.h>
#import "CusperBannerAdapter.h"
#import <Cusper/Cusper.h>
#import <Cusper/CusperBannerAdSize.h>
#import <Cusper/CusperBannerAd.h>
#import "ATCPBiddingManager.h"
#import "ATCPBiddingRequest.h"
#import "CPBannerCustomEvent.h"

@implementation CusperBannerAdapter

- (instancetype)initWithNetworkCustomInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo {
    self = [super init];
    if (self != nil) {
    }
    return self;
}

- (void)loadADWithInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo completion:(void (^)(NSArray<NSDictionary *> * _Nonnull, NSError * _Nonnull))completion {
    
    NSLog(@"loadADWithInfo");

    CPBannerCustomEvent *event = [[CPBannerCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
    event.requestCompletionBlock = completion;
    event.delegate = self.delegateToBePassed;
    
    ATCPBiddingManager *biddingManager = [ATCPBiddingManager sharedInstance];
    ATCPBiddingRequest *bidingRequest = [biddingManager getRequestItemWithUnitID:serverInfo[@"unitid"]];
    
    
    if (bidingRequest && bidingRequest.customObject) {
        CusperBannerAd *bannerAd = bidingRequest.customObject;
        bannerAd.adDelegate = event;
        [event trackBannerAdLoaded:bannerAd adExtra:nil];
        [biddingManager removeRequestItmeWithUnitID:serverInfo[@"unitid"]];
        return;
    }
    
    
}

+ (BOOL)adReadyWithCustomObject:(id)customObject info:(NSDictionary *)info {
    return customObject?YES:NO;
}


#pragma mark - Header bidding
#pragma mark - c2s
+(void)bidRequestWithPlacementModel:(ATPlacementModel*)placementModel unitGroupModel:(ATUnitGroupModel*)unitGroupModel info:(NSDictionary*)info completion:(void(^)(ATBidInfo *bidInfo, NSError *error))completion {
    NSLog(@"bidRequestWithPlacementModel");
    dispatch_async(dispatch_get_main_queue(), ^{
        [Cusper initConfig:^(BOOL success, NSString *error) {
          NSLog(@"sdk init success = %@",[Cusper getSdkVersion]);
            
            NSInteger width = [info[@"cusper_width"] integerValue];
            NSInteger height = [info[@"cusper_height"] integerValue];
            
            [CusperBannerAd loadAdWithAdUnitId:info[@"unitid"] adSize:[CusperBannerAdSize initWithWH:&width height:&height] loadCallback:^(CusperBannerAd *bannerAd, NSString *error) {
                    
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
            NSString *price = [NSString stringWithFormat:@"%f", [bannerAd getPrice]];
            NSLog(@"load ad success %@", price);
          
           // 需要确认一下传入的货币单位 currencyType
           ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:placementModel.placementID
                                                    unitGroupUnitID:unitGroupModel.unitID
                                                    adapterClassString:@"CusperBannerAdapter"
                                                    price:price
                                                    currencyType:ATBiddingCurrencyTypeUS
                                                    expirationInterval:unitGroupModel.networkTimeout
                                                    customObject:bannerAd];
       
        
                        ATCPBiddingManager *biddingManager = [ATCPBiddingManager sharedInstance];
                        ATCPBiddingRequest *request = [ATCPBiddingRequest new];
                                   request.unitGroup = unitGroupModel;
                                   request.placementID = placementModel.placementID;
                                   request.bidCompletion = completion;
                                   request.unitID = info[@"unitid"];
                                   request.extraInfo = info;
                                   request.adType = ESCAdFormatReward;
                        request.customObject = bannerAd;
                        [biddingManager startWithRequestItem:request];
                        // 4. 调用completion block，并将ATBidInfo对象传入
                        completion(bidInfo, nil);
             }];
            
        }];
    });
}


+ (void)sendWinnerNotifyWithCustomObject:(id)customObject secondPrice:(NSString*)price userInfo:(NSDictionary<NSString *, NSString *> *)userInfo {
    NSLog(@"sendWinnerNotifyWithCustomObject");
    CusperBannerAd *bannerAd = (CusperBannerAd *)customObject;
    [bannerAd notifyBidWin:bannerAd.getPrice];
}

+ (void)sendLossNotifyWithCustomObject:(nonnull id)customObject lossType:(ATBiddingLossType)lossType winPrice:(nonnull NSString *)price userInfo:(NSDictionary *)userInfo {
    NSLog(@"sendLossNotifyWithCustomObject");
}



@end
