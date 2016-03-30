//
//  PopoverItem.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PopoverItem : NSObject

@property (strong, nonatomic) UIImage *image;
@property (copy, nonatomic) NSString *title;
@property (weak, nonatomic) id target;
@property (nonatomic) SEL action;

+ (instancetype)initItemWithTitle:(NSString*)title image:(UIImage*)image target:(id)target action:(SEL)action;
- (void) performAction;
@end