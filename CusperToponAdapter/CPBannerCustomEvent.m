//
//  CPBannerCustomEvent.m
//  CusperDemoRelease
//
//  Created by Zinco on 2024/6/19.
//

#import <Foundation/Foundation.h>
#import "CPBannerCustomEvent.h"


@implementation CPBannerCustomEvent


- (void)adDidShow:(id)ad {
    [self trackBannerAdImpression];
}

- (void)adDidClick:(id)ad {
    [self trackBannerAdClick];
}

@end
