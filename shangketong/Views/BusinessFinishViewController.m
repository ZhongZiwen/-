//
//  BusinessFinishViewController.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "BusinessFinishViewController.h"
#import "UIView+Common.h"
#import "PerformanceTableViewCell.h"
#import "PerformanceItem.h"
#import "TableHeaderView.h"
#import "InfoPopView.h"

#define kCellIdentifier @"PerformanceTableViewCell"

@interface BusinessFinishViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) InfoPopView *infoPopView;

@property (nonatomic, strong) NSDictionary *chartDict;
@property (nonatomic, strong) NSArray *conditionsArray;
@property (nonatomic, strong) NSMutableArray *sourceArray;

/** 初始化headerView*/
- (UIView*)customTableHeaderView;
@end

@implementation BusinessFinishViewController

#pragma mark - ViewController Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"筛选" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonPress)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    _sourceArray = [NSMutableArray arrayWithCapacity:0];
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"businessFinish-data" ofType:@"json"]];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    for (NSDictionary *tempDict in dict[@"body"][@"entities"]) {
        PerformanceItem *item = [PerformanceItem initWithDictionary:tempDict];
        [_sourceArray addObject:item];
    }
    
    self.chartDict = [NSDictionary dictionaryWithDictionary:dict[@"body"][@"chart"]];
    self.conditionsArray = [NSArray arrayWithArray:dict[@"body"][@"conditions"]];
    
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)rightButtonPress {
    
}

#pragma mark - private method
- (UIView*)customTableHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 0)];
    headerView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    __weak __block typeof(self) weak_self = self;
    TableHeaderView *chartView = [[TableHeaderView alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(headerView.bounds) - 20, 0)];
    chartView.chartType = _type;
    chartView.periodType = _chartDict[@"periodType"];
    chartView.sourceData = _chartDict[@"data"];
    chartView.infoButtonBlock = ^{
        [weak_self.infoPopView showInView:weak_self.tableView];
    };
    [headerView addSubview:chartView];
    
    [headerView setHeight:CGRectGetHeight(chartView.bounds) + 20];
    
    return headerView;
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PerformanceItem *item = _sourceArray[indexPath.row];
    return [PerformanceTableViewCell cellHeightWithItem:item];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PerformanceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    PerformanceItem *item = _sourceArray[indexPath.row];
    [cell configWithItem:item];
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = [self customTableHeaderView];
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView registerClass:[PerformanceTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    }
    return _tableView;
}

- (InfoPopView*)infoPopView {
    if (!_infoPopView) {
        _infoPopView = [[InfoPopView alloc] initWithFrame:CGRectZero];
        _infoPopView.maxWidth = kScreen_Width - 20 - 20 - 37 - 5;
        _infoPopView.titleString = _chartDict[@"name"];
        _infoPopView.detailArray = _conditionsArray;
    }
    return _infoPopView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
