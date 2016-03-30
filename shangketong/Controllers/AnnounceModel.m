//
//  AnnounceModel.m
//  shangketong
//
//  Created by 蒋 on 15/9/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AnnounceModel.h"
#import "CommonFuntion.h"
@implementation AnnounceModel

- (AnnounceModel *)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.title = [dict safeObjectForKey:@"title"];
        self.content = [dict safeObjectForKey:@"content"];
        if ([dict objectForKey:@"createDate"]) {
           self.createDate = [CommonFuntion getStringForTime:[[dict safeObjectForKey:@"createDate"] longLongValue]];
        }
        
        self.createUserName = [dict safeObjectForKey:@"createUserName"];
        self.deptName = [dict safeObjectForKey:@"deptName"];
        self.announce_ID = [NSString stringWithFormat:@"%@",[dict safeObjectForKey:@"id"]];
        self.isHasRead = [NSString stringWithFormat:@"%@", [dict safeObjectForKey:@"isHasRead"]];
        self.typeName = [dict safeObjectForKey:@"typeName"];
    }
    return self;
}

+ (AnnounceModel *)initWithDictionary:(NSDictionary *)dict {
    AnnounceModel *model = [[AnnounceModel alloc] initWithDictionary:dict];
    return model;
}

@end
