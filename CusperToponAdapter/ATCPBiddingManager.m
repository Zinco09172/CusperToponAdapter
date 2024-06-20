//
//  ATCPBiddingManager.m
//  CusperDemoRelease
//
//  Created by Zinco on 2024/6/19.
//

#import <Foundation/Foundation.h>
#import "ATCPBiddingManager.h"


@interface ATCPBiddingManager ()

@property (nonatomic, strong) NSMutableDictionary *bidingAdStorageAccessor;
@property (nonatomic, strong) NSMutableDictionary *bidingAdDelegate;

@end

@implementation ATCPBiddingManager

+ (instancetype)sharedInstance {
    static ATCPBiddingManager *sharedInstance = nil;
       static dispatch_once_t onceToken;
       dispatch_once(&onceToken, ^{
           sharedInstance = [[ATCPBiddingManager alloc] init];
           sharedInstance.bidingAdStorageAccessor = [NSMutableDictionary dictionary];
           sharedInstance.bidingAdDelegate = [NSMutableDictionary dictionary];
       });
       return sharedInstance;
}


- (ATCPBiddingManager *)getRequestItemWithUnitID:(NSString *)unitID {
    @synchronized (self) {
        return [self.bidingAdStorageAccessor objectForKey:unitID];
    }
    
}

- (void)removeRequestItmeWithUnitID:(NSString *)unitID {
    @synchronized (self) {
        [self.bidingAdStorageAccessor removeObjectForKey:unitID];
    }
}


- (void)startWithRequestItem:(ATCPBiddingRequest *)request {
    [self.bidingAdStorageAccessor setObject:request forKey:request.unitID];
}

@end
