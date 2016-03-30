//
//  CommonLocalNotification.h
//  shangketong
//  未读消息轮询
//  Created by sungoin-zjp on 15-12-19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUnReadMsgForCycle : NSObject


#pragma mark - 未读消息轮询
-(void)getUnReadMsgForCycle;

#pragma mark - 标记为已读公告
-(void)sendCmdReadSysAnnouncement;

@end
