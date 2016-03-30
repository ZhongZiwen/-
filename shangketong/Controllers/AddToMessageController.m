//
//  AddToMessageController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AddToMessageController.h"
#import "MJRefresh.h"
#import "Lead.h"
#import "LeadTableViewCell.h"
#import "Customer.h"
#import "CustomerTableViewCell.h"

#import "AddToMessageSelectedController.h"
#import "MessageViewController.h"

#define kCellIdentifier_lead @"LeadTableViewCell"
#define kCellIdentifier_customer @"CustomerTableViewCell"

@interface AddToMessageController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableArray *selectedArray;
@property (strong, nonatomic) NSMutableArray *searchArray;
@property (strong, nonatomic) NSMutableDictionary *params;
@property (strong, nonatomic) NSMutableDictionary *searchParams;

@property (strong, nonatomic) UIButton *selectedButton;
@property (strong, nonatomic) UILabel *selectedLabel;
@property (strong, nonatomic) UIImageView *selectedAccessory;

@property (assign, nonatomic) NSInteger selectedCount;
@property (assign, nonatomic) BOOL isSearch;        // 是否搜索状态
@end

@implementation AddToMessageController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"下一步" target:self action:@selector(rightBtnPress)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.selectedButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _selectedArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    _params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [_params setObject:@1 forKey:@"pageNo"];
    [_params setObject:@20 forKey:@"pageSize"];
    [_params setObject:_activityId forKey:@"activityId"];
    
    _searchParams = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [_searchParams setObject:@1 forKey:@"pageNo"];
    [_searchParams setObject:@20 forKey:@"pageSize"];
    
    self.selectedCount = _selectedArray.count;
    
    [self.view beginLoading];
    [self sendRequestForList];
    
    [_tableView addHeaderWithTarget:self action:@selector(sendRequestForRefresh)];
    [_tableView addFooterWithTarget:self action:@selector(sendRequestForReloadMore)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
- (void)sendRequestForList {
    if (_addType == AddToMessageTypeLead) {
        [[Net_APIManager sharedManager] request_Common_SaleLeadsList_WithParams:_params path:kNetPath_Activity_SaleLeadsList block:^(id data, NSError *error) {
            [_tableView headerEndRefreshing];
            [_tableView footerEndRefreshing];
            if (data) {
                [self.view endLoading];
                NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
                for (NSDictionary *tempDict in data[@"saleLeads"]) {
                    Lead *item = [NSObject objectOfClass:@"Lead" fromJSON:tempDict];
                    [tempArray addObject:item];
                }
                if ([_params[@"pageNo"] isEqualToNumber:@1]) {
                    _sourceArray = tempArray;
                }
                else {
                    [_sourceArray addObjectsFromArray:tempArray];
                }
                
                if (tempArray.count == 20) {
                    _tableView.footerHidden = NO;
                }
                else {
                    _tableView.footerHidden = YES;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                });
            }
            else {
                if (error.code == STATUS_SESSION_UNAVAILABLE) {
                    CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                    comRequest.RequestAgainBlock = ^(){
                        [self sendRequestForList];
                    };
                    [comRequest loginInBackground];
                    return;
                }
                
                [self.view endLoading];
            }
            [_tableView configBlankPageWithTitle:@"暂无销售线索" hasData:_sourceArray.count hasError:error != nil reloadButtonBlock:nil];
        }];
        return;
    }
    
    [[Net_APIManager sharedManager] request_Common_Customer_List_WithParams:_params path:kNetPath_Activity_CustomerList block:^(id data, NSError *error) {
        [_tableView headerEndRefreshing];
        [_tableView footerEndRefreshing];
        if (data) {
            [self.view endLoading];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"customers"]) {
                Customer *item = [NSObject objectOfClass:@"Customer" fromJSON:tempDict];
                [tempArray addObject:item];
            }
            
            if ([_params[@"pageNo"] isEqualToNumber:@1]) {
                _sourceArray = tempArray;
            }
            else {
                [_sourceArray addObjectsFromArray:tempArray];
            }
            
            if (tempArray.count == 20) {
                _tableView.footerHidden = NO;
            }
            else {
                _tableView.footerHidden = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        }
        else {
            if (error.code == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^(){
                    [self sendRequestForList];
                };
                [comRequest loginInBackground];
                return;
            }
            
            [self.view endLoading];
        }
        [_tableView configBlankPageWithTitle:@"暂无客户" hasData:_sourceArray.count hasError:error != nil reloadButtonBlock:nil];
    }];
}

- (void)sendRequestForRefresh {
    if (_isSearch) {
        [_searchParams setObject:@1 forKey:@"pageNo"];
    }
    else {
        [_params setObject:@1 forKey:@"pageNo"];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (_isSearch) {
            [self sendRequestForSearch];
        }
        else {
            [self sendRequestForList];
        }
    });
}

- (void)sendRequestForReloadMore {
    if (_isSearch) {
        [_searchParams setObject:@([self.params[@"pageNo"] integerValue] + 1) forKey:@"pageNo"];
    }
    else {
        [_params setObject:@([self.params[@"pageNo"] integerValue] + 1) forKey:@"pageNo"];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (_isSearch) {
            [self sendRequestForSearch];
        }
        else {
            [self sendRequestForList];
        }
    });
}

- (void)sendRequestForSearch {
    if (_addType == AddToMessageTypeLead) {
        [[Net_APIManager sharedManager] request_Lead_Search_WithParams:_searchParams block:^(id data, NSError *error) {
            [_tableView headerEndRefreshing];
            [_tableView footerEndRefreshing];
            if (data) {
                [self.view endLoading];
                NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
                for (NSDictionary *tempDict in data[@"saleLeads"]) {
                    Lead *lead = [NSObject objectOfClass:@"Lead" fromJSON:tempDict];
                    for (Lead *selectedItem in _selectedArray) {
                        if ([selectedItem.id isEqualToNumber:lead.id]) {
                            lead.isSelected = YES;
                        }
                    }
                    [tempArray addObject:lead];
                }
                
                if ([_searchParams[@"pageNo"] isEqualToNumber:@1]) {
                    _searchArray = tempArray;
                }
                else {
                    [_searchArray addObjectsFromArray:tempArray];
                }
                
                if (tempArray.count == 20) {
                    _tableView.footerHidden = NO;
                }
                else {
                    _tableView.footerHidden = YES;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                });
            }
            else {
                if (error.code == STATUS_SESSION_UNAVAILABLE) {
                    CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                    comRequest.RequestAgainBlock = ^(){
                        [self sendRequestForSearch];
                    };
                    [comRequest loginInBackground];
                    return;
                }
                
                [self.view endLoading];
            }
            [_tableView configBlankPageWithTitle:@"无结果" hasData:_searchArray.count hasError:error != nil reloadButtonBlock:nil];
        }];
        return;
    }
    
    [[Net_APIManager sharedManager] request_Customer_Search_WithParams:_searchParams block:^(id data, NSError *error) {
        [_tableView headerEndRefreshing];
        [_tableView footerEndRefreshing];
        if (data) {
            [self.view endLoading];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"customers"]) {
                Customer *item = [NSObject objectOfClass:@"Customer" fromJSON:tempDict];
                for (Customer *selectedItem in _selectedArray) {
                    if ([selectedItem.id isEqualToNumber:item.id]) {
                        item.isSelected = YES;
                    }
                }
                [tempArray addObject:item];
            }
            
            if ([_searchParams[@"pageNo"] isEqualToNumber:@1]) {
                _searchArray = tempArray;
            }
            else {
                [_searchArray addObjectsFromArray:tempArray];
            }
            
            if (tempArray.count == 20) {
                _tableView.footerHidden = NO;
            }
            else {
                _tableView.footerHidden = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        }
        else {
            if (error.code == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^(){
                    [self sendRequestForSearch];
                };
                [comRequest loginInBackground];
                return;
            }
            
            [self.view endLoading];
        }
        [_tableView configBlankPageWithTitle:@"无结果" hasData:_searchArray.count hasError:error != nil reloadButtonBlock:nil];
    }];
}

- (BOOL)isEmptySelected {
    BOOL isEmpty = YES;
    if (self.selectedArray.count > 0) {
        isEmpty = NO;
    }
    return isEmpty;
}

#pragma mark - event response
- (void)rightBtnPress {
    if (!_selectedArray.count)
        return;
    
    MessageViewController *messageController = [[MessageViewController alloc] init];
    messageController.title = @"输入短信内容";
    messageController.sourceArray = _selectedArray;
    [self.navigationController pushViewController:messageController animated:YES];
}

- (void)selectedButtonPress {
    if (!_selectedCount) return;
    
    AddToMessageSelectedController *selectedController = [[AddToMessageSelectedController alloc] init];
    selectedController.title = (_addType == AddToMessageTypeLead ? @"已选择销售线索" : @"已选择客户");
    selectedController.sourceArray = [_selectedArray mutableCopy];
    selectedController.selectedType = (_addType == AddToMessageTypeLead ? AddToMessageSelectedTypeLead : AddToMessageSelectedTypeCustomer);
    selectedController.refleshBlock = ^(id obj) {
        
        if (_addType == AddToMessageTypeLead) {
            Lead *item = obj;
            if (item.isSelected) {
                [_selectedArray addObject:item];
            }else {
                for (int i = 0; i < _selectedArray.count; i ++) {
                    Lead *tempItem = _selectedArray[i];
                    if ([tempItem.id isEqualToNumber:item.id]) {
                        [_selectedArray removeObjectAtIndex:i];
                        break;
                    }
                }
            }
            
            self.selectedCount = _selectedArray.count;
            
            if (_isSearch) {
                for (int i = 0; i < _searchArray.count; i ++) {
                    Lead *tempLead = _searchArray[i];
                    if ([tempLead.id isEqualToNumber:item.id]) {
                        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                        break;
                    }
                }
                return;
            }
            
            for (int i = 0; i < _sourceArray.count; i ++) {
                Lead *tempItem = _sourceArray[i];
                if ([tempItem.id isEqualToNumber:item.id]) {
                    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    break;
                }
            }
        }else if (_addType == AddToMessageTypeCustomer) {
            Customer *item = obj;
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
            
            if (_isSearch) {
                for (int i = 0; i < _searchArray.count; i ++) {
                    Customer *tempItem = _searchArray[i];
                    if ([tempItem.id isEqualToNumber:item.id]) {
                        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                        break;
                    }
                }
                
                return;
            }
            
            for (int i = 0; i < _sourceArray.count; i ++) {
                Customer *tempItem = _sourceArray[i];
                if ([tempItem.id isEqualToNumber:item.id]) {
                    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    break;
                }
            }
        }

    };
    [self.navigationController pushViewController:selectedController animated:YES];
}

#pragma mark - UITablView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isSearch) {
        return _searchArray.count;
    }
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_addType == AddToMessageTypeLead) {
        return [LeadTableViewCell cellHeight];
    }
    else if (_addType == AddToMessageTypeCustomer) {
        return [CustomerTableViewCell cellHeight];
    }
    
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_addType == AddToMessageTypeLead) {
        LeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_lead forIndexPath:indexPath];
        Lead *item;
        if (_isSearch) {
            item = _searchArray[indexPath.row];
        }else {
            item = _sourceArray[indexPath.row];
        }
        [cell configWithModel:item];
        if (item.mobile) {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", item.isSelected ? @"tenant_agree_selected" : @"tenant_agree"]]];
        }else {
            cell.accessoryView = nil;
        }
        return cell;
    }
    else if (_addType == AddToMessageTypeCustomer) {
        CustomerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_customer forIndexPath:indexPath];
        Customer *item;
        if (_isSearch) {
            item = _searchArray[indexPath.row];
        }else {
            item = _sourceArray[indexPath.row];
        }
        [cell configWithModel:item];
        if (item.phone) {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", item.isSelected ? @"tenant_agree_selected" : @"tenant_agree"]]];
        }else {
            cell.accessoryView = nil;
        }
        return cell;
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_addType == AddToMessageTypeLead) {
        Lead *item;
        if (_isSearch) {
            item = _searchArray[indexPath.row];
        }else {
            item = _sourceArray[indexPath.row];
        }
        
        if (!item.mobile) {
            return;
        }
        
        if (item.isSelected) {
            for (int i = 0; i < _selectedArray.count; i ++) {
                Lead *tempItem = _selectedArray[i];
                if ([tempItem.id isEqualToNumber:item.id]) {
                    [self.selectedArray removeObjectAtIndex:i];
                    break;
                }
            }
            item.isSelected = NO;
            
            if (_isSearch) {
                for (Lead *tempItem in _sourceArray) {
                    if ([tempItem.id isEqualToNumber:item.id]) {
                        tempItem.isSelected = NO;
                        break;
                    }
                }
            }
            
        }else {
            [self.selectedArray addObject:item];
            item.isSelected = YES;
            
            if (_isSearch) {
                for (Lead *tempItem in _sourceArray) {
                    if ([tempItem.id isEqualToNumber:item.id]) {
                        tempItem.isSelected = YES;
                        break;
                    }
                }
            }
        }
        
        self.selectedCount = _selectedArray.count;
        
        LeadTableViewCell *cell = (LeadTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", item.isSelected ? @"tenant_agree_selected" : @"tenant_agree"]]];
        return;
    }
    
    Customer *item;
    if (_isSearch) {
        item = _searchArray[indexPath.row];
    }else {
        item = _sourceArray[indexPath.row];
    }
    
    if (!item.phone) {
        return;
    }
    
    if (item.isSelected) {
        for (int i = 0; i < _selectedArray.count; i ++) {
            Customer *tempItem = _selectedArray[i];
            if ([tempItem.id isEqualToNumber:item.id]) {
                [self.selectedArray removeObjectAtIndex:i];
                break;
            }
        }
        item.isSelected = NO;
        
        if (_isSearch) {
            for (Lead *tempItem in _sourceArray) {
                if ([tempItem.id isEqualToNumber:item.id]) {
                    tempItem.isSelected = NO;
                    break;
                }
            }
        }
    }else {
        [self.selectedArray addObject:item];
        item.isSelected = YES;
        
        if (_isSearch) {
            for (Customer *tempItem in _sourceArray) {
                if ([tempItem.id isEqualToNumber:item.id]) {
                    tempItem.isSelected = YES;
                    break;
                }
            }
        }
    }
    
    self.selectedCount = _selectedArray.count;
    
    CustomerTableViewCell *cell = (CustomerTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", item.isSelected ? @"tenant_agree_selected" : @"tenant_agree"]]];

}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_searchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    if (!_isSearch) {
        _isSearch = YES;
        [_tableView reloadData];
        [searchBar setShowsCancelButton:YES animated:YES];
    }
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    searchBar.text = nil;
    [searchBar setShowsCancelButton:NO animated:YES];
    _isSearch = NO;
    [_searchParams setObject:@1 forKey:@"pageNo"];
    [_tableView.blankPageView removeFromSuperview];
    [_tableView reloadData];
    [_tableView configBlankPageWithTitle:(_addType == AddToMessageTypeLead ? @"暂无销售线索" : @"暂无客户") hasData:_sourceArray.count hasError:NO reloadButtonBlock:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [_searchParams setObject:searchBar.text forKey:@"name"];
    [self sendRequestForSearch];
}

#pragma mark - setters and getters
- (void)setSelectedCount:(NSInteger)selectedCount {
    _selectedCount = selectedCount;
    
    if (_addType == AddToMessageTypeLead) {
        _selectedLabel.text = [NSString stringWithFormat:@"已选择销售线索: %ld", (long)_selectedCount];
    }
    else if (_addType == AddToMessageTypeCustomer) {
        _selectedLabel.text = [NSString stringWithFormat:@"已选择客户: %ld", (long)_selectedCount];
    }
    
    if (_selectedCount) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setY:0.0];
        [_tableView setWidth:kScreen_Width];
        [_tableView setHeight:kScreen_Height  - 44];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[LeadTableViewCell class] forCellReuseIdentifier:kCellIdentifier_lead];
        [_tableView registerClass:[CustomerTableViewCell class] forCellReuseIdentifier:kCellIdentifier_customer];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.tableHeaderView = self.searchBar;
    }
    return _tableView;
}

- (UISearchBar*)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        [_searchBar sizeToFit];
        if (_addType == AddToMessageTypeLead) {
            _searchBar.placeholder = @"搜索销售线索";
        }else if (_addType == AddToMessageTypeCustomer) {
            _searchBar.placeholder = @"搜索客户";
        }
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
