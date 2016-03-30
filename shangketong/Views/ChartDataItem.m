//
//  ChartDataItem.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ChartDataItem.h"

@implementation ChartDataItem

- (ChartDataItem*)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.m_uid = [dict objectForKey:@"uid"];
        self.m_id = [dict objectForKey:@"id"];
        self.m_name = [dict objectForKey:@"name"];
        self.m_count = [NSString stringWithFormat:@"%@", [dict objectForKey:@"count"]];
    }
    return self;
}

+ (ChartDataItem*)initWithDictionary:(NSDictionary *)dict {
    ChartDataItem *item = [[ChartDataItem alloc] initWithDictionary:dict];
    return item;
}
@end
