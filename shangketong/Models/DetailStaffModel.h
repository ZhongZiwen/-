//
//  DetailStaffModel.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AddressBook;

@interface DetailStaffModel : NSObject

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber *staffLevel;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *icon;

// 用于添加成员模型转换
+ (instancetype)initWithAddressBook:(AddressBook*)item;
- (instancetype)initWithAddressBook:(AddressBook*)item;
@end
