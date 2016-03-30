//
//  ScheduleType.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ScheduleType.h"

@implementation ScheduleType

#pragma mark - XLFormOptionObject
- (NSString*)formDisplayText {
    return _name;
}

- (id)formValue {
    return _id;
}
@end
