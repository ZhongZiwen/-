//
//  ApprovalViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ApprovalViewController.h"
#import "AFNHttp.h"
#import <MBProgressHUD.h>
#import "UIViewController+NavDropMenu.h"
#import "Approval.h"
#import "ApprovalCell.h"
#import "ApprovalDetailViewController.h"
#import "ApprovalApplyViewController.h"

#import "SKTFilter.h"
#import "SKTFilterValue.h"
#import "SKTCondition.h"
#import "SKTDropDownMenu.h"
#import "SKTSelectMemberController.h"
#import "SKTSelectMemberPreController.h"


#import "MJRefresh.h"
#import "CommonNoDataView.h"
#import "CommonFuntion.h"
#import "CustomTitleView.h"

#import "AddressBook.h"
#import "EditAddressViewController.h"
#import "ExportAddress.h"
#import "ExportAddressViewController.h"
#import "SKTConditionView.h"



///每页条数
#define PageSize 20
#define kCellIdentifier @"ApprovalCell"
#define ApprovalListBaseName @"ApprovalList"
#define ApprovalFilterBaseName @"ApprovalFilter"
#define ApprovalSubmitContactBaseName @"ApprovalSubmitContactList"

#define workType @"fType" //类型
#define workStatus @"fStatus" //状态
#define workChracter @"fPyaCs" //批阅，抄送
#define workUserId @"fUserId" //提交人

@interface ApprovalViewController ()<UITableViewDataSource, UITableViewDelegate, SKTDropDownMenuDataSource, SKTDropDownMenuDelegate>{
    NSInteger pageNo;//页数下标
    ///无数据时提示语  根据请求条件填充
    NSString *titleForNoData;
    BOOL isSelect; //是否进行过筛选
}

@property (nonatomic, assign) NSInteger curIndex;
@property (nonatomic, assign) NSInteger fOrder;     // 1:最新修改  2:最新创建

@property (nonatomic, strong) SKTDropDownMenu *dropDownMenu;
@property (nonatomic, strong) NSArray *smartArray;
@property (nonatomic, strong) NSArray *otherArray;
@property (nonatomic, strong) NSMutableArray *filterSourceArray;
@property (nonatomic, strong) NSMutableArray *conditionArray;

@property (nonatomic, strong) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableDictionary *params;

@property (nonatomic, strong) UITableView *tableView;

///无数据时的view
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property (nonatomic, strong) NSMutableArray *searchHistroyArray; //筛选记录
@property (nonatomic, strong) NSMutableArray *searchRightIdsArray; //右边列表id
@property (nonatomic, strong) NSMutableDictionary *searchDict;//存数右边被选中的id
@property (nonatomic, strong) UIScrollView *conditionScrollView;    //筛选条件视图


- (void)sendRequestForList;
- (void)sendRequestForFilter;
- (void)addAndDeleteConditionWithItem:(SKTCondition*)conditionItem complete:(void(^)())complete;
@end

@implementation ApprovalViewController

- (void)loadView {
    [super loadView];
    isSelect = NO;
    self.view.backgroundColor = kView_BG_Color;
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItemPress)];
    self.navigationItem.rightBarButtonItem = addItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    titleForNoData = @"暂无审批";
    pageNo = 1;
    _searchDict = [NSMutableDictionary dictionaryWithCapacity:0];
    _searchHistroyArray = [NSMutableArray arrayWithCapacity:0];
    _searchRightIdsArray = [NSMutableArray arrayWithCapacity:0];
    
    if (!appDelegateAccessor.moudle.isShowAll) {
        _smartArray = @[@"我提交的审批", @"提交给我的审批", @"全部审批"];
    } else {
        _smartArray = @[@"我提交的审批", @"提交给我的审批"];
    }
    
    _otherArray = @[@"最新创建", @"最新修改"];
    _filterSourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    _conditionArray = [[NSMutableArray alloc] initWithCapacity:0];
    _curIndex = -1;
    _fOrder = 1;    // 默认加载最新修改
    _sourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self.view addSubview:self.dropDownMenu];
    [self.view addSubview:self.tableView];
    
    [self setupRefresh];
    
    self.curIndex = 1;  // 加载提交给我的审批
    
    NSNumber *numIndex = [NSNumber numberWithInteger:_curIndex];
    NSArray *cachaAarray = [[FMDBManagement sharedFMDBManager] resultDataWithName:ApprovalFilterBaseName conditionId:numIndex sortId:numIndex];
    if (cachaAarray && cachaAarray.count > 0) {
        [self customConScrollView];
        [self configScrollCustomView];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGroupList) name:@"ApprovalRefreshGroupList" object:nil];
}

- (void)refreshGroupList {
    pageNo = 1;
    [self sendRequestForList];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCurIndex:(NSInteger)curIndex {
    if (_curIndex == curIndex)
        return;
    isSelect = NO;
    _curIndex = curIndex;
    
    // 清空筛选条件
    [_conditionArray removeAllObjects];
    pageNo = 1;
    if (_sourceArray) {
        [_sourceArray removeAllObjects];
    }
    [self.tableView reloadData];
    
    [_searchHistroyArray removeAllObjects];
    NSNumber *numIndex = [NSNumber numberWithInteger:_curIndex];
    NSArray *array = [[FMDBManagement sharedFMDBManager] resultDataWithName:ApprovalFilterBaseName conditionId:numIndex sortId:numIndex];
    [_searchHistroyArray addObjectsFromArray:array];
//    [_conditionArray addObjectsFromArray:array];
    _dropDownMenu.conditionArray = _conditionArray;
    [self customConScrollView];
    [self configScrollCustomView];
    [self sendRequestForList];
    [self sendRequestForFilter];
}

- (void)setFOrder:(NSInteger)fOrder {
    if (_fOrder == fOrder)
        return;
    
    _fOrder = fOrder;
    pageNo = 1;
    [self sendRequestForList];
}

#pragma mark - event respoonse
// 添加审批
- (void)addItemPress {
    __weak typeof(self) weak_self = self;
    ApprovalApplyViewController *applyController = [[ApprovalApplyViewController alloc] init];
    applyController.title = @"申请类型";
    applyController.applyType = ApplyFlowTypeApprovalType;
    applyController.refreshBlock = ^{
        [weak_self sendRequestForList];
    };
    [self.navigationController pushViewController:applyController animated:YES];
}

#pragma mark - private method
- (void)sendRequestForList {
    
    [self clearViewNoData];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:[NSNumber numberWithInteger:pageNo] forKey:@"pageNo"];
    [params setObject:[NSNumber numberWithInt:PageSize] forKey:@"pageSize"];
    [params setObject:@(_fOrder) forKey:@"fOrder"];
    
    if (_searchHistroyArray && _searchHistroyArray.count > 0) {
        _conditionArray = _searchHistroyArray;
    }
    for (SKTCondition *condition in _conditionArray) {
        // 多选时，如果已经有该key，则组装value值
        if ([[params allKeys] containsObject:condition.m_itemId]) {
            [params setObject:[NSString stringWithFormat:@"%@,%@", params[condition.m_itemId], condition.m_id] forKey:condition.m_itemId];
        }else {
            [params setObject:[NSString stringWithFormat:@"%@", condition.m_id] forKey:condition.m_itemId];
        }
    }

    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSArray *pathArray = @[kNetPath_Approve_Mine, kNetPath_Approve_ToMe, kNetPath_Approve_All];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, pathArray[_curIndex]] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@"审批 = %@", responseObj);
        NSDictionary *resultdic = responseObj;
        
        if (resultdic && [[resultdic objectForKey:@"status"] integerValue] == 0) {
            [self setViewRequestSusscess:resultdic];
        }else if (resultdic && [[resultdic objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self sendRequestForList];
            };
            [comRequest loginInBackground];
        }
        else{
            NSString *desc = [resultdic objectForKey:@"desc"];
            ///加载失败 做相应处理
            [self setViewRequestFaild:desc];
        }
        ///刷新UI
        [self reloadRefeshView];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        ///网络失败 做相应处理
        [self setViewRequestFaild:NET_ERROR];
        ///刷新UI
        [self reloadRefeshView];
    }];
}

- (void)sendRequestForFilter {
//    [_conditionArray removeAllObjects];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *params=[NSMutableDictionary dictionary];
        [params addEntriesFromDictionary:COMMON_PARAMS];
        [params setObject:@(_curIndex) forKey:@"type"];
        [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, kNetPath_Approve_Filter] params:params success:^(id responseObj) {
            if (![[responseObj objectForKey:@"status"] integerValue]) {
                
                [_filterSourceArray removeAllObjects];
                
                for (NSDictionary *tempDict in [responseObj objectForKey:@"filters"]) {
                    SKTFilter *filterItem = [SKTFilter initWithDictionary:tempDict];
                    
                    if ([filterItem.m_id isEqualToString:@"fUserId"]) {
                        NSNumber *number = [NSNumber numberWithInteger:100];
                        [[FMDBManagement sharedFMDBManager] creatWorkResportWithBaseName:ApprovalSubmitContactBaseName];
                        NSArray *newArray = [NSArray arrayWithArray:[[FMDBManagement sharedFMDBManager] resultDataWithName:ApprovalSubmitContactBaseName conditionId:number sortId:number]];
                        NSArray *array = [_searchDict objectForKey:workUserId];
                        
                        for (SKTCondition *condition in newArray) {
                            AddressBook *cacheBook = [[AddressBook alloc] init];
                            cacheBook.name = condition.m_name;
                            cacheBook.id = [NSNumber numberWithLongLong:[condition.m_id longLongValue]];
                            cacheBook.icon = condition.m_icon;
                            SKTFilterValue *filterValue = [SKTFilterValue  initWithAddressBookModel:cacheBook];
                            for (AddressBook *tempBook in array) {
                                if ([cacheBook.id integerValue] == [tempBook.id integerValue]) {
                                    
                                    filterValue.isSelected = YES;
                                }
                            }
                            [filterItem.m_values addObject:filterValue];
                        }
                    }

                    
                    [_filterSourceArray addObject:filterItem];
                    
                    SKTFilter *firstFilter = _filterSourceArray.firstObject;
                    if (firstFilter) {
                        _dropDownMenu.searchType = firstFilter.m_searchType;
                    }
                    
                    [_dropDownMenu reloadTableView];
                }
                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    
//                    _dropDownMenu.dataSource = self;
//                    [_dropDownMenu reloadTableView];
//                });
            }
        } failure:^(NSError *error) {
            
        }];
    });
}
- (void)addAndDeleteConditionWithItem:(SKTCondition *)conditionItem complete:(void (^)())complete {
    switch (conditionItem.m_itemType) {
        case 0: {
            NSMutableArray *newArray = [NSMutableArray arrayWithArray:_conditionArray];
            for (SKTCondition *tempCondition in newArray) {
                if ([tempCondition.m_itemId isEqualToString:conditionItem.m_itemId]) {
                    [_conditionArray removeObject:tempCondition];
                }
            }
            if (![conditionItem.m_id isEqualToString: @"-10"]) {
                [_conditionArray addObject:conditionItem];
            }
        }
            break;
        case 1: {
            if ([conditionItem.m_id isEqualToString:@"-10"]) { // 选择不限时，清除条件
                NSMutableArray *deleteArray = [[NSMutableArray alloc] initWithCapacity:0];
                for (SKTCondition *tempCondition in _conditionArray) {
                    if ([tempCondition.m_itemId isEqualToString:conditionItem.m_itemId]) {
                        [deleteArray addObject:tempCondition];
                    }
                }
                [_conditionArray removeObjectsInArray:deleteArray];
            }else {
                BOOL isExist = NO;
                NSInteger index = -1;
                for (int i = 0; i < _conditionArray.count; i ++) {
                    SKTCondition *tempCondition = _conditionArray[i];
                    if ([tempCondition.m_itemId isEqualToString:conditionItem.m_itemId] && [tempCondition.m_id isEqualToString:conditionItem.m_id]) {
                        isExist = YES;
                        index = i;
                    }
                }
                
                if (isExist) {  // 已存在
                    [_conditionArray removeObjectAtIndex:index];
                }else {
                    [_conditionArray addObject:conditionItem];
                }
            }
        }
            break;
        case 3: {
            BOOL isExist = NO;
            NSInteger index = -1;
            for (int i = 0; i < _conditionArray.count; i ++) {
                SKTCondition *tempCondition = _conditionArray[i];
                if ([tempCondition.m_itemId isEqualToString:conditionItem.m_itemId] && [tempCondition.m_id isEqualToString: conditionItem.m_id]) {
                    isExist = YES;
                    index = i;
                }
            }
            
            if (isExist) {  // 已存在
                [_conditionArray removeObjectAtIndex:index];
            }else {
                [_conditionArray addObject:conditionItem];
            }
        }
        default:
            break;
    }
    
    complete();
}

#pragma mark - SKTDropDownMenuDataSource
- (NSInteger)menu:(SKTDropDownMenu *)menu numberOfRowsInType:(SKTIndexPathType)type {
    if (type == SKTIndexPathTypeSmartView) {
        return _smartArray.count;
    }else if (type == SKTIndexPathTypeOther) {
        return _otherArray.count;
    }else {
        return _filterSourceArray.count;
    }
}

- (NSInteger)menu:(SKTDropDownMenu *)menu numberOfItemsInRow:(NSInteger)row {
    if (!_filterSourceArray.count)
        return 0;
    
    SKTFilter *filterItem = _filterSourceArray[row];
    return filterItem.m_values.count;
}

- (NSString*)menu:(SKTDropDownMenu *)menu titleForRowAtIndexPath:(SKTIndexPath *)indexPath {
    switch (indexPath.type) {
        case SKTIndexPathTypeSmartView:
            return _smartArray[indexPath.row];
            break;
        case SKTIndexPathTypeOther:
            return _otherArray[indexPath.row];
            break;
        case SKTIndexPathTypeScreening: {
            SKTFilter *filterItem = _filterSourceArray[indexPath.row];
            if (_searchDict) {
                if ([[_searchDict allKeys] containsObject:filterItem.m_id]) {
                    NSArray *newArray = [NSArray arrayWithArray:_searchDict[filterItem.m_id]];
                    if (newArray.count > 0 && ![newArray containsObject:@"-10"]) {
                        filterItem.isCondition = YES;
                    }
                }
            }
            return filterItem.m_itemName;
        }
        default:
            return @"";
            break;
    }
}

- (CGFloat)menu:(SKTDropDownMenu *)menu heightForRowIndexPath:(SKTIndexPath *)indexPath {
    return 44.0f;
}

- (SKTFilterValue*)menu:(SKTDropDownMenu *)menu sourceForItemInRowAtIndexPath:(SKTIndexPath *)indexPath {
    SKTFilter *filter = _filterSourceArray[indexPath.row];
    SKTFilterValue *value = filter.m_values[indexPath.item];
    if (_searchDict && [[_searchDict allKeys] containsObject:filter.m_id]) {
        NSArray *array = _searchDict[filter.m_id];
        if (array && array.count > 0) {
            if ([filter.m_id isEqualToString:@"fUserId"]) {
                
            } else {
                if ([array containsObject:value.m_id]) {
                    value.isSelected = YES;
                } else {
                    value.isSelected = NO;
                }
            }
        } else {
            if ([filter.m_id isEqualToString:@"fUserId"]) {
                
            } else {
                if ([value.m_id isEqualToString:@"-10"]) {
                    value.isSelected = YES;
                }
            }
        }
    }

    return filter.m_values[indexPath.item];
}

#pragma mark - SKTDropDownMenuDelegate
- (void)menu:(SKTDropDownMenu *)menu smartViewDidSelectRowAtRow:(NSInteger)row {
    [_searchDict removeAllObjects];
//    [_searchHistroyArray removeAllObjects];
    self.curIndex = row;
    
}

- (void)menu:(SKTDropDownMenu *)menu didSelectRowAtIndexPath:(SKTIndexPath *)indexPath {
    
    __weak typeof(self) weak_self = self;
    if (indexPath.type == SKTIndexPathTypeOther) {
        if (indexPath.row == 0) {
            self.fOrder = 2;
        }else {
            self.fOrder = 1;
        }
    }
    
    if (indexPath.type == SKTIndexPathTypeScreening) {
        SKTFilter *filter = _filterSourceArray[indexPath.row];
        NSMutableArray *selectArray = [NSMutableArray arrayWithCapacity:0];
        if (_searchDict && [[_searchDict allKeys] containsObject:filter.m_id]) {
            [selectArray addObjectsFromArray:[_searchDict objectForKey:filter.m_id]];
        }
        
        switch (filter.m_searchType) {
            case 0: {   // 单选
                
                if (indexPath.item == 0) {
                    filter.isCondition = NO;
                }else {
                    filter.isCondition = YES;
                }
                
                for (int i = 0; i < filter.m_values.count; i ++) {
                    
                    SKTFilterValue *valueItem = filter.m_values[i];
                    if (i == indexPath.item) {
                        SKTCondition *condition = [SKTCondition initWithItemId:filter.m_id andItemName:filter.m_itemName andType:filter.m_searchType andValue:valueItem];
                        if (valueItem.isSelected) {
                            return;
                        }
                        condition.indexPath = indexPath;
                        [self addAndDeleteConditionWithItem:condition complete:^{
                            weak_self.dropDownMenu.conditionArray = weak_self.conditionArray;
                        }];
                        if ([selectArray containsObject:valueItem.m_id]) {
                            [selectArray removeObject:valueItem.m_id];
                        }else {
                            [selectArray addObject:valueItem.m_id];
                        }
                        valueItem.isSelected = !valueItem.isSelected;
                    }else {
                        if ([selectArray containsObject:valueItem.m_id]) {
                            [selectArray removeObject:valueItem.m_id];
                        }
                        valueItem.isSelected = NO;
                    }
                    if (selectArray.count == 0) {
                        filter.isCondition = NO;
                    }
                }
                NSLog(@"--------单选循环体走完----------");
                [_searchDict setObject:selectArray forKey:filter.m_id];
            }
                break;
            case 1: {   // 多选
                if (indexPath.item == 0) {  // 点击第0行时
                    filter.isCondition = NO;
                    SKTFilterValue *valueItem = filter.m_values[0];
                    if (valueItem.isSelected)   // 已经处于点击状态
                        return;
                    SKTCondition *deleteCondition = [SKTCondition initWithItemId:filter.m_id andItemName:filter.m_itemName andType:filter.m_searchType andValue:valueItem];
                    deleteCondition.indexPath = indexPath;
                    [self addAndDeleteConditionWithItem:deleteCondition complete:^{
                        weak_self.dropDownMenu.conditionArray = weak_self.conditionArray;
                    }];
                    [selectArray removeAllObjects];
                    [selectArray addObject:valueItem.m_id];
                    for (SKTFilterValue *tempValue in filter.m_values) {
                        tempValue.isSelected = NO;
                    }
                    valueItem.isSelected = YES;
                }else {
                    filter.isCondition = YES;
                    SKTFilterValue *valueItem;
                    
                    // 将第0行设置为非选中状态
                    valueItem = filter.m_values[0];
                    valueItem.isSelected = NO;
                    if ([selectArray containsObject:valueItem.m_id]) {
                        [selectArray removeObject:valueItem.m_id];
                    }
                    
                    // 将对应的行设置为选中状态
                    valueItem = filter.m_values[indexPath.item];
                    SKTCondition *condition = [SKTCondition initWithItemId:filter.m_id andItemName:filter.m_itemName andType:filter.m_searchType andValue:valueItem];
                    condition.indexPath = indexPath;
                    [self addAndDeleteConditionWithItem:condition complete:^{
                        weak_self.dropDownMenu.conditionArray = weak_self.conditionArray;
                    }];
                    if (!valueItem.isSelected) {
                        if (![selectArray containsObject:valueItem.m_id]) {
                            [selectArray addObject:valueItem.m_id];
                        }
                    } else {
                        if ([selectArray containsObject:valueItem.m_id]) {
                            [selectArray removeObject:valueItem.m_id];
                        }
                    }
                    valueItem.isSelected = !valueItem.isSelected;
                    
                    // 检测是否还有选定项，如果没有，则改变第0行状态
                    BOOL isCondition = YES;
                    for (SKTFilterValue *tempValue in filter.m_values) {
                        if (tempValue.isSelected && ![tempValue.m_id isEqualToString:@"-10"]) {
                            isCondition = YES;
                        }else {
                            isCondition = NO;
                        }
                    }
                    
                    if (!isCondition) {
                        filter.isCondition = NO;
                        valueItem = filter.m_values[0];
                        valueItem.isSelected = NO;
                    }
                    
                }
                NSLog(@"--------多选循环体走完----------");
                [_searchDict setObject:selectArray forKey:filter.m_id];
            }
                break;
            case 2:
                break;
            case 3: {   // 自定义
                if (indexPath.item == 0) {
                    NSNumber *number = [NSNumber numberWithInteger:100];
                    if (filter.m_values.count) {
                        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
                        for (SKTFilterValue *tempItem in filter.m_values) {
                            AddressBook *item = [[AddressBook alloc] init];
                            item.id = [NSNumber numberWithLongLong:[tempItem.m_id longLongValue]];
                            item.name = tempItem.m_name;
                            item.icon = tempItem.m_icon;
                            [tempArray addObject:item];
                        }
                        EditAddressViewController *editController = [[EditAddressViewController alloc] init];
                        editController.title = @"编辑常用提交人";
                        editController.sourceModel = [ExportAddress initWithArray:tempArray];
                        NSMutableArray *cacheArray = [NSMutableArray arrayWithArray:[[FMDBManagement sharedFMDBManager] resultDataWithName:ApprovalSubmitContactBaseName conditionId:number sortId:number]];
                        NSMutableArray *newCacheArray = [NSMutableArray arrayWithArray:cacheArray];
                        NSMutableArray *newValuesArray = [NSMutableArray arrayWithArray:filter.m_values];
                        NSMutableArray *oldArray = [NSMutableArray arrayWithArray:_conditionArray];
                        editController.deleteBlock = ^(AddressBook *bookModel){
                            for (SKTCondition *condition in newCacheArray) {
                                if ([[NSString stringWithFormat:@"%@", bookModel.id] isEqualToString:condition.m_id]) {
                                    [cacheArray removeObject:condition];
                                    for (SKTFilterValue *tempItem in newValuesArray) {
                                        if ([tempItem.m_id isEqualToString: condition.m_id]) {
                                            [filter.m_values removeObject:tempItem];
                                        }
                                    }
                                    
                                    for (SKTCondition *conModel in oldArray) {
                                        if ([conModel.m_id isEqualToString: condition.m_id]) {
                                            [_conditionArray removeObject:conModel];
                                        }
                                    }
                                    weak_self.dropDownMenu.conditionArray = weak_self.conditionArray;
//                                    if (_conditionArray.count > 0) {
//                                        [self addAndDeleteConditionWithItem:condition complete:^{
//                                            weak_self.dropDownMenu.conditionArray = weak_self.conditionArray;
//                                        }];
//                                    }
                                }
                            }
                            for (SKTCondition *cond in cacheArray) {
                                NSLog(@"检测存数的数据： %@---%@----%ld----%@", cond.m_name, cond.m_itemName, (long)cond.m_id, cond.m_itemId);
                            }
                            [[FMDBManagement sharedFMDBManager] insertOrUpdateDataSourceWithName:ApprovalSubmitContactBaseName array:cacheArray conditionId:number sortId:number];
                            //确定之后做筛选记录的缓存
                            NSNumber *numIndex = [NSNumber numberWithInteger:_curIndex];
                            [[FMDBManagement sharedFMDBManager] insertOrUpdateDataSourceWithName:ApprovalFilterBaseName array:_conditionArray conditionId:numIndex sortId:numIndex];
                            [_dropDownMenu reloadTableView];
                        };
                        editController.refreshBlock = ^(NSArray *array) {
                            //                            [filter.m_values removeAllObjects];
                            NSMutableArray *contactIds = [NSMutableArray arrayWithCapacity:0];
                            for (SKTFilterValue *filterValue in filter.m_values) {
                                [contactIds addObject:filterValue.m_id];
                            }
                            //
                            NSMutableArray *cacheArray = [NSMutableArray arrayWithArray:[[FMDBManagement sharedFMDBManager] resultDataWithName:ApprovalSubmitContactBaseName conditionId:number sortId:number]];
                            for (AddressBook *tempBook in array) {
                                if (![contactIds containsObject:@([tempBook.id integerValue])]) {
                                    SKTFilterValue *filterValue = [SKTFilterValue  initWithAddressBookModel:tempBook];
                                    filterValue.isSelected = YES;
                                    [filter.m_values addObject:filterValue];
                                    SKTCondition *condition = [SKTCondition initWithItemId:filter.m_id andItemName:filter.m_itemName andType:filter.m_searchType andValue:filterValue];
                                    [self addAndDeleteConditionWithItem:condition complete:^{
                                        weak_self.dropDownMenu.conditionArray = weak_self.conditionArray;
                                    }];
                                    [cacheArray addObject:condition];
                                }
                            }
                            for (SKTCondition *cond in cacheArray) {
                                NSLog(@"检测存数的数据： %@---%@----%ld----%@", cond.m_name, cond.m_itemName, (long)cond.m_id, cond.m_itemId);
                            }
                            [[FMDBManagement sharedFMDBManager] insertOrUpdateDataSourceWithName:ApprovalSubmitContactBaseName array:cacheArray conditionId:number sortId:number];
                            [_dropDownMenu reloadTableView];
                        };
                        [self.navigationItem setBackBarButtonItem:kBackItem];
                        [self.navigationController pushViewController:editController animated:YES];
                        return;
                    }
                    
                    ExportAddressViewController *exportController = [[ExportAddressViewController alloc] init];
                    exportController.title = @"选择提交人";
                    exportController.isActivityRecExport = YES;
                    exportController.valueBlock = ^(NSArray *array) {
                        NSMutableArray *cacheArray = [NSMutableArray arrayWithCapacity:0];
                        for (AddressBook *tempBook in array) {
                            SKTFilterValue *filterValue = [SKTFilterValue  initWithAddressBookModel:tempBook];
                            filterValue.isSelected = YES;
                            [filter.m_values addObject:filterValue];
                            SKTCondition *condition = [SKTCondition initWithItemId:filter.m_id andItemName:filter.m_itemName andType:filter.m_searchType andValue:filterValue];
                            [self addAndDeleteConditionWithItem:condition complete:^{
                                weak_self.dropDownMenu.conditionArray = weak_self.conditionArray;
                            }];
                            [cacheArray addObject:condition];
                        }
                        [[FMDBManagement sharedFMDBManager] insertOrUpdateDataSourceWithName:ApprovalSubmitContactBaseName array:cacheArray conditionId:number sortId:number];
                        [_dropDownMenu reloadTableView];
                    };
                    [self.navigationController pushViewController:exportController animated:YES];
                    return;
                    
                }
                
                filter.isCondition = YES;
                SKTFilterValue *valueItem;
                
                // 将对应的行设置为选中状态
                valueItem = filter.m_values[indexPath.item - 1];
                SKTCondition *condition = [SKTCondition initWithItemId:filter.m_id andItemName:filter.m_itemName andType:filter.m_searchType andValue:valueItem];
                condition.indexPath = indexPath;
                [self addAndDeleteConditionWithItem:condition complete:^{
                    weak_self.dropDownMenu.conditionArray = weak_self.conditionArray;
                }];
                valueItem.isSelected = !valueItem.isSelected;
                
                // 检测是否还有选定项，如果没有，则改变leftTableView的选中标识状态
                BOOL isCondition = YES;
                for (SKTFilterValue *tempValue in filter.m_values) {
                    if (tempValue.isSelected) {
                        isCondition = YES;
                        return;
                    }else {
                        isCondition = NO;
                    }
                }
                
                if (!isCondition)
                    filter.isCondition = NO;
            }
            default:
                break;
        }
    }
}

- (BOOL)menu:(SKTDropDownMenu *)menu isConditionInRow:(NSInteger)row {
    SKTFilter *filter = _filterSourceArray[row];
    return filter.isCondition;
}

- (NSInteger)menu:(SKTDropDownMenu *)menu searchTypeForItemInRow:(NSInteger)row {
    SKTFilter *filter = _filterSourceArray[row];
    return filter.m_searchType;
}

- (SKTFilter*)menu:(SKTDropDownMenu *)menu sourceForTableViewInRow:(NSInteger)row {
    return _filterSourceArray[row];
}

- (void)menu:(SKTDropDownMenu *)menu deleteConditionWithItem:(SKTCondition *)condition {
    isSelect = YES;
    for (SKTFilter *tempFilter in _filterSourceArray) {
        if ([tempFilter.m_id isEqualToString:condition.m_itemId]) {
            NSMutableArray *selectArray = [NSMutableArray arrayWithCapacity:0];
            if (_searchDict && [[_searchDict allKeys] containsObject:tempFilter.m_id]) {
                [selectArray addObjectsFromArray:[_searchDict objectForKey:tempFilter.m_id]];
            }
            switch (tempFilter.m_searchType) {
                case 0: {   // 单选
                    tempFilter.isCondition = NO;
                    for (int i = 0; i < tempFilter.m_values.count; i ++) {
                        SKTFilterValue *valueItem = tempFilter.m_values[i];
                        if (i == 0) {
                            valueItem.isSelected = YES;
                            [selectArray removeAllObjects];
                            [selectArray addObject:valueItem.m_id];
                            [_searchDict setObject:selectArray forKey:tempFilter.m_id];
                        }else {
                            valueItem.isSelected = NO;
                        }
                    }
                }
                    break;
                case 1:     // 多选
                {
                    for (SKTFilterValue *tempValue in tempFilter.m_values) {
                        NSLog(@"%@---%@", tempValue.m_id, condition.m_id);
                        if ([tempValue.m_id isEqualToString: condition.m_id]) {
                            tempValue.isSelected = NO;
                            [selectArray removeObject:tempValue.m_id];
                        }
                    }
                    if (selectArray.count == 0) {
                        [selectArray addObject:@"-10"];
                    }
                    [_searchDict setObject:selectArray forKey:tempFilter.m_id];
                    NSLog(@"改变多选状态");
                }
                case 3: {   // 自定义
                    // 判断是否存在此条件
                    tempFilter.isCondition = NO;
                    for (SKTFilterValue *tempValue in tempFilter.m_values) {
                        if ([tempValue.m_id isEqualToString: condition.m_id]) {
                            tempValue.isSelected = NO;
                        }
                    }
                }
                default:
                    break;
            }
            
        }
    }
    [_dropDownMenu reloadTableView];
}

- (void)resetCondition {
    [_searchDict removeAllObjects];
    for (SKTCondition *tempCondition in _conditionArray) {
        for (SKTFilter *tempFilter in _filterSourceArray) {
            if ([tempFilter.m_id isEqualToString:tempCondition.m_itemId]) {
                
                switch (tempFilter.m_searchType) {
                    case 0: {   // 单选
                        tempFilter.isCondition = NO;
                        for (int i = 0; i < tempFilter.m_values.count; i ++) {
                            SKTFilterValue *valueItem = tempFilter.m_values[i];
                            if (i == 0) {
                                valueItem.isSelected = YES;
                            }else {
                                valueItem.isSelected = NO;
                            }
                        }
                    }
                        break;
                    case 1: {   // 多选
                        // 判断是否存在此条件
                        tempFilter.isCondition = NO;
                        
                        for (SKTFilterValue *tempValue in tempFilter.m_values) {
                            tempValue.isSelected = NO;
                        }
                        // 显示不限的状态
                        SKTFilterValue *value0 = tempFilter.m_values[0];
                        value0.isSelected = YES;
                    }
                        break;
                    case 3: {   // 自定义
                        // 判断是否存在此条件
                        tempFilter.isCondition = NO;
                        
                        for (SKTFilterValue *tempValue in tempFilter.m_values) {
                            tempValue.isSelected = NO;
                        }
                    }
                    default:
                        break;
                }
                
            }
        }
    }
    
    [_conditionArray removeAllObjects];
    _dropDownMenu.conditionArray = _conditionArray;
    [_dropDownMenu reloadTableView];
//    [_dropDownMenu backgroundTap];
//    pageNo = 1;
//    [self sendRequestForList];
}

- (void)confirmCondition {
    
    
//    _searchHistroyArray = _conditionArray;
    
//    NSMutableArray *newDataSourceArray = [NSMutableArray arrayWithArray:_conditionArray];
//    for (SKTCondition *condition in newDataSourceArray) {
//        if ([condition.m_itemId isEqualToString:@"fUserId"]) {
//            [_conditionArray removeObject:condition];
//        }
//    }
//    NSInteger count = _conditionArray.count;
//    for (int i = 0; i < count; i++) {
//        SKTCondition *condition = _conditionArray[i];
//        if ([condition.m_itemId isEqualToString:@"fUserId"]) {
//            [_conditionArray removeObject:condition];
//            count --;
//        }
//    }
    
    _searchHistroyArray = _conditionArray;
    
    [self customConScrollView];
    [self configScrollCustomView];
    [_dropDownMenu backgroundTap];
    
    
    NSNumber *numIndex = [NSNumber numberWithInteger:_curIndex];
    [[FMDBManagement sharedFMDBManager] creatWorkResportWithBaseName:ApprovalFilterBaseName];
    [[FMDBManagement sharedFMDBManager] insertOrUpdateDataSourceWithName:ApprovalFilterBaseName array:_conditionArray conditionId:numIndex sortId:numIndex];
    
    pageNo = 1;
    [self sendRequestForList];
    return;

    //确定之后做筛选记录的缓存
    

    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:@(_fOrder) forKey:@"fOrder"];
//    for (SKTCondition *condition in _conditionArray) {
//        [params setObject:@(condition.m_id) forKey:condition.m_itemId];
//    }
    for (SKTCondition *condition in _conditionArray) {
        // 多选时，如果已经有该key，则组装value值
        if ([[params allKeys] containsObject:condition.m_itemId]) {
            [params setObject:[NSString stringWithFormat:@"%@,%@", params[condition.m_itemId], condition.m_id] forKey:condition.m_itemId];
        }else {
            [params setObject:[NSString stringWithFormat:@"%@", condition.m_id] forKey:condition.m_itemId];
        }
    }

    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSArray *pathArray = @[kNetPath_Approve_Mine, kNetPath_Approve_ToMe, kNetPath_Approve_All];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, pathArray[_curIndex]] params:params success:^(id responseObj) {
        [hud hide:YES];
        if ([[responseObj objectForKey:@"status"] integerValue] == 0) {
            [_sourceArray removeAllObjects];
            if ([CommonFuntion checkNullForValue:[responseObj objectForKey:@"status"]]) {
                NSArray *array = [NSArray arrayWithArray:[responseObj objectForKey:@"approvals"]];
                if (array.count == 0) {
                    [self clearViewNoData];
                    [self setViewNoData:@"暂无审批"];
                } else {
                    [self clearViewNoData];
                    for (NSDictionary *tempDict in array) {
                        Approval *approval = [Approval initWithDictionary:tempDict];
                        [_sourceArray addObject:approval];
                    }
                }
            }
        }
        [self reloadRefeshView];
    } failure:^(NSError *error) {
        [hud hide:YES];
        NSLog(@"数据加载失败");
        [self reloadRefeshView];
    }];
//    [self configScrollCustomView];
}

- (void)didSelectAction {
    _conditionArray = _searchHistroyArray;
    _dropDownMenu.conditionArray = _conditionArray;
}


- (void)afreshGetDataSourceFromServer {
    
    if (isSelect == NO) {
        return;
    } else {
        isSelect = NO;
    }
    _searchHistroyArray = _conditionArray;
    
    [self customConScrollView];
    [self configScrollCustomView];
    
    //确定之后做筛选记录的缓存
    
    
    NSNumber *numIndex = [NSNumber numberWithInteger:_curIndex];
    [[FMDBManagement sharedFMDBManager] creatWorkResportWithBaseName:ApprovalFilterBaseName];
    [[FMDBManagement sharedFMDBManager] insertOrUpdateDataSourceWithName:ApprovalFilterBaseName array:_conditionArray conditionId:numIndex sortId:numIndex];
    
    pageNo = 1;
    [self sendRequestForList];
    return;
    
    /*
    //确定之后做筛选记录的缓存
    NSNumber *numIndex = [NSNumber numberWithInteger:_curIndex];
    [[FMDBManagement sharedFMDBManager] creatWorkResportWithBaseName:ApprovalFilterBaseName];
    [[FMDBManagement sharedFMDBManager] insertOrUpdateDataSourceWithName:ApprovalFilterBaseName array:_conditionArray conditionId:numIndex sortId:numIndex];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:@(_fOrder) forKey:@"fOrder"];
    //    for (SKTCondition *condition in _conditionArray) {
    //        [params setObject:@(condition.m_id) forKey:condition.m_itemId];
    //    }
    for (SKTCondition *condition in _conditionArray) {
        // 多选时，如果已经有该key，则组装value值
        if ([[params allKeys] containsObject:condition.m_itemId]) {
            [params setObject:[NSString stringWithFormat:@"%@,%@", params[condition.m_itemId], condition.m_id] forKey:condition.m_itemId];
        }else {
            [params setObject:[NSString stringWithFormat:@"%@", condition.m_id] forKey:condition.m_itemId];
        }
    }
    
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSArray *pathArray = @[kNetPath_Approve_Mine, kNetPath_Approve_ToMe, kNetPath_Approve_All];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, pathArray[_curIndex]] params:params success:^(id responseObj) {
        [hud hide:YES];
        if ([[responseObj objectForKey:@"status"] integerValue] == 0) {
            [_sourceArray removeAllObjects];
            if ([CommonFuntion checkNullForValue:[responseObj objectForKey:@"status"]]) {
                NSArray *array = [NSArray arrayWithArray:[responseObj objectForKey:@"approvals"]];
                if (array.count == 0) {
                    [self clearViewNoData];
                    [self setViewNoData:@"暂无审批"];
                } else {
                    [self clearViewNoData];
                    for (NSDictionary *tempDict in array) {
                        Approval *approval = [Approval initWithDictionary:tempDict];
                        [_sourceArray addObject:approval];
                    }
                }
            }
        }
        [self reloadRefeshView];
    } failure:^(NSError *error) {
        [hud hide:YES];
        NSLog(@"数据加载失败");
        [self reloadRefeshView];
    }];
     */
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ApprovalCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ApprovalCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    Approval *item = _sourceArray[indexPath.row];
    [cell configWithModel:item andApprovalType:_curIndex];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Approval *approvalItem = _sourceArray[indexPath.row];
    ApprovalDetailViewController *approvalDetailController = [[ApprovalDetailViewController alloc] init];
    approvalDetailController.approval = approvalItem;
    approvalDetailController.refreshDataSource = ^{
        pageNo = 1;
        [self sendRequestForList];
    };
    [self.navigationController pushViewController:approvalDetailController animated:YES];
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
         _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64 + 44, kScreen_Width, kScreen_Height - 64 - 44) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView registerClass:[ApprovalCell class] forCellReuseIdentifier:kCellIdentifier];
        _tableView.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
        _tableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    }
    return _tableView;
}

- (SKTDropDownMenu*)dropDownMenu {
    if (!_dropDownMenu) {
        _dropDownMenu = [[SKTDropDownMenu alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height - 64) andViewController:self];
        NSInteger row = 1;
        _dropDownMenu.selectRow = row;
        _dropDownMenu.smartViewSelectRow = row;
        _dropDownMenu.dataSource = self;
        _dropDownMenu.delegate = self;
    }
    return _dropDownMenu;
}




#pragma mark - 上拉下拉刷新相关事件
//集成刷新控件
- (void)setupRefresh
{
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [_tableView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"approvalView"];
    //上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [_tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 自动刷新(一进入程序就下拉刷新)
    //    [self.tableviewCampaign headerBeginRefreshing];
}

// 结束加载
-(void)reloadRefeshView{
    // 刷新列表
    [_tableView reloadData];
    [_tableView footerEndRefreshing];
    [_tableView headerEndRefreshing];
}

// 下拉
- (void)headerRereshing
{
    if ([_tableView isFooterRefreshing]) {
        [_tableView headerEndRefreshing];
        return;
    }
    
    pageNo = 1;
    [self sendRequestForList];
}

// 上拉
- (void)footerRereshing
{
    if ([_tableView isHeaderRefreshing]) {
        [_tableView footerEndRefreshing];
        return;
    }
    [self sendRequestForList];
}


#pragma mark - 是否存在缓存数据  存在则读取
-(void)getExistCache{
}


// 请求成功时数据处理
-(void)setViewRequestSusscess:(NSDictionary *)resultdic
{
    NSArray  *array = nil;
    NSMutableArray *newDataArray = [NSMutableArray arrayWithCapacity:0];
    if ([[resultdic objectForKey:@"approvals"] count]) {
        array = [resultdic objectForKey:@"approvals"];
    }
    
    //有数据返回
    if (array && [array count] > 0) {
        ///添加当前页数据到列表中...
        for (NSDictionary *tempDict in array) {
            Approval *approval = [Approval initWithDictionary:tempDict];
            [newDataArray addObject:approval];
        }
        
        ///缓存第一页数据
        if(pageNo == 1)
        {
            [_sourceArray removeAllObjects];
            [_sourceArray addObjectsFromArray:newDataArray];
            ///缓存数据
            [[FMDBManagement sharedFMDBManager] creatWorkResportWithBaseName:ApprovalListBaseName];
            NSNumber *numIndex = [NSNumber numberWithInteger:_curIndex];
            NSNumber *numFOrder = [NSNumber numberWithInteger:_fOrder];
            [[FMDBManagement sharedFMDBManager] insertOrUpdateDataSourceWithName:ApprovalListBaseName array:_sourceArray conditionId:numIndex sortId:numFOrder];
        } else {
            [_sourceArray addObjectsFromArray:newDataArray];
        }
        
        ///页码++
        if ([array count] == PageSize) {
            pageNo++;
            [_tableView setFooterHidden:NO];
        }else
        {
            ///隐藏上拉刷新
            [_tableView setFooterHidden:YES];
        }
        
    }else{
        ///返回为空
        ///隐藏上拉刷新
        [_tableView setFooterHidden:YES];
        ///若是第一页 读取是否存在缓存
        if(pageNo == 1)
        {
            [_sourceArray removeAllObjects];
//            [self getExistCache];
            [self setViewNoData:titleForNoData];
            [[FMDBManagement sharedFMDBManager] creatWorkResportWithBaseName:ApprovalListBaseName];
            NSNumber *numIndex = [NSNumber numberWithInteger:_curIndex];
            NSNumber *numFOrder = [NSNumber numberWithInteger:_fOrder];
            [[FMDBManagement sharedFMDBManager] insertOrUpdateDataSourceWithName:ApprovalListBaseName array:_sourceArray conditionId:numIndex sortId:numFOrder];
        }
    }
}

// 请求失败时数据处理
-(void)setViewRequestFaild:(NSString *)desc
{
    ///若是第一页 读取是否存在缓存
    if(pageNo == 1)
    {
        ///如果当前没有展示数据 则读取缓存
        if (_sourceArray == nil || [_sourceArray count] == 0) {
            [_sourceArray addObjectsFromArray:[self resultApprovalListCache]];
            if (_sourceArray.count == 0) {
                [self setViewNoData:titleForNoData];
            }
        }
    }
    kShowHUD(desc,nil);
}


#pragma mark - 没有数据时的view
-(void)setViewNoData:(NSString *)title{
    
    self.commonNoDataView = [CommonFuntion commonNoDataViewIcon:@"list_empty.png" Title:title optionBtnTitle:@""];
    
    [_tableView addSubview:self.commonNoDataView];
}


-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
    }
}
//读取列表缓存
- (NSArray *)resultApprovalListCache {
    NSNumber *numIndex = [NSNumber numberWithInteger:_curIndex];
    NSNumber *numFOrder = [NSNumber numberWithInteger:_fOrder];
    NSArray *resultArray = [NSArray arrayWithArray:[[FMDBManagement sharedFMDBManager] resultDataWithName:ApprovalListBaseName conditionId:numIndex sortId:numFOrder]];
    return resultArray;
}
#pragma mark - 展示筛选历史条件
- (void)customConScrollView {
    if (!_conditionScrollView) {
        _conditionScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 108, CGRectGetWidth(self.view.bounds), 53.5)];
        _conditionScrollView.backgroundColor = kView_BG_Color;
        _conditionScrollView.showsHorizontalScrollIndicator = NO;
        _conditionScrollView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_conditionScrollView];
    }
}
- (void)configScrollCustomView {
    for (UIView *view in _conditionScrollView.subviews) {
        [view removeFromSuperview];
    }
    [_searchRightIdsArray removeAllObjects];
    CGFloat VHight = 0.0;
    if (_searchHistroyArray.count) {
        _conditionScrollView.hidden = NO;
        NSMutableArray *typeArray = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *statusArray = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *charcterArray = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *useridArray = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < _searchHistroyArray.count; i ++) {
            SKTCondition *condition = _searchHistroyArray[i];
            NSLog(@"%@---%@----%@", condition.m_itemName , condition.m_name, condition.m_itemId);
            if (_curIndex == 0) {
                //类型 日期 状态
                if ([condition.m_itemId isEqualToString:workType]) {
                    [typeArray addObject:condition.m_id];
                } else if ([condition.m_itemId isEqualToString:workStatus]) {
                    [statusArray addObject:condition.m_id];
                }
            } else if (_curIndex == 1) {
                //类型 日期 状态 分类 提交人
                if ([condition.m_itemId isEqualToString:workType]) {
                    [typeArray addObject:condition.m_id];
                } else if ([condition.m_itemId isEqualToString:workStatus]) {
                    [statusArray addObject:condition.m_id];
                } else if ([condition.m_itemId isEqualToString:workChracter]) {
                    [charcterArray addObject:condition.m_id];
                } else if ([condition.m_itemId isEqualToString:workUserId]) {
                    AddressBook *addBook = [[AddressBook alloc] init];
                    addBook.name = condition.m_name;
                    addBook.id = [NSNumber numberWithLongLong:[condition.m_id longLongValue]];
                    [useridArray addObject:addBook];
                }
            } else {
                //类型  提交人
                if ([condition.m_itemId isEqualToString:workType]) {
                    [typeArray addObject:condition.m_id];
                } else if ([condition.m_itemId isEqualToString:workUserId]) {
                    AddressBook *addBook = [[AddressBook alloc] init];
                    addBook.name = condition.m_name;
                    addBook.id = [NSNumber numberWithLongLong:[condition.m_id longLongValue]];
                    [useridArray addObject:addBook];
                }
            }
            SKTConditionView *conditionView = [SKTConditionView initWithFrame:CGRectMake(5 + (44 + 5) * i, 5, 44, 44) andConditionItem:condition];
            conditionView.tag = 400 + i;
            [conditionView addTarget:self action:@selector(cancelButtonPress:) forControlEvents:UIControlEventTouchUpInside];
            [_conditionScrollView addSubview:conditionView];
        }
        if (_curIndex == 0) {
            [_searchDict setObject:typeArray forKey:workType];
            [_searchDict setObject:statusArray forKey:workStatus];
        } else if (_curIndex == 1) {
            //类型 状态 分类 提交人
            [_searchDict setObject:typeArray forKey:workType];
            [_searchDict setObject:statusArray forKey:workStatus];
            [_searchDict setObject:charcterArray forKey:workChracter];
            [_searchDict setObject:useridArray forKey:workUserId];
        } else {
            //类型  提交人
            [_searchDict setObject:typeArray forKey:workType];
            [_searchDict setObject:useridArray forKey:workUserId];
        }
        
        [_conditionScrollView setContentSize:CGSizeMake((44 + 5)*_searchHistroyArray.count, 53.5)];
        VHight = 53.5;
        _tableView.frame = CGRectMake(0, 108 + VHight, kScreen_Width, kScreen_Height - 108 -VHight);
    }else {
        _conditionScrollView.hidden = YES;
        VHight = 0.0;
        _tableView.frame = CGRectMake(0, 108 + VHight, kScreen_Width, kScreen_Height - 108 -VHight);
    }
}
- (void)cancelButtonPress:(UIButton*)sender {
    
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
