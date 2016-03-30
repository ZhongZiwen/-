//
//  ContactModel.h
//  shangketong
//
//  Created by 蒋 on 15/9/1.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactModel : NSObject

@property (nonatomic, strong) NSString *contactName; //联系人姓名
@property (nonatomic, strong) NSString *departmentName;
@property (nonatomic, strong) NSString *positionName;
@property (nonatomic, strong) NSString *imgHeaderName;
@property (nonatomic, assign) NSInteger state; //联系人的在职状态
@property (nonatomic, assign) NSInteger userID;

@property (nonatomic, assign) BOOL isSelect; //是否被选中
@property (nonatomic, assign) BOOL isDefault;   // 用于区分用户头像（用户导出通讯录是默认添加一个数据）

@property (nonatomic, assign) NSInteger sectionNum;
@property (nonatomic, assign) NSInteger originIndex;

+ (ContactModel *)initWithDataSource:(NSDictionary *)dict;
- (ContactModel *)initWithDataSource:(NSDictionary *)dict;

- (NSString*)getFirstName;
- (NSString*)getLastName;

@end
