//
//  LLC_NSUserDefaults_Cache.m
//  
//
//  Created by sungoin-zjp on 15/12/30.
//
//

#define kLLCUserAccountInfo   @"llc_user_account_info"

#import "LLC_NSUserDefaults_Cache.h"
#import "NSUserDefaults_Cache.h"
#import "InterfacesAction.h"

@implementation LLC_NSUserDefaults_Cache

#pragma mark - 帐号信息
///存储当前用户帐号信息
+(void)setUserAccountInfo:(NSDictionary *)userInfo{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:userInfo forKey:kLLCUserAccountInfo];
    [userDefaults synchronize];
    
}

///获取存储的当前用户帐号信息
+(NSDictionary *)getUserAccountInfo{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    return  [userDefaultes dictionaryForKey:kLLCUserAccountInfo];
}


///根据商客通返回登陆信息  存储联络中心账号信息
+(void)saveLLCAccountInfo:(NSDictionary *)loginInfo{
    
//    tele4Account = "chen@4002562.com";
    
    //    NSString *userName = @"4000091694";
    //    NSString *userName = @"4008290377";
    //    NSString *userName = @"4000038555";
    //    NSString *userName = @"4000093012";
    
    
    //    NSString *psw = md5Encode(@"111111");
    //    NSString *companyName = @"boss";
    //    NSString *userName = @"4008290377";
    
    ///工号@4008016161
    ///@"4008771655";
   
    
    if (loginInfo) {
        
        
        
//        NSString *tele4Account = @"boss@4008771655";
        NSString *tele4Account = [loginInfo safeObjectForKey:@"tele4Account"];
        
        if (tele4Account.length > 0) {
            NSArray *arr = [tele4Account componentsSeparatedByString:@"@"];
            if (arr && [arr count] == 2) {
                NSDictionary *account = [NSUserDefaults_Cache getUserAccountInfo];
                NSString *passwordStr = [account safeObjectForKey:@"password"];
                ///400工号
                NSString *userName = [arr objectAtIndex:0];
                ///400号码
                NSString *companyName = [arr objectAtIndex:1];
                //密码
                NSString *password = md5Encode(passwordStr);
                
                
                NSMutableDictionary *params=[NSMutableDictionary dictionary];
                [params setObject:userName forKey:@"userName"];
                [params setObject:companyName forKey:@"companyName"];
                [params setObject:password forKey:@"password"];
                
                ///存储登录账号信息
                [self setUserAccountInfo:params];
            }else{
                 ///存储登录账号信息
                 [self setUserAccountInfo:nil];
             }
        }else{
            ///存储登录账号信息
            [self setUserAccountInfo:nil];
        }
        
        
    
    
    /*
        NSString *password = md5Encode(@"111111");
//      NSString *companyName = @"4008771655";
//        NSString *companyName = @"4008290377";
        NSString *companyName = @"4008290377";
        NSString *userName = @"boss";
        
        NSMutableDictionary *params=[NSMutableDictionary dictionary];
        [params setObject:userName forKey:@"userName"];
        [params setObject:companyName forKey:@"companyName"];
        [params setObject:password forKey:@"password"];
        
        ///存储登录账号信息
        [self setUserAccountInfo:params];
    */
     
     
    }
}

@end
