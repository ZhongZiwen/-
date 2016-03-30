//
//  RemindModel.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "RemindModel.h"

@implementation RemindModel

- (RemindModel*)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.user_name = [[dict objectForKey:@"creator"] objectForKey:@"name"];
        self.user_icon = [[dict objectForKey:@"creator"] objectForKey:@"icon"];
        self.user_uid = [[dict objectForKey:@"creator"] objectForKey:@"id"];
        
        self.m_content = [dict objectForKey:@"content"];
        self.m_operate = [dict objectForKey:@"operate"];
        self.m_createdTime = [dict objectForKey:@"createdDate"];
        self.m_type = [[dict objectForKey:@"type"] integerValue];
        self.m_noticeType = [[dict objectForKey:@"type"] integerValue];
        
        self.isRead = [NSString stringWithFormat:@"%@", [dict objectForKey:@"isRead"]];
        self.remindID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
        self.dataId = [[dict objectForKey:@"dataId"] integerValue];
    }
    return self;
}

+ (RemindModel*)initWithDictionary:(NSDictionary *)dict {
    RemindModel *model = [[RemindModel alloc] initWithDictionary:dict];
    return model;
}
@end
