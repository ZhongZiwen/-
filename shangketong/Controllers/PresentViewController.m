//
//  PresentViewController.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PresentViewController.h"
#import "PresentItem.h"

#define kCellIdentifier @"UITableViewCell"

@interface PresentViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *deleteArray;  // 存放被选中的item
@end

@implementation PresentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPress)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(confirmButtonPress)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)backButtonPress {
    [self dismissViewControllerAnimated:YES completion:^{
        for (PresentItem *item in _sourceArray) {
            item.isSelected = NO;
        }
    }];
}

- (void)confirmButtonPress {
    _deleteArray = [NSMutableArray arrayWithCapacity:0];
    __weak __block PresentViewController *copy_self = self;
    for (PresentItem *item in _sourceArray) {
        if (item.isSelected) {
            [self.deleteArray addObject:item];
            if (copy_self.addBlock) {
                copy_self.addBlock(item);
            }
        }
    }
    [self dismissViewControllerAnimated:YES completion:^{
        for (PresentItem *item in copy_self.deleteArray) {
            if (copy_self.deleteBlock) {
                copy_self.deleteBlock(item);
            }
        }
    }];
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    PresentItem *item = _sourceArray[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    cell.textLabel.text = item.m_title;
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", (item.isSelected? @"multi_graph_select" : @"accessory_message_normal")]]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    PresentItem *item = _sourceArray[indexPath.row];
    item.isSelected = !item.isSelected;
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", (item.isSelected? @"multi_graph_select" : @"accessory_message_normal")]]];
    
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
