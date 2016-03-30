//
//  RecordMapAnnotation.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "RecordMapAnnotation.h"

@implementation RecordMapAnnotation

- (instancetype)initWithTitle:(NSString *)atitle coordinate:(CLLocationCoordinate2D)location {
    self = [super init];
    if (self) {
        _title = atitle;
        _coordinate = location;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)atitle latitue:(float)alatitue longitude:(float)alongitude {
    self = [super init];
    if (self) {
        _title = atitle;
        _coordinate.latitude = alatitue;
        _coordinate.longitude = alongitude;
    }
    return self;
}
@end
