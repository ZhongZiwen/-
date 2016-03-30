//
//  MsgRootSearcherController.m
//  shangketong
//
//  Created by 蒋 on 15/12/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MsgRootSearcherController.h"
#import "SearchTextCell.h"
#import "CommonConstant.h"
#import "CommonNoDataView.h"
#import "CommonFuntion.h"
#import "ChineseToPinyin.h"
#import "pinyin.h"
#import "PinYin4Objc.h"
#import "ChatMessage.h"
#import "MsgRootSearchCell.h"
#import "MsgRootMoreResultsController.h"
#import "MsgRootSearcherController.h"
#import "ConversationListModel.h"
#import "IM_FMDB_FILE.h"
#import "MsgChatTableViewCell.h"
#import "ChatViewController.h"
#import "MsgSearchGuideView.h"
#import "companyGroupCell.h"
#import "CompanyGroupModel.h"

@interface MsgRootSearcherController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITextFieldDelegate>{
    ///当编辑框不为空时显示
    BOOL isShowHeadSearch;
    NSArray *allcontactArray;//所有通讯录成员
    NSArray *allGroupArray; //所有讨论组
    NSArray *allMessageArray; //所有讨论组的聊天记录
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSString *serachBarText;
@property (nonatomic, strong) NSMutableArray *searchHistoryArr; //搜索历史
//@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property (nonatomic, strong) NSMutableArray *resultsArray; //存储搜索结果
@property (nonatomic, strong) MsgSearchGuideView *guideView;
@end

@implementation MsgRootSearcherController

- (void)viewDidLoad {
    [super viewDidLoad];
    isShowHeadSearch = FALSE;
    [self initSearchBarView];
    [self initTableview];
    _searchHistoryArr = [[NSMutableArray alloc] init];
    [self notifyHistoryView];
    _resultsArray = [NSMutableArray arrayWithCapacity:0];
    allcontactArray = [NSArray arrayWithArray:[IM_FMDB_FILE result_IM_AllContactAddressBook]];
    allGroupArray =  [IM_FMDB_FILE result_IM_ConversationListWithResultType:@"normal"];
    
    NSArray *messageListArray = [IM_FMDB_FILE result_IM_AllGroup_MessageList];
    //获取到全部聊天记录
    [allGroupArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        ConversationListModel *model  = (ConversationListModel *)obj;
        NSLog(@"---%@-----", model.b_id);
        [messageListArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSDictionary *messageDict  = (NSDictionary *)obj;
            NSLog(@"---%@-----", messageDict[@"groupId"]);
            
        }];
        
    }];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)notifyHistoryView{
    [self clearViewNoData];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
    [self setViewNoData:0 withString:@""];
}
#pragma mark - 没有数据时的view
-(void)setViewNoData:(NSInteger)type withString:(NSString *)searchString {
    NSString *msg = @"";
    if (type == 0) {
        msg = @"您可以搜到通讯录、相关聊天记录以及讨论组";
    }else if (type == 1){
        msg = [NSString stringWithFormat:@"没有找到“%@”相关搜索", searchString];
    }
    if (self.guideView == nil) {
        self.guideView = [[MsgSearchGuideView alloc] initWithFrame:CGRectMake(0, (kScreen_Height-140)/2-80, kScreen_Width, 140)];
        if (type == 0) {
            self.guideView.imgName = @"search_empty_privatemsg";
            self.guideView.imgNameOne = @"";
            self.guideView.imgNameTwo = @"";
            self.guideView.imgNameThree = @"";
            self.guideView.imgNameFour = @"";
        }
        self.guideView.labelTitle = msg;
        self.guideView.btnTitle = @"";
    }
    [self.tableView addSubview:self.guideView];
}

-(void)clearViewNoData{
    if (self.guideView) {
        [self.guideView removeFromSuperview];
        [self.tableView layoutIfNeeded];
    }
}
#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.sectionFooterHeight = 0;
    self.tableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    
    [self.view addSubview:self.tableView];
}
#pragma mark - 初始化searchbar
-(void)initSearchBarView{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 64)];
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(5, 25, kScreen_Width - 50, 30)];
//    topView.backgroundColor = [UIColor colorWithRed:200.0f/255 green:200.0f/255 blue:200.0f/255 alpha:1.0f];
    topView.backgroundColor = COMM_SEARCHBAR_BACKGROUNDCOLOR;
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索";
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchBar.keyboardType = UIKeyboardTypeNamePhonePad;
    _searchBar.contentMode = UIViewContentModeLeft;
    [topView addSubview:_searchBar];
    
    for (UIView *view in _searchBar.subviews) {
        // for later iOS7.0(include)
        if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
            [[view.subviews objectAtIndex:0] removeFromSuperview];
            break;
        }
    }
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(kScreen_Width - 50, 20, 50, 40);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [cancelBtn setTitleColor:LIGHT_BLUE_COLOR forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:cancelBtn];
    
    [self.view addSubview:topView];
}
#pragma mark -- Button Action
//取消事件
-(void)cancelBtnAction{
    [self.navigationController popViewControllerAnimated:NO];
}
#pragma mark -- tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_resultsArray && _resultsArray.count > 0) {
        return [_resultsArray count];
    }
    return 0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_resultsArray != nil && [_resultsArray count] > 0) {
        return [_resultsArray[section][@"results"] count];
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_resultsArray[indexPath.section][@"titleName"] isEqualToString:@"联系人"]) {
        
        companyGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"companyGroupCellIdentifier"];
        if (!cell) {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"companyGroupCell" owner:self options:nil];
            cell = (companyGroupCell *)[array objectAtIndex:0];
            [cell awakeFromNib];
            [cell setFrameAllPhone];
        }
        ContactModel *contactModel = _resultsArray[indexPath.section][@"results"][indexPath.row];
        CompanyGroupModel *model = [[CompanyGroupModel alloc] init];
        model.group_name = contactModel.contactName;
        model.group_images = contactModel.imgHeaderName;
        [cell configWithModel:model];
        return cell;
    }
    
    if ([_resultsArray[indexPath.section][@"titleName"] isEqualToString:@"讨论组"]) {
        MsgChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MsgChatTableViewCell"];
        if (!cell) {
            cell = [[MsgChatTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MsgChatTableViewCell"];
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_resultsArray && _resultsArray.count > 0) {
        return _resultsArray[section][@"titleName"];
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (isShowHeadSearch) {
        return 30;
    }
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (_resultsArray && _resultsArray.count > 0) {
        return 15;
    }
    return 0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([_resultsArray[indexPath.section][@"titleName"] isEqualToString:@"联系人"]) {
        NSMutableArray *contactArray = [NSMutableArray arrayWithCapacity:0];
        [contactArray addObject:_resultsArray[indexPath.section][@"results"][indexPath.row]];
        ChatViewController *controller = [[ChatViewController alloc] init];
        controller.usersArray = contactArray;
        controller.pushType = ControllerPushTypeStartChatVC;
        [self.navigationController pushViewController:controller animated:YES];
    } else if ([_resultsArray[indexPath.section][@"titleName"] isEqualToString:@"讨论组"]) {
        ChatViewController *chatController = [[ChatViewController alloc] init];
        chatController.hidesBottomBarWhenPushed = YES;
        ConversationListModel *model = _resultsArray[indexPath.section][@"results"][indexPath.row];
        NSString *titleStr = model.b_name;
        if ([model.b_type isEqualToString:@"0"]) {
            NSArray *userArray = [IM_FMDB_FILE result_IM_UserList:model.b_id];
            for (ContactModel *conModel in userArray) {
                if (conModel.userID != [appDelegateAccessor.moudle.userId integerValue]) {
                    model.b_name = titleStr = conModel.contactName;
                }
            }
        }
        chatController.titleName = titleStr;
        if (_BlackOneGroupIdBlock) {
            _BlackOneGroupIdBlock(model.b_id);
        }
        chatController.groupID = model.b_id;
        chatController.flag_FromWhereInto = @"searchVC";
        chatController.groupType = model.b_type;
        chatController.unReadMessageCount = [model.b_unReadNumber integerValue];
        chatController.pushType = ControllerPushTypeMessageVC;
        chatController.usersArray = model.usersListArray;
        chatController.unSendStr = model.m_content;
        chatController.RefreshDataSourceBlock = ^(NSDictionary *dict, NSString *sting) {
            //插入消息
            if (sting && sting.length > 0) {
                [IM_FMDB_FILE update_IM_ConversationListGroupID:model.b_id withUnsendSting:[NSString stringWithFormat:@"[草稿]%@", sting]];
            } else {
                [IM_FMDB_FILE update_IM_ConversationListGroupWithInfo:[self changeNotficationToMessageDic:dict]];
                //修改已读消息number  和 未读消息数
                [IM_FMDB_FILE update_IM_ConversationListGroupID:model.b_id withReadNumber:[NSString stringWithFormat:@"%@", [dict objectForKey:@"number"]] withUnReadNumber:@"0"];
            }
            [IM_FMDB_FILE update_IM_ConversationListGroupID:[NSString stringWithFormat:@"%@", [dict objectForKey:@"to"]] withShow:@"1"];
            [IM_FMDB_FILE closeDataBase];
        };
        //修改已读消息number  和 未读消息数
        [IM_FMDB_FILE update_IM_ConversationListGroupID:model.b_id withReadNumber:model.m_number withUnReadNumber:@"0"];
        [IM_FMDB_FILE closeDataBase];
        [self.navigationController pushViewController:chatController animated:YES];
        return;
    } else {
        NSDictionary *dict = _resultsArray[indexPath.section][@"results"][indexPath.row];
        if ([[dict objectForKey:@"hasMore"] isEqualToString:@"1"]) {
            MsgRootMoreResultsController *controller = [[MsgRootMoreResultsController alloc] init];
            controller.resultArray = dict[@"dataSource"];
            NSString *sting = [NSString stringWithFormat:@"共%ld与“%@”相关的聊天记录", [dict[@"dataSource"] count], _searchBar.text];
            controller.titelSting = sting;
            __weak typeof(self) weak_self = self;
            controller.BlackGroupIdBlock = ^(NSString *groupId){
                if (weak_self.BlackOneGroupIdBlock) {
                    weak_self.BlackOneGroupIdBlock(groupId);
                }
            };
            [self.navigationController pushViewController:controller animated:YES];
            return;
        } else {
            ChatViewController *chatController = [[ChatViewController alloc] init];
            chatController.titleName = [[dict objectForKey:@"dataSource"][0] safeObjectForKey:@"groupName"];
            NSString *groupID = [NSString stringWithFormat:@"%ld", [[[dict objectForKey:@"dataSource"][0] objectForKey:@"groupId"] integerValue]];
            chatController.groupID = groupID;
            chatController.messageIndex = [[[dict objectForKey:@"dataSource"][0] safeObjectForKey:@"messageIndex"] integerValue];
            chatController.messageID = [[dict objectForKey:@"dataSource"][0] safeObjectForKey:@"messageId"];
            chatController.flag_FromWhereInto = @"searchVC";
            chatController.pushType = ControllerPushTypeMessageVC;
            chatController.RefreshDataSourceBlock = ^(NSDictionary *dict, NSString *sting) {
                //插入消息
                if (sting && sting.length > 0) {
                    [IM_FMDB_FILE update_IM_ConversationListGroupID:groupID withUnsendSting:[NSString stringWithFormat:@"[草稿]%@", sting]];
                } else {
                    [IM_FMDB_FILE update_IM_ConversationListGroupWithInfo:[self changeNotficationToMessageDic:dict]];
                    //修改已读消息number  和 未读消息数
                    [IM_FMDB_FILE update_IM_ConversationListGroupID:groupID withReadNumber:[NSString stringWithFormat:@"%@", [dict objectForKey:@"number"]] withUnReadNumber:@"0"];
                }
                [IM_FMDB_FILE update_IM_ConversationListGroupID:[NSString stringWithFormat:@"%@", [dict objectForKey:@"to"]] withShow:@"1"];
                [IM_FMDB_FILE closeDataBase];
            };
            [self.navigationController pushViewController:chatController animated:YES];
            return;
        }
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView)
    {
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }
}

#pragma mark -- SearchBar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;
{
    _serachBarText = searchText;
//    NSLog(@"J_%@", searchText);
    [_resultsArray removeAllObjects];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    [array addObjectsFromArray:_dataSourceArray];
    NSMutableArray *groupArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *msgArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *conArray = [NSMutableArray arrayWithCapacity:0];
    __weak typeof(self) weak_self = self;
    
    for (int i = 0; i < allcontactArray.count; i++) {
        ContactModel *conModel = allcontactArray[i];
        NSString *contactName = conModel.contactName;
        NSString *pinyinName = [ChineseToPinyin pinyinFromChiniseString:contactName];
        NSLog(@"%@", pinyinName);
        if([self searchResult:pinyinName searchText:searchText])
        {
            [conArray addObject:conModel];
        } else {
            NSString *chineseName = [weak_self namToPinYinFisrtNameWith:contactName];
            if([self searchResult:chineseName searchText:searchText]){
                [conArray addObject:conModel];
            } else if([weak_self searchResult:contactName searchText:searchText]){
                [conArray addObject:conModel];
            } else {
                
            }
        }
    }
    if (conArray.count > 0) {
        NSDictionary *dict = @{@"titleName" : @"联系人",
                               @"results" : conArray};
        [weak_self.resultsArray addObject:dict];
    }
    
    ConversationListModel *conModel = [[ConversationListModel alloc] init];
    for (int i = 0; i < array.count; i++) {
        conModel = array[i];
        NSString *groupName = conModel.b_name;
        NSString *pinyinName = [ChineseToPinyin pinyinFromChiniseString:groupName];
        NSLog(@"%@", pinyinName);
        if([self searchResult:pinyinName searchText:searchText])
        {
            [groupArray addObject:conModel];
        } else {
            NSString *chineseName = [weak_self namToPinYinFisrtNameWith:groupName];
            if([self searchResult:chineseName searchText:searchText]){
                [groupArray addObject:conModel];
            } else if([weak_self searchResult:groupName searchText:searchText]){
                [groupArray addObject:conModel];
            } else {
                
            }
        }
    }
    if (groupArray && groupArray.count > 0) {
        NSDictionary *dict = @{@"titleName" : @"讨论组",
                               @"results" : groupArray};
        [weak_self.resultsArray addObject:dict];
    }
    for (ConversationListModel *conModel in allGroupArray) {
        NSArray *messageArray = [NSArray arrayWithArray:[IM_FMDB_FILE result_IM_MessageList:conModel.b_id]];
        NSMutableArray *saveMsgArray = [NSMutableArray arrayWithCapacity:0];
        NSInteger index = 0;
        for (NSDictionary *messageDic in messageArray) {
            NSString *msgSting = [messageDic objectForKey:@"message"];
            NSDictionary *dict = [NSDictionary dictionaryWithDictionary:[CommonFuntion dictionaryWithJsonString:msgSting]];
            ChatMessage *msgModel = [ChatMessage initWithDictionary:dict withNSArray:nil];
            NSString *msgName = msgModel.msg_content;
            NSString *pinyinName = [ChineseToPinyin pinyinFromChiniseString:msgName];
            NSLog(@"%@", pinyinName);
            if([weak_self searchResult:pinyinName searchText:searchText])
            {
                [saveMsgArray addObject:[weak_self creatNewDictOfResultWithConModel:conModel withMsgModel:msgModel withMessageIndex:index]];
            } else {
                NSString *chineseName = [weak_self namToPinYinFisrtNameWith:msgName];
                if([weak_self searchResult:chineseName searchText:searchText]){
                    [saveMsgArray addObject:[weak_self creatNewDictOfResultWithConModel:conModel withMsgModel:msgModel withMessageIndex:index]];
                } else if([weak_self searchResult:msgName searchText:searchText]){
                    [saveMsgArray addObject:[weak_self creatNewDictOfResultWithConModel:conModel withMsgModel:msgModel withMessageIndex:index]];
                } else {
                    
                }
            }
            index++;
        }
        NSDictionary *resultsDict;
        if (saveMsgArray.count > 1) {
            resultsDict = @{@"hasMore" : @"1",
                            @"dataSource" : saveMsgArray};
            [msgArray addObject:resultsDict];
        } else if (saveMsgArray.count == 1) {
            resultsDict = @{@"hasMore" : @"0",
                            @"dataSource" : saveMsgArray};
            [msgArray addObject:resultsDict];
        } else {
            
        }
    }
    if (msgArray.count > 0) {
        NSDictionary *dict = @{@"titleName" : @"聊天记录",
                               @"results" : msgArray};
        [weak_self.resultsArray addObject:dict];
    }
    if (weak_self.resultsArray && [weak_self.resultsArray count] > 0) {
        [self clearViewNoData];
        _guideView = nil;
    } else {
        if (searchText.length > 0) {
            [self clearViewNoData];
            _guideView = nil;
            [self setViewNoData:1 withString:searchText];
        } else {
            [self setViewNoData:0 withString:@""];
        }
    }
    [_tableView reloadData];
}
- (NSDictionary *)creatNewDictOfResultWithConModel:(ConversationListModel *)conModel withMsgModel:(ChatMessage *)msgModel withMessageIndex:(NSInteger)index {
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithCapacity:0];
    //组id 组名  组头像 消息id 消息内容
    [newDict setObject:conModel.b_id forKey:@"groupId"];
    [newDict setObject:conModel.b_name forKey:@"groupName"];
    NSArray *usersArray = [IM_FMDB_FILE result_IM_UserList:conModel.b_id];
    NSMutableArray *iconsArray = [NSMutableArray arrayWithCapacity:0];
    for (ContactModel *model in usersArray) {
        [iconsArray addObject:model.imgHeaderName];
    }
    [newDict setObject:iconsArray forKey:@"icons"];
    [newDict setObject:msgModel.msg_id forKey:@"messageId"];
    [newDict setObject:msgModel.msg_content forKey:@"content"];
    [newDict setObject:msgModel.msg_time forKey:@"msgTime"];
    [newDict setObject:@(index) forKey:@"messageIndex"];
    return newDict;
}
- (NSDictionary *)changeNotficationToMessageDic:(NSDictionary *)dict {
    NSMutableDictionary *messagedict = [NSMutableDictionary dictionary];
    [messagedict setObject:[dict objectForKey:@"content"] forKey:@"content"];
    [messagedict setObject:[NSString stringWithFormat:@"%@", [dict objectForKey:@"number"]] forKey:@"number"];
    [messagedict setObject:[NSString stringWithFormat:@"%@", [dict objectForKey:@"type"]] forKey:@"type"];
    [messagedict setObject:[NSString stringWithFormat:@"%@", [dict objectForKey:@"to"]] forKey:@"id"];
    [messagedict setObject:[NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]] forKey:@"userId"];
    NSString *timeStr = @"";
    long dateTime = 0;
    if (dict && [dict objectForKey:@"time"]) {
        timeStr = [CommonFuntion getStringForTime:[[dict safeObjectForKey:@"time"] longLongValue]];
        dateTime = [[dict safeObjectForKey:@"time"] longLongValue];
    }
//    NSInteger value = [CommonFuntion getTimeDaysSinceToady:timeStr];
//    if (value == 0) {
//        timeStr = [timeStr substringWithRange:NSMakeRange(11, 5)];
//    } else if (value == 1) {
//        timeStr = @"昨天";
//    } else if (value > 1 && value <=7) {
//        NSArray *weekDaysArray = @[@"星期日", @"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六"];
//        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:dateTime / 1000];
//        NSInteger index = [CommonFuntion getCurDateWeekday:date];
//        timeStr = [weekDaysArray objectAtIndex:index - 1];
//    } else {
//        timeStr = [timeStr substringToIndex:10];
//    }
//    [messagedict setObject:timeStr forKey:@"time"];
    [messagedict setObject:@(dateTime) forKey:@"time"];
    [messagedict setObject:timeStr forKey:@"sendTime"];
    
    if ([[dict allKeys] containsObject:@"resource"] && [CommonFuntion checkNullForValue:[dict objectForKey:@"resource"]]) {
        NSDictionary *resourceDic =  [CommonFuntion dictionaryWithJsonString:[dict objectForKey:@"resource"]];
        [messagedict setObject:@"1" forKey:@"isHave"];
        [messagedict setObject:[NSString stringWithFormat:@"%@", [resourceDic objectForKey:@"type"]] forKey:@"r_type"];
        
    } else {
        [messagedict setObject:@"0" forKey:@"isHave"];
        [messagedict setObject:@"" forKey:@"r_type"];
    }
    return messagedict;
}

- (NSString *)namToPinYinFisrtNameWith:(NSString *)name
{
    NSString * outputString = @"";
    for (int i =0; i<[name length]; i++) {
        outputString = [NSString stringWithFormat:@"%@%c",outputString,pinyinFirstLetter([name characterAtIndex:i])];
    }
    return outputString;
}

-(BOOL)searchResult:(NSString *)contactName searchText:(NSString *)searchT{
    if (contactName==nil || searchT == nil || (id)contactName == [NSNull null] || [contactName isEqualToString:@"(null)"] || [contactName isEqualToString:@"<null>"]) {
        return NO;
    }
    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    NSRange productNameRange = NSMakeRange(0, contactName.length);
    NSRange foundRange = [contactName rangeOfString:searchT options:searchOptions range:productNameRange];
    if (foundRange.length > 0)
        return YES;
    else
        return NO;
}
@end
