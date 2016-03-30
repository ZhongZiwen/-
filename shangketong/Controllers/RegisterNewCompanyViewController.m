//
//  RegisterNewCompanyViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/12/4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "RegisterNewCompanyViewController.h"
#import "WebViewController.h"
#import <XLForm.h>
#import "NSUserDefaults_Cache.h"
#import "CommonModuleFuntion.h"
#import "Dynamic_Data.h"
#import "RootTabBarController.h"
#import "IM_FMDB_FILE.h"
#import "TTTAttributedLabel.h"

@interface RegisterNewCompanyViewController ()<TTTAttributedLabelDelegate>

@property (strong, nonatomic) UIButton *commitButton;
@property (assign, nonatomic) BOOL isAgree;

@property (strong, nonatomic) NSMutableDictionary *params;
@end

@implementation RegisterNewCompanyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    _isAgree = YES;
    
    XLFormDescriptor *form = [XLFormDescriptor formDescriptor];
    self.form = form;

    XLFormSectionDescriptor *section = [XLFormSectionDescriptor formSectionWithTitle:@"填写真实材料，让您的同事更容易找到您。"];
    [self.form addFormSection:section];
    
    XLFormRowDescriptor *row;
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"company" rowType:XLFormRowDescriptorTypeText title:@"公司名"];
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfigAtConfigure setObject:@"必填" forKey:@"textField.placeholder"];
    [section addFormRow:row];
    
    NSIndexPath *indexPath = [self.form indexPathOfFormRow:row];
    XLFormTextFieldCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"position" rowType:XLFormRowDescriptorTypeText title:@"职务"];
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfigAtConfigure setObject:@"必填" forKey:@"textField.placeholder"];
    [section addFormRow:row];
    
    indexPath = [self.form indexPathOfFormRow:row];
    cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"name" rowType:XLFormRowDescriptorTypeText title:@"姓名"];
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfigAtConfigure setObject:@"必填" forKey:@"textField.placeholder"];
    [section addFormRow:row];
    
    indexPath = [self.form indexPathOfFormRow:row];
    cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    if (_isEmailRegister) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"phone" rowType:XLFormRowDescriptorTypePhone title:@"手机"];
        [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
        [row.cellConfigAtConfigure setObject:@"必填" forKey:@"textField.placeholder"];
        [section addFormRow:row];
    }
    else {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"Email" rowType:XLFormRowDescriptorTypeEmail title:@"邮箱"];
        [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
        [row.cellConfigAtConfigure setObject:@"必填" forKey:@"textField.placeholder"];
        [section addFormRow:row];
    }
    
    // 第一次注册，显示输入密码
    if (_isFirstRegister) {
        section = [XLFormSectionDescriptor formSection];
        [form addFormSection:section];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"password" rowType:XLFormRowDescriptorTypePassword title:@"密码"];
        [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
        [row.cellConfigAtConfigure setObject:@"请输入6~16位密码" forKey:@"textField.placeholder"];
        [section addFormRow:row];
    }
    
    self.tableView.tableFooterView = [self customFooterView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 限制textField字数
- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.text.length > MAX_LIMIT_TEXTFIELD) {
        textField.text = [textField.text substringToIndex:MAX_LIMIT_TEXTFIELD];
    }
}

#pragma mark - event response
- (void)commitButtonPress {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    XLFormRowDescriptor *row;
    row = [self.form formRowWithTag:@"company"];
    if (!row.value) {
        kShowHUD(@"请填写公司名");
        return;
    }
    [_params setObject:row.value forKey:@"companyName"];
    
    row = [self.form formRowWithTag:@"position"];
    if (!row.value) {
        kShowHUD(@"请填写职务");
        return;
    }
    [_params setObject:row.value forKey:@"position"];
    
    row = [self.form formRowWithTag:@"name"];
    if (!row.value) {
        kShowHUD(@"请填写姓名");
        return;
    }
    [_params setObject:row.value forKey:@"userName"];
    
    if (_isEmailRegister) {
        row = [self.form formRowWithTag:@"phone"];
        if (!row.value || ![CommonFuntion isMobileNumber:row.value]) {
            kShowHUD(@"请填写正确的手机号");
            return;
        }
    }
    else {
        row = [self.form formRowWithTag:@"Email"];
        if (!row.value || ![NSString isValidateEmail:row.value]) {
            kShowHUD(@"请填写正确的邮箱地址");
            return;
        }
    }
    [_params setObject:row.value forKey:@"contact"];
    
    if (_isFirstRegister) {
        row = [self.form formRowWithTag:@"password"];
        if (!row.value) {
            kShowHUD(@"请输入密码");
            return;
        }
        if ([row.value length] < 6 || [row.value length] > 16) {
            kShowHUD(@"请输入6~16位密码");
            return;
        }
        [_params setObject:row.value forKey:@"password"];
    }
    
    [self.view beginLoading];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",kNetPath_Web_Server_Base, kNetPath_RegisterInit] params:_params success:^(id responseObj) {
        [self.view endLoading];
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            //清除IM缓存
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IMAddressServerTime"];
//            [IM_FMDB_FILE delete_IM_AllRecentContact];
//            [IM_FMDB_FILE delete_IM_ConversationList];
//            [IM_FMDB_FILE delete_IM_AllGroupMessageList];
//            [IM_FMDB_FILE delete_IM_AllAddressBook];
//            [IM_FMDB_FILE delete_IM_LastMessageList];
            [IM_FMDB_FILE setIM_FMDB_FILE_NULL:nil];
            [IM_FMDB_FILE removeIM_FMDB];
            
            if (_isFirstRegister) {
                // 缓存登录信息
                NSDictionary *accountInfo = [NSDictionary dictionaryWithObjectsAndKeys:_account, @"accountName", _params[@"password"], @"password", nil];
                [NSUserDefaults_Cache setUserAccountInfo:accountInfo];
            }

            ///缓存登录信息
            [NSUserDefaults_Cache setUserInfo:responseObj];

            appDelegateAccessor.moudle.userId =[responseObj safeObjectForKey:@"id"];
            appDelegateAccessor.moudle.userName = [responseObj safeObjectForKey:@"name"];
            appDelegateAccessor.moudle.userCompanyId = [NSString stringWithFormat:@"%@", [responseObj safeObjectForKey:@"id"]];
            appDelegateAccessor.moudle.IM_tokenString = [responseObj safeObjectForKey:@"token"];
            appDelegateAccessor.moudle.userFunctionCodes = [responseObj safeObjectForKey:@"functionCodes"];
            appDelegateAccessor.moudle.isOpen_cluePool = [[responseObj safeObjectForKey:@"cluePoolOpen"] integerValue];
            appDelegateAccessor.moudle.isOpen_customerPool = [[responseObj safeObjectForKey:@"customerPoolOpen"] integerValue];
            
            [NSUserDefaults_Cache setUserLoginStatus:true];
            [NSUserDefaults_Cache setUserLogOutStatus:0];
            
            // 缓存公司列表
            NSDictionary *companyDict = @{@"id" : responseObj[@"id"], @"name" : responseObj[@"companyName"]};
            NSMutableArray *tempCompanyArray = [NSMutableArray arrayWithArray:[NSUserDefaults_Cache getCurCompanyLogined]];
            [tempCompanyArray addObject:companyDict];
            [NSUserDefaults_Cache setCurCompanyLogined:tempCompanyArray];
            
            ///初始化办公/CRM模块设置
            [CommonModuleFuntion initOAandCRMModuleOption];
            ///设置动态相关缓存路径
            [Dynamic_Data setDynamicCacheFilePathByUserLoginInfo];
            
            ///预加载
            [self setupRootViewController];
            [appDelegateAccessor getAllReportAndApprove];
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

- (void)setupRootViewController {
    RootTabBarController *rootTabbarController = [[RootTabBarController alloc] init];
    appDelegateAccessor.window.rootViewController = rootTabbarController;
}

- (void)agreeButtonPress:(UIButton*)sender {
    if (_isAgree) {
        _isAgree = NO;
        _commitButton.enabled = NO;
        [sender setImage:[UIImage imageNamed:@"accessory_message_normal"] forState:UIControlStateNormal];
    }else {
        _isAgree = YES;
        _commitButton.enabled = YES;
        [sender setImage:[UIImage imageNamed:@"multi_graph_select"] forState:UIControlStateNormal];
    }
}

- (UIView*)customFooterView {
    UIView *view = [[UIView alloc] init];
    [view setWidth:kScreen_Width];
    [view setHeight:200];
    
    _commitButton = [UIButton buttonWithStyle:StrapPrimaryStyle andTitle:@"提交资料" andFrame:CGRectMake(20, 20, kScreen_Width-2*20, 45) target:self action:@selector(commitButtonPress)];
    [view addSubview:_commitButton];
    
    UIButton *agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [agreeButton setX:10];
    [agreeButton setY:CGRectGetMaxY(_commitButton.frame) + 20];
    [agreeButton setWidth:44.0f];
    [agreeButton setHeight:44.0f];
    [agreeButton setImage:[UIImage imageNamed:@"multi_graph_select"] forState:UIControlStateNormal];
    [agreeButton addTarget:self action:@selector(agreeButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:agreeButton];
    
    TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(agreeButton.frame), 0, kScreen_Width - CGRectGetMaxX(agreeButton.frame) - 15, 20)];
    [label setCenterY:CGRectGetMidY(agreeButton.frame)];
    label.delegate = self;
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor iOS7darkGrayColor];
    label.linkAttributes = kLinkAttributes;
    label.activeLinkAttributes = kLinkAttributesActive;
    label.text = @"已阅读并同意：商客通使用条款";
    NSRange range = [label.text rangeOfString:@"商客通使用条款"];
    [label addLinkToTransitInformation:nil withRange:range];
    [view addSubview:label];
    
    return view;
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components {
    NSString *urlStr = @"http://app.sunke.com/user/service.jsf";
    WebViewController *positionController = [WebViewController webViewControllerWithUrlStr:urlStr];
    [self.navigationController pushViewController:positionController animated:YES];
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
