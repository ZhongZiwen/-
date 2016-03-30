//
//  ProductGroup.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ProductGroup.h"

@implementation ProductGroup

- (instancetype)init {
    self = [super init];
    if (self) {
        _array = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}
@end
