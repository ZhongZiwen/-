//
//  Message_RootViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "Message_RootViewController.h"
#import "MsgNotificationTableViewCell.h"
#import "MsgChatTableViewCell.h"
#import "MsgRemindViewController.h"
#import "MsgNotificationViewController.h"
#import "ChatViewController.h"
#import "MJRefresh.h"
#import "CommonFuntion.h"
#import "AFNHttp.h"
#import "ConversationListModel.h"
#import "CommonFuntion.h"
#import "IM_FMDB_FILE.h"
#import "SBJson.h"
#import "MySBJsonParser.h"
#import "ChineseToPinyin.h"
#import "pinyin.h"
#import "PinYin4Objc.h"
#import "ChatMessage.h"
#import "MsgRootSearchCell.h"
#import "MsgRootMoreResultsController.h"
#import "MsgRootSearcherController.h"
#import "StartChatViewController.h"

#import "UnReadNumberModle.h"
#import "CommonUnReadNumberUtil.h"
#import "AnnouncementViewController.h"

#define kCellIdentifier_Notification    @"MsgNotificationTableViewCell"
#define kCellIdentifier_Chat            @"MsgChatTableViewCell"

@interface Message_RootViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) NSMutableArray *resultsArray; //存储搜索结果
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;

@property (nonatomic, strong) NSMutableArray *unReadArray;
@property (nonatomic, strong) UIView *searchView;

@property (nonatomic, strong) NSMutableArray *allGroupIds; //所有会话的id
@property (nonatomic, strong) NSMutableArray *hiddeGroupIds; //隐藏的会话id
@property (nonatomic, strong) NSString *flagString;//标记 已有讨论组返回
@property (nonatomic, strong) NSString *flagGroupId;

@property (nonatomic, assign) NSInteger announcementCount; //未读公告数
@property (nonatomic, assign) NSInteger systemNoticeCount; //未读系统通知数

@end

@implementation Message_RootViewController


- (void)viewDidLoad {
    [super viewDidLoad];
//    [self setupRefresh];
    appDelegateAccessor.moudle.isLoadIMView = TRUE;
    [self customSearchView];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    UIView *V = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:V];
    self.tableView.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 64, 0, 0)];
    _dataSourceArray = [NSMutableArray array];
    _allGroupIds = [NSMutableArray arrayWithCapacity:0];
    _hiddeGroupIds = [NSMutableArray arrayWithCapacity:0];
    NSArray *cacheArray = [NSArray arrayWithArray:[IM_FMDB_FILE result_IM_ConversationListWithResultType:@"normal"]];
    if (cacheArray.count > 0) {
        [_dataSourceArray addObjectsFromArray:cacheArray];
        [_tableView reloadData];
        ///统计IM未读消息数
        [self countUnReadMessage];
        for (ConversationListModel *model in cacheArray) {
            [_allGroupIds addObject:model.b_id];
        }
    }

//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
    [self getConversationList];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGroupList:) name:@"refreshGroupList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooseGroup:) name:@"messageListUnread" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewDataSourceOfGroupList) name:@"getNewDataSourceOfGroupList" object:nil];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//        });
//    });
}
- (void)initViewForSearchBar {
    _resultsArray = [NSMutableArray arrayWithCapacity:0];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 30)];
    _searchBar.placeholder = @"搜索";
    _searchBar.backgroundColor = COMM_SEARCHBAR_BACKGROUNDCOLOR;
    _searchBar.delegate = self;
    [_searchBar sizeToFit];
    
    _searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    _searchController.delegate = self;
    _searchController.searchResultsDelegate = self;
    _searchController.searchResultsDataSource = self;
    _searchController.searchResultsTableView.frame = CGRectMake(0, 64, kScreen_Width, kScreen_Height - 64 - 44 - 64);
    _searchController.searchBar.tintColor = LIGHT_BLUE_COLOR;
    _tableView.tableHeaderView = _searchBar;
    _tableView.tableHeaderView.backgroundColor = COMM_SEARCHBAR_BACKGROUNDCOLOR;
    
}
- (void)reGetNewGroup:(NSNotification *)notfication {
    [self getConversationList];
}
- (void)refreshGroupList:(NSNotification *)notfication {
    NSDictionary *dict = [notfication object];
    NSLog(@"refreshGroupList dict:%@",dict);
    if ([[dict objectForKey:@"type"] integerValue] != 1) {
        [self getConversationList];
        
    } else {
        NSString *sendGroupId = [dict safeObjectForKey:@"to"];
        if (![_allGroupIds containsObject:sendGroupId]) {
            [self getConversationList];
            return;
        } else {
            if ([_hiddeGroupIds containsObject:sendGroupId]) {
                [IM_FMDB_FILE update_IM_ConversationListGroupID:[NSString stringWithFormat:@"%@", [dict objectForKey:@"to"]] withShow:@"1"];
                [_hiddeGroupIds removeObject:sendGroupId];
            }
        }
        if (_selectGroupId && [_selectGroupId integerValue] == [[dict objectForKey:@"to"] integerValue]) {
            
        } else {
            [IM_FMDB_FILE update_IM_ConversationListGroupWithInfo:[self changeNotficationToMessageDic:dict]];
            if ([[dict objectForKey:@"to"] longLongValue] == [_flagGroupId longLongValue]) {
                
            } else {
                //如果是自己发送的消息，则不+1
                if ([[dict objectForKey:@"id"] longLongValue] != [appDelegateAccessor.moudle.userId longLongValue]) {
                    NSInteger unReadCount = [IM_FMDB_FILE result_IM_One_ConversationUnReadnumber:[NSString stringWithFormat:@"%@", [dict objectForKey:@"to"]]];
                    unReadCount = unReadCount + 1;
                    [IM_FMDB_FILE update_IM_ConversationListGroupID:[NSString stringWithFormat:@"%@", [dict objectForKey:@"to"]] withReadNumber:@"" withUnReadNumber:[NSString stringWithFormat:@"%ld", unReadCount]];
                } 
            }
            
        }
    }
    NSArray *modelArr = [[IM_FMDB_FILE result_IM_ConversationListWithResultType:@"normal"] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ConversationListModel *model1 = (ConversationListModel *)obj1;
        ConversationListModel *model2 = (ConversationListModel *)obj2;
        return [model2.m_lastMessageTime compare:model1.m_lastMessageTime];
    }];
    [_dataSourceArray removeAllObjects];
    [_dataSourceArray addObjectsFromArray:modelArr];
    [_tableView reloadData];
    
    ///统计IM未读消息数
    [self countUnReadMessage];
}
- (void)getNewDataSourceOfGroupList {
    //这样做是为了在手动退出讨论组的时候及时刷新数据源
    [_dataSourceArray removeAllObjects];
    [_dataSourceArray addObjectsFromArray:[IM_FMDB_FILE result_IM_ConversationListWithResultType:@"normal"]];
    
    NSArray *modelArr = [_dataSourceArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ConversationListModel *model1 = (ConversationListModel *)obj1;
        ConversationListModel *model2 = (ConversationListModel *)obj2;
        return [model2.m_lastMessageTime compare:model1.m_lastMessageTime];
    }];
    [_dataSourceArray removeAllObjects];
    [_dataSourceArray addObjectsFromArray:modelArr];
    [_tableView reloadData];
}
- (NSDictionary *)changeNotficationToMessageDic:(NSDictionary *)dict {
    NSMutableDictionary *messagedict = [NSMutableDictionary dictionary];
    [messagedict setObject:[dict objectForKey:@"content"] forKey:@"content"];
    [messagedict setObject:[NSString stringWithFormat:@"%@", [dict objectForKey:@"number"]] forKey:@"number"];
    [messagedict setObject:[NSString stringWithFormat:@"%@", [dict objectForKey:@"type"]] forKey:@"type"];
    [messagedict setObject:[NSString stringWithFormat:@"%@", [dict objectForKey:@"to"]] forKey:@"id"];
    [messagedict setObject:[NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]] forKey:@"userId"];
    NSString *timeStr = @"";
    long long dateTime = 0;
    if (dict && [dict objectForKey:@"time"]) {
        timeStr = [CommonFuntion getStringForTime:[[dict safeObjectForKey:@"time"] longLongValue]];
        dateTime = [[dict safeObjectForKey:@"time"] longLongValue];
    }
    [messagedict setObject:@(dateTime) forKey:@"time"];
    [messagedict setObject:timeStr forKey:@"sendTime"];
    
    if ([[dict allKeys] containsObject:@"resource"] && [CommonFuntion checkNullForValue:[dict objectForKey:@"resource"]]) {
        NSDictionary *resourceDic =  [CommonFuntion dictionaryWithJsonString:[dict objectForKey:@"resource"]];
        [messagedict setObject:@"1" forKey:@"isHave"];
        [messagedict setObject:[NSString stringWithFormat:@"%@", [resourceDic objectForKey:@"type"]] forKey:@"r_type"];
    } else if ([[dict allKeys] containsObject:@"resourceView"] && [CommonFuntion checkNullForValue:[dict objectForKey:@"resourceView"]]) {
        NSDictionary *resourceDic = [dict objectForKey:@"resourceView"];
        [messagedict setObject:@"1" forKey:@"isHave"];
        [messagedict setObject:[NSString stringWithFormat:@"%@", [resourceDic objectForKey:@"type"]] forKey:@"r_type"];
    } else {
        [messagedict setObject:@"0" forKey:@"isHave"];
        [messagedict setObject:@"" forKey:@"r_type"];
    }
    return messagedict;
}
- (void)chooseGroup:(NSNotification *)notfication {
    NSDictionary *dict = (NSDictionary *)[notfication object];
    
    _flagString = @"chooseView";
    _flagGroupId = [dict objectForKey:@"groupId"];

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addNotification];
    
    NSArray *modelArr = [_dataSourceArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ConversationListModel *model1 = (ConversationListModel *)obj1;
        ConversationListModel *model2 = (ConversationListModel *)obj2;
        return [model2.m_lastMessageTime compare:model1.m_lastMessageTime];
    }];
    [_dataSourceArray removeAllObjects];
    [_dataSourceArray addObjectsFromArray:modelArr];
    [_tableView reloadData];
    ///统计IM未读消息数
    [self countUnReadMessage];
    
    if ([_flagString isEqualToString:@"chooseView"]) {
        [IM_FMDB_FILE update_IM_ConversationListGroupID:_flagGroupId withReadNumber:@"" withUnReadNumber:@"0"];
        _flagGroupId = @"";
        _flagString = @"";
        [self getConversationList];
    }
    _selectGroupId = @"";
    [self getUnReadMsgNumber];
    if (![self isToday:[self getNewDayTime]]) {
        [self getConversationList];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeNotification];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    NSArray *array = [IM_FMDB_FILE result_IM_ConversationListWithResultType:@"normal"];
//    if (array && array.count > 0) {
//        NSArray *modelArr = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//            ConversationListModel *model1 = (ConversationListModel *)obj1;
//            ConversationListModel *model2 = (ConversationListModel *)obj2;
//            return [model2.m_lastMessageTime compare:model1.m_lastMessageTime];
//        }];
//        [_dataSourceArray removeAllObjects];
//        [_dataSourceArray addObjectsFromArray:modelArr];
//        [_tableView reloadData];
//        for (ConversationListModel *conModel in _dataSourceArray) {
//            [_allGroupIds addObject:conModel.b_id];
//        }
//    }
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
#pragma mark - add and delete Notification
///注册通知
-(void)addNotification {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooseGroup:) name:@"messageListUnread" object:nil];
    
    //网络异常  网络断开，重新连接成功之后，进行请求，获取离线消息。
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reGetNewGroup:) name:@"ReGetNewGroup" object:nil];

}
///移除通知
-(void)removeNotification{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshGroupList" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"messageListUnread" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ReGetNewGroup" object:nil];
}

#pragma mark - 接口调用
//获取会话列表
- (void)getConversationList {
    __weak typeof(self) weak_self = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:appDelegateAccessor.moudle.userId forKey:@"userId"];
    NSArray *groupList = [IM_FMDB_FILE result_IM_ConversationListWithResultType:@"result"];
    NSMutableArray *allGroupList = [NSMutableArray arrayWithCapacity:0];
    if (groupList && groupList.count > 0) {
        for (ConversationListModel *conModel in _dataSourceArray) {
            //将隐藏的讨论组或者会话id 添加进去。
            if (![_allGroupIds containsObject:conModel.b_id]) {
                [_allGroupIds addObject:conModel.b_id];
                [_hiddeGroupIds addObject:conModel.b_id];
            }
            NSDictionary *dict = @{@"id" : conModel.b_id,
                                   @"versionCode" : @(conModel.b_versionCode)
                                   };
            [allGroupList addObject:dict];
        }
        MySBJsonWriter *jsonParser = [[MySBJsonWriter alloc]init];
        NSString *message =[jsonParser stringWithObject:allGroupList];
        [params setObject:message forKey:@"appGroupList"];
    } else {
        [params setObject:@"" forKey:@"appGroupList"];
    }
    [params setObject:appDelegateAccessor.moudle.IM_tokenString forKey:@"token"];
    
    
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_IM, IM_GET_CONVERSATION_LIST] params:params success:^(id responseObj) {
        NSLog(@"--会话列表--%@", responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
            if ([CommonFuntion checkNullForValue:[responseObj objectForKey:@"body"]]) {
                [array addObjectsFromArray:[responseObj objectForKey:@"body"]];
                [weak_self dataSourceInfo:array];
            } else {
                [weak_self dataSourceInfo:array];
            }
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getConversationList];
            };
            [comRequest loginInBackground];
        }
        
        //        [weak_self reloadRefeshView];
    } failure:^(NSError *error) {
        NSLog(@"----%@", error);
    //                [weak_self reloadRefeshView];
        
    }];

}

- (void)deleteOneGroup:(ConversationListModel *)model {
//    if ([model.b_type isEqualToString:@"0"]) {
    [IM_FMDB_FILE update_IM_ConversationListGroupID:model.b_id withShow:@"0"];
    if (![_hiddeGroupIds containsObject:model.b_id]) {
        [_hiddeGroupIds addObject:model.b_id];
    }
//    [IM_FMDB_FILE delete_IM_OneConversationList:model.b_id];
    [IM_FMDB_FILE delete_IM_OneGroupMessageList:model.b_id];
    [_dataSourceArray removeAllObjects];
    [_dataSourceArray addObjectsFromArray:[IM_FMDB_FILE result_IM_ConversationListWithResultType:@"normal"]];
    
    NSArray *modelArr = [_dataSourceArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ConversationListModel *model1 = (ConversationListModel *)obj1;
        ConversationListModel *model2 = (ConversationListModel *)obj2;
        return [model2.m_lastMessageTime compare:model1.m_lastMessageTime];
    }];
    [_dataSourceArray removeAllObjects];
    [_dataSourceArray addObjectsFromArray:modelArr];
    [_tableView reloadData];
}
- (void)dataSourceInfo:(NSArray *)array {
    [_dataSourceArray  removeAllObjects];
    
    if (array.count > 0) {
        
        ///删除会话人列表
        NSMutableArray *sqlMutableDeleteHHRList = [NSMutableArray arrayWithCapacity:0];
        ///插入会话人
        NSMutableArray *sqlMutableInsertHHR = [NSMutableArray arrayWithCapacity:0];
        ///删除会话列表
        NSMutableArray *sqlMutableDeleteHHList = [NSMutableArray arrayWithCapacity:0];
        ///插入会话列表
        NSMutableArray *sqlMutableInsertHHList = [NSMutableArray arrayWithCapacity:0];
        ///删除最近联系人
        NSMutableArray *sqlMutableDeleteZJ = [NSMutableArray arrayWithCapacity:0];
        ///插入最近联系人
        NSMutableArray *sqlMutableInsertZJ = [NSMutableArray arrayWithCapacity:0];
        
        
        for (NSDictionary *dict in array) {
            ConversationListModel *model = [[ConversationListModel alloc] initWithDictionary:dict];
            ///删除会话人列表
            NSString *sqlStrDeleteHHR = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id = '%@'", @"USERSLIST", model.b_id];
            [sqlMutableDeleteHHRList addObject:sqlStrDeleteHHR];
            
            ///批量插入会话人
            if (model.usersListArray) {
                for (ContactModel *u_dict in model.usersListArray) {
                    NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(id, name, images, u_id, groupType) values ('%@', '%@', '%@', '%ld', '%@')", @"USERSLIST", model.b_id, u_dict.contactName, u_dict.imgHeaderName, u_dict.userID, model.b_type];
                    [sqlMutableInsertHHR addObject:sqlStr];
                }
            }
            
            ///删除会话列表
            NSString *sqlStrDeleteHH = [NSString stringWithFormat:@"DELETE FROM %@ WHERE groupId = '%@'", @"CONVERSATIONLIST", model.b_id];
            [sqlMutableDeleteHHList addObject:sqlStrDeleteHH];
            
            ///插入会话列表
            NSString *sqlStrInsertHH = [NSString stringWithFormat:@"insert into %@(groupId, show, createDate, msgNumber, name, type, unReadNumber, content, number, time, msgType, userid, isHave, r_type, messageTime) values ('%@', '%d', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%d', '%@', '%@')", @"CONVERSATIONLIST", model.b_id, 1, model.b_createDate, model.b_msgNumber, model.b_name, model.b_type, model.b_unReadNumber, model.m_content, model.m_number, model.m_time, model.m_type, model.m_userId, model.isHave, model.r_type, model.m_lastMessageTime];
            
            //存在则插入到数据库， 不存在则不插入
            if (![[dict objectForKey:@"isHave"] boolValue]) {
                [sqlMutableInsertHHList addObject:sqlStrInsertHH];
                //            NSLog(@"-----存在%@-----", [dict objectForKey:@"isHave"]);
            } else {
                //            NSLog(@"-----不存在%@-----", [dict objectForKey:@"isHave"]);
            }
            
            ///讨论组
            if ([model.b_type isEqualToString:@"1"]) {
                ///删除最近联系人
                NSString *sqlStrDeleteZJ = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id = '%@'", @"SHOWCONTACTNAMELIST", model.b_id];
                [sqlMutableDeleteZJ addObject:sqlStrDeleteZJ];
                ///插入最近联系人
                NSString *sqlStrInsertZJ = [NSString stringWithFormat:@"insert into %@(id, show) values ('%@', '%@')", @"SHOWCONTACTNAMELIST", model.b_id, @"1"];
                [sqlMutableInsertZJ addObject:sqlStrInsertZJ];
            }
        }
        
        NSMutableArray *allSql = [[NSMutableArray alloc] init];
        [allSql addObject:sqlMutableDeleteHHRList];
        [allSql addObject:sqlMutableInsertHHR];
        [allSql addObject:sqlMutableDeleteHHList];
        [allSql addObject:sqlMutableInsertHHList];
        [allSql addObject:sqlMutableDeleteZJ];
        [allSql addObject:sqlMutableInsertZJ];
        
        ///批量操作
        [IM_FMDB_FILE batch_option_im:sqlMutableDeleteHHRList];
        [IM_FMDB_FILE batch_option_im:sqlMutableInsertHHR];
        [IM_FMDB_FILE batch_option_im:sqlMutableDeleteHHList];
        [IM_FMDB_FILE batch_option_im:sqlMutableInsertHHList];
        [IM_FMDB_FILE batch_option_im:sqlMutableDeleteZJ];
        [IM_FMDB_FILE batch_option_im:sqlMutableInsertZJ];
    }
    
    [_dataSourceArray addObjectsFromArray:[IM_FMDB_FILE result_IM_ConversationListWithResultType:@"normal"]];

    NSArray *modelArr = [_dataSourceArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ConversationListModel *model1 = (ConversationListModel *)obj1;
        ConversationListModel *model2 = (ConversationListModel *)obj2;
        return [model2.m_lastMessageTime compare:model1.m_lastMessageTime];
    }];
    [_dataSourceArray removeAllObjects];
    [_dataSourceArray addObjectsFromArray:modelArr];
    [_tableView reloadData];
    ///统计IM未读消息数
    [self countUnReadMessage];
}

#pragma mark - 红点个数 
- (void)getUnReadMsgNumber {
    __weak typeof(self) weak_self = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [AFNHttp get:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, MESSAGE_UNREAD_COUNT] params:params success:^(id responseObj) {
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            _systemNoticeCount = [[responseObj safeObjectForKey:@"systemNoticeCount"] integerValue];
            _announcementCount = [[responseObj safeObjectForKey:@"announcementCount"] integerValue];
            if ( [CommonFuntion checkNullForValue:[responseObj objectForKey:@"unReads"]]) {
                
                UnReadNumberModle *unReadNumberModel = [CommonUnReadNumberUtil unReadNumberModelInstance];
                
                _unReadArray = [NSMutableArray arrayWithCapacity:0];
                NSArray *array = [responseObj objectForKey:@"unReads"];
                for (NSDictionary *dict in array) {
                    if ([[dict objectForKey:@"type"] integerValue] == 1) {
                        [weak_self.unReadArray insertObject:[dict objectForKey:@"count"] atIndex:0];
                        unReadNumberModel.number_remind = [NSString stringWithFormat:@"%@",[dict objectForKey:@"count"]];
                    } else {
                        [weak_self.unReadArray addObject:[dict objectForKey:@"count"]];
                        unReadNumberModel.number_inform = [NSString stringWithFormat:@"%@",[dict objectForKey:@"count"]];
                    }
                }
                [weak_self.unReadArray addObject:@(_announcementCount)];
                [CommonUnReadNumberUtil saveUnReadNumberModelAndChangeBadge:unReadNumberModel];
            }
            ///刷新红点
            [self notifyRedPoint];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getUnReadMsgNumber];
            };
            [comRequest loginInBackground];
        }
        [_tableView reloadData];
        NSLog(@"请求成功----%@", responseObj);
    } failure:^(NSError *error) {
        NSLog(@"请求异常----%@", error);
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"发起聊天" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonPress)];
    self.navigationItem.rightBarButtonItem = rightButton;
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = _searchBar;
        _tableView.showsHorizontalScrollIndicator = YES;
        _tableView.showsVerticalScrollIndicator = YES;
        [_tableView registerClass:[MsgNotificationTableViewCell class] forCellReuseIdentifier:kCellIdentifier_Notification];
        [_tableView registerClass:[MsgChatTableViewCell class] forCellReuseIdentifier:kCellIdentifier_Chat];
        _tableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
        [self.view addSubview:_tableView];
    }
}

// 发起聊天
- (void)rightButtonPress {
    StartChatViewController *controller = [StartChatViewController new];
    controller.hidesBottomBarWhenPushed = YES;
    controller.title = @"发起聊天";
    controller.flag_controller = ControllerPopTypeInto;
    [self.navigationController pushViewController:controller animated:YES];
}

#define mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _searchController.searchResultsTableView) {
        return _resultsArray.count;
    }
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _searchController.searchResultsTableView) {
        return [_resultsArray[section][@"results"] count];
    }
    return _dataSourceArray.count + 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _searchController.searchResultsTableView) {
        return [MsgChatTableViewCell cellHeight];
    }
    if (indexPath.row < 3) {
        return [MsgNotificationTableViewCell cellHeight];
    }
    
    return [MsgChatTableViewCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    if (tableView == _searchController.searchResultsTableView) {
        
        if ([_resultsArray[indexPath.section][@"titleName"] isEqualToString:@"讨论组"]) {
            MsgChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Chat];
            if (!cell) {
                cell = [[MsgChatTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellIdentifier_Chat];
                cell.backgroundColor = [UIColor whiteColor];
            }
            ConversationListModel *model = _resultsArray[indexPath.section][@"results"][indexPath.row];
            [cell configWithModel:model];
            return cell;
        }
        MsgRootSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"msgRootSearchCellIdentifier"];
        if (!cell) {
            cell = [[MsgRootSearchCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"msgRootSearchCellIdentifier"];
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MsgRootSearchCell" owner:self options:nil];
            cell = (MsgRootSearchCell *)[array objectAtIndex:0];
            [cell awakeFromNib];
            cell.backgroundColor = [UIColor whiteColor];
        }
        NSDictionary *dict = _resultsArray[indexPath.section][@"results"][indexPath.row];
        [cell configWithDict:[dict objectForKey:@"dataSource"] withIsMore:[dict objectForKey:@"hasMore"]];
        return cell;
        
    }
     */
    if (indexPath.row < 3) {
        MsgNotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Notification forIndexPath:indexPath];
        NSArray *source = @[@{@"image":@"message_icon_remind",
                              @"title":@"待办提醒"},
                            @{@"image":@"message_icon_notice",
                              @"title":@"通知"},
                            @{@"image":@"message_icon_announcement",
                              @"title":@"部门公告"}];
        NSDictionary *dict = source[indexPath.row];
        [cell configImageView:[dict objectForKey:@"image"] andTitleLabel:[dict objectForKey:@"title"] andBadge:[_unReadArray[indexPath.row] integerValue]];
        return cell;
    }
    
    MsgChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Chat forIndexPath:indexPath];
    if (_dataSourceArray && _dataSourceArray.count > 0) {
        ConversationListModel *model = _dataSourceArray[indexPath.row - 3];
        [cell configWithModel:model];
    }
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    /*
    if (tableView == _searchController.searchResultsTableView) {
        return _resultsArray[section][@"titleName"];
    }
     */
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    /*
    if (tableView == _searchController.searchResultsTableView) {
        return 30;
    }
     */
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    /*
    if (tableView == _searchController.searchResultsTableView) {
        return 15;
    }
     */
    return 0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        MsgRemindViewController *remindController = [[MsgRemindViewController alloc] init];
        remindController.title = @"提醒";
        remindController.unReadCount = [_unReadArray[indexPath.row] integerValue];
        remindController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:remindController animated:YES];
        return;
    }
    
    if (indexPath.row == 1) {
        MsgNotificationViewController *notificationController = [[MsgNotificationViewController alloc] init];
        notificationController.title = @"通知";
        notificationController.announcementCount = _announcementCount;
        notificationController.systemNoticeCount = _systemNoticeCount;
        notificationController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:notificationController animated:YES];
        return;
    }
    if (indexPath.row == 2) {
        AnnouncementViewController *controller = [[AnnouncementViewController alloc] init];
        controller.title = @"部门公告";
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    ChatViewController *chatController = [[ChatViewController alloc] init];
    chatController.hidesBottomBarWhenPushed = YES;
    ConversationListModel *model = _dataSourceArray[indexPath.row - 3];
    chatController.titleName = model.b_name;
    chatController.groupID = _selectGroupId = model.b_id;
    chatController.groupType = model.b_type;
    chatController.unReadMessageCount = [model.b_unReadNumber integerValue];
    chatController.pushType = ControllerPushTypeMessageVC;
    chatController.usersArray = model.usersListArray;
    chatController.unSendStr = model.m_content;
    chatController.messageNumber = [model.m_number integerValue];
    chatController.RefreshDataSourceBlock = ^(NSDictionary *dict, NSString *sting) {
        _selectGroupId = @"";
        NSLog(@"------返回的消息体-----%@", dict);
        //插入消息
        if (sting && sting.length > 0 && [sting stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0) {
            [IM_FMDB_FILE update_IM_ConversationListGroupID:model.b_id withUnsendSting:[NSString stringWithFormat:@"[草稿]%@", sting]];
        } else {
            [IM_FMDB_FILE update_IM_ConversationListGroupWithInfo:[self changeNotficationToMessageDic:dict]];
            //修改已读消息number  和 未读消息数
            [IM_FMDB_FILE update_IM_ConversationListGroupID:model.b_id withReadNumber:[NSString stringWithFormat:@"%@", [dict objectForKey:@"number"]] withUnReadNumber:@"0"];
        }
        [IM_FMDB_FILE update_IM_ConversationListGroupID:[NSString stringWithFormat:@"%@", [dict objectForKey:@"to"]] withShow:@"1"];
        [IM_FMDB_FILE closeDataBase];
        [self getConversationList];
    };
    //在跳转之前将该谈论组的未读消息数置为0
    model.b_unReadNumber = @"0";
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    
    //修改已读消息number  和 未读消息数
    [IM_FMDB_FILE update_IM_ConversationListGroupID:model.b_id withReadNumber:model.m_number withUnReadNumber:@"0"];
    [IM_FMDB_FILE closeDataBase];
    
    ///消息数-- b_unReadNumber
    [CommonUnReadNumberUtil unReadNumberDecrease:0 number:[model.b_unReadNumber integerValue]];
    ///刷新红点
    [self notifyRedPoint];
    
    [self.navigationController pushViewController:chatController animated:YES];
    //    }
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
     if (tableView == _searchController.searchResultsTableView) {
     return UITableViewCellEditingStyleNone;
     }
     */
    if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self deleteOneGroup:_dataSourceArray[indexPath.row - 3]];
    
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}
#pragma mark -  上拉加载 下来刷新
//集成刷新控件
- (void)setupRefresh
{
    //上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    // 自动刷新(一进入程序就下拉刷新)
    //    [self.tableviewCampaign headerBeginRefreshing];
}

// 结束加载
-(void)reloadRefeshView{
    // 刷新列表
    [self.tableView reloadData];
    [self.tableView footerEndRefreshing];
    [self.tableView headerEndRefreshing];
}

// 上拉
- (void)footerRereshing
{
    NSLog(@"footerRereshing--上拉-->");
    
    if ([self.tableView isHeaderRefreshing]) {
        [self.tableView footerEndRefreshing];
        return;
    }
    [self getConversationList];
}
- (void)headerRereshing {
    if ([self.tableView isFooterRefreshing]) {
        [self.tableView headerEndRefreshing];
        return;
    }
    [self getConversationList];
}
#pragma mark --自定义搜索
- (void)customSearchView {
    _searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
    _searchView.backgroundColor = COMM_SEARCHBAR_BACKGROUNDCOLOR;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10, 5, self.searchView.frame.size.width - 20, self.searchView.frame.size.height - 10);
    button.backgroundColor = [UIColor whiteColor];
    button.layer.cornerRadius = 5;
    [button addTarget:self action:@selector(gotoSearchController) forControlEvents:UIControlEventTouchUpInside];
    
    NSInteger vX = kScreen_Width / 2 - 27;
    UIImageView *imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(vX, 10, 22, 22)];
    imgIcon.image = [UIImage imageNamed:@"img_search_icon.png"];
    
    UILabel *labelTag = [[UILabel alloc] initWithFrame:CGRectMake(vX + 27, 5, 120, 30)];
    labelTag.font = [UIFont systemFontOfSize:14.0];
    labelTag.textColor = [UIColor grayColor];
    labelTag.text = @"搜索";
    
    [self.searchView addSubview:button];
    [self.searchView addSubview:imgIcon];
    [self.searchView addSubview:labelTag];
    _tableView.tableHeaderView = _searchView;
}
- (void)gotoSearchController {
    MsgRootSearcherController *controller = [[MsgRootSearcherController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.dataSourceArray = _dataSourceArray;
    controller.BlackOneGroupIdBlock = ^(NSString *groupId) {
        _selectGroupId = groupId;
    };
    [self.navigationController pushViewController:controller animated:NO];
}

#pragma 隔天刷新一次
- (NSString *)getNewDayTime {
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *nowTime = [dateFormatter stringFromDate:currentDate];
    NSLog(@"%@", nowTime);
    return nowTime;
}
- (BOOL)isToday:(NSString *)nowTime {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![[userDefaults objectForKey:@"dayTime"] isEqualToString:nowTime]) {
        [userDefaults setObject:nowTime forKey:@"dayTime"];
        [userDefaults synchronize];//立即同步
        return NO;
    }
    return YES;
}


#pragma mark - mesage 未读消息数统计
-(void)countUnReadMessage{
    NSInteger countData = 0;
    NSInteger countUnRead = 0;
    if (_dataSourceArray) {
        countData = [_dataSourceArray count];
    }
     ConversationListModel *model;
    for (int i= 0; i<countData; i++) {
        model = _dataSourceArray[i];
        countUnRead += [model.b_unReadNumber integerValue];
    }
    
    UnReadNumberModle *unReadNumberModel = [CommonUnReadNumberUtil unReadNumberModelInstance];
    unReadNumberModel.number_message = [NSString stringWithFormat:@"%ti",countUnRead];
    [CommonUnReadNumberUtil saveUnReadNumberModelAndChangeBadge:unReadNumberModel];
    
    NSLog(@"countUnReadMessage countUnRead:%ti",countUnRead);
}

///刷新红点
-(void)notifyRedPoint{
    UnReadNumberModle *model = [CommonUnReadNumberUtil unReadNumberModelInstance];
    ///未读消息总数
    NSInteger unReadNum = [model.number_remind integerValue] + [model.number_inform integerValue] + [model.number_message integerValue] + [model.number_announcement integerValue];
    
    if (unReadNum > 0) {
        appDelegateAccessor.moudle.icon_unread_im.hidden = NO;
    }else{
        appDelegateAccessor.moudle.icon_unread_im.hidden = YES;
    }
}

@end
