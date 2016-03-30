//
//  QuickGroup.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "QuickGroup.h"

@implementation QuickGroup

- (QuickGroup*)initWithName:(NSString *)groupName andQuickArray:(NSMutableArray *)quickArray
{
    self = [super init];
    if (self) {
        self.groupName = groupName;
        self.quickArray = quickArray;
    }
    return self;
}

+ (QuickGroup*)initWithName:(NSString *)groupName andQuickArray:(NSMutableArray *)quickArray
{
    QuickGroup *quickGroup = [[QuickGroup alloc] initWithName:groupName andQuickArray:quickArray];
    return quickGroup;
}
@end
