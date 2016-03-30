//
//  ColumnSelectModel.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ColumnSelectModel.h"

@implementation ColumnSelectModel

- (instancetype)copyWithZone:(NSZone *)zone {
    ColumnSelectModel *selected = [[self class] allocWithZone:zone];
    selected.id = [_id copy];
    selected.value = [_value copy];
    return selected;
}
@end
