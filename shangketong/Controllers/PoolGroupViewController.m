//
//  PoolGroupViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PoolGroupViewController.h"
#import "Net_APIManager.h"
#import "SaleLeadPool.h"
#import "CustomerPool.h"
#import "PoolGroupTableViewCell.h"
#import "MJRefresh.h"

#import "LeadNewViewController.h"
#import "CustomerNewViewController.h"

#define kCellIdentifier @"PoolGroupTableViewCell"

@interface PoolGroupViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UILabel *bottomLabel;
@property (strong, nonatomic) UISearchBar *mSearchBar;
@property (strong, nonatomic) UISearchDisplayController *mSearchDisplayController;
@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableArray *searchResult;
@property (strong, nonatomic) NSMutableDictionary *params;
@property (assign, nonatomic) BOOL isSearch;

- (void)sendRequest;
- (void)getPoolWithIndex:(NSInteger)index;
- (void)newSaleLead;
- (void)newCustomer;
@end

@implementation PoolGroupViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    self.automaticallyAdjustsScrollViewInsets = NO;

    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightButtonItemPress)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.bottomView];
    
    _mSearchDisplayController = ({
        UISearchDisplayController *searchVC = [[UISearchDisplayController alloc] initWithSearchBar:_mSearchBar contentsController:self];
        [searchVC.searchResultsTableView registerClass:[PoolGroupTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        searchVC.searchResultsTableView.tableFooterView = [[UIView alloc] init];
        searchVC.delegate = self;
        searchVC.searchResultsDataSource = self;
        searchVC.searchResultsDelegate = self;
        searchVC.displaysSearchBarInNavigationBar = NO;
        searchVC.searchBar.tintColor = LIGHT_BLUE_COLOR;
        searchVC;
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _params = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [_params setObject:_groupId forKey:@"id"];
    [_params setObject:@1 forKey:@"pageNo"];
    [_params setObject:@20 forKey:@"pageSize"];
    
    _bottomLabel.text = [NSString stringWithFormat:@"已领取%@:%@", (_poolType ? @"客户数" : @"线索数"), _bottomString];
    
    
    [self.view beginLoading];
    [self sendRequest];
    
    [_tableView addHeaderWithTarget:self action:@selector(sendRequestForRefresh)];
    [_tableView addFooterWithTarget:self action:@selector(sendRequestForReloadMore)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
- (void)sendRequest {
    [[Net_APIManager sharedManager] request_Pool_DetailList_WithType:_poolType params:_params block:^(id data, NSError *error) {
        [_tableView headerEndRefreshing];
        [_tableView footerEndRefreshing];
        if (data) {
            [self.view endLoading];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            if (!_poolType) {
                for (NSDictionary *tempDict in data[@"saleLeads"]) {
                    SaleLeadPool *saleLead = [NSObject objectOfClass:@"SaleLeadPool" fromJSON:tempDict];
                    [tempArray addObject:saleLead];
                }
            }else {
                for (NSDictionary *tempDict in data[@"customers"]) {
                    CustomerPool *customer = [NSObject objectOfClass:@"CustomerPool" fromJSON:tempDict];
                    [tempArray addObject:customer];
                }
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
            
            if (_sourceArray.count) {
                _tableView.tableFooterView = [[UIView alloc] init];
            }
            else {
                _tableView.tableFooterView = self.footerView;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
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

- (void)sendRequestForRefresh {
    [_params setObject:@1 forKey:@"pageNo"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequest];
    });
}

- (void)sendRequestForReloadMore {
    [_params setObject:@([_params[@"pageNo"] integerValue] + 1) forKey:@"pageNo"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequest];
    });
}

- (void)getPoolWithIndex:(NSInteger)index {
    
    id obj;
    if (_isSearch) {
        obj = _searchResult[index];
    }else {
        obj = _sourceArray[index];
    }
    
    NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [tempParams setObject:_groupId forKey:@"id"];
    if ([obj isKindOfClass:[SaleLeadPool class]]) {
        SaleLeadPool *saleLead = obj;
        [tempParams setObject:saleLead.id forKey:@"saleLeadId"];
    }else {
        CustomerPool *customer = obj;
        [tempParams setObject:customer.id forKey:@"customerId"];
    }
    
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_Pool_Get_WithType:_poolType params:tempParams block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            // 刷新公海池列表
            if (self.refreshBlock) {
                self.refreshBlock();
            }
            
            if ([obj isKindOfClass:[SaleLeadPool class]]) {
                SaleLeadPool *saleLead = obj;
                saleLead.isGet = YES;
                
                if (_isSearch) {
                    int i = 0;
                    for (SaleLeadPool *tempItem in _sourceArray) {
                        i ++;
                        if ([tempItem.id isEqualToNumber:saleLead.id]) {
                            break;
                        }
                    }
                }
            }else {
                CustomerPool *customer = obj;
                customer.isGet = YES;
                
                if (_isSearch) {
                    int i = 0;
                    for (CustomerPool *tempItem in _sourceArray) {
                        i ++;
                        if ([tempItem.id isEqualToNumber:customer.id]) {
                            tempItem.isGet = YES;
                            break;
                        }
                    }
                }
            }
            
            if (_isSearch) {
                [_mSearchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }else {
                [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
        }else {
            NSLog(@"领取失败");
        }
    }];
}

- (void)scanningSaleLead {
    
    NSMutableDictionary *tempParams = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [tempParams setObject:_groupId forKey:@"groupId"];
    
    LeadNewViewController *scanningController = [[LeadNewViewController alloc] init];
    scanningController.title = @"创建销售线索";
    scanningController.params = tempParams;
    scanningController.isScanning = YES;
    scanningController.refreshBlock = ^{
        [self sendRequestForRefresh];
    };
    [self.navigationController pushViewController:scanningController animated:YES];
}

- (void)scanningCustomer {
    NSMutableDictionary *tempParams = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [tempParams setObject:_groupId forKey:@"groupId"];
    
    CustomerNewViewController *newController = [[CustomerNewViewController alloc] init];
    newController.title = @"创建客户";
    newController.params = tempParams;
    newController.isScanning = YES;
    newController.refreshBlock = ^{
        [self sendRequestForRefresh];
    };
    [self.navigationController pushViewController:newController animated:YES];
}

- (void)newSaleLead {
    
    NSMutableDictionary *tempParams = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [tempParams setObject:_groupId forKey:@"groupId"];
    
    LeadNewViewController *newController = [[LeadNewViewController alloc] init];
    newController.title = @"创建销售线索";
    newController.params = tempParams;
    newController.refreshBlock = ^{
        [self sendRequestForRefresh];
    };
    [self.navigationController pushViewController:newController animated:YES];
}

- (void)newCustomer {
    NSMutableDictionary *tempParams = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [tempParams setObject:_groupId forKey:@"groupId"];
    
    CustomerNewViewController *newController = [[CustomerNewViewController alloc] init];
    newController.title = @"创建客户";
    newController.params = tempParams;
    newController.refreshBlock = ^{
        [self sendRequestForRefresh];
    };
    [self.navigationController pushViewController:newController animated:YES];
}

#pragma mark - event response
- (void)rightButtonItemPress {
    @weakify(self);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *scanfAction = [UIAlertAction actionWithTitle:@"名片扫描" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        @strongify(self);
        if (!self.poolType) {   // 新建销售线索
            [self scanningSaleLead];
        }else {     // 新建客户
            [self scanningCustomer];
        }
    }];
    UIAlertAction *inputAction = [UIAlertAction actionWithTitle:@"手工输入" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        @strongify(self);
        if (!self.poolType) {   // 新建销售线索
            [self newSaleLead];
        }else {     // 新建客户
            [self newCustomer];
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:scanfAction];
    [alertController addAction:inputAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _mSearchDisplayController.searchResultsTableView) {
        return _searchResult.count;
    }
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_poolType) {
        return 84.0f;
    }else {
        return 64.0f;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PoolGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.receiveBtn.tag = indexPath.row;
    if (tableView == _mSearchDisplayController.searchResultsTableView) {
        [cell configWithObj:_searchResult[indexPath.row]];
    }else {
        [cell configWithObj:_sourceArray[indexPath.row]];
    }
    cell.receiveBtnClickedBlock = ^(NSInteger index) {
        [self getPoolWithIndex:index];
    };
    return cell;
}

#pragma mark UISearchDisplayDelegate M
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self updateFilteredContentForSearchString:searchString];
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
    _isSearch = YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    _isSearch = NO;
    [_tableView reloadData];
}

- (void)updateFilteredContentForSearchString:(NSString *)searchString {
    DebugLog(@"\n%@", searchString);
    
    // start out with the entire list
    NSMutableArray *searchArray = [_sourceArray mutableCopy];
    
    NSString *keyName = _poolType ? [CustomerPool keyName] : [SaleLeadPool keyName];
    
    // 模糊查找
    NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", keyName, searchString];
    
    _searchResult = [[searchArray filteredArrayUsingPredicate:predicateString] mutableCopy];
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setY:64.0f];
        [_tableView setWidth:kScreen_Width];
        [_tableView setHeight:kScreen_Height - CGRectGetMinY(_tableView.frame) - 44.0f];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[PoolGroupTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.tableHeaderView = self.mSearchBar;
    }
    return _tableView;
}

- (UIView*)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] init];
        [_footerView setWidth:kScreen_Width];
        [_footerView setHeight:300];
        
        UIImage *image = [UIImage imageNamed:@"list_empty"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [imageView setWidth:image.size.width];
        [imageView setHeight:image.size.height];
        [imageView setCenterX:kScreen_Width / 2];
        [imageView setCenterY:CGRectGetHeight(_footerView.bounds) / 2 - 15];
        [_footerView addSubview:imageView];
        
        UILabel *tipLabel = [[UILabel alloc] init];
        [tipLabel setY:CGRectGetMaxY(imageView.frame)];
        [tipLabel setWidth:kScreen_Width];
        [tipLabel setHeight:30];
        tipLabel.font = [UIFont systemFontOfSize:15];
        tipLabel.textColor = [UIColor lightGrayColor];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.text = _poolType ? @"暂无可领取客户" : @"暂无可领取销售线索";
        [_footerView addSubview:tipLabel];
    }
    return _footerView;
}

- (UIView*)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        [_bottomView setY:kScreen_Height - 44.0f];
        [_bottomView setWidth:kScreen_Width];
        [_bottomView setHeight:44.0f];
        _bottomView.backgroundColor = kView_BG_Color;
        [_bottomView addLineUp:YES andDown:NO];
        
        [_bottomView addSubview:self.bottomLabel];
    }
    return _bottomView;
}

- (UILabel*)bottomLabel {
    if (!_bottomLabel) {
        _bottomLabel = [[UILabel alloc] init];
        [_bottomLabel setX:15];
        [_bottomLabel setWidth:kScreen_Width - 30];
        [_bottomLabel setHeight:20];
        [_bottomLabel setCenterY:CGRectGetHeight(_bottomView.bounds) / 2.0];
        _bottomLabel.font = [UIFont systemFontOfSize:15];
        _bottomLabel.textAlignment = NSTextAlignmentLeft;
        _bottomLabel.textColor = [UIColor iOS7lightBlueColor];
    }
    return _bottomLabel;
}

- (UISearchBar*)mSearchBar {
    if (!_mSearchBar) {
        _mSearchBar = [[UISearchBar alloc] init];
        _mSearchBar.delegate = self;
        [_mSearchBar sizeToFit];
        [_mSearchBar setPlaceholder:@"搜索"];
        _mSearchBar.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
    }
    return _mSearchBar;
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
