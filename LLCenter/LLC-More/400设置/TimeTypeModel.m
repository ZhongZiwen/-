//
//  TimeTypeModel.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TimeTypeModel.h"

@implementation TimeTypeModel

+ (TimeTypeModel*)initWithDataSource:(NSDictionary *)dict
{
    TimeTypeModel *timeType = [[TimeTypeModel alloc] initWithDataSource:dict];
    return timeType;
}

- (TimeTypeModel*)initWithDataSource:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
    
        _checked = NO;
        _sitWeek = @"";
        _sitPointStartTime = @"";
        _sitPointEndTime = @"";
        
        if ([dict objectForKey:@"checked"] ) {
            _checked = [[dict objectForKey:@"checked"] boolValue];
        }
        
        if ([dict objectForKey:@"sitWeek"] ) {
            _sitWeek = [dict objectForKey:@"sitWeek"];
        }
        if ([dict objectForKey:@"sitWeekValue"] ) {
            _sitWeekValue = [dict objectForKey:@"sitWeekValue"];
        }
        if ([dict objectForKey:@"sitPointStartTime"]) {
            _sitPointStartTime = [dict safeObjectForKey:@"sitPointStartTime"];
        }
        if ([dict objectForKey:@"sitPointEndTime"]) {
            _sitPointEndTime = [dict safeObjectForKey:@"sitPointEndTime"];
        }
        
    }
    return self;
}

@end
