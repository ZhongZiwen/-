//
//  CustomerStatusListController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/3.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CustomerStatusListController.h"
#import "NameIdModel.h"
#import "Customer.h"

#define kCellIdentifier @"UITableViewCell"

@interface CustomerStatusListController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSIndexPath *preIndexPath;
@property (strong, nonatomic) NameIdModel *status;
@end

@implementation CustomerStatusListController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(leftButtonPress)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"保存" target:self action:@selector(rightButtonPress)];
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _sourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_Common_ChangeCustomerStatus_WithBlock:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            for (NSDictionary *tempDict in data[@"customerStates"]) {
                NameIdModel *item = [NSObject objectOfClass:@"NameIdModel" fromJSON:tempDict];
                [_sourceArray addObject:item];
            }
            [_tableView reloadData];
        }else {
            
        }
        [self.view configBlankPageWithTitle:@"暂无状态数据" hasData:_sourceArray.count hasError:error != nil reloadButtonBlock:nil];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)leftButtonPress {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonPress {
    
    if (self.valueBlock) {
        self.valueBlock(_status);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    NameIdModel *item = _sourceArray[indexPath.row];
    cell.textLabel.text = item.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _status = _sourceArray[indexPath.row];
    
    self.preIndexPath = indexPath;
}

- (void)setPreIndexPath:(NSIndexPath *)preIndexPath {
    if (_preIndexPath == preIndexPath)
        return;
    
    if (_preIndexPath) {
        UITableViewCell *preCell = [_tableView cellForRowAtIndexPath:_preIndexPath];
        preCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    _preIndexPath = preIndexPath;
    
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:_preIndexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
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
