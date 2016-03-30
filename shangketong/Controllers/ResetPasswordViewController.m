//
//  ResetPasswordViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-7-30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import <TPKeyboardAvoidingTableView.h>
#import "LoginTableViewCell.h"
#import "LoginViewController.h"
#import "AFNHttp.h"
#import <MBProgressHUD.h>
#import "CommonFuntion.h"

#define kCellIdentifier @"LoginTableViewCell"

@interface ResetPasswordViewController ()<UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, weak) TPKeyboardAvoidingTableView *m_tableView;
@property (nonatomic, weak) UIButton *m_completeButton;
@property (nonatomic, copy) NSString *inputStrNewPassword1;
@property (nonatomic, copy) NSString *inputStrNewPassword2;

@end

@implementation ResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

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

#pragma mark - Private_M
- (UIView*)customHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 54)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kCellLeftWidth, 0, 200, 54)];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = @"请设置6位以上的新密码";
    [headerView addSubview:label];
    
    return headerView;
}

- (UIView*)customFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 200)];
    
    UIButton *completeButton = [UIButton buttonWithStyle:StrapPrimaryStyle andTitle:@"保存" andFrame:CGRectMake(20, 20, kScreen_Width-2*20, 40) target:self action:@selector(completeButtonPress)];
    [footerView addSubview:completeButton];
    _m_completeButton = completeButton;
    
    return footerView;
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LoginTableViewCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LoginTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    NSArray *dataSource = @[@"输入新密码", @"再次输入密码"];
    
    [cell configTextFieldWithPlaceholder:dataSource[indexPath.row] captchaWithBool:NO];
    
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kCellLeftWidth];
    
    if (indexPath.row == 0) {
        [cell setTextSecure:YES];
        [cell setCellInfo:_inputStrNewPassword1];
        cell.textValueChangedBlock = ^(NSString *valueString) {
            _inputStrNewPassword1 = valueString;
        };
    }else if(indexPath.row == 1){
        [cell setTextSecure:YES];
        [cell setCellInfo:_inputStrNewPassword2];
        cell.textValueChangedBlock = ^(NSString *valueString) {
            _inputStrNewPassword2 = valueString;
        };
    }
    
    return cell;
}

#pragma mark - UIScrollView
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

#pragma mark - 事件
// 保存
- (void)completeButtonPress {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    if ([self isValidInputStr]) {
        [self sendCmdResetPassword];
    }
}

///输入是否有效
-(BOOL)isValidInputStr {
    
    
    if (_inputStrNewPassword1 == nil || [CommonFuntion isEmptyString:_inputStrNewPassword1] ) {
        kShowHUD(@"请输入新密码")
        return  NO;
    }
    
    if ( _inputStrNewPassword1.length < 6) {
        kShowHUD(@"密码不能小于6位")
        return  NO;
    }
    
    if (_inputStrNewPassword2 == nil || [CommonFuntion isEmptyString:_inputStrNewPassword2]) {
        kShowHUD(@"请再次输入新密码")
        return  NO;
    }
    
    if ( _inputStrNewPassword2.length < 6) {
        kShowHUD(@"密码不能小于6位")
        return  NO;
    }
    
    if (![_inputStrNewPassword1 isEqualToString:_inputStrNewPassword2]) {
        kShowHUD(@"两次密码不一致")
        return  NO;
    }

    
    return YES;
}

// 设置新密码
-(void)sendCmdResetPassword {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [params setObject:_inputStrNewPassword1 forKey:@"newPassword"];
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_FindPassword_SetNewPassword_WithParams:params block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            for (UIViewController *loginview in self.navigationController.viewControllers) {
                if ([loginview isKindOfClass:[LoginViewController class]]) {
                    [self.navigationController popToViewController:loginview animated:YES];
                }
            }
        }
    }];
}
@end
