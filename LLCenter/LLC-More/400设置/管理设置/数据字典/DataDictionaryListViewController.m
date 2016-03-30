//
//  DataDictionaryListViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-19.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "DataDictionaryListViewController.h"
#import "LLCenterUtility.h"
#import "MoreViewCell.h"
#import "DataDictionaryDetailViewController.h"

@interface DataDictionaryListViewController ()<UITableViewDataSource,UITableViewDelegate>{
}

@property(strong,nonatomic) UITableView *tableview;
@property(strong,nonatomic) NSArray *arrayData;

@end

@implementation DataDictionaryListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"数据字典";
    self.view.backgroundColor = COLOR_BG;
    [super customBackButton];
    
    [self initTableview];
    [self.tableview reloadData];
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
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-64) style:UITableViewStyleGrouped];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.sectionFooterHeight = 0;
    
    [self.view addSubview:self.tableview];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableview setTableFooterView:v];
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
    return 4;
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
        cell.imgIcon.image = [UIImage imageNamed:@"icon_data_dictionary_customer.png"];
        cell.labelTitle.text = @"客户";
    } else if (index.row == 1) {
        cell.imgIcon.image = [UIImage imageNamed:@"icon_data_dictionary_linkman.png"];
        cell.labelTitle.text = @"联系人";
    }else if (index.row == 2) {
        cell.imgIcon.image = [UIImage imageNamed:@"icon_data_dictionary_sale.png"];
        cell.labelTitle.text = @"销售";
    }else if (index.row == 3) {
        cell.imgIcon.image = [UIImage imageNamed:@"icon_data_dictionary_afterservice.png"];
        cell.labelTitle.text = @"售后";
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger section = indexPath.section;
    
    if (section == 0) {
        NSInteger type = -1;
        if (indexPath.row == 0) {
            type = 1;
        }else if (indexPath.row == 1) {
            type = 2;
        }else if (indexPath.row == 2) {
            type = 3;
        }else if (indexPath.row == 3) {
            type = 4;
        }
        [self gotoDataDictionaryView:type];
    }
}

///数据字典  1 客户 2 联系人 3 销售 4 售后 
-(void)gotoDataDictionaryView:(NSInteger)viewType{
    DataDictionaryDetailViewController *ddv = [[DataDictionaryDetailViewController alloc] init];
    ddv.viewType = viewType;
    [self.navigationController pushViewController:ddv animated:YES];
}





@end
