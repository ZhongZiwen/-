//
//  MsgNotificationViewController.h
//  MenuDemo
//  通知界面
//  Created by sungoin-zbs on 15/6/2.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MsgNotificationViewController : BaseViewController

@property (nonatomic, assign) NSInteger announcementCount; //未读公告数
@property (nonatomic, assign) NSInteger systemNoticeCount; //未读系统通知数
@end
