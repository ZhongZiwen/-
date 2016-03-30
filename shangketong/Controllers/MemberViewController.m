//
//  MemberViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MemberViewController.h"
#import "UIViewController+Expand.h"
#import "AddressBook.h"
#import "AddressBookGroup.h"
#import "AddressBookTableViewCell.h"
#import "AddressBookActionSheet.h"
#import "InfoViewController.h"
#import "DepartGroupModel.h"

#define kCellIdentifier @"AddressBookTableViewCell"

@interface MemberViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *mSearchDisplayController;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableArray *groupArray;
@property (strong, nonatomic) NSMutableArray *searchArray;
@end

@implementation MemberViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    [self.view addSubview:self.tableView];
    _mSearchDisplayController = ({
        UISearchDisplayController *searchVC = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self.tabBarController];
        [searchVC.searchResultsTableView registerClass:[AddressBookTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        searchVC.searchResultsTableView.tableFooterView = [[UIView alloc] init];
        searchVC.delegate = self;
        searchVC.searchResultsDataSource = self;
        searchVC.searchResultsDelegate = self;
        searchVC.displaysSearchBarInNavigationBar = NO;
        searchVC.searchResultsTableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
        searchVC.searchBar.tintColor = LIGHT_BLUE_COLOR;
        searchVC;
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _sourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    _groupArray = [[NSMutableArray alloc] initWithCapacity:0];
    _searchArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    if (_memberType == MemberViewControllerTypeDepartment) {
        [params setObject:_item.id forKey:@"departmentId"];
    }else {
        [params setObject:_item.id forKey:@"groupId"];
    }

    MBProgressHUD *hudView = [[MBProgressHUD alloc] initWithView:appDelegateAccessor.window];
    [appDelegateAccessor.window addSubview:hudView];
    [hudView show:YES];
    
    __weak typeof(self) weak_self = self;
    [[Net_APIManager sharedManager] request_Address_Member_List_WithParams:params memberType:_memberType andBlock:^(id data, NSError *error) {
        [hudView hide:YES];
        if (data) {
            if ([[data allKeys] containsObject:@"groupName"]) {
                weak_self.tabBarController.title = [data safeObjectForKey:@"groupName"];
            }
            for (NSDictionary *tempDict in data[@"users"]) {
                AddressBook *item = [NSObject objectOfClass:@"AddressBook" fromJSON:tempDict];
                [_sourceArray addObject:item];
            }
            
            // 分组
            [self groupingDataSourceFrom:_sourceArray to:_groupArray];
            
            // 排序
            [self sortForArray:_groupArray];
            
            [_tableView reloadData];
        }
        [_tableView configBlankPageWithTitle:@"暂无成员" hasData:_sourceArray.count hasError:error != nil reloadButtonBlock:nil];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
NSInteger memberSort(id user1, id user2, void *context)
{
    AddressBook *u1,*u2;
    //类型转换
    u1 = (AddressBook*)user1;
    u2 = (AddressBook*)user2;
    return  [u1.pinyin localizedCompare:u2.pinyin];
}

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
        NSArray *sortArrary = [group.groupItems sortedArrayUsingFunction:memberSort context:NULL];
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
    if (tableView == _mSearchDisplayController.searchResultsTableView) {
        return _searchArray.count;
    }
    
    return _groupArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _mSearchDisplayController.searchResultsTableView) {
        AddressBookGroup *group = _searchArray[section];
        return group.groupItems.count;
    }
    
    AddressBookGroup *group = _groupArray[section];
    return group.groupItems.count;
}

// 分组的标题名称
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == _mSearchDisplayController.searchResultsTableView) {
        AddressBookGroup *group = _searchArray[section];
        return group.groupName;
    }

    AddressBookGroup *group = _groupArray[section];
    return group.groupName;
}

// 索引
- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (tableView == _mSearchDisplayController.searchResultsTableView) {
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

    AddressBookGroup *group;
    AddressBook *item;
    
    if (tableView == _mSearchDisplayController.searchResultsTableView) {
        group = _searchArray[indexPath.section];
        item = group.groupItems[indexPath.row];
        [cell configWithModel:item];
        return cell;
    }
    
    group = _groupArray[indexPath.section];
    item = group.groupItems[indexPath.row];
    [cell configWithModel:item];
    
    cell.phoneBtnClickedBlock = ^{
        AddressBookActionSheet *actionSheet = [[AddressBookActionSheet alloc] initWithCancelTitle:@"取消" andMobile:item.mobile andPhone:item.phone];
        actionSheet.phoneBlock = ^(NSString *tel) {
            [self takePhoneWithNumber:tel];
        };
        actionSheet.msgBlock = ^(NSString *tel) {
            [self sendMessageWithRecipients:@[tel]];
        };
        [actionSheet show];
        
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AddressBookGroup *group;
    AddressBook *item;
    
    if (tableView == _mSearchDisplayController.searchResultsTableView) {
        group = _searchArray[indexPath.section];
        item = group.groupItems[indexPath.row];
    }else {
        group = _groupArray[indexPath.section];
        item = group.groupItems[indexPath.row];
    }

    InfoViewController *infoController = [[InfoViewController alloc] init];
    infoController.title = @"个人信息";
    if ([appDelegateAccessor.moudle.userId integerValue] == [item.id integerValue]) {
        infoController.infoTypeOfUser = InfoTypeMyself;
    }else{
        infoController.infoTypeOfUser = InfoTypeOthers;
        infoController.userId = [item.id integerValue];
    }
    [self.navigationController pushViewController:infoController animated:YES];
}

#pragma mark UISearchDisplayDelegate M
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = YES;
    for(id cc in [self.searchBar.subviews[0] subviews])
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
    
    NSString *keyName = [AddressBook keyName];
    
    // 模糊查找
    NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", keyName, searchString];
    // 精确查找
    //    NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"%K == %@", keyName, searchString];
    
    [self groupingDataSourceFrom:[[searchArray filteredArrayUsingPredicate:predicateString] mutableCopy] to:_searchArray];
    
    [self sortForArray:_searchArray];
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
            [self groupingDataSourceFrom:resultArray to:_searchArray];
            // 排序
            [self sortForArray:_searchArray];
            [_mSearchDisplayController.searchResultsTableView reloadData];
        });
    });
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView setHeight:kScreen_Height - 64 - 49];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[AddressBookTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _tableView.sectionIndexColor = [UIColor lightGrayColor];
        _tableView.tableHeaderView = self.searchBar;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (UISearchBar*)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.delegate = self;
        [_searchBar sizeToFit];
        [_searchBar setPlaceholder:@"搜索"];
//        _searchBar.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
        [_searchBar setBackgroundImage:[CommonFuntion createImageWithColor:COMM_SEARCHBAR_BACKGROUNDCOLOR]];
    }
    return _searchBar;
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
