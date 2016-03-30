//
//  SaleTrendViewController.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/7/6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SaleTrendViewController.h"
#import <UIImageView+WebCache.h>
#import "UIView+Common.h"
#import "UIColor+expanded.h"
#import "LineChartView.h"

#define kHeaderHeight               50      // 标题栏的高度

@interface SaleTrendViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *headImageView;   // 用户头像
@property (nonatomic, strong) UILabel *headName;            // 用户名
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIImageView *periodImageView;
@property (nonatomic, strong) UILabel *periodLabel;         // 年份
@property (nonatomic, strong) UILabel *month;               // 月份
@property (nonatomic, strong) UILabel *money;               // 赢单
@property (nonatomic, strong) LineChartView *lineChartView; // 线性图表
@property (nonatomic, strong) NSArray *sourceArray;
@end

@implementation SaleTrendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"筛选" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonItemPress)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    NSString *dataString = @"[{\"periodMonth\":1,\"periodName\":\"2015-01\",\"money\":0,\"count\":0},{\"periodMonth\":2,\"periodName\":\"2015-02\",\"money\":0,\"count\":0},{\"periodMonth\":3,\"periodName\":\"2015-03\",\"money\":0,\"count\":0},{\"periodMonth\":4,\"periodName\":\"2015-04\",\"money\":0,\"count\":0},{\"periodMonth\":5,\"periodName\":\"2015-05\",\"money\":4832,\"count\":3},{\"periodMonth\":6,\"periodName\":\"2015-06\",\"money\":1.11590758E8,\"count\":15},{\"periodMonth\":7,\"periodName\":\"2015-07\",\"money\":2070000,\"count\":4},{\"periodMonth\":8,\"periodName\":\"2015-08\",\"money\":-1,\"count\":0},{\"periodMonth\":9,\"periodName\":\"2015-09\",\"money\":-1,\"count\":0},{\"periodMonth\":10,\"periodName\":\"2015-10\",\"money\":-1,\"count\":0},{\"periodMonth\":11,\"periodName\":\"2015-11\",\"money\":-1,\"count\":0},{\"periodMonth\":12,\"periodName\":\"2015-12\",\"money\":-1,\"count\":0}]";
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    _sourceArray = [NSArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]];
    
    [self.view addSubview:self.tableView];
}
 
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event response
- (void)rightButtonItemPress {
    
}

#pragma mark - Privte Method
- (UIView*)customHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 360)];
    headerView.backgroundColor = [UIColor lightGrayColor];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, kScreen_Width - 20, 340)];
    bgView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:bgView];
    
    [bgView addSubview:self.headImageView];
    [bgView addSubview:self.headName];
    [bgView addSubview:self.lineView];
    [bgView addSubview:self.periodImageView];
    [bgView addSubview:self.periodLabel];
    [bgView addSubview:self.month];
    [bgView addSubview:self.money];
    [bgView addSubview:self.lineChartView];
    [_lineChartView configWithDataSource:_sourceArray];
    [_lineChartView strokeChart];
    
    return headerView;
}

- (NSMutableAttributedString*)getStringWithTitle:(NSString *)title andValue:(NSString *)value{
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", title, value]];
    [attriString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                 NSForegroundColorAttributeName : [UIColor grayColor]}
                         range:NSMakeRange(0, title.length)];
    
    [attriString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                 NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x3bbd79"]}
                         range:NSMakeRange(title.length+1, value.length)];
    return  attriString;
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.tableHeaderView = [self customHeaderView];
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (UIImageView*)headImageView {
    if(!_headImageView) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, kHeaderHeight - 20, kHeaderHeight - 20)];
        NSString *imageStr = @"https://rs.ingageapp.com/upload/i/151745/329692/s_e822aae387324d5b8862245e8e7ecf4c.jpg";
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:nil];
    }
    return _headImageView;
}

- (UILabel*)headName {
    if (!_headName) {
        _headName = [[UILabel alloc] initWithFrame:CGRectMake(kHeaderHeight, 10, kScreen_Width - kHeaderHeight - 30, kHeaderHeight - 20)];
        _headName.font = [UIFont systemFontOfSize:14];
        _headName.textAlignment = NSTextAlignmentLeft;
        _headName.textColor = [UIColor blackColor];
        _headName.text = @"张彬";
    }
    return _headName;
}

- (UIView*)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(10, kHeaderHeight - 0.5, kScreen_Width - 40, 0.5)];
        _lineView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0f];
    }
    return _lineView;
}

- (UIImageView*)periodImageView {
    if (!_periodImageView) {
        UIImage *periodImage = [UIImage imageNamed:@"dashboard_date"];
        _periodImageView = [[UIImageView alloc] initWithImage:periodImage];
        _periodImageView.frame = CGRectMake(10, kHeaderHeight + 10, periodImage.size.width, periodImage.size.height);
    }
    return _periodImageView;
}

- (UILabel*)periodLabel {
    if (!_periodLabel) {
        _periodLabel = [[UILabel alloc] initWithFrame:CGRectMake(_periodImageView.frame.origin.x + CGRectGetWidth(_periodImageView.bounds) + 5, kHeaderHeight, 50, CGRectGetHeight(_periodImageView.bounds) + 20)];
        _periodLabel.backgroundColor = [UIColor whiteColor];
        _periodLabel.font = [UIFont systemFontOfSize:14];
        _periodLabel.textAlignment = NSTextAlignmentLeft;
        _periodLabel.textColor = [UIColor blackColor];
        _periodLabel.text = @"2015";
    }
    return _periodLabel;
}

- (UILabel*)month {
    if (!_month) {
        _month = [[UILabel alloc] initWithFrame:CGRectMake(10, _periodLabel.frame.origin.y + CGRectGetHeight(_periodLabel.bounds), kScreen_Width - 40, 20)];
        _month.textAlignment = NSTextAlignmentLeft;
        _month.attributedText = [self getStringWithTitle:@"月份" andValue:@"2015-07"];
    }
    return _month;
}

- (UILabel*)money {
    if (!_money) {
        _money = [[UILabel alloc] initWithFrame:CGRectMake(10, _month.frame.origin.y + CGRectGetHeight(_month.bounds), kScreen_Width - 40, 20)];
        _money.textAlignment = NSTextAlignmentLeft;
        _money.attributedText = [self getStringWithTitle:@"赢单" andValue:@"60,000元/2个"];
    }
    return _money;
}

- (LineChartView*)lineChartView {
    if (!_lineChartView) {
        _lineChartView = [[LineChartView alloc] initWithFrame:CGRectMake(0, 340 - 210, kScreen_Width - 20, 210)];
        
    }
    return _lineChartView;
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
