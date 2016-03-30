//
//  DepartGroupGroupModel.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "DepartGroupGroupModel.h"

@implementation DepartGroupGroupModel

- (DepartGroupGroupModel*)initWithGroupName:(NSString *)name {
    self = [super init];
    if (self) {
        self.groupName = name;
        self.groupArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

+ (DepartGroupGroupModel*)initWithGroupName:(NSString *)name {
    DepartGroupGroupModel *group = [[DepartGroupGroupModel alloc] initWithGroupName:name];
    return group;
}
@end
