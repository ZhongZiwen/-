//
//  ActivityRecSearchResultController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/17.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ActivityRecSearchResultController.h"
#import "ActivityRecordTitleCell.h"
#import "ActivityRecordDailyCell.h"
#import "ActivityRecordWeeklyCell.h"
#import "ActivityRecHeaderView.h"
#import "AddressBook.h"

#define kCellIdentifier_title @"ActivityRecordTitleCell"
#define kCellIdentifier_daily @"ActivityRecordDailyCell"
#define kCellIdentifier_weekly @"ActivityRecordWeeklyCell"
#define kHeight_headerView 100

@interface ActivityRecSearchResultController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) ActivityRecHeaderView *headerView;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (assign, nonatomic) BOOL isDaily;

- (void)sendRequestForList;
@end

@implementation ActivityRecSearchResultController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _sourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    _isDaily = NO;
    if ([NSDate daysOffsetBetweenStartDate:_startDate endDate:_endDate] == 0 || [NSDate daysOffsetBetweenStartDate:_startDate endDate:_endDate] > 7) {
        _isDaily = YES;
    }
    
    @weakify(self);
    self.headerView.iconViewClickedBlock = ^(NSInteger tag) {
        @strongify(self);
        AddressBook *item = self.usersArray[tag];
        [self.params setObject:item.id forKey:@"userId"];
        
        [self sendRequestForList];
    };

    [self sendRequestForList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
- (void)sendRequestForList {
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_ActivityRecord_List_WithParams:_params block:^(id data, NSError *error) {
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

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath.row) {
        return [ActivityRecordTitleCell cellHeight];
    }
    
    if (_isDaily) {
        return [ActivityRecordDailyCell cellHeight];
    }
    
    return [ActivityRecordWeeklyCell cellHeight];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHeight_headerView;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        ActivityRecordTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_title forIndexPath:indexPath];
        [cell configWithStartDate:_startDate endDate:_endDate];
        return cell;
    }
    
    ActivityType *activityType = _sourceArray[indexPath.row - 1];
    if (_isDaily) {
        ActivityRecordDailyCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_daily forIndexPath:indexPath];
        cell.popBlock = ^{
            
        };
        [cell configWithModel:activityType];
        return cell;
    }
    
    ActivityRecordWeeklyCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_weekly forIndexPath:indexPath];
    [cell configWithModel:activityType];
    [cell strokeChartWithModel:activityType];
    return cell;
}

//21世纪人与人交流最重要的是什么？ 表情包。古人以文会友，我们以图会友。的确，没有表情的聊天，
#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[ActivityRecordTitleCell class] forCellReuseIdentifier:kCellIdentifier_title];
        [_tableView registerClass:[ActivityRecordDailyCell class] forCellReuseIdentifier:kCellIdentifier_daily];
        [_tableView registerClass:[ActivityRecordWeeklyCell class] forCellReuseIdentifier:kCellIdentifier_weekly];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (ActivityRecHeaderView*)headerView {
    if (!_headerView) {
        _headerView = [[ActivityRecHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kHeight_headerView)];
        [_headerView configWithArray:_usersArray showMoreButton:NO];
    }
    return _headerView;
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
