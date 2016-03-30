//
//  NSDate+Utils.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "NSDate+Utils.h"
#import <objc/runtime.h>
#import "NSDate+Helper.h"
#import "SKTYearDateFormatter.h"

#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

#define D_MINUTE 60
#define D_HOUR   3600
#define D_DAY    86400
#define D_WEEK   604800
#define D_YEAR   31556926

@implementation NSDate (Utils)

+ (NSDate *)dateWithYear:(NSInteger)year
                   month:(NSInteger)month
                     day:(NSInteger)day
                    hour:(NSInteger)hour
                  minute:(NSInteger)minute
                  second:(NSInteger)second{
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSTimeZone *systemTimeZone = [NSTimeZone systemTimeZone];
    
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setCalendar:gregorian];
    [dateComps setYear:year];
    [dateComps setMonth:month];
    [dateComps setDay:day];
    [dateComps setTimeZone:systemTimeZone];
    [dateComps setHour:hour];
    [dateComps setMinute:minute];
    [dateComps setSecond:second];
    
    return [dateComps date];
}

+ (NSInteger)daysOffsetBetweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned int unitFlags = NSDayCalendarUnit;
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:startDate  toDate:endDate  options:0];
    NSInteger days = [comps day];
    return days;
}

+ (NSDate*)dateWithHour:(int)hour minute:(int)minute {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    [components setHour:hour];
    [components setMinute:minute];
    NSDate *newDate = [calendar dateFromComponents:components];
    return newDate;
}

+ (BOOL)isDateThisWeek:(NSDate *)date {
    NSDate *start;
    NSTimeInterval extends;
    
    NSCalendar *cal = [NSCalendar autoupdatingCurrentCalendar];
    NSDate *today = [NSDate date];
    
    BOOL success = [cal rangeOfUnit:NSWeekCalendarUnit startDate:&start interval: &extends forDate:today];
    
    if(!success)
        return NO;
    
    NSTimeInterval dateInSecs = [date timeIntervalSinceReferenceDate];
    NSTimeInterval dayStartInSecs = [start timeIntervalSinceReferenceDate];
    
    if(dateInSecs > dayStartInSecs && dateInSecs < (dayStartInSecs+extends)){
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark - Data component
- (NSInteger)year
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:self];
    return [dateComponents year];
}

- (NSInteger)month
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:self];
    return [dateComponents month];
}

- (NSInteger)day
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:self];
    return [dateComponents day];
}

- (NSInteger)hour
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit  fromDate:self];
    return [dateComponents hour];
}

- (NSInteger)minute
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit  fromDate:self];
    return [dateComponents minute];
}

- (NSInteger)second
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit  fromDate:self];
    return [dateComponents second];
}

- (NSString *)weekday
{
    NSCalendar*calendar = [NSCalendar currentCalendar];
    NSDateComponents*comps;
    
    NSDate *date = [NSDate date];
    comps =[calendar components:(NSWeekCalendarUnit | NSWeekdayCalendarUnit |NSWeekdayOrdinalCalendarUnit)
                       fromDate:date];
    NSInteger weekday = [comps weekday]; // 星期几（注意，周日是“1”，周一是“2”。。。。）
    NSString *week = @"";
    switch (weekday) {
        case 1:
            week = @"星期日";
            break;
        case 2:
            week = @"星期一";
            break;
        case 3:
            week = @"星期二";
            break;
        case 4:
            week = @"星期三";
            break;
        case 5:
            week = @"星期四";
            break;
        case 6:
            week = @"星期五";
            break;
        case 7:
            week = @"星期六";
            break;
            
        default:
            break;
    }
    
    return week;
}

- (NSInteger)secondsAgo{
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:(NSSecondCalendarUnit)
                                               fromDate:self
                                                 toDate:[NSDate date]
                                                options:0];
    return [components second];
}
- (NSInteger)minutesAgo{
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:(NSMinuteCalendarUnit)
                                               fromDate:self
                                                 toDate:[NSDate date]
                                                options:0];
    return [components minute];
}
- (NSInteger)hoursAgo{
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit)
                                               fromDate:self
                                                 toDate:[NSDate date]
                                                options:0];
    return [components hour];
}
- (NSInteger)monthsAgo{
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:(NSMonthCalendarUnit)
                                               fromDate:self
                                                 toDate:[NSDate date]
                                                options:0];
    return [components month];
}

- (NSInteger)yearsAgo{
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit)
                                               fromDate:self
                                                 toDate:[NSDate date]
                                                options:0];
    return [components year];
}

- (NSInteger)leftDayCount{
    NSDate *today = [NSDate dateFromString:[[NSDate date] stringWithFormat:@"yyyy-MM-dd"] withFormat:@"yyyy-MM-dd"];//时分清零
    NSDate *selfCopy = [NSDate dateFromString:[self stringWithFormat:@"yyyy-MM-dd"] withFormat:@"yyyy-MM-dd"];//时分清零
    
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit)
                                               fromDate:today
                                                 toDate:selfCopy
                                                options:0];
    return [components day];
}

- (NSString *)stringDisplay_HHmm{
    NSString *displayStr = @"";
    if ([self year] != [[NSDate date] year]) {
        displayStr = [self stringWithFormat:@"yy-MM-dd HH:mm"];
    }else if ([self leftDayCount] != 0){
        displayStr = [self stringWithFormat:@"MM-dd HH:mm"];
    }else if ([self hoursAgo] > 0){
        displayStr = [self stringWithFormat:@"今天 HH:mm"];
    }else if ([self minutesAgo] > 0){
        displayStr = [NSString stringWithFormat:@"%ld 分钟前", (long)[self minutesAgo]];
    }else if ([self secondsAgo] > 10){
        displayStr = [NSString stringWithFormat:@"%ld 秒前", (long)[self secondsAgo]];
    }else{
        displayStr = @"刚刚";
    }
    return displayStr;
}

#pragma mark - Time string
- (NSString *)timeHourMinute
{
    
    return [self timeHourMinuteWithPrefix:NO suffix:NO];
}

- (NSString *)timeHourMinuteWithPrefix
{
    return [self timeHourMinuteWithPrefix:YES suffix:NO];
}

- (NSString *)timeHourMinuteWithSuffix
{
    return [self timeHourMinuteWithPrefix:NO suffix:YES];
}

- (NSString *)timeHourMinuteWithPrefix:(BOOL)enablePrefix suffix:(BOOL)enableSuffix
{
    NSDateFormatter *formatter = [[self class] sharedDateFormatter];
    [formatter setDateFormat:@"HH:mm"];
    NSString *timeStr = [formatter stringFromDate:self];
    if (enablePrefix) {
        timeStr = [NSString stringWithFormat:@"%@%@",([self hour] > 12 ? @"下午" : @"上午"),timeStr];
    }
    if (enableSuffix) {
        timeStr = [NSString stringWithFormat:@"%@%@",([self hour] > 12 ? @"下午" : @"上午"),timeStr];
    }
    return timeStr;
}

- (NSString*)msgRemindStringYearMonthDay {
    return [NSDate msgRemindStringYearMonthDayWithDate:self];
}


+ (NSString*)msgRemindStringYearMonthDayWithDate:(NSDate*)date {
    if (date == nil) {
        date = [NSDate date];
    }
    SKTYearDateFormatter *formatter = [SKTYearDateFormatter sharedFormatter];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *str = [formatter stringFromDate:date];
    return str;
}

#pragma mark - Date String
- (NSString *)stringTime
{
    NSDateFormatter *formatter = [[self class] sharedDateFormatter];
    [formatter setDateFormat:@"HH:mm"];
    NSString *str = [formatter stringFromDate:self];
    return str;
}

+ (NSString *)dateMonthDayWithDate:(NSDate *)date
{
    if (date == nil) {
        date = [NSDate date];
    }
    
    NSDateFormatter *formatter = [[self class] sharedDateFormatter];
    [formatter setDateFormat:@"MM月dd日"];
    NSString *str = [formatter stringFromDate:date];
    return str;
}

- (NSString *)stringYearMonthDayHourMinuteSecond
{
    NSDateFormatter *formatter = [[self class] sharedDateFormatter];
    [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
    NSString *str = [formatter stringFromDate:self];
    return str;
    
}

+ (NSString *)stringLoacalDate
{
    NSDateFormatter *formatter = [[self class] sharedDateFormatter];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter  setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    NSString *dateStr = [formatter stringFromDate:localeDate];
    
    return dateStr;
}

+ (NSString *)stringYearMonthDayWithDate:(NSDate *)date
{
    if (date == nil) {
        date = [NSDate date];
    }
    NSDateFormatter *formatter = [[self class] sharedDateFormatter];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    NSString *str = [formatter stringFromDate:date];
    return str;
}

static char dateFormatterKey, dateLineFormatterKey, dateLineYYFormatterKey, yearMonthFormatterKey, yearMonthLineFormatterKey, dateWithoutYearFormatterKey, timestampFormatterKey, monthDayFormatterKey, monthDayLineFormatterKey, hourMinuteFormatterKey;

#pragma mark - DateFormatter

/*
- (void)setDateFormatter:(NSDateFormatter *)dateFormatter {
    [self willChangeValueForKey:@"dateFormatterKey"];
    objc_setAssociatedObject(self, &dateFormatterKey, dateFormatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"dateFormatterKey"];
}

- (NSDateFormatter*)dateFormatter {
    return objc_getAssociatedObject(self, &dateFormatterKey);
}

- (void)setDateLineFormatter:(NSDateFormatter *)dateLineFormatter {
    [self willChangeValueForKey:@"dateLineFormatterKey"];
    objc_setAssociatedObject(self, &dateLineFormatterKey, dateLineFormatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"dateLineFormatterKey"];
}

- (NSDateFormatter*)dateLineFormatter {
    return objc_getAssociatedObject(self, &dateLineFormatterKey);
}

- (void)setDateLineYYFormatter:(NSDateFormatter *)dateLineYYFormatter {
    [self willChangeValueForKey:@"dateLineYYFormatterKey"];
    objc_setAssociatedObject(self, &dateLineYYFormatterKey, dateLineYYFormatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"dateLineYYFormatterKey"];
}

- (NSDateFormatter*)dateLineYYFormatter {
    return objc_getAssociatedObject(self, &dateLineYYFormatterKey);
}

- (void)setYearMonthFormatter:(NSDateFormatter *)yearMonthFormatter {
    [self willChangeValueForKey:@"yearMonthFormatterKey"];
    objc_setAssociatedObject(self, &yearMonthFormatterKey, yearMonthFormatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"yearMonthFormatterKey"];
}

- (NSDateFormatter*)yearMonthFormatter {
    return objc_getAssociatedObject(self, &yearMonthFormatterKey);
}

- (void)setYearMonthLineFormatter:(NSDateFormatter *)yearMonthLineFormatter {
    [self willChangeValueForKey:@"yearMonthLineFormatterKey"];
    objc_setAssociatedObject(self, &yearMonthLineFormatterKey, yearMonthLineFormatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"yearMonthLineFormatterKey"];
}

- (NSDateFormatter*)yearMonthLineFormatter {
    return objc_getAssociatedObject(self, &yearMonthLineFormatterKey);
}

- (void)setMonthDayFormatter:(NSDateFormatter *)monthDayFormatter {
    [self willChangeValueForKey:@"monthDayFormatterKey"];
    objc_setAssociatedObject(self, &monthDayFormatterKey, monthDayFormatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"monthDayFormatterKey"];
}

- (NSDateFormatter*)monthDayFormatter {
    return objc_getAssociatedObject(self, &monthDayFormatterKey);
}

- (void)setMonthDayLineFormatter:(NSDateFormatter *)monthDayLineFormatter {
    [self willChangeValueForKey:@"monthDayLineFormatterKey"];
    objc_setAssociatedObject(self, &monthDayLineFormatterKey, monthDayLineFormatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"monthDayLineFormatterKey"];
}

- (NSDateFormatter*)monthDayLineFormatter {
    return objc_getAssociatedObject(self, &monthDayLineFormatterKey);
}

- (void)setDateWithoutYearFormatter:(NSDateFormatter *)dateWithoutYearFormatter {
    [self willChangeValueForKey:@"dateWithoutYearFormatterKey"];
    objc_setAssociatedObject(self, &dateWithoutYearFormatterKey, dateWithoutYearFormatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"dateWithoutYearFormatterKey"];
}

- (NSDateFormatter*)dateWithoutYearFormatter {
    return objc_getAssociatedObject(self, &dateWithoutYearFormatterKey);
}

- (void)setTimestampFormatter:(NSDateFormatter *)timestampFormatter {
    [self willChangeValueForKey:@"timestampFormatterKey"];
    objc_setAssociatedObject(self, &timestampFormatterKey, timestampFormatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"timestampFormatterKey"];
}

- (NSDateFormatter*)timestampFormatter {
    return objc_getAssociatedObject(self, &timestampFormatterKey);
}

- (void)setHourMinuteFormatter:(NSDateFormatter *)hourMinuteFormatter {
    [self willChangeValueForKey:@"hourMinuteFormatterKey"];
    objc_setAssociatedObject(self, &hourMinuteFormatterKey, hourMinuteFormatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"hourMinuteFormatterKey"];
}

- (NSDateFormatter*)hourMinuteFormatter {
    return objc_getAssociatedObject(self, &hourMinuteFormatterKey);
}

 */

- (NSString*)stringYearMonthDay {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    return [dateFormatter stringFromDate:self];
}


- (NSString*)stringDateByFormat:(NSString *)foramt {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:foramt];
    return [dateFormatter stringFromDate:self];
}

- (NSString*)stringYearMonthDayForLine {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter stringFromDate:self];
}

- (NSString*)stringYearMonthDayForYY {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yy-MM-dd"];
    return [dateFormatter stringFromDate:self];
}

- (NSString*)stringYearMonth {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月"];
    return [dateFormatter stringFromDate:self];
}

- (NSString*)stringNumberOfWeekInMonth {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月"];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];
    
    int count = [calendar ordinalityOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:self];
    
    return [NSString stringWithFormat:@"%@第%d周", [dateFormatter stringFromDate:self], count];
}

- (NSString*)stringYearMonthForLine {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    return [dateFormatter stringFromDate:self];
}

- (NSString*)stringMonthDay {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM月dd日"];
    return [dateFormatter stringFromDate:self];
}

- (NSString*)stringMonthDayForLine {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd"];
    return [dateFormatter stringFromDate:self];
}

- (NSString*)stringTimestampWithoutYear {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    return [dateFormatter stringFromDate:self];
}

- (NSString*)stringTimestamp {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [dateFormatter stringFromDate:self];
}

- (NSString*)stringHourMinute {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    return [dateFormatter stringFromDate:self];
}

/*
- (NSString*)stringYearMonthDay {
    if (!self.dateFormatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
        self.dateFormatter = dateFormatter;
    }
    return [self.dateFormatter stringFromDate:self];
}


- (NSString*)stringDateByFormat:(NSString *)foramt {
    if (!self.dateLineFormatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:foramt];
        self.dateLineFormatter = dateFormatter;
    }
    return [self.dateLineFormatter stringFromDate:self];
}

- (NSString*)stringYearMonthDayForLine {
    if (!self.dateLineFormatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        self.dateLineFormatter = dateFormatter;
    }
    return [self.dateLineFormatter stringFromDate:self];
}

- (NSString*)stringYearMonthDayForYY {
    if (!self.dateLineYYFormatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yy-MM-dd"];
        self.dateLineYYFormatter = dateFormatter;
    }
    return [self.dateLineYYFormatter stringFromDate:self];
}

- (NSString*)stringYearMonth {
    if (!self.yearMonthFormatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy年MM月"];
        self.yearMonthFormatter = dateFormatter;
    }
    return [self.yearMonthFormatter stringFromDate:self];
}

- (NSString*)stringNumberOfWeekInMonth {
    if (!self.yearMonthFormatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy年MM月"];
        self.yearMonthFormatter = dateFormatter;
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];
    
    int count = [calendar ordinalityOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:self];
    
    return [NSString stringWithFormat:@"%@第%d周", [self.yearMonthFormatter stringFromDate:self], count];
}

- (NSString*)stringYearMonthForLine {
    if (!self.yearMonthLineFormatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM"];
        self.yearMonthLineFormatter = dateFormatter;
    }
    return [self.yearMonthLineFormatter stringFromDate:self];
}

- (NSString*)stringMonthDay {
    if (!self.monthDayFormatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM月dd日"];
        self.monthDayFormatter = dateFormatter;
    }
    return [self.monthDayFormatter stringFromDate:self];
}

- (NSString*)stringMonthDayForLine {
    if (!self.monthDayLineFormatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd"];
        self.monthDayLineFormatter = dateFormatter;
    }
    return [self.monthDayLineFormatter stringFromDate:self];
}

- (NSString*)stringTimestampWithoutYear {
    if (!self.dateWithoutYearFormatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
        self.dateWithoutYearFormatter = dateFormatter;
    }
    return [self.dateWithoutYearFormatter stringFromDate:self];
}

- (NSString*)stringTimestamp {
    if (!self.timestampFormatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        self.timestampFormatter = dateFormatter;
    }
    return [self.timestampFormatter stringFromDate:self];
}

- (NSString*)stringHourMinute {
    if (!self.hourMinuteFormatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        self.hourMinuteFormatter = dateFormatter;
    }
    return [self.hourMinuteFormatter stringFromDate:self];
}
 
 */

#pragma mark - Date formate
+ (NSString *)dateFormatString {
    return @"yyyy年MM月dd日";
}

+ (NSString *)timeFormatString {
    return @"HH:mm";
}

+ (NSString *)timestampFormatString {
    return @"yyyy年MM月dd日 HH:mm:ss";
}

+ (NSString *)timestampFormatStringSubSeconds
{
    return @"yyyy年MM月dd日 HH:mm";
}

#pragma mark - Date adjust
- (NSDate *) dateByAddingDays: (NSInteger) dDays
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_DAY * dDays;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) dateBySubtractingDays: (NSInteger) dDays
{
    return [self dateByAddingDays: (dDays * -1)];
}

#pragma mark - Relative dates from the date
+ (NSDate *) dateWithDaysFromNow: (NSInteger) days
{
    // Thanks, Jim Morrison
    return [[NSDate date] dateByAddingDays:days];
}

+ (NSDate *) dateWithDaysBeforeNow: (NSInteger) days
{
    // Thanks, Jim Morrison
    return [[NSDate date] dateBySubtractingDays:days];
}

+ (NSDate *) dateTomorrow
{
    return [NSDate dateWithDaysFromNow:1];
}

+ (NSDate *) dateYesterday
{
    return [NSDate dateWithDaysBeforeNow:1];
}

+ (NSDate *) dateWithHoursFromNow: (NSInteger) dHours
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) dateWithHoursBeforeNow: (NSInteger) dHours
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) dateWithMinutesFromNow: (NSInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) dateWithMinutesBeforeNow: (NSInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+ (NSDate *) dateStandardFormatTimeZeroWithDate: (NSDate *) aDate{
    NSString *str = [[NSDate stringYearMonthDayWithDate:aDate]stringByAppendingString:@" 00:00:00"];
    NSDate *date = [NSDate dateFromString:str];
    return date;
}

- (NSInteger) daysBetweenCurrentDateAndDate
{
    //只取年月日比较
    NSDate *dateSelf = [NSDate dateStandardFormatTimeZeroWithDate:self];
    NSTimeInterval timeInterval = [dateSelf timeIntervalSince1970];
    NSDate *dateNow = [NSDate dateStandardFormatTimeZeroWithDate:nil];
    NSTimeInterval timeIntervalNow = [dateNow timeIntervalSince1970];
    
    NSTimeInterval cha = timeInterval - timeIntervalNow;
    CGFloat chaDay = cha / 86400.0;
    NSInteger day = chaDay * 1;
    return day;
}

#pragma mark - Date compare
- (BOOL) isEqualToDateIgnoringTime: (NSDate *) aDate
{
    NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
    return ((components1.year == components2.year) &&
            (components1.month == components2.month) &&
            (components1.day == components2.day));
}

- (NSString *)stringYearMonthDayCompareToday
{
    NSString *str;
    NSInteger chaDay = [self daysBetweenCurrentDateAndDate];
    if (chaDay == 0) {
        str = @"今天";
    }else if (chaDay == 1){
        str = @"明天";
    }else if (chaDay == -1){
        str = @"昨天";
    }else{
        str = [self stringYearMonthDayForLine];
    }
    
    return str;
}

#pragma mark - Date and string convert
+ (NSDate *)dateFromString:(NSString *)string {
    return [NSDate dateFromString:string withFormat:[NSDate dbFormatString]];
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format {
    NSDateFormatter *inputFormatter = [[self class] sharedDateFormatter];
    [inputFormatter setDateFormat:format];
    NSDate *date = [inputFormatter dateFromString:string];
    return date;
}

- (NSString *)string {
    return [self stringWithFormat:[NSDate dbFormatString]];
}

- (NSString *)stringCutSeconds
{
    return [self stringWithFormat:[NSDate timestampFormatStringSubSeconds]];
}

- (NSString *)stringWithFormat:(NSString *)format {
    NSDateFormatter *outputFormatter = [[self class] sharedDateFormatter];
    [outputFormatter setDateFormat:format];
    NSString *timestamp_str = [outputFormatter stringFromDate:self];
    return timestamp_str;
}

+ (NSString *)dbFormatString {
    return [NSDate timestampFormatString];
}



// 在date日期基础上做向前推移或向后推移  年月日
+(NSDate*)getOneDate:(int)year month:(int)month day:(int)day byDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = nil;
    comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setYear:year];
    [adcomps setMonth:month];
    [adcomps setDay:day];
    NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:date options:0];
    return newdate;
}


/// 在date日期基础上做向前推移或向后推移 时分秒
+(NSDate*)getOneDateHour:(int)hour minute:(int)minute second:(int)second byDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = nil;
    comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setHour:hour];
    [adcomps setMinute:minute];
    [adcomps setSecond:second];
    NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:date options:0];
    return newdate;
}

///设置日期的分钟
+(NSDate *)setOneDate:(NSDate *)date  Minute:(int)minute{
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSTimeZone *systemTimeZone = [NSTimeZone systemTimeZone];
    
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit  fromDate:date];
    [dateComponents setCalendar:greCalendar];
    [dateComponents setTimeZone:systemTimeZone];
    [dateComponents setMinute:minute];
    [dateComponents setSecond:0];
    
    return [dateComponents date];
}


///设置日期的时、分钟
+(NSDate *)setOneDate:(NSDate *)date Hour:(int)hour  Minute:(int)minute{
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSTimeZone *systemTimeZone = [NSTimeZone systemTimeZone];
    
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit  fromDate:date];
    [dateComponents setCalendar:greCalendar];
    [dateComponents setTimeZone:systemTimeZone];
    [dateComponents setHour:hour];
    [dateComponents setMinute:minute];
    [dateComponents setSecond:0];
    
    return [dateComponents date];
}


@end
