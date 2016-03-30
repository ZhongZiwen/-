//
//  OpportunityViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "OpportunityViewController.h"
#import "MJRefresh.h"
#import <SBJson4Writer.h>

#import "TypeActionSheet.h"
#import "TypeModel.h"

#import "Stage.h"
#import "SaleChance.h"
#import "OpportunityIndicatorCell.h"
#import "OpportunityTableViewCell.h"
#import "OpportunityNewViewController.h"
#import "OpportunityDetailController.h"
#import "SearchViewController.h"

#define kCellIdentifier_indicator @"OpportunityIndicatorCell"
#define kCellIdentifier @"OpportunityTableViewCell"
#define kTag_sectionView    4345
#define kTag_arrowImageView 3469

@interface OpportunityViewController ()<SWTableViewCellDelegate>

@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property (assign, nonatomic) NSInteger sectionIndex;   // 保存点击的段

@end

@implementation OpportunityViewController

static int(^maxIntBlock)(int, int) = ^(int a, int b){return a>b?a:b;};

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchItemPress)];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItemPress)];
    if ([appDelegateAccessor.moudle.userFunctionCodes rangeOfString:kCrm_chanceCreate].location != NSNotFound) {
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
    [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_opportunity array:self.indexArray conditionId:@-1 sortId:@-1];
    
    // 缓存筛选
    [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_opportunity array:self.filterShowArray conditionId:@-2 sortId:@-2];
    [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_opportunity array:self.filterHiddenArray conditionId:@-3 sortId:@-3];
    
    // 保存当前索引和排序状态
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *curIndexData = [NSKeyedArchiver archivedDataWithRootObject:self.curIndex];
    NSData *curSortData = [NSKeyedArchiver archivedDataWithRootObject:self.curSort];
    [defaults setObject:curIndexData forKey:kIndexStatus_opportunity];
    [defaults setObject:curSortData forKey:kSortStatus_opportunity];
    [defaults synchronize];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _sectionIndex = -1;
    
    [[FMDBManagement sharedFMDBManager] creatCRMTableWithName:kTableName_opportunity];
    [[FMDBManagement sharedFMDBManager] creatCRMRecentlyTableWithName:kTableName_opportunity];
    
    [self configTitleViewWithTableName:kTableName_opportunity currentIndexKey:kIndexStatus_opportunity];
    [self configFilterWithTableName:kTableName_opportunity currentSortKey:kSortStatus_opportunity];
    
    @weakify(self);
    self.navigationItem.titleView = self.titleView;
    self.titleView.valueBlock = ^(NSInteger index) {
        @strongify(self);
        if (self.curIndex == self.indexArray[index]) {
            return;
        }
        
        self.curIndex = self.indexArray[index];
        
        if ([self.curIndex.name isEqualToString:@"最近浏览"]) {
            
            self.sourceArray = [[FMDBManagement sharedFMDBManager] getCRMRecentlyDataSourceWithName:kTableName_opportunity];
            self.tableView.headerHidden = YES;
            self.tableView.footerHidden = YES;
            self.filterView.hidden = YES;
            self.bottomView.hidden = YES;
            [self.tableView setY:64.0f];
            [self.tableView setHeight:kScreen_Height - CGRectGetMinY(self.tableView.frame)];
            [self.tableView reloadData];
            [self.tableView configBlankPageWithTitle:@"暂无最近浏览记录" hasData:self.sourceArray.count hasError:NO reloadButtonBlock:nil];
            return;
        }
        
        
        self.sourceArray = [[FMDBManagement sharedFMDBManager] getCRMDataWithName:kTableName_opportunity conditionId:self.curIndex.id sortId:self.curSort.id];
        if (self.sourceArray.count) {
            [self.tableView.blankPageView removeFromSuperview];
        }
        
        self.tableView.headerHidden = NO;
        self.filterView.hidden = NO;
        self.bottomView.hidden = NO;
        [self.tableView setY:CGRectGetMaxY(self.filterView.frame)];
        if ([self.curSort.name isEqualToString:@"销售阶段"]) {
            self.tableView.footerHidden = YES;
            [self.tableView setHeight:kScreen_Height - CGRectGetMinY(self.tableView.frame)];
        }
        else {
            self.tableView.footerHidden = NO;
            [self.tableView setHeight:kScreen_Height - CGRectGetMinY(self.tableView.frame) - CGRectGetHeight(self.bottomView.bounds)];
        }
        [self.tableView reloadData];
        
        [self.params setObject:self.curIndex.id forKey:@"retrievalId"];
        [self.view beginLoading];
        if (self.isStageList) {
            [self sendRequestForOpportunityStageList];
        }else {
            [self sendRequestForOpportunityList];
        }
    };
    self.titleView.defalutTitleString = self.title;
    
    // 获取离线索引对应的缓存数据
    if (self.curIndex.id) {
        self.sourceArray = [[FMDBManagement sharedFMDBManager] getCRMDataWithName:kTableName_opportunity conditionId:self.curIndex.id sortId:self.curSort.id];
    }
    
    // 离线索引为nil，且非市场活动，获取最近浏览缓存数据
    if (self.curIndex && !self.curIndex.id) {
        self.sourceArray = [[FMDBManagement sharedFMDBManager] getCRMRecentlyDataSourceWithName:kTableName_opportunity];
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
    
    // 判断销售阶段
    if ([self.curSort.id integerValue] == 1) {
        _isStageList = YES;
    }else {
        _isStageList = NO;
        [self.view addSubview:self.bottomView];
    }
    
    if (self.curIndex && !self.curIndex.id) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sendRequestInit];
        });
    }
    else {
        [self.view beginLoading];
        [self sendRequestInit];
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
    searchController.searchType = SearchViewControllerTypeOpportunity;
    if (_isStageList) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (Stage *stage in self.sourceArray) {
            [tempArray addObjectsFromArray:stage.opportunityArray];
        }
        searchController.sourceArray = tempArray;
    }
    else {
        searchController.sourceArray = self.sourceArray;
    }
//    searchController.searchRefreshBlock = ^{
//        [self sendRequestToRefresh];
//    };
    [self.navigationController pushViewController:searchController animated:YES];
}

- (void)addItemPress {
    OpportunityNewViewController *newController = [[OpportunityNewViewController alloc] init];
    newController.title = @"创建销售机会";
    newController.refreshBlock = ^{
        [self sendRequestToRefresh];
    };
    [self.navigationController pushViewController:newController animated:YES];
}

- (void)headerViewTap:(UITapGestureRecognizer*)sender {
    
    __weak __block typeof(self) weak_self = self;
    UIView *headerView = sender.view;
    UIImageView *imageView = (UIImageView*)[headerView viewWithTag:kTag_arrowImageView + headerView.tag - kTag_sectionView];
    
    // 如果点击的是展开section，则关闭该section，然后sectionIndex赋值为-1
    if (_sectionIndex == headerView.tag - kTag_sectionView) {
        [self animateIndicatorView:imageView show:NO complete:^{
            [weak_self closeSectionWithStageIndex:_sectionIndex];
            weak_self.sectionIndex = -1;
        }];
        return;
    }
    
    // 如果是第一次点击或者点击的section不是展开section，先打开新的section，再关闭前展开section
    // 展开新的IndicatorView
    [self animateIndicatorView:imageView show:YES complete:^{
        [weak_self openSectionWithStageIndex:sender.view.tag - kTag_sectionView];
    }];
    
    // 关闭前IndicatorView
    headerView = [self.tableView viewWithTag:kTag_sectionView + _sectionIndex];
    imageView = (UIImageView*)[headerView viewWithTag:kTag_arrowImageView + _sectionIndex];
    [self animateIndicatorView:imageView show:NO complete:^{
        [weak_self closeSectionWithStageIndex:_sectionIndex];
        // 标记展开的sectionIndex
        weak_self.sectionIndex = sender.view.tag - kTag_sectionView;
    }];
}

#pragma mark - public method
- (void)sendRequestInit {
    // 初始化
    [[Net_APIManager sharedManager] request_Common_Init_WithPath:kNetPath_SaleChance_Init block:^(id data, NSError *error) {
        if (data) {
            [self sendRequestForIndex];
            [self sendRequestForFilter];
        }else {
            if (error.code == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^{
                    [self sendRequestInit];
                };
                [comRequest loginInBackground];
                return;
            }
            
            [self.view endLoading];
        }
    }];
}

- (void)sendRequestForOpportunityStageList {
    [self.params removeObjectForKey:@"order"];
    [[Net_APIManager sharedManager] request_SaleChance_StageList_WithParams:self.params andBlock:^(id data, NSError *error) {
        [self.tableView headerEndRefreshing];
        if (data) {
            [self.view endLoading];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"stages"]) {
                Stage *stage = [NSObject objectOfClass:@"Stage" fromJSON:tempDict];
                [tempArray addObject:stage];
            }
            self.tableView.footerHidden = YES;
            self.sourceArray = tempArray;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
            [self.tableView configBlankPageWithTitle:@"暂无销售阶段数据" hasData:self.sourceArray.count hasError:NO reloadButtonBlock:nil];

            // 缓存列表数据
            [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_opportunity array:self.sourceArray conditionId:self.curIndex.id sortId:self.curSort.id];
        }
        else {
            if (error.code == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^{
                    [self sendRequestForOpportunityStageList];
                };
                [comRequest loginInBackground];
                return;
            }
            
            [self.view endLoading];
        }
    }];
}

- (void)sendRequestForOpportunityList {
    [[Net_APIManager sharedManager] request_SaleChance_List_WithParams:self.params andBlock:^(id data, NSError *error) {
        [self.tableView headerEndRefreshing];
        [self.tableView footerEndRefreshing];
        if (data) {
            [self.view endLoading];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"saleChances"]) {
                SaleChance *saleChance = [NSObject objectOfClass:@"SaleChance" fromJSON:tempDict];
                [tempArray addObject:saleChance];
            }
            
            _bottomLabel.text = [NSString stringWithFormat:@"销售金额合计(元)：%@", [self.numberFormatter stringForObjectValue:data[@"sumSalesAmount"]]];
            
            if ([self.params[@"pageNo"] isEqualToNumber:@1]) {
                self.sourceArray = tempArray;
                [self.tableView addFooterWithTarget:self action:@selector(sendRequestToReloadMore)];
            }
            else {
                [self.sourceArray addObjectsFromArray:tempArray];
            }
            
            if (tempArray.count == 20) {
                self.tableView.footerHidden = NO;
            }
            else {
                self.tableView.footerHidden = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.tableView configBlankPageWithTitle:@"暂无销售机会" hasData:self.sourceArray.count hasError:NO reloadButtonBlock:nil];
            });

            // 缓存列表数据
            [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_opportunity array:self.sourceArray conditionId:self.curIndex.id sortId:self.curSort.id];
        }
        else {
            if (error.code == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^{
                    [self sendRequestForOpportunityList];
                };
                [comRequest loginInBackground];
                return;
            }
            
            [self.view endLoading];
        }
    }];
}

- (void)sendRequestToRefresh {
    if (_isStageList) {
        _sectionIndex = -1;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sendRequestForOpportunityStageList];
        });
    }
    else {
        [self.params setObject:@1 forKey:@"pageNo"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sendRequestForOpportunityList];
        });
    }
}

- (void)sendRequestToReloadMore {
    [self.params setObject:@([self.params[@"pageNo"] integerValue] + 1) forKey:@"pageNo"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequestForOpportunityList];
    });
}

- (void)deleteAndRefreshDataSource {
    
    // 刷新索引
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequestRefreshForIndex];
    });
    
    SaleChance *item;

    // 删除数据
    if (_isStageList) {
        Stage *group = self.sourceArray[_selectedIndexPath.section];
        [group.opportunityArray removeObjectAtIndex:_selectedIndexPath.row];
    }
    else {
        item = self.sourceArray[_selectedIndexPath.row];
        [self.sourceArray removeObjectAtIndex:_selectedIndexPath.row];
    }
    [self.tableView deleteRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView configBlankPageWithTitle:@"暂无销售机会" hasData:self.sourceArray.count hasError:NO reloadButtonBlock:nil];
    
    if (!self.curIndex.id) {
        [[FMDBManagement sharedFMDBManager] deleteCRMRecentyDataSourceWithName:kTableName_opportunity item:item];
    }
    else {
        // 重新缓存数据
        [[FMDBManagement sharedFMDBManager] casheCRMDataSourceWithName:kTableName_opportunity array:self.sourceArray conditionId:self.curIndex.id sortId:self.curSort.id];
    }
}

- (void)hideFilterView {
    [self.filterView backgroundTap];
}

- (void)openSectionWithStageIndex:(NSInteger)index {
    Stage *stage = self.sourceArray[index];
    stage.isShow = YES;
    
    // 刷新指定的section
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
}

- (void)closeSectionWithStageIndex:(NSInteger)index {
    if (index < 0) return;
    
    Stage *stage = self.sourceArray[index];
    stage.isShow = NO;
    
    // 刷新指定的section
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)animateIndicatorView:(UIImageView*)indicatorView show:(BOOL)show complete:(void(^)())complete {
    if (show) { // 显示
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
        [UIView animateWithDuration:0.2 animations:^{
            [indicatorView setTransform:transform];
        }];
        complete();
    }else{
        CGAffineTransform transform = CGAffineTransformMakeRotation(0);
        [UIView animateWithDuration:0.2 animations:^{
            [indicatorView setTransform:transform];
        } completion:^(BOOL finished) {
            complete();
        }];
    }
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_isStageList) {
        return self.sourceArray.count;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (!_isStageList) { // 非销售阶段
        return self.sourceArray.count;
    }
    
    Stage *stage = self.sourceArray[section];
    if (stage.isShow) {
        if ([stage.opportunityArray count]) {
            return stage.opportunityArray.count;
        }else {
            return 1;
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_isStageList) {
        return 64.0f;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 非销售阶段
    if (!_isStageList) {
        return [OpportunityTableViewCell cellHeight];
    }
    
    Stage *stage = self.sourceArray[indexPath.section];
    if ([stage.opportunityArray count]) {
        return [OpportunityTableViewCell cellHeight];
    }else {
        return [OpportunityIndicatorCell cellHeight];
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (!_isStageList) {
        return nil;
    }
    
    Stage *stage = self.sourceArray[section];
    
    UIView *headerView = ({
        UIView *view = [[UIView alloc] init];
        [view setWidth:kScreen_Width];
        [view setHeight:64.0];
        [view addLineUp:NO andDown:YES];
        view.backgroundColor = [UIColor whiteColor];
        view.tag = kTag_sectionView + section;
        view;
    });
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewTap:)];
    [headerView addGestureRecognizer:tap];
    
    UILabel *title = [[UILabel alloc] init];
    [title setX:15];
    [title setWidth:200];
    [title setHeight:64];
    title.font = [UIFont systemFontOfSize:16];
    title.textColor = kNavigationTintColor;
    title.textAlignment = NSTextAlignmentLeft;
    title.text = [NSString stringWithFormat:@"%@(%@%%)", stage.name, stage.percent];
    [headerView addSubview:title];
    
    UIImage *arrowImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@", stage.isShow ? @"opportunity_stage_title_arrow_up" : @"opportunity_stage_title_arrow_down"]];
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:arrowImage];
    [arrowImageView setX:kScreen_Width - arrowImage.size.width - 15];
    [arrowImageView setWidth:arrowImage.size.width];
    [arrowImageView setHeight:arrowImage.size.height];
    [arrowImageView setCenterY:CGRectGetHeight(headerView.bounds) / 2];
    arrowImageView.tag = kTag_arrowImageView + section;
    [headerView addSubview:arrowImageView];
    
    UILabel *detail = [[UILabel alloc] init];
    detail.font = [UIFont systemFontOfSize:14];
    detail.textColor = [UIColor lightGrayColor];
    detail.textAlignment = NSTextAlignmentRight;
    detail.text = [NSString stringWithFormat:@"%@元", [self.numberFormatter stringFromNumber:stage.money]];
    [detail sizeToFit];
    [detail setX:CGRectGetMinX(arrowImageView.frame) - CGRectGetWidth(detail.bounds) - 10];
    [detail setCenterY:CGRectGetHeight(headerView.bounds) / 2];
    [headerView addSubview:detail];
    
    return headerView;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 非销售阶段
    if (!_isStageList) {
        SaleChance *saleChance = self.sourceArray[indexPath.row];
        OpportunityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
        cell.delegate = self;
        
        [cell configWithModel:saleChance];
        
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:15.0];
        return cell;
    }
    
    Stage *stage = self.sourceArray[indexPath.section];
    if ([stage.opportunityArray count]) {
        OpportunityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
        cell.delegate = self;

        SaleChance *saleChance = stage.opportunityArray[indexPath.row];
        [cell configWithModel:saleChance];
        
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:15.0];
        return cell;
    }
    
    OpportunityIndicatorCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_indicator forIndexPath:indexPath];
    cell.valueBlock = ^(id data, NSError *error) {
        if (data) {
            for (NSDictionary *tempDict in data[@"saleChances"]) {
                SaleChance *saleChance = [NSObject objectOfClass:@"SaleChance" fromJSON:tempDict];
                [stage.opportunityArray addObject:saleChance];
            }
            
            // 刷新指定的section
            NSIndexSet *set = [NSIndexSet indexSetWithIndex:indexPath.section];
            [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
        }
    };
    [cell beginLoadingWithNavIndex:self.curIndex stageId:stage.id];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([appDelegateAccessor.moudle.userFunctionCodes rangeOfString:kCrm_chanceCheck].location == NSNotFound) {
        kShowHUD(@"对不起，您暂时没有权限访问");
        return;
    }
    
    _selectedIndexPath = indexPath;
    
    SaleChance *item;
    if (_isStageList) {
        Stage *stage = self.sourceArray[indexPath.section];
        if (!stage.opportunityArray.count) {
            return;
        }
        item = stage.opportunityArray[indexPath.row];
    }else {
        item = self.sourceArray[indexPath.row];
    }
    
    // 缓存最近浏览
    [[FMDBManagement sharedFMDBManager] casheCRMRecentlyDataSourceWithName:kTableName_opportunity item:item];
    
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
    
    SaleChance *saleChance;
    if (_isStageList) {
        Stage *stage = self.sourceArray[indexPath.section];
        saleChance = stage.opportunityArray[indexPath.row];
    }else {
        saleChance = self.sourceArray[indexPath.row];
    }
    
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
        [_tableView registerClass:[OpportunityIndicatorCell class] forCellReuseIdentifier:kCellIdentifier_indicator];
        [_tableView registerClass:[OpportunityTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    }
    return _tableView;
}

- (UIView*)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        [_bottomView setY:kScreen_Height - 44.0f];
        [_bottomView setWidth:kScreen_Width];
        [_bottomView setHeight:44.0f];
        _bottomView.backgroundColor = kView_BG_Color;
        [_bottomView addLineUp:YES andDown:NO];
        
        [_bottomView addSubview:self.bottomLabel];
    }
    return _bottomView;
}

- (UILabel*)bottomLabel {
    if (!_bottomLabel) {
        _bottomLabel = [[UILabel alloc] init];
        [_bottomLabel setX:15];
        [_bottomLabel setWidth:CGRectGetWidth(_bottomView.bounds) - 30];
        [_bottomLabel setHeight:CGRectGetHeight(_bottomView.bounds)];
        _bottomLabel.font = [UIFont systemFontOfSize:14];
        _bottomLabel.textColor = [UIColor iOS7lightBlueColor];
        _bottomLabel.textAlignment = NSTextAlignmentLeft;
        _bottomLabel.text = @"销售金额合计(元)：";
    }
    return _bottomLabel;
}

- (NSNumberFormatter*)numberFormatter {
    if (!_numberFormatter) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
    }
    return _numberFormatter;
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
