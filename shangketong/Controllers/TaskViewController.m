//
//  TaskViewController.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TaskViewController.h"
#import "UIViewController+NavDropMenu.h"
#import "UIView+Common.h"
#import "NSDate+Utils.h"
#import "TaskNewViewController.h"
#import "TaskTableViewCell.h"
#import "TaskMember.h"
#import "XLFTaskDetailViewController.h"
#import "AFNHttp.h"
#import "CommonConstant.h"
#import <MBProgressHUD.h>
#import "CommonFuntion.h"
#import "MJRefresh.h"
#import "ChineseToPinyin.h"
#import "pinyin.h"
#import "PinYin4Objc.h"
#import "ScheduleNewViewController.h"

#import "Select_Table_View.h"
#import "CommonNoDataView.h"

#define kCellIdentifier @"TaskTableViewCell"

@interface TaskViewController ()<UITableViewDataSource, UITableViewDelegate, TaskTableViewCellDelegate, UISearchBarDelegate, UISearchDisplayDelegate,SWTableViewCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *sourceArray;
@property (nonatomic, assign) NSInteger sourceType; 
@property (nonatomic, assign) NSInteger oldTag;
@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, strong) TaskMember *item;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) NSMutableArray *resultsArray; //存储搜索结果
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;

@end

@implementation TaskViewController

- (void)customDataSource:(NSDictionary *)dictionary {
    NSLog(@"%ld", [[dictionary objectForKey:@"taskMembers"] count]);
     self.sourceArray = [NSMutableArray arrayWithCapacity:0];
    
    [_sourceArray removeAllObjects];
    
    NSMutableArray *overdue = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *wait = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *today = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *tomorrow = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *future = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *refuseArr = [NSMutableArray arrayWithCapacity:0];
    
    if (_sourceType == 1) {
        //做倒序处理
        NSArray *array = [dictionary objectForKey:@"finishedTasks"];
        if (array) {
            NSArray *newArray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [[obj2 objectForKey:@"date"] compare:[obj1 objectForKey:@"date"]];
            }];
            
            for (NSDictionary *dic in newArray) {
                TaskMember *item = [TaskMember initWithDictionary:dic];
                [_sourceArray addObject:item];
            }
        }
        
    } else {
        if ([dictionary objectForKey:@"taskMembers"]) {
            //做倒序处理
            NSArray *array = [dictionary objectForKey:@"taskMembers"];
            
            NSArray *newArray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [[obj2 objectForKey:@"date"] compare:[obj1 objectForKey:@"date"]];
            }];
              for (NSDictionary *dic in newArray) {
                TaskMember *item = [TaskMember initWithDictionary:dic];
                // 1 2 3 4 5 6
                //今天 明天 将来 已过期 待接收 被拒绝
                if (item.taskStatus == 1) {
                    [today addObject:item];
                } else if (item.taskStatus == 2) {
                    [tomorrow addObject:item];
                } else if (item.taskStatus == 3) {
                    [future addObject:item];
                } else if (item.taskStatus == 4) {
                    [overdue addObject:item];
                } else if (item.taskStatus == 5) {
                    [wait addObject:item];
                } else if (item.taskStatus == 6) {
                    [refuseArr addObject:item];
                }
            }
        }
    }
    
    if (overdue.count) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"name" : @"已过期",
                                                                                    @"open" : @(NO),
                                                                                    @"source" : overdue}];
        [_sourceArray addObject:dict];
    }
    
    if (wait.count) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"name" : @"待接受",
                                                                                    @"open" : @(NO),
                                                                                    @"source" : wait}];
        [_sourceArray addObject:dict];
    }
    if (refuseArr.count) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"name" : @"被拒绝",
                                                                                    @"open" : @(NO),
                                                                                    @"source" : refuseArr}];
        [_sourceArray addObject:dict];
    }
    
    if (today.count) {
        self.isOpen = YES;
        self.oldTag = _sourceArray.count;
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"name" : @"今天",
                                                                                    @"open" : @(YES),
                                                                                    @"source" : today}];
        [_sourceArray addObject:dict];
    } else {
        self.isOpen = NO;
    }
    
    if (tomorrow.count) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"name" : @"明天",
                                                                                    @"open" : @(NO),
                                                                                    @"source" : tomorrow}];
        [_sourceArray addObject:dict];
    }
    
    if (future.count) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"name" : @"将来",
                                                                                    @"open" : @(NO),
                                                                                    @"source" : future}];
        [_sourceArray addObject:dict];
    }
    
    if (_sourceArray && _sourceArray.count == 0) {
        if (_sourceType == 0) {
            [self setViewNoData:@"待办任务"];
        } else {
            [self setViewNoData:@"已完成任务"];
        }
        
    } else {
        [self clearViewNoData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViewForSearchBar];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTaskPress)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    NSArray *array = [NSArray new];
    if (_flag_type == TaskViewTypeNormal) {
         array = @[@"待办任务", @"已完成的任务"];
    } else {
         array = @[@"待办日程任务", @"已完成的日程任务"];
    }
    
    [self customDownMenuWithType:TableViewCellTypeDefault andSource:array andDefaultIndex:0 andBlock:^(NSInteger index) {
        self.sourceType = index;
        [_sourceArray removeAllObjects];
        [self getDataSourceForTask];
        [_tableView reloadData];
    }];
    
    [self.view addSubview:self.tableView];
    ///添加上拉和下拉
    [self setupRefresh];
    
    self.sourceArray = 0;
    self.isOpen = NO;   // 如果今天没数据，默认为不显示
    [self getDataSourceForTask];
    
}
- (void)initViewForSearchBar {
    _resultsArray = [NSMutableArray arrayWithCapacity:0];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 30)];
    _searchBar.placeholder = @"待办任务";
    _searchBar.backgroundColor = COMM_SEARCHBAR_BACKGROUNDCOLOR;
    [_searchBar setBackgroundColor:COMM_SEARCHBAR_BACKGROUNDCOLOR];
    [_searchBar setBackgroundImage:[CommonFuntion createImageWithColor:COMM_SEARCHBAR_BACKGROUNDCOLOR]];
    _searchBar.delegate = self;
    [_searchBar sizeToFit];

    _searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    _searchController.delegate = self;
    _searchController.searchResultsDelegate = self;
    _searchController.searchResultsDataSource = self;
    _searchController.searchResultsTableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    _searchController.searchResultsTableView.frame = CGRectMake(0, 64, kScreen_Width, kScreen_Height - 64);
    _searchController.searchBar.tintColor = LIGHT_BLUE_COLOR;
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

#pragma mark - event response
- (void)addTaskPress {
    if (_flag_type == TaskViewTypeNormal) {
        TaskNewViewController *newTaskController = [[TaskNewViewController alloc] init];
        newTaskController.title = @"新建任务";
        __weak typeof(self) weak_self = self;
        newTaskController.refreshBlock = ^{
            [weak_self getDataSourceForTask];
        };
        [self.navigationController pushViewController:newTaskController animated:YES];
    } else {
        [self addSelectView];
    }
    
}
- (void)addSelectView {
    NSArray *array = @[@"新建跟进任务", @"新建日程"];
    Select_Table_View *selectView = [[Select_Table_View alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) dataArray:array];
    
    __weak typeof(self) weak_self = self;
    __weak typeof(selectView) weak_selectView = selectView;
    selectView.BackIndexBlock = ^(NSInteger index) {
        //根据返回不同的下标进行不同的事件处理
        [weak_self pushDifferenceController:index];
        [weak_selectView removeFromSuperview];
    };
    selectView.RemoveViewBlock = ^(){
        //移除视图
        [weak_selectView removeFromSuperview];
    };
    selectView.backgroundColor = [UIColor clearColor];
    [self.view.window addSubview:selectView];
}
- (void)pushDifferenceController:(NSInteger)index {
    switch (index) {
        case 0:
        {
            TaskNewViewController *taskController = [[TaskNewViewController alloc] init];
            taskController.refreshBlock = ^(){
                
            };
            [self.navigationController pushViewController:taskController animated:YES];
        }
            break;
        case 1:
        {
            ScheduleNewViewController *scheduleController = [[ScheduleNewViewController alloc] init];
            [self.navigationController pushViewController:scheduleController animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)headerViewTap:(UITapGestureRecognizer*)sender {
    UIView *view = sender.view;
    if (self.isOpen) {
        
        if (self.oldTag == view.tag) {  // 点击展开的section，关闭
            [self animationRowsWithSectionTag:view.tag complete:^{
                self.isOpen = NO;
            }];
        }else {
            [self animationRowsWithSectionTag:self.oldTag complete:^{
                [self animationRowsWithSectionTag:view.tag complete:^{

                }];
            }];
        }
        
    }else {
        [self animationRowsWithSectionTag:view.tag complete:^{
            self.isOpen = YES;
        }];
    }
    
    self.oldTag = view.tag;
}

- (void)animationRowsWithSectionTag:(NSInteger)tag complete:(void(^)())complete {
    
    // 更新数据源
    NSMutableDictionary *dict = _sourceArray[tag];
    [dict setValue:@(!([[dict objectForKey:@"open"] boolValue])) forKey:@"open"];
    
    // 刷新指定section
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:tag];
    [_tableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
    
    complete();
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        if (_sourceType == 0) {
            return _sourceArray.count;
        }else {
            return 1;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_resultsArray count];
    } else {
        if (_sourceType == 0) {
            NSDictionary *dict = _sourceArray[section];
            if ([[dict objectForKey:@"open"] boolValue]) {
                return [[dict objectForKey:@"source"] count];
            }else {
                return 0;
            }
        }else {
            return _sourceArray.count;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchController.searchResultsTableView) {
        return 0;
    }
    if (_sourceType == 0) {
        return 60.0f;
    }else {
        return 0;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (tableView == self.searchController.searchResultsTableView) {
        return nil;
    }
    if (_sourceType == 1)
        return nil;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 60)];
    view.backgroundColor = [UIColor whiteColor];
    view.tag = section;
    NSLog(@"===%ld", view.tag);
    [view addLineUp:NO andDown:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewTap:)];
    [view addGestureRecognizer:tap];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 60)];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    titleLabel.textColor = (section == 1 ? [UIColor colorWithHexString:@"f2ba33"] : kTitleColor);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = [_sourceArray[section] objectForKey:@"name"];
    [view addSubview:titleLabel];
    
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - 20 - 100, 0, 100, 60)];
    detailLabel.font = [UIFont systemFontOfSize:14];
    detailLabel.textColor = [UIColor lightGrayColor];
    detailLabel.textAlignment = NSTextAlignmentRight;
    detailLabel.text = [NSString stringWithFormat:@"%ld", [[_sourceArray[section] objectForKey:@"source"] count]];
    [view addSubview:detailLabel];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TaskTableViewCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[TaskTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    if (tableView == self.searchController.searchResultsTableView) {
        _item = _resultsArray[indexPath.row];
        [cell configWithItem:_item];
        return cell;
    }
//    TaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    if (_sourceType == 0) {
        _item = [_sourceArray[indexPath.section] objectForKey:@"source"][indexPath.row];
        NSLog(@"%@", _item.taskName);
        [cell configWithItem:_item];
    }else {
        _item = (TaskMember*)_sourceArray[indexPath.row];
        NSLog(@"%@", _sourceArray);
        [cell configWithItem:_item];
    }
    cell.delegate = self;
    return cell;
}

/*
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    long long userID = _item.creatByUID;
 
//     任务----不同身份操作权限
//     创建人：删除，完成，重启，修改详情中的所有内容
//     负责人：接受，拒绝，完成，重启，修改除负责人之外的所有信息
//     参与人：退出任务
//     
//     日程----不同身份操作权限
//     创建人：修改所有字段
//     参与人：接受，拒绝，修改除参与人之外的任何字段，退出日程
 

    if (userID == [appDelegateAccessor.moudle.userId longLongValue]) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskMember *model = [[TaskMember alloc] init];
    if (_sourceType == 0) {
        model = [_sourceArray[indexPath.section] objectForKey:@"source"][indexPath.row];
        NSLog(@"%@", model.taskName);
    }else {
        model = (TaskMember*)_sourceArray[indexPath.row];
        NSLog(@"%@", _sourceArray);
    }
    [self deleteOrChangeOneTask:[model.taskID longLongValue] url:GET_OFFICE_TASK_DELETE];
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TaskMember *item;
    if (tableView == self.searchController.searchResultsTableView) {
        item = _resultsArray[indexPath.row];
    } else {
        if (_sourceType == 0) {
            item = ([_sourceArray[indexPath.section] objectForKey:@"source"])[indexPath.row];
            NSLog(@"%@", item.taskName);
        }else {
            item = (TaskMember*)_sourceArray[indexPath.row];
        }
    }
    
    __weak typeof(self) weak_self = self;
    XLFTaskDetailViewController *taskDetailController = [[XLFTaskDetailViewController alloc] init];
    taskDetailController.title = @"任务详情";
    taskDetailController.uid = item.taskID;
    taskDetailController.RefreshTaskListBlock = ^() {
        [weak_self getDataSourceForTask];
    };
    [self.navigationController pushViewController:taskDetailController animated:YES];
}


///删除任务
-(void)deleteTask:(NSIndexPath *)indexPath{
    TaskMember *model = [[TaskMember alloc] init];
    if (_sourceType == 0) {
        model = [_sourceArray[indexPath.section] objectForKey:@"source"][indexPath.row];
        NSLog(@"%@", model.taskName);
    }else {
        model = (TaskMember*)_sourceArray[indexPath.row];
        NSLog(@"%@", _sourceArray);
    }
    [self deleteOrChangeOneTask:[model.taskID longLongValue] url:GET_OFFICE_TASK_DELETE];
}

///重启任务
-(void)resetTask:(NSIndexPath *)indexPath{
    TaskMember *model = [[TaskMember alloc] init];
    if (_sourceType == 0) {
        model = [_sourceArray[indexPath.section] objectForKey:@"source"][indexPath.row];
        NSLog(@"%@", model.taskName);
    }else {
        model = (TaskMember*)_sourceArray[indexPath.row];
        NSLog(@"%@", _sourceArray);
    }
    [self changOneTask:@"3" withTaskId:model.taskID];
}

///完成任务
-(void)overTask:(NSIndexPath *)indexPath{
    TaskMember *model = [[TaskMember alloc] init];
    if (_sourceType == 0) {
        model = [_sourceArray[indexPath.section] objectForKey:@"source"][indexPath.row];
        NSLog(@"%@", model.taskName);
    }else {
        model = (TaskMember*)_sourceArray[indexPath.row];
        NSLog(@"%@", _sourceArray);
    }
    [self changOneTask:@"2" withTaskId:model.taskID];
}



#pragma mark - SWTableViewCellDelegate
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    [cell hideUtilityButtonsAnimated:YES];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
   
    NSLog(@"index:%ti",index);
    NSLog(@"indexPath section:%ti   row:%ti",indexPath.section,indexPath.row);
    
    UIButton *btn =  (UIButton*)[cell.rightUtilityButtons objectAtIndex:index];
    NSString *btnActionTitle = btn.titleLabel.text;
    NSLog(@"btn  title:%@",btnActionTitle);
    
    if ([btnActionTitle isEqualToString:@"删除"]) {
        [self deleteTask:indexPath];
    }else if ([btnActionTitle isEqualToString:@"完成"]) {
        [self overTask:indexPath];
    }else if ([btnActionTitle isEqualToString:@"重启"]) {
        [self resetTask:indexPath];
    }
}

#pragma mark - setters and getters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.tableHeaderView = _searchBar;
        [_tableView registerClass:[TaskTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        _tableView.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
        _tableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    }
    return _tableView;
}
#pragma mark - 获取待办任务列表数据
- (void)getDataSourceForTask {
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
//    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
//    [CommonFuntion showHUD:@"正在加载" andView:self.tableView andHUD:hud];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    NSString *action = @"";
    if (_sourceType == 1) {
        action = GET_OFFICE_TASK_FINISH;
    } else {
        action = GET_OFFICE_TASK_TODO;
        [params setValue:@"1" forKey:@"pageSize"];
    }
    __weak typeof(self) weak_self = self;
    [AFNHttp get:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, action] params:nil success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@"responseObj---:%@", responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            [self customDataSource:responseObj];
            [weak_self.tableView reloadData];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getDataSourceForTask];
            };
            [comRequest loginInBackground];
        } else{
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            kShowHUD(desc,nil);
        }
        [weak_self reloadRefeshView];
    } failure:^(NSError *error) {
        [hud hide:YES];
        kShowHUD(NET_ERROR,nil);
        NSLog(@"error---:%@", error);
        [weak_self reloadRefeshView];
    }];
}

#pragma mark -- delete Or Change tasks
- (void)deleteOrChangeOneTask:(long long)taskID url:(NSString *)action {
    //添加两个变量 用来存储 taskID 和 action
    long long saveTaskID = taskID;
    NSString *saveAction = action;
    
//    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.tableView addSubview:hud];
//    [hud show:YES];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:[NSString stringWithFormat:@"%lld", taskID] forKey:@"taskId"];
    if ([action isEqualToString:GET_OFFICE_TASK_CHANGE]) {
        NSInteger status;
        if (_sourceType == 1) {
            status = 3;
        } else {
            status = 2;
        }
        [params setObject:[NSString stringWithFormat:@"%ld", status] forKey:@"status"];
    }
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, action] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@"操作成功:%@", responseObj);
        if ([[responseObj objectForKey:@"status"] integerValue] == 0) {
            NSLog(@"%@", [responseObj objectForKey:@"desc"]);
            [self getDataSourceForTask];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self deleteOrChangeOneTask:saveTaskID url:saveAction];
            };
            [comRequest loginInBackground];
        } else{
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            kShowHUD(desc,nil);
        }
        [_tableView reloadData];
    } failure:^(NSError *error) {
        [hud hide:YES];
        NSLog(@"操作失败: %@", error);
    }];

}
- (void)getTasksIDForChange:(long long)taskID {
    [self deleteOrChangeOneTask:taskID url:GET_OFFICE_TASK_CHANGE];
}
#pragma mark - SearchDisplayController Delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    //    searchOrNot = YES;
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self searhAddress:searchString];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{

}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = YES;
    NSLog(@"%@", [self.searchBar.subviews[0] subviews]);
    for(id cc in [self.searchBar.subviews[0] subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            [btn setTitle:@"取消"  forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        if([cc isKindOfClass:[UITextField class]])
        {
            UITextField *txt = (UITextField *)cc;
            txt.placeholder = @"待办任务";
        }
    }
}
- (void)searhAddress:(NSString *)searchText {
    NSLog(@"搜索文本%@", searchText);
    _searchController.searchResultsTableView.frame = CGRectMake(0, 64, kScreen_Width, kScreen_Height);
    UIView *Vv = [[UIView alloc] initWithFrame:CGRectZero];
    [_searchController.searchResultsTableView setTableFooterView:Vv];
    
    [_resultsArray removeAllObjects];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    if (_sourceType == 1) {
        [array addObjectsFromArray:_sourceArray];
    } else {
        for (NSDictionary *dict in _sourceArray) {
            for (TaskMember *model in [dict objectForKey:@"source"]) {
                [array addObject:model];
            }
        }
    }
    
    for (int i = 0; i < array.count; i++) {
        _item = array[i];
        NSString *taskName = _item.taskName;
        NSString *pinyinName = [ChineseToPinyin pinyinFromChiniseString:taskName];
        NSLog(@"%@", pinyinName);
        if([self searchResult:pinyinName searchText:searchText])
        {
            [_resultsArray addObject:_item];
        } else {
            NSString *chineseName = [self namToPinYinFisrtNameWith:taskName];
            if([self searchResult:chineseName searchText:searchText]){
                [_resultsArray addObject:_item];
            } else if([self searchResult:taskName searchText:searchText]){
                [_resultsArray addObject:_item];
            } else {
                
            }
        }
    }
}

- (NSString *)namToPinYinFisrtNameWith:(NSString *)name
{
    NSString * outputString = @"";
    for (int i =0; i<[name length]; i++) {
        outputString = [NSString stringWithFormat:@"%@%c",outputString,pinyinFirstLetter([name characterAtIndex:i])];
    }
    return outputString;
    
}

-(BOOL)searchResult:(NSString *)contactName searchText:(NSString *)searchT{
    if (contactName==nil || searchT == nil || (id)contactName == [NSNull null] || [contactName isEqualToString:@"(null)"] || [contactName isEqualToString:@"<null>"]) {
        return NO;
    }
    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    NSRange productNameRange = NSMakeRange(0, contactName.length);
    NSRange foundRange = [contactName rangeOfString:searchT options:searchOptions range:productNameRange];
    if (foundRange.length > 0)
        return YES;
    else
        return NO;
}

#pragma mark -  上拉加载 下来刷新
//集成刷新控件
- (void)setupRefresh
{
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"taskList"];
    //上拉加载更多(进入刷新状态就会调用self的footerRereshing)
//    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 自动刷新(一进入程序就下拉刷新)
    //    [self.tableviewCampaign headerBeginRefreshing];
}

// 结束加载
-(void)reloadRefeshView{
    // 刷新列表
    [self.tableView reloadData];
    [self.tableView footerEndRefreshing];
    [self.tableView headerEndRefreshing];
}

// 下拉
- (void)headerRereshing
{
    NSLog(@"headerRereshing--下拉-->");
    
    if ([self.tableView isFooterRefreshing]) {
        [self.tableView headerEndRefreshing];
        return;
    }
    [self getDataSourceForTask];
}

// 上拉
- (void)footerRereshing
{
    NSLog(@"footerRereshing--上拉-->");
    
    if ([self.tableView isHeaderRefreshing]) {
        [self.tableView footerEndRefreshing];
        return;
    }
    [self getDataSourceForTask];
}
#pragma mark - 没数据UI
-(void)setViewNoData:(NSString *)textString {
    if (self.commonNoDataView == nil) {
        self.commonNoDataView = [CommonFuntion commonNoDataViewIcon:@"list_empty.png" Title:[NSString stringWithFormat:@"暂无%@", textString] optionBtnTitle:@""];
    }
    [self.tableView addSubview:self.commonNoDataView];
}

-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
    }
}


#pragma mark - 完成/重启  2完成  3重启
- (void)changOneTask:(NSString *)type withTaskId:(NSString *)taskId{
    __weak typeof(self) weak_self = self;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:taskId forKey:@"taskId"];
    [params setObject:type forKey:@"status"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, GET_OFFICE_TASK_CHANGE] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@"操作成功:%@", responseObj);
        if ([[responseObj objectForKey:@"status"] integerValue] == 0) {
            NSLog(@"%@", [responseObj objectForKey:@"desc"]);
            [weak_self getDataSourceForTask];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self changOneTask:type withTaskId:taskId];
            };
            [comRequest loginInBackground];
        }else{
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if (desc && desc.length > 0) {
                kShowHUD(desc,nil);
            }
        }
    } failure:^(NSError *error) {
        [hud hide:YES];
        kShowHUD(NET_ERROR,nil);
        NSLog(@"操作失败: %@", error);
    }];
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
