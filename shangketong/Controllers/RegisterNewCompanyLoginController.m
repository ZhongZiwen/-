//
//  RegisterNewCompanyLoginController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/12/4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "RegisterNewCompanyLoginController.h"
#import "LoginTableViewCell.h"
#import "RegisterNewCompanyViewController.h"
#import "FindPasswordViewController.h"
#import "NSUserDefaults_Cache.h"

#define kCellIdentifier @"LoginTableViewCell"

@interface RegisterNewCompanyLoginController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *params;
@property (copy, nonatomic) NSString *password;
@end

@implementation RegisterNewCompanyLoginController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    [self.view addSubview:self.tableView];
    
    [self initBottomView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [_params setObject:_accountName forKey:@"accountName"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)findPasswordButtonPress {
    FindPasswordViewController *controller = [[FindPasswordViewController alloc] init];
    controller.title = @"重置密码";
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)loginButtonPress {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self.view endEditing:YES];
    
    [_params setObject:_password forKey:@"password"];
    
    [self.view beginLoading];
    // 发起请求
    [[Net_APIManager sharedManager] request_CheckAccountPassword_WithParams:_params block:^(id data, NSError *error) {
        [self.view endLoading];
        if (![data integerValue]) {
            // 缓存帐号信息
            NSDictionary *accountInfo = [NSDictionary dictionaryWithObjectsAndKeys:_accountName,@"accountName",_password,@"password", nil];
            [NSUserDefaults_Cache setUserAccountInfo:accountInfo];
            
            RegisterNewCompanyViewController *newCompanyController = [[RegisterNewCompanyViewController alloc] init];
            newCompanyController.title = @"创建公司";
            newCompanyController.account = _accountName;
            if (_isEmailRegister) {
                newCompanyController.isEmailRegister = YES;
            }
            [self.navigationController pushViewController:newCompanyController animated:YES];
        }else {
            UIAlertView *alserView = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"登录失败，请重试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alserView show];
        }
    }];
}

#pragma mark - private method
- (UIView*)customHeaderView {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20 + 20 + 10)];
    
    UILabel *label = [[UILabel alloc] init];
    [label setX:kCellLeftWidth];
    [label setY:20];
    [label setWidth:kScreen_Width - CGRectGetMinX(label.frame) * 2];
    [label setHeight:20];
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor iOS7darkGrayColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 0;
    label.text = @"登录之后即可开始创建新公司";
    [headerView addSubview:label];
    
    return headerView;
}

- (UIView*)customFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 200)];
    
    UIButton *loginButton = [UIButton buttonWithStyle:StrapPrimaryStyle andTitle:@"登 录" andFrame:CGRectMake(20, 20, kScreen_Width-2*20, 40) target:self action:@selector(loginButtonPress)];
    
    [footerView addSubview:loginButton];
    
    return footerView;
}

- (void)initBottomView {
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height-54, kScreen_Width, 54)];
    [self.view addSubview:bottomView];
    
    UIButton *findPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    findPasswordButton.frame = CGRectMake((kScreen_Width-64)/2.0, 5, 64, 44);
    findPasswordButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [findPasswordButton setTitleColor:LIGHT_BLUE_COLOR forState:UIControlStateNormal];
    [findPasswordButton setTitle:@"忘记密码" forState:UIControlStateNormal];
    [findPasswordButton addTarget:self action:@selector(findPasswordButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:findPasswordButton];
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LoginTableViewCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LoginTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    [cell configTextFieldWithPlaceholder:@"输入密码" captchaWithBool:NO];
    [cell setTextSecure:YES];
    cell.textValueChangedBlock = ^(NSString *str) {
        _password = str;
    };
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:15.0f];
    return cell;
}


#pragma mark - UIScrollView
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[LoginTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        _tableView.tableHeaderView = [self customHeaderView];
        _tableView.tableFooterView = [self customFooterView];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
        _tableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    }
    return _tableView;
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
