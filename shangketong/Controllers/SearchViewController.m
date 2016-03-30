//
//  SearchViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResultListController.h"
#import "ActivityModel.h"
#import "ActivityCell.h"
#import "ActivityDetailViewController.h"
#import "Lead.h"
#import "LeadTableViewCell.h"
#import "LeadDetailViewController.h"
#import "Customer.h"
#import "CustomerTableViewCell.h"
#import "CustomerDetailViewController.h"
#import "Contact.h"
#import "ContactTableViewCell.h"
#import "ContactDetailViewController.h"
#import "SaleChance.h"
#import "OpportunityTableViewCell.h"
#import "OpportunityDetailController.h"
#import "CommonNoDataView.h"

#define kCellIdentifier @"UITableViewCell"
#define kCellIdentifier_activity @"ActivityCell"
#define kCellIdentifier_lead @"LeadTableViewCell"
#define kCellIdentifier_customer @"CustomerTableViewCell"
#define kCellIdentifier_contact @"ContactTableViewCell"
#define kCellIdentifier_opportunity @"OpportunityTableViewCell"

@interface SearchViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, SWTableViewCellDelegate>

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UISearchBar *mSearchBar;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *footTableView;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *searchButton;

@property (assign, nonatomic) BOOL isSearch;
@property (assign, nonatomic) BOOL isDetail;
@property (assign, nonatomic) NSTimeInterval animationDuration;
@property (copy, nonatomic) NSString *requestPath;
@property (copy, nonatomic) NSString *tableName;
@property (copy, nonatomic) NSString *casheSearch;
@property (copy, nonatomic) NSString *searchText;
@property (strong, nonatomic) NSMutableArray *searchArray;
@property (strong, nonatomic) NSMutableArray *casheArray;
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property (nonatomic, strong) NSString *searchTypeStr;
@property (nonatomic, strong) NSString *searchImage;
@end

@implementation SearchViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    [self.view addSubview:self.bgView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.searchButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    _casheArray = [[FMDBManagement sharedFMDBManager] getCRMSearchDataSourceWithTableName:_tableName];
    if (_casheArray.count && !_isSearch) {
        _tableView.tableFooterView = self.footTableView;
    }
    else {
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    if (_casheArray.count > 0) {
        //这里清除图标
        [self clearViewNoData];
    } else {
        //在这个地方添加搜索图标
        [self setViewNoData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _isDetail = NO;
    [self.mSearchBar becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_isDetail) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    switch (_searchType) {
        case SearchViewControllerTypeActivity:
            _mSearchBar.placeholder = @"搜索市场活动";
            _requestPath = kNetPath_Activity_List;
            _tableName = kTableName_activity;
            _casheSearch = kSearch_activity;
            _searchTypeStr = @"市场活动";
            _searchImage = @"icon_search_activity";
            break;
        case SearchViewControllerTypeLead:
            _mSearchBar.placeholder = @"搜索销售线索";
            _requestPath = kNetPath_Lead_List;
            _tableName = kTableName_lead;
            _casheSearch = kSearch_lead;
            _searchTypeStr = @"销售线索";
            _searchImage = @"icon_search_lead";
            break;
        case SearchViewControllerTypeCustomer:
            _mSearchBar.placeholder = @"搜索客户";
            _requestPath = kNetPath_Customer_List;
            _tableName = kTableName_customer;
            _casheSearch = kSearch_customer;
            _searchTypeStr = @"客户";
            _searchImage = @"icon_search_customer";
            break;
        case SearchViewControllerTypeContact:
            _mSearchBar.placeholder = @"搜索联系人";
            _requestPath = kNetPath_Contact_List;
            _tableName = kTableName_contact;
            _casheSearch = kSearch_contact;
            _searchTypeStr = @"联系人";
            _searchImage = @"icon_search_contact";
            break;
        case SearchViewControllerTypeOpportunity:
            _mSearchBar.placeholder = @"搜索销售机会";
            _requestPath = kNetPath_SaleChance_List;
            _tableName = kTableName_opportunity;
            _casheSearch = kSearch_opportunity;
            _searchTypeStr = @"销售机会";
            _searchImage = @"icon_search_opportunity";
            break;
        default:
            break;
    }
    
    [[FMDBManagement sharedFMDBManager] createCRMSearchTableWithName:_tableName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KeyBoard Notification Handlers
- (void)keyboardChange:(NSNotification*)notification {
    if ([notification name] == UIKeyboardDidChangeFrameNotification) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    }
    
    if ([_mSearchBar isFirstResponder]) {
        NSDictionary *userInfo = [notification userInfo];
        _animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
        CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        [_tableView setHeight:kScreen_Height - 64.0 - 44.0f];
        
        [UIView animateWithDuration:_animationDuration delay:0.0f options:[UIView animationOptionsForCurve:animationCurve] animations:^{
            CGFloat keyboardY = keyboardEndFrame.origin.y;
            if (ABS(keyboardY - kScreen_Height) < 0.1) {
                [_searchButton setY:kScreen_Height - CGRectGetHeight(_searchButton.bounds)];
            }else {
                [_searchButton setY:keyboardY - CGRectGetHeight(_searchButton.bounds)];
            }
        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark - UIScrollviewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_mSearchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
//    if (_isSearch) {
//        return;
//    }
//    
//    _isSearch = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    _searchText = searchText;
    
    // 显示缓存数据
    if (!searchText.length) {
        _isSearch = NO;
        [_searchArray removeAllObjects];
        
        if (_casheArray.count) {
            _tableView.tableFooterView = self.footTableView;
        }
        else {
            _tableView.tableFooterView = nil;
            [self setViewNoData];
        }
        [_tableView.blankPageView removeFromSuperview];
        [_tableView reloadData];
        _searchButton.enabled = NO;
        return;
    }
    
    _tableView.tableFooterView = [[UIView alloc] init];
    _isSearch = YES;
    _searchButton.enabled = YES;
    
    NSMutableArray *tempSearchArray = [_sourceArray mutableCopy];
    NSString *keyName;
    switch (_searchType) {
        case SearchViewControllerTypeActivity: {
            keyName = [ActivityModel keyName];
        }
            break;
        case SearchViewControllerTypeLead: {
            keyName = [Lead keyName];
        }
            break;
        case SearchViewControllerTypeCustomer: {
            keyName = [Customer keyName];
        }
            break;
        case SearchViewControllerTypeContact: {
            keyName = [Contact keyName];
        }
            break;
        case SearchViewControllerTypeOpportunity: {
            keyName = [SaleChance keyName];
        }
            break;
        default:
            break;
    }
    
    NSPredicate *preicate = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", keyName, searchText];
    _searchArray = [[NSMutableArray alloc] initWithArray:[tempSearchArray filteredArrayUsingPredicate:preicate]];
    [self clearViewNoData];
    [_tableView reloadData];
    [_tableView configBlankPageWithTitle:@"无数据" hasData:_searchArray.count hasError:NO reloadButtonBlock:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isSearch) {
        return _searchArray.count;
    }
    
    if (_casheArray.count) {
        return _casheArray.count + 2;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_isSearch && !indexPath.row) {
        return 44.0f;
    }
    else if (!_isSearch && indexPath.row == 1) {
        return 30.0f;
    }
    else {
        switch (_searchType) {
            case SearchViewControllerTypeActivity:
                return [ActivityCell cellHeight];
                break;
            case SearchViewControllerTypeLead:
                return [LeadTableViewCell cellHeight];
                break;
            case SearchViewControllerTypeCustomer:
                return [CustomerTableViewCell cellHeight];
                break;
            case SearchViewControllerTypeContact:
                return [ContactTableViewCell cellHeight];
                break;
            case SearchViewControllerTypeOpportunity:
                return [OpportunityTableViewCell cellHeight];
            default:
                break;
        }
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!_isSearch && !indexPath.row) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"0x8899a6"];
        cell.textLabel.text = [NSString stringWithFormat:@"查找“%@”", [[NSUserDefaults standardUserDefaults] objectForKey:_casheSearch]];
        return cell;
    }
    else if (!_isSearch && indexPath.row == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
        cell.contentView.backgroundColor = [UIColor iOS7lightGrayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.backgroundColor = [UIColor iOS7lightGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.textLabel.textColor = [UIColor iOS7darkGrayColor];
        cell.textLabel.text = @"搜索历史";
        return cell;
    }
    else {
        id obj;
        if (_isSearch) {
            obj = _searchArray[indexPath.row];
        }
        else {
            obj = _casheArray[indexPath.row - 2];
        }
        
        switch (_searchType) {
            case SearchViewControllerTypeActivity: {
                ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_activity forIndexPath:indexPath];
                ActivityModel *item = obj;
                [cell configWithItem:item isSwipeable:NO];
                [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:10.f];
                return cell;
            }
                break;
            case SearchViewControllerTypeLead: {
                LeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_lead forIndexPath:indexPath];
                Lead *item = obj;
                [cell configWithModel:item];
                [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:10.f];
                return cell;
            }
                break;
            case SearchViewControllerTypeCustomer: {
                CustomerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_customer forIndexPath:indexPath];
                Customer *item = obj;
                [cell configWithModel:item];
                [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:10.f];
                return cell;
            }
                break;
            case SearchViewControllerTypeContact: {
                ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_contact forIndexPath:indexPath];
                Contact *item = obj;
                [cell configWithModel:item];
                [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:10.f];
                return cell;
            }
                break;
            case SearchViewControllerTypeOpportunity: {
                OpportunityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_opportunity forIndexPath:indexPath];
                SaleChance *item = obj;
                [cell configWithModel:item];
                [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:10.f];
                return cell;
            }
                break;
            default:
                break;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!_isSearch && !indexPath.row) {
        NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:_casheSearch];
        _mSearchBar.text = string;
        [self searchBar:_mSearchBar textDidChange:string];
        return;
    }
    else if (!_isSearch && indexPath.row == 1) {
        return;
    }
    
    id obj;
    if (_isSearch) {
        obj = _searchArray[indexPath.row];
        // 保存关键字
        [[NSUserDefaults standardUserDefaults] setObject:_searchText forKey:_casheSearch];
        // 保存搜索历史
        [[FMDBManagement sharedFMDBManager] casheCRMSearchDataSourceWithTableName:_tableName item:obj];
    }
    else {
        obj = _casheArray[indexPath.row - 2];
    }
    
    [_mSearchBar resignFirstResponder];
    
    _isDetail = YES;
    
    switch (_searchType) {
        case SearchViewControllerTypeActivity: {
            ActivityModel *item = obj;
            ActivityDetailViewController *detailController = [[ActivityDetailViewController alloc] init];
            detailController.title = @"市场活动";
            detailController.id = item.id;
            [self.navigationController pushViewController:detailController animated:YES];
        }
            break;
        case SearchViewControllerTypeLead: {
            Lead *item = obj;
            LeadDetailViewController *leadDetailController = [[LeadDetailViewController alloc] init];
            leadDetailController.title = @"销售线索";
            leadDetailController.id = item.id;
            [self.navigationController pushViewController:leadDetailController animated:YES];
        }
            break;
        case SearchViewControllerTypeCustomer: {
            Customer *item = obj;
            CustomerDetailViewController *customerDetailController = [[CustomerDetailViewController alloc] init];
            customerDetailController.title = @"客户";
            customerDetailController.id = item.id;
            [self.navigationController pushViewController:customerDetailController animated:YES];
        }
            break;
        case SearchViewControllerTypeContact: {
            Contact *item = obj;
            ContactDetailViewController *contactDetailController = [[ContactDetailViewController alloc] init];
            contactDetailController.title = @"联系人";
            contactDetailController.id = item.id;
            [self.navigationController pushViewController:contactDetailController animated:YES];
        }
            break;
        case SearchViewControllerTypeOpportunity: {
            SaleChance *item = obj;
            OpportunityDetailController *detailController = [[OpportunityDetailController alloc] init];
            detailController.title = @"销售机会";
            detailController.id = item.id;
            [self.navigationController pushViewController:detailController animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - event response
- (void)backButtonPress {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchButtonPress {
    SearchResultListController *resultListController = [[SearchResultListController alloc] init];
    resultListController.title = @"搜索结果";
    resultListController.searchType = _searchType;
    resultListController.searchName = _searchText;
    resultListController.requestPath = _requestPath;
    [self.navigationController pushViewController:resultListController animated:YES];
}

- (void)clearButtonPress {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:_casheSearch];
    [[FMDBManagement sharedFMDBManager] deleteCRMSearchDataSourceWithTableName:_tableName];
    
    [_casheArray removeAllObjects];
    _tableView.tableFooterView = nil;
    //在这个地方添加搜索图标
    [self setViewNoData];
    [_tableView reloadData];
}

#pragma mark - setters and getters
- (UIView*)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        [_bgView setWidth:kScreen_Width];
        [_bgView setHeight:64.0f];
        _bgView.backgroundColor = [UIColor colorWithHexString:@"0x2e3440"];
        
        [_bgView addSubview:self.mSearchBar];
        [_bgView addSubview:self.backButton];
    }
    return _bgView;
}

- (UISearchBar*)mSearchBar {
    if (!_mSearchBar) {
        _mSearchBar = [[UISearchBar alloc] init];
        [_mSearchBar setX:0];
        [_mSearchBar setY:20];
        [_mSearchBar setWidth:kScreen_Width - 54];
        [_mSearchBar setHeight:44];
        _mSearchBar.delegate = self;
        _mSearchBar.placeholder = @"搜索市场活动";
        
        for (UIView *view in _mSearchBar.subviews) {
            if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
                [[view.subviews objectAtIndex:0] removeFromSuperview];
                break;
            }
        }
    }
    return _mSearchBar;
}

- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setY:64];
        [_tableView setWidth:kScreen_Width];
        [_tableView setHeight:kScreen_Height - CGRectGetMinY(_tableView.frame)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        [_tableView registerClass:[ActivityCell class] forCellReuseIdentifier:kCellIdentifier_activity];
        [_tableView registerClass:[LeadTableViewCell class] forCellReuseIdentifier:kCellIdentifier_lead];
        [_tableView registerClass:[CustomerTableViewCell class] forCellReuseIdentifier:kCellIdentifier_customer];
        [_tableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:kCellIdentifier_contact];
        [_tableView registerClass:[OpportunityTableViewCell class] forCellReuseIdentifier:kCellIdentifier_opportunity];
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (UIView*)footTableView {
    if (!_footTableView) {
        _footTableView = [[UIView alloc] init];
        [_footTableView setWidth:kScreen_Width];
        [_footTableView setHeight:54.0f];
        
        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [clearButton setWidth:kScreen_Width];
        [clearButton setHeight:54.0f];
        clearButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [clearButton setTitleColor:[UIColor colorWithHexString:@"0x8899a6"] forState:UIControlStateNormal];
        [clearButton setTitle:@"清空搜索历史" forState:UIControlStateNormal];
        [clearButton addTarget:self action:@selector(clearButtonPress) forControlEvents:UIControlEventTouchUpInside];
        [_footTableView addSubview:clearButton];
    }
    return _footTableView;
}

- (UIButton*)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setX:kScreen_Width - 54 - 10];
        [_backButton setY:20];
        [_backButton setWidth:64];
        [_backButton setHeight:44.0f];
        [_backButton setTitle:@"取消" forState:UIControlStateNormal];
        [_backButton setTitleColor:LIGHT_BLUE_COLOR forState:UIControlStateNormal];
        _backButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_backButton addTarget:self action:@selector(backButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIButton*)searchButton {
    if (!_searchButton) {
        _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_searchButton setY:kScreen_Height];
        [_searchButton setWidth:kScreen_Width];
        [_searchButton setHeight:44];
        _searchButton.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];
        [_searchButton addLineUp:YES andDown:NO andColor:[UIColor lightGrayColor]];
        _searchButton.enabled = NO;
        [_searchButton setImage:[UIImage imageNamed:@"search_server_icon"] forState:UIControlStateNormal];
        [_searchButton setTitle:@"点击搜索网络数据" forState:UIControlStateNormal];
        [_searchButton setTitleColor:[UIColor iOS7lightBlueColor] forState:UIControlStateNormal];
        [_searchButton addTarget:self action:@selector(searchButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchButton;
}

#pragma mark - 没有数据时的view
-(void)setViewNoData{
        if (self.commonNoDataView == nil) {
            self.commonNoDataView = [CommonFuntion CRMNoDataViewIcon:_searchImage Title:_searchTypeStr optionBtnTitle:@""];
        }
        [self.tableView addSubview:self.commonNoDataView];
}

-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
        [self.tableView layoutIfNeeded];
    }
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
