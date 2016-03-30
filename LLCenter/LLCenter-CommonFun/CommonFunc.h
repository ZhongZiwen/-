//
//  CommonFunc.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 14-12-10.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <Foundation/Foundation.h>



@class CommonNoDataView;

@interface CommonFunc : NSObject


// 设置view的frame
+ (CGRect)setViewFrameOffset:(CGRect)frame byX:(float)x byY:(float)y ByWidth:(float) width byHeight:(float)height;

// 校验字符串是否由指定的字符组成
+(BOOL)checkString:(NSString*)str inCharactersString:(NSString*)characters;

// 校验字符串是否由数字组成
+(BOOL)checkStringIsNum:(NSString*)str;

///根据string  font  width 获取Size
+(CGSize)getSizeOfContents:(NSString *)content Font:(UIFont*)font withWidth:(CGFloat)width withHeight:(CGFloat)height;


//mode --
//0 - 计算时长
//1 - 计算时间
+(NSString*)getMinutString:(int)interval intervalType:(int)intervalType mode:(int)mode;

+(NSString*)formatDisplayDateString:(NSString*)dString;

///跟进文件名读取本地json数据
+(id)readJsonFile:(NSString *)fileName;
///颜色值转换为图片
+ (UIImage*) createImageWithColor: (UIColor*) color;

#pragma mark - 没有数据时的view
+(CommonNoDataView*)commonNoDataViewIcon:(NSString *)iconName Title:(NSString *)titleName optionBtnTitle:(NSString *)btnTitle;
+(CommonNoDataView*)commonNoDataViewIconNearBottom:(NSString *)iconName Title:(NSString *)titleName optionBtnTitle:(NSString *)btnTitle;

#pragma mark - 验证是否为有效的邮箱地址
+ (BOOL)isValidateEmail:(NSString *)email;
#pragma mark - 检测网络状态
+ (Boolean)checkNetworkState;
#pragma mark - 验证手机号码
+ (BOOL)isValidatePhoneNumber:(NSString *) telNumber;


///日期转string
+(NSString*)dateToString:(NSDate*)date Format:(NSString *)format;
///string转日期
+(NSDate *)stringToDate:(NSString *)strDate Format:(NSString *)format;

////将字符串转换为date  不做timezone转换
+(NSDate *)stringToDateNoTimeZone:(NSString *)strDate withFormat:(NSString *)format;

// 将字典或者数组转化为JSON串
+ (NSData *)toJSONData:(id)theData;

+ (NSString *)getWeekdayWithDate:(NSDate *)date;
///根据日期 获取其对应的星期几 周日是“1”，周一是“2”
+ (NSInteger)getWeekdayTagWithDate:(NSDate *)date;


+(BOOL)isPureInt:(NSString*)string;
+ (BOOL)isPureLong:(NSString*)string;
+ (BOOL)isPureDecimal:(NSString*)string;


#pragma mark - 编辑导航根据id、flag获取其对应的文本信息
///全部时间1 星期时间 2  节假日3
+(NSString *)getNavTimeType:(NSString *)flag;

#pragma mark - 判断string是否为"null"
+(BOOL)isStringNullObject:(NSString *)strObject;
/**
 *  将阿拉伯数字转换为中文数字
 */
+(NSString *)translationArabicNum:(NSInteger)arabicNum;

#pragma  mark - 遍历日期 将其组织成目标数据格式
+(NSArray *)transDateToWeekFormatByStrBeginDate:(NSString *)strBeginDate andStrEndDate:(NSString *)strEndDate;

#pragma  mark - 路径
///根据文件夹名称 生成路径
+ (NSString *)getDocumentsPathByDirName:(NSString *)dirName;


@end
