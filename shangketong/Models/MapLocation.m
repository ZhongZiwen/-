//
//  MapLocation.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MapLocation.h"

@implementation MapLocation

- (NSString*)title {
    return _streetAddress;
}

- (NSString*)subtitle {
    
    NSMutableString *ret = [NSMutableString new];
    
    if (_state && [_state length])
        [ret appendString:_state];
    
    if (_city && [_city length])
        [ret appendString:_city];
    
    if (_streetAddress && [_streetAddress length])
        [ret appendString:_streetAddress];
    
    return ret;
}

@end
