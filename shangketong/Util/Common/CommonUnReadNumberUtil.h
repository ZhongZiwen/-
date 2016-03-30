//
//  CommonUnReadNumberUtil.h
//  未读消息数
//
//  Created by sungoin-zjp on 16/3/3.
//
//

#import <Foundation/Foundation.h>
@class UnReadNumberModle;


@interface CommonUnReadNumberUtil : NSObject

///使用缓存初始化APP icon badge
+(void)setApplicationIconBadgeNumber;
///获取缓存中的model
+(UnReadNumberModle *)unReadNumberModelInstance;
///根据最新的未读消息数 做缓存+设置图标
+(void)saveUnReadNumberModelAndChangeBadge:(UnReadNumberModle *)model;


///未读消息数++
///type  0企业微信 1待办提醒 2通知 3公告
+(void)unReadNumberIncrease:(NSInteger)type;
///未读消息数-- 0企业微信 1待办提醒 2通知 3公告
+(void)unReadNumberDecrease:(NSInteger)type number:(NSInteger)number;

@end
