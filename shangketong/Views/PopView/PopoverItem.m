//
//  PopoverItem.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PopoverItem.h"

@implementation PopoverItem

- (instancetype)initItemWithTitle:(NSString *)title image:(UIImage *)image target:(id)target action:(SEL)action {
    self = [super init];
    if (self) {
        
        _title = title;
        _image = image;
        _target = target;
        _action = action;
    }
    return self;
}

- (void) performAction
{
    __strong id target = self.target;
    
    if (target && [target respondsToSelector:_action]) {
        
        [target performSelectorOnMainThread:_action withObject:self waitUntilDone:YES];
    }
}

+ (instancetype)initItemWithTitle:(NSString *)title image:(UIImage *)image target:(id)target action:(SEL)action {
    PopoverItem *item = [[PopoverItem alloc] initItemWithTitle:title image:image target:target action:action];
    return item;
}
@end
