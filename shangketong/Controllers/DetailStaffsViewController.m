//
//  DetailStaffsViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "DetailStaffsViewController.h"
#import "DetailStaffModel.h"
#import "DetailStaffCell.h"
#import "DetailStaffExpandCell.h"
#import "AddressBook.h"
#import "ExportAddressViewController.h"
#import "Code.h"
#import "InfoViewController.h"

#define kCellIdentifier @"DetailStaffCell"
#define kCellIdentifier_expand @"DetailStaffExpandCell"

@interface DetailStaffsViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *ownerArray;
@property (strong, nonatomic) NSMutableArray *othersArray;
@property (assign, nonatomic) BOOL isExpand;
@property (assign, nonatomic) NSInteger expandIndex;
@end

@implementation DetailStaffsViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    if ([_editCode.status isEqualToNumber:@0]) {
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"添加成员" target:self action:@selector(rightButtonItemPress)];
    }
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _ownerArray = [[NSMutableArray alloc] initWithCapacity:0];
    _othersArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (DetailStaffModel *tempItem in _sourceArray) {
        if ([tempItem.staffLevel integerValue] == 1) {
            [_ownerArray addObject:tempItem];
        }else {
            [_othersArray addObject:tempItem];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)rightButtonItemPress {
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
    for (DetailStaffModel *tempItem in _sourceArray) {
        AddressBook *item = [AddressBook initWithStaff:tempItem];
        [tempArray addObject:item];
    }
    
    ExportAddressViewController *exportController = [[ExportAddressViewController alloc] init];
    exportController.title = @"通讯录";
    exportController.selectedArray = tempArray;
    exportController.valueBlock = ^(NSArray *array) {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:array.count];
        NSString *ids = @"";
        for (int i = 0; i < array.count; i ++) {
            AddressBook *tempBook = array[i];
            if (i) {
                ids = [NSString stringWithFormat:@"%@,%@", ids, tempBook.id];
            }else {
                ids = [NSString stringWithFormat:@"%@", tempBook.id];
            }
            
            DetailStaffModel *staff = [DetailStaffModel initWithAddressBook:tempBook];
            [tempArray addObject:staff];
        }
        [params setObject:ids forKey:@"ids"];
        
        [self.view beginLoading];
        [[Net_APIManager sharedManager] request_Common_AddStaffs_WithParams:params path:_addStaffsPath block:^(id data, NSError *error) {
            [self.view endLoading];
            if (data) {
                [_othersArray addObjectsFromArray:tempArray];
                [_sourceArray addObjectsFromArray:tempArray];
                [_tableView reloadData];
                
                if (self.refreshBlock) {
                    self.refreshBlock();
                }
            }
        }];
    };
    [self.navigationController pushViewController:exportController animated:YES];
}

#pragma mark - private method
- (void)animateIndicatorView:(UIImageView*)indicatorView show:(BOOL)show {
    if (show) { // 显示
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
        [UIView animateWithDuration:0.2 animations:^{
            [indicatorView setTransform:transform];
        }];
    }else{
        CGAffineTransform transform = CGAffineTransformMakeRotation(0);
        [UIView animateWithDuration:0.2 animations:^{
            [indicatorView setTransform:transform];
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)updateAccess {
    
    DetailStaffModel *item = _othersArray[_expandIndex];

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [params setObject:item.id forKey:@"userId"];
    // 分配修改权限
    if ([item.staffLevel integerValue] == 3) {
        [params setObject:@0 forKey:@"updateType"];
        [self.view beginLoading];
        [[Net_APIManager sharedManager] request_Common_UpdateAccess_WithParams:params path:_updateAccessPath block:^(id data, NSError *error) {
            [self.view endLoading];
            if (data) {
                item.staffLevel = @2;
                
                for (DetailStaffModel *tempItem in _sourceArray) {
                    if ([tempItem.id isEqualToNumber:item.id]) {
                        tempItem.staffLevel = @2;
                        break;
                    }
                }
                
                if (self.refreshBlock) {
                    self.refreshBlock();
                }
                
                // 刷新对应行
                [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_expandIndex inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
        
        return;
    }
    
    [params setObject:@1 forKey:@"updateType"];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否取消负责人?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.view beginLoading];
        [[Net_APIManager sharedManager] request_Common_UpdateAccess_WithParams:params path:_updateAccessPath block:^(id data, NSError *error) {
            [self.view endLoading];
            if (data) {
                item.staffLevel = @3;
                for (DetailStaffModel *tempItem in _sourceArray) {
                    if ([tempItem.id isEqualToNumber:item.id]) {
                        tempItem.staffLevel = @3;
                        break;
                    }
                }
                
                // 刷新对应行
                [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_expandIndex inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)deleteStaff {
    
    DetailStaffModel *item = _othersArray[_expandIndex];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"是否删除该成员——%@", item.name] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
        [params setObject:item.id forKey:@"userId"];
        [self.view beginLoading];
        [[Net_APIManager sharedManager] request_Common_DeleteStaff_WithParams:params path:_deleteStaffPath block:^(id data, NSError *error) {
            [self.view endLoading];
            if (data) {
                
                for (DetailStaffModel *tempItem in _sourceArray) {
                    if ([tempItem.id isEqualToNumber:item.id]) {
                        [_sourceArray removeObject:tempItem];
                        break;
                    }
                }
                
                [_othersArray removeObjectAtIndex:_expandIndex];
                
                [_tableView reloadData];
                
                if (self.refreshBlock) {
                    self.refreshBlock();
                }
            }
        }];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([_othersArray count]) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!section) {
        return 1;
    }
    
    if (_isExpand) {
        return _othersArray.count + 1;
    }
    return _othersArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _expandIndex + 1) {
        return [DetailStaffExpandCell cellHeight];
    }
    return [DetailStaffCell cellHeight];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    [headerView setWidth:kScreen_Width];
    [headerView setHeight:25.0f];
    headerView.backgroundColor = [UIColor colorWithHexString:@"0xf7f7f8"];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setX:10];
    [titleLabel setWidth:200];
    [titleLabel setHeight:CGRectGetHeight(headerView.bounds)];
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.textColor = [UIColor colorWithHexString:@"0x8b8b8b"];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    if (!section) {
        titleLabel.text = @"所有者";
    }
    else {
        titleLabel.text = @"其他成员";
    }
    [headerView addSubview:titleLabel];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == _expandIndex + 1 && _isExpand) {
        DetailStaffExpandCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_expand forIndexPath:indexPath];
        DetailStaffModel *item = _othersArray[indexPath.row - 1];
        [cell configWithModel:item];
        
        cell.changeBtnClickedBlock = ^{
            self.expandIndex = indexPath.row - 1;
            [self updateAccess];
        };
        cell.deleteBtnClickedBlock = ^{
            self.expandIndex = indexPath.row - 1;
            [self deleteStaff];
        };
        return cell;
    }
    
    DetailStaffCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    DetailStaffModel *item;
    if (!indexPath.section) {
        item = _ownerArray.firstObject;
    }else {
        item = _othersArray[indexPath.row];
    }
    [cell configWithModel:item codeStatus:_editCode.status indexPath:indexPath];
    cell.showBtnClickedBlock = ^(NSInteger tag) {
        self.expandIndex = tag;
    };
    cell.iconViewClickedBlock = ^{
        InfoViewController *infoController = [[InfoViewController alloc] init];
        infoController.title = @"个人信息";
        if ([appDelegateAccessor.moudle.userId integerValue] == [item.id integerValue]) {
            infoController.infoTypeOfUser = InfoTypeMyself;
        }else{
            infoController.infoTypeOfUser = InfoTypeOthers;
            infoController.userId = [item.id integerValue];
        }
        [self.navigationController pushViewController:infoController animated:YES];
    };
    return cell;
}

#pragma mark - setters and getters
- (void)setExpandIndex:(NSInteger)expandIndex {
    
    DetailStaffCell *cell = nil;
    if (_expandIndex == expandIndex) {  // 点击同一行
        if (_isExpand) {  // 已经展开
            _isExpand = NO;
            [_tableView beginUpdates];
            [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:expandIndex + 1 inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
            [_tableView endUpdates];
            
            cell = (DetailStaffCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:expandIndex inSection:1]];
            [self animateIndicatorView:cell.indicatorView show:NO];
            
        }else {  // 之前没有展开
            _isExpand = YES;
            [_tableView beginUpdates];
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:expandIndex + 1 inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
            [_tableView  endUpdates];
            
            cell = (DetailStaffCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:expandIndex inSection:1]];
            [self animateIndicatorView:cell.indicatorView show:YES];
        }
        
        return;
    }
    
    // 点击的是非同行
    // 先判断是否有展开
    if (_isExpand) {
        _isExpand = NO;
        [_tableView beginUpdates];
        [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_expandIndex + 1 inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
        [_tableView endUpdates];
        
        cell = (DetailStaffCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_expandIndex inSection:1]];
        [self animateIndicatorView:cell.indicatorView show:NO];
    }
    
    _isExpand = YES;
    _expandIndex = expandIndex;
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_expandIndex + 1 inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
    [_tableView endUpdates];
    
    cell = (DetailStaffCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_expandIndex inSection:1]];
    [self animateIndicatorView:cell.indicatorView show:YES];
}

- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[DetailStaffCell class] forCellReuseIdentifier:kCellIdentifier];
        [_tableView registerClass:[DetailStaffExpandCell class] forCellReuseIdentifier:kCellIdentifier_expand];
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
