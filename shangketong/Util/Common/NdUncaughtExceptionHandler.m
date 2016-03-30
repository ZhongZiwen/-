//
//  NdUncaughtExceptionHandler.m
//  
//
//  Created by sungoin-zjp on 16/2/25.
//
//

#import "NdUncaughtExceptionHandler.h"

NSString *applicationDocumentsDirectory()
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


void UncaughtExceptionHandler(NSException *exception)
{
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *url = [NSString stringWithFormat:@"===SKT异常崩溃报告===:\nname:\n%@\nreason:\n%@\ncallStackSymbols:\n%@",
                     name,reason,[arr componentsJoinedByString:@"\n"]];
    NSLog(@"奔溃信息url:%@",url);
    
    ///此处对崩溃动作做对应操作
    [appDelegateAccessor removeTimer];
    [appDelegateAccessor removeHeartTimer];
    [appDelegateAccessor deleteWebSocket];
    
}

@implementation NdUncaughtExceptionHandler

-(NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (void)setDefaultHandler
{
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
}

+ (NSUncaughtExceptionHandler*)getHandler
{
    return NSGetUncaughtExceptionHandler();
}

@end
