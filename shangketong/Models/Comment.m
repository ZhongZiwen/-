//
//  Comment.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "Comment.h"

@implementation Comment

- (instancetype)init {
    self = [super init];
    if (self) {
        _altsArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}
@end
