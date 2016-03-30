//
//  ContactsInfo.h
//  lianluozhongxin
//
//  Created by Vescky on 14-6-24.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//  联系人信息

#import <Foundation/Foundation.h>

@interface ContactsInfo : NSObject {
    
}

@property (nonatomic,copy) NSString *userId;//联系人编号
@property (nonatomic,copy) NSString *name;//姓名
@property (nonatomic,copy) NSString *jobNumber;//工号
@property (nonatomic,copy) NSString *phoneNumber;//电话
@property (nonatomic,copy) NSString *departmentNameList;//部门
@property (nonatomic,copy) NSString *departmentIdList;//部门编号

//把字典类型转换成通讯录类型
- (id)initWithDictionary:(NSDictionary*)dict;

//把通讯录类型转换成字典类型
- (NSDictionary*)toDictionary;

@end
