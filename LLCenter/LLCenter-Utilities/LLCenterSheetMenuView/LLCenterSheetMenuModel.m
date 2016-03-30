//
//  SheetMenuModel.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "LLCenterSheetMenuModel.h"

@implementation LLCenterSheetMenuModel



- (id)init
{
    if (self = [super init])
    {
        self.itmeId = [[NSString alloc]init];
        self.title = [[NSString alloc]init];
        self.selectedFlag = [[NSString alloc]init];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    LLCenterSheetMenuModel *copy = [[[self class] allocWithZone:zone] init];
    copy->_itmeId = [_itmeId copy];
    copy->_title = [_title copy];
    copy->_selectedFlag = [_selectedFlag copy];
    return copy;
}


@end
