//
//  ActivityRecordListController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ActivityRecordListController.h"
#import "Record.h"
#import "ActivityRecordCell.h"
#import "ActivityRecordDetailController.h"

#define kCellIdentifier @"ActivityRecordCell"

@interface ActivityRecordListController ()<UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *params;
@property (strong, nonatomic) NSMutableArray *sourceArray;

- (void)deleteDynamicWithObj:(Record*)record indexPath:(NSIndexPath*)indexPath;
@end

@implementation ActivityRecordListController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _sourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    _params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [_params setObject:_userId forKey:@"userId"];
    [_params setObject:_typeId forKey:@"typeId"];
    [_params setObject:_startTime forKey:@"startTime"];
    [_params setObject:_endTime forKey:@"endTime"];
    [_params setObject:@1 forKey:@"pageNo"];
    [_params setObject:@20 forKey:@"pageSize"];
    
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_ActivityRecord_List_WithParams:_params block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            for (NSDictionary *tempDict in data[@"followRecords"]) {
                Record *record = [NSObject objectOfClass:@"Record" fromJSON:tempDict];
                for (NSDictionary *alts in tempDict[@"alts"]) {
                    User *atUser = [NSObject objectOfClass:@"User" fromJSON:alts];
                    [record.altsArray addObject:atUser];
                }
                for (NSDictionary *imageDict in tempDict[@"imageFiles"]) {
                    FileModel *imageItem = [NSObject objectOfClass:@"FileModel" fromJSON:imageDict];
                    [record.imageFilesArray addObject:imageItem];
                }
                [_sourceArray addObject:record];
            }
            [_tableView reloadData];
        }
        [_tableView configBlankPageWithTitle:@"暂无活动记录" hasData:_sourceArray.count hasError:error != nil reloadButtonBlock:nil];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
- (void)deleteDynamicWithObj:(Record *)record indexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [tempParams setObject:record.id forKey:@"trendsId"];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[Net_APIManager sharedManager] request_Dynamic_Delete_WithParams:tempParams block:^(id data, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                if (data) {
                    [self.sourceArray removeObjectAtIndex:indexPath.row];
                    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                }else {
                    kShowHUD(@"删除活动记录失败");
                }
            });
        }];
    });
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Record *item = _sourceArray[indexPath.row];
    return [ActivityRecordCell cellHeightWithObj:item];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ActivityRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.contentLabel.delegate = self;
    Record *item = _sourceArray[indexPath.row];
    [cell configWithObj:item];
    cell.moreBtnClickedBlock = ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self deleteDynamicWithObj:item indexPath:indexPath];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:deleteAction];
        [self presentViewController:alertController animated:YES completion:nil];
    };
    cell.commentBlock = ^{
        ActivityRecordDetailController *recordDetailController = [[ActivityRecordDetailController alloc] init];
        recordDetailController.title = @"活动记录详情";
        recordDetailController.record = item;
        recordDetailController.isAnimateInput = YES;
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationItem setBackBarButtonItem:backItem];
        [self.navigationController pushViewController:recordDetailController animated:YES];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Record *item = _sourceArray[indexPath.row];
    
    ActivityRecordDetailController *recordDetailController = [[ActivityRecordDetailController alloc] init];
    recordDetailController.title = @"活动记录详情";
    recordDetailController.record = item;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
    [self.navigationController pushViewController:recordDetailController animated:YES];
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components {
    User *user = [components objectForKey:@"value"];
    NSLog(@"name = %@", user.name);
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        [_tableView registerClass:[ActivityRecordCell class] forCellReuseIdentifier:kCellIdentifier];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
