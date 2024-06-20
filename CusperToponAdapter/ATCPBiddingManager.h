//
//  ATCPBiddingManager.h
//  CusperDemoRelease
//
//  Created by Zinco on 2024/6/19.
//

#ifndef ATCPBiddingManager_h
#define ATCPBiddingManager_h


#endif /* ATCPBiddingManager_h */
#import "ATCPBiddingRequest.h"



@interface ATCPBiddingManager : NSObject


+ (instancetype)sharedInstance;

- (void)startWithRequestItem:(ATCPBiddingRequest *)request;

- (ATCPBiddingRequest *)getRequestItemWithUnitID:(NSString *)unitID;

- (void)removeRequestItmeWithUnitID:(NSString *)unitID;



@end
