//
//  SaleLeadPool.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SaleLeadPool : NSObject

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber *backCount;
@property (strong, nonatomic) NSDate *createTime;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *companyName;
@property (copy, nonatomic) NSString *reason;
@property (strong, nonatomic) NSNumber *canGet;     // 能否领取

@property (assign, nonatomic) BOOL isGet;           // 是否被领取

+ (NSString*)keyName;
@end