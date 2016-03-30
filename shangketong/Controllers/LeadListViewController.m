//
//  LeadListViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "LeadListViewController.h"
#import "LeadTableViewCell.h"
#import "Lead.h"
#import "LeadDetailViewController.h"
#import "LeadNewViewController.h"
#import "PopoverView.h"
#import "PopoverItem.h"
#import "MJRefresh.h"

#define kCellIdentifier @"LeadTableViewCell"

@interface LeadListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableDictionary *params;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@end

@implementation LeadListViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightButtonPress)];
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
    [[Net_APIManager sharedManager] request_Common_SaleLeadsList_WithParams:_params path:kNetPath_Activity_SaleLeadsList block:^(id data, NSError *error) {
        [self.view endLoading];
        [_tableView headerEndRefreshing];
        [_tableView footerEndRefreshing];
        if (data) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"saleLeads"]) {
                Lead *item = [NSObject objectOfClass:@"Lead" fromJSON:tempDict];
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
            
            [_tableView configBlankPageWithTitle:@"暂无销售线索" hasData:_sourceArray.count hasError:NO reloadButtonBlock:nil];
        }
        else if (error.code == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [self sendRequst];
            };
            [comRequest loginInBackground];
        }
        else {
            [self.view endLoading];
        }
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
    NSArray *titlesArray = @[[PopoverItem initItemWithTitle:@"名片扫描" image:nil target:self action:@selector(scanfCreate)],
                             [PopoverItem initItemWithTitle:@"手工输入" image:nil target:self action:@selector(inputCreate)]];
    PopoverView *pop = [[PopoverView alloc] initWithImageItems:nil titleItems:titlesArray];
    [pop show];
}

- (void)scanfCreate {
    LeadNewViewController *newController = [[LeadNewViewController alloc] init];
    newController.title = @"创建销售线索";
    newController.params = _params;
    newController.isScanning = YES;
    newController.refreshBlock = ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sendRequst];
        });
    };
    [self.navigationController pushViewController:newController animated:YES];
}

- (void)inputCreate {
    LeadNewViewController *newController = [[LeadNewViewController alloc] init];
    newController.title = @"创建销售线索";
    newController.params = _params;
    newController.refreshBlock = ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sendRequst];
        });
    };
    [self.navigationController pushViewController:newController animated:YES];
}

#pragma mark - public method
- (void)deleteAndRefreshDataSource {
    // 删除数据，刷新tableview
    [self.sourceArray removeObjectAtIndex:_selectedIndexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView configBlankPageWithTitle:@"暂无销售线索" hasData:_sourceArray.count hasError:NO reloadButtonBlock:nil];
}

#pragma mark - UITablView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LeadTableViewCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    Lead *item = _sourceArray[indexPath.row];
    [cell configWithModel:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _selectedIndexPath = indexPath;

    Lead *leadItem = _sourceArray[indexPath.row];
    LeadDetailViewController *leadDetailController = [[LeadDetailViewController alloc] init];
    leadDetailController.title = @"销售线索";
    leadDetailController.id = leadItem.id;
    [self.navigationController pushViewController:leadDetailController animated:YES];
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
        [_tableView registerClass:[LeadTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
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
