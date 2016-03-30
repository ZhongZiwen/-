//
//  ActivityType.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ActivityType.h"

@implementation ActivityType

- (instancetype)init {
    self = [super init];
    if (self) {
        _activitiesArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}
@end
