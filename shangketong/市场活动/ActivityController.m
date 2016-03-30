//
//  ActivityController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ActivityController.h"
#import "ActivityModel.h"
#import "ActivityCell.h"
#import "ActivityDetailViewController.h"
#import "ActivityNewViewController.h"
#import "SearchViewController.h"
#import <SBJson4Writer.h>

#import "UIViewController+CustomTitleView.h"

#import "MJRefresh.h"

#define kCellIdentifier @"ActivityCell"

@interface ActivityController ()<SWTableViewCellDelegate>

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@end

@implementation ActivityController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchItemPress)];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItemPress)];
    // 权限控制，能够新建市场活动
    if ([appDelegateAccessor.moudle.userFunctionCodes rangeOfString:kCrm_activityCreate].location != NSNotFound) {
        self.navigationItem.rightBarButtonItems = @[addItem, searchItem];
    }
    else {
        self.navigationItem.rightBarButtonItem = searchItem;
    }
    
    [self.view addSubview:self.tableView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 缓存索引
    [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_activity array:self.indexArray conditionId:@-1 sortId:@-1];
    
    // 缓存筛选
    [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_activity array:self.filterShowArray conditionId:@-2 sortId:@-2];
    [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_activity array:self.filterHiddenArray conditionId:@-3 sortId:@-3];
    
    // 保存当前索引和排序状态
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *curIndexData = [NSKeyedArchiver archivedDataWithRootObject:self.curIndex];
    NSData *curSortData = [NSKeyedArchiver archivedDataWithRootObject:self.curSort];
    [defaults setObject:curIndexData forKey:kIndexStatus_activity];
    [defaults setObject:curSortData forKey:kSortStatus_activity];
    [defaults synchronize];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // 建表
    [[FMDBManagement sharedFMDBManager] creatCRMTableWithName:kTableName_activity];
    
    [self configTitleViewWithTableName:kTableName_activity currentIndexKey:kIndexStatus_activity];
    [self configFilterWithTableName:kTableName_activity currentSortKey:kSortStatus_activity];
    
    @weakify(self);
    self.navigationItem.titleView = self.titleView;
    self.titleView.valueBlock = ^(NSInteger index) {
        @strongify(self);
        if (self.curIndex == self.indexArray[index]) {
            return;
        }
        
        self.curIndex = self.indexArray[index];
        
        self.sourceArray = [[FMDBManagement sharedFMDBManager] getCRMDataWithName:kTableName_activity conditionId:self.curIndex.id sortId:self.curSort.id];
        if (self.sourceArray.count) {
            [self.tableView.blankPageView removeFromSuperview];
        }
        [self.tableView reloadData];
        
        [self.params setObject:@1 forKey:@"pageNo"];
        [self.params setObject:self.curIndex.id forKey:@"retrievalId"];
        [self.view beginLoading];
        [self sendRequest];
    };
    self.titleView.defalutTitleString = self.title;
    
    // 获取离线索引对应的缓存数据
    if (self.curIndex.id) {
        self.sourceArray = [[FMDBManagement sharedFMDBManager] getCRMDataWithName:kTableName_activity conditionId:self.curIndex.id sortId:self.curSort.id];
    }
    
    _params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [_params setObject:@1 forKey:@"pageNo"];
    [_params setObject:@20 forKey:@"pageSize"];
    // 排序
    [_params setObject:self.curSort.id forKey:@"order"];
    // 已选中的筛选
    if (self.jsonArray && self.jsonArray.count) {
        SBJson4Writer *jsonParser = [[SBJson4Writer alloc] init];
        NSString *jsonString = [jsonParser stringWithObject:self.jsonArray];
        [_params setObject:jsonString forKey:@"filters"];
    }
    
    // 有缓存时，后台初始化
    if (self.sourceArray && self.sourceArray.count) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sendRequestInit];
        });
    }
    else {
        [self.view beginLoading];
        [self sendRequestInit];
    }
    
    [self.tableView addHeaderWithTarget:self action:@selector(sendRequestRefresh)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - public method
- (void)sendRequestInit {
    // 初始化
    [[Net_APIManager sharedManager] request_Activity_Init_WithBlock:^(id data, NSError *error) {
        if (data) {
            [self sendRequestForIndex];
            [self sendRequestForFilter];
        }else {
            if (error.code == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^(){
                    [self sendRequestInit];
                };
                [comRequest loginInBackground];
                return;
            }
            
            [self.view endLoading];
        }
    }];
}

- (void)sendRequest {
    [[Net_APIManager sharedManager] request_Activity_List_WithParams:self.params andBlock:^(id data, NSError *error) {
        [self.tableView headerEndRefreshing];
        [self.tableView footerEndRefreshing];
        if (data) {
            [self.view endLoading];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"marketDirectorys"]) {
                ActivityModel *item = [NSObject objectOfClass:@"ActivityModel" fromJSON:tempDict];
                item.pinyin = [NSString transform:item.name];
                [tempArray addObject:item];
            }
            // 刷新或第一次请求
            if ([self.params[@"pageNo"] isEqualToNumber:@1]) {
                self.sourceArray = tempArray;
                [self.tableView addFooterWithTarget:self action:@selector(sendRequestReloadMore)];
            }
            // 加载更多
            else {
                [self.sourceArray addObjectsFromArray:tempArray];
            }
            
            // 不足pageSize = 20，则隐藏上拉加载更多
            if (tempArray.count == 20) {
                self.tableView.footerHidden = NO;
            }
            else {
                self.tableView.footerHidden = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
            // 缓存列表数据
            [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_activity array:self.sourceArray conditionId:self.curIndex.id sortId:self.curSort.id];
            [self.tableView configBlankPageWithTitle:@"暂无市场活动" hasData:self.sourceArray.count hasError:NO reloadButtonBlock:nil];
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

- (void)deleteAndRefreshDataSource {
    // 刷新索引
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequestRefreshForIndex];
    });
    
    // 删除数据，刷新tableview
    [self.sourceArray removeObjectAtIndex:_selectedIndexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView configBlankPageWithTitle:@"暂无市场活动" hasData:self.sourceArray.count hasError:NO reloadButtonBlock:nil];
    // 缓存数据
    [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_activity array:self.sourceArray conditionId:self.curIndex.id sortId:self.curSort.id];
}

// 刷新
- (void)sendRequestRefresh {
    [self.params setObject:@1 forKey:@"pageNo"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequest];
    });
}

// 加载更多
- (void)sendRequestReloadMore {
    [self.params setObject:@([self.params[@"pageNo"] integerValue] + 1) forKey:@"pageNo"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequest];
    });
}

// 筛选视图消失
- (void)hideFilterView {
    [self.filterView backgroundTap];
}

#pragma mark - event response
- (void)searchItemPress {
    SearchViewController *searchController = [[SearchViewController alloc] init];
    searchController.searchType = SearchViewControllerTypeActivity;
    searchController.sourceArray = self.sourceArray;
//    searchController.searchRefreshBlock = ^{
//        [self sendRequestRefresh];
//    };
    [self.navigationController pushViewController:searchController animated:YES];
}

- (void)addItemPress {
    ActivityNewViewController *newActivity = [[ActivityNewViewController alloc] init];
    newActivity.title = @"创建市场活动";
    newActivity.refreshBlock = ^{
        [self sendRequestRefresh];
    };
    [self.navigationController pushViewController:newActivity animated:YES];
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ActivityCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    
    ActivityModel *item = self.sourceArray[indexPath.row];
    [cell configWithItem:item isSwipeable:YES];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if ([appDelegateAccessor.moudle.userFunctionCodes rangeOfString:kCrm_activityCheck].location == NSNotFound) {
        kShowHUD(@"对不起，您暂时没有权限访问");
        return;
    }
    
    _selectedIndexPath = indexPath;
    
    ActivityModel *item = self.sourceArray[indexPath.row];
    
    ActivityDetailViewController *detailController = [[ActivityDetailViewController alloc] init];
    detailController.title = @"市场活动";
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
    ActivityModel *item = self.sourceArray[indexPath.row];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [params setObject:item.id forKey:@"id"];
    [params setObject:@(![item.focus integerValue]) forKey:@"type"];
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_Activity_FocusOrCancel_WithParams:params andBlock:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            // 修改源数据
            item.focus = @(![item.focus integerValue]);
            
            //  刷洗对应行
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }else {
            NSLog(@"关注或取消关注失败!");
        }
    }];
}

#pragma mark - setters and getters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setY:64];
        [_tableView setWidth:kScreen_Width];
        [_tableView setHeight:kScreen_Height - CGRectGetMinY(_tableView.frame)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
        _tableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
        [_tableView registerClass:[ActivityCell class] forCellReuseIdentifier:kCellIdentifier];
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
