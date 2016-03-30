//
//  Examine.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "Examine.h"

@implementation Examine

- (instancetype)init {
    self = [super init];
    if (self) {
        _columnListArray = [[NSMutableArray alloc] initWithCapacity:0];
        _ccUsersArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}
@end
