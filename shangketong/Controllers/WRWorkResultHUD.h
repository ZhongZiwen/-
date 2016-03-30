//
//  WorkReportWorkResultHUD.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WRWorkResultHUD : UIView

@property (strong, nonatomic) UIFont *titleFont;
@property (strong, nonatomic) UIColor *titleColor;

- (void)startAnimationWith:(NSString*)string;
- (void)stopAnimationWith:(NSString*)string;
@end
