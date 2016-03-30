//
//  HomePageViewController.m
//  lianluozhongxin
//
//  Created by Vescky on 14-6-16.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "HomePageViewController.h"
#import "UserSession.h"
#import "HomePageCell.h"
#import "MJRefresh.h"
#import "RegexKitLite.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"



@interface HomePageViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate> {
    HomePageCell *sampleCell;
    
}
@end

@implementation HomePageViewController

#pragma mark - life-cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"账户";
     
    [super customBackButton];
    // UI 适配
    [self setCurViewFrame];
    
    [self setupRefresh];
    
    sampleCell = [[[NSBundle mainBundle] loadNibNamed:@"HomePageCell" owner:self options:nil] objectAtIndex:0];
    // 20141219-注释 登录时无法刷新问题
    [self initData];
    [self getAccountDetailInfoFromServer];
    
    
//    [self getDataFromServer];
//    [self refreshUserDetailInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self getAccountDetailInfoFromServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)initData {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAccountDetailInfoFromServer) name:@"user_detail_info_refreshed" object:nil];
}

- (void)refreshUserDetailInfo {
    NSDictionary *accountDetailInfo = [[UserSession shareSession] getAccountDetailInfo];
    
    CellDataInfo *cellInfo1,*cellInfo2,*cellInfo3,*cellInfo4;
    
//    CellDataInfo *cellInfo1 = [[CellDataInfo alloc] initWithCellDataInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"账户:",@"itemName", @"400-400-4000",@"itemContent",@"hp_account.png",@"itemIcon",nil] expandable:NO];
//    CellDataInfo *cellInfo2 = [[CellDataInfo alloc] initWithCellDataInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"名称:",@"itemName", @"上海尚景通信",@"itemContent",@"hp_username.png",@"itemIcon",nil] expandable:NO];
//    CellDataInfo *cellInfo3 = [[CellDataInfo alloc] initWithCellDataInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"套餐:",@"itemName", @"100/0.2/12月",@"itemContent",@"hp_package.png",@"itemIcon",nil] expandable:YES];
//    CellDataInfo *cellInfo4 = [[CellDataInfo alloc] initWithCellDataInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"时长:",@"itemName", @"13246分钟",@"itemContent",@"hp_time.png",@"itemIcon",nil] expandable:NO];
    
    if (accountDetailInfo) {
        cellInfo1 = [[CellDataInfo alloc] initWithCellDataInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"账户:",@"itemName", [accountDetailInfo objectForKey:@"phone400"],@"itemContent",@"hp_account.png",@"itemIcon",nil] expandable:NO];
        
        NSString *companyName = [accountDetailInfo safeObjectForKey:@"companyName"];
        if ([companyName isKindOfClass:NSClassFromString(@"NSString")]) {
            companyName = [companyName stringByReplacingOccurrencesOfRegex:@"\\(.*\\)" withString:@""];
//            NSArray *arr = [companyName componentsSeparatedByString:@"("];
//            if (arr.count > 1) {
//                companyName = [NSString stringWithFormat:@"%@(400..)",[arr firstObject]];
//                if (companyName.length > 12) {
//                    companyName = [arr firstObject];
//                }
//            }
        }
        cellInfo2 = [[CellDataInfo alloc] initWithCellDataInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"名称:",@"itemName", companyName,@"itemContent",@"hp_username.png",@"itemIcon",nil] expandable:NO];
        cellInfo3 = [[CellDataInfo alloc] initWithCellDataInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"套餐:",@"itemName", [accountDetailInfo objectForKey:@"combo"],@"itemContent",@"hp_package.png",@"itemIcon",accountDetailInfo,@"extra",nil] expandable:YES];
        
        NSString *aString = [NSString stringWithFormat:@"%@ 分钟",[accountDetailInfo objectForKey:@"amount"]];
        cellInfo4 = [[CellDataInfo alloc] initWithCellDataInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"时长:",@"itemName", aString,@"itemContent",@"hp_time.png",@"itemIcon",nil] expandable:NO];
    }
    
    dataSource = [[NSMutableArray alloc] initWithObjects:cellInfo1,cellInfo2,cellInfo3,cellInfo4, nil];
    
    [tbView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //有个特殊行,行数+1
    return [dataSource count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    HomePageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homepagetableviewcell"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"HomePageCell" owner:self options:nil];
        cell = (HomePageCell*)[array objectAtIndex:0];
    }
    [cell setCellViewFrame];
    
    if (indexPath.row == 0) {
        //特殊行，显示背景图
        [cell addSubview:imgv_bg];
        cell.tag = indexPath.row;
        return cell;
    }
    
    CellDataInfo *currentCellDataInfo = [dataSource objectAtIndex:indexPath.row-1];
    
    cell.tag = indexPath.row;
    [cell setCellDataInfo:currentCellDataInfo];

    
    /*
    if([cell respondsToSelector:@selector(setCellDataInfo:)]){
        [cell performSelector:@selector(setCellDataInfo:) withObject:currentCellDataInfo];
    }
     */
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        //特殊行，显示背景图
        return 1.f;
    }
    else {
        
        CellDataInfo *currentCellDataInfo = [dataSource objectAtIndex:indexPath.row - 1];
//        return [sampleCell getCellHeight:currentCellDataInfo];
        
        
        if (currentCellDataInfo.expanded) {
            //放大状态
            return [sampleCell getCellHeight:currentCellDataInfo];
        }
        else {
            //缩小状态
            return 57.f;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tbView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row - 1 < 0) {
        return;
    }
    CellDataInfo *currentCellDataInfo = [dataSource objectAtIndex:indexPath.row - 1];
    if (currentCellDataInfo.expandable) {
        currentCellDataInfo.expanded = !currentCellDataInfo.expanded;
        [dataSource replaceObjectAtIndex:(indexPath.row - 1) withObject:currentCellDataInfo];
        
        HomePageCell *cCell = (HomePageCell*)[tbView cellForRowAtIndexPath:indexPath];
        [cCell setButtonSelected:currentCellDataInfo.expanded];
        [tbView beginUpdates];
        [tbView endUpdates];
//        UITableViewCell *cell = (UITableViewCell *)[tbView cellForRowAtIndexPath:indexPath];
        //刷新单个cell
//        if (currentCellDataInfo.expanded) {
//            [tbView reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
//        }
//        else {
//            [tbView reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
//        }
        
        [tbView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}


// 获取账号信息
- (void)getAccountDetailInfoFromServer {

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_ACCOUNT_INFO_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        if ([[jsonResponse objectForKey:@"status"]intValue] == 1) {
            [[UserSession shareSession] saveAccountDetailInfo:[jsonResponse objectForKey:@"resultMap"]];
            [self refreshUserDetailInfo];
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getAccountDetailInfoFromServer];
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
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        [self reloadRefeshView];
    }];
}


#pragma mark - 上拉下拉刷新相关事件
//集成刷新控件
- (void)setupRefresh
{
    NSString *dateKey = @"llc-accountinfo";
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [tbView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:dateKey];
}


// 结束加载
-(void)reloadRefeshView{
    // 刷新列表
    [tbView reloadData];
    [tbView headerEndRefreshing];
}

// 下拉
- (void)headerRereshing
{
    NSLog(@"headerRereshing--下拉-->");
   [self getAccountDetailInfoFromServer];
}




#pragma mark - UI适配
-(void)setCurViewFrame
{
    NSInteger vYTopView = 180;
    
    if (DEVICE_IS_IPHONE6) {
        vYTopView = 210;
    }else if(DEVICE_IS_IPHONE6_PLUS)
    {
        vYTopView = 233;
    }else if(!DEVICE_IS_IPHONE5)
    {
        
    }else
    {
        // zhenzhidaole   happybirthday
    }
    
    tbView.frame = CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT);
    imgv_bg.frame = CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, vYTopView);
}


@end
