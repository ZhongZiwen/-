//
//  SMSCustomerViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/12/31.
//  Copyright © 2015年 sungoin. All rights reserved.
//

#import "SMSCustomerViewController.h"
#import "MessageViewController.h"
#import "CustomerListAddSelectedController.h"
#import "Customer.h"
#import "CustomerTableViewCell.h"
#import "MJRefresh.h"
#import "CustomTitleView.h"
#import "IndexCondition.h"

#define kCellIdentifier @"CustomerTableViewCell"

@interface SMSCustomerViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISearchBar *mSearchBar;
@property (strong, nonatomic) UIButton *bottomButton;
@property (strong, nonatomic) UILabel *bottomLabel;
@property (strong, nonatomic) UIImageView *bottomAccessory;
@property (strong, nonatomic) CustomTitleView *titleView;
@property (strong, nonatomic) IndexCondition *curIndex;

@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableArray *searchArray;
@property (strong, nonatomic) NSMutableArray *selectedArray;
@property (strong, nonatomic) NSMutableArray *indexArray;
@property (strong, nonatomic) NSMutableDictionary *params;
@property (strong, nonatomic) NSMutableDictionary *searchParams;

@property (assign, nonatomic) NSInteger selectedCount;
@property (assign, nonatomic) BOOL isSearch;

- (void)sendRequestInit;
- (void)sendRequest;
@end

@implementation SMSCustomerViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"下一步" target:self action:@selector(rightButtonPress)];
    
    @weakify(self);
    self.navigationItem.titleView = self.titleView;
    _titleView.defalutTitleString = self.title;
    _titleView.valueBlock = ^(NSInteger index) {
        @strongify(self);
        self.curIndex = self.indexArray[index];
    };

    [self.view addSubview:self.tableView];
    [self.view addSubview:self.bottomButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _selectedArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.selectedCount = 0;
    
    _params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [_params setObject:@1 forKey:@"pageNo"];
    [_params setObject:@20 forKey:@"pageSize"];
    
    [self.view beginLoading];
    [self sendRequestInit];
    
    [self.tableView addHeaderWithTarget:self action:@selector(sendRequestToRefresh)];
    [self.tableView addFooterWithTarget:self action:@selector(sendRequestToReloadMore)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)rightButtonPress {
    if (!_selectedArray.count) {
        return;
    }
    
    MessageViewController *messageController = [[MessageViewController alloc] init];
    messageController.title = @"输入短信内容";
    messageController.sourceArray = _selectedArray;
    [self.navigationController pushViewController:messageController animated:YES];
}

- (void)selectedButtonPress {
    if (!_selectedCount) {
        return;
    }
    
    CustomerListAddSelectedController *selectedController = [[CustomerListAddSelectedController alloc] init];
    selectedController.title = @"已选择客户";
    selectedController.sourceArray = [_selectedArray mutableCopy];
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
        
        for (int i = 0; i < self.sourceArray.count; i ++) {
            Customer *tempItem = self.sourceArray[i];
            if ([tempItem.id isEqualToNumber:item.id]) {
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
        }
    };
    [self.navigationController pushViewController:selectedController animated:YES];
}

#pragma mark - public method
- (void)sendRequestInit {
    [[Net_APIManager sharedManager] request_Customer_Init_WithBlock:^(id data, NSError *error) {
        if (data) {
            [self sendRequestForIndex];
        }else {
            if (error.code == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^(){
                    [self sendRequestInit];
                };
                [comRequest loginInBackground];
                return;
            }
            
            [self.view endLoading];
        }
    }];
}

- (void)sendRequestForIndex {
    [[Net_APIManager sharedManager] request_CRM_Common_Index_WithPath:kNetPath_Customer_Select_List block:^(id data, NSError *error) {
        if (data) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"conditions"]) {
                IndexCondition *item = [NSObject objectOfClass:@"IndexCondition" fromJSON:tempDict];
                [tempArray addObject:item];
                
                if ([item.id isEqualToNumber:data[@"id"]]) {
                    _curIndex = item;
                }
            }
            
            self.indexArray = tempArray;
            self.titleView.sourceArray = self.indexArray;
            
            for (int i = 0; i < tempArray.count; i ++) {
                IndexCondition *tempIndex = tempArray[i];
                if ([tempIndex.id isEqualToNumber:_curIndex.id]) {
                    self.titleView.index = i;
                    break;
                }
            }
            
            // 请求列表数据
            [self.params setObject:_curIndex.id forKey:@"retrievalId"];
            [self sendRequest];
        }
    }];
}

- (void)sendRequest {
    [[Net_APIManager sharedManager] request_Customer_List_WithParams:self.params andBlock:^(id data, NSError *error) {
        [self.tableView headerEndRefreshing];
        [self.tableView footerEndRefreshing];
        if (data) {
            [self.view endLoading];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"customers"]) {
                Customer *customer = [NSObject objectOfClass:@"Customer" fromJSON:tempDict];
                [tempArray addObject:customer];
            }
            if ([self.params[@"pageNo"] isEqualToNumber:@1]) {
                self.sourceArray = tempArray;
            }
            else {
                [self.sourceArray addObjectsFromArray:tempArray];
            }
            if (tempArray.count == 20) {
                self.tableView.footerHidden = NO;
            }
            else {
                self.tableView.footerHidden = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.tableView configBlankPageWithTitle:@"暂无客户" hasData:self.sourceArray.count hasError:NO reloadButtonBlock:nil];
            });
        }
        else {
            if (error.code == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^(){
                    [self sendRequest];
                };
                [comRequest loginInBackground];
                return;
            }
            
            [self.view endLoading];
        }
    }];
}

- (void)sendRequestToRefresh {
    [self.params setObject:@1 forKey:@"pageNo"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequest];
    });
}

- (void)sendRequestToReloadMore {
    if (_isSearch) {
        [self.searchParams setObject:@([self.searchParams[@"pageNo"] integerValue] + 1) forKey:@"pageNo"];
    }
    else {
        [self.params setObject:@([self.params[@"pageNo"] integerValue] + 1) forKey:@"pageNo"];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (_isSearch) {
            [self sendRequestForSearch];
        }
        else {
            [self sendRequest];
        }
    });
}

- (void)sendRequestForSearch {
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_Common_SearchList_WithParams:_searchParams path:RELATED_CUSTOMER block:^(id data, NSError *error) {
        [_tableView footerEndRefreshing];
        if (data) {
            [self.view endLoading];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"customers"]) {
                Customer *customer = [NSObject objectOfClass:@"Customer" fromJSON:tempDict];
                [tempArray addObject:customer];
            }
            if ([self.params[@"pageNo"] isEqualToNumber:@1]) {
                self.searchArray = tempArray;
            }
            else {
                [self.searchArray addObjectsFromArray:tempArray];
            }
            
            if (tempArray.count == 20) {
                self.tableView.footerHidden = NO;
            }
            else {
                self.tableView.footerHidden = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        else {
            if (error.code == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^{
                    [self sendRequest];
                };
                [comRequest loginInBackground];
                return;
            }
            
            [self.view endLoading];
        }
        
        [_tableView configBlankPageWithTitle:@"无结果" hasData:_searchArray.count hasError:error != nil reloadButtonBlock:nil];
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_mSearchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    searchBar.text = nil;
    [searchBar setShowsCancelButton:NO animated:YES];
    self.isSearch = NO;
    [self.searchArray removeAllObjects];
    [self.searchParams setObject:@1 forKey:@"pageNo"];
    [_tableView.blankPageView removeFromSuperview];
    [_tableView reloadData];
    [self.tableView configBlankPageWithTitle:@"暂无联系人" hasData:self.sourceArray.count hasError:NO reloadButtonBlock:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self.searchParams setObject:searchBar.text forKey:@"name"];
    [self sendRequestForSearch];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (!_isSearch) {
        self.isSearch = YES;
        [_tableView reloadData];
        [searchBar setShowsCancelButton:YES animated:YES];
    }
    
    return YES;
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isSearch) {
        return _searchArray.count;
    }
    return self.sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [CustomerTableViewCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    Customer *item;
    if (_isSearch) {
        item = self.searchArray[indexPath.row];
    }
    else {
        item = self.sourceArray[indexPath.row];
    }
    [cell configWithoutSWWithItem:item];
    
    if ([CommonFuntion isMobileNumber:item.phone]) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", item.isSelected ? @"tenant_agree_selected" : @"tenant_agree"]]];
    }
    else {
        cell.accessoryView = nil;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Customer *item;
    
    if (_isSearch) {
        item = self.searchArray[indexPath.row];
    }
    else {
        item = self.sourceArray[indexPath.row];
    }
    
    if (![CommonFuntion isMobileNumber:item.phone]) {
        return;
    }
    
    if (item.isSelected) {
        for (int i = 0; i < _selectedArray.count; i ++) {
            Customer *tempItem = _selectedArray[i];
            if ([tempItem.id isEqualToNumber:item.id]) {
                [_selectedArray removeObjectAtIndex:i];
                break;
            }
        }
        item.isSelected = NO;
        
        if (_isSearch) {
            for (Customer *tempItem in _sourceArray) {
                if ([tempItem.id isEqualToNumber:item.id]) {
                    tempItem.isSelected = NO;
                    break;
                }
            }
        }
        
    }else {
        [_selectedArray addObject:item];
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
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - setters and getters
- (void)setCurIndex:(IndexCondition *)curIndex {
    if (_curIndex == curIndex) {
        return;
    }
    
    _curIndex = curIndex;
    
    [_params setObject:_curIndex.id forKey:@"retrievalId"];
    [self.view beginLoading];
    [self sendRequest];
}

- (void)setSelectedCount:(NSInteger)selectedCount {
    _selectedCount = selectedCount;
    
    if (_selectedCount) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    _bottomLabel.text = [NSString stringWithFormat:@"已选择客户:%d", _selectedCount];
}

- (void)setIsSearch:(BOOL)isSearch {
    if (_isSearch == isSearch) {
        return;
    }
    
    _isSearch = isSearch;
    
    if (_isSearch) {
        _tableView.headerHidden = YES;
    }
    else {
        _tableView.headerHidden = NO;
    }
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setY:64.0f];
        [_tableView setWidth:kScreen_Width];
        [_tableView setHeight:kScreen_Height - CGRectGetMinY(_tableView.frame) - 44];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = self.mSearchBar;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
        _tableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
        [self.tableView registerClass:[CustomerTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    }
    return _tableView;
}

- (UISearchBar*)mSearchBar {
    if (!_mSearchBar) {
        _mSearchBar = [[UISearchBar alloc] init];
        [_mSearchBar sizeToFit];
        _mSearchBar.placeholder = @"搜索客户";
        _mSearchBar.delegate = self;
    }
    return _mSearchBar;
}

- (UIButton*)bottomButton {
    if (!_bottomButton) {
        _bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _bottomButton.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];
        [_bottomButton setWidth:kScreen_Width];
        [_bottomButton setHeight:44];
        [_bottomButton setY:kScreen_Height - 44];
        [_bottomButton addLineUp:YES andDown:NO];
        [_bottomButton addTarget:self action:@selector(selectedButtonPress) forControlEvents:UIControlEventTouchUpInside];
        
        [_bottomButton addSubview:self.bottomLabel];
        [_bottomButton addSubview:self.bottomAccessory];
    }
    return _bottomButton;
}

- (UILabel*)bottomLabel {
    if (!_bottomLabel) {
        _bottomLabel = [[UILabel alloc] init];
        [_bottomLabel setX:15];
        [_bottomLabel setWidth:kScreen_Width - 30];
        [_bottomLabel setHeight:CGRectGetHeight(_bottomButton.bounds)];
        _bottomLabel.font = [UIFont systemFontOfSize:15];
        _bottomLabel.textAlignment = NSTextAlignmentLeft;
        _bottomLabel.textColor = [UIColor iOS7darkGrayColor];
    }
    return _bottomLabel;
}

- (UIImageView*)bottomAccessory {
    if (!_bottomAccessory) {
        UIImage *image = [UIImage imageNamed:@"activity_Arrow"];
        _bottomAccessory = [[UIImageView alloc] initWithImage:image];
        [_bottomAccessory setWidth:image.size.width];
        [_bottomAccessory setHeight:image.size.height];
        [_bottomAccessory setX:kScreen_Width - image.size.width - 15];
        [_bottomAccessory setCenterY:CGRectGetHeight(_bottomButton.bounds) / 2];
    }
    return _bottomAccessory;
}

- (CustomTitleView *)titleView {
    if (!_titleView) {
        _titleView = [[CustomTitleView alloc] init];
        _titleView.cellType = CellTypeDefault;
        _titleView.superViewController = self;
    }
    return _titleView;
}

- (NSMutableArray *)searchArray {
    if (!_searchArray) {
        _searchArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _searchArray;
}

- (NSMutableDictionary *)searchParams {
    if (!_searchParams) {
        _searchParams = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
        [_searchParams setObject:@1 forKey:@"pageNo"];
        [_searchParams setObject:@20 forKey:@"pageSize"];
    }
    return _searchParams;
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
