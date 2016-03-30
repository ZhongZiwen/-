//
//  AfterServiceViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//
#define pageSize 10
#import "AfterServiceViewController.h"
#import "AfterServiceCell.h"
#import "LLCenterUtility.h"
#import "CommonStaticVar.h"
#import "MJRefresh.h"
#import "CommonFunc.h"
#import "CommonNoDataView.h"
#import "CustomPopView.h"
#import "DeleteAfterServiceViewController.h"
#import "AfterServiceDetailViewController.h"
#import "AddOrEditAfterServiceViewController.h"


@interface AfterServiceViewController ()<UITableViewDataSource,UITableViewDelegate>{
    
    //分页加载
    int listPage,lastPosition;
}

@property(strong,nonatomic) UITableView *tableview;
@property(strong,nonatomic) NSMutableArray *dataSource;
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@end

@implementation AfterServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"售后服务";
    [super customBackButton];
    self.view.backgroundColor = COLOR_BG;
    [self addNavBar];
    [self initData];
    [self initTableview];
        [self getAfterService];
//    [self readTestData];
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
    
    NSArray *titles;
    NSArray *imgs;
    ///判断是否有权限 是否为普通用户
    if ([[CommonStaticVar getAccountType] isEqualToString:@"boss"]) {
        titles = [NSArray arrayWithObjects:@"新增售后服务",@"删除售后服务", nil];
        imgs = [NSArray arrayWithObjects:@"icon_add_afterservice.png",@"icon_delete_img.png", nil];
    }else{
        titles = [NSArray arrayWithObjects:@"新增售后服务", nil];
        imgs = [NSArray arrayWithObjects:@"icon_add_afterservice.png",nil];
    }
    CustomPopView *popView = [[CustomPopView alloc] initWithPoint:CGPointMake(0, 64+64) titles:titles imageNames:imgs];
    
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

///删除售后服务
-(void)gotoDeleteView{
    
    if (self.dataSource == nil || [self.dataSource count] < 1) {
        [CommonFuntion showToast:@"暂无售后服务" inView:self.view];
        return;
    }
    
    
    DeleteAfterServiceViewController *controll = [[DeleteAfterServiceViewController alloc] init];
    controll.dataSourceOld = self.dataSource;
    
    __weak typeof(self) weak_self = self;
    controll.NotifyAfterServiceList = ^{
        listPage = 1;
        [weak_self getAfterService];
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
    id jsondata = [CommonFunc readJsonFile:@"after_service_data "];
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
    return 90.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AfterServiceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AfterServiceCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"AfterServiceCell" owner:self options:nil];
        cell = (AfterServiceCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
        [cell setCellFrameWithType:1];
    }
    
    [cell setCellDetail:[self.dataSource objectAtIndex:indexPath.section] anIndexPath:indexPath];
    
    __weak typeof(self) weak_self = self;
    cell.GotoEditDetailsViewBlock = ^(NSInteger section){
        NSLog(@"section:%ti",section);
        [weak_self gotoDetailsView:section];
    };
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self gotoDetailsView:indexPath.section];
}


///详情页面
-(void)gotoDetailsView:(NSInteger)section{
    AfterServiceDetailViewController *sod = [[AfterServiceDetailViewController alloc] init];
    sod.serviceId = [[self.dataSource objectAtIndex:section] safeObjectForKey:@"serviceId"];
    sod.customerId = self.customerId;
    
    __weak typeof(self) weak_self = self;
    sod.NotifyAfterServiceList = ^{
        listPage = 1;
        [weak_self getAfterService];
    };
    [self.navigationController pushViewController:sod animated:YES];
}

///跳转到新增或编辑页面 action : add edit
-(void)gotoAddOrEditDetailsView:(NSString*)action andIndex:(NSInteger)section{
    AddOrEditAfterServiceViewController *aec = [[AddOrEditAfterServiceViewController alloc] init];
    aec.actionType = action;
    aec.title = @"新增售后服务";
    aec.customerId = self.customerId;
    
    __weak typeof(self) weak_self = self;
    aec.NotifyAfterServiceList = ^{
        listPage = 1;
        [weak_self getAfterService];
    };
    
    [self.navigationController pushViewController:aec animated:YES];
}




#pragma mark - 上拉下拉刷新相关事件
//集成刷新控件
- (void)setupRefresh
{
    NSString *dateKey = @"llcafterservice";
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
    [self getAfterService];
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
    [self getAfterService];
}

#pragma mark - 没有数据时的view
-(void)notifyNoDataView{
    if (self.dataSource && [self.dataSource count] > 0) {
        [self clearViewNoData];
    }else{
        [self setViewNoData:@"暂无售后服务"];
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
-(void)getAfterService{
    
    [self clearViewNoData];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    
    [rDict setValue:self.customerId forKey:@"customerId"];
    [rDict setValue:[NSString stringWithFormat:@"%i",listPage] forKey:@"pageCount"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_AFTER_SERVICE_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        if(listPage == 1)
        {
            [self.dataSource removeAllObjects];
        }
        NSLog(@"售后服务jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [self setViewRequestSusscess:jsonResponse];
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getAfterService];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
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
