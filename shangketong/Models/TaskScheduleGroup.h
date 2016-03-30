//
//  TaskScheduleGroup.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskScheduleGroup : NSObject

@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *array;
@property (assign, nonatomic) BOOL isShow;

- (instancetype)initWithGroupName:(NSString*)name;
+ (instancetype)initWithGroupName:(NSString*)name;
@end
