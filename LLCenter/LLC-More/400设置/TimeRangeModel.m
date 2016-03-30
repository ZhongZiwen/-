//
//  TimeRangeModel.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TimeRangeModel.h"

@implementation TimeRangeModel

+ (TimeRangeModel*)initWithDataSource:(NSDictionary *)dict
{
    TimeRangeModel *timeType = [[TimeRangeModel alloc] initWithDataSource:dict];
    return timeType;
}

- (TimeRangeModel*)initWithDataSource:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
    
        _weekValue = @"";
        _weekStartTime = @"";
        _weekEndTime = @"";
        
        if ([dict objectForKey:@"weekValue"] ) {
            _weekValue = [dict objectForKey:@"weekValue"];
        }
        if ([dict objectForKey:@"weekStartTime"] ) {
            _weekStartTime = [dict objectForKey:@"weekStartTime"];
        }
        if ([dict objectForKey:@"weekEndTime"]) {
            _weekEndTime = [dict safeObjectForKey:@"weekEndTime"];
        }
    }
    return self;
}

@end
