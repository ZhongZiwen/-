//
//  UIBarButtonItem+Common.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/26.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Common)

+ (UIBarButtonItem*)itemWithBtnTitle:(NSString*)title target:(id)obj action:(SEL)selector;
+ (UIBarButtonItem*)itemWithIcon:(NSString*)iconName showBadge:(BOOL)showBadge target:(id)obj action:(SEL)selector;
@end
