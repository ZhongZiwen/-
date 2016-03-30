//
//  CustomerRelatedViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-7-18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

///每页条数
#define PageSize 10

#import "CustomerRelatedViewController.h"
#import "CommonConstant.h"
#import "CommonFuntion.h"
#import "CustomerRelatedCell.h"
#import "MsgCustomerViewController.h"

#import "AFNHttp.h"
#import <MBProgressHUD.h>
#import "MJRefresh.h"
#import "CommonNoDataView.h"
#import "CommonDetailViewController.h"

@interface CustomerRelatedViewController ()<UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,SWTableViewCellDelegate>{
    NSInteger pageNo;//页数下标
}

@property(strong,nonatomic) UITableView *tableviewCustomerRelated;
@property(strong,nonatomic) NSMutableArray *arrayCustomerRelated;
///无数据时的view
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@end

@implementation CustomerRelatedViewController

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = VIEW_BG_COLOR;
    [self addRightNarBtn];
    [self initTableview];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
//    [self readTestData];
    [self getDataFromService];
//    [self.tableviewCustomerRelated reloadData];
}



#pragma mark - 读取测试数据
-(void)readTestData{
    id jsondata = [CommonFuntion readJsonFile:@"customer-relate-data"];
    NSLog(@"jsondata:%@",jsondata);
    
    NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"accounts"];
    [self.arrayCustomerRelated addObjectsFromArray:array];
    NSLog(@"arrayCustomer count:%li",[self.arrayCustomerRelated count]);
    
}


#pragma mark - 初始化数据
-(void)initData{
    self.arrayCustomerRelated = [[NSMutableArray alloc] init];
}

#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewCustomerRelated = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStylePlain];
    [self.tableviewCustomerRelated registerNib:[UINib nibWithNibName:@"CustomerRelatedCell" bundle:nil] forCellReuseIdentifier:@"CustomerRelatedCellIdentify"];
    self.tableviewCustomerRelated.delegate = self;
    self.tableviewCustomerRelated.dataSource = self;
    self.tableviewCustomerRelated.sectionFooterHeight = 0;
    [self.view addSubview:self.tableviewCustomerRelated];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewCustomerRelated setTableFooterView:v];
    
    [self setupRefresh];
}

#pragma mark - tableview delegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.arrayCustomerRelated) {
        return [self.arrayCustomerRelated count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CustomerRelatedCellIdentify";
    CustomerRelatedCell *cell = (CustomerRelatedCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"CustomerRelatedCell" owner:self options:nil];
        cell = (CustomerRelatedCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    cell.delegate = self;
   
    [cell setLeftAndRightBtn];
    [cell setCellDetails:[self.arrayCustomerRelated objectAtIndex:indexPath.row] indexPath:indexPath];
    
    __block typeof(self) weak_self = self;
    cell.CallCusotmerBlock = ^(NSInteger index){
        [weak_self callCustomer:index];
        
    };
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CommonDetailViewController *controller = [[CommonDetailViewController alloc] init];
    controller.typeOfDetail = 1;
    controller.title = @"客户";
    [self.navigationController pushViewController:controller animated:YES];
    
}


#pragma mark - SWTableViewDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
        //        NSLog(@"utility buttons closed");
        break;
        case 1:
        //        NSLog(@"left utility buttons open");
        break;
        case 2:
        //        NSLog(@"right utility buttons open");
        break;
        default:
        break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        //        NSLog(@"left button 0 was pressed");
        break;
        default:
        break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [self.tableviewCustomerRelated indexPathForCell:cell];
    NSLog(@"click index:%ld",indexPath.row);
    NSDictionary *item = [self.arrayCustomerRelated objectAtIndex:indexPath.row];
    
    switch (index) {
        case 0:
        {
            ///删除
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        
        default:
        break;
    }
}


- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
        // set to NO to disable all left utility buttons appearing
        return NO;
        break;
        case 2:
        // set to NO to disable all right utility buttons appearing
        return YES;
        break;
        default:
        break;
    }
    
    return YES;
}


#pragma mark - 右侧更多按钮
-(void)addRightNarBtn{
    
    UIButton *option = [UIButton buttonWithType:UIButtonTypeCustom];
    option.frame = CGRectMake(0, 0, 20, 4);
    [option setBackgroundImage:[UIImage imageNamed:@"more.png"]
                      forState:UIControlStateNormal];
    
    [option setBackgroundImage:[UIImage imageNamed:@"more.png"]
                      forState:UIControlStateHighlighted];
    
    
    [option addTarget:self action:@selector(showOptionMenu)
     forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:option];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)showOptionMenu{
    UIActionSheet *actionSheet;
    if (self.arrayCustomerRelated && [self.arrayCustomerRelated count] > 0) {
        actionSheet = [[UIActionSheet alloc]
                       initWithTitle:nil
                       delegate:self
                       cancelButtonTitle:@"取消"
                       destructiveButtonTitle:nil
                       otherButtonTitles: @"添加客户",@"修改参与状态",nil];
        actionSheet.tag = 101;
    }else{
        actionSheet = [[UIActionSheet alloc]
                       initWithTitle:nil
                       delegate:self
                       cancelButtonTitle:@"取消"
                       destructiveButtonTitle:nil
                       otherButtonTitles: @"添加客户",nil];
        actionSheet.tag = 102;
    }
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        ///添加客户
        MsgCustomerViewController *controller = [[MsgCustomerViewController alloc] init];
        controller.typeViewFrom = @"addCustomer";
        controller.BackCustomersBlock = ^(NSArray *array) {
            //先遍历 去重
            NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
            for (NSDictionary *dict in self.arrayCustomerRelated) {
                [newArray addObject:[dict safeObjectForKey:@"id"]];
            }
            for (NSDictionary *newDic in array) {
                if (![newArray containsObject:[newDic safeObjectForKey:@"id"]]) {
                    [self.arrayCustomerRelated insertObject:newDic atIndex:0];
                }
            }
            NSLog(@"---%@", self.arrayCustomerRelated);
            [_tableviewCustomerRelated reloadData];
        };
        [self.navigationController pushViewController:controller animated:YES];
    }else if (buttonIndex == 1) {
        ///修改参与状态
    }
}


#pragma mark - 拨打电话
-(void)callCustomer:(NSInteger)index{
    ///phone
    NSString *phone = @"";
    if ([[self.arrayCustomerRelated objectAtIndex:index] objectForKey:@"phone"]) {
        phone = [[self.arrayCustomerRelated objectAtIndex:index] objectForKey:@"phone"];
    }
    NSLog(@"phone:%@",phone);
    [CommonFuntion callToCurPhoneNum:phone atView:self.view];
}




#pragma mark - 上拉下拉刷新相关事件
//集成刷新控件
- (void)setupRefresh
{
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [self.tableviewCustomerRelated addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"CustomerRelated"];
    //上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableviewCustomerRelated addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 自动刷新(一进入程序就下拉刷新)
    //    [self.tableviewCampaign headerBeginRefreshing];
}

// 结束加载
-(void)reloadRefeshView{
    // 刷新列表
    [self.tableviewCustomerRelated reloadData];
    [self.tableviewCustomerRelated footerEndRefreshing];
    [self.tableviewCustomerRelated headerEndRefreshing];
}

// 下拉
- (void)headerRereshing
{
    if ([self.tableviewCustomerRelated isFooterRefreshing]) {
        [self.tableviewCustomerRelated headerEndRefreshing];
        return;
    }
    
    pageNo = 1;
    [self getDataFromService];
}

// 上拉
- (void)footerRereshing
{
    if ([self.tableviewCustomerRelated isHeaderRefreshing]) {
        [self.tableviewCustomerRelated footerEndRefreshing];
        return;
    }
    [self getDataFromService];
}



#pragma mark - 请求数据
-(void)getDataFromService{
    
    NSString *url = GET_CAMPAIGN_DETAILS_CUSTOMER;
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    [params setObject:[NSNumber numberWithInteger:pageNo] forKey:@"pageNo"];
    [params setObject:[NSNumber numberWithInt:PageSize] forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithLongLong:self.requestId] forKey:@"id"];
    [params setObject:@"0" forKey:@"type"];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP,url] params:params success:^(id responseObj) {
        
        NSLog(@"详情-客户 responseObj:%@",responseObj);
        //字典转模型
        NSDictionary *resultdic = responseObj;
        
        if (resultdic && [[resultdic objectForKey:@"status"] integerValue] == 0) {
            [self setViewRequestSusscess:resultdic];
        }else if (resultdic && [[resultdic objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
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
                desc = @"加载失败";
            }
            ///加载失败 做相应处理
            [self setViewRequestFaild:desc];
        }
        ///刷新UI
        [self reloadRefeshView];
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        ///网络失败 做相应处理
        [self setViewRequestFaild:NET_ERROR];
        ///刷新UI
        [self reloadRefeshView];
    }];
}


// 请求成功时数据处理
-(void)setViewRequestSusscess:(NSDictionary *)resultdic
{
    NSArray  *array = nil;
    
    if ([resultdic objectForKey:@"customers"] ) {
        array = [resultdic objectForKey:@"customers"] ;
    }
    NSLog(@"count:%ti",[array count]);
    
    ///有数据返回
    if (array && [array count] > 0) {
        if(pageNo == 1)
        {
            [self.arrayCustomerRelated removeAllObjects];
        }
        
        //////
        [self.arrayCustomerRelated addObjectsFromArray:array];

        ///缓存第一页数据
        if(pageNo == 1)
        {
            
        }
        
        ///页码++
        if ([array count] == PageSize) {
            pageNo++;
            [self.tableviewCustomerRelated setFooterHidden:NO];
        }else
        {
            ///隐藏上拉刷新
            [self.tableviewCustomerRelated setFooterHidden:YES];
        }
        
    }else{
        ///返回为空
        ///隐藏上拉刷新
        [self.tableviewCustomerRelated setFooterHidden:YES];
        ///若是第一页 读取是否存在缓存
        if(pageNo == 1)
        {
            [self.arrayCustomerRelated removeAllObjects];
            [self setViewNoData];
        }
    }
}

// 请求失败时数据处理
-(void)setViewRequestFaild:(NSString *)desc
{
    ///若是第一页 读取是否存在缓存
    if(pageNo == 1)
    {
    }
    [CommonFuntion showToast:desc inView:self.view];
}


#pragma mark - 没有数据时的view
-(void)setViewNoData{
    __weak __block typeof(self) weak_self = self;
    
    self.commonNoDataView = [CommonFuntion commonNoDataViewIcon:@"feed_empty.png" Title:@"没有市场活动" optionBtnTitle:@""];
    
    [self.tableviewCustomerRelated addSubview:self.commonNoDataView];
    _commonNoDataView.optionBtnClickBlock = ^{
        ///新建市场活动
        NSLog(@"新建市场活动");
    };
}


-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
    }
}

/*
 {
 id = 1;
 name = FFF;
 participateState = 111;
 }
 */

@end
