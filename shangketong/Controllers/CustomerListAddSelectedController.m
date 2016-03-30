//
//  CustomerListAddSelectedController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/3.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CustomerListAddSelectedController.h"
#import "Customer.h"
#import "CustomerTableViewCell.h"

#define kCellIdentifier @"CustomerTableViewCell"

@interface CustomerListAddSelectedController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@end

@implementation CustomerListAddSelectedController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    return [CustomerTableViewCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    Customer *item = _sourceArray[indexPath.row];
    [cell configWithModel:item];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", item.isSelected ? @"tenant_agree_selected" : @"tenant_agree"]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Customer *item = _sourceArray[indexPath.row];
    item.isSelected = !item.isSelected;
    
    if (self.refleshBlock) {
        self.refleshBlock(item);
    }
    
    CustomerTableViewCell *cell = (CustomerTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", item.isSelected ? @"tenant_agree_selected" : @"tenant_agree"]]];
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[CustomerTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        _tableView.tableFooterView = [[UIView alloc] init];
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
