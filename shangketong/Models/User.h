//
//  User.h
//  shangketong
//
//  Created by sungoin-zbs on 15/8/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject<NSCoding>

@property (copy, nonatomic) NSString *icon;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *company;
@property (copy, nonatomic) NSString *pinyin;
@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSDate *serverTime;
@end
