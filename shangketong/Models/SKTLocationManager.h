//
//  SKTLocationManager.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/14.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^LocationUpdateCompletionBlock)(CLLocation *location, NSError *error);

@interface SKTLocationManager : NSObject<CLLocationManagerDelegate>

+ (SKTLocationManager*)sharedLocationManager;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSError *locationError;
@property (nonatomic) BOOL hasLocation;

- (void)getLocationWithCompletionBlock:(LocationUpdateCompletionBlock)block;
@end
