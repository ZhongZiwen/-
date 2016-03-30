//
//  CommonUnReadTabBarPoint.m
//  shangketong
//
//  Created by sungoin-zjp on 15-12-19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//


///  modelCode = @"1001,1002,1003"
#define SKT_UNREAD_MSG_TABBAR_SKT 1000
#define SKT_UNREAD_MSG_TABBAR_IM 1001
#define SKT_UNREAD_MSG_TABBAR_CRM 1002
#define SKT_UNREAD_MSG_TABBAR_OA 1003
#define SKT_UNREAD_MSG_TABBAR_ME 1004

#define SKT_UNREAD_MSG_TABBAR_POINT_SIZE 8

#import "CommonUnReadTabBarPoint.h"
#import "GBMoudle.h"
#import "AppDelegate.h"
#import "CommonUnReadNumberUtil.h"
#import "UnReadNumberModle.h"


@implementation CommonUnReadTabBarPoint

#pragma mark - 设置 红点显示与隐藏  登录/未登录

///根据返回码 控制红点的显示与隐藏
+(void)notifyTabBarItemUnReadIcon:(NSString *)modelCode{
    [self initTabbarIconView];
    ///默认全隐藏
    [self hideAllPoint];
    if(modelCode && modelCode.length >0){
        NSArray *arrCodes = [modelCode componentsSeparatedByString:@","];
        NSLog(@"arrCodes:%@",arrCodes);
        NSInteger count = 0;
        if(arrCodes){
            count = [arrCodes count];
        }
        NSLog(@"count:%ti",count);
        for(int i=0; i<count; i++){
            NSInteger model = [[arrCodes objectAtIndex:i] integerValue];
            switch(model){
                case SKT_UNREAD_MSG_TABBAR_SKT:
                {
                   appDelegateAccessor.moudle.icon_unread_skt.hidden = NO;
                }
                    break;
                case SKT_UNREAD_MSG_TABBAR_IM:
                {
                    appDelegateAccessor.moudle.icon_unread_im.hidden = NO;
                }
                    break;
                case SKT_UNREAD_MSG_TABBAR_CRM:
                {
                    appDelegateAccessor.moudle.icon_unread_crm.hidden = NO;
                }
                    break;
                case SKT_UNREAD_MSG_TABBAR_OA:
                {
                    appDelegateAccessor.moudle.icon_unread_oa.hidden = NO;

                }
                    break;
                case SKT_UNREAD_MSG_TABBAR_ME:
                {
                    appDelegateAccessor.moudle.icon_unread_me.hidden = NO;
                }
                    break;
                default:
                    break;
            }
        }
    }
    
    ///有未读IM消息
    UnReadNumberModle *model = [CommonUnReadNumberUtil unReadNumberModelInstance];
    if ([model.number_message integerValue] > 0) {
        appDelegateAccessor.moudle.icon_unread_im.hidden = NO;
    }
    
    ///工作圈有新动态
    if (appDelegateAccessor.moudle.icon_oa_workzone_newtrends && appDelegateAccessor.moudle.icon_oa_workzone_newtrends.length > 0) {
        appDelegateAccessor.moudle.icon_unread_oa.hidden = NO;
    }
}

///初始化红点
+(void)initTabbarIconView{

    NSInteger xOffset = (kScreen_Width-320)/5;
    NSInteger yPoint = 10;
    
    NSInteger xByPhone = 0;
    if (DEVICE_IS_IPHONE6) {
        xByPhone = -5;
    }else if(DEVICE_IS_IPHONE6_PLUS){
        xByPhone = -7;
    }
    
    ///首页
    if (appDelegateAccessor.moudle.icon_unread_skt == nil) {
        appDelegateAccessor.moudle.icon_unread_skt = [[UIImageView alloc]initWithFrame:CGRectMake(40+xOffset+xByPhone, yPoint, SKT_UNREAD_MSG_TABBAR_POINT_SIZE, SKT_UNREAD_MSG_TABBAR_POINT_SIZE)];
        appDelegateAccessor.moudle.icon_unread_skt.image = [UIImage imageNamed:@"badge_1.png"];
        appDelegateAccessor.moudle.icon_unread_skt.hidden = YES;
    }
   
    ///IM
    if (appDelegateAccessor.moudle.icon_unread_im == nil) {
        appDelegateAccessor.moudle.icon_unread_im = [[UIImageView alloc]initWithFrame:CGRectMake(105+xOffset*2+xByPhone, yPoint, SKT_UNREAD_MSG_TABBAR_POINT_SIZE, SKT_UNREAD_MSG_TABBAR_POINT_SIZE)];
        appDelegateAccessor.moudle.icon_unread_im.image = [UIImage imageNamed:@"badge_1.png"];
        appDelegateAccessor.moudle.icon_unread_im.hidden = YES;
    }
    
    ///CRM
    if (appDelegateAccessor.moudle.icon_unread_crm == nil) {
        appDelegateAccessor.moudle.icon_unread_crm = [[UIImageView alloc]initWithFrame:CGRectMake(170+xOffset*3+xByPhone, yPoint, SKT_UNREAD_MSG_TABBAR_POINT_SIZE, SKT_UNREAD_MSG_TABBAR_POINT_SIZE)];
        appDelegateAccessor.moudle.icon_unread_crm.image = [UIImage imageNamed:@"badge_1.png"];
        appDelegateAccessor.moudle.icon_unread_crm.hidden = YES;
    }
    
    ///OA
    if (appDelegateAccessor.moudle.icon_unread_oa == nil) {
        appDelegateAccessor.moudle.icon_unread_oa = [[UIImageView alloc]initWithFrame:CGRectMake(235+xOffset*4+xByPhone, yPoint, SKT_UNREAD_MSG_TABBAR_POINT_SIZE, SKT_UNREAD_MSG_TABBAR_POINT_SIZE)];
        appDelegateAccessor.moudle.icon_unread_oa.image = [UIImage imageNamed:@"badge_1.png"];
        appDelegateAccessor.moudle.icon_unread_oa.hidden = YES;
    }
    
    ///ME
    if (appDelegateAccessor.moudle.icon_unread_me == nil) {
        appDelegateAccessor.moudle.icon_unread_me = [[UIImageView alloc]initWithFrame:CGRectMake(295+xOffset*5+xByPhone, yPoint, SKT_UNREAD_MSG_TABBAR_POINT_SIZE, SKT_UNREAD_MSG_TABBAR_POINT_SIZE)];
        appDelegateAccessor.moudle.icon_unread_me.image = [UIImage imageNamed:@"badge_1.png"];
        appDelegateAccessor.moudle.icon_unread_me.hidden = YES;
    }
}

+(void)hideAllPoint{
    appDelegateAccessor.moudle.icon_unread_skt.hidden = YES;
    appDelegateAccessor.moudle.icon_unread_im.hidden = YES;
    appDelegateAccessor.moudle.icon_unread_crm.hidden = YES;
    appDelegateAccessor.moudle.icon_unread_oa.hidden = YES;
    appDelegateAccessor.moudle.icon_unread_me.hidden = YES;
}


+(void)setViewByNotificatoin{
    BOOL isShow = FALSE;
    
    if (0) {
        //显示红点
        isShow = TRUE;
    }else{
        //隐藏红点
        isShow = FALSE;
    }
    
   
}



@end
