//
//  ColumnModel.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface ColumnModel : NSObject<NSCopying>

@property (strong, nonatomic) NSNumber *type;  // (101 用户)(203 公司)(501 图片)(502 电话)(503 手机)(504 地址)(505 电子邮件)
@property (strong, nonatomic) NSNumber *showWhenInit;
@property (strong, nonatomic) NSNumber *editAble;
@property (strong, nonatomic) NSNumber *fullDate;   // 是否开启时分属性 0开启 1未开启
@property (strong, nonatomic) NSNumber *columnType; // (0, "未定义类型")(1, "文本类型")(2," 文本区域类型")(3,"单选类型")(4,"多选类型")(5,"整数类型")(6,"浮点类型")(7,"日期类型")(8,"分割线类型")(9,"自动编号"--客户端不显示)(10,"对象类型")(100,表示部门)
@property (strong, nonatomic) NSNumber *required;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *propertyName;
@property (copy, nonatomic) NSString *object;
@property (strong, nonatomic) NSMutableArray *selectArray;

@property (copy, nonatomic) NSString *stringResult;
@property (strong, nonatomic) NSDate *dateResult;
@property (strong, nonatomic) User *objectResult;
@property (strong, nonatomic) NSMutableArray *arrayResult;

- (void)configResultWithDictionary:(NSDictionary*)tempDict;
@end
