//
//  AppsBaseViewController.m
//  GDPU_Bible
//
//  Created by Vescky on 13-5-31.
//  Copyright (c) 2013年 gdpuDeveloper. All rights reserved.
//

#import "AppsBaseViewController.h"
#import "LLCenterUtility.h"

@implementation AppsBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
    if (!iPhone5()) {
        CGRect selfRect = self.view.frame;
        selfRect.size.height = 480.f;
        self.view.frame = selfRect;
    }
    */
    self.view.frame = CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT);
//    self.view.backgroundColor = kView_BG_Color;
    //定义导航栏标题字体颜色
    /*
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,
                          [UIColor clearColor],UITextAttributeTextShadowColor,
                          [UIFont systemFontOfSize:20],UITextAttributeFont,nil];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    */
    
    /*
    //2014-12-10-zjp
    NSDictionary * dict=[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    
    
    
    
    //适配ios7
    if (ios7OrLater()) {
        [self.navigationController.navigationBar setTranslucent:NO];
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        [self.navigationController.navigationBar setBarTintColor:GetColorWithRGB(250, 250, 250)];
    }
    else {
        [self.navigationController.navigationBar setTintColor:GetColorWithRGB(250, 250, 250)];
        self.navigationController.navigationBar.clipsToBounds = YES;
    }
     */
    
    [self customizeInterface];
    
    //适配ios7以下的系统
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    //监听键盘高度的变换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 键盘高度变化通知，ios5.0新增的
#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
#endif
}


/**
 * 设置导航条样式
 */
- (void)customizeInterface
{
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    
    // 设置导航栏的背景颜色
    [navigationBar setBarTintColor:[UIColor colorWithHexString:@"0x1d1d1d"]];
    
    
    // 默认情况下，导航栏的translucent属性为YES,另外，系统还会对所有的导航栏做模糊处理，这样可以让iOS 7中导航栏的颜色更加饱和。
    // 关闭导航栏translucent属性
    //    [navigationBar setTranslucent:NO];
    
    // 导航栏使用背景图片
    //    [navigationBar setBackgroundImage:[UIImage imageNamed:@"xxx"] forBarMetrics:UIBarMetricsDefault];
    
    // 制定返回按钮的颜色（tintColor熟悉会影响到所有按钮标题和图片）
    // 如果想要用自己的图片替换v型，可以通过backIndicatorImage和backIndicatorTransitionMaskImage方法来实现，图片的颜色是由tintColor属性控制的
    [navigationBar setTintColor:[UIColor whiteColor]];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    
    
    // 修改导航栏标题的字体
    [navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:kNavTitleFontSize],
                                            NSForegroundColorAttributeName: [UIColor whiteColor],}];
    
    // 修改状态栏的风格
    // 1:在project target的Info tab中，插入一个新的key，名字为View controller-based status bar appearance，并将其值设置为NO。
    // 2:设置StatusBarStyle
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    if (isSubView) {
        NSLog(@"二级View----->");
        // 二级View
//        setCustomTabBarHidden(YES, NO);
         NSLog(@"2级页面height:%f",self.view.frame.size.height);
        //重定义tabbar,navigation和view的高度
        if (self.view.frame.size.height == 367 || self.view.frame.size.height == 455 || self.view.frame.size.height == 554 || self.view.frame.size.height == 623) {
            CGRect sRect = self.view.frame;
            sRect.size.height = sRect.size.height + 49.0f;
            self.view.frame = sRect;
            
            //            CGRect nRect = self.navigationController.view.frame;
            //            nRect.size.height = nRect.size.height + 49.0f;
            //            self.navigationController.view.frame = nRect;
            
            CGRect tRect = self.tabBarController.view.frame;
            tRect.size.height = tRect.size.height + 49.0;
            self.tabBarController.view.frame = tRect;
             NSLog(@"2级页面height:%f",self.view.frame.size.height);
        }
    }
    else {
        NSLog(@"一级View----->");
//        setCustomTabBarHidden(NO, NO);
        
        NSLog(@"一级页面height:%f",self.view.frame.size.height);
        
        // 返回一级页面时 view frame做更改
        if (self.view.frame.size.height == 416 || self.view.frame.size.height == 504 || self.view.frame.size.height == 436 || self.view.frame.size.height == 603 || self.view.frame.size.height == 672) {
        
            CGRect sRect = self.view.frame;
            sRect.size.height = sRect.size.height - 49.0f;
            self.view.frame = sRect;
            
            CGRect tRect = self.tabBarController.view.frame;
            tRect.size.height = tRect.size.height - 49.0;
            self.tabBarController.view.frame = tRect;
            
            NSLog(@"一级页面2height:%f",self.view.frame.size.height);
            
        }
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    self.navigationController.navigationBarHidden = NO;
//    if (isSubView) {
//        setCustomTabBarHidden(YES, NO);
//        //重定义tabbar,navigation和view的高度
//        if (self.view.frame.size.height == 367 || self.view.frame.size.height == 455 ) {
//            CGRect sRect = self.view.frame;
//            sRect.size.height = sRect.size.height + 49.0f;
//            self.view.frame = sRect;
//            
////            CGRect nRect = self.navigationController.view.frame;
////            nRect.size.height = nRect.size.height + 49.0f;
////            self.navigationController.view.frame = nRect;
//            
//            CGRect tRect = self.tabBarController.view.frame;
//            tRect.size.height = tRect.size.height + 49.0;
//            self.tabBarController.view.frame = tRect;
//        }
//    }
//    else {
//        setCustomTabBarHidden(NO, NO);
//        
//        if (self.view.frame.size.height == 416 || self.view.frame.size.height == 504 || self.view.frame.size.height == 436) {
//            CGRect sRect = self.view.frame;
//            sRect.size.height = sRect.size.height - 49.0f;
//            self.view.frame = sRect;
//            
////            CGRect nRect = self.navigationController.view.frame;
////            nRect.size.height = nRect.size.height - 49.0f;
////            self.navigationController.view.frame = nRect;
//            
//            CGRect tRect = self.tabBarController.view.frame;
//            tRect.size.height = tRect.size.height - 49.0;
//            self.tabBarController.view.frame = tRect;
//        }
//    }
    
    
    //兼容ios5-6的navigationbar
    if (!ios7OrLater()) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:APP_Did_Enter_Forground object:nil];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}


//自定义样式的返回键
- (void)customBackButton {
    /*
    //自定义背景图片
    UIImage* image= [UIImage imageNamed:@"btn_back.png"];
    CGRect frame_1= CGRectMake(0, 0, 80, 44);
    UIView *cView = [[UIView alloc] initWithFrame:frame_1];
    
    //自定义按钮图片
    UIImageView *cImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 16, 24)];
    [cImgView setImage:image];
    [cView addSubview:cImgView];
    
    //覆盖一个大按钮在上面，利于用户点击
    UIButton* backButton= [[UIButton alloc] initWithFrame:frame_1];
    [backButton setBackgroundColor:[UIColor clearColor]];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [cView addSubview:backButton];
    
    //创建导航栏按钮UIBarButtonItem
    UIBarButtonItem* backItem= [[UIBarButtonItem alloc] initWithCustomView:cView];
    [self.navigationItem setLeftBarButtonItem:backItem];
    */
    isSubView = YES;
}


//自定义样式的返回键
- (void)customBackButtonWithTitle:(NSString *)title {
    UIButton* backButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];//
    [backButton setTitle:title forState:UIControlStateNormal];
    ///1C86FB
    [backButton setTitleColor:[UIColor colorWithRed:(CGFloat)28/255.0 green:(CGFloat)134/255.0 blue:(CGFloat)251/255.0 alpha:1.0] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBack)
         forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* backItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    isSubView = YES;
}

-(void)setFlagOfSubView{
    isSubView = YES;
}

//自定义样式的导航栏右键 -- 用图片
- (void)customNavigationBarRightButtonWithImageName:(NSString*)imgName {
    UIImage *btnImage = [UIImage imageNamed:imgName];
    //定制自己的风格的  UIBarButtonItem
    UIButton* jumpButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 4, 34, 36)];//
    [jumpButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [jumpButton addTarget:self action:@selector(rightBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* actionItem= [[UIBarButtonItem alloc] initWithCustomView:jumpButton];
    [self.navigationItem setRightBarButtonItem:actionItem];
    
}

//自定义样式的导航栏右键 -- 用标题
- (void)customNavigationBarRightButtonWithTitleName:(NSString*)titleName {
    if (titleName && titleName.length > 0) {
        UIButton* jumpButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];//
        [jumpButton setTitle:titleName forState:UIControlStateNormal];
        [jumpButton addTarget:self action:@selector(rightBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* actionItem= [[UIBarButtonItem alloc] initWithCustomView:jumpButton];
        [self.navigationItem setRightBarButtonItem:actionItem];
    }
}

//返回键响应函数，重写此函数，实现返回前执行一系列操作
- (void)goBack {
    NSLog(@"---goBack-->");
    [self.navigationController popViewControllerAnimated:YES];
}

//导航栏右键响应函数，重写此函数，响应点击事件
- (void)rightBarButtonAction {
    NSLog(@"need to implement this methor");
}


#pragma mark - Responding to keyboard events
//键盘即将出现时的回调函数
- (void)keyboardWillShow:(NSNotification *)notification {
    
}
//键盘即将隐藏时的回调函数
- (void)keyboardWillHide:(NSNotification *)notification {
    
}

- (void)didBecomeActive {
    [self performSelector:@selector(adjustNavigationBar) withObject:nil afterDelay:1.0];
}

- (void)adjustNavigationBar {
    CGRect nRect = self.navigationController.navigationBar.frame;
    nRect.origin.y = 20.0f;
    self.navigationController.navigationBar.frame = nRect;
}


@end
