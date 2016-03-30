//
//  RingListViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-16.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//
#define pageSize 10
#import "RingListViewController.h"
#import "LLCenterUtility.h"
#import "MJRefresh.h"
#import "CommonFunc.h"
#import "CommonNoDataView.h"
#import "CustomPopView.h"
#import "RingCellA.h"
#import "RingCellB.h"
#import "AddOrEditRingViewController.h"
#import "DeleteRingViewController.h"

@interface RingListViewController ()<UITableViewDataSource,UITableViewDelegate>{
    
    //分页加载
    int listPage,lastPosition;
}

@property(strong,nonatomic) UITableView *tableview;
@property(strong,nonatomic) NSMutableArray *dataSource;
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@end

@implementation RingListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"炫铃设置";
    [super customBackButton];
    self.view.backgroundColor = COLOR_BG;
    [self addNavBar];
    [self initData];
    [self initTableview];
    [self getRingList];
//        [self readTestData];
    [self.tableview reloadData];
}


#pragma mark - Nav Bar
-(void)addNavBar{
    
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
    CustomPopView *popView = [[CustomPopView alloc] initWithPoint:CGPointMake(0, 64+64) titles:@[@"新增炫铃", @"删除炫铃"] imageNames:@[@"icon_add_ring.png", @"icon_delete_img.png"]];
    __weak typeof(self) weak_self = self;
    popView.selectBlock = ^(NSInteger index) {
        if (index == 0) {
            [weak_self gotoAddOrEditDetailsView:@"add" andIndex:0];
        }else if (index == 1){
            [self gotoDeleteView];
        }
    };
    [popView show];
}

///删除炫铃
-(void)gotoDeleteView{
    
    if (self.dataSource == nil || [self.dataSource count] < 1) {
        [CommonFuntion showToast:@"暂无炫铃" inView:self.view];
        return;
    }
    
    DeleteRingViewController *controll = [[DeleteRingViewController alloc] init];
    controll.dataSourceOld = self.dataSource;
    
    __weak typeof(self) weak_self = self;
    controll.NotifyRingList = ^{
        listPage = 1;
        [weak_self getRingList];
    };
    
    [self.navigationController pushViewController:controll animated:YES];
}

#pragma mark - 初始化数据
-(void)initData{
    listPage = 1;
    self.dataSource = [[NSMutableArray alloc] init];
}

#pragma mark - 读取测试数据
-(void)readTestData{
    id jsondata = [CommonFunc readJsonFile:@"ring_data"];
    [self.dataSource addObjectsFromArray:[[jsondata objectForKey:@"resultMap"] objectForKey:@"data"]];
    
    NSLog(@"self.dataSource:%@",self.dataSource);
}


#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-64) style:UITableViewStyleGrouped];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.sectionFooterHeight = 0;
    [self.view addSubview:self.tableview];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableview setTableFooterView:v];
    
     [self setupRefresh];
}


#pragma mark - tableview delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.dataSource) {
        return [self.dataSource count];
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *item = [self.dataSource objectAtIndex:indexPath.section];
    NSInteger timeType = [[item safeObjectForKey:@"timeType"] integerValue] ;
    ///节假日 2  星期日期3
    if (timeType == 2) {
        return [RingCellA getCellHeight];
    }else{
        return [RingCellB getCellHeight:item];
    }
    return 130.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *item = [self.dataSource objectAtIndex:indexPath.section];
    NSInteger timeType = [[item safeObjectForKey:@"timeType"] integerValue] ;
    ///节假日 2  星期日期3
    if (timeType == 2) {
        RingCellA *cell = [tableView dequeueReusableCellWithIdentifier:@"RingCellAIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RingCellA" owner:self options:nil];
            cell = (RingCellA*)[array objectAtIndex:0];
            [cell awakeFromNib];
            [cell setCellFrameWithType:1];
        }
        
        [cell setCellDetail:[self.dataSource objectAtIndex:indexPath.section] anIndexPath:indexPath];
        
        __weak typeof(self) weak_self = self;
        cell.GotoEditDetailsViewBlock = ^(NSInteger section){
            NSLog(@"section:%ti",section);
            [weak_self gotoAddOrEditDetailsView:@"edit" andIndex:section];
        };
        
        return cell;
    }else{
        ///星期类型
        RingCellB *cell = [tableView dequeueReusableCellWithIdentifier:@"RingCellBIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RingCellB" owner:self options:nil];
            cell = (RingCellB*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        
        [cell setCellDetail:[self.dataSource objectAtIndex:indexPath.section] anIndexPath:indexPath andType:1];
        
        __weak typeof(self) weak_self = self;
        cell.GotoEditDetailsViewBlock = ^(NSInteger section){
            NSLog(@"edit section:%ti",section);
            [weak_self gotoAddOrEditDetailsView:@"edit" andIndex:section];
        };
        
        return cell;
    }
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self gotoDetailsView:indexPath.section];
}


///详情页面
-(void)gotoDetailsView:(NSInteger)section{
    /*
    SaleOpportunityDetailViewController *sod = [[SaleOpportunityDetailViewController alloc] init];
    sod.saleId = [[self.dataSource objectAtIndex:section] safeObjectForKey:@"saleId"];
    sod.customerId = self.customerId;
    
    __weak typeof(self) weak_self = self;
    sod.NotifySaleOpportunitysList = ^{
        listPage = 1;
        [weak_self getSaleOpportunityList];
    };
    [self.navigationController pushViewController:sod animated:YES];
     */
}

///跳转到新增或编辑页面 action : add edit
-(void)gotoAddOrEditDetailsView:(NSString*)action andIndex:(NSInteger)section{
    
    AddOrEditRingViewController *aec = [[AddOrEditRingViewController alloc] init];
    aec.actionType = action;
    if ([action isEqualToString:@"add"]) {
        aec.title = @"新增炫铃";
    }else{
        aec.title = @"编辑炫铃";
        aec.detail = [self.dataSource objectAtIndex:section];
    }
    
    __weak typeof(self) weak_self = self;
    aec.NotifyRingList = ^{
        listPage = 1;
        [weak_self getRingList];
    };

    [self.navigationController pushViewController:aec animated:YES];
}
         
#pragma mark - 上拉下拉刷新相关事件
//集成刷新控件
- (void)setupRefresh
{
    NSString *dateKey = @"llcorder";
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
    [self getRingList];
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
    [self getRingList];
}
      
         
#pragma mark - 没有数据时的view
-(void)notifyNoDataView{
    if (self.dataSource && [self.dataSource count] > 0) {
        [self clearViewNoData];
    }else{
        [self setViewNoData:@"暂无炫铃"];
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
-(void)getRingList{
    
    [self clearViewNoData];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rDict setValue:[NSString stringWithFormat:@"%i",listPage] forKey:@"pageCount"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    
    NSLog(@"rParam:%@",rParam);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_RING_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        if(listPage == 1)
        {
            [self.dataSource removeAllObjects];
        }
        NSLog(@"炫铃列表jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [self setViewRequestSusscess:jsonResponse];
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getRingList];
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
    id data = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"];
    if ([data respondsToSelector:@selector(count)] && [data count] > 0) {
        if(listPage == 1)
        {
            [self.dataSource removeAllObjects];
        }
        
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
