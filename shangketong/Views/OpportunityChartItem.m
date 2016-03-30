//
//  OpportunityChartItem.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/7/3.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "OpportunityChartItem.h"

@implementation OpportunityChartItem

- (OpportunityChartItem*)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.m_dateString = dict[@"x"];
        self.m_fillColor = dict[@"marker"][@"fillColor"];
        self.m_radius = [dict[@"marker"][@"radius"] integerValue];
        self.m_yValue = [dict[@"y"] integerValue];
    }
    return self;
}

+ (OpportunityChartItem*)initWithDictionary:(NSDictionary *)dict {
    OpportunityChartItem *item = [[OpportunityChartItem alloc] initWithDictionary:dict];
    return item;
}
@end
