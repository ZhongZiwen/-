//
//  AppDelegate.h
//  shangketong
//
//  Created by sungoin-zbs on 15/4/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBMoudle.h"
#import "GBCellMoudle.h"
#import "SRWebSocket.h"
#import "Reachability.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate, SRWebSocketDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) GBMoudle *moudle;
@property (nonatomic, retain) GBCellMoudle *cellMoudle;
@property (nonatomic, strong) SRWebSocket *webSocket;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) NSTimer *startTime; //socket练接失败之后开启定时器
@property (nonatomic, assign) BOOL isNetwork; //是否有网络
@property (nonatomic, strong) NSTimer *heartTimer; //心跳timer

/**
 * 设置主视图
 */
- (void) setupRootViewController;

/**
 * 设置引导动画
 */
- (void) setupGuideViewController;
//获取全部审批，全部工作报告的权限
- (void)getAllReportAndApprove;
//关闭scoket
- (void)deleteWebSocket;
//链接socket
- (void)_reconnect;
//移除定时器
- (void)removeTimer;
- (void)removeHeartTimer;
@end
