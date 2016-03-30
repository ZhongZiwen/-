//
//  IndexCondition.h
//  shangketong
//
//  Created by sungoin-zbs on 15/12/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IndexCondition : NSObject<NSCoding>

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber *itemCount;
@property (copy, nonatomic) NSString *name;

- (instancetype)initWithId:(NSNumber*)mID name:(NSString*)name;
+ (instancetype)initWithId:(NSNumber*)mID name:(NSString*)name;
@end
