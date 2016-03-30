//
//  NSDate+Utils.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSDate (Utils)

+ (NSDate *)dateWithYear:(NSInteger)year
                   month:(NSInteger)month
                     day:(NSInteger)day
                    hour:(NSInteger)hour
                  minute:(NSInteger)minute
                  second:(NSInteger)second;

+ (NSInteger)daysOffsetBetweenStartDate:(NSDate*)startDate endDate:(NSDate*)endDate;

+ (NSDate*)dateWithHour:(int)hour
                  minute:(int)minute;

/**
 * 判断一个日期是否在当前一周内（使用格里高利历）
 */
+ (BOOL)isDateThisWeek:(NSDate*)date;

#pragma mark - Data component
- (NSInteger)year;
- (NSInteger)month;
- (NSInteger)day;
- (NSInteger)hour;
- (NSInteger)minute;
- (NSInteger)second;
- (NSString*)weekday;


- (NSInteger)secondsAgo;
- (NSInteger)minutesAgo;
- (NSInteger)hoursAgo;
- (NSInteger)monthsAgo;
- (NSInteger)yearsAgo;
- (NSInteger)leftDayCount;
- (NSString *)stringDisplay_HHmm;//n秒前 / 今天 HH:mm


#pragma mark - Time string
- (NSString*)timeHourMinute;
- (NSString*)timeHourMinuteWithPrefix;
- (NSString*)timeHourMinuteWithSuffix;
- (NSString*)timeHourMinuteWithPrefix:(BOOL)enablePrefix suffix:(BOOL)enableSuffix;

#pragma mark - Date String
- (NSString*)stringTime;
- (NSString*)stringYearMonthDayHourMinuteSecond;
+ (NSString*)stringYearMonthDayWithDate:(NSDate*)date;      //date为空时返回的是当前年月日
+ (NSString*)stringLoacalDate;
- (NSString*)msgRemindStringYearMonthDay;

/** yyyy年MM月dd日*/
- (NSString*)stringYearMonthDay;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

/** yyyy-MM-dd*/
- (NSString*)stringYearMonthDayForLine;
@property (strong, nonatomic) NSDateFormatter *dateLineFormatter;

/** yy-MM-dd*/
- (NSString*)stringYearMonthDayForYY;
@property (strong, nonatomic) NSDateFormatter *dateLineYYFormatter;

/** yyyy年MM月*/
- (NSString*)stringYearMonth;
/** yyyy年MM月第x周*/
- (NSString*)stringNumberOfWeekInMonth;
@property (strong, nonatomic) NSDateFormatter *yearMonthFormatter;

/** yyyy-MM*/
- (NSString*)stringYearMonthForLine;
@property (strong, nonatomic) NSDateFormatter *yearMonthLineFormatter;

/** MM月dd日*/
- (NSString*)stringMonthDay;
@property (strong, nonatomic) NSDateFormatter *monthDayFormatter;

/** MM-dd*/
- (NSString*)stringMonthDayForLine;
@property (strong, nonatomic) NSDateFormatter *monthDayLineFormatter;

/** MM-dd HH:mm*/
- (NSString*)stringTimestampWithoutYear;
@property (strong, nonatomic) NSDateFormatter *dateWithoutYearFormatter;

/** yyyy-MM-dd HH:mm*/
- (NSString*)stringTimestamp;
@property (strong, nonatomic) NSDateFormatter *timestampFormatter;

- (NSString*)stringDateByFormat:(NSString *)foramt;

/** HH:mm*/
- (NSString*)stringHourMinute;
@property (strong, nonatomic) NSDateFormatter *hourMinuteFormatter;

#pragma mark - Date formate
+ (NSString*)dateFormatString;
+ (NSString*)timeFormatString;
+ (NSString*)timestampFormatString;
+ (NSString*)timestampFormatStringSubSeconds;

#pragma mark - Date adjust
- (NSDate*)dateByAddingDays:(NSInteger) dDays;
- (NSDate*)dateBySubtractingDays:(NSInteger) dDays;

#pragma mark - Relative dates from the date
+ (NSDate*)dateTomorrow;
+ (NSDate*)dateYesterday;
+ (NSDate*)dateWithDaysFromNow:(NSInteger) days;
+ (NSDate*)dateWithDaysBeforeNow:(NSInteger) days;
+ (NSDate*)dateWithHoursFromNow:(NSInteger) dHours;
+ (NSDate*)dateWithHoursBeforeNow:(NSInteger) dHours;
+ (NSDate*)dateWithMinutesFromNow:(NSInteger) dMinutes;
+ (NSDate*)dateWithMinutesBeforeNow:(NSInteger) dMinutes;
+ (NSDate*)dateStandardFormatTimeZeroWithDate:(NSDate *)aDate;  //标准格式的零点日期
- (NSInteger)daysBetweenCurrentDateAndDate;                     //负数为过去，正数为未来

#pragma mark - Date compare
- (BOOL)isEqualToDateIgnoringTime:(NSDate*) aDate;
- (NSString*)stringYearMonthDayCompareToday;                 //返回“今天”，“明天”，“昨天”，或年月日

#pragma mark - Date and string convert
+ (NSDate*)dateFromString:(NSString*)string;
+ (NSDate*)dateFromString:(NSString*)string withFormat:(NSString*)format;
- (NSString*)string;
- (NSString*)stringCutSeconds;


#pragma mark - 日期前后推移
// 在date日期基础上做向前推移或向后推移  年月日
+(NSDate*)getOneDate:(int)year month:(int)month day:(int)day byDate:(NSDate *)date;
/// 在date日期基础上做向前推移或向后推移 时分秒
+(NSDate*)getOneDateHour:(int)hour minute:(int)minute second:(int)second byDate:(NSDate *)date;
///设置日期的分钟
+(NSDate *)setOneDate:(NSDate *)date  Minute:(int)minute;
///设置日期的时、分钟
+(NSDate *)setOneDate:(NSDate *)date Hour:(int)hour  Minute:(int)minute;


@end
