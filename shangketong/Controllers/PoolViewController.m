//
//  PoolViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/26.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PoolViewController.h"
#import "PoolGroup.h"
#import "PoolTableViewCell.h"
#import "PoolGroupViewController.h"

#define kCellIdentifier @"PoolTableViewCell"

@interface PoolViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSNumber *hadReceived;
@property (strong, nonatomic) NSNumber *totalCount;
@end

@implementation PoolViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view beginLoading];
    [self sendRequest];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendRequest {
    [[Net_APIManager sharedManager] request_Pool_GroupList_WithType:_poolType block:^(id data, NSError *error) {
        if (data) {
            [self.view endLoading];
            _hadReceived = data[@"hadReceived"];
            _totalCount = data[@"totalCount"];
            
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"groups"]) {
                PoolGroup *group = [NSObject objectOfClass:@"PoolGroup" fromJSON:tempDict];
                [tempArray addObject:group];
            }
            _sourceArray = tempArray;
            [_tableView reloadData];
            [_tableView configBlankPageWithTitle:(_poolType ? @"暂无客户" : @"暂无销售线索") hasData:_sourceArray.count hasError:NO reloadButtonBlock:nil];
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
    }];
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [PoolTableViewCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PoolTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    PoolGroup *group = _sourceArray[indexPath.row];
    [cell configWithModel:group];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 退回公海池返回
    if (self.poolGroupNameBlock) {
        self.poolGroupNameBlock(_sourceArray[indexPath.row]);
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    PoolGroup *group = _sourceArray[indexPath.row];
    PoolGroupViewController *groupController = [[PoolGroupViewController alloc] init];
    groupController.title = group.name;
    groupController.poolType = _poolType;
    groupController.groupId = group.id;
    groupController.bottomString = [NSString stringWithFormat:@"%@/%@", _hadReceived, _totalCount];
    groupController.refreshBlock = ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sendRequest];
        });
    };
    [self.navigationController pushViewController:groupController animated:YES];
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
        [_tableView registerClass:[PoolTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
        _tableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
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
