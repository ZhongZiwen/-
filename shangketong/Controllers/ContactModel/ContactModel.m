//
//  ContactModel.m
//  shangketong
//
//  Created by 蒋 on 15/9/1.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ContactModel.h"
#import "pinyin.h"

@implementation ContactModel

+ (ContactModel *)initWithDataSource:(NSDictionary *)dict {
    ContactModel *model = [[ContactModel alloc] initWithDataSource:dict];
    return model;
}
- (ContactModel *)initWithDataSource:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _contactName = [dict safeObjectForKey:@"name"];
        
        if ([[dict allKeys] containsObject:@"depart"] && [CommonFuntion checkNullForValue:[dict objectForKey:@"depart"]]) {
            _departmentName = [dict objectForKey:@"depart"];
        }else {
            _departmentName = @"";
        }
        if ([[dict allKeys] containsObject:@"position"] &&  [CommonFuntion checkNullForValue:[dict objectForKey:@"position"]]) {
            _positionName = [dict objectForKey:@"position"];
        } else {
            _positionName = @"";
        }

        if ([[dict allKeys] containsObject:@"icon"]) {
            _imgHeaderName = [dict safeObjectForKey:@"icon"];
        } else if ([[dict allKeys] containsObject:@"images"]) {
            _imgHeaderName = [dict safeObjectForKey:@"images"];
        }
        
        _userID = [[dict safeObjectForKey:@"id"] integerValue];
        _state = [[dict safeObjectForKey:@"status"] integerValue];
    }
    return self;
}

- (NSString *)getFirstName
{
    NSString *firstName = [_contactName substringToIndex:1];
    if ([firstName canBeConvertedToEncoding:NSASCIIStringEncoding]) {   // 如果是英语
        return firstName;
    }else{  // 如果是非英语
        return [NSString stringWithFormat:@"%c", pinyinFirstLetter([firstName characterAtIndex:0])];
        //        return @"★";
    }
}

- (NSString *)getLastName
{
    if ([_contactName canBeConvertedToEncoding:NSASCIIStringEncoding]) {   // 如果是英语
        return _contactName;
    }else{  // 如果是非英语
        return [NSString stringWithFormat:@"%c", pinyinFirstLetter([_contactName characterAtIndex:0])];
    }
}

@end
