//
//  Office_RootViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "Office_RootViewController.h"
#import "MenuSettingViewController.h"
#import "WorkGroupRecordViewController.h"
#import "AddressBookViewController.h"
#import "WorkReportViewController.h"
#import "ApprovalViewController.h"
#import "PlanViewController.h"
#import "TaskViewController.h"
#import "KnowledgeFileViewController.h"
#import "CommonStaticVar.h"
#import "ArrayDataSource.h"
#import "SDImageCache.h"
#import "TitleImageCell.h"
#import "NSUserDefaults_Cache.h"
#import "CommonModuleFuntion.h"
#import "AFNHttp.h"
#import "RootMenuCell.h"

#define kCellIdentifier @"TitleImageCell"

@interface Office_RootViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation Office_RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = TABLEVIEW_BG_COLOR;
     self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initTableview];
    [self initSettingBtn];
    [self initMenuData];
}

- (void)didReceiveMemoryWarning {
    if ([self isViewLoaded] && [self.view window] == nil) {
        NSLog(@"--oa--didReceiveMemoryWarning----->");
        self.view = nil;
        ///清除图片相关缓存
        [[SDImageCache sharedImageCache] getSize];
        [[SDImageCache sharedImageCache] clearMemory];
        [[SDImageCache sharedImageCache] clearDisk];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableview reloadData];
    [self getUnReadMsgNumber];
    [self registObserverByNewestTrend];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeObserverByNewestTrend];
}

#pragma mark - 初始化tablview
-(void)initTableview{
//    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStyleGrouped];
    self.tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.tableview setY:64.0f];
    [self.tableview setWidth:kScreen_Width];
    [self.tableview setHeight:kScreen_Height - CGRectGetMinY(self.tableview.frame) - 49.0f];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.sectionFooterHeight = 0;
    [self.view addSubview:self.tableview];
    self.tableview.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    self.tableview.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableview setTableFooterView:v];
}


#pragma mark - 初始化数据
-(void)initMenuData{
    self.dataSource = [[NSMutableArray alloc] init];
    NSArray *oaModuleOptions = [NSUserDefaults_Cache getOAModuleOptions];
//    NSLog(@"oaModuleOptions:%@",oaModuleOptions);
    [self notifyTableview:oaModuleOptions];
}

///刷新数据
-(void)notifyTableview:(NSArray *)options{
    [self.dataSource removeAllObjects];
    
    NSMutableArray *oaOptions = [[NSMutableArray alloc] init];
    if (options) {
        for (int i=0; i<options.count; i++) {
            RootMenuModel *model = [RootMenuModel initWithDictionary:options[i]];
            [oaOptions addObject:model];
        }
        [self.dataSource addObjectsFromArray:[CommonModuleFuntion getOptionsModuleShow:oaOptions]];
    }
    
    [self.tableview reloadData];
}


///设置按钮
-(void)initSettingBtn{
    UIButton *btnSetting = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSetting.frame = CGRectMake(kScreen_Width-40, kScreen_Height-90, 30, 30);
    [btnSetting setImage:[UIImage imageNamed:@"menu_item_setting"] forState:UIControlStateNormal];
    [btnSetting addTarget:self action:@selector(settingItemPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSetting];
}


- (void)settingItemPress
{
    __weak typeof(self) weak_self = self;
    MenuSettingViewController *menuSettingController = [[MenuSettingViewController alloc] init];
    menuSettingController.title = @"办公设置";
    menuSettingController.sourceType = DataSourceTypeOffice;
    menuSettingController.hidesBottomBarWhenPushed = YES;
    menuSettingController.notifyModuleOptions = ^(NSArray *options){
        [weak_self notifyTableview:options];
    };
    
    [self.navigationController pushViewController:menuSettingController animated:YES];
}



#pragma mark - tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.5f;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.dataSource) {
        return [self.dataSource count];
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.dataSource) {
        return [[self.dataSource objectAtIndex:section] count];
    }
    return 0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RootMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RootMenuCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RootMenuCell" owner:self options:nil];
        cell = (RootMenuCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    
    [cell setCellDetails:(RootMenuModel *)([[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]) withType:1];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RootMenuModel *itemModel = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    NSInteger eventIndex = [itemModel.menu_eventindex integerValue];
    
    switch (eventIndex) {
        case 1:
        {
            ///标记为已读消息
            [NSUserDefaults_Cache setNewTrendsInformValue:nil];
            appDelegateAccessor.moudle.icon_oa_workzone_newtrends = @"";
            WorkGroupRecordViewController *workGroupController = [[WorkGroupRecordViewController alloc] init];
            workGroupController.title = @"工作圈";
            workGroupController.typeOfView = @"workzone";
            [CommonStaticVar setFlagOfWorkGroupViewFrom:@"workzone"];
            workGroupController.hidesBottomBarWhenPushed = YES;
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
            backItem.title = @"";
            self.navigationItem.backBarButtonItem = backItem;
            [self.navigationController pushViewController:workGroupController animated:YES];
        }
            break;
        case 2:
        {
            AddressBookViewController *addressBookController = [[AddressBookViewController alloc] init];
            addressBookController.title = @"通讯录";
            addressBookController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:addressBookController animated:YES];
        }
            break;
        case 3:
        {
            WorkReportViewController *workReportController = [[WorkReportViewController alloc] init];
            workReportController.title = @"工作报告";
            workReportController.hidesBottomBarWhenPushed = YES;
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
            backItem.title = @"";
            self.navigationItem.backBarButtonItem = backItem;
            [self.navigationController pushViewController:workReportController animated:YES];
        }
            break;
        case 4:
        {
            ApprovalViewController *approvalController = [[ApprovalViewController alloc] init];
            approvalController.title = @"审批";
            approvalController.hidesBottomBarWhenPushed = YES;
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
            backItem.title = @"";
            self.navigationItem.backBarButtonItem = backItem;
            [self.navigationController pushViewController:approvalController animated:YES];
        }
            break;
        case 5:
        {
            PlanViewController *scheduleController = [[PlanViewController alloc] init];
            scheduleController.title = @"我的日程";
            scheduleController.flagFromWhereIntoPlan = 0;
            scheduleController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:scheduleController animated:YES];
        }
            break;
        case 6:
        {
            TaskViewController *taskController = [[TaskViewController alloc] init];
            taskController.title = @"任务";
            taskController.hidesBottomBarWhenPushed = YES;
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
            backItem.title = @"";
            self.navigationItem.backBarButtonItem = backItem;
            [self.navigationController pushViewController:taskController animated:YES];
        }
            break;
        case 7:
        {
            KnowledgeFileViewController *knowledgeController = [[KnowledgeFileViewController alloc] init];
            knowledgeController.strTitle = @"知识库";
            knowledgeController.typeKnowledge = -1;
            knowledgeController.typeKnowledgeSearchView = 0;
            knowledgeController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:knowledgeController animated:YES];
        }
            break;
        default:
            break;
    }
   
}


#pragma mark - 红点个数 
- (void)getUnReadMsgNumber {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [AFNHttp get:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, OFFICE_UNREAD_COUNT] params:params success:^(id responseObj) {
        NSLog(@"OA--getUnReadMsgNumber--%@", responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            if ([responseObj objectForKey:@"unReads"]) {
                [self notifyUnReadNums:[responseObj objectForKey:@"unReads"]];
            }
        }
        
    } failure:^(NSError *error) {
        NSLog(@"OA--getUnReadMsgNumber------%@", error);
    }];
    
}

///刷新未读消息数
-(void)notifyUnReadNums:(NSArray *)unRrads{
    /*
     {
     count = 0;
     type = 3;
     }
     */
    NSMutableArray *oaModuleOptions = [[NSMutableArray alloc] init];
    [oaModuleOptions addObjectsFromArray:[NSUserDefaults_Cache getOAModuleOptions]];
    
    NSInteger count = 0;
    if (oaModuleOptions) {
        count = [oaModuleOptions count];
    }
    
    NSInteger countUnRead = 0;
    if (unRrads) {
        countUnRead = [unRrads count];
    }
    
    NSDictionary *itemUn;
    BOOL isFound = FALSE;
    ///消息数据列表
    for (int i=0; i<countUnRead; i++) {
        itemUn = [unRrads objectAtIndex:i];
        NSInteger type = [[itemUn safeObjectForKey:@"type"] integerValue];
        isFound = FALSE;
        for (int j=0; !isFound && j<count; j++) {
            if (type == [[[oaModuleOptions objectAtIndex:j] safeObjectForKey:@"tag"] integerValue]) {
                NSDictionary *item = [oaModuleOptions objectAtIndex:j];
                NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:item];
                [mutableItemNew setValue:[itemUn safeObjectForKey:@"count"] forKey:@"unreadmsg"];
                //修改数据
                [oaModuleOptions setObject: mutableItemNew atIndexedSubscript:j];
                isFound = TRUE;
            }
        }
    }
    ///存储
    [NSUserDefaults_Cache setOAModuleOptions:oaModuleOptions];
    ///刷新列表数据
    [self notifyTableview:oaModuleOptions];
}


#pragma mark - 本地通知事件
-(void)registObserverByNewestTrend
{
    NSLog(@"注册本地消息通知事件...");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyNewestTrend:) name:SKT_OA_HOME_TREND_OBSERVER_NAME object:nil];
}

-(void)removeObserverByNewestTrend{
    NSLog(@"移除本地消息通知事件...");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SKT_OA_HOME_TREND_OBSERVER_NAME object:nil];
}

///根据最新动态  刷新UI
- (void)notifyNewestTrend:(NSNotification*) notification{
    NSLog(@"notifyNewestTrend---dy->");
    [self.tableview reloadData];
}

@end
