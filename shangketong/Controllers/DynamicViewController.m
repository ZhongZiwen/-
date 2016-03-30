//
//  DynamicViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/12/5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "DynamicViewController.h"
#import "DepartGroupModel.h"
#import "Record.h"
#import "ActivityRecordCell.h"
#import "ActivityRecordDetailController.h"

#define kCellIdentifier @"ActivityRecordCell"

@interface DynamicViewController ()<UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableDictionary *params;

- (void)sendRequestForList;
@end

@implementation DynamicViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _sourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    _params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [_params setObject:@1 forKey:@"pageNo"];
    if (_dynamicType == DynamicViewControllerTypeDepartment) {
        [_params setObject:@"dept" forKey:@"type"];
        [_params setObject:_item.id forKey:@"deptId"];
    }else {
        [_params setObject:@"group" forKey:@"type"];
        [_params setObject:_item.id forKey:@"groupId"];
    }
    
    [self sendRequestForList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event ersponse
- (void)addDynamic {
    NSLog(@"add dynamic");
}

#pragma mark - private method
- (void)sendRequestForList {
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_Address_DynamicList_WithParams:_params block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            for (NSDictionary *tempDict in data[@"feeds"]) {
                Record *item = [NSObject objectOfClass:@"Record" fromJSON:tempDict];
                for (NSDictionary *alts in tempDict[@"alts"]) {
                    User *atUser = [NSObject objectOfClass:@"User" fromJSON:alts];
                    [item.altsArray addObject:atUser];
                }
                for (NSDictionary *imageDict in tempDict[@"imageFiles"]) {
                    FileModel *imageItem = [NSObject objectOfClass:@"FileModel" fromJSON:imageDict];
                    [item.imageFilesArray addObject:imageItem];
                }
                [_sourceArray addObject:item];
            }
            
            [_tableView reloadData];
        }
        [_tableView configBlankPageWithTitle:@"暂无动态" hasData:_sourceArray.count hasError:error != nil reloadButtonBlock:nil];
    }];
}

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
        UIAlertAction *favAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@", [item.isfav integerValue] ? @"收藏" : @"取消收藏"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
            [tempParams setObject:item.id forKey:@"trendsId"];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[Net_APIManager sharedManager] request_Dynamic_AddOrDeleteFavorite_WithParams:tempParams isFavorite:[item.isfav boolValue] block:^(id data, NSError *error) {
                    if (data) {
                        item.isfav = @(![item.isfav integerValue]);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                        });
                    }
                }];
            });
        }];
        [alertController addAction:cancelAction];
        if ([[NSString stringWithFormat:@"%@", item.user.id] isEqualToString:KAppDelegateAccessor.moudle.userId]) {
            [alertController addAction:deleteAction];
        }
        [alertController addAction:favAction];
        [self presentViewController:alertController animated:YES completion:nil];
    };
    cell.commentBlock = ^{  // 评论
        ActivityRecordDetailController *recordDetailController = [[ActivityRecordDetailController alloc] init];
        recordDetailController.title = @"活动记录详情";
        recordDetailController.record = item;
        recordDetailController.isAnimateInput = YES;
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationItem setBackBarButtonItem:backItem];
        [self.navigationController pushViewController:recordDetailController animated:YES];
    };
    cell.forwardBlock = ^{  // 转发
        
    };
    cell.likeBlock = ^{ // 赞
        NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
        [tempParams setObject:item.id forKey:@"trendsId"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[Net_APIManager sharedManager] request_Dynamic_Like_WithParams:tempParams block:^(id data, NSError *error) {
                if (data) {
                    item.isFeedUp = @0;
                    item.feedUpCount = @([item.feedUpCount integerValue] + 1);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    });
                }
            }];
        });
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
        [_tableView setHeight:kScreen_Height - 64 - 49];
        _tableView.delegate = self;
        _tableView.dataSource = self;
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
