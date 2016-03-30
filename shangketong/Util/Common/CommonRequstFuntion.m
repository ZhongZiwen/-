//
//  CommonRequstFuntion.m
//  shangketong
//
//  Created by sungoin-zjp on 15-5-27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CommonRequstFuntion.h"
#import "AFNHttp.h"
#import "CommonConstant.h"
#import "NSUserDefaults_Cache.h"
#import "FMDB_SKT_CACHE.h"
#import <MBProgressHUD.h>

@interface CommonRequstFuntion (){

}

@end

@implementation CommonRequstFuntion

#pragma mark - 根据目录id请求其对应的文件信息
-(NSDictionary *)getKnowledgeFileByDirId:(NSString *)dirId{

    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:dirId forKey:@"dirId"];
    
    //同步
    NSDictionary *info =  [AFNHttp doSynType:@"POST" WithUrl:@"" params:params];
    
    NSLog(@"getKnowledgeFileByDirId info:%@",info);
    
    if ([[info objectForKey:@"status"] integerValue] == 0) {
        return info;
    }else
    {
        return nil;
    }
    
    /*
    // 发起请求
    [AFNHttp post:GET_KNOWLEDGE_FILE_ACTION params:params success:^(id responseObj) {
        //字典转模型
        
        NSLog(@"根据目录id请求其对应的文件信息responseObj:%@",responseObj);
        
        NSDictionary *info = responseObj;
        
    } failure:^(NSError *error) {
        //隐藏遮罩
        
        NSLog(@"error:%@",error);
    }];
     */
}

-(void)xxxxxxxxx{
}


#pragma mark - 登录事件
+(NSDictionary *)loginEvent{
    
    NSDictionary *account = [NSUserDefaults_Cache getUserAccountInfo];
    NSString *accountName = [account safeObjectForKey:@"accountName"];
    NSString *password = [account safeObjectForKey:@"password"];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:accountName forKey:@"accountName"];
    [params setObject:password forKey:@"password"];
    
        //同步
    NSDictionary *responseObj =  [AFNHttp doSynType:@"POST" WithUrl:[NSString stringWithFormat:@"%@%@",kNetPath_Web_Server_Base,kNetPath_Login] params:params];
    
    NSLog(@"登录事件 responseObj:%@",responseObj);
    
    if ([[responseObj objectForKey:@"status"] integerValue] == 0) {
        ///喜报参数
        return responseObj;
    }else
    {
        return nil;
    }
}


#pragma mark - 获取部门或分组数据
+(void)getDepartmentsOrGroupDataFromService:(NSString *)dataType{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    NSString *url = @"";
    
    ///部门
    if ([dataType isEqualToString:@"department"]) {
        [params setObject:@"1" forKey:@"type"];
        url = [NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP,ADDRESS_BOOK_CHILD_DEPARTMENT_ACTION];
    }else{
        ///群组
        url = [NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP,ADDRESS_BOOK_GROUP_ACTION];
    }
    
    // 发起请求
    [AFNHttp post:url params:params success:^(id responseObj) {
        //字典转模型
        NSLog(@"部门/群组 responseObj:%@",responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
                
                NSArray *resultArray;
                ///部门
                if ([dataType isEqualToString:@"departments"]) {
                    if ([responseObj objectForKey:@"departments"] ) {
                        resultArray = [responseObj objectForKey:@"departments"];
                        if (appDelegateAccessor.moudle.arrayAllDepartment) {
                            [appDelegateAccessor.moudle.arrayAllDepartment removeAllObjects];
                        }else{
                            appDelegateAccessor.moudle.arrayAllDepartment = [[NSMutableArray alloc] init];
                        }
                        [appDelegateAccessor.moudle.arrayAllDepartment addObjectsFromArray:resultArray];
                        
                    }
                }else{
                    ///群组
                    if ([responseObj objectForKey:@"groups"] ) {
                        resultArray = [responseObj objectForKey:@"groups"];
                        if (appDelegateAccessor.moudle.arrayAllGroup) {
                            [appDelegateAccessor.moudle.arrayAllGroup removeAllObjects];
                        }else{
                            appDelegateAccessor.moudle.arrayAllGroup = [[NSMutableArray alloc] init];
                        }
                        [appDelegateAccessor.moudle.arrayAllGroup addObjectsFromArray:resultArray];
                    }
                }
            }
        
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        
    }];
}





#pragma mark - 举报功能
+(void)reportFun{
    kShowHUD(@"暂无举报接口");
}



@end
