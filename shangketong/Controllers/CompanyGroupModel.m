//
//  CompanyGroupModel.m
//  shangketong
//
//  Created by 蒋 on 15/10/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CompanyGroupModel.h"
#import "ContactModel.h"
#import "CommonFuntion.h"
#import "pinyin.h"

@implementation CompanyGroupModel
- (CompanyGroupModel *)initWithDictionary:(NSDictionary *)dict {
    self.contactModelArray = [NSMutableArray arrayWithCapacity:0];
    self = [super init];
    if (self) {
        self.group_id = [dict objectForKey:@"id"];
        self.group_name = [dict objectForKey:@"name"];
        self.group_images = [dict objectForKey:@"images"];
        if ([dict objectForKey:@"hasChildren"] && [[dict objectForKey:@"hasChildren"] integerValue] == 0) {
            self.isHasChildren = YES;
        } else {
            self.isHasChildren = NO;
        }
        if ([CommonFuntion checkNullForValue:[dict objectForKey:@"userViewList"]]) {
            NSArray *newArray = [dict objectForKey:@"userViewList"];
            for (NSDictionary *u_dict in newArray) {
                ContactModel *model = [ContactModel initWithDataSource:u_dict];
                [self.contactModelArray addObject:model];
            }
        }
    }
    return self;
}
+ (CompanyGroupModel *)initWithDictionary:(NSDictionary *)dict {
    CompanyGroupModel *model = [[CompanyGroupModel alloc]initWithDictionary:dict];
    return model;
}

- (NSString *)getFirstName
{
    NSString *firstName = [_group_name substringToIndex:1];
    if ([firstName canBeConvertedToEncoding:NSASCIIStringEncoding]) {   // 如果是英语
        return firstName;
    }else{  // 如果是非英语
        return [NSString stringWithFormat:@"%c", pinyinFirstLetter([firstName characterAtIndex:0])];
        //        return @"★";
    }
}

- (NSString *)getLastName
{
    if ([_group_name canBeConvertedToEncoding:NSASCIIStringEncoding]) {   // 如果是英语
        return _group_name;
    }else{  // 如果是非英语
        return [NSString stringWithFormat:@"%c", pinyinFirstLetter([_group_name characterAtIndex:0])];
    }
}

@end
