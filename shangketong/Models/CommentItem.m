//
//  CommentItem.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CommentItem.h"

@implementation CommentItem

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.m_content = [dict safeObjectForKey:@"content"];
        self.m_createTime = [dict safeObjectForKey:@"date"];
        self.m_id = [[dict safeObjectForKey:@"id"] integerValue];
        self.m_usersArray = [[NSArray alloc] initWithArray:[dict objectForKey:@"alts"]];
        if ([dict objectForKey:@"creator"]) {
            NSDictionary *creatorDict = [NSDictionary dictionaryWithDictionary:[dict objectForKey:@"creator"]];
            self.user_name = [creatorDict safeObjectForKey:@"name"];
            self.user_icon = [creatorDict safeObjectForKey:@"icon"];
            self.user_uid = [[creatorDict safeObjectForKey:@"id"] integerValue];
        }
    }
    return self;
}

+ (instancetype)initWithDictionary:(NSDictionary *)dict {
    CommentItem *comment = [[CommentItem alloc] initWithDictionary:dict];
    return comment;
}

@end
