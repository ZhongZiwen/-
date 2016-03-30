//
//  SettingPasswordController.m
//  shangketong
//
//  Created by sungoin-zbs on 16/3/8.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import "SettingPasswordController.h"
#import <TPKeyboardAvoidingTableView.h>
#import "LoginTableViewCell.h"
#import "NSUserDefaults_Cache.h"

#define kCellIdentifier @"LoginTableViewCell"

@interface SettingPasswordController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) TPKeyboardAvoidingTableView *tableView;
@property (copy, nonatomic) NSString *originallyPassword;
@property (copy, nonatomic) NSString *resetPassword;
@property (copy, nonatomic) NSString *confirePassword;
@end

@implementation SettingPasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"设置密码";

    [self.view addSubview:self.tableView];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelClicked)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confireClicked)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)cancelClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)confireClicked {
    [self.view endEditing:YES];
    
    NSString *tipStr = nil;
    if (!self.originallyPassword || self.originallyPassword.length <= 0){
        tipStr = @"请输入当前密码";
    }
    else if (!self.resetPassword || self.resetPassword.length <= 0){
        tipStr = @"请输入新密码";
    }
    else if (!self.confirePassword || self.confirePassword.length <= 0) {
        tipStr = @"请确认新密码";
    }
    else if (![self.resetPassword isEqualToString:self.confirePassword]){
        tipStr = @"两次输入的密码不一致";
    }
//    else if (self.resetPassword.length < 6){
//        tipStr = @"新密码不能少于6位";
//    }else if (self.resetPassword.length > 16){
//        tipStr = @"新密码不得长于16位";
//    }
    
    if (tipStr) {
        [NSObject showHudTipStr:tipStr];
        return;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // 网络请求
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [params setObject:self.originallyPassword forKey:@"oldPwd"];
    [params setObject:self.confirePassword forKey:@"newPwd"];
    
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_UpdatePassword_WithParams:params block:^(id data, NSError *error) {
        [self.view endLoading];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if (data) {
            
            NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:[NSUserDefaults_Cache getUserAccountInfo]];
            [tempDict setObject:self.confirePassword forKey:@"password"];
            [NSUserDefaults_Cache setUserAccountInfo:tempDict];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"修改密码成功，新密码已生效" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
            [alertView show];
        }
    }];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LoginTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LoginTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    [cell setTextSecure:YES];
    
    NSArray *array = @[@"请输入当前密码", @"请输入新密码", @"请确认密码"];
    [cell configTextFieldWithPlaceholder:array[indexPath.row] captchaWithBool:NO];
    @weakify(self);
    cell.textValueChangedBlock = ^(NSString *textValue) {
        @strongify(self);
        if (!indexPath.row) {
            self.originallyPassword = textValue;
        }else if (indexPath.row == 1) {
            self.resetPassword = textValue;
        }
        else {
            self.confirePassword = textValue;
        }
    };
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - setters and getters
- (TPKeyboardAvoidingTableView *)tableView {
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[LoginTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
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
