//
//  CustomTabBarViewController.h
//  lianluozhongxin
//
//  原理：在系统的tabbar上覆盖一个view，并把原来的view隐藏
//
//  Created by Vescky on 14-7-4.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface CustomTabBarViewController : UITabBarController {
    NSMutableArray *buttons;
    int currentSelectedIndex;
    UIView *customTabBarView;
}

@property (nonatomic,assign) int currentSelectedIndex;
@property (nonatomic,retain) NSMutableArray *buttons;
@property (nonatomic,strong) NSMutableArray *selectedImages,*unselectedImages;
@property (nonatomic,strong) NSMutableArray *titles;
@property (nonatomic) bool isBarHidden;
@property (nonatomic,strong) UIView *customTabBarView;

//隐藏真实tabbar
- (void)hideRealTabBar;
//自定义tabbar
- (void)customTabBar;
//选中的一项
- (void)selectedTab:(UIButton *)button;
//设置自定义tabbar隐藏
- (void)setCustomTabBarHidden:(bool)isHidden animated:(bool)animated;

@end
