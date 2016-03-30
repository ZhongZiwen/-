//
//  UITableView+Common.h
//  shangketong
//
//  Created by sungoin-zbs on 15/4/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseBlankPageView.h"

@interface UITableView (Common)

- (void)addRadiusforCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)addLineforPlainCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withLeftSpace:(CGFloat)leftSpace;

#pragma mark - EaseBlankPageView
@property (strong, nonatomic) EaseBlankPageView *blankPageView;
- (void)configBlankPageWithTitle:(NSString*)title hasData:(BOOL)hasData hasError:(BOOL)hasError reloadButtonBlock:(void(^)(id sender))block;
@end
