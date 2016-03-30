//
//  CommonStaticVar.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CommonStaticVar.h"

#pragma mark - 动态内容字体大小、颜色

///区分不同页面进入到动态页面
static NSString *flagOfWorkGroupViewFrom;

///区分不同数据源下的cell
static NSString *typeOfWorkGroupCellInfo;
///字体大小
static CGFloat contentFontSize ;
///颜色
static UIColor *contentColor;

#pragma mark - 其他

//---------------------联络中心-------------------------//
#pragma nark - 联络中心
///区分是boss用户还是普通用户
static NSString *accountType;
///是否显示版本信息
static NSString *showVersionView;

///标记是否从联络中心进入  llcenter
static NSString *fromLLCenterView;

///(ivr是否开通：1-是，0-否)
static NSInteger ivrStatus;
///(彩铃是否开通：1-是，0-否)
static NSInteger ringStatus;
///(炫铃是否开通：1-是，0-否)
static NSInteger ringtoneStatus;
//-----------------------联络中心-----------------------//


@implementation CommonStaticVar


#pragma mark - setter  getter 区分不同页面进入到动态页面

+(void)setFlagOfWorkGroupViewFrom:(NSString *)type {
    flagOfWorkGroupViewFrom = type;
}

+(NSString *)getFlagOfWorkGroupViewFrom{
    return flagOfWorkGroupViewFrom;
}

#pragma mark - setter  getter 区分不同数据源下的cell

+(void)setTypeOfWorkGroupCellInfo:(NSString *)type {
    typeOfWorkGroupCellInfo = type;
}

+(NSString *)getTypeOfWorkGroupCellInfo{
    return typeOfWorkGroupCellInfo;
}

#pragma mark - setter  getter 动态内容字体大小、颜色
+(void)setContentFont:(CGFloat )fontSize color:(UIColor *)color{
    contentFontSize = fontSize;
    contentColor = color;
}

+(CGFloat )getContentFontSize{
    return contentFontSize;
}

+(UIColor *)getContentColor{
    return contentColor;
}


//---------------------联络中心-------------------------//
#pragma nark - 联络中心
#pragma mark - setter  getter boss用户还是普通用户
+(void)setAccountType:(NSString *)type {
    accountType = type;
}

+(NSString *)getAccountType{
    return accountType;
}

#pragma mark - setter  getter boss是否显示版本信息
+(void)setShowVersionView:(NSString *)show {
    showVersionView = show;
}

+(NSString *)getShowVersionView{
    return showVersionView;
}

#pragma mark - setter  getter 是否是联络中心进入  llcenter
+(void)setFromLLCenterView:(NSString *)flag {
    fromLLCenterView = flag;
}
+(NSString *)getFromLLCenterView{
    return fromLLCenterView;
}

#pragma mark - setter  getter ivr是否开通
+(void)setIvrStatus:(NSInteger)status {
    ivrStatus = status;
}
+(NSInteger)getIvrStatus{
    return ivrStatus;
}


#pragma mark - setter  getter 彩铃是否开通
+(void)setRingStatus:(NSInteger)status {
    ringStatus = status;
}
+(NSInteger)getRingStatus{
    return ringStatus;
}


#pragma mark - setter  getter 炫铃是否开通
+(void)setRingtoneStatus:(NSInteger)status {
    ringtoneStatus = status;
}
+(NSInteger)getRingtoneStatus{
    return ringtoneStatus;
}




//-----------------------联络中心-----------------------//


@end
