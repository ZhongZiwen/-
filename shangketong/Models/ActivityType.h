//
//  ActivityType.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityType : NSObject

@property (copy, nonatomic) NSString *id;
@property (strong, nonatomic) NSNumber *sum;
@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *activitiesArray;
@end
