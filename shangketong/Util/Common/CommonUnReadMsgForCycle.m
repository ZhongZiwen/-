//
//  CommonUnReadMsgForCycle.m
//  shangketong
//  
//  Created by sungoin-zjp on 15-12-19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//






///本地推送消息key标识  IM 任务 日程
#define SKT_UNREAD_MSG_LOCALNOTIFICATION_KEY_IM   @"skt_unread_msg_localnotification_im"
#define SKT_UNREAD_MSG_LOCALNOTIFICATION_KEY_TASK   @"skt_unread_msg_localnotification_task"
#define SKT_UNREAD_MSG_LOCALNOTIFICATION_KEY_SCHEDULE   @"skt_unread_msg_localnotification_schedule"


#import "CommonUnReadMsgForCycle.h"
#import "NSUserDefaults_Cache.h"
#import "AFNHttp.h"
#import "CommonUnReadTabBarPoint.h"
#import "NSUserDefaults_Cache.h"

#import "PopupView.h"
#import "LewPopupViewController.h"

@implementation CommonUnReadMsgForCycle

/*
 
 参数:serverTime (如果为空不传)
 isVictoryExist(如果为空不传)
 
 MESSAGE_UNREAD_FOR_CYCLE
 oa/message/getUnReadMsgForCycle.do 轮询接口
 
 private int remindCount;    // 提醒的数目
 private int noticeCount;   //通知的数目
 private String content;       //消息的内容
 private String modelCode;   //要显示气泡的模块
 private int isVictoryExist; //是否要求服务端再次去查询喜报
 private List<Long> remindTasks; //任务提醒
 private List<Long> remindSchedules;//日程提醒
 private long serverTime;  //服务器返回时间
 
 */






/*
 {
 content = "<null>";
 desc = "<null>";
 isVictoryExist = 1;
 modelCode = "";
 noticeCount = 0;
 remindCount = 0;
 remindSchedules =     (
 );
 remindTasks =     (
 );
 serverTime = 1450495756997;
 status = 0;
 }
 */
#pragma mark - 未读消息轮询
-(void)getUnReadMsgForCycle{
    
    if (![NSUserDefaults_Cache getUserLoginStatus]) {
        return;
    }

    NSString *serverTime = [NSUserDefaults_Cache getSKTUnReadMsgCycleServerTime];
    NSInteger victoryFlg = [NSUserDefaults_Cache getSKTUnReadMsgCycleVictoryFlag];
    NSString *serverTimeOaTrend = [NSUserDefaults_Cache getSKTUnReadOATrendCycleServerTime];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    NSInteger dayCount = 0;
    if((!serverTime || [serverTime isEqualToString:@""])){
        dayCount = -1;
    }else{
        ///判断是不是今天
        dayCount =  [CommonFuntion getTimeDaysSinceToady:[CommonFuntion transDateWithTimeInterval:[serverTime longLongValue] withFormat:@"yyyy-MM-dd"]];
        NSLog(@"dayCount:%ti",dayCount);
    }
    
    
    ///不是今天
    if (dayCount != 0) {
        [self saveServerVictoryFlag:-1];
    }else{
        if(serverTime && ![serverTime isEqualToString:@""]){
            [params setObject:serverTime forKey:@"serverTime"];
        }
        
        NSLog(@"victoryFlg:%ti",victoryFlg);
        if(victoryFlg != -1){
            [params setObject:[NSNumber numberWithInteger:victoryFlg] forKey:@"isVictoryExist"];
        }
    }
    
    ///动态时间戳
    if (serverTimeOaTrend) {
        [params setObject:serverTimeOaTrend forKey:@"snsTime"];
    }
    
    NSLog(@"getUnReadMsgForCycle params:%@",params);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA,MESSAGE_UNREAD_FOR_CYCLE] params:params success:^(id responseObj) {
        //字典转模型
        NSLog(@"getUnReadMsgForCycle responseObj:%@",responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            ///保存servertime / victory
            [self saveServerTimeFlag:responseObj];
           NSInteger isVictoryExist = [[responseObj safeObjectForKey:@"isVictoryExist"] integerValue];
            
            if (appDelegateAccessor.moudle.controllerCurView == nil) {
                NSLog(@"isVictoryShowAlready  --controllerCurView  nil-->");
            }
            
            ///不做处理
            if (victoryFlg == 0) {
                
            }else{
                ///isVictoryExist 0 添加喜报弹框
                if (isVictoryExist == 0) {
                    
                    if (appDelegateAccessor.moudle.controllerCurView) {
                        if (!appDelegateAccessor.moudle.isVictoryShowAlready) {
                            NSLog(@"isVictoryShowAlready  notshow");
                            [self showVictoryView];
                        }else{
                            ///设置为继续查询
                            [self saveServerVictoryFlag:-1];
                            NSLog(@"isVictoryShowAlready  show");
                        }
                    }else{
                        ///设置为继续查询
                        [self saveServerVictoryFlag:-1];
                    }
                    
                }else{
                    ///设置为继续查询
                    [self saveServerVictoryFlag:-1];
                }
            }
            
            ///最新动态
            [self notifyNewTrends:responseObj];
            
            ///刷新底部tabbar 红点
            [CommonUnReadTabBarPoint notifyTabBarItemUnReadIcon:[responseObj safeObjectForKey:@"modelCode"]];
            ///IM添加本地消息通知
            [self addLocalNotificationForIM:responseObj];
            ///日程添加通知
            [self addLocalNotificationForSchedule:responseObj];
            ///任务添加本地消息通知
            [self addLocalNotificationForTask:responseObj];
            
            ///系统通知
            [self showSystemInformsView:responseObj];
            
        }else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
               
            };
            [comRequest loginInBackground];
        }
        else{
            NSLog(@"轮询失败------>");
            ///最新动态
            [self notifyNewTrends:nil];
            [CommonUnReadTabBarPoint notifyTabBarItemUnReadIcon:@""];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        ///最新动态
        [self notifyNewTrends:nil];
        [CommonUnReadTabBarPoint notifyTabBarItemUnReadIcon:@""];
        
    }];
    
}

///保存servertime / victory
-(void)saveServerVictoryFlag:(NSInteger)isVictoryExist{
    ///存储请求参数
     NSLog(@"isVictoryExist:%ti",isVictoryExist);
    [NSUserDefaults_Cache setSKTUnReadMsgCycleVictoryFlag:isVictoryExist];
}


-(void)saveServerTimeFlag:(NSDictionary *)unReadInfo{
    ///存储请求参数
    NSString *serverTime = [unReadInfo safeObjectForKey:@"serverTime"];
    NSLog(@"serverTime:%@",serverTime);
    if (serverTime) {
        [NSUserDefaults_Cache setSKTUnReadMsgCycleServerTime:serverTime];
    }
}

#pragma mark - 添加本地推送

#pragma mark 消息模块
-(void)addLocalNotificationForIM:(NSDictionary *)unReadInfo{
    ///通知
    NSInteger noticeCount = [[unReadInfo safeObjectForKey:@"noticeCount"] integerValue];
    ///待办提醒
    NSInteger remindCount = [[unReadInfo safeObjectForKey:@"remindCount"] integerValue];
    NSString *content = @"";
    
    if (noticeCount + remindCount == 0) {
        NSLog(@"IM 无未读消息");
        return;
    }else if (noticeCount + remindCount == 1) {
        ///总共一条消息
        content = [unReadInfo safeObjectForKey:@"content"];
        if (content == nil || [content isEqualToString:@""]) {
            if (noticeCount == 1) {
                content = @"您有一条未读通知";
            }
            if (remindCount == 1) {
                content = @"您有一条未读待办提醒";
            }
        }
    }else if (noticeCount + remindCount > 1){
        if (noticeCount > 0) {
           content = [NSString stringWithFormat:@"您有%ti条未读通知",noticeCount];
            if (remindCount > 0) {
                content = [NSString stringWithFormat:@"%@,%ti条未读待办提醒",content,remindCount];
            }
        }else{
            content = [NSString stringWithFormat:@"您%ti条未读待办提醒",remindCount];
        }
    }
    
    ///type / tag
    NSDictionary *infos = [NSDictionary dictionaryWithObjectsAndKeys:@"IM",@"NotificationType",SKT_UNREAD_MSG_LOCALNOTIFICATION_KEY_IM,@"NotificationTag", nil];
    [self addNotification:content withInfo:infos];
}

#pragma mark 日程
-(void)addLocalNotificationForSchedule:(NSDictionary *)unReadInfo{
    //    remindSchedules =     (
//    1016,
//    1015
//    )
    
    if (unReadInfo && [unReadInfo objectForKey:@"remindSchedules"]) {
        NSLog(@"addLocalNotificationForSchedule--->");
        
        NSArray *scheduleIds = [unReadInfo objectForKey:@"remindSchedules"];

        NSInteger count = 0;
        if (scheduleIds) {
            count = [scheduleIds count];
        }
        
        NSLog(@"count:%ti",count);
        for (int i=0; i<count; i++) {
            
            NSString *schId = [NSString stringWithFormat:@"%ti",[[scheduleIds objectAtIndex:i] integerValue]];
            
            NSString *content = @"您有一条待处理的日程";
            ///type / tag
            NSDictionary *infos = [NSDictionary dictionaryWithObjectsAndKeys:@"SCHEDULE",@"NotificationType",SKT_UNREAD_MSG_LOCALNOTIFICATION_KEY_SCHEDULE,@"NotificationTag", schId,@"NotificationId",nil];
            
            [self addNotification:content withInfo:infos];
        }
    }
}

#pragma mark 任务
-(void)addLocalNotificationForTask:(NSDictionary *)unReadInfo{
//    remindTasks =     (
//    );
    if (unReadInfo && [unReadInfo objectForKey:@"remindTasks"]) {
        NSLog(@"addLocalNotificationForTask--->");
        
        NSArray *taskIds = [unReadInfo objectForKey:@"remindTasks"];
        NSInteger count = 0;
        if (taskIds) {
            count = [taskIds count];
        }
        
        NSLog(@"count:%ti",count);
        for (int i=0; i<count; i++) {
            
            NSString *tasId = [NSString stringWithFormat:@"%ti",[[taskIds objectAtIndex:i] integerValue]];
            
            NSString *content = @"您有一条待处理的任务";
            ///type / tag
            NSDictionary *infos = [NSDictionary dictionaryWithObjectsAndKeys:@"TASK",@"NotificationType",SKT_UNREAD_MSG_LOCALNOTIFICATION_KEY_TASK,@"NotificationTag", tasId,@"NotificationId",nil];
            
            [self addNotification:content withInfo:infos];
        }
    }
}

///添加一个本地通知
-(void)addNotification:(NSString *)content  withInfo:(NSDictionary *)info{
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    //设置5秒之后
    NSDate *pushDate = [NSDate dateWithTimeIntervalSinceNow:1];
    if (notification != nil) {
        // 设置推送时间（5秒后）
        notification.fireDate = pushDate;
        // 设置时区（此为默认时区）
        notification.timeZone = [NSTimeZone defaultTimeZone];
        // 设置重复间隔（默认0，不重复推送）
        notification.repeatInterval = 0;
        // 推送声音（系统默认）
        notification.soundName = UILocalNotificationDefaultSoundName;
        // 推送内容
        notification.alertBody = content;
        //显示在icon上的数字
//        notification.applicationIconBadgeNumber = 1;
        //设置userinfo 方便在之后需要撤销的时候使用
        
        notification.userInfo = info;
        //添加推送到UIApplication
        UIApplication *app = [UIApplication sharedApplication];
        [app scheduleLocalNotification:notification];
    }
}


#pragma mark  - 喜报弹框

-(void)showVictoryView{
    
    if (appDelegateAccessor.moudle.controllerCurView) {
        [self saveServerVictoryFlag:0];
        appDelegateAccessor.moudle.isVictoryShowAlready = YES;
        PopupView *view = [PopupView defaultPopupView];
        view.parentVC = appDelegateAccessor.moudle.controllerCurView;
        
        [appDelegateAccessor.moudle.controllerCurView lew_presentPopupView:view animation:[LewPopupViewAnimationSpring new] dismissed:^{
            NSLog(@"动画结束1");
            appDelegateAccessor.moudle.isVictoryShowAlready = NO;
        }];
    }
    
}


#pragma mark - 运营平台系统通知弹框
-(void)showSystemInformsView:(NSDictionary *)response{
    NSDictionary *sysInform = nil;
    if (response) {
        sysInform = [response objectForKey:@"sysAnnouncement"];
    }
    
    if ([CommonFuntion checkNullForValue:sysInform]) {
        
        ///存储  设置为未读
        [self cacheAndShowSysAnnouncement:sysInform];
        /*
        NSDictionary *cacheAnnouncement = [NSUserDefaults_Cache getSystemInformValue];
        ///存在缓存  判断id是否一致  如一致 则不显示  发送请求标记为已读
        if (cacheAnnouncement) {
            if ([[cacheAnnouncement safeObjectForKey:@"id"] isEqualToString:[sysInform safeObjectForKey:@"id"]]) {
                ///发送请求标记为已读
                [self sendCmdReadSysAnnouncement];
            }else{
                ///ID不一致 则直接覆盖 设置为未读
                [self cacheAndShowSysAnnouncement:sysInform];
            }
        }else{
            ///存储  设置为未读
            [self cacheAndShowSysAnnouncement:sysInform];
        }
         */
    }
}

///缓存系统公告  并弹框显示
-(void)cacheAndShowSysAnnouncement:(NSDictionary *)sysInform{
    
    /*
     sysAnnouncement =     {
     content = diertiaogonggao;
     expireDate = 1459323780000;
     id = 22;
     };
     */
    
    [NSUserDefaults_Cache setSystemInformValue:nil];
    
    ///判断是否处于后台
    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
        NSLog(@"程序在后台运行");
        ///做缓存
        NSDictionary *inform = [NSDictionary dictionaryWithObjectsAndKeys:[sysInform safeObjectForKey:@"content"],@"content",[sysInform safeObjectForKey:@"id"],@"id",[sysInform safeObjectForKey:@"expireDate"],@"expireDate", nil];
        [NSUserDefaults_Cache setSystemInformValue:inform];
    }else{
        if (appDelegateAccessor.moudle.alertViewOfSysAnnouncement) {
            [appDelegateAccessor.moudle.alertViewOfSysAnnouncement dismissWithClickedButtonIndex:0 animated:NO];appDelegateAccessor.moudle.alertViewOfSysAnnouncement = nil;
        }

        ////判断是否在有效期内
        
        NSString *expireDate = [CommonFuntion transDateWithTimeInterval:[[sysInform safeObjectForKey:@"expireDate"] longLongValue] withFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSLog(@"expireDate:%@",expireDate);
        
        if ([expireDate compare:[CommonFuntion dateToString:[NSDate date] Format:@"yyyy-MM-dd HH:mm:ss"]] == NSOrderedDescending) {
            appDelegateAccessor.moudle.alertViewOfSysAnnouncement = [[UIAlertView alloc]initWithTitle:@"系统公告" message:[NSString stringWithFormat:@"\n%@",[sysInform safeObjectForKey:@"content"]] delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
            appDelegateAccessor.moudle.alertViewOfSysAnnouncement.tag = 10001;
            appDelegateAccessor.moudle.alertViewOfSysAnnouncement.delegate = self;
            [appDelegateAccessor.moudle.alertViewOfSysAnnouncement show];
        }
    }
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10001) {
        NSLog(@"clickedButtonAtIndex--->");


    }
}




#pragma mark - 最新动态
-(void)notifyNewTrends:(NSDictionary *)response{
    NSDictionary *dynamicInfo = nil;
    if (response && [response objectForKey:@"dynamic"]) {
        dynamicInfo = [response objectForKey:@"dynamic"];
    }
    
    ///有最新动态
    if ([CommonFuntion checkNullForValue:dynamicInfo]) {
        appDelegateAccessor.moudle.icon_oa_workzone_newtrends = [dynamicInfo safeObjectForKey:@"icon"];
        [NSUserDefaults_Cache setNewTrendsInformValue:nil];
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[dynamicInfo safeObjectForKey:@"icon"],@"icon",[dynamicInfo safeObjectForKey:@"id"],@"id", nil];
        [NSUserDefaults_Cache setNewTrendsInformValue:info];
    }else{
        ///无最新动态  判断是否有未读最新动态的缓存
        NSDictionary *newT = [NSUserDefaults_Cache getNewThrendsInformValue];
        if (newT) {
            appDelegateAccessor.moudle.icon_oa_workzone_newtrends = [newT safeObjectForKey:@"icon"];
        }else{
            appDelegateAccessor.moudle.icon_oa_workzone_newtrends = @"";
        }
    }
    
    ///触发通知  刷新UI
    [[NSNotificationCenter defaultCenter] postNotificationName:SKT_OA_HOME_TREND_OBSERVER_NAME object:nil];
}


#pragma mark - 标记为已读公告
-(void)sendCmdReadSysAnnouncement{
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:@"" forKey:@"id"];

    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA,@""] params:params success:^(id responseObj) {
        //字典转模型
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_LOGIN_RESPONSE_0) {
            ///已读 清空缓存
            [NSUserDefaults_Cache setSystemInformValue:nil];
        }else{
            
            NSString *desc = @"";
            desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"标记已读失败";
            }
            NSLog(@"desc:%@",desc);
            [self readFailedSysAnnouncement];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        [self readFailedSysAnnouncement];
    }];
}


///设置为已读消息请求失败 本地标记为已读
-(void)readFailedSysAnnouncement{
    NSDictionary *cacheAnnouncement = [NSUserDefaults_Cache getSystemInformValue];
    if (cacheAnnouncement) {
        NSDictionary *inform = [NSDictionary dictionaryWithObjectsAndKeys:[cacheAnnouncement safeObjectForKey:@"content"],@"content",[cacheAnnouncement safeObjectForKey:@"id"],@"id",@"1",@"readflag", nil];
        [NSUserDefaults_Cache setSystemInformValue:inform];
    }
}

@end
