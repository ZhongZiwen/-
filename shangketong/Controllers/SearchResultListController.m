//
//  SearchResultListController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SearchResultListController.h"
#import "ActivityModel.h"
#import "ActivityCell.h"
#import "ActivityDetailViewController.h"
#import "Lead.h"
#import "LeadTableViewCell.h"
#import "LeadDetailViewController.h"
#import "Customer.h"
#import "CustomerTableViewCell.h"
#import "CustomerDetailViewController.h"
#import "Contact.h"
#import "ContactTableViewCell.h"
#import "ContactDetailViewController.h"
#import "SaleChance.h"
#import "OpportunityTableViewCell.h"
#import "OpportunityDetailController.h"
#import "MJRefresh.h"

#define kCellIdentifier_activity @"ActivityCell"
#define kCellIdentifier_lead @"LeadTableViewCell"
#define kCellIdentifier_customer @"CustomerTableViewCell"
#define kCellIdentifier_contact @"ContactTableViewCell"
#define kCellIdentifier_opportunity @"OpportunityTableViewCell"

@interface SearchResultListController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableDictionary *params;
@end

@implementation SearchResultListController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [_params setObject:@1 forKey:@"pageNo"];
    [_params setObject:@20 forKey:@"pageSize"];
    [_params setObject:_searchName forKey:@"name"];
    
    [self.view beginLoading];
    [self sendRequest];
    
    [_tableView addFooterWithTarget:self action:@selector(sendRequestReloadMore)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendRequest {
    [[Net_APIManager sharedManager] request_Common_SearchList_WithParams:_params path:_requestPath block:^(id data, NSError *error) {
        [self.view endLoading];
        [self.tableView footerEndRefreshing];
        if (data) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            switch (_searchType) {
                case SearchViewControllerTypeActivity: {
                    for (NSDictionary *tempDict in data[@"marketDirectorys"]) {
                        ActivityModel *item = [NSObject objectOfClass:@"ActivityModel" fromJSON:tempDict];
                        [tempArray addObject:item];
                    }
                }
                    break;
                case SearchViewControllerTypeLead: {
                    for (NSDictionary *tempDict in data[@"saleLeads"]) {
                        Lead *item = [NSObject objectOfClass:@"Lead" fromJSON:tempDict];
                        [tempArray addObject:item];
                    }
                }
                    break;
                case SearchViewControllerTypeCustomer: {
                    for (NSDictionary *tempDict in data[@"customers"]) {
                        Customer *item = [NSObject objectOfClass:@"Customer" fromJSON:tempDict];
                        [tempArray addObject:item];
                    }
                }
                    break;
                case SearchViewControllerTypeContact: {
                    for (NSDictionary *tempDict in data[@"contacts"]) {
                        Contact *item = [NSObject objectOfClass:@"Contact" fromJSON:tempDict];
                        [tempArray addObject:item];
                    }
                }
                    break;
                case SearchViewControllerTypeOpportunity: {
                    for (NSDictionary *tempDict in data[@"saleChances"]) {
                        SaleChance *item = [NSObject objectOfClass:@"SaleChance" fromJSON:tempDict];
                        [tempArray addObject:item];
                    }
                }
                    break;
                default:
                    break;
            }
            
            if ([self.params[@"pageNo"] isEqualToNumber:@1]) {
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
                [_tableView reloadData];
            });
            
            [_tableView configBlankPageWithTitle:@"无数据" hasData:_sourceArray.count hasError:error != nil reloadButtonBlock:nil];
        }
    }];
}

- (void)sendRequestReloadMore {
    [_params setObject:@([self.params[@"pageNo"] integerValue] + 1) forKey:@"pageNo"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequest];
    });
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (_searchType) {
        case SearchViewControllerTypeActivity:
            return [ActivityCell cellHeight];
            break;
        case SearchViewControllerTypeLead:
            return [LeadTableViewCell cellHeight];
            break;
        case SearchViewControllerTypeCustomer:
            return [CustomerTableViewCell cellHeight];
            break;
        case SearchViewControllerTypeContact:
            return [ContactTableViewCell cellHeight];
            break;
        case SearchViewControllerTypeOpportunity:
            return [OpportunityTableViewCell cellHeight];
            break;
        default:
            return 44.0f;
            break;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (_searchType) {
        case SearchViewControllerTypeActivity: {
            ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_activity forIndexPath:indexPath];
            ActivityModel *item = _sourceArray[indexPath.row];
            [cell configWithItem:item isSwipeable:NO];
            return cell;
        }
            break;
        case SearchViewControllerTypeLead: {
            LeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_lead forIndexPath:indexPath];
            Lead *item = _sourceArray[indexPath.row];
            [cell configWithModel:item];
            return cell;
        }
            break;
        case SearchViewControllerTypeCustomer: {
            CustomerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_customer forIndexPath:indexPath];
            Customer *item = _sourceArray[indexPath.row];
            [cell configWithModel:item];
            return cell;
        }
            break;
        case SearchViewControllerTypeContact: {
            ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_contact forIndexPath:indexPath];
            Contact *item = _sourceArray[indexPath.row];
            [cell configWithModel:item];
            return cell;
        }
            break;
        case SearchViewControllerTypeOpportunity: {
            OpportunityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_opportunity forIndexPath:indexPath];
            SaleChance *item = _sourceArray[indexPath.row];
            [cell configWithModel:item];
            return cell;
        }
            break;
        default:
            return nil;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (_searchType) {
        case SearchViewControllerTypeActivity: {
            ActivityModel *item = _sourceArray[indexPath.row];
            ActivityDetailViewController *detailController = [[ActivityDetailViewController alloc] init];
            detailController.title = @"市场活动";
            detailController.id = item.id;
            [self.navigationController pushViewController:detailController animated:YES];
        }
            break;
        case SearchViewControllerTypeLead: {
            Lead *item = _sourceArray[indexPath.row];
            LeadDetailViewController *leadDetailController = [[LeadDetailViewController alloc] init];
            leadDetailController.title = @"销售线索";
            leadDetailController.id = item.id;
            [self.navigationController pushViewController:leadDetailController animated:YES];
        }
            break;
        case SearchViewControllerTypeCustomer: {
            Customer *item = _sourceArray[indexPath.row];
            CustomerDetailViewController *customerDetailController = [[CustomerDetailViewController alloc] init];
            customerDetailController.title = @"客户";
            customerDetailController.id = item.id;
            [self.navigationController pushViewController:customerDetailController animated:YES];
        }
            break;
        case SearchViewControllerTypeContact: {
            Contact *item = _sourceArray[indexPath.row];
            ContactDetailViewController *contactDetailController = [[ContactDetailViewController alloc] init];
            contactDetailController.title = @"联系人";
            contactDetailController.id = item.id;
            [self.navigationController pushViewController:contactDetailController animated:YES];
        }
            break;
        case SearchViewControllerTypeOpportunity: {
            SaleChance *item = _sourceArray[indexPath.row];
            OpportunityDetailController *detailController = [[OpportunityDetailController alloc] init];
            detailController.title = @"销售机会";
            detailController.id = item.id;
            [self.navigationController pushViewController:detailController animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setY:64];
        [_tableView setWidth:kScreen_Width];
        [_tableView setHeight:kScreen_Height - 64];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[ActivityCell class] forCellReuseIdentifier:kCellIdentifier_activity];
        [_tableView registerClass:[LeadTableViewCell class] forCellReuseIdentifier:kCellIdentifier_lead];
        [_tableView registerClass:[CustomerTableViewCell class] forCellReuseIdentifier:kCellIdentifier_customer];
        [_tableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:kCellIdentifier_contact];
        [_tableView registerClass:[OpportunityTableViewCell class] forCellReuseIdentifier:kCellIdentifier_opportunity];
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
