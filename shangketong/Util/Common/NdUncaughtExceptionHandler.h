//
//  NdUncaughtExceptionHandler.h
//  程序异常时触发
//
//  Created by sungoin-zjp on 16/2/25.
//
//

#import <Foundation/Foundation.h>

@interface NdUncaughtExceptionHandler : NSObject

+ (void)setDefaultHandler;
+ (NSUncaughtExceptionHandler*)getHandler;

@end
