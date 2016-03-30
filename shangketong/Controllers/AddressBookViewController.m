//
//  AddressBookViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AddressBookViewController.h"
#import "UIViewController+Expand.h"
#import "ExportAddressViewController.h"
#import "AddressBookTableViewCell.h"
#import "AddressBookRecentlyCell.h"
#import "AddressBookActionSheet.h"
#import "DepartGroupViewController.h"
#import "InfoViewController.h"

#define kCellIdentifier @"AddressBookTableViewCell"
#define kCellIdentifier_recently @"AddressBookRecentlyCell"

@interface AddressBookViewController ()

@property (strong, nonatomic) NSMutableArray *recentlyArray;
@end

@implementation AddressBookViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"导出" target:self action:@selector(rightButtonItemPress)];
    [self.tableView registerClass:[AddressBookTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    [self.tableView registerClass:[AddressBookRecentlyCell class] forCellReuseIdentifier:kCellIdentifier_recently];
    [self.mSearchDisplayController.searchResultsTableView registerClass:[AddressBookTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _recentlyArray = [[FMDBManagement sharedFMDBManager] getRecentlyAddressBookDataSource];

    if (self.sourceArray) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sendRequest];
        });
    }else {
        [self.view beginLoading];
        [self sendRequest];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)leftButtonItemPress {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonItemPress {
    ExportAddressViewController *exportAddressController = [[ExportAddressViewController alloc] init];
    exportAddressController.title = @"导出到手机";
    [self.navigationController pushViewController:exportAddressController animated:YES];
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
        return self.searchResults.count;
    }
    
    // 最近
    if (_recentlyArray.count) {
        return self.groupsArray.count + 2;
    }
    
    return self.groupsArray.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
        AddressBookGroup *group = self.searchResults[section];
        return group.groupItems.count;
    }
    
    // 公司部门和群组
    if (!section) {
        return 2;
    }
    
    // 最近
    if (_recentlyArray.count && section == 1) {
        return 1;
    }
    
    if (_recentlyArray.count) {
        AddressBookGroup *group = self.groupsArray[section - 2];
        return group.groupItems.count;
    }else {
        AddressBookGroup *group = self.groupsArray[section - 1];
        return group.groupItems.count;
    }
}

// 分组的标题名称
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    [headerView setWidth:kScreen_Width];
    [headerView setHeight:22];
    headerView.backgroundColor = COMM_SEARCHBAR_BACKGROUNDCOLOR;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setX:kCellLeftWidth];
    [titleLabel setWidth:100];
    [titleLabel setHeight:CGRectGetHeight(headerView.bounds)];
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.textColor = [UIColor colorWithHexString:@"0x8e8e93"];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:titleLabel];
    
    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
        AddressBookGroup *group = self.searchResults[section];
        titleLabel.text = group.groupName;
        return headerView;
    }
    
    // 公司部门和群组
    if (section == 0) {
        return nil;
    }
    
    // 最近
    if (_recentlyArray.count && section == 1) {
        titleLabel.text = @"最近";
    }
    else {
        if (_recentlyArray.count) {
            AddressBookGroup *group = self.groupsArray[section - 2];
            titleLabel.text = group.groupName;
        }else {
            AddressBookGroup *group = self.groupsArray[section - 1];
            titleLabel.text = group.groupName;
        }
    }

    return headerView;
}

//- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
//        AddressBookGroup *group = self.searchResults[section];
//        return group.groupName;
//    }
//    
//    // 公司部门和群组
//    if (section == 0) {
//        return nil;
//    }
//    
//    // 最近
//    if (_recentlyArray.count && section == 1) {
//        return @"最近";
//    }
//    
//    if (_recentlyArray.count) {
//        AddressBookGroup *group = self.groupsArray[section - 2];
//        return group.groupName;
//    }else {
//        AddressBookGroup *group = self.groupsArray[section - 1];
//        return group.groupName;
//    }
//}

// 索引
- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
        return nil;
    }
    
    NSMutableArray *indexs = [NSMutableArray array];
    
    // 公司部门和群组索引不显示
    [indexs addObject:@""];
    
    // 最近的通讯录
    if (_recentlyArray.count) {
        [indexs addObject:@"★"];
    }
    
    for (AddressBookGroup *group in self.groupsArray) {
        [indexs addObject:group.groupName];
    }
    return indexs;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_recentlyArray.count && indexPath.section == 1) {
        return [AddressBookRecentlyCell cellHeight];
    }
    
    return [AddressBookTableViewCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 最近联系人
    if (_recentlyArray.count && indexPath.section == 1) {
        AddressBookRecentlyCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_recently forIndexPath:indexPath];
        cell.iconViewTapBlock = ^(AddressBook *item) {
            InfoViewController *infoController = [[InfoViewController alloc] init];
            infoController.title = @"个人信息";
            if ([appDelegateAccessor.moudle.userId integerValue] == [item.id integerValue]) {
                infoController.infoTypeOfUser = InfoTypeMyself;
            }else{
                infoController.infoTypeOfUser = InfoTypeOthers;
                infoController.userId = [item.id integerValue];
            }
            [self.navigationController pushViewController:infoController animated:YES];
        };
        [cell configWithArray:_recentlyArray];
        return cell;
    }
    
    AddressBookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    if (tableView == self.tableView && indexPath.section == 0) {
        NSArray *array = @[@{@"image":@"colleague_depart_icon", @"title":@"公司部门"},
                           @{@"image":@"colleague_group_icon", @"title":@"群组"}];
        [cell configWithImageOfName:[[array objectAtIndex:indexPath.row] objectForKey:@"image"] title:[[array objectAtIndex:indexPath.row] objectForKey:@"title"]];
        return cell;
    }
    
    AddressBookGroup *group;
    AddressBook *item;
    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
        group = self.searchResults[indexPath.section];
        item = group.groupItems[indexPath.row];
        [cell configWithModel:item];
    }
    else {
        if (_recentlyArray.count) {
            group = self.groupsArray[indexPath.section - 2];
        }else {
            group = self.groupsArray[indexPath.section - 1];
        }
        item = group.groupItems[indexPath.row];
        [cell configWithModel:item];
    }
    
    cell.phoneBtnClickedBlock = ^{
        [self.view endEditing:YES];
        
        AddressBookActionSheet *actionSheet = [[AddressBookActionSheet alloc] initWithCancelTitle:@"取消" andMobile:item.mobile andPhone:item.phone];
        actionSheet.phoneBlock = ^(NSString *tel) {
            [[FMDBManagement sharedFMDBManager] casheRecentlyAddressBookWithItem:item];
            [self takePhoneWithNumber:tel];
        };
        actionSheet.msgBlock = ^(NSString *tel) {
            [[FMDBManagement sharedFMDBManager] casheRecentlyAddressBookWithItem:item];
            [self sendMessageWithRecipients:@[tel]];
        };
        [actionSheet show];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
        AddressBookGroup *group = self.searchResults[indexPath.section];
        AddressBook *item = group.groupItems[indexPath.row];
        InfoViewController *infoController = [[InfoViewController alloc] init];
        infoController.title = @"个人信息";
        if ([appDelegateAccessor.moudle.userId integerValue] == [item.id integerValue]) {
            infoController.infoTypeOfUser = InfoTypeMyself;
        }else{
            infoController.infoTypeOfUser = InfoTypeOthers;
            infoController.userId = [item.id integerValue];
        }
        [self.navigationController pushViewController:infoController animated:YES];
        return;
    }
    
    if (indexPath.section == 0) {
        DepartGroupViewController *departGroupController = [[DepartGroupViewController alloc] init];
        if (indexPath.row == 0) {
            departGroupController.title = @"公司部门";
            departGroupController.type = DepartGroupViewControllerTypeDepartment;
        }else {
            departGroupController.title = @"群组";
            departGroupController.type = DepartGroupViewControllerTypeGroup;
        }
        [self.navigationController pushViewController:departGroupController animated:YES];
        
    }else if (_recentlyArray.count && indexPath.section == 1) {
        
    }else {
        AddressBookGroup *group;
        if (_recentlyArray.count) {
            group = self.groupsArray[indexPath.section - 2];
        }else {
            group = self.groupsArray[indexPath.section - 1];
        }
        AddressBook *item = group.groupItems[indexPath.row];
        
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
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
        return 22.;
    }
    if (section == 0) {
        return 0.;
    }
    return 22.;
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
