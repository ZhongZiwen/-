//
//  PoolGroup.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PoolGroup : NSObject

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber *waitToGetCount;
@property (copy, nonatomic) NSString *name;
@end
