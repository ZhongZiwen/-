//
//  OpportunityListController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "OpportunityListController.h"
#import "OpportunityTableViewCell.h"
#import "SaleChance.h"
#import "OpportunityDetailController.h"
#import "CRM_OpportunityNewViewController.h"
#import "MJRefresh.h"

#define kCellIdentifier @"ContactTableViewCell"

@interface OpportunityListController ()<UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableDictionary *params;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

- (void)sendRequest;
@end

@implementation OpportunityListController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightButtonPress)];
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
    
    _params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    if (_fromType == OpportunityListFromTypeCustomer) {
        [_params setObject:_customerId forKey:@"customerId"];
    }else {
        [_params setObject:_contactId forKey:@"linkManId"];
    }
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

#pragma mark - event response
- (void)rightButtonPress {
    @weakify(self);
    CRM_OpportunityNewViewController *newController = [[CRM_OpportunityNewViewController alloc] init];
    newController.title = @"创建销售机会";
    newController.customerId = _customerId;
    newController.requestInitPath = _requestInitPath;
    newController.requestSavePath = _requestSavePath;
    newController.refreshBlock = ^{
        @strongify(self);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sendRequest];
        });
    };
    [self.navigationController pushViewController:newController animated:YES];
}

#pragma mark - public method
- (void)deleteAndRefreshDataSource {
    // 删除数据，刷新tableview
    [_sourceArray removeObjectAtIndex:_selectedIndexPath.row];
    [_tableView deleteRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [_tableView configBlankPageWithTitle:@"暂无销售机会" hasData:self.sourceArray.count hasError:NO reloadButtonBlock:nil];
}

- (void)sendRequest {
    [[Net_APIManager sharedManager] request_Common_OpportunityList_WithParams:_params path:_requestListPath block:^(id data, NSError *error) {
        [_tableView headerEndRefreshing];
        [_tableView footerEndRefreshing];
        if (data) {
            [self.view endLoading];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"saleChances"]) {
                SaleChance *item = [NSObject objectOfClass:@"SaleChance" fromJSON:tempDict];
                [tempArray addObject:item];
            }
            if ([_params[@"pageNo"] isEqualToNumber:@1]) {
                _sourceArray = tempArray;
            }
            else {
                [_sourceArray addObjectsFromArray:tempArray];
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
            
            [_tableView configBlankPageWithTitle:@"暂无销售机会" hasData:_sourceArray.count hasError:NO reloadButtonBlock:nil];
        }
        else if (error.code == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [self sendRequest];
            };
            [comRequest loginInBackground];
        }
        else {
            [self.view endLoading];
        }
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
    return [OpportunityTableViewCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OpportunityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    
    SaleChance *item = _sourceArray[indexPath.row];
    [cell configWithModel:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _selectedIndexPath = indexPath;
    
    SaleChance *item = _sourceArray[indexPath.row];
    OpportunityDetailController *detailController = [[OpportunityDetailController alloc] init];
    detailController.title = @"销售机会";
    detailController.id = item.id;
    [self.navigationController pushViewController:detailController animated:YES];
}

#pragma mark - SWTableViewCellDelegate
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    [cell hideUtilityButtonsAnimated:YES];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    SaleChance *saleChance = _sourceArray[indexPath.row];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [params setObject:saleChance.id forKey:@"id"];
    [params setObject:@(![saleChance.focus integerValue]) forKey:@"type"];
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_SaleChance_FocusOrCancel_WithParams:params block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            // 修改源数据
            saleChance.focus = @(![saleChance.focus integerValue]);
            
            //  刷洗对应行
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }else {
            NSLog(@"关注或取消关注失败!");
        }
    }];
}

#pragma mark - setters  and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setY:64.0f];
        [_tableView setWidth:kScreen_Width];
        [_tableView setHeight:kScreen_Height - 64.0f];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[OpportunityTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        _tableView.tableFooterView = [[UIView alloc] init];
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
