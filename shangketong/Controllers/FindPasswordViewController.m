//
//  FindPasswordViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/5/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "FindPasswordViewController.h"
#import <TPKeyboardAvoidingTableView.h>
#import "LoginTableViewCell.h"
#import "RegisterCompleteViewController.h"
#import "AFNHttp.h"

#define kCellIdentifier @"LoginTableViewCell"

@interface FindPasswordViewController ()<UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, weak) TPKeyboardAvoidingTableView *m_tableView;
@property (nonatomic, weak) UIButton *m_captchaButton;
@property (nonatomic, copy) NSString *inputString;
@property (strong, nonatomic) NSMutableDictionary *params;
@end

@implementation FindPasswordViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    if (!_m_tableView) {
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[LoginTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.tableHeaderView = [self customHeaderView];
        tableView.tableFooterView = [self customFooterView];
        tableView.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
        tableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
        [self.view addSubview:tableView];
        _m_tableView = tableView;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Private_M
- (UIView*)customHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 54)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kCellLeftWidth, 0, kScreen_Width-kCellLeftWidth*2, 54)];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = @"找回密码功能将停用您当前的密码,请在验证身份后设置新密码。";
    [headerView addSubview:label];
    
    return headerView;
}

- (UIView*)customFooterView
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 200)];
    
    UIButton *captchaButton = [UIButton buttonWithStyle:StrapPrimaryStyle andTitle:@"获取验证码" andFrame:CGRectMake(20, 20, kScreen_Width-2*20, 40) target:self action:@selector(captchaButtonPress)];
    [footerView addSubview:captchaButton];
    _m_captchaButton = captchaButton;
    
    return footerView;
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
    
    [cell configTextFieldWithPlaceholder:@"输入登录账号(手机号/邮箱)" captchaWithBool:NO];
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

#pragma mark - 事件
- (void)captchaButtonPress {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (!_inputString) {
        kShowHUD(@"请输入手机号或者邮箱地址");
        return;
    }
    
    if (![CommonFuntion isMobileNumber:_inputString] && ![NSString isValidateEmail:_inputString]) {
        kShowHUD(@"请输入正确的手机号或者邮箱地址");
        return;
    }
    
    [_params setObject:_inputString forKey:@"passport"];
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_FindPassword_ResetPassword_WithParams:_params block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            RegisterCompleteViewController *registerCompleteController = [[RegisterCompleteViewController alloc] init];
            registerCompleteController.authCodeType = AuthCodeTypeFindPassword;
            registerCompleteController.title = @"重置密码";
            registerCompleteController.inputStr = _inputString;
            [self.navigationController pushViewController:registerCompleteController animated:YES];
        }
    }];
}
@end
