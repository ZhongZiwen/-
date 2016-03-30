//
//  MsgNotificationViewController.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/2.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MsgNotificationViewController.h"
#import "UIView+Common.h"
#import "RemindModel.h"
#import "MsgRemindCell.h"
#import "AFNHttp.h"
#import "AnnounceCell.h"
#import "AnnounceDetailsController.h"
#import "AnnounceModel.h"
#import "WorkGroupRecordCellA.h"
#import "WorkGroupRecordCellB.h"
#import "CommonStaticVar.h"
#import "XLFTaskDetailViewController.h"
#import "WorkGroupRecordDetailsViewController.h"
#import "WorkReportDetailViewController.h"
#import "ScheduleDetailViewController.h"
#import "ApprovalDetailViewController.h"
#import "InfoViewController.h"
#import "Approval.h"
#import "MJRefresh.h"
#import "DepartGroupModel.h"
#import "DepartViewController.h"
#import "KnowledgeFileDetailsViewController.h"
#import "MapViewViewController.h"
#import "ReleaseViewController.h"
#import "CommonModuleFuntion.h"
#import "ReportToServiceViewController.h"
#import "WorkGroupRecordViewController.h"

#import "ActivityDetailViewController.h"
#import "LeadDetailViewController.h"
#import "CustomerDetailViewController.h"
#import "ContactDetailViewController.h"
#import "OpportunityDetailController.h"
#import "Lead.h"
#import "Contact.h"
#import "Customer.h"
#import "SaleChance.h"
#import "AFSoundPlaybackHelper.h"
#import "DepartViewController.h"
#import "DepartGroupModel.h"
#import "ReportToServiceViewController.h"
#import "CommonNoDataView.h"
#import "PhotoBroswerVC.h"


#import "CommonUnReadNumberUtil.h"

typedef NS_ENUM(NSInteger, TableViewType) {
    TableViewTypeAbountMe = 200,      // 提到我的
    TableViewTypeNotice   = 201,      // 系统通知
    TableViewTypeAnnounce = 202       // 部门公告
};

#define kCellIdentifier_notice     @"MsgRemindCell"

@interface MsgNotificationViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, WorkGroupDelegate, UITabBarControllerDelegate, TTTAttributedLabelDelegate> {
    NSInteger abountMePage;  //提到我的页码
    NSInteger noticePage;    //系统通知页码
    NSInteger announcePage;  //部门公告页码
    
    ///标记删除操作
    NSInteger indexDelete;
    long long trendIdDelete;
    
    NSInteger firstRead; //第一次请求系统通知
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *abountSourceArray;        // 提到我的
@property (nonatomic, strong) NSMutableArray *noticeSourceArray;        // 系统通知
@property (nonatomic, strong) NSMutableArray *announceSourceArray;      // 部门公告
@property (nonatomic, assign) TableViewType tableViewType;
@property (nonatomic, strong) UIView *markView; //滚动线

@property (nonatomic, assign) PushControllerType sourceType;
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;


@property (nonatomic, strong) UILabel *systemLabel; //系统通知
@property (nonatomic, strong) UILabel *announLabel; // 部门公告
@end

@implementation MsgNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = TABLEVIEW_BG_COLOR;
    firstRead = 0; //第一次请求系统通知
    [self setupRefresh];
    
    self.abountSourceArray = [NSMutableArray arrayWithCapacity:0];
    self.noticeSourceArray = [NSMutableArray arrayWithCapacity:0];
    self.announceSourceArray = [NSMutableArray arrayWithCapacity:0];
    
    self.markView = [[UIView alloc] initWithFrame:CGRectZero];
    self.markView.backgroundColor = [UIColor colorWithHexString:@"09bb07"];
    [self.view addSubview:self.markView];
    
//    NSArray *menuArray = @[@"提到我的", @"系统通知", @"部门公告"];
    NSArray *menuArray = @[@"提到我的", @"系统通知"];
    for (int i = 0; i < menuArray.count; i ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((kScreen_Width / 2.0) * i, 64, kScreen_Width / 2.0, 44);
        button.tag = 200 + i;
        [button addLineUp:NO andDown:YES];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setTitle:menuArray[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(menuButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:button];
        if (i == 0) {
            self.markView.frame = CGRectMake(20, button.frame.origin.y + button.frame.size.height - 1.5, button.frame.size.width - 40, 1.5);
        } else if (i == 1) {
            if (_systemNoticeCount > 0) {
               _systemLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width / 2.0 - 25, 5, 20, 20)];
                _systemLabel.layer.cornerRadius = 10.0;
                _systemLabel.layer.masksToBounds = YES;
                _systemLabel.textAlignment = NSTextAlignmentCenter;
                _systemLabel.textColor = [UIColor whiteColor];
                _systemLabel.backgroundColor = [UIColor redColor];
                _systemLabel.font = [UIFont systemFontOfSize:11];
                [button addSubview:_systemLabel];
                _systemLabel.text = [NSString stringWithFormat:@"%ld", _systemNoticeCount];
                [button addSubview:_systemLabel];
            }
        } else {
            if (_announcementCount > 0) {
                _announLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width / 3.0 - 25, 5, 20, 20)];
                _announLabel.layer.cornerRadius = 10.0;
                _announLabel.layer.masksToBounds = YES;
                _announLabel.textAlignment = NSTextAlignmentCenter;
                _announLabel.textColor = [UIColor whiteColor];
                _announLabel.backgroundColor = [UIColor redColor];
                _announLabel.font = [UIFont systemFontOfSize:11];
                _announLabel.text = [NSString stringWithFormat:@"%ld", _announcementCount];
                [button addSubview:_announLabel];
            }
        }
    }
    
    abountMePage = 1;
    noticePage = 1;
    announcePage = 1;
    [self.view addSubview:self.tableView];
    
    // 默认列表为“提到我的”
    self.tableViewType = TableViewTypeAbountMe;
//    self.tableViewType = TableViewTypeNotice;
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 64, 0, 0)];
}
- (void)changeVeiwFrameX:(CGFloat)x {
    if (_tableViewType == TableViewTypeNotice) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 64, 0, 0)];
    } else {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.markView.frame = CGRectMake(x + 20, self.markView.frame.origin.y, self.markView.frame.size.width, self.markView.frame.size.height);
    }];
}
- (void)showAllReadActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"全部已读", nil];
    actionSheet.tag = 500;
    [actionSheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 500) {
        if (buttonIndex == 0) {
            [self changeAllRead];
        }
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [AFSoundPlaybackHelper stop_helper];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && [self.view window] == nil) {
        NSLog(@"--wg--didReceiveMemoryWarning----->");
        self.view = nil;
        ///清除图片相关缓存
        [[SDImageCache sharedImageCache] clearMemory];
        [[SDImageCache sharedImageCache] clearDisk];
    }
    // Dispose of any resources that can be recreated.
}
#pragma mark - 变未读为已读
- (void)changeAllRead {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, GET_ANNOUNCEMENT_ALL_ISREAD] params:params success:^(id responseObj) {
        NSLog(@"----%@", responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
//            [self getAllDataSourceFromSever:GET_ANNOUNCEMENT_LIST withPageNo:1];
            _systemNoticeCount = 0;
            _systemLabel.hidden = YES;
            
            announcePage = 1;
            [self getDataSourceWithType:_tableViewType];
            
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self changeAllRead];
            };
            [comRequest loginInBackground];
        }
    } failure:^(NSError *error) {
        
    }];
    
}




- (void)changeOneRead:(NSString *)oneId {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:oneId forKey:@"id"];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, GET_ANNOUNCEMENT_ONE_ISREAD] params:params success:^(id responseObj) {
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            [self getAllDataSourceFromSever:GET_ANNOUNCEMENT_LIST withPageNo:1];
        }
    } failure:^(NSError *error) {
        
    }];

}



#pragma mark - private method
- (void)getDataSourceWithType:(TableViewType)type {
    switch (type) {
        case TableViewTypeAbountMe:
        {
            [self getAllDataSourceFromSever:GET_AT_TO_ME withPageNo:abountMePage];
        }
            break;
        case TableViewTypeNotice:
        {
            [self getAllDataSourceFromSever:GET_ALL_NOTICE withPageNo:noticePage];
        }
            break;
        case TableViewTypeAnnounce:
        {
            [self getAllDataSourceFromSever:GET_ANNOUNCEMENT_LIST withPageNo:announcePage];
        }
            break;
        default:
            break;
    }
    [_tableView reloadData];
}
- (void)getAllDataSourceFromSever:(NSString *)action withPageNo:(NSInteger )pageNo {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:appDelegateAccessor.window];
    [appDelegateAccessor.window addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    __weak typeof(self) weak_self = self;
    [params setObject:[NSNumber numberWithInteger:pageNo] forKey:@"pageNo"];
    [params setObject:[NSNumber numberWithInt:20] forKey:@"pageSize"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, action] params:params success:^(id responseObj) {
        NSLog(@"responseObj:%@",responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            NSString *keyStr = @"";
            switch (_tableViewType) {
                case TableViewTypeAbountMe:
                    keyStr = @"snsComments";
                    break;
                case TableViewTypeAnnounce:
                    keyStr = @"announceMents";
                    break;
                case TableViewTypeNotice:
                    firstRead ++;
                    keyStr = @"notices";
                    break;
                    
                default:
                    break;
            }
            if ([responseObj objectForKey:keyStr]) {
                [self changeDataSourceType:[responseObj objectForKey:keyStr]];
            }
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getAllDataSourceFromSever:action withPageNo:pageNo];
            };
            [comRequest loginInBackground];
        }
        [hud hide:YES];
        [weak_self  reloadRefeshView];

    } failure:^(NSError *error) {
        [hud hide:YES];
        [weak_self  reloadRefeshView];
    }];
}
- (void)changeDataSourceType:(NSArray *)dataArray {

    if (_tableViewType == TableViewTypeNotice) {
        if (noticePage == 1) {
            [_noticeSourceArray removeAllObjects];
        }
        for (NSDictionary *dict in dataArray) {
            RemindModel *model = [[RemindModel alloc] initWithDictionary:dict];
            [_noticeSourceArray addObject:model];
        }
        ///有数据返回
        if (dataArray && [dataArray count] > 0) {
            ///页码++
            [self clearViewNoData];
            if ([dataArray count] == 20) {
                noticePage ++;
            }else
            {
                ///隐藏上拉刷新
                [self.tableView setFooterHidden:YES];
            }
            
        }else{
            ///返回为空
            [self clearViewNoData];
            NSString *string = @"暂无系统通知";
            [self setViewNoData:string];
            [self.tableView setFooterHidden:YES];
        }
    } else if (_tableViewType == TableViewTypeAbountMe) {
        if (abountMePage == 1) {
            [_abountSourceArray removeAllObjects];
        }
        
        for (NSDictionary *dict in dataArray) {
            if ([[dict objectForKey:@"type"] integerValue] == 2) {
                [_abountSourceArray addObject:[dict objectForKey:@"comment"]]; //objectForKey:@"commentFrom"]
            } else {
                [_abountSourceArray addObject:[dict objectForKey:@"sns"]];
            }
        }
        
        ///有数据返回
        if (dataArray && [dataArray count] > 0) {
            ///页码++
            [self clearViewNoData];
            if ([dataArray count] == 20) {
                abountMePage ++;
            }else
            {
                ///隐藏上拉刷新
                [self.tableView setFooterHidden:YES];
            }
            
        }else{
            ///返回为空
            [self clearViewNoData];
            NSString *string = @"暂无提到我的";
            [self setViewNoData:string];
            [self.tableView setFooterHidden:YES];
        }
    } else {
        if (announcePage == 1) {
            [_announceSourceArray removeAllObjects];
        }
        for (NSDictionary *dict in dataArray) {
            AnnounceModel *model = [[AnnounceModel alloc] initWithDictionary:dict];
            [_announceSourceArray addObject:model];
        }
        ///有数据返回
        if (dataArray && [dataArray count] > 0) {
            ///页码++
            [self clearViewNoData];
            if ([dataArray count] == 20) {
                announcePage ++;
            }else
            {
                ///隐藏上拉刷新
                [self.tableView setFooterHidden:YES];
            }
            
        }else{
            ///返回为空
            [self clearViewNoData];
            NSString *string = @"暂无部门公告";
            [self setViewNoData:string];
            [self.tableView setFooterHidden:YES];
        }
    }
}
#pragma mark - event response
- (void)menuButtonPress:(UIButton*)sender {
    self.tableViewType = sender.tag;
    [self changeVeiwFrameX:sender.frame.origin.x];
    if (_tableViewType == TableViewTypeAnnounce) {
        
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_showMore_active"] style:UIBarButtonItemStylePlain target:self action:@selector(showAllReadActionSheet)];
        self.navigationItem.rightBarButtonItem = rightItem;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_tableViewType == TableViewTypeAbountMe) {
        return _abountSourceArray.count;
    }
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (_tableViewType) {
        case TableViewTypeAbountMe:
            return 1;
            break;
        case TableViewTypeNotice:
            return _noticeSourceArray.count;
            break;
        case TableViewTypeAnnounce:
            return _announceSourceArray.count;
            break;
        default:
            return 0;
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_tableViewType == TableViewTypeAbountMe && section != 0) {
        return 15.0;
    }
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (_tableViewType) {
        case TableViewTypeAbountMe:
        {
            CGFloat height = 0;
            NSDictionary *item = _abountSourceArray[indexPath.section];
//            if ([[self.abountSourceArray[indexPath.row] objectForKey:@"type"] integerValue] == 2) {
//                item = [[self.abountSourceArray objectAtIndex:indexPath.section] objectForKey:@"comment"];
//            } else {
//                item = [[self.abountSourceArray objectAtIndex:indexPath.section] objectForKey:@"sns"];
//            }
            height = [WorkGroupRecordCellB getCellContentHeight:item byCellStatus:WorkGroupTypeStatusCell];
            return height;
        }
            break;
        case TableViewTypeNotice:
        {
            RemindModel *model = _noticeSourceArray[indexPath.row];
            return [MsgRemindCell cellHeightWithModel:model];
        }
            break;
        case TableViewTypeAnnounce:
        {
            return 54.0f;
        }
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_tableViewType == TableViewTypeAbountMe) {
        WorkGroupRecordCellB *cell = [tableView dequeueReusableCellWithIdentifier:@"WorkGroupRecordCellBIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"WorkGroupRecordCellB" owner:self options:nil];
            cell = (WorkGroupRecordCellB*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        cell.delegate = self;
        cell.labelContent.delegate = self;
        NSDictionary *item = _abountSourceArray[indexPath.section];
        [cell setContentDetails:item indexPath:indexPath byCellStatus:WorkGroupTypeStatusCell];
        [cell addClickEventForCellView:item withIndex:indexPath];
        
        return cell;
    }
    
    if (_tableViewType == TableViewTypeNotice) {
        MsgRemindCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_notice forIndexPath:indexPath];
        RemindModel *model = _noticeSourceArray[indexPath.row];
        [cell configWithModel:model];
        return cell;
    }
    AnnounceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AnnounceCellIdentifier"];
    if (!cell) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"AnnounceCell" owner:self options:nil];
        cell = (AnnounceCell *)[array objectAtIndex:0];
        [cell awakeFromNib];
        [cell setFrameAllPhone];
    }
    AnnounceModel *model = _announceSourceArray[indexPath.row];
    [cell configWithModel:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (_tableViewType) {
        case TableViewTypeAbountMe:
        {
            /*
            WorkGroupRecordDetailsViewController *controller = [[WorkGroupRecordDetailsViewController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            controller.flagOfDetails = @"normal";
            controller.isShowKeyBoardView = @"no";
            
            NSDictionary *item = [self.abountSourceArray objectAtIndex:indexPath.section];
            if ([CommonFuntion checkNullForValue:[item objectForKey:@"commentFrom"]])  {
                item = [item objectForKey:@"commentFrom"];
            }
            controller.dicWorkGroupDetailsOld = item;
            
            __weak typeof(self) weak_self = self;
            controller.BlackFreshenBlock = ^(){
                [weak_self getDataSourceWithType:TableViewTypeAbountMe];
            };
            [self.navigationController pushViewController:controller animated:YES];
             */
            [self requestAtMeDetail:indexPath];
        }
            
            break;
        case TableViewTypeNotice: //系统通知
        {
            RemindModel *model = _noticeSourceArray[indexPath.row];
            if ([model.isRead isEqualToString:@"1"]) {
                model.isRead = @"0";
//                [self changeOneRead:model.remindID];
                if (_systemNoticeCount > 0) {
                    _systemNoticeCount --;
                    if (_systemNoticeCount == 0) {
                        _systemLabel.hidden = YES;
                    } else {
                        _systemLabel.text = [NSString stringWithFormat:@"%ld", _systemNoticeCount];
                    }
                } else {
                    _systemNoticeCount = 0;
                    _systemLabel.hidden = YES;
                }
                
                ///消息数--
                [CommonUnReadNumberUtil unReadNumberDecrease:2 number:1];
                
            }
            //1动态；2博客；3文档；4日程；5任务；6审批；7粉丝； 8群组.
            switch (model.m_noticeType) {
                case NoticeTypeRecord:
                    [self pushIntoRecordDetailsView:NoticeTypeRecord withDataId:model.dataId];
                    break;
                case NoticeTypeBlog:
//                    [self pushIntoRecordDetailsView:NoticeTypeBlog withDataId:model.dataId];
                    break;
                case NoticeTypeFile:
                    
                    break;
                case NoticeTypeSchedule:
                {
                    ScheduleDetailViewController *controller = [[ScheduleDetailViewController alloc] init];
                    controller.title = @"日程详情";
                    controller.scheduleId = model.dataId;
                    [self.navigationController pushViewController:controller animated:YES];
                }
                    break;
                case NoticeTypeTask:
                {
                    XLFTaskDetailViewController *taskDetailController = [[XLFTaskDetailViewController alloc] init];
                    taskDetailController.uid = [NSString stringWithFormat:@"%ld", model.dataId];
                    taskDetailController.title = @"任务详情";
                    [self.navigationController pushViewController:taskDetailController animated:YES];
                }
                    break;
                case NoticeTypeApproval:
                {
                    if (_noticeSourceArray && [_noticeSourceArray count] > indexPath.row) {
                        Approval *approval = [Approval initWithDictionary:_noticeSourceArray[indexPath.row]];
                        approval.m_id = model.dataId;
                        ApprovalDetailViewController *approvalController = [[ApprovalDetailViewController alloc] init];
                        approvalController.title = @"审批明细";
                        approvalController.approval = approval;
                        [self.navigationController pushViewController:approvalController animated:YES];
                    }
                }
                    break;
                case NoticeTypeInfo:
                {
                    /*
                    InfoViewController *controller = [[InfoViewController alloc] init];
                    if (model.dataId == [appDelegateAccessor.moudle.userId integerValue]) {
                        controller.infoTypeOfUser = InfoTypeMyself;
                    } else {
                        controller.infoTypeOfUser = InfoTypeOthers;
                    }
                    controller.userId = model.dataId;
                    [self.navigationController pushViewController:controller animated:YES];
                     */
                }
                    break;
                case NoticeTypeGroup:
                {
                     NSDictionary *fromItem = [NSDictionary dictionaryWithObjectsAndKeys:@(model.dataId),@"id", model.user_name,@"name",@1,@"hasChildren",@"",@"icon",@"",@"pinyin",nil];

                    [self gotoDepartMentOrGroup:@{@"from" : fromItem}];
                    return;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case TableViewTypeAnnounce:
        {
            AnnounceDetailsController *controller = [[AnnounceDetailsController alloc] init];
            AnnounceModel *model = _announceSourceArray[indexPath.row];
            if ([model.isHasRead isEqualToString:@"1"]) {
                model.isHasRead = @"0";
               
                ///消息数--
                [CommonUnReadNumberUtil unReadNumberDecrease:3  number:1];
                if (_announcementCount > 0) {
                    _announcementCount --;
                    if (_announcementCount == 0) {
                        _announLabel.hidden = YES;
                    } else {
                        _announLabel.text = [NSString stringWithFormat:@"%ld", _announcementCount];
                    }
                } else {
                    _announcementCount = 0;
                    _announLabel.hidden = YES;
                }
            }
            controller.title = @"部门公告";
            controller.announceID = model.announce_ID;
            controller.announceContent = model.content;
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
            
        default:
            break;
    }
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section],nil] withRowAnimation:UITableViewRowAnimationNone];
}


-(void)gotoDetailsView:(NSIndexPath *)indexPath{
    WorkGroupRecordDetailsViewController *controller = [[WorkGroupRecordDetailsViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.flagOfDetails = @"normal";
    controller.isShowKeyBoardView = @"no";
    
    NSDictionary *item = [self.abountSourceArray objectAtIndex:indexPath.section];
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"commentFrom"]])  {
        item = [item objectForKey:@"commentFrom"];
    }
    controller.dicWorkGroupDetailsOld = item;
    
    __weak typeof(self) weak_self = self;
    controller.BlackFreshenBlock = ^(){
        [weak_self getDataSourceWithType:TableViewTypeAbountMe];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)requestAtMeDetail:(NSIndexPath *)indexPath{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:appDelegateAccessor.window];
    [appDelegateAccessor.window addSubview:hud];
    [hud show:YES];

    NSDictionary *item = [self.abountSourceArray objectAtIndex:indexPath.section];
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"commentFrom"]])  {
        item = [item objectForKey:@"commentFrom"];
    }
    long long trendsId  = [[item objectForKey:@"id"] longLongValue];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    __weak typeof(self) weak_self = self;
    [params setObject:[NSNumber numberWithLongLong:trendsId] forKey:@"id"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, TREND_DETAILS_A_DYNAMIC] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@"desc: %@", [responseObj objectForKey:@"desc"]);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            [self gotoDetailsView:indexPath];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 1) {
            kShowHUD([responseObj objectForKey:@"desc"], nil);
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self requestAtMeDetail:indexPath];
            };
            [comRequest loginInBackground];
        }
        [weak_self  reloadRefeshView];
        [_tableView reloadData];
    } failure:^(NSError *error) {
        [hud hide:YES];
        NSLog(@"-----异常日志---%@", error);
    }];
}

///跳转到部门或群组
-(void)gotoDepartMentOrGroup:(NSDictionary *)item{
    NSDictionary *from =  [item objectForKey:@"from"];
    NSDictionary *fromItem = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:[[from objectForKey:@"id"] longValue]],@"id", [from objectForKey:@"name"],@"name",@1,@"hasChildren",@"",@"icon",@"",@"pinyin",nil];
    DepartGroupModel *model = [NSObject objectOfClass:@"DepartGroupModel" fromJSON:fromItem];
    
    DepartViewController *controll = [[DepartViewController alloc] init];
    UITabBarController *tabbarController = [[UITabBarController alloc] init];
    tabbarController.edgesForExtendedLayout = UIRectEdgeNone;
    tabbarController.viewControllers = [controll getTabBarItems:model andType:1001];
    tabbarController.hidesBottomBarWhenPushed = YES;
    tabbarController.delegate = self;
    [tabbarController setSelectedIndex:0];
    [self.navigationController pushViewController:tabbarController animated:YES];
}
//动态详情
- (void)pushIntoRecordDetailsView:(NoticeType)type withDataId:(NSInteger )dataId {
    NSString *action = @"";
    ///动态详情
    if (type == NoticeTypeRecord) {
        //动态
        action = TREND_DETAILS_A_DYNAMIC;
    } else {
        //博客
        action = TREND_DETAILS_A_BLOG;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    __weak typeof(self) weak_self = self;
    [params setObject:@(dataId) forKey:@"id"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, action] params:params success:^(id responseObj) {
        NSLog(@"desc: %@", [responseObj objectForKey:@"desc"]);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            WorkGroupRecordDetailsViewController *controller = [[WorkGroupRecordDetailsViewController alloc] init];
            controller.dicWorkGroupDetailsOld = (NSDictionary *)responseObj;
            [weak_self.navigationController pushViewController:controller animated:YES];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 1) {
            kShowHUD([responseObj objectForKey:@"desc"], nil);
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self pushIntoRecordDetailsView:type withDataId:dataId];
            };
            [comRequest loginInBackground];
        }
        [weak_self  reloadRefeshView];
        [_tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"-----异常日志---%@", error);
    }];
}
#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64 + 44, kScreen_Width, kScreen_Height - 64 - 44) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView registerClass:[MsgRemindCell class] forCellReuseIdentifier:kCellIdentifier_notice];
        _tableView.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
        _tableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    }
    return _tableView;
}

- (void)setTableViewType:(TableViewType)tableViewType {
    if (tableViewType == _tableViewType) {
        return;
    }
    noticePage = 1;
    abountMePage = 1;
    announcePage = 1;
    _tableViewType = tableViewType;
    if (_tableViewType == TableViewTypeNotice && firstRead != 0) {
        _systemNoticeCount = 0;
        _systemLabel.hidden = YES;
    }
    [self clearViewNoData];
    [self getDataSourceWithType:tableViewType];
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
    noticePage = 1;
    abountMePage = 1;
    announcePage = 1;
    [self getDataSourceWithType:_tableViewType];
}

// 上拉
- (void)footerRereshing
{
    NSLog(@"footerRereshing--上拉-->");
    
    if ([self.tableView isHeaderRefreshing]) {
        [self.tableView footerEndRefreshing];
        return;
    }
    [self getDataSourceWithType:_tableViewType];
}
#pragma mark - WorkGroupDelegate cell点击事件

///点击头像事件
-(void)clickUserIconEvent:(NSInteger)section{
    NSLog(@"clickUserIconEvent section：%li",section);
    
    ///获取对应的item
    ///user
    NSDictionary *item = [self.abountSourceArray objectAtIndex:section];
    NSDictionary *user = nil;
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"user"]]) {
        user = [item objectForKey:@"user"];
    }else if ([CommonFuntion checkNullForValue:[item objectForKey:@"creator"]]) {
        user = [item objectForKey:@"creator"];
    }
    
    if (!user) {
        return;
    }
    
    ///获取到uid
    ///根据uid跳转页面
    
    InfoViewController *infoController = [[InfoViewController alloc] init];
    infoController.title = @"个人信息";
    if ([appDelegateAccessor.moudle.userId longLongValue] == [[user safeObjectForKey:@"id"] longLongValue]) {
        infoController.infoTypeOfUser = InfoTypeMyself;
    }else{
        infoController.infoTypeOfUser = InfoTypeOthers;
        infoController.userId = [[user safeObjectForKey:@"id"] longLongValue];
    }
    
    infoController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:infoController animated:YES];
}

///点击右上角菜单事件
-(void)clickRightMenuEvent:(NSInteger)section{
    NSLog(@"clickRightMenuEvent section：%li",section);
    NSDictionary *item = [self.abountSourceArray objectAtIndex:section];
    NSInteger modelType = 2;
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"moduleType"]]) {
        modelType = [[item objectForKey:@"moduleType"] integerValue];
    }
    ///OA
    if (modelType == 1) {
        [self showRightActionSheetMenu:section];
    }else if (modelType == 2) {
        [self showRightActionSheetMenuCRM:section];
    }
}

///点击文件事件
-(void)clickFileEvent:(NSInteger)section{
    NSLog(@"clickFileEvent row：%li",section);
    
    NSDictionary *fileItem = nil;
    NSDictionary *item = [self.abountSourceArray objectAtIndex:section];
    
    ///转发内容
    if ([[item objectForKey:@"type"] integerValue] == 2) {
        if ([CommonFuntion checkNullForValue:[item objectForKey:@"forward"]]) {
            item = [item objectForKey:@"forward"];
        }
    }
    
    
    //    if ([item objectForKey:@"file"] && [item objectForKey:@"fileType"]) {
    //        if ([[item safeObjectForKey:@"fileType"]  integerValue] == 2) {
    //            ///文件
    //            fileItem = [item objectForKey:@"file"];
    //        }
    //    }
    
    if (item && [CommonFuntion checkNullForValue:[item objectForKey:@"file"]]) {
        NSLog(@"item:%@",item);
        KnowledgeFileDetailsViewController *controller = [[KnowledgeFileDetailsViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        controller.detailsOld = [item objectForKey:@"file"];
        controller.viewFrom = @"other";
        controller.isNeedRightNavBtn = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        //        kShowHUD(@"文件不存在");
        [CommonFuntion showToast:@"文件不存在" inView:self.view];
    }
}

///点击地址事件
-(void)clickAddressEvent:(NSInteger)section{
    NSLog(@"clickAddressEvent section：%li",section);
    NSDictionary *item = [self.abountSourceArray objectAtIndex:section];
    NSDictionary *feedItem = nil;
    
    ///是转发信息
    if ([[item objectForKey:@"type"] integerValue] == 2) {
        ///
        if ([CommonFuntion checkNullForValue:[item objectForKey:@"forward"]]) {
            feedItem = [item objectForKey:@"forward"];
        }
    }
    
    ///是转发动态
    if (feedItem) {
        item = feedItem;
    }
    
    double latitude = 0;
    double longitude = 0;
    if ([item objectForKey:@"latitude"]) {
        latitude = [[item safeObjectForKey:@"latitude"] doubleValue];
    }
    if ([item objectForKey:@"longitude"]) {
        longitude = [[item safeObjectForKey:@"longitude"] doubleValue];
    }
    ///location
    NSString *location = @"";
    if ([item objectForKey:@"position"]) {
        location = [item safeObjectForKey:@"position"];
    }
    NSString *locationDetail = @"";
    if ([item objectForKey:@"position"]) {
        locationDetail = [item safeObjectForKey:@"position"];
    }
    
    if (latitude !=0 && longitude !=0) {
        MapViewViewController *controller = [[MapViewViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        controller.typeOfMap = @"show";
        controller.latitude = latitude;
        controller.longitude = longitude;
        controller.location = location;
        controller.locationDetail = locationDetail;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

///展开或收起
-(void)clickExpContentEvent:(NSInteger)section{
    NSLog(@"clickExpContentEvent section：%li",section);
    
    NSDictionary *itemOld = [self.abountSourceArray objectAtIndex:section];
    
    NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:itemOld];
    
    ///已经处于展开状态 则收起
    if ([itemOld objectForKey:@"isExp"] && [[itemOld objectForKey:@"isExp"] isEqualToString:@"yes"]) {
        [mutableItemNew setObject:@"no" forKey:@"isExp"];
    }else{
        ///标记为展开展开状态
        [mutableItemNew setObject:@"yes" forKey:@"isExp"];
    }
    

    //修改数据
    [self.abountSourceArray setObject: mutableItemNew atIndexedSubscript:section];
    
    ///刷新当前cell
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:section],nil] withRowAnimation:UITableViewRowAnimationNone];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

///点击转发事件
-(void)clickRepostEvent:(NSInteger)section{
    NSLog(@"clickRepostEvent section：%li",section);
    
    __weak typeof(self) weak_self = self;
    ReleaseViewController *releaseController = [[ReleaseViewController alloc] init];
    releaseController.title = @"转发";
    releaseController.typeOfOptionDynamic = TypeOfOptionDynamicForward;
    releaseController.itemDynamic = [self.abountSourceArray objectAtIndex:section];
    releaseController.ReleaseSuccessNotifyData = ^(){
        ///重新请求数据
//        [weak_self notifyDataByHeadRequest];
    };
    [self.navigationController pushViewController:releaseController animated:YES];
}

///点击评论事件
-(void)clickReviewEvent:(NSInteger)section{
    NSLog(@"clickReviewEvent section：%li",section);
    WorkGroupRecordDetailsViewController *controller = [[WorkGroupRecordDetailsViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.flagOfDetails = @"normal";
    controller.isShowKeyBoardView = @"yes";
    controller.dicWorkGroupDetailsOld = [self.abountSourceArray objectAtIndex:section];
    __weak typeof(self) weak_self = self;
    controller.BlackFreshenBlock = ^(){
        [weak_self getDataSourceWithType:TableViewTypeAbountMe];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

///点击赞事件
-(void)clickPraiseEvent:(NSInteger)section{
    NSLog(@"clickPraiseEvent section：%li",section);
    NSDictionary *item = [self.abountSourceArray objectAtIndex:section];
    
    long long trendsId = -1;
    if ([item objectForKey:@"id"]) {
        trendsId = [[item objectForKey:@"id"] longLongValue];
    }
    
    [self trendOption:FEED_UP_ADD withTrendsId:trendsId indexTrends:section];
    

//    ///是否已经赞
//     NSString *isFeedUp = @"0";
//     if ([item objectForKey:@"isFeedUp"]) {
//     isFeedUp = [item safeObjectForKey:@"isFeedUp"];
//     }
//     
//     ///还没有赞
//     if ([isFeedUp isEqualToString:@"0"]) {
//     
//     }
//
    
}

///点击来自XXX事件
-(void)clickFromEvent:(NSInteger)section{
    NSLog(@"clickFromEvent section：%li",section);
    NSDictionary *item = [self.abountSourceArray objectAtIndex:section];
    
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"from"]]) {
        _sourceType = [[[item objectForKey:@"from"] objectForKey:@"sourceId"] integerValue];
        NSInteger sectionId = [[[item objectForKey:@"from"] objectForKey:@"id"] integerValue];
        switch (_sourceType) {
            case PushControllerTypeActivity:
            {
                ActivityDetailViewController *controller = [[ActivityDetailViewController alloc] init];
                controller.id = @(sectionId);
                controller.title = @"市场活动";
                [self.navigationController pushViewController:controller animated:YES];
            }
                NSLog(@"市场活动");
                break;
            case PushControllerTypeClue:
            {
                LeadDetailViewController *controller = [[LeadDetailViewController alloc] init];
                Lead *lead = [[Lead alloc] init];
                lead.id = @(sectionId);
                controller.id = lead.id;
                controller.title = @"销售线索";
                [self.navigationController pushViewController:controller animated:YES];
            }
                NSLog(@"销售线索");
                break;
            case PushControllerTypeCustomer:
            {
                CustomerDetailViewController *controller = [[CustomerDetailViewController alloc] init];
                Customer *tomer = [[Customer alloc] init];
                tomer.id = @(sectionId);
                controller.id = tomer.id;
                controller.title = @"客户";
                [self.navigationController pushViewController:controller animated:YES];
            }
                NSLog(@"客户");
                break;
            case PushControllerTypeContract:
            {
                ContactDetailViewController *controller = [[ContactDetailViewController alloc] init];
                Contact *tact = [[Contact alloc] init];
                tact.id = @(sectionId);
                controller.id = tact.id;
                controller.title = @"联系人";
                [self.navigationController pushViewController:controller animated:YES];
            }
                NSLog(@"联系人");
                break;
            case PushControllerTypeOpportunity:
            {
                OpportunityDetailController *controller = [[OpportunityDetailController alloc] init];
                SaleChance *chance = [[SaleChance alloc] init];
                chance.id = @(sectionId);
                controller.id = chance.id;
                controller.title = @"销售机会";
                [self.navigationController pushViewController:controller animated:YES];
            }
                NSLog(@"销售机会");
                break;
            case PushControllerTypeGroup:
            {
                [self gotoDepartMentOrGroup:item];
            }
                NSLog(@"群组");
                break;
            case PushControllerTypeDepartment:
            {
                [self gotoDepartMentOrGroup:item];
            }
                NSLog(@"部门");
                break;
                
            default:
                break;
        }
    }
}


///点击内容中的@
-(void)clickContentCharType:(NSString *)type content:(NSString *)content atIndex:(NSIndexPath *)indexPath{
    NSLog(@"clickContentCharType type:%@ content:%@ index:%li",type,content,indexPath.section);
    
    NSDictionary *item;
    if ([[CommonStaticVar getTypeOfWorkGroupCellInfo] isEqualToString:@"comment"])  {
        
        ///消息 提到我的
        if ([[[self.abountSourceArray objectAtIndex:indexPath.section] objectForKey:@"type"] integerValue] == 1) {
            item = [[self.abountSourceArray objectAtIndex:indexPath.section] objectForKey:@"comment"];
        }else{
            ///type == 0
            item = [[self.abountSourceArray objectAtIndex:indexPath.section] objectForKey:@"feed"];
        }
        
    }else{
        item = [self.abountSourceArray objectAtIndex:indexPath.section];
    }
    
    NSLog(@"item:%@",item);
    ///未返回标记@集合的key
    
    long long uid = [CommonModuleFuntion getUidByAtName:[[content substringFromIndex:1] stringByReplacingOccurrencesOfString:@" " withString:@
                                                         ""] fromAtList:[item objectForKey:@"alts"]];
    NSLog(@"uid:%lld",uid);
    InfoViewController *infoController = [[InfoViewController alloc] init];
    infoController.title = @"个人信息";
    if ([appDelegateAccessor.moudle.userId longLongValue] == uid) {
        infoController.infoTypeOfUser = InfoTypeMyself;
    }else{
        infoController.infoTypeOfUser = InfoTypeOthers;
        infoController.userId = uid;
    }
    
    infoController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:infoController animated:YES];
    
}


///点击图片事件
-(void)clickImageViewEvent:(NSIndexPath *)imgIndexPath{
    NSLog(@"clickImageViewEvent section：%li andImgIndex:%li",imgIndexPath.section,imgIndexPath.row);
    
    [PhotoBroswerVC show:self type:PhotoBroswerVCTypeZoom index:imgIndexPath.row photoModelBlock:^NSArray *{
        
        WorkGroupRecordCellB *cell = (WorkGroupRecordCellB *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:imgIndexPath.section]];
        
        NSDictionary *item = [self.abountSourceArray objectAtIndex:imgIndexPath.section];
        NSLog(@"-----img  click--item:%@",item);
        ///转发内容
        if ([[item objectForKey:@"type"] integerValue] == 2) {
            if ([CommonFuntion checkNullForValue:[item objectForKey:@"forward"]]) {
                item = [item objectForKey:@"forward"];
            }
        }
        NSArray *arrayImg;
        
        /// fileType  0 不存在  1图片  2附件
        /// imageFiles 判断图片
        if ([CommonFuntion checkNullForValue:[item objectForKey:@"imageFiles"]] && [item objectForKey:@"fileType"]) {
            if ([[item safeObjectForKey:@"fileType"]  integerValue] == 1) {
                arrayImg = [item objectForKey:@"imageFiles"];
            }
        }
        
        //        NSLog(@"-----img  click--arrimg:%@",arrayImg);
#warning 该替换为url
        NSString *imgSizeType = @"url";
        
        
        NSMutableArray *modelsM = [NSMutableArray arrayWithCapacity:arrayImg.count];
        
        
        NSInteger imgIndex = 0;
        if ([arrayImg count] > imgIndex) {
            NSLog(@"----imgIndex:%ti",imgIndex);
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            
            //源frame
            NSLog(@"cell.img1:%@",cell.img1);
            pbModel.sourceImageView = cell.img1;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        
        if ([arrayImg count] > imgIndex) {
            NSLog(@"----imgIndex:%ti",imgIndex);
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            NSLog(@"cell.img2:%@",cell.img2);
            UIImageView *imageV =(UIImageView *)cell.img2;
            pbModel.sourceImageView = imageV;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        if ([arrayImg count] > imgIndex) {
            NSLog(@"----imgIndex:%ti",imgIndex);
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            pbModel.sourceImageView = cell.img3;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        if ([arrayImg count] > imgIndex) {
            NSLog(@"----imgIndex:%ti",imgIndex);
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            pbModel.sourceImageView = cell.img4;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        if ([arrayImg count] > imgIndex) {
            NSLog(@"----imgIndex:%ti",imgIndex);
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            pbModel.sourceImageView = cell.img5;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        if ([arrayImg count] > imgIndex) {
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            pbModel.sourceImageView = cell.img6;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        if ([arrayImg count] > imgIndex) {
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            pbModel.sourceImageView = cell.img7;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        
        if ([arrayImg count] > imgIndex) {
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            pbModel.sourceImageView = cell.img8;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        if ([arrayImg count] > imgIndex) {
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            pbModel.sourceImageView = cell.img9;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        for (int i=0; i<modelsM.count; i++) {
            NSLog(@"modelsM:%@",[modelsM objectAtIndex:i]);
        }
        
        return modelsM;
    }];
}

//播放语音
- (void)clickVoiceDataEvent:(NSInteger)section {
    NSLog(@"clickVoiceDataEvent section：%li",section);
    if (self.abountSourceArray && [self.abountSourceArray count]>section) {
        NSDictionary *item = [self.abountSourceArray objectAtIndex:section];
        NSString *voiceStr = @"";
        if ([CommonFuntion checkNullForValue:[item objectForKey:@"audio"]]) {
            if ([[item objectForKey:@"audio"] objectForKey:@"url"]) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
                WorkGroupRecordCellB *cell = (WorkGroupRecordCellB *)[self.tableView cellForRowAtIndexPath:indexPath];
                NSString *imgSting = @"other";
                if (appDelegateAccessor.cellMoudle.workgroupCellB != nil) {
                    NSLog(@"图片复位-----：%@",appDelegateAccessor.cellMoudle.workgroupCellB);
                    appDelegateAccessor.cellMoudle.workgroupCellB.imgVoice.image = [UIImage imageNamed:[NSString stringWithFormat:@"voice_sign_%@_3.png", imgSting]];
                }
                appDelegateAccessor.cellMoudle.workgroupCellB = cell;
                
                voiceStr = [[item objectForKey:@"audio"] objectForKey:@"url"];
                [AFSoundPlaybackHelper playVoiceByUrl:voiceStr];
            }
        }
    }
    
}

///点击转发view区域 跳转到详情
-(void)clickRepostViewEvent:(NSInteger)section{
    NSLog(@"clickRepostViewEvent section：%li",section);
    NSDictionary *item = [self.abountSourceArray objectAtIndex:section];
    ///是转发信息
    if ([[item  objectForKey:@"type"] integerValue] == 2 ) {
        ///
        NSDictionary *feedItem = nil;
        if ([item objectForKey:@"forward"] && [CommonFuntion checkNullForValue:[item objectForKey:@"forward"]]) {
            feedItem = [item objectForKey:@"forward"];
        }
        
        ///存在转发内容
        if (feedItem) {
            WorkGroupRecordDetailsViewController *controller = [[WorkGroupRecordDetailsViewController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            controller.isShowKeyBoardView = @"no";
            controller.flagOfDetails = @"forward";
            controller.dicWorkGroupDetailsOld = feedItem;
            [self.navigationController pushViewController:controller animated:YES];
        }else{
            ///动态已经被删除
            //            kShowHUD(@"该动态已被删除");
            [CommonFuntion showToast:@"该动态已被删除" inView:self.view];
        }
    }
    
}


#pragma mark  OA  点击右上角菜单按钮 弹出actionsheetview
///点击右上角菜单按钮 弹出actionsheetview
-(void)showRightActionSheetMenu:(NSInteger)section{
    
    NSDictionary *item = [self.abountSourceArray objectAtIndex:section];
    NSDictionary *user = nil;
    NSString *uid = @"";
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"user"]]) {
        user = [item objectForKey:@"user"];
    }
    if (user) {
        if ([user objectForKey:@"id"]) {
            uid = [user safeObjectForKey:@"id"];
        }
    }
    
    NSInteger isfav = 0;
    if ([item objectForKey:@"isfav"]) {
        isfav = [[item objectForKey:@"isfav"] integerValue];
    }
    NSString *report = @"举报";
    NSString *fav = @"";
    NSString *delete = @"删除";
    ///已收藏
    if (isfav == 0) {
        fav = @"取消收藏";
    }else{
        fav = @"收藏";
    }
    
    ///是我的动态  举报 收藏 删除收藏等操作   有删除操作
    if ([[item objectForKey:@"moduleType"] integerValue] == 1) {
        if ([appDelegateAccessor.moudle.userId longLongValue] == [uid longLongValue]) {
            
            ///判断可删除时 标红
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:nil
                                          delegate:self
                                          cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:report
                                          otherButtonTitles: fav,delete,nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            actionSheet.destructiveButtonIndex = 2;
            actionSheet.tag = section;
            [actionSheet showInView:self.view];
            
        }else{
            ///别人的动态   收藏   取消收藏  举报
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:nil
                                          delegate:self
                                          cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                          otherButtonTitles: report,fav,nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            actionSheet.tag = section;
            [actionSheet showInView:self.view];
        }
        
    } else {
        if ([appDelegateAccessor.moudle.userId longLongValue] == [uid longLongValue]) {
            
            ///判断可删除时 标红
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:nil
                                          delegate:self
                                          cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:report
                                          otherButtonTitles:delete,nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            actionSheet.tag = section;
            [actionSheet showInView:self.view];
            
        }else{
            ///别人的动态   收藏   取消收藏  举报
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:nil
                                          delegate:self
                                          cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:report
                                          otherButtonTitles:nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            actionSheet.tag = section;
            [actionSheet showInView:self.view];
        }
    }
}
#pragma mark  OA  点击右上角菜单按钮 弹出actionsheetview
///点击右上角菜单按钮 弹出actionsheetview
-(void)showRightActionSheetMenuCRM:(NSInteger)section{
    
    NSDictionary *item = [self.abountSourceArray objectAtIndex:section];
    NSDictionary *user = nil;
    NSString *uid = @"";
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"user"]]) {
        user = [item objectForKey:@"user"];
    }
    if (user) {
        if ([user objectForKey:@"id"]) {
            uid = [user safeObjectForKey:@"id"];
        }
    }
    
    NSString *delete = @"删除";
    if ([appDelegateAccessor.moudle.userId longLongValue] == [uid longLongValue]) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles: delete,nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        actionSheet.destructiveButtonIndex = 0;
        actionSheet.tag = section;
        [actionSheet showInView:self.view];
        
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 500) {
        return;
    }
    NSDictionary *item = [self.abountSourceArray objectAtIndex:actionSheet.tag];
    NSDictionary *user = nil;
    NSString *uid = @"";
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"user"]]) {
        user = [item objectForKey:@"user"];
    }
    if (user) {
        if ([user objectForKey:@"id"]) {
            uid = [user safeObjectForKey:@"id"];
        }
    }
    NSInteger m_Type = 2;
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"moduleType"]]) {
        m_Type = [[item objectForKey:@"moduleType"] integerValue];
    }
    
    ///OA
    if (m_Type == 1) {
        
        if (buttonIndex == 0) {
            //举报
            [self reportToService];
        }else if (buttonIndex == 1) {
            //收藏 取消收藏
            if (m_Type != 2) {
                NSInteger isfav = 0;
                if ([item objectForKey:@"isfav"]) {
                    isfav = [[item objectForKey:@"isfav"] integerValue];
                }
                long long trendsId = -1;
                if ([item objectForKey:@"id"]) {
                    trendsId = [[item objectForKey:@"id"] longLongValue];
                }
                
                NSString *url = @"";
                ///已收藏
                if (isfav == 0) {
                    ///取消收藏
                    url = DELETE_FAVORITE;
                }else{
                    ///收藏
                    url = ADD_FAVORITE;
                }
                [self trendOption:url withTrendsId:trendsId indexTrends:actionSheet.tag];
            } else {
                ///我的动态
                if ([appDelegateAccessor.moudle.userId longLongValue] == [uid longLongValue]) {
                    
                    //删除
                    NSDictionary *item = [self.abountSourceArray objectAtIndex:actionSheet.tag];
                    trendIdDelete  = -1;
                    if ([item objectForKey:@"id"]) {
                        trendIdDelete = [[item objectForKey:@"id"] longLongValue];
                    }
                    indexDelete = actionSheet.tag;
                    
                    UIAlertView *alertDelete = [[UIAlertView alloc] initWithTitle:@"确认删除动态？" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
                    alertDelete.tag = 101;
                    [alertDelete show];
                    
                }
            }
        }else if(buttonIndex == 2 ) {
            if (m_Type != 2) {
                ///我的动态
                if ([appDelegateAccessor.moudle.userId longLongValue] == [uid longLongValue]) {
                    
                    //删除
                    NSDictionary *item = [self.abountSourceArray objectAtIndex:actionSheet.tag];
                    trendIdDelete  = -1;
                    if ([item objectForKey:@"id"]) {
                        trendIdDelete = [[item objectForKey:@"id"] longLongValue];
                    }
                    indexDelete = actionSheet.tag;
                    
                    UIAlertView *alertDelete = [[UIAlertView alloc] initWithTitle:@"确认删除动态？" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
                    alertDelete.tag = 101;
                    [alertDelete show];
                    
                }
            } else {
                //取消
            }
        }else if(buttonIndex == 3) {
            //取消
        }
        
    } else if(m_Type == 2){
        ///CRM  只可删除
        
        if (buttonIndex == 0) {
            //删除
            NSDictionary *item = [self.abountSourceArray objectAtIndex:actionSheet.tag];
            trendIdDelete  = -1;
            if ([item objectForKey:@"id"]) {
                trendIdDelete = [[item objectForKey:@"id"] longLongValue];
            }
            indexDelete = actionSheet.tag;
            
            UIAlertView *alertDelete = [[UIAlertView alloc] initWithTitle:@"确认删除活动记录？" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
            alertDelete.tag = 101;
            [alertDelete show];
        }
    }
    
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components {
    
    User *user = [components objectForKey:@"altUser"];
    
    if (user) {
        InfoViewController *infoController = [[InfoViewController alloc] init];
        infoController.title = @"个人信息";
        if ([appDelegateAccessor.moudle.userId integerValue] == [user.id integerValue]) {
            infoController.infoTypeOfUser = InfoTypeMyself;
        }else{
            infoController.infoTypeOfUser = InfoTypeOthers;
            infoController.userId = [user.id integerValue];
        }
        [self.navigationController pushViewController:infoController animated:YES];
        return;
    }
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            NSLog(@"删除动态");
            
            NSString *strUrl = @"";
            NSDictionary *item = [self.abountSourceArray objectAtIndex:indexDelete];
            NSInteger m_Type = 2;
            if ([CommonFuntion checkNullForValue:[item objectForKey:@"moduleType"]]) {
                m_Type = [[item objectForKey:@"moduleType"] integerValue];
            }
            if (m_Type == 1) {
                strUrl = DELETE_DYNAMIC;
            }else if(m_Type == 2){
                strUrl = kNetPath_Common_DeleteActivity;
            }
            [self trendOption:strUrl withTrendsId:trendIdDelete indexTrends:indexDelete];
        }
    }
}

#pragma mark - 举报
-(void)reportToService{
    ReportToServiceViewController *controller = [[ReportToServiceViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}
#pragma mark - 收藏/取消收藏/赞/删除动态
-(void)trendOption:(NSString *)url  withTrendsId:(long long)trendsId indexTrends:(NSInteger)section{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    __weak typeof(self) weak_self = self;
    
    NSString *url_h = @"";
    if ([url isEqualToString:kNetPath_Common_DeleteActivity]) {
        url_h = MOBILE_SERVER_IP_CRM;
        [params setObject:[NSNumber numberWithLongLong:trendsId] forKey:@"id"];
    }else{
        url_h = MOBILE_SERVER_IP_OA;
        [params setObject:[NSNumber numberWithLongLong:trendsId] forKey:@"trendsId"];
    }
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",url_h,url] params:params success:^(id responseObj) {
        
        NSLog(@" responseObj:%@",responseObj);
        //字典转模型
        NSDictionary *resultdic = responseObj;
        
        if (resultdic && [[resultdic objectForKey:@"status"] integerValue] == 0) {
            [self setViewRequestSusscessByTrendOptions:url index:section];
        } else if ((resultdic && [[resultdic objectForKey:@"status"] integerValue] == 1) || (resultdic && [[resultdic objectForKey:@"status"] integerValue] == 2)) {
            NSString *desc = [resultdic safeObjectForKey:@"desc"];
            kShowHUD(desc,nil);
            //如果提示  该动态被删除，则刷新列表
            abountMePage = 1;
            [weak_self getDataSourceWithType:TableViewTypeAbountMe];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self trendOption:url withTrendsId:trendsId indexTrends:section];
            };
            [comRequest loginInBackground];
        }
        else{
            NSString *desc = [resultdic safeObjectForKey:@"desc"];
            NSLog(@"desc:%@",desc);
            ///失败 做相应处理
            if ([url isEqualToString:ADD_FAVORITE]) {
                //                kShowHUD(@"收藏失败");
                [CommonFuntion showToast:@"收藏失败" inView:self.view];
            }else if([url isEqualToString:DELETE_FAVORITE]){
                //                kShowHUD(@"取消收藏失败");
                [CommonFuntion showToast:@"取消收藏失败" inView:self.view];
            }else if([url isEqualToString:FEED_UP_ADD]){
                ///赞操作失败
            }else if([url isEqualToString:DELETE_DYNAMIC]){
                //                kShowHUD(@"删除动态失败");
                [CommonFuntion showToast:@"删除动态失败" inView:self.view];
            }else if([url isEqualToString:kNetPath_Common_DeleteActivity]){
                //                kShowHUD(@"删除动态失败");
                [CommonFuntion showToast:@"删除活动记录失败" inView:self.view];
            }
        }
        
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        //        kShowHUD(NET_ERROR);
        [CommonFuntion showToast:NET_ERROR inView:self.view];
    }];
}
// 收藏/取消收藏/赞/删除动态操作请求成功时数据处理
-(void)setViewRequestSusscessByTrendOptions:(NSString *)action index:(NSInteger)section
{
    ///收藏 取消收藏
    if ([action isEqualToString:ADD_FAVORITE] || [action isEqualToString:DELETE_FAVORITE]) {
        if ([action isEqualToString:ADD_FAVORITE]) {
            [CommonFuntion showToast:@"收藏成功" inView:self.view];
        }else if([action isEqualToString:DELETE_FAVORITE]){
            [CommonFuntion showToast:@"取消收藏成功" inView:self.view];
        }
        [self updateFavFlag:action index:section];
        
    }else if ( [action isEqualToString:FEED_UP_ADD]){
        ///赞操作
        [self updateFeedCountAndFlag:section];
    }else if([action isEqualToString:DELETE_DYNAMIC]){
        [CommonFuntion showToast:@"删除动态成功" inView:self.view];
//        [self deleteTrend:section];
    }else if([action isEqualToString:kNetPath_Common_DeleteActivity]){
        //                kShowHUD(@"删除动态失败");
        [CommonFuntion showToast:@"删除活动记录成功" inView:self.view];
//        [self deleteTrend:section];
    }
}
#pragma mark - 更新收藏标记
-(void)updateFavFlag:(NSString *)action index:(NSInteger)section{
    NSLog(@"updateFavFlag  action:%@  section:%ti",action,section);
        NSInteger isfav = 1;
        if ([action isEqualToString:ADD_FAVORITE]) {
            isfav = 0;
        }else if([action isEqualToString:DELETE_FAVORITE]){
            isfav = 1;
        }
        NSDictionary *item = [self.abountSourceArray objectAtIndex:section];
        ///修改本地数据
        NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:item];
        [mutableItemNew setObject:[NSNumber numberWithInteger:isfav] forKey:@"isfav"];
        //修改数据
        [self.abountSourceArray setObject: mutableItemNew atIndexedSubscript:section];
        
        ///刷新当前cell
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:section],nil] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - 刷新赞个数与标志
-(void)updateFeedCountAndFlag:(NSInteger)section{
    NSLog(@"updateFeedCountAndFlag  section:%ti",section);
    NSDictionary *item = [self.abountSourceArray objectAtIndex:section];
    ///已经被赞的个数
    NSInteger feedUpCount = 0;
    if ([item objectForKey:@"feedUpCount"]) {
        feedUpCount = [[item objectForKey:@"feedUpCount"] integerValue];
    }
    feedUpCount ++;
    ///修改本地数据
    NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:item];
    [mutableItemNew setObject:[NSNumber numberWithInteger:0] forKey:@"isFeedUp"];
    [mutableItemNew setObject:[NSNumber numberWithInteger:feedUpCount] forKey:@"feedUpCount"];
    //修改数据
    [self.abountSourceArray setObject: mutableItemNew atIndexedSubscript:section];
    
    ///刷新当前cell
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:section],nil] withRowAnimation:UITableViewRowAnimationNone];
    /*
     dispatch_queue_t queue= dispatch_get_main_queue();
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), queue, ^{
     ///刷新当前cell
     [self.tableviewWorkGroup reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:section],nil] withRowAnimation:UITableViewRowAnimationNone];
     });
     */
}

#pragma mark - 本地数据删除动态
-(void)deleteTrend:(NSInteger)section{
    NSLog(@"deleteTrend ：%ti",section);
    if (self.abountSourceArray && [self.abountSourceArray count] > section) {
        [self.abountSourceArray removeObjectAtIndex:section];
        [self.tableView reloadData];
        NSLog(@"本地数据删除动态");
    }
}


#pragma mark - 刷新评论个数
-(void)updateReviewComment:(NSInteger)section withFlag:(NSString *)optionFlag{
    NSLog(@"updateReviewComment");
    NSDictionary *item = [self.abountSourceArray objectAtIndex:section];
    ///已经评论的个数
    NSInteger commentCount = 0;
    if ([item objectForKey:@"commentCount"]) {
        commentCount = [[item objectForKey:@"commentCount"] integerValue];
    }
    if ([optionFlag isEqualToString:@"add"]) {
        commentCount ++;
    }else{
        commentCount --;
    }
    
    ///修改本地数据
    NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:item];
    [mutableItemNew setObject:[NSNumber numberWithInteger:commentCount] forKey:@"commentCount"];
    //修改数据
    [self.abountSourceArray setObject: mutableItemNew atIndexedSubscript:section];
    
    ///刷新当前cell
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:section],nil] withRowAnimation:UITableViewRowAnimationNone];
    ///修改缓存数据
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
