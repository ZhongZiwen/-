//
//  OpportunityAddContactController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/12/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "OpportunityAddContactController.h"
#import "ContactTableViewCell.h"
#import "Contact.h"

#define kCellIdentifier @"ContactTableViewCell"

@interface OpportunityAddContactController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *params;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableArray *selectedArray;
@end

@implementation OpportunityAddContactController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(leftButtonPress)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"确定" target:self action:@selector(rightButtonPress)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _selectedArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    _params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [_params setObject:@1 forKey:@"pageNo"];
    [_params setObject:@10 forKey:@"pageSize"];
    
    [self.view beginLoading];
    [self sendRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)leftButtonPress {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonPress {
    NSString *linkManIds;
    for (int i = 0; i < _selectedArray.count; i ++) {
        Contact *item = _selectedArray[i];
        if (i) {
            linkManIds = [NSString stringWithFormat:@"%@,%@", linkManIds, item.id];
        }
        else {
            linkManIds = [NSString stringWithFormat:@"%@", item.id];
        }
    }
    
    NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [tempParams setObject:linkManIds forKey:@"linkManIds"];
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_SaleChance_AddContact_WithParams:tempParams block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            if (self.refreshBlock) {
                self.refreshBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark - private method
- (void)sendRequest {
    [[Net_APIManager sharedManager] request_SaleChance_ContactListFromOpportunity_WithParams:_params block:^(id data, NSError *error) {
        if (data) {
            [self.view endLoading];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"contacts"]) {
                Contact *contact = [NSObject objectOfClass:@"Contact" fromJSON:tempDict];
                [tempArray addObject:contact];
            }
            
            _sourceArray = tempArray;
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
            
            [_tableView configBlankPageWithTitle:@"暂无可选联系人" hasData:_sourceArray.count hasError:NO reloadButtonBlock:nil];
        }
        else {
            if (error.code == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^{
                    [self sendRequest];
                };
                [comRequest loginInBackground];
                return;
            }
            
            [self.view endLoading];
        }
    }];
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ContactTableViewCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    Contact *item = _sourceArray[indexPath.row];
    if (item.isSelected) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tenant_agree_selected"]];
    }
    else {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tenant_agree"]];
    }
    [cell configWithoutSWWithItem:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Contact *item = _sourceArray[indexPath.row];
    if (item.isSelected) {
        [_selectedArray removeObject:item];
        item.isSelected = NO;
    }
    else {
        item.isSelected = YES;
        [_selectedArray addObject:item];
    }
    
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (_selectedArray.count) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.title = [NSString stringWithFormat:@"已选择%d人", _selectedArray.count];
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.title = @"选择联系人";
    }
}


#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setY:64.0f];
        [_tableView setWidth:kScreen_Width];
        [_tableView setHeight:kScreen_Height - 64.0f];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
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
