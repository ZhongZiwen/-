//
//  StartChatViewController.m
//  shangketong
//
//  Created by 蒋 on 16/1/26.
//  Copyright (c) 2016年 sungoin. All rights reserved.
//

#import "StartChatViewController.h"
#import "ChatContactCell.h"
#import "ChatImageAndTitleCell.h"
#import "ChatContactDetalsCell.h"
#import "ContactModel.h"
#import "AFNHttp.h"
#import "ChatViewController.h"
#import "ChooseDiscussionGroupController.h"
#import "AddGroupDiscussionController.h"
#import "CommonFuntion.h"
#import "ChineseToPinyin.h"
#import "pinyin.h"
#import "PinYin4Objc.h"
#import <MBProgressHUD.h>
#import "IM_FMDB_FILE.h"
#import "Message_RootViewController.h"


@interface StartChatViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
{
    BOOL isAllSelect; //返回的时候cell恢复原样
    NSArray *cacheArray;
}

@property (nonatomic, strong) UITableView *tableView_V;  //竖直方向
@property (nonatomic, strong) UITableView *tableView_H;  //水平方向
@property (nonatomic, strong) UIView *bottomBgView;
@property (nonatomic, strong) UIButton *OKBtn;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) NSMutableArray *dataSourceArray; //存储联系人数据
@property (nonatomic, strong) NSMutableArray *allKeysArray; //存储有效Key
@property (nonatomic, strong) NSMutableArray *bottomDataSourceArray; //选中的联系人
@property (nonatomic, strong) NSMutableArray *resultsArray; //存储搜索结果
@property (nonatomic, strong) NSMutableArray *resultKeysArray;
@property (nonatomic, strong) NSMutableArray *saveResultArray;
@property (nonatomic, strong) NSMutableArray *recentContactArray; //最近联系人
@property (nonatomic, strong) ContactModel *contactItem;

@property (nonatomic, strong) NSString *groupNameTitle;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation StartChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.automaticallyAdjustsScrollViewInsets = YES;
    [self.view addSubview:self.tableView_V];
    
    [self.view addSubview:self.bottomBgView];
    
    [_bottomBgView addSubview:self.tableView_H];
    [_bottomBgView addSubview:self.OKBtn];
    
    UIView *zeroV = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView_H setTableFooterView:zeroV];
    [_tableView_V setTableFooterView:zeroV];
    
    [self initViewForSearchBar];
    
    
    
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_hud];
    [_hud show:YES];
    
    _dataSourceArray = [NSMutableArray arrayWithCapacity:0];
    _bottomDataSourceArray = [NSMutableArray arrayWithCapacity:0];
    _resultsArray = [NSMutableArray arrayWithCapacity:0];
    _allKeysArray = [NSMutableArray arrayWithCapacity:0];
    
    _recentContactArray = [NSMutableArray arrayWithArray:[IM_FMDB_FILE result_IM_RecentContactList]];
    NSMutableArray *oldArray = [NSMutableArray arrayWithCapacity:0];
    cacheArray = [IM_FMDB_FILE result_IM_AllContactAddressBook];
    if(cacheArray && [cacheArray count] > 0){
        for (ContactModel *model in cacheArray) {
            if (model.userID != [appDelegateAccessor.moudle.userId integerValue]) {
                [oldArray addObject:model];
            }
        }
        cacheArray = oldArray;
        [self getGroupOfContact:cacheArray WithType:@"normal"];
    }
    
    // 默认添加一个空数据
    ContactModel *item = [[ContactModel alloc] init];
    item.isDefault = YES;
    item.imgHeaderName = @"Head_Box";
    [_bottomDataSourceArray addObject:item];
    
    [self getContactDataSourceFromSever];

    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGroupList:) name:@"refreshGroupList" object:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGroupList:) name:@"refreshGroupList" object:nil];
}
- (void)initViewForSearchBar {
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44)];
    _searchBar.placeholder = @"搜索";
    _searchBar.delegate = self;
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchBar.contentMode = UIViewContentModeLeft;
    [_searchBar sizeToFit];
    [_searchBar setBackgroundImage:[CommonFuntion createImageWithColor:COMM_SEARCHBAR_BACKGROUNDCOLOR]];
    self.tableView_V.tableHeaderView = _searchBar;
    self.tableView_V.tableHeaderView.backgroundColor = COMM_SEARCHBAR_BACKGROUNDCOLOR;
    [_tableView_V setTableHeaderView:_searchBar];
    
    _searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    _searchController.delegate = self;
    _searchController.searchResultsDelegate = self;
    _searchController.searchResultsDataSource = self;
     _searchController.searchResultsTableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    _searchController.searchResultsTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _searchController.searchResultsTableView.sectionIndexColor = [UIColor lightGrayColor];
    _searchController.searchResultsTableView.clipsToBounds = NO;
    _searchController.searchResultsTableView.frame = CGRectMake(0, 64, kScreen_Width, kScreen_Height - 64);
    _searchController.searchBar.tintColor = LIGHT_BLUE_COLOR;
}
#pragma mark - 获取数据
- (void)getContactDataSourceFromSever {
    __weak typeof(self) weak_self = self;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *serverTime = @"";
    if ([defaults objectForKey:@"IMAddressServerTime"]) {
        serverTime = [[defaults objectForKey:@"IMAddressServerTime"] stringValue];
    }
    [params setObject:serverTime forKey:@"serverTime"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, ADDRESS_BOOK_ACTION] params:params success:^(id responseObj) {
        //        NSLog(@"%@", responseObj);
        //        [hud hide:YES];
        NSDictionary *dict = (NSDictionary *)responseObj;
        if (dict && [[dict objectForKey:@"status"] integerValue] == 0) {
            ///第一次  添加全部数据
            if ([serverTime isEqualToString:@""]) {
                if ([CommonFuntion checkNullForValue:[dict objectForKey:@"users"]]) {
                    NSArray *resultArray = [dict objectForKey:@"users"];
                    [weak_self changeDataForGetDataSource:resultArray];
                    //                    NSLog(@"resultArray:%ti",[resultArray count]);
                    ///清空
                    [IM_FMDB_FILE delete_IM_AllAddressBook];
                    ///缓存
                    [IM_FMDB_FILE getAllAddressBookContactFromServer:resultArray];
                    [IM_FMDB_FILE closeDataBase];
                }
                
            }else{
                if ([CommonFuntion checkNullForValue:[dict objectForKey:@"users"]]) {
                    NSArray *resultArray = [responseObj objectForKey:@"users"];
                    [self optionAddressByAddressStatus:resultArray];
                }
            }
            if ([dict objectForKey:@"serverTime"]) {
                [defaults setObject:dict[@"serverTime"] forKey:@"IMAddressServerTime"];
                [defaults synchronize];
            }
            [weak_self.tableView_V reloadData];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getContactDataSourceFromSever];
            };
            [comRequest loginInBackground];
        }else{
            
        }
        [_hud hide:YES];
    } failure:^(NSError *error) {
        [_hud hide:YES];
//        kShowHUD(@"加载失败" ,nil);
    }];
}
-(void)optionAddressByAddressStatus:(NSArray *)arrayAddress{
    
    [IM_FMDB_FILE optionAddressByAddressStatus:arrayAddress];
    NSInteger count = 0;
    if (arrayAddress) {
        count = [arrayAddress count];
    }
    
    ///有更改  刷新数据
    if (count > 0) {
        [_dataSourceArray removeAllObjects];
        [_allKeysArray removeAllObjects];
        ///先读取缓存
        cacheArray = [IM_FMDB_FILE result_IM_AllContactAddressBook];
        if(cacheArray && [cacheArray count] > 0){
            NSMutableArray *newAddressArray = [NSMutableArray array];
            for (ContactModel *model in cacheArray) {
                if ([appDelegateAccessor.moudle.userId integerValue] != model.userID) {
                    [newAddressArray addObject:model];
                }
            }
            [self getGroupOfContact:newAddressArray WithType:@"normal"];
        }
    }
    [IM_FMDB_FILE closeDataBase];
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
        ContactModel *model = [ContactModel initWithDataSource:dict];
        if (model.userID != [appDelegateAccessor.moudle.userId integerValue]) {
            model.originIndex = i;
            [newArray addObject:model];
            //            [IM_FMDB_FILE delete_IM_AddressBookOneContact:model];
            //            [IM_FMDB_FILE insert_IM_AddressBook:model];
        }
    }
    [self getGroupOfContact:newArray WithType:@"normal"];
}
- (void)getGroupOfContact:(NSArray *)groupArray WithType:(NSString *)type {
    //建立索引
    UILocalizedIndexedCollation *indexCollation = [UILocalizedIndexedCollation currentCollation];
    //根据姓名分区
    for (ContactModel *item in groupArray) {
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
    for (ContactModel *item in groupArray) {
        [sectionArrays[item.sectionNum] addObject:item];
    }
    NSArray *titleArray = [[UILocalizedIndexedCollation currentCollation] sectionTitles];
    _resultKeysArray = [NSMutableArray arrayWithCapacity:0];
    _saveResultArray = [NSMutableArray arrayWithCapacity:0];
    //    _allKeysArray = [NSMutableArray arrayWithCapacity:0];
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
    if ([type isEqualToString:@"normal"]) {
        if (_recentContactArray && _recentContactArray.count > 0) {
            [_allKeysArray insertObject:@"☆" atIndex:0];
            [_dataSourceArray insertObject:_recentContactArray atIndex:0];
        }
        [self.tableView_V reloadData];
    }
    
//    NSLog(@"%@", _dataSourceArray);
}
#pragma mark - table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _tableView_V) {
        return _dataSourceArray.count + 1;
    } else if (tableView == _searchController.searchResultsTableView) {
        return _saveResultArray.count;
    }
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _tableView_V) {
        if (section == 0 ) {
            if (_flag_controller == ControllerPopTypeBack) {
                return 0;
            }
            return 2;
        }
        return [_dataSourceArray[section - 1] count];
    } else if (tableView == _searchController.searchResultsTableView) {
        return [_saveResultArray[section] count];
    }
    return [_bottomDataSourceArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tableView_V) {
        if (indexPath.section == 0) {
            NSArray *array = @[@{@"name":@"选择已有的讨论组",
                                 @"icon": @"group_select"}, @{@"name":@"按部门选择并创建新讨论组",
                                                              @"icon": @"depart_select"}];
            ChatImageAndTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatImageAndTitleCellIdentifier"];
            if (!cell) {
                NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ChatImageAndTitleCell" owner:self options:nil];
                cell = (ChatImageAndTitleCell *)[array objectAtIndex:0];
                [cell awakeFromNib];
            }
            cell.titleLabel.text = [array[indexPath.row] objectForKey:@"name"];
            cell.imgIcon.image = [UIImage imageNamed:[array[indexPath.row] objectForKey:@"icon"]];
            return cell;
        } else {
            ChatContactDetalsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatContactDetalsCellIdentifier"];
            if (!cell) {
                NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ChatContactDetalsCell" owner:self options:nil];
                cell = (ChatContactDetalsCell *)[array objectAtIndex:0];
                [cell awakeFromNib];
                [cell setFrameForAllPhone];
            }
            ContactModel *model = _dataSourceArray[indexPath.section - 1][indexPath.row];
            [cell configWithModel:model];
            return cell;
        }
    } else if (tableView == _tableView_H) {
        ChatContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatContactCellIdentifier"];
        if (!cell) {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ChatContactCell" owner:self options:nil];
            cell = (ChatContactCell *)[array objectAtIndex:0];
            [cell awakeFromNib];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
        }
        ContactModel *model = _bottomDataSourceArray[indexPath.row];
        [cell configWithModel:model];
        return cell;
    } else if (tableView == self.searchController.searchResultsTableView) {
        ChatContactDetalsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatContactDetalsCellIdentifier"];
        if (!cell) {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ChatContactDetalsCell" owner:self options:nil];
            cell = (ChatContactDetalsCell *)[array objectAtIndex:0];
            [cell awakeFromNib];
            [cell setFrameForAllPhone];
        }
        ContactModel *model = _saveResultArray[indexPath.section][indexPath.row];
        [cell configWithModel:model];
        return cell;
    }
    return nil;
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == _tableView_V) {
        if (section == 0) {
            return nil;
        }
        NSString *title = _allKeysArray[section - 1];
        if ([title isEqualToString:@"☆"]) {
            return @"最近联系人";
        }
        return title;
    } else if (tableView == self.searchController.searchResultsTableView) {
        return _resultKeysArray[section];
    }
    return nil;
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.tableView_V) {
        return _allKeysArray;
    } else if (tableView == self.searchController.searchResultsTableView) {
        return _resultKeysArray;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == _tableView_V) {
        if (section == 0) {
            return 0;
        }
        return 30;
    } else if (tableView == self.searchController.searchResultsTableView){
        return 30;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView != _tableView_H) {
        return 60;
    }
    return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
    if (tableView == _tableView_V) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                ChooseDiscussionGroupController *controller = [[ChooseDiscussionGroupController alloc] init];
                [self.navigationController pushViewController:controller animated:YES];
            } else {
                AddGroupDiscussionController *controller = [[AddGroupDiscussionController alloc] init];
                [self.navigationController pushViewController:controller animated:YES];
            }
        } else {
            NSIndexPath *path = nil;
            ContactModel *model = _dataSourceArray[indexPath.section - 1][indexPath.row];
            if (model.isSelect) {
                model.isSelect = NO;
                // 在_bottomDataSource数组中找到取消选中的联系人
                for (int i = 0; i < _bottomDataSourceArray.count-1; i ++) {
                    ContactModel *item = (ContactModel *)[_bottomDataSourceArray objectAtIndex:i];
                    if (item.userID  == model.userID) {
                        
                        // 赋值path，删除在_bottomTableView的数据
                        path = [NSIndexPath indexPathForRow:i inSection:0];
                        
                        // 删除选中数据
                        [_bottomDataSourceArray removeObjectAtIndex:i];
                    }
                }
                NSString *titleStr = @"";
                if (_bottomDataSourceArray && _bottomDataSourceArray.count <= 1) {
                    [_OKBtn setEnabled:NO];
                    titleStr = @"确定";
                } else {
                    [_OKBtn setEnabled:YES];
                    titleStr = [NSString stringWithFormat:@"确定(%lu)", _bottomDataSourceArray.count-1];
                }
                // 改变_bottomButton的title
                [_OKBtn setTitle:titleStr forState:UIControlStateNormal];
                // 动态删除cell
                [_tableView_H beginUpdates];
                [_tableView_H deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationBottom];
                [_tableView_H endUpdates];
            } else {
                model.isSelect = YES;
                // 申明path，保存在_bottomTableView倒数第二行的位置插入数据
                path = [NSIndexPath indexPathForRow:_bottomDataSourceArray.count-1 inSection:0];
                
                // 选中添加数据
                [_bottomDataSourceArray insertObject:model atIndex:_bottomDataSourceArray.count-1];
                // 改变_bottomButton的title
                [_OKBtn setEnabled:YES];
                [_OKBtn setTitle:[NSString stringWithFormat:@"确定(%lu)", _bottomDataSourceArray.count-1] forState:UIControlStateNormal];
                
                // 动态插入cell
                [_tableView_H beginUpdates];
                [_tableView_H insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationBottom];
                [_tableView_H endUpdates];
                
            }
            //最近联系人和通讯录同步状态.前提条件存在最近联系人
            NSIndexPath *index = nil;
            if (_recentContactArray && _recentContactArray.count > 0) {
                if (indexPath.section == 1) {
                    NSInteger sectionIndex = 1;
                    for (int i = 1; i < _dataSourceArray.count; i++) {
                        sectionIndex ++;
                        NSInteger rowIndex = 0;
                        for (ContactModel *newModel in _dataSourceArray[i]) {
                            if (newModel.userID == model.userID) {
                                newModel.isSelect = model.isSelect;
                                index = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
                                ChatContactDetalsCell *cell = (ChatContactDetalsCell *)[tableView cellForRowAtIndexPath:index];
                                [cell configWithModel:newModel];
                            }
                            rowIndex ++;
                        }
                        
                    }
                } else {
                    NSInteger sectionIndex = 1;
                    NSInteger rowIndex = 0;
                    for (ContactModel *newModel in _dataSourceArray[0]) {
                        if (newModel.userID == model.userID) {
                            newModel.isSelect = model.isSelect;
                            index = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
                            ChatContactDetalsCell *cell = (ChatContactDetalsCell *)[tableView cellForRowAtIndexPath:index];
                            [cell configWithModel:newModel];
                        }
                        rowIndex ++;
                    }
                }
            }
            
            //改变当前cell
            ChatContactDetalsCell *cell = (ChatContactDetalsCell *)[tableView cellForRowAtIndexPath:indexPath];
            [cell configWithModel:model];
            
            path = [NSIndexPath indexPathForRow:[_tableView_H numberOfRowsInSection:0]-1 inSection:0];
            [_tableView_H scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            
            [_tableView_H reloadData];
            
        }
    } else if (tableView == _searchController.searchResultsTableView) {
        NSIndexPath *path = nil;
        ContactModel *item = _saveResultArray[indexPath.section][indexPath.row];
        if (item.isSelect) {
            
        }else{
            item.isSelect = YES;
            if (_recentContactArray && _recentContactArray.count > 0) {
                NSInteger sectionIndex = 1;
                NSInteger rowIndex = 0;
                NSIndexPath *index = nil;
                for (ContactModel *newModel in _dataSourceArray[0]) {
                    if (newModel.userID == item.userID) {
                        newModel.isSelect = item.isSelect;
                        index = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
                        ChatContactDetalsCell *cell = (ChatContactDetalsCell *)[tableView cellForRowAtIndexPath:index];
                        [cell configWithModel:newModel];
                    }
                    rowIndex ++;
                }
            }
            
            // 申明path，保存在_bottomTableView倒数第二行的位置插入数据
            path = [NSIndexPath indexPathForRow:_bottomDataSourceArray.count-1 inSection:0];
            
            // 选中添加数据
            [_bottomDataSourceArray insertObject:item atIndex:_bottomDataSourceArray.count-1];
            // 改变_bottomButton的title
            [_OKBtn setTitle:[NSString stringWithFormat:@"确定(%lu)", _bottomDataSourceArray.count-1] forState:UIControlStateNormal];
            [_OKBtn setEnabled:YES];
            
            // 动态插入cell
            [_tableView_H beginUpdates];
            [_tableView_H insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationBottom];
            [_tableView_H endUpdates];
        }
        [_searchController setActive:NO];
        [self.tableView_V reloadData];
        ///滑动到最顶部
        //        [self.tableViewChat setContentOffset:CGPointZero animated:NO];
        
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *header = @"customHeader";
    
    UITableViewHeaderFooterView *vHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:header];
    
    if (!vHeader) {
        vHeader = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:header];
        //        vHeader.textLabel.textColor = [UIColor colorWithHexString:@"f9f9f9"];
        vHeader.textLabel.font = [UIFont systemFontOfSize:13];
        vHeader.contentView.backgroundColor = [UIColor colorWithHexString:@"f9f9f9"];
    }
    
    vHeader.textLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    return vHeader;
}
- (void)getContactAction {
    if (_bottomDataSourceArray && _bottomDataSourceArray.count > 1) {
        NSMutableArray *newArray = [NSMutableArray arrayWithArray:_bottomDataSourceArray];
        [newArray removeLastObject];
        ChatViewController *contactroller = [[ChatViewController alloc] init];
        isAllSelect = YES;
        [_tableView_V reloadData];
        //触发确定事件
        //1.从通讯录发起聊天
          //①直接进入聊天界面，存不存在的逻辑交给聊天界面处理
        //2.两人会话跳转到通讯录页面
          //②先判断存在不存在符合要求的讨论组，如果存在则创建，不存在跳转
        //3.讨论组跳转到通讯录
          //③返回新添加的联系人，并将新添加的联系人添加到该讨论组中
        
        if (_flag_controller == ControllerPopTypeBack) {
            if ([_groupType isEqualToString:@"0"]) {
                //先判断是否已存在，存在则进入已有讨论组，否则创建
                NSArray *groupIds = [IM_FMDB_FILE result_IM_UsersListOfGroupType:@"1"];
                if (groupIds.count > 0) {
                    for (NSString *string in groupIds) {
                        NSArray *userArray = [IM_FMDB_FILE result_IM_UserList:string];
                        NSMutableArray *idsArray = [NSMutableArray arrayWithCapacity:0];
                        for (ContactModel *userModel in userArray) {
                            if (userModel.userID != [appDelegateAccessor.moudle.userId longLongValue]) {
                                [idsArray addObject:@(userModel.userID)];
                            }
                        }
                        
                        if ([self isHasGroupWithNewIdsAarray:[self getContactIds:newArray] withOldIdsAarray:idsArray]) {
                            NSLog(@"已存在");
                            [self pushIntoChatView:string];
                            return;
                        }
                    }
                    [self getCreateGroup:newArray];
                    NSLog(@"---- 不存在---");
                } else {
                    [self getCreateGroup:newArray];
                    return;
                }
            } else {
                if (_BackContactsBlock) {
                    _BackContactsBlock(newArray);
                }
                contactroller.pushType = ControllerPushTypeMessageVC;
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            contactroller.usersArray = newArray;
            contactroller.pushType = ControllerPushTypeStartChatVC;
            [self.navigationController pushViewController:contactroller animated:YES];
        }
    }
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

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
//    [tableView setContentInset:UIEdgeInsetsZero];
//    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
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
    UIView *Vv = [[UIView alloc] initWithFrame:CGRectZero];
    [_searchController.searchResultsTableView setTableFooterView:Vv];
    [_resultsArray removeAllObjects];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    
    
    int index = 0;
    if (_recentContactArray && _recentContactArray.count > 0) {
        index = 1;
    }
    if (index >= _dataSourceArray.count) {
        return;
    }
    for (int i = index; i < _dataSourceArray.count; i++) {
        for (ContactModel *model in _dataSourceArray[i]) {
            [array addObject:model];
        }
    }
    
    
    for (int i = 0; i < array.count; i++) {
        _contactItem = array[i];
        NSString *contactName = _contactItem.contactName;
        NSString *pinyinName = [ChineseToPinyin pinyinFromChiniseString:contactName];
//        NSLog(@"%@---%@", pinyinName, contactName);
        if([self searchResult:pinyinName searchText:searchText])
        {
            [_resultsArray addObject:_contactItem];
        } else {
            NSString *chineseName = [self namToPinYinFisrtNameWith:contactName];
            if([self searchResult:chineseName searchText:searchText]){
                [_resultsArray addObject:_contactItem];
            } else if([self searchResult:contactName searchText:searchText]){
                [_resultsArray addObject:_contactItem];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setFrameForAllPhone {
    CGFloat vX = kScreen_Width - 320;
    CGFloat vH = kScreen_Height - 568;
    self.view.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
    _tableView_H.frame = [CommonFuntion setViewFrameOffset:_tableView_H.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    _tableView_V.frame = [CommonFuntion setViewFrameOffset:_tableView_V.frame byX:0 byY:0 ByWidth:vX byHeight:vH];
    _bottomBgView.frame = [CommonFuntion setViewFrameOffset:_bottomBgView.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    _searchBar.frame = [CommonFuntion setViewFrameOffset:_searchBar.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    _OKBtn.frame = [CommonFuntion setViewFrameOffset:_OKBtn.frame byX:vX byY:0 ByWidth:0 byHeight:0];
}

- (void)getCreateGroup:(NSArray *)array {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    NSArray *idsArray = [NSArray arrayWithArray:[self getContactIds:array]];
    NSString *idsStr = [idsArray componentsJoinedByString:@","];
    [params setObject:appDelegateAccessor.moudle.userId forKey:@"userId"];
    [params setObject:idsStr forKey:@"ids"];
    [params setObject:appDelegateAccessor.moudle.IM_tokenString forKey:@"token"];
    __weak typeof(self) weak_self = self;
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_IM, IM_GET_CREATE_GROUP] params:params success:^(id responseObj) {
//        NSLog(@"----%@", responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            if ([CommonFuntion checkNullForValue:[responseObj objectForKey:@"body"]]) {
                _groupType = [NSString stringWithFormat:@"%@", [[responseObj objectForKey:@"body"] objectForKey:@"type"]];
            }
            NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
            NSArray *oldArray = [NSArray arrayWithArray:[IM_FMDB_FILE result_IM_RecentContactList]];
            NSMutableArray *oldIdsArray = [NSMutableArray arrayWithCapacity:0];
            
            //去重处理
            if (oldArray.count > 0) {
                for (ContactModel *oldModel in oldArray) {
                    if (![oldIdsArray containsObject:@(oldModel.userID)]) {
                        [oldIdsArray addObject:@(oldModel.userID)];
                    }
                }
                for (ContactModel *model in array) {
                    if (![oldIdsArray containsObject:@(model.userID)]) {
                        [newArray addObject:model];
                    }
                }
            } else {
                [newArray addObjectsFromArray:array];
            }
            //合并数据
            newArray = (NSMutableArray *)[[newArray reverseObjectEnumerator] allObjects];
            oldArray = (NSMutableArray *)[[oldArray reverseObjectEnumerator] allObjects];
            
            [newArray addObjectsFromArray:oldArray];
            
            if (newArray && newArray.count > 5) {
                newArray  = [NSMutableArray arrayWithArray:[newArray subarrayWithRange:NSMakeRange(0, 4)]];
            }
            [IM_FMDB_FILE delete_IM_AllRecentContact];
            for (ContactModel *model in newArray) {
                if (model.userID != [appDelegateAccessor.moudle.userId integerValue]) {
                    [IM_FMDB_FILE insert_IM_RecentContact:model];
                }
            }
            [IM_FMDB_FILE closeDataBase];
            [self pushIntoChatView:[NSString stringWithFormat:@"%@", [[responseObj objectForKey:@"body"] objectForKey:@"id"]]];
//            [weak_self.navigationController popToRootViewControllerAnimated:YES];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getCreateGroup:array];
            };
            [comRequest loginInBackground];
        }
    } failure:^(NSError *error) {
        NSLog(@"----%@", error);
    }];
}
//获取已有成员id
- (NSMutableArray *)getContactIds:(NSArray *)newAarray {
    _groupNameTitle = @"";
    NSMutableArray *idsArray = [NSMutableArray arrayWithCapacity:0];
    for (ContactModel *model in newAarray) {
        if (model.userID != [appDelegateAccessor.moudle.userId integerValue]) {
            [idsArray addObject:@(model.userID)];
        }
        if ([CommonFuntion checkNullForValue:_groupNameTitle]) {
            _groupNameTitle = [NSString stringWithFormat:@"%@,%@", _groupNameTitle, model.contactName];
        } else {
            _groupNameTitle = model.contactName;
        }
        
    }
    
    for (ContactModel *model in _GroupContactArray) {
        if (model.userID != [appDelegateAccessor.moudle.userId integerValue] && ![idsArray containsObject:@(model.userID)]) {
            [idsArray addObject:@(model.userID)];
            if ([CommonFuntion checkNullForValue:_groupNameTitle]) {
                _groupNameTitle = [NSString stringWithFormat:@"%@,%@", _groupNameTitle, model.contactName];
            } else {
                _groupNameTitle = model.contactName;
            }
        }
    }
    return idsArray;
}
- (BOOL)isHasGroupWithNewIdsAarray:(NSArray *)newIdsAarray withOldIdsAarray:(NSArray *)oldIdsAarray {
    if (oldIdsAarray.count != 0 && newIdsAarray.count != oldIdsAarray.count) {
        return NO;
    }
    for (NSString *newId in newIdsAarray) {
        if ([oldIdsAarray containsObject:newId]) {
           
        } else {
            return NO;
        }
    }
    return YES;
}
#pragma mark - getter
- (UITableView *)tableView_V {
    if (!_tableView_V) {
        _tableView_V = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - 50) style:UITableViewStylePlain];
        _tableView_V.delegate = self;
        _tableView_V.dataSource = self;
        _tableView_V.sectionIndexBackgroundColor = [UIColor clearColor];
        _tableView_V.sectionIndexColor = [UIColor lightGrayColor];
        _tableView_V.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    }
    return _tableView_V;
}
- (UIView *)bottomBgView {
    if (!_bottomBgView) {
        _bottomBgView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height - 50, kScreen_Width, 50)];
        _bottomBgView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    }
    return _bottomBgView;
}
- (UITableView *)tableView_H {
    if (!_tableView_H) {
        _tableView_H = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView_H.transform = CGAffineTransformMakeRotation(M_PI / -2);
        _tableView_H.frame = CGRectMake(0, 0, kScreen_Width - 70, 50);
        _tableView_H.delegate = self;
        _tableView_H.dataSource = self;
        _tableView_H.rowHeight = 50;
        _tableView_H.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
        _tableView_H.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView_H;
}
- (UIButton *)OKBtn {
    if (!_OKBtn) {
        _OKBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _OKBtn.frame = CGRectMake(kScreen_Width - 60, 5, 60, 40);
        [_OKBtn setEnabled:NO];
        [_OKBtn setTitle:@"确定" forState:UIControlStateNormal];
        _OKBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_OKBtn setTitleColor:COMMEN_LABEL_COROL forState:UIControlStateNormal];
        [_OKBtn addTarget:self action:@selector(getContactAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _OKBtn;
}
- (void)pushIntoChatView:(NSString *)groupId {
    NSArray *allGroup = [IM_FMDB_FILE result_IM_ConversationListWithResultType:@"result"];
    ConversationListModel *model = [[ConversationListModel alloc] init];
    for (ConversationListModel *ConModel in allGroup) {
        if ([ConModel.b_id isEqualToString:groupId]) {
            model = ConModel;
        }
    }
    ChatViewController *chatController = [[ChatViewController alloc] init];
    chatController.hidesBottomBarWhenPushed = YES;
    //
    if (![CommonFuntion checkNullForValue:model.b_name]) {
        model.b_name = _groupNameTitle;
    }
    chatController.titleName = model.b_name;
    chatController.groupID = groupId;
    chatController.groupType = @"1";
    chatController.unReadMessageCount = [model.b_unReadNumber integerValue];
    chatController.pushType = ControllerPushTypeMessageVC;
    chatController.usersArray = model.usersListArray;
    chatController.unSendStr = model.m_content;
    chatController.RefreshDataSourceBlock = ^(NSDictionary *dict, NSString *sting) {
        if (sting && sting.length > 0 && [sting stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0) {
            [IM_FMDB_FILE update_IM_ConversationListGroupID:model.b_id withUnsendSting:[NSString stringWithFormat:@"[草稿]%@", sting]];
        } else {
            
            //修改已读消息number  和 未读消息数
            [IM_FMDB_FILE update_IM_ConversationListGroupID:model.b_id withReadNumber:[NSString stringWithFormat:@"%@", [dict objectForKey:@"number"]] withUnReadNumber:@"0"];
        }
        [IM_FMDB_FILE update_IM_ConversationListGroupID:[NSString stringWithFormat:@"%@", [dict objectForKey:@"to"]] withShow:@"1"];
        [IM_FMDB_FILE closeDataBase];
        Message_RootViewController *messageController = [[Message_RootViewController alloc] init];
        [messageController getConversationList];
    };
    //修改已读消息number  和 未读消息数
    [IM_FMDB_FILE update_IM_ConversationListGroupID:model.b_id withReadNumber:model.m_number withUnReadNumber:@"0"];
    [IM_FMDB_FILE closeDataBase];
    [self.navigationController pushViewController:chatController animated:YES];
    return;
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
