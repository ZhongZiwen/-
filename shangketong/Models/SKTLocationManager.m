//
//  SKTLocationManager.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/14.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SKTLocationManager.h"

@interface SKTLocationManager ()

@property (nonatomic, strong) NSMutableArray *completionBlocks;
@end

@implementation SKTLocationManager

+ (SKTLocationManager*)sharedLocationManager {
    static dispatch_once_t onceToken;
    static SKTLocationManager *sharedLocationManager = nil;
    dispatch_once(&onceToken, ^{
        sharedLocationManager = [[SKTLocationManager alloc] init];
    });
    return sharedLocationManager;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setLocationManager:[[CLLocationManager alloc] init]];
        // 设置精度属性
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        // 设置属性distanceFilter，移动多长距离后才触发新的位置事件，以米为单位
        [self.locationManager setDistanceFilter:100.0f];
        // 设置委托，响应位置事件和授权状态变化
        [self.locationManager setDelegate:self];
        
        [self setCompletionBlocks:[[NSMutableArray alloc] initWithCapacity:3.0]];
    }
    return self;
}

#pragma mark - Public Method
- (void)getLocationWithCompletionBlock:(LocationUpdateCompletionBlock)block {
    
    if (block) {
        [self.completionBlocks addObject:[block copy]];
    }
    
    if (self.hasLocation) {
        for (LocationUpdateCompletionBlock comletionBlock in self.completionBlocks) {
            comletionBlock(self.location, nil);
        }
        
        if (self.completionBlocks.count == 0) {
            //notify map view of change to location when not requested
            [[NSNotificationCenter defaultCenter] postNotificationName:@"locationUpdated" object:nil];
        }
        [self.completionBlocks removeAllObjects];
    }
    
    if (self.locationError) {
        for (LocationUpdateCompletionBlock completionBlock in self.completionBlocks) {
            completionBlock(nil, self.locationError);
        }
        [self.completionBlocks removeAllObjects];
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusDenied) {
        [self.locationManager stopUpdatingLocation];
        
        NSString *errorMsg = @"Location Services Permission Denied for this app. Visit Settings.app to allow";
        NSDictionary *errorInfo = @{NSLocalizedDescriptionKey : errorMsg};
        
        NSError *deniedError = [NSError errorWithDomain:@"LocationErrorDomain" code:1 userInfo:errorInfo];
        
        [self setLocationError:deniedError];
        [self getLocationWithCompletionBlock:nil];
    }
    
    if (status == kCLAuthorizationStatusAuthorized) {
        [self.locationManager startUpdatingLocation];
        [self setLocationError:nil];
    }
}

// 获取位置后，调用该方法
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // 位置管理器可能通过数组locations提供多个位置，其中最后一个对象是最新的位置
    CLLocation *lastLocation = [locations lastObject];
    // 检查位置的精度，如果精度值为负，就忽略返回的位置
    if (lastLocation.horizontalAccuracy < 0)
        return;
    
    [self setLocation:lastLocation];
    [self setHasLocation:YES];
    
    [self getLocationWithCompletionBlock:nil];
}

// 位置管理器未能获取位置时
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
    [self setLocationError:error];
    [self getLocationWithCompletionBlock:nil];
}

@end
