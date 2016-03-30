//
//  LLCSettingViewController.m
//  lianluozhongxin
//
//  Created by Vescky on 14-7-2.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "LLCSettingViewController.h"
#import "UserSession.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "SimpleActionSheet.h"

@interface LLCSettingViewController ()<SimpleActionSheetDelegate>

@end

@implementation LLCSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"设置";
    [super customBackButton];
    
    [self initView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView {
    if (!ios7OrLater()) {
        CGRect sRect = swh.frame;
        sRect.origin.x = sRect.origin.x - 20;
        swh.frame = sRect;
    }
    
    if ([[UserSession shareSession] canPlayVoiceWithoutWiFi]) {
        swh.on = NO;
    }
    else {
        swh.on = YES;
    }
}

- (IBAction)btnAction:(id)sender {
    //确定退出登录?
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"确定要注销登陆?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"注销", nil];
//    alert.delegate = self;
//    [alert show];
    
    SimpleActionSheet *sAs = [[SimpleActionSheet alloc] init];
    [sAs setAlertDescription:@"确定要注销登录?"];
    [sAs setButtonsTitle:[NSArray arrayWithObjects:@"注销",@"取消", nil]];
    sAs.delegate = self;
    [sAs showOnWindow:self.view.window];
}

- (IBAction)swichValueChanged:(id)sender {
    [[UserSession shareSession] setCanPlayVoiceWithoutWifi:!swh.on];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UserSession shareSession] destroyLoginInfo];//销毁登录信息
        [[UserSession shareSession] destroyAccountDetailInfo];//销毁账户信息
        LoginViewController *lVc = [[LoginViewController alloc] init];
        [app_delegate() window].rootViewController = lVc;
//        [self.navigationController pushViewController:lVc animated:YES];
    }
}

- (void)buttonDidClickedAtIndex:(int)index {
    if (index == 0) {
        [[UserSession shareSession] destroyLoginInfo];
        LoginViewController *lVc = [[LoginViewController alloc] init];
        [app_delegate() window].rootViewController = lVc;
        //        [self.navigationController pushViewController:lVc animated:YES];
    }
}

@end
