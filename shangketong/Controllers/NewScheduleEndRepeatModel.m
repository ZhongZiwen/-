//
//  NewScheduleEndRepeatModel.m
//  shangketong
//
//  Created by sungoin-zjp on 15-8-5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "NewScheduleEndRepeatModel.h"

@implementation NewScheduleEndRepeatModel

- (id)init {
    self = [super init];
    if (self) {
        self.selectedContent = @"";
    }
    return self;
}

#pragma mark - XLFormOptionObject
- (NSString*)formDisplayText {
    return _selectedContent;
}

- (id)formValue {
    return _selectedContent;
}


@end
