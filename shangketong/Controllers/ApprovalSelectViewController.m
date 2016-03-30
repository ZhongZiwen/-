//
//  ApprovalSelectViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/26.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ApprovalSelectViewController.h"
#import "AddressBookTableViewCell.h"
#import "AddressBook.h"
#import "AddressBookGroup.h"
#import "AFNHttp.h"
#import "UIColor+expanded.h"
#import <MBProgressHUD.h>

#define kCellIdentifier @"AddressBookTableViewCell"

@interface ApprovalSelectViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) UISearchBar *mySearchBar;
@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, strong) NSMutableArray *sourceArray;
@property (nonatomic, strong) NSMutableArray *groupArray;       // 保存分组后的数据
@property (nonatomic, strong) NSMutableArray *searchResults;    // 保存搜索后的数据

- (void)groupingDataSourceFrom:(NSMutableArray*)fromArray to:(NSMutableArray*)toArray;
@end

@implementation ApprovalSelectViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    self.title = @"选择审批人";
    
    // 自定义返回按钮 开启手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(leftButtonItemPress)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    [self.view addSubview:self.myTableView];
    _mySearchDisplayController = ({
        UISearchDisplayController *searchVC = [[UISearchDisplayController alloc] initWithSearchBar:_mySearchBar contentsController:self];
        [searchVC.searchResultsTableView registerClass:[AddressBookTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
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
    
    _sourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    _groupArray = [[NSMutableArray alloc] initWithCapacity:0];
    _searchResults = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (_approvalReveiwer && _approvalReveiwer.count) {
        for (NSDictionary *tempDict in _approvalReveiwer) {
            AddressBook *item = [NSObject objectOfClass:@"AddressBook" fromJSON:tempDict];
            [_sourceArray addObject:item];
        }
        [self groupingDataSourceFrom:_sourceArray to:_groupArray];
    }else {
        NSMutableDictionary *params=[NSMutableDictionary dictionary];
        [params addEntriesFromDictionary:COMMON_PARAMS];
        ///updatedAt需要缓存
        [params setObject:[NSNumber numberWithLongLong:0] forKey:@"updatedAt"];
        
        // 发出请求
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        [hud show:YES];
        [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, ADDRESS_BOOK_ACTION] params:params success:^(id responseObj) {
            [hud hide:YES];
            if (responseObj) {
                for (NSDictionary *tempDict in responseObj[@"users"]) {
                    AddressBook *item = [NSObject objectOfClass:@"AddressBook" fromJSON:tempDict];
                    [_sourceArray addObject:item];
                }
                
                [self groupingDataSourceFrom:_sourceArray to:_groupArray];
                [self sortForArray:_groupArray];
                [_myTableView reloadData];
            }
        } failure:^(NSError *error) {
            [hud hide:YES];
            
        }];
    }
}
- (void)sortForArray:(NSMutableArray*)array {
    [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        AddressBookGroup *group1 = obj1;
        AddressBookGroup *group2 = obj2;
        
        return [group1.groupName compare:group2.groupName];
    }];
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
- (void)groupingDataSourceFrom:(NSMutableArray*)fromArray to:(NSMutableArray*)toArray {
    [toArray removeAllObjects];
    for (AddressBook *bookItem in fromArray) {
        if ([self checkAddressInArray:toArray withItem:bookItem]) {
            [self addAddressInArray:toArray withItem:bookItem];
        }else {
            AddressBookGroup *group = [AddressBookGroup initWithName:[bookItem getFirstName]];
            [group.groupItems addObject:bookItem];
            [toArray addObject:group];
        }
    }
}

- (BOOL)checkAddressInArray:(NSMutableArray*)array withItem:(AddressBook*)item {
    BOOL isSame = NO;
    for (AddressBookGroup *group in array) {
        if ([group.groupName isEqualToString:[item getFirstName]]) {
            isSame = YES;
        }
    }
    return isSame;
}

- (void)addAddressInArray:(NSMutableArray*)array withItem:(AddressBook*)item {
    for (AddressBookGroup *group in array) {
        if ([group.groupName isEqualToString:[item getFirstName]]) {
            [group.groupItems addObject:item];
        }
    }
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        if (_searchResults.count) {
            return _searchResults.count;
        }
        return 0;
    }
    return _groupArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        if (_searchResults.count) {
            AddressBookGroup *group = _searchResults[section];
            return group.groupItems.count;
        }
        return 0;
    }
    
    AddressBookGroup *group = _groupArray[section];
    return group.groupItems.count;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        if (_searchResults.count) {
            AddressBookGroup *group = _searchResults[section];
            return group.groupName;
        }
        return @"";
    }
    
    AddressBookGroup *group = _groupArray[section];
    return group.groupName;
}

// 索引
- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        return nil;
    }
    
    NSMutableArray *indexs = [NSMutableArray array];
    for (AddressBookGroup *group in _groupArray) {
        [indexs addObject:group.groupName];
    }
    return indexs;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AddressBookTableViewCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddressBookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        AddressBookGroup *group = _searchResults[indexPath.section];
        [cell configWithoutButtonWithModel:group.groupItems[indexPath.row]];
    }else {
        AddressBookGroup *group = _groupArray[indexPath.section];
        [cell configWithoutButtonWithModel:group.groupItems[indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        NSLog(@"搜索后的数据");
        AddressBookGroup *group = _searchResults[indexPath.section];
        AddressBook *item = group.groupItems[indexPath.row];
        
        if (self.valueBlock) {
            self.valueBlock(@{@"name" : item.name,
                              @"id" : item.id});
            [self.navigationController popViewControllerAnimated:YES];
        }
        return;
    }
    
    AddressBookGroup *group = _groupArray[indexPath.section];
    AddressBook *item = group.groupItems[indexPath.row];
    
    if (self.valueBlock) {
        self.valueBlock(@{@"name" : item.name,
                          @"id" : item.id});
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark UISearchDisplayDelegate M
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self updateFilteredContentForSearchString:searchString];
    return YES;
}

- (void)updateFilteredContentForSearchString:(NSString *)searchString {
    DebugLog(@"\n%@", searchString);
    
    // start out with the entire list
    NSMutableArray *searchArray = [_sourceArray mutableCopy];
    
    NSString *keyName = [AddressBook keyName];
    
    // 模糊查找
    NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", keyName, searchString];
    // 精确查找
    //    NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"%K == %@", keyName, searchString];
    
    [self groupingDataSourceFrom:[[searchArray filteredArrayUsingPredicate:predicateString] mutableCopy] to:_searchResults];
}

#pragma mark - setters and getters
- (UITableView*)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        [_myTableView registerClass:[AddressBookTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        _myTableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _myTableView.sectionIndexColor = [UIColor lightGrayColor];
        _myTableView.tableHeaderView = self.mySearchBar;
        _myTableView.tableFooterView = [[UIView alloc] init];
    }
    return _myTableView;
}

- (UISearchBar*)mySearchBar {
    if (!_mySearchBar) {
        _mySearchBar = [[UISearchBar alloc] init];
        _mySearchBar.delegate = self;
        [_mySearchBar sizeToFit];
        [_mySearchBar setPlaceholder:@"搜索"];
        _mySearchBar.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
    }
    return _mySearchBar;
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
