//
//  RegisterompleteViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/5/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "RegisterCompleteViewController.h"
#import <TPKeyboardAvoidingTableView.h>
#import "LoginTableViewCell.h"
#import "AFNHttp.h"
#import "CommonFuntion.h"
#import "NameIdModel.h"
#import "ResetPasswordViewController.h"
#import "RegisterAccountListController.h"
#import "RegisterNewCompanyViewController.h"
#import "NSUserDefaults_Cache.h"
#import "CaptchaHelpViewController.h"

#define kCellIdentifier @"LoginTableViewCell"

@interface RegisterCompleteViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) TPKeyboardAvoidingTableView *m_tableView;
@property (nonatomic, weak) UIButton *m_completeButton;
@property (nonatomic, copy) NSString *captchaString;    // 验证码
@end

@implementation RegisterCompleteViewController

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
    
    [self initBottomView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private_M
- (UIView*)customHeaderView {
    CGFloat sizeHeight = 0;
    NSString *string = [NSString stringWithFormat:@"验证码已经发送到%@,请查收。", _inputStr];
    CGFloat stringHeight = [string getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(kScreen_Width-2*kCellLeftWidth, MAXFLOAT)];
    if (stringHeight > 34) {
        sizeHeight = stringHeight;
    }else{
        sizeHeight = 34;
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20+sizeHeight)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kCellLeftWidth, 20, kScreen_Width-2*kCellLeftWidth, sizeHeight)];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.text = string;
    [headerView addSubview:label];
    
    return headerView;
}

- (UIView*)customFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 200)];
    
    UIButton *completeButton = [UIButton buttonWithStyle:StrapPrimaryStyle andTitle:@"提 交" andFrame:CGRectMake(20, 20, kScreen_Width-2*20, 45) target:self action:@selector(completeButtonPress)];
    [footerView addSubview:completeButton];
    _m_completeButton = completeButton;
    
    return footerView;
}

- (void)initBottomView {
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height-54, kScreen_Width, 54)];
    [self.view addSubview:bottomView];
    
    UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    helpButton.frame = CGRectMake((kScreen_Width-220)/2.0, 5, 220, 44);
    helpButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [helpButton setTitleColor:[UIColor colorWithHexString:@"0x8899a6"] forState:UIControlStateNormal];
    [helpButton setTitle:@"长时间未收到验证码,请点击此处" forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(helpButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:helpButton];
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
    
    [cell configTextFieldWithPlaceholder:@"输入验证码" captchaWithBool:YES];
    cell.sendCaptchaBlock = ^{
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
            [tempParams setObject:_inputStr forKey:@"accountName"];
            [[Net_APIManager sharedManager] request_SendCaptcha_WithParams:tempParams block:^(id data, NSError *error) {
                if (data && ![data integerValue]) {
                    kShowHUD(@"验证码已发送，请查收！")
                }else {
                    kShowHUD(@"获取验证码失败，请重试！");
                }
            }];
        });
    };
    cell.textValueChangedBlock = ^(NSString *valueString) {
        _captchaString = valueString;
    };
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kCellLeftWidth];
    
    return cell;
}

// 帮助
- (void)helpButtonPress {
    CaptchaHelpViewController *helpController = [[CaptchaHelpViewController alloc] init];
    helpController.title = @"未收到验证短信/邮件";
    [self.navigationController pushViewController:helpController animated:YES];
}

// 提交
- (void)completeButtonPress {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    [self.view endEditing:YES];
    
    if (!_captchaString || [CommonFuntion isEmptyString:_captchaString]) {
        kShowHUD(@"请输入验证码");
        return;
    }
    
    // 注册
    if (self.authCodeType == AuthCodeTypeRegister) {
        NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
        [tempParams setObject:_inputStr forKey:@"accountName"];
        [tempParams setObject:_captchaString forKey:@"captcha"];
        [self.view beginLoading];
        [[Net_APIManager sharedManager] request_CheckAccountName_WithParams:tempParams block:^(id data, NSError *error) {
            [self.view endLoading];
            if (data && ![data[@"result"] integerValue]) {
                RegisterNewCompanyViewController *newCompanyController = [[RegisterNewCompanyViewController alloc] init];
                newCompanyController.title = @"初始设置";
                newCompanyController.account = _inputStr;
                newCompanyController.isFirstRegister = YES;
                if (_isEmailRegister) {
                    newCompanyController.isEmailRegister = YES;
                }
                [self.navigationController pushViewController:newCompanyController animated:YES];
            }
            // 账号已存在，显示公司列表
            else if (data && [data[@"result"] integerValue] == 2) {
                
                [NSUserDefaults_Cache setCurCompanyLogined:data[@"companyList"]];

                NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
                for (NSDictionary *tempDict in data[@"companyList"]) {
                    NameIdModel *item = [NSObject objectOfClass:@"NameIdModel" fromJSON:tempDict];
                    [tempArray addObject:item];
                }
                RegisterAccountListController *accountListController = [[RegisterAccountListController alloc] init];
                accountListController.title = @"账号已存在";
                accountListController.sourceArray = tempArray;
                accountListController.accountName = _inputStr;
                if (_isEmailRegister) {
                    accountListController.isEmailRegister = YES;
                }
                [self.navigationController pushViewController:accountListController animated:YES];
            }
        }];
        return;
    }
    
    // 重置密码
    NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [tempParams setObject:_inputStr forKey:@"passport"];
    [tempParams setObject:_captchaString forKey:@"verificationCode"];
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_FindPassword_VerificationCode_WithParams:tempParams block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            ResetPasswordViewController *resetPasswordController = [[ResetPasswordViewController alloc] init];
            resetPasswordController.title = @"重置密码";
            [self.navigationController pushViewController:resetPasswordController animated:YES];
        }
    }];
}


#pragma mark - UIScrollView
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

@end
