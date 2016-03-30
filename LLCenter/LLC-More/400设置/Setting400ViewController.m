//
//  Setting400ViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-12.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "Setting400ViewController.h"
#import "LLCenterUtility.h"
#import "MoreViewCell.h"
#import "NavigationSettingViewController.h"
#import "NavigationNoIVRSeatSettingViewController.h"
#import "RingListViewController.h"
#import "NoAnswerViewController.h"
#import "OutCallLineViewController.h"
#import "BlackWhiteListViewController.h"
#import "ManageSettingViewController.h"
#import "CommonStaticVar.h"


@interface Setting400ViewController ()<UITableViewDataSource,UITableViewDelegate>{
    ///ivrStatus(ivr是否开通：1-是，0-否)
    ///ringStatus(彩铃是否开通：1-是，0-否)
    ///ringtoneStatus (炫铃是否开通：1-是，0-否)
    NSInteger ivrStatus;
    NSInteger ringStatus;
    NSInteger ringtoneStatus;
}


@property(strong,nonatomic) UITableView *tableviewSetting400;
@property(strong,nonatomic) NSArray *arrayData;

@end

@implementation Setting400ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"400设置";
    self.view.backgroundColor = COLOR_BG;
    [super customBackButton];
    
    ivrStatus = 0;
    ringStatus = 0;
    ringtoneStatus = 0;
    
    [self initTableview];
    [self.tableviewSetting400 reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getJurisdictionStatus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 初始化数据
-(void)initData{
    
}

#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewSetting400 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-64) style:UITableViewStyleGrouped];
    self.tableviewSetting400.delegate = self;
    self.tableviewSetting400.dataSource = self;
    self.tableviewSetting400.sectionFooterHeight = 0;
    
    [self.view addSubview:self.tableviewSetting400];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewSetting400 setTableFooterView:v];
}


#pragma mark- tableview
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc] init];
    headView.backgroundColor = COLOR_BG;
    return headView;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footView = [[UIView alloc] init];
    footView.backgroundColor = COLOR_BG;
    return footView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MoreViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MoreViewCelllIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MoreViewCell" owner:self options:nil];
        cell = (MoreViewCell*)[array objectAtIndex:0];
    }
    
    //    [cell setCellViewFrame];
    
    cell.clipsToBounds = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectedBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    cell.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    
    [self setContentValue:cell forCurIndex:indexPath];
    
    return cell;
}

// cell  详情
-(void)setContentValue:(MoreViewCell *)cell forCurIndex:(NSIndexPath *)index
{
    NSInteger section = index.section;
    
    cell.imgNoticeIcon.hidden = YES;
    
//    if (index.row == 0) {
//        cell.imgIcon.image = [UIImage imageNamed:@"icon_navigation_set.png"];
//        cell.labelTitle.text = @"导航设置";
//    } else
//        
    if (index.row == 0) {
        cell.imgIcon.image = [UIImage imageNamed:@"more_icon_whiteblack.png"];
        cell.labelTitle.text = @"黑白名单";
    }else if (index.row == 1) {
        cell.imgIcon.image = [UIImage imageNamed:@"more_icon_outcall.png"];
        cell.labelTitle.text = @"外呼线路";
    }else if (index.row == 2) {
        cell.imgIcon.image = [UIImage imageNamed:@"more_icon_noanswer_sms.png"];
        cell.labelTitle.text = @"漏挂短信";
    }else if (index.row == 3) {
        cell.imgIcon.image = [UIImage imageNamed:@"icon_ring.png"];
        cell.labelTitle.text = @"炫铃设置";
    }else if (index.row == 4) {
        cell.imgIcon.image = [UIImage imageNamed:@"icon_manage_set.png"];
        cell.labelTitle.text = @"管理设置";
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger section = indexPath.section;
    
    if (section == 0) {
//        if (indexPath.row == 0) {
//            ///ivr开通
////            if (ivrStatus== 1) {
////                [self navigationSettingView];
////            }else{
////                [self navigationNoIVRSettingView];
////            }
//        }else
//            
        
        if(indexPath.row == 0) {
            [self blackandWhiteListView];
        }else if (indexPath.row == 1) {
            [self outCallView];
        }else if (indexPath.row == 2) {
            [self noAnswerMsgView];
        }else if (indexPath.row == 3) {
            ///ringtoneStatus (炫铃是否开通：1-是，0-否)
            if ([CommonStaticVar getRingtoneStatus] == 1) {
                [self ringSettingView];
            }else{
                [CommonFuntion showToast:@"您尚未开通炫铃" inView:self.view];
            }
        }else if (indexPath.row == 4) {
            [self manageSettingView];
        }
    }
}


///黑白名单
-(void)blackandWhiteListView{
    BlackWhiteListViewController *rVc = [[BlackWhiteListViewController alloc] init];
    [self.navigationController pushViewController:rVc animated:YES];
}

///外呼线路
-(void)outCallView{
    OutCallLineViewController *rVc = [[OutCallLineViewController alloc] init];
    [self.navigationController pushViewController:rVc animated:YES];
}

///漏挂短信
-(void)noAnswerMsgView{
    NoAnswerViewController *rVc = [[NoAnswerViewController alloc] init];
    [self.navigationController pushViewController:rVc animated:YES];
}

///炫铃设置
-(void)ringSettingView{
    RingListViewController *rVc = [[RingListViewController alloc] init];
    [self.navigationController pushViewController:rVc animated:YES];
}

///管理设置
-(void)manageSettingView{
    ManageSettingViewController *rVc = [[ManageSettingViewController alloc] init];
    [self.navigationController pushViewController:rVc animated:YES];
}

///导航设置
-(void)navigationSettingView{
    NavigationSettingViewController *rVc = [[NavigationSettingViewController alloc] init];
    rVc.navigationId = @"";
    [self.navigationController pushViewController:rVc animated:YES];
}


///导航设置
-(void)navigationNoIVRSettingView{
    NavigationNoIVRSeatSettingViewController *rVc = [[NavigationNoIVRSeatSettingViewController alloc] init];
    rVc.ringStatus = ringStatus;
    [self.navigationController pushViewController:rVc animated:YES];
}

#pragma mark - 获取用户开通权限状态
-(void)getJurisdictionStatus{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_IVR_STATUS_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"获取用户开通权限状态:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            if ([jsonResponse objectForKey:@"resultMap"]) {
                ///ivrStatus(ivr是否开通：1-是，0-否)
                ///ringStatus(彩铃是否开通：1-是，0-否)
                ///ringtoneStatus (炫铃是否开通：1-是，0-否)
                /*
                 resultMap =     {
                 ivrStatus = 1;
                 ringStatus = 0;
                 };
                 */
                
                NSDictionary *resultMap = [jsonResponse objectForKey:@"resultMap"];
                
                ///ivr是否开通：1-是，0-否
                ivrStatus = 0;
                if ([resultMap objectForKey:@"ivrStatus"]) {
                    ivrStatus = [[resultMap safeObjectForKey:@"ivrStatus"] integerValue];
                }
                
                ///彩铃是否开通：1-是，0-否
                ringStatus = 0;
                if ([resultMap objectForKey:@"ringStatus"]) {
                    ringStatus = [[resultMap safeObjectForKey:@"ringStatus"] integerValue];
                }
                
                ///炫铃是否开通：1-是，0-否
                ringtoneStatus = 0;
                if ([resultMap objectForKey:@"ringtoneStatus"]) {
                    ringtoneStatus = [[resultMap safeObjectForKey:@"ringtoneStatus"] integerValue];
                }
                
            }else{
                NSLog(@"data------>:<null>");
                [CommonFuntion showToast:@"加载异常" inView:self.view];
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getJurisdictionStatus];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"获取失败";
            }
            
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
    
}



@end
