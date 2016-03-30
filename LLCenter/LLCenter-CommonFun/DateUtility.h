//
//  DateUtility.h
//  iFamily
//
//  Created by Jason Wang on 5/21/11.
//  Copyright 2011 Jason Wang. All rights reserved.
//

#define DAY_OF_SECONDS (24*60*60)
#define HOUR_OF_SECONDS (60*60)

#define DEFAULT_DATE_TEMPLATE_STRING @"yyyyMMddHHmmss"
//#define DEFAULT_DATE_TEMPLATE_STRING @"HH:mm:ss dd/MM/yy"
#define SHORT_DATE_TEMPLATE_STRING @"yyyy-MM-dd"
#define HOUR_MINUT_TEMPLATE_STRING @"HH:mm"

struct MNSDate {
    NSUInteger second;
    NSUInteger minute;
    NSUInteger hour;
    NSUInteger weekday;
    NSUInteger day;
    NSUInteger month;
    NSUInteger year;
};
typedef struct MNSDate MNSDate;

CG_INLINE MNSDate MNSDateMake(NSDate *date) {
    MNSDate MNSDate;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    
    MNSDate.second = [components second];
    MNSDate.minute = [components minute];
    MNSDate.hour = [components hour];
    MNSDate.weekday = [components weekday];
    MNSDate.day = [components day];
    MNSDate.month = [components month];
    MNSDate.year = [components year];
    
    return MNSDate;
}

CG_INLINE NSArray * getWeekdaySymbols() {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSArray *weekdaySymbols = [formatter weekdaySymbols];
    
    return weekdaySymbols;
}

CG_INLINE NSArray * getShortWeekdaySymbols() {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSArray *weekdaySymbols = [formatter shortWeekdaySymbols];
    
    return weekdaySymbols;
}

CG_INLINE NSArray * getMonthSymbols() {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSArray *monthSymbols = [formatter monthSymbols];
    
    return monthSymbols;
}

CG_INLINE NSArray * getShortMonthSymbols() {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSArray *monthSymbols = [formatter shortMonthSymbols];
    
    return monthSymbols;
}

CG_INLINE NSDate * getDate(NSDate *fromDate, NSInteger dayGap) {
    return [NSDate dateWithTimeInterval:DAY_OF_SECONDS * dayGap sinceDate:fromDate];
}

CG_INLINE NSDate * getLocalDateFromGMTDate(NSDate *GMTDate) {
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    
    NSInteger interval = [zone secondsFromGMTForDate: GMTDate];
    
    NSDate *localeDate = [GMTDate  dateByAddingTimeInterval: interval];
    
    return localeDate;
}

CG_INLINE NSDate * getLastDateOfMonth(NSDate *targetMonthDay) {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSRange daysRange = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:targetMonthDay];
    
    NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:targetMonthDay];
    [components setDay:daysRange.length];
    
    return [calendar dateFromComponents:components];
}

CG_INLINE NSDate * getFirstDateOfMonth(NSDate *targetMonthDay) {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:targetMonthDay];
    [components setDay:1];
    
    return [calendar dateFromComponents:components];
}

CG_INLINE NSDate *getFirstDateOfWeek(NSDate *date) {
    MNSDate MNSDate = MNSDateMake(date);
    
    return getDate(date, -1 * (MNSDate.weekday - 1));
}

CG_INLINE NSDate *getTomorrowDate() {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *today = [NSDate date];
    
    NSDateComponents *components = [calendar components:kCFCalendarUnitHour | kCFCalendarUnitMinute | kCFCalendarUnitSecond fromDate:today];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    NSInteger second = [components second];
    
    NSTimeInterval timeInterval = DAY_OF_SECONDS - 3600 * hour - 60 * minute - second + 1;
    
    return [NSDate dateWithTimeInterval:timeInterval sinceDate:today];;
}

CG_INLINE NSDate * getDateFromString(NSString *dateStringTemplate, NSString *dateStr) {
    
    [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (!dateStringTemplate) {
        dateStringTemplate = DEFAULT_DATE_TEMPLATE_STRING;
    }
    
    [dateFormatter setDateFormat:dateStringTemplate];
    
    NSDate *date = [dateFormatter dateFromString:dateStr];
    
    return date;
}

CG_INLINE NSDate * getShortDateFromString(NSString *dateStringTemplate, NSString *dateStr) {
    [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (!dateStringTemplate) {
        dateStringTemplate = SHORT_DATE_TEMPLATE_STRING;
    }
    
    [dateFormatter setDateFormat:dateStringTemplate];
    
    NSDate *date = [dateFormatter dateFromString:dateStr];
    
    return date;
}

CG_INLINE NSString *getStringFromDate(NSString *dateStringTemplate, NSDate *date) {
    [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (!dateStringTemplate) {
        dateStringTemplate = DEFAULT_DATE_TEMPLATE_STRING;
    }
    
    [dateFormatter setDateFormat:dateStringTemplate];
    
    NSString *dateStr = [dateFormatter stringFromDate:date];
    
    return dateStr;
}

CG_INLINE NSInteger getWeekDayFromDate(NSDate* _date) {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps;
    comps = [calendar components:(NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit) fromDate:_date];
    NSInteger week = [comps weekday];
    return week;
}

CG_INLINE NSString *getChinaWeekdayFromDate(NSDate *_date){
    int _weekday = getWeekDayFromDate(_date);
    NSString *weekdayOfChina = @"";
    switch (_weekday) {
        case 1:
            weekdayOfChina = @"星期日";
            break;
        case 2:
            weekdayOfChina = @"星期一";
            break;
        case 3:
            weekdayOfChina = @"星期二";
            break;
        case 4:
            weekdayOfChina = @"星期三";
            break;
        case 5:
            weekdayOfChina = @"星期四";
            break;
        case 6:
            weekdayOfChina = @"星期五";
            break;
        case 7:
            weekdayOfChina = @"星期六";
            break;
            
        default:
            break;
    }
    return weekdayOfChina;
}

CG_INLINE NSString *getEnglishWeekdayFromDate(NSDate *_date){
    int _weekday = getWeekDayFromDate(_date);
    NSString *weekdayOfChina = @"";
    switch (_weekday) {
        case 1:
            weekdayOfChina = @"Sunday";
            break;
        case 2:
            weekdayOfChina = @"Monday";
            break;
        case 3:
            weekdayOfChina = @"Tuesday";
            break;
        case 4:
            weekdayOfChina = @"Wednesday";
            break;
        case 5:
            weekdayOfChina = @"Thursday";
            break;
        case 6:
            weekdayOfChina = @"Friday";
            break;
        case 7:
            weekdayOfChina = @"Saturday";
            break;
            
        default:
            break;
    }
    return weekdayOfChina;
}

CG_INLINE NSString* getChineseCalendarWithDate(NSDate *date) {
    
    NSArray *chineseYears = [NSArray arrayWithObjects:
                             @"甲子", @"乙丑", @"丙寅", @"丁卯",  @"戊辰",  @"己巳",  @"庚午",  @"辛未",  @"壬申",  @"癸酉",
                             @"甲戌",   @"乙亥",  @"丙子",  @"丁丑", @"戊寅",   @"己卯",  @"庚辰",  @"辛己",  @"壬午",  @"癸未",
                             @"甲申",   @"乙酉",  @"丙戌",  @"丁亥",  @"戊子",  @"己丑",  @"庚寅",  @"辛卯",  @"壬辰",  @"癸巳",
                             @"甲午",   @"乙未",  @"丙申",  @"丁酉",  @"戊戌",  @"己亥",  @"庚子",  @"辛丑",  @"壬寅",  @"癸丑",
                             @"甲辰",   @"乙巳",  @"丙午",  @"丁未",  @"戊申",  @"己酉",  @"庚戌",  @"辛亥",  @"壬子",  @"癸丑",
                             @"甲寅",   @"乙卯",  @"丙辰",  @"丁巳",  @"戊午",  @"己未",  @"庚申",  @"辛酉",  @"壬戌",  @"癸亥", nil];
    
    NSArray *chineseMonths=[NSArray arrayWithObjects:
                            @"正月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月",
                            @"九月", @"十月", @"冬月", @"腊月", nil];
    
    
    NSArray *chineseDays=[NSArray arrayWithObjects:
                          @"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",
                          @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十",
                          @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十",  nil];
    
    
    NSCalendar *localeCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSChineseCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    
    NSDateComponents *localeComp = [localeCalendar components:unitFlags fromDate:date];
    
    NSLog(@"%d_%d_%d  %@",localeComp.year,localeComp.month,localeComp.day, localeComp.date);
    
    NSString *y_str = [chineseYears objectAtIndex:localeComp.year-1];
    NSString *m_str = [chineseMonths objectAtIndex:localeComp.month-1];
    NSString *d_str = [chineseDays objectAtIndex:localeComp.day-1];
    
    NSString *chineseCal_str =[NSString stringWithFormat: @"%@-%@-%@",y_str,m_str,d_str];
    
    return chineseCal_str;
}

CG_INLINE NSDate *getDateAfterMonth(int _monthB ,NSDate *_date) {
    int _yearB = _monthB / 12;
    if (abs(_yearB) > 0) {
        _monthB = _monthB % 12;
    }
    
    int year = [getStringFromDate(@"yyyy", _date) intValue];
    int month = [getStringFromDate(@"MM", _date) intValue];
    
    month = month + _monthB;
    year = year + _yearB;
    
    if (month > 12) {
        year++;
        month -= 12;
    }

    NSString *resultDateStr = [NSString stringWithFormat:@"%d-%d-%@",year,month,getStringFromDate(@"dd HH:mm:ss", _date)];
    NSDate *resultDate = getDateFromString(@"yyyy-MM-dd HH:mm:ss", resultDateStr);

    return resultDate;
}

CG_INLINE NSDate *getDateAfterMinuts(int _minuts,NSDate *_date) {
    int s = _minuts * 60;
    NSDate *rDate = [_date dateByAddingTimeInterval:s];
    return rDate;
}

CG_INLINE NSString *getChnTimeString(int interval) {
//    NSDate *dateLast = [NSDate dateWithTimeIntervalSince1970:a];
//    NSDate *dateNow = [NSDate date];
//    int interval = [dateNow timeIntervalSinceDate:dateLast];
//    interval = interval / 60;
    NSString *str = [NSString stringWithFormat:@"%d时%d分",interval/60,interval%60];
    return str;
}

CG_INLINE NSDate *getDateFromNumber(double num) {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:num];
    return date;
}

CG_INLINE NSDate *getBigDate(NSDate *dateSmall,NSDate *dateBig) {
    if ([[dateSmall earlierDate:dateBig] isEqualToDate:dateBig]) {
        dateBig = [dateBig dateByAddingTimeInterval:24*60*60];
    }
    return dateBig;
}


//未来的时间(可能用户手机时间不准确),显示"刚刚"；1小时内,显示分钟；24小时内,显示小时；48小时内,显示昨天；之后显示日期MM-dd
CG_INLINE NSString* getWeiboDisplayTimeFromDate(NSDate *_date) {
    NSDate *dateNow = [NSDate date];
    if ([_date isEqualToDate:[dateNow laterDate:_date]] || !_date) {
        return @"刚刚";
    }
    NSTimeInterval tInterval = [dateNow timeIntervalSinceDate:_date];
    if (tInterval/60 < 1) {
        return @"刚刚";
    }
    if (tInterval < HOUR_OF_SECONDS) {
        return [NSString stringWithFormat:@"%d分钟前",(int)tInterval/60];
    }
    
    if (tInterval < DAY_OF_SECONDS) {
        return [NSString stringWithFormat:@"%d小时前",(int)tInterval/HOUR_OF_SECONDS];
    }
    
    if (tInterval < 2 * DAY_OF_SECONDS) {
        return @"昨天";
    }
    
    return getStringFromDate(@"MM月dd日", _date);
}

CG_INLINE BOOL isToday(NSDate *d) {
    NSDate *today = [NSDate date];
    NSString *dString = getStringFromDate(@"yyyy-MM-dd",d);
    NSString *todayString = getStringFromDate(@"yyyy-MM-dd",today);
    if ([dString isEqualToString:todayString]) {
        return YES;
    }
    return NO;
}
