//
//  AddGroupDiscussionController.m
//  shangketong
//
//  Created by 蒋 on 15/10/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AddGroupDiscussionController.h"
#import "companyGroupCell.h"
#import "CompanyGroupModel.h"
#import "ChatViewController.h"
#import "AFNHttp.h"
#import "ContactModel.h"
#import "CommonConstant.h"
#import "CommonFuntion.h"
#import <MBProgressHUD.h>
#import "ChineseToPinyin.h"
#import "pinyin.h"
#import "PinYin4Objc.h"
#import "CommonNoDataView.h"


@interface AddGroupDiscussionController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) NSMutableArray *dataSourceArray; //数据源
@property (nonatomic, strong) NSMutableArray *allKeysArray;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) NSMutableArray *resultsArray; //存储搜索结果
@property (nonatomic, strong) NSMutableArray *resultKeysArray;
@property (nonatomic, strong) NSMutableArray *saveResultArray;
@property (nonatomic, strong) CompanyGroupModel *comModel;
@property (nonatomic, strong) void (^BackContactsArrayBlock)(NSArray *array);
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@end

@implementation AddGroupDiscussionController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择一个部门";
    
    UIView *V = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableViewGroup setTableFooterView:V];
    _tableViewGroup.sectionIndexBackgroundColor = [UIColor clearColor];
    _tableViewGroup.sectionIndexColor = [UIColor lightGrayColor];
//    [_tableViewGroup setSeparatorInset:UIEdgeInsetsMake(0, 64, 0, 0)];
    [self initViewForSearchBar];
    
    _dataSourceArray = [NSMutableArray arrayWithCapacity:0];
    _allKeysArray = [NSMutableArray arrayWithCapacity:0];
    [self getDepartmentList];
    
    // Do any additional setup after loading the view from its nib.
}
- (void)hideKeyBoard {
    NSLog(@"11111");
    for(id cc in [self.searchBar.subviews[0] subviews])
    {
        if([cc isKindOfClass:[UITextField class]])
        {
            UITextField *txt = (UITextField *)cc;
            [txt resignFirstResponder];
        }
    }

}
- (void)initViewForSearchBar {
    _resultsArray = [NSMutableArray arrayWithCapacity:0];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 30)];
    _searchBar.placeholder = @"搜索";
//    _searchBar.backgroundColor = COLOR_SEARCHBAR_BG;
    [_searchBar setBackgroundImage:[CommonFuntion createImageWithColor:COMM_SEARCHBAR_BACKGROUNDCOLOR]];
    _searchBar.delegate = self;
    [_searchBar sizeToFit];
    
    _searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    _searchController.delegate = self;
    _searchController.searchResultsDelegate = self;
    _searchController.searchResultsDataSource = self;
    _searchController.searchResultsTableView.frame = CGRectMake(0, 64, kScreen_Width, kScreen_Height - 64);
    _searchController.searchResultsTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _searchController.searchResultsTableView.sectionIndexColor = [UIColor lightGrayColor];

    _searchController.searchResultsTableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    _searchController.searchBar.tintColor = LIGHT_BLUE_COLOR;
    
    _tableViewGroup.tableHeaderView = _searchBar;
}

//将得到的数据转化为对象model
- (void)changeDataForGetDataSource:(NSArray *)array {
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
    NSInteger count = 0;
    if (array.count > 0 ) {
        count = [array count];
    }
    for (int i = 0; i < count; i++) {
        NSDictionary *dict = array[i];
        CompanyGroupModel *model = [CompanyGroupModel initWithDictionary:dict];
        model.originIndex = i;
        [newArray addObject:model];
    }
    [self getGroupOfContact:newArray WithType:@"normal"];
}
- (void)getGroupOfContact:(NSArray *)groupArray WithType:(NSString *)type{
    //建立索引
    UILocalizedIndexedCollation *indexCollation = [UILocalizedIndexedCollation currentCollation];
    //根据姓名分区
    for (CompanyGroupModel *item in groupArray) {
        NSInteger section = [indexCollation sectionForObject:item collationStringSelector:@selector(getFirstName)];
        //设定姓的索引编号
        item.sectionNum = section;
    }
    //返回28 A-Z+#
    NSInteger sectionTitleCount = [[indexCollation sectionIndexTitles] count];
    //tableView 默认被分为27个分区
    NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:sectionTitleCount];
    //初始化27个空数组
    for (int i = 0; i <= sectionTitleCount; i++) {
        NSMutableArray *contactArray = [NSMutableArray arrayWithCapacity:0];
        [sectionArrays addObject:contactArray];
    }
    // 根据sectionNum把对象加入到对应section数组里
    for (CompanyGroupModel *item in groupArray) {
        [sectionArrays[item.sectionNum] addObject:item];
    }
    NSArray *titleArray = [[UILocalizedIndexedCollation currentCollation] sectionTitles];
    _allKeysArray = [NSMutableArray arrayWithCapacity:0];
    _resultKeysArray = [NSMutableArray arrayWithCapacity:0];
    _saveResultArray = [NSMutableArray arrayWithCapacity:0];
    // 对每组数据进行排序后，加入到数据源中
    for (NSArray *sectionArray in sectionArrays) {
        //按照首字母排序
        NSArray *sortedSectionArray = [indexCollation sortedArrayFromArray:sectionArray collationStringSelector:@selector(getFirstName)];
        if (sortedSectionArray && sortedSectionArray.count > 0) {
            NSInteger flag = [sectionArrays indexOfObject:sectionArray];
            NSLog(@"flag %ld", flag);
            if ([type isEqualToString:@"normal"]) {
                [_dataSourceArray addObject:sortedSectionArray];
                [_allKeysArray addObject:titleArray[flag]];
                
            } else {
                [_saveResultArray addObject:sortedSectionArray];
                [_resultKeysArray addObject:titleArray[flag]];
                [_searchController.searchResultsTableView reloadData];
            }
        }
    }
    NSLog(@"%@", _dataSourceArray);
}

#pragma mark - table View 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _searchController.searchResultsTableView) {
        return _resultKeysArray.count;
    }
    return _dataSourceArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _searchController.searchResultsTableView) {
        return [_saveResultArray[section] count];
    }
    return [_dataSourceArray[section] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    companyGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"companyGroupCellIdentifier"];
    if (!cell) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"companyGroupCell" owner:self options:nil];
        cell = (companyGroupCell *)[array objectAtIndex:0];
        [cell awakeFromNib];
        [cell setFrameAllPhone];
    }
    if (tableView == _searchController.searchResultsTableView) {
        CompanyGroupModel *model = _saveResultArray[indexPath.section][indexPath.row];
        [cell configWithModel:model];
    } else {
        CompanyGroupModel *model = _dataSourceArray[indexPath.section][indexPath.row];
        [cell configWithModel:model];
    }
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == _searchController.searchResultsTableView) {
        return _resultKeysArray[section];
    }
    return _allKeysArray[section];
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == _searchController.searchResultsTableView) {
        return _resultKeysArray;
    }
    return _allKeysArray;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableArray *contactArray = [NSMutableArray arrayWithCapacity:0];
    CompanyGroupModel *model = [[CompanyGroupModel alloc] init];
    if (tableView == _searchController.searchResultsTableView) {
        model = _saveResultArray[indexPath.section][indexPath.row];
        [self hideKeyBoard];
    } else {
        model = _dataSourceArray[indexPath.section][indexPath.row];
    }
    [self getContactsOfOneDepartment:model.group_id];
    __weak typeof(self) weak_self = self;
    _BackContactsArrayBlock = ^(NSArray *array) {
        NSMutableArray *allUserArray = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *dict in array) {
            ContactModel *conModel = [ContactModel initWithDataSource:dict];
            if (conModel.userID != [appDelegateAccessor.moudle.userId integerValue]) {
                [contactArray addObject:conModel];
            }
            [allUserArray addObject:conModel];
        }
        if (contactArray.count > 1) {
            ChatViewController *controller = [[ChatViewController alloc] init];
            controller.pushType = ControllerPushTypeStartChatVC;
            controller.usersArray = allUserArray;
            controller.titleName = model.group_name;
            controller.companyType = @"company";
            [weak_self.navigationController pushViewController:controller animated:YES];
        } else {
            kShowHUD(@"部门下无用户或者用户不足创建讨论组");
        }
    };
    /*
    if (model.isHasChildren) {
        //跳转到子部门  子公司
        AddGroupDiscussionController *controller = [[AddGroupDiscussionController alloc] init];
        controller.parentId = model.group_id;
        [self.navigationController pushViewController:controller animated:YES];
        return;
    } else {
        [self getContactsOfOneDepartment];
        __weak typeof(self) weak_self = self;
        _BackContactsArrayBlock = ^(NSArray *array) {
            for (NSDictionary *dict in array) {
                ContactModel *conModel = [ContactModel initWithDataSource:dict];
                if (conModel.userID != [appDelegateAccessor.moudle.userId integerValue]) {
                    [contactArray addObject:conModel];
                }
            }
            if (contactArray.count > 1) {
                ChatViewController *controller = [[ChatViewController alloc] init];
                controller.usersArray = contactArray;
                controller.pushType = ControllerPushTypeStartChatVC;
                controller.usersArray = contactArray;
                controller.titleName = model.group_name;
                controller.companyType = @"company";
                [weak_self.navigationController pushViewController:controller animated:YES];
            } else {
                kShowHUD(@"部门下无用户或者用户不足创建讨论组");
            }
        };
    }
     */
}
#pragma mark - 获取部门列表
- (void)getDepartmentList {
    __weak typeof(self) weak_self = self; //@"getDepartmentList.do"  ADDRESS_BOOK_CHILD_DEPARTMENT_ACTION
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:appDelegateAccessor.moudle.IM_tokenString forKey:@"token"];
    [params setObject:appDelegateAccessor.moudle.userCompanyId forKey:@"companyId"];    
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_IM, IM_GET_DEPARTMENT_LIST] params:params success:^(id responseObj) {
        NSLog(@"%@", responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            if ([CommonFuntion checkNullForValue:[responseObj objectForKey:@"body"]]) {
                NSArray *array = [responseObj objectForKey:@"body"];
                if (array.count > 0) {
                    [weak_self clearViewNoData];
                    [weak_self changeDataForGetDataSource:array];
                } else {
                    [weak_self clearViewNoData];
                    [weak_self setViewNoData:@"暂无部门"];
                }
            } else {
                [weak_self clearViewNoData];
                [weak_self setViewNoData:@"暂无部门"];
            }
            [_tableViewGroup reloadData];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getDepartmentList];
            };
            [comRequest loginInBackground];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}
#pragma mark - 获取部门下的成员
- (void)getContactsOfOneDepartment:(NSString *)groupId {
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:groupId forKey:@"deptId"];
    [params setObject:appDelegateAccessor.moudle.IM_tokenString forKey:@"token"];
    __weak typeof(self) weak_self = self;
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_IM, IM_GET_DEPTUSER_LIST] params:params success:^(id responseObj) {
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            NSArray *resultArray;//
            if ([CommonFuntion checkNullForValue:[responseObj objectForKey:@"body"]]) {
                resultArray = [responseObj objectForKey:@"body"];
                if (resultArray.count > 0) {
                    if (weak_self.BackContactsArrayBlock) {
                        weak_self.BackContactsArrayBlock(resultArray);
                    }
                }
            } else {
               kShowHUD(@"部门下无用户或者用户不足创建讨论组");
            }
        }else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getContactsOfOneDepartment:groupId];
            };
            [comRequest loginInBackground];
        }else{
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        [hud hide:YES];
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        [hud hide:YES];
    }];
}

/*
- (void)getContactsOfOneDepartment {
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:_parentId forKey:@"departmentId"];
    __weak typeof(self) weak_self = self;
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, DEPARTMENT_CHILD_STAFFS_ACTION] params:params success:^(id responseObj) {
        //字典转模型
        NSLog(@"部门/群组员工 responseObj:%@",responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            
            NSArray *resultArray;
            if ([responseObj objectForKey:@"users"] ) {
                resultArray = [responseObj objectForKey:@"users"];
                if (resultArray.count > 0) {
                    if (weak_self.BackContactsArrayBlock) {
                        weak_self.BackContactsArrayBlock(resultArray);
                    }
                }
            }
        }else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getContactsOfOneDepartment];
            };
            [comRequest loginInBackground];
        }else{
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        
    }];
}
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - SearchDisplayController Delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    //    searchOrNot = YES;
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self searhAddress:searchString];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

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
- (void)searhAddress:(NSString *)searchText {
    NSLog(@"搜索文本%@", searchText);
    [self.view becomeFirstResponder];
    _searchController.searchResultsTableView.frame = CGRectMake(0, 64, kScreen_Width, kScreen_Height);
    UIView *Vv = [[UIView alloc] initWithFrame:CGRectZero];
    [_searchController.searchResultsTableView setTableFooterView:Vv];
    
    [_resultsArray removeAllObjects];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    for (NSArray *newDataArray in _dataSourceArray) {
        for (CompanyGroupModel *model in newDataArray) {
            [array addObject:model];
        }
    }
    
    for (int i = 0; i < array.count; i++) {
        _comModel = array[i];
        NSString *companyName = _comModel.group_name;
        NSString *pinyinName = [ChineseToPinyin pinyinFromChiniseString:companyName];
        NSLog(@"%@", pinyinName);
        if([self searchResult:pinyinName searchText:searchText])
        {
            [_resultsArray addObject:_comModel];
        } else {
            NSString *chineseName = [self namToPinYinFisrtNameWith:companyName];
            if([self searchResult:chineseName searchText:searchText]){
                [_resultsArray addObject:_comModel];
            } else if([self searchResult:companyName searchText:searchText]){
                [_resultsArray addObject:_comModel];
            } else {
                
            }
        }
    }
    [self getGroupOfContact:_resultsArray WithType:@"search"];
}

- (NSString *)namToPinYinFisrtNameWith:(NSString *)name
{
    NSString * outputString = @"";
    for (int i =0; i<[name length]; i++) {
        outputString = [NSString stringWithFormat:@"%@%c",outputString,pinyinFirstLetter([name characterAtIndex:i])];
    }
    return outputString;
    
}

-(BOOL)searchResult:(NSString *)contactName searchText:(NSString *)searchT{
    if (contactName==nil || searchT == nil || (id)contactName == [NSNull null] || [contactName isEqualToString:@"(null)"] || [contactName isEqualToString:@"<null>"]) {
        return NO;
    }
    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    NSRange productNameRange = NSMakeRange(0, contactName.length);
    NSRange foundRange = [contactName rangeOfString:searchT options:searchOptions range:productNameRange];
    if (foundRange.length > 0)
        return YES;
    else
        return NO;
}
#pragma mark - 没有数据时的view
-(void)setViewNoData:(NSString *)title{
    
    self.commonNoDataView = [CommonFuntion commonNoDataViewIcon:@"list_empty.png" Title:title optionBtnTitle:@""];
    
    [_tableViewGroup addSubview:self.commonNoDataView];
}


-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
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
