//
//  SortNavigationSeatsViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-27.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "SortNavigationSeatsViewController.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"
#import "CommonStaticVar.h"
#import "CustomPopView.h"
#import "EditNavigationSeatCell.h"
#import "SortNavigationSitCell.h"

@interface SortNavigationSeatsViewController ()<UITableViewDataSource,UITableViewDelegate>{
    
}

@property(strong,nonatomic) UITableView *tableview;
@property(strong,nonatomic) NSMutableArray *dataSource;

@end

@implementation SortNavigationSeatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"排序";
    [super customBackButton];
    self.view.backgroundColor = COLOR_BG;
    [self initData];
    [self addNavBar];
    [self initTableview];
    [self.tableview reloadData];
}


#pragma mark - Nav Bar
-(void)addNavBar{
    [super customBackButton];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonPress)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
}

#pragma mark-  保存事件
-(void)saveButtonPress {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (![CommonFunc checkNetworkState]) {
        [CommonFuntion showToast:@"无网络可用,加载失败" inView:self.view];
        return;
    }
    
    ///发送请求
    [self sortSeats];
}



#pragma mark - 初始化数据
-(void)initData{
    self.dataSource = [[NSMutableArray alloc] init];
    if (self.dataSourceOld) {
        [self.dataSource addObjectsFromArray:self.dataSourceOld];
    }
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
    
    [self.tableview setEditing:YES animated:YES];

}



#pragma mark - tableview delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
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
    /*
    ///座席
    EditNavigationSeatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditNavigationSeatCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"EditNavigationSeatCell" owner:self options:nil];
        cell = (EditNavigationSeatCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
        [cell setCellFrame:2];
    }
    NSDictionary *item = [self.dataSource objectAtIndex:indexPath.row];
    
    [cell setCellDetail:item withIndexPath:indexPath];
    */
    
    SortNavigationSitCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SortNavigationSitCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SortNavigationSitCell" owner:self options:nil];
        cell = (SortNavigationSitCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    NSDictionary *item = [self.dataSource objectAtIndex:indexPath.row];
    [cell setCellDetails:item];
    
    return cell;
}



// 排序（只要实现这个方法在编辑状态右侧就有排序图标）
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [self.dataSource exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    [self.tableview reloadData];
}

// 符合条件cell的reordering功能
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// 取得当前操作状态，根据不同的状态左侧出现不同的错左按钮
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewCellEditingStyleNone;
}



#pragma mark - 网络请求
-(void)sortSeats{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    NSDictionary *item;
    NSMutableString *strSeatIds = [[NSMutableString alloc] init];
    for (int i=0; i<[self.dataSource count]; i++) {
        item = [self.dataSource objectAtIndex:i];
        if ([strSeatIds isEqualToString:@""]) {
            [strSeatIds appendString:[item safeObjectForKey:@"SITID"]];
        }else{
            [strSeatIds appendString:@","];
            [strSeatIds appendString:[item safeObjectForKey:@"SITID"]];
        }
        
    }
    [rDict setValue:self.navitaionId forKey:@"navigationId"];
    [rDict setValue:strSeatIds forKey:@"seatIds"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_SORT_NAVIGATION_SIT_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"坐席排序jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [CommonFuntion showToast:@"排序成功" inView:self.view];
            [self actionSuccess];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self sortSeats];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"保存失败";
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
    if (self.NotifyNavigationSitList) {
        self.NotifyNavigationSitList(self.dataSource);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
