//
//  LoginViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/5/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "LoginViewController.h"
#import <TPKeyboardAvoidingTableView.h>
#import "LoginTableViewCell.h"
#import "AFNHttp.h"
#import "RootTabBarController.h"
#import "CommonConstant.h"
#import "CommonFuntion.h"
#import <MBProgressHUD.h>
#import "ChangeCompanyViewController.h"
#import "FindPasswordViewController.h"
#import "NSUserDefaults_Cache.h"
#import "Dynamic_Data.h"
#import "CommonModuleFuntion.h"
#import "IM_FMDB_FILE.h"
#import "LLC_NSUserDefaults_Cache.h"

#define kCellIdentifier @"LoginTableViewCell"

@interface LoginViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) TPKeyboardAvoidingTableView *m_tableView;
@property (nonatomic, weak) UIButton *m_loginButton;
@property (nonatomic, copy) NSString *inputStrEmail;
@property (nonatomic, copy) NSString *inputStrPasswork;
@end

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.   09bb07
//    UIColor *customColor = [UIColor colorWithHexString:@"f8f8f8"];
    self.m_tableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    NSDictionary *account = [NSUserDefaults_Cache getUserAccountInfo];
    NSString *accountName = @"";
    NSString *psw = @"";
    if ([NSUserDefaults_Cache getUserLogOutStatus] != 1) {
        psw = [account safeObjectForKey:@"password"];
    }
    if (account) {
       accountName = [account safeObjectForKey:@"accountName"];
    }
    _inputStrEmail = accountName;
    _inputStrPasswork = psw;
    
    
    ///登陆异常时 提示用户
    if (self.errorDesc && self.errorDesc.length > 0) {
        kShowHUD(self.errorDesc,nil);
    }
    
    
    //5.54
//    NSString *email = @"chenlei2@sungoin.com";
//    NSString *psw = @"111111";
    
//    NSString *email = @"huyue@sungoin.com";
//    NSString *psw = @"111111";
    
    
//    NSString *email = @"1531925649@qq.com";
//    NSString *psw = @"111111";

//    NSString *email = @"516119693@qq.com";
//    NSString *psw = @"chenlei119";

//    NSString *email = @"zhongbisheng_hope@163.com";
//    NSString *psw = @"131400";
    
//    NSString *email = @"machao@sungoin.com";
//    NSString *psw = @"111111";
    
//    NSString *email = @"zhangbin@sungoin.com";
//    NSString *psw = @"111111";
    
//    _inputStrEmail = email;
//    _inputStrPasswork = psw;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView
{
    [super loadView];
    
    /*
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_bar_setting"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemPress)];
    self.navigationItem.rightBarButtonItem = rightButton;
     */
    
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

#pragma mark - Private_M
- (UIView*)customHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
    return headerView;
}

- (UIView*)customFooterView
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 200)];
    
    UIButton *loginButton = [UIButton buttonWithStyle:StrapPrimaryStyle andTitle:@"登 录" andFrame:CGRectMake(20, 20, kScreen_Width-2*20, 40) target:self action:@selector(loginButtonPress)];
//    [loginButton setTitleColor:COMMEN_LABEL_COROL forState:UIControlStateNormal];
    [footerView addSubview:loginButton];
    
    _m_loginButton = loginButton;
    
    return footerView;
}

- (void)initBottomView
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height-54, kScreen_Width, 54)];
    [self.view addSubview:bottomView];
    
    UIButton *findPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    findPasswordButton.frame = CGRectMake((kScreen_Width-64)/2.0, 5, 64, 44);
    findPasswordButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [findPasswordButton setTitleColor:COMMEN_LABEL_COROL forState:UIControlStateNormal];
    [findPasswordButton setTitle:@"忘记密码" forState:UIControlStateNormal];
    [findPasswordButton addTarget:self action:@selector(findPasswordButtonPress) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:findPasswordButton];
}



- (void)findPasswordButtonPress
{
    FindPasswordViewController *controller = [[FindPasswordViewController alloc] init];
    controller.title = @"重置密码";
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)rightBarButtonItemPress
{
    
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [LoginTableViewCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LoginTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    NSArray *dataSource = @[@"手机号/邮箱", @"密码"];
    
    [cell configTextFieldWithPlaceholder:dataSource[indexPath.row] captchaWithBool:NO];
    
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kCellLeftWidth];
    
    if (indexPath.row == 0) {
        [cell setTextSecure:NO];
        [cell setCellInfo:_inputStrEmail];
        cell.textValueChangedBlock = ^(NSString *valueString) {
            _inputStrEmail = valueString;
        };
    }else if(indexPath.row == 1){
        [cell setTextSecure:YES];
        [cell setCellInfo:_inputStrPasswork];
        cell.textValueChangedBlock = ^(NSString *valueString) {
            _inputStrPasswork = valueString;
        };
    }
    
    return cell;
}


#pragma mark - 登录事件

- (void)loginButtonPress
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    if ([self isValidInputStr]) {
        [self loginEvent:_inputStrEmail password:_inputStrPasswork];
    }
}

///输入是否有效
-(BOOL)isValidInputStr{

    if (_inputStrEmail == nil) {
        kShowHUD(@"账号不能为空")
        return  NO;
    }
    
    if ([[_inputStrEmail stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        kShowHUD(@"账号不能为空")
        return  NO;
    }
    
    /*
    if (![NSString isMobileNumber:_inputStrEmail] && ![NSString isValidateEmail:_inputStrEmail]) {
        kShowHUD(@"请输入正确的手机号或者邮箱地址")
        return  NO;
    }
    */
    
    if (_inputStrPasswork == nil) {
        kShowHUD(@"请输入密码")
        return  NO;
    }
    
    if ([[_inputStrPasswork stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        kShowHUD(@"请输入密码")
        return  NO;
    }
    
    return YES;
}

///登录请求
-(void)loginEvent:(NSString *)email password:(NSString *)psw{

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    
    [CommonFuntion showHUD:@"登录中" andView:self.view andHUD:hud];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:email forKey:@"accountName"];
    [params setObject:psw forKey:@"password"];
    
    // 发起请求kNetPath_Web_Server_Base ，kNetPath_Login
    //WEB_SERVER_IP  LOGIN_ACTION
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", WEB_SERVER_IP, LOGIN_ACTION] params:params success:^(id responseObj) {
        [hud hide:YES];
        //字典转模型
        NSLog(@"登录事件 responseObj:%@",responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_LOGIN_RESPONSE_0) {
            
            NSArray *tenants;
            if ([responseObj objectForKey:@"tenants"]) {
                tenants = [responseObj objectForKey:@"tenants"];
            }
 
            ///跳转到选择公司页面
            if (tenants && [tenants count] > 0) {
                ///缓存公司列表
                [NSUserDefaults_Cache setCurCompanyLogined:tenants];
                ///缓存帐号信息
                NSDictionary *accountInfo = [NSDictionary dictionaryWithObjectsAndKeys:email,@"accountName",psw,@"password", nil];
                [NSUserDefaults_Cache setUserAccountInfo:accountInfo];
                
                ChangeCompanyViewController *controller = [[ChangeCompanyViewController alloc] init];
                controller.title = @"登录";
                [self.navigationController pushViewController:controller animated:YES];
                
            }else{
                ///缓存帐号信息
                
                NSLog(@"旧用户id%@-------旧用户账户%@", appDelegateAccessor.moudle.userId, [NSUserDefaults_Cache getUserAccountInfo]);
                //清除IM缓存
                //获取旧用户信息
                NSDictionary *dict = [NSUserDefaults_Cache getUserAccountInfo];
                NSString *oldEmail = @"";
                if (dict) {
                    oldEmail = [dict objectForKey:@"accountName"];
                }
                //是不是同一个账号直接清除缓存
                if (![oldEmail isEqualToString:email]) {
                    // 删除IM通讯录请求时间
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IMAddressServerTime"];
                    [IM_FMDB_FILE setIM_FMDB_FILE_NULL:nil];
                    [IM_FMDB_FILE removeIM_FMDB];
                } else {
                    if ([responseObj objectForKey:@"id"]) {
                        if ([appDelegateAccessor.moudle.userId integerValue] != [[responseObj safeObjectForKey:@"id"] integerValue]) {
                            // 删除IM通讯录请求时间
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IMAddressServerTime"];
                            [IM_FMDB_FILE setIM_FMDB_FILE_NULL:nil];
                            [IM_FMDB_FILE removeIM_FMDB];
                            
                            //                            [IM_FMDB_FILE delete_IM_AllRecentContact];
                            //                            [IM_FMDB_FILE delete_IM_ConversationList];
                            //                            [IM_FMDB_FILE delete_IM_AllGroupMessageList];
                            //                            [IM_FMDB_FILE delete_IM_AllAddressBook];
                            //                            [IM_FMDB_FILE delete_IM_LastMessageList];
                        }
                    }
                }
                [appDelegateAccessor deleteWebSocket];
                [appDelegateAccessor _reconnect];

                NSDictionary *accountInfo = [NSDictionary dictionaryWithObjectsAndKeys:email,@"accountName",psw,@"password", nil];
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
                [self setupRootViewController];
                [appDelegateAccessor getAllReportAndApprove];
            }
            
            ///存储联络中心账号
            [LLC_NSUserDefaults_Cache  saveLLCAccountInfo:responseObj];
        }else {
            NSString *desc = @"";
            desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"登录失败";
            }
            [NSUserDefaults_Cache setUserLoginStatus:false];
            kShowHUD(desc,nil)
        }
        
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        [hud hide:YES];
        [NSUserDefaults_Cache setUserLoginStatus:false];
        kShowHUD(NET_ERROR)
        
    }];
}


- (void)setupRootViewController {
    RootTabBarController *rootTabbarController = [[RootTabBarController alloc] init];
    appDelegateAccessor.window.rootViewController = rootTabbarController;
}

@end
