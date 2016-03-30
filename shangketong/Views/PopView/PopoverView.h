//
//  PopoverView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopoverView : UIView

- (instancetype)initWithImageItems:(NSArray*)imageItems titleItems:(NSArray*)titleItems;
- (void)show;

@end
