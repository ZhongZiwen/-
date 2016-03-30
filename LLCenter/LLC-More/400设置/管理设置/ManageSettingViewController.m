//
//  ManageSettingViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-13.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "ManageSettingViewController.h"
#import "LLCenterUtility.h"
#import "MoreViewCell.h"
#import "DefaultSettingViewController.h"
#import "TagSettingViewController.h"
#import "DataDictionaryListViewController.h"


@interface ManageSettingViewController ()<UITableViewDataSource,UITableViewDelegate>{
}


@property(strong,nonatomic) UITableView *tableviewManageSetting;
@property(strong,nonatomic) NSArray *arrayData;

@end

@implementation ManageSettingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"管理设置";
    self.view.backgroundColor = COLOR_BG;
    [super customBackButton];
    
    [self initTableview];
    [self.tableviewManageSetting reloadData];
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
    self.tableviewManageSetting = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-64) style:UITableViewStyleGrouped];
    self.tableviewManageSetting.delegate = self;
    self.tableviewManageSetting.dataSource = self;
    self.tableviewManageSetting.sectionFooterHeight = 0;
    
    [self.view addSubview:self.tableviewManageSetting];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewManageSetting setTableFooterView:v];
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
    return 3;
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
    
    if (index.row == 0) {
        cell.imgIcon.image = [UIImage imageNamed:@"icon_default_set.png"];
        cell.labelTitle.text = @"默认设置";
    } else if (index.row == 1) {
        cell.imgIcon.image = [UIImage imageNamed:@"icon_tag.png"];
        cell.labelTitle.text = @"标签设置";
    }else if (index.row == 2) {
        cell.imgIcon.image = [UIImage imageNamed:@"icon_data_dictionary.png"];
        cell.labelTitle.text = @"数据字典";
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger section = indexPath.section;
    
    if (section == 0) {
        if (indexPath.row == 0) {
            [self defaultSettingView];
        }else if (indexPath.row == 1) {
            [self tagSettingView];
        }else if (indexPath.row == 2) {
            [self dataDictionaryView];
        }
    }
}

///默认设置
-(void)defaultSettingView{
    DefaultSettingViewController *dsv = [[DefaultSettingViewController alloc] init];
    [self.navigationController pushViewController:dsv animated:YES];
}

///标签设置
-(void)tagSettingView{
    TagSettingViewController *tsv = [[TagSettingViewController alloc] init];
    [self.navigationController pushViewController:tsv animated:YES];
}


///数据字典
-(void)dataDictionaryView{
    DataDictionaryListViewController *tsv = [[DataDictionaryListViewController alloc] init];
    [self.navigationController pushViewController:tsv animated:YES];
}

@end
