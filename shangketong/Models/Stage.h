//
//  Stage.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stage : NSObject<NSCoding>

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSNumber *percent;
@property (strong, nonatomic) NSNumber *money;
@property (copy, nonatomic) NSString *name;

@property (assign, nonatomic) BOOL isShow;
@property (strong, nonatomic) NSMutableArray *opportunityArray;
@end
