//
//  GuideViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "GuideViewController.h"
#import "UIView+Common.h"

#import "LoginViewController.h"
#import "RegisterViewController.h"


#define kSpace              10
#define kSizeWidth_Button   70
#define kSizeHeight_Button  (54-2*kSpace)

@interface GuideViewController ()<UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView *bgView;
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) UIButton *registerButton;
@property (nonatomic, strong) UIScrollView *m_scrollView;
@property (nonatomic, strong) UIPageControl *m_pageControl;
@property (nonatomic, strong) UIView *m_bottomView;
@end

@implementation GuideViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    self.title = @"";
    
    [self.view addSubview:self.bgView];
    [self.view addSubview:self.loginButton];
    [self.view addSubview:self.registerButton];
//    [self.view addSubview:self.m_scrollView];
//    [self.view addSubview:self.m_pageControl];
//    [self.view addSubview:self.m_bottomView];
    
    ///直接跳转到登陆页面
    if (self.flagToLoginView && self.flagToLoginView.length > 0) {
        LoginViewController *loginController = [[LoginViewController alloc] init];
        loginController.title = @"登录";
        loginController.errorDesc = self.errorDesc;
        [self.navigationController pushViewController:loginController animated:NO];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kView_BG_Color;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
//    for (int i = 0; i < 5; i ++) {
//        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"login_640w_%d@2x", i+2] ofType:@"png"]];
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//        imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
//        imageView.center = CGPointMake(CGRectGetWidth(_m_scrollView.bounds)*i+CGRectGetWidth(_m_scrollView.bounds)/2.0, (CGRectGetHeight(_m_scrollView.bounds)-54)/2.0);
////        imageView.contentMode = UIViewContentModeScaleAspectFit;
//        [_m_scrollView addSubview:imageView];
//    }
//    [_m_scrollView setContentSize:CGSizeMake(CGRectGetWidth(_m_scrollView.bounds) * 5, CGRectGetHeight(_m_scrollView.bounds))];
//    
//    _m_pageControl.frame = CGRectMake(0, kScreen_Height-54-40, kScreen_Width, 40);
//    _m_pageControl.numberOfPages = 5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 注册
- (void)registerButtonPress
{
    RegisterViewController *registerController = [[RegisterViewController alloc] init];
    registerController.title = @"新用户注册";
    [self.navigationController pushViewController:registerController animated:YES];
}

// 快速体验
- (void)experienceButtonPress
{
    
}

// 登录
- (void)loginButtonPress
{
    LoginViewController *loginController = [[LoginViewController alloc] init];
    loginController.title = @"登录";
    [self.navigationController pushViewController:loginController animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 根据当前的x坐标和宽度计算出当前页数
    _m_pageControl.currentPage = (int)scrollView.contentOffset.x/kScreen_Width;
}

#pragma mark - setters and getters

- (UIImageView*)bgView {
    if (!_bgView) {
        UIImage *image;
        if (kDevice_Is_iPhone6Plus) {
            image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"guide_iPhone6Plus@2x" ofType:@"png"]];
        }
        else if (kDevice_Is_iPhone6) {
            image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"guide_iPhone6@2x" ofType:@"png"]];
        }
        else if (kDevice_Is_iPhone5) {
            image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"guide_iPhone5@2x" ofType:@"png"]];
        }
        else {
            image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"guide_iPhone4@2x" ofType:@"png"]];
        }
        _bgView = [[UIImageView alloc] initWithImage:image];
        _bgView.contentMode = UIViewContentModeScaleAspectFit;
        [_bgView setWidth:kScreen_Width];
        [_bgView setHeight:kScreen_Height];
    }
    return _bgView;
}

- (UIButton*)loginButton {
    if (!_loginButton) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (kDevice_Is_iPhone6Plus) {
            [_loginButton setWidth:307.0];
            [_loginButton setHeight:50.0];
            [_loginButton setY:kScreen_Height - 226.0];
            _loginButton.titleLabel.font = [UIFont systemFontOfSize:20];
        }
        else if (kDevice_Is_iPhone6) {
            [_loginButton setWidth:280.0];
            [_loginButton setHeight:47.0f];
            [_loginButton setY:kScreen_Height - 205.0];
            _loginButton.titleLabel.font = [UIFont systemFontOfSize:18];
        }
        else if (kDevice_Is_iPhone5) {
            [_loginButton setWidth:239.0];
            [_loginButton setHeight:40];
            [_loginButton setY:kScreen_Height - 175.0];
            _loginButton.titleLabel.font = [UIFont systemFontOfSize:18];
        }
        else {
            [_loginButton setWidth:239.0];
            [_loginButton setHeight:40];
            [_loginButton setY:kScreen_Height - 149];
            _loginButton.titleLabel.font = [UIFont systemFontOfSize:16];
        }
        [_loginButton setCenterX:kScreen_Width / 2.0];
        [_loginButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_loginButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"0xd4eaff"]] forState:UIControlStateHighlighted];
        _loginButton.layer.cornerRadius = 5.0f;
        _loginButton.layer.masksToBounds = YES;
        _loginButton.clipsToBounds = YES;
        [_loginButton setTitleColor:[UIColor colorWithHexString:@"0x2f85d9"] forState:UIControlStateNormal];
        [_loginButton setTitle:@"登 录" forState:UIControlStateNormal];
        [_loginButton addTarget:self action:@selector(loginButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

- (UIButton*)registerButton {
    if (!_registerButton) {
        _registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_registerButton setWidth:CGRectGetWidth(_loginButton.bounds)];
        [_registerButton setHeight:CGRectGetHeight(_loginButton.bounds)];
        [_registerButton setCenterX:kScreen_Width / 2.0];
        if (kDevice_Is_iPhone6Plus) {
            [_registerButton setY:CGRectGetMaxY(_loginButton.frame) + 36.0];
        }
        else if (kDevice_Is_iPhone6) {
            [_registerButton setY:CGRectGetMaxY(_loginButton.frame) + 22.0];
        }
        else if (kDevice_Is_iPhone5) {
            [_registerButton setY:CGRectGetMaxY(_loginButton.frame) + 17.5];
        }
        else {
            [_registerButton setY:CGRectGetMaxY(_loginButton.frame) + 17.5];
        }
        [_registerButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"0x2f85d9"]] forState:UIControlStateNormal];
        [_registerButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"0x2579cb"]] forState:UIControlStateHighlighted];
        _registerButton.layer.cornerRadius = 5.0f;
        _registerButton.layer.borderWidth = 1.0f;
        _registerButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _registerButton.layer.masksToBounds = YES;
        _registerButton.clipsToBounds = YES;
        _registerButton.titleLabel.font = _loginButton.titleLabel.font;
        [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_registerButton setTitle:@"注 册" forState:UIControlStateNormal];
        [_registerButton addTarget:self action:@selector(registerButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerButton;
}

- (UIScrollView*)m_scrollView {
    if (!_m_scrollView) {
        _m_scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _m_scrollView.delegate = self;
        _m_scrollView.showsHorizontalScrollIndicator = NO;
        _m_scrollView.showsVerticalScrollIndicator = NO;
        _m_scrollView.bounces = NO;    // 去掉弹性效果
        _m_scrollView.pagingEnabled = YES;
    }
    return _m_scrollView;
}

- (UIPageControl*)m_pageControl {
    if (!_m_pageControl) {
        _m_pageControl = [[UIPageControl alloc] init];
        [_m_pageControl sizeToFit];
        _m_pageControl.currentPage = 0;
        _m_pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:(CGFloat)89/255 green:(CGFloat)174/255 blue:(CGFloat)231/255 alpha:1.0f];
        _m_pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    }
    return _m_pageControl;
}

- (UIView*)m_bottomView {
    if (!_m_bottomView) {
        _m_bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height-54, kScreen_Width, 54)];
        [_m_bottomView addLineUp:YES andDown:NO];
        
        UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        registerButton.frame = CGRectMake(kScreen_Width-kSpace-kSizeWidth_Button, kSpace, kSizeWidth_Button, kSizeHeight_Button);
        registerButton.layer.cornerRadius = 3;
        registerButton.clipsToBounds = YES;
        registerButton.titleLabel.font = [UIFont systemFontOfSize:14];
        registerButton.backgroundColor = COMMEN_LABEL_COROL;
        [registerButton setTitle:@"注册" forState:UIControlStateNormal];
        [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [registerButton addTarget:self action:@selector(registerButtonPress) forControlEvents:UIControlEventTouchUpInside];
        [_m_bottomView addSubview:registerButton];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kSpace, kSpace, kSizeWidth_Button, kSizeHeight_Button)];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"已有账号，";
        [_m_bottomView addSubview:label];
        
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        loginButton.frame = CGRectMake(kSpace+kSizeWidth_Button, kSpace, kSizeWidth_Button, kSizeHeight_Button);
        loginButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [loginButton setTitleColor:COMMEN_LABEL_COROL forState:UIControlStateNormal];
        [loginButton setTitle:@"点击登录" forState:UIControlStateNormal];
        [loginButton addTarget:self action:@selector(loginButtonPress) forControlEvents:UIControlEventTouchUpInside];
        [_m_bottomView addSubview:loginButton];
        
        UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSpace+kSizeWidth_Button, kSpace + kSizeHeight_Button - 10, kSizeWidth_Button, 0.5)];
        bottomLabel.backgroundColor = COMMEN_LABEL_COROL;
        [_m_bottomView addSubview:bottomLabel];
    }
    return _m_bottomView;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
