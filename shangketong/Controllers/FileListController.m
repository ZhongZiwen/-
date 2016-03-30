//
//  FileListController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "FileListController.h"
#import "FileList_DirectoryCell.h"
#import "FileList_fileCell.h"
#import "Directory.h"
#import "FileListDetailController.h"
#import "MJRefresh.h"

#define kCellIdentifier_directory @"FileList_DirectoryCell"
#define kCellIdentifier_file @"FileList_fileCell"

@interface FileListController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *params;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@end

@implementation FileListController

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
    if (_id) {
        [_params setObject:_id forKey:@"id"];
    }

    [self.view beginLoading];
    [self sendRequest];
    
    [_tableView addHeaderWithTarget:self action:@selector(sendRequestToRefresh)];
    [_tableView addFooterWithTarget:self action:@selector(sendRequestToReloadMore)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendRequest {
    [[Net_APIManager sharedManager] request_Common_File_List_WithPath:_requestPath params:_params block:^(id data, NSError *error) {
        [_tableView headerEndRefreshing];
        [_tableView footerEndRefreshing];
        if (data) {
            [self.view endLoading];
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"directorys"]) {
                Directory *item = [NSObject objectOfClass:@"Directory" fromJSON:tempDict];
                [item configFileTypeAndSize];
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
            
            [_tableView configBlankPageWithTitle:@"暂无文档" hasData:_sourceArray.count hasError:error != nil reloadButtonBlock:nil];
        }
        else if (error.code == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [self sendRequest];
            };
            [comRequest loginInBackground];
        }
        else {
            [self.view endLoading];
        }
    }];
}

- (void)sendRequestToRefresh {
    [_params setObject:@1 forKey:@"pageNo"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequest];
    });
}

- (void)sendRequestToReloadMore {
    [_params setObject:@([_params[@"pageNo"] integerValue] + 1) forKey:@"pageNo"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequest];
    });
}

#pragma mark - public method
- (void)refreshDataSource {
    if (_selectedIndexPath) {
        [_tableView reloadRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)deleteDataSource {
    if (_selectedIndexPath) {
        [_sourceArray removeObjectAtIndex:_selectedIndexPath.row];
        [_tableView deleteRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
    }
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [FileList_DirectoryCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Directory *item = _sourceArray[indexPath.row];
    if ([item.type integerValue] == 1) {    // 文件夹
        FileList_DirectoryCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_directory forIndexPath:indexPath];
        [cell configWithObj:item];
        return cell;
    }
    
    FileList_fileCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_file forIndexPath:indexPath];
    [cell configWithObj:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _selectedIndexPath = indexPath;
    
    Directory *item = _sourceArray[indexPath.row];
    
    if ([item.type integerValue] == 1) {
        
        if (![item.child integerValue]) return;
        
        FileListController *directoryController = [[FileListController alloc] init];
        directoryController.title = item.name;
        directoryController.id = item.id;
        directoryController.requestPath = _requestPath;
        [self.navigationController pushViewController:directoryController animated:YES];
        return;
    }

    FileListDetailController *detailController = [[FileListDetailController alloc] init];
    detailController.title = item.name;
    detailController.directory = item;
    detailController.isShowRightBarButton = YES;
    [self.navigationController pushViewController:detailController animated:YES];
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setY:64];
        [_tableView setWidth:kScreen_Width];
        [_tableView setHeight:kScreen_Height - CGRectGetMinY(_tableView.frame)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[FileList_DirectoryCell class] forCellReuseIdentifier:kCellIdentifier_directory];
        [_tableView registerClass:[FileList_fileCell class] forCellReuseIdentifier:kCellIdentifier_file];
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
