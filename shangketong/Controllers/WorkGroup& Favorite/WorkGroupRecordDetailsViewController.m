//
//  WorkGroupRecordDetailsViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

///每页条数
#define PageSize 10

#import "WorkGroupRecordDetailsViewController.h"
#import "CommonFuntion.h"
#import "CommonConstant.h"
#import "CommonModuleFuntion.h"
#import "UserReviewCell.h"
#import "HPGrowingTextView.h"
#import "WorkGroupRecordCellA.h"
#import "WorkGroupRecordCellB.h"
#import "WorkGroupPraiseListCell.h"
#import "CommonStaticVar.h"
#import "PhotoBroswerVC.h"
#import "MapViewViewController.h"
#import "KnowledgeFileDetailsViewController.h"
#import "AFNHttp.h"
#import "MJRefresh.h"
#import <MBProgressHUD.h>
#import "InfoViewController.h"
#import "ExportAddressViewController.h"
#import "AddressBook.h"
#import "ReleaseViewController.h"
#import "FMDB_SKT_CACHE.h"
#import "AddressBook.h"
#import "CommonRequstFuntion.h"
#import "ActivityDetailViewController.h"
#import "LeadDetailViewController.h"
#import "CustomerDetailViewController.h"
#import "ContactDetailViewController.h"
#import "OpportunityDetailController.h"
#import "Lead.h"
#import "Contact.h"
#import "Customer.h"
#import "SaleChance.h"
#import "AFSoundPlaybackHelper.h"
#import "DepartViewController.h"
#import "DepartGroupModel.h"
#import "ReportToServiceViewController.h"
#import "User.h"

@interface WorkGroupRecordDetailsViewController ()<UITableViewDataSource,UITableViewDelegate,WorkGroupDelegate,UserReviewDelegate,HPGrowingTextViewDelegate,UIActionSheetDelegate,PraiseContactDelegate,UITabBarControllerDelegate, TTTAttributedLabelDelegate>{
    UIView *keyboardContainerView;
    UIView *viewBottom;
    HPGrowingTextView *textViewReview;
    UITextField *textfiled;
    UIButton *btnAt;
    NSString *strReview;
    
    ///测试数据  评论、转发、赞  个数
    int typeCell;
    
    UIButton *btnPraise;
    NSMutableArray *arrayPraise;
    
    NSInteger pageNo;//页数下标
    BOOL isMoreData;///是否有更多数据
    
    ///标记删除操作
    long long trendIdDelete;
    NSInteger indexDelete;

}

@property (nonatomic, strong) WorkGroupRecordCellB *cell;
@end

@implementation WorkGroupRecordDetailsViewController

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initBottomBtnCount];
    [self initTableviewAndDate];
    [self creatBottomView];
    
    [self creatKeyBoardView];
    [self initPraiseBtnStatus];
    
    NSInteger m_Type = 1;
    if (![[self.dicWorkGroupDetails safeObjectForKey:@"moduleType"] isEqualToString:@""]) {
        m_Type = [[self.dicWorkGroupDetails objectForKey:@"moduleType"] integerValue];
    }
    
    ///OA
    if (m_Type == 1) {
        self.title = @"动态详情";
        [self addRightNarBtn];
    }else if(m_Type == 2){
        ///CRM
        self.title = @"活动记录详情";
        
        NSDictionary *user = nil;
        NSString *uid = @"";
        if ([CommonFuntion checkNullForValue:[self.dicWorkGroupDetails objectForKey:@"user"]]) {
            user = [self.dicWorkGroupDetails objectForKey:@"user"];
        }
        if (user) {
            if ([user objectForKey:@"id"]) {
                uid = [user safeObjectForKey:@"id"];
            }
        }
        
        ///如果是当前用户  则显示按钮
        if ([appDelegateAccessor.moudle.userId longLongValue] == [uid longLongValue]) {
            [self addRightNarBtn];
        }
    }
    
    ///动态详情
    if (m_Type == 1) {
        keyboardContainerView.hidden = YES;
    }else if(m_Type == 2){
        ///活动记录详情
        keyboardContainerView.hidden = NO;
    }
    
    
    //    [self readTestData];
    //    [self.tableviewWorkGroupReviews reloadData];
    [self getCommentsData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addObserverOfKeyBoard];
    [CommonStaticVar setContentFont:15.0 color:COLOR_WORKGROUP_CONTENT];
    
    if (typeCell == 1){
    }else{
        ///编辑框存在内容时 编辑框不隐藏
        if (strReview && strReview.length > 0) {
            viewBottom.hidden = YES;
            keyboardContainerView.hidden = NO;
        }else{
            viewBottom.hidden = NO;
            keyboardContainerView.hidden = YES;
        }
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //    [self showKeyBoardByFlag];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    strReview = textViewReview.text;
    [textViewReview resignFirstResponder];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self removeObserverOfKeyBoard];
    
    if (typeCell == 1){
    }else{
        keyboardContainerView.hidden = YES;
    }
    
    
    
//    [AFSoundPlaybackHelper stop_helper];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopVoice" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 读取测试数据
-(void)readTestData{
    
    id jsondata = [CommonFuntion readJsonFile:@"workgroup-details-revice-data"];
    NSLog(@"jsondata:%@",jsondata);
    
    NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"comments"];
    [self.arrayWorkGroupReview addObjectsFromArray:array];
    NSLog(@"arrayDetails count:%li",[self.arrayWorkGroupReview count]);
    
    
    ///点赞列表
    id jsondata2 = [CommonFuntion readJsonFile:@"details-praise-contact-data"];
    NSArray *array2 = [[jsondata2 objectForKey:@"body"] objectForKey:@"praise"];
    [arrayPraise addObjectsFromArray:array2];
    NSLog(@"read----arrayPraise:%@",arrayPraise);
}


#pragma mark - 初始化数据
-(void)initData{
    isMoreData = YES;
    pageNo = 1;
    self.arrayWorkGroupReview = [[NSMutableArray alloc] init];
    self.dicWorkGroupDetails = [[NSMutableDictionary alloc] initWithDictionary:self.dicWorkGroupDetailsOld];
    arrayPraise = [[NSMutableArray alloc] init];
}

#pragma mark - 初始化tablview
-(void)initTableviewAndDate{
    self.tableviewWorkGroupReviews = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height-50) style:UITableViewStyleGrouped];
    self.tableviewWorkGroupReviews.delegate = self;
    self.tableviewWorkGroupReviews.dataSource = self;
    //    self.tableviewWorkGroupReviews.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableviewWorkGroupReviews.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
    self.tableviewWorkGroupReviews.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    [self.view addSubview:self.tableviewWorkGroupReviews];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewWorkGroupReviews setTableFooterView:v];
    
    ///上拉刷新
    [self setupRefresh];
}

#pragma mark - 获取底部按钮个数
-(void)initBottomBtnCount{
    typeCell = 1;
    if ([[self.dicWorkGroupDetailsOld objectForKey:@"moduleType"] integerValue]== 2) {
//        _isShowKeyBoardView = @"yes";
        [self showKeyBoardByFlag];
        return;
    }
    ///是否可转发
    if ([self.dicWorkGroupDetailsOld objectForKey:@"canForward"] && [[self.dicWorkGroupDetailsOld objectForKey:@"canForward"] integerValue] == 0) {
        typeCell ++;
    }
    
    NSInteger system = -1;
    if ([self.dicWorkGroupDetailsOld objectForKey:@"system"]) {
        system = [[self.dicWorkGroupDetailsOld safeObjectForKey:@"system"] integerValue];
    }
    if (system == 607) {
        
    }else{
        typeCell ++;
    }
}

#pragma mark - Table view data source
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == self.tableviewWorkGroupReviews)
    {
        strReview = textViewReview.text;
        [textViewReview resignFirstResponder];
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        
        if (typeCell == 1){
        }else{
            ///编辑框存在内容时 编辑框不隐藏
            if (strReview && strReview.length > 0) {
                viewBottom.hidden = YES;
                keyboardContainerView.hidden = NO;
            }else{
                viewBottom.hidden = NO;
                keyboardContainerView.hidden = YES;
            }
        }
    }
}

///点赞头像列表
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (!isMoreData && self.tableviewWorkGroupReviews == tableView) {
        NSInteger count = 0;
        if (self.arrayWorkGroupReview) {
            count = [self.arrayWorkGroupReview count];
        }
        if (arrayPraise && [arrayPraise count] > 1) {
            count++;
        }
        count++;
        if (count-1 == section) {
            return 40;
        }
    }
    return 0.01;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.tableviewWorkGroupReviews) {
        NSInteger count = 0;
        if (self.arrayWorkGroupReview) {
            count = [self.arrayWorkGroupReview count];
        }
        
        if (arrayPraise && [arrayPraise count] > 1) {
            count++;
        }
        return count+1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableviewWorkGroupReviews) {
        return 1;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableviewWorkGroupReviews) {
        if (indexPath.section == 0) {
            return [WorkGroupRecordCellB getCellContentHeight:self.dicWorkGroupDetails byCellStatus:WorkGroupTypeStatusDetails];
        }else if ((arrayPraise && [arrayPraise count] > 1) && indexPath.section == 1) {
            return 40;
        }
        else{
            if ((arrayPraise && [arrayPraise count] > 1)) {
                return [UserReviewCell getCellContentHeight:[self.arrayWorkGroupReview objectAtIndex:indexPath.section-2]];
            }else{
                return [UserReviewCell getCellContentHeight:[self.arrayWorkGroupReview objectAtIndex:indexPath.section-1]];
            }
            
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableviewWorkGroupReviews) {
        
        ///详情内容
        if (indexPath.section == 0) {
            WorkGroupRecordCellB *cell = [tableView dequeueReusableCellWithIdentifier:@"WorkGroupRecordCellBIdentify"];
            if (!cell)
            {
                NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"WorkGroupRecordCellB" owner:self options:nil];
                cell = (WorkGroupRecordCellB*)[array objectAtIndex:0];
                [cell awakeFromNib];
            }
            cell.delegate = self;
            cell.labelContent.delegate = self;
            [cell setContentDetails:self.dicWorkGroupDetails indexPath:indexPath byCellStatus:WorkGroupTypeStatusDetails];
            [cell addClickEventForCellView:self.dicWorkGroupDetails withIndex:indexPath];
            
            return cell;
        }else if ((arrayPraise && [arrayPraise count] > 1) &&indexPath.section == 1){
            
            WorkGroupPraiseListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WorkGroupPraiseListCellIdentify"];
            if (cell == nil)
            {
                NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"WorkGroupPraiseListCell" owner:self options:nil];
                cell = (WorkGroupPraiseListCell*)[array objectAtIndex:0];
                [cell awakeFromNib];
            }
            cell.delegate = self;
            [cell setCellDetails:arrayPraise indexPath:indexPath];
            
            return cell;
        }else{
            
            ///评论内容
            UserReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserReviewCellIdentify"];
            if (cell == nil)
            {
                NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"UserReviewCell" owner:self options:nil];
                cell = (UserReviewCell*)[array objectAtIndex:0];
                [cell awakeFromNib];
            }
            cell.delegate = self;
            cell.labelContent.delegate = self;
            if ((arrayPraise && [arrayPraise count] > 1)) {
                [cell setContentDetails:[self.arrayWorkGroupReview objectAtIndex:indexPath.section-2]];
            }else{
                [cell setContentDetails:[self.arrayWorkGroupReview objectAtIndex:indexPath.section-1]];
            }
            
            [cell addClickEventForCellView:indexPath];
            
            return cell;
        }
    }
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.tableviewWorkGroupReviews) {
        
        if (indexPath.section == 0) {
            return;
        }
        
        NSDictionary *item = nil;
        if ((arrayPraise && [arrayPraise count] > 1)) {
            item = [self.arrayWorkGroupReview objectAtIndex:indexPath.section-2];
        }else{
            item = [self.arrayWorkGroupReview objectAtIndex:indexPath.section-1];
        }
        
        long long createId = -1;
        if ([item objectForKey:@"creator"] && [[item objectForKey:@"creator"] objectForKey:@"id"]) {
            createId = [[[item objectForKey:@"creator"] safeObjectForKey:@"id"] longLongValue];
        }
        
        ///如果是自己的评论  则弹出删除操作
        if ([appDelegateAccessor.moudle.userId longLongValue] == createId) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:nil
                                          delegate:self
                                          cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                          otherButtonTitles: @"删除",nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            actionSheet.tag = 2001+indexPath.section;
            [actionSheet showInView:self.view];
        }else{
            ///负责将当前user的姓名 添加到输入框内容中
            
            ///拼接@姓名到编辑框
            NSString *strText = @"";
            if (textViewReview.text) {
                strText = textViewReview.text;
            }
            strReview = [NSString stringWithFormat:@"%@ @%@ ",strText,[[item objectForKey:@"creator"] objectForKey:@"name"]];
            
            [self creatKeyBoardView];
            [textViewReview becomeFirstResponder];
            textViewReview.text = strReview;
            
        }
        
    }
}


-(void)gotoUserInfoViewById:(long long)userId{

    InfoViewController *infoController = [[InfoViewController alloc] init];
    infoController.title = @"个人信息";
    if ([appDelegateAccessor.moudle.userId longLongValue] == userId) {
        infoController.infoTypeOfUser = InfoTypeMyself;
    }else{
        infoController.infoTypeOfUser = InfoTypeOthers;
        
    }
    infoController.userId = userId;
    infoController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:infoController animated:YES];
}


#pragma mark - 已赞联系人头像点击事件
-(void)clickPraiseUserIconEvent:(NSInteger)row{
    NSLog(@"clickPraiseUserIconEvent row:%ti",row);
    NSDictionary *item = nil;
    item = [arrayPraise objectAtIndex:row];
    long long uid = [[item safeObjectForKey:@"id"] longLongValue];
    NSLog(@"uid:%lld",uid);
    [self gotoUserInfoViewById:uid];
}


#pragma mark  转发
-(void)clickRepost:(id)sender{
    __weak typeof(self) weak_self = self;
    ReleaseViewController *releaseController = [[ReleaseViewController alloc] init];
    releaseController.title = @"转发";
    releaseController.typeOfOptionDynamic = TypeOfOptionDynamicForward;
    releaseController.itemDynamic = self.dicWorkGroupDetailsOld;
    releaseController.ReleaseSuccessNotifyData = ^(){
        [weak_self notifyDataByForward];
    };
    [self.navigationController pushViewController:releaseController animated:YES];
}


-(void)notifyDataByForward{
    //先注释掉，在动态详情页面转发动态成功后，会连续返回两次页面，最终返回到动态列表页面。
    //    [self.navigationController popViewControllerAnimated:YES];
    ///重新请求数据
    if (self.UpdateByForwardTrend) {
        self.UpdateByForwardTrend();
    }
}

#pragma mark  评论
-(void)clickReview:(id)sender{
    [self creatKeyBoardView];
    [textViewReview becomeFirstResponder];
}


#pragma mark  赞
-(void)clickPraise:(id)sender{
    NSLog(@"赞--->");
    
    ///是否已经赞
    NSInteger  isFeedUp = [[self.dicWorkGroupDetails safeObjectForKey:@"isFeedUp"] integerValue];
    ///还没有赞
    if (isFeedUp == 1) {
        NSDictionary *item = self.dicWorkGroupDetails;
        long long trendsId = -1;
        if ([item objectForKey:@"id"]) {
            trendsId = [[item objectForKey:@"id"] longLongValue];
        }
        
        [self trendOption:FEED_UP_ADD withTrendsId:trendsId withCommentId:0 indexTrends:self.sectionOfDic];
    }else{
        kShowHUD2(@"该动态您已赞过");
    }
    
    
}

#pragma mark  @事件 ///跳转到通讯录
-(void)clickAtEvent:(id)sender{
    __weak typeof(self) weak_self = self;
    ExportAddressViewController *exportAddressController = [[ExportAddressViewController alloc] init];
    exportAddressController.title = @"选择同事";
    exportAddressController.valueBlock = ^(NSArray *selectedContact) {
        [weak_self initSelectContactNameStr:selectedContact];
    };
    [self.navigationController pushViewController:exportAddressController animated:YES];
}


#pragma mark - 通讯录选择同事
-(void)initSelectContactNameStr:(NSArray *)selectedContact{
    NSMutableString *nameAt = [[NSMutableString alloc] initWithString:@""];
    NSInteger count = 0;
    if (selectedContact) {
        count = [selectedContact count];
    }
    
    for (int i=0; i<count; i++) {
        AddressBook *model = selectedContact[i];
        [nameAt appendString:[NSString stringWithFormat:@" @%@ ",model.name]];
    }
    
    strReview = [NSString stringWithFormat:@"%@%@",textViewReview.text,nameAt];
    [self clickReview:nil];
    textViewReview.text = strReview;
}


#pragma mark 发送事件
-(void)sendReview{
#warning 缓存的通讯录数据 如未缓存则需请求
    ///缓存的通讯录数据
    /*
     NSDictionary *user1 =  [NSDictionary dictionaryWithObjectsAndKeys:@"295",@"id",@"1154546",@"name",nil];
     NSDictionary *user2 = [NSDictionary dictionaryWithObjectsAndKeys:@"10002",@"id",@"紫杀",@"name",nil];
     
     NSArray *arrAddress = [NSArray arrayWithObjects:user1,user2, nil];
     */
    
    NSArray *arrayAtId = nil;
    ///读取缓存
    //    NSArray *arrayCache = [FMDB_SKT_CACHE select_AddressBook_AllData];
    
    NSArray *arrayCache = [[FMDBManagement sharedFMDBManager] getAddressBookDataSource];
    
    if (arrayCache) {
        NSLog(@"arrayCache:%@",arrayCache);
        arrayAtId = [CommonFuntion getAtUserIds:textViewReview.text atArray:arrayCache isAddressBookArray:TRUE];
    }
    
    if (arrayAtId && arrayAtId.count > 9) {
        kShowHUD(@"你最多能@9人");
        return;
    }
    
    NSLog(@"arrayAtId:%@",arrayAtId);
    [self sendAComment:textViewReview.text atIds:arrayAtId];
}

#pragma mark - UserReviewDelegate cell点击事件
///点击头像事件
-(void)clickUserReviewIconEvent:(NSInteger)section{
    NSLog(@"clickUserReviewIconEvent section：%li",section);
    long long userId = -1;
    NSDictionary *item = nil;
    if ((arrayPraise && [arrayPraise count] > 1)) {
        item = [self.arrayWorkGroupReview objectAtIndex:section-2];
    }else{
        item = [self.arrayWorkGroupReview objectAtIndex:section-1];
    }
    
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"creator"]]) {
        userId = [[[item objectForKey:@"creator"] safeObjectForKey:@"id"] longLongValue];
    }
    [self gotoUserInfoViewById:userId];
}

///点击@
-(void)clickReviewContentCharType:(NSString *)type content:(NSString *)content atIndex:(NSIndexPath *)index{
    NSLog(@"clickReviewContentCharType type:%@ content:%@ index:%li",type,content,index.section);
    NSDictionary *item = nil;
    if ((arrayPraise && [arrayPraise count] > 1)) {
        item = [self.arrayWorkGroupReview objectAtIndex:index.section-2];
    }else{
        item = [self.arrayWorkGroupReview objectAtIndex:index.section-1];
    }
    
    NSLog(@"user:%@",[item objectForKey:@"alts"]);
    
    long long uid = [CommonModuleFuntion getUidByAtName:[[content substringFromIndex:1] stringByReplacingOccurrencesOfString:@" " withString:@
                                                         ""] fromAtList:[item objectForKey:@"alts"]];
    NSLog(@"uid:%lld",uid);
    
    [self gotoUserInfoViewById:uid];
}

#pragma mark - WorkGroupDelegate cell点击事件
///点击头像事件
-(void)clickUserIconEvent:(NSInteger)section{
    NSLog(@"clickUserIconEvent section：%li",section);
    ///获取到uid
    ///根据uid跳转页面
    NSDictionary *user = nil;
    if ([self.dicWorkGroupDetails objectForKey:@"user"]) {
        user = [self.dicWorkGroupDetails objectForKey:@"user"];
    }
    long long userId =  [[user safeObjectForKey:@"id"] longLongValue];
    [self gotoUserInfoViewById:userId];
}

///点击文件事件
-(void)clickFileEvent:(NSInteger)section{
    NSLog(@"clickFileEvent row：%li",section);
    
    NSDictionary *fileItem = nil;
    NSDictionary *item = self.dicWorkGroupDetails;
    
    ///转发内容
    if ([[item objectForKey:@"type"] integerValue] == 2) {
        if ([CommonFuntion checkNullForValue:[item objectForKey:@"forward"]]) {
            item = [item objectForKey:@"forward"];
        }
    }
    
    //    if ([item objectForKey:@"file"] && [item objectForKey:@"fileType"]) {
    //        if ([[item safeObjectForKey:@"fileType"]  integerValue] == 2) {
    //            ///文件
    //            fileItem = [item objectForKey:@"file"];
    //        }
    //    }
    if (item && [CommonFuntion checkNullForValue:[item objectForKey:@"file"]]) {
        KnowledgeFileDetailsViewController *controller = [[KnowledgeFileDetailsViewController alloc] init];
        controller.detailsOld = [item objectForKey:@"file"];
        controller.viewFrom = @"other";
        controller.isNeedRightNavBtn = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        [CommonFuntion showToast:@"文件不存在" inView:self.view];
    }
}

///展开或收起
-(void)clickExpContentEvent:(NSInteger)section{
    NSLog(@"clickExpContentEvent section：%li",section);
    
    ///已经处于展开状态 则收起
    if ([self.dicWorkGroupDetails objectForKey:@"isExp"] && [[self.dicWorkGroupDetails objectForKey:@"isExp"] isEqualToString:@"yes"]) {
        [self.dicWorkGroupDetails setObject:@"no" forKey:@"isExp"];
    }else{
        ///标记为展开展开状态
        [self.dicWorkGroupDetails setObject:@"yes" forKey:@"isExp"];
    }
    
    ///刷新当前cell
    [self.tableviewWorkGroupReviews reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],nil] withRowAnimation:UITableViewRowAnimationNone];
    
    
    [self.tableviewWorkGroupReviews scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

///点击右上角菜单事件
-(void)clickRightMenuEvent:(NSInteger)section{
    NSLog(@"clickRightMenuEvent section：%li",section);
}

///点击地址事件
-(void)clickAddressEvent:(NSInteger)section{
    NSLog(@"clickAddressEvent section：%li",section);
    
    NSDictionary *item = self.dicWorkGroupDetails;;
    
    NSDictionary *feedItem = nil;
    
    ///是转发信息
    if ([[item objectForKey:@"type"] integerValue] == 2) {
        ///
        if ([CommonFuntion checkNullForValue:[item objectForKey:@"forward"]]) {
            feedItem = [item objectForKey:@"forward"];
        }
    }
    
    ///是转发动态
    if (feedItem ) {
        item = feedItem;
    }
    
    double latitude = 0;
    double longitude = 0;
    if ([item objectForKey:@"latitude"]) {
        latitude = [[item safeObjectForKey:@"latitude"] doubleValue];
    }
    if ([item objectForKey:@"longitude"]) {
        longitude = [[item safeObjectForKey:@"longitude"] doubleValue];
    }
    ///location
    NSString *location = @"";
    if ([item objectForKey:@"position"]) {
        location = [item safeObjectForKey:@"position"];
    }
    NSString *locationDetail = @"";
    if ([item objectForKey:@"position"]) {
        locationDetail = [item safeObjectForKey:@"position"];
    }
    
    if (latitude !=0 && longitude !=0) {
        MapViewViewController *controller = [[MapViewViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        controller.typeOfMap = @"show";
        controller.latitude = latitude;
        controller.longitude = longitude;
        controller.location = location;
        controller.locationDetail = locationDetail;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

///点击转发事件
-(void)clickRepostEvent:(NSInteger)section{
    NSLog(@"clickRepostEvent section：%li",section);
}

///点击评论事件
-(void)clickReviewEvent:(NSInteger)section{
    NSLog(@"clickReviewEvent section：%li",section);
}
//点击语音事件
- (void)clickVoiceDataEvent:(NSInteger)section {
    NSLog(@"clickVoiceDataEvent section：%li",section);
    NSDictionary *item = [NSDictionary dictionaryWithDictionary:self.dicWorkGroupDetailsOld];
    NSString *voiceStr = @"";
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"audio"]]) {
        if ([[item objectForKey:@"audio"] objectForKey:@"url"]) {
            voiceStr = [[item objectForKey:@"audio"] safeObjectForKey:@"url"];
            [AFSoundPlaybackHelper playVoiceByUrl:voiceStr];
        }
    }
}
///点击赞事件
-(void)clickPraiseEvent:(NSInteger)section{
    NSLog(@"clickPraiseEvent section：%li",section);
}

///点击来自XXX事件
-(void)clickFromEvent:(NSInteger)section{
    NSLog(@"clickFromEvent section：%li",section);
    NSDictionary *item = [NSDictionary dictionaryWithDictionary:self.dicWorkGroupDetailsOld];
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"from"]]) {
        _sourceType = [[[item objectForKey:@"from"] objectForKey:@"sourceId"] integerValue];
        NSInteger sectionId = [[[item objectForKey:@"from"] objectForKey:@"id"] integerValue];
        switch (_sourceType) {
            case PushControllerTypeActivity:
            {
                ActivityDetailViewController *controller = [[ActivityDetailViewController alloc] init];
                controller.id = @(sectionId);
                controller.title = @"市场活动";
                [self.navigationController pushViewController:controller animated:YES];
            }
                NSLog(@"市场活动");
                break;
            case PushControllerTypeClue:
            {
                LeadDetailViewController *controller = [[LeadDetailViewController alloc] init];
                Lead *lead = [[Lead alloc] init];
                lead.id = @(sectionId);
                controller.id = lead.id;
                controller.title = @"销售线索";
                [self.navigationController pushViewController:controller animated:YES];
            }
                NSLog(@"销售线索");
                break;
            case PushControllerTypeCustomer:
            {
                CustomerDetailViewController *controller = [[CustomerDetailViewController alloc] init];
                Customer *tomer = [[Customer alloc] init];
                tomer.id = @(sectionId);
                controller.id = tomer.id;
                controller.title = @"客户";
                [self.navigationController pushViewController:controller animated:YES];
            }
                NSLog(@"客户");
                break;
            case PushControllerTypeContract:
            {
                ContactDetailViewController *controller = [[ContactDetailViewController alloc] init];
                Contact *tact = [[Contact alloc] init];
                tact.id = @(sectionId);
                controller.id = tact.id;
                controller.title = @"联系人";
                [self.navigationController pushViewController:controller animated:YES];
            }
                NSLog(@"联系人");
                break;
            case PushControllerTypeOpportunity:
            {
                OpportunityDetailController *controller = [[OpportunityDetailController alloc] init];
                SaleChance *chance = [[SaleChance alloc] init];
                chance.id = @(sectionId);
                controller.id = chance.id;
                controller.title = @"销售机会";
                [self.navigationController pushViewController:controller animated:YES];
            }
                NSLog(@"销售机会");
                break;
            case PushControllerTypeGroup:
            {
                [self gotoDepartMentOrGroup:item];
            }
                NSLog(@"群组");
                break;
            case PushControllerTypeDepartment:
            {
                [self gotoDepartMentOrGroup:item];
            }
                NSLog(@"部门");
                break;
                
            default:
                break;
        }
    }
}


///跳转到部门或群组
-(void)gotoDepartMentOrGroup:(NSDictionary *)item{
    
    NSDictionary *from =  [item objectForKey:@"from"];
    NSDictionary *fromItem = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:[[from objectForKey:@"id"] longValue]],@"id", [from objectForKey:@"name"],@"name",@1,@"hasChildren",@"",@"icon",@"",@"pinyin",nil];
    DepartGroupModel *model = [NSObject objectOfClass:@"DepartGroupModel" fromJSON:fromItem];
    
    DepartViewController *controll = [[DepartViewController alloc] init];
    UITabBarController *tabbarController = [[UITabBarController alloc] init];
    tabbarController.edgesForExtendedLayout = UIRectEdgeNone;
    tabbarController.title = model.name;
    tabbarController.viewControllers = [controll getTabBarItems:model andType:[[from objectForKey:@"sourceId"] integerValue]];
    tabbarController.hidesBottomBarWhenPushed = YES;
    tabbarController.delegate = self;
    [self.navigationController pushViewController:tabbarController animated:YES];
}


///点击@
-(void)clickContentCharType:(NSString *)type content:(NSString *)content atIndex:(NSIndexPath *)index{
    
    NSLog(@"clickContentCharType type:%@ content:%@ index:%li",type,content,index.row);
    
#warning
    ///未返回标记@集合的key
    
    long long uid = [CommonModuleFuntion getUidByAtName:[[content substringFromIndex:1] stringByReplacingOccurrencesOfString:@" " withString:@
                                                         ""] fromAtList:[self.dicWorkGroupDetails objectForKey:@"alts"]];
    NSLog(@"uid:%lld",uid);
    
    
    ///根据uid 跳转页面
    [self gotoUserInfoViewById:uid];
}

///点击转发view区域
-(void)clickRepostViewEvent:(NSInteger)section{
    NSLog(@"clickRepostViewEvent section：%li",section);
    
    ///是转发信息
    if ([[self.dicWorkGroupDetails  objectForKey:@"type"] integerValue] == 2 ) {
        ///
        NSDictionary *feedItem = nil;
        if ([CommonFuntion checkNullForValue:[self.dicWorkGroupDetails objectForKey:@"forward"]]) {
            feedItem = [self.dicWorkGroupDetails objectForKey:@"forward"];
        }
        
        ///存在转发内容
        if (feedItem) {
            WorkGroupRecordDetailsViewController *controller = [[WorkGroupRecordDetailsViewController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            controller.isShowKeyBoardView = @"no";
            controller.dicWorkGroupDetailsOld = feedItem;
            [self.navigationController pushViewController:controller animated:YES];
        }else{
            ///动态已经被删除
            [CommonFuntion showToast:@"该动态已被删除" inView:self.view];
        }
    }
}


///点击图片事件
-(void)clickImageViewEvent:(NSIndexPath *)imgIndexPath{
    NSLog(@"clickImageViewEvent section：%li andImgIndex:%li",imgIndexPath.section,imgIndexPath.row);
    
    ///转发 、正常
    NSLog(@"self.dicWorkGroupDetails:%@",self.dicWorkGroupDetails);
    
    [PhotoBroswerVC show:self type:PhotoBroswerVCTypeZoom index:imgIndexPath.row photoModelBlock:^NSArray *{
        
        WorkGroupRecordCellB *cell = (WorkGroupRecordCellB *)[self.tableviewWorkGroupReviews cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        
        //        NSLog(@"-----img  click--item:%@",item);
        
        NSDictionary *item = self.dicWorkGroupDetails;
        ///转发内容
        if ([[item objectForKey:@"type"] integerValue] == 2) {
            if ([CommonFuntion checkNullForValue:[item objectForKey:@"forward"]]) {
                item = [item objectForKey:@"forward"];
            }
        }
        NSArray *arrayImg;
        
        /// fileType  0 不存在  1图片  2附件
        /// imageFiles 判断图片
        if ([CommonFuntion checkNullForValue:[item objectForKey:@"imageFiles"]] && [item objectForKey:@"fileType"]) {
            if ([[item safeObjectForKey:@"fileType"]  integerValue] == 1) {
                arrayImg = [item objectForKey:@"imageFiles"];
            }
        }
        
        //        NSLog(@"-----img  click--arrimg:%@",arrayImg);
#warning 该替换为url
        NSString *imgSizeType = @"url";
        
        NSMutableArray *modelsM = [NSMutableArray arrayWithCapacity:arrayImg.count];
        
        NSInteger imgIndex = 0;
        if ([arrayImg count] > imgIndex) {
            NSLog(@"----imgIndex:%ti",imgIndex);
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            
            //源frame
            NSLog(@"cell.img1:%@",cell.img1);
            pbModel.sourceImageView = cell.img1;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        
        if ([arrayImg count] > imgIndex) {
            NSLog(@"----imgIndex:%ti",imgIndex);
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            NSLog(@"cell.img2:%@",cell.img2);
            UIImageView *imageV =(UIImageView *)cell.img2;
            pbModel.sourceImageView = imageV;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        if ([arrayImg count] > imgIndex) {
            NSLog(@"----imgIndex:%ti",imgIndex);
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            pbModel.sourceImageView = cell.img3;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        if ([arrayImg count] > imgIndex) {
            NSLog(@"----imgIndex:%ti",imgIndex);
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            pbModel.sourceImageView = cell.img4;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        if ([arrayImg count] > imgIndex) {
            NSLog(@"----imgIndex:%ti",imgIndex);
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            pbModel.sourceImageView = cell.img5;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        if ([arrayImg count] > imgIndex) {
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            pbModel.sourceImageView = cell.img6;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        if ([arrayImg count] > imgIndex) {
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            pbModel.sourceImageView = cell.img7;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        if ([arrayImg count] > imgIndex) {
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            pbModel.sourceImageView = cell.img8;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        if ([arrayImg count] > imgIndex) {
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            pbModel.sourceImageView = cell.img9;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        for (int i=0; i<modelsM.count; i++) {
            NSLog(@"modelsM:%@",[modelsM objectAtIndex:i]);
        }
        
        return modelsM;
    }];
}


#pragma mark - 底部按钮 (转发、评论、赞)
-(void)creatBottomView{
    ///判断当前cell的类型
    
    if (typeCell == 1) {
        [self creatKeyBoardView];
    }else{
        NSString *btnTextColor = @"585858";
        viewBottom = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height-50, kScreen_Width, 50)];
        viewBottom.backgroundColor = [UIColor whiteColor];
        //        viewBottom.alpha = 0.3;
        UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 1)];
        imgLine.image = [UIImage imageNamed:@"line.png"];
        [viewBottom addSubview:imgLine];
        
        ///转发按钮
        UIButton *btnRepost = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnRepost setImage:[UIImage imageNamed:@"feed_repost.png"] forState:UIControlStateNormal];
//        [btnRepost setBackgroundImage:[UIImage imageNamed:@"nodown_file_btn.png"] forState:UIControlStateNormal];
        [btnRepost.layer setMasksToBounds:YES];
        [btnRepost.layer setCornerRadius:6];
        [btnRepost.layer setBorderWidth:1];
        btnRepost.layer.borderColor = [UIColor colorWithHexString:@"cbcdcd"].CGColor;
        
        [btnRepost setTitle:@"转发" forState:UIControlStateNormal];
        btnRepost.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [btnRepost setTitleColor:[UIColor colorWithHexString:btnTextColor] forState:UIControlStateNormal];
        [btnRepost addTarget:self action:@selector(clickRepost:) forControlEvents:UIControlEventTouchUpInside];
        
        ///评论按钮
        UIButton *btnReview = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnReview setImage:[UIImage imageNamed:@"feed_review.png"] forState:UIControlStateNormal];
//        [btnReview setBackgroundImage:[UIImage imageNamed:@"nodown_file_btn.png"] forState:UIControlStateNormal];
        [btnReview.layer setMasksToBounds:YES];
        [btnReview.layer setCornerRadius:6];
        [btnReview.layer setBorderWidth:1];
        btnReview.layer.borderColor = [UIColor colorWithHexString:@"cbcdcd"].CGColor;
        [btnReview setTitle:@"评论" forState:UIControlStateNormal];
        btnReview.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [btnReview setTitleColor:[UIColor colorWithHexString:btnTextColor] forState:UIControlStateNormal];
        [btnReview addTarget:self action:@selector(clickReview:) forControlEvents:UIControlEventTouchUpInside];
        
        ///赞按钮
        btnPraise = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnPraise setImage:[UIImage imageNamed:@"feed_praise.png"] forState:UIControlStateNormal];
//        [btnPraise setBackgroundImage:[UIImage imageNamed:@"nodown_file_btn.png"] forState:UIControlStateNormal];
        [btnPraise.layer setMasksToBounds:YES];
        [btnPraise.layer setCornerRadius:6];
        [btnPraise.layer setBorderWidth:1];
        btnPraise.layer.borderColor = [UIColor colorWithHexString:@"cbcdcd"].CGColor;
        [btnPraise setTitle:@"赞" forState:UIControlStateNormal];
        btnPraise.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [btnPraise setTitleColor:[UIColor colorWithHexString:btnTextColor] forState:UIControlStateNormal];
        [btnPraise addTarget:self action:@selector(clickPraise:) forControlEvents:UIControlEventTouchUpInside];
        NSInteger space = 0;
        CGFloat width = 0;
        CGFloat height = 36.0;
        
        ///主动发布的动态
        if (typeCell == 3) {
            space = 15;
            width = (kScreen_Width-15*4)/3;
            
            btnRepost.frame = CGRectMake(space, 7, width, height);
            btnReview.frame = CGRectMake(space*2+width, 7, width, height);
            btnPraise.frame = CGRectMake(space*3+width*2, 7, width, height);
        }else if (typeCell == 1) {
            ///评论
            space = 15;
            width = (kScreen_Width-15*3)/2;
            btnRepost.hidden = YES;
            btnReview.hidden = YES;
            btnPraise.hidden = YES;
        }
        else if (typeCell == 2) {
            ///评论与赞
            space = 15;
            width = (kScreen_Width-15*3)/2;
            btnRepost.hidden = YES;
            btnReview.frame = CGRectMake(space, 7, width, height);
            btnPraise.frame = CGRectMake(space*2+width, 7, width, height);
        }
        
        [viewBottom addSubview:btnRepost];
        [viewBottom addSubview:btnReview];
        [viewBottom addSubview:btnPraise];
        
        [self.view addSubview:viewBottom];
    }
    
}

///是否已经赞过
-(void)initPraiseBtnStatus{
    
    NSLog(@"self.dicWorkGroupDetails:%@",self.dicWorkGroupDetails);
    
    ///已经被赞的个数
    NSInteger feedUpCount = 0;
    if (![[self.dicWorkGroupDetails safeObjectForKey:@"feedUpCount"] isEqualToString:@""]) {
        feedUpCount = [[self.dicWorkGroupDetails objectForKey:@"feedUpCount"] integerValue];
    }
    
    ///是否已经赞
    NSInteger  isFeedUp = [[self.dicWorkGroupDetails safeObjectForKey:@"isFeedUp"] integerValue];
//    if (![[self.dicWorkGroupDetails safeObjectForKey:@"isFeedUp"] isEqualToString:@""]) {
//        isFeedUp = [[self.dicWorkGroupDetails safeObjectForKey:@"isFeedUp"] integerValue];
//    }
    
    
    ///还没有赞
    if (isFeedUp == 1) {
//        btnPraise.enabled = YES;
        [btnPraise setImage:[UIImage imageNamed:@"feed_praise.png"] forState:UIControlStateNormal];
        //        self.btnPraise.userInteractionEnabled = YES;
    }else{
//        btnPraise.enabled = NO;
        [btnPraise setImage:[UIImage imageNamed:@"feed_praise_select.png"] forState:UIControlStateNormal];
        
        [btnPraise setTitle:[NSString stringWithFormat:@" %ti",feedUpCount] forState:UIControlStateNormal];
        
        //        self.btnPraise.userInteractionEnabled = NO;
    }
    
    
    
}

///根据标识 控制键盘是否显示
-(void)showKeyBoardByFlag{
    ///展示键盘
    if (typeCell == 1) {
        if ([self.isShowKeyBoardView isEqualToString:@"yes"]) {
            keyboardContainerView.hidden = NO;
            NSLog(@"控制键盘显示---->");
            [textViewReview becomeFirstResponder];
        }
    }else{
        if ([self.isShowKeyBoardView isEqualToString:@"yes"]) {
            
            [self clickReview:nil];
        }
    }
}

#pragma mark - 创建键盘view
-(void)creatKeyBoardView{
    if (keyboardContainerView == nil) {
        NSLog(@"clickReview---new->");
        keyboardContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height - 40, kScreen_Width, 40)];
        keyboardContainerView.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];;
        keyboardContainerView.layer.borderColor = [UIColor lightGrayColor].CGColor;;
        keyboardContainerView.layer.borderWidth = 0.5;
        
        textViewReview = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(50, 5, kScreen_Width-60, 30)];
        
        
        textViewReview.isScrollable = NO;
        textViewReview.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
        textViewReview.minNumberOfLines = 1;
        textViewReview.maxNumberOfLines = 2;
        // you can also set the maximum height in points with maxHeight
        // textView.maxHeight = 200.0f;
        textViewReview.returnKeyType = UIReturnKeySend;
        textViewReview.font = [UIFont systemFontOfSize:12.0f];
        textViewReview.internalTextView.font = [UIFont systemFontOfSize:12.0f];
        textViewReview.delegate = self;
        textViewReview.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        
        textViewReview.backgroundColor = [UIColor whiteColor];
        textViewReview.layer.borderWidth = 0.5;
        textViewReview.layer.borderColor = [UIColor lightGrayColor].CGColor;
        textViewReview.layer.cornerRadius = 5;
        
        
        NSLog(@"textViewReview width:%f  height:%f",textViewReview.frame.size.width,textViewReview.frame.size.height);
        NSLog(@"1internalTextView width:%f  height:%f",textViewReview.internalTextView.frame.size.width,textViewReview.internalTextView.frame.size.height);
        
        textViewReview.placeholder = @"输入评论内容";
        
        [keyboardContainerView addSubview:textViewReview];
        
        
        btnAt = [UIButton buttonWithType:UIButtonTypeCustom];
        btnAt.frame = CGRectMake(10, 7, 26, 26);
        [btnAt setBackgroundImage:[UIImage imageNamed:@"feed_comments_at.png"] forState:UIControlStateNormal];
        [btnAt addTarget:self action:@selector(clickAtEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [keyboardContainerView addSubview:btnAt];
        // textView.text = @"test\n\ntest";
        // textView.animateHeightChange = NO; //turns off animation
        //        [textViewReview becomeFirstResponder];
        
        
        [self.view addSubview:keyboardContainerView];
        
        //        textfiled = [[UITextField alloc] init];
        //        textfiled.inputAccessoryView = keyboardContainerView;
        //        textfiled.hidden = YES;
        //        [self.view addSubview:textfiled];
        
        //        keyboardContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    
    keyboardContainerView.hidden = NO;
}


//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = keyboardContainerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    keyboardContainerView.frame = containerFrame;
    /*
    if ((self.view.bounds.size.height-keyboardBounds.size.height-keyboardContainerView.frame.size.height) < self.tableviewWorkGroupReviews.contentSize.height) {
        [self.tableviewWorkGroupReviews setContentOffset:CGPointMake(0.0, self.tableviewWorkGroupReviews.contentSize.height-(self.view.bounds.size.height-keyboardBounds.size.height-keyboardContainerView.frame.size.height)) animated:YES];
    }
     */
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = keyboardContainerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    keyboardContainerView.frame = containerFrame;
    
    [UIView commitAnimations];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    NSLog(@"diff:%f",diff);
    CGRect r = keyboardContainerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    keyboardContainerView.frame = r;
}


///return键事件
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView{
    NSLog(@"发送--->");
    [textViewReview resignFirstResponder];
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    if (typeCell == 1){
    }else{
        keyboardContainerView.hidden = YES;
    }
    
    if (textViewReview.text && ![[textViewReview.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""] && textViewReview.text.length > 0) {
        ///有内容  发送
        [self sendReview];
    }
    
    return NO;
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


#pragma mark - 右侧更多按钮
-(void)addRightNarBtn{
    
    UIButton *option = [UIButton buttonWithType:UIButtonTypeCustom];
    option.frame = CGRectMake(0, 0, 20, 4);
    [option setBackgroundImage:[UIImage imageNamed:@"more.png"]
                      forState:UIControlStateNormal];
    
    [option setBackgroundImage:[UIImage imageNamed:@"more.png"]
                      forState:UIControlStateHighlighted];
    
    
    [option addTarget:self action:@selector(showOptionMenu)
     forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:option];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}

-(void)showOptionMenu{
    
    NSInteger m_Type = 2;
    if ([CommonFuntion checkNullForValue:[self.dicWorkGroupDetails objectForKey:@"moduleType"]]) {
        m_Type = [[self.dicWorkGroupDetails objectForKey:@"moduleType"] integerValue];
    }
    
    ///OA
    if (m_Type == 1) {
        [self showRightActionSheetMenuOA];
    }else if(m_Type == 2){
        ///CRM
        [self showRightActionSheetMenuCRM];
    }
}


#pragma mark  OA  点击右上角菜单按钮 弹出actionsheetview
///点击右上角菜单按钮 弹出actionsheetview
-(void)showRightActionSheetMenuOA{
    NSDictionary *item = self.dicWorkGroupDetails;
    NSDictionary *user = nil;
    NSString *uid = @"";
    if ([item objectForKey:@"user"]) {
        user = [item objectForKey:@"user"];
    }
    if (user) {
        if ([user objectForKey:@"id"]) {
            uid = [user safeObjectForKey:@"id"];
        }
    }
    
    NSInteger isfav = 0;
    if ([item objectForKey:@"isfav"]) {
        isfav = [[item objectForKey:@"isfav"] integerValue];
    }
    NSString *report = @"举报";
    NSString *fav = @"";
    NSString *delete = @"删除";
    ///已收藏
    if (isfav == 0) {
        fav = @"取消收藏";
    }else{
        fav = @"收藏";
    }
    
    ///是我的动态  举报 收藏 删除收藏等操作   有删除操作
    if ([appDelegateAccessor.moudle.userId longLongValue] == [uid longLongValue]) {
        
        ///判断可删除时 标红
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:report
                                      otherButtonTitles: fav,delete,nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        actionSheet.destructiveButtonIndex = 2;
        actionSheet.tag = 101;
        [actionSheet showInView:self.view];
        
    }else{
        ///别人的动态   收藏   取消收藏  举报
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles: report,fav,nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        actionSheet.tag = 101;
        [actionSheet showInView:self.view];
    }
}


///点击右上角菜单按钮 弹出actionsheetview
-(void)showRightActionSheetMenuCRM{
    
    NSDictionary *item = self.dicWorkGroupDetails;
    NSDictionary *user = nil;
    NSString *uid = @"";
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"user"]]) {
        user = [item objectForKey:@"user"];
    }
    if (user) {
        if ([user objectForKey:@"id"]) {
            uid = [user safeObjectForKey:@"id"];
        }
    }
    
    NSString *delete = @"删除";
    if ([appDelegateAccessor.moudle.userId longLongValue] == [uid longLongValue]) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles: delete,nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        actionSheet.destructiveButtonIndex = 0;
        actionSheet.tag = 102;
        [actionSheet showInView:self.view];
        
    }
}



-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 101) {
        
        NSDictionary *item = self.dicWorkGroupDetails;
        NSDictionary *user = nil;
        NSString *uid = @"";
        if ([item objectForKey:@"user"]) {
            user = [item objectForKey:@"user"];
        }
        if (user) {
            if ([user objectForKey:@"id"]) {
                uid = [user safeObjectForKey:@"id"];
            }
        }
        
        if (buttonIndex == 0) {
            //            //举报
            [self reportToService];
        }else if (buttonIndex == 1) {
            //收藏 取消收藏
            
            NSInteger isfav = 0;
            if ([item objectForKey:@"isfav"]) {
                isfav = [[item objectForKey:@"isfav"] integerValue];
            }
            
            long long trendsId = -1;
            if ([item objectForKey:@"id"]) {
                trendsId = [[item objectForKey:@"id"] longLongValue];
            }
            
            NSString *url = @"";
            ///已收藏
            if (isfav == 0) {
                ///取消收藏
                url = DELETE_FAVORITE;
            }else{
                ///收藏
                url = ADD_FAVORITE;
            }
            [self trendOption:url withTrendsId:trendsId withCommentId:0 indexTrends:self.sectionOfDic];
            
        }else if(buttonIndex == 2) {
            ///我的动态
            if ([appDelegateAccessor.moudle.userId longLongValue] == [uid longLongValue]) {
                //删除
                NSDictionary *item = self.dicWorkGroupDetails;
                trendIdDelete = -1;
                if ([item objectForKey:@"id"]) {
                    trendIdDelete = [[item objectForKey:@"id"] longLongValue];
                }
                
                UIAlertView *alertDelete = [[UIAlertView alloc] initWithTitle:@"确认删除动态？" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
                alertDelete.tag = 1001;
                [alertDelete show];
                
                
            }
            
        }else if(buttonIndex == 3) {
            //取消
        }
    }else if (actionSheet.tag == 102) {
        
        NSDictionary *item = self.dicWorkGroupDetails;
        NSDictionary *user = nil;
        NSString *uid = @"";
        if ([item objectForKey:@"user"]) {
            user = [item objectForKey:@"user"];
        }
        if (user) {
            if ([user objectForKey:@"id"]) {
                uid = [user safeObjectForKey:@"id"];
            }
        }
        
        if (buttonIndex == 0) {
            //删除
            NSDictionary *item = self.dicWorkGroupDetails;
            trendIdDelete = -1;
            if ([item objectForKey:@"id"]) {
                trendIdDelete = [[item objectForKey:@"id"] longLongValue];
            }
            
            UIAlertView *alertDelete = [[UIAlertView alloc] initWithTitle:@"确认删除活动记录？" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
            alertDelete.tag = 1003;
            [alertDelete show];
        }
    }
    else {
        ///点击评论内容时的弹框
        NSInteger section = actionSheet.tag -2001;
        if (buttonIndex == 0) {
            //删除
            NSLog(@"删除----》");
            indexDelete = section;
            UIAlertView *alertDelete = [[UIAlertView alloc] initWithTitle:@"确认删除评论？" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
            alertDelete.tag = 1002;
            [alertDelete show];
            
            
        }else if (buttonIndex == 1) {
            
        }
    }
    
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components {
    
    User *user = [components objectForKey:@"altUser"];
    
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
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001) {
        if (buttonIndex == 1) {
            NSLog(@"删除动态");
            [self trendOption:DELETE_DYNAMIC withTrendsId:trendIdDelete  withCommentId:0 indexTrends:self.sectionOfDic];
        }
    }else if (alertView.tag == 1002){
        if (buttonIndex == 1) {
            NSLog(@"删除评论");
            [self deleteComent:indexDelete];
        }
    }else if (alertView.tag == 1003){
        if (buttonIndex == 1) {
            NSLog(@"删除活动记录");
            [self trendOption:kNetPath_Common_DeleteActivity withTrendsId:trendIdDelete  withCommentId:0 indexTrends:self.sectionOfDic];
        }
    }
    
}


///删除评论
-(void)deleteComent:(NSInteger)section{
    long long trendsId = -1;
    if ([self.dicWorkGroupDetails objectForKey:@"id"]) {
        trendsId = [[self.dicWorkGroupDetails objectForKey:@"id"] longLongValue];
    }
    
    NSDictionary *item = nil;
    if ((arrayPraise && [arrayPraise count] > 1)) {
        item = [self.arrayWorkGroupReview objectAtIndex:section-2];
        section = section-2;
    }else{
        item = [self.arrayWorkGroupReview objectAtIndex:section-1];
        section = section-1;
    }
    
    long long commentId = -1;
    if ([item objectForKey:@"id"]) {
        commentId = [[item safeObjectForKey:@"id"] longLongValue];
    }
    
    [self trendOption:TREND_DELETE_A_COMMENT withTrendsId:trendsId withCommentId:commentId indexTrends:section];
    
    //    NSInteger m_Type = 1;
    //    if ([self.dicWorkGroupDetails objectForKey:@"moduleType"]) {
    //        m_Type = [[self.dicWorkGroupDetails objectForKey:@"moduleType"] integerValue];
    //    }
    //
    //    ///OA
    //    if (m_Type == 1) {
    //
    //    }else if(m_Type == 2){
    //        ///CRM
    //        [self trendOption:@"" withTrendsId:trendsId withCommentId:commentId indexTrends:section];
    //    }
    
}

#pragma mark - 举报
-(void)reportToService{
    ReportToServiceViewController *controller = [[ReportToServiceViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - 收藏/取消收藏/赞/删除动态 删除评论
-(void)trendOption:(NSString *)url  withTrendsId:(long long)trendsId withCommentId:(long long)commentId  indexTrends:(NSInteger)section{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    NSString *action = @"";
    ///删除评论  评论id
    if ([url isEqualToString:TREND_DELETE_A_COMMENT]) {
        [params setObject:[NSNumber numberWithLongLong:commentId] forKey:@"commentId"];
        ///(类型<1：动态 2：博客 3：知识库  4:任务 5:工作报告>)
        [params setObject:@"1" forKey:@"objectType"];
        action = MOBILE_SERVER_IP_OA;
        [params setObject:[NSNumber numberWithLongLong:trendsId] forKey:@"trendsId"];
    }else  if ([url isEqualToString:kNetPath_Common_DeleteActivity]) {
        action = MOBILE_SERVER_IP_CRM;
        [params setObject:[NSNumber numberWithLongLong:trendsId] forKey:@"id"];
    }
    else {
        action = MOBILE_SERVER_IP_OA;
        [params setObject:[NSNumber numberWithLongLong:trendsId] forKey:@"trendsId"];
    }
    
    
    __weak typeof(self) weak_self = self;
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",action,url] params:params success:^(id responseObj) {
        
        NSLog(@" responseObj:%@",responseObj);
        //字典转模型
        NSDictionary *resultdic = responseObj;
        
        if (resultdic && [[resultdic objectForKey:@"status"] integerValue] == 0) {
            [weak_self setViewRequestSusscessByTrendOptions:url index:section];
        } else if (resultdic && [[resultdic objectForKey:@"status"] integerValue] == 2) {
            NSString *desc = [resultdic safeObjectForKey:@"desc"];
            kShowHUD(desc,nil);
            //如果提示  该动态被删除，则刷新列表
            if (weak_self.BlackFreshenBlock) {
                weak_self.BlackFreshenBlock();
            }
            [weak_self.navigationController popViewControllerAnimated:YES];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self trendOption:url withTrendsId:trendsId withCommentId:commentId indexTrends:section];
            };
            [comRequest loginInBackground];
        }
        else{
            NSString *desc = [resultdic safeObjectForKey:@"desc"];
            NSLog(@"desc:%@",desc);
            ///失败 做相应处理
            if ([url isEqualToString:ADD_FAVORITE]) {
                [CommonFuntion showToast:@"收藏失败" inView:self.view];
            }else if([url isEqualToString:DELETE_FAVORITE]){
                [CommonFuntion showToast:@"取消收藏失败" inView:self.view];
            }else if([url isEqualToString:FEED_UP_ADD]){
                ///赞操作失败
                [CommonFuntion showToast:@"点赞失败" inView:self.view];
            }else if([url isEqualToString:DELETE_DYNAMIC]){
                [CommonFuntion showToast:@"删除动态失败" inView:self.view];
            }else if([url isEqualToString:TREND_DELETE_A_COMMENT]){
                [CommonFuntion showToast:@"删除评论失败" inView:self.view];
            }else if([url isEqualToString:kNetPath_Common_DeleteActivity]){
                //                kShowHUD(@"删除动态失败");
                [CommonFuntion showToast:@"删除活动记录失败" inView:self.view];
            }
        }
        
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        [CommonFuntion showToast:NET_ERROR inView:self.view];
    }];
}

// 收藏/取消收藏/赞/删除动态操作请求成功时数据处理
-(void)setViewRequestSusscessByTrendOptions:(NSString *)action index:(NSInteger)section
{
    ///收藏 取消收藏
    if ([action isEqualToString:ADD_FAVORITE] || [action isEqualToString:DELETE_FAVORITE]) {
        
        [self updateFavFlag:action];
        if (self.UpdateFavStatus) {
            self.UpdateFavStatus(section,action);
        }
        
        if ([action isEqualToString:ADD_FAVORITE]) {
            [CommonFuntion showToast:@"收藏成功" inView:self.view];
        }else if([action isEqualToString:DELETE_FAVORITE]){
            [CommonFuntion showToast:@"取消收藏成功" inView:self.view];
        }
        
    }else if ( [action isEqualToString:FEED_UP_ADD]){
        ///赞操作
        [self updateFeedCountAndFlag];
        if (self.UpdatePriaseStatus) {
            self.UpdatePriaseStatus(section);
        }
    }else if([action isEqualToString:DELETE_DYNAMIC]){
        
        if (self.DeleteTrendStatus) {
            self.DeleteTrendStatus(section);
        }
        [CommonFuntion showToast:@"删除动态成功" inView:self.view];
        [self.navigationController popViewControllerAnimated:YES];
    }else if([action isEqualToString:TREND_DELETE_A_COMMENT]){
        [CommonFuntion showToast:@"删除评论成功" inView:self.view];
        [self updateComments:section];
    }else if([action isEqualToString:kNetPath_Common_DeleteActivity]){
        //                kShowHUD(@"删除动态失败");
        [CommonFuntion showToast:@"删除活动记录成功" inView:self.view];
        if (self.DeleteTrendStatus) {
            self.DeleteTrendStatus(section);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - 更新收藏标记
-(void)updateFavFlag:(NSString *)action {
    NSLog(@"updateFavFlag  action:%@ ",action);
    NSInteger isfav = 1;
    if ([action isEqualToString:ADD_FAVORITE]) {
        isfav = 0;
    }else if([action isEqualToString:DELETE_FAVORITE]){
        isfav = 1;
    }
    
    ///修改本地数据
    [self.dicWorkGroupDetails setObject:[NSNumber numberWithInteger:isfav] forKey:@"isfav"];
    ///刷新当前cell
    [self.tableviewWorkGroupReviews reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],nil] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - 刷新赞个数与标志
-(void)updateFeedCountAndFlag{
    NSLog(@"updateFeedCountAndFlag");
    ///已经被赞的个数
    NSInteger feedUpCount = [[self.dicWorkGroupDetails objectForKey:@"feedUpCount"] integerValue];
    
    feedUpCount ++;
    ///修改本地数据
    
    [self.dicWorkGroupDetails setObject:[NSNumber numberWithInteger:0] forKey:@"isFeedUp"];
    [self.dicWorkGroupDetails setObject:[NSNumber numberWithInteger:feedUpCount] forKey:@"feedUpCount"];
    
    ///刷新当前cell
    [self.tableviewWorkGroupReviews reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],nil] withRowAnimation:UITableViewRowAnimationNone];
    
    ////同时更新底部赞按钮
//    btnPraise.enabled = NO;
    [btnPraise setImage:[UIImage imageNamed:@"feed_praise_select.png"] forState:UIControlStateNormal];
//    btnPraise.enabled = NO;
    [btnPraise setImage:[UIImage imageNamed:@"feed_praise_select.png"] forState:UIControlStateNormal];
    
    [btnPraise setTitle:[NSString stringWithFormat:@" %ti",feedUpCount] forState:UIControlStateNormal];
}


#pragma mark - 刷新评论个数  增1还是减1
-(void)updateReviewComment:(NSString*) optionFlag{
    NSLog(@"updateReviewComment");
    ///已经被评论的个数
    NSInteger commentCount = [[self.dicWorkGroupDetails objectForKey:@"commentCount"] integerValue];
//    if ([self.dicWorkGroupDetails objectForKey:@"commentCount"]) {
//        commentCount = [[self.dicWorkGroupDetails objectForKey:@"commentCount"] integerValue];
//    }
    if ([optionFlag isEqualToString:@"add"]) {
        commentCount ++;
    }else{
        commentCount --;
    }
    
    ///修改本地数据
    
    [self.dicWorkGroupDetails setObject:[NSNumber numberWithInteger:commentCount] forKey:@"commentCount"];
    
    ///刷新当前cell
    [self.tableviewWorkGroupReviews reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],nil] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - 刷新评论列表
-(void)updateComments:(NSInteger)section{
    if (self.arrayWorkGroupReview && [self.arrayWorkGroupReview count] > section ) {
        [self.arrayWorkGroupReview removeObjectAtIndex:section];
        [self.tableviewWorkGroupReviews reloadData];
        ///本地数据评论个数+1
        [self updateReviewComment:@"delete"];
        if (self.CommentTrendStatus) {
            self.CommentTrendStatus(self.sectionOfDic,@"delete");
        }
    }
}



#pragma mark - 发表评论
-(void)sendAComment:(NSString *)content atIds:(NSArray *)atIds{
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    long long trendsId = -1;
    if ([self.dicWorkGroupDetails objectForKey:@"id"]) {
        trendsId = [[self.dicWorkGroupDetails objectForKey:@"id"] longLongValue];
    }
    [params setObject:[NSNumber numberWithLongLong:trendsId] forKey:@"trendsId"];
    NSString *transString = [NSString stringWithString:[content stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [params setObject:transString forKey:@"content"];
    ///(类型(1：动态 2：博客 3：知识库  4:任务 5:工作报告))
    [params setObject:@"1" forKey:@"objectType"];
    
    ///（@人id集合,以“,”分隔开）
    [params setObject:[CommonFuntion getStringStaffIds:atIds] forKey:@"staffIds"];
    __weak typeof(self) weak_self = self;
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA,TREND_ADD_A_COMMENT] params:params success:^(id responseObj) {
        
        NSLog(@" responseObj:%@",responseObj);
        //字典转模型
        NSDictionary *resultdic = responseObj;
        
        if (resultdic && [[resultdic objectForKey:@"status"] integerValue] == 0) {
            ///重新加载评论列表
            strReview = @"";
            textViewReview.text = @"";
            ///本地数据评论个数+1
            [weak_self updateReviewComment:@"add"];
            if (weak_self.CommentTrendStatus) {
                weak_self.CommentTrendStatus(weak_self.sectionOfDic,@"add");
            }
            
            pageNo = 1;
            
            [weak_self getCommentsData];
            [weak_self.tableviewWorkGroupReviews reloadData];
            
        } else if (resultdic && [[resultdic objectForKey:@"status"] integerValue] == 2) {
            NSString *desc = [resultdic safeObjectForKey:@"desc"];
            kShowHUD(desc,nil);
            //如果提示  该动态被删除，则刷新列表
            if (weak_self.BlackFreshenBlock) {
                weak_self.BlackFreshenBlock();
            }
            [weak_self.navigationController popViewControllerAnimated:YES];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self sendAComment:content atIds:atIds];
            };
            [comRequest loginInBackground];
        }else{
            NSString *desc = [resultdic safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"发表评论失败";
            }
            NSLog(@"desc:%@",desc);
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        [CommonFuntion showToast:NET_ERROR inView:self.view];
    }];
    
}


#pragma mark - 获取评论列表数据
-(void)getCommentsData{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    long long trendsId = -1;
    if ([self.dicWorkGroupDetails objectForKey:@"id"]) {
        trendsId = [[self.dicWorkGroupDetails objectForKey:@"id"] longLongValue];
    }
    [params setObject:[NSNumber numberWithLongLong:trendsId] forKey:@"trendsId"];
    [params setObject:[NSNumber numberWithInteger:pageNo] forKey:@"pageNo"];
    [params setObject:[NSNumber numberWithInt:PageSize] forKey:@"pageSize"];
    ///(类型<1：动态 2：博客 3：知识库  4:任务 5:工作报告>)
    [params setObject:@"1" forKey:@"objectType"];
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA,TREND_DETAILS_COMMENT_LIST] params:params success:^(id responseObj) {
        
        NSLog(@"responseObj:%@",responseObj);
        //字典转模型
        NSDictionary *resultdic = responseObj;
        
        if (resultdic && [[resultdic objectForKey:@"status"] integerValue] == 0) {
            [self setViewRequestSusscess:resultdic];
        }else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getCommentsData];
            };
            [comRequest loginInBackground];
            ///刷新UI
            [self reloadRefeshView];
        }
        else{
            NSString *desc = [resultdic safeObjectForKey:@"desc"];
            ///加载失败 做相应处理
            [self setViewRequestFaild:desc];
            ///刷新UI
            [self reloadRefeshView];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        ///网络失败 做相应处理
        [self setViewRequestFaild:NET_ERROR];
        ///刷新UI
        [self reloadRefeshView];
    }];
}

// 请求成功时数据处理
-(void)setViewRequestSusscess:(NSDictionary *)resultdic
{
    BOOL isFirst = FALSE;
    if (pageNo == 1) {
        isFirst = TRUE;
        [arrayPraise removeAllObjects];
        ///点赞列表
        NSArray  *arrayPriases = nil;
        if ([resultdic objectForKey:@"praises"] ) {
            arrayPriases = [resultdic objectForKey:@"praises"];
        }
        [arrayPraise addObjectsFromArray:arrayPriases];
        
        if (arrayPriases && [arrayPriases count] > 0) {
            NSDictionary *itemTag = [NSDictionary dictionaryWithObjectsAndKeys:@"feed_praise.png",@"icon",@"0",@"id",@"tag",@"name", nil];
            [arrayPraise insertObject:itemTag atIndex:0];
        }
        
        NSLog(@"arrayPraise:%@",arrayPraise);
    }
    
    ///评论列表
    NSArray  *arrayComments = nil;
    if ([resultdic objectForKey:@"comments"]) {
        arrayComments = [resultdic  objectForKey:@"comments"];
    }
    
    NSLog(@"arrayComments:%ti",[arrayComments count]);
    ///有数据返回
    if (arrayComments && [arrayComments count] > 0) {
        
        if(pageNo == 1)
        {
            [self.arrayWorkGroupReview removeAllObjects];
            
        }
        
        ///页码++
        if ([arrayComments count] == PageSize) {
            pageNo++;
            isMoreData = YES;
            [self.tableviewWorkGroupReviews setFooterHidden:NO];
        }else
        {
            isMoreData = NO;
            ///隐藏上拉刷新
            [self.tableviewWorkGroupReviews setFooterHidden:YES];
        }
        
        ///添加当前页数据到列表中...
        [self.arrayWorkGroupReview addObjectsFromArray:arrayComments];
        
    }else{
        isMoreData = NO;
        ///隐藏上拉刷新
        [self.tableviewWorkGroupReviews setFooterHidden:YES];
        ///返回为空
        ///若是第一页 读取是否存在缓存
        if(pageNo == 1)
        {
            
        }
    }
    
    if (self.arrayWorkGroupReview && [self.arrayWorkGroupReview count] > 0) {
        
    }else{
        [self showKeyBoardByFlag];
    }
    ///刷新UI
    [self reloadRefeshView];
    if (isFirst) {
        [self.tableviewWorkGroupReviews scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

// 请求失败时数据处理
-(void)setViewRequestFaild:(NSString *)desc
{
    ///若是第一页 读取是否存在缓存
    if(pageNo == 1)
    {
        
    }
    [CommonFuntion showToast:desc inView:self.view];
}

/*
 #pragma mark - 播放语音
 - (void)playVoiceWithVoiceUrl:(NSString *)voiceUrl WithIndexPathSection:(NSInteger)section {
 NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
 WorkGroupRecordCellB *cell = (WorkGroupRecordCellB *)[self.tableviewWorkGroupReviews cellForRowAtIndexPath:indexPath];
 NSString *imgSting = @"other";
 if (_playback) {
 [_playback pause];
 _playback = nil;
 
 if (_cell != nil) {
 NSLog(@"图片复位-----：%@",_cell);
 _cell.imgVoice.image = [UIImage imageNamed:[NSString stringWithFormat:@"voice_sign_%@_3.png", imgSting]];
 }else{
 _cell = cell;
 }
 }
 
 dispatch_async(dispatch_get_global_queue(0, 0), ^{
 
 AFSoundItem *item = [[AFSoundItem alloc] initWithStreamingURL:[NSURL URLWithString:voiceUrl]];
 
 _playback = [[AFSoundPlayback alloc] initWithItem:item];
 [_playback play];
 
 
 dispatch_async(dispatch_get_main_queue(), ^{
 NSLog(@"----->");
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
 cell.imageView.image = [UIImage imageNamed:imgName];
 
 } andFinishedBlock:^(void){
 NSLog(@"andFinishedBlock");
 cell.imgVoice.image = [UIImage imageNamed:[NSString stringWithFormat:@"voice_sign_%@_3.png", imgSting]];
 
 }];
 });
 
 });
 
 }
 */

#pragma mark - 上拉下拉刷新相关事件
//集成刷新控件
- (void)setupRefresh
{
    //上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableviewWorkGroupReviews addFooterWithTarget:self action:@selector(footerRereshing)];
}

// 结束加载
-(void)reloadRefeshView{
    // 刷新列表
    [self.tableviewWorkGroupReviews reloadData];
    [self.tableviewWorkGroupReviews footerEndRefreshing];
}

// 上拉
- (void)footerRereshing
{
    NSLog(@"footerRereshing--上拉-->");
    
    //    if ([self.tableviewWorkGroupReviews isFooterRefreshing]) {
    //        return;
    //    }
    [self getCommentsData];
}

@end
