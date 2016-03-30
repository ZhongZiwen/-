//
//  ChartItem.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ChartItem.h"

@implementation ChartItem

- (ChartItem*)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.m_id = [dict objectForKey:@"id"];
        self.m_name = [dict objectForKey:@"name"];
        self.m_viewCase = [dict objectForKey:@"viewCase"];
        self.m_description = [dict objectForKey:@"description"];
        self.m_dataDisplay = [dict objectForKey:@"dataDisplay"];
        self.m_type = [dict objectForKey:@"type"];
    }
    return self;
}

+ (ChartItem*)initWithDictionary:(NSDictionary *)dict {
    ChartItem *item = [[ChartItem alloc] initWithDictionary:dict];
    return item;
}

@end
