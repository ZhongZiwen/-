//
//  OAComment.m
//  shangketong
//
//  Created by sungoin-zbs on 16/1/14.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import "OAComment.h"

@implementation OAComment

- (instancetype)init {
    self = [super init];
    if (self) {
        _altsArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}
@end
