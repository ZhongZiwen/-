//
//  TaskScheduleGroup.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TaskScheduleGroup.h"

@implementation TaskScheduleGroup

- (instancetype)initWithGroupName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
        _array = [[NSMutableArray alloc] initWithCapacity:0];
        _isShow = [name isEqualToString:@"今天"];
    }
    return self;
}

+ (instancetype)initWithGroupName:(NSString *)name {
    TaskScheduleGroup *group = [[TaskScheduleGroup alloc] initWithGroupName:name];
    return group;
}
@end
