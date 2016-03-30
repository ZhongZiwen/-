//
//  CommonFunc.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 14-12-10.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//
#define CHECK_ChAR @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

#define CHECK_ChAR_NUM @"0123456789"

#import "CommonFunc.h"
#import "LLCenterUtility.h"
#import "CommonNoDataView.h"
#import "Reachability.h"

@interface CommonFunc () {
}

@end

@implementation CommonFunc

// 设置view的frame
+ (CGRect)setViewFrameOffset:(CGRect)frame byX:(float)x byY:(float)y ByWidth:(float) width byHeight:(float)height{
    
    CGRect newFrame = CGRectMake(frame.origin.x+x, frame.origin.y+y, frame.size.width+width, frame.size.height+height);
    return newFrame;
}

// 校验字符串是否由指定的字符组成
+(BOOL)checkString:(NSString*)str inCharactersString:(NSString*)characters
{
    NSScanner* scanner = [[NSScanner alloc] initWithString:str];
    NSCharacterSet* charsets = [NSCharacterSet characterSetWithCharactersInString:CHECK_ChAR];
    NSString* restr = @"";
    [scanner scanCharactersFromSet:charsets intoString:&restr];
    if([restr length] == [str length])
        return YES;
    return  NO;
}


// 校验字符串是否由指定的字符组成
+(BOOL)checkStringIsNum:(NSString*)str {
    NSScanner* scanner = [[NSScanner alloc] initWithString:str];
    NSCharacterSet* charsets = [NSCharacterSet characterSetWithCharactersInString:CHECK_ChAR_NUM];
    NSString* restr = @"";
    [scanner scanCharactersFromSet:charsets intoString:&restr];
    if([restr length] == [str length])
        return YES;
    return  NO;
}

+(void)getNameCity{
    // guide
    NSScanner *scanner;
    NSCharacterSet *charSets;
    NSCondition *condition;
    
    [scanner setValue:nil forKey:@"scanner"];
    
    
}


///根据string  font  width 获取Size
+(CGSize)getSizeOfContents:(NSString *)content Font:(UIFont*)font withWidth:(CGFloat)width withHeight:(CGFloat)height{
    
    CGSize size = CGSizeMake(width, height);
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
    
    size =[content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return size;
}

+(NSString*)formatDisplayDateString:(NSString*)dString {
    if (!dString || ![dString isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSDate *d = getDateFromString(@"yyyy-MM-dd HH:mm", dString);
    return getStringFromDate(@"MM-dd HH:mm", d);
    
    if (isToday(d)) {
        return getStringFromDate(@"HH:mm", d);
    }
    else {
        return getStringFromDate(@"MM-dd HH:mm", d);
    }
    
    //    NSDate *currentDate = [NSDate date];
    //    unsigned long timeInterval = [currentDate timeIntervalSinceDate:d];
    //    unsigned long dayInterval = 24*60*60;
    //    if (timeInterval < dayInterval) {
    //        //显示时间
    //        return getStringFromDate(@"今天 HH:mm", d);
    //    }
    //    else if (timeInterval >= dayInterval && timeInterval < 2*dayInterval) {
    //        //昨天
    //        //return @"昨天";
    //        return getStringFromDate(@"昨天 HH:mm", d);
    //    }
    //    else if (timeInterval >= 2*dayInterval && timeInterval < 3*dayInterval) {
    //        //前天
    //        //return @"前天";
    //        return getStringFromDate(@"前天 HH:mm", d);
    //    }
    //    else {
    //        //显示日期
    //        return getStringFromDate(@"MM月dd日 HH:mm", d);
    //    }
}

//mode --
//0 - 计算时长
//1 - 计算时间
+(NSString*)getMinutString:(int)interval intervalType:(int)intervalType mode:(int)mode {
    if (intervalType == 0) {
        int min = interval % 60;
        int hour = interval / 60;
        if (hour > 0) {
            if (mode == 0) {
                return [NSString stringWithFormat:@"%d时%d分",hour,min];
            }
        }
        if (min > 0) {
            if (mode == 0) {
                return [NSString stringWithFormat:@"%d分",min];
            }
        }
    }
    
    int hour = interval / 3600;
    int min = interval / 60;
    int sec = interval % 60;
    
    if (mode == 1) {
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hour,min,sec];
    }
    
    if (hour > 0) {
        if (mode == 0) {
            return [NSString stringWithFormat:@"%d时%d分%d秒",hour,min,sec];
        }
        else {
            return [NSString stringWithFormat:@"%02d:%02d:%02d",hour,min,sec];
        }
    }
    if (min > 0) {
        if (mode == 0) {
            return [NSString stringWithFormat:@"%d分%d秒",min,sec];
        }
        else {
            return [NSString stringWithFormat:@"%02d:%02d",min,sec];
        }
    }
    else {
        if (mode == 0) {
            return [NSString stringWithFormat:@"%d秒",sec];
        }
        else {
            return [NSString stringWithFormat:@"00:00:%02d",sec];
        }
    }
}

///获取当前 年、月、日、时、分、秒
/// mode   1-年  2-月 3-日 4-时 5-分 6-秒
+(NSInteger)getCurY_M_D_H_M_S:(int)mode{
    
    //获取当前时间
    NSDate *now = [NSDate date];
    NSLog(@"now date is: %@", now);
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    NSInteger Y_M_D_H_M_S = 0;
    switch (mode) {
        case 1:
            Y_M_D_H_M_S = [dateComponent year];
            break;
        case 2:
            Y_M_D_H_M_S = [dateComponent month];
            break;
        case 3:
            Y_M_D_H_M_S = [dateComponent day];
            break;
        case 4:
            Y_M_D_H_M_S = [dateComponent hour];
            break;
        case 5:
            Y_M_D_H_M_S = [dateComponent minute];
            break;
        case 6:
            Y_M_D_H_M_S = [dateComponent second];
            break;
            
        default:
            break;
    }
    return Y_M_D_H_M_S;
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
    
    return JsonObject;
}


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


#pragma mark - 没有数据时的view
+(CommonNoDataView*)commonNoDataViewIcon:(NSString *)iconName Title:(NSString *)titleName optionBtnTitle:(NSString *)btnTitle{
    
    CommonNoDataView *commonNoDataView = [[CommonNoDataView alloc] initWithFrame:CGRectMake(0, (DEVICE_BOUNDS_HEIGHT-140)/2-40, DEVICE_BOUNDS_WIDTH, 140)];
    
    commonNoDataView.imgName = iconName;
    commonNoDataView.labelTitle = titleName;
    commonNoDataView.btnTitle = btnTitle;
    
    return commonNoDataView;
}

///位置稍微偏下
+(CommonNoDataView*)commonNoDataViewIconNearBottom:(NSString *)iconName Title:(NSString *)titleName optionBtnTitle:(NSString *)btnTitle{
    
    CommonNoDataView *commonNoDataView = [[CommonNoDataView alloc] initWithFrame:CGRectMake(0, (DEVICE_BOUNDS_HEIGHT-140)/2, DEVICE_BOUNDS_WIDTH, 140)];
    
    commonNoDataView.imgName = iconName;
    commonNoDataView.labelTitle = titleName;
    commonNoDataView.btnTitle = btnTitle;
    
    return commonNoDataView;
}


+ (BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
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


#pragma 正则匹配手机号
+ (BOOL)isValidatePhoneNumber:(NSString *) telNumber
{
    NSString *pattern = @"^1+[34578]+\\d{9}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:telNumber];
    return isMatch;
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
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setDateFormat:format];
    NSString *dateFromData = [formatter stringFromDate:date];
//    NSLog(@"dateToString strData===%@",dateFromData);
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


////将字符串转换为date  不做timezone转换
+(NSDate *)stringToDateNoTimeZone:(NSString *)strDate  withFormat:(NSString *)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSDate *dateTime = [formatter dateFromString:strDate];
    return dateTime;
}


// 将字典或者数组转化为JSON串
+ (NSData *)toJSONData:(id)theData{
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        return jsonData;
    }else{
        return nil;
    }
}


+ (NSString *)getWeekdayWithDate:(NSDate *)date
{
    NSCalendar*calendar = [NSCalendar currentCalendar];
    NSDateComponents*comps;
    
    comps =[calendar components:(NSWeekCalendarUnit | NSWeekdayCalendarUnit |NSWeekdayOrdinalCalendarUnit)
                       fromDate:date];
    NSInteger weekday = [comps weekday]; // 星期几（注意，周日是“1”，周一是“2”。。。。）
    NSLog(@"");
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


///根据日期 获取其对应的星期几 周日是“1”，周一是“2”
+ (NSInteger)getWeekdayTagWithDate:(NSDate *)date
{
    NSCalendar*calendar = [NSCalendar currentCalendar];
    NSDateComponents*comps;
    
    comps =[calendar components:(NSWeekCalendarUnit | NSWeekdayCalendarUnit |NSWeekdayOrdinalCalendarUnit)
                       fromDate:date];
    NSInteger weekday = [comps weekday]; // 星期几（注意，周日是“1”，周一是“2”。。。。）
    NSLog(@"getWeekdayTagWithDate :%@ weekday:%ti",date,weekday);
    return weekday;
    
    /*
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
     */
}

//判断字符串是否是整型

+(BOOL)isPureInt:(NSString*)string{
    
    NSScanner* scan = [NSScanner scannerWithString:string];
    
    int val;
    
    return[scan scanInt:&val] && [scan isAtEnd];
    
}

+ (BOOL)isPureLong:(NSString*)string{
    
    NSScanner* scan = [NSScanner scannerWithString:string];
    
    long long val;
    
    return[scan scanLongLong:&val] && [scan isAtEnd];
    
}

//判断是否为浮点形：

+ (BOOL)isPureFloat:(NSString*)string{
    
    NSScanner* scan = [NSScanner scannerWithString:string];
    
    float val;
    
    return[scan scanFloat:&val] && [scan isAtEnd];
    
}

+ (BOOL)isPureDecimal:(NSString*)string{
    
    NSScanner* scan = [NSScanner scannerWithString:string];
    
    NSDecimal val;
    return[scan scanDecimal:&val] && [scan isAtEnd];
    
}


#pragma mark - 编辑导航根据id、flag获取其对应的文本信息
///全部时间1 星期时间 2  节假日3
+(NSString *)getNavTimeType:(NSString *)flag{
    NSString *timeType = @"";
    if (flag == nil || [flag isEqualToString:@""]) {
        return @"";
    }
    NSInteger intFlag = [flag integerValue];
    switch (intFlag) {
        case 1:
            timeType = @"全部时间";
            break;
        case 2:
            timeType = @"星期时间";
            break;
        case 3:
            timeType = @"节假日";
            break;
            
        default:
            break;
    }
    
    return timeType;
}


#pragma mark - 判断string是否为"null"
+(BOOL)isStringNullObject:(NSString *)strObject{
    if ([strObject isEqualToString:@"null"]) {
        return YES;
    }
    return NO;
}


/**
 *  将阿拉伯数字转换为中文数字
 */
+(NSString *)translationArabicNum:(NSInteger)arabicNum
{
    NSString *arabicNumStr = [NSString stringWithFormat:@"%ld",(long)arabicNum];
    NSArray *arabicNumeralsArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"];
    NSArray *chineseNumeralsArray = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"零"];
    NSArray *digits = @[@"个",@"十",@"百",@"千",@"万",@"十",@"百",@"千",@"亿",@"十",@"百",@"千",@"兆"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:chineseNumeralsArray forKeys:arabicNumeralsArray];
    
    if (arabicNum < 20 && arabicNum > 9) {
        if (arabicNum == 10) {
            return @"十";
        }else{
            NSString *subStr1 = [arabicNumStr substringWithRange:NSMakeRange(1, 1)];
            NSString *a1 = [dictionary objectForKey:subStr1];
            NSString *chinese1 = [NSString stringWithFormat:@"十%@",a1];
            return chinese1;
        }
    }else{
        NSMutableArray *sums = [NSMutableArray array];
        for (int i = 0; i < arabicNumStr.length; i ++)
        {
            NSString *substr = [arabicNumStr substringWithRange:NSMakeRange(i, 1)];
            NSString *a = [dictionary objectForKey:substr];
            NSString *b = digits[arabicNumStr.length -i-1];
            NSString *sum = [a stringByAppendingString:b];
            if ([a isEqualToString:chineseNumeralsArray[9]])
            {
                if([b isEqualToString:digits[4]] || [b isEqualToString:digits[8]])
                {
                    sum = b;
                    if ([[sums lastObject] isEqualToString:chineseNumeralsArray[9]])
                    {
                        [sums removeLastObject];
                    }
                }else
                {
                    sum = chineseNumeralsArray[9];
                }
                
                if ([[sums lastObject] isEqualToString:sum])
                {
                    continue;
                }
            }
            
            [sums addObject:sum];
        }
        NSString *sumStr = [sums  componentsJoinedByString:@""];
        NSString *chinese = [sumStr substringToIndex:sumStr.length-1];
        return chinese;
    }
}


#pragma  mark - 遍历日期 将其组织成目标数据格式
+(NSArray *)transDateToWeekFormatByStrBeginDate:(NSString *)strBeginDate andStrEndDate:(NSString *)strEndDate{
    
    NSDate *beginDate = [self stringToDate:strBeginDate Format:@"yyyy-MM-dd"];
    NSDate *endDate = [self stringToDate:strEndDate Format:@"yyyy-MM-dd"];
    NSLog(@"strBeginDate:%@ \n beginDate:%@",strBeginDate,beginDate);
    NSLog(@"strEndDate:%@ \n endDate:%@",strEndDate,endDate);
    
    NSDate *bDate = beginDate;
    NSMutableArray *allWeekDays = [[NSMutableArray alloc] init];
    
    
    for ( int i=0;[bDate compare:endDate] <= 0 && i<7; ) {
        NSLog(@"bDate:%@",bDate);
        
        ///根据日期 获取其对应的星期几 周日是“1”，周一是“2”
        NSInteger weekValue = [self getWeekdayTagWithDate:bDate];
        [allWeekDays addObject:[NSString stringWithFormat:@"%ti",weekValue]];
        bDate = [bDate dateByAddingDays:1];
        i++;
    }
    
    NSLog(@"allWeekDays:%@",allWeekDays);
    return allWeekDays;
}


///根据文件夹名称 获取路径
+ (NSString *)getDocumentsPathByDirName:(NSString *)dirName {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dir = [docDir stringByAppendingPathComponent:dirName];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:dir isDirectory:&isDir];
    BOOL isCreated = NO;
    if (!existed){
        isCreated = [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }else{
        isCreated = YES;
    }
    return dir;
}




@end
