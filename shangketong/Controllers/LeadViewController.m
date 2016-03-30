//
//  LeadViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "LeadViewController.h"
#import "UIViewController+Expand.h"
#import "WebViewController.h"
#import "AddressBookActionSheet.h"

#import "MJRefresh.h"
#import <SBJson4Writer.h>

#import "PopoverView.h"
#import "PopoverItem.h"

#import "LeadTableViewCell.h"
#import "Lead.h"
#import "LeadNewViewController.h"
#import "LeadDetailViewController.h"
#import "SearchViewController.h"
#import "PoolViewController.h"

#define kCellIdentifier @"LeadTableViewCell"

@interface LeadViewController ()<SWTableViewCellDelegate>

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@end

@implementation LeadViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchItemPress)];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItemPress)];
    if ([appDelegateAccessor.moudle.userFunctionCodes rangeOfString:kCrm_leadCreate].location != NSNotFound) {
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
    [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_lead array:self.indexArray conditionId:@-1 sortId:@-1];
    
    // 缓存筛选
    [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_lead array:self.filterShowArray conditionId:@-2 sortId:@-2];
    [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_lead array:self.filterHiddenArray conditionId:@-3 sortId:@-3];
    
    // 保存当前索引和排序状态
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *curIndexData = [NSKeyedArchiver archivedDataWithRootObject:self.curIndex];
    NSData *curSortData = [NSKeyedArchiver archivedDataWithRootObject:self.curSort];
    [defaults setObject:curIndexData forKey:kIndexStatus_lead];
    [defaults setObject:curSortData forKey:kSortStatus_lead];
    [defaults synchronize];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[FMDBManagement sharedFMDBManager] creatCRMTableWithName:kTableName_lead];
    [[FMDBManagement sharedFMDBManager] creatCRMRecentlyTableWithName:kTableName_lead];
    
    [self configTitleViewWithTableName:kTableName_lead currentIndexKey:kIndexStatus_lead];
    [self configFilterWithTableName:kTableName_lead currentSortKey:kSortStatus_lead];
    
    @weakify(self);
    self.navigationItem.titleView = self.titleView;
    self.titleView.valueBlock = ^(NSInteger index) {
        @strongify(self);
        if (self.curIndex == self.indexArray[index]) {
            return;
        }
        
        self.curIndex = self.indexArray[index];
        
        if ([self.curIndex.name isEqualToString:@"最近浏览"]) {
            self.tableView.headerHidden = YES;
            self.tableView.footerHidden = YES;
            self.filterView.hidden = YES;
            
            _sourceArray = [[FMDBManagement sharedFMDBManager] getCRMRecentlyDataSourceWithName:kTableName_lead];
            
            [self.tableView setY:64.0f];
            [self.tableView setHeight:kScreen_Height - CGRectGetMinY(self.tableView.frame)];
            [self.tableView reloadData];
            [self.tableView configBlankPageWithTitle:@"暂无最近浏览记录" hasData:self.sourceArray.count hasError:NO reloadButtonBlock:nil];
        }
        else {
            self.tableView.headerHidden = NO;
            self.tableView.footerHidden = NO;
            self.filterView.hidden = NO;
            
            _sourceArray = [[FMDBManagement sharedFMDBManager] getCRMDataWithName:kTableName_lead conditionId:self.curIndex.id sortId:self.curSort.id];
            if (self.sourceArray.count) {
                [self.tableView.blankPageView removeFromSuperview];
            }
            
            [self.tableView setY:CGRectGetMaxY(self.filterView.frame)];
            [self.tableView setHeight:kScreen_Height - CGRectGetMinY(self.tableView.frame)];
            [self.tableView reloadData];
            
            [self.params setObject:self.curIndex.id forKey:@"retrievalId"];
            [self.view beginLoading];
            [self sendRequest];
        }
    };
    self.titleView.defalutTitleString = self.title;
    
    // 获取离线索引对应的缓存数据
    if (self.curIndex.id) {
        self.sourceArray = [[FMDBManagement sharedFMDBManager] getCRMDataWithName:kTableName_lead conditionId:self.curIndex.id sortId:self.curSort.id];
    }
    
    // 离线索引为nil，且非市场活动，获取最近浏览缓存数据
    if (self.curIndex && !self.curIndex.id) {
        self.sourceArray = [[FMDBManagement sharedFMDBManager] getCRMRecentlyDataSourceWithName:kTableName_lead];
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
    
    // 最近浏览
    if (self.curIndex && !self.curIndex.id) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sendRequestInit];
        });
    }
    else {
        if (_sourceArray && _sourceArray.count) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self sendRequestInit];
            });
        }
        else {
            [self.view beginLoading];
            [self sendRequestInit];
        }
    }
    
    [self.tableView addHeaderWithTarget:self action:@selector(sendRequestToRefresh)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)searchItemPress {
    SearchViewController *searchController = [[SearchViewController alloc] init];
    searchController.searchType = SearchViewControllerTypeLead;
    searchController.sourceArray = self.sourceArray;
//    searchController.searchRefreshBlock = ^{
//        [self sendRequestToRefresh];
//    };
    [self.navigationController pushViewController:searchController animated:YES];
}

- (void)addItemPress {
    
    NSArray *items = @[[PopoverItem initItemWithTitle:@"到线索公海池领取" image:nil target:self action:@selector(newFromSeaPool)],
                       [PopoverItem initItemWithTitle:@"名片扫描" image:nil target:self action:@selector(newFromScanning)],
                       [PopoverItem initItemWithTitle:@"手工输入" image:nil target:self action:@selector(newFromInputting)]];
    
    PopoverView *pop = [[PopoverView alloc] initWithImageItems:nil titleItems:items];
    [pop show];
}

- (void)newFromSeaPool {
    PoolViewController *poolController = [[PoolViewController alloc] init];
    poolController.title = @"线索公海池";;
    poolController.poolType = PoolTypeLead;
    [self.navigationController pushViewController:poolController animated:YES];
}

- (void)newFromScanning {
    LeadNewViewController *newController = [[LeadNewViewController alloc] init];
    newController.title = @"创建销售线索";
    newController.params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    newController.isScanning = YES;
    newController.refreshBlock = ^{
        [self sendRequestToRefresh];
    };
    [self.navigationController pushViewController:newController animated:YES];
}

- (void)newFromInputting {
    LeadNewViewController *newController = [[LeadNewViewController alloc] init];
    newController.title = @"创建销售线索";
    newController.params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    newController.refreshBlock = ^{
        [self sendRequestToRefresh];
    };
    [self.navigationController pushViewController:newController animated:YES];
}

#pragma mark - public method
- (void)sendRequestInit {
    [[Net_APIManager sharedManager] request_Lead_Init_WithBlock:^(id data, NSError *error) {
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
    [[Net_APIManager sharedManager] request_Lead_List_WithParams:self.params andBlock:^(id data, NSError *error) {
        [self.tableView headerEndRefreshing];
        [self.tableView footerEndRefreshing];
        if (data) {
            [self.view endLoading];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"saleLeads"]) {
                Lead *item = [NSObject objectOfClass:@"Lead" fromJSON:tempDict];
                [tempArray addObject:item];
            }
            // 刷新或第一次请求
            if ([self.params[@"pageNo"] isEqualToNumber:@1]) {
                self.sourceArray = tempArray;
                [self.tableView addFooterWithTarget:self action:@selector(sendRequestToReloadMore)];
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
            [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_lead array:self.sourceArray conditionId:self.curIndex.id sortId:self.curSort.id];
            [self.tableView configBlankPageWithTitle:@"暂无销售线索" hasData:self.sourceArray.count hasError:NO reloadButtonBlock:nil];
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

- (void)sendRequestToRefresh {
    [self.params setObject:@1 forKey:@"pageNo"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequest];
    });
}

- (void)sendRequestToReloadMore {
    [self.params setObject:@([self.params[@"pageNo"] integerValue] + 1) forKey:@"pageNo"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequest];
    });
}

- (void)deleteAndRefreshDataSource {
    
    // 刷新索引
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequestRefreshForIndex];
    });
    
    Lead *item = self.sourceArray[_selectedIndexPath.row];
    
    // 删除数据，刷新tableview
    [self.sourceArray removeObjectAtIndex:_selectedIndexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView configBlankPageWithTitle:@"暂无销售线索" hasData:self.sourceArray.count hasError:NO reloadButtonBlock:nil];
    
    if (self.curIndex && !self.curIndex.id) {
        [[FMDBManagement sharedFMDBManager] deleteCRMRecentyDataSourceWithName:kTableName_lead item:item];
    }
    else {
        // 重新缓存数据
        [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_lead array:self.sourceArray conditionId:self.curIndex.id sortId:self.curSort.id];
    }
}

// 筛选视图消失
- (void)hideFilterView {
    [self.filterView backgroundTap];
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LeadTableViewCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    
    Lead *item = self.sourceArray[indexPath.row];
    [cell configWithModel:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([appDelegateAccessor.moudle.userFunctionCodes rangeOfString:kCrm_leadCheck].location == NSNotFound) {
        kShowHUD(@"对不起，您暂时没有权限访问");
        return;
    }
    
    _selectedIndexPath = indexPath;
    
    Lead *leadItem = self.sourceArray[indexPath.row];
    
    // 缓存最近浏览
    [[FMDBManagement sharedFMDBManager] casheCRMRecentlyDataSourceWithName:kTableName_lead item:leadItem];
    
    LeadDetailViewController *leadDetailController = [[LeadDetailViewController alloc] init];
    leadDetailController.title = @"销售线索";
    leadDetailController.id = leadItem.id;
    [self.navigationController pushViewController:leadDetailController animated:YES];
}

#pragma mark SWTableViewCellDelegate
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    [cell hideUtilityButtonsAnimated:YES];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Lead *item = self.sourceArray[indexPath.row];
    
    if (!index && item.position) {
        NSString *urlStr = [NSString stringWithFormat:@"http://map.baidu.com/mobile/webapp/search/search/wd=%@&qt=s&searchFlag=bigBox&version=5&exptype=dep&c=undefined&src_from=webapp_all_bigbox/", item.position];
        WebViewController *positionController = [WebViewController webViewControllerWithUrlStr:urlStr];
        [self.navigationController pushViewController:positionController animated:YES];
    }
    
    if (index && (item.phone || item.mobile)) {
        AddressBookActionSheet *actionSheet = [[AddressBookActionSheet alloc] initWithCancelTitle:@"取消" andMobile:item.mobile andPhone:item.phone];
        actionSheet.phoneBlock = ^(NSString *tel) {
            [self takePhoneWithNumber:tel];
        };
        actionSheet.msgBlock = ^(NSString *tel) {
            [self sendMessageWithRecipients:@[tel]];
        };
        [actionSheet show];
    }
}

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
        [_tableView registerClass:[LeadTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
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
