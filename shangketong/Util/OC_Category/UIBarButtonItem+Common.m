//
//  UIBarButtonItem+Common.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/26.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "UIBarButtonItem+Common.h"

@implementation UIBarButtonItem (Common)

+ (UIBarButtonItem*)itemWithBtnTitle:(NSString *)title target:(id)obj action:(SEL)selector {
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:obj action:selector];
    [buttonItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]} forState:UIControlStateDisabled];
    return buttonItem;
}

+ (UIBarButtonItem*)itemWithIcon:(NSString *)iconName showBadge:(BOOL)showBadge target:(id)obj action:(SEL)selector {
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:iconName] style:UIBarButtonItemStylePlain target:obj action:selector];
    return buttonItem;
}
@end
