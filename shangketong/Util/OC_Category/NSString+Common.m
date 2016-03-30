//
//  NSString+Common.m
//  PhoneMeeting
//
//  Created by sungoin-zbs on 15/4/21.
//  Copyright (c) 2015年 songoin. All rights reserved.
//

#import "NSString+Common.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSDate+Utils.h"
#import "CommonFunc.h"

@implementation NSString (Common)

- (NSString *)md5Str {
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (BOOL)isMobileNumber:(NSString *)mobileNum {
    NSString *phoneRegex = @"1[3|5|7|8|][0-9]{9}";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:mobileNum];
}

+ (BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (NSString*)transform:(NSString *)chinese {
    NSMutableString *pinyin = [chinese mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    return [pinyin uppercaseString];
}

- (CGSize)getSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size{
    CGSize resultSize = CGSizeZero;
    if (self.length <= 0) {
        return resultSize;
    }
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        resultSize = [self boundingRectWithSize:size
                                        options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin)
                                     attributes:@{NSFontAttributeName: font}
                                        context:nil].size;
    } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        resultSize = [self sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        //        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:self attributes:@{NSFontAttributeName:font}];
        //
        //        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        //        [paragraphStyle setLineSpacing:2.0];
        //
        //        [attributedStr addAttribute:NSParagraphStyleAttributeName
        //                              value:paragraphStyle
        //                              range:NSMakeRange(0, [self length])];
        //        resultSize = [attributedStr boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
#endif
    }
    resultSize = CGSizeMake(MIN(size.width, ceilf(resultSize.width)), MIN(size.height, ceilf(resultSize.height)));
    //    if ([self containsEmoji]) {
    //        resultSize.height += 10;
    //    }
    return resultSize;
}

- (CGFloat)getHeightWithFont:(UIFont *)font constrainedToSize:(CGSize)size{
    return [self getSizeWithFont:font constrainedToSize:size].height;
}

- (CGFloat)getWidthWithFont:(UIFont *)font constrainedToSize:(CGSize)size{
    return [self getSizeWithFont:font constrainedToSize:size].width;
}

+ (NSString*)transDateWithTimeInterval:(NSString *)longTime {
    
    NSDate *lastDate = [[NSDate alloc] initWithTimeIntervalSince1970:[longTime longLongValue] / 1000.0];
    
    NSString *dateStr;      // 年月日
    NSString *period;       // 时间段
    NSString *hour;         // 时
    
    if ([lastDate year] == [[NSDate date] year]) {  // 今年
        NSInteger days = [NSDate daysOffsetBetweenStartDate:lastDate endDate:[NSDate date]];
        if (days <= 2) {    // 判断是否为今天或昨天
            dateStr = [lastDate stringYearMonthDayCompareToday];
        }else {     // 非今天或昨天 显示xx月xx日
            dateStr = [lastDate stringMonthDay];
        }
    }else { // 非今年
        dateStr = [lastDate stringYearMonthDay];
    }
    
    if ([lastDate hour]>=5 && [lastDate hour]<12) {
        period = @"上午";
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]];
    }else if ([lastDate hour]>=12 && [lastDate hour]<=18){
        period = @"下午";
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]-12];
    }else if ([lastDate hour]>18 && [lastDate hour]<=23){
        period = @"晚上";
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]-12];
    }else{
        period = @"凌晨";
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]];
    }
    return [NSString stringWithFormat:@"%@ %@ %@:%02d",dateStr,period,hour,(int)[lastDate minute]];
}

+ (NSString*)msgRemindTransDateWithTimeInterval:(NSString *)longTime {
    NSDate *lastDate = [[NSDate alloc] initWithTimeIntervalSince1970:[longTime longLongValue] / 1000.0];
    
    if ([NSDate isDateThisWeek:lastDate]) { // 跟当天为同一个星期
        
        NSInteger chaDay = [lastDate daysBetweenCurrentDateAndDate];
        if (chaDay == 0) {  // 今天
            return [NSString stringWithFormat:@"%02d:%02d", (int)[lastDate hour], (int)[lastDate minute]];
        }else if (chaDay == -1){    // 昨天
            return @"昨天";
        }else{  // 显示星期几
            return [lastDate weekday];
        }
    }else {
        return [lastDate stringYearMonthDayForYY];
    }
}

+ (NSString*)msgRemindTransDateWithDate:(NSDate *)lastDate {
    //    NSDate *lastDate = [[NSDate alloc] initWithTimeIntervalSince1970:[longTime longLongValue] / 1000.0];
    
    //    NSLog(@"lastDate:%@",lastDate);
    if ([NSDate isDateThisWeek:lastDate]) { // 跟当天为同一个星期
        
        NSInteger chaDay = [lastDate daysBetweenCurrentDateAndDate];
        //        NSLog(@"chaDay:%ti",chaDay);
        if (chaDay == 0) {  // 今天
            return [NSString stringWithFormat:@"%02d:%02d", (int)[lastDate hour], (int)[lastDate minute]];
        }else if (chaDay == -1){    // 昨天
            return @"昨天";
        }else{  // 显示星期几
            return [CommonFunc getWeekdayWithDate:lastDate];
        }
    }else if ([[CommonFunc dateToString:lastDate Format:@"yyyy"] isEqualToString:[CommonFunc dateToString:[NSDate date] Format:@"yyyy"]]){
        ///同一年
        return [lastDate stringMonthDay];
    }
    else {
        return [lastDate msgRemindStringYearMonthDay];
    }
}

+ (NSString*)msgRemindApprovalTransDateWithTimeInterval:(NSString *)longTime {
    NSDate *lastDate = [[NSDate alloc] initWithTimeIntervalSince1970:[longTime longLongValue] / 1000.0];
    
    NSString *dateStr;      // 年月日
    
    NSInteger days = [NSDate daysOffsetBetweenStartDate:lastDate endDate:[NSDate date]];
    NSLog(@"时间差值%ld", days);
    if (days <= 2) {
        dateStr = [lastDate stringYearMonthDayCompareToday];
    }else {
        dateStr = [lastDate stringMonthDay];
    }
    
    return [NSString stringWithFormat:@"%@ %02d:%02d", dateStr, [lastDate hour], [lastDate minute]];
}

+ (NSString*)transDateToYearMonthDayWithTimeInterval:(NSString *)longTime {
    NSDate *lastDate = [[NSDate alloc] initWithTimeIntervalSince1970:[longTime longLongValue] / 1000.0];
    return [lastDate stringYearMonthDay];
//    return [lastDate msgRemindStringYearMonthDay];
}

+ (NSString*)transDateWithTimeInterval:(NSString *)longTime andCustomFormate:(NSString *)formate {
    if ([longTime longLongValue]) {
        NSDate *lastDate = [[NSDate alloc] initWithTimeIntervalSince1970:[longTime longLongValue] / 1000.0];
        return [lastDate stringYearMonthDayForLine];
//        return [NSDate dateWithDateFormate:formate andDate:lastDate];
    }
    return @"";
}

+ (NSString*)transDateWithTimeInterval:(NSString *)longTime andFormate:(NSString *)formate {
    if ([longTime longLongValue]) {
        NSDate *lastDate = [[NSDate alloc] initWithTimeIntervalSince1970:[longTime longLongValue] / 1000.0];
        return [lastDate stringDateByFormat:formate];
        //        return [NSDate dateWithDateFormate:formate andDate:lastDate];
    }
    return @"";
}

+ (NSString*)transDateToWeekWithTimeInterval:(NSString *)longTime {
    
    NSDate *lastDate = [[NSDate alloc] initWithTimeIntervalSince1970:[longTime longLongValue] / 1000.0];

    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    
    //设置周日为周首日
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];
    BOOL ok = [calendar rangeOfUnit:NSWeekCalendarUnit startDate:&beginDate interval:&interval forDate:lastDate];
    
    /*
     NSDayCalendarUnit
     NSWeekCalendarUnit
     NSYearCalendarUnit
     NSMonthCalendarUnit
     */
    if (ok) {
        endDate = [beginDate dateByAddingTimeInterval:interval-1];
    }else {
        return @"";
    }
    
    NSString *beginStr = [beginDate stringYearMonthDayForLine];
    NSString *endStr = [endDate stringYearMonthDayForLine];
    
    return [NSString stringWithFormat:@"%@~%@", beginStr, endStr];
}

+ (NSString*)transDateToWeekWithCurrentDate {
    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    
    //设置周日为周首日
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];
    BOOL ok = [calendar rangeOfUnit:NSWeekCalendarUnit startDate:&beginDate interval:&interval forDate:[NSDate date]];
    
    /*
     NSDayCalendarUnit
     NSWeekCalendarUnit
     NSYearCalendarUnit
     NSMonthCalendarUnit
     */
    if (ok) {
        endDate = [beginDate dateByAddingTimeInterval:interval-1];
    }else {
        return @"";
    }
    
    NSString *beginStr = [beginDate stringYearMonthDayForLine];
    NSString *endStr = [endDate stringYearMonthDayForLine];
    
    return [NSString stringWithFormat:@"%@~%@", beginStr, endStr];
}

+ (NSString*)transDateToNumberOfWeekInMonthWithTimeInterval:(NSString *)longTime {
    /*
     NSDate *lastDate = [[NSDate alloc] initWithTimeIntervalSince1970:[longTime longLongValue] / 1000.0];
     
     NSCalendar *calendar = [NSCalendar currentCalendar];
     [calendar setFirstWeekday:1];
     
     NSDateComponents *compt = [calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:lastDate];
     
     NSDate *date = [calendar dateFromComponents:compt];
     
     int count = [calendar ordinalityOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
     
     return [NSString stringWithFormat:@"%@第%d周", [NSDate dateWithDateFormate:@"yyyy年MM月" andDate:lastDate], count];
     */
    NSDate *lastDate = [[NSDate alloc] initWithTimeIntervalSince1970:[longTime longLongValue] / 1000.0];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:1];
    
    int count = [calendar ordinalityOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:lastDate];
    
    return [NSString stringWithFormat:@"%@第%d周", [lastDate stringYearMonth], count];
}

+ (NSString*)transDateFromCurrentDateWithDayCount:(NSInteger)days {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *compt = [calendar components:NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
    
    [compt setDay:[compt day] + days];
    NSDate *m_date = [calendar dateFromComponents:compt];
    
    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    
    //设置周一为周首日
    [calendar setFirstWeekday:2];
    BOOL ok = [calendar rangeOfUnit:NSWeekCalendarUnit startDate:&beginDate interval:&interval forDate:m_date];

    if (ok) {
        endDate = [beginDate dateByAddingTimeInterval:interval-1];
    }else {
        return @"";
    }
    
    NSString *beginStr = [beginDate stringYearMonthDayForLine];
    NSString *endStr = [endDate stringYearMonthDayForLine];
    
    return [NSString stringWithFormat:@"%@~%@", beginStr, endStr];
}

+ (NSString*)sizeDisplayWithByte:(CGFloat)sizeOfByte {
    NSString *sizeDisplayStr;
    if (sizeOfByte < 1024) {
        sizeDisplayStr = [NSString stringWithFormat:@"%.2f bytes", sizeOfByte];
    }else{
        CGFloat sizeOfKB = sizeOfByte/1024;
        if (sizeOfKB < 1024) {
            sizeDisplayStr = [NSString stringWithFormat:@"%.2f KB", sizeOfKB];
        }else{
            CGFloat sizeOfM = sizeOfKB/1024;
            if (sizeOfM < 1024) {
                sizeDisplayStr = [NSString stringWithFormat:@"%.2f M", sizeOfM];
            }else{
                CGFloat sizeOfG = sizeOfKB/1024;
                sizeDisplayStr = [NSString stringWithFormat:@"%.2f G", sizeOfG];
            }
        }
    }
    return sizeDisplayStr;
}

- (NSString *)trimWhitespace {
    NSMutableString *str = [self mutableCopy];
    CFStringTrimWhitespace((__bridge CFMutableStringRef)str);
    return str;
}

- (BOOL)isEmpty {
    return [[self trimWhitespace] isEqualToString:@""];
}

@end
