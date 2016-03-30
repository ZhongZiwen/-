//
//  DepartViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/12/5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "DepartViewController.h"
#import "AddressBookTableViewCell.h"
#import "DepartGroupModel.h"
#import "DepartGroupGroupModel.h"
#import "MemberViewController.h"
#import "DynamicViewController.h"
#import "DocumentViewController.h"
#import "WorkGroupRecordViewController.h"
#import "KnowledgeFileViewController.h"
#import "CommonStaticVar.h"

#define kCellIdentifier @"AddressBookTableViewCell"

@interface DepartViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *mSearchDisplayController;
@property (strong, nonatomic) NSMutableArray *sourceArray;  // 数据源
@property (strong, nonatomic) NSMutableArray *groupArray;   // 分组后的数据
@property (strong, nonatomic) NSMutableArray *searchArray;  // 搜索后的数据
@end

@implementation DepartViewController

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
    [params setObject:@2 forKey:@"type"];
    [params setObject:_item.id forKey:@"departmentId"];
    
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_DepartmentOrGroup_List_WithParams:params listType:0 andBlock:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            for (NSDictionary *tempDict in data[@"departments"]) {
                DepartGroupModel *item = [NSObject objectOfClass:@"DepartGroupModel" fromJSON:tempDict];
                [_sourceArray addObject:item];
            }
            
            // 分组
            [self groupingDataSourceFrom:_sourceArray to:_groupArray];
            
            // 排序
            [self sortForArray:_groupArray];
            
            [_tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
NSInteger departGroupArraySort(id user1, id user2, void *context)
{
    DepartGroupModel *u1,*u2;
    //类型转换
    u1 = (DepartGroupModel*)user1;
    u2 = (DepartGroupModel*)user2;
    return  [u1.pinyin localizedCompare:u2.pinyin];
}

- (void)groupingDataSourceFrom:(NSArray*)fromArray to:(NSMutableArray*)toArray {
    [toArray removeAllObjects];
    for (DepartGroupModel *item in fromArray) {
        if ([self checkModelInArray:toArray withItem:item]) {
            [self addGroupInArray:toArray withItem:item];
        }else {
            DepartGroupGroupModel *group = [DepartGroupGroupModel initWithGroupName:[item getFirstName]];
            [group.groupArray addObject:item];
            [toArray addObject:group];
        }
    }
    
    // 对每组的数组元素进行排序
    for (DepartGroupGroupModel *group in toArray) {
        NSArray *sortArray = [group.groupArray sortedArrayUsingFunction:departGroupArraySort context:NULL];
        [group.groupArray removeAllObjects];
        group.groupArray = [NSMutableArray arrayWithArray:sortArray];
    }
}

- (BOOL)checkModelInArray:(NSArray*)array withItem:(DepartGroupModel*)item {
    BOOL isSame = NO;
    for (DepartGroupGroupModel *group in array) {
        if ([group.groupName isEqualToString:[item getFirstName]]) {
            isSame = YES;
        }
    }
    return isSame;
}

- (void)addGroupInArray:(NSMutableArray*)array withItem:(DepartGroupModel*)item {
    for (DepartGroupGroupModel *group in array) {
        if ([group.groupName isEqualToString:[item getFirstName]]) {
            [group.groupArray addObject:item];
        }
    }
}

- (void)sortForArray:(NSMutableArray*)array {
    [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        DepartGroupGroupModel *group1 = obj1;
        DepartGroupGroupModel *group2 = obj2;
        
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
        DepartGroupGroupModel *group = _searchArray[section];
        return group.groupArray.count;
    }
    DepartGroupGroupModel *group = _groupArray[section];
    return group.groupArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AddressBookTableViewCell cellHeight];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == _mSearchDisplayController.searchResultsTableView) {
        DepartGroupGroupModel *group = _searchArray[section];
        return group.groupName;
    }
    DepartGroupGroupModel *group = _groupArray[section];
    return group.groupName;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddressBookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    if (tableView == _mSearchDisplayController.searchResultsTableView) {
        DepartGroupGroupModel *group = _searchArray[indexPath.section];
        DepartGroupModel *item = group.groupArray[indexPath.row];
        [cell configDepartGroupWithModel:item type:0];
        return cell;
    }
    DepartGroupGroupModel *group = _groupArray[indexPath.section];
    DepartGroupModel *item = group.groupArray[indexPath.row];
    [cell configDepartGroupWithModel:item type:0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DepartGroupGroupModel *group;
    DepartGroupModel *item;
    if (tableView == _mSearchDisplayController.searchResultsTableView) {
        group = _searchArray[indexPath.section];
        item = group.groupArray[indexPath.row];
    }else {
        group = _groupArray[indexPath.section];
        item = group.groupArray[indexPath.row];
    }
    
    NSMutableArray *tabBarItems = [NSMutableArray arrayWithCapacity:0];
    
    // 添加成员
    MemberViewController *memberController = [[MemberViewController alloc] init];
    memberController.title = self.title;
    memberController.item = item;
    memberController.memberType = MemberViewControllerTypeDepartment;
    UIImage *memberNormalImage = [UIImage imageNamed:@"depart_member_normal"];
    memberNormalImage = [memberNormalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *memberSelectImage = [UIImage imageNamed:@"depart_member_selected"];
    memberSelectImage = [memberSelectImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *memberItem = [[UITabBarItem alloc] initWithTitle:@"成员" image:memberNormalImage selectedImage:memberSelectImage];
    [memberItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TABBAR_ITEM_NORMAL_COLOR,NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [memberItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TABBAR_ITEM_SELECTED_COLOR,NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    memberController.tabBarItem = memberItem;
    [tabBarItems addObject:memberController];
    
    
    WorkGroupRecordViewController *recordController = [[WorkGroupRecordViewController alloc] init];
    UIImage *recordNormalImage = [UIImage imageNamed:@"depart_feed_normal.png"];
    UIImage *recordSelectImage = [UIImage imageNamed:@"depart_feed_selected.png"];
    recordNormalImage = [recordNormalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    recordSelectImage = [recordSelectImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    recordController.tabBarItem.image = recordNormalImage;
    recordController.tabBarItem.selectedImage = recordSelectImage;
    [recordController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TABBAR_ITEM_NORMAL_COLOR,NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [recordController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TABBAR_ITEM_SELECTED_COLOR,NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    recordController.tabBarItem.title = @"动态";
    recordController.tabBarItem.tag = 200;
    ///判断是部门还是群组 并且传递id过去
    recordController.typeOfView = @"departmentfeed";
    [CommonStaticVar setFlagOfWorkGroupViewFrom:@"departmentfeed"];
    
    recordController.parentId = [item.id longLongValue];
    recordController.departmentOrGroup = self.title;
    [tabBarItems addObject:recordController];
    
    /*
    // 添加文档
    DocumentViewController *documentController = [[DocumentViewController alloc] init];
    documentController.title = self.title;
    UITabBarItem *documentItem = [[UITabBarItem alloc] initWithTitle:@"文档" image:[UIImage imageNamed:@"depart_doc_normal"] selectedImage:[UIImage imageNamed:@"depart_doc_selected"]];
    [documentItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TABBAR_ITEM_NORMAL_COLOR,NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [documentItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TABBAR_ITEM_SELECTED_COLOR,NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    documentController.tabBarItem = documentItem;
    [tabBarItems addObject:documentController];
    */
    
    
    KnowledgeFileViewController *documentController = [[KnowledgeFileViewController alloc] init];

    UIImage *fileNormalImage = [UIImage imageNamed:@"depart_doc_normal.png"];
    UIImage *fileSelectImage = [UIImage imageNamed:@"depart_doc_selected.png"];
    fileNormalImage = [fileNormalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    fileSelectImage = [fileSelectImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [documentController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TABBAR_ITEM_NORMAL_COLOR,NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
    [documentController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TABBAR_ITEM_SELECTED_COLOR,NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
    documentController.tabBarItem.image = fileNormalImage;
    documentController.tabBarItem.selectedImage = fileSelectImage;
    documentController.tabBarItem.title = @"文档";

    documentController.typeKnowledge = 0;
    
    documentController.typeKnowledgeRequest = 1;
    documentController.dirId = -1;
    documentController.departmengOrGroupId = [item.id longLongValue];
    documentController.typeKnowledgeSearchView = 1;
    documentController.typeKnowledgeSearchViewFirst = 0;
    
    [tabBarItems addObject:documentController];
    

    
    
    // 添加下一部门
    if (item.hasChildren && ![item.hasChildren integerValue]) {
        DepartViewController *nextDepartController = [[DepartViewController alloc] init];
        nextDepartController.title = self.title;
        nextDepartController.item = item;
        UIImage *departNormalImage = [UIImage imageNamed:@"departchild_icon_normal"];
        departNormalImage = [departNormalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *departSelectImage = [UIImage imageNamed:@"departchild_icon_selected"];
        departSelectImage = [departSelectImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UITabBarItem *departItem = [[UITabBarItem alloc] initWithTitle:@"下级部门" image:departNormalImage selectedImage:departSelectImage];
        [departItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TABBAR_ITEM_NORMAL_COLOR,NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        [departItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TABBAR_ITEM_SELECTED_COLOR,NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
        nextDepartController.tabBarItem = departItem;
        [tabBarItems insertObject:nextDepartController atIndex:0];
    }
    
    UITabBarController *tabbarController = [[UITabBarController alloc] init];
    tabbarController.edgesForExtendedLayout = UIRectEdgeNone;
    tabbarController.title = item.name;
    tabbarController.viewControllers = tabBarItems;
    tabbarController.hidesBottomBarWhenPushed = YES;
    tabbarController.delegate = self;
    [self.navigationController pushViewController:tabbarController animated:YES];
}


///获取tabbar controller  items   groupOrDepartType 1001 1002
-(NSArray *)getTabBarItems:(DepartGroupModel *)item andType:(NSInteger)groupOrDepartType{
     NSMutableArray *tabBarItems = [NSMutableArray arrayWithCapacity:0];
    // 添加成员
    MemberViewController *memberController = [[MemberViewController alloc] init];
    memberController.title = item.name;
    memberController.item = item;
    if (groupOrDepartType == 1001) {
        memberController.memberType = MemberViewControllerTypeGroup;
    }else if (groupOrDepartType == 1002){
        memberController.memberType = MemberViewControllerTypeDepartment;
    }
    
    
    /*
    UITabBarItem *memberItem = [[UITabBarItem alloc] initWithTitle:@"成员" image:[UIImage imageNamed:@"depart_member_normal"] selectedImage:[UIImage imageNamed:@"depart_member_selected"]];
    [memberItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TABBAR_ITEM_NORMAL_COLOR,NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [memberItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TABBAR_ITEM_SELECTED_COLOR,NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    memberController.tabBarItem = memberItem;
    [tabBarItems addObject:memberController];
     */
    
    UIImage *memberNormalImage = [UIImage imageNamed:@"depart_member_normal"];
    memberNormalImage = [memberNormalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *memberSelectImage = [UIImage imageNamed:@"depart_member_selected"];
    memberSelectImage = [memberSelectImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *memberItem = [[UITabBarItem alloc] initWithTitle:@"成员" image:memberNormalImage selectedImage:memberSelectImage];
    [memberItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TABBAR_ITEM_NORMAL_COLOR,NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [memberItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TABBAR_ITEM_SELECTED_COLOR,NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    memberController.tabBarItem = memberItem;
    [tabBarItems addObject:memberController];
    
    
    
    WorkGroupRecordViewController *recordController = [[WorkGroupRecordViewController alloc] init];
    UIImage *recordNormalImage = [UIImage imageNamed:@"depart_feed_normal.png"];
    UIImage *recordSelectImage = [UIImage imageNamed:@"depart_feed_selected.png"];
    recordNormalImage = [recordNormalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    recordSelectImage = [recordSelectImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    recordController.tabBarItem.image = recordNormalImage;
    recordController.tabBarItem.selectedImage = recordSelectImage;
    [recordController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TABBAR_ITEM_NORMAL_COLOR,NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [recordController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TABBAR_ITEM_SELECTED_COLOR,NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    recordController.tabBarItem.title = @"动态";
    recordController.tabBarItem.tag = 200;
    ///判断是部门还是群组 并且传递id过去
    
    if (groupOrDepartType == 1001) {
        recordController.typeOfView = @"groupfeed";
        [CommonStaticVar setFlagOfWorkGroupViewFrom:@"groupfeed"];
    }else if (groupOrDepartType == 1002){
        recordController.typeOfView = @"departmentfeed";
        [CommonStaticVar setFlagOfWorkGroupViewFrom:@"departmentfeed"];
    }
    
    
    recordController.parentId = [item.id longLongValue];
    recordController.departmentOrGroup = item.name;
    [tabBarItems addObject:recordController];
    
    
    KnowledgeFileViewController *documentController = [[KnowledgeFileViewController alloc] init];
    
    UIImage *fileNormalImage = [UIImage imageNamed:@"depart_doc_normal.png"];
    UIImage *fileSelectImage = [UIImage imageNamed:@"depart_doc_selected.png"];
    fileNormalImage = [fileNormalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    fileSelectImage = [fileSelectImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [documentController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TABBAR_ITEM_NORMAL_COLOR,NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
    [documentController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TABBAR_ITEM_SELECTED_COLOR,NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
    documentController.tabBarItem.image = fileNormalImage;
    documentController.tabBarItem.selectedImage = fileSelectImage;
    documentController.tabBarItem.title = @"文档";
    
    if (groupOrDepartType == 1001) {
        documentController.typeKnowledge = 2;
    }else if (groupOrDepartType == 1002){
        documentController.typeKnowledge = 0;
    }
    
    documentController.typeKnowledgeRequest = 1;
    documentController.dirId = -1;
    documentController.departmengOrGroupId = [item.id longLongValue];
    documentController.typeKnowledgeSearchView = 1;
    documentController.typeKnowledgeSearchViewFirst = 0;
    
    [tabBarItems addObject:documentController];
    
    return tabBarItems;
}


// 索引
- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == _mSearchDisplayController.searchResultsTableView) {
        return nil;
    }
    
    NSMutableArray *indexArray = [NSMutableArray arrayWithCapacity:0];
    for (DepartGroupGroupModel *group in _groupArray) {
        [indexArray addObject:group.groupName];
    }
    
    return indexArray;
}

#pragma mark - UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
//    if ([viewController isKindOfClass:[DynamicViewController class]]) {
//        tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:viewController action:@selector(addDynamic)];
//    }else {
//        tabBarController.navigationItem.rightBarButtonItem = nil;
//    }
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
    
    NSString *keyName = [DepartGroupModel keyName];
    
    // 模糊查找
    NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"%K contains[cd] %@", keyName, searchString];
    // 精确查找
    //    NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"%K == %@", keyName, searchString];
    
    [self groupingDataSourceFrom:[searchArray filteredArrayUsingPredicate:predicateString] to:_searchArray];
    
    // 排序
    [self sortForArray:_searchArray];
}


- (void)updateFilteredContentForSearchString2:(NSString *)searchString {
    DebugLog(@"\n%@", searchString);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *searchArray = [_sourceArray mutableCopy];
        NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (DepartGroupModel *tempItem in searchArray) {
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
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setWidth:kScreen_Width];
        [_tableView setHeight:kScreen_Height - 49 - 64.0f];
        _tableView.dataSource = self;
        _tableView.delegate = self;
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
        _searchBar.placeholder = @"搜索";
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
