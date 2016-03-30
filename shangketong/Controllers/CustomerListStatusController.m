//
//  CustomerListStatusController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/3.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CustomerListStatusController.h"
#import "CustomerStatusListController.h"
#import "CustomerListAddSelectedController.h"

#import "CustomerTableViewCell.h"

#import "Customer.h"
#import "NameIdModel.h"

#define kCellIdentifier @"CustomerTableViewCell"

@interface CustomerListStatusController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *selectedArray;
@property (strong, nonatomic) NSMutableArray *searchArray;

@property (strong, nonatomic) UIButton *selectedButton;
@property (strong, nonatomic) UILabel *selectedLabel;
@property (strong, nonatomic) UIImageView *selectedAccessory;

@property (assign, nonatomic) BOOL isSearch;
@property (assign, nonatomic) NSInteger selectedCount;

- (void)sendRequestForSearchWithKey:(NSString*)keyStr;
- (void)sendRequestForUpdateStatusWithStatus:(NameIdModel*)status;
@end

@implementation CustomerListStatusController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"下一步" target:self action:@selector(rightButtonPress)];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.selectedButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _selectedArray = [[NSMutableArray alloc] initWithCapacity:0];
    _searchArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    self.selectedCount = _selectedArray.count;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)rightButtonPress {
    
    if (!_selectedArray.count)
        return;
    
    __weak typeof(self) weak_self = self;
    CustomerStatusListController *statusListController = [[CustomerStatusListController alloc] init];
    statusListController.title = @"修改参与状态";
    statusListController.valueBlock = ^(NameIdModel *status) {
        [weak_self sendRequestForUpdateStatusWithStatus:status];
    };
    [self.navigationController pushViewController:statusListController animated:YES];
}

- (void)selectedButtonPress {
    
    if (!_selectedCount)
        return;
    
    CustomerListAddSelectedController *selectedController = [[CustomerListAddSelectedController alloc] init];
    selectedController.title = @"已选择客户";
    selectedController.sourceArray = _selectedArray;
    selectedController.refleshBlock = ^(Customer *item) {
        
        if (item.isSelected) {
            [_selectedArray addObject:item];
        }else {
            for (int i = 0; i < _selectedArray.count; i ++) {
                Customer *tempItem = _selectedArray[i];
                if ([tempItem.id isEqualToNumber:item.id]) {
                    [_selectedArray removeObjectAtIndex:i];
                    break;
                }
            }
        }
        
        self.selectedCount = _selectedArray.count;
        
        for (int i = 0; i < _sourceArray.count; i ++) {
            Customer *tempItem = _sourceArray[i];
            if ([tempItem.id isEqualToNumber:item.id]) {
                [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
        }
    };
    [self.navigationController pushViewController:selectedController animated:YES];
}

#pragma mark - private method
- (void)sendRequestForSearchWithKey:(NSString *)keyStr {
    
    [_params setObject:keyStr forKey:@"name"];
    
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_Common_Customer_List_WithParams:_params path:kNetPath_Activity_CustomerList block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            [_searchArray removeAllObjects];
            for (NSDictionary *tempDict in data[@"customers"]) {
                Customer *customer = [NSObject objectOfClass:@"Customer" fromJSON:tempDict];
                for (Customer *selectedItem in _selectedArray) {
                    if ([selectedItem.id isEqualToNumber:customer.id]) {
                        customer.isSelected = YES;
                    }
                }
                [_searchArray addObject:customer];
            }
            
            [_tableView reloadData];
        }else {
            NSLog(@"搜索失败");
        }
        [self.view configBlankPageWithTitle:@"无结果" hasData:_searchArray.count hasError:error != nil reloadButtonBlock:nil];
    }];
}

- (void)sendRequestForUpdateStatusWithStatus:(NameIdModel *)status {
    NSMutableDictionary *mParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [mParams setObject:status.id forKey:@"participateId"];
    
    NSString *customerIds = @"";
    for (int i = 0; i < _selectedArray.count; i ++) {
        Customer *item = _selectedArray[i];
        if (i) {
            customerIds = [NSString stringWithFormat:@"%@,%@", customerIds, item.id];
        }else {
            customerIds = [NSString stringWithFormat:@"%@", item.id];
        }
    }
    
    [mParams setObject:customerIds forKey:@"customerIds"];
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_Activity_UpdateAttendedStatus_WithParams:mParams block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            // 修改状态
            for (Customer *tempItem in _selectedArray) {
                tempItem.statusDesc = status.name;
            }
            // 同步上一视图
            if (self.refreshBlock) {
                self.refreshBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            NSLog(@"修改状态失败");
        }
    }];
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isSearch) {
        return _searchArray.count;
    }
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [CustomerTableViewCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    Customer *item;
    if (_isSearch) {
        item = _searchArray[indexPath.row];
    }else {
        item = _sourceArray[indexPath.row];
    }
    item = _sourceArray[indexPath.row];
    
    [cell configWithModel:item];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", item.isSelected ? @"tenant_agree_selected" : @"tenant_agree"]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Customer *item;
    if (_isSearch) {
        item = _searchArray[indexPath.row];
    }else {
        item = _sourceArray[indexPath.row];
    }
    item = _sourceArray[indexPath.row];
    
    if (item.isSelected) {
        for (int i = 0; i < _selectedArray.count; i ++) {
            Customer *tempItem = _selectedArray[i];
            if ([tempItem.id isEqualToNumber:item.id]) {
                [_selectedArray removeObjectAtIndex:i];
                break;
            }
        }
        item.isSelected = NO;
    }else {
        [_selectedArray addObject:item];
        item.isSelected = YES;
    }
    
    self.selectedCount = _selectedArray.count;
    
    CustomerTableViewCell *cell = (CustomerTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", item.isSelected ? @"tenant_agree_selected" : @"tenant_agree"]]];
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    _isSearch = YES;
    [_tableView reloadData];
    [searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    searchBar.text = nil;
    _isSearch = NO;
    [_searchArray removeAllObjects];
    [_tableView reloadData];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self sendRequestForSearchWithKey:searchBar.text];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_searchBar resignFirstResponder];
    //    [_searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - setters and getters
- (void)setSelectedCount:(NSInteger)selectedCount {
    _selectedCount = selectedCount;
    
    _selectedLabel.text = [NSString stringWithFormat:@"已选择客户: %ld", (long)_selectedCount];
}

- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - 44) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[CustomerTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.tableHeaderView = self.searchBar;
        
    }
    return _tableView;
}

- (UISearchBar*)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        [_searchBar sizeToFit];
        _searchBar.placeholder = @"搜索客户";
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (UIButton*)selectedButton {
    if (!_selectedButton) {
        _selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectedButton.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];
        [_selectedButton setWidth:kScreen_Width];
        [_selectedButton setHeight:44];
        [_selectedButton setY:kScreen_Height - 44];
        [_selectedButton addLineUp:YES andDown:NO];
        [_selectedButton addTarget:self action:@selector(selectedButtonPress) forControlEvents:UIControlEventTouchUpInside];
        
        [_selectedButton addSubview:self.selectedLabel];
        [_selectedButton addSubview:self.selectedAccessory];
    }
    return _selectedButton;
}

- (UILabel*)selectedLabel {
    if (!_selectedLabel) {
        _selectedLabel = [[UILabel alloc] init];
        [_selectedLabel setX:15];
        [_selectedLabel setWidth:kScreen_Width - 30];
        [_selectedLabel setHeight:CGRectGetHeight(_selectedButton.bounds)];
        _selectedLabel.font = [UIFont systemFontOfSize:15];
        _selectedLabel.textAlignment = NSTextAlignmentLeft;
        _selectedLabel.textColor = [UIColor iOS7darkGrayColor];
    }
    return _selectedLabel;
}

- (UIImageView*)selectedAccessory {
    if (!_selectedAccessory) {
        UIImage *image = [UIImage imageNamed:@"activity_Arrow"];
        _selectedAccessory = [[UIImageView alloc] initWithImage:image];
        [_selectedAccessory setWidth:image.size.width];
        [_selectedAccessory setHeight:image.size.height];
        [_selectedAccessory setX:kScreen_Width - image.size.width - 15];
        [_selectedAccessory setCenterY:CGRectGetHeight(_selectedButton.bounds) / 2];
    }
    return _selectedAccessory;
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
