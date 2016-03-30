//
//  ValueIdModel.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ValueIdModel : NSObject<NSCoding>

@property (copy, nonatomic) NSString *id;
@property (copy, nonatomic) NSString *value;

+ (instancetype)initWithId:(NSString*)mId value:(NSString*)value;
- (instancetype)initWithId:(NSString*)mId value:(NSString*)value;
@end
