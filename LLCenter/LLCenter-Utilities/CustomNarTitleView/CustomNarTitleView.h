//
//  CustomNarTitleView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomNarTitleView : UIView

@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (assign, nonatomic) NSInteger index;
@property (copy, nonatomic) NSString *defalutTitleString;
@property (weak, nonatomic) UIViewController *superViewController;
@property (assign, nonatomic) BOOL isShow;
@property (copy, nonatomic) void(^valueBlock) (NSInteger index);

-(void)setIndicatorViewHide:(BOOL)hide;
@end
