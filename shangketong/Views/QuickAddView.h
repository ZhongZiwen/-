//
//  QuickAddView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuickAddView : UIView

@property (nonatomic, strong) NSMutableArray *sourceArray;
@property (nonatomic, copy) void(^tapClickBlock) (NSString*);

- (void)popAnimationShow;
- (void)popAnimationDismiss;
@end
