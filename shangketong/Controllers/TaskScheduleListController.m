//
//  TaskScheduleListController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TaskScheduleListController.h"
#import "CRM_ScheduleNewViewController.h"
#import "CRM_TaskNewViewController.h"
#import "ScheduleDetailViewController.h"
#import "XLFTaskDetailViewController.h"

#import "MJRefresh.h"
#import "PopoverView.h"
#import "PopoverItem.h"
#import "CustomTitleView.h"
#import "TaskScheduleListCell.h"

#import "TaskSchedule.h"
#import "TaskScheduleGroup.h"
#import "Schedule.h"
#import "Task.h"

#define kCellIdentifier @"TaskScheduleListCell"

@interface TaskScheduleListController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) CustomTitleView *navTitleView;

@property (assign, nonatomic) NSInteger navCurIndex;
@property (strong, nonatomic) TaskSchedule *taskSchedule;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@end

@implementation TaskScheduleListController

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = kView_BG_Color;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightButtonPress)];
    
    @weakify(self);
    self.navigationItem.titleView = self.navTitleView;
    _navTitleView.valueBlock = ^(NSInteger index) {
        @strongify(self);
        self.navCurIndex = index;
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
    
    // 默认加载待办日程任务
    _navCurIndex = 0;

    [self.view beginLoading];
    [self sendRequest];
    
    [_tableView addHeaderWithTarget:self action:@selector(sendRequestForRefresh)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
- (void)sendRequest {
    [[Net_APIManager sharedManager] request_Common_TaskSchedule_List_WithPath:_requestPath block:^(id data, NSError *error) {
        [self.view endLoading];
        [_tableView headerEndRefreshing];
        if (data) {
            TaskSchedule *item = [NSObject objectOfClass:@"TaskSchedule" fromJSON:data];
            for (NSDictionary *tempDict in data[@"schedules"]) {
                Schedule *schedule = [NSObject objectOfClass:@"Schedule" fromJSON:tempDict];
                [item configWithObj:schedule];
            }
            for (NSDictionary *tempDict in data[@"tasks"]) {
                Task *task = [NSObject objectOfClass:@"Task" fromJSON:tempDict];
                [item configWithObj:task];
            }
            
            _taskSchedule = item;
            [_taskSchedule removeGroupForEmpityArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        }
        [_tableView configBlankPageWithTitle:@"暂无待办日程任务" hasData:_taskSchedule.waitArray.count hasError:error != nil reloadButtonBlock:nil];
    }];
}

- (void)sendRequestForRefresh {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequest];
    });
}

#pragma mark - event response
- (void)rightButtonPress {
    NSArray *titlesArray = @[[PopoverItem initItemWithTitle:@"新建任务" image:nil target:self action:@selector(newTask)],
                             [PopoverItem initItemWithTitle:@"新建日程" image:nil target:self action:@selector(newSchedule)]];
    PopoverView *pop = [[PopoverView alloc] initWithImageItems:nil titleItems:titlesArray];
    [pop show];
}

- (void)headerButtonPress:(UIButton*)sender {
    
    if (_navCurIndex)
        return;
    
    for (int i = 0; i < _taskSchedule.waitArray.count; i ++) {
        TaskScheduleGroup *tempGroup = _taskSchedule.waitArray[i];
        if (i == sender.tag) {
            tempGroup.isShow = !tempGroup.isShow;
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationAutomatic];
        }else if (tempGroup.isShow) {
            tempGroup.isShow = !tempGroup.isShow;
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (void)newTask {
    CRM_TaskNewViewController *newController = [[CRM_TaskNewViewController alloc] init];
    newController.title = @"新建任务";
    newController.requestPath = _task_createPath;
    newController.refreshBlock = ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sendRequest];
        });
    };
    [self.navigationController pushViewController:newController animated:YES];
}

- (void)newSchedule {
    CRM_ScheduleNewViewController *newController = [[CRM_ScheduleNewViewController alloc] init];
    newController.title = @"新建日程";
    newController.requestPath = _schedule_createPath;
    newController.refreshBlock = ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sendRequest];
        });
    };
    [self.navigationController pushViewController:newController animated:YES];
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!_navCurIndex) {
        return _taskSchedule.waitArray.count;
    }
    
    TaskScheduleGroup *group = _taskSchedule.finishedArray.firstObject;
    return group.array.count ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    TaskScheduleGroup *group;
    if (!_navCurIndex) {
        group = _taskSchedule.waitArray[section];
        return group.isShow ? group.array.count : 0;
    }else {
        group = _taskSchedule.finishedArray[section];
        return group.array.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 54.0f;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [headerButton setHeight:53.5];
    headerButton.backgroundColor = kView_BG_Color;
//    [headerButton addLineUp:NO andDown:YES];
    headerButton.tag = section;
    [headerButton addTarget:self action:@selector(headerButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    
    TaskScheduleGroup *group = _navCurIndex ? _taskSchedule.finishedArray[section] : _taskSchedule.waitArray[section];

    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setX:15];
    [titleLabel setWidth:200];
    [titleLabel setHeight:54.0f];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor iOS7lightBlueColor];
    titleLabel.text = group.name;
    [headerButton addSubview:titleLabel];
    
    UILabel *countLabel = [[UILabel alloc] init];
    [countLabel setX:kScreen_Width - 15 - 64];
    [countLabel setWidth:64];
    [countLabel setHeight:54.0];
    countLabel.font = [UIFont systemFontOfSize:16];
    countLabel.textAlignment = NSTextAlignmentRight;
    countLabel.text = [NSString stringWithFormat:@"%d", group.array.count];
    [headerButton addSubview:countLabel];
    
    return headerButton;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TaskScheduleListCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskScheduleListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    TaskScheduleGroup *group = _navCurIndex ? _taskSchedule.finishedArray[indexPath.section] : _taskSchedule.waitArray[indexPath.section];

    [cell configWithObj:group.array[indexPath.row]];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:15.0f];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _selectedIndexPath = indexPath;
    
    TaskScheduleGroup *group = _navCurIndex ? _taskSchedule.finishedArray[indexPath.section] : _taskSchedule.waitArray[indexPath.section];

    id obj = group.array[indexPath.row];
    
    if ([obj isKindOfClass:[Task class]]) {
        Task *task = obj;
        XLFTaskDetailViewController *detailController = [[XLFTaskDetailViewController alloc] init];
        detailController.title = @"任务详情";
        detailController.uid = [NSString stringWithFormat:@"%@", task.id];
        detailController.RefreshTaskListBlock = ^{
            [self sendRequestForRefresh];
//            TaskScheduleGroup *group;
//            if (_navCurIndex) {
//                group = _taskSchedule.finishedArray[_selectedIndexPath.section];
//            }
//            else {
//                group = _taskSchedule.waitArray[_selectedIndexPath.section];
//            }
//            [group.array removeObjectAtIndex:_selectedIndexPath.row];
//            [_tableView deleteRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
        };
        [self.navigationController pushViewController:detailController animated:YES];
    }else if ([obj isKindOfClass:[Schedule class]]) {
        Schedule *schedule = obj;
        ScheduleDetailViewController *detailController = [[ScheduleDetailViewController alloc] init];
        detailController.scheduleId = [schedule.id integerValue];
        detailController.RefreshForPlanControllerBlock = ^{
            [self sendRequestForRefresh];
//            TaskScheduleGroup *group;
//            if (_navCurIndex) {
//                group = _taskSchedule.finishedArray[_selectedIndexPath.section];
//            }
//            else {
//                group = _taskSchedule.waitArray[_selectedIndexPath.section];
//            }
//            [group.array removeObjectAtIndex:_selectedIndexPath.row];
//            [_tableView deleteRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
        };
        [self.navigationController pushViewController:detailController animated:YES];
    }
}

#pragma mark - setters and getters
- (void)setNavCurIndex:(NSInteger)navCurIndex {
    if (_navCurIndex == navCurIndex) return;
    
    _navCurIndex = navCurIndex;
    
    [_tableView reloadData];
    
    if (_navCurIndex) {
        TaskScheduleGroup *group = _taskSchedule.finishedArray.firstObject;
        [_tableView configBlankPageWithTitle:@"暂无已完成日程任务" hasData:group.array.count hasError:NO reloadButtonBlock:nil];
    }else {
        [_tableView configBlankPageWithTitle:@"暂无待办日程任务" hasData:_taskSchedule.waitArray.count hasError:NO reloadButtonBlock:nil];
    }
}

- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setY:64];
        [_tableView setWidth:kScreen_Width];
        [_tableView setHeight:kScreen_Height - CGRectGetMinY(_tableView.frame)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[TaskScheduleListCell class] forCellReuseIdentifier:kCellIdentifier];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
        _tableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    }
    return _tableView;
}

- (CustomTitleView*)navTitleView {
    if (!_navTitleView) {
        _navTitleView = [[CustomTitleView alloc] init];
        _navTitleView.cellType = CellTypeOnlyName;
        _navTitleView.defalutTitleString = self.title;
        _navTitleView.superViewController = self;
        _navTitleView.sourceArray = [NSMutableArray arrayWithArray:@[@"待办日程任务", @"已完成的日程任务"]];
        _navTitleView.index = 0;
    }
    return _navTitleView;
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
