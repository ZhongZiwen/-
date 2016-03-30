//
//  MRCommentModel.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/1.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MRCommentModel.h"

@implementation MRCommentModel

- (MRCommentModel*)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.user_name = [[dict objectForKey:@"user"] objectForKey:@"name"];
        self.user_uid = [[dict objectForKey:@"user"] objectForKey:@"uid"];
        self.user_icon = [[dict objectForKey:@"user"] objectForKey:@"icon"];
        self.m_content = [dict objectForKey:@"content"];
        self.m_id = [dict objectForKey:@"id"];
        self.m_time = [dict objectForKey:@"date"];
    }
    return self;
}

+ (MRCommentModel*)initWithDictionary:(NSDictionary *)dict {
    MRCommentModel *model = [[MRCommentModel alloc] initWithDictionary:dict];
    return model;
}

@end
