//
//  RegisterViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/5/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "RegisterViewController.h"
#import <TPKeyboardAvoidingTableView.h>
#import "LoginTableViewCell.h"
#import "RegisterCompleteViewController.h"
#import <MBProgressHUD.h>
#define kCellIdentifier @"LoginTableViewCell"

typedef NS_ENUM(NSUInteger, RegisterType) {
    RegisterTypePhone,
    RegisterTypeEmail
};

@interface RegisterViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) TPKeyboardAvoidingTableView *m_tableView;
@property (nonatomic, weak) UIButton *m_captchaButton;
@property (nonatomic, assign) RegisterType registerType;
@property (nonatomic, copy) NSString *inputString;

@property (strong, nonatomic) NSMutableDictionary *params;
@end

@implementation RegisterViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    
    _registerType = RegisterTypePhone;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    if (!_m_tableView) {
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[LoginTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
        tableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
        tableView.tableHeaderView = [self customHeaderView];
        tableView.tableFooterView = [self customFooterView];
        [self.view addSubview:tableView];
        _m_tableView = tableView;
    }
}

#pragma mark - Private_M
- (UIView*)customHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 54)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kCellLeftWidth, 20, 200, 34)];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = @"登录时的个人账号";
    [headerView addSubview:label];
    
    return headerView;
}

- (UIView*)customFooterView
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 200)];
    
    UIButton *captchaButton = [UIButton buttonWithStyle:StrapPrimaryStyle andTitle:@"获取验证码" andFrame:CGRectMake(20, 20, kScreen_Width-2*20, 40) target:self action:@selector(captchaButtonPress)];
    [footerView addSubview:captchaButton];
    _m_captchaButton = captchaButton;
    
    UIButton *emailRegisterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    emailRegisterBtn.frame = CGRectMake(_m_captchaButton.frame.origin.x, 20*2+CGRectGetHeight(_m_captchaButton.bounds), 100, 20);
    emailRegisterBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [emailRegisterBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [emailRegisterBtn setTitle:@"用邮箱注册" forState:UIControlStateNormal];
    [emailRegisterBtn addTarget:self action:@selector(emailRegisterButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:emailRegisterBtn];
    
    return footerView;
}

// 获取验证码
- (void)captchaButtonPress {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    [self.view endEditing:YES];

    if (![_inputString length]) {
        UIAlertView *alserView = [[UIAlertView alloc] initWithTitle:@"错误提示" message:(_registerType == RegisterTypePhone? @"请输入手机号":@"请输入邮箱地址") delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alserView show];
        return;
    }
    if (_registerType == RegisterTypePhone && ![CommonFuntion isMobileNumber:_inputString]) {
        UIAlertView *alserView = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"请输入正确的手机号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alserView show];
        return;
    }
    if (_registerType == RegisterTypeEmail && ![NSString isValidateEmail:_inputString]) {
        UIAlertView *alserView = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"请输入正确的邮箱地址" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alserView show];
        return;
    }
    
    [_params setObject:_inputString forKey:@"accountName"];
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_SendCaptcha_WithParams:_params block:^(id data, NSError *error) {
        [self.view endLoading];
        
        if (data && ![data integerValue]) {
            RegisterCompleteViewController *registerCompleteController = [[RegisterCompleteViewController alloc] init];
            registerCompleteController.authCodeType = AuthCodeTypeRegister;
            registerCompleteController.title = @"注册";
            registerCompleteController.inputStr = _inputString;
            if (_registerType == RegisterTypeEmail) {
                registerCompleteController.isEmailRegister = YES;
            }
            [self.navigationController pushViewController:registerCompleteController animated:YES];
        }else {
            UIAlertView *alserView = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"获取验证码失败，请重试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alserView show];
        }
    }];
}

// 邮箱注册
- (void)emailRegisterButtonPress:(UIButton*)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    LoginTableViewCell *cell = (LoginTableViewCell*)[_m_tableView cellForRowAtIndexPath:indexPath];
    
    if (_registerType == RegisterTypePhone) {
        _registerType = RegisterTypeEmail;
        [sender setTitle:@"用手机号注册" forState:UIControlStateNormal];
        [cell configTextFieldWithPlaceholder:@"输入邮箱" captchaWithBool:NO];
    }else{
        _registerType = RegisterTypePhone;
        [sender setTitle:@"用邮箱注册" forState:UIControlStateNormal];
        [cell configTextFieldWithPlaceholder:@"输入手机号" captchaWithBool:NO];
    }
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [LoginTableViewCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LoginTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    [cell configTextFieldWithPlaceholder:@"输入手机号" captchaWithBool:NO];
    cell.textValueChangedBlock = ^(NSString *valueString) {
        _inputString = valueString;
    };
    
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kCellLeftWidth];
    
    return cell;
}


#pragma mark - UIScrollView
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
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