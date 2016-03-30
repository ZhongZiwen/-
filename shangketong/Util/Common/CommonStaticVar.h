//
//  CommonStaticVar.h
//  shangketong
//  全局静态变量
//  Created by sungoin-zjp on 15-6-18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonStaticVar : NSObject


#pragma mark - setter  getter 区分不同页面进入到动态页面

+(void)setFlagOfWorkGroupViewFrom:(NSString *)type;
+(NSString *)getFlagOfWorkGroupViewFrom;

#pragma mark - setter  getter 区分不同数据源下的cell
+(void)setTypeOfWorkGroupCellInfo:(NSString *)type;
+(NSString *)getTypeOfWorkGroupCellInfo;

#pragma mark - 动态内容字体大小、颜色
+(void)setContentFont:(CGFloat)fontSize color:(UIColor *)color;
+(CGFloat )getContentFontSize;
+(UIColor *)getContentColor;

#pragma mark - 其他


//---------------------联络中心-------------------------//
#pragma nark - 联络中心

#pragma mark - setter  getter boss用户还是普通用户
+(void)setAccountType:(NSString *)type;
+(NSString *)getAccountType;

#pragma mark - setter  getter boss是否显示版本信息
+(void)setShowVersionView:(NSString *)show ;
+(NSString *)getShowVersionView;


#pragma mark - setter  getter boss是否是联络中心进入
+(void)setFromLLCenterView:(NSString *)show ;
+(NSString *)getFromLLCenterView;


#pragma mark - setter  getter ivr是否开通
+(void)setIvrStatus:(NSInteger)status;
+(NSInteger)getIvrStatus;


#pragma mark - setter  getter 彩铃是否开通
+(void)setRingStatus:(NSInteger)status;
+(NSInteger)getRingStatus;


#pragma mark - setter  getter 炫铃是否开通
+(void)setRingtoneStatus:(NSInteger)status;
+(NSInteger)getRingtoneStatus;

//-----------------------联络中心-----------------------//


@end
