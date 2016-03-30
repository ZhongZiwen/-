//
//  AppDelegate.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

///本地推送消息key标识  IM消息
#define SKT_IM_MSG_LOCALNOTIFICATION_KEY_IM   @"skt_im_msg_localnotification_im"
///本地推送消息key标识  顶部view
#define SKT_IM_MSG_LOCALNOTIFICATION_KEY_TOPVIEW   @"skt_im_msg_localnotification_topview"

#import "AppDelegate.h"
#import "GuideViewController.h"
#import "RootTabBarController.h"

#import "Login.h"
#import "AFNHttp.h"
#import "CommonRequstFuntion.h"
#import "NSUserDefaults_Cache.h"
#import "LLC_NSUserDefaults_Cache.h"
#import "Dynamic_Data.h"
#import "CommonConstant.h"
#import "CommonModuleFuntion.h"
#import "SBJson.h"
#import "MySBJsonWriter.h"
#import "CommonFuntion.h"
#import "IM_FMDB_FILE.h"


#import "CommonCheckVersion.h"
#import "MobClick.h"
#import "LoginViewController.h"

#import <AudioToolbox/AudioToolbox.h>
#import "NSString+JsonHandler.h"
#import "NdUncaughtExceptionHandler.h"

#import "CommonUnReadNumberUtil.h"
#import "LocalCacheUtil.h"

@implementation AppDelegate

/**
 * 设置导航条样式
 */
- (void)customizeInterface
{
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    
    // 设置导航栏的背景颜色
    [navigationBar setBarTintColor:[UIColor colorWithHexString:@"0x1d1d1d"]];
    
    
    // 默认情况下，导航栏的translucent属性为YES,另外，系统还会对所有的导航栏做模糊处理，这样可以让iOS 7中导航栏的颜色更加饱和。
    // 关闭导航栏translucent属性
    //    [navigationBar setTranslucent:NO];
    
    // 导航栏使用背景图片
//        [navigationBar setBackgroundImage:[UIImage imageNamed:@"nar_bg_img.jpg.png"] forBarMetrics:UIBarMetricsDefault];
    
    // 制定返回按钮的颜色（tintColor熟悉会影响到所有按钮标题和图片）
    // 如果想要用自己的图片替换v型，可以通过backIndicatorImage和backIndicatorTransitionMaskImage方法来实现，图片的颜色是由tintColor属性控制的
    [navigationBar setTintColor:[UIColor whiteColor]];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    
    
    // 修改导航栏标题的字体
    [navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:kNavTitleFontSize],
                                            NSForegroundColorAttributeName: [UIColor whiteColor],}];
    
    // 修改状态栏的风格
    // 1:在project target的Info tab中，插入一个新的key，名字为View controller-based status bar appearance，并将其值设置为NO。
    // 2:设置StatusBarStyle
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)sendHeartMessage {
    NSTimeInterval second = [[NSDate date] timeIntervalSince1970] * 1000;
    NSInteger time = second;
    NSDictionary *heartDcit = @{@"id" : appDelegateAccessor.moudle.userId,
                                @"head" : @"heart",
                                @"time" : @(time)};
    MySBJsonWriter *heartJson = [[MySBJsonWriter alloc]init];
    NSString *heartmessage =[heartJson stringWithObject:heartDcit];
    
    if (_webSocket.readyState == SR_OPEN) {
        [_webSocket send:heartmessage];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //设置程序Background Fetch的时间周期
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    application.applicationIconBadgeNumber = 0;
    NSLog(@"Launched in background %d", UIApplicationStateBackground == application.applicationState);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    ///注册本地通知
    [self registerLocalNotificationForLaterIOS8];
    
    // 设置导航条样式
    [self customizeInterface];
    
    [self initDataByFirstLanuch];
    ////-----初始化数据-----////
    [self initGBData];
    
    _isNetwork = YES;
    [self launchApplication];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [CommonUnReadNumberUtil setApplicationIconBadgeNumber];
    ///友盟统计
//    [self umengTrack];
    /*
     UIApplication*
     app = [UIApplication sharedApplication];
     
     __block
     UIBackgroundTaskIdentifier bgTask;
     
     bgTask
     = [app beginBackgroundTaskWithExpirationHandler:^{
     
     dispatch_async(dispatch_get_main_queue(),
     ^{
     
     if
     
     (bgTask != UIBackgroundTaskInvalid)
     
     {
     
     bgTask
     = UIBackgroundTaskInvalid;
     
     }
     
     });
     
     }];
     
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
     0),
     ^{
     
     dispatch_async(dispatch_get_main_queue(),
     ^{
     
     if
     
     (bgTask != UIBackgroundTaskInvalid)
     
     {
     
     bgTask
     = UIBackgroundTaskInvalid;
     
     }
     
     });
     
     });
     */
    
    
//    [NSDictionary jr_swizzleMethod:@selector(description) withMethod:@selector(dic_description) error:nil];

    ///初始化版本更新标识
    [self initCheckVersionInfos];
    
    ///应用崩溃时信息采集
    [NdUncaughtExceptionHandler setDefaultHandler];
    
    return YES;
}



-(void)initDataByFirstLanuch{
    ///判断是不是第一次启动
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    if(![userDefaultes boolForKey:@"firstlanuch"]){
        
        NSLog(@"initDataByFirstLanuch");
        
        [NSUserDefaults_Cache setIMMessageStatus:TRUE];
        [NSUserDefaults_Cache setIMMessageVoiceStatus:TRUE];
        [userDefaultes setBool:TRUE forKey:@"firstlanuch"];
        [userDefaultes synchronize];
    }
}

- (void)setupRootViewController
{
    RootTabBarController *rootTabbarController = [[RootTabBarController alloc] init];
    self.window.rootViewController = rootTabbarController;
    [self deleteWebSocket];
    [self _reconnect];
    [self startNotificationNetwork];
}

- (void)setupGuideViewController
{
    GuideViewController *guideController = [[GuideViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:guideController];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    

    if (flagOfBecomeActive == 1 ) {
        [self checkSKTVersion];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self removeTimer];
    [self removeHeartTimer];
    [self deleteWebSocket];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    /*
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURL *url = [[NSURL alloc] initWithString:SKT_SOCKET_SERVER_IP];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completionHandler(UIBackgroundFetchResultFailed);
            return;
        }
        BOOL hasNewData = YES;
        if (hasNewData) {
            completionHandler(UIBackgroundFetchResultNewData);
            application.applicationIconBadgeNumber += 1;
        } else {
            completionHandler(UIBackgroundFetchResultNoData);
        }
    }];
    //开始任务
    [task resume];
     */
    NSLog(@"多久走了一次");
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
}
#pragma mark - 初始化数据
-(void)initGBData{
    self.moudle = [[GBMoudle alloc] init];
    self.cellMoudle = [[GBCellMoudle alloc] init];
    
    self.moudle.arrayCampaignsStatusNames = [[NSMutableArray alloc] init];
    self.moudle.arrayHighSeaStatusStatusNames = [[NSMutableArray alloc] init];
    self.moudle.arraySaleLeadtatusStatusNames = [[NSMutableArray alloc] init];
    self.moudle.isIMView = FALSE;
    appDelegateAccessor.moudle.isLoadIMView = FALSE;
}

#pragma mark - 启动APP

-(void)launchApplication{
    Boolean loginStatus = [NSUserDefaults_Cache getUserLoginStatus];
    ///已登录
    if (loginStatus) {
        NSLog(@"已登录状态");
        [self loginAgain];
    }else{
        ///跳转到登录页面
        [self setupGuideViewController];
    }
    
    
}


#pragma   mark - 使用本地缓存用户信息重新登录请求
// 使用本地缓存用户信息 重新发起登录请求
-(void)loginAgain
{
    NSDictionary *account = [NSUserDefaults_Cache getUserAccountInfo];
    NSString *accountName = @"";
    NSString *password = @"";
    
    if (account) {
        accountName = [account safeObjectForKey:@"accountName"];
        password = [account safeObjectForKey:@"password"];
    }
    
    ///若帐号密码为空则跳转到登录页面 同时设置登录状态为false
    if ([accountName isEqualToString:@""] || [password isEqualToString:@""]) {
        [NSUserDefaults_Cache setUserLoginStatus:false];
        [self setupGuideViewController];
    }else{
        // 组装参数
        NSMutableDictionary *params=[NSMutableDictionary dictionary];
        [params addEntriesFromDictionary:COMMON_PARAMS];
        [params setObject:accountName forKey:@"accountName"];
        [params setObject:password forKey:@"password"];
        
        NSDictionary *loginInfo = [AFNHttp doSynType:@"POST" WithUrl:[NSString stringWithFormat:@"%@%@",kNetPath_Web_Server_Base,kNetPath_Login] params:params];
        
        
        NSLog(@"loginInfo:%@",loginInfo);
        
        if (loginInfo) {
            if ([[loginInfo objectForKey:@"status"] integerValue] == 0) {
                NSArray *tenants;
                
                if ([loginInfo objectForKey:@"tenants"]) {
                    tenants = [loginInfo objectForKey:@"tenants"];
                }
                
                ///使用缓存的公司做登录操作
                if (tenants && [tenants count] > 0) {
                    ///缓存公司列表
                    [NSUserDefaults_Cache setCurCompanyLogined:tenants];
                    
                    NSDictionary *userInfo = [NSUserDefaults_Cache getUserInfo];
                    NSString *userId = [userInfo safeObjectForKey:@"id"] ;
                    
                    [self loginBySelectedCompany:userId];
                }else{
                    ///缓存登录信息
                    [NSUserDefaults_Cache setUserInfo:loginInfo];
                    
                    [NSUserDefaults_Cache setUserLoginStatus:true];
                    [NSUserDefaults_Cache setUserLogOutStatus:0];
                    appDelegateAccessor.moudle.userId =[loginInfo safeObjectForKey:@"id"] ;
                    appDelegateAccessor.moudle.userName = [loginInfo safeObjectForKey:@"name"];
                    appDelegateAccessor.moudle.userCompanyId = [loginInfo safeObjectForKey:@"companyId"];
                    appDelegateAccessor.moudle.IM_tokenString = [loginInfo safeObjectForKey:@"token"];
                    appDelegateAccessor.moudle.userFunctionCodes = [loginInfo safeObjectForKey:@"functionCodes"];
                    appDelegateAccessor.moudle.isOpen_cluePool = [[loginInfo safeObjectForKey:@"cluePoolOpen"] integerValue];
                    appDelegateAccessor.moudle.isOpen_customerPool = [[loginInfo safeObjectForKey:@"customerPoolOpen"] integerValue];
                    
                    ///设置动态相关缓存路径
                    [Dynamic_Data setDynamicCacheFilePathByUserLoginInfo];
                    ///初始化办公/CRM模块设置
                    [CommonModuleFuntion initOAandCRMModuleOption];
                    
                    ///设置动态相关缓存路径
                    [Dynamic_Data setDynamicCacheFilePathByUserLoginInfo];
                    ///初始化办公/CRM模块设置
                    [CommonModuleFuntion initOAandCRMModuleOption];
                    
                    
                    ///首页
                    [self setupRootViewController];
                    [self getAllReportAndApprove];
                }
                
                ///存储联络中心账号
                [LLC_NSUserDefaults_Cache  saveLLCAccountInfo:loginInfo];
            }else{
                
                NSString *desc =[loginInfo safeObjectForKey:@"desc"];

                ///跳转到登录页面
                [LocalCacheUtil clearCacheBylogoutComplete:1];
                GuideViewController *guideController = [[GuideViewController alloc] init];
                guideController.flagToLoginView = @"yes";
                guideController.errorDesc = desc;
                appDelegateAccessor.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:guideController];
            }
        }else{
            NSDictionary *userInfo = [NSUserDefaults_Cache getUserInfo];
            NSString *userId = [userInfo safeObjectForKey:@"id"] ;
            appDelegateAccessor.moudle.userId = userId;
            appDelegateAccessor.moudle.userName = [userInfo safeObjectForKey:@"id"];
            appDelegateAccessor.moudle.userCompanyId = [userInfo safeObjectForKey:@"companyId"];
            appDelegateAccessor.moudle.IM_tokenString = [userInfo safeObjectForKey:@"token"];
            appDelegateAccessor.moudle.userFunctionCodes = [userInfo safeObjectForKey:@"functionCodes"];
            appDelegateAccessor.moudle.isOpen_cluePool = [[userInfo safeObjectForKey:@"cluePoolOpen"] integerValue];
            appDelegateAccessor.moudle.isOpen_customerPool = [[userInfo safeObjectForKey:@"customerPoolOpen"] integerValue];
            
            ///初始化办公/CRM模块设置
            [CommonModuleFuntion initOAandCRMModuleOption];
            [NSUserDefaults_Cache setUserLoginStatus:true];
            [NSUserDefaults_Cache setUserLogOutStatus:0];
            ///设置动态相关缓存路径
            [Dynamic_Data setDynamicCacheFilePathByUserLoginInfo];
            
            [self setupRootViewController];
        }
    }
}



#pragma mark - 进入事件
-(void)loginBySelectedCompany:(NSString *)companyIdStr{
    
    long long companyId = [companyIdStr longLongValue];
//    NSLog(@"companyId:%lli",companyId);
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithLongLong:companyId] forKey:@"tenantId"];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    NSDictionary *loginInfo = [AFNHttp doSynType:@"POST" WithUrl:[NSString stringWithFormat:@"%@%@",kNetPath_Web_Server_Base,kNetPath_ChooseCompany] params:params];
//    NSLog(@"loginInfo:%@",loginInfo);
//    NSLog(@"desc:%@",[loginInfo objectForKey:@"desc"]);
    
    if (loginInfo && [[loginInfo objectForKey:@"status"] integerValue] == 0) {
        
        appDelegateAccessor.moudle.userId =[loginInfo  safeObjectForKey:@"id"] ;
        appDelegateAccessor.moudle.userName = [loginInfo safeObjectForKey:@"name"];
        appDelegateAccessor.moudle.userCompanyId = [loginInfo safeObjectForKey:@"companyId"];
        appDelegateAccessor.moudle.IM_tokenString = [loginInfo safeObjectForKey:@"token"];
        appDelegateAccessor.moudle.userFunctionCodes = [loginInfo safeObjectForKey:@"functionCodes"];
        appDelegateAccessor.moudle.isOpen_cluePool = [[loginInfo safeObjectForKey:@"cluePoolOpen"] integerValue];
        appDelegateAccessor.moudle.isOpen_customerPool = [[loginInfo safeObjectForKey:@"customerPoolOpen"] integerValue];
        
        ///缓存登录信息
        [NSUserDefaults_Cache setUserInfo:loginInfo];
        
        [NSUserDefaults_Cache setUserLoginStatus:true];
        [NSUserDefaults_Cache setUserLogOutStatus:0];
        
        ///设置动态相关缓存路径
        [Dynamic_Data setDynamicCacheFilePathByUserLoginInfo];
        
        ///初始化办公/CRM模块设置
        [CommonModuleFuntion initOAandCRMModuleOption];
        
        
        ///预加载
        [self setupRootViewController];
        [self getAllReportAndApprove];
    }else{
        ///登录失败
        NSDictionary *userInfo = [NSUserDefaults_Cache getUserInfo];
        NSString *userId = [userInfo safeObjectForKey:@"id"] ;
        appDelegateAccessor.moudle.userId = userId;
        appDelegateAccessor.moudle.userName = [userInfo safeObjectForKey:@"name"];
        appDelegateAccessor.moudle.userCompanyId = [userInfo safeObjectForKey:@"companyId"];
        appDelegateAccessor.moudle.IM_tokenString = [loginInfo safeObjectForKey:@"token"];
        appDelegateAccessor.moudle.userFunctionCodes = [loginInfo safeObjectForKey:@"functionCodes"];
        appDelegateAccessor.moudle.isOpen_cluePool = [[loginInfo safeObjectForKey:@"cluePoolOpen"] integerValue];
        appDelegateAccessor.moudle.isOpen_customerPool = [[loginInfo safeObjectForKey:@"customerPoolOpen"] integerValue];
        ///初始化办公/CRM模块设置
        [CommonModuleFuntion initOAandCRMModuleOption];
        [NSUserDefaults_Cache setUserLoginStatus:true];
        [NSUserDefaults_Cache setUserLogOutStatus:0];
        ///设置动态相关缓存路径
        [Dynamic_Data setDynamicCacheFilePathByUserLoginInfo];
        
        [self setupRootViewController];
    }
}

#pragma mark - web Socket
- (void)_reconnect;
{
    NSLog(@"----最新token---%@", appDelegateAccessor.moudle.IM_tokenString);
    //参数拼接说明 webSocketUrl, token, client=ios, userId=11111
    //ws://192.168.1.120/skt-im/websocket?30db583b-dbb1-4fb7-863d-3848c5d7ba69&client=ios&userId=11111
    NSString *webSocketURL = [NSString stringWithFormat:@"%@?%@&%@userId=%@", SKT_SOCKET_SERVER_IP, appDelegateAccessor.moudle.IM_tokenString, @"client=ios", appDelegateAccessor.moudle.userId];
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:webSocketURL]]];
    _webSocket.delegate = self;
    
    [_webSocket open];
}
- (void)reconnect:(id)sender;
{
    [self _reconnect];
}

- (void)sendPing:(id)sender;
{
    [_webSocket sendPing:nil];
}
#pragma mark - SRWebSocketDelegate
//先走这里
- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    NSTimeInterval second = [[NSDate date] timeIntervalSince1970] * 1000;
    NSInteger time = second;
    NSDictionary *dict = @{@"id" : appDelegateAccessor.moudle.userId,
                           @"head" : @"reg",
                           @"time" : @(time),
                           @"client": @"app"};
    MySBJsonWriter *jsonParser = [[MySBJsonWriter alloc]init];
    NSString *message =[jsonParser stringWithObject:dict];
    NSLog(@"链接成功之后的状态%ld", _webSocket.readyState);
    if (_webSocket.readyState == SR_OPEN) {
        [_webSocket send:message];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    //
    [self deleteWebSocket];
    [self removeHeartTimer];
    //
    if (!_startTime) {
        _startTime = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(_reconnect) userInfo:nil repeats:YES];
        //RequestWebSocket
    }
//    [self RequestWebSocket];
    
}
//再走这里
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSLog(@"Appdelegate Received \"%@\"", message);
//    MySBJsonWriter *ackJson = [[MySBJsonWriter alloc] init];
    NSDictionary *msgDict = [message JSONValue];
    //链接失败
    if ([[msgDict allKeys] containsObject:@"status"]) {
        if ([msgDict objectForKey:@"status"] && [msgDict objectForKey:@"desc"]) {
            if ([[msgDict safeObjectForKey:@"status"] integerValue] == 1 && [[msgDict safeObjectForKey:@"desc"] isEqualToString:@"Invalidtoken"]) {
                [self deleteWebSocket];
                if (!_startTime) {
                    _startTime = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(RequestWebSocket) userInfo:nil repeats:YES];
                }
                return;
            } else if ([[msgDict safeObjectForKey:@"status"] integerValue] == 0 && [[msgDict safeObjectForKey:@"desc"] isEqualToString:@"successOpen"]) {
                // 会话界面  重发消息
                [[NSNotificationCenter defaultCenter] postNotificationName:@"sendFailMessages" object:nil];
                NSLog(@"-----IM链接成功");
                if (!_heartTimer) {
                    _heartTimer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(sendHeartMessage) userInfo:nil repeats:YES];
                }
                [self removeTimer];
            }
        }
    } else if ([[msgDict allKeys] containsObject:@"head"]) {
        //判断是否被踢出
        if ([msgDict objectForKey:@"head"]) {
            if ([[msgDict objectForKey:@"head"] isEqualToString:@"repeat"]) {
                [self showAlViewAction];
                return;
            } else if ([[msgDict objectForKey:@"head"] isEqualToString:@"message"]){
                // 会话界面
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceveMessage" object:msgDict];
                // 会话列表界面
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshGroupList" object:msgDict];
                
                ///处理消息
                [self optionWithMessage:msgDict];

                
//                NSDictionary *ackDcit = @{@"id" : [msgDict safeObjectForKey:@"id"],
//                                          @"head" : @"ack",
//                                          @"to" : [msgDict safeObjectForKey:@"to"],
//                                          @"number" : [msgDict safeObjectForKey:@"number"],
//                                          @"time" : [msgDict safeObjectForKey:@"time"]};
//                
//                NSString *ackmessage =[ackJson stringWithObject:ackDcit];
//                if (_webSocket.readyState == SR_OPEN) {
//                    [_webSocket send:ackmessage];
//                } else {
//                    [self removeHeartTimer];
//                    [self deleteWebSocket];
//                    [self _reconnect];
//                }
                
            }
        }
    }
    

    
    /*
     {
     content = 11111;
     head = message;
     id = 86;
     number = 86;
     resource = "{\"size\":8440,\"id\":\"\",\"fileName\":\"20160115/a5e50468-ac11-40aa-83bc-107257d198ca.mp3\",\"name\":\"recordvoice.aac\",\"type\":3,\"second\":3}";
     time = 1452826517000;
     to = 21;
     type = 1;
     uuid = 14528265169938317;
     }
     */
    
}

-(void)optionWithMessage:(NSDictionary *)msgDict{
    
    if (msgDict) {
        if (!appDelegateAccessor.moudle.isIMView) {
            
            ///不是自己发的消息
            if (![appDelegateAccessor.moudle.userId isEqualToString:[msgDict safeObjectForKey:@"id"]]) {
                NSLog(@"optionWithMessage  msgDict:%@",msgDict);
                
                
                if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
                    
                    ///不是聊天页面  播放声音
                    if ([[msgDict safeObjectForKey:@"type"] integerValue] == 1) {
                        NSLog(@"程序在前台运行 播放声音");
                        
                        ///未点击消息页面 则统计未读消息 ++
                        if(!appDelegateAccessor.moudle.isLoadIMView){
                            [CommonUnReadNumberUtil unReadNumberIncrease:0];
                        }
                        
                        ///消息声音开关
                        if([NSUserDefaults_Cache getIMMessageStatuVoice]){
                           AudioServicesPlaySystemSound(1015);
                        }
                        
                        ///消息开关
                        if([NSUserDefaults_Cache getIMMessageStatu]){
                            NSDictionary *infos = [NSDictionary dictionaryWithObjectsAndKeys:@"IM_MESSAGE",@"NotificationType",SKT_IM_MSG_LOCALNOTIFICATION_KEY_TOPVIEW,@"NotificationTag", [self getLocalNotificationMessageForIM:msgDict],@"content",nil];
                            
                            ///发送通知  显示顶部view
                            [[NSNotificationCenter defaultCenter] postNotificationName:SKT_LOCAL_NOTIFICATION_OBSERVER_NAME3 object:self userInfo:infos];
                        }
                        
                    }
                    
                    
                }else if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
                    NSLog(@"程序在后台运行  添加通知提醒");
                    
                    if ([[msgDict safeObjectForKey:@"type"] integerValue] == 1) {
                        
                        ///未点击消息页面 则统计未读消息 ++
                        if(!appDelegateAccessor.moudle.isLoadIMView){
                            [CommonUnReadNumberUtil unReadNumberIncrease:0];
                        }
                        ///消息开关
                        if([NSUserDefaults_Cache getIMMessageStatu]){
                            NSDictionary *infos = [NSDictionary dictionaryWithObjectsAndKeys:@"IM_MESSAGE",@"NotificationType",SKT_IM_MSG_LOCALNOTIFICATION_KEY_IM,@"NotificationTag", @"",@"NotificationId",nil];
                            
                            [self addNotification:[self getLocalNotificationMessageForIM:msgDict] withInfo:infos];
                        }
                        
                    }
                    
                    //消息类型 消息类 system: 0系统消息  text: 1文本类型  create: 2创建组 join: 3加入组 exit: 4退出组  update:5修改组
                    //文件资源类类型（resource 层）: 1// 图片类型   file: 2,// 文件类型  voice: 3// 语音类型
                }
            }
        }
    }
}


#pragma mark IM 消息
-(NSString *)getLocalNotificationMessageForIM:(NSDictionary *)message{
    
    NSString *messageType = @"";
    
    //        resource = "{\"size\":8440,\"id\":\"\",\"fileName\":\"20160115/a5e50468-ac11-40aa-83bc-107257d198ca.mp3\",\"name\":\"recordvoice.aac\",\"type\":3,\"second\":3}";
    
    if (![CommonFuntion checkNullForValue:[message objectForKey:@"resource"]] ) {
        
        messageType = [NSString stringWithFormat:@"%@",[message safeObjectForKey:@"content"]];
//        if (messageType && messageType.length > 15) {
//            messageType = [NSString stringWithFormat:@"%@...",[messageType substringToIndex:6]];
//        }
        
//        if (!messageType || messageType.length == 0) {
//            messageType = @"发来一条消息";
//        }
        
    }else{
        NSDictionary *source  = [[message objectForKey:@"resource"] toJsonValue];
        NSLog(@"source:%@",source);
        
        if (source) {
            ///图片
            if ([[source safeObjectForKey:@"type"] integerValue] == 1) {
                messageType = @"图片";
            }else if ([[source safeObjectForKey:@"type"] integerValue] == 2) {
                ///文件
                messageType = @"文件";
            }else if ([[source safeObjectForKey:@"type"] integerValue] == 3) {
                ///语音
                messageType = @"语音";
            }
        }
    }
    
    NSString *name = [[FMDBManagement sharedFMDBManager] selectAddressBookNameById:[NSNumber numberWithInteger:[[message objectForKey:@"id"] integerValue]]];
    NSLog(@"name:%@",name);
    
    NSString *msgContent = [NSString stringWithFormat:@"%@:%@",name,messageType];
    
    return msgContent;
}


///添加一个本地通知
-(void)addNotification:(NSString *)content  withInfo:(NSDictionary *)info{
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    //设置5秒之后
    NSDate *pushDate = [NSDate dateWithTimeIntervalSinceNow:0];
    if (notification != nil) {
        // 设置推送时间（0秒后）
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



- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed%@", reason);
    [self deleteWebSocket];
    [self removeTimer];
    [self removeHeartTimer];
    [self _reconnect];
}
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;
{
    NSLog(@"Websocket received pong");
}
#pragma mark - 踢出提示
- (void)showAlViewAction {
    [NSUserDefaults_Cache setUserLoginStatus:false];
    [self removeTimer];
    [self removeHeartTimer];
    [self deleteWebSocket];
    UIAlertView *alView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的账号已在另一个地方登录，如果非您本人操作，请重新登录并及时更改密码！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"重新登录", nil];
    alView.tag = 101;
    [alView show];
}
- (void)getAllReportAndApprove {

    appDelegateAccessor.moudle.isShowAll = YES;

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, ALL_REPORT_AND_APPROVE] params:params success:^(id responseObj) {
        NSLog(@"获取权限成功-----%@", responseObj);
        if ([[responseObj objectForKey:@"status"] integerValue] == 0) {
            appDelegateAccessor.moudle.isShowAll = [[responseObj objectForKey:@"isAuthority"] boolValue];
        }
    } failure:^(NSError *error) {
        NSLog(@"获取权限失败-----%@", error);
    }];
}

#pragma mark - 获取版本信息

///初始化版本更新标识
-(void)initCheckVersionInfos{
    // 启动 在becomeActive里检测
    flagOfBecomeActive = 1;
    ///默认在设置页面不显示版本信息
    [CommonCheckVersion setShowSKTVersionView:@"notshow"];
    ///默认没有
    isNewVersion = NO;
}

///判断日期标签 是否需要显示版本升级提示
-(BOOL)isShowNewVersionAlert{
    BOOL isNeedCheck = FALSE;
    NSString *dateFlag = [CommonCheckVersion getSKTCheckVersionDateFlag];
    if (dateFlag == nil || [dateFlag isEqualToString:@""]) {
        isNeedCheck = TRUE;
    }else{
        NSString *cur_date = [CommonFuntion dateToString:[NSDate date] Format:@"yyyy-MM-dd"];
        if ([cur_date compare:dateFlag] == 1) {
            isNeedCheck = TRUE;
        }
    }
    return isNeedCheck;
}

/*
 desc = "<null>";
 id = 2;
 name = "\U5546\U5ba2\U901a";
 needUpdate = 1;
 remark = "";
 showUpdate = 1;
 size = 5MB;
 status = 0;
 updateTime = 1449545031000;
 url = "http://192.168.5.54:9080/download/app-2.0.1.apk";
 versionCode = "1.2.9";
 versionName = "1.2.9";
 */

-(void)checkSKTVersion{
    NSLog(@"checkSKTVersion---->");
    ///不显示版本信息
    [CommonCheckVersion defaultSKTVersion];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",kNetPath_User_Server_Base,SKT_CHECK_APP_VERSION] params:params success:^(id responseObj) {
        //字典转模型
//        NSLog(@"检测版本信息 responseObj:%@",responseObj);
        if ([[responseObj objectForKey:@"status"] intValue] == 0) {
            ///存储当前信息
            [CommonCheckVersion setSKTAppVersionInfo:responseObj];
            
            Boolean isShowUpdate = TRUE;
            if ([responseObj objectForKey:@"showUpdate"] != nil) {
                isShowUpdate = [[responseObj objectForKey:@"showUpdate"] boolValue];
            }

            if (!isShowUpdate) {
                ///显示版本信息
                [CommonCheckVersion setShowSKTVersionView:@"show"];
            }else{
                ///不显示版本信息
                [CommonCheckVersion setShowSKTVersionView:@"notshow"];
            }
            
            ///如果有新版本  且显示
            NSString *versionCode = [responseObj safeObjectForKey:@"versionCode"];
            if (versionCode && [SKT_VERSION_CODE compare:versionCode] == -1 && !isShowUpdate) {
                isNewVersion = YES;
                
                Boolean isNeedUpdate = TRUE;
                NSString *updateRemark = @"";
                if ([responseObj objectForKey:@"needUpdate"] != nil) {
                    isNeedUpdate = [[responseObj objectForKey:@"needUpdate"] boolValue];
                }
                if ([responseObj objectForKey:@"remark"] != nil) {
                    updateRemark = [responseObj objectForKey:@"remark"];
                }
                
                
                if(!isNeedUpdate){
//                     NSLog(@"---强制更新--->");
                    if (updateRemark == nil || [updateRemark isEqualToString:@""]) {
                        updateRemark = @"有可用的新版本，更新之后才能正常使用";
                    }
                    flagOfBecomeActive = 0;
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"版本提示" message:updateRemark delegate:self cancelButtonTitle:@"立即升级" otherButtonTitles:nil, nil];
                    [alert setTag:999];
                    [alert show];
                    
                }else
                {
                    ///显示版本更新信息
                    if ([self isShowNewVersionAlert]) {
                        ///存储当前日期
                        NSString *cur_date = [CommonFuntion dateToString:[NSDate date] Format:@"yyyy-MM-dd"];
                        [CommonCheckVersion setSKTCheckVersionDateFlag:cur_date];
                        
                        flagOfBecomeActive = 0;
                        if (updateRemark == nil || [updateRemark isEqualToString:@""]) {
                            updateRemark = @"有可用的新版本，是否更新？";
                        }

                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"版本提示" message:updateRemark delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"立即升级", nil];
                        [alert setTag:998];
                        
                        [alert show];
                    }
                }
            }
            
        }else{
            ///不显示版本信息
            [CommonCheckVersion defaultSKTVersion];
        }
        
    } failure:^(NSError *error) {
//        NSLog(@"checkSKTVersion  error:%@",error);
        ///不显示版本信息
        [CommonCheckVersion defaultSKTVersion];
    }];
}


#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            NSLog(@"重新登录");
//            [self loginAgain];
            [self _reconnect];
        } else {
            NSLog(@"确定退出");
            [self sendCmdLogout];
        }
    }
    
    ///登陆异常
    if(alertView.tag == 10101)
    {
        [LocalCacheUtil clearCacheBylogoutComplete:1];
        LoginViewController *loginController = [[LoginViewController alloc] init];
        loginController.title = @"登录";
        appDelegateAccessor.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:loginController];
        return;
    }
    
    // 未点击按钮
    if(alertView.tag == 998)
    {
        NSLog(@"点击--998-->");
        flagOfBecomeActive = 1;
        if(buttonIndex == 0)
        {
        }
        else if(buttonIndex == 1)
        {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:SKT_URL_APPATORE]];

        }
    }
    
    
    if(alertView.tag == 999)
    {
        NSLog(@"点击--999-->");
        flagOfBecomeActive = 1;
        if(buttonIndex == 0)
        {
            //强制更新版本
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:SKT_URL_APPATORE]];
        }
    }
}

#pragma mark - 本地通知相关

///对IOS8及之后做本地通知注册
-(void)registerLocalNotificationForLaterIOS8{
    // ios8后，需要添加这个注册，才能得到授权
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}


// 本地通知回调函数，当应用程序在前台时调用
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"didReceiveLocalNotification noti:%@",notification);
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    // 运行
    if (application.applicationState == UIApplicationStateInactive)
    {
        NSLog(@"notification:%@",notification);
        NSLog(@"notification  userInfo:%@",notification.userInfo);
        
//        NSDictionary *infos = [[notification object] userInfo];
//        if ([[infos objectForKey:@"NotificationType"] isEqualToString:@"IM_NOTIFICATION"]) {
//        }
        
        NSDictionary *userInfo = notification.userInfo;
        NSLog(@"notification.userinfo:%@",userInfo);
        if ([[userInfo safeObjectForKey:@"NotificationType"] isEqualToString:@"IM_MESSAGE"]) {
            NSLog(@"IM消息--->");
            ///消息开关
            if([NSUserDefaults_Cache getIMMessageStatu]){
                [[NSNotificationCenter defaultCenter] postNotificationName:SKT_LOCAL_NOTIFICATION_OBSERVER_NAME2 object:notification];
            }
            
        }else{
            NSLog(@"本地通知--->");
            //         发送通知 做页面跳转
            [[NSNotificationCenter defaultCenter] postNotificationName:SKT_LOCAL_NOTIFICATION_OBSERVER_NAME1 object:notification];
        }
    }else if(application.applicationState == UIApplicationStateBackground){
            NSLog(@"程序在后台运行");
        
    }
}


#pragma mark UMeng
- (void)umengTrack {
    [MobClick startWithAppkey:SKT_UMENG_KEY reportPolicy:(ReportPolicy) REALTIME channelId:nil];
    //   reportPolicy为枚举类型,可以为 REALTIME, BATCH,SENDDAILY,SENDWIFIONLY几种
    //   channelId 为NSString * 类型，channelId 为nil或@""时,默认会被被当作@"App Store"渠道
}
#pragma mark - 退出
-(void)sendCmdLogout{
    ///标记登录状态
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.window];
    [self.window addSubview:hud];
    [hud show:YES];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",kNetPath_Web_Server_Base,kNetPath_Logout] params:nil success:^(id responseObj) {
        [hud hide:YES];
        //字典转模型
        NSLog(@"退出登录 responseObj:%@",responseObj);
        [LocalCacheUtil clearCacheBylogoutComplete:2];
        
        GuideViewController *guideController = [[GuideViewController alloc] init];
        guideController.flagToLoginView = @"yes";
        appDelegateAccessor.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:guideController];
        
    } failure:^(NSError *error) {
        NSLog(@"退出登录error:%@",error);
        [hud hide:YES];
        [LocalCacheUtil clearCacheBylogoutComplete:2];
        GuideViewController *guideController = [[GuideViewController alloc] init];
        guideController.flagToLoginView = @"yes";
        appDelegateAccessor.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:guideController];
        
    }];
}


//关闭scoket
- (void)deleteWebSocket {
    if (_webSocket) {
        [_webSocket close];
        _webSocket.delegate = nil;
        _webSocket = nil;
    }
}
#pragma mark - 检测网络状态
//处理连接改变后的情况 //对连接改变做出响应的处理动作。
- (void)updateInterfaceWithReachability: (Reachability*) curReach
{
    NetworkStatus status = [curReach currentReachabilityStatus];
    if(status == NotReachable) {
        _isNetwork = NO;
         NSLog(@"connect with the internet fail");
    }else{
        if (!_isNetwork) {
            //发出通知，获取数据
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReGetNewGroup" object:nil];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReGetNewMessages" object:nil];
            _isNetwork = YES;
        } else {
            
        }
        NSLog(@"connect with the internet successfully");
    }
}


// 连接改变
- (void)reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}


-(void)startNotificationNetwork{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    _reachability=[Reachability reachabilityWithHostName:SKT_SOCKET_SERVER_IP];
    [_reachability startNotifier];
}
- (void)RequestWebSocket {
    CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
    [comRequest loginInBackground];
}
#pragma mark - 移除定时器
//重新连接
- (void)removeTimer {
    if (_startTime){
        [_startTime invalidate];
        _startTime = nil;
    }
}
//心跳
- (void)removeHeartTimer {
    if (_heartTimer) {
        [_heartTimer invalidate];
        _heartTimer = nil;
    }
}
@end
