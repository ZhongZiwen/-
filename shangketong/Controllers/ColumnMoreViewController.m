//
//  ColumnMoreViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ColumnMoreViewController.h"
#import "ColumnModel.h"

#define kCellIdentifier @"UITableViewCell"

@interface ColumnMoreViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *unselectedArray;
@end

@implementation ColumnMoreViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    self.title = @"添加更多条目";
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPress)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(confirmButtonPress)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (ColumnModel *tempItem in _sourceArray) {
        if ([tempItem.showWhenInit isEqualToNumber:@1]) {
            [tempArray addObject:tempItem];
        }
    }
    _unselectedArray = tempArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)backButtonPress {
    for (ColumnModel *tempItem in _unselectedArray) {
        tempItem.showWhenInit = @1;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)confirmButtonPress {
    if (self.confireBlock) {
        self.confireBlock();
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _unselectedArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    ColumnModel *item = _unselectedArray[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    cell.textLabel.text = item.name;
    if ([item.showWhenInit isEqualToNumber:@1]) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_message_normal"]];
    }
    else {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"multi_graph_select"]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ColumnModel *item = _unselectedArray[indexPath.row];
    item.showWhenInit = @(![item.showWhenInit integerValue]);
    
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
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
