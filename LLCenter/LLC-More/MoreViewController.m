//
//  MoreViewController.m
//  lianluozhongxin
//
//  Created by Vescky on 14-6-16.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "MoreViewController.h"
#import "HomePageViewController.h"
#import "ReportViewController.h"
#import "Setting400ViewController.h"
#import "ChargingViewController.h"
#import "LLCSettingViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "MoreViewCell.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"
#import "CommonStaticVar.h"

@interface MoreViewController ()<UITableViewDataSource,UITableViewDelegate> {
    ///是否显示版本栏
    BOOL isShowVersion;
}
@end

@implementation MoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tabBarController.navigationItem.title = @"更多";
    self.view.backgroundColor = COLOR_BG;
     
//    self.tableViewMore.backgroundColor = [UIColor clearColor];
    self.tableViewMore.frame = CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-110);
    self.tableViewMore.showsVerticalScrollIndicator = NO;
    if ([[CommonStaticVar getShowVersionView] isEqualToString:@"show"]) {
        isShowVersion = TRUE;
    }else{
        isShowVersion = FALSE;
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableViewMore reloadData];
    self.tabBarController.navigationItem.rightBarButtonItems = nil;
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    ///判断是否有权限 是否为普通用户
    if ([[CommonStaticVar getAccountType] isEqualToString:@"boss"]) {
        return 2;
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ///判断是否有权限 是否为普通用户
    if ([[CommonStaticVar getAccountType] isEqualToString:@"boss"]) {
        if (section == 0) {
            return 3;
        }else if (section == 1)
        {
            return 1;
        }
    }else{
        if (section == 0) {
            return 1;
        }
    }
    return 0;
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

    ///判断是否有权限 是否为普通用户
    if ([[CommonStaticVar getAccountType] isEqualToString:@"boss"]) {
        if (section == 0) {
            if (index.row == 0) {
                cell.imgIcon.image = [UIImage imageNamed:@"more_menu_report.png"];
                cell.labelTitle.text = @"统计报表";
            } else if (index.row == 1) {
                cell.imgIcon.image = [UIImage imageNamed:@"icon_charge_center.png"];
                cell.labelTitle.text = @"计费中心";
            } else if (index.row == 2) {
                cell.imgIcon.image = [UIImage imageNamed:@"icon_400_seting.png"];
                cell.labelTitle.text = @"400设置";
            }

        }else if (section == 1)
        {
            if (index.row == 0) {
                cell.imgIcon.image = [UIImage imageNamed:@"more_menu_setting.png"];
                cell.labelTitle.text = @"设置";
            }
        }
    }else{
       if (section == 0)
        {
            if (index.row == 0) {
                cell.imgIcon.image = [UIImage imageNamed:@"more_menu_setting.png"];
                cell.labelTitle.text = @"设置";
            }
        }
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger section = indexPath.section;

    ///判断是否有权限 是否为普通用户
    if ([[CommonStaticVar getAccountType] isEqualToString:@"boss"]) {
        if (section == 0) {
            if (indexPath.row == 0) {
                [self calllistView];
            } else if (indexPath.row == 1) {
                [self chargingView];
            }else if (indexPath.row == 2) {
                [self setting400View];
            }
            
        }else if (section == 1)
        {
            if (indexPath.row == 0) {
                [self settingView];
            }
        }
    }else{
        if (section == 0)
        {
            if (indexPath.row == 0) {
                [self settingView];
            }
        }
    }
    
}


///报表系统
-(void)calllistView{
    ReportViewController *rVc = [[ReportViewController alloc] init];
    [self.tabBarController.navigationController pushViewController:rVc animated:YES];
}

///计费中心
-(void)chargingView{
    ChargingViewController *rVc = [[ChargingViewController alloc] init];
    [self.tabBarController.navigationController pushViewController:rVc animated:YES];
}

///400设置
-(void)setting400View{
    Setting400ViewController *rVc = [[Setting400ViewController alloc] init];
    [self.tabBarController.navigationController pushViewController:rVc animated:YES];

}


///版本
-(void)versionView{
//    VersionViewController *vVc = [[VersionViewController alloc] init];
//    [self.tabBarController.navigationController pushViewController:vVc animated:YES];
}


///意见
-(void)feedbackView{
//    FeedbackViewController *fVc = [[FeedbackViewController alloc] init];
//    [self.tabBarController.navigationControllerr pushViewController:fVc animated:YES];
}

///关于
-(void)aboutView{
//    AboutUsViewController *aVc = [[AboutUsViewController alloc] init];
//    [self.tabBarController.navigationController pushViewController:aVc animated:YES];
}

///账户
-(void)accountView{
    HomePageViewController *cbViewController = [[HomePageViewController alloc] init];
    [self.tabBarController.navigationController pushViewController:cbViewController animated:YES];
}

///设置
-(void)settingView{
    LLCSettingViewController *sVc = [[LLCSettingViewController alloc] init];
    [self.tabBarController.navigationController pushViewController:sVc animated:YES];
}

@end
