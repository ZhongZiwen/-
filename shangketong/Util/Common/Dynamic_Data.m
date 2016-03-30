//
//  Dynamic_Data.m
//  shangketong
//
//  Created by sungoin-zjp on 15-8-7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "Dynamic_Data.h"
#import "CommonConstant.h"
#import "NSUserDefaults_Cache.h"

@implementation Dynamic_Data

#pragma mark - 同步到本地文件
///将更改的【我关注的动态】同步到本地文件
+(void)updateUserFocusDynamicToFile:(NSArray *)array{
    NSArray *arrayNew = [NSArray arrayWithArray:array];
    if (appDelegateAccessor.moudle.user_focus_dynamic == nil) {
        appDelegateAccessor.moudle.user_focus_dynamic = [[NSMutableArray alloc] init];
    }
    [appDelegateAccessor.moudle.user_focus_dynamic removeAllObjects];
    [appDelegateAccessor.moudle.user_focus_dynamic addObjectsFromArray:arrayNew];
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:appDelegateAccessor.moudle.user_focus_dynamic];
    [data writeToFile:appDelegateAccessor.moudle.filepath_user_focus_dynamic atomically:YES];
}

///将更改的【公开动态】同步到本地文件
+(void)updateUserPublicDynamicToFile:(NSArray *)array{
    NSArray *arrayNew = [NSArray arrayWithArray:array];
    if (appDelegateAccessor.moudle.user_public_dynamic == nil) {
        appDelegateAccessor.moudle.user_public_dynamic = [[NSMutableArray alloc] init];
    }
    [appDelegateAccessor.moudle.user_public_dynamic removeAllObjects];
    [appDelegateAccessor.moudle.user_public_dynamic addObjectsFromArray:arrayNew];
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:appDelegateAccessor.moudle.user_public_dynamic];
    [data writeToFile:appDelegateAccessor.moudle.filepath_user_public_dynamic atomically:YES];
}

///将更改的【我的收藏】同步到本地文件
+(void)updateUserFavoriteDynamicToFile:(NSArray *)array{
    NSArray *arrayNew = [NSArray arrayWithArray:array];
    if (appDelegateAccessor.moudle.user_favorite_dynamic == nil) {
        appDelegateAccessor.moudle.user_favorite_dynamic = [[NSMutableArray alloc] init];
    }
    [appDelegateAccessor.moudle.user_favorite_dynamic removeAllObjects];
    [appDelegateAccessor.moudle.user_favorite_dynamic addObjectsFromArray:arrayNew];
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:appDelegateAccessor.moudle.user_favorite_dynamic];
    [data writeToFile:appDelegateAccessor.moudle.filepath_user_favorite_dynamic atomically:YES];
}

///将更改的【我的动态】同步到本地文件
+(void)updateUserMyDynamicToFile:(NSArray *)array{
    NSArray *arrayNew = [NSArray arrayWithArray:array];
    if (appDelegateAccessor.moudle.user_my_dynamic == nil) {
        appDelegateAccessor.moudle.user_my_dynamic = [[NSMutableArray alloc] init];
    }
    [appDelegateAccessor.moudle.user_my_dynamic removeAllObjects];
    [appDelegateAccessor.moudle.user_my_dynamic addObjectsFromArray:arrayNew];

    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:appDelegateAccessor.moudle.user_my_dynamic];
    [data writeToFile:appDelegateAccessor.moudle.filepath_user_my_dynamic atomically:YES];
}


#pragma mark - 根据登录信息 设置缓存文件的为当前路径
///根据登录信息 设置缓存文件的为当前路径
///公司名称_帐号UID_动态类型.dat
+(void)setDynamicCacheFilePathByUserLoginInfo{
    NSDictionary *userInfo = [NSUserDefaults_Cache getUserInfo];
    
    NSString *companyName = [userInfo safeObjectForKey:@"companyName"];
    NSString *userId = [userInfo safeObjectForKey:@"id"] ;
    appDelegateAccessor.moudle.userId = userId;
    appDelegateAccessor.moudle.userName = [userInfo safeObjectForKey:@"name"];
    appDelegateAccessor.moudle.userCompanyId = [userInfo safeObjectForKey:@"companyId"];
    appDelegateAccessor.moudle.IM_tokenString = [userInfo safeObjectForKey:@"token"];
    appDelegateAccessor.moudle.userFunctionCodes = [userInfo safeObjectForKey:@"functionCodes"];
    appDelegateAccessor.moudle.isOpen_cluePool = [[userInfo safeObjectForKey:@"cluePoolOpen"] integerValue];
    appDelegateAccessor.moudle.isOpen_customerPool = [[userInfo safeObjectForKey:@"customerPoolOpen"] integerValue];
    
    NSString *preStr = [NSString stringWithFormat:@"%@_%@",companyName,userId];
//    NSString *preStr = [NSString stringWithFormat:@"%@_",userId];
    NSLog(@"file preStr:%@",preStr);
    
    appDelegateAccessor.moudle.filepath_user_focus_dynamic = [Dynamic_Data documentsPath:[NSString stringWithFormat:@"%@_user_focus_dynamic.dat",preStr]];
    
    appDelegateAccessor.moudle.filepath_user_public_dynamic = [Dynamic_Data documentsPath:[NSString stringWithFormat:@"%@_user_public_dynamic.dat",preStr]];
    
    appDelegateAccessor.moudle.filepath_user_favorite_dynamic = [Dynamic_Data documentsPath:[NSString stringWithFormat:@"%@_user_favorite_dynamic.dat",preStr]];
    
    appDelegateAccessor.moudle.filepath_user_my_dynamic = [Dynamic_Data documentsPath:[NSString stringWithFormat:@"%@_user_my_dynamic.dat",preStr]];
}


#pragma mark - 获取本地缓存
///获取本地缓存的【我关注的动态】
+(void)getUserFocusDynamic{
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:appDelegateAccessor.moudle.filepath_user_focus_dynamic]];
    
    if(appDelegateAccessor.moudle.user_focus_dynamic == nil)
    {
        appDelegateAccessor.moudle.user_focus_dynamic = [[NSMutableArray alloc]init];
    }
    
    if (array && [array count] > 0) {
        [appDelegateAccessor.moudle.user_focus_dynamic addObjectsFromArray:array];
    }
}


///获取本地缓存的【公开动态】
+(void)getUserPublicDynamic{
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:appDelegateAccessor.moudle.filepath_user_public_dynamic]];
    
    if(appDelegateAccessor.moudle.user_public_dynamic == nil)
    {
        appDelegateAccessor.moudle.user_public_dynamic = [[NSMutableArray alloc]init];
    }
    
    if (array && [array count] > 0) {
        [appDelegateAccessor.moudle.user_public_dynamic addObjectsFromArray:array];
    }
}

///获取本地缓存的【我收藏动态】
+(void)getUserFavoriteDynamic{
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:appDelegateAccessor.moudle.filepath_user_favorite_dynamic]];
    
    if(appDelegateAccessor.moudle.user_favorite_dynamic == nil)
    {
        appDelegateAccessor.moudle.user_favorite_dynamic = [[NSMutableArray alloc]init];
    }
    
    if (array && [array count] > 0) {
        [appDelegateAccessor.moudle.user_favorite_dynamic addObjectsFromArray:array];
    }
}


///获取本地缓存的【我的动态】
+(void)getUserMyDynamic{
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:appDelegateAccessor.moudle.filepath_user_my_dynamic]];
    
    if(appDelegateAccessor.moudle.user_my_dynamic == nil)
    {
        appDelegateAccessor.moudle.user_my_dynamic = [[NSMutableArray alloc]init];
    }
    
    if (array && [array count] > 0) {
        [appDelegateAccessor.moudle.user_my_dynamic addObjectsFromArray:array];
    }
}


#pragma mark - 清除本地缓存
+(void)clearDynamicCache{
    NSData * data ;
    if (appDelegateAccessor.moudle.user_focus_dynamic) {
        [appDelegateAccessor.moudle.user_focus_dynamic removeAllObjects];
    }
    data = [NSKeyedArchiver archivedDataWithRootObject:appDelegateAccessor.moudle.user_focus_dynamic];
    [data writeToFile:appDelegateAccessor.moudle.filepath_user_focus_dynamic atomically:YES];
    
    
    if (appDelegateAccessor.moudle.user_public_dynamic) {
        [appDelegateAccessor.moudle.user_public_dynamic removeAllObjects];
    }
    data = [NSKeyedArchiver archivedDataWithRootObject:appDelegateAccessor.moudle.user_public_dynamic];
    [data writeToFile:appDelegateAccessor.moudle.filepath_user_public_dynamic atomically:YES];
    
    
    if (appDelegateAccessor.moudle.user_favorite_dynamic) {
        [appDelegateAccessor.moudle.user_favorite_dynamic removeAllObjects];
    }
    data = [NSKeyedArchiver archivedDataWithRootObject:appDelegateAccessor.moudle.user_favorite_dynamic];
    [data writeToFile:appDelegateAccessor.moudle.filepath_user_favorite_dynamic atomically:YES];
    
    
    if (appDelegateAccessor.moudle.user_my_dynamic) {
        [appDelegateAccessor.moudle.user_my_dynamic removeAllObjects];
    }
    data = [NSKeyedArchiver archivedDataWithRootObject:appDelegateAccessor.moudle.user_my_dynamic];
    [data writeToFile:appDelegateAccessor.moudle.filepath_user_my_dynamic atomically:YES];
}

#pragma mark-  文件路径相关
+(NSString *)bundlePath:(NSString *)fileName {
    return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:fileName];
}

+(NSString *)documentsPath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

+(NSString *)documentsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"%@",documentsDirectory);
    return documentsDirectory;
}

+(NSString*)pngFileNameWithTime
{
    NSDate *date = [NSDate date];
    NSString *dateStr = [date description];
    
    //    NSLog(@"%@",dateStr);
    
    NSMutableString *mutabletem = [NSMutableString stringWithString:[dateStr substringWithRange:NSMakeRange(0,4)]];
    [mutabletem appendString:[dateStr substringWithRange:NSMakeRange(5,2)]];
    [mutabletem appendString:[dateStr substringWithRange:NSMakeRange(8,2)]];
    [mutabletem appendString:[dateStr substringWithRange:NSMakeRange(11,2)]];
    [mutabletem appendString:[dateStr substringWithRange:NSMakeRange(14,2)]];
    [mutabletem appendString:[dateStr substringWithRange:NSMakeRange(17,2)]];
    return [self documentsPath:[NSString stringWithFormat:@"%@.png",mutabletem]];
}

+(NSString*)h264FileNameWithTime
{
    NSDate *date = [NSDate date];
    NSString *dateStr = [date description];
    
    //    NSLog(@"%@",dateStr);
    
    NSMutableString *mutabletem = [NSMutableString stringWithString:[dateStr substringWithRange:NSMakeRange(0,4)]];
    [mutabletem appendString:[dateStr substringWithRange:NSMakeRange(5,2)]];
    [mutabletem appendString:[dateStr substringWithRange:NSMakeRange(8,2)]];
    [mutabletem appendString:[dateStr substringWithRange:NSMakeRange(11,2)]];
    [mutabletem appendString:[dateStr substringWithRange:NSMakeRange(14,2)]];
    [mutabletem appendString:[dateStr substringWithRange:NSMakeRange(17,2)]];
    return [self documentsPath:[NSString stringWithFormat:@"%@.h264",mutabletem]];
}

@end
