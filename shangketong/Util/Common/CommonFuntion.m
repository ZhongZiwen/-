//
//  CommonFuntion.m
//  shangketong
//
//  Created by sungoin-zjp on 15-5-20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//


#import "CommonFuntion.h"
#import "CommonConstant.h"
#import <CommonCrypto/CommonDigest.h>
#import <MBProgressHUD.h>
#import "CommonNoDataView.h"
#import "Reachability.h"
#import "UIColor+expanded.h"
#import "AddressBook.h"

#import "pinyin.h"
#import "PinYin4Objc.h"
#import "ChineseToPinyin.h"

@implementation CommonFuntion

#pragma mark - View相关


+(void)showToast:(NSString *)title inView:(UIView *)view{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = title;
    hud.margin = 10.f;
    hud.yOffset = (kScreen_Height/2)-120;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.0];
}

// 设置view的frame
+ (CGRect)setViewFrameOffset:(CGRect)frame byX:(float)x byY:(float)y ByWidth:(float) width byHeight:(float)height{
    
    CGRect newFrame = CGRectMake(frame.origin.x+x, frame.origin.y+y, frame.size.width+width, frame.size.height+height);
    return newFrame;
}

#pragma mark - 没有数据时的view
+(CommonNoDataView*)commonNoDataViewIcon:(NSString *)iconName Title:(NSString *)titleName optionBtnTitle:(NSString *)btnTitle{
    
    CommonNoDataView *commonNoDataView = [[CommonNoDataView alloc] initWithFrame:CGRectMake(0, (kScreen_Height-140)/2-80, kScreen_Width, 140)];
    
    commonNoDataView.imgName = iconName;
    commonNoDataView.labelTitle = titleName;
    commonNoDataView.btnTitle = btnTitle;
    
    return commonNoDataView;
}
//crm  搜索
+(CommonNoDataView*)CRMNoDataViewIcon:(NSString *)iconName Title:(NSString *)titleName optionBtnTitle:(NSString *)btnTitle{
    
    CommonNoDataView *commonNoDataView = [[CommonNoDataView alloc] initWithFrame:CGRectMake(0, (kScreen_Height-140)/2-80, kScreen_Width, 140)];
    
    commonNoDataView.imgName = @"";
    commonNoDataView.labelTitle = titleName;
    commonNoDataView.btnTitle = btnTitle;
    commonNoDataView.crmImgName = iconName;
    
    return commonNoDataView;
}

#pragma mark - md5加密
+(NSString *)createMD5:(NSString *)signString
{
    const char*cStr =[signString UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return[NSString stringWithFormat:
           @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
           result[0], result[1], result[2], result[3],
           result[4], result[5], result[6], result[7],
           result[8], result[9], result[10], result[11],
           result[12], result[13], result[14], result[15]
           ];
}

#pragma mark - String相关
// 字符串是否未空串 去除空格
+(BOOL)isEmptyString:(NSString *)str{
    BOOL isEmpty = TRUE;
    
    if (![[str stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        isEmpty = FALSE;
    }
    return isEmpty;
}

/// 校验字符串是否由指定的字符组成
+(BOOL)checkStringIsAllow:(NSString*)str withChar:(NSString *)allchar{
    NSScanner* scanner = [[NSScanner alloc] initWithString:str];
    NSCharacterSet* charsets = [NSCharacterSet characterSetWithCharactersInString:allchar];
    NSString* restr = @"";
    [scanner scanCharactersFromSet:charsets intoString:&restr];
    if([restr length] == [str length])
        return YES;
    return  NO;
}


///根据string  font  width 获取Size
+(CGSize)getSizeOfContents:(NSString *)content Font:(UIFont*)font withWidth:(CGFloat)width withHeight:(CGFloat)height{

    CGSize size = CGSizeMake(width, height);
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
    
    size =[content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return size;
}


#pragma mark - 日期
///获取年/月/周开始结束时间
+ (void)getDateBeginAndEndWith:(NSDate *)newDate{
    if (newDate == nil) {
        newDate = [NSDate date];
    }
    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    
    //设置周日为周首日
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:1];
    BOOL ok = [calendar rangeOfUnit:NSWeekCalendarUnit startDate:&beginDate interval:&interval forDate:newDate];
    
    /*
     NSDayCalendarUnit
     NSWeekCalendarUnit
     NSYearCalendarUnit
     NSMonthCalendarUnit
     */
    if (ok) {
        endDate = [beginDate dateByAddingTimeInterval:interval-1];
    }else {
        return;
    }
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    [myDateFormatter setDateFormat:@"yyyy.MM.dd"];
    NSString *beginString = [myDateFormatter stringFromDate:beginDate];
    NSString *endString = [myDateFormatter stringFromDate:endDate];
    
    NSString *s = [NSString stringWithFormat:@"%@-%@",beginString,endString];
    NSLog(@"getMonthBeginAndEndWith: %@",s);
}


///返回一周的第几天(周末为第一天)
+ (NSUInteger)getCurDateWeekday:(NSDate *)newDate {
    if (newDate == nil) {
        newDate = [NSDate date];
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *weekdayComponents = [calendar components:(NSWeekdayCalendarUnit) fromDate:newDate];
    return [weekdayComponents weekday];
}

//获取分钟
+ (NSUInteger)getCurDateMinute:(NSDate *)newDate{
    if (newDate == nil) {
        newDate = [NSDate date];
    }
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit  fromDate:newDate];
    
    return [dateComponents minute];
}


//获取分钟
+ (NSUInteger)getCurDateHour:(NSDate *)newDate{
    if (newDate == nil) {
        newDate = [NSDate date];
    }
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit  fromDate:newDate];
    
    return [dateComponents minute];
}

//获取日
+ (NSUInteger)getCurDateDay:(NSDate *)newDate{
    if (newDate == nil) {
        newDate = [NSDate date];
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponents = [calendar components:(NSDayCalendarUnit) fromDate:newDate];
    return [dayComponents day];
}
//获取月
+ (NSUInteger)getCurDateMonth:(NSDate *)newDate
{
    if (newDate == nil) {
        newDate = [NSDate date];
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponents = [calendar components:(NSMonthCalendarUnit) fromDate:newDate];
    return [dayComponents month];
}
//获取年
+ (NSUInteger)getCurDateYear:(NSDate *)newDate
{
    if (newDate == nil) {
        newDate = [NSDate date];
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponents = [calendar components:(NSYearCalendarUnit) fromDate:newDate];
    return [dayComponents year];
}


#pragma mark - 日期格式相关

/// 在date日期基础上做向前推移或向后推移  年月日
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
+(NSDate*)getOneDate:(int)hour minute:(int)minute second:(int)second byDate:(NSDate *)date
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

///将毫秒转换为指定格式的日期
+(NSString *)transDateWithTimeInterval:(long long )time withFormat:(NSString *)format{
    NSString *formatDate = @"";
    NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:time/1000.0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    formatDate = [dateFormatter stringFromDate:date];
    return formatDate;
}

///将日期转换为 今天 HH:mm /昨天 HH:mm / MM-DD HH:mm
+(NSString *)transDateWithFormatDate:(NSDate *)date{
    
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    NSDate *yesterday;
    
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    
    // 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    
    NSString * dateString = [[date description] substringToIndex:10];
    
    if ([dateString isEqualToString:todayString])
    {
        return [NSString stringWithFormat:@"%@",[self dateToString:date Format:@"HH:mm"]];
    } else if ([dateString isEqualToString:yesterdayString])
    {
        return [NSString stringWithFormat:@"昨天 %@",[self dateToString:date Format:@"HH:mm"]];
    }
    return [self dateToString:date Format:DATE_FORMAT_MMddHHmm];
}

///判断日期是 过期 今天  明天  将来
+(NSString *)compareDateYTT:(NSDate *)date{
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    NSDate *tomorrow, *yesterday;
    
    tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    
    // 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
//    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    NSString * tomorrowString = [[tomorrow description] substringToIndex:10];
    
    NSString * dateString = [[date description] substringToIndex:10];
    
    
    if ([dateString compare:todayString] == 0) {
        return @"今天";
    }else if ([dateString compare:tomorrowString] == 0)
    {
        return @"明天";
    }else if ([dateString compare:tomorrowString] > 0)
    {
        return @"将来";
    }else if ([dateString compare:todayString] < 0)
    {
        return @"已过期";
    }
    
    return @"";
}



/**
 /////  和当前时间比较
 ////   1）1分钟以内 显示        :    刚刚
 ////   2）1小时以内 显示        :    X分钟前
 ///    3）今天或者昨天 显示      :    今天 09:30   昨天 09:30
 ///    4) 今年显示              :   09月12日
 ///    5) 大于本年      显示    :    2013/09/09
 **/

+ (NSString *)formateDate:(NSString *)dateString withFormate:(NSString *) formate
{
    @try {
        //实例化一个NSDateFormatter对象
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:formate];
        
        NSDate * nowDate = [NSDate date];
        
        /////  将需要转换的时间转换成 NSDate 对象
        NSDate * needFormatDate = [dateFormatter dateFromString:dateString];
        /////  取当前时间和转换时间两个日期对象的时间间隔
        /////  这里的NSTimeInterval 并不是对象，是基本型，其实是double类型，是由c定义的:  typedef double NSTimeInterval;
        NSTimeInterval time = [nowDate timeIntervalSinceDate:needFormatDate];
        
        //// 再然后，把间隔的秒数折算成天数和小时数：
        
        NSString *dateStr = @"";
        
        if (time<=60) {  //// 1分钟以内的
            dateStr = @"刚刚";
        }else if(time<=60*60){  ////  一个小时以内的
            
            int mins = time/60;
            dateStr = [NSString stringWithFormat:@"%d分钟前",mins];
            
        }else if(time<=60*60*24){   //// 在两天内的
            
            [dateFormatter setDateFormat:@"YYYY/MM/dd"];
            NSString * need_yMd = [dateFormatter stringFromDate:needFormatDate];
            NSString *now_yMd = [dateFormatter stringFromDate:nowDate];
            
            [dateFormatter setDateFormat:@"HH:mm"];
            if ([need_yMd isEqualToString:now_yMd]) {
                //// 在同一天
                dateStr = [NSString stringWithFormat:@"今天 %@",[dateFormatter stringFromDate:needFormatDate]];
            }else{
                ////  昨天
                dateStr = [NSString stringWithFormat:@"昨天 %@",[dateFormatter stringFromDate:needFormatDate]];
            }
        }else {
            
            [dateFormatter setDateFormat:@"yyyy"];
            NSString * yearStr = [dateFormatter stringFromDate:needFormatDate];
            NSString *nowYear = [dateFormatter stringFromDate:nowDate];
            
            if ([yearStr isEqualToString:nowYear]) {
                ////  在同一年
                [dateFormatter setDateFormat:@"MM月dd日"];
                dateStr = [dateFormatter stringFromDate:needFormatDate];
            }else{
                [dateFormatter setDateFormat:@"yyyy/MM/dd"];
                dateStr = [dateFormatter stringFromDate:needFormatDate];
            }
        }
        
        return dateStr;
    }
    @catch (NSException *exception) {
        return @"";
    }
    
} 


#pragma mark - 根据日期 获取对应的格式
+ (NSString *)formateLongDate:(long long)itemDate
{
    NSString *dateStr = @"";
    
    /////  将需要转换的时间转换成 NSDate 对象
    NSDate * date = [self stringToDate:[self transDateWithTimeInterval:itemDate withFormat:DATE_FORMAT_yyyyMMddHHmm] Format:DATE_FORMAT_yyyyMMddHHmm];
    NSLog(@"formateLongDate date:%@",date);
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    NSDate *yesterday;
    
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    
    // 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    
    NSString * dateString = [[date description] substringToIndex:10];
    NSLog(@"dateString:%@",dateString);
    
    if ([dateString isEqualToString:todayString])
    {
        dateStr = @"今天";
    } else if ([dateString isEqualToString:yesterdayString])
    {
        dateStr = @"昨天";
    }else if ([[self dateToString:date Format:DATE_FORMAT_yyyy] isEqualToString:[self dateToString:[NSDate date] Format:DATE_FORMAT_yyyy]]){
        ///同一年
        dateStr = [CommonFuntion transDateWithTimeInterval:itemDate withFormat:DATE_FORMAT_MMdd];
    }else{
        ///往年
        dateStr = [CommonFuntion transDateWithTimeInterval:itemDate withFormat:DATE_FORMAT_yyyyMMdd];
    }
    
    return dateStr;
}

#pragma mark - 根据日期 获取对应的格式  公用
+ (NSString *)formateLongDateCommon:(long long)itemDate
{
    NSString *dateStr = @"";
    
    /////  将需要转换的时间转换成 NSDate 对象
    NSDate * date = [self stringToDate:[self transDateWithTimeInterval:itemDate withFormat:DATE_FORMAT_yyyyMMddHHmm] Format:DATE_FORMAT_yyyyMMddHHmm];
    NSLog(@"formateLongDate date:%@",date);
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    NSDate *yesterday;
    
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    
    // 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    
    NSString * dateString = [[date description] substringToIndex:10];
    NSLog(@"dateString:%@",dateString);
    
    if ([dateString isEqualToString:todayString])
    {
        ///今天
        dateStr = [CommonFuntion transDateWithTimeInterval:itemDate withFormat:DATE_FORMAT_HHmm];
    } else if ([dateString isEqualToString:yesterdayString])
    {
//        dateStr = @"昨天";
        dateStr = [CommonFuntion transDateWithTimeInterval:itemDate withFormat:DATE_FORMAT_MMdd];
    }else if ([[self dateToString:date Format:DATE_FORMAT_yyyy] isEqualToString:[self dateToString:[NSDate date] Format:DATE_FORMAT_yyyy]]){
        ///同一年
        dateStr = [CommonFuntion transDateWithTimeInterval:itemDate withFormat:DATE_FORMAT_MMdd];
    }else{
        ///往年
        dateStr = [CommonFuntion transDateWithTimeInterval:itemDate withFormat:DATE_FORMAT_yyyyMMdd];
    }
    
    return dateStr;
}


#pragma mark  评论日期格式
/*
 评论采用和发布动态同样的规则：
 今天的精确到时分，24小时制，格式如：13:34
 今天以外今年以内的精确到月日时分，24小时制， 格式如：2-03  12:45
 今年以外的精确到年月日时分，24小时制， 格式如：2014-03-23  12:23
 */
+ (NSString *)commentOrTrendsDateCommonByLong:(long long)itemDate
{
    NSString *dateStr = @"";
    
    ///将需要转换的时间转换成 NSDate 对象
    NSDate * date = [self stringToDate:[self transDateWithTimeInterval:itemDate withFormat:DATE_FORMAT_yyyyMMddHHmm] Format:DATE_FORMAT_yyyyMMddHHmm];
    NSLog(@"formateLongDate date:%@",date);
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    NSDate *yesterday;
    
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    
    // 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
    
    NSString * dateString = [[date description] substringToIndex:10];
    NSLog(@"dateString:%@",dateString);
    
    if ([dateString isEqualToString:todayString])
    {
        ///今天
        dateStr = [CommonFuntion transDateWithTimeInterval:itemDate withFormat:DATE_FORMAT_HHmm];
    } else if ([[self dateToString:date Format:DATE_FORMAT_yyyy] isEqualToString:[self dateToString:[NSDate date] Format:DATE_FORMAT_yyyy]]){
        ///同一年
        dateStr = [CommonFuntion transDateWithTimeInterval:itemDate withFormat:DATE_FORMAT_MMddHHmm];
    }else{
        ///往年
        dateStr = [CommonFuntion transDateWithTimeInterval:itemDate withFormat:DATE_FORMAT_yyyyMMddHHmm];
    }
    
    return dateStr;
}

///评论日期格式 date
+ (NSString *)commentOrTrendsDateCommonByDate:(NSDate *)date
{
    if (!date) {
        return @"";
    }
    NSString *dateStr = @"";
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    NSDate *yesterday;
    
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    
    // 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
    
    NSString * dateString = [[date description] substringToIndex:10];
    NSLog(@"dateString:%@",dateString);
    
    if ([dateString isEqualToString:todayString])
    {
        ///今天
        dateStr = [CommonFuntion dateToString:date Format:DATE_FORMAT_HHmm];
    } else if ([[self dateToString:date Format:DATE_FORMAT_yyyy] isEqualToString:[self dateToString:[NSDate date] Format:DATE_FORMAT_yyyy]]){
        ///同一年
        dateStr = [CommonFuntion dateToString:date Format:DATE_FORMAT_MMddHHmm];
    }else{
        ///往年
        dateStr = [CommonFuntion dateToString:date Format:DATE_FORMAT_yyyyMMddHHmm];
    }
    
    return dateStr;
}


///日期转string
+(NSString*)dateToString:(NSDate*)date Format:(NSString *)format
{
//    NSDateFormatter *formatter =  [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:format];
//    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
//    [formatter setTimeZone:timeZone];
//    NSString *dateFromData = [formatter stringFromDate:date];
//    NSLog(@"dateToString strData===%@",dateFromData);
//    return dateFromData;
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *newDate =  [date  dateByAddingTimeInterval: interval];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setDateFormat:format];
    NSString *dateFromData = [formatter stringFromDate:newDate];
    NSLog(@"dateToString strData===%@",dateFromData);
    return dateFromData;
}


///string转日期
+(NSDate *)stringToDate:(NSString *)strDate Format:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];

    NSDate *dateTime = [formatter dateFromString:strDate];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: dateTime];
    NSDate *localeDate = [dateTime  dateByAddingTimeInterval: interval];
    NSLog(@"date:%@",localeDate);
    return localeDate;
}

///获取回收日期格式
+(NSString *)getDateOfExpire:(long long) expireTime{
    NSString *strExpireTime = @"";
    NSDate *dateExpireTime = [[NSDate alloc]initWithTimeIntervalSince1970:expireTime/1000.0];
    ///时差
    NSTimeInterval tInterval = [dateExpireTime timeIntervalSinceDate:[NSDate date]];
    
    if (tInterval <= 0) {
        
    }else{
        if (tInterval < HOUR_OF_SECONDS) {
            strExpireTime = [NSString stringWithFormat:@"%i分钟后回收",(int)tInterval/60];
        }else  if (tInterval < DAY_OF_SECONDS) {
            strExpireTime = [NSString stringWithFormat:@"%i小时后回收",(int)tInterval/HOUR_OF_SECONDS];
        }else {
            NSInteger count = tInterval/DAY_OF_SECONDS;
            strExpireTime = [NSString stringWithFormat:@"%li天后回收",count];
        }
    }
    return strExpireTime;
}

///获取当前日期范围  早上  下午  晚上
+(NSString *)getCurDateZone:(NSDate *)date
{
    NSString *zone = @"";
    NSInteger hh = [[self dateToString:date Format:@"HH"] integerValue] ;
    
    if (hh >= 6 && hh < 12) {
        zone = @"上午好";
    }else if (hh >= 12 && hh < 18){
        zone = @"下午好";
    }else{
        zone = @"晚上好";
    }
    return zone;
}


#pragma mark - 将颜色值转换未UIImage
+ (UIImage*) createImageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

///将byte转换为GB MB KB
+(NSString *)byteConversionGBMBKB:(long)KSize{
    int GB = 1024 * 1024 * 1024;//定义GB的计算常量
    int MB = 1024 * 1024;//定义MB的计算常量
    int KB = 1024;//定义KB的计算常量
    //如果当前Byte的值大于等于1GB
    if (KSize / GB >= 1){
       return [NSString stringWithFormat:@"%@G",[self formatFloatToPointNumber:(KSize/(float)GB) byForamt:FORMAT_FLOAT_POINT_1]];
    }
    
    //如果当前Byte的值大于等于1MB
    if (KSize / MB >= 1){
        return [NSString stringWithFormat:@"%@M",[self formatFloatToPointNumber:(KSize/(float)MB) byForamt:FORMAT_FLOAT_POINT_1]];
    }
    
    //如果当前Byte的值大于等于1KB
    if (KSize / KB >= 1){
        return [NSString stringWithFormat:@"%@K",[self formatFloatToPointNumber:(KSize/(float)KB) byForamt:FORMAT_FLOAT_POINT_1]];
    }
   
    return [NSString stringWithFormat:@"%liB",KSize];
}

///将float转为保留小数点后指定位数的格式
+(NSString *)formatFloatToPointNumber:(float)f byForamt:(NSString *)format{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//    [numberFormatter setPositiveFormat:@"###,##0.00;"];
    [numberFormatter setPositiveFormat:format];
    NSString *formattedNumberString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:f]];
    return formattedNumberString;
}


///判断指定的文件是否存在
+(BOOL)isExistsFileInDocument:(NSString *)fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *filePath = [cachesDirectory stringByAppendingPathComponent:fileName];
    
    NSLog(@"filePath:%@",filePath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
     return [fileManager fileExistsAtPath:filePath];
}

///跟进文件名读取本地json数据
+(id)readJsonFile:(NSString *)fileName{
    NSString* path = [[NSBundle mainBundle] pathForResource:fileName
                                                     ofType:@"json"];
    NSLog(@"path:%@",path);
    NSData *data=[NSData dataWithContentsOfFile:path];
    NSError *err;
        //==JsonObject
//    NSLog(@"Json_data:%@",data);
    id JsonObject=[NSJSONSerialization JSONObjectWithData:data
                                                      options:NSJSONReadingAllowFragments
                                                        error:&err];
    
//    NSLog(@"Json_data:%@",JsonObject);
//    NSLog(@"content:%@",content);
    
//    //==Json文件路径
//    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *path=[paths objectAtIndex:0];
//    NSString *Json_path=[path stringByAppendingPathComponent:fileName];
//    NSLog(@"Json_path:%@",Json_path);
//    //==Json数据
//    NSData *data=[NSData dataWithContentsOfFile:Json_path];
//    //==JsonObject
//    NSLog(@"Json_data:%@",data);
//    id JsonObject=[NSJSONSerialization JSONObjectWithData:data
//                                                  options:NSJSONReadingAllowFragments
//                                                    error:nil];
    
    return JsonObject;
}



///匹配
+(BOOL)searchResult:(NSString *)sourceT searchText:(NSString *)searchT{
    if (sourceT==nil || searchT == nil || (id)sourceT == [NSNull null] || [sourceT isEqualToString:@"(null)"] || [sourceT isEqualToString:@"<null>"]) {
        return NO;
    }
    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    NSRange sourceTRange = NSMakeRange(0, sourceT.length);
    NSRange foundRange = [sourceT rangeOfString:searchT options:searchOptions range:sourceTRange];
    if (foundRange.length > 0)
    return YES;
    else
    return NO;
}


#pragma mark - 拨打电话
+(void)callToCurPhoneNum:(NSString *)phoneNum atView:(UIView *)view
{
    //---电话结束以后会返回
    UIWebView *callWebview = [[UIWebView alloc] init] ;
    
    NSMutableString *strNumber = [[NSMutableString alloc] init];
    [strNumber appendString:@"tel:"];
    [strNumber appendString:phoneNum];
    
    NSURL *telURL =[NSURL URLWithString:strNumber];
    [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
    //添加到view上
    [view addSubview:callWebview];
    
}

#pragma mark - 显示HUD
+ (void)showHUD:(NSString *)text andView:(UIView *)view andHUD:(MBProgressHUD *)hud
{
    [view addSubview:hud];
    if (text == nil || [text isEqualToString:@""]) {
        
    }else{
        hud.labelText = text;//显示提示
    }
    
//    hud.dimBackground = YES;//使背景成黑灰色，让MBProgressHUD成高亮显示
//    hud.square = YES;//设置显示框的高度和宽度一样
    [hud show:YES];
}


#pragma mark - 日程、首页 用到的根据颜色值判断显示颜色
+ (UIColor *)getColorValueByColorType:(NSInteger )type {
    /*
    ///默认
    BLUE(5, "#26bfb0"), // 蓝色
    
    RED(1, "#e5352c"),// 红色
    GREEN(2, "#3eb252"),// 绿色
    ORANGE(3, "#ff9500"),// 橙色
    YELLOW(4, "#d9bc15"),//黄色
    BLUE(5, "#26bfb0"), // 蓝色
    PURPLE(6, "#9d5ee6"),// 紫色
    ROSE(7, "#fa65b9"),// 玫红色
    BROWN(8, "#bf5e26");//棕色
     */
    switch (type) {
        case 1:
            return [UIColor colorWithHexString:@"0xe5352c"];
        case 2:
            return [UIColor colorWithHexString:@"0x3eb252"];
        case 3:
            return [UIColor colorWithHexString:@"0xff9500"];
        case 4:
            return [UIColor colorWithHexString:@"0xd9bc15"];
        case 5:
            return [UIColor colorWithHexString:@"0x26bfb0"];
        case 6:
            return [UIColor colorWithHexString:@"0x9d5ee6"];
        case 7:
            return [UIColor colorWithHexString:@"0xfa65b9"];
        case 8:
            return [UIColor colorWithHexString:@"0xbf5e26"];
        default:
            return [UIColor colorWithHexString:@"0x26bfb0"];
            break;
    }
}

#pragma mark - 将毫秒转换为时间 年月日时分秒
+ (NSString *)getStringForTime:(long long)time {
    NSDate *d = [[NSDate alloc]initWithTimeIntervalSince1970:time/1000.0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    return [dateFormatter stringFromDate:d];
}

#pragma mark - 将毫秒转换为时间  指定格式
+ (NSString *)getStringForTime:(long long)time withFormat:(NSString *)format{
    NSDate *d = [[NSDate alloc]initWithTimeIntervalSince1970:time/1000.0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = format;
    return [dateFormatter stringFromDate:d];
}

#pragma mark - 将字符串中@对应的关键词做处理 重新生成有效的字符串
+(NSString *)searchAtCharAndSetItValid:(NSString *)content atArray:(NSArray *)atArray isAddressBookArray:(BOOL)isAddressBook{
    
    ///组织之后的字符串
    NSMutableString *newContent = [[NSMutableString alloc] initWithString:@""];
    ///字符串长度
    NSInteger countStr = 0;
    
    ///@开始
    NSInteger indexBeginAt = 0;
    ///开始@字符
    NSString *beingAt = @"";
    
    
    if (content) {
        countStr = content.length;
    }
    
    NSString *singleChar = @"";
    for (int i=0; i<countStr; i++) {
//        NSLog(@"i:%i",i);
        singleChar = [content substringWithRange:NSMakeRange(i, 1)];
//        NSLog(@"singleChar:%@",singleChar);
        
        ///开始@
        if ([beingAt isEqualToString:@""] && [singleChar isEqualToString:@"@"]) {
            beingAt = @"@";
            indexBeginAt = i;
        }else if ([beingAt isEqualToString:@"@"] && [singleChar isEqualToString:@" "]){
            ///@开始 空格结束
            NSString *hot = [content substringWithRange:NSMakeRange(indexBeginAt, i-indexBeginAt)];
//            NSLog(@"hot:%@",hot);
            ///是有效的
            if ([self isValidAtWord:hot inArrayL:atArray isAddressBookArray:isAddressBook]) {
                ///将hot添加到newContent中
                [newContent appendString:[NSString stringWithFormat:@" %@ ",hot]];
            }else{
                //                [newContent appendString:[NSString stringWithFormat:@"%@",hot]];
                [newContent appendString:[hot substringWithRange:NSMakeRange(0, 1)]];
                [newContent appendString:@" "];
                [newContent appendString:[hot substringWithRange:NSMakeRange(1, hot.length-1)]];
                
            }
            
            ///
            beingAt = @"";
            indexBeginAt = i;
            
        }
        
        else if ([beingAt isEqualToString:@"@"] && [singleChar isEqualToString:@"@"]){
            ///@开始 @结束
            
            NSString *hot = [content substringWithRange:NSMakeRange(indexBeginAt, i-indexBeginAt)];
//            NSLog(@"hot:%@",hot);
            ///是有效的
            if ([self isValidAtWord:hot inArrayL:atArray isAddressBookArray:isAddressBook]) {
                ///将hot添加到newContent中
                [newContent appendString:[NSString stringWithFormat:@" %@ ",hot]];
            }else{
                //                [newContent appendString:[NSString stringWithFormat:@"%@",hot]];
                [newContent appendString:[hot substringWithRange:NSMakeRange(0, 1)]];
                [newContent appendString:@" "];
                [newContent appendString:[hot substringWithRange:NSMakeRange(1, hot.length-1)]];
            }
            ///
            beingAt = @"@";
            indexBeginAt = i;
            
        }else if([beingAt isEqualToString:@""]){
            [newContent appendString:singleChar];
        }
        
        
        ///处理结尾情况
        if (i == countStr-1 && [beingAt isEqualToString:@"@"]) {
            NSString *hot = [content substringWithRange:NSMakeRange(indexBeginAt, i-indexBeginAt+1)];
//            NSLog(@"hot:%@",hot);
            ///是有效的
            if ([self isValidAtWord:hot inArrayL:atArray isAddressBookArray:isAddressBook]) {
                ///将hot添加到newContent中
                [newContent appendString:[NSString stringWithFormat:@" %@ ",hot]];
            }else{
                //                [newContent appendString:[NSString stringWithFormat:@"%@",hot]];
                [newContent appendString:[hot substringWithRange:NSMakeRange(0, 1)]];
                [newContent appendString:@" "];
                [newContent appendString:[hot substringWithRange:NSMakeRange(1, hot.length-1)]];
            }
            ///
            beingAt = @"";
            indexBeginAt = i;
        }
    }
    
//    NSLog(@"newContent:%@",newContent);
    return newContent;
}


#pragma mark - 获取字符串中@对应的关键词对应的userid
+(NSArray *)getAtUserIds:(NSString *)content atArray:(NSArray *)atArray  isAddressBookArray:(BOOL)isAddressBook{
    
    NSMutableArray *arrayValidAtId = [[NSMutableArray alloc] init];
    ///字符串长度
    NSInteger countStr = 0;
    ///@开始
    NSInteger indexBeginAt = 0;
    ///开始@字符
    NSString *beingAt = @"";
    
    if (content) {
        countStr = content.length;
    }
    
    NSString *singleChar = @"";
    for (int i=0; i<countStr; i++) {
//        NSLog(@"i:%i",i);
        singleChar = [content substringWithRange:NSMakeRange(i, 1)];
//        NSLog(@"singleChar:%@",singleChar);
        
        ///开始@
        if ([beingAt isEqualToString:@""] && [singleChar isEqualToString:@"@"]) {
            beingAt = @"@";
            indexBeginAt = i;
        }else if ([beingAt isEqualToString:@"@"] && [singleChar isEqualToString:@" "]){
            ///@开始 空格结束
            NSString *hot = [content substringWithRange:NSMakeRange(indexBeginAt, i-indexBeginAt)];
//            NSLog(@"hot:%@",hot);
            ///是有效的
            if ([self isValidAtWord:hot inArrayL:atArray isAddressBookArray:isAddressBook]) {
                ///将hot添加到arrayValidAtId中
                NSString *uid = [self getValidAtWordId:hot
                                              inArrayL:atArray isAddressBookArray:isAddressBook];
//                if (![arrayValidAtId containsObject:uid]) {
//                    [arrayValidAtId addObject:[self getValidAtWordId:hot
//                                                            inArrayL:atArray isAddressBookArray:isAddressBook]];
//                }
                [arrayValidAtId addObject:[self getValidAtWordId:hot
                                                        inArrayL:atArray isAddressBookArray:isAddressBook]];
            }
            
            ///
            beingAt = @"";
            indexBeginAt = i;
            
        }
        
        else if ([beingAt isEqualToString:@"@"] && [singleChar isEqualToString:@"@"]){
            ///@开始 @结束
            
            
            NSString *hot = [content substringWithRange:NSMakeRange(indexBeginAt, i-indexBeginAt)];
//            NSLog(@"hot:%@",hot);
            ///是有效的
            if ([self isValidAtWord:hot inArrayL:atArray isAddressBookArray:isAddressBook]) {
                ///将hot添加到arrayValidAtId中
                NSString *uid = [self getValidAtWordId:hot
                                              inArrayL:atArray isAddressBookArray:isAddressBook];
//                if (![arrayValidAtId containsObject:uid]) {
//                    [arrayValidAtId addObject:[self getValidAtWordId:hot
//                                                            inArrayL:atArray isAddressBookArray:isAddressBook]];
//                }
                [arrayValidAtId addObject:[self getValidAtWordId:hot
                                                        inArrayL:atArray isAddressBookArray:isAddressBook]];
            }
            ///
            beingAt = @"@";
            indexBeginAt = i;
            
        }
        
        else if([beingAt isEqualToString:@""]){
            
        }
        
        
        ///处理结尾情况
        if (i == countStr-1 && [beingAt isEqualToString:@"@"]) {
            NSString *hot = [content substringWithRange:NSMakeRange(indexBeginAt, i-indexBeginAt+1)];
//            NSLog(@"hot:%@",hot);
            ///是有效的
            if ([self isValidAtWord:hot inArrayL:atArray isAddressBookArray:isAddressBook]) {
                ///将hot添加到arrayValidAtId中
                NSString *uid = [self getValidAtWordId:hot
                                              inArrayL:atArray isAddressBookArray:isAddressBook];
//                if (![arrayValidAtId containsObject:uid]) {
//                    [arrayValidAtId addObject:[self getValidAtWordId:hot
//                                                            inArrayL:atArray isAddressBookArray:isAddressBook]];
//                }
                [arrayValidAtId addObject:[self getValidAtWordId:hot
                                                        inArrayL:atArray isAddressBookArray:isAddressBook]];
            }
            ///
            beingAt = @"";
            indexBeginAt = i;
        }
    }
    return arrayValidAtId;
}


#pragma mark - 判断当前关键词是否在有效的集合中
+(BOOL)isValidAtWord:(NSString *)atWord inArrayL:(NSArray *)atArray  isAddressBookArray:(BOOL)isAddressBook{
    BOOL isValid = FALSE;
//    NSLog(@"atWord:%@",atWord);
//    NSLog(@"atArray:%@",atArray);
    NSInteger count = 0;
    if (atArray) {
        count = [atArray count];
    }
    
    ///是通讯录 如发送评论、发布动态时
    if (isAddressBook) {
        AddressBook *addressbook = nil;
        for (int i=0; !isValid && i<count; i++) {
            //        NSLog(@"array i:%@",[atArray objectAtIndex:i]);
            addressbook = (AddressBook *)[atArray objectAtIndex:i];
            if ([[[atWord stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"@" withString:@""] isEqualToString:addressbook.name]) {
                isValid = TRUE;
            }
        }
    }else{
        ///展示动态内容 或 评论里的@时
        for (int i=0; !isValid && i<count; i++) {
//                    NSLog(@"array i:%@",[atArray objectAtIndex:i]);
            
            if ([[[atWord stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"@" withString:@""] isEqualToString:[[atArray objectAtIndex:i] safeObjectForKey:@"name"]]) {
                isValid = TRUE;
            }
        }
    }
    
    
    return isValid;
}

#pragma mark - 获取当前关键词在有效的集合中的id
+(NSString *)getValidAtWordId:(NSString *)atWord inArrayL:(NSArray *)atArray  isAddressBookArray:(BOOL)isAddressBook{
    BOOL isValid = FALSE;
    NSString *atId = @"";
//    NSLog(@"atWord:%@",atWord);
    NSInteger count = 0;
    if (atArray) {
        count = [atArray count];
    }
    
    ///是通讯录 如发送评论、发布动态时
    if (isAddressBook) {
        AddressBook *addressbook = nil;
        for (int i=0; !isValid && i<count; i++) {
            //        NSLog(@"array i:%@",[atArray objectAtIndex:i]);
            addressbook = (AddressBook *)[atArray objectAtIndex:i];
            if ([[[atWord stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"@" withString:@""] isEqualToString:addressbook.name]) {
                isValid = TRUE;
                atId = [NSString stringWithFormat:@"%@",addressbook.id];
            }
        }
    }else{
        for (int i=0; !isValid && i<count; i++) {
            //        NSLog(@"array i:%@",[atArray objectAtIndex:i]);
            if ([[[atWord stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"@" withString:@""] isEqualToString:[[atArray objectAtIndex:i] safeObjectForKey:@"name"]]) {
                isValid = TRUE;
                atId = [[atArray objectAtIndex:i] safeObjectForKey:@"id"];
            }
        }
    }
    
    
    return atId;
}



#pragma mark - @人id集合,以“,”分隔开）
+(NSString *)getStringStaffIds:(NSArray *)arrayStaffs{
    NSMutableString *strIds = [[NSMutableString alloc] initWithString:@""];
    NSInteger count = 0;
    if (arrayStaffs) {
        count = [arrayStaffs count];
    }
    
    for (int i=0; i<count; i++) {
        if ([strIds isEqualToString:@""]) {
            [strIds appendString:[NSString stringWithFormat:@"%@",[arrayStaffs objectAtIndex:i]]];
        }else{
            [strIds appendString:@","];
            [strIds appendString:[NSString stringWithFormat:@"%@",[arrayStaffs objectAtIndex:i]]];
        }
    }
    return strIds;
}
#pragma mark - 将时间转化为字符串
+ (NSString *)dateToString:(NSDate *)date
{
    NSDateFormatter *formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
    [formatter setTimeZone:timeZone];
    NSString *dateFromData = [formatter stringFromDate:date];
    //    NSLog(@"dateFromData===%@",dateFromData);
    return dateFromData;
}


#pragma mark - 检测网络状态
+ (Boolean)checkNetworkState
{
     // 1.检测wifi状态
     Reachability *wifi = [Reachability reachabilityForLocalWiFi];

     // 2.检测手机是否能上网络(WIFI\3G\2.5G)
     Reachability *conn = [Reachability reachabilityForInternetConnection];

     // 3.判断网络状态
     if ([wifi currentReachabilityStatus] != NotReachable) { // 有wifi
         NSLog(@"有wifi");

     } else if ([conn currentReachabilityStatus] != NotReachable) { // 没有使用wifi, 使用手机自带网络进行上网
         NSLog(@"使用手机自带网络进行上网");
     } else { // 没有网络
         
         NSLog(@"没有网络");
         return NO;
     }
    return YES;
 }
#pragma mark -  两个日期相隔天数
+ (NSInteger)getTimeDaysSinceToady:(NSString *)time {
    NSDate *todayTime = [NSDate date];
    time = [time substringToIndex:10];
    NSDate *dateTime = [CommonFuntion stringToDate:time Format:@"yyyy-MM-dd"];
    NSTimeInterval interval = [todayTime timeIntervalSince1970] * 1000;
    NSTimeInterval oldInterval = [dateTime timeIntervalSince1970] * 1000;
    NSInteger old_date = oldInterval / 1000 / 3600 / 24;
    NSInteger today_tate = interval / 1000 / 3600 / 24;
    return today_tate - old_date;
}
#pragma mark - 判断可以对应的value是否为nil
+ (BOOL)checkNullForValue:(id )value {
    // 判断是否为空串
    if ([value isEqual:[NSNull null]]) {
        return NO;
    } else if ([value isKindOfClass:[NSNull class]])
    {
        return NO;
    } else if (value == nil){
        return NO;
    } else if ([value isKindOfClass:[NSString class]] && [value isEqualToString:@""]) {
        return NO;
    }
    return YES;
}
#pragma mark - json串 转换为字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


#pragma mark - 获取图片格式
+ (NSString *)typeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
            
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
            
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}


///获取文件名称  如为nil 则填充当前日期
+(NSString *)getFileNameDeleteEctension:(NSString *)originalFileName{
    NSString *fileName = @"";
    
    if (!originalFileName || originalFileName.length < 1) {
        fileName = [NSString stringWithFormat:@"IMG-%@",[self dateToString:[NSDate date] Format:@"yyyyMMddHHmmss"]];
    }else{
        fileName = [originalFileName stringByDeletingPathExtension];
    }

    return fileName;
}

///验证手机是否有效  纯数字+11位
+ (BOOL)isMobileNumber:(NSString *)mobileNum
{
    ///去除空格
    if ([self isEmptyString:mobileNum]) {
        return NO;
    }
    
    ///纯数字
    if (![self checkStringIsAllow:mobileNum withChar:CHECK_CHAR_PHONE_NUM]) {
        return NO;
    }
    
    ///11位
    if ( mobileNum.length != 11 ) {
        return  NO;
    }
    return YES;
}

// 将汉子转换为拼音首字母
+(NSString *)namToPinYinFisrtNameWith:(NSString *)name
{
    NSString * outputString = @"";
    for (int i =0; i<[name length]; i++) {
        outputString = [NSString stringWithFormat:@"%@%c",outputString,pinyinFirstLetter([name characterAtIndex:i])];
        
    }
    return outputString;
    
}


///生成目录路径
+(NSString *)createDocumentsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

@end
