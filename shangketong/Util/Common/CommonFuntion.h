//
//  CommonFuntion.h
//  shangketong
//  公用方法类
//  Created by sungoin-zjp on 15-5-20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
@class MBProgressHUD;
@class CommonNoDataView;

@interface CommonFuntion : NSObject

#pragma mark - view相关
+(void)showToast:(NSString *)title inView:(UIView *)view;
// 设置view的frame
+ (CGRect)setViewFrameOffset:(CGRect)frame byX:(float)x byY:(float)y ByWidth:(float) width byHeight:(float)height;

#pragma mark - 没有数据时的view
+(CommonNoDataView*)commonNoDataViewIcon:(NSString *)iconName Title:(NSString *)titleName optionBtnTitle:(NSString *)btnTitle;
//crm  搜索
+(CommonNoDataView*)CRMNoDataViewIcon:(NSString *)iconName Title:(NSString *)titleName optionBtnTitle:(NSString *)btnTitle;
///将颜色值转换未UIImage
+ (UIImage*) createImageWithColor: (UIColor*) color;

#pragma mark - md5加密
+(NSString *)createMD5:(NSString *)signString;

#pragma mark - 字符串相关
// 字符串是否未空串 去除空格
+(BOOL)isEmptyString:(NSString *)str;

/// 校验字符串是否由指定的字符组成
+(BOOL)checkStringIsAllow:(NSString*)str withChar:(NSString *)allchar;

///根据string  font  width 获取Size
+(CGSize)getSizeOfContents:(NSString *)content Font:(UIFont*)font withWidth:(CGFloat)width withHeight:(CGFloat)height;



#pragma mark - 日期相关
///获取年/月/周开始结束时间
+ (void)getDateBeginAndEndWith:(NSDate *)newDate;
///返回一周的第几天(周末为第一天)
+ (NSUInteger)getCurDateWeekday:(NSDate *)newDate;
//获取分钟
+ (NSUInteger)getCurDateMinute:(NSDate *)newDate;
//获取日
+ (NSUInteger)getCurDateDay:(NSDate *)newDate;
//获取月
+ (NSUInteger)getCurDateMonth:(NSDate *)newDate;
//获取年
+ (NSUInteger)getCurDateYear:(NSDate *)newDate;


+(NSDate*)getOneDate:(int)year month:(int)month day:(int)day byDate:(NSDate *)date;
///将毫秒转换为指定格式的日期
+(NSString *)transDateWithTimeInterval:(long long )time withFormat:(NSString *)format;

///将日期转换为 今天 HH:mm /昨天 HH:mm / MM-DD HH:mm
+(NSString *)transDateWithFormatDate:(NSDate *)date;

///判断日期是 过期 今天  明天  将来
+(NSString *)compareDateYTT:(NSDate *)date;

///日期转string
+(NSString*)dateToString:(NSDate*)date Format:(NSString *)format;
-(NSString *)dateToString2:(NSDate *)date Format:(NSString *)format;
///string转日期
+(NSDate *)stringToDate:(NSString *)strDate Format:(NSString *)format;
#pragma mark - 根据日期 获取对应的格式
+ (NSString *)formateLongDate:(long long)itemDate;
#pragma mark - 将毫秒转换为时间  指定格式
+ (NSString *)getStringForTime:(long long)time withFormat:(NSString *)format;

///动态、评论日期格式
+ (NSString *)commentOrTrendsDateCommonByLong:(long long)itemDate;
///评论日期格式 date
+ (NSString *)commentOrTrendsDateCommonByDate:(NSDate *)date;

#pragma mark - 根据日期 获取对应的格式  公用
+ (NSString *)formateLongDateCommon:(long long)itemDate;
///获取回收日期格式
+(NSString *)getDateOfExpire:(long long) expireTime;

///获取当前日期范围  早上  下午  晚上
+(NSString *)getCurDateZone:(NSDate *)date;

#pragma mark - 格式转换
///将byte转换为GB MB KB
+(NSString *)byteConversionGBMBKB:(long)KSize;

///将float转为保留小数点后指定位数的格式
+(NSString *)formatFloatToPointNumber:(float)f byForamt:(NSString *)format;


#pragma mark - 文件相关
///判断指定的文件是否存在
+(BOOL)isExistsFileInDocument:(NSString *)fileName;

///跟进文件名读取本地json数据
+(id)readJsonFile:(NSString *)fileName;

#pragma mark - 搜索匹配
///匹配
+(BOOL)searchResult:(NSString *)sourceT searchText:(NSString *)searchT;

#pragma mark - 拨打电话
+(void)callToCurPhoneNum:(NSString *)phoneNum atView:(UIView *)view;

#pragma mark - 显示HUD
+ (void)showHUD:(NSString *)text andView:(UIView *)view andHUD:(MBProgressHUD *)hud;


#pragma mark - 日程、首页 用到的根据颜色值判断显示颜色
+ (UIColor *)getColorValueByColorType:(NSInteger )type;
#pragma mark - 将毫秒转换为时间 年月日时分秒
+ (NSString *)getStringForTime:(long long)time;


#pragma mark - 获取字符串中@对应的关键词对应的userid
+(NSArray *)getAtUserIds:(NSString *)content atArray:(NSArray *)atArray isAddressBookArray:(BOOL)isAddressBook;
#pragma mark - 将字符串中@对应的关键词做处理 重新生成有效的字符串
+(NSString *)searchAtCharAndSetItValid:(NSString *)content atArray:(NSArray *)atArray isAddressBookArray:(BOOL)isAddressBook;
#pragma mark - @人id集合,以“,”分隔开）
+(NSString *)getStringStaffIds:(NSArray *)arrayStaffs;
#pragma mark - 将时间转化为字符串
+ (NSString *)dateToString:(NSDate *)date;


#pragma mark - 检测网络状态
+ (Boolean)checkNetworkState;

#pragma mark -  两个日期相隔天数
+ (NSInteger)getTimeDaysSinceToady:(NSString *)time;
#pragma mark - 判断可以对应的value是否为nil
+ (BOOL)checkNullForValue:(id )value;
#pragma mark - json串 转换为字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

#pragma mark - 获取图片格式
+ (NSString *)typeForImageData:(NSData *)data;
///获取文件名称  如为nil 则填充当前日期
+(NSString *)getFileNameDeleteEctension:(NSString *)originalFileName;

#pragma mark - 验证手机是否有效
///验证手机是否有效  纯数字+11位
+ (BOOL)isMobileNumber:(NSString *)mobileNum;

#pragma mark -  将汉字转换为拼音首字母
+(NSString *)namToPinYinFisrtNameWith:(NSString *)name;

#pragma mark -  生成目录路径
+(NSString *)createDocumentsPath;

@end
