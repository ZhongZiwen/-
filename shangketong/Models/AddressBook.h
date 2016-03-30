//
//  AddressBook.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XLForm.h>

@class User, FilterValue, DetailStaffModel;

@interface AddressBook : NSObject<XLFormOptionObject, NSCoding, NSCopying>

@property (strong, nonatomic) NSNumber *id;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *pinyin;
@property (copy, nonatomic) NSString *icon;
@property (copy, nonatomic) NSString *position;         // 职位
@property (copy, nonatomic) NSString *depart;           // 部门
@property (strong, nonatomic) NSNumber *focused;
@property (copy, nonatomic) NSString *mobile;
@property (copy, nonatomic) NSString *phone;            // 固话
@property (copy, nonatomic) NSString *extensionNumber;  // 分机
@property (strong, nonatomic) NSNumber *status;         // 2:已激活 3:离职 4:禁用

@property (assign, nonatomic) BOOL isSelected;          // 是否被选定（用于导出通讯录）
@property (assign, nonatomic) BOOL isDefault;           // 用于区分用户头像（用户导出通讯录是默认添加一个数据）

// 用于编辑表格时，模型的转换
+ (AddressBook*)initWithUser:(User*)user;
- (AddressBook*)initWithUser:(User*)user;

// 筛选模块中选择联系人时，模型的转换
+ (AddressBook*)initWithFilter:(FilterValue*)item;
- (AddressBook*)initWithFilter:(FilterValue*)item;

// 添加团队成员时，模型的转换
+ (AddressBook*)initWithStaff:(DetailStaffModel*)item;
- (AddressBook*)initWithStaff:(DetailStaffModel*)item;

- (NSString*)getFirstName;
+ (NSString*)keyName;
@end
