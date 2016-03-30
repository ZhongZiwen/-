//
//  ActivityRecViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ActivityRecViewController.h"
#import "AppDelegate.h"
#import "NSDate+Helper.h"
#import "FMDBManagement.h"
#import "ValueIdModel.h"
#import "AddressBook.h"
#import "CustomTitleView.h"
#import "SmartConditionModel.h"
#import "PopoverItem.h"
#import "PopoverView.h"
#import "CustomActionSheet.h"
#import "AddressSelectedController.h"
#import "ActivityRecordTypeListController.h"
#import "ActivityRecordListController.h"
#import "ActivityRecConditionController.h"
#import "ActivityType.h"
#import "Activity.h"
#import "ActivityRecHeaderView.h"
#import "ActivityRecordTitleCell.h"
#import "ActivityRecordDailyCell.h"
#import "ActivityRecordWeeklyCell.h"

#define kCellIdentifier_title @"ActivityRecordTitleCell"
#define kCellIdentifier_daily @"ActivityRecordDailyCell"
#define kCellIdentifier_weekly @"ActivityRecordWeeklyCell"
#define kTag_button 43513
#define kHeight_headerView 100

@interface ActivityRecViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) CustomTitleView *customTitleView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) ActivityRecHeaderView *headerView;
@property (strong, nonatomic) UIToolbar *toolBar;
@property (strong, nonatomic) CustomActionSheet *actionSheet;

@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableArray *usersArray;
@property (strong, nonatomic) NSMutableArray *recordsArray;
@property (strong, nonatomic) NSMutableDictionary *params;
@property (assign, nonatomic) NSInteger type;
@property (assign, nonatomic) NSInteger curIndex;

- (void)sendRequestForList;
- (void)sendRequestForActivityRecordType;
@end

@implementation ActivityRecViewController

- (void)loadView {
    [super loadView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonPress)];
    
    @weakify(self);
    self.navigationItem.titleView = self.customTitleView;
    _customTitleView.valueBlock = ^(NSInteger index) {
        @strongify(self);
        self.curIndex = index;
    };
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.toolBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _type = 2;
    
    _sourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    _usersArray = [[NSMutableArray alloc] initWithCapacity:4];
    _recordsArray = [[NSMutableArray alloc] initWithCapacity:0];
    _params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [_params setObject:@(_type) forKey:@"type"];
    
    NSArray *tempArray = [[FMDBManagement sharedFMDBManager] getAddressBookDataSource];
    for (int i = 0; i < MIN(tempArray.count, 4); i ++) {
        AddressBook *item = tempArray[i];
        [_usersArray addObject:item];
        
        if (i == 0) {
            [_params setObject:item.id forKey:@"userId"];
        }
    }
    [_headerView configWithArray:_usersArray showMoreButton:YES];
    
    @weakify(self);
    _headerView.iconViewClickedBlock = ^(NSInteger tag) {
        @strongify(self);
        AddressBook *item = self.usersArray[tag];
        [self.params setObject:item.id forKey:@"userId"];
        
        [self sendRequestForList];
    };
    _headerView.userMoreClickedBlock = ^{
        @strongify(self);
        AddressSelectedController *selectedController = [[AddressSelectedController alloc] init];
        selectedController.title = @"选择责任人";
        selectedController.activityRecBtnImage = @"menu_set_active";
        selectedController.selectedBlock = ^(AddressBook *item) {
            [self.params setObject:item.id forKey:@"userId"];
            [self.usersArray removeLastObject];
            [self.usersArray insertObject:item atIndex:0];
            [self.headerView configWithArray:self.usersArray showMoreButton:YES];
            
            [self sendRequestForList];
        };
        selectedController.activityRecBlock = ^(NSArray *array) {
            
            for (AddressBook *tempItem in array) {
                [self.usersArray removeLastObject];
                [self.usersArray insertObject:tempItem atIndex:0];
            }
            
            [self.headerView configWithArray:self.usersArray showMoreButton:YES];
        };
        [self.navigationController pushViewController:selectedController animated:YES];
    };
    
    [self sendRequestForList];
    
    // 异步获取活动类型
    [self sendRequestForActivityRecordType];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
- (void)sendRequestForList {
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_ActivityRecord_Types_WithParams:_params block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            [_sourceArray removeAllObjects];
            for (NSDictionary *tempDict in data[@"activityTypes"]) {
                ActivityType *activityType = [NSObject objectOfClass:@"ActivityType" fromJSON:tempDict];
                for (NSDictionary *dict in tempDict[@"activities"]) {
                    Activity *activity = [NSObject objectOfClass:@"Activity" fromJSON:dict];
                    [activityType.activitiesArray addObject:activity];
                }
                [_sourceArray addObject:activityType];
            }
            
            [_tableView reloadData];
        }else {
            NSLog(@"获取活动记录数据失败");
        }
    }];
}

- (void)sendRequestForActivityRecordType {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[Net_APIManager sharedManager] request_ActivityRecord_Type_WithBlock:^(id data, NSError *error) {
            if (data) {
                for (NSString *keyStr in [data[@"records"] allKeys]) {
                    ValueIdModel *item = [[ValueIdModel alloc] init];
                    item.id = keyStr;
                    item.value = data[@"records"][keyStr];
                    [_recordsArray addObject:item];
                }
            }else {
                NSLog(@"获取活动类型失败!");
            }
        }];
    });
}

- (UIButton*)buttonWithTitle:(NSString*)title tag:(NSInteger)tag {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setWidth:64.0f];
    [button setHeight:44.0f];
    button.tag = kTag_button + tag;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor iOS7darkGrayColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor iOS7lightBlueColor] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    if (tag == 2) {
        [button setSelected:YES];
    }
    return button;
}

#pragma mark - event response
- (void)buttonPress:(UIButton*)sender {
    self.type = sender.tag - kTag_button;
    
}

- (void)searchButtonPress {
    ActivityRecConditionController *conditonController = [[ActivityRecConditionController alloc] init];
    conditonController.title = @"搜索条件";
    
    
    [self.navigationItem setBackBarButtonItem:[UIBarButtonItem itemWithBtnTitle:@"返回" target:nil action:nil]];
    [self.navigationController pushViewController:conditonController animated:YES];
}

- (void)addActivityRecord {
    self.actionSheet.title = @"选择要添加的活动类型";
    _actionSheet.sourceArray = _recordsArray;
    _actionSheet.actionType = ActionSheetTypeFromActivity;
    @weakify(self);
    _actionSheet.selectedBlock = ^(id obj, ActionSheetTypeFrom fromType) {
        @strongify(self);
        
    };
    [_actionSheet show];
}

- (void)showMoreButtonPress {
    
    NSArray *array = @[[PopoverItem initItemWithTitle:@"搜索" image:nil target:self action:@selector(searchButtonPress)],
                       [PopoverItem initItemWithTitle:@"添加活动记录" image:nil target:self action:@selector(addActivityRecord)]];
    PopoverView *pop = [[PopoverView alloc] initWithImageItems:nil titleItems:array];
    [pop show];
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return [ActivityRecordTitleCell cellHeight];
    }
    
    if (_type < 2) {
        return [ActivityRecordDailyCell cellHeight];
    }else {
        return [ActivityRecordWeeklyCell cellHeight];
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!_curIndex) {
        return self.headerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!_curIndex) {
        return kHeight_headerView;
    }
    
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        ActivityRecordTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_title forIndexPath:indexPath];
        [cell configWithType:_type];
        return cell;
    }
    
    ActivityType *activityType = _sourceArray[indexPath.row - 1];
    if (_type < 2) {
        @weakify(self);
        ActivityRecordDailyCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_daily forIndexPath:indexPath];
        cell.popBlock = ^{
            @strongify(self);
            NSString *timeStr;
            if (!self.type) {
                timeStr = [[NSDate date] stringYearMonthDayForLine];
            }else {
                timeStr = [[NSDate dateYesterday] stringYearMonthDayForLine];
            }
            ActivityRecordListController *recordListController = [[ActivityRecordListController alloc] init];
            recordListController.title = @"活动记录";
            recordListController.startTime = timeStr;
            recordListController.endTime = timeStr;
            recordListController.userId = self.params[@"userId"];
            recordListController.typeId = activityType.id;
            [self.navigationItem setBackBarButtonItem:[UIBarButtonItem itemWithBtnTitle:@"返回" target:nil action:nil]];
            [self.navigationController pushViewController:recordListController animated:YES];
        };
        [cell configWithModel:activityType];
        return cell;
    }else {
        ActivityRecordWeeklyCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_weekly forIndexPath:indexPath];
        [cell configWithModel:activityType];
        [cell strokeChartWithModel:activityType];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return;
    }
    
    if (_type < 2) {
        return;
    }
    
    ActivityType *activityType = _sourceArray[indexPath.row - 1];
    
    ActivityRecordTypeListController *typeListController = [[ActivityRecordTypeListController alloc] init];
    typeListController.title = activityType.name;
    typeListController.userId = _params[@"userId"];
    typeListController.typeId = activityType.id;
    typeListController.sourceArray = activityType.activitiesArray;
    [self.navigationItem setBackBarButtonItem:[UIBarButtonItem itemWithBtnTitle:@"活动记录" target:nil action:nil]];
    [self.navigationController pushViewController:typeListController animated:YES];
}

#pragma mark - setters and getters
- (void)setCurIndex:(NSInteger)curIndex {
    if (_curIndex == curIndex)
        return;
    
    _curIndex = curIndex;
    
    if (!_curIndex) {
        AddressBook *item = _usersArray.firstObject;
        [_params setObject:item.id forKey:@"userId"];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonPress)];
    }else {
        [_params setObject:KAppDelegateAccessor.moudle.userId forKey:@"userId"];
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithIcon:@"menu_showMore" showBadge:YES target:self action:@selector(showMoreButtonPress)];
    }
    
    [self sendRequestForList];
}

- (void)setType:(NSInteger)type {
    if (_type == type)  return;
    
    UIButton *button = (UIButton*)[_toolBar viewWithTag:kTag_button + _type];
    [button setSelected:NO];
    
    button = (UIButton*)[_toolBar viewWithTag:kTag_button + type];
    [button setSelected:YES];
    
    _type = type;
    
    [_params setObject:@(_type) forKey:@"type"];
    [self sendRequestForList];
}

- (CustomTitleView*)customTitleView {
    if (!_customTitleView) {
        _customTitleView = [[CustomTitleView alloc] init];
        _customTitleView.cellType = CellTypeOnlyName;
        _customTitleView.superViewController = self;
        _customTitleView.sourceArray = [[NSMutableArray alloc] initWithArray:@[@"全部活动记录", @"我的活动记录"]];
        _customTitleView.index = 0;
    }
    return _customTitleView;
}

- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height  - 44) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[ActivityRecordTitleCell class] forCellReuseIdentifier:kCellIdentifier_title];
        [_tableView registerClass:[ActivityRecordDailyCell class] forCellReuseIdentifier:kCellIdentifier_daily];
        [_tableView registerClass:[ActivityRecordWeeklyCell class] forCellReuseIdentifier:kCellIdentifier_weekly];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
        _tableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    }
    return _tableView;
}

- (ActivityRecHeaderView*)headerView {
    if (!_headerView) {
        _headerView = [[ActivityRecHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kHeight_headerView)];
    }
    return _headerView;
}

- (UIToolbar*)toolBar {
    if (!_toolBar) {
        _toolBar = [[UIToolbar alloc] init];
        [_toolBar setY:kScreen_Height - 44.0f];
        [_toolBar setWidth:kScreen_Width];
        [_toolBar setHeight:44.0f];
        
        UIBarButtonItem *todayItem = [[UIBarButtonItem alloc] initWithCustomView:[self buttonWithTitle:@"今日" tag:0]];
        UIBarButtonItem *yesterdayItem = [[UIBarButtonItem alloc] initWithCustomView:[self buttonWithTitle:@"昨日" tag:1]];
        UIBarButtonItem *weekItem = [[UIBarButtonItem alloc] initWithCustomView:[self buttonWithTitle:@"本周" tag:2]];
        UIBarButtonItem *lastWeekItem = [[UIBarButtonItem alloc] initWithCustomView:[self buttonWithTitle:@"上周" tag:3]];
        //        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        _toolBar.items = @[todayItem, yesterdayItem, weekItem, lastWeekItem];
        //        _toolBar.items = @[todayItem, spaceItem, yesterdayItem, spaceItem, weekItem, spaceItem, lastWeekItem];
    }
    return _toolBar;
}

- (CustomActionSheet*)actionSheet {
    if (!_actionSheet) {
        _actionSheet = [[CustomActionSheet alloc] init];
    }
    return _actionSheet;
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
