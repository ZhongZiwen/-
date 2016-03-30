//
//  AddressBookBaseController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/12/12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AddressBookBaseController.h"

@interface AddressBookBaseController ()

@property (strong, nonatomic) NSMutableDictionary *params;
@end

@implementation AddressBookBaseController

NSInteger nickNameSort(id user1, id user2, void *context) {
    AddressBook *u1,*u2;
    //类型转换
    u1 = (AddressBook*)user1;
    u2 = (AddressBook*)user2;
    return  [u1.pinyin localizedCompare:u2.pinyin];
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    [self.view addSubview:self.tableView];
    _mSearchDisplayController = ({
        UISearchDisplayController *searchVC = [[UISearchDisplayController alloc] initWithSearchBar:_mSearchBar contentsController:self];
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
    
    [[FMDBManagement sharedFMDBManager] creatAddressBookTable];
    [[FMDBManagement sharedFMDBManager] creatRecentlyAddressBookTable];
    
    _groupsArray = [[NSMutableArray alloc] initWithCapacity:0];
    _searchResults = [[NSMutableArray alloc] initWithCapacity:0];
    _sourceArray = [[FMDBManagement sharedFMDBManager] getAddressBookDataSource];
    
    if (_sourceArray && _sourceArray.count) {
        [self groupingDataSourceFrom:_sourceArray to:_groupsArray];
        // 排序
        [self sortForArray:_groupsArray];
    }

    // 请求时间
    NSString *serverTime = [[NSUserDefaults standardUserDefaults] objectForKey:kAddressBookServerTime];
    _params = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    if (serverTime) {
        [_params setObject:serverTime forKey:kAddressBookServerTime];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - public method
- (void)sendRequest {
    [[Net_APIManager sharedManager] request_Address_List_WithParams:_params andBlock:^(id data, NSError *error) {
        if (data) {
            [self.view endLoading];
            // 保存serverTime
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:data[@"serverTime"] forKey:kAddressBookServerTime];
            [defaults synchronize];
            
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"users"]) {
                AddressBook *item = [NSObject objectOfClass:@"AddressBook" fromJSON:tempDict];
                [tempArray addObject:item];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (tempArray.count) {
                    [[FMDBManagement sharedFMDBManager] updateAddressBookWithArray:tempArray];
                    _sourceArray = [[FMDBManagement sharedFMDBManager] getAddressBookDataSource];
                    [self groupingDataSourceFrom:_sourceArray to:_groupsArray];
                    // 排序
                    [self sortForArray:_groupsArray];
                }
                [_tableView reloadData];
            });
            
//            [_tableView configBlankPageWithTitle:@"暂无通讯录" hasData:_groupsArray.count hasError:NO reloadButtonBlock:nil];
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
    
    // 对每组的数组元素进行排序
    for (AddressBookGroup *group in toArray) {
        NSArray *sortArrary = [group.groupItems sortedArrayUsingFunction:nickNameSort context:NULL];
        [group.groupItems removeAllObjects];
        group.groupItems = [NSMutableArray arrayWithArray:sortArrary];
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

- (void)sortForArray:(NSMutableArray*)array {
    [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        AddressBookGroup *group1 = obj1;
        AddressBookGroup *group2 = obj2;
        
        return [group1.groupName compare:group2.groupName];
    }];
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UISearchDisplayDelegate M
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.mSearchBar.showsCancelButton = YES;
    for(id cc in [self.mSearchBar.subviews[0] subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            [btn setTitle:@"取消"  forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        if([cc isKindOfClass:[UITextField class]])
        {
            UITextField *txt = (UITextField *)cc;
            txt.placeholder = @"搜索";
        }
    }
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self updateFilteredContentForSearchString2:searchString];
    return NO;
}

- (void)updateFilteredContentForSearchString:(NSString *)searchString {
    DebugLog(@"\n%@", searchString);
    // start out with the entire list
    NSMutableArray *searchArray = [_sourceArray mutableCopy];
    for (AddressBook *tempItem in searchArray) {
        NSLog(@"name = %@", tempItem.name);
        NSLog(@"pinyin = %@", tempItem.name);
    }
    
    NSString *keyName = [AddressBook keyName];
 
    // 模糊查找
    NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", keyName, searchString];
    // 精确查找
    //    NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"%K == %@", keyName, searchString];
    
    // 分组
    [self groupingDataSourceFrom:[[searchArray filteredArrayUsingPredicate:predicateString] mutableCopy] to:_searchResults];
    
    // 排序
    [self sortForArray:_searchResults];
}


- (void)updateFilteredContentForSearchString2:(NSString *)searchString {
    DebugLog(@"\n%@", searchString);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *searchArray = [_sourceArray mutableCopy];
        NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (AddressBook *tempItem in searchArray) {
//            NSLog(@"name = %@", tempItem.name);
//            NSLog(@"pinyin = %@", tempItem.pinyin);
            //拼音
            if([CommonFuntion searchResult:tempItem.pinyin searchText:searchString])
            {
                [resultArray addObject:tempItem];
            }else{
                //首字母
                NSString * firstLetter = [CommonFuntion namToPinYinFisrtNameWith:tempItem.name];
                if([CommonFuntion searchResult:firstLetter searchText:searchString]){
                    [resultArray addObject:tempItem];
                }else if ([CommonFuntion searchResult:tempItem.name searchText:searchString]){
                    ///汉字
                    [resultArray addObject:tempItem];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // 分组
            [self groupingDataSourceFrom:resultArray to:_searchResults];
            // 排序
            [self sortForArray:_searchResults];
            [_mSearchDisplayController.searchResultsTableView reloadData];
        });
    });
}


-(BOOL)searchResult:(NSString *)sourceT searchText:(NSString *)searchT{
    if (sourceT==nil || searchT == nil || [sourceT isEqualToString:@"(null)"]==YES) {
        return NO;
    }
    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    NSRange productNameRange = NSMakeRange(0, sourceT.length);
    NSRange foundRange = [sourceT rangeOfString:searchT options:searchOptions range:productNameRange];
    if (foundRange.length > 0)
        return YES;
    else
        return NO;
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _tableView.sectionIndexColor = [UIColor lightGrayColor];
        _tableView.tableHeaderView = self.mSearchBar;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.tableHeaderView.backgroundColor = COMM_SEARCHBAR_BACKGROUNDCOLOR;
        _tableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
        _tableView.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;

    }
    return _tableView;
}

- (UISearchBar*)mSearchBar {
    if (!_mSearchBar) {
        _mSearchBar = [[UISearchBar alloc] init];
        _mSearchBar.delegate = self;
        [_mSearchBar sizeToFit];
        [_mSearchBar setPlaceholder:@"搜索"];
//        _mSearchBar.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
//        _mSearchBar.backgroundColor = COMM_SEARCHBAR_BACKGROUNDCOLOR;
        [_mSearchBar setBackgroundImage:[CommonFuntion createImageWithColor:COMM_SEARCHBAR_BACKGROUNDCOLOR]];
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
