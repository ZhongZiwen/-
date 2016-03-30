//
//  AddressBookModel.m
//  shangketong
//
//  Created by sungoin-zbs on 15/5/6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AddressBookModel.h"
#import "pinyin.h"

@implementation AddressBookModel

+ (AddressBookModel*)initWithDataSource:(NSDictionary *)dict
{
    AddressBookModel *addressBook = [[AddressBookModel alloc] initWithDataSource:dict];
    return addressBook;
}

- (AddressBookModel*)initWithDataSource:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        /*
        depart 部门
        focused = 0;
        icon  头像
        name  姓名
        pinyin 姓名的拼音
        position 职位
        userId 联系人id
        mobile 手机号
        extensionNumber 分机号
        phone 电话
         */
        if ([dict objectForKey:@"id"]) {
            _m_uid = [NSString stringWithFormat:@"%@", [dict safeObjectForKey:@"id"]];
        }
        if ([dict objectForKey:@"name"]) {
            _m_name = [dict safeObjectForKey:@"name"];
        }
        if ([dict objectForKey:@"depart"]) {
            _m_depart = [dict safeObjectForKey:@"depart"];
        }
        if ([dict objectForKey:@"position"]) {
            _m_post = [dict safeObjectForKey:@"position"];
        }
        if ([dict objectForKey:@"pinyin"]) {
            _m_pinyin = [dict safeObjectForKey:@"pinyin"];
        }
        if ([dict objectForKey:@"icon"]) {
            _m_headImage = [dict safeObjectForKey:@"icon"];
        }
        if ([dict objectForKey:@"mobile"]) {
            _m_mobile = [dict safeObjectForKey:@"mobile"];
        }
        if ([dict objectForKey:@"phone"]) {
            _m_tel = [dict safeObjectForKey:@"phone"];
        }
        if ([dict objectForKey:@"extensionNumber"]) {
            _m_extensionNumber = [dict safeObjectForKey:@"extensionNumber"];
        }
        if ([dict objectForKey:@"departmentId"]) {
            _m_departId = [dict safeObjectForKey:@"departmentId"];
        }
    }
    return self;
}

- (NSString*)getFirstName
{
    NSString *firstName = [_m_name substringFromIndex:1];
    if ([firstName canBeConvertedToEncoding:NSASCIIStringEncoding]) {   // 如果是英语
        return firstName;
    }else{  // 如果是非英语
        return [NSString stringWithFormat:@"%c", pinyinFirstLetter([firstName characterAtIndex:0])];
    }
}

- (NSString*)getLastName
{
    if ([_m_name canBeConvertedToEncoding:NSASCIIStringEncoding]) {   // 如果是英语
        return _m_name;
    }else{  // 如果是非英语
        return [NSString stringWithFormat:@"%c", pinyinFirstLetter([_m_name characterAtIndex:0])];
    }
}
@end
