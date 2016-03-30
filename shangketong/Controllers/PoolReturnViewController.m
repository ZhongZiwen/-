//
//  PoolReturnViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PoolReturnViewController.h"
#import <TPKeyboardAvoidingTableView.h>
#import "PoolReturnTitleCell.h"
#import "PoolReturnPoolCell.h"
#import "PoolReturnReasoncell.h"
#import "PoolViewController.h"
#import "PoolGroup.h"
#import "LeadViewController.h"
#import "CustomerViewController.h"
#import "Reason.h"

#define kCellIdentifier_title   @"PoolReturnTitleCell"
#define kCellIdentifier_pool    @"PoolReturnPoolCell"
#define kCellIdentifier_reason  @"PoolReturnReasoncell"

@interface PoolReturnViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) TPKeyboardAvoidingTableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *params;
@end

@implementation PoolReturnViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"确定" target:self action:@selector(rightButtonPress)];
    [self.view addSubview:self.tableView];
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

#pragma mark - event response
- (void)rightButtonPress {
    if (!_groupId) {
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:nil message:@"请选择公海池" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alerView show];
        return;
    }
    [_params setObject:_groupId forKey:@"groupId"];
    [_params setObject:(_reason.reason ? : @"") forKey:@"reason"];
    
    [self.view beginLoading];
    [self sendRequest];
}

- (void)sendRequest {
    [[Net_APIManager sharedManager] request_Common_BackToPool_WithPath:(_poolReturnType ? kNetPath_Customer_BackToPool : kNetPath_Lead_BackToPool) params:_params block:^(id data, NSError *error) {
        if (data) {
            [self.view endLoading];
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[LeadViewController class]]) {
                    LeadViewController *leadController = (LeadViewController*)controller;
                    [leadController deleteAndRefreshDataSource];
                    [self.navigationController popToViewController:leadController animated:YES];
                    break;
                }
                if ([controller isKindOfClass:[CustomerViewController class]]) {
                    CustomerViewController *customerController = (CustomerViewController*)controller;
                    [customerController deleteAndRefreshDataSource];
                    [self.navigationController popToViewController:customerController animated:YES];
                    break;
                }
            }
        }
        else {
            if (error.code == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^(){
                    [self sendRequest];
                };
                [comRequest loginInBackground];
                return;
            }
            
            [self.view endLoading];
        }
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_reason.type isEqualToNumber:@0]) {
        return 2;
    }
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return [PoolReturnTitleCell cellHeightWithString:_name];
    }
    else if (indexPath.row == 1) {
        return [PoolReturnPoolCell cellHeight];
    }
    else {
        return [PoolReturnReasoncell cellHeight];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        PoolReturnTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_title forIndexPath:indexPath];
        [cell configWithString:_name];
        return cell;
    }
    else if (indexPath.row == 1) {
        PoolReturnPoolCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_pool forIndexPath:indexPath];
        [cell configWithString:_groupName];
        return cell;
    }
    
    PoolReturnReasoncell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_reason forIndexPath:indexPath];
    cell.textValueChangedBlock = ^(NSString *text) {
        _reason.reason = text;
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 选择线索池
    if (indexPath.row == 1) {
        PoolViewController *poolController = [[PoolViewController alloc] init];
        poolController.title = @"线索公海池";
        poolController.poolType = _poolReturnType ? PoolTypeCustomer : PoolTypeLead;
        @weakify(self);
        poolController.poolGroupNameBlock = ^(PoolGroup *group) {
            @strongify(self);
            self.groupId = [NSString stringWithFormat:@"%@", group.id];
            self.groupName = group.name;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        };
        [self.navigationController pushViewController:poolController animated:YES];
    }
}

#pragma mark - setters and getters
- (TPKeyboardAvoidingTableView*)tableView {
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[PoolReturnTitleCell class] forCellReuseIdentifier:kCellIdentifier_title];
        [_tableView registerClass:[PoolReturnPoolCell class] forCellReuseIdentifier:kCellIdentifier_pool];
        [_tableView registerClass:[PoolReturnReasoncell class] forCellReuseIdentifier:kCellIdentifier_reason];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
