//
//  NSString+Common.h
//  PhoneMeeting
//
//  Created by sungoin-zbs on 15/4/21.
//  Copyright (c) 2015年 songoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Common)

- (NSString *)md5Str;

/**
 * 正则判断手机号码地址格式
 */
+ (BOOL)isMobileNumber:(NSString *)mobileNum;

/**
 * 判断邮箱地址格式
 */
+ (BOOL)isValidateEmail:(NSString *)email;

/**
 * 中文转拼音
 */
+ (NSString*)transform:(NSString*)chinese;

/**
 * 计算字符串的size，返回size
 */
- (CGSize)getSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

/**
 * 计算字符串的高度，返回height
 */
- (CGFloat)getHeightWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

/**
 * 计算字符串的宽度，返回width
 */
- (CGFloat)getWidthWithFont:(UIFont *)font constrainedToSize:(CGSize)size;


/**
 * 将时间戳转换为 2012-08-10 凌晨07:09
 */
+ (NSString*)transDateWithTimeInterval:(NSString*)longTime;

/**
 * 消息中待办提醒，将时间戳转换为别的时间显示
 */
+ (NSString*)msgRemindTransDateWithTimeInterval:(NSString*)longTime;

/**
 * 消息中待办提醒，审批明细中审核时间、评论时间的转换
 */
+ (NSString*)msgRemindApprovalTransDateWithTimeInterval:(NSString*)longTime;

/**
 * 将时间戳按照指定格式转换
 */
+ (NSString*)transDateWithTimeInterval:(NSString *)longTime andCustomFormate:(NSString*)formate;

+ (NSString*)transDateWithTimeInterval:(NSString *)longTime andFormate:(NSString *)formate;

/**
 * 根据某天的时间获得所出星期的时间段
 */
+ (NSString*)transDateToWeekWithTimeInterval:(NSString*)longTime;

/**
 * 根据当天的时间获得所在星期的时间段
 */
+ (NSString*)transDateToWeekWithCurrentDate;

/**
 * 计算某个日期在所在月中是第几周
 */
+ (NSString*)transDateToNumberOfWeekInMonthWithTimeInterval:(NSString*)longTime;


+ (NSString*)transDateFromCurrentDateWithDayCount:(NSInteger)days;

/** 文件大小值的转换*/
+ (NSString *)sizeDisplayWithByte:(CGFloat)sizeOfByte;


+ (NSString*)msgRemindTransDateWithDate:(NSDate *)lastDate;

- (NSString *)trimWhitespace;
- (BOOL)isEmpty;

@end
