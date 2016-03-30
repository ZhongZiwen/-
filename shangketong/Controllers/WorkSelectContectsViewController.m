//
//  WorkSelectContectsViewController.m
//  shangketong
//
//  Created by 蒋 on 15/12/31.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "WorkSelectContectsViewController.h"
#import "ExportAddressTableViewCell.h"
#import "ExportBottomTableViewCell.h"
#import "ExportAddress.h"
#import <AddressBook/AddressBook.h>

#define kCellIdentifier @"ExportAddressTableViewCell"
#define kBottomCellIdentifier @"ExportBottomTableViewCell"

@interface WorkSelectContectsViewController ()

@property (strong, nonatomic) ExportAddress *bottomExport;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UITableView *bottomTableView;
@property (nonatomic, strong) UILabel *bottomSelectedLabel;
@property (nonatomic, strong) UIButton *bottomConfirmBtn;       // 确认按钮
@property (nonatomic, strong) NSMutableArray *lastContactArray; //最近联系人

@property (assign, nonatomic) BOOL isAllSeledted;

@property (assign, nonatomic) NSInteger countSuccess;


- (void)updateBottomView;   // 更新bottomSelectedLabel和bottomConfirmBtn的属性值
@end

@implementation WorkSelectContectsViewController
@synthesize rowDescriptor = _rowDescriptor;
@synthesize popoverController = __popoverController;

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    // 自定义返回按钮 开启手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    [self.tableView registerClass:[ExportAddressTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    [self.tableView setHeight:CGRectGetHeight(self.tableView.bounds) - 54];
    [self.mSearchDisplayController.searchResultsTableView registerClass:[ExportAddressTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    
    [self.view addSubview:self.bottomView];
    [_bottomView addSubview:self.bottomTableView];
    [_bottomView addSubview:self.bottomSelectedLabel];
    [_bottomView addSubview:self.bottomConfirmBtn];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _lastContactArray = [NSMutableArray arrayWithCapacity:0];
    [_lastContactArray addObjectsFromArray:[[FMDBManagement sharedFMDBManager] getLastContactsAddressBookDataSource]];
    _bottomExport = [[ExportAddress alloc] init];
    // 默认添加一个空数据
    AddressBook *item = [[AddressBook alloc] init];
    item.isDefault = YES;
    item.icon = @"Head_Box";
    [_bottomExport.selectedArray addObject:item];
    
    if (!self.sourceArray.count) {
        [self.view beginLoading];
        [self sendRequest];
        return;
    }
    
    for (AddressBook *selectedItem in _selectedArray) {
        for (AddressBook *tempItem in self.sourceArray) {
            if ([selectedItem.id isEqualToNumber:tempItem.id]) {
                [self.sourceArray removeObject:tempItem];
                break;
            }
        }
        for (AddressBook *tempItem in self.lastContactArray) {
            if ([selectedItem.id isEqualToNumber:tempItem.id]) {
                [self.lastContactArray removeObject:tempItem];
                break;
            }
        }
    }
    
    [self groupingDataSourceFrom:self.sourceArray to:self.groupsArray];
    [self sortForArray:self.groupsArray];
    [self.tableView configBlankPageWithTitle:@"暂无可选成员" hasData:self.groupsArray.count hasError:NO reloadButtonBlock:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)leftButtonItemPress {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - private method
- (void)updateBottomView {
    if (_bottomExport.selectedArray.count - 1) {
        _bottomConfirmBtn.enabled = YES;
        
        _bottomSelectedLabel.hidden = NO;
        _bottomSelectedLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
        _bottomSelectedLabel.text = [NSString stringWithFormat:@"%ld", _bottomExport.selectedArray.count - 1];
        
        [UIView animateWithDuration:0.3 animations:^{
            _bottomSelectedLabel.transform = CGAffineTransformMakeScale(1.125, 1.125);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                _bottomSelectedLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
            } completion:nil];
        }];
        
        return;
    }
    
    _bottomConfirmBtn.enabled = NO;
    _bottomSelectedLabel.hidden = YES;
    _bottomSelectedLabel.text = @"0";
}
- (void)confirmButtonPress {
    
    if (self.valueBlock) {
        [_bottomExport.selectedArray removeLastObject];
        
        self.valueBlock(_bottomExport.selectedArray);
        if (_isActivityRecExport) {
            [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        return;
    }
    
    [_bottomExport.selectedArray removeLastObject];
    self.rowDescriptor.value = _bottomExport;
    
    if (self.popoverController){
        [self.popoverController dismissPopoverAnimated:YES];
        [self.popoverController.delegate popoverControllerDidDismissPopover:self.popoverController];
    }else if ([self.parentViewController isKindOfClass:[UINavigationController class]]){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UITableView_M
- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
        return nil;
    }
    if (tableView == _bottomTableView) {
        return nil;
    }
    
    NSMutableArray *indexs = [NSMutableArray array];
    for (AddressBookGroup *group in self.groupsArray) {
        [indexs addObject:group.groupName];
    }
    return indexs;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // 搜索列表
    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
        if (self.searchResults.count) {
            AddressBookGroup *group = self.searchResults[section];
            return group.groupName;
        }
        return @"";
    }
    
    // 主列表
    if (tableView == self.tableView) {
        if (_lastContactArray.count > 0) {
            if (section == 0) {
                return @"最近";
            }
            AddressBookGroup *group = self.groupsArray[section - 1];
            return group.groupName;
        }
        AddressBookGroup *group = self.groupsArray[section];
        return group.groupName;
    }
    
    // 底部选择表格
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
        if (self.searchResults.count) {
            return self.searchResults.count;
        }
        return 0;
    }
    
    if (tableView == self.tableView) {
        if (_lastContactArray.count > 0) {
            return self.groupsArray.count + 1;
        }
        return self.groupsArray.count;
    }
    
    // bottomTableView默认为一组
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
        if (self.searchResults.count) {
            AddressBookGroup *group = self.searchResults[section];
            return group.groupItems.count;
        }
        return 0;
    }
    
    if (tableView == self.tableView) {
        if (_lastContactArray.count > 0) {
            if (section == 0) {
                return _lastContactArray.count;
            }
            AddressBookGroup *group = self.groupsArray[section - 1];
            return group.groupItems.count;
        }
        AddressBookGroup *group = self.groupsArray[section];
        return group.groupItems.count;
    }
    
    return [_bottomExport.selectedArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _bottomTableView) {
        return [ExportBottomTableViewCell cellHeight];
    }
    
    return [ExportAddressTableViewCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _bottomTableView) {
        ExportBottomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBottomCellIdentifier forIndexPath:indexPath];
        AddressBook *item = _bottomExport.selectedArray[indexPath.row];
        [cell configWithModel:item];
        return cell;
    }
    
    ExportAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
        AddressBookGroup *group = self.searchResults[indexPath.section];
        [cell configWithModel:group.groupItems[indexPath.row]];
        cell.accessoryView = nil;
    }else {
        AddressBookGroup *group = [[AddressBookGroup alloc] init];
        AddressBook *item = [[AddressBook alloc] init];
        if (_lastContactArray.count > 0) {
            if (indexPath.section == 0) {
                item = _lastContactArray[indexPath.row];
            } else {
                group = self.groupsArray[indexPath.section - 1];
                item = group.groupItems[indexPath.row];
            }
        } else {
            group = self.groupsArray[indexPath.section];
            item = group.groupItems[indexPath.row];
        }
        
        [cell configWithModel:item];
        if (!item.isSelected) {    // 没有选中
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_message_normal"]];
        }else{      // 选中
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"multi_graph_select"]];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSIndexPath *path = nil;
    AddressBookGroup *group;
    AddressBook *item;
    NSIndexPath *index = nil;
    
    if (tableView == self.bottomTableView) {
        return;
    }
    
    if (tableView == self.tableView) {
        if (_lastContactArray.count > 0) {
            if (indexPath.section == 0) {
                item = _lastContactArray[indexPath.row];
                NSInteger sectionIndex = 0;
                for (int i = 0; i < self.groupsArray.count; i++) {
                    sectionIndex ++;
                    NSInteger rowIndex = 0;
                    group = self.groupsArray[i];
                    for (AddressBook *newModel in group.groupItems) {
                        if ([newModel.id integerValue] == [item.id integerValue]) {
                            newModel.isSelected = !newModel.isSelected;
                            index = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
                            ExportAddressTableViewCell *cell = (ExportAddressTableViewCell *)[tableView cellForRowAtIndexPath:index];
                            if (!newModel.isSelected) {    // 没有选中
                                cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_message_normal"]];
                            }else{      // 选中
                                cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"multi_graph_select"]];
                            }

                            [cell configWithModel:newModel];
                        }
                        rowIndex ++;
                    }
                }
            } else {
                NSInteger sectionIndex = 0;
                NSInteger rowIndex = 0;
                group = self.groupsArray[indexPath.section - 1];
                item = group.groupItems[indexPath.row];
                for (AddressBook *newModel in _lastContactArray) {
                    if ([newModel.id integerValue] == [item.id integerValue]) {
                        newModel.isSelected = !newModel.isSelected;
                        index = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
                        ExportAddressTableViewCell *cell = (ExportAddressTableViewCell *)[tableView cellForRowAtIndexPath:index];
                        [cell configWithModel:newModel];
                        if (!newModel.isSelected) {    // 没有选中
                            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_message_normal"]];
                        }else{      // 选中
                            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"multi_graph_select"]];
                        }

                        
                    }
                    rowIndex ++;
                }
            }
        } else {
            group = self.groupsArray[indexPath.section];
            item = group.groupItems[indexPath.row];
        }
        
        if (item.isSelected) {
            item.isSelected = NO;
            // 在bottomSourceArray数组中找到并取消选中该联系人
            for (int i = 0; i < _bottomExport.selectedArray.count - 1; i ++) {
                AddressBook *tempItem = _bottomExport.selectedArray[i];
                if ([tempItem.id integerValue] == [item.id integerValue]) {
                    // 赋值path，用于删除在bottomtableview的数据
                    path = [NSIndexPath indexPathForRow:i inSection:0];
                    // 从bottomSourceArray中删除选中数据
                    [_bottomExport.selectedArray removeObjectAtIndex:i];
                    
                    [self updateBottomView];
                }
            }
            
            // 动态删除cell
            [_bottomTableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationBottom];
            
        }else {
            item.isSelected = YES;
            
            //申明path，在_bottomTableView倒数第二行位置插入数据
            path = [NSIndexPath indexPathForRow:_bottomExport.selectedArray.count - 1 inSection:0];
            
            // 选中添加数据
            [_bottomExport.selectedArray insertObject:item atIndex:_bottomExport.selectedArray.count - 1];
            
            [self updateBottomView];
            
            // 动态插入cell
            [_bottomTableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationBottom];
        }
        
        // 改变当前cell的选中状态
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        // 让_bottomTableView显示最后一行
        path = [NSIndexPath indexPathForRow:[_bottomTableView numberOfRowsInSection:0] - 1 inSection:0];
        [_bottomTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        return;
    }
    
    group = self.searchResults[indexPath.section];
    item = group.groupItems[indexPath.row];
    if (_lastContactArray.count > 0) {
        NSInteger sectionIndex = 0;
        NSInteger rowIndex = 0;
        for (AddressBook *newModel in _lastContactArray) {
            if ([newModel.id integerValue] == [item.id integerValue]) {
                newModel.isSelected = !newModel.isSelected;
                index = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
                ExportAddressTableViewCell *cell = (ExportAddressTableViewCell *)[tableView cellForRowAtIndexPath:index];
                [cell configWithModel:newModel];
                if (!newModel.isSelected) {    // 没有选中
                    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_message_normal"]];
                }else{      // 选中
                    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"multi_graph_select"]];
                }
                
                
            }
            rowIndex ++;
        }
    }
    if (item.isSelected) {
        [self.mSearchDisplayController setActive:NO animated:YES];
        return;
    }

    item.isSelected = YES;
    
    //申明path，在_bottomTableView倒数第二行位置插入数据
    path = [NSIndexPath indexPathForRow:_bottomExport.selectedArray.count - 1 inSection:0];
    
    // 选中添加数据
    [_bottomExport.selectedArray insertObject:item atIndex:_bottomExport.selectedArray.count - 1];
    
    [self updateBottomView];
    
    // 动态插入cell
    [_bottomTableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationBottom];
    
    [self.tableView reloadData];
    
    // 让_bottomTableView显示最后一行
    path = [NSIndexPath indexPathForRow:[_bottomTableView numberOfRowsInSection:0] - 1 inSection:0];
    [_bottomTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    [self.mSearchDisplayController setActive:NO animated:YES];
}

#pragma mark - setters and getters
- (UIView*)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height-54, kScreen_Width, 54)];
        _bottomView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        [_bottomView addLineUp:YES andDown:NO];
    }
    return _bottomView;
}

- (UITableView*)bottomTableView {
    if (!_bottomTableView) {
        _bottomTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 54, CGRectGetWidth(_bottomView.bounds)-10-72) style:UITableViewStylePlain];
        _bottomTableView.center = CGPointMake((CGRectGetWidth(_bottomView.bounds)-72-10)/2.0, CGRectGetHeight(_bottomView.bounds)/2.0);
        _bottomTableView.backgroundView = nil;
        _bottomTableView.backgroundColor = [UIColor clearColor];
        _bottomTableView.transform = CGAffineTransformMakeRotation(-M_PI/2);
        _bottomTableView.showsVerticalScrollIndicator = NO;
        _bottomTableView.delegate = self;
        _bottomTableView.dataSource = self;
        _bottomTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_bottomTableView registerClass:[ExportBottomTableViewCell class] forCellReuseIdentifier:kBottomCellIdentifier];
        _bottomTableView.tableFooterView = [[UIView alloc] init];
    }
    return _bottomTableView;
}

- (UILabel*)bottomSelectedLabel {
    if (!_bottomSelectedLabel) {
        _bottomSelectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - 50 - 24, 15, 24, 24)];
        _bottomSelectedLabel.backgroundColor = [UIColor colorWithRed:(CGFloat)34/255.0f green:(CGFloat)192/255.f blue:(CGFloat)100/255.f alpha:1.f];
        _bottomSelectedLabel.textColor = [UIColor whiteColor];
        _bottomSelectedLabel.font = [UIFont systemFontOfSize:14.f];
        _bottomSelectedLabel.textAlignment = NSTextAlignmentCenter;
        _bottomSelectedLabel.layer.cornerRadius = 12.f;
        _bottomSelectedLabel.layer.masksToBounds = YES;
        _bottomSelectedLabel.clipsToBounds = YES;
        _bottomSelectedLabel.hidden = YES;
    }
    return _bottomSelectedLabel;
}

- (UIButton*)bottomConfirmBtn {
    if (!_bottomConfirmBtn) {
        _bottomConfirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _bottomConfirmBtn.frame = CGRectMake(kScreen_Width-50, 0, 50, 54);
        _bottomConfirmBtn.enabled = NO;
        _bottomConfirmBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_bottomConfirmBtn setTitleColor:[[UIColor alloc] initWithRed:34/255.f green:192/255.f blue:100/255.f alpha:1.0]
                                forState:UIControlStateNormal];
        [_bottomConfirmBtn setTitleColor:[[UIColor alloc] initWithRed:34/255.f green:192/255.f blue:100/255.f alpha:0.3]
                                forState:UIControlStateDisabled];
        [_bottomConfirmBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_bottomConfirmBtn addTarget:self action:@selector(confirmButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomConfirmBtn;
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
