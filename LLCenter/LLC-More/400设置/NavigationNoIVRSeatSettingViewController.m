//
//  NavigationNoIVRSeatSettingViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-26.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//
#define pageSize 10
#import "NavigationNoIVRSeatSettingViewController.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"
#import "CommonStaticVar.h"
#import "CommonNoDataView.h"
#import "CustomPopView.h"
#import "NavigationSeatCell.h"
#import "EditNavigationNoIVRSeatViewController.h"
#import "MJRefresh.h"
#import "AFSoundPlaybackHelper.h"

@interface NavigationNoIVRSeatSettingViewController ()<UITableViewDataSource,UITableViewDelegate>{
    ///当前导航ID
    NSString *curNavigationId;
    ///导航信息
    NSDictionary *navigationDic;
    
    ///当前播放下标
    NSInteger indexPlaying;
    
    int soundDuration,watchDogCounter;
    
    //分页加载
    int listPage,lastPosition;
}

@property(strong,nonatomic) UITableView *tableview;
@property(strong,nonatomic) NSMutableArray *dataSource;
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;

@end

@implementation NavigationNoIVRSeatSettingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"导航设置";
    [super customBackButton];
    self.view.backgroundColor = COLOR_BG;
    [self initData];
//    [self readTestData];
    [self initTableview];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    listPage = 1;
    [self getNavigationDetails];
    [self.tableview reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [AFSoundPlaybackHelper stop_helper];
}

/*
 {如果当前导航有下级导航，则返回childNavigationList，否则返回sitList
 }
 navigationId(导航ID)
 navigationName(导航名称)
 navigationRingName(当前彩铃名称)
 navigationRingId(当前彩铃ID)
 navigationRingUrl(当前彩铃url)
 navigationKey(当前导航按键，按键进入时返回)
 timeType(时间类型，分流进入时返回)
 areaType(地区类型，分流进入时返回)
 sitRingId(当前导航的座席提示音)
 sitRingName(当前导航的座席提示音名称)
 answerStrategy(当前导航的接听策略，最后一级导航时返回)
 childNavigationHasChild (当前导航的下级导航是否有开再下一级导航的权限)
 navigationsetChild(当前导航的是否设置了下级导航0-是，1-否)
 navigationType(进入下级导航的方式 0-按键，1-分流)
 appointTimeWeek(指定时间,周次，星期时返回，例如周一返回1，周三返回3等等)、startTime(开始时间)、endTime(结束时间)、areaName(自定义地区时的地区名称)、areaCode(地区区号，以”,”分隔开)
 childNavigationKeyLength(下级导航的按键长度)
 childNavigationList(下级导航列表[childNavigationId 下级导航ID; childNavigationName 下级导航名称;
 childNavigationKeyPress 下级导航按键;
 childNavigationRing 下级导航彩铃;
 childNavigationRingUrl 下级导航彩铃URL;
 childNavigationHasChild 下级导航是否含有下级导航 ])
 sitList(座席列表[
 sitName 座席名称;
 sitNo 工号;
 sitPhone 绑定号码;
 waitDuration等待时长
 strategy 策略])
 */


#pragma mark - 读取测试数据
-(void)readTestData{
    
    /*
     navigationId(导航ID)
     navigationName(导航名称)
     navigationRingName(当前彩铃名称)
     navigationRingId(当前彩铃ID)
     navigationRingUrl(当前彩铃url)
     navigationKey(当前导航按键，按键进入时返回)
     timeType(时间类型，分流进入时返回)
     areaType(地区类型，分流进入时返回)
     sitRingId(当前导航的座席提示音)
     sitRingName(当前导航的座席提示音名称)
     answerStrategy(当前导航的接听策略，最后一级导航时返回)
     childNavigationHasChild (当前导航的下级导航是否有开再下一级导航的权限)
     navigationsetChild(当前导航的是否设置了下级导航0-是，1-否)
     navigationType(进入下级导航的方式 0-按键，1-分流)
     childNavigationKeyLength(下级导航的按键长度)
     */
    
    id jsondata = [CommonFunc readJsonFile:@"navigation_child_sit_data"];
    
    [self initDetailsData:jsondata];
    
}


-(void)initDetailsData:(id)jsondata{
    navigationDic = [jsondata objectForKey:@"resultMap"] ;
    if (navigationDic) {
        [self addNavBar];
        self.tableview.tableHeaderView = nil;
        self.tableview.tableHeaderView = [self creatHeadViewForTableView];
    }
    
    ///当前导航的ID
    curNavigationId = [navigationDic safeObjectForKey:@"navigationId"];
    
}

#pragma mark - Nav Bar
-(void)addNavBar{
    self.navigationItem.rightBarButtonItem = nil;
    UIButton *rightButton=[UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame=CGRectMake(0, 0, 25, 16);
    [rightButton setBackgroundImage:[UIImage imageNamed:@"icon_more_function.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"icon_more_function.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(rightBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    [self.navigationItem setRightBarButtonItem:rightBarButton];
    
    
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonAction)];
    self.navigationItem.rightBarButtonItem = editButton;
    
}

///
-(void)rightBarButtonAction{
//    [self showPopView];
    [self gotoEditNavigationView];
}


-(void)showPopView{
    NSArray *titles;
    NSArray *imgs;
    
    
    ///存在座席 不可删除
//    if (self.dataSource && [self.dataSource count] > 0) {
//        titles = [NSArray arrayWithObjects:@"编辑导航", nil];
//        imgs = [NSArray arrayWithObjects:@"icon_edit_nav.png", nil];
//    }else{
//        titles = [NSArray arrayWithObjects:@"编辑导航",@"删除导航", nil];
//        imgs = [NSArray arrayWithObjects:@"icon_edit_nav.png",@"icon_delete_img.png", nil];
//    }
    
    titles = [NSArray arrayWithObjects:@"编辑导航",@"删除导航", nil];
    imgs = [NSArray arrayWithObjects:@"icon_edit_nav.png",@"icon_delete_img.png", nil];
    
    
    CustomPopView *popView = [[CustomPopView alloc] initWithPoint:CGPointMake(0, 64+64) titles:titles imageNames:imgs];
    __weak typeof(self) weak_self = self;
    popView.selectBlock = ^(NSInteger index) {
        
        if (index == 0) {
            ///编辑底层导航和座席
            [weak_self gotoEditNavigationView];
        }else if(index == 1){
            ///删除导航
            if (self.dataSource && [self.dataSource count] > 0) {
                [CommonFuntion showToast:@"该导航存在坐席,请先在坐席管理中删除坐席" inView:self.view];
            }else{
                [weak_self showDeleteAlert];
            }
            
        }
        
    };
    [popView show];
}

///新增导航
-(void)gotoAddView{
    
}

///编辑导航-座席
-(void)gotoEditNavigationView{
    EditNavigationNoIVRSeatViewController *anc = [[EditNavigationNoIVRSeatViewController alloc] init];
    anc.detail = navigationDic;
    anc.sourNavigationSeatsOld = self.dataSource;
    anc.ringStatus = self.ringStatus;
    __weak typeof(self) weak_self = self;
    anc.NotifyNavigationList = ^{
        //        listPage = 1;
        //        [weak_self getSiteList];
    };
    
    [self.navigationController pushViewController:anc animated:YES];
}

///删除
-(void)gotoDeleteView{
    
}


#pragma mark - UIAlertView

///删除提示框
-(void)showDeleteAlert{
    UIAlertView *alertDelete = [[UIAlertView alloc] initWithTitle:nil message: @"确认删除当前导航?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alertDelete.tag = 1001;
    [alertDelete show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1001)
    {
        //删除
        if (buttonIndex == 1) {
            
        }
    }
}

#pragma mark - 初始化数据
-(void)initData{
    listPage = 1;
    indexPlaying = -1;
    self.dataSource = [[NSMutableArray alloc] init];
}


-(void)addFootView{
}

#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-64) style:UITableViewStylePlain];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.sectionFooterHeight = 0;
    [self.view addSubview:self.tableview];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableview setTableFooterView:v];
    
//    self.tableview.tableHeaderView = [self creatHeadViewForTableView];
    
    [self setupRefresh];
}


#pragma mark - 播放导航铃声
-(void)playNavigationRing{
    NSString *urlString = [navigationDic safeObjectForKey:@"navigationRingUrl"];
    NSLog(@"playNavigationRing urlString:%@",urlString);
    
    [AFSoundPlaybackHelper stop_helper];
    
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
}


#pragma mark - 创建HeadView
-(UIView *)creatHeadViewForTableView{
    UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 140)];
    headview.backgroundColor = [UIColor whiteColor];
    
    UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 30)];
    top.backgroundColor = COLOR_BG;
    
    ///提示
    UILabel *labelNotice = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, DEVICE_BOUNDS_WIDTH-40, 30)];
    labelNotice.textColor = [UIColor grayColor];
    labelNotice.font = [UIFont systemFontOfSize:13.0];
    labelNotice.text = @"IVR功能未开通(开通IVR功能创建更多子导航)";
    [top addSubview:labelNotice];
    
    ///当前导航
    UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, DEVICE_BOUNDS_WIDTH-40, 20)];
    labelName.textColor = [UIColor grayColor];
    labelName.font = [UIFont systemFontOfSize:15.0];
    
    ///当前导航名称
    UILabel *labelNavName = [[UILabel alloc] initWithFrame:CGRectMake(15, 85, DEVICE_BOUNDS_WIDTH-100, 20)];
    labelNavName.textColor = [UIColor blackColor];
    labelNavName.font = [UIFont systemFontOfSize:18.0];
    
    
    ///当前导航铃声
    UILabel *labelRing = [[UILabel alloc] initWithFrame:CGRectMake(15, 115, DEVICE_BOUNDS_WIDTH-100, 20)];
    labelRing.textColor = [UIColor grayColor];
    labelRing.font = [UIFont systemFontOfSize:15.0];
    
    if (([navigationDic safeObjectForKey:@"navigationRingName"] && [navigationDic safeObjectForKey:@"navigationRingName"].length > 0) && ([navigationDic safeObjectForKey:@"navigationRingUrl"] && [navigationDic safeObjectForKey:@"navigationRingUrl"].length > 0)) {
        UIButton *btnPlay = [UIButton buttonWithType:UIButtonTypeCustom];
        btnPlay.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-60, 90, 40, 40);
        [btnPlay setBackgroundImage:[UIImage imageNamed:@"icon_listen.png"] forState:UIControlStateNormal];
        [btnPlay addTarget:self action:@selector(playNavigationRing) forControlEvents:UIControlEventTouchUpInside];
        [headview addSubview:btnPlay];
        btnPlay.hidden = NO;
        ///彩铃未开通
        if (self.ringStatus == 0) {
            btnPlay.hidden = YES;
        }
    }
    
    NSInteger yPoint = 115;
    ///彩铃未开通  隐藏不显示
    if (self.ringStatus == 0) {
        yPoint = 115;
        labelRing.hidden = YES;
    }else{
        yPoint = 145;
        labelRing.hidden = NO;
    }
    
    [headview addSubview:top];
    [headview addSubview:labelName];
    [headview addSubview:labelNavName];
    [headview addSubview:labelRing];
    
    
    NSString *name = @"根导航";
    NSString *navName = @"";
    NSString *ringName = @"";
    if (navigationDic) {
//        NSString *navigationLevel = [CommonFunc translationArabicNum:[[navigationDic safeObjectForKey:@"navigationLevel"] integerValue]];
//        name = [NSString stringWithFormat:@"第%@层导航",navigationLevel];
        navName = [navigationDic safeObjectForKey:@"navigationName"];
        ringName = [navigationDic safeObjectForKey:@"navigationRingName"];
    }
    
    ///彩铃未开通
    if (self.ringStatus == 0) {
        ringName = @"空";
    }
    
    ///最多显示6个，多出部门用...表示
    if (navName.length>6) {
        navName = [NSString stringWithFormat:@"%@...",[navName substringToIndex:6]];
    }
    
    if (ringName.length > 8) {
        ringName = [NSString stringWithFormat:@"%@...",[ringName substringToIndex:8]];
    }
    
    labelName.text = name;
    labelNavName.text = [NSString stringWithFormat:@"名称: %@",navName];
    labelRing.text = [NSString stringWithFormat:@"当前彩铃: %@",ringName];
    
    
    ///接听策略
    UILabel *labelAnswerStrategy= [[UILabel alloc] initWithFrame:CGRectMake(15, yPoint, DEVICE_BOUNDS_WIDTH-100, 20)];
    labelAnswerStrategy.textColor = [UIColor grayColor];
    labelAnswerStrategy.font = [UIFont systemFontOfSize:15.0];
    
    NSString *answerStrategy = @"";
    
    if (navigationDic) {
        answerStrategy = [navigationDic safeObjectForKey:@"answerStrategy"];
    }
    labelAnswerStrategy.text = [NSString stringWithFormat:@"接听策略: %@",[self getAnswerStrategy:answerStrategy]];;
    [headview addSubview:labelAnswerStrategy];
    
    
    headview.frame = CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, yPoint+25);
    
    
    
    return headview;
}



///(0-顺序接听,1-随机接听,2-平均接听)
-(NSString *)getAnswerStrategy:(NSString *)flag{
    NSString *answerStrategy = @"";
    
    NSInteger intFlag = [flag integerValue];
    switch (intFlag) {
        case 0:
            answerStrategy = @"顺序接听";
            break;
        case 1:
            answerStrategy = @"随机接听";
            break;
        case 2:
            answerStrategy = @"平均接听";
            break;
            
        default:
            break;
    }
    
    return answerStrategy;
}

#pragma mark - tableview delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headview =[[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 40)];
    headview.backgroundColor = COLOR_BG;
    
    
    //    UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 20)];
    //    top.backgroundColor = COLOR_BG;
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, DEVICE_BOUNDS_WIDTH-20, 20)];
    labelTitle.textColor = [UIColor blackColor];
    labelTitle.font = [UIFont systemFontOfSize:15.0];
    labelTitle.text = @"坐席列表";
    
    //    [headview addSubview:top];
    [headview addSubview:labelTitle];
    return headview;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.dataSource) {
        return [self.dataSource count];
    }
    return 0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NavigationSeatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NavigationSeatCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"NavigationSeatCell" owner:self options:nil];
        cell = (NavigationSeatCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    
    NSDictionary *item = [self.dataSource objectAtIndex:indexPath.row];
    [cell setCellDetails:item];
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *item = [self.dataSource objectAtIndex:indexPath.row];
    
}


///详情页面
-(void)gotoDetailsView:(NSInteger)section{
}

///跳转到新增或编辑页面 action : add edit
-(void)gotoAddOrEditDetailsView:(NSString*)action andIndex:(NSInteger)section{
    
}



#pragma mark - 上拉下拉刷新相关事件
//集成刷新控件
- (void)setupRefresh
{
    NSString *dateKey = @"llcnoivrnavgationsetingview";
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [self.tableview addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:dateKey];
    //上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableview addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 自动刷新(一进入程序就下拉刷新)
    //    [self.tableviewCampaign headerBeginRefreshing];
}


// 结束加载
-(void)reloadRefeshView{
    // 刷新列表
    [self.tableview reloadData];
    [self.tableview footerEndRefreshing];
    [self.tableview headerEndRefreshing];
}

// 下拉
- (void)headerRereshing
{
    NSLog(@"headerRereshing--下拉-->");
    
    if ([self.tableview isFooterRefreshing]) {
        [self.tableview headerEndRefreshing];
        return;
    }
    
    ///下拉
    listPage = 1;
    [self getNavigationDetails];
}

// 上拉
- (void)footerRereshing
{
    NSLog(@"footerRereshing--上拉-->");
    
    if ([self.tableview isHeaderRefreshing]) {
        [self.tableview footerEndRefreshing];
        return;
    }
    
    //上拉加载更多
    [self getSiteList];
}

#pragma mark - 没有数据时的view
-(void)notifyNoDataView{
    if (self.dataSource && [self.dataSource count] > 0) {
        [self clearViewNoData];
    }else{
        [self setViewNoData:@"暂无坐席"];
    }
}

-(void)setViewNoData:(NSString *)title{
    if (self.commonNoDataView == nil) {
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

#pragma mark 获取导航详情
-(void)getNavigationDetails{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    ///非根目录则传
    //    if (self.navigationId) {
    [rDict setValue:@"" forKey:@"navigationId"];
    //    }
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    
    NSLog(@"rParam:%@",rParam);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_NAVIGATION_DETAILS_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"导航详情jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            if ([jsonResponse objectForKey:@"resultMap"]) {
                
                [self initDetailsData:jsonResponse];
                [self getSiteList];
                
            }else{
                NSLog(@"data------>:<null>");
                [CommonFuntion showToast:@"加载异常" inView:self.view];
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getNavigationDetails];
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
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
    
}

///获取座席列表
-(void)getSiteList{
    [self clearViewNoData];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    ///非根目录则传
//    if (self.navigationId) {
        [rDict setValue:curNavigationId forKey:@"navigationId"];
//    }
    [rDict setValue:[NSString stringWithFormat:@"%i",listPage] forKey:@"pageSize"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    
    NSLog(@"rParam:%@",rParam);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_CUR_NAVIGATION_SITS_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        if(listPage == 1)
        {
            [self.dataSource removeAllObjects];
        }
        NSLog(@"坐席列表jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [self setViewRequestSusscess:jsonResponse];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getSiteList];
            };
            [comRequest loginInBackground];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        [self reloadRefeshView];
        [self notifyNoDataView];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        [self reloadRefeshView];
        [self notifyNoDataView];
    }];
    
}


// 请求成功时数据处理
-(void)setViewRequestSusscess:(NSDictionary *)jsonResponse
{
    id data = [[jsonResponse objectForKey:@"resultMap"]  objectForKey:@"sitList"];
    
    if ([data respondsToSelector:@selector(count)] && [data count] > 0) {
        
        ///添加当前页数据到列表中...
        [self.dataSource addObjectsFromArray:data];
        
        ///页码++
        if ([data count] == pageSize) {
            listPage++;
            [self.tableview setFooterHidden:NO];
        }else
        {
            ///隐藏上拉刷新
            [self.tableview setFooterHidden:YES];
        }
        
    }else{
        ///隐藏上拉刷新
        [self.tableview setFooterHidden:YES];
    }
}

// 请求失败时数据处理
-(void)setViewRequestFaild:(NSString *)desc
{
    
}




@end
