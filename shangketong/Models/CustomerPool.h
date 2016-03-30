//
//  CustomerPool.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomerPool : NSObject

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber *backCount;
@property (strong, nonatomic) NSNumber *canGet;
@property (strong, nonatomic) NSDate *createTime;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *reason;

@property (assign, nonatomic) BOOL isGet;           // 是否被领取

+ (NSString*)keyName;
@end