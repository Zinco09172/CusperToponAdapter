//
//  CPRewardVideoCustomEvent.m
//  CusperDemoRelease
//
//  Created by Zinco on 2024/6/18.
//

#import <Foundation/Foundation.h>
#import "CPRewardVideoCustomEvent.h"
#import <Cusper/CusperRewardAd.h>

@interface CPRewardVideoCustomEvent()
@property (nonatomic) bool isRewarded;
@end

@implementation CPRewardVideoCustomEvent

- (void)adDidShow:(CusperRewardAd *)ad {
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

- (void)adDidClick:(CusperRewardAd *)ad {
    [self trackRewardedVideoAdClick];
}

- (void)adDidDismiss:(CusperRewardAd *)ad {
    NSDictionary *rewardInfo = @{};
    [self trackRewardedVideoAdCloseRewarded:self.isRewarded && self.isRewarded == YES extra:rewardInfo];
}

- (void)rewardedAd:(CusperRewardAd *)ad {
    self.isRewarded = YES;
    [self trackRewardedVideoAdRewarded];
}




@end
