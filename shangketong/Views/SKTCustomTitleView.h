//
//  SKTCustomTitleView.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^AnimateSmartViewBlock) (BOOL isShow);
typedef void (^CustomTitleViewTapBlock) (void);

@interface SKTCustomTitleView : UIView

@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, copy) NSString *titleString;

- (void)animateSmartViewWithBlock:(AnimateSmartViewBlock)block andTapBlock:(CustomTitleViewTapBlock)cBlock;

@end
