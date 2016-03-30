//
//  CommonUnReadNumberUtil.m
//  
//
//  Created by sungoin-zjp on 16/3/3.
//
//

#import "CommonUnReadNumberUtil.h"
#import "UnReadNumberModle.h"
#import "NSUserDefaults_Cache.h"

@implementation CommonUnReadNumberUtil


///获取实例
+ (CommonUnReadNumberUtil*)sharedUnReadNumber {
    static dispatch_once_t onceToken;
    static CommonUnReadNumberUtil *management = nil;
    dispatch_once(&onceToken, ^{
        management = [[CommonUnReadNumberUtil alloc] init];
    });
    return management;
}

///使用缓存初始化APP icon badge
+(void)setApplicationIconBadgeNumber{
    UnReadNumberModle *model = [self unReadNumberModelInstance];
    ///未读消息总数
    NSInteger unReadNum = [model.number_remind integerValue] + [model.number_inform integerValue] + [model.number_message integerValue] + [model.number_announcement integerValue];
    NSLog(@"setApplicationIconBadgeNumber :%ti",unReadNum);
    ///设置ICON BADGE
    if (unReadNum <= 0) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }else{
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unReadNum];
    }
}

///获取缓存中的model
+(UnReadNumberModle *)unReadNumberModelInstance{
    UnReadNumberModle *unreadModel = [NSUserDefaults_Cache getApplicationIconBadgeModel];
    if (!unreadModel) {
        unreadModel = [[UnReadNumberModle alloc] init];
        unreadModel.number_message = @"0";
        unreadModel.number_remind = @"0";
        unreadModel.number_inform = @"0";
        unreadModel.number_announcement = @"0";
    }
    return unreadModel;
}


///根据最新的未读消息数 做缓存+设置图标
+(void)saveUnReadNumberModelAndChangeBadge:(UnReadNumberModle *)model{
    ///缓存数据
    [NSUserDefaults_Cache setApplicationIconBadgeModel:model];
    
//    ///未读消息总数
    NSInteger unReadNum = [model.number_remind integerValue] + [model.number_inform integerValue] + [model.number_message integerValue] + [model.number_announcement integerValue];
    ///设置ICON BADGE
    if (unReadNum <= 0) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }else{
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unReadNum];
    }
    
}


///未读消息数++
///type  0企业微信 1待办提醒 2通知 3公告
+(void)unReadNumberIncrease:(NSInteger)type{
    UnReadNumberModle *unreadModel = [self unReadNumberModelInstance];
    switch (type) {
        case 0:
            unreadModel.number_message = [NSString stringWithFormat:@"%ti",[unreadModel.number_message integerValue]+1];
            break;
        case 1:
            unreadModel.number_remind = [NSString stringWithFormat:@"%ti",[unreadModel.number_remind integerValue]+1];
            break;

        case 2:
            unreadModel.number_inform = [NSString stringWithFormat:@"%ti",[unreadModel.number_inform integerValue]+1];
            break;

        case 3:
            unreadModel.number_announcement = [NSString stringWithFormat:@"%ti",[unreadModel.number_announcement integerValue]+1];
            break;
            
        default:
            break;
    }
    [self saveUnReadNumberModelAndChangeBadge:unreadModel];
}

///未读消息数-- 0企业微信 1待办提醒 2通知 3公告
+(void)unReadNumberDecrease:(NSInteger)type number:(NSInteger)number{
    UnReadNumberModle *unreadModel = [self unReadNumberModelInstance];
    switch (type) {
        case 0:
            unreadModel.number_message = [NSString stringWithFormat:@"%ti",[unreadModel.number_message integerValue]-number];
            if ([unreadModel.number_message integerValue] < 0) {
                unreadModel.number_message = @"0";
            }
            break;
        case 1:
            unreadModel.number_remind = [NSString stringWithFormat:@"%ti",[unreadModel.number_remind integerValue]-number];
            if ([unreadModel.number_remind integerValue] < 0) {
                unreadModel.number_remind = @"0";
            }
            break;
            
        case 2:
            unreadModel.number_inform = [NSString stringWithFormat:@"%ti",[unreadModel.number_inform integerValue]-number];
            if ([unreadModel.number_inform integerValue] < 0) {
                unreadModel.number_inform = @"0";
            }
            break;
            
        case 3:
            unreadModel.number_announcement = [NSString stringWithFormat:@"%ti",[unreadModel.number_announcement integerValue]-number];
            if ([unreadModel.number_announcement integerValue] < 0) {
                unreadModel.number_announcement = @"0";
            }
            break;
            
        default:
            break;
    }
    [self saveUnReadNumberModelAndChangeBadge:unreadModel];
}

@end
