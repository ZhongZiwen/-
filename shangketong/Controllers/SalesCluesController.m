//
//  SalesCluesController.m
//  shangketong
//
//  Created by 蒋 on 15/9/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SalesCluesController.h"
#import "AFNHttp.h"
#import "SalesLeadsCell.h"
#import "CommonDetailViewController.h"
#import "Select_Table_View.h"

@interface SalesCluesController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataSourceArray;//数据源

@end

@implementation SalesCluesController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableViewClue setTableFooterView:v];
    
    _dataSourceArray = [NSMutableArray arrayWithCapacity:0];
    [self customNavRightItem];
    [self getDataSourceFromSever];
    // Do any additional setup after loading the view from its nib.
}
#pragma mark - custom Nar
- (void)customNavRightItem {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(AddOneSaleLeads)];
    self.navigationItem.rightBarButtonItem = rightItem;
}
- (void)AddOneSaleLeads {
    NSArray *array = @[@"名片扫描", @"手工输入"];
    Select_Table_View *selectView = [[Select_Table_View alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) dataArray:array];
    
    __weak typeof(self) weak_self = self;
    selectView.BackIndexBlock = ^(NSInteger index) {
        //根据返回不同的下标进行不同的事件处理
        [weak_self pushDifferenceController:index];
    };
    __weak typeof(selectView) weak_selectView = selectView;
    selectView.RemoveViewBlock = ^(){
        //移除视图
        [weak_selectView removeFromSuperview];
    };
    selectView.backgroundColor = [UIColor clearColor];
    [self.view.window addSubview:selectView];
}
- (void)pushDifferenceController:(NSInteger)index {
    switch (index) {
        case 0:
            NSLog(@"我是第%ld行", index);
            break;
        case 1:
            NSLog(@"我是第%ld行", index);
            break;
        case 2:
            NSLog(@"我是第%ld行", index);
            break;
        case 3:
            NSLog(@"我是第%ld行", index);
            break;
        case 4:
            NSLog(@"我是第%ld行", index);
            break;
        default:
            break;
    }
}

#pragma mark - table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataSourceArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SalesLeadsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SalesLeadsCellIdentifier"];
    if (!cell) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SalesLeadsCell" owner:self options:nil];
        cell = (SalesLeadsCell *)[array objectAtIndex:0];
        [cell awakeFromNib];
        [cell setFrameForAllPhones];
    }
    NSDictionary *dict = _dataSourceArray[indexPath.row];
    [cell initWithDictionary:dict];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CommonDetailViewController *controller = [[CommonDetailViewController alloc] init];
    controller.typeOfDetail = 4;
    [self.navigationController pushViewController:controller animated:YES];
}
- (void)getDataSourceFromSever {
    NSMutableDictionary *parmas = [NSMutableDictionary dictionary];
    [parmas setObject:@"" forKey:@"id"];
    [parmas setObject:@"0" forKey:@"type"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP, GET_CAMPAIGN_DETAILS_SALELEADS] params:parmas success:^(id responseObj) {
        NSLog(@"%@", responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            if ([responseObj safeObjectForKey:@"saleLeads"]) {
                [_dataSourceArray addObjectsFromArray:[responseObj objectForKey:@"saleLeads"]];
            }
        }
        [_tableViewClue reloadData];
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
