//
//  CommonLoginEvent.m
//  shangketong
//  
//  Created by sungoin-zjp on 15-8-26.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CommonLoginEvent.h"
#import "NSUserDefaults_Cache.h"
#import "LLC_NSUserDefaults_Cache.h"
#import "CommonStaticVar.h"
#import "AFNHttp.h"
//#import "LoginViewController.h"
#import "LocalCacheUtil.h"
#import "GuideViewController.h"

@implementation CommonLoginEvent

#pragma mark - 登录事件
-(void)loginInBackground{
    [appDelegateAccessor removeHeartTimer];
    [appDelegateAccessor deleteWebSocket];
    NSDictionary *account = [NSUserDefaults_Cache getUserAccountInfo];
    NSString *accountName = [account safeObjectForKey:@"accountName"];
    NSString *password = [account safeObjectForKey:@"password"];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:accountName forKey:@"accountName"];
    [params setObject:password forKey:@"password"];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",kNetPath_Web_Server_Base,kNetPath_Login] params:params success:^(id responseObj) {
        //字典转模型
//        NSLog(@"session失效 登录事件 responseObj:%@",responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_LOGIN_RESPONSE_0) {
            NSArray *tenants;
            if ([responseObj objectForKey:@"tenants"] ) {
                tenants = [responseObj objectForKey:@"tenants"] ;
            }
            
            ///使用缓存的公司做登录操作
            if (tenants && [tenants count] > 0) {
                ///缓存公司列表
                [NSUserDefaults_Cache setCurCompanyLogined:tenants];
                
                NSDictionary *userInfo = [NSUserDefaults_Cache getUserInfo];
                NSString *userId = [userInfo safeObjectForKey:@"id"] ;
                
                [self loginBySelectedCompany:userId];
            }else{
                ///登录成功
                [NSUserDefaults_Cache setUserInfo:responseObj];
                [NSUserDefaults_Cache setUserLoginStatus:true];
                [NSUserDefaults_Cache setUserLogOutStatus:0];
                
                appDelegateAccessor.moudle.IM_tokenString = [responseObj safeObjectForKey:@"token"];
                appDelegateAccessor.moudle.userFunctionCodes = [responseObj safeObjectForKey:@"functionCodes"];
                appDelegateAccessor.moudle.isOpen_cluePool = [[responseObj safeObjectForKey:@"cluePoolOpen"] integerValue];
                appDelegateAccessor.moudle.isOpen_customerPool = [[responseObj safeObjectForKey:@"customerPoolOpen"] integerValue];
                [appDelegateAccessor _reconnect];
                __weak typeof(self) weak_self = self;
                [weak_self requsetAgain];
            }
            ///存储联络中心账号
            [LLC_NSUserDefaults_Cache  saveLLCAccountInfo:responseObj];
        }else {
            
            NSString *desc =[responseObj safeObjectForKey:@"desc"];

//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:desc delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            alert.tag = 10101;
//            [alert show];
            
            [LocalCacheUtil clearCacheBylogoutComplete:2];

            GuideViewController *guideController = [[GuideViewController alloc] init];
            guideController.flagToLoginView = @"yes";
            guideController.errorDesc = desc;
            appDelegateAccessor.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:guideController];
        }
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        
    }];
    
}


#pragma mark - 进入事件
-(void)loginBySelectedCompany:(NSString *)companyIdStr{
    
    long long companyId = [companyIdStr longLongValue];
    NSLog(@"companyId:%lli",companyId);
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithLongLong:companyId] forKey:@"tenantId"];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",kNetPath_Web_Server_Base,kNetPath_ChooseCompany] params:params success:^(id responseObj) {
        //字典转模型
//        NSLog(@"session失效 切换公司事件 responseObj:%@",responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            ///缓存登录信息
            [NSUserDefaults_Cache setUserInfo:responseObj];
            [NSUserDefaults_Cache setUserLoginStatus:true];
            [NSUserDefaults_Cache setUserLogOutStatus:0];
            appDelegateAccessor.moudle.IM_tokenString = [responseObj safeObjectForKey:@"token"];
            appDelegateAccessor.moudle.userFunctionCodes = [responseObj safeObjectForKey:@"functionCodes"];
            appDelegateAccessor.moudle.isOpen_cluePool = [[responseObj safeObjectForKey:@"cluePoolOpen"] integerValue];
            appDelegateAccessor.moudle.isOpen_customerPool = [[responseObj safeObjectForKey:@"customerPoolOpen"] integerValue];
            [appDelegateAccessor _reconnect];
            __weak typeof(self) weak_self = self;
            [weak_self requsetAgain];

        }
        
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);

    }];
    
}

///重新请求
-(void)requsetAgain{
    if (self.RequestAgainBlock) {
        NSLog(@"requsetAgain->");
        self.RequestAgainBlock();
    }
}



#pragma mark - 联络中心登录事件
-(void)loginInBackgroundLLC{
    
    /*
     
     NSString *psw = md5Encode(@"111111");
     NSString *companyName = @"4008290377";
     NSString *userName = @"boss";
     
     NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:userName,@"companyName",//企业账号
     companyName,@"userName",//工号
     psw,@"password", nil];//密码
     */
    
    
    NSDictionary *account = [LLC_NSUserDefaults_Cache getUserAccountInfo];
    NSString *userName = [account safeObjectForKey:@"userName"];
    NSString *companyName = [account safeObjectForKey:@"companyName"];
    NSString *password = [account safeObjectForKey:@"password"];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:userName forKey:@"userName"];
    [params setObject:companyName forKey:@"companyName"];
    [params setObject:password forKey:@"password"];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_LOGIN_ACTION] params:params success:^(id responseObj) {
        //字典转模型
//        NSLog(@"session失效 登录事件 responseObj:%@",responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 1) {
            if ([[params safeObjectForKey:@"userName"] isEqualToString:@"boss"]) {
                [CommonStaticVar setAccountType:@"boss"];
            }else{
                [CommonStaticVar setAccountType:@"normal"];
            }
            
            __weak typeof(self) weak_self = self;
            [weak_self requsetAgain];
        }else{
            
        }
        
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        
    }];
}


#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    ///返回到登陆页面
    if (alertView.tag == 10101) {
        
    }
}


@end
