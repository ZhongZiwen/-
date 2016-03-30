//
//  DashboardViewController.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "DashboardViewController.h"
#import "UIViewController+NavDropMenu.h"
#import "ChartItem.h"
#import "BusinessFinishViewController.h"
#import "OpportunityViewController.h"
#import "ActivityViewController.h"
#import "PerformanceViewController.h"
#import "FunnelViewController.h"

#define kCellIdentifier @"UITableViewCell"

@interface DashboardViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *sourceArray;
@end

@implementation DashboardViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    [self customDownMenuWithType:TableViewCellTypeDefault andSource:@[@"全部仪表盘", @"绩效仪表盘", @"行为仪表盘", @"客户分析"] andDefaultIndex:0 andBlock:^(NSInteger index) {
        
    }];
    
    _sourceArray = [NSMutableArray arrayWithCapacity:0];
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dashboard_list" ofType:@"json"]];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    for (NSDictionary *tempDict in dict[@"body"][@"charts"]) {
        ChartItem *item = [ChartItem initWithDictionary:tempDict];
        [_sourceArray addObject:item];
    }
    
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    ChartItem *item = _sourceArray[indexPath.row];
    switch ([item.m_type integerValue]) {
        case 1001:
            cell.imageView.image = [UIImage imageNamed:@"dashboard_BusinessFinish"];
            break;
        case 1002:
            cell.imageView.image = [UIImage imageNamed:@"dashboard_Opportunity"];
            break;
        case 1003:
            cell.imageView.image = [UIImage imageNamed:@"dashboard_Performance"];
            break;
        case 1004:
            cell.imageView.image = [UIImage imageNamed:@"dashboard_Funnel"];
            break;
        case 1005:
        case 1006:
        case 1007:
            cell.imageView.image = [UIImage imageNamed:@"dashboard_Activity"];
            break;
        default:
            break;
    }
    cell.textLabel.text = item.m_name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ChartItem *item = _sourceArray[indexPath.row];
    switch ([item.m_type integerValue]) {
        case 1001: {
            BusinessFinishViewController *businessController = [[BusinessFinishViewController alloc] init];
            businessController.title = item.m_name;
            businessController.type = [item.m_type integerValue];
            [self.navigationController pushViewController:businessController animated:YES];
        }
            break;
        case 1002: {
//            OpportunityViewController *opportunityController = [[OpportunityViewController alloc] init];
//            opportunityController.title = item.m_name;
//            opportunityController.type = [item.m_type integerValue];
//            [self.navigationController pushViewController:opportunityController animated:YES];
        }
            break;
            break;
        case 1003: {
            PerformanceViewController *performanceController = [[PerformanceViewController alloc] init];
            performanceController.title = item.m_name;
            performanceController.type = [item.m_type integerValue];
            [self.navigationController pushViewController:performanceController animated:YES];
        }
            break;
        case 1004: {
            FunnelViewController *funnelController = [[FunnelViewController alloc] init];
            funnelController.title = item.m_name;
            funnelController.type = [item.m_type integerValue];
            [self.navigationController pushViewController:funnelController animated:YES];
        }
            break;
        case 1005:
        case 1006:
        case 1007: {
            ActivityViewController *activityController = [[ActivityViewController alloc] init];
            activityController.title = item.m_name;
            activityController.type = [item.m_type integerValue];
            [self.navigationController pushViewController:activityController animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    }
    return _tableView;
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
