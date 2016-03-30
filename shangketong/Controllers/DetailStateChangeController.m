//
//  DetailStateChangeController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "DetailStateChangeController.h"
#import "ValueIdModel.h"

#define kCellIdentifier @"UITableViewCell"

@interface DetailStateChangeController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (assign, nonatomic) NSInteger markIndex;
@end

@implementation DetailStateChangeController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    // 自定义返回按钮 开启手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonItemPress)];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleBordered target:self action:@selector(rightButtonItemPress)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)backButtonItemPress {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonItemPress {

    NSString *path;

    ValueIdModel *item = _sourceArray[_markIndex];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    if (_changeType == DetailStateChangeTypeActivity) {
        [params setObject:item.id forKey:@"activityId"];
        path = kNetPath_Activity_ChangeStatus;
    }else if (_changeType == DetailStateChangeTypeSaleLeads) {
        [params setObject:item.id forKey:@"followId"];
        path = kNetPath_Lead_ChangeStatus;
    }
    
    [[Net_APIManager sharedManager] request_Common_ChangeState_WithParams:params path:path block:^(id data, NSError *error) {
        if (data) {
            if (self.refreshBlock) {
                self.refreshBlock(item);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            
        }
    }];
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    ValueIdModel *item = _sourceArray[indexPath.row];
    cell.textLabel.text = item.value;
    
    if ([item.id isEqualToString:_currentState.id]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _markIndex = indexPath.row;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.markIndex = indexPath.row;
}

#pragma mark - setters and getters
- (void)setMarkIndex:(NSInteger)markIndex {
    if (_markIndex == markIndex)
        return;
    
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_markIndex inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    _markIndex = markIndex;
    cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_markIndex inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
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
