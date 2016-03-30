//
//  SKTSelectMemberController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SKTSelectMemberController.h"
#import "ExportAddressTableViewCell.h"
#import "ExportBottomTableViewCell.h"
#import "AddressBook.h"
#import "AddressBookGroup.h"
#import "SKTFilterValue.h"
#import "AFNHttp.h"
#import <MBProgressHUD.h>

#define kCellIdentifier @"ExportAddressTableViewCell"
#define kBottomCellIdentifier @"ExportBottomTableViewCell"

@interface SKTSelectMemberController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) UISearchBar *mySearchBar;
@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, strong) NSMutableArray *sourceArray;
@property (nonatomic, strong) NSMutableArray *groupArray;       // 保存分组后的数据
@property (nonatomic, strong) NSMutableArray *searchResults;    // 保存搜索后的数据

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UITableView *bottomTableView;
@property (nonatomic, strong) UILabel *bottomSelectedLabel;
@property (nonatomic, strong) UIButton *bottomConfirmBtn;       // 确认按钮
@property (nonatomic, strong) NSMutableArray *bottomSourceArray;    // 选中通讯录列表数据源


- (void)groupingDataSourceFrom:(NSMutableArray*)fromArray to:(NSMutableArray*)toArray;  // 数据分组

- (void)updateBottomView;   // 更新bottomSelectedLabel和bottomConfirmBtn的属性值
@end

@implementation SKTSelectMemberController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    // 自定义返回按钮 开启手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(leftButtonItemPress)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    [self.view addSubview:self.myTableView];
    
    _mySearchDisplayController = ({
        UISearchDisplayController *searchVC = [[UISearchDisplayController alloc] initWithSearchBar:_mySearchBar contentsController:self];
        [searchVC.searchResultsTableView registerClass:[ExportAddressTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        searchVC.searchResultsTableView.tableFooterView = [[UIView alloc] init];
        searchVC.delegate = self;
        searchVC.searchResultsDataSource = self;
        searchVC.searchResultsDelegate = self;
        searchVC.displaysSearchBarInNavigationBar = NO;
        searchVC.searchBar.tintColor = LIGHT_BLUE_COLOR;
        searchVC;
    });
    
    [self.view addSubview:self.bottomView];
    [_bottomView addSubview:self.bottomTableView];
    [_bottomView addSubview:self.bottomSelectedLabel];
    [_bottomView addSubview:self.bottomConfirmBtn];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _sourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    _groupArray = [[NSMutableArray alloc] initWithCapacity:0];
    _searchResults = [[NSMutableArray alloc] initWithCapacity:0];
    _bottomSourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    
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
//                AddressBook *addressItem = [AddressBook initWithDictionary:tempDict];
//                [_sourceArray addObject:addressItem];
            }
            
            // 过滤数据
            for (SKTFilterValue *tempItem in _selectedArray) {
//                for (AddressBook *tempBook in _sourceArray) {
//                    if (tempItem.m_id == tempBook.m_userid) {
//                        [_sourceArray removeObject:tempBook];
//                        break;
//                    }
//                }
            }
            
            [self groupingDataSourceFrom:_sourceArray to:_groupArray];
            [_myTableView reloadData];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        
    }];
    
    // 默认添加一个空数据
    AddressBook *item = [[AddressBook alloc] init];
    item.isDefault = YES;
    item.icon = @"Head_Box";
    [_bottomSourceArray addObject:item];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)leftButtonItemPress {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)confirmButtonPress {
    if (self.valueBlock) {
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < _bottomSourceArray.count - 1; i ++) {
//            AddressBook *tempItem = _bottomSourceArray[i];
//            AddressSelectModel *selectItem = [AddressSelectModel initWithModel:tempItem];
//            [tempArray addObject:selectItem];
        }
        self.valueBlock(tempArray);
    }
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

- (void)updateBottomView {
    if (_bottomSourceArray.count) {
        _bottomConfirmBtn.enabled = YES;
        
        _bottomSelectedLabel.hidden = NO;
        _bottomSelectedLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
        _bottomSelectedLabel.text = [NSString stringWithFormat:@"%d", _bottomSourceArray.count - 1];
        
        [UIView animateWithDuration:0.3 animations:^{
            _bottomSelectedLabel.transform = CGAffineTransformMakeScale(1.125, 1.125);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                _bottomSelectedLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
            } completion:nil];
        }];
        
        return;
    }
    
    _bottomConfirmBtn.enabled = NO;
    _bottomSelectedLabel.hidden = YES;
    _bottomSelectedLabel.text = @"0";
}

#pragma mark - UITableView_M
- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        return nil;
    }
    if (tableView == _bottomTableView) {
        return nil;
    }
    
    NSMutableArray *indexs = [NSMutableArray array];
    for (AddressBookGroup *group in _groupArray) {
        [indexs addObject:group.groupName];
    }
    return indexs;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // 搜索列表
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        if (_searchResults.count) {
            AddressBookGroup *group = _searchResults[section];
            return group.groupName;
        }
        return @"";
    }
    
    // 主列表
    if (tableView == _myTableView) {
        AddressBookGroup *group = _groupArray[section];
        return group.groupName;
    }
    
    // 底部选择表格
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        if (_searchResults.count) {
            return _searchResults.count;
        }
        return 0;
    }
    
    if (tableView == _myTableView) {
        return _groupArray.count;
    }
    
    // bottomTableView默认为一组
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        if (_searchResults.count) {
            AddressBookGroup *group = _searchResults[section];
            return group.groupItems.count;
        }
        return 0;
    }
    
    if (tableView == _myTableView) {
        AddressBookGroup *group = _groupArray[section];
        return group.groupItems.count;
    }
    
    return [_bottomSourceArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _bottomTableView) {
        return [ExportBottomTableViewCell cellHeight];
    }
    
    return [ExportAddressTableViewCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _bottomTableView) {
        ExportBottomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBottomCellIdentifier forIndexPath:indexPath];
        AddressBook *item = _bottomSourceArray[indexPath.row];
        [cell configWithModel:item];
        return cell;
    }
    
    ExportAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
//    if (tableView == _mySearchDisplayController.searchResultsTableView) {
//        AddressBookGroup *group = _searchResults[indexPath.section];
//        [cell configWithModel:group.groupItems[indexPath.row] withType:0];
//    }else {
//        AddressBookGroup *group = _groupArray[indexPath.section];
//        [cell configWithModel:group.groupItems[indexPath.row] withType:0];
//    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSIndexPath *path = nil;
    
    if (tableView == _myTableView) {
        AddressBookGroup *group = _groupArray[indexPath.section];
        AddressBook *bookItem = group.groupItems[indexPath.row];
        
        if (bookItem.isSelected) {
            bookItem.isSelected = NO;
            
            // 在bottomSourceArray数组中找到并取消选中该联系人
            for (int i = 0; i < _bottomSourceArray.count - 1; i ++) {
                AddressBook *tempItem = _bottomSourceArray[i];
//                if (tempItem.m_userid == bookItem.m_userid) {
//                    // 赋值path，用于删除在bottomtableview的数据
//                    path = [NSIndexPath indexPathForRow:i inSection:0];
//                    // 从bottomSourceArray中删除选中数据
//                    [_bottomSourceArray removeObjectAtIndex:i];
//                    
//                    [self updateBottomView];
//                }
            }
            
            // 将数据从AddressSelectMorePreModel中删除
//            for (int i = 0; i < _preSourceModel.selectedArray.count; i ++) {
//                AddressSelectModel *tempItem = _preSourceModel.selectedArray[i];
//                if (tempItem.m_id == bookItem.m_userid) {
//                    [_preSourceModel.selectedArray removeObject:tempItem];
//                }
//            }
//            
            // 动态删除cell
            [_bottomTableView beginUpdates];
            [_bottomTableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationBottom];
            [_bottomTableView endUpdates];
        }else {
            bookItem.isSelected = YES;
            
            // 把数据添加到AddressSelectMorePreModel中
//            AddressSelectModel *item = [AddressSelectModel initWithModel:bookItem];
//            [_preSourceModel.selectedArray addObject:item];
            
            //申明path，在_bottomTableView倒数第二行位置插入数据
            path = [NSIndexPath indexPathForRow:_bottomSourceArray.count - 1 inSection:0];
            
            // 选中添加数据
            [_bottomSourceArray insertObject:bookItem atIndex:_bottomSourceArray.count - 1];
            
            [self updateBottomView];
            
            // 动态插入cell
            [_bottomTableView beginUpdates];
            [_bottomTableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationBottom];
            [_bottomTableView endUpdates];
        }
        
        // 改变当前cell的选中状态
        ExportAddressTableViewCell *cell = (ExportAddressTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
//        [cell configWithModel:bookItem withType:0];
        
        // 让_bottomTableView显示最后一行
        path = [NSIndexPath indexPathForRow:[_bottomTableView numberOfRowsInSection:0] - 1 inSection:0];
        [_bottomTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
}

#pragma mark - UISearchDisplayDelegate M
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
- (UISearchBar*)mySearchBar {
    if (!_mySearchBar) {
        _mySearchBar = [[UISearchBar alloc] init];
        _mySearchBar.placeholder = @"搜索";
        _mySearchBar.delegate = self;
        [_mySearchBar sizeToFit];
    }
    return _mySearchBar;
}

- (UITableView*)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height-54) style:UITableViewStylePlain];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        [_myTableView registerClass:[ExportAddressTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        _myTableView.tableHeaderView = self.mySearchBar;
        _myTableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _myTableView.sectionIndexColor = [UIColor lightGrayColor];
        _myTableView.tableFooterView = [[UIView alloc] init];
    }
    return _myTableView;
}

- (UIView*)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height-54, kScreen_Width, 54)];
        _bottomView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    }
    return _bottomView;
}

- (UITableView*)bottomTableView {
    if (!_bottomTableView) {
        _bottomTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 54, CGRectGetWidth(_bottomView.bounds)-10-72) style:UITableViewStylePlain];
        _bottomTableView.center = CGPointMake((CGRectGetWidth(_bottomView.bounds)-72-10)/2.0, CGRectGetHeight(_bottomView.bounds)/2.0);
        _bottomTableView.backgroundView = nil;
        _bottomTableView.backgroundColor = [UIColor clearColor];
        _bottomTableView.transform = CGAffineTransformMakeRotation(-M_PI/2);
        _bottomTableView.showsVerticalScrollIndicator = NO;
        _bottomTableView.delegate = self;
        _bottomTableView.dataSource = self;
        _bottomTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_bottomTableView registerClass:[ExportBottomTableViewCell class] forCellReuseIdentifier:kBottomCellIdentifier];
        _bottomTableView.tableFooterView = [[UIView alloc] init];
    }
    return _bottomTableView;
}

- (UILabel*)bottomSelectedLabel {
    if (!_bottomSelectedLabel) {
        _bottomSelectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - 50 - 24, 15, 24, 24)];
        _bottomSelectedLabel.backgroundColor = [UIColor colorWithRed:(CGFloat)34/255.0f green:(CGFloat)192/255.f blue:(CGFloat)100/255.f alpha:1.f];
        _bottomSelectedLabel.textColor = [UIColor whiteColor];
        _bottomSelectedLabel.font = [UIFont systemFontOfSize:14.f];
        _bottomSelectedLabel.textAlignment = NSTextAlignmentCenter;
        _bottomSelectedLabel.layer.cornerRadius = 12.f;
        _bottomSelectedLabel.layer.masksToBounds = YES;
        _bottomSelectedLabel.clipsToBounds = YES;
        _bottomSelectedLabel.hidden = YES;
    }
    return _bottomSelectedLabel;
}

- (UIButton*)bottomConfirmBtn {
    if (!_bottomConfirmBtn) {
        _bottomConfirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _bottomConfirmBtn.frame = CGRectMake(kScreen_Width-50, 0, 50, 54);
        _bottomConfirmBtn.enabled = NO;
        _bottomConfirmBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_bottomConfirmBtn setTitleColor:[[UIColor alloc] initWithRed:34/255.f green:192/255.f blue:100/255.f alpha:1.0]
                                forState:UIControlStateNormal];
        [_bottomConfirmBtn setTitleColor:[[UIColor alloc] initWithRed:34/255.f green:192/255.f blue:100/255.f alpha:0.3]
                                forState:UIControlStateDisabled];
        [_bottomConfirmBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_bottomConfirmBtn addTarget:self action:@selector(confirmButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomConfirmBtn;
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
