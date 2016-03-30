//
//  ApprovalStatusListController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ApprovalStatusListController.h"
#import "ApprovalStatusListCell.h"

#define kCellIdentifier @"ApprovalStatusListCell"

@interface ApprovalStatusListController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ApprovalStatusListController

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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ApprovalStatusListCell cellHeightWithDictionary:_sourceArray[indexPath.row]];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ApprovalStatusListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    NSDictionary *tempDict = _sourceArray[indexPath.row];
    [cell configWithDictionary:tempDict];
    return cell;
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[ApprovalStatusListCell class] forCellReuseIdentifier:kCellIdentifier];
        
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
