//
//  SitListViewController.m
//  
//
//  Created by sungoin-zjp on 16/1/5.
//
//

#import "SitListViewController.h"
#import "SitCell.h"
#import "CommonFunc.h"
#import "MJRefresh.h"
#import "CommonNoDataView.h"
#import "CommonStaticVar.h"
#import "ContactBookAddNewLevel1ViewController.h"
#import "SitDetailsViewController.h"
#import "SitHeadCell.h"
#import "RootNavigationViewController.h"
#import "NavigationDetailViewController.h"
#import "AFSoundPlaybackHelper.h"
#import "AddSitToNavigationViewController.h"

@interface SitListViewController ()<UITableViewDataSource,UITableViewDelegate>{
    ///导航信息
    NSDictionary *navigationDic;
    ///导航列表
    NSArray *arrayNavgation;
    
    MBProgressHUD *hudSit;
}


@property(strong,nonatomic) UITableView *tableview;
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property(strong,nonatomic) NSMutableArray *dataSource;

@end


@implementation SitListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"坐席";
    self.view.backgroundColor = COLOR_BG;
    
    [self initData];
    [self initTableview];
    
    [self getNavigationDetails];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addNarBar];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [AFSoundPlaybackHelper stop_helper];
}


#pragma mark - 注册通知
-(void)RegistNotificationForUpdate
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUIForUpdateNavigationList) name:LLC_NOTIFICATON_SIT_LIST object:nil];
}
// 移除通知
-(void)removeNotificationForUpdate
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LLC_NOTIFICATON_SIT_LIST object:nil];
}

-(void)refreshUIForUpdateNavigationList{
    [self getNavigationDetails];
}

#pragma mark - 初始化data
-(void)initData{
    self.dataSource = [[NSMutableArray alloc] init];
}

#pragma mark - 读取测试数据
-(void)readTestData{
    id jsondata = [CommonFunc readJsonFile:@"sit_status_data"];
    [self.dataSource addObjectsFromArray:[[jsondata objectForKey:@"resultMap"] objectForKey:@"data"]];
    
    NSLog(@"self.dataSource:%@",self.dataSource);
}

#pragma mark - Nar Bar
-(void)addNarBar{
    
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
    self.tabBarController.navigationItem.rightBarButtonItems = nil;
    ///boss可增加
    if (![[CommonStaticVar getAccountType] isEqualToString:@"boss"]) {
        return;
    }

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightBarButtonAction)];
    self.navigationItem.rightBarButtonItem = addButton;
    
//    UIButton *rightButton=[UIButton buttonWithType:UIButtonTypeCustom];
//    rightButton.frame=CGRectMake(0, 0, 21, 20);
//    [rightButton setBackgroundImage:[UIImage imageNamed:@"icon_data_notify.png"] forState:UIControlStateNormal];
//    [rightButton setBackgroundImage:[UIImage imageNamed:@"icon_data_notify.png"] forState:UIControlStateHighlighted];
//    
//    [rightButton addTarget:self action:@selector(rightBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    [self.tabBarController.navigationItem setRightBarButtonItem:addButton];
}

///新增
-(void)rightBarButtonAction{
    __weak typeof(self) weak_self = self;
    ContactBookAddNewLevel1ViewController *controller = [[ContactBookAddNewLevel1ViewController alloc] init];
    controller.navigationDic = navigationDic;
    controller.NotifySitListBlock = ^(){
        [weak_self getNavigationDetails];
    };
    [self.tabBarController.navigationController pushViewController:controller animated:YES];
}

///根导航页面
-(void)gotoRootNavigationView{
    __weak typeof(self) weak_self = self;
    RootNavigationViewController *controller = [[RootNavigationViewController alloc] init];
    controller.navigationDic = navigationDic;
    controller.NotifySitListBlock = ^(){
        [weak_self getNavigationDetails];
    };
    [self.tabBarController.navigationController pushViewController:controller animated:YES];
}

///非根导航详情
-(void)actionNavigationDetail:(id)sender{
    UIButton *btn = (UIButton*)sender;
    NSInteger section = btn.tag;
    NSDictionary *navDetail = [self.dataSource objectAtIndex:section];
    ///是根导航
    if ([[navigationDic safeObjectForKey:@"navigationId"] isEqualToString:[navDetail safeObjectForKey:@"ivrId"]]) {
        
        __weak typeof(self) weak_self = self;
        RootNavigationViewController *controller = [[RootNavigationViewController alloc] init];
        controller.navigationDic = nil;
        controller.navigationIdIvr = [navDetail safeObjectForKey:@"ivrId"];
        controller.NotifySitListBlock = ^(){
            [weak_self getNavigationDetails];
        };
        [self.tabBarController.navigationController pushViewController:controller animated:YES];
        
    }else{
        
        __weak typeof(self) weak_self = self;
        NavigationDetailViewController *controller = [[NavigationDetailViewController alloc] init];
        controller.navigationDic = navDetail;
        
        controller.NotifySitListBlock = ^(){
            [weak_self getNavigationDetails];
        };
        [self.tabBarController.navigationController pushViewController:controller animated:YES];
    }
}


#pragma mark - 播放音频
-(void)playSoundByUrl:(NSString *)urlSound{
    NSString *urlString = [navigationDic safeObjectForKey:@"navigationRingUrl"];
    NSLog(@"playNavigationRing urlString:%@",urlString);
    
    [AFSoundPlaybackHelper  playAndCacheWithUrl:urlString];
    
    /*
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AFSoundItem *item = [[AFSoundItem alloc] initWithStreamingURL:[NSURL URLWithString:urlString]];
        [AFSoundPlaybackHelper setAFSoundPlaybackHelper:[[AFSoundPlayback alloc] initWithItem:item]];
        
        [AFSoundPlaybackHelper play_helper];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AFSoundPlaybackHelper getAFSoundPlaybackHelper] listenFeedbackUpdatesWithBlock:^(AFSoundItem *item) {
                NSLog(@"Item duration: %ld - time elapsed: %ld", (long)item.duration, (long)item.timePlayed);
            } andFinishedBlock:^(void){
                NSLog(@"andFinishedBlock");
            }];
        });
    });
     */
}




#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStyleGrouped];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.sectionFooterHeight = 0;
    
    [self.view addSubview:self.tableview];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableview setTableFooterView:v];
    
    ///下拉刷新
    [self setupRefresh];
}


#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.dataSource) {
        return [self.dataSource count];
    }
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 2;
    }
    return [[[self.dataSource objectAtIndex:section] objectForKey:@"seats"] count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0){
        if ([CommonStaticVar getIvrStatus] == 1) {
            return 0.1;
        }
        return 40.0;
    }
    return 40.0;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if(section == 0){
        if ([CommonStaticVar getIvrStatus] == 1) {
            return nil;
        }else{
            UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
            headview.backgroundColor = COLOR_BG;
            ///title
            UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreen_Width-30, 40)];
            labelTitle.font = [UIFont boldSystemFontOfSize:14.0];
            
            labelTitle.textAlignment = NSTextAlignmentLeft;
            labelTitle.textColor = [UIColor darkGrayColor];
            labelTitle.text = @"IVR功能未开通(开通IVR功能创建更多子分组)";
            [headview addSubview:labelTitle];
            return headview;
        }
    }
    
    UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
    headview.backgroundColor = COLOR_BG;
    
    /*
    headview.tag = section;
    //    [headview addLineUp:NO andDown:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewTap:)];
    [headview addGestureRecognizer:tap];
     */
    
//    ///底部分割线
//    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 39, kScreen_Width, 1)];
//    line.image = [UIImage imageNamed:@"line.png"];
//    [headview addSubview:line];
    
    
    ///title
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreen_Width-100, 39)];
    labelTitle.font = [UIFont boldSystemFontOfSize:15.0];
    
    labelTitle.textAlignment = NSTextAlignmentLeft;
    labelTitle.textColor = COLOR_LIGHT_BLUE;
    labelTitle.text = [self getHeadViewTitle:section];
    [headview addSubview:labelTitle];
    
    
    ///icon
    UIImageView *icon = [[UIImageView alloc] init];
    icon.frame = CGRectMake(kScreen_Width-31, 10, 12, 19);
    icon.image = [UIImage imageNamed:@"btn_to_right_gray.png"];
    [headview addSubview:icon];
    
    
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRight.frame = CGRectMake(kScreen_Width-100, 0, 100, 40);
    btnRight.tag = section;
    [btnRight addTarget:self action:@selector(actionNavigationDetail:) forControlEvents:UIControlEventTouchUpInside];
    [headview addSubview:btnRight];
    
    
    ///分割线
    if ([[[self.dataSource objectAtIndex:section] objectForKey:@"seats"] count] == 0) {
        UIImageView *line = [[UIImageView alloc] init];
        line.frame = CGRectMake(0, 39, kScreen_Width, 1);
        line.image = [UIImage imageNamed:@"line"];
        [headview addSubview:line];
    }
    
    return headview;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ///head
    if(indexPath.section == 0){
        SitHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SitHeadCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SitHeadCell" owner:self options:nil];
            cell = (SitHeadCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        
        NSDictionary *item = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        [cell setCellDetail:item];
        
        cell.RightBtnActionBlock = ^(){
            __weak typeof(self) weak_self = self;
            if (indexPath.row == 0) {
                ///根导航详情
                [weak_self gotoRootNavigationView];
            }else if (indexPath.row == 1) {
                ///音频播放
                NSString *url = [item safeObjectForKey:@"ringurl"];
                [weak_self playSoundByUrl:url];
            }
        };
        
        return cell;
    }
    
    
    SitCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SitCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SitCell" owner:self options:nil];
        cell = (SitCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    [cell setCellDetail:[[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"seats"] objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 0){
        return;
    }
    
    NSDictionary *item = [[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"seats"] objectAtIndex:indexPath.row];
    __weak typeof(self) weak_self = self;
    SitDetailsViewController *controller =  [[SitDetailsViewController alloc] init];
    controller.navigationDic = navigationDic;
    controller.sitDetail = item;
    controller.NotifySitListBlock = ^(){
        [weak_self getNavigationDetails];
    };
    
//    controller.hidesBottomBarWhenPushed = YES;
    [self.tabBarController.navigationController pushViewController:controller animated:YES];
}


#pragma mark - 获取headview title信息
-(NSString *)getHeadViewTitle:(NSInteger)section{
    ///stageName
    NSString *navName = @"";
    if ([[self.dataSource objectAtIndex:section] objectForKey:@"navigationName"]) {
        navName = [[self.dataSource objectAtIndex:section] objectForKey:@"navigationName"];
    }
    ///最多显示6个，多出部门用...表示
    if (navName.length>6) {
        navName = [NSString stringWithFormat:@"%@...",[navName substringToIndex:6]];
    }
    
    return navName;
}
#pragma mark - 上拉下拉刷新相关事件
//集成刷新控件
- (void)setupRefresh
{
    NSString *dateKey = @"llcsitlist";
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [self.tableview addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:dateKey];
    
}


// 结束加载
-(void)reloadRefeshView{
    // 刷新列表
    [self.tableview reloadData];
    [self.tableview headerEndRefreshing];
}

// 下拉
- (void)headerRereshing
{
    NSLog(@"headerRereshing--下拉-->");
    [self getNavigationDetails];
}



#pragma mark - 没有数据时的view
-(void)setViewNoData:(NSString *)title{
    if (self.dataSource == nil || [self.dataSource count] == 0) {
        self.commonNoDataView = [CommonFunc commonNoDataViewIcon:@"list_empty.png" Title:title optionBtnTitle:@""];
    }
    [self.tableview addSubview:self.commonNoDataView];
}

-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
    }
}


#pragma mark - 网络请求
-(void)getSitListData{
}


#pragma mark 获取根导航详情
-(void)getNavigationDetails{
    hudSit = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hudSit];
    [hudSit show:YES];
    
    [self.dataSource removeAllObjects];
    [self.tableview reloadData];
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rDict setValue:@"" forKey:@"navigationId"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    
    NSLog(@"rParam:%@",rParam);
    
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_NAVIGATION_DETAILS_ACTION] params:rParam success:^(id jsonResponse) {
        
        
        NSLog(@"导航详情jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            if ([jsonResponse objectForKey:@"resultMap"]) {
                
                [self initDetailsData:jsonResponse];
                
            }else{
                NSLog(@"data------>:<null>");
                [hudSit hide:YES];
                [CommonFuntion showToast:@"加载异常" inView:self.view];
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            [hudSit hide:YES];
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getNavigationDetails];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            [hudSit hide:YES];
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        [hudSit hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
    
}


#pragma mark -获取导航分组
-(void)getNaviGroup{
    [self clearViewNoData];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    // 发起请求llc_cccc
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_SIT_STATUS_ACTION] params:params success:^(id jsonResponse) {
        
        NSLog(@"导航分组jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            id data = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"];
            if ([data respondsToSelector:@selector(count)] && [data count] > 0) {
                arrayNavgation = data;
                [self.dataSource addObjectsFromArray:data];
            }
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getNaviGroup];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        [hudSit hide:YES];
        [self  reloadRefeshView];
        
    } failure:^(NSError *error) {
        [hudSit hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        NSLog(@"%@",error);
        [self  reloadRefeshView];
    }];
}


///根导航详情信息
-(void)initDetailsData:(id)jsondata{
    navigationDic = [jsondata objectForKey:@"resultMap"];

    /*
     {
     desc = "<null>";
     resultMap =     {
     answerStrategy = 0;
     answerStrategyDesc = "";
     appointTimeWeek =         (
     1
     );
     areaCode = 1;
     areaName = "<null>";
     areaType = "<null>";
     childNavigationHasChildDesc = "\U53ef\U4ee5\U65b0\U589e";
     childNavigationKeyLength = 1;
     endTime =         (
     "23:59"
     );
     maxLevel = 10;
     navigationHasChild = 0;
     navigationId = 4008290377;
     navigationKey = "<null>";
     navigationLevel = 0;
     navigationName = 4008290377;
     navigationRingId = 116909264;
     navigationRingName = "backgroud.wav";
     navigationRingUrl = "http://www.sungoin.cn//voices/temp/rings/4008290377/2015080317465798.mp3";
     navigationType = 0;
     navigationsetChild = 1;
     sitRingId = "<null>";
     sitRingName = "<null>";
     startTime =         (
     "00:00"
     );
     timeType = 1;
     };
     status = 1;
     }
     
     */
    
    if (navigationDic) {
        
        NSMutableArray *rootInfo = [[NSMutableArray alloc] init];
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
        
        ///接入号
        [item setObject:@"navNum" forKey:@"tag"];
        [item setObject:@"接听分组:" forKey:@"name"];
        [item setObject:[navigationDic safeObjectForKey:@"navigationName"] forKey:@"content"];
        [rootInfo addObject:item];
        
        item = [[NSMutableDictionary alloc] init];
        ///企业彩铃
        [item setObject:@"navRing" forKey:@"tag"];
        [item setObject:@"企业彩铃:" forKey:@"name"];
        [item setObject:[navigationDic safeObjectForKey:@"navigationRingName"] forKey:@"content"];
        [item setObject:[navigationDic safeObjectForKey:@"navigationRingUrl"] forKey:@"ringurl"];
        [rootInfo addObject:item];
       
        [self.dataSource addObject:rootInfo];
    }
    
    ///测试数据
//    [self readTestData];
    [self getNaviGroup];
}



@end
