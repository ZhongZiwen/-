//
//  WorkGroupRecordViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#define actionDelete  @"delete"
#define actionModify  @"modify"
///每页条数
#define PageSize 10


#import "WorkGroupRecordViewController.h"
#import "UIViewController+NavDropMenu.h"
#import "AppDelegate.h"
#import "CommonFuntion.h"
#import "CommonConstant.h"
#import "CommonStaticVar.h"
#import "CommonModuleFuntion.h"
#import "WorkGroupRecordCellA.h"
#import "WorkGroupRecordCellB.h"
#import "WorkGroupRecordDetailsViewController.h"
#import "AFNHttp.h"
#import "MJRefresh.h"
#import <MBProgressHUD.h>
#import "PhotoBroswerVC.h"
#import "MapViewViewController.h"
#import "ReleaseViewController.h"
#import "KnowledgeFileDetailsViewController.h"
#import "InfoViewController.h"
#import "SDImageCache.h"
#import "NavDropView.h"
#import "CommonNoDataView.h"
#import "Dynamic_Data.h"
#import "CommonRequstFuntion.h"
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
#import "NSUserDefaults_Cache.h"

@interface WorkGroupRecordViewController ()<UITableViewDataSource,UITableViewDelegate,WorkGroupDelegate,UIActionSheetDelegate,UITabBarControllerDelegate, TTTAttributedLabelDelegate>{
    NSInteger pageNo;//页数下标
    BOOL isMoreData;///是否有更多数据
    
    ///标记删除操作
    NSInteger indexDelete;
    long long trendIdDelete;
    ///初次加载
    MBProgressHUD *hudRefresh;
}

@property (nonatomic, assign) NSInteger curIndex;
@property (nonatomic, strong)NavDropView *dropView;
@property (nonatomic, strong)NSArray *arrayDropMen;

@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property (nonatomic, strong) WorkGroupRecordCellB *cell;
@end

@implementation WorkGroupRecordViewController

- (void)loadView
{
    [super loadView];
    
    NSLog(@"self.typeOfView:%@",self.typeOfView);
    NSLog(@"getFlagOfWorkGroupViewFrom:%@",[CommonStaticVar getFlagOfWorkGroupViewFrom]);
    
    if ([[CommonStaticVar getFlagOfWorkGroupViewFrom] isEqualToString:@"homeworkzone"]) {
        self.typeOfView = @"homeworkzone";
    }
    
    if ([self.typeOfView isEqualToString:@"workzone"]) {
        ///工作圈
        [self addTitleMenu];
        [self addRelessBtn];
    }else if([self.typeOfView isEqualToString:@"departmentfeed"] || [self.typeOfView isEqualToString:@"groupfeed"]){
        ///部门动态  ///群组动态
        [self addRelessBtn];
    }
    
    [self initTableviewAndDate];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = TABLEVIEW_BG_COLOR;

    /*
    if ([[CommonStaticVar getFlagOfWorkGroupViewFrom] isEqualToString:@"workzone"]) {
        ///工作圈
    }else if ([[CommonStaticVar getFlagOfWorkGroupViewFrom] isEqualToString:@"feed"]) {
        ///我的动态
        
    }else if ([[CommonStaticVar getFlagOfWorkGroupViewFrom] isEqualToString:@"favorite"]) {
        ///我的收藏
        
    }else if([[CommonStaticVar getFlagOfWorkGroupViewFrom] isEqualToString:@"homeworkzone"]){
        ///首页工作圈
    }else if([[CommonStaticVar getFlagOfWorkGroupViewFrom] isEqualToString:@"departmentfeed"]){
        ///部门动态
        
    }else if([[CommonStaticVar getFlagOfWorkGroupViewFrom] isEqualToString:@"groupfeed"]){
        ///群组动态
        
    }
     */
    
    NSLog(@"viewDidLoad 工作圈:%@",self.typeOfView);
    [self initData];
    [self getExistCache];
//    [self getCacheData];
    
    hudRefresh = [[MBProgressHUD alloc] initWithView:appDelegateAccessor.window];
    [appDelegateAccessor.window addSubview:hudRefresh];
    [hudRefresh show:YES];
    [self getDataFromService];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [CommonStaticVar setContentFont:15.0 color:COLOR_WORKGROUP_CONTENT];
    if ([[CommonStaticVar getFlagOfWorkGroupViewFrom] isEqualToString:@"homeworkzone"]) {
        self.typeOfView = @"homeworkzone";
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [AFSoundPlaybackHelper stop_helper];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopVoice" object:nil];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


#pragma mark -发布动态
-(void)addRelessBtn{
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_item_activityRecord"] style:UIBarButtonItemStylePlain target:self action:@selector(editItemPress)];
    self.navigationItem.rightBarButtonItem = editItem;
}

// 发布动态
- (void)editItemPress {
     __weak typeof(self) weak_self = self;
    ReleaseViewController *releaseController = [[ReleaseViewController alloc] init];
    releaseController.title = @"发布动态";
    if (self.parentId && self.departmentOrGroup && self.departmentOrGroup.length > 0) {
        releaseController.typeOfRelease = @"department";
        releaseController.titleStr = self.departmentOrGroup;
        releaseController.parentId = self.parentId;
    }else{
        releaseController.typeOfRelease = @"zone";
    }
    
    releaseController.typeOfOptionDynamic = TypeOfOptionDynamicRelease;
    releaseController.ReleaseSuccessNotifyData = ^(){
        ///重新请求数据
//        [weak_self.tableviewWorkGroup setContentOffset:CGPointMake(0,0) animated:NO];

        pageNo = 1;
//        [weak_self.arrayWorkGroup removeAllObjects];
        [weak_self getDataFromService];
    };
    [self.navigationController pushViewController:releaseController animated:YES];
}

#pragma mark - Title 菜单
-(void)addTitleMenu{
    _curIndex = 0;
    
    [self customDownMenuWithType:TableViewCellTypeDefault andSource:@[@"我关注的动态", @"公开动态"] andDefaultIndex:_curIndex andBlock:^(NSInteger index) {
        if(hudRefresh == nil){
            hudRefresh = [[MBProgressHUD alloc] initWithView:appDelegateAccessor.window];
        }
        [appDelegateAccessor.window addSubview:hudRefresh];
        [hudRefresh show:YES];
        ///记录上一次状态
        _curIndex = index;
        NSLog(@"_curIndex:%ti",_curIndex);
        pageNo = 1;
//        [self.arrayWorkGroup removeAllObjects];
        
        [self getDataFromService];
    }];
}

#pragma mark - 读取测试数据
-(void)readTestData{
    
#warning 测试数据  要区分是动态还是消息页面提到信息 来取不同的数据
    ///首页工作圈 homeworkzone 工作圈 workzone  我的动态feed   我的收藏favorite
    /*
    id jsondata;
    NSArray *array;
    
    if ([[CommonStaticVar getFlagOfWorkGroupViewFrom] isEqualToString:@"workzone"]) {
        jsondata = [CommonFuntion readJsonFile:@"workgroup-data"];
        #warning 测试数据
        [CommonStaticVar setTypeOfWorkGroupCellInfo:@"feed"];
        array = [[jsondata objectForKey:@"body"] objectForKey:@"feeds"];
    }else if ([[CommonStaticVar getFlagOfWorkGroupViewFrom] isEqualToString:@"feed"]) {
        
        jsondata = [CommonFuntion readJsonFile:@"feed-data"];
        [CommonStaticVar setTypeOfWorkGroupCellInfo:@"feed"];
        array = [[jsondata objectForKey:@"body"] objectForKey:@"feeds"];
        
    }else if ([[CommonStaticVar getFlagOfWorkGroupViewFrom] isEqualToString:@"favorite"]) {
        jsondata = [CommonFuntion readJsonFile:@"favorite-data"];
        [CommonStaticVar setTypeOfWorkGroupCellInfo:@"feed"];
        array = [[jsondata objectForKey:@"body"] objectForKey:@"feeds"];
    }else if([[CommonStaticVar getFlagOfWorkGroupViewFrom] isEqualToString:@"homeworkzone"]){
        jsondata = [CommonFuntion readJsonFile:@"feed-data"];
        [CommonStaticVar setTypeOfWorkGroupCellInfo:@"feed"];
        array = [[jsondata objectForKey:@"body"] objectForKey:@"feeds"];
    }else if([[CommonStaticVar getFlagOfWorkGroupViewFrom] isEqualToString:@"notificationatme"]){
        ///提到我的
        [CommonStaticVar setTypeOfWorkGroupCellInfo:@"comment"];
        array = [[jsondata objectForKey:@"body"] objectForKey:@"atList"];
    }
    
    NSLog(@"jsondata:%@",jsondata);
    
    [self.arrayWorkGroup addObjectsFromArray:array];
    NSLog(@"arrayDetails count:%li",[self.arrayWorkGroup count]);
     */
}



#pragma mark - 初始化tablview
-(void)initTableviewAndDate{
    
    
    if([self.typeOfView isEqualToString:@"homeworkzone"]){
        self.tableviewWorkGroup = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height-108) style:UITableViewStyleGrouped];
       
    }else if([self.typeOfView isEqualToString:@"departmentfeed"]
        || [self.typeOfView isEqualToString:@"groupfeed"]){
        self.tableviewWorkGroup = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height-108) style:UITableViewStyleGrouped];
        
    }
    else{
        self.tableviewWorkGroup = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    }
    
    
    self.tableviewWorkGroup.delegate = self;
    self.tableviewWorkGroup.dataSource = self;
    
    [self.view addSubview:self.tableviewWorkGroup];
    self.tableviewWorkGroup.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
    self.tableviewWorkGroup.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewWorkGroup setTableFooterView:v];
    
    ///添加上拉和下拉
    [self setupRefresh];
}

-(void)notifyTableviewFrame{
    if([self.typeOfView isEqualToString:@"homeworkzone"]
       || [self.typeOfView isEqualToString:@"departmentfeed"]
       || [self.typeOfView isEqualToString:@"groupfeed"]){
        self.tableviewWorkGroup.frame = CGRectMake(0, 64, kScreen_Width, kScreen_Height-108);
    }else{
        self.tableviewWorkGroup.frame = self.view.bounds;
    }
    
    //上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableviewWorkGroup addFooterWithTarget:self action:@selector(footerRereshing)];
}


#pragma mark - 初始化数据
-(void)initData{
    pageNo = 1;
    isMoreData = YES;
    self.arrayWorkGroup = [[NSMutableArray alloc] init];
}


#pragma mark - 初次进入页面 先读取缓存 如果有缓存则直接显示 否则请求数据
-(void)getCacheData{
//    [self getDataFromService];
//    return;
    
    [self getExistCache];
    [self getDataFromService];
    
    
    return;

    __weak typeof(self) weak_self = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [weak_self getExistCache];
        [weak_self getDataFromService];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weak_self.tableviewWorkGroup reloadData];
        });
    });
}

///是否存在缓存数据  存在则读取
-(void)getExistCache{
   
    if ([self.typeOfView isEqualToString:@"workzone"]) {
        ///工作圈
        if (_curIndex == 0) {
            /*
            ///我关注的动态
            if (appDelegateAccessor.moudle.user_focus_dynamic == nil || [appDelegateAccessor.moudle.user_focus_dynamic count] == 0) {
                [Dynamic_Data getUserFocusDynamic];
            }
             */
            if (appDelegateAccessor.moudle.user_focus_dynamic) {
                [self.arrayWorkGroup addObjectsFromArray:appDelegateAccessor.moudle.user_focus_dynamic];
            }
        }else if (_curIndex == 1){
            /*
            ///公开动态
            if (appDelegateAccessor.moudle.user_public_dynamic == nil || [appDelegateAccessor.moudle.user_public_dynamic count] == 0) {
                [Dynamic_Data getUserPublicDynamic];
            }
            */
            if (appDelegateAccessor.moudle.user_public_dynamic) {
                [self.arrayWorkGroup addObjectsFromArray:appDelegateAccessor.moudle.user_public_dynamic];
            }
            
        }
    }else if ([self.typeOfView isEqualToString:@"feed"]) {
        /*
        ///我的动态
        if (appDelegateAccessor.moudle.user_my_dynamic == nil || [appDelegateAccessor.moudle.user_my_dynamic count] == 0) {
            [Dynamic_Data getUserMyDynamic];
        }
         */
        if (appDelegateAccessor.moudle.user_my_dynamic) {
            [self.arrayWorkGroup addObjectsFromArray:appDelegateAccessor.moudle.user_my_dynamic];
        }
        
    }else if ([self.typeOfView isEqualToString:@"favorite"]) {
        /*
        ///我的收藏
        if (appDelegateAccessor.moudle.user_favorite_dynamic == nil || [appDelegateAccessor.moudle.user_favorite_dynamic count] == 0) {
            [Dynamic_Data getUserFavoriteDynamic];
        }
         */
        if (appDelegateAccessor.moudle.user_favorite_dynamic) {
            [self.arrayWorkGroup addObjectsFromArray:appDelegateAccessor.moudle.user_favorite_dynamic];
        }
        
    }else if([self.typeOfView isEqualToString:@"homeworkzone"]){
        /*
        ///首页工作圈
        if (appDelegateAccessor.moudle.user_focus_dynamic == nil || [appDelegateAccessor.moudle.user_focus_dynamic count] == 0) {
            [Dynamic_Data getUserFocusDynamic];
        }
         */
        if (appDelegateAccessor.moudle.user_focus_dynamic) {
            [self.arrayWorkGroup addObjectsFromArray:appDelegateAccessor.moudle.user_focus_dynamic];
        }
    }
    
    if ([self.arrayWorkGroup count] > 0) {
         NSLog(@"getExistCache---有缓存数据-->");
    }
    [self.tableviewWorkGroup reloadData];
}

#pragma mark - 缓存第一页数据

-(void)saveDynamicData:(NSArray *)array{
    __weak typeof(self) weak_self = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [weak_self saveFirstPageDataToFile:array];
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    });
}

-(void)saveFirstPageDataToFile:(NSArray *)array{
    
    if ([self.typeOfView isEqualToString:@"workzone"]) {
        ///工作圈
        if (_curIndex == 0) {
            ///我关注的动态
            [Dynamic_Data updateUserFocusDynamicToFile:array];
        }else if (_curIndex == 1){
            ///公开动态
            [Dynamic_Data updateUserPublicDynamicToFile:array];
        }
    }else if ([self.typeOfView isEqualToString:@"feed"]) {
        ///我的动态
        [Dynamic_Data updateUserMyDynamicToFile:array];
    }else if ([self.typeOfView isEqualToString:@"favorite"]) {
        ///我的收藏
        [Dynamic_Data updateUserFavoriteDynamicToFile:array];
    }else if([self.typeOfView isEqualToString:@"homeworkzone"]){
        ///首页工作圈
        [Dynamic_Data updateUserFocusDynamicToFile:array];
    }
}


#pragma mark - 根据操作对缓存做数据更新
-(void)updateCacheData:(NSDictionary *)item andIndex:(NSInteger)section action:(NSString *)action{
    
    if ([self.typeOfView isEqualToString:@"workzone"]) {
        ///工作圈
        if (_curIndex == 0) {
            ///我关注的动态
            if (appDelegateAccessor.moudle.user_focus_dynamic && [appDelegateAccessor.moudle.user_focus_dynamic count]> section) {
                
                if ([action isEqualToString:actionDelete]) {
                    [appDelegateAccessor.moudle.user_focus_dynamic removeObjectAtIndex:section];
                }else if ([action isEqualToString:actionModify]){
                    [appDelegateAccessor.moudle.user_focus_dynamic setObject:item atIndexedSubscript:section];
                }
                
                [Dynamic_Data updateUserFocusDynamicToFile:appDelegateAccessor.moudle.user_focus_dynamic];
            }
            
        }else if (_curIndex == 1){
            ///公开动态
            if (appDelegateAccessor.moudle.user_public_dynamic && [appDelegateAccessor.moudle.user_public_dynamic count] > section) {
                if ([action isEqualToString:actionDelete]) {
                    [appDelegateAccessor.moudle.user_public_dynamic removeObjectAtIndex:section];
                }else if ([action isEqualToString:actionModify]){
                    [appDelegateAccessor.moudle.user_public_dynamic setObject:item atIndexedSubscript:section];
                }
                
                [Dynamic_Data updateUserPublicDynamicToFile:appDelegateAccessor.moudle.user_public_dynamic];
            }
        }
    }else if ([self.typeOfView isEqualToString:@"feed"]) {
        ///我的动态
        if (appDelegateAccessor.moudle.user_my_dynamic && [appDelegateAccessor.moudle.user_my_dynamic count]> section) {
            if ([action isEqualToString:actionDelete]) {
                [appDelegateAccessor.moudle.user_my_dynamic removeObjectAtIndex:section];
            }else if ([action isEqualToString:actionModify]){
                [appDelegateAccessor.moudle.user_my_dynamic setObject:item atIndexedSubscript:section];
            }
            [Dynamic_Data updateUserMyDynamicToFile:appDelegateAccessor.moudle.user_my_dynamic];
        }
        
    }else if ([self.typeOfView isEqualToString:@"favorite"]) {
        ///我的收藏
        if (appDelegateAccessor.moudle.user_favorite_dynamic && [appDelegateAccessor.moudle.user_favorite_dynamic count]> section) {
            if ([action isEqualToString:actionDelete]) {
                [appDelegateAccessor.moudle.user_favorite_dynamic removeObjectAtIndex:section];
            }else if ([action isEqualToString:actionModify]){
                [appDelegateAccessor.moudle.user_favorite_dynamic setObject:item atIndexedSubscript:section];
            }
            [Dynamic_Data updateUserFavoriteDynamicToFile:appDelegateAccessor.moudle.user_favorite_dynamic];
        }
        
    }else if([self.typeOfView isEqualToString:@"homeworkzone"]){
        ///首页工作圈
        if (appDelegateAccessor.moudle.user_focus_dynamic && [appDelegateAccessor.moudle.user_focus_dynamic count]> section) {
            if ([action isEqualToString:actionDelete]) {
                [appDelegateAccessor.moudle.user_focus_dynamic removeObjectAtIndex:section];
            }else if ([action isEqualToString:actionModify]){
                [appDelegateAccessor.moudle.user_focus_dynamic setObject:item atIndexedSubscript:section];
            }
            [Dynamic_Data updateUserFocusDynamicToFile:appDelegateAccessor.moudle.user_focus_dynamic];
        }
    }
}


#pragma mark - 获取数据
-(void)getDataFromService{

    [self clearViewNoData];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    NSString *url = @"";
    if ([self.typeOfView isEqualToString:@"workzone"]) {
        ///工作圈
        url = TRENDS_LIST;
        if (_curIndex == 0) {
            ///我关注的动态
            [params setObject:@"focus" forKey:@"type"];
        }else if (_curIndex == 1){
            ///公开动态
            [params setObject:@"company" forKey:@"type"];
        }
    }else if ([self.typeOfView isEqualToString:@"feed"]) {
        ///我的动态
        url = MY_TRENDS_LIST;
        
        [params setObject:appDelegateAccessor.moudle.userId forKey:@"id"];
        [CommonStaticVar setTypeOfWorkGroupCellInfo:@"feed"];
    }else if ([self.typeOfView isEqualToString:@"favorite"]) {
        ///我的收藏
        url = MY_FAVORITES_LIST;
        [CommonStaticVar setTypeOfWorkGroupCellInfo:@"feed"];
    }else if([self.typeOfView isEqualToString:@"homeworkzone"]){
//        ///首页工作圈
        url = TRENDS_LIST;
        [params setObject:@"focus" forKey:@"type"];
    
        [CommonStaticVar setTypeOfWorkGroupCellInfo:@"feed"];
        
    }else if([self.typeOfView isEqualToString:@"departmentfeed"]){
        ///部门动态
        url = TRENDS_LIST;
        
        [params setObject:@"dept" forKey:@"type"];
        [params setObject:[NSNumber numberWithLongLong:self.parentId] forKey:@"deptId"];
    }else if([self.typeOfView isEqualToString:@"groupfeed"]){
        ///群组动态
        url = TRENDS_LIST;
        
        [params setObject:@"group" forKey:@"type"];
        [params setObject:[NSNumber numberWithLongLong:self.parentId] forKey:@"groupId"];
    }
    
    [params setObject:[NSNumber numberWithInteger:pageNo] forKey:@"pageNo"];
    [params setObject:[NSNumber numberWithInt:PageSize] forKey:@"pageSize"];
    
    BOOL isScrToTop = FALSE;
    if (pageNo == 1) {
        isScrToTop = TRUE;
    }
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA,url] params:params success:^(id responseObj) {
        NSLog(@"responseObj:%@",responseObj);
        //字典转模型
        NSDictionary *resultdic = responseObj;
        
        if (resultdic && [[resultdic objectForKey:@"status"] integerValue] == 0) {
            ///动态时间戳 缓存时间戳
            ///我关注的动态
            if ([url isEqualToString:TRENDS_LIST] && _curIndex == 0) {
                NSString *serverTime = [resultdic safeObjectForKey:@"serverTime"];
                [self saveServerTimeFlag:serverTime];
            }
            [self setViewRequestSusscess:resultdic];
        }else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getDataFromService];
            };
            [comRequest loginInBackground];
        }
        else{
            NSString *desc = [resultdic safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"操作失败";
            }
            ///加载失败 做相应处理
            [self setViewRequestFaild:desc];
        }
        ///刷新UI
        [self reloadRefeshView];
        
        if (isScrToTop && self.arrayWorkGroup && self.arrayWorkGroup.count > 0) {
            [self acrollToTop];
        }
        
        if(hudRefresh){
            [hudRefresh hide:YES];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        if(hudRefresh){
            [hudRefresh hide:YES];
        }
        ///网络失败 做相应处理
        [self setViewRequestFaild:NET_ERROR];
        ///刷新UI
        [self reloadRefeshView];
    }];
}


// 请求成功时数据处理
-(void)setViewRequestSusscess:(NSDictionary *)resultdic
{
    NSArray *allDataArry = nil;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];

    if ([resultdic objectForKey:@"feeds"]) {
        array = [resultdic  objectForKey:@"feeds"];
        //  moduleType  模块类型 1 OA 2 CRM.
//        for (NSDictionary *dict in allDataArry) {
//            if ([dict objectForKey:@"moduleType"] && [[dict objectForKey:@"moduleType"] integerValue] == 1) {
//                [array addObject:dict];
//            }
//        }
    }
    
    NSLog(@"count:%ti",[array count]);
    if(pageNo == 1)
    {
        [self.arrayWorkGroup removeAllObjects];
    }
    ///有数据返回
    if (array && [array count] > 0) {
        
        ///添加当前页数据到列表中...
        [self.arrayWorkGroup addObjectsFromArray:array];
        ///缓存第一页数据
        if(pageNo == 1)
        {
            [self saveDynamicData:self.arrayWorkGroup];
//            [self acrollToTop];
        }
        
        ///页码++
        if ([array count] == PageSize) {
            pageNo++;
            isMoreData = YES;
            [self.tableviewWorkGroup setFooterHidden:NO];
        }else
        {
            ///隐藏上拉刷新
            [self.tableviewWorkGroup setFooterHidden:YES];
            isMoreData = NO;
        }
        
    }else{
        ///返回为空
        ///隐藏上拉刷新
        isMoreData = NO;
        [self.tableviewWorkGroup setFooterHidden:YES];
        ///若是第一页 读取是否存在缓存
        if(pageNo == 1)
        {
            [self.arrayWorkGroup removeAllObjects];
            [self saveDynamicData:self.arrayWorkGroup];
            [self setViewNoData];
        }
    }
}


-(void)acrollToTop{
//    if([self.typeOfView isEqualToString:@"homeworkzone"] || [self.typeOfView isEqualToString:@"departmentfeed"]
//       || [self.typeOfView isEqualToString:@"groupfeed"]){
//        [self.tableviewWorkGroup setContentOffset:CGPointMake(0,0) animated:YES];
//    }else{
//        [self.tableviewWorkGroup setContentOffset:CGPointMake(0,-64) animated:YES];
//    }
    
//    [self.tableviewWorkGroup scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
    
    if (self.arrayWorkGroup && self.arrayWorkGroup.count > 0) {
        [self.tableviewWorkGroup scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
}

// 请求失败时数据处理
-(void)setViewRequestFaild:(NSString *)desc
{
    ///若是第一页 读取是否存在缓存
    if(pageNo == 1)
    {
        ///如果当前没有展示数据 则读取缓存
        if (self.arrayWorkGroup == nil || [self.arrayWorkGroup count] == 0) {
            [self getExistCache];
        }
    }
    [CommonFuntion showToast:desc inView:self.view];
}


#pragma mark - 没有数据时的view
-(void)setViewNoData{
    __weak __block typeof(self) weak_self = self;
    
    if([self.typeOfView isEqualToString:@"departmentfeed"] || [self.typeOfView isEqualToString:@"groupfeed"]){
        if (self.commonNoDataView == nil) {
            self.commonNoDataView = [CommonFuntion commonNoDataViewIcon:@"feed_empty.png" Title:@"暂无动态" optionBtnTitle:@""];
            
            [self.tableviewWorkGroup addSubview:self.commonNoDataView];
            _commonNoDataView.optionBtnClickBlock = ^{
//                ///新建动态
//                NSLog(@"新建动态");
//                [weak_self editItemPress];
            };
        }
    }else{
        if (self.commonNoDataView == nil) {
            self.commonNoDataView = [CommonFuntion commonNoDataViewIcon:@"feed_empty.png" Title:@"分享工作中的进展和心得" optionBtnTitle:@"新建动态"];
        }
        
        [self.tableviewWorkGroup addSubview:self.commonNoDataView];
        _commonNoDataView.optionBtnClickBlock = ^{
            ///新建动态
            NSLog(@"新建动态");
            [weak_self editItemPress];
        };
    }
    
}


-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
    }
}


#pragma mark - 上拉下拉刷新相关事件
//集成刷新控件
- (void)setupRefresh
{
    NSString *dateKey = @"";
    if ([self.typeOfView isEqualToString:@"workzone"]) {
        ///工作圈
        dateKey = @"workzone";
    }else if ([self.typeOfView isEqualToString:@"feed"]) {
        ///我的动态
        dateKey = @"feed";
    }else if ([self.typeOfView isEqualToString:@"favorite"]) {
        ///我的收藏
        dateKey = @"favorite";
    }else if([self.typeOfView isEqualToString:@"homeworkzone"]){
        ///首页工作圈
        dateKey = @"homeworkzone";
    }else if([self.typeOfView isEqualToString:@"departmentfeed"]){
        ///部门动态
        dateKey = @"departmentfeed";
    }else if([self.typeOfView isEqualToString:@"groupfeed"]){
        ///群组动态
        dateKey = @"groupfeed";
    }
    
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [self.tableviewWorkGroup addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:dateKey];
    //上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableviewWorkGroup addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 自动刷新(一进入程序就下拉刷新)
    //    [self.tableviewCampaign headerBeginRefreshing];
}

// 结束加载
-(void)reloadRefeshView{
    // 刷新列表
    [self.tableviewWorkGroup reloadData];
    [self.tableviewWorkGroup footerEndRefreshing];
    [self.tableviewWorkGroup headerEndRefreshing];
}

// 下拉
- (void)headerRereshing
{
    NSLog(@"headerRereshing--下拉-->");
    
    if ([self.tableviewWorkGroup isFooterRefreshing]) {
        [self.tableviewWorkGroup headerEndRefreshing];
        return;
    }
    
    pageNo = 1;
    [self getDataFromService];
}

// 上拉
- (void)footerRereshing
{
    NSLog(@"footerRereshing--上拉-->");
    
    if ([self.tableviewWorkGroup isHeaderRefreshing]) {
        [self.tableviewWorkGroup footerEndRefreshing];
        return;
    }
    [self getDataFromService];
}


#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.arrayWorkGroup && self.arrayWorkGroup.count > 0) {
        return [self.arrayWorkGroup count];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 14.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if ( !isMoreData &&  self.arrayWorkGroup && (section == [self.arrayWorkGroup count]-1)) {
        return 70.;
    }
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self getHeightByCellType:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WorkGroupType type = [self getWorkTypeByIndex:indexPath.section];
    
    ///不可操作的评论
    if (type == WorkGroupTypeA) {
        static NSString *identifyA = @"WorkGroupRecordCellAIdentify";
        WorkGroupRecordCellA *cell = [tableView dequeueReusableCellWithIdentifier:identifyA];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"WorkGroupRecordCellA" owner:self options:nil];
            cell = (WorkGroupRecordCellA*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        [cell setContentDetails:[self.arrayWorkGroup objectAtIndex:indexPath.section] indexPath:indexPath];
        
        return cell;
    }else if (type == WorkGroupTypeB) {
        WorkGroupRecordCellB *cell = [tableView dequeueReusableCellWithIdentifier:@"WorkGroupRecordCellBIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"WorkGroupRecordCellB" owner:self options:nil];
            cell = (WorkGroupRecordCellB*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        cell.delegate = self;
        cell.labelContent.delegate = self;
        NSDictionary *item;
        if ([[CommonStaticVar getTypeOfWorkGroupCellInfo] isEqualToString:@"comment"])  {
            
            ///消息 提到我的
            if ([[[self.arrayWorkGroup objectAtIndex:indexPath.section] objectForKey:@"type"] integerValue] == 1) {
                item = [[self.arrayWorkGroup objectAtIndex:indexPath.section] objectForKey:@"comment"];
                
                NSLog(@"comment-item:%@",item);
            }else{
                ///type == 0
                item = [[self.arrayWorkGroup objectAtIndex:indexPath.section] objectForKey:@"feed"];
            }
            
        }else{
            item = [self.arrayWorkGroup objectAtIndex:indexPath.section];
        }
        
        [cell setContentDetails:item indexPath:indexPath byCellStatus:WorkGroupTypeStatusCell];
        [cell addClickEventForCellView:item withIndex:indexPath];
        
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ///根据system 跳转到不同页面
    
    
#warning 这里区分是哪种view  source 做请求
    NSDictionary *item;
    if ([[CommonStaticVar getTypeOfWorkGroupCellInfo] isEqualToString:@"comment"])  {
        
        ///消息 @提到我的
        if ([[[self.arrayWorkGroup objectAtIndex:indexPath.section] objectForKey:@"type"] integerValue] == 1) {
            
            /*
            item = [[self.arrayWorkGroup objectAtIndex:indexPath.section] objectForKey:@"comment"];
            */
#warning 请求服务器  获取feed信息
            
            id jsondata = [CommonFuntion readJsonFile:@"common-atme-data"];
            NSLog(@"jsondata:%@",jsondata);
            
            item = [jsondata  objectForKey:@"feed"];
            
        }else{
            ///type == 0
            item = [[self.arrayWorkGroup objectAtIndex:indexPath.section] objectForKey:@"feed"];
        }
        
        WorkGroupRecordDetailsViewController *controller = [[WorkGroupRecordDetailsViewController alloc] init];
        controller.isShowKeyBoardView = @"no";
        controller.hidesBottomBarWhenPushed = YES;
        controller.dicWorkGroupDetailsOld = item;
        [self.navigationController pushViewController:controller animated:YES];
        
    }else{
        item = [self.arrayWorkGroup objectAtIndex:indexPath.section];
        
        WorkGroupType type = [self getWorkTypeByIndex:indexPath.section];
        
        if (type == WorkGroupTypeA) {
            
            ///这里做其他判断跳转
            ///system
            
            
        }else{
            __weak typeof(self) weak_self = self;
            WorkGroupRecordDetailsViewController *controller = [[WorkGroupRecordDetailsViewController alloc] init];
            controller.isShowKeyBoardView = @"no";
            controller.flagOfDetails = @"normal";
            controller.hidesBottomBarWhenPushed = YES;
            controller.dicWorkGroupDetailsOld = item;
            controller.sectionOfDic = indexPath.section;
            ///更新赞的状态和数量
            controller.UpdatePriaseStatus = ^(NSInteger section){
                [weak_self updateFeedCountAndFlag:section];
            };
            
            ///更新收藏状态
            controller.UpdateFavStatus = ^(NSInteger section, NSString *action){
                [weak_self updateFavFlag:action index:section];
            };
            
            ///删除动态
            controller.DeleteTrendStatus = ^(NSInteger section){
                [weak_self deleteTrend:section];
            };
            
            ///评论动态
            controller.CommentTrendStatus = ^(NSInteger section,NSString *optionFlag){
                [weak_self updateReviewComment:section withFlag:optionFlag];
            };
            
            ///转发动态
            controller.UpdateByForwardTrend = ^(){
                ///重新请求数据
                [weak_self notifyDataByHeadRequest];
            };
            controller.BlackFreshenBlock = ^(){
                pageNo = 1;
                [weak_self getDataFromService];
            };
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

#pragma mark - 获取cell对应的type
-(WorkGroupType)getWorkTypeByIndex:(NSInteger)index{
    WorkGroupType type;
    NSInteger typeValue = 0;

    if ([[self.arrayWorkGroup objectAtIndex:index] objectForKey:@"type"]) {
        typeValue = [[[self.arrayWorkGroup objectAtIndex:index] safeObjectForKey:@"type"]  integerValue];
    }
    ///moduleType  1OA  2CRM
    NSInteger  moduleType = [[[self.arrayWorkGroup objectAtIndex:index] safeObjectForKey:@"moduleType"]  integerValue];
    
    
    type = WorkGroupTypeA;
    ///CRM
    if (moduleType == 2) {
        type = WorkGroupTypeB;
    }else if (moduleType == 1){
        if (typeValue == 0) {
            type = WorkGroupTypeA;
        }else{
            type = WorkGroupTypeB;
        }
    }
    
    return type;
}

#pragma mark - 获取cell对应type对应的height
-(CGFloat)getHeightByCellType:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    
    WorkGroupType type = [self getWorkTypeByIndex:indexPath.section];
    switch (type) {
        case WorkGroupTypeA:
            
            height = [WorkGroupRecordCellA getCellContentHeight:[self.arrayWorkGroup objectAtIndex:indexPath.section]];
            break;
        case WorkGroupTypeB:
        {
            NSDictionary *item;
            if ([[CommonStaticVar getTypeOfWorkGroupCellInfo] isEqualToString:@"comment"])  {
                
                ///消息 提到我的
                if ([[[self.arrayWorkGroup objectAtIndex:indexPath.section] objectForKey:@"type"] integerValue] == 1) {
                    item = [[self.arrayWorkGroup objectAtIndex:indexPath.section] objectForKey:@"comment"];
                }else{
                    ///type == 0
                    item = [[self.arrayWorkGroup objectAtIndex:indexPath.section] objectForKey:@"feed"];
                }
                
            }else{
                item = [self.arrayWorkGroup objectAtIndex:indexPath.section];
            }
            height = [WorkGroupRecordCellB getCellContentHeight:item byCellStatus:WorkGroupTypeStatusCell ];
            break;
        }

        default:
            height = [WorkGroupRecordCellA getCellContentHeight:[self.arrayWorkGroup objectAtIndex:indexPath.section]];
            break;
    }
    return height;
}

#pragma mark - WorkGroupDelegate cell点击事件

///点击头像事件
-(void)clickUserIconEvent:(NSInteger)section{
    NSLog(@"clickUserIconEvent section：%li",section);
    
    ///获取对应的item
    NSDictionary *item;
    /*
    if ([[CommonStaticVar getTypeOfWorkGroupCellInfo] isEqualToString:@"comment"])  {
        ///消息 提到我的
        if ([[[self.arrayWorkGroup objectAtIndex:section] objectForKey:@"type"] integerValue] == 1) {
            item = [[self.arrayWorkGroup objectAtIndex:section] objectForKey:@"comment"];
        }else{
            ///type == 0
            item = [[self.arrayWorkGroup objectAtIndex:section] objectForKey:@"feed"];
        }
        
    }else{
        item = [self.arrayWorkGroup objectAtIndex:section];
    }
    */
    ///user
    NSDictionary *user = nil;
    if ([CommonFuntion checkNullForValue:[[self.arrayWorkGroup objectAtIndex:section] objectForKey:@"user"]]) {
        user = [[self.arrayWorkGroup objectAtIndex:section] objectForKey:@"user"];
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
    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];
    NSInteger  modelType = [[item objectForKey:@"moduleType"] integerValue];
    
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
    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];
    
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
    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];
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
    
    NSDictionary *itemOld ;
    
    if ([[CommonStaticVar getTypeOfWorkGroupCellInfo] isEqualToString:@"comment"])  {
        
        ///消息 提到我的
        if ([[[self.arrayWorkGroup objectAtIndex:section] objectForKey:@"type"] integerValue] == 1) {
            itemOld = [[self.arrayWorkGroup objectAtIndex:section] objectForKey:@"comment"];
        }else{
            ///type == 0
            itemOld = [[self.arrayWorkGroup objectAtIndex:section] objectForKey:@"feed"];
        }
        
    }else{
        itemOld = [self.arrayWorkGroup objectAtIndex:section];
    }
    
    
    NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:itemOld];
    
    ///已经处于展开状态 则收起
    if ([itemOld objectForKey:@"isExp"] && [[itemOld objectForKey:@"isExp"] isEqualToString:@"yes"]) {
        [mutableItemNew setObject:@"no" forKey:@"isExp"];
    }else{
        ///标记为展开展开状态
        [mutableItemNew setObject:@"yes" forKey:@"isExp"];
    }
    
    
#warning 修改数据
    if ([[CommonStaticVar getTypeOfWorkGroupCellInfo] isEqualToString:@"comment"])  {
        NSDictionary *itemComment =[self.arrayWorkGroup objectAtIndex:section];
        NSMutableDictionary *mutableItemNewComment = [NSMutableDictionary dictionaryWithDictionary:itemComment];
        
        [mutableItemNewComment setObject:mutableItemNew forKey:@"comment"];
        //修改数据
        [self.arrayWorkGroup setObject: mutableItemNewComment atIndexedSubscript:section];
    }else{
        //修改数据
        [self.arrayWorkGroup setObject: mutableItemNew atIndexedSubscript:section];
    }
    
    ///刷新当前cell
    [self.tableviewWorkGroup reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:section],nil] withRowAnimation:UITableViewRowAnimationNone];
    
    //    [self.tableviewWorkGroup scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewRowAnimationNone animated:YES];
    
    [self.tableviewWorkGroup scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

///点击转发事件
-(void)clickRepostEvent:(NSInteger)section{
    NSLog(@"clickRepostEvent section：%li",section);
    
    __weak typeof(self) weak_self = self;
    ReleaseViewController *releaseController = [[ReleaseViewController alloc] init];
    releaseController.title = @"转发";
    releaseController.typeOfOptionDynamic = TypeOfOptionDynamicForward;
    releaseController.itemDynamic = [self.arrayWorkGroup objectAtIndex:section];
    releaseController.ReleaseSuccessNotifyData = ^(){
        ///重新请求数据
        [weak_self notifyDataByHeadRequest];
    };
    [self.navigationController pushViewController:releaseController animated:YES];
}

///加载第一页数据
-(void)notifyDataByHeadRequest{
//    [self.tableviewWorkGroup setContentOffset:CGPointZero animated:YES];
     pageNo = 1;
//    [self.arrayWorkGroup removeAllObjects];
    [self getDataFromService];
}

///点击评论事件
-(void)clickReviewEvent:(NSInteger)section{
    NSLog(@"clickReviewEvent section：%li",section);
    WorkGroupRecordDetailsViewController *controller = [[WorkGroupRecordDetailsViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.flagOfDetails = @"normal";
    controller.isShowKeyBoardView = @"no";
    controller.dicWorkGroupDetailsOld = [self.arrayWorkGroup objectAtIndex:section];
    __weak typeof(self) weak_self = self;
    controller.BlackFreshenBlock = ^(){
        [weak_self getDataFromService];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

///点击赞事件
-(void)clickPraiseEvent:(NSInteger)section{
    NSLog(@"clickPraiseEvent section：%li",section);
    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];
    long long trendsId = -1;
    if ([item objectForKey:@"id"]) {
        trendsId = [[item objectForKey:@"id"] longLongValue];
    }

    [self trendOption:FEED_UP_ADD withTrendsId:trendsId indexTrends:section];
    
    /*
    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];

    ///是否已经赞
    NSString *isFeedUp = @"0";
    if ([item objectForKey:@"isFeedUp"]) {
        isFeedUp = [item objectForKey:@"isFeedUp"];
    }
    
    ///还没有赞
    if ([isFeedUp isEqualToString:@"0"]) {
        
    }
    */
    
}

///点击来自XXX事件
-(void)clickFromEvent:(NSInteger)section{
    NSLog(@"clickFromEvent section：%li",section);
    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];
    
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


///跳转到部门或群组
-(void)gotoDepartMentOrGroup:(NSDictionary *)item{
    /*
     from =             {
     id = 798;
     name = "\U5927\U4f5c\U6218";
     sourceId = 1001;
     sourceName = "\U7fa4\U7ec4";
     }
     */
    
    
    /*
     {
     icon = "http://192.168.5.54:9080/skt-user/resource/file.do?u=XDY3NFwyMDE1LTEyLTE2XDE0NTAyNzA4Njg1NzAuanBn";
     id = 798;
     name = "\U5927\U4f5c\U6218";
     pinyin = daizuozhan;
     }
     */
    
    
    NSDictionary *from =  [item objectForKey:@"from"];
    NSDictionary *fromItem = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:[[from objectForKey:@"id"] longValue]],@"id", [from objectForKey:@"name"],@"name",@1,@"hasChildren",@"",@"icon",@"",@"pinyin",nil];
    DepartGroupModel *model = [NSObject objectOfClass:@"DepartGroupModel" fromJSON:fromItem];
    
    DepartViewController *controll = [[DepartViewController alloc] init];
    UITabBarController *tabbarController = [[UITabBarController alloc] init];
    tabbarController.edgesForExtendedLayout = UIRectEdgeNone;
    tabbarController.title = model.name;
    tabbarController.viewControllers = [controll getTabBarItems:model andType:[[from objectForKey:@"sourceId"] integerValue]];
    tabbarController.hidesBottomBarWhenPushed = YES;
    tabbarController.delegate = self;
    [self.navigationController pushViewController:tabbarController animated:YES];
}

///点击内容中的@
-(void)clickContentCharType:(NSString *)type content:(NSString *)content atIndex:(NSIndexPath *)indexPath{
    NSLog(@"clickContentCharType type:%@ content:%@ index:%li",type,content,indexPath.section);
    
    NSDictionary *item;
    if ([[CommonStaticVar getTypeOfWorkGroupCellInfo] isEqualToString:@"comment"])  {
        
        ///消息 提到我的
        if ([[[self.arrayWorkGroup objectAtIndex:indexPath.section] objectForKey:@"type"] integerValue] == 1) {
            item = [[self.arrayWorkGroup objectAtIndex:indexPath.section] objectForKey:@"comment"];
        }else{
            ///type == 0
            item = [[self.arrayWorkGroup objectAtIndex:indexPath.section] objectForKey:@"feed"];
        }
        
    }else{
        item = [self.arrayWorkGroup objectAtIndex:indexPath.section];
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


///点击转发view区域 跳转到详情
-(void)clickRepostViewEvent:(NSInteger)section{
    NSLog(@"clickRepostViewEvent section：%li",section);
    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];
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

///点击图片事件
-(void)clickImageViewEvent:(NSIndexPath *)imgIndexPath{
    NSLog(@"clickImageViewEvent section：%li andImgIndex:%li",imgIndexPath.section,imgIndexPath.row);
    
    [PhotoBroswerVC show:self type:PhotoBroswerVCTypeZoom index:imgIndexPath.row photoModelBlock:^NSArray *{
        
        WorkGroupRecordCellB *cell = (WorkGroupRecordCellB *)[self.tableviewWorkGroup cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:imgIndexPath.section]];
        
        NSDictionary *item = [self.arrayWorkGroup objectAtIndex:imgIndexPath.section];
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
    if (self.arrayWorkGroup && [self.arrayWorkGroup count]>section) {
        NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];
        NSString *voiceStr = @"";
        if ([CommonFuntion checkNullForValue:[item objectForKey:@"audio"]]) {
            if ([[item objectForKey:@"audio"] objectForKey:@"url"]) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
                WorkGroupRecordCellB *cell = (WorkGroupRecordCellB *)[self.tableviewWorkGroup cellForRowAtIndexPath:indexPath];
                NSString *imgSting = @"other";
                if (appDelegateAccessor.cellMoudle.workgroupCellB != nil) {
                    NSLog(@"图片复位-----：%@",appDelegateAccessor.cellMoudle.workgroupCellB);
                    appDelegateAccessor.cellMoudle.workgroupCellB.imgVoice.image = [UIImage imageNamed:[NSString stringWithFormat:@"voice_sign_%@_3.png", imgSting]];
                }
                appDelegateAccessor.cellMoudle.workgroupCellB = cell;
                NSLog(@"showViewAnimation workgroupCellB 0:%@",appDelegateAccessor.cellMoudle.workgroupCellB);
                
                voiceStr = [[item objectForKey:@"audio"] objectForKey:@"url"];
//                [AFSoundPlaybackHelper playAndCacheWithUrl:voiceStr];
            }
        }
    }
    
}

#pragma mark - cell点击事件处理


#pragma mark  OA  点击右上角菜单按钮 弹出actionsheetview
///点击右上角菜单按钮 弹出actionsheetview
-(void)showRightActionSheetMenu:(NSInteger)section{
    
    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];
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
    
    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];
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
    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:actionSheet.tag];
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
    NSInteger m_Type = [[item objectForKey:@"moduleType"] integerValue];
    
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
                    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:actionSheet.tag];
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
                    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:actionSheet.tag];
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
            NSDictionary *item = [self.arrayWorkGroup objectAtIndex:actionSheet.tag];
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
            NSDictionary *item = [self.arrayWorkGroup objectAtIndex:indexDelete];
            NSInteger m_Type = [[item objectForKey:@"moduleType"] integerValue];
             
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
        
//        NSLog(@" responseObj:%@",responseObj);
        //字典转模型
        NSDictionary *resultdic = responseObj;
        
        if (resultdic && [[resultdic objectForKey:@"status"] integerValue] == 0) {
            [self setViewRequestSusscessByTrendOptions:url index:section];
        } else if ((resultdic && [[resultdic objectForKey:@"status"] integerValue] == 1) || (resultdic && [[resultdic objectForKey:@"status"] integerValue] == 2)) {
            NSString *desc = [resultdic safeObjectForKey:@"desc"];
            kShowHUD(desc,nil);
            //如果提示  该动态被删除，则刷新列表
            pageNo = 1;
            [weak_self getDataFromService];
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
        [self deleteTrend:section];
    }else if([action isEqualToString:kNetPath_Common_DeleteActivity]){
        //                kShowHUD(@"删除动态失败");
        [CommonFuntion showToast:@"删除活动记录成功" inView:self.view];
        [self deleteTrend:section];
    }
}


#pragma mark - 更新收藏标记
-(void)updateFavFlag:(NSString *)action index:(NSInteger)section{
    NSLog(@"updateFavFlag  action:%@  section:%ti",action,section);
    ///收藏页面
    if ([self.typeOfView isEqualToString:@"favorite"]) {
        
        pageNo = 1;
        [self getDataFromService];
        
    }else{
        NSInteger isfav = 1;
        if ([action isEqualToString:ADD_FAVORITE]) {
            isfav = 0;
        }else if([action isEqualToString:DELETE_FAVORITE]){
            isfav = 1;
        }
        NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];
        ///修改本地数据
        NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:item];
        [mutableItemNew setObject:[NSNumber numberWithInteger:isfav] forKey:@"isfav"];
        //修改数据
        [self.arrayWorkGroup setObject: mutableItemNew atIndexedSubscript:section];
        
        ///刷新当前cell
        [self.tableviewWorkGroup reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:section],nil] withRowAnimation:UITableViewRowAnimationNone];
        ///修改缓存数据
        [self updateCacheData:mutableItemNew andIndex:section action:actionModify];
    }
 
}

#pragma mark - 刷新赞个数与标志
-(void)updateFeedCountAndFlag:(NSInteger)section{
    NSLog(@"updateFeedCountAndFlag  section:%ti",section);
    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];
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
    [self.arrayWorkGroup setObject: mutableItemNew atIndexedSubscript:section];
    
    ///刷新当前cell
    [self.tableviewWorkGroup reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:section],nil] withRowAnimation:UITableViewRowAnimationNone];
    
    ///修改缓存数据
    [self updateCacheData:mutableItemNew andIndex:section action:actionModify];
    
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
    
//    [self.tableviewWorkGroup setContentOffset:CGPointMake(0,0) animated:NO];
    pageNo = 1;
    [self getDataFromService];
//    if (self.arrayWorkGroup && [self.arrayWorkGroup count] > section) {
//        [self.arrayWorkGroup removeObjectAtIndex:section];
//        [self.tableviewWorkGroup reloadData];
//        NSLog(@"本地数据删除动态");
//        ///缓存数据删除
//        [self updateCacheData:nil andIndex:section action:actionDelete];
//    }
}


#pragma mark - 刷新评论个数
-(void)updateReviewComment:(NSInteger)section withFlag:(NSString *)optionFlag{
    NSLog(@"updateReviewComment");
    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];
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
    [self.arrayWorkGroup setObject: mutableItemNew atIndexedSubscript:section];
    
    ///刷新当前cell
    [self.tableviewWorkGroup reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:section],nil] withRowAnimation:UITableViewRowAnimationNone];
    ///修改缓存数据
    [self updateCacheData:mutableItemNew andIndex:section action:actionModify];
}



- (void)didReceiveMemoryWarning {
    if ([self isViewLoaded] && [self.view window] == nil) {
        NSLog(@"--wg--didReceiveMemoryWarning----->");
        self.view = nil;
        ///清除图片相关缓存
        [[SDImageCache sharedImageCache] clearMemory];
        [[SDImageCache sharedImageCache] clearDisk];
    }
}


#pragma mark - 存储动态时间戳
-(void)saveServerTimeFlag:(NSString *)serverTime{
    ///存储动态时间戳
    NSLog(@"serverTime:%@",serverTime);
    if (serverTime) {
        [NSUserDefaults_Cache setSKTUnReadOATrendCycleServerTime:serverTime];
    }
}

/*
#pragma mark - 播放语音
- (void)playVoiceWithVoiceUrl:(NSString *)voiceUrl WithIndexPathSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    WorkGroupRecordCellB *cell = (WorkGroupRecordCellB *)[self.tableviewWorkGroup cellForRowAtIndexPath:indexPath];
    NSString *imgSting = @"other";
    if (_playback) {
        [_playback pause];
        _playback = nil;
        
        if (_cell != nil) {
            NSLog(@"图片复位-----：%@",_cell);
            _cell.imgVoice.image = [UIImage imageNamed:[NSString stringWithFormat:@"voice_sign_%@_3.png", imgSting]];
        }else{
            _cell = cell;
        }
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        AFSoundItem *item = [[AFSoundItem alloc] initWithStreamingURL:[NSURL URLWithString:voiceUrl]];
        
        _playback = [[AFSoundPlayback alloc] initWithItem:item];
        [_playback play];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"----->");
            [_playback listenFeedbackUpdatesWithBlock:^(AFSoundItem *item) {
                NSLog(@"Item duration: %ld - time elapsed: %ld", (long)item.duration, (long)item.timePlayed);
                NSString *imgName = @"";
                NSInteger durationing = item.timePlayed;
                switch (durationing%3) {
                    case 0:
                    {
                        imgName = [NSString stringWithFormat:@"voice_sign_%@_1.png", imgSting];
                    }
                        break;
                    case 1:
                    {
                        imgName = [NSString stringWithFormat:@"voice_sign_%@_2.png", imgSting];
                    }
                        break;
                    case 2:
                    {
                        imgName = [NSString stringWithFormat:@"voice_sign_%@_3.png", imgSting];
                    }
                        break;
                        
                    default:
                    {
                        imgName = [NSString stringWithFormat:@"voice_sign_%@_3.png", imgSting];
                    }
                        break;
                }
                cell.imageView.image = [UIImage imageNamed:imgName];
                
            } andFinishedBlock:^(void){
                NSLog(@"andFinishedBlock");
                cell.imgVoice.image = [UIImage imageNamed:[NSString stringWithFormat:@"voice_sign_%@_3.png", imgSting]];
                
            }];
        });
        
    });
    
}
 */

@end
