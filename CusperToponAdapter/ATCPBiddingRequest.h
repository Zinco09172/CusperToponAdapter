//
//  ATCPBiddingRequest.h
//  CusperDemoRelease
//
//  Created by Zinco on 2024/6/19.
//

#ifndef ATCPBiddingRequest_h
#define ATCPBiddingRequest_h


#endif /* ATCPBiddingRequest_h */

#import <AnyThinkSDK/AnyThinkSDK.h>

typedef NS_ENUM(NSInteger, ESCAdFormat) {
    ESCAdFormatReward = 0,
};

@interface ATCPBiddingRequest : NSObject

@property(nonatomic, strong) id customObject;

@property(nonatomic, strong) ATUnitGroupModel *unitGroup;

@property(nonatomic, strong) ATAdCustomEvent *customEvent;

@property(nonatomic, copy) NSString *unitID;
@property(nonatomic, copy) NSString *placementID;

@property(nonatomic, copy) NSDictionary *extraInfo;

@property(nonatomic, copy) void(^bidCompletion)(ATBidInfo * _Nullable bidInfo, NSError * _Nullable error);

@property(nonatomic, assign) ESCAdFormat adType;

@end
