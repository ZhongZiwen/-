
//
//  MsgRemindViewController.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MsgRemindViewController.h"
#import "MsgRemindCell.h"
#import "RemindModel.h"
#import "Approval.h"
#import "WorkReportItem.h"
#import "XLFTaskDetailViewController.h"
#import "WorkReportDetailViewController.h"
#import "AFNHttp.h"
#import "CommonFuntion.h"
#import "ScheduleDetailViewController.h"
#import "ApprovalDetailViewController.h"
#import "MJRefresh.h"
#import "CommonNoDataView.h"

#import "CommonUnReadNumberUtil.h"

#define kCellIdentifier @"MsgRemindCell"

@interface MsgRemindViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>{
    NSInteger pageNo;//页码
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *sourceArray;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) NSMutableArray *arrayOldData;
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@end

@implementation MsgRemindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customNavRightItem];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupRefresh];
    pageNo = 1;
    _sourceArray = [NSMutableArray arrayWithCapacity:0];
    _arrayOldData = [NSMutableArray arrayWithCapacity:0];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    UIView *V = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:V];
    
    
    [self getDataSourceFromSever];
    [self.view addSubview:self.tableView];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_unReadCount > 0) {
        [self creatNarCountLabel];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_countLabel removeFromSuperview];
}


///创建导航栏数字控件
-(void)creatNarCountLabel{
    _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width / 2 + 25, 12, 20, 20)];
    _countLabel.backgroundColor = [UIColor colorWithHexString:@"f74c31"];
    _countLabel.textColor = [UIColor whiteColor];
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.font = [UIFont systemFontOfSize:12];
    _countLabel.layer.masksToBounds = YES;
    _countLabel.layer.cornerRadius = 10;
    _countLabel.text = [NSString stringWithFormat:@"%ld", _unReadCount];
    if (_unReadCount > 99) {
        _countLabel.frame = CGRectMake(kScreen_Width / 2 + 30, 12, 30, 20);
    }
    [self.navigationController.navigationBar addSubview:_countLabel];
}

- (void)customNavRightItem {
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController)];
    leftItem.imageInsets = UIEdgeInsetsMake(0, -10, 0,0);
    self.navigationItem.leftBarButtonItem = leftItem;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_showMore"] style:UIBarButtonItemStylePlain target:self action:@selector(showAllReadActionSheet)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}
- (void)popViewController {
    [_countLabel removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)showAllReadActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"全部已读", nil];
    [actionSheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self changeAllDataSourceToIsRead];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 获取列表数据
- (void)getDataSourceFromSever {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:appDelegateAccessor.window];
    [appDelegateAccessor.window addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:@(pageNo) forKey:@"pageNo"];
    [params setObject:@"20" forKey:@"pageSize"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, GET_WAIT_REMINDS] params:params success:^(id responseObj) {
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            if ([responseObj objectForKey:@"reminds"]) {
                [self changeDataSourceType:[responseObj objectForKey:@"reminds"]];
            }
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getDataSourceFromSever];
            };
            [comRequest loginInBackground];
        }
        [hud hide:YES];
        [self reloadRefeshView];
        [_tableView reloadData];
    } failure:^(NSError *error) {
        [hud hide:YES];
        [self reloadRefeshView];
    }];
}
- (void)changeDataSourceType:(NSArray *)dataArray {
    if(pageNo == 1)
    {   [_arrayOldData removeAllObjects];
        [_sourceArray removeAllObjects];
    }
    [_arrayOldData addObjectsFromArray:dataArray];
    NSMutableArray *unReadArray = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *dict in dataArray) {
        RemindModel *model = [[RemindModel alloc] initWithDictionary:dict];
        if ([model.isRead isEqualToString:@"1"]) {
            [unReadArray addObject:model.isRead];
        }
        [_sourceArray addObject:model];
    }
    if (_unReadCount > 0) {
        _countLabel.hidden = NO;
        _countLabel.text = [NSString stringWithFormat:@"%ld", _unReadCount];
    } else {
        _countLabel.hidden = YES;
    }

    ///有数据返回
    if (dataArray && [dataArray count] > 0) {
        ///页码++
        [self clearViewNoData];
        if ([dataArray count] == 20) {
            pageNo++;
        }else
        {
            ///隐藏上拉刷新
            [self.tableView setFooterHidden:YES];
        }
    
    }else{
        ///返回为空
        [self clearViewNoData];
        NSString *sting = @"暂无待办提醒";
        [self setViewNoData:sting];
        [self.tableView setFooterHidden:YES];
    }
}
#pragma mark - 改为已读
- (void)changeAllDataSourceToIsRead {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, GET_ALL_ISREAD] params:params success:^(id responseObj) {
        NSLog(@"----%@", responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            //修改成功之后重新读取数据
            pageNo = 1;
            _unReadCount = 0;
            self.navigationItem.rightBarButtonItem.enabled = NO;
            [self getDataSourceFromSever];
//            kShowHUD([responseObj objectForKey:@"desc"], nil);
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self changeAllDataSourceToIsRead];
            };
            [comRequest loginInBackground];
        }
    } failure:^(NSError *error) {
        NSLog(@"+++++%@", error);
    }];
}
- (void)changeOneDataSourceToIsRead:(NSString *)remindID {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:remindID forKey:@"id"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, GET_ONE_ISREAD] params:params success:^(id responseObj) {
        NSLog(@"----%@", responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            //修改成功之后重新读取数据
            pageNo = 1;
            if (_countLabel > 0) {
                _unReadCount --;
            } else {
                _countLabel = 0;
            }
            ///消息数--
            [CommonUnReadNumberUtil unReadNumberDecrease:1  number:1];
            [self getDataSourceFromSever];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self changeOneDataSourceToIsRead:remindID];
            };
            [comRequest loginInBackground];
        }
    } failure:^(NSError *error) {
        NSLog(@"+++++%@", error);
    }];
}
#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    RemindModel *model = _sourceArray[indexPath.row];
    return [MsgRemindCell cellHeightWithModel:model];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MsgRemindCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    RemindModel *model = self.sourceArray[indexPath.row];
    [cell configWithModel:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RemindModel *model = _sourceArray[indexPath.row];
    
    //先改变状态
    if ([model.isRead isEqualToString:@"1"]) {
        [self changeOneDataSourceToIsRead:model.remindID];
    }
    switch (model.m_type) {
        case RemindTypeApproval:    // 审批
        {
            if (_arrayOldData && [_arrayOldData count] > indexPath.row) {
                Approval *approval = [Approval initWithDictionary:_arrayOldData[indexPath.row]];
                approval.m_id = model.dataId;
                ApprovalDetailViewController *approvalController = [[ApprovalDetailViewController alloc] init];
                approvalController.title = @"审批明细";
                approvalController.approval = approval;
                [self.navigationController pushViewController:approvalController animated:YES];
            }
        }
            break;
        case RemindTypeSchedule:    // 日程
        {
            ScheduleDetailViewController *controller = [[ScheduleDetailViewController alloc] init];
            controller.title = @"日程详情";
            controller.scheduleId = model.dataId;
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case RemindTypeTask:        // 任务
        {
            XLFTaskDetailViewController *taskDetailController = [[XLFTaskDetailViewController alloc] init];
            taskDetailController.uid = [NSString stringWithFormat:@"%ld", model.dataId];
            taskDetailController.title = @"任务详情";
            [self.navigationController pushViewController:taskDetailController animated:YES];
        }
            break;
        case RemindTypeWorkreportDay:  // 日报
        {
            if (_arrayOldData && [_arrayOldData count] > indexPath.row) {
                WorkReportItem *workReportItem = [WorkReportItem initWithDictionary:_arrayOldData[indexPath.row]];
                workReportItem.m_reportTypeName = @"日报";
                workReportItem.m_reportTypeIndex = 0;
                workReportItem.m_reportType = @"dayReport";
                workReportItem.m_reportID = model.dataId;
                WorkReportDetailViewController *wrController = [[WorkReportDetailViewController alloc] init];
                wrController.curIndex = 1;
                wrController.reportItem = workReportItem;
                wrController.title = model.user_name;
                [self.navigationController pushViewController:wrController animated:YES];
            }
        }
            break;
        case RemindTypeWorkreportWeek:  //周报
        {
            if (_arrayOldData && [_arrayOldData count] > indexPath.row) {
                WorkReportItem *workReportItem = [WorkReportItem initWithDictionary:_arrayOldData[indexPath.row]];
                workReportItem.m_reportTypeName = @"周报";
                workReportItem.m_reportTypeIndex = 1;
                workReportItem.m_reportType = @"weekReport";
                workReportItem.m_reportID = model.dataId;
                WorkReportDetailViewController *wrController = [[WorkReportDetailViewController alloc] init];
                wrController.curIndex = 1;
                wrController.reportItem = workReportItem;
                wrController.title = model.user_name;
                [self.navigationController pushViewController:wrController animated:YES];
            }
        }
            break;
        case RemindTypeWorkreportMonth:  //月报
        {
            if (_arrayOldData && [_arrayOldData count] > indexPath.row) {
                WorkReportItem *workReportItem = [WorkReportItem initWithDictionary:_arrayOldData[indexPath.row]];
                workReportItem.m_reportTypeName = @"月报";
                workReportItem.m_reportTypeIndex = 2;
                workReportItem.m_reportType = @"monthReport";
                workReportItem.m_reportID = model.dataId;
                WorkReportDetailViewController *wrController = [[WorkReportDetailViewController alloc] init];
                wrController.curIndex = 1;
                wrController.reportItem = workReportItem;
                wrController.title = model.user_name;
                [self.navigationController pushViewController:wrController animated:YES];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[MsgRemindCell class] forCellReuseIdentifier:kCellIdentifier];
        _tableView.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
        _tableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 64, 0, 0)];
        
    }
    return _tableView;
}
#pragma mark -  上拉加载 下来刷新
//集成刷新控件
- (void)setupRefresh
{
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"taskList"];
    //上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    
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
    pageNo = 1;
    [self getDataSourceFromSever];
}

// 上拉
- (void)footerRereshing
{
    NSLog(@"footerRereshing--上拉-->");
    
    if ([self.tableView isHeaderRefreshing]) {
        [self.tableView footerEndRefreshing];
        return;
    }
    [self getDataSourceFromSever];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
