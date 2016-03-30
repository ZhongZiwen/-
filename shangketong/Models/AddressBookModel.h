//
//  AddressBookModel.h
//  shangketong
//
//  Created by sungoin-zbs on 15/5/6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressBookModel : NSObject

@property (nonatomic, copy) NSString *m_uid;
@property (nonatomic, copy) NSString *m_name;
@property (nonatomic, copy) NSString *m_st;
@property (nonatomic, copy) NSString *m_passport;
@property (nonatomic, copy) NSString *m_headImage;
@property (nonatomic, copy) NSString *m_pinyin;
@property (nonatomic, copy) NSString *m_departId;
@property (nonatomic, copy) NSString *m_depart;
@property (nonatomic, copy) NSString *m_post;   // 岗位
@property (nonatomic, copy) NSString *m_tel;
@property (nonatomic, copy) NSString *m_mobile;
@property (nonatomic, copy) NSString *m_extensionNumber; //分机号

@property (nonatomic, assign) NSInteger sectionNum;
@property (nonatomic, assign) NSInteger originIndex;

@property (nonatomic, assign) BOOL isSelected;  // 是否被选定（用于导出通讯录）
@property (nonatomic, assign) BOOL isDefault;   // 用于区分用户头像（用户导出通讯录是默认添加一个数据）

+ (AddressBookModel*)initWithDataSource:(NSDictionary*)dict;
- (AddressBookModel*)initWithDataSource:(NSDictionary*)dict;

- (NSString*)getFirstName;
- (NSString*)getLastName;
@end
