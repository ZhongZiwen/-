//
//  HighSeaPoolAdvanceSearchViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "HighSeaPoolAdvanceSearchViewController.h"
#import "CommonConstant.h"

@interface HighSeaPoolAdvanceSearchViewController ()<UITableViewDataSource,UITableViewDelegate>{
}
@end

@implementation HighSeaPoolAdvanceSearchViewController

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = kView_BG_Color;
    self.title = @"高级检索";
    
    [self addNarBarView];
    [self initTableview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self.tableviewAdvanceSearch reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark - nar  bar
-(void)addNarBarView{
    UIView *viewNar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 64)];
    viewNar.backgroundColor = [UIColor colorWithHexString:@"0x28303b"];
    [self.view addSubview:viewNar];
    
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBack.frame = CGRectMake(10, 27, 60, 30);
    btnBack.titleLabel.textColor = [UIColor whiteColor];
    btnBack.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [btnBack setTitle:@"返回" forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(backPressed) forControlEvents:UIControlEventTouchUpInside];
    [viewNar addSubview:btnBack];
    
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSearch.frame = CGRectMake(kScreen_Width-70, 27, 60, 30);
    btnSearch.titleLabel.textColor = [UIColor whiteColor];
    btnSearch.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [btnSearch setTitle:@"检索" forState:UIControlStateNormal];
    [btnSearch addTarget:self action:@selector(searchPressed) forControlEvents:UIControlEventTouchUpInside];
    [viewNar addSubview:btnSearch];
}

#pragma mark - 检索按钮事件

-(void)backPressed{
    NSLog(@"back--->");
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)searchPressed{
    NSLog(@"检索-->");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 初始化数据
-(void)initData{
    self.arrayAdvanceSearch = [NSArray arrayWithObjects:@"全部时间",@"今天",@"昨天",@"本周",@"上周",@"本月",@"上月", nil];
    if (self.indexSelected && self.indexSelected > 0 && self.indexSelected < [self.arrayAdvanceSearch count]) {
    }else{
        self.indexSelected = 0;
    }
}


#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewAdvanceSearch = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height) style:UITableViewStyleGrouped];
    self.tableviewAdvanceSearch.delegate = self;
    self.tableviewAdvanceSearch.dataSource = self;
    self.tableviewAdvanceSearch.sectionFooterHeight = 0;
    [self.view addSubview:self.tableviewAdvanceSearch];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewAdvanceSearch setTableFooterView:v];
}


#pragma mark - tableview delegate

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 35.0)];
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 100, 21)];
    labelTitle.font = [UIFont systemFontOfSize:12.0];
    labelTitle.textColor = GROUP_HEAD_TITLE_COLOR;
    labelTitle.text = @"创建时间";
    [headView addSubview:labelTitle];
    return headView;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35.0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.arrayAdvanceSearch) {
        return [self.arrayAdvanceSearch count];
    }
    return 0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.0;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"ClueHighSeaPoolSearchCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    if (self.indexSelected == indexPath.row) {
        cell.accessoryType  = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType  = UITableViewCellAccessoryNone;
    }
    
    [self setContentDetails:cell indexPath:indexPath];
    return cell;
}


-(void)setContentDetails:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath{
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
    
    cell.textLabel.text = [self.arrayAdvanceSearch objectAtIndex:indexPath.row];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.indexSelected = indexPath.row;
    [self.tableviewAdvanceSearch reloadData];
}

@end
