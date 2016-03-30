//
//  Main_RootViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "Home_RootViewController.h"
#import "NSUserDefaults_Cache.h"
#import "UIView+Common.h"
#import "HomePaggingNavBar.h"
#import "FMDBManagement.h"
#import "Quick.h"
#import "QuickGroup.h"
#import "QuickAddView.h"
#import "QuickSettingViewController.h"
#import "Record.h"

#import "CommonStaticVar.h"
#import "AddressBookViewController.h"
#import "SDImageCache.h"
#import "MsgViewController.h"
#import "HomeSeacherController.h"
#import "ReleaseViewController.h"
#import "CustomerNewViewController.h"
#import "ContactNewViewController.h"
#import "LeadNewViewController.h"
#import "OpportunityNewViewController.h"
#import "MapViewViewController.h"
#import "RecordSendViewController.h"

#import "ScheduleNewViewController.h"
#import "TaskNewViewController.h"
#import "ApprovalApplyViewController.h"
#import "WRNewViewController.h"

#import "CommonUnReadMsgForCycle.h"
#import "CommonUnReadTabBarPoint.h"
#import "WorkGroupRecordViewController.h"


#import "CustomTabBarViewController.h"
#import "LLC_NSUserDefaults_Cache.h"


#import "CRM_RootViewController.h"
#import "Today_HomeViewController.h"
#import "PlanViewController.h"
#import "TaskViewController.h"
#import "ApprovalViewController.h"
#import "WorkReportViewController.h"
#import "KnowledgeFileViewController.h"

#import "TodayCollectionCellA.h"
#import "TodayHeaderView.h"
#import "InfoViewController.h"


#define FirstLineHight 80.0  // 400  今日工作  工作圈   高度
#define OtherLineHight 75.0
#define ItemWidth (kScreen_Width - 1 )/ 2.0
#define FirstLineTopSpacing 32 //第一行 上下间距
#define FirstLineLeftSpacing 30 //第一行 左右间距
#define SecondLineLeftSpacing 50 //第一行 左右间距
#define SecondLineTopSpacing 20 //第二行 上下间距

@interface Home_RootViewController ()<UIScrollViewDelegate,UIActionSheetDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>{

    ///OA menu数据  用以获取未读消息数
    NSArray *arrOAMenuData;
}

/**
 * 显示内容的容器
 */
@property (nonatomic, strong) UIScrollView *m_scrollView;

@property (nonatomic, strong) HomePaggingNavBar *m_paggingNavBar;
@property (nonatomic, strong) UIButton *quickAddBtn;
@property (nonatomic, strong) QuickAddView *quickAddView;

@property (nonatomic, strong) CommonUnReadMsgForCycle *cycleEvent;
@property (strong, nonatomic) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataSourceArray;

@end

@implementation Home_RootViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.quickAddView.sourceArray = [[FMDBManagement sharedFMDBManager] getQuickDataSource];
    
    ///读取缓存数据
    arrOAMenuData = [NSUserDefaults_Cache getOAModuleOptions];

    WorkGroupRecordViewController *feedController = [[WorkGroupRecordViewController alloc] init];
    feedController.typeOfView = @"homeworkzone";
    
    [CommonStaticVar setFlagOfWorkGroupViewFrom:@"homeworkzone"];
    [_collectionView reloadData];
    [self registObserverByNewestTrend];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeObserverByNewestTrend];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.view.backgroundColor = kView_BG_Color;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIBarButtonItem *colleagueItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_bar_colleague"] style:UIBarButtonItemStylePlain target:self action:@selector(colleagueItemPress)];
    self.navigationItem.leftBarButtonItem = colleagueItem;
    
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_bar_search"] style:UIBarButtonItemStylePlain target:self action:@selector(searchItemmPress)];
    self.navigationItem.rightBarButtonItem = searchItem;
    
    // 添加titleview
//    self.navigationItem.titleView = self.m_paggingNavBar;
    
    // 添加视图容器
//    [self.view addSubview:self.m_scrollView];
//    self.title = @"商客通";
    self.navigationItem.title = @"商客通";
    self.view.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
//    self.view.backgroundColor = [UIColor colorWithHexString:@"e5e5e5"];
    
    // 建表快捷操作
    [[FMDBManagement sharedFMDBManager] createQuickTable];
    /*
    WorkGroupRecordViewController *feedController = [[WorkGroupRecordViewController alloc] init];
    feedController.typeOfView = @"homeworkzone";
    ///默认设置标记变量为首页工作圈
    [CommonStaticVar setFlagOfWorkGroupViewFrom:@"homeworkzone"];
    
    NSArray *titleArray = @[@"今天", @"工作圈", @"仪表盘"];
    NSArray *controllerArray = @[@"Today_HomeViewController", @"WorkGroupRecordViewController", @"Instrument_HomeViewController"];
    
    _m_paggingNavBar.currentPage = 0;
    _m_paggingNavBar.titlesArray = titleArray;
    
    [_m_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    [controllerArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Class class = NSClassFromString((NSString*)obj);
        UIViewController *viewController = [[class alloc] init];
        [viewController.view setX:idx * kScreen_Width];
        viewController.title = titleArray[idx];
        
        [self addChildViewController:viewController];
        [_m_scrollView addSubview:viewController.view];
    }];
    [_m_scrollView setContentSize:CGSizeMake(kScreen_Width*controllerArray.count, kScreen_Height)];
    */
    // 添加快捷键
//    [self.view addSubview:self.quickAddBtn];
    //9宫格
//    [self addNewViewForTopModules];
//    [self addNewViewForKindsOfModules];
    
    //添加数据源
    _dataSourceArray  = [NSMutableArray arrayWithCapacity:0];
    NSArray *namesArray = @[@"CRM", @"今日工作", @"工作圈", @"日程", @"任务", @"工作报告", @"审批", @"知识库"];
    NSArray *imgsArray = @[@"Home_CRM", @"Home_Today_Normal", @"Home_WorkGroup_Normal", @"Home_Schedule", @"Home_Task", @"Home_WorkReport", @"Home_Approval", @"Home_Knowledge"];
    NSArray *detailArray = @[@"把客户装进口袋", @"今日事，今日毕", @"同事间的微博", @"按行程做事更轻松", @"工作内容一目了然", @"及时汇报每日成果", @"审批结果提早知道", @"随时获得支持"];
    for (int i = 0; i < namesArray.count; i++) {
        NSDictionary *newDict = @{@"titleName" : namesArray[i],
                                  @"detailName" :detailArray[i],
                                  @"icon" : imgsArray[i],
                                  @"tag" : @(i + 1)};
        [_dataSourceArray addObject:newDict];
    }
    
    
    ///获取缓存LLC账号信息
    NSDictionary *account = [LLC_NSUserDefaults_Cache getUserAccountInfo];
    NSString *userName = @"";
    NSString *companyName = @"";
    if (account) {
        userName = [account safeObjectForKey:@"userName"];
        companyName = [account safeObjectForKey:@"companyName"];
    }
    
    NSLog(@"userName:%@",userName);
    NSLog(@"companyName:%@",companyName);
    
    if (userName && userName.length > 0  && companyName && companyName.length > 0) {
        //400设置 根据条件限制 进行添加
        NSDictionary *newDict = @{@"titleName" : @"400设置",
                                  @"detailName" : @"绑定号码、查看话单",
                                  @"icon" : @"Home_400_Normal",
                                  @"tag" : @(0)};
        [_dataSourceArray insertObject:newDict atIndex:0];
        NSDictionary *addNullDict = @{@"titleName" : @"",
                                      @"detailName" : @"",
                                      @"icon" : @"",
                                      @"tag" : @(100)};
        [_dataSourceArray addObject:addNullDict];
    }
    
    
    /*
    //400设置 根据条件限制 进行添加
    NSDictionary *newDict = @{@"titleName" : @"400设置",
                              @"detailName" : @"绑定号码、查看话单",
                              @"icon" : @"Home_400_Normal",
                              @"tag" : @(0)};
    [_dataSourceArray insertObject:newDict atIndex:0];
    NSDictionary *addNullDict = @{@"titleName" : @"",
                                  @"detailName" : @"",
                                  @"icon" : @"",
                                  @"tag" : @(100)};
    [_dataSourceArray addObject:addNullDict];
    */
    
    
    // 创建布局
    UICollectionViewFlowLayout *layou = [[UICollectionViewFlowLayout alloc] init];
    //设置Item的最小间隔
    layou.minimumInteritemSpacing = 1;
    //设置行与行之间的间隔
    layou.minimumLineSpacing = 1;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height - 64 - 44) collectionViewLayout:layou];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;

    //注册item
    UINib *nib = [UINib nibWithNibName:@"TodayCollectionCellA"
                                bundle: [NSBundle mainBundle]];
    [_collectionView registerNib:nib forCellWithReuseIdentifier:@"TodayCollectionCellAIdentifier"];
    //注册页眉
    [_collectionView registerClass:[TodayHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TodayHeaderViewIdentifier"];
    [self.view addSubview:_collectionView];
    
    ///初始化tababr 红点
    [CommonUnReadTabBarPoint initTabbarIconView];
    [self addIconToTabbar];
    
    ///5s后轮询查询未读消息
    self.cycleEvent = [[CommonUnReadMsgForCycle alloc] init];
    [self getUnReadMsgForCycle];
    [self performSelector:@selector(showSystemInformWithCache) withObject:nil afterDelay:3.0f];
}

- (void)didReceiveMemoryWarning {
    if ([self isViewLoaded] && [self.view window] == nil) {
        NSLog(@"--home--didReceiveMemoryWarning----->");
        self.view = nil;
        ///清除图片相关缓存
        [[SDImageCache sharedImageCache] clearMemory];
        [[SDImageCache sharedImageCache] clearDisk];
    }
}

#pragma mark - event response
- (void)colleagueItemPress {
    AddressBookViewController *addressBookController = [[AddressBookViewController alloc] init];
    addressBookController.title = @"通讯录";
    addressBookController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addressBookController animated:YES];
}

- (void)searchItemmPress {
    
    HomeSeacherController *controller = [[HomeSeacherController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.flagToHomeSearch = 0;
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)quickAddBtnPress {
    [self.tabBarController.view addSubview:self.quickAddView];
    [_quickAddView popAnimationShow];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _m_paggingNavBar.contentOffset = scrollView.contentOffset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 得到没页的宽度
    CGFloat pageWidth = CGRectGetWidth(_m_paggingNavBar.frame);
    
    // 根据当前的x坐标和宽度计算出当前页数
    _m_paggingNavBar.currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth);
    
}

#pragma mark - setters and getters
- (UIScrollView*)m_scrollView {
    if (!_m_scrollView) {
        _m_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
        _m_scrollView.backgroundColor = [UIColor whiteColor];
        _m_scrollView.pagingEnabled = YES;
        _m_scrollView.delegate = self;
        _m_scrollView.bounces = NO;
        _m_scrollView.showsHorizontalScrollIndicator = NO;
        _m_scrollView.showsVerticalScrollIndicator = NO;
    }
    return _m_scrollView;
}

- (HomePaggingNavBar*)m_paggingNavBar {
    if (!_m_paggingNavBar) {
        _m_paggingNavBar = [[HomePaggingNavBar alloc] initWithFrame:CGRectMake(0, 0, 212, 44)];
    }
    return _m_paggingNavBar;
}

- (UIButton*)quickAddBtn {
    if (!_quickAddBtn) {
        UIImage *image = [UIImage imageNamed:@"today_quick_add"];
        _quickAddBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _quickAddBtn.frame = CGRectMake(CGRectGetWidth(self.view.bounds) - 20 - image.size.width, CGRectGetHeight(self.view.bounds) - 20 - image.size.width - 50, image.size.width, image.size.height);
        _quickAddBtn.layer.shadowOpacity  = 0.8;
        _quickAddBtn.layer.shadowOffset = CGSizeMake(2,3);
        _quickAddBtn.layer.shadowRadius = 4;
        [_quickAddBtn setImage:image forState:UIControlStateNormal];
        [_quickAddBtn setImage:image forState:UIControlStateHighlighted];
        [_quickAddBtn addTarget:self action:@selector(quickAddBtnPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _quickAddBtn;
}

- (QuickAddView*)quickAddView {
    if (!_quickAddView) {
        _quickAddView = [[QuickAddView alloc] initWithFrame:kScreen_Bounds];
        @weakify(self);
        _quickAddView.tapClickBlock = ^(NSString *string) {
            @strongify(self);
            
            if (![string isEqualToString:@"设置"]) {
                [self.quickAddView popAnimationDismiss];
            }
            
            if ([string isEqualToString:@"设置"]) {
                [self quickToSetting];
            }
            else if ([string isEqualToString:@"发布动态"]) {
                [self quickToSendRelease];
            }
            else if ([string isEqualToString:@"新建客户"]) {
                [self quickToNewCustomer];
            }
            else if ([string isEqualToString:@"新建日程"]) {
                [self quickToNewSchedule];
            }
            else if ([string isEqualToString:@"快速签到"]) {
                [self quickToSignIn];
            }
            else if ([string isEqualToString:@"名片扫描"]) {
                [self quickToScanfNewContact];
            }
            else if ([string isEqualToString:@"新建联系人"]) {
                [self quickToNewContact];
            }
            else if ([string isEqualToString:@"提交审批"]) {
                [self quickToNewApproval];
            }
            else if ([string isEqualToString:@"新建销售线索"]) {
                [self quickToNewLead];
            }
            else if ([string isEqualToString:@"新建任务"]) {
                [self quickToNewTask];
            }
            else if ([string isEqualToString:@"新建工作报告"]) {
                [self quickToNewReport];
            }
            else if ([string isEqualToString:@"新建销售机会"]) {
                [self quickToNewSaleChance];
            }
            else if ([string isEqualToString:@"群发短信"]) {
                [self quickToSMS];
            }
        };
    }
    return _quickAddView;
}

- (void)quickToSetting {
    QuickSettingViewController *quickSettingController = [[QuickSettingViewController alloc] init];
    UINavigationController *settingNav = [[UINavigationController alloc] initWithRootViewController:quickSettingController];
    [kKeyWindow.rootViewController presentViewController:settingNav animated:YES completion:nil];
}

- (void)quickToSendRelease {
    ReleaseViewController *releaseController = [[ReleaseViewController alloc] init];
    releaseController.title = @"发布动态";
    releaseController.typeOfOptionDynamic = TypeOfOptionDynamicRelease;
    releaseController.ReleaseSuccessNotifyData = ^(){
    };
    releaseController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:releaseController animated:YES];
}

- (void)quickToNewCustomer {
    CustomerNewViewController *customerNewController = [[CustomerNewViewController alloc] init];
    customerNewController.title = @"创建客户";
    customerNewController.params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    customerNewController.refreshBlock = ^{
        
    };
    customerNewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:customerNewController animated:YES];
}

///日程
- (void)quickToNewSchedule {
    
    NSDictionary *userInfo = [NSUserDefaults_Cache getUserInfo];
    ScheduleNewViewController *controller = [[ScheduleNewViewController alloc] init];
    
    controller.dateString = [CommonFuntion dateToString:[NSDate date] Format:@"yyyy-MM-dd HH:mm"];
    controller.userId = [[userInfo safeObjectForKey:@"id"] integerValue];

    controller.userName = [userInfo safeObjectForKey:@"name"];
    controller.userIcon = [userInfo safeObjectForKey:@"icon"];
    controller.title = @"新建日程";
    controller.refreshBlock = ^{
        
    };
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)quickToSignIn {
    MapViewViewController *mapController = [[MapViewViewController alloc] init];
    mapController.hidesBottomBarWhenPushed = YES;
    mapController.typeOfMap = @"location";
    mapController.LocationResultBlock = ^(CLLocationCoordinate2D locCoordinate,NSString *location){
        Record *record = [[Record alloc] init];
        record.recordId = @"A003";
        record.position = location;
        record.latitude = [NSString stringWithFormat:@"%f", locCoordinate.latitude];
        record.longitude = [NSString stringWithFormat:@"%f", locCoordinate.longitude];
        
        RecordSendViewController *recordController = [[RecordSendViewController alloc] init];
        recordController.title = @"添加拜访签到记录";
        recordController.curRecord = record;
        recordController.isQuickSignIn = YES;
        recordController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:recordController animated:YES];
    };
    mapController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mapController animated:YES];
}

- (void)quickToNewContact {
    ContactNewViewController *newController = [[ContactNewViewController alloc] init];
    newController.title = @"新建联系人";
    newController.requestInitPath = kNetPath_Contact_New;
    newController.requestAddPath = kNetPath_Contact_EditOrSave;
    newController.params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    newController.refreshBlock = ^{
        
    };
    newController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:newController animated:YES];
}

- (void)quickToScanfNewContact {
    ContactNewViewController *newController = [[ContactNewViewController alloc] init];
    newController.title = @"新建联系人";
    newController.requestInitPath = kNetPath_Contact_New;
    newController.requestAddPath = kNetPath_Contact_EditOrSave;
    newController.requestScanningPath = kNetPath_Contact_Scanning;
    newController.params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    newController.isScanning = YES;
    newController.refreshBlock = ^{
        
    };
    newController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:newController animated:YES];
}

///审批
- (void)quickToNewApproval {
    ApprovalApplyViewController *applyController = [[ApprovalApplyViewController alloc] init];
    applyController.title = @"申请类型";
    applyController.applyType = ApplyFlowTypeApprovalType;
    applyController.refreshBlock = ^{
        
    };
    applyController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:applyController animated:YES];
}

- (void)quickToNewLead {
    LeadNewViewController *newController = [[LeadNewViewController alloc] init];
    newController.title = @"创建销售线索";
    newController.params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    newController.refreshBlock = ^{
    };
    newController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:newController animated:YES];
}

///任务
- (void)quickToNewTask {
    TaskNewViewController *newTaskController = [[TaskNewViewController alloc] init];
    newTaskController.title = @"新建任务";
    newTaskController.refreshBlock = ^{
        
    };
    newTaskController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:newTaskController animated:YES];
}

///工作报告
- (void)quickToNewReport {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"写日报", @"写周报", @"写月报", nil];
    actionSheet.tag = 200;
    [actionSheet showInView:self.view];
}

- (void)quickToNewSaleChance {
    OpportunityNewViewController *newController = [[OpportunityNewViewController alloc] init];
    newController.title = @"创建销售机会";
    newController.refreshBlock = ^{
        
    };
    newController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:newController animated:YES];
}

- (void)quickToSMS {
    MsgViewController *controller = [[MsgViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;
    
    if (actionSheet.tag == 200) {
        NSArray *array = @[@"新建日报", @"新建周报", @"新建月报"];
        WRNewViewController *newReportController = [[WRNewViewController alloc] init];
        newReportController.title = array[buttonIndex];
        newReportController.newType = WorkReportNewTypeNew;
        newReportController.reportType = buttonIndex;
        newReportController.refreshBlock = ^{
           
        };
        newReportController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:newReportController animated:YES];
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


#pragma mark - 开始轮询查询未读消息
-(void)getUnReadMsgForCycle{
    [self cycleRequsetUnReadMsg];
    [NSTimer scheduledTimerWithTimeInterval:60.0
                                     target:self
                                   selector:@selector(cycleRequsetUnReadMsg)
                                   userInfo:nil repeats:YES];
}


-(void)cycleRequsetUnReadMsg{
    if (self.cycleEvent == nil) {
        self.cycleEvent = [[CommonUnReadMsgForCycle alloc] init];
    }
    [self.cycleEvent getUnReadMsgForCycle];
}


#pragma mark - 添加红点到tababr
-(void)addIconToTabbar{
    [self.tabBarController.tabBar addSubview:appDelegateAccessor.moudle.icon_unread_skt];
    [self.tabBarController.tabBar addSubview:appDelegateAccessor.moudle.icon_unread_im];
    [self.tabBarController.tabBar addSubview:appDelegateAccessor.moudle.icon_unread_crm];
    [self.tabBarController.tabBar addSubview:appDelegateAccessor.moudle.icon_unread_oa];
    [self.tabBarController.tabBar addSubview:appDelegateAccessor.moudle.icon_unread_me];
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSourceArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TodayCollectionCellA *cell = [[TodayCollectionCellA alloc] init];
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TodayCollectionCellAIdentifier" forIndexPath:indexPath];
    cell.backgroundColor =[UIColor whiteColor];
    UIView* selectedBGView = [[UIView alloc] initWithFrame:cell.bounds];
    if (indexPath.row == 9) {
        selectedBGView.backgroundColor = [UIColor whiteColor];
    } else {
        selectedBGView.backgroundColor = [UIColor colorWithHexString:@"0xefeff4"];
    }
    cell.selectedBackgroundView = selectedBGView;
    
    cell.imgNew.hidden = YES;
    
    NSDictionary *newDict = [NSDictionary dictionaryWithDictionary:_dataSourceArray[indexPath.row]];
    cell.titleLabel.text = [newDict objectForKey:@"titleName"];
    cell.titleLabel.font = [UIFont systemFontOfSize:15];
    cell.detailLabel.textColor = [UIColor colorWithHexString:@"333333"];
    cell.detailLabel.text = [newDict objectForKey:@"detailName"];
    cell.detailLabel.font = [UIFont systemFontOfSize:11];
    cell.detailLabel.textColor = [UIColor colorWithHexString:@"a5a5a5"];
    cell.iconImgView.image = [UIImage imageNamed:[newDict objectForKey:@"icon"]];
    
    ///刷新红点
    [self notifyHomeNewPoint:newDict inCell:cell];
    
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(kScreen_Width, 110);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(ItemWidth, OtherLineHight);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 1) {
//        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionReusableIdentifier" forIndexPath:indexPath];
//        view.backgroundColor = [UIColor colorWithHexString:@"F8F8F8"];
//        return view;
//    }
    TodayHeaderView *head = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TodayHeaderViewIdentifier" forIndexPath:indexPath];
    head.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    head.bgView.backgroundColor = [UIColor whiteColor];
    //添加进入事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushIntoInfoView)];
    [head addGestureRecognizer:tap];
    NSString *name = @"";
    NSString *company = @"";
    NSString *icon = @"";
    NSDictionary *userInfo = [NSUserDefaults_Cache getUserInfo];
    if(userInfo){
        name = [userInfo safeObjectForKey:@"name"];
        company = [userInfo safeObjectForKey:@"companyName"];
        icon = [userInfo safeObjectForKey:@"icon"];
    }
    
    [head.headerImageView sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
    head.nameLabel.text = name;
    head.companyLabel.text = company;
    head.rightImageView.image = [UIImage imageNamed:@"activity_Arrow"];
    return head;
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%ld %ld", indexPath.section, indexPath.row);
    [collectionView selectItemAtIndexPath:nil animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    if (indexPath.row == 9) {
        return;
    }
    NSDictionary *newDict = _dataSourceArray[indexPath.row];
    [self buttonOfKindsOfModules:[[newDict objectForKey:@"tag"] integerValue]];
}

#pragma mark - 
- (void)addNewViewForTopModules {
    // Normal   Selected
    NSArray *namesArray = @[@"400设置", @"今日工作", @"工作圈"];
    NSArray *imgsArray = @[@"Home_400_", @"Home_Today_", @"Home_WorkGroup_"];
    UIView *firstBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, FirstLineHight)];
    firstBgView.backgroundColor = [UIColor colorWithHexString:@"0x2e3440"];
    [self.view addSubview:firstBgView];
    for (int i = 0; i < namesArray.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tag = i;
        [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@Normal", imgsArray[i]]] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@Selected", imgsArray[i]]] forState:UIControlStateHighlighted];
        if (i == 0) {
            button.frame = CGRectMake(FirstLineLeftSpacing - 1, FirstLineTopSpacing, (ItemWidth - FirstLineLeftSpacing * 2), (ItemWidth - FirstLineLeftSpacing * 2) / 3 * 2);
        } else {
            button.frame = CGRectMake(ItemWidth * i + (ItemWidth - 40) / 2, FirstLineTopSpacing, 40, 40);
        }
        
        [button addTarget:self action:@selector(buttonOfKindsOfModules:) forControlEvents:UIControlEventTouchUpInside];
        UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
        titleButton.tag = i;
        [titleButton setTitle:namesArray[i] forState:UIControlStateNormal];
        [titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        titleButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [titleButton addTarget:self action:@selector(buttonOfKindsOfModules:) forControlEvents:UIControlEventTouchUpInside];
        titleButton.frame = CGRectMake(ItemWidth * i, FirstLineHight - FirstLineTopSpacing - 20, ItemWidth, 20);

//        UILabel *titleLabel = [[UILabel alloc] init];
//        titleLabel.text = namesArray[i];
//        titleLabel.textAlignment = NSTextAlignmentCenter;
//        titleLabel.font = [UIFont systemFontOfSize:15];
//        titleLabel.textColor = [UIColor whiteColor];
//        titleLabel.frame = CGRectMake(ItemWidth * i, FirstLineHight - FirstLineTopSpacing - 20, ItemWidth, 20);
        [firstBgView addSubview:button];
        [firstBgView addSubview:titleButton];
        
    }

}
- (void)pushIntoInfoView {
    InfoViewController *infoController = [[InfoViewController alloc] init];
    infoController.title = @"个人信息";
    infoController.hidesBottomBarWhenPushed = YES;
    infoController.infoTypeOfUser = InfoTypeMyself;
    [self.navigationController pushViewController:infoController animated:YES];
}
#pragma mark - 9宫格页面入口
//type  控制400显示与隐藏 0存在  1不存在
- (void)addNewViewForKindsOfModules {
    NSArray *namesArray = @[@"400设置", @"今日工作", @"工作圈", @"CRM", @"日程", @"任务", @"工作报告", @"审批", @"知识库"];
    NSArray *imgsArray = @[@"Home_400_Normal", @"Home_Today_Normal", @"Home_WorkGroup_Normal", @"Home_CRM", @"Home_Schedule", @"Home_Task", @"Home_WorkReport", @"Home_Approval", @"Home_Knowledge"];
    
//    NSArray *namesArray = @[@"CRM", @"日程", @"任务", @"工作报告", @"审批", @"知识库", @"发布动态", @"快速签到" ,@"名片扫描"];
//    NSArray *imgsArray = @[@"Home_CRM", @"Home_Schedule", @"Home_Task", @"Home_WorkReport", @"Home_Approval", @"Home_Knowledge", @"Home_WorkGroupRecord", @"Home_SignIn" ,@"Home_ScanfNewContact"];
    
    UIView *secondBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 64 + FirstLineHight, kScreen_Width, OtherLineHight * 3)];
    secondBgView.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
    
    int index = 0;
    NSInteger lineCount = 0;
    for (int i = index; i < namesArray.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tag = i + 3;
        UIImageView *imgView = [[UIImageView alloc] init];
        UILabel *titleLabel = [[UILabel alloc] init];
        imgView.frame = CGRectMake((ItemWidth - 30) / 2, SecondLineTopSpacing, 30, 30);
        imgView.image = [UIImage imageNamed:imgsArray[i]];
        titleLabel.frame = CGRectMake(0, OtherLineHight - SecondLineTopSpacing - 20, ItemWidth, 20);
        titleLabel.text = namesArray[i];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:15];
        if (lineCount < 2) {
            button.frame = CGRectMake(ItemWidth * (lineCount % 2), 0, ItemWidth - 0.5, OtherLineHight - 0.5);
        } else if (2 <= lineCount && lineCount < 4) {
            button.frame = CGRectMake(ItemWidth * (lineCount % 2), OtherLineHight, ItemWidth - 0.5, OtherLineHight - 0.5);
        } else if (4 <= lineCount && lineCount < 6) {
            button.frame = CGRectMake(ItemWidth * (lineCount % 2), OtherLineHight, ItemWidth - 0.5, OtherLineHight - 0.5);
        } else {
            button.frame = CGRectMake(ItemWidth * (lineCount % 2), OtherLineHight + OtherLineHight, ItemWidth - 0.5, OtherLineHight - 0.5);
        }
        [button setBackgroundImage:[CommonFuntion createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [button setBackgroundImage:[CommonFuntion createImageWithColor:[UIColor colorWithHexString:@"0xefeff4"]] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(buttonOfKindsOfModules:) forControlEvents:UIControlEventTouchUpInside];
        [button addSubview:imgView];
        [button addSubview:titleLabel];
        [secondBgView addSubview:button];
        lineCount ++;
    }
    [self.view addSubview:secondBgView];
}
- (void)buttonOfKindsOfModules:(NSInteger)tag {
    NSLog(@"----按钮下标记-----%ld", tag);
    //0 - 11对应的事件
    //[@"400", @"今日工作", @"工作圈", @"CRM", @"日程", @"任务", @"工作报告", @"审批", @"知识库", @"发布动态", @"快速签到" ,@"名片扫描"];
    switch (tag) {
        case 0:
        {
            [self llcenterLoginAction];
        }
            break;
        case 1:
        {
            self.tabBarController.selectedIndex = 2;
        }
            break;
        case 2:
        {
            Today_HomeViewController *controller = [[Today_HomeViewController alloc] init];
            controller.title = @"今日工作";
            controller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 3:
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
        case 4:
        {
            PlanViewController *controller = [[PlanViewController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 5:
        {
            TaskViewController *controller = [[TaskViewController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
            backItem.title = @"";
            self.navigationItem.backBarButtonItem = backItem;
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 6:
        {
            WorkReportViewController *controller = [[WorkReportViewController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
            backItem.title = @"";
            self.navigationItem.backBarButtonItem = backItem;
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 7:
        {
            ApprovalViewController *controller = [[ApprovalViewController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
            backItem.title = @"";
            self.navigationItem.backBarButtonItem = backItem;
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 8:
        {
            KnowledgeFileViewController *knowledgeController = [[KnowledgeFileViewController alloc] init];
            knowledgeController.strTitle = @"知识库";
            knowledgeController.typeKnowledge = -1;
            knowledgeController.typeKnowledgeSearchView = 0;
            knowledgeController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:knowledgeController animated:YES];
        }
            break;
        case 9:
        {
            [self quickToSendRelease];
        }
            break;
        case 10:
        {
            [self quickToSignIn];
        }
            break;
        case 11:
        {
            [self quickToScanfNewContact];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 跳转到联络中心

-(void)gotoLLCenterView{
    CustomTabBarViewController *controller = [[CustomTabBarViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}


//联络中心登录方法
- (void)llcenterLoginAction {
    ///获取缓存LLC账号信息
    NSDictionary *account = [LLC_NSUserDefaults_Cache getUserAccountInfo];
    
    if (account) {
        NSString *userName = [account safeObjectForKey:@"userName"];
        NSString *companyName = [account safeObjectForKey:@"companyName"];
        NSString *password = [account safeObjectForKey:@"password"];
        
        NSMutableDictionary *params=[NSMutableDictionary dictionary];
        [params setObject:userName forKey:@"userName"];
        [params setObject:companyName forKey:@"companyName"];
        [params setObject:password forKey:@"password"];
        
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        [hud show:YES];
        // 发起请求
        [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_LOGIN_ACTION] params:params success:^(id jsonResponse) {
            [hud hide:YES];
            
            NSDictionary *dic = jsonResponse;
            NSLog(@"登录responseObj:%@",[dic description]);
            NSLog(@"desc :%@",[jsonResponse objectForKey:@"desc"]);
            
            if (jsonResponse && [[jsonResponse objectForKey:@"status"] integerValue] == 1) {
                //登录成功
                [CommonFuntion showToast:[jsonResponse objectForKey:@"desc"] inView:self.view];
                
                if ([[params safeObjectForKey:@"userName"] isEqualToString:@"boss"]) {
                    [CommonStaticVar setAccountType:@"boss"];
                }else{
                    [CommonStaticVar setAccountType:@"normal"];
                }
                
                [self gotoLLCenterView];
            }else {
                //登录失败
                //            [CommonFuntion showToast:[jsonResponse objectForKey:@"desc"] inView:self.view];
//                NSLog(@"jsonResponse desc:%@",[jsonResponse safeObjectForKey:@"desc"]);
                [CommonFuntion showToast:@"加载失败" inView:self.view];
            }
            
        } failure:^(NSError *error) {
            NSLog(@"error:%@",error);
            [hud hide:YES];
            [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        }];
    }else{
        [CommonFuntion showToast:@"请重新登陆" inView:self.view];
    }
}


#pragma mark - 红点控制
-(void)notifyHomeNewPoint:(NSDictionary *)dicInfo inCell:(TodayCollectionCellA *)cell{

    NSInteger tag = [[dicInfo objectForKey:@"tag"] integerValue];
    
    switch (tag) {
        case 3:
        {
            ///工作圈
            if (appDelegateAccessor.moudle.icon_oa_workzone_newtrends && appDelegateAccessor.moudle.icon_oa_workzone_newtrends.length > 0) {
                cell.imgNew.hidden = NO;
            }
        }
            break;
        case 4:
        {
            ///日程
            if ([self isNewPointByType:5]) {
                cell.imgNew.hidden = NO;
            }
        }
            break;
        case 5:
        {
            ///任务
            if ([self isNewPointByType:6]) {
                cell.imgNew.hidden = NO;
            }
        }
            break;
        case 6:
        {
            ///工作报告
            if ([self isNewPointByType:3]) {
                cell.imgNew.hidden = NO;
            }
        }
            break;
        case 7:
        {
            ///审批
            if ([self isNewPointByType:4]) {
                cell.imgNew.hidden = NO;
            }
        }
            break;
        default:
            break;
    }
}

///判断是否有红点
-(BOOL)isNewPointByType:(NSInteger)type{
    NSInteger count = 0;
    if (arrOAMenuData) {
        count = [arrOAMenuData count];
    }
    NSDictionary *item;
    for (int i=0; i<count; i++) {
        item = [arrOAMenuData objectAtIndex:i];
        if ([[item objectForKey:@"tag"] integerValue] == type) {
            if ([[item objectForKey:@"unreadmsg"] integerValue] > 0) {
                return YES;
            }
            return NO;
        }
    }
    return NO;
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
    NSLog(@"notifyNewestTrend---home->");
    [self.collectionView reloadData];
}


#pragma mark-  判断是否有缓存未读的系统公告信息
-(void)showSystemInformWithCache{
    NSDictionary *inform = [NSUserDefaults_Cache getSystemInformValue];
    ///存在  且是未读状态
    if (inform) {
        ///判断是否在有效期内
        if (appDelegateAccessor.moudle.alertViewOfSysAnnouncement) {
            [appDelegateAccessor.moudle.alertViewOfSysAnnouncement dismissWithClickedButtonIndex:0 animated:NO];appDelegateAccessor.moudle.alertViewOfSysAnnouncement = nil;
        }
        
        ////判断是否在有效期内
        
        NSString *expireDate = [CommonFuntion getStringForTime:[[inform safeObjectForKey:@"expireDate"] longLongValue] withFormat:@"yyyy-MM-dd HH:mm:ss"];
        [CommonFuntion dateToString:[NSDate date] Format:@"yyyy-MM-dd HH:mm:ss"];
        
        if ([expireDate compare:[CommonFuntion dateToString:[NSDate date] Format:@"yyyy-MM-dd HH:mm:ss"]] == NSOrderedDescending) {
            appDelegateAccessor.moudle.alertViewOfSysAnnouncement = [[UIAlertView alloc]initWithTitle:@"系统公告" message:[NSString stringWithFormat:@"\n%@",[inform safeObjectForKey:@"content"]] delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
            appDelegateAccessor.moudle.alertViewOfSysAnnouncement.tag = 10001;
            appDelegateAccessor.moudle.alertViewOfSysAnnouncement.delegate = self;
            [appDelegateAccessor.moudle.alertViewOfSysAnnouncement show];
        }
        ///清空缓存
        [NSUserDefaults_Cache setSystemInformValue:nil];
    }
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10001) {
    }
}


@end
