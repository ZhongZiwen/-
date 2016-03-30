//
//  CustomerListController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CustomerListController.h"
#import "UIViewController+Expand.h"
#import "AddressBookActionSheet.h"
#import "Customer.h"
#import "CustomerListCell.h"
#import "CustomerDetailViewController.h"
#import "CustomerNewViewController.h"
#import "CustomerListAddController.h"
#import "CustomerListStatusController.h"
#import "PopoverView.h"
#import "PopoverItem.h"
#import "MJRefresh.h"

#define kCellIdentifier @"CustomerListCell"

@interface CustomerListController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableDictionary *params;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@end

@implementation CustomerListController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_showMore"] style:UIBarButtonItemStyleBordered target:self action:@selector(rightButtonPress)];
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
    [_params setObject:_activityId forKey:@"activityId"];
    [_params setObject:@1 forKey:@"pageNo"];
    [_params setObject:@20 forKey:@"pageSize"];
    
    [self.view beginLoading];
    [self sendRequst];
    
    [_tableView addHeaderWithTarget:self action:@selector(sendRequstForRefresh)];
    [_tableView addFooterWithTarget:self action:@selector(sendRequstForReloadMore)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendRequst {
    [[Net_APIManager sharedManager] request_Common_Customer_List_WithParams:_params path:kNetPath_Activity_CustomerList block:^(id data, NSError *error) {
        [_tableView headerEndRefreshing];
        [_tableView footerEndRefreshing];
        if (data) {
            [self.view endLoading];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"customers"]) {
                Customer *item = [NSObject objectOfClass:@"Customer" fromJSON:tempDict];
                [tempArray addObject:item];
            }
            if ([_params[@"pageNo"] isEqualToNumber:@1]) {
                _sourceArray = tempArray;
            }
            else {
                [_sourceArray addObjectsFromArray:tempArray];
            }
            
            if (tempArray.count == 20) {
                _tableView.footerHidden = NO;
            }
            else {
                _tableView.footerHidden = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        }
        else if (error.code == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [self sendRequst];
            };
            [comRequest loginInBackground];
            return;
        }
        
        [self.view endLoading];
        [_tableView configBlankPageWithTitle:@"暂无客户" hasData:_sourceArray.count hasError:NO reloadButtonBlock:nil];
    }];
}

- (void)sendRequstForRefresh {
    [_params setObject:@1 forKey:@"pageNo"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequst];
    });
}

- (void)sendRequstForReloadMore {
    [_params setObject:@([_params[@"pageNo"] integerValue] + 1) forKey:@"pageNo"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequst];
    });
}

#pragma mark - event response
- (void)rightButtonPress {
    NSArray *titlesArray = @[[PopoverItem initItemWithTitle:@"添加客户" image:nil target:self action:@selector(addCustomer)],
                             [PopoverItem initItemWithTitle:@"修改参与状态" image:nil target:self action:@selector(editCustomerStatus)]];
    PopoverView *pop = [[PopoverView alloc] initWithImageItems:nil titleItems:titlesArray];
    [pop show];
}

- (void)addCustomer {
    CustomerListAddController *addController = [[CustomerListAddController alloc] init];
    addController.title = @"添加客户";
    addController.activityId = _activityId;
    addController.refreshBlock = ^{
        [self sendRequst];
    };
    [self.navigationController pushViewController:addController animated:YES];
}

- (void)editCustomerStatus {
    for (Customer *tempItem in _sourceArray) {
        tempItem.isSelected = NO;
    }
    
    CustomerListStatusController *statusController = [[CustomerListStatusController alloc] init];
    statusController.title = @"修改客户状态";
    statusController.sourceArray = _sourceArray;
    statusController.params = [_params mutableCopy];
    statusController.refreshBlock = ^{
        [_tableView reloadData];
    };
    [self.navigationController pushViewController:statusController animated:YES];
}

#pragma mark - public method
- (void)deleteAndRefreshDataSource {
    [_sourceArray removeObjectAtIndex:_selectedIndexPath.row];
    [_tableView deleteRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [_tableView configBlankPageWithTitle:@"暂无客户" hasData:_sourceArray.count hasError:NO reloadButtonBlock:nil];
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [CustomerListCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomerListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    Customer *item = _sourceArray[indexPath.row];
    [cell configWithObj:item];
    cell.photoBlock = ^{
        AddressBookActionSheet *actionSheet = [[AddressBookActionSheet alloc] initWithCancelTitle:@"取消" andMobile:nil andPhone:item.phone];
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
    
    Customer *item = _sourceArray[indexPath.row];
    CustomerDetailViewController *detailController = [[CustomerDetailViewController alloc] init];
    detailController.title = @"客户";
    detailController.id = item.id;
    [self.navigationController pushViewController:detailController animated:YES];
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setY:64];
        [_tableView setWidth:kScreen_Width];
        [_tableView setHeight:kScreen_Height - 64.0f];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[CustomerListCell class] forCellReuseIdentifier:kCellIdentifier];
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
