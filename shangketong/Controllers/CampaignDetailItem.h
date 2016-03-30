//
//  CampaignDetailItem.h
//  shangketong
//
//  Created by sungoin-zjp on 15-9-7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CampaignDetailItem : NSObject

/*
 * UNKNOWN(0, "未定义类型"), //未定义类型 TEXT(1, "文本类型", CompareType.textTypes),
 * //文本类型 TEXTAREA(2," 文本区域类型"), //文本区域类型 SELECT(3,"单选类型",
 * CompareType.selectTypes), //单选类型 CHECKBOX(4,"多选类型",
 * CompareType.selectTypes), //多选类型 INT(5,"整数类型",
 * CompareType.numberTypes), //整数类型 FLOAT(6,"浮点类型",
 * CompareType.numberTypes), //浮点类型 DATE(7,"日期类型",
 * CompareType.numberTypes), //日期类型 LINE(8,"--"), //分割线类型
 * NUMBER(9,"自动编号",CompareType.textTypes), //自动编号-文本类型
 * OBJECT(10,"对象类型",CompareType.selectTypes); //对象类型
 */
@property (nonatomic, assign) NSInteger m_columnType;
@property (nonatomic, copy) NSString *m_name;
@property (nonatomic, copy) NSString *m_propertyName;
@property (nonatomic, copy) NSString *m_object;
@property (nonatomic, copy) NSString *m_result;
@property (nonatomic, assign) NSInteger m_required;          // 必填或选填
@property (nonatomic, strong) NSArray *m_selectArray;   // 单选或多选保存的数据

+ (CampaignDetailItem*)initWithDictionary:(NSDictionary*)dict;
- (CampaignDetailItem*)initWithDictionary:(NSDictionary*)dict;

@end
