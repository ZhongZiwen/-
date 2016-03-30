//
//  PerformanceItem.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PerformanceItem.h"

@implementation PerformanceItem

- (PerformanceItem*)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.m_id = dict[@"id"];
        self.m_name = dict[@"name"];
        self.m_ownerId = dict[@"ownerId"];
        self.m_accountId = dict[@"accountId"];
        self.m_money = [dict[@"money"] integerValue];
    }
    return self;
}

+ (PerformanceItem*)initWithDictionary:(NSDictionary *)dict {
    PerformanceItem *item = [[PerformanceItem alloc] initWithDictionary:dict];
    return item;
}
@end
