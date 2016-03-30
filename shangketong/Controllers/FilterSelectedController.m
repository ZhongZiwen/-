//
//  FilterSelectedController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "FilterSelectedController.h"
#import "Filter.h"

#define kCellIdentifier @"UITableViewCell"

@interface FilterSelectedController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@end

@implementation FilterSelectedController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    self.title = @"添加筛选项";
    
    UIBarButtonItem *completeBtn = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(completeBtnPress)];
    self.navigationItem.rightBarButtonItem = completeBtn;
    [self.view addSubview:self.tableView];
    [_tableView setEditing:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)completeBtnPress {

    if (self.refreshBlock) {
        self.refreshBlock();
    }
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _selectedArray.count;
    }
    
    return _unSelectedArray.count;
}

// 设置分组标题内容高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 34;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.0f;
}

// 取得当前操作状态，根据不同的状态左侧出现不同的错左按钮
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleInsert;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    Filter *filter;
    if (indexPath.section == 0) {
        filter = _selectedArray[indexPath.row];
    }else {
        filter = _unSelectedArray[indexPath.row];
    }
    cell.textLabel.text = filter.itemName;
    return cell;
}

// 分组的标题名称
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"已添加";
    }
    return @"未添加";
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"移除";
}

// 编辑操作（删除或添加）
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        
        Filter *filter = _unSelectedArray[indexPath.row];
        [_unSelectedArray removeObjectAtIndex:indexPath.row];
        [_selectedArray addObject:filter];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_selectedArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
        [tableView endUpdates];
        
    }else if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Filter *filter = _selectedArray[indexPath.row];
        [_selectedArray removeObjectAtIndex:indexPath.row];
        [_unSelectedArray insertObject:filter atIndex:0];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationRight];
        [tableView endUpdates];
    }
}

// 禁用符合条件cell的reordering功能
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return YES;
    }
    return NO;
}

// 排序（只要实现这个方法在编辑状态右侧就有排序图标）
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [_tableView reloadData];
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
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
