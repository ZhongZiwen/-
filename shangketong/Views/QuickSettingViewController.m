//
//  QuickSettingViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "QuickSettingViewController.h"
#import "Quick.h"
#import "QuickGroup.h"
#import "FMDBManagement.h"

#define kCellIdentifier @"UITableViewCell"

@interface QuickSettingViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

// 获取数据库中数据
- (void)getDataSourceFromSQL;
@end

@implementation QuickSettingViewController

- (void)loadView {
    [super loadView];
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"设置快捷操作";
    self.view.backgroundColor = kView_BG_Color;
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"完成" target:self action:@selector(completeBtnPress)];
    
    _dataSource = [[NSMutableArray alloc] initWithCapacity:2];
    NSMutableArray *tempArray = [[FMDBManagement sharedFMDBManager] getQuickDataSource];
    NSMutableArray *selectedArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableArray  *unSelectedArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (Quick *tempItem in tempArray) {
        if ([tempItem.isSelected isEqualToNumber:@1]) {
            [selectedArray addObject:tempItem];
        }
        else {
            [unSelectedArray addObject:tempItem];
        }
    }
    QuickGroup *quickGroup = [QuickGroup initWithName:[NSString stringWithFormat:@"已选择%d/5", selectedArray.count] andQuickArray:selectedArray];
    [_dataSource addObject:quickGroup];
    quickGroup = [QuickGroup initWithName:@"未选择" andQuickArray:unSelectedArray];
    [_dataSource addObject:quickGroup];
    
    [self.tableView setEditing:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)completeBtnPress {
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
    QuickGroup *firstGroup = _dataSource.firstObject;
    QuickGroup *lastGroup = _dataSource.lastObject;
    [tempArray addObjectsFromArray:firstGroup.quickArray];
    [tempArray addObjectsFromArray:lastGroup.quickArray];
    
    [[FMDBManagement sharedFMDBManager] casheQuickWithArray:tempArray];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    QuickGroup *group = _dataSource[section];
    return group.quickArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    //    if (indexPath.section == 0) {
    //        cell.showsReorderControl = YES;
    //    }else{
    //        cell.showsReorderControl = NO;
    //    }
    QuickGroup *group = _dataSource[indexPath.section];
    Quick *quick = group.quickArray[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"today_quick_icon_%@", quick.imageString]];
    cell.textLabel.text = quick.titleString;
    return cell;
}

// 分组的标题名称
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    QuickGroup *group = _dataSource[section];
    return group.groupName;
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"移除";
}

// 编辑操作（删除或添加）
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QuickGroup *group = _dataSource[indexPath.section];
    Quick *quick = group.quickArray[indexPath.row];
    
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        
        QuickGroup *selectGroup = _dataSource[0];
        if (selectGroup.quickArray.count == 5) {
            kShowHUD(@"最多选择5个快捷操作");
            return;
        }
        
        QuickGroup *firstGroup = _dataSource[0];
        quick.isSelected = @1;
        [firstGroup.quickArray addObject:quick];
        firstGroup.groupName = [NSString stringWithFormat:@"已选择%d/5", firstGroup.quickArray.count];
        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:firstGroup.quickArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [tableView endUpdates];

        [group.quickArray removeObjectAtIndex:indexPath.row];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [tableView endUpdates];
        
    }else if (editingStyle == UITableViewCellEditingStyleDelete){
        
        [group.quickArray removeObjectAtIndex:indexPath.row];
        group.groupName = [NSString stringWithFormat:@"已选择%d/5", group.quickArray.count];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [tableView endUpdates];
        
        QuickGroup *secondGroup = _dataSource[1];
        quick.isSelected = @0;
        [secondGroup.quickArray insertObject:quick atIndex:0];
        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationBottom];
        [tableView endUpdates];
    }
    
    [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
}

// 排序（只要实现这个方法在编辑状态右侧就有排序图标）
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.section == destinationIndexPath.section) {
        QuickGroup *group = _dataSource[0];
        [group.quickArray exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
//        [_tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
        return;
    }
    
    QuickGroup *sourceGroup = _dataSource[sourceIndexPath.section];
    Quick *sourceQuick = sourceGroup.quickArray[sourceIndexPath.row];
    
    if ([sourceQuick.titleString isEqualToString:@"发布动态"]) {
        [_tableView reloadData];
        return;
    }
    
    QuickGroup *destinationGroup = _dataSource[destinationIndexPath.section];
    sourceQuick.isSelected = @0;
    [sourceGroup.quickArray removeObjectAtIndex:sourceIndexPath.row];
    [destinationGroup.quickArray insertObject:sourceQuick atIndex:0];
    sourceGroup.groupName = [NSString stringWithFormat:@"已选择%d/5", sourceGroup.quickArray.count];
    [_tableView reloadData];
}

// 禁用符合条件cell的reordering功能
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return YES;
    }
    return NO;
}

// 取得当前操作状态，根据不同的状态左侧出现不同的错左按钮
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return UITableViewCellEditingStyleNone;
        }
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleInsert;
}

#pragma mark - UITableViewDelegate
// 设置分组标题内容高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 34;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0f;
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
