//
//  RegisterAccountLoginController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/12/4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "RegisterAccountLoginController.h"
#import "NameIdModel.h"
#import "LoginTableViewCell.h"
#import "FindPasswordViewController.h"
#import "RootTabBarController.h"
#import "NSUserDefaults_Cache.h"
#import "Dynamic_Data.h"
#import "CommonModuleFuntion.h"
#import "LLC_NSUserDefaults_Cache.h"

#define kCellIdentifier @"LoginTableViewCell"

@interface RegisterAccountLoginController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *params;
@property (copy, nonatomic) NSString *password;
@end

@implementation RegisterAccountLoginController

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
    [_params setObject:_item.id forKey:@"tenantId"];
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
    
    [_params setObject:_password forKey:@"password"];
    
    [self.view beginLoading];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",kNetPath_Web_Server_Base, kNetPath_Login] params:_params success:^(id responseObj) {
        [self.view endLoading];
        //字典转模型
        NSLog(@"登录事件 responseObj:%@",responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            ///缓存帐号信息
            NSLog(@"旧用户名称%@", appDelegateAccessor.moudle.userId);
            NSDictionary *accountInfo = [NSDictionary dictionaryWithObjectsAndKeys:_accountName,@"accountName",_password,@"password", nil];
            [NSUserDefaults_Cache setUserAccountInfo:accountInfo];
            ///缓存登录信息
            [NSUserDefaults_Cache setUserInfo:responseObj];
            appDelegateAccessor.moudle.userId =[responseObj safeObjectForKey:@"id"];
            appDelegateAccessor.moudle.userName = [responseObj safeObjectForKey:@"name"];
            appDelegateAccessor.moudle.userCompanyId = [responseObj safeObjectForKey:@"companyId"];
            appDelegateAccessor.moudle.IM_tokenString = [responseObj safeObjectForKey:@"token"];
            appDelegateAccessor.moudle.userFunctionCodes = [responseObj safeObjectForKey:@"functionCodes"];
            appDelegateAccessor.moudle.isOpen_cluePool = [[responseObj safeObjectForKey:@"cluePoolOpen"] integerValue];
            appDelegateAccessor.moudle.isOpen_customerPool = [[responseObj safeObjectForKey:@"customerPoolOpen"] integerValue];
            
            [NSUserDefaults_Cache setUserLoginStatus:true];
            [NSUserDefaults_Cache setUserLogOutStatus:0];
            ///初始化办公/CRM模块设置
            [CommonModuleFuntion initOAandCRMModuleOption];
            ///设置动态相关缓存路径
            [Dynamic_Data setDynamicCacheFilePathByUserLoginInfo];
            
            ///预加载
            ///存储联络中心账号
            [LLC_NSUserDefaults_Cache  saveLLCAccountInfo:responseObj];
            
            [self setupRootViewController];
        }else{
            NSString *desc = @"";
            desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"登录失败";
            }
            [NSUserDefaults_Cache setUserLoginStatus:false];
            kShowHUD(desc,nil)
        }
        
    } failure:^(NSError *error) {
        [self.view endLoading];
        NSLog(@"error:%@",error);
        [NSUserDefaults_Cache setUserLoginStatus:false];
        kShowHUD(NET_ERROR)
        
    }];
}

#pragma mark - private method
- (UIView*)customHeaderView {
    NSString *string = [NSString stringWithFormat:@"输入密码，进入%@", _item.name];
    CGFloat stringHeight = [string getHeightWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(kScreen_Width - 2 * kCellLeftWidth, CGFLOAT_MAX)];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20 + stringHeight + 10)];
    
    UILabel *label = [[UILabel alloc] init];
    [label setX:kCellLeftWidth];
    [label setY:20];
    [label setWidth:kScreen_Width - CGRectGetMinX(label.frame) * 2];
    [label setHeight:stringHeight];
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor iOS7darkGrayColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 0;
    label.text = string;
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

- (void)setupRootViewController {
    RootTabBarController *rootTabbarController = [[RootTabBarController alloc] init];
    appDelegateAccessor.window.rootViewController = rootTabbarController;
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
