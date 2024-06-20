//
//  CPInterstitialVideoCustomEvent.m
//  CusperDemoRelease
//
//  Created by Zinco on 2024/6/19.
//

#import <Foundation/Foundation.h>
#import "CPInterstitialVideoCustomEvent.h"
#import <Cusper/CusperInterstitialAd.h>


@implementation CPInterstitialVideoCustomEvent

- (void)adDidShow:(CusperInterstitialAd *)ad {
    [self trackInterstitialAdShow];
    [self trackInterstitialAdVideoStart];
}

- (void)adDidClick:(CusperInterstitialAd *)ad {
    [self trackInterstitialAdClick];
}

- (void)adDidDismiss:(CusperInterstitialAd *)ad {
    NSDictionary *closeInfo = @{};
    [self trackInterstitialAdClose:closeInfo];
}


@end
