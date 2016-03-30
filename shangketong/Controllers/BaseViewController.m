//
//  BaseViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//


#import "BaseViewController.h"
#import "ScheduleDetailViewController.h"
#import "XLFTaskDetailViewController.h"
#import "NSUserDefaults_Cache.h"
#import "CWStatusBarNotification.h"
#import "StatusBarMsgView.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

//- (void)loadView {
//    [super loadView];
//    
//    self.view.backgroundColor = kView_BG_Color;
//    self.automaticallyAdjustsScrollViewInsets = YES;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    appDelegateAccessor.moudle.controllerCurView = self;
    ///注册
    [self RegistLocalNotificationForMessage];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    appDelegateAccessor.moudle.controllerCurView = nil;
    ///移除
    [self removeLocalNotificationForMessage];
}


#pragma mark - 本地通知事件
-(void)RegistLocalNotificationForMessage
{
    NSLog(@"注册本地消息通知事件...");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoLocalNotificationView:) name:SKT_LOCAL_NOTIFICATION_OBSERVER_NAME1 object:nil];
    
    if (!appDelegateAccessor.moudle.isIMView) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoLocalNotificationIMView:) name:SKT_LOCAL_NOTIFICATION_OBSERVER_NAME2 object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNotificationIMView:) name:SKT_LOCAL_NOTIFICATION_OBSERVER_NAME3 object:nil];
    }
}

-(void)removeLocalNotificationForMessage{
    NSLog(@"移除本地消息通知事件...");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SKT_LOCAL_NOTIFICATION_OBSERVER_NAME1 object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SKT_LOCAL_NOTIFICATION_OBSERVER_NAME2 object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SKT_LOCAL_NOTIFICATION_OBSERVER_NAME3 object:nil];
}

/// IM消息 顶部view
- (void)showNotificationIMView:(NSNotification*) notification{
    if([NSUserDefaults_Cache getIMMessageStatu]){
        NSLog(@"showNotificationIMView :%@",notification);
        NSLog(@"showNotificationIMView  userinfo:%@",notification.userInfo);
        NSDictionary *item = notification.userInfo;
//        [NSObject showStatusBarSuccessStr:[item safeObjectForKey:@"content"]];
        [self showNotifyViewForIm:[item safeObjectForKey:@"content"]];
    }
}

///IM 弹框
-(void)showNotifyViewForIm:(NSString *)content{
    if (!appDelegateAccessor.moudle.notificationIM) {
        appDelegateAccessor.moudle.notificationIM = [CWStatusBarNotification new];
        appDelegateAccessor.moudle.notificationIM.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
        appDelegateAccessor.moudle.notificationIM.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
        appDelegateAccessor.moudle.notificationIM.notificationStyle = CWNotificationStyleNavigationBarNotification;
    }
//    else{
//        [appDelegateAccessor.moudle.notificationIM dismissNotification];
//    }
    
    if (!appDelegateAccessor.moudle.viewStatusBarIM) {
        appDelegateAccessor.moudle.viewStatusBarIM = (StatusBarMsgView *)[[NSBundle mainBundle] loadNibNamed:@"StatusBarMsgView" owner:nil options:nil][0];
        
        appDelegateAccessor.moudle.viewStatusBarIM.frame = CGRectMake(0, 0, kScreen_Width, 64);
        appDelegateAccessor.moudle.viewStatusBarIM.imgIcon.frame = CGRectMake(5, 5, 16, 16);
        appDelegateAccessor.moudle.viewStatusBarIM.labelTitle.frame = CGRectMake(30, 3, kScreen_Width-40, 20);
        appDelegateAccessor.moudle.viewStatusBarIM.labelContent.frame = CGRectMake(30, 22, kScreen_Width-40, 40);
        
        appDelegateAccessor.moudle.viewStatusBarIM.imgIcon.contentMode = UIViewContentModeScaleAspectFill;
        
        appDelegateAccessor.moudle.viewStatusBarIM.labelContent.numberOfLines = 2;
        appDelegateAccessor.moudle.viewStatusBarIM.labelContent.lineBreakMode = NSLineBreakByCharWrapping | NSLineBreakByTruncatingTail;
    }
    
    
    appDelegateAccessor.moudle.viewStatusBarIM.labelTitle.text = @"商客通";
    appDelegateAccessor.moudle.viewStatusBarIM.labelContent.text = content;
    
    [appDelegateAccessor.moudle.notificationIM displayNotificationWithView:appDelegateAccessor.moudle.viewStatusBarIM forDuration:2];
}


/// IM消息  进行页面跳转
- (void)gotoLocalNotificationIMView:(NSNotification*) notification
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.tabBarController setSelectedIndex:1];
}

/// 根据不同消息  进行页面跳转
- (void)gotoLocalNotificationView:(NSNotification*) notification
{
    NSLog(@"gotoLocalNotificationView:%@",notification);
    /*
     {
     NotificationId = 1018;
     NotificationTag = "skt_unread_msg_localnotification_schedule";
     NotificationType = SCHEDULE;
     }
     */
    
    if (notification) {
        
        NSLog(@"userInfo:%@",[notification userInfo]);
        NSLog(@"object:%@",[[notification object] userInfo]);
        NSDictionary *infos = [[notification object] userInfo];
        if ([[infos objectForKey:@"NotificationType"] isEqualToString:@"SCHEDULE"]) {
            NSLog(@"日程通知");
            [self gotoScheduleDetailsView:[infos objectForKey:@"NotificationId"]];
        }else if ([[infos objectForKey:@"NotificationType"] isEqualToString:@"TASK"]) {
            NSLog(@"任务通知");
            [self gotoTaskDetailsView:[infos objectForKey:@"NotificationId"]];
        }
        else if ([[infos objectForKey:@"NotificationType"] isEqualToString:@"IM"]) {
            NSLog(@"IM通知");
        }
    }
}


#pragma mark - 跳转到日程详情页面
-(void)gotoScheduleDetailsView:(NSString *)schId{
    ScheduleDetailViewController *scheduleDetailController = [[ScheduleDetailViewController alloc] init];
    scheduleDetailController.scheduleId = [schId integerValue];
    scheduleDetailController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:scheduleDetailController animated:YES];
}

-(void)gotoTaskDetailsView:(NSString *)taskId{
    XLFTaskDetailViewController *taskDetailController = [[XLFTaskDetailViewController alloc] init];
    taskDetailController.uid = taskId;
    taskDetailController.title = @"任务详情";
    taskDetailController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:taskDetailController animated:YES];
}

@end
