//
//  ChatViewController.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/26.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ChatViewController.h"
#import "UIMessageInputView.h"
#import "ChatTableViewCell.h"
#import "ChatMessage.h"
#import "MJRefresh.h"
#import "AddOrDelContactController.h"
#import "SRWebSocket.h"
#import "SBJson.h"
#import "MySBJsonWriter.h"
#import "AFNHttp.h"
#import "ContactModel.h"
#import "AFHTTPRequestOperationManager.h"
#import "InfoViewController.h"
#import "AFSoundPlayback.h"
#import "CommonFuntion.h"
#import "IM_FMDB_FILE.h"
#import "AppDelegate.h"
#import "ShowAndSaveController.h"
#import "KnowledgeFileDetailsViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CommonFunc.h"
#import "PhotoAssetLibraryViewController.h"
#import "PhotoBroswerVC.h"
#import "PhotoAssetModel.h"

#define kCellIdentifier     @"ChatTableViewCell"

#define kInputViewWillShowNotification  @"UIMessageInputViewWillShowNotification"
#define kInputViewWillHideNotification  @"UIMessageInputViewWillHideNotification"

@interface ChatViewController ()<UIMessageInputViewDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, SRWebSocketDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIMessageInputView *msgInputView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *contactsArray;

@property (nonatomic, strong) NSIndexPath * indexPath;
@property (nonatomic, strong) ChatTableViewCell *cell;
@property (nonatomic, strong) ChatMessage *chatMsgModel;

@property (nonatomic, strong) UIButton *deleteBtn; //删除按钮
@property (nonatomic, strong) NSString *flag_CreateStr; //0创建成功  1失败、未创建
@property (nonatomic, strong) AFSoundPlayback *playback;
@property (nonatomic, strong) NSMutableArray *selectArray;
@property (nonatomic, strong) NSString *resourceSting;
@property (nonatomic, strong) AppDelegate *appdelegate;
@property (nonatomic, strong) NSMutableArray *uuidArray;

@property (nonatomic, strong) NSMutableDictionary *lastMsgDict;
@property (nonatomic, strong) NSMutableArray *oldMessageArray; //消息的数据源
@property (nonatomic, strong) NSString *timeFlag; //记录上个时间点

@property (nonatomic, strong) NSMutableArray *showListDataArray; //用来展示数据

@property (nonatomic, strong) NSMutableArray *allImagesArray; //保存现有数据源中的图片

@property (nonatomic, strong) UIButton *messageBtn; //新消息提示悬浮
@property (nonatomic, assign) NSInteger newMessageCount;
@property (nonatomic, assign) BOOL isHave; //在获取到新消息之后，搜索的消息是否还存在
@end

@implementation ChatViewController
{
    NSInteger flag_Nav; //0 正常 1取消+全选
    NSInteger flag_isAll; //0全选 1单选
    BOOL isAllSelect;
    NSString *showName;
    NSInteger selectIndex; //选中的下标
    
    NSInteger selectRow;//下拉加载完成之后选择行
    NSInteger refreshList_flag; //在返回的时候是否需要返回最后一条消息 0无草稿，无新推过来的消息(socket)，无新消息（http） 1草稿 2新消息（socket）3新消息（http）
    BOOL isRemove; //是否清除老数据
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    appDelegateAccessor.moudle.isIMView = TRUE;
    [super viewWillAppear:animated];
    [self addNotification];
    [self.msgInputView prepareToShow];

    NSString *sting = @"[草稿]";
    if (_unSendStr && _unSendStr.length > 0 && [_unSendStr rangeOfString:sting].location != NSNotFound) {
        
        [self.msgInputView notifyInputView:[_unSendStr stringByReplacingOccurrencesOfString:sting withString:@""]];
        refreshList_flag = 1;
    } else {
        refreshList_flag = 0;
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeNotification];
    appDelegateAccessor.moudle.isIMView = FALSE;
//    if (_playback) {
//        [_playback pause];
//        _playback = nil;
//    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopVoice" object:nil];
//    NSLog(@"%@", _dataSource);
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _tableView.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height - _msgInputView.frame.size.height);
    [self.msgInputView prepareToDismiss];
}

-(void)notifyData{
    
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(getNewMessageList)
                                   userInfo:nil repeats:NO];
}

//通知UI刷新
-(void)getNewMessageList{
    
    [self getGroupConversationListWithNumber:_messageNumber WithFlag:@"0"];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:LLC_NOTIFICATON_NAVIGATION_LIST object:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _lastMsgDict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    selectRow = 0;
    isRemove = YES; //默认清除
    _isHave = NO; //默认不存在
    NSString *show = [IM_FMDB_FILE result_IM_ShowOrHiddenContactName:_groupID];
    if ([show isEqualToString:@"1"]) {
        showName = @"show";
    } else {
        showName = @"hidden";
    }
    self.view.backgroundColor = [UIColor whiteColor];
    self.allImagesArray = [NSMutableArray arrayWithCapacity:0];
    self.dataSource = [NSMutableArray arrayWithCapacity:0];
    self.selectArray = [NSMutableArray arrayWithCapacity:0];
    self.uuidArray = [NSMutableArray arrayWithCapacity:0];
    self.oldMessageArray = [NSMutableArray arrayWithCapacity:0];
    self.showListDataArray = [NSMutableArray arrayWithCapacity:0];
    self.contactsArray = [NSMutableArray arrayWithCapacity:0];
    if (_pushType == ControllerPushTypeMessageVC) {
        NSArray *array = [IM_FMDB_FILE result_IM_MessageList:_groupID];
        NSArray *userArray = [NSArray arrayWithArray:[IM_FMDB_FILE result_IM_UserList:_groupID]];
        self.contactsArray = [NSMutableArray arrayWithArray:userArray];
        [self dataSourceInfo:array usersArray:userArray];
       
        if ([_flag_FromWhereInto isEqualToString:@"searchVC"]) {
            _isHave = YES;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_messageIndex inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        } else {
            [self tableViewScrollToBottom];
        }
        
        [_tableView reloadData];
        [self notifyData];
        
        _flag_CreateStr = @"0";
    } else {
        NSMutableArray *nameArray = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *userIdArray = [NSMutableArray arrayWithCapacity:0];
        self.contactsArray = [NSMutableArray arrayWithArray:_usersArray];
        for (ContactModel *model in _contactsArray) {
            [nameArray addObject:model.contactName];
            if (model.userID != [appDelegateAccessor.moudle.userId integerValue]) {
                [userIdArray addObject:@(model.userID)];
            }
        }
        NSString *nameStr = [nameArray componentsJoinedByString:@","];
        if ([_companyType isEqualToString:@"company"]) {
            self.title = _titleName;
        } else {
             _titleName = nameStr;
        }
        _flag_CreateStr = @"1";
        if (userIdArray && userIdArray.count == 1) {
            NSArray *groupIds = [IM_FMDB_FILE result_IM_UsersListOfGroupType:@"0"];
            if (groupIds.count > 0) {
                for (NSString *string in groupIds) {
                    NSArray *userArray = [IM_FMDB_FILE result_IM_UserList:string];
                    for (ContactModel *userModel in userArray) {
                        if (userModel.userID == [userIdArray[0] integerValue]) {
                            _groupID = string;
                            NSArray *msgArray = [IM_FMDB_FILE result_IM_MessageList:_groupID];
                            [self dataSourceInfo:msgArray usersArray:userArray];
                            [_tableView reloadData];
                            [self tableViewScrollToBottom];
                            [self notifyData];
                            // 会话列表界面
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"messageListUnread" object:@{@"groupId" : _groupID}];
                            _flag_CreateStr = @"0";
                            _pushType = ControllerPushTypeMessageVC;
                            break;
                        }
                    }
                }
            } else {
                
            }
        } else if (userIdArray && userIdArray.count > 1){
            NSArray *groupIds = [IM_FMDB_FILE result_IM_UsersListOfGroupType:@"1"];
            for (NSString *string in groupIds) {
                NSArray *userArray = [IM_FMDB_FILE result_IM_UserList:string];
                NSMutableArray *idsArray = [NSMutableArray arrayWithCapacity:0];
                for (ContactModel *userModel in userArray) {
                    if (userModel.userID != [appDelegateAccessor.moudle.userId longLongValue]) {
                        [idsArray addObject:@(userModel.userID)];
                    }
                }
                if ([self isHasGroupWithNewIdsAarray:userIdArray withOldIdsAarray:idsArray]) {
                    NSLog(@"已存在");
                    _groupID = string;
                    NSArray *msgArray = [IM_FMDB_FILE result_IM_MessageList:_groupID];
                    [self dataSourceInfo:msgArray usersArray:userArray];
                    [_tableView reloadData];
                    [self tableViewScrollToBottom];
                    [self notifyData];
                    // 会话列表界面
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"messageListUnread" object:@{@"groupId" : _groupID}];
                    _flag_CreateStr = @"0";
                    _pushType = ControllerPushTypeMessageVC;
                    break;
                }
            }
        }
    }
    
    //获取消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMessageOfWebSocket:) name:@"ReceveMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showContactName:) name:@"ShowName" object:nil];
    
    [self customNavRight];
    [self.view addSubview:self.tableView];

}
- (BOOL)isHasGroupWithNewIdsAarray:(NSArray *)newIdsAarray withOldIdsAarray:(NSArray *)oldIdsAarray {
    if (oldIdsAarray.count != 0 && newIdsAarray.count != oldIdsAarray.count) {
        return NO;
    }
    for (NSString *newId in newIdsAarray) {
        if ([oldIdsAarray containsObject:newId]) {
            
        } else {
            return NO;
        }
    }
    return YES;
}

- (void)reGetNewMessages:(NSNotification *)notfication {
//    [self getNewMessageList];
}
#pragma mark - add and delete Notification
///注册通知
-(void)addNotification{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(inputViewShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(inputViewHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tableViewScrollToBottom) name:UIKeyboardDidShowNotification object:nil];
    
    
    //UI刷新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyBorad:) name:@"showKeyBorad" object:nil];
    //点击图片
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToShowAndSaveController:) name:@"showAndSaveImg" object:nil];
    
    //webSocket 异常后再次连接成功 将页面的失败消息发送出去
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendFailMessages:) name:@"sendFailMessages" object:nil];
    
    //网络异常  网络断开，重新连接成功之后，进行请求，获取离线消息。
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reGetNewMessages:) name:@"ReGetNewMessages" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refeshSelectCell:) name:@"refeshSelectCell" object:nil];
}
///移除通知
-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showKeyBorad" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showAndSaveImg" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sendFailMessages" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ReGetNewMessages" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refeshSelectCell" object:nil];
}
#pragma mark - delete 删除消息
- (void)deleteMessage{
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteBtn.frame = CGRectMake(0, kScreen_Height - 44, kScreen_Width, 44);
//    [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [_deleteBtn setImage:[UIImage imageNamed:@"remove_allReply"] forState:UIControlStateNormal];
     [_deleteBtn setImage:[UIImage imageNamed:@"remove_allReply_clicked"] forState:UIControlStateHighlighted];
    _deleteBtn.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
//    [_deleteBtn setTitleColor:[UIColor colorWithHexString:@"ec5050"] forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(deleteTalkTextAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_deleteBtn];
}
- (void)removeDeleteBtnAction {
    [_deleteBtn removeFromSuperview];
    _deleteBtn = nil;
}
#pragma mark - notification
- (void)showKeyBorad:(NSNotification *)notification {
    NSInteger Vh = (NSInteger)[[notification object] integerValue];
    _tableView.frame = CGRectMake(0, 0, kScreen_Width, Vh - 50);
    [self tableViewScrollToBottom];
}
//接受本会话消息
- (void)addMessageOfWebSocket:(NSNotification *)notfication {
    NSDictionary *notDict = (NSDictionary *)[notfication object];
    NSDictionary *messageDict = [NSDictionary dictionaryWithDictionary:notDict];
    NSDictionary *newDict = [self changeKeysForDictionary:messageDict withType:@"recevied"];
    MySBJsonWriter *jsonParser = [[MySBJsonWriter alloc]init];
    NSDictionary *ackDcit = @{@"id" : [notDict safeObjectForKey:@"id"],
                              @"head" : @"ack",
                              @"to" : [notDict safeObjectForKey:@"to"],
                              @"number" : [notDict safeObjectForKey:@"number"],
                              @"time" : [notDict safeObjectForKey:@"time"]};
    
    NSString *ackmessage =[jsonParser stringWithObject:ackDcit];
    if (appDelegateAccessor.webSocket.readyState == SR_OPEN) {
        [appDelegateAccessor.webSocket send:ackmessage];
    } else {
        [appDelegateAccessor removeTimer];
        [appDelegateAccessor removeHeartTimer];
        [appDelegateAccessor deleteWebSocket];
        [appDelegateAccessor _reconnect];
    }
    
    //返回最后一条消息
    refreshList_flag = 2;
    [_lastMsgDict addEntriesFromDictionary:messageDict];
    NSString *groupId = [NSString stringWithFormat:@"%@", [messageDict objectForKey:@"to"]];
    NSString *messageID = [NSString stringWithFormat:@"%@",[newDict objectForKey:@"id"]];
    NSString *userId = [NSString stringWithFormat:@"%@", [newDict objectForKey:@"userId"]];
    
    [IM_FMDB_FILE delete_IM_LastMessageOfOneGroup:_groupID];
    [IM_FMDB_FILE insert_IM_LastMessageOfOneGroup:_groupID withMessgeId:messageID];
    if ([groupId isEqualToString:_groupID]) {
        NSString *messageStr = [jsonParser stringWithObject:newDict];
        NSLog(@"当前用户id%@", appDelegateAccessor.moudle.userId);
        if ([userId isEqualToString:appDelegateAccessor.moudle.userId]) {
            if ([[messageDict allKeys]containsObject:@"uuid"]) {
                if ([_uuidArray containsObject:[messageDict objectForKey:@"uuid"]]) {
                    for (ChatMessage *model in _showListDataArray) {
                        if ([model.msg_id integerValue] == [[messageDict objectForKey:@"uuid"] integerValue]) {
                            model.msg_state = MessageStateRecevied;
                            [_tableView reloadData];
//                            [self reloadDataTableViewRow:[_showListDataArray indexOfObject:model]];
                        }
                    }
                    
                    for (ChatMessage *model in _dataSource) {
                        if ([model.msg_id integerValue] == [[messageDict objectForKey:@"uuid"] integerValue]) {
                            model.msg_state = MessageStateRecevied;
                        }
                    }

//                    收到消息之后进行判断，是不是我自己发的消息，是的话移除
                    if ([[messageDict allKeys] containsObject:@"uuid"]) {
                        NSString *messageUUID = [messageDict objectForKey:@"uuid"];
                        if ([_uuidArray containsObject:messageUUID]) {
                            [_uuidArray removeObject:messageUUID];
                        }
                    }
                    [IM_FMDB_FILE update_IM_MessageListGroupID:groupId withMessageId:[messageDict objectForKey:@"uuid"] WithMessageState:MessageStateRecevied];
                    [IM_FMDB_FILE update_IM_MessageListGroupID:groupId withMessageId:[messageDict objectForKey:@"uuid"] WithNewMessageId:messageID withInfo:messageStr];
                    [IM_FMDB_FILE closeDataBase];
                }
            } else {
                ChatMessage *msgModel = [ChatMessage initWithDictionary:newDict withNSArray:_contactsArray];
                [_dataSource addObject:msgModel];
//                if (_showListDataArray.count == 30) {
//                    [_showListDataArray removeObjectAtIndex:0];
//                }
                [_showListDataArray addObject:msgModel];
                [_tableView reloadData];
                if ((_tableView.contentOffset.y + _tableView.frame.size.height + 300) > _tableView.contentSize.height) {
                     [self tableViewScrollToBottom];
                } else {
                    if (!_messageBtn) {
                        [self.view addSubview:self.messageBtn];
                    } else {
                        if (_newMessageCount >= 99) {
                            [_messageBtn setTitle:@"99+条新消息" forState:UIControlStateNormal];
                        } else {
                            _newMessageCount++;
                            [_messageBtn setTitle:[NSString stringWithFormat:@"%ld条新消息", _newMessageCount] forState:UIControlStateNormal];
                        }
                    }
                }
               [self deleteFirstMessage];
                [IM_FMDB_FILE insert_IM_MessageListGroupID:groupId withMessageId:messageID withInfo:messageStr withMessageState:MessageStateRecevied];
                [IM_FMDB_FILE closeDataBase];
            }
        } else {
            ChatMessage *msgModel = [ChatMessage initWithDictionary:newDict withNSArray:_contactsArray];
            [_dataSource addObject:msgModel];
//            if (_showListDataArray.count == 30) {
//                [_showListDataArray removeObjectAtIndex:0];
//            }
            [_showListDataArray addObject:msgModel];
            [_tableView reloadData];
//            [self tableViewScrollToBottom];
            if ((_tableView.contentOffset.y + _tableView.frame.size.height + 300) > _tableView.contentSize.height) {
                [self tableViewScrollToBottom];
            } else {
                if (!_messageBtn) {
                    [self.view addSubview:self.messageBtn];
                } else {
                    if (_newMessageCount >= 99) {
                        [_messageBtn setTitle:@"99+条新消息" forState:UIControlStateNormal];
                    } else {
                        _newMessageCount++;
                        [_messageBtn setTitle:[NSString stringWithFormat:@"%ld条新消息", _newMessageCount] forState:UIControlStateNormal];
                    }
                }
            }
            [self deleteFirstMessage];
            [IM_FMDB_FILE insert_IM_MessageListGroupID:groupId withMessageId:messageID withInfo:messageStr withMessageState:MessageStateRecevied];
            if ([[newDict objectForKey:@"type"] integerValue] == 4) {
                ContactModel *delModel = [[ContactModel alloc] init];
                for (ContactModel *contacModel in _contactsArray) {
                    if (contacModel.userID == [[newDict objectForKey:@"userId"] integerValue]) {
                        delModel = contacModel;
                        break;
                    }
                }
                [IM_FMDB_FILE delete_IM_OneUsersListListGroupID:_groupID WithContactId:delModel.userID];
                [_contactsArray removeObject:delModel];
            }
        }
    }
}
- (void)showContactName:(NSNotification *)notfication {
    UISwitch *send = (UISwitch *)[notfication object];
    if (send.on) {
        showName = @"show";
        NSLog(@"%d", send.on);
        [IM_FMDB_FILE delete_IM_ShowOrHiddenContactName:_groupID];
        [IM_FMDB_FILE insert_IM_ShowOrHiddenContactName:_groupID withShow:@"1"];
    } else {
        showName = @"hidden";
        [IM_FMDB_FILE delete_IM_ShowOrHiddenContactName:_groupID];
        [IM_FMDB_FILE insert_IM_ShowOrHiddenContactName:_groupID withShow:@"0"];
         NSLog(@"%d", send.on);
    }
    [_tableView reloadData];
}
//点击图片事件
- (void)pushToShowAndSaveController:(NSNotification *)notfication {
    __weak typeof(self) weakSelf = self;
    
    NSInteger indexM = [[notfication object] integerValue];
    
    ChatTableViewCell *cell = (ChatTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:indexM inSection:0]];
    
    ChatMessage *message = _showListDataArray[indexM];
    NSInteger index = 0;
    if ([_allImagesArray containsObject:message.msg_imageUrl]) {
        index = [_allImagesArray indexOfObject:message.msg_imageUrl];
    }
    [PhotoBroswerVC show:self type:PhotoBroswerVCTypeModal index:index photoModelBlock:^NSArray *{
        
        NSMutableArray *modelsM = [NSMutableArray arrayWithCapacity:weakSelf.allImagesArray.count];
        for (NSUInteger i = 0; i< weakSelf.allImagesArray.count; i++) {
            
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = i + 1;

            pbModel.image_HD_U = weakSelf.allImagesArray[i];
            
            //源frame
            UIImageView *imageV =(UIImageView *) cell.contentImageView;
            pbModel.sourceImageView = imageV;
            
            [modelsM addObject:pbModel];
        }
        
        return modelsM;
    }];

}
- (void)sendFailMessages:(NSNotification *)notfication {
    isRemove = YES;
    if (_uuidArray.count > 0) {
        for (ChatMessage *model in _showListDataArray) {
            if ([_uuidArray containsObject:model.msg_id]) {
                NSInteger index = [_dataSource indexOfObject:model];
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:_oldMessageArray[index]];
                NSDictionary *newMessageDict = @{@"id" : appDelegateAccessor.moudle.userId,
                                                 @"head" : @"message",
                                                 @"to" : _groupID,
                                                 @"content" : [dict objectForKey:@"content"],
                                                 @"type" : @"1",
                                                 @"resource" : [dict objectForKey:@"resource"],
                                                 @"time" : [dict objectForKey:@"time"],
                                                 @"uuid": model.msg_id};
                MySBJsonWriter *jsonParser = [[MySBJsonWriter alloc]init];
                NSString *messageStr =[jsonParser stringWithObject:newMessageDict];
                if (appDelegateAccessor.webSocket.readyState == SR_OPEN) {
                    [appDelegateAccessor.webSocket send:messageStr];
                } else {
                    [appDelegateAccessor removeTimer];
                    [appDelegateAccessor removeHeartTimer];
                    [appDelegateAccessor deleteWebSocket];
                    [appDelegateAccessor _reconnect];
                }
            }
        }
    }
    [self getNewMessageList];
}
- (void)refeshSelectCell:(NSNotification *)notfication {
    NSInteger row = [[notfication object] integerValue];
    ChatMessage *messageModel = _showListDataArray[row];
    messageModel.isRead = YES;
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:row inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
}
- (void)customNavRight {
    NSString *rightNav = @"";
    NSString *leftNav = @"";
    UIBarButtonItem *leftItem;
    UIBarButtonItem *rightItem;
    if (flag_Nav == 0) {
        leftNav = @"nav_back";
        rightNav = @"index_tabicon_my_normal";
        self.title = _titleName;
        leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:leftNav] style:UIBarButtonItemStylePlain target:self action:@selector(leftItemAction)];
        leftItem.imageInsets = UIEdgeInsetsMake(0, -10, 0,0);
        rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:rightNav] style:UIBarButtonItemStylePlain target:self action:@selector(rightItemAction:)];
    } else {
        leftNav = @"取消";
        rightNav = @"全选";
        self.title = @"已选择0项";
        leftItem = [[UIBarButtonItem alloc] initWithTitle:leftNav style:UIBarButtonItemStylePlain target:self action:@selector(leftItemAction)];
        rightItem = [[UIBarButtonItem alloc] initWithTitle:rightNav style:UIBarButtonItemStylePlain target:self action:@selector(rightItemAction:)];
    }
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationItem.rightBarButtonItem = rightItem;
}
- (void)leftItemAction {
    if (flag_Nav == 0) {
        if (refreshList_flag != 0) {
            if (refreshList_flag == 1 || refreshList_flag == 3) {
                [_lastMsgDict addEntriesFromDictionary:[_oldMessageArray lastObject]];
                [_lastMsgDict setObject:_groupID forKey:@"to"];
                [_lastMsgDict setObject:[_lastMsgDict objectForKey:@"userId"] forKey:@"id"];
            } else {
                [_lastMsgDict setObject:_groupID forKey:@"to"];
            }
            
        }
        if ([[_lastMsgDict allKeys] count] > 0 || (self.msgInputView.inputTextView.text.length > 0 && [self.msgInputView.inputTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0)) {
            if (_RefreshDataSourceBlock) {
                _RefreshDataSourceBlock(_lastMsgDict, self.msgInputView.inputTextView.text);
            }
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissActionView:) object:nil];
        
        NSMutableArray *changeMessageState = [NSMutableArray arrayWithCapacity:0];
        for (NSString *messageId in _uuidArray) {
            NSString *sqlStrUpdate = [NSString stringWithFormat:@"UPDATE %@ SET messageState = '%ld' WHERE id = '%@' AND messageId = '%@'", @"MESSAGELIST", MessageStateFail, _groupID ,messageId];
            [changeMessageState addObject:sqlStrUpdate];
        }
        if (changeMessageState.count > 0) {
            [IM_FMDB_FILE batch_option_im:changeMessageState];
            [IM_FMDB_FILE closeDataBase];
        }

        if ([_flag_FromWhereInto isEqualToString:@"searchVC"]) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    } else {
        flag_Nav = 0;
        [self removeDeleteBtnAction];
        isAllSelect = NO;
        [self.msgInputView prepareToShow];
        [self customNavRight];
        [_tableView reloadData];
    }
}
- (void)rightItemAction:(UIBarButtonItem *)item {
    if (flag_Nav == 0) {
        AddOrDelContactController *controller = [[AddOrDelContactController alloc] init];
        controller.title = @"同事";
        controller.groupID = _groupID;
        controller.type = _flag_CreateStr;
        controller.groupName = self.title;
        controller.groupType = _groupType;
        controller.contactModelArray = _contactsArray;
        controller.BlackContactArray = ^(NSArray *array) {
            [_contactsArray removeAllObjects];
            [_contactsArray addObjectsFromArray:array];
            NSMutableArray *nameArray = [NSMutableArray arrayWithCapacity:0];
            for (ContactModel *item in _contactsArray) {
                [nameArray addObject:item.contactName];
            }
            self.title = [nameArray componentsJoinedByString:@","];
        };
        __weak typeof(self) weak_self = self;
        controller.BlackGroupNewNameBlock = ^(NSString *string){
            weak_self.title = string;
        };
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        flag_isAll = 0;
        if (isAllSelect) {
            isAllSelect = NO;
            [item setTitle:@"全选"];
            self.title = @"已选择0项";
            [_selectArray removeAllObjects];
        } else {
            isAllSelect = YES;
            [_selectArray removeAllObjects];
            [item setTitle:@"取消全选"];
            for (ChatMessage *msgModel in _dataSource) {
                if ([msgModel.type isEqualToString:@"1"]) {
                    [_selectArray addObject:msgModel];
                }
            }
            self.title = [NSString stringWithFormat:@"已选择%ld项", _selectArray.count];
        }
        [_tableView reloadData];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
- (void)tableViewScrollToBottom {
    
    if (self.showListDataArray.count==0)
        return;
    if (_isHave) {
        _isHave = NO;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_messageIndex inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    } else {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.showListDataArray.count-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

#pragma mark - NSNotification
- (void)inputViewShow:(NSNotification*)notification {
    
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        self.tableView.frame = CGRectMake(0, 0, kScreen_Width, _msgInputView.frame.origin.y);
    }];

}

- (void)inputViewHide:(NSNotification*)notification {
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        self.tableView.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height - _msgInputView.frame.size.height);
    }];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
        ((UIImagePickerController *)navigationController).sourceType ==     UIImagePickerControllerSourceTypeSavedPhotosAlbum) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }
}

#pragma mark - UIMessageInputViewDelegate
- (void)messageInputView:(UIMessageInputView *)inputView sendText:(NSString *)text {
    if ([_flag_CreateStr isEqualToString:@"1"]) {
        _resourceSting = @"";
        [self getCreateGroup:_contactsArray withContent:text];
    } else {
        NSTimeInterval second = [[NSDate date] timeIntervalSince1970] * 1000;
        long long time = second;
        NSString *uuidStr = [self getUUIDString];
        NSDictionary *dic = @{@"id" : appDelegateAccessor.moudle.userId,
                              @"head" : @"message",
                              @"to" : _groupID,
                              @"content" : text,
                              @"type" : @"1",
                              @"resource" : @"",
                              @"time" : @(time),
                              @"uuid": uuidStr};
        MySBJsonWriter *jsonParser = [[MySBJsonWriter alloc]init];
        NSString *messageStr =[jsonParser stringWithObject:dic];
        
        NSDictionary *newDict = [self changeKeysForDictionary:dic withType:@"send"];
        [self.oldMessageArray addObject:newDict];
        NSString *newMessageStr = [jsonParser stringWithObject:newDict];
        ChatMessage *msgModel = [ChatMessage initWithDictionary:newDict withNSArray:_contactsArray];
        msgModel.msg_state = MessageStateSend;
        [_dataSource addObject:msgModel];
        [_showListDataArray addObject:msgModel];
        [_uuidArray addObject:uuidStr];
        [_tableView reloadData];
        [self tableViewScrollToBottom];
        
        [self deleteFirstMessage];
        
        //预插入数据：本地显示（未成功状态）
        [IM_FMDB_FILE insert_IM_MessageListGroupID:_groupID withMessageId:uuidStr withInfo:newMessageStr withMessageState:MessageStateSend];
        [IM_FMDB_FILE closeDataBase];
        dispatch_queue_t queue = dispatch_queue_create("Search.Queue", NULL);
        dispatch_async(queue, ^{
            if (appDelegateAccessor.webSocket.readyState == SR_OPEN) {
                [appDelegateAccessor.webSocket send:messageStr];
            } else {
                [appDelegateAccessor removeTimer];
                [appDelegateAccessor removeHeartTimer];
                [appDelegateAccessor deleteWebSocket];
                [appDelegateAccessor _reconnect];
            }
        });
        [self performSelector:@selector(dismissActionView:) withObject:(id)msgModel afterDelay:60];
    }
    [self.msgInputView notifyInputView:@""];
}

- (void)messageInputView:(UIMessageInputView *)inputView addIndexClicked:(NSInteger)index {
    if (index == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:^{}];
        }
        return;
    }
    __weak typeof(self) weak_self = self;
    PhotoAssetLibraryViewController *assetLibraryController = [[PhotoAssetLibraryViewController alloc] init];
    assetLibraryController.maxCount = 9;
    assetLibraryController.confirmBtnClickedBlock = ^(NSArray *array) {
        if (array.count > 0) {
            [weak_self sendImagesMessageWithImagesArray:array];
        }
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:assetLibraryController];
    [self presentViewController:nav animated:YES completion:^{
    }];
    return;
    
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
//        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//        picker.delegate = self;
//        picker.allowsEditing = NO;
//        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
//        [self presentViewController:picker animated:YES completion:^{
//        }];
//    }
}
- (void)sendImagesMessageWithImagesArray:(NSArray *)imageArray {
    for (PhotoAssetModel *assetModel in imageArray) {
        ALAssetRepresentation *representation = [assetModel.asset defaultRepresentation];
        NSURL *imageURL = [representation url];//[info valueForKey:UIImagePickerControllerReferenceURL];
        NSString *fileName = [NSString stringWithFormat:@"%@", imageURL];
        MySBJsonWriter *jsonParser = [[MySBJsonWriter alloc]init];
        NSDictionary *resourceDic = @{@"fileName" : @"",
                                      @"name" : fileName,
                                      @"second" : @"",
                                      @"type" : @"1"};
        _resourceSting = [jsonParser stringWithObject:resourceDic];
        NSLog(@"_resourceSting %@", _resourceSting);
        NSDictionary *messageDic, *modelDict;
        NSMutableDictionary *dic;
        ChatMessage *msgModel;
        NSTimeInterval second = [[NSDate date] timeIntervalSince1970] * 1000;
        long long time = second;
        NSString *uuidStr = [self getUUIDString];
        if ([_flag_CreateStr isEqualToString:@"0"]) {
            
            //消息体字典格式
            messageDic = @{@"id" : appDelegateAccessor.moudle.userId,
                           @"head" : @"message",
                           @"to" : _groupID,
                           @"content" : @"",
                           @"type" : @"1",
                           @"resource" : _resourceSting,
                           @"time" : @(time),
                           @"uuid" : uuidStr};
            dic = [NSMutableDictionary dictionaryWithDictionary:messageDic];
            modelDict = [self changeKeysForDictionary:dic withType:@"send"];
            msgModel = [ChatMessage initWithDictionary:modelDict withNSArray:_contactsArray];
            msgModel.msg_state = MessageStateSend;
            [self deleteFirstMessage];
            //预插入数据：本地显示（未成功状态）
            NSString *imageMessageStr = [jsonParser stringWithObject:modelDict];
            [IM_FMDB_FILE insert_IM_MessageListGroupID:_groupID withMessageId:uuidStr withInfo:imageMessageStr withMessageState:MessageStateSend];
            [self.oldMessageArray addObject:modelDict];
            [_showListDataArray addObject:msgModel];
            [_dataSource addObject:msgModel];
            [_tableView reloadData];
            [self tableViewScrollToBottom];
        }
        
        
        CGImageRef ref = [[assetModel.asset  defaultRepresentation]fullScreenImage];
        UIImage *originalImage = [[UIImage alloc]initWithCGImage:ref];
        NSData *imgData = UIImageJPEGRepresentation(originalImage, 1.0);
        
        if ((float)imgData.length/1024 > 1000) {
            imgData = UIImageJPEGRepresentation(originalImage, 1024*1000.0/(float)imgData.length);
        }
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:appDelegateAccessor.moudle.userId forKey:@"id"];
        [params setObject:appDelegateAccessor.moudle.userCompanyId forKey:@"companyId"];
        [params setObject:@"0" forKey:@"second"];
        [params setObject:appDelegateAccessor.moudle.IM_tokenString forKey:@"token"];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_IM, IM_GET_UPLOAD_FILE] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData :imgData name:@"file" fileName:[NSString stringWithFormat:@"files.jpeg"] mimeType:@"image/jpeg"];
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (responseObject && [[responseObject objectForKey:@"status"] integerValue] == 0) {
                if ([CommonFuntion checkNullForValue:[responseObject objectForKey:@"body"]]) {
                    MySBJsonWriter *jsonParser = [[MySBJsonWriter alloc]init];
                    _resourceSting = [responseObject objectForKey:@"body"];
                    _resourceSting = [jsonParser stringWithObject:_resourceSting];
                    if ([_flag_CreateStr isEqualToString:@"0"]) {
                        
                        [dic setValue:_resourceSting forKey:@"resource"];
                        NSString *messageStr =[jsonParser stringWithObject:dic];
                        if (appDelegateAccessor.webSocket.readyState == SR_OPEN) {
                            [appDelegateAccessor.webSocket send:messageStr];
                        } else {
                            [appDelegateAccessor removeTimer];
                            [appDelegateAccessor removeHeartTimer];
                            [appDelegateAccessor deleteWebSocket];
                            [appDelegateAccessor _reconnect];
                        }
                        [_uuidArray addObject:uuidStr];
                        NSDictionary *newDict = [self changeKeysForDictionary:dic withType:@"send"];
                        NSInteger index = [self.oldMessageArray indexOfObject:modelDict];
                        [self.oldMessageArray removeObject:modelDict];
                        [self.oldMessageArray insertObject:newDict atIndex:index];
                        NSString *newMessageStr = [jsonParser stringWithObject:newDict];
                        //预插入数据：本地显示（未成功状态）
                        [IM_FMDB_FILE update_IM_MessageListGroupID:_groupID withMessageId:uuidStr WithNewMessageId:uuidStr withInfo:newMessageStr];
                        [IM_FMDB_FILE closeDataBase];
                        
                        NSInteger messageIndex = [_showListDataArray indexOfObject:msgModel];
                        [_showListDataArray removeObject:msgModel];
                        [_dataSource removeObject:msgModel];
                        
                        ChatMessage *messageModel = [ChatMessage initWithDictionary:newDict withNSArray:_contactsArray];
                        messageModel.msg_state = MessageStateSend;
                        [self performSelector:@selector(dismissActionView:) withObject:(id)messageModel afterDelay:60];
                        [_showListDataArray insertObject:messageModel atIndex:messageIndex];
                        [_dataSource insertObject:messageModel atIndex:messageIndex];
                        //                    [_dataSource addObject:msgModel];
                        [_allImagesArray addObject:messageModel.msg_imageUrl];
                        [_tableView reloadData];
                        [self tableViewScrollToBottom];
                        
                    } else {
                        [self getCreateGroup:_contactsArray withContent:@""];
                    }
                } else {
                    _resourceSting = @"";
                }
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            msgModel.msg_state = MessageStateFail;
            [IM_FMDB_FILE update_IM_MessageListGroupID:_groupID withMessageId:uuidStr WithMessageState:MessageStateFail];
            [_tableView reloadData];
        }];
    }
    
}
- (void)messageInputView:(UIMessageInputView *)inputView heightToBottomChanged:(CGFloat)heightToBottom {
    
}
- (void)getWithVoiceFileData:(NSData *)data withVoiceFileName:(NSString *)name withVoiceFileTime:(NSInteger)voiceTime {
    if (voiceTime == 0) {
        kShowHUD(@"录音时间太短");
        return;
    }
    
    MySBJsonWriter *jsonParser = [[MySBJsonWriter alloc]init];
    //文件字典格式
    NSDictionary *resourceDic = @{@"fileName" : @"",
                                  @"name" : name,
                                  @"second" : @(voiceTime),
                                  @"type" : @"3"};
    _resourceSting = [jsonParser stringWithObject:resourceDic];
    
    //先显示UI，再上传文件
    NSTimeInterval second = [[NSDate date] timeIntervalSince1970] * 1000;
    long long time = second;
    NSString *uuidStr = [self getUUIDString];
    
    NSDictionary *messageDic, *modelDict;
    NSMutableDictionary *dic;
    ChatMessage *msgModel;
    if ([_flag_CreateStr isEqualToString:@"0"]) {
        
        //消息体字典格式
        messageDic = @{@"id" : appDelegateAccessor.moudle.userId,
                       @"head" : @"message",
                       @"to" : _groupID,
                       @"content" : @"",
                       @"type" : @"1",
                       @"resource" : _resourceSting,
                       @"time" : @(time),
                       @"uuid" : uuidStr};
        dic = [NSMutableDictionary dictionaryWithDictionary:messageDic];
        modelDict = [self changeKeysForDictionary:dic withType:@"send"];
        msgModel = [ChatMessage initWithDictionary:modelDict withNSArray:_contactsArray];
        msgModel.msg_state = MessageStateSend;
        [self deleteFirstMessage];
        //预插入数据：本地显示（未成功状态）
        NSString *imageMessageStr = [jsonParser stringWithObject:modelDict];
        [IM_FMDB_FILE insert_IM_MessageListGroupID:_groupID withMessageId:uuidStr withInfo:imageMessageStr withMessageState:MessageStateSend];
        [self.oldMessageArray addObject:modelDict];
        [_showListDataArray addObject:msgModel];
        [_dataSource addObject:msgModel];
        [_tableView reloadData];
        [self tableViewScrollToBottom];
    }

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:appDelegateAccessor.moudle.userId forKey:@"id"];
    [params setObject:appDelegateAccessor.moudle.userCompanyId forKey:@"companyId"];
    [params setObject:@(voiceTime) forKey:@"second"];
    [params setObject:appDelegateAccessor.moudle.IM_tokenString forKey:@"token"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager]
    ;
    
    [manager POST:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_IM, IM_GET_UPLOAD_FILE] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData :data name:@"file" fileName:name mimeType:@"video/aac"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject && [[responseObject objectForKey:@"status"] integerValue] == 0) {
            if ([CommonFuntion checkNullForValue:[responseObject objectForKey:@"body"]]) {
                MySBJsonWriter *jsonParser = [[MySBJsonWriter alloc]init];
                _resourceSting = [responseObject objectForKey:@"body"];
                _resourceSting = [jsonParser stringWithObject:_resourceSting];
                if ([_flag_CreateStr isEqualToString:@"0"]) {                    [dic setValue:_resourceSting forKey:@"resource"];
                    NSString *messageStr =[jsonParser stringWithObject:dic];
                    if (appDelegateAccessor.webSocket.readyState == SR_OPEN) {
                        [appDelegateAccessor.webSocket send:messageStr];
                    } else {
                        [appDelegateAccessor removeTimer];
                        [appDelegateAccessor removeHeartTimer];
                        [appDelegateAccessor deleteWebSocket];
                        [appDelegateAccessor _reconnect];
                    }
                    NSDictionary *newDict = [self changeKeysForDictionary:dic withType:@"send"];
                    NSInteger index = [self.oldMessageArray indexOfObject:modelDict];
                    [self.oldMessageArray removeObject:modelDict];
                    [self.oldMessageArray insertObject:newDict atIndex:index];
                    NSString *newMessageStr = [jsonParser stringWithObject:dic];
                    [_uuidArray addObject:uuidStr];
                    //预插入数据：本地显示（未成功状态）
                    [IM_FMDB_FILE update_IM_MessageListGroupID:_groupID withMessageId:uuidStr WithNewMessageId:uuidStr withInfo:newMessageStr];
                    [IM_FMDB_FILE closeDataBase];
                    
                    NSInteger messageIndex = [_showListDataArray indexOfObject:msgModel];
                    [_showListDataArray removeObject:msgModel];
                    [_dataSource removeObject:msgModel];
                    
                    ChatMessage *messageModel = [ChatMessage initWithDictionary:newDict withNSArray:_contactsArray];
                    messageModel.msg_state = MessageStateSend;
                     [self performSelector:@selector(dismissActionView:) withObject:(id)messageModel afterDelay:60];
                    [_showListDataArray insertObject:messageModel atIndex:messageIndex];
                    [_dataSource insertObject:messageModel atIndex:messageIndex];
                    
                    [_tableView reloadData];
                    [self tableViewScrollToBottom];
                    
                } else {
                     [self getCreateGroup:_contactsArray withContent:@""];
                }
            } else {
                _resourceSting = @"";
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        msgModel.msg_state = MessageStateFail;
        [IM_FMDB_FILE update_IM_MessageListGroupID:_groupID withMessageId:uuidStr WithMessageState:MessageStateFail];
        [_tableView reloadData];
    }];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:^{
        NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
        NSString *fileName = [NSString stringWithFormat:@"%@", imageURL];
        MySBJsonWriter *jsonParser = [[MySBJsonWriter alloc]init];
        //文件字典格式
        NSDictionary *resourceDic = @{@"fileName" : @"",
                                      @"name" : fileName,
                                      @"second" : @"",
                                      @"type" : @"1"};
        _resourceSting = [jsonParser stringWithObject:resourceDic];
        NSLog(@"_resourceSting %@", _resourceSting);
        NSDictionary *messageDic, *modelDict;
        NSMutableDictionary *dic;
        ChatMessage *msgModel;
        NSTimeInterval second = [[NSDate date] timeIntervalSince1970] * 1000;
        long long time = second;
        NSString *uuidStr = [self getUUIDString];
        if ([_flag_CreateStr isEqualToString:@"0"]) {
            
            //消息体字典格式
            messageDic = @{@"id" : appDelegateAccessor.moudle.userId,
                           @"head" : @"message",
                           @"to" : _groupID,
                           @"content" : @"",
                           @"type" : @"1",
                           @"resource" : _resourceSting,
                           @"time" : @(time),
                           @"uuid" : uuidStr};
            dic = [NSMutableDictionary dictionaryWithDictionary:messageDic];
            modelDict = [self changeKeysForDictionary:dic withType:@"send"];
            msgModel = [ChatMessage initWithDictionary:modelDict withNSArray:_contactsArray];
            msgModel.msg_state = MessageStateSend;
            [self deleteFirstMessage];
            //预插入数据：本地显示（未成功状态）
            NSString *imageMessageStr = [jsonParser stringWithObject:modelDict];
            [IM_FMDB_FILE insert_IM_MessageListGroupID:_groupID withMessageId:uuidStr withInfo:imageMessageStr withMessageState:MessageStateSend];
            [self.oldMessageArray addObject:modelDict];
            [_showListDataArray addObject:msgModel];
            [_dataSource addObject:msgModel];
            [_tableView reloadData];
            [self tableViewScrollToBottom];
        }
        UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        originalImage = [self fixOrientation:originalImage];
        NSData *imgData = UIImageJPEGRepresentation(originalImage, 1.0);
        if ((float)imgData.length/1024 > 1000) {
            imgData = UIImageJPEGRepresentation(originalImage, 1024*1000.0/(float)imgData.length);
        }
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:appDelegateAccessor.moudle.userId forKey:@"id"];
        [params setObject:appDelegateAccessor.moudle.userCompanyId forKey:@"companyId"];
        [params setObject:@"0" forKey:@"second"];
        [params setObject:appDelegateAccessor.moudle.IM_tokenString forKey:@"token"];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_IM, IM_GET_UPLOAD_FILE] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData :imgData name:@"file" fileName:[NSString stringWithFormat:@"files.jpeg"] mimeType:@"image/jpeg"];
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (responseObject && [[responseObject objectForKey:@"status"] integerValue] == 0) {
                if ([CommonFuntion checkNullForValue:[responseObject objectForKey:@"body"]]) {
                    MySBJsonWriter *jsonParser = [[MySBJsonWriter alloc]init];
                    _resourceSting = [responseObject objectForKey:@"body"];
                    _resourceSting = [jsonParser stringWithObject:_resourceSting];
                    if ([_flag_CreateStr isEqualToString:@"0"]) {

                        [dic setValue:_resourceSting forKey:@"resource"];
                        NSString *messageStr =[jsonParser stringWithObject:dic];
                        if (appDelegateAccessor.webSocket.readyState == SR_OPEN) {
                            [appDelegateAccessor.webSocket send:messageStr];
                        } else {
                            [appDelegateAccessor removeTimer];
                            [appDelegateAccessor removeHeartTimer];
                            [appDelegateAccessor deleteWebSocket];
                            [appDelegateAccessor _reconnect];
                        }
                        [_uuidArray addObject:uuidStr];
                        NSDictionary *newDict = [self changeKeysForDictionary:dic withType:@"send"];
                        NSInteger index = [self.oldMessageArray indexOfObject:modelDict];
                        [self.oldMessageArray removeObject:modelDict];
                        [self.oldMessageArray insertObject:newDict atIndex:index];
                        NSString *newMessageStr = [jsonParser stringWithObject:newDict];
                        //预插入数据：本地显示（未成功状态）
                        [IM_FMDB_FILE update_IM_MessageListGroupID:_groupID withMessageId:uuidStr WithNewMessageId:uuidStr withInfo:newMessageStr];
                        [IM_FMDB_FILE closeDataBase];

                        NSInteger messageIndex = [_showListDataArray indexOfObject:msgModel];
                        [_showListDataArray removeObject:msgModel];
                        [_dataSource removeObject:msgModel];
                        
                        ChatMessage *messageModel = [ChatMessage initWithDictionary:newDict withNSArray:_contactsArray];
                        messageModel.msg_state = MessageStateSend;
                        [self performSelector:@selector(dismissActionView:) withObject:(id)messageModel afterDelay:60];
                        [_showListDataArray insertObject:messageModel atIndex:messageIndex];
                        [_dataSource insertObject:messageModel atIndex:messageIndex];
                        [_allImagesArray addObject:messageModel.msg_imageUrl];
                        //                    [_dataSource addObject:msgModel];
                        [_tableView reloadData];
                        [self tableViewScrollToBottom];
                        
                    } else {
                        [self getCreateGroup:_contactsArray withContent:@""];
                    }
                } else {
                    _resourceSting = @"";
                }
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            msgModel.msg_state = MessageStateFail;
            [IM_FMDB_FILE update_IM_MessageListGroupID:_groupID withMessageId:uuidStr WithMessageState:MessageStateFail];
            [_tableView reloadData];
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.dataSource.count;
    return _showListDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    ChatMessage *msgModel = self.dataSource[indexPath.row];
    ChatMessage *msgModel = self.showListDataArray[indexPath.row];
    return [ChatTableViewCell cellHeightWithObject:msgModel withIsShow:showName];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
//    ChatMessage *msgModel = self.dataSource[indexPath.row];
    ChatMessage *msgModel = self.showListDataArray[indexPath.row];
    cell.timeLabel.hidden = YES;
    NSString *newTime = [CommonFuntion getStringForTime:[msgModel.msg_time longLongValue]];
    NSLog(@"_timeFlag: %@", _timeFlag);
    if (_timeFlag) {
        if ([[_timeFlag substringFromIndex:14] isEqualToString:[newTime substringFromIndex:14]]) {
            if ([[newTime substringWithRange:NSMakeRange(1, 15)] integerValue] - [[_timeFlag substringWithRange:NSMakeRange(1, 15)] integerValue] > 2) {
                cell.timeLabel.hidden = NO;
                _timeFlag = newTime;
            }
        } else {
            cell.timeLabel.hidden = NO;
            _timeFlag = newTime;
        }
    } else {
        cell.timeLabel.hidden = NO;
        _timeFlag = newTime;
    }
    if (indexPath.row == 0) {
        cell.timeLabel.hidden = NO;
    }
    if (flag_Nav == 1) {
        if (flag_isAll == 0) {
            if (isAllSelect) {
                msgModel.isSelect = YES;
            } else {
                msgModel.isSelect = NO;
            }
        } else {
            
        }
        [cell configWithObject:msgModel withType:@"delete" withIsShow:showName];
    } else {
        cell.index = indexPath.row;
        [cell configWithObject:msgModel withType:@"normal" withIsShow:showName];
    }
    
    __weak typeof(self) weak_self = self;
    cell.headImageViewClickBlock = ^(NSString *string) {
        [weak_self pushIntoInfoControllerView:msgModel.user_uid];
        
    };
    
    /*
    cell.BackVoiceUrlBlock = ^() {
        [weak_self playVoiceWithChatMessage:msgModel withIndexPath:indexPath];
    };
     */
    
//    cell.BackMessageIdBlock = ^(ChatMessage *chatModel) {
//        [weak_self performSelector:@selector(dismissActionView:) withObject:(id)chatModel afterDelay:60];
//    };
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPress:)];
    [cell addGestureRecognizer:longPressGesture];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"indexPath:%@", indexPath);
    if (flag_Nav == 1) {
        flag_isAll = 1;
//        ChatMessage *chatModel = _dataSource[indexPath.row];
         ChatMessage *chatModel = _showListDataArray[indexPath.row];
        if (chatModel.isSelect) {
            chatModel.isSelect = NO;
            //取消选中的同时，删除掉数据
            for (int i = 0; i < _selectArray.count; i++) {
                ChatMessage *model = _selectArray[i];
                if ([model.msg_id integerValue] == [chatModel.msg_id integerValue]) {
                    [_selectArray removeObjectAtIndex:i];
                }
            }
        } else {
            chatModel.isSelect = YES;
            [_selectArray addObject:chatModel];
        }
        self.title = [NSString stringWithFormat:@"已选择%ld项", _selectArray.count];
        //改变当前cell
        ChatTableViewCell *cell = (ChatTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell configWithObject:chatModel withType:@"delete" withIsShow:showName];
        [_tableView reloadData];
//        [self reloadDataTableViewRow:indexPath.row];
    } else {
        ChatMessage *chatModel = _showListDataArray[indexPath.row];
//        ChatMessage *chatModel = _dataSource[indexPath.row];
        if (chatModel.msg_state == MessageStateFail) {
            selectIndex = indexPath.row;
            [self showActionSheetReSendOneMessge];
            return;
        } else {
            if (!chatModel.hasResourceView) {
                return;
            }
            switch (chatModel.msg_type) {
                case ChatMessageTypeImage:
                {
                }
                    break;
                case ChatMessageTypeFile:
                {
                    KnowledgeFileDetailsViewController *knowController = [[KnowledgeFileDetailsViewController alloc] init];
                    knowController.isNeedRightNavBtn = YES;
                    knowController.detailsOld = [self changeKeyAndValueOfOldDcit:_showListDataArray[indexPath.row]];
                    knowController.viewFrom = @"other";
                    [self.navigationController pushViewController:knowController animated:YES];
                }
                    break;
                    
                default:
                    break;
            }

        }
    }

}
#pragma mark - 消息发送状态监听
- (void)dismissActionView:(ChatMessage *)msgModel {
    if ([_uuidArray containsObject:msgModel.msg_id]) {
        //发送失败关闭webSocket
        [appDelegateAccessor removeTimer];
        [appDelegateAccessor removeHeartTimer];
        [appDelegateAccessor deleteWebSocket];
        NSInteger index = [_dataSource indexOfObject:msgModel];
        [_dataSource removeObject:msgModel];
        [_showListDataArray removeObject:msgModel];
        msgModel.msg_state = MessageStateFail;
        [_dataSource insertObject:msgModel atIndex:index];
        [_showListDataArray insertObject:msgModel atIndex:index];
        [IM_FMDB_FILE update_IM_MessageListGroupID:_groupID withMessageId:msgModel.msg_id WithMessageState:MessageStateFail];
        
        
        if ([_showListDataArray containsObject:msgModel]) {
            
             NSInteger row = [_showListDataArray indexOfObject:msgModel];
            [_showListDataArray removeObject:msgModel];
            [_showListDataArray insertObject:msgModel atIndex:row];
            if ( 0 <= row < _showListDataArray.count) {
//                [self reloadDataTableViewRow:row];
                [_tableView reloadData];
            }
        }
        [_uuidArray removeObject:msgModel.msg_id];
       /*
        for (ChatMessage *messageModel in _showListDataArray) {
            if ([msgModel.msg_id isEqualToString:messageModel.msg_id]) {
                 NSInteger row = [_showListDataArray indexOfObject:messageModel];
                msgModel.msg_state = MessageStateFail;
                row = [_showListDataArray indexOfObject:messageModel];
                if ( 0 <= row < _showListDataArray.count) {
                    
                    [self reloadDataTableViewRow:row];
                }
            }
        }
        */
        
    }
}
#pragma mark - MenuItem Action
- (void)cellLongPress:(UILongPressGestureRecognizer *)recognizer {
    if (flag_Nav == 0) {
        if (recognizer.state ==  UIGestureRecognizerStateBegan) {
            CGPoint location = [recognizer locationInView:self.tableView];
            _indexPath = [self.tableView indexPathForRowAtPoint:location];
            
            _cell = (ChatTableViewCell *)recognizer.view;
            _chatMsgModel = _dataSource[_indexPath.row];
            [_cell resignFirstResponder];
            //系统消息不能对其做操作
            if (![_chatMsgModel.type isEqualToString:@"1"]) {
                return;
            }
            UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyHandleAction:)];
            UIMenuItem *answerItem = [[UIMenuItem alloc] initWithTitle:@"回复" action:@selector(answerHandleAction:)];
            UIMenuItem *moreItem = [[UIMenuItem alloc] initWithTitle:@"更多" action:@selector(moreHandleAction:)];
             UIMenuController *controller = [UIMenuController sharedMenuController];
            if (_chatMsgModel.hasResourceView) {
                [controller setMenuItems:[NSArray arrayWithObjects:moreItem, nil]];
            } else {
                if (_chatMsgModel.isMe) {
                    [controller setMenuItems:[NSArray arrayWithObjects:copyItem, moreItem, nil]];
                } else {
                    [controller setMenuItems:[NSArray arrayWithObjects:copyItem, answerItem, moreItem, nil]];
                }
            }
            [controller setTargetRect:_cell.frame inView:self.tableView];
            [controller setMenuVisible:YES animated:YES];
        }
    }
}

- (void)copyHandleAction:(id)sender {
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    board.string = _chatMsgModel.msg_content;
//    NSLog(@"复制%@", board.string);
}
- (void)answerHandleAction:(id)sender {
    [self.msgInputView.inputTextView becomeFirstResponder];
    self.msgInputView.inputTextView.text = [NSString stringWithFormat:@"回复%@:", _chatMsgModel.user_name];
}
- (void)moreHandleAction:(id)sender {
    [self.msgInputView prepareToDismiss];
    _deleteBtn.hidden = NO;
    flag_Nav = 1;
    [self customNavRight];
    [self deleteMessage];
    [_tableView reloadData];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.msgInputView isAndResignFirstResponder];
    _tableView.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height - _msgInputView.frame.size.height);
//    [self tableViewScrollToBottom];
//    [_tableView reloadData];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //    [scrollView setContentOffset:CGPointMake(320, 400) animated:YES];
//    NSLog(@"%s %d %@", __FUNCTION__, __LINE__, self.tableView);
    if (self.tableView.contentSize.height - self.tableView.contentOffset.y <= self.self.tableView.bounds.size.height) {
        [self readNewMessage];
    }
}
#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, CGRectGetHeight(self.view.bounds)-50) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[ChatTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    }
    return _tableView;
}

- (UIMessageInputView*)msgInputView {
    if (!_msgInputView) {
        _msgInputView = [UIMessageInputView initMessageInputViewWithType:UIMessageInputViewTypeMedia andRootView:self.view];
        _msgInputView.delegate = self;
    }
    return _msgInputView;
}
- (void)deleteTalkTextAction {
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除", nil];
    [action showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 500) {
        if (buttonIndex == 0) {
            NSLog(@"重新发送");
            [self sendOneMessageOfFail];
        }
    } else {
        if (buttonIndex == 0) {
            if (_selectArray.count == 0) {
                return;
            }
            for (ChatMessage *chatModel in _selectArray) {
                [IM_FMDB_FILE delete_IM_MessageListGroupID:_groupID withMessageId:chatModel.msg_id];
            }
            [_selectArray removeAllObjects];
            [self dataSourceInfo:[IM_FMDB_FILE result_IM_MessageList:_groupID] usersArray:[IM_FMDB_FILE result_IM_UserList:_groupID]];
            [IM_FMDB_FILE closeDataBase];
            flag_Nav = 0;
            [self customNavRight];
            _deleteBtn.hidden = YES;
            isAllSelect = NO;
            [self.msgInputView prepareToShow];
            [_tableView reloadData];
            NSLog(@"删除数据");
        }
    }
}
- (NSDictionary *)changeKeysForDictionary:(NSDictionary *)dict withType:(NSString *)sendOrRecevied {
    NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
    [newDict setValue:[dict objectForKey:@"id"] forKey:@"userId"];
    if ([sendOrRecevied isEqualToString:@"send"]) {
        [newDict setValue:[dict objectForKey:@"uuid"] forKey:@"id"];
    } else {
        [newDict setValue:[dict objectForKey:@"number"] forKey:@"id"];
    }
    [newDict setValue:[dict objectForKey:@"content"] forKey:@"content"];
    [newDict setValue:[dict objectForKey:@"type"] forKey:@"type"];
    [newDict setValue:[dict objectForKey:@"time"] forKey:@"time"];
    [newDict setValue:[dict objectForKey:@"resource"] forKey:@"resource"];
    [newDict setValue:sendOrRecevied forKey:@"myself"];
    return newDict;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
    return YES;
}
#pragma mark -  上拉加载 下来刷新
//集成刷新控件
- (void)setupRefresh
{
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
        [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"chatList"];
    // 自动刷新(一进入程序就下拉刷新)
//        [self.tableView headerBeginRefreshing];
    
}

// 结束加载
-(void)reloadRefeshView{
    // 刷新列表
    [self.tableView reloadData];
    //定位到具体的行
    if (selectRow < _showListDataArray.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectRow inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    [self.tableView headerEndRefreshing];
}

// 下拉
- (void)headerRereshing
{
    NSLog(@"headerRereshing--下拉-->");
    if ([self.tableView isFooterRefreshing]) {
        [self.tableView headerEndRefreshing];
        return;
    }
//    [self readMoreOldMessages];
    //如果第一次就获取失败的话，那么保持原有的messageNumber
    if (!isRemove) {
        ChatMessage *model = _showListDataArray[0];
        _messageNumber = [model.msg_number integerValue];
    }
    //当_messageNuber表示已经获取到第一条消息了，那么此时就不用再获取了
    if (_messageNumber > 1) {
        [self getGroupConversationListWithNumber:_messageNumber WithFlag:@"1"];
    }else {
        [self.tableView headerEndRefreshing];
    }
}

#pragma mark - 调用接口
//获取消息列表
- (void)getGroupConversationListWithNumber:(NSInteger)messageNumber WithFlag:(NSString *)flag {
    __weak typeof(self) weak_self = self;
//    [weak_self tableViewScrollToBottom];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    [params setObject:appDelegateAccessor.moudle.userId forKey:@"userId"];
    [params setObject:_groupID forKey:@"groupId"];
    
    [params setObject:@(messageNumber) forKey:@"number"];
    
    [params setObject:appDelegateAccessor.moudle.IM_tokenString forKey:@"token"];
    
    [params setObject:@"30" forKey:@"pageSize"];
    
    //下拉1   默认请求0
    [params setObject:flag forKey:@"flag"];
    
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_IM, IM_GET_GROUP_CONVERSATION_LIST] params:params success:^(id responseObj) {
        NSLog(@"responseObj:%@",responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            
            if ([CommonFuntion checkNullForValue:[responseObj objectForKey:@"body"]]) {
                [weak_self insertCacheFileOfDataSource:[responseObj objectForKey:@"body"]];
            }
//            [weak_self tableViewScrollToBottom];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getGroupConversationListWithNumber:messageNumber WithFlag:flag];
            };
            [comRequest loginInBackground];
        }
        if ([flag isEqualToString:@"0"]) {
            [weak_self setupRefresh];
        }
        [weak_self reloadRefeshView];
        if (isRemove) {
            [weak_self tableViewScrollToBottom];
            isRemove = NO;
        } else {
            
        }
    } failure:^(NSError *error) {
        NSLog(@"----%@", error);
        if ([flag isEqualToString:@"0"]) {
            [weak_self setupRefresh];
        }
        [weak_self reloadRefeshView];
//        [weak_self tableViewScrollToBottom];
        if (isRemove) {
            [weak_self tableViewScrollToBottom];
            isRemove = NO;
        } else {
            
        }
    }];
}
//创建组
- (void)getCreateGroup:(NSArray *)array withContent:(NSString *)text {
    if (![CommonFuntion checkNullForValue:_resourceSting] && ![CommonFuntion checkNullForValue:text]) {
        return;
    }
    if (array.count == 0) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    NSMutableArray *idsArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *namesArray = [NSMutableArray arrayWithCapacity:0];
    for (ContactModel *model in array) {
        if (model.userID != [appDelegateAccessor.moudle.userId integerValue]) {
            [idsArray addObject:@(model.userID)];
        }
        [namesArray addObject:model.contactName];
    }
    if (![namesArray containsObject:appDelegateAccessor.moudle.userName]) {
        [namesArray addObject:appDelegateAccessor.moudle.userName];
    }
    NSString *idsStr = [idsArray componentsJoinedByString:@","];
//    NSString *namesStr = [namesArray componentsJoinedByString:@","];
    [params setObject:appDelegateAccessor.moudle.userId forKey:@"userId"];
    [params setObject:idsStr forKey:@"ids"];
    [params setObject:text forKey:@"content"];
    [params setObject:_resourceSting forKey:@"resource"];
    
    NSString *actionStr = @"";
    if ([_companyType isEqualToString:@"company"]) {
        [params setObject:_titleName forKey:@"groupName"];
        actionStr = IM_GET_CREATE_COMPANY_GROUP;
    } else {
        actionStr = IM_GET_CREATE_GROUP;
    }
    [params setObject:appDelegateAccessor.moudle.IM_tokenString forKey:@"token"];
    __weak typeof(self) weak_self = self;
//    _hud = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.tableView addSubview:_hud];
//    [_hud show:YES];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_IM, actionStr] params:params success:^(id responseObj) {
//        [_hud hide:YES];
//        NSLog(@"----%@", responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            _flag_CreateStr = @"0";
            _pushType = ControllerPushTypeMessageVC;
            if ([CommonFuntion checkNullForValue:[responseObj objectForKey:@"body"]]) {
                _groupID = [NSString stringWithFormat:@"%@", [[responseObj objectForKey:@"body"] objectForKey:@"id"]];
                _groupType = [NSString stringWithFormat:@"%@", [[responseObj objectForKey:@"body"] objectForKey:@"type"]];
            }
            [weak_self getGroupConversationListWithNumber:_messageNumber WithFlag:@"0"];
            if ([_companyType isEqualToString:@"company"]) {
                return;
            }
            NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
            NSMutableArray *oldArray = [NSMutableArray arrayWithArray:[IM_FMDB_FILE result_IM_RecentContactList]];
            NSMutableArray *oldIdsArray = [NSMutableArray arrayWithCapacity:0];
            
            //去重处理
            if (oldArray.count > 0) {
                for (ContactModel *oldModel in oldArray) {
                    [oldIdsArray addObject:@(oldModel.userID)];
                }
                for (ContactModel *model in array) {
                    if ([oldIdsArray containsObject:@(model.userID)]) {
                        [IM_FMDB_FILE delete_IM_RecentContact:[NSString stringWithFormat:@"%ld", model.userID]];
                    }
                }
            }
            //合并数据
            newArray = (NSMutableArray *)[[newArray reverseObjectEnumerator] allObjects];
//            oldArray = (NSMutableArray *)[[oldArray reverseObjectEnumerator] allObjects];
            
            [newArray addObjectsFromArray:[IM_FMDB_FILE result_IM_RecentContactList]];
            
            if (newArray && newArray.count > 5) {
                newArray  = [NSMutableArray arrayWithArray:[newArray subarrayWithRange:NSMakeRange(0, 5)]];
            }
            
            [IM_FMDB_FILE delete_IM_AllRecentContact];
            
            for (ContactModel *model in newArray) {
                if (model.userID != [appDelegateAccessor.moudle.userId integerValue]) {
                    [IM_FMDB_FILE insert_IM_RecentContact:model];
                }
            }
            [IM_FMDB_FILE closeDataBase];

//            if (![_companyType isEqualToString:@"company"]) {
//                weak_self.title = namesStr;
//            } else {
//                weak_self.title = _titleName;
//            }
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getGroupConversationListWithNumber:_messageNumber WithFlag:@"0"];
            };
            [comRequest loginInBackground];
        }
    } failure:^(NSError *error) {
        _pushType = ControllerPushTypeMessageVC;
        NSLog(@"----%@", error);
//        [_hud hide:YES];
    }];
}
- (void)dataSourceInfo:(NSArray *)array usersArray:(NSArray *)userArray {
    [_contactsArray removeAllObjects];
    [_showListDataArray removeAllObjects];
//    [_dataSource removeAllObjects];
    [_contactsArray addObjectsFromArray:userArray];
    
//    [dict setObject:infoSring forKey:@"message"];
//    [dict setObject:@(msgState) forKey:@"messageState"];
    for (NSDictionary *messageDic in array) {
        NSDictionary *dict = [NSDictionary dictionaryWithDictionary:[CommonFuntion dictionaryWithJsonString:[messageDic objectForKey:@"message"]]];
        
        if (isRemove) {
            [self.oldMessageArray addObject:dict];
        } else {
            [self.oldMessageArray insertObject:dict atIndex:0];
        }
        ChatMessage *model = [ChatMessage initWithDictionary:dict withNSArray:_contactsArray];
        model.msg_state = [[messageDic objectForKey:@"messageState"] integerValue];
        if ([model.msg_content stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0 || model.hasResourceView) {
            if (isRemove) {
                [_dataSource addObject:model];
                if (model.hasResourceView && model.msg_type == ChatMessageTypeImage) {
                    [_allImagesArray addObject:model.msg_imageUrl];
                }
            } else {
                [_dataSource insertObject:model atIndex:0];
                if (model.hasResourceView && model.msg_type == ChatMessageTypeImage) {
                    [_allImagesArray insertObject:model.msg_imageUrl atIndex:0];
                }
            }
        }
        
    }
//    if (_dataSource.count > 30 ) {
//        [_showListDataArray addObjectsFromArray:[_dataSource subarrayWithRange:NSMakeRange(_dataSource.count - 30, 30)]];
//    } else {
        [_showListDataArray addObjectsFromArray:_dataSource];
//    }
}
#pragma mark - 跳转联系人详情、播放声音
- (void)pushIntoInfoControllerView:(NSString *)userId {
    InfoViewController *controller = [[InfoViewController alloc] init];
    controller.title = @"个人信息";
    if ([appDelegateAccessor.moudle.userId isEqualToString:userId]) {
        controller.infoTypeOfUser = InfoTypeMyself;
    }else{
        controller.infoTypeOfUser = InfoTypeOthers;
        controller.userId = [userId integerValue];
    }
    [self.navigationController pushViewController:controller animated:YES];
}
- (void)playVoiceWithChatMessage:(ChatMessage *)chatMsg withIndexPath:(NSIndexPath *)index{
    
    if (chatMsg.msg_type != ChatMessageTypeVoice) {
        return;
    }
    if ([chatMsg.msg_voiceUrl isEqualToString:@""]) {
        return;
    }
    ChatTableViewCell *cell = (ChatTableViewCell *)[self.tableView cellForRowAtIndexPath:index];
    NSString *imgSting = @"";
    if (chatMsg.isMe) {
        imgSting = @"mine";
    } else {
        imgSting = @"other";
    }
    if (_playback) {
        
        [_playback pause];
        _playback = nil;
        
        if (_cell != nil) {
            _cell.voiceIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"voice_sign_%@_3.png", imgSting]];
        }else{
            _cell = cell;
        }
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        AFSoundItem *item = [[AFSoundItem alloc] initWithStreamingURL:[NSURL URLWithString:chatMsg.msg_voiceUrl]];

        _playback = [[AFSoundPlayback alloc] initWithItem:item];
        [_playback play];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_playback listenFeedbackUpdatesWithBlock:^(AFSoundItem *item) {
                NSLog(@"Item duration: %ld - time elapsed: %ld", (long)item.duration, (long)item.timePlayed);
                NSString *imgName = @"";
                NSInteger durationing = item.timePlayed;
                switch (durationing%3) {
                    case 0:
                    {
                        imgName = [NSString stringWithFormat:@"voice_sign_%@_1.png", imgSting];
                    }
                        break;
                    case 1:
                    {
                        imgName = [NSString stringWithFormat:@"voice_sign_%@_2.png", imgSting];
                    }
                        break;
                    case 2:
                    {
                        imgName = [NSString stringWithFormat:@"voice_sign_%@_3.png", imgSting];
                    }
                        break;
                        
                    default:
                    {
                        imgName = [NSString stringWithFormat:@"voice_sign_%@_3.png", imgSting];
                    }
                        break;
                }
                cell.voiceIcon.image = [UIImage imageNamed:imgName];
                
            } andFinishedBlock:^(void){
                NSLog(@"andFinishedBlock");
                cell.voiceIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"voice_sign_%@_3.png", imgSting]];
                
            }];
        });
        
    });
    
}
//生成唯一标识 当前时间（毫秒）+4位随机数
- (NSString *)getUUIDString {
    NSTimeInterval second = [[NSDate date] timeIntervalSince1970] * 1000;
    long long time = second;
    NSInteger acrCount = [self getRandomNumber:1000 to:9999];
    NSString *stingTime = [NSString stringWithFormat:@"%lld%ld", time, acrCount];
//    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
//    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
//    CFRelease(uuidRef);
//    NSString *uniqueId = (__bridge NSString *)uuidStringRef;
    return stingTime;
}
-(NSInteger)getRandomNumber:(NSInteger)from to:(NSInteger)to

{
    return (int)(from + (arc4random() % (to - from + 1)));
    
}
- (void)showActionSheetReSendOneMessge {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"重新发送", nil];
    sheet.tag = 500;
    [sheet showInView:self.view];
}
- (void)sendOneMessageOfFail {
    NSInteger oldIndex;
    
    if ([_dataSource containsObject:_showListDataArray[selectIndex]]) {
        oldIndex = [_dataSource indexOfObject:_showListDataArray[selectIndex]];
        [_dataSource removeObjectAtIndex:oldIndex];
    }
    
    [_showListDataArray removeObjectAtIndex:selectIndex];

    NSTimeInterval second = [[NSDate date] timeIntervalSince1970] * 1000;
    long long time = second;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:_oldMessageArray[oldIndex]];
    [dict setObject:@(time) forKey:@"time"];
    //先删除旧消息
    NSString *uuidStr = [dict safeObjectForKey:@"id"];
    [IM_FMDB_FILE delete_IM_MessageListGroupID:_groupID withMessageId:uuidStr];
    
    [_oldMessageArray removeObjectAtIndex:oldIndex];
    
    [_oldMessageArray addObject:dict];
    
    ChatMessage *msgModel = [ChatMessage initWithDictionary:dict withNSArray:_contactsArray];
    msgModel.msg_state = MessageStateSend;
    [_dataSource addObject:msgModel];
    [_showListDataArray addObject:msgModel];
    [_tableView reloadData];
    //这里分情况了。
    //1.图片
    //①发送成功的图片已经上传到服务器的
    //②没有上传成功的
    //2.语音
    //①发送成功的图片已经上传到服务器的
    //②没有上传成功的
    //3.文本类   直接重新发送
    __weak typeof(self) weak_self = self;
    if (msgModel.hasResourceView) {
        NSDictionary *resourceDict = [CommonFuntion dictionaryWithJsonString:[dict objectForKey:@"resource"]];
        switch (msgModel.msg_type) {
            case ChatMessageTypeImage:
            {
                //不为空，则说明已经上传成功。否则需要重新上传
                if ([CommonFuntion checkNullForValue:[resourceDict objectForKey:@"fileName"]]) {
                    
                } else {
                    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
                    
                    [assetslibrary assetForURL:[NSURL URLWithString:msgModel.msg_imageName] resultBlock:^(ALAsset *asset) {
 
                        ALAssetRepresentation *assetRep = [asset defaultRepresentation];
                        CGImageRef imgRef = [assetRep fullScreenImage];
                        UIImage *image = [[UIImage alloc]initWithCGImage:imgRef];
                        
                        
                        /*
                        UIImage *image = [UIImage imageWithCGImage:imgRef
                                                             scale:assetRep.scale
                                                       orientation:(UIImageOrientation)assetRep.orientation];
                        
                        image = [self fixOrientation:image];
                         */
                        NSData *imgData = UIImageJPEGRepresentation(image, 1.0);
                        if ((float)imgData.length/1024 > 1000) {
                            imgData = UIImageJPEGRepresentation(image, 1024*1000.0/(float)imgData.length);
                        }
                        [weak_self sendImageOrVoiceResourceToServerWithImage:imgData WithType:msgModel.msg_type WithMessageDict:dict WithMessageModel:msgModel];
                    } failureBlock:^(NSError *error) {
                        
                    }];
                    return;
                }
            }
                
                break;
            case ChatMessageTypeVoice:
            {
                //不为空，则说明已经上传成功，直接重新发送消息。否则需要重新上传
                if ([CommonFuntion checkNullForValue:[resourceDict objectForKey:@"fileName"]]) {
                    
                } else {
                    NSString *fileDirPath = [CommonFunc getDocumentsPathByDirName:@"AudioDownload"];
                    NSString *filePath = [NSString stringWithFormat:@"%@/%@",fileDirPath,msgModel.msg_voiceName];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                        NSData *voiceData = [NSData dataWithContentsOfFile:filePath];
                         [weak_self sendImageOrVoiceResourceToServerWithImage:voiceData WithType:msgModel.msg_type WithMessageDict:dict WithMessageModel:msgModel];
                        return;
                    }
                }
            }
                break;
                
            default:
                break;
        }
    }
    NSDictionary *newMessageDict = @{@"id" : appDelegateAccessor.moudle.userId,
                          @"head" : @"message",
                          @"to" : _groupID,
                          @"content" : [dict objectForKey:@"content"],
                          @"type" : @"1",
                          @"resource" : [dict objectForKey:@"resource"],
                          @"time" : @(time),
                          @"uuid": uuidStr};
    MySBJsonWriter *jsonParser = [[MySBJsonWriter alloc]init];
    NSString *messageStr =[jsonParser stringWithObject:newMessageDict];
    
    NSString *newMessageStr = [jsonParser stringWithObject:dict];
    [self deleteFirstMessage];
    //预插入数据：本地显示（未成功状态）
    [IM_FMDB_FILE insert_IM_MessageListGroupID:_groupID withMessageId:uuidStr withInfo:newMessageStr withMessageState:MessageStateSend];
    [IM_FMDB_FILE closeDataBase];
    [_uuidArray addObject:[dict objectForKey:@"id"]];
    
    if (appDelegateAccessor.webSocket.readyState == SR_OPEN) {
        [appDelegateAccessor.webSocket send:messageStr];
    } else {
        [appDelegateAccessor removeTimer];
        [appDelegateAccessor removeHeartTimer];
        [appDelegateAccessor deleteWebSocket];
        [appDelegateAccessor _reconnect];
    }
    [self performSelector:@selector(dismissActionView:) withObject:(id)msgModel afterDelay:60];
}
//需要文件资源 消息体
- (void)sendImageOrVoiceResourceToServerWithImage:(NSData *)resourceData WithType:(ChatMessageType)messageType WithMessageDict:(NSMutableDictionary *)messageDict WithMessageModel:(ChatMessage *)msgModel {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:appDelegateAccessor.moudle.userId forKey:@"id"];
    [params setObject:appDelegateAccessor.moudle.userCompanyId forKey:@"companyId"];
    [params setObject:appDelegateAccessor.moudle.IM_tokenString forKey:@"token"];
    NSString *type = @"";
    NSString *fileName = @"";
    NSDictionary *resourceDict = [CommonFuntion dictionaryWithJsonString:[messageDict objectForKey:@"resource"]];
    if (messageType == ChatMessageTypeImage) {
        type = @"image/jpeg";
        fileName = @"files.jpeg";
        [params setObject:@"0" forKey:@"second"];
    } else {
        type = @"video/aac";
        fileName = [NSString stringWithFormat:@"%@", [resourceDict objectForKey:@"name"]];
        [params setObject:[resourceDict objectForKey:@"second"] forKey:@"second"];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_IM, IM_GET_UPLOAD_FILE] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData :resourceData name:@"file" fileName:fileName mimeType:type];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject && [[responseObject objectForKey:@"status"] integerValue] == 0) {
            if ([CommonFuntion checkNullForValue:[responseObject objectForKey:@"body"]]) {
                MySBJsonWriter *jsonParser = [[MySBJsonWriter alloc]init];
                _resourceSting = [responseObject objectForKey:@"body"];
                _resourceSting = [jsonParser stringWithObject:_resourceSting];
                if ([_flag_CreateStr isEqualToString:@"0"]) {
                    [messageDict setValue:_resourceSting forKey:@"resource"];
                    //
                    NSDictionary *newMessageDict = @{@"id" : appDelegateAccessor.moudle.userId,
                                                     @"head" : @"message",
                                                     @"to" : _groupID,
                                                     @"content" : [messageDict objectForKey:@"content"],
                                                     @"type" : @"1",
                                                     @"resource" : _resourceSting,
                                                     @"time" : [messageDict objectForKey:@"time"],
                                                     @"uuid": [messageDict objectForKey:@"id"]};
                    MySBJsonWriter *jsonParser = [[MySBJsonWriter alloc]init];
                    NSString *messageStr =[jsonParser stringWithObject:newMessageDict];
                    //

                    if (appDelegateAccessor.webSocket.readyState == SR_OPEN) {
                        [appDelegateAccessor.webSocket send:messageStr];
                    } else {
                        [appDelegateAccessor removeTimer];
                        [appDelegateAccessor removeHeartTimer];
                        [appDelegateAccessor deleteWebSocket];
                        [appDelegateAccessor _reconnect];
                    }
                    NSString *uuidStr = messageDict[@"id"];
                    [_uuidArray addObject:uuidStr];
                    NSDictionary *newDict = [self changeKeysForDictionary:newMessageDict withType:@"send"];
                    NSInteger index = [self.oldMessageArray indexOfObject:messageDict];
                    [self.oldMessageArray removeObject:messageDict];
                    [self.oldMessageArray insertObject:newDict atIndex:index];

                    NSString *newMessageStr = [jsonParser stringWithObject:newDict];
                    [self deleteFirstMessage];
                    //预插入数据：本地显示（未成功状态）
                    [IM_FMDB_FILE insert_IM_MessageListGroupID:_groupID withMessageId:uuidStr withInfo:newMessageStr withMessageState:MessageStateSend];
                    [IM_FMDB_FILE closeDataBase];
                    
                    ChatMessage *messageModel = [ChatMessage initWithDictionary:newDict withNSArray:_contactsArray];
                    messageModel.msg_state = MessageStateSend;
                    [self performSelector:@selector(dismissActionView:) withObject:(id)messageModel afterDelay:60];
                    [_showListDataArray removeObject:msgModel];
                    [_dataSource removeObject:msgModel];
                    [_showListDataArray insertObject:messageModel atIndex:index];
                    [_dataSource insertObject:messageModel atIndex:index];
                    [_allImagesArray addObject:messageModel.msg_imageUrl];
                    [_tableView reloadData];
                    [self tableViewScrollToBottom];
                    
                } else {
                    [self getCreateGroup:_contactsArray withContent:@""];
                }
            } else {
                _resourceSting = @"";
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        msgModel.msg_state = MessageStateFail;
        [_tableView reloadData];
    }];
}
- (void)insertCacheFileOfDataSource:(NSDictionary *)oldDict {
    if (![CommonFuntion checkNullForValue:[oldDict objectForKey:@"messageViewList"]] || [[oldDict objectForKey:@"messageViewList"] count] == 0) {
        return;
    }
    refreshList_flag = 3;
    MySBJsonWriter *jsonParser = [[MySBJsonWriter alloc]init];
    //存储新获取到的消息
    NSMutableArray *newMessagesList = [NSMutableArray arrayWithCapacity:0];
    
    //读取全部数据
    if (isRemove) {
        NSString *lastMessageId = [IM_FMDB_FILE result_IM_LastMessageId:_groupID];
        //用讨论组列表的最新消息number和会话中最后一条成功的消息number进行比较，如果一样则不请求，如果不一样则请求。
        if ([CommonFuntion checkNullForValue:[oldDict objectForKey:@"messageViewList"]] && [[oldDict objectForKey:@"messageViewList"] count] > 0) {
            NSDictionary *lastMessageDict = [[oldDict objectForKey:@"messageViewList"] lastObject];
            if ([lastMessageId isEqualToString:[lastMessageDict safeObjectForKey:@"number"]]) {
                return;
            }
        }

        [_dataSource removeAllObjects];
        [_oldMessageArray removeAllObjects];
        [_allImagesArray  removeAllObjects];
        //插入全部消息列表
        NSMutableArray *insertMessageArray = [NSMutableArray arrayWithCapacity:0];
        //删除全部消息列表
        NSMutableArray *deleteMessageArray = [NSMutableArray arrayWithCapacity:0];
        
        //插入最后一条成功的消息
        NSMutableArray *insertLastMessageArray = [NSMutableArray arrayWithCapacity:0];
        //删除最后一条成功消息
        NSMutableArray *deleteLastMessageArray = [NSMutableArray arrayWithCapacity:0];
        
        //插入讨论组成员
        NSMutableArray *insertUserArray = [NSMutableArray arrayWithCapacity:0];
        //删除讨论组成员
        NSMutableArray *deleteUserArray = [NSMutableArray arrayWithCapacity:0];
        
        if ([CommonFuntion checkNullForValue:[oldDict objectForKey:@"messageViewList"]]) {
            NSInteger index = 0;
            for (NSDictionary *dict in [oldDict objectForKey:@"messageViewList"]) {
                NSString *messageID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
                if ([_messageID longLongValue] == [messageID longLongValue]) {
                    _isHave = YES;
                    _messageIndex = index;
                } else {
                    _isHave = NO;
                }
                index++;
                NSString *messageStr = [jsonParser stringWithObject:dict];
                NSDictionary *messageDict = @{@"message" : messageStr,
                                              @"messageState" : @(MessageStateRecevied)};
                [newMessagesList addObject:messageDict];
                //删除消息列表
                NSString *sqlStrDelete = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id = '%@'", @"MESSAGELIST", _groupID];
                [deleteMessageArray addObject:sqlStrDelete];
                //插入消息列表
                NSString *sqlStrInsert = [NSString stringWithFormat:@"insert into %@ (id, messageId, message, messageState) values ('%@', '%@', '%@', '%ld')", @"MESSAGELIST", _groupID, messageID, messageStr, MessageStateRecevied];
                [insertMessageArray addObject:sqlStrInsert];

            }
            NSDictionary *lastDcit = [[oldDict objectForKey:@"messageViewList"] lastObject];
            NSString *sqlLastStrDelete = [NSString stringWithFormat:@"DELETE FROM %@ WHERE groupId = '%@'", @"LASTMESSAGELIST", _groupID];
            [deleteLastMessageArray addObject:sqlLastStrDelete];
            NSString *sqlLastStrInsert = [NSString stringWithFormat:@"insert into %@(groupId, messageId) values ('%@', '%@')", @"LASTMESSAGELIST", _groupID, [NSString stringWithFormat:@"%@", [lastDcit objectForKey:@"number"]]];
            [insertLastMessageArray addObject:sqlLastStrInsert];
           
        }
        
        //userIdViewList 层
        if ([CommonFuntion checkNullForValue:[oldDict objectForKey:@"userIdViewList"]]) {
            //删除讨论组成员列表
            NSString *sqlStrDelete = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id = '%@'", @"USERSLIST", _groupID];
            [deleteUserArray addObject:sqlStrDelete];
            
            [_contactsArray removeAllObjects];
            
            NSMutableArray *resultSqlArray = [NSMutableArray arrayWithCapacity:0];
            NSString *sqlId = @"";
            for (NSDictionary *dict in [oldDict objectForKey:@"userIdViewList"]) {
                if ([sqlId isEqualToString:@""]) {
                    sqlId = [NSString stringWithFormat:@"'%ld'", [[dict safeObjectForKey:@"id"] integerValue]];
                } else {
                    sqlId = [NSString stringWithFormat:@"%@,'%ld'", sqlId, [[dict safeObjectForKey:@"id"] integerValue]];
                }
            }
            NSString *sqlResultStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE id in(%@)", @"ADDRESSBOOKLIST",  sqlId];
            [resultSqlArray addObject:sqlResultStr];
            NSArray *resultArray = [IM_FMDB_FILE batch_result_IM:resultSqlArray withType:ResultTypeContacat];
            [_contactsArray addObjectsFromArray:resultArray];
            for (ContactModel *model in  resultArray) {
                //插入讨论组成员列表
                NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(id, name, images, u_id, groupType) values ('%@', '%@', '%@', '%ld', '%@')", @"USERSLIST", _groupID, model.contactName, model.imgHeaderName, model.userID, _groupType];
                [insertUserArray addObject:sqlStr];
            }
        }
        /*
        if ([CommonFuntion checkNullForValue:[dict objectForKey:@"userIdViewList"]]) {
            NSMutableArray *resultSqlArray = [NSMutableArray arrayWithCapacity:0];
            NSArray *array = [dict objectForKey:@"userIdViewList"];
            NSString *sqlId = @"";
            for (NSDictionary *u_dict in array) {
                if ([sqlId isEqualToString:@""]) {
                    sqlId = [NSString stringWithFormat:@"'%ld'", [[u_dict safeObjectForKey:@"id"] integerValue]];
                } else {
                    sqlId = [NSString stringWithFormat:@"%@,'%ld'", sqlId, [[u_dict safeObjectForKey:@"id"] integerValue]];
                }
            }
            NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE id in(%@)", @"ADDRESSBOOKLIST",  sqlId];
            [resultSqlArray addObject:sqlStr];
            NSArray *resultArray = [IM_FMDB_FILE batch_result_IM:resultSqlArray withType:ResultTypeContacat];
            [_usersListArray addObjectsFromArray:resultArray];
            for (ContactModel *model in  resultArray) {
                _u_images = model.imgHeaderName;
                _u_id = [NSString stringWithFormat:@"%ld", model.userID];
                //这里针对单人和群聊的头像做一个筛选
                if ([_b_type isEqualToString:@"1"]) {
                    [_imgsArray addObject:_u_images];
                } else {
                    if (![_u_id isEqualToString:appDelegateAccessor.moudle.userId]) {
                        [_imgsArray addObject:_u_images];
                    }
                }
                if ([_u_id isEqualToString:appDelegateAccessor.moudle.userId]) {
                    _u_name = model.contactName;
                }
            }
        }
         */

        /*
        if ([CommonFuntion checkNullForValue:[oldDict objectForKey:@"userViewList"]]) {
            //删除讨论组成员列表
            NSString *sqlStrDelete = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id = '%@'", @"USERSLIST", _groupID];
            [deleteUserArray addObject:sqlStrDelete];
            
            [_contactsArray removeAllObjects];
            for (NSDictionary *dict in [oldDict objectForKey:@"userViewList"]) {
                ContactModel *model = [ContactModel initWithDataSource:dict];
                [_contactsArray addObject:model];
                //插入讨论组成员列表
                NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(id, name, images, u_id, groupType) values ('%@', '%@', '%@', '%ld', '%@')", @"USERSLIST", _groupID, model.contactName, model.imgHeaderName, model.userID, _groupType];
                [insertUserArray addObject:sqlStr];

            }
        }
        */
        ///批量操作
        [IM_FMDB_FILE batch_option_im:deleteMessageArray];
        [IM_FMDB_FILE batch_option_im:insertMessageArray];
        [IM_FMDB_FILE batch_option_im:deleteUserArray];
        [IM_FMDB_FILE batch_option_im:deleteLastMessageArray];
        [IM_FMDB_FILE batch_option_im:insertLastMessageArray];
        [IM_FMDB_FILE batch_option_im:insertUserArray];
        [IM_FMDB_FILE closeDataBase];
    } else {
        if ([CommonFuntion checkNullForValue:[oldDict objectForKey:@"messageViewList"]]) {
            for (NSDictionary *dict in [oldDict objectForKey:@"messageViewList"]) {
                NSString *messageStr = [jsonParser stringWithObject:dict];
                NSDictionary *messageDict = @{@"message" : messageStr,
                                              @"messageState" : @(MessageStateRecevied)};
                [newMessagesList addObject:messageDict];
                
            }
        }
        newMessagesList = (NSMutableArray *)[[newMessagesList reverseObjectEnumerator] allObjects];
    }
    [self dataSourceInfo:newMessagesList usersArray:[IM_FMDB_FILE result_IM_UserList:_groupID]];
    selectRow = newMessagesList.count;
//    [self dataSourceInfo:newMessagesList usersArray:_contactsArray];
    
}
#pragma mark - 刷新指定行
- (void)reloadDataTableViewRow:(NSInteger)row {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [_tableView reloadData];
//    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark - 下拉加载老消息
- (void)readMoreOldMessages {
    //数据源消息个数 > 列表展示的消息 加载更多老消息
    if (_dataSource && _dataSource.count > _showListDataArray.count) {
        //数据源 - 列表源 > 0
        NSArray *AddArray = [NSArray array];
        
        if (_dataSource.count - _showListDataArray.count >= 30) {
            AddArray = [_dataSource subarrayWithRange:NSMakeRange(_dataSource.count - _showListDataArray.count - 30, 30)];
            selectRow = 30;
        } else if (30 > _dataSource.count - _showListDataArray.count > 0) {
            AddArray = [_dataSource subarrayWithRange:NSMakeRange(0, _dataSource.count - _showListDataArray.count)];
            selectRow =  _dataSource.count - _showListDataArray.count;
        }
        AddArray = (NSMutableArray *)[[AddArray reverseObjectEnumerator] allObjects];
        for (ChatMessage *chatMsg in AddArray) {
            [_showListDataArray insertObject:chatMsg atIndex:0];
        }
    } else {
        
    }
    [self reloadRefeshView];
}

-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer

{
    [self.msgInputView isAndResignFirstResponder];
    _tableView.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height - _msgInputView.frame.size.height);
    [_tableView reloadData];
    
}
- (NSDictionary *)changeKeyAndValueOfOldDcit:(ChatMessage *)model {
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [newDict setObject:model.msg_fileUrl forKey:@"url"];
    [newDict setObject:model.msg_fileName forKey:@"name"];
    [newDict setObject:model.msg_fileSize forKey:@"size"];
    return newDict;
}
//针对拍照上传的图片别的端显示逆时针90°
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
- (UIButton *)messageBtn {
    if (!_messageBtn) {
        _messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _messageBtn.frame = CGRectMake(kScreen_Width - 80, kScreen_Height - 100, 80, 30);
        [_messageBtn addTarget:self action:@selector(readNewMessage) forControlEvents:UIControlEventTouchUpInside];
        _messageBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        _newMessageCount = 1;
        [_messageBtn setTitle:[NSString stringWithFormat:@"%ld条新消息", _newMessageCount] forState:UIControlStateNormal];
        [_messageBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_messageBtn setBackgroundImage:[UIImage imageNamed:@"activity_feed_time_bg"] forState:UIControlStateNormal];
    }
    return _messageBtn;
}
- (void)readNewMessage {
    if (_messageBtn) {
        [_messageBtn removeFromSuperview];
        _messageBtn = nil;
    }
    if (self.showListDataArray.count==0)
        return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.showListDataArray.count-1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
- (void)deleteFirstMessage {
    [IM_FMDB_FILE deleteOneMessage:_groupID value:^(BOOL isDelete, NSString *messageId) {
        if (isDelete) {
            [IM_FMDB_FILE delete_IM_MessageListGroupID:_groupID withMessageId:messageId];
        }
    }];
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
