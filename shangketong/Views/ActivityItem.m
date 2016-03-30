//
//  VisitingItem.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/17.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ActivityItem.h"

@implementation ActivityItem

- (ActivityItem*)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.m_id = dict[@"id"];
        self.m_content = dict[@"content"];
        self.m_groupBelongName = dict[@"group"][@"belongName"];
        self.m_groupName = dict[@"group"][@"name"];
        self.m_time = dict[@"createdAt"];
    }
    return self;
}

+ (ActivityItem*)initWithDictionary:(NSDictionary *)dict {
    ActivityItem *item = [[ActivityItem alloc] initWithDictionary:dict];
    return item;
}
@end
