//
//  AddressSelectedController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AddressSelectedController.h"
#import "ExportAddressViewController.h"
#import "AddressBookTableViewCell.h"

#define kCellIdentifier @"AddressBookTableViewCell"

@interface AddressSelectedController ()

@end

@implementation AddressSelectedController
@synthesize rowDescriptor = _rowDescriptor;
@synthesize popoverController = __popoverController;

- (void)loadView {
    [super loadView];
        
    // 自定义返回按钮 开启手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(leftButtonItemPress)];
    
    if (_activityRecBtnImage) {
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithIcon:_activityRecBtnImage showBadge:YES target:self action:@selector(rightButtonPress)];
    }
    
    [self.tableView registerClass:[AddressBookTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    [self.mSearchDisplayController.searchResultsTableView registerClass:[AddressBookTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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

- (void)rightButtonPress {
    @weakify(self);
    ExportAddressViewController *exportController = [[ExportAddressViewController alloc] init];
    exportController.title = @"设置默认优先显示";
    exportController.isActivityRecExport = YES;
    exportController.valueBlock = ^(NSArray *array) {
        @strongify(self);
        if (self.activityRecBlock) {
            self.activityRecBlock(array);
        }
    };
    [self.navigationController pushViewController:exportController animated:YES];
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
        return self.searchResults.count;
    }

    return self.groupsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
        AddressBookGroup *group = self.searchResults[section];
        return group.groupItems.count;
    }
    
    AddressBookGroup *group = self.groupsArray[section];
    return group.groupItems.count;
}

// 分组的标题名称
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
        AddressBookGroup *group = self.searchResults[section];
        return group.groupName;
    }
    
    AddressBookGroup *group = self.groupsArray[section];
    return group.groupName;
}

// 索引
- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
        return nil;
    }
    
    NSMutableArray *indexs = [NSMutableArray array];
    for (AddressBookGroup *group in self.groupsArray) {
        [indexs addObject:group.groupName];
    }
    return indexs;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AddressBookTableViewCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddressBookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
        AddressBookGroup *group = self.searchResults[indexPath.section];
        [cell configWithModel:group.groupItems[indexPath.row]];
        return cell;
    }
    
    AddressBookGroup *group = self.groupsArray[indexPath.section];
    [cell configWithoutButtonWithModel:group.groupItems[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AddressBookGroup *group;
    if (tableView == self.mSearchDisplayController.searchResultsTableView) {
        group = self.searchResults[indexPath.section];
    }else {
        group = self.groupsArray[indexPath.section];
    }
    
    if (self.selectedBlock) {
        if (self.flagForPopViewAnimation && [self.flagForPopViewAnimation isEqualToString:@"no"]) {
            [self.navigationController popViewControllerAnimated:NO];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
        self.selectedBlock(group.groupItems[indexPath.row]);
        return;
    }
    
    self.rowDescriptor.value = group.groupItems[indexPath.row];
    
    if (self.popoverController){
        [self.popoverController dismissPopoverAnimated:YES];
        [self.popoverController.delegate popoverControllerDidDismissPopover:self.popoverController];
    }else if ([self.parentViewController isKindOfClass:[UINavigationController class]]){
        [self.navigationController popViewControllerAnimated:YES];
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
