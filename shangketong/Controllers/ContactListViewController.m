//
//  OpportunityListController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ContactListViewController.h"
#import "UIViewController+Expand.h"
#import "PopoverItem.h"
#import "PopoverView.h"
#import "ContactDetailViewController.h"
#import "ContactTableViewCell.h"
#import "OpportunityContactCell.h"
#import "Contact.h"
#import "AddressBookActionSheet.h"
#import "WebViewController.h"
#import "CRM_ContactNewViewController.h"
#import "OpportunityEditMainContactController.h"
#import "OpportunityAddContactController.h"
#import "MJRefresh.h"

#define kCellIdentifier @"ContactTableViewCell"
#define kCellIdentifier_opportunity @"OpportunityContactCell"

@interface ContactListViewController ()<UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableDictionary *params;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

- (void)sendRequest;
@end

@implementation ContactListViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (_fromType == ContactListFromTypeCustomer) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(customerButtonPress)];
    }
    else {
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithIcon:@"menu_showMore" showBadge:YES target:self action:@selector(opportunityButtonPress)];
    }
    [self.view addSubview:self.tableView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.refreshBlock) {
        self.refreshBlock();
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [_params setObject:_customerId forKey:@"customerId"];
    [_params setObject:@1 forKey:@"pageNo"];
    [_params setObject:@20 forKey:@"pageSize"];
    
    [self.view beginLoading];
    [self sendRequest];
    
    [_tableView addHeaderWithTarget:self action:@selector(sendRequestForRefresh)];
    [_tableView addFooterWithTarget:self action:@selector(sendRequestForReloadMore)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - public method
- (void)deleteAndRefreshDataSource {
    [_sourceArray removeObjectAtIndex:_selectedIndexPath.row];
    [_tableView deleteRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [_tableView configBlankPageWithTitle:@"暂无联系人" hasData:_sourceArray.count hasError:NO reloadButtonBlock:nil];
}

#pragma mark - private method
- (void)sendRequest {
    [[Net_APIManager sharedManager] request_Common_ContactList_WithParams:_params path:_requestListPath block:^(id data, NSError *error) {
        [_tableView headerEndRefreshing];
        [_tableView footerEndRefreshing];
        if (data) {
            [self.view endLoading];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"contacts"]) {
                Contact *contact = [NSObject objectOfClass:@"Contact" fromJSON:tempDict];
                [tempArray addObject:contact];
            }
            if ([_params[@"pageNo"] isEqualToNumber:@1]) {
                self.sourceArray = tempArray;
            }
            else {
                [self.sourceArray addObjectsFromArray:tempArray];
            }
            if (tempArray.count == 20) {
                self.tableView.footerHidden = NO;
            }
            else {
                self.tableView.footerHidden = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
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
        
        [_tableView configBlankPageWithTitle:@"暂无联系人" hasData:_sourceArray.count hasError:NO reloadButtonBlock:nil];
    }];
}

- (void)sendRequestForRefresh {
    [_params setObject:@1 forKey:@"pageNo"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequest];
    });
}

- (void)sendRequestForReloadMore {
    [_params setObject:@([_params[@"pageNo"] integerValue] + 1) forKey:@"pageNo"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequest];
    });
}

#pragma mark - event response
- (void)customerButtonPress {
    NSArray *items = @[[PopoverItem initItemWithTitle:@"名片扫描" image:nil target:self action:@selector(newScanning)],
                       [PopoverItem initItemWithTitle:@"手工输入" image:nil target:self action:@selector(newInput)]];
    
    PopoverView *pop = [[PopoverView alloc] initWithImageItems:nil titleItems:items];
    [pop show];
}

- (void)opportunityButtonPress {
    
    NSArray *array = @[[PopoverItem initItemWithTitle:@"创建联系人" image:nil target:self action:@selector(newContact)],
                       [PopoverItem initItemWithTitle:@"添加已有联系人" image:nil target:self action:@selector(addContact)],
                       [PopoverItem initItemWithTitle:@"设置主联系人" image:nil target:self action:@selector(setMainContact)]];
    PopoverView *pop = [[PopoverView alloc] initWithImageItems:nil titleItems:array];
    [pop show];
}

- (void)newScanning {
    @weakify(self);
    CRM_ContactNewViewController *newController = [[CRM_ContactNewViewController alloc] init];
    newController.title = @"新建联系人";
    newController.isScanning = YES;
    newController.requestInitPath = _requestInitPath;
    newController.requestScanfPath = _requestScanfPath;
    newController.requestSavePath = _requestSavePath;
    newController.customerId = _customerId;
    newController.refreshBlock = ^{
        @strongify(self);
        [self.view beginLoading];
        [self sendRequest];
    };
    [self.navigationController pushViewController:newController animated:YES];
}

- (void)newInput {
    @weakify(self);
    CRM_ContactNewViewController *newController = [[CRM_ContactNewViewController alloc] init];
    newController.title = @"新建联系人";
    newController.requestInitPath = _requestInitPath;
    newController.requestSavePath = _requestSavePath;
    newController.customerId = _customerId;
    newController.refreshBlock = ^{
        @strongify(self);
        [self.view beginLoading];
        [self sendRequest];
    };
    [self.navigationController pushViewController:newController animated:YES];
}

- (void)newContact {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *scanningAction = [UIAlertAction actionWithTitle:@"名片扫描" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self newScanning];
    }];
    UIAlertAction *inputAction = [UIAlertAction actionWithTitle:@"手工输入" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self newInput];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:scanningAction];
    [alertController addAction:inputAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)addContact {
    @weakify(self);
    OpportunityAddContactController *addContactController = [[OpportunityAddContactController alloc] init];
    addContactController.title = @"添加联系人";
    addContactController.refreshBlock = ^{
        @strongify(self);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sendRequest];
        });
    };
    [self.navigationController pushViewController:addContactController animated:YES];
}

- (void)setMainContact {
    @weakify(self);
    OpportunityEditMainContactController *editMainContact = [[OpportunityEditMainContactController alloc] init];
    editMainContact.title = @"设置主联系人";
    editMainContact.sourceArray = _sourceArray;
    editMainContact.refreshBlock = ^{
        @strongify(self);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sendRequest];
        });
    };
    [self.navigationController pushViewController:editMainContact animated:YES];
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_fromType == ContactListFromTypeCustomer) {
        return [ContactTableViewCell cellHeight];
    }
    else {
        return [OpportunityContactCell cellHeight];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_fromType == ContactListFromTypeCustomer) {
        ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
        cell.delegate = self;
        
        Contact *item = _sourceArray[indexPath.row];
        [cell configWithModel:item];
        return cell;
    }
    
    OpportunityContactCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_opportunity forIndexPath:indexPath];
    Contact *item = _sourceArray[indexPath.row];
    [cell configWithItem:item];
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
    
    _selectedIndexPath = indexPath;
    
    Contact *contact = self.sourceArray[indexPath.row];
    
    ContactDetailViewController *detailController = [[ContactDetailViewController alloc] init];
    detailController.title = @"联系人";
    detailController.id = contact.id;
    [self.navigationController pushViewController:detailController animated:YES];
}

#pragma mark - SWTableViewCellDelegate
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    [cell hideUtilityButtonsAnimated:YES];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Contact *item = self.sourceArray[indexPath.row];
    
    if (!index && item.position) {
        NSString *urlStr = [NSString stringWithFormat:@"http://map.baidu.com/mobile/webapp/search/search/wd=%@&qt=s&searchFlag=bigBox&version=5&exptype=dep&c=undefined&src_from=webapp_all_bigbox/", item.position];
        WebViewController *positionController = [WebViewController webViewControllerWithUrlStr:urlStr];
        [self.navigationController pushViewController:positionController animated:YES];
    }
    
    if (index && (item.phone || item.mobile)) {
        AddressBookActionSheet *actionSheet = [[AddressBookActionSheet alloc] initWithCancelTitle:@"取消" andMobile:item.mobile andPhone:item.phone];
        actionSheet.phoneBlock = ^(NSString *tel) {
            [self takePhoneWithNumber:tel];
        };
        actionSheet.msgBlock = ^(NSString *tel) {
            [self sendMessageWithRecipients:@[tel]];
        };
        [actionSheet show];
    }
}

#pragma mark - setters  and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setY:64];
        [_tableView setWidth:kScreen_Width];
        [_tableView setHeight:kScreen_Height - 64];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        [_tableView registerClass:[OpportunityContactCell class] forCellReuseIdentifier:kCellIdentifier_opportunity];
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
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
