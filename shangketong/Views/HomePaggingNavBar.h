//
//  HomePaggingNavBar.h
//  shangketong
//
//  Created by sungoin-zbs on 15/4/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomePaggingNavBar : UIView

/**
 * 显示在导航条上的title集合
 */
@property (nonatomic, strong) NSArray *titlesArray;

/**
 * 当前页码
 */
@property (nonatomic, assign) NSInteger currentPage;

/**
 * 外部设置滑动页面的距离
 */
@property (nonatomic, assign) CGPoint contentOffset;

@end
