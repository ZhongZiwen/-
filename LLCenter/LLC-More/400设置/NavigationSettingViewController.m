//
//  NavigationSettingViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-20.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//
#define pageSize 10
#import "NavigationSettingViewController.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"
#import "CommonStaticVar.h"
#import "CommonNoDataView.h"
#import "CustomPopView.h"
#import "NavigationSettingCell.h"
#import "NavigationSeatCell.h"
#import "AddNavigationViewController.h"
#import "EditNavigationViewController.h"
#import "EditNavigationSeatViewController.h"
#import "MJRefresh.h"
#import "AFSoundPlaybackHelper.h"

@interface NavigationSettingViewController ()<UITableViewDataSource,UITableViewDelegate>{
    ///当前导航ID
    NSString *curNavigationId;
    NSString *curNavigationName;
    ///导航信息
    NSDictionary *navigationDic;
    ///是否有下级导航(0-没有，1-有)
//    NSString *isHaveChildNav;
    
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

@implementation NavigationSettingViewController


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

#pragma mark - 读取测试数据
-(void)readTestData{
    
    id jsondata = [CommonFunc readJsonFile:@"navigation_child_data"];
    
    
    [self initDetailsData:jsondata];
}


-(void)initDetailsData:(id)jsondata{
    navigationDic = [jsondata objectForKey:@"resultMap"];
    
    NSLog(@"self.navigationId:%@",self.navigationId);

    if (navigationDic) {
         ///是根导航
        if([[navigationDic safeObjectForKey:@"navigationLevel"] integerValue] == 0){
            self.isRootNavigation = @"yes";
        }else{
            self.isRootNavigation = @"no";
        }
        
        ///设置了下级导航  显示下级导航
        if([[navigationDic safeObjectForKey:@"navigationsetChild"] integerValue] == 1){
            NSLog(@"设置了下级导航  显示下级导航");
            self.curNavigationViewType = NavigationViewTypeNextChild;
        }else{
            ///未设置下级导航  显示坐席列表
            self.curNavigationViewType = NavigationViewTypeSitList;
        }
    }
    
    
    if (navigationDic) {
        self.tableview.tableHeaderView = nil;
        self.tableview.tableHeaderView = [self creatHeadViewForTableView];
        [self addNavBar];
    }
    
    ///当前导航的下级导航是否有开再下一级导航的权限0-是，1-否
    NSInteger  maxLevel = 0;
    NSInteger  navigationLevel = 0;
    if ([navigationDic objectForKey:@"maxLevel"]) {
       maxLevel = [[navigationDic objectForKey:@"maxLevel"] integerValue];
    }
    if ([navigationDic objectForKey:@"navigationLevel"]) {
        navigationLevel = [[navigationDic objectForKey:@"navigationLevel"] integerValue];
    }
    
    if ((navigationLevel+1) < maxLevel) {
        self.childNavigationHasChild = @"yes";
    }else{
        self.childNavigationHasChild = @"no";
    }
    
    ///当前导航是否有开再下一级导航的权限0-是，1-否
    if ([[navigationDic safeObjectForKey:@"navigationHasChild"] integerValue] == 0) {
        self.curChildNavigationHasChild = @"yes";
    }else{
        self.curChildNavigationHasChild = @"no";
    }
    
    ///进入下级导航的方式
    if ([[navigationDic safeObjectForKey:@"navigationType"] isEqualToString:@"0"]) {
        self.nextEnterNavigationWay = EnterNavWayByKeyNum;
    }else{
        self.nextEnterNavigationWay = EnterNavWayShunt;
    }
    ///当前导航的ID
    curNavigationId = [navigationDic safeObjectForKey:@"navigationId"];
    curNavigationName = [navigationDic safeObjectForKey:@"navigationName"];
    ///当前导航的进入方式
    if ([self.navigationId isEqualToString:@""]) {
        self.curEnterNavigationWay = EnterNavWayByKeyNum;
        self.curNavigationKeyLength = 1;
    }

    
    ///下级按键长度
    self.childNavigationKeyLength = [[navigationDic safeObjectForKey:@"childNavigationKeyLength"] integerValue];
    
    ///导航
//    [self.dataSource addObjectsFromArray:[navigationDic objectForKey:@"childNavigationList"]];
//    NSLog(@"self.dataSource:%@",self.dataSource);
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
    
}

///
-(void)rightBarButtonAction{
    [self showPopView];
}


-(void)showPopView{
    NSArray *titles;
    NSArray *imgs;
    if (self.curNavigationViewType == NavigationViewTypeNextChild) {
        ///可以开启下级导航
        if ([self.curChildNavigationHasChild isEqualToString:@"yes"]) {
            NSLog(@"----可以开启下级导航--->");
            if ([self.isRootNavigation isEqualToString:@"yes"]) {
                NSLog(@"----self.isRootNavigation  yes--->");
                titles = [NSArray arrayWithObjects:@"新增导航",@"编辑导航", nil];
                imgs = [NSArray arrayWithObjects:@"icon_add_nav.png",@"icon_edit_nav.png", nil];
            }else{
                NSLog(@"----self.isRootNavigation  no--->");
                titles = [NSArray arrayWithObjects:@"新增导航",@"编辑导航",@"删除导航", nil];
                imgs = [NSArray arrayWithObjects:@"icon_add_nav.png",@"icon_edit_nav.png",@"icon_delete_img.png", nil];
            }
            
        }else{
            ///不能开启下级导航
            
            ///根导航时只能编辑
            if ([self.isRootNavigation isEqualToString:@"yes"]) {
                titles = [NSArray arrayWithObjects:@"编辑导航", nil];
                imgs = [NSArray arrayWithObjects:@"icon_edit_nav.png", nil];
            }else{
                titles = [NSArray arrayWithObjects:@"编辑导航",@"删除导航", nil];
                imgs = [NSArray arrayWithObjects:@"icon_edit_nav.png",@"icon_delete_img.png", nil];
            }
        }
    }else if (self.curNavigationViewType == NavigationViewTypeSitList) {
        ///根导航
        if ([self.isRootNavigation isEqualToString:@"yes"]) {
            titles = [NSArray arrayWithObjects:@"编辑导航", nil];
            imgs = [NSArray arrayWithObjects:@"icon_edit_nav.png", nil];
        }else{
            titles = [NSArray arrayWithObjects:@"编辑导航",@"删除导航", nil];
            imgs = [NSArray arrayWithObjects:@"icon_edit_nav.png",@"icon_delete_img.png", nil];
        }
    }
    
    NSLog(@"titles:%@",titles);
    NSLog(@"imgs:%@",imgs);
    
    CustomPopView *popView = [[CustomPopView alloc] initWithPoint:CGPointMake(0, 64+64) titles:titles imageNames:imgs];
    
    __weak typeof(self) weak_self = self;
    popView.selectBlock = ^(NSInteger index) {
        if (self.curNavigationViewType == NavigationViewTypeNextChild) {
            ///可以开启下级导航
            if ([self.curChildNavigationHasChild isEqualToString:@"yes"]) {
                if ([self.isRootNavigation isEqualToString:@"yes"]) {
                    if (index == 0) {
                        ///新增导航
                        [weak_self gotoAddView];
                    }else if (index == 1){
                        ///编辑进入下级的导航
                        [weak_self gotoEditNavigationViewNoSit];
                    }
                }else{
                    
                    if (index == 0) {
                        ///新增导航
                        [weak_self gotoAddView];
                    }else if (index == 1){
                        ///编辑进入下级的导航
                        [weak_self gotoEditNavigationViewNoSit];
                    }else if (index == 2){
                        ///删除
                        ///删除导航
                        if (self.dataSource && [self.dataSource count] > 0) {
                            [CommonFuntion showToast:@"该导航存在下级导航,请先删除下级导航" inView:self.view];
                        }else{
                            [weak_self showDeleteAlert];
                        }
                        
                    }
                }
                
            }else{
                ///根导航时只能编辑
                if ([self.isRootNavigation isEqualToString:@"yes"]) {
                    ///编辑进入下级的导航
                    [weak_self gotoEditNavigationViewNoSit];
                }else{
                    if (index == 0){
                        ///编辑进入下级的导航
                        [weak_self gotoEditNavigationViewNoSit];
                    }else if (index == 1){
                        ///删除
                        ///删除导航
                        if (self.dataSource && [self.dataSource count] > 0) {
                            [CommonFuntion showToast:@"该导航存在下级导航,请先删除下级导航" inView:self.view];
                        }else{
                            [weak_self showDeleteAlert];
                        }
                    }
                }
            }
        }else if (self.curNavigationViewType == NavigationViewTypeSitList) {
            ///根导航
            if ([self.isRootNavigation isEqualToString:@"yes"]) {
                if (index == 0) {
                    ///编辑底层导航和座席
                    [weak_self gotoEditNavigationViewSit];
                }
            }else{
                if (index == 0) {
                    ///编辑底层导航和座席
                    [weak_self gotoEditNavigationViewSit];
                }else if(index == 1){
                    ///删除导航
                    if (self.dataSource && [self.dataSource count] > 0) {
                        [CommonFuntion showToast:@"该导航存在坐席,请先在坐席管理中删除坐席" inView:self.view];
                    }else{
                        [weak_self showDeleteAlert];
                    }
                    
                }
            }
        }

    };
    [popView show];
}

///新增导航
-(void)gotoAddView{
    AddNavigationViewController *anc = [[AddNavigationViewController alloc] init];
    ///进入方式
    anc.enterNavigationWay = self.nextEnterNavigationWay;
    ///是否有开启下级的权限
    anc.childNavigationHasChild = self.childNavigationHasChild;
    anc.navigationId = curNavigationId;
    anc.navigationName = curNavigationName;
    anc.childNavigationKeyLength = self.childNavigationKeyLength;
    __weak typeof(self) weak_self = self;
    anc.NotifyNavigationList = ^{
//        listPage = 1;
//        [weak_self getNavigationList];
    };
    NSDictionary *dic;
    
    [self.navigationController pushViewController:anc animated:YES];
}

///编辑导航-无座席
-(void)gotoEditNavigationViewNoSit{
    EditNavigationViewController *anc = [[EditNavigationViewController alloc] init];
    NSLog(@"self.curEnterNavigationWay:%ti",self.curEnterNavigationWay);
    ///导航的方式
    anc.enterNavigationWay = self.curEnterNavigationWay;
    ///是否有开启下级导航的权限
    anc.childNavigationHasChild = self.curChildNavigationHasChild ;
    ///是否设置了下级导航
    anc.navigationsetChild = [NSString stringWithFormat:@"%ti",[[navigationDic safeObjectForKey:@"navigationsetChild"] integerValue]];
    anc.isRootNavigation = self.isRootNavigation;
    NSLog(@"self.isRootNavigation:%@",self.isRootNavigation);
    anc.detail = navigationDic;
    anc.sourChildNavigation = self.dataSource;
    anc.curNavigationKeyLength = self.curNavigationKeyLength;
    NSLog(@"self.curNavigationKeyLength:%ti",self.curNavigationKeyLength);
    __weak typeof(self) weak_self = self;
    anc.NotifyNavigationList = ^(BOOL isBack){
//        if (isBack) {
//            [weak_self.navigationController popViewControllerAnimated:YES];
//        }
    };
    [self.navigationController pushViewController:anc animated:YES];
}


///编辑导航-座席
-(void)gotoEditNavigationViewSit{
    EditNavigationSeatViewController *anc = [[EditNavigationSeatViewController alloc] init];
    anc.isRootNavigation = self.isRootNavigation;
    anc.enterNavigationWay = self.curEnterNavigationWay;
    anc.childNavigationHasChild = self.childNavigationHasChild;
    anc.detail = navigationDic;
    anc.sourNavigationSeatsOld = self.dataSource;
    anc.curNavigationKeyLength = self.curNavigationKeyLength;
    __weak typeof(self) weak_self = self;
    anc.NotifyNavigationList = ^(BOOL isBack){
//        if (isBack) {
//            [weak_self.navigationController popViewControllerAnimated:YES];
//        }
    };
    
    [self.navigationController pushViewController:anc animated:YES];
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
            [self DeleteNavigation];
        }
    }
}


#pragma mark - 初始化数据
-(void)initData{
#warning 测试数据
    curNavigationId = @"";
    if ([self.navigationId isEqualToString:@""]) {
        self.isRootNavigation = @"yes";
        ///如果是根目录 则不指定当前导航内容类型
        self.curNavigationViewType = NavigationViewTypeUnknown;
    }else{
        self.isRootNavigation = @"no";
    }
    indexPlaying = -1;
    listPage = 1;
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
    if ([urlString isEqualToString:@""]) {
        [CommonFuntion showToast:@"播放出错!" inView:self.view];
        return;
    }
    
    [self playSoundByUrl:urlString];
}


#pragma mark - 播放音频
-(void)playSoundByUrl:(NSString *)urlSound{
    NSString *urlString = [navigationDic safeObjectForKey:@"navigationRingUrl"];
    NSLog(@"playNavigationRing urlString:%@",urlString);
    
    [AFSoundPlaybackHelper  playAndCacheWithUrl:urlString];
    
    /*
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
     */
}



#pragma mark - 创建HeadView
-(UIView *)creatHeadViewForTableView{
    UIView *headview = [[UIView alloc] init];
    headview.backgroundColor = [UIColor whiteColor];
    
    UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 20)];
    top.backgroundColor = COLOR_BG;
    
    ///当前导航
    UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, DEVICE_BOUNDS_WIDTH-40, 20)];
    labelName.textColor = [UIColor grayColor];
    labelName.font = [UIFont systemFontOfSize:15.0];
    
    ///当前导航名称
    UILabel *labelNavName = [[UILabel alloc] initWithFrame:CGRectMake(15, 75, DEVICE_BOUNDS_WIDTH-100, 20)];
    labelNavName.textColor = [UIColor blackColor];
    labelNavName.font = [UIFont systemFontOfSize:18.0];
    
    ///当前导航铃声
    UILabel *labelRing = [[UILabel alloc] initWithFrame:CGRectMake(15, 105, DEVICE_BOUNDS_WIDTH-100, 20)];
    labelRing.textColor = [UIColor grayColor];
    labelRing.font = [UIFont systemFontOfSize:15.0];
    
    if (([navigationDic safeObjectForKey:@"navigationRingName"] && [navigationDic safeObjectForKey:@"navigationRingName"].length > 0) && ([navigationDic safeObjectForKey:@"navigationRingUrl"] && [navigationDic safeObjectForKey:@"navigationRingUrl"].length > 0)) {
        UIButton *btnPlay = [UIButton buttonWithType:UIButtonTypeCustom];
        btnPlay.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-50, 80, 40, 40);
        [btnPlay setBackgroundImage:[UIImage imageNamed:@"icon_listen.png"] forState:UIControlStateNormal];
        [btnPlay addTarget:self action:@selector(playNavigationRing) forControlEvents:UIControlEventTouchUpInside];
        [headview addSubview:btnPlay];
    }
    
    [headview addSubview:top];
    [headview addSubview:labelName];
    [headview addSubview:labelNavName];
    [headview addSubview:labelRing];
    
    
    NSString *name = @"";
    if ([self.navigationId isEqualToString:@""]) {
        name = @"根导航";
    }else{
        NSString *navigationLevel = [CommonFunc translationArabicNum:[[navigationDic safeObjectForKey:@"navigationLevel"] integerValue]];
        name = [NSString stringWithFormat:@"第%@层导航",navigationLevel];
    }
    
    NSString *navName = @"";
    NSString *ringName = @"";
    if (navigationDic) {
        navName = [navigationDic safeObjectForKey:@"navigationName"];
        ringName = [navigationDic safeObjectForKey:@"navigationRingName"];
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
    
    NSInteger yPoint = 135;
    ///非根目录
    if (![self.navigationId isEqualToString:@""]) {
        if (self.curEnterNavigationWay == EnterNavWayByKeyNum) {
            ///导航按键
            UILabel *labelKeyNum = [[UILabel alloc] initWithFrame:CGRectMake(15, yPoint, DEVICE_BOUNDS_WIDTH-100, 20)];
            labelKeyNum.textColor = [UIColor grayColor];
            labelKeyNum.font = [UIFont systemFontOfSize:15.0];
            
            NSString *keyNum = @"";
            
            if (navigationDic) {
                keyNum = [navigationDic safeObjectForKey:@"navigationKey"];
            }
            labelKeyNum.text = [NSString stringWithFormat:@"导航按键: %@",keyNum];;
            [headview addSubview:labelKeyNum];
            yPoint += 30;
            headview.frame = CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, yPoint);
        }else{
            ///分流进入
            ///时间类型
            UILabel *labelTimeType = [[UILabel alloc] initWithFrame:CGRectMake(15, yPoint, DEVICE_BOUNDS_WIDTH-100, 20)];
            labelTimeType.textColor = [UIColor grayColor];
            labelTimeType.font = [UIFont systemFontOfSize:15.0];
            
            NSString *timeType = @"";
            
            if (navigationDic) {
                timeType = [navigationDic safeObjectForKey:@"timeType"];
            }
            labelTimeType.text = [NSString stringWithFormat:@"时间类型: %@",[CommonFunc getNavTimeType:timeType]];;
            [headview addSubview:labelTimeType];
            
            yPoint += 30;
            
            ///地区类型
            UILabel *labelAreaType = [[UILabel alloc] initWithFrame:CGRectMake(15, yPoint, DEVICE_BOUNDS_WIDTH-100, 20)];
            labelAreaType.textColor = [UIColor grayColor];
            labelAreaType.font = [UIFont systemFontOfSize:15.0];
            
            NSString *areaName = @"";
            ///全部地区
            if ([[navigationDic safeObjectForKey:@"areaCode"] isEqualToString:@"1"]) {
                areaName = @"全部地区";
            }else{
                areaName = [navigationDic safeObjectForKey:@"areaName"];
            }
            
            labelAreaType.text = [NSString stringWithFormat:@"地区类型: %@",areaName];;
            [headview addSubview:labelAreaType];
            
            yPoint += 30;
            ///导航方式
            UILabel *labelNaviType = [[UILabel alloc] initWithFrame:CGRectMake(15, yPoint, DEVICE_BOUNDS_WIDTH-100, 20)];
            labelNaviType.textColor = [UIColor grayColor];
            labelNaviType.font = [UIFont systemFontOfSize:15.0];
            
            labelNaviType.text = [NSString stringWithFormat:@"导航方式: %@",@"分流进入"];;
            [headview addSubview:labelNaviType];
            headview.frame = CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 230);
            yPoint += 30;
        }

    }
    
    ///是不是最后一层 是的话添加接听策略
    if (self.curNavigationViewType == NavigationViewTypeSitList) {
        ///接听策略
        UILabel *labelAnswerStrategy= [[UILabel alloc] initWithFrame:CGRectMake(15, yPoint, DEVICE_BOUNDS_WIDTH-100, 20)];
        labelAnswerStrategy.textColor = [UIColor grayColor];
        labelAnswerStrategy.font = [UIFont systemFontOfSize:15.0];
        
        NSString *answerStrategy = @"";
        
        if (navigationDic) {
            answerStrategy = [navigationDic safeObjectForKey:@"answerStrategy"];
        }
        NSLog(@"answerStrategy:%@",answerStrategy);
        labelAnswerStrategy.text = [NSString stringWithFormat:@"接听策略: %@",[self getAnswerStrategy:answerStrategy]];;
        [headview addSubview:labelAnswerStrategy];
        
       
        yPoint += 30;
    }
     headview.frame = CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, yPoint+10);
    
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
    
    NSString *sectionTitle = @"";
    if (self.curNavigationViewType == NavigationViewTypeNextChild) {
        sectionTitle = @"下级导航";
    }else if (self.curNavigationViewType == NavigationViewTypeSitList) {
        sectionTitle = @"坐席列表";
    }
    labelTitle.text = sectionTitle;
    
    [headview addSubview:labelTitle];
    return headview;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.curNavigationViewType == NavigationViewTypeNextChild || self.curNavigationViewType == NavigationViewTypeSitList) {
        if (self.dataSource) {
            return [self.dataSource count];
        }
    }
    return 0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.curNavigationViewType == NavigationViewTypeNextChild) {
        NavigationSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NavigationSettingCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"NavigationSettingCell" owner:self options:nil];
            cell = (NavigationSettingCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        
        NSDictionary *item = [self.dataSource objectAtIndex:indexPath.row];
        [cell setCellDetails:item andIndexPath:indexPath];
        
//        __weak typeof(cell) weak_cell = cell;
        __weak typeof(self) weak_self = self;
        
        cell.PlayRingBlock = ^(NSInteger index){
            indexPlaying = index;
            [weak_self.tableview reloadData];
            NSString *url = [item objectForKey:@"childNavigationRingUrl"];
            [weak_self playSoundByUrl:url];
        };
        
        NSLog(@"indexPlaying:%ti",indexPlaying);
        
        return cell;
    }else if (self.curNavigationViewType == NavigationViewTypeSitList){
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
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.curNavigationViewType == NavigationViewTypeNextChild) {
        
        NSDictionary *item = [self.dataSource objectAtIndex:indexPath.row];
        
        NavigationSettingViewController *nsv = [[NavigationSettingViewController alloc] init];
        nsv.navigationId = [item safeObjectForKey:@"childNavigationId"];
        nsv.curEnterNavigationWay = self.nextEnterNavigationWay;
        //        nsv.curChildNavigationHasChild = self.childNavigationHasChild;
        nsv.curNavigationKeyLength = [[navigationDic safeObjectForKey:@"childNavigationKeyLength"] integerValue];
        ///没有下级导航了
        if ([[item objectForKey:@"childNavigationHasChild"] integerValue] == 0) {
            nsv.curNavigationViewType = NavigationViewTypeSitList;
        }else{
            nsv.curNavigationViewType = NavigationViewTypeNextChild;
        }
        __weak typeof(self) weak_self = self;
        ///删除导航/编辑  ---刷新导航列表
        nsv.NotifyNavigationListBlock = ^(){
            
        };
        [self.navigationController pushViewController:nsv animated:YES];
        
    }else if (self.curNavigationViewType == NavigationViewTypeSitList) {
        
    }
    
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
    NSString *dateKey = @"llcnavgationsettingview";
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
    [self getNavigationListOrSitList];
}


#pragma mark - 没有数据时的view
-(void)notifyNoDataView{
    if (self.dataSource && [self.dataSource count] > 0) {
        [self clearViewNoData];
    }else{
        if (self.curNavigationViewType == NavigationViewTypeNextChild) {
            [self setViewNoData:@"暂无下级导航"];
        }else if (self.curNavigationViewType == NavigationViewTypeNextChild) {
            [self setViewNoData:@"暂无坐席列表"];
        }
    }
}

-(void)setViewNoData:(NSString *)title{
    if (self.commonNoDataView == nil) {
        self.commonNoDataView = [CommonFunc commonNoDataViewIconNearBottom:@"list_empty.png" Title:title optionBtnTitle:@""];
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

    [rDict setValue:self.navigationId forKey:@"navigationId"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    
    NSLog(@"rParam:%@",rParam);
    
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_NAVIGATION_DETAILS_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"导航详情jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            if ([jsonResponse objectForKey:@"resultMap"]) {
                
                [self initDetailsData:jsonResponse];
                [self getNavigationListOrSitList];
                
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


#pragma mark - 获取当前导航的下级导航列表/坐席列表
-(void)getNavigationListOrSitList{
    
    [self clearViewNoData];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
     NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    ///非根目录则传

    [rDict setValue:curNavigationId forKey:@"navigationId"];

    [rDict setValue:[NSString stringWithFormat:@"%i",listPage] forKey:@"pageSize"];
    
     NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
     encoding:NSUTF8StringEncoding];
     NSLog(@"jsonString:%@",jsonString);
     
     ///dic转换为json
     NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
     
     [rParam setObject:jsonString forKey:@"data"];
     
     NSLog(@"rParam:%@",rParam);
    
    NSString *url = @"";
    if (self.curNavigationViewType == NavigationViewTypeNextChild) {
        url = LLC_GET_CUR_NAVIGATION_CHILDNAVIGATION_ACTION;
    }else if (self.curNavigationViewType == NavigationViewTypeSitList) {
        url = LLC_GET_CUR_NAVIGATION_SITS_ACTION;
    }
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,url] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        if(listPage == 1)
        {
            [self.dataSource removeAllObjects];
        }
        
        NSLog(@"导航/坐席jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [self setViewRequestSusscess:jsonResponse];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getNavigationListOrSitList];
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
    id data;
    if (self.curNavigationViewType == NavigationViewTypeNextChild) {
        data = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"childNavigationList"];
    }else if (self.curNavigationViewType == NavigationViewTypeSitList) {
        data = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"sitList"];
    }
    
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




#pragma mark  删除导航
-(void)DeleteNavigation{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    ///非根目录则传
    //    if (self.navigationId) {
    [rDict setValue:curNavigationId forKey:@"navigationId"];
    //    }
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    
    NSLog(@"rParam:%@",rParam);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_DELETE_NAVIGATION_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"删除导航jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            if ([jsonResponse objectForKey:@"resultMap"]) {
                [CommonFuntion showToast:@"删除导航成功" inView:self.view];
                [self actionSuccess];
                
            }else{
                NSLog(@"data------>:<null>");
                [CommonFuntion showToast:@"请求异常" inView:self.view];
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self DeleteNavigation];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"删除失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];

}


#pragma mark - 返回到前一页
-(void)actionSuccess{
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(gobackView)
                                   userInfo:nil repeats:NO];
}

-(void)gobackView{
    if (self.NotifyNavigationListBlock) {
        self.NotifyNavigationListBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
