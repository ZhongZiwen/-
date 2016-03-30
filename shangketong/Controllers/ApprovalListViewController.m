//
//  ApprovalListViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ApprovalListViewController.h"
#import "CustomTitleView.h"
#import "ApprovalListCell.h"
#import "CRM_Approval.h"
#import "ApprovalDetailViewController.h"
#import "MJRefresh.h"
#import "Approval.h"

#define kCellIdentifier @"ApprovalListCell"

@interface ApprovalListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) CustomTitleView *titleView;
@property (assign, nonatomic) NSInteger navIndex;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableDictionary *params;
@end

@implementation ApprovalListViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    self.automaticallyAdjustsScrollViewInsets = NO;

    @weakify(self);
    self.navigationItem.titleView = self.titleView;
    _titleView.valueBlock = ^(NSInteger index) {
        @strongify(self);
        self.navIndex = index + 1;
    };
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.refreshBlock) {
        self.refreshBlock();
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _navIndex = 1;
    _params = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [_params setObject:@(_navIndex) forKey:@"status"];
    [_params setObject:@1 forKey:@"pageNo"];
    [_params setObject:@20 forKey:@"pageSize"];
    
    [self.view beginLoading];
    [self sendRequest];
    
    [_tableView addHeaderWithTarget:self action:@selector(sendRequestForRefresh)];
    [_tableView addFooterWithTarget:self action:@selector(sendRequestForReloadMore)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendRequest {
    [[Net_APIManager sharedManager] request_Common_Approval_List_WithPath:_requestPath params:_params block:^(id data, NSError *error) {
        [_tableView headerEndRefreshing];
        [_tableView footerEndRefreshing];
        if (data) {
            [self.view endLoading];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray *tempData = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"approvals"]) {
                CRM_Approval *item = [NSObject objectOfClass:@"CRM_Approval" fromJSON:tempDict];
                [tempArray addObject:item];
                [tempData addObject:[Approval initWithDictionary:tempDict]];
            }
            if ([_params[@"pageNo"] isEqualToNumber:@1]) {
                _sourceArray = tempArray;
                _dataArray = tempData;
            }
            else {
                [_sourceArray addObjectsFromArray:tempArray];
                [_dataArray addObjectsFromArray:tempData];
            }
            
            if (tempArray.count == 20) {
                _tableView.footerHidden = NO;
            }
            else {
                _tableView.footerHidden = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
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
        
        [_tableView configBlankPageWithTitle:@"暂无审批" hasData:_sourceArray.count hasError:error != nil reloadButtonBlock:nil];
    }];
}

- (void)sendRequestForRefresh {
    [_params setObject:@1 forKey:@"pageNo"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequest];
    });
}

- (void)sendRequestForReloadMore {
    [_params setObject:@([_params[@"pageNo"] integerValue] + 1) forKey:@"pageNo"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequest];
    });
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ApprovalListCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ApprovalListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    CRM_Approval *item = _sourceArray[indexPath.row];
    [cell configWithObj:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Approval *item = _dataArray[indexPath.row];
    ApprovalDetailViewController *detailController = [[ApprovalDetailViewController alloc] init];
    detailController.approval = item;
    [self.navigationController pushViewController:detailController animated:YES];
}

#pragma mark - setters and getters
- (void)setNavIndex:(NSInteger)navIndex {
    if (_navIndex == navIndex) return;
    
    _navIndex = navIndex;
    [_params setObject:@(_navIndex) forKey:@"status"];
    [self sendRequest];
}

- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setY:64];
        [_tableView setWidth:kScreen_Width];
        [_tableView setHeight:kScreen_Height - CGRectGetMinY(_tableView.frame)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[ApprovalListCell class] forCellReuseIdentifier:kCellIdentifier];
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (CustomTitleView*)titleView {
    if (!_titleView) {
        _titleView = [[CustomTitleView alloc] init];
        _titleView.cellType = CellTypeOnlyName;
        _titleView.superViewController = self;
        _titleView.sourceArray = [NSMutableArray arrayWithArray:@[@"审批中", @"中止", @"通过"]];
        _titleView.index = 0;
    }
    return _titleView;
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
