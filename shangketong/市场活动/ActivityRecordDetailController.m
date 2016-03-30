//
//  ActivityRecordDetailController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ActivityRecordDetailController.h"
#import "ExportAddressViewController.h"
#import "ActivityDetailViewController.h"
#import "MapViewViewController.h"
#import "FileListDetailController.h"
#import "InfoViewController.h"
#import "Directory.h"
#import "AddressBook.h"
#import "UIMessageInputView_zbs.h"
#import "RecordDetail_headCell.h"
#import "RecordDetail_commentCell.h"
#import "Record.h"
#import "Comment.h"
#import "User.h"
#import "MJRefresh.h"

#define kCellIdentifier_head @"RecordDetail_headCell"
#define kCellIdentifier_comment @"RecordDetail_commentCell"

@interface ActivityRecordDetailController ()<UITableViewDataSource, UITableViewDelegate, UIMessageInputViewDelegate, TTTAttributedLabelDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIMessageInputView_zbs *inputView;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableArray *altsArray;
@property (strong, nonatomic) NSMutableDictionary *params;
@end

@implementation ActivityRecordDetailController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.inputView prepareToShowWithView:self.view];
    [self addObserverOfKeyBoard];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_isAnimateInput) {
        [self.inputView notAndBecomeFirstResponder];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.inputView prepareToDismiss];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopVoice" object:nil];

    [self removeObserverOfKeyBoard];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if ([appDelegateAccessor.moudle.userId isEqualToString:[NSString stringWithFormat:@"%@", _record.user.id]]) {
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithIcon:@"menu_showMore" showBadge:YES target:self action:@selector(rightButtonPress)];
    }
    
    _params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [_params setObject:_record.id forKey:@"trendsId"];
    [_params setObject:@1 forKey:@"objectType"];
    [_params setObject:@1 forKey:@"pageNo"];
    [_params setObject:@10 forKey:@"pageSize"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self sendRequst];
    });
    
    [self.tableView addHeaderWithTarget:self action:@selector(sendRequestForRefresh)];
    [self.tableView addFooterWithTarget:self action:@selector(sendRequestForReloadMore)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendRequst {
    [[Net_APIManager  sharedManager] request_Common_CommentList_WithParams:_params block:^(id data, NSError *error) {
        [self.tableView headerEndRefreshing];
        [self.tableView footerEndRefreshing];
        if (data) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"comments"]) {
                Comment *comment = [NSObject objectOfClass:@"Comment" fromJSON:tempDict];
                for (NSDictionary *altsDict in tempDict[@"alts"]) {
                    User *user = [NSObject objectOfClass:@"User" fromJSON:altsDict];
                    [comment.altsArray addObject:user];
                }
                [tempArray addObject:comment];
            }
            
            if ([[NSString stringWithFormat:@"%@", _params[@"pageNo"]] isEqualToString:@"1"]) {
                self.sourceArray = tempArray;
            }
            else {
                [self.sourceArray addObjectsFromArray:tempArray];
            }
            
            if (tempArray.count == 10) {
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
                    [self sendRequst];
                };
                [comRequest loginInBackground];
            }
        }
    }];
}

- (void)sendRequestForRefresh {
    [_params setObject:@1 forKey:@"pageNo"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequst];
    });
}

- (void)sendRequestForReloadMore {
    [_params setObject:@([self.params[@"pageNo"] integerValue] + 1) forKey:@"pageNo"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequst];
    });
}

#pragma mark - event response
- (void)rightButtonPress {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
        [tempParams setObject:_record.id forKey:@"id"];
        
        [self.view beginLoading];
        [[Net_APIManager sharedManager] request_Common_DeleteActivity_WithParams:tempParams block:^(id data, NSError *error) {
            [self.view endLoading];
            if (data) {
                if (self.deleteRecordSuccessBlock) {
                    self.deleteRecordSuccessBlock();
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UIMessageInputViewDelegate
- (void)messageInputViewAt {
    ExportAddressViewController *exportController = [[ExportAddressViewController alloc] init];
    exportController.title = @"选择同事";
    exportController.valueBlock = ^(NSArray *array) {
        
        
        for (AddressBook *tempItem in array) {
            
            _inputView.inputTextView.text = [NSString stringWithFormat:@"%@@%@ ", _inputView.inputTextView.text, tempItem.name];
        }
        
        [self.altsArray addObjectsFromArray:array];
        [_inputView notAndBecomeFirstResponder];
    };
    [self.navigationController pushViewController:exportController animated:YES];
}

- (void)messageInputView:(UIMessageInputView_zbs *)inputView sendText:(NSString *)text {
    
    [_inputView isAndResignFirstResponder];
    
    NSMutableString *contentString = [NSMutableString stringWithString:text];
    // @人的id
    NSString *tempStaffIds;

    int i = 0;
    for (AddressBook *tempItem in self.altsArray) {
        
        NSRange altRange = [contentString rangeOfString:[NSString stringWithFormat:@"@%@", tempItem.name] options:0 range:NSMakeRange(0, [contentString length])];
        if (altRange.location != NSNotFound) {
            if (!i) {
                tempStaffIds = [NSString stringWithFormat:@"%@", tempItem.id];
            }
            else {
                tempStaffIds = [NSString stringWithFormat:@"%@,%@", tempStaffIds, tempItem.id];
            }
            
            // 删除该@人
            [contentString deleteCharactersInRange:altRange];
        }
        i ++;
    }
    [self.altsArray removeAllObjects];
    
//    int i = 0;
//    for (NSString *tempKey in _atsKeyValue.allKeys) {
//        if ([text rangeOfString:[NSString stringWithFormat:@"@%@", tempKey]].location != NSNotFound) {
//            if (!i) {
//                tempStaffIds = [NSString stringWithFormat:@"%@", _atsKeyValue[tempKey]];
//            }
//            else {
//                tempStaffIds = [NSString stringWithFormat:@"%@,%@", tempStaffIds, _atsKeyValue[tempKey]];
//            }
//        }
//        i ++;
//    }
    
    if (tempStaffIds && [tempStaffIds componentsSeparatedByString:@","].count > 9) {
        kShowHUD(@"你最多能@9人");
        return;
    }
    
    NSString *transString = [NSString stringWithString:[text stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [tempParams setObject:_record.id forKey:@"trendsId"];
    [tempParams setObject:@1 forKey:@"objectType"];
    [tempParams setObject:tempStaffIds ? : @"" forKey:@"staffIds"];
    [tempParams setObject:transString forKey:@"content"];
    
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_Common_AddComment_WithParams:tempParams block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {

            Comment *comment = [NSObject objectOfClass:@"Comment" fromJSON:data[@"comment"]];
            for (NSDictionary *altsDict in data[@"comment"][@"alts"]) {
                User *user = [NSObject objectOfClass:@"User" fromJSON:altsDict];
                [comment.altsArray addObject:user];
            }
            
            [self.sourceArray insertObject:comment atIndex:0];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }];
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1 + _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row) {
        Comment *comment = _sourceArray[indexPath.row - 1];
        return [RecordDetail_commentCell cellHeightWithObj:comment];
    }
    return [RecordDetail_headCell cellHeightWithObj:_record];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath.row) {
        RecordDetail_headCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_head forIndexPath:indexPath];
        cell.contentLabel.delegate = self;
        cell.timeAndfromLabel.delegate = self;
        cell.handleVC = self;
        [cell configWithModel:_record];
        cell.headerViewTapBlock = ^{
            InfoViewController *infoController = [[InfoViewController alloc] init];
            infoController.title = @"个人信息";
            if ([appDelegateAccessor.moudle.userId integerValue] == [_record.user.id integerValue]) {
                infoController.infoTypeOfUser = InfoTypeMyself;
            }else{
                infoController.infoTypeOfUser = InfoTypeOthers;
                infoController.userId = [_record.user.id integerValue];
            }
            [self.navigationController pushViewController:infoController animated:YES];
        };
        cell.fileBlock = ^{
            Directory *directory = [[Directory alloc] init];
            directory.id = _record.file.id;
            directory.size = _record.file.size;
            directory.name = _record.file.name;
            directory.url = _record.file.url;
            [directory configFileTypeAndSize];
            FileListDetailController *detailController = [[FileListDetailController alloc] init];
            detailController.title = _record.file.name;
            detailController.directory = directory;
            [self.navigationController pushViewController:detailController animated:YES];
        };
        cell.positionBlock = ^{
            MapViewViewController *mapController = [[MapViewViewController alloc] init];
            mapController.title = @"查看地理位置";
            mapController.typeOfMap = @"show";
            mapController.location = _record.position;
            mapController.latitude = [_record.latitude doubleValue];
            mapController.longitude = [_record.longitude doubleValue];
            [self.navigationController pushViewController:mapController animated:YES];
        };
        return cell;
    }
    
    Comment *comment = _sourceArray[indexPath.row - 1];
    RecordDetail_commentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_comment forIndexPath:indexPath];
    cell.contentLabel.delegate = self;
    cell.iconImageView.imageViewTapBlock = ^(NSInteger index) {
        InfoViewController *infoController = [[InfoViewController alloc] init];
        infoController.title = @"个人信息";
        if ([appDelegateAccessor.moudle.userId integerValue] == [comment.creator.id integerValue]) {
            infoController.infoTypeOfUser = InfoTypeMyself;
        }else{
            infoController.infoTypeOfUser = InfoTypeOthers;
            infoController.userId = [comment.creator.id integerValue];
        }
        [self.navigationController pushViewController:infoController animated:YES];
    };
    [cell configWithObj:comment];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!indexPath.row) {
        return;
    }
    
    Comment *comment = _sourceArray[indexPath.row -1];

    // @该评论人
    if (![[NSString stringWithFormat:@"%@", comment.creator.id] isEqualToString:appDelegateAccessor.moudle.userId]) {
        
        [self.altsArray removeAllObjects];
        AddressBook *tempItem = [[AddressBook alloc] init];
        tempItem.id = comment.creator.id;
        tempItem.name = comment.creator.name;
        [self.altsArray addObject:tempItem];
        
        _inputView.inputTextView.text = [NSString stringWithFormat:@"@%@ ", comment.creator.name];
        [_inputView notAndBecomeFirstResponder];
        return;
    }
    
    // 删除自己的评论
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
        [tempParams setObject:@1 forKey:@"objectType"];
        [tempParams setObject:_record.id forKey:@"trendsId"];
        [tempParams setObject:comment.id forKey:@"commentId"];
        
        [self.view beginLoading];
        [[Net_APIManager sharedManager] request_Common_DeleteComment_WithParams:tempParams block:^(id data, NSError *error) {
            [self.view endLoading];
            if (data) {
                [_sourceArray removeObjectAtIndex:indexPath.row - 1];
                [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            }
        }];
        
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_inputView isAndResignFirstResponder];
}


#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components {
    User *user = [components objectForKey:@"user"];
    NSNumber *fromId = [components objectForKey:@"from"];
    
    if (user) {
        InfoViewController *infoController = [[InfoViewController alloc] init];
        infoController.title = @"个人信息";
        if ([appDelegateAccessor.moudle.userId integerValue] == [user.id integerValue]) {
            infoController.infoTypeOfUser = InfoTypeMyself;
        }else{
            infoController.infoTypeOfUser = InfoTypeOthers;
            infoController.userId = [user.id integerValue];
        }
        [self.navigationController pushViewController:infoController animated:YES];
        return;
    }
    
    if (fromId) {
        ActivityDetailViewController *detailController = [[ActivityDetailViewController alloc] init];
        detailController.title = @"市场活动";
        detailController.id = fromId;
        [self.navigationController pushViewController:detailController animated:YES];
        return;
    }
}

#pragma mark - setters and getters
- (NSMutableArray *)altsArray {
    if (!_altsArray) {
        _altsArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _altsArray;
}

- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - 50.0) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[RecordDetail_headCell class] forCellReuseIdentifier:kCellIdentifier_head];
        [_tableView registerClass:[RecordDetail_commentCell class] forCellReuseIdentifier:kCellIdentifier_comment];
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (UIMessageInputView_zbs*)inputView {
    if (!_inputView) {
        _inputView = [UIMessageInputView_zbs initMessageInputViewWithType:UIMessageInputViewTypeComment placeHolder:@"输入评论内容"];
        _inputView.isAlwaysShow = YES;
        _inputView.delegate = self;
    }
    return _inputView;
}

#pragma mark 添加键盘事件监听
-(void)addObserverOfKeyBoard{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)removeObserverOfKeyBoard{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
}

#pragma mark 键盘弹起 tableview上移
//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    /*
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    // set views with new info
    if ((self.view.bounds.size.height-keyboardBounds.size.height-_inputView.frame.size.height) < self.tableView.contentSize.height) {
        [self.tableView setContentOffset:CGPointMake(0.0, self.tableView.contentSize.height-(self.view.bounds.size.height-keyboardBounds.size.height-_inputView.frame.size.height)) animated:YES];
    }
     */
}

-(void) keyboardWillHide:(NSNotification *)note{
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
