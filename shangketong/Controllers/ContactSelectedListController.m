//
//  ContactSelectedListController.m
//  shangketong
//
//  Created by sungoin-zbs on 16/1/5.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import "ContactSelectedListController.h"
#import "Contact.h"
#import "ContactTableViewCell.h"

#define kCellIdentifier @"ContactTableViewCell"

@interface ContactSelectedListController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@end

@implementation ContactSelectedListController

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
    return [ContactTableViewCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    Contact *item = _sourceArray[indexPath.row];
    [cell configWithoutSWWithItem:item];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", item.isSelected ? @"tenant_agree_selected" : @"tenant_agree"]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Contact *item = _sourceArray[indexPath.row];
    item.isSelected = !item.isSelected;
    
    if (self.refreshBlock) {
        self.refreshBlock(item);
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
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
