//
//  XLFTaskDetailViewController.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFTaskDetailViewController.h"
#import "NSString+Common.h"
#import <XLForm.h>
#import "XLFTaskImageTextCell.h"
#import "XLFTextValueCell.h"
#import "XLFTextImageCell.h"
#import "XLFTextImagesCell.h"
#import "CommentItem.h"
#import "UIButton+Create.h"
#import "HPGrowingTextView.h"
#import "AFNHttp.h"
#import "CommonConstant.h"
#import "ExportAddressViewController.h"
#import "AddressBook.h"
#import "CommonFuntion.h"
#import <MBProgressHUD.h>
#import "AddressBookViewController.h"
#import "EditTextForDetailController.h"
#import "KnowledgeFileDetailsViewController.h"
//#import "XLFChoiceBusinessViewController.h"
//#import "XLTaskRemindController.h"
#import "SKTPickerView.h"
#import "FMDB_SKT_CACHE.h"
#import "AddressSelectedController.h"
#import "AddressBookViewController.h"
#import "ScheduleAcceptMemberPreController.h"
#import "ShowMembersViewController.h"
#import "XLFTaskDetailForFilesCell.h"
#import "XLTotalCell.h"
#import "SKTSelectMemberController.h"
#import "SKTSelectMemberPreController.h"
#import "RelatedBusinessController.h"
#import "ExportAddress.h"
#import "EditAddressViewController.h"

#import "WorkGroupRecordViewController.h"
#import "ActivityDetailViewController.h"
#import "LeadDetailViewController.h"
#import "CustomerDetailViewController.h"
#import "ContactDetailViewController.h"
#import "OpportunityDetailController.h"
#import "Lead.h"
#import "Contact.h"
#import "Customer.h"
#import "SaleChance.h"
#import "OAComment.h"
#import "MJRefresh.h"
#import "InfoViewController.h"

@interface XLFTaskDetailViewController ()<HPGrowingTextViewDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, PickerDataChangeDelegate, TTTAttributedLabelDelegate>
{
    UIView *keyboardContainerView; //底部view
    HPGrowingTextView *textViewReview;//键盘
    NSString *strReview;
    
    ///测试数据  评论、转发、赞  个数
    int typeCell;
    //标记 页面滑动需不需要 隐藏 底部view
    NSString *typeStr;
    SKTPickerView *sktPickView;
    NSArray *remindArray; //提醒时间数组
    NSString *isAllEdit; //0不可编辑  1可编辑 (除责任人外)
    NSString *isWonerEdit; // 0 不可编辑 1可编辑(责任人事件)
    NSString *isRemindEdit; //提醒时间 0不可编辑  1可编辑（除待接受任务）
    NSInteger commentID; //评论ID
    
    NSString *valueStr;
    NSMutableArray *newMemberIds; //修改参与人之后的ids
    
    ///任务类型标记  是不是待接收状态   1是
    NSString *flagOfTaskType;
    
    NSInteger typeForItem;
}
@property (nonatomic, assign) long long taskID; //任务ID
@property (nonatomic, assign) NSInteger creatFlag; //创建人标记 （0可操作 !0不可操作）
@property (nonatomic, assign) NSInteger ownerFlag; //负责人标记 （0可操作 !0不可操作）
@property (nonatomic, strong) NSMutableDictionary *taskDetailDict; //存储获取的原数据
@property (nonatomic, strong) NSString *reasonStr; //拒绝原因
@property (nonatomic, strong) NSString *taskNameStr; //当前任务名称

@property (nonatomic, strong) NSString *changeOwnerType; //修改负责人之后传入类型
@property (nonatomic, strong) NSString *againTask; //重新分配（1）
@property (nonatomic, strong) NSString *ownerIcon; //责任人头像

@property (strong, nonatomic) NSMutableDictionary *commentParams;
@property (strong, nonatomic) XLFormRowDescriptor *deleteRow;   // 删除评论时标记行
@property (assign, nonatomic) BOOL isComment;       // 是否有评论

@property (nonatomic, copy) void(^refreshBlock)(NSDictionary *);
@property (nonatomic, assign) PushControllerType sourceType;

- (void)sendRequestToDetail;
- (void)sendRequestToComment;
- (void)sendRequestToCommentForRefresh;
- (void)sendRequestToCommentForReloadMore;
@end

@implementation XLFTaskDetailViewController

#pragma mark - ViewController Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = TABLEVIEW_BG_COLOR;
    
    XLFormDescriptor *form = [XLFormDescriptor formDescriptor];
    self.form = form;
    
    [self.tableView setHeight:kScreen_Height - 50];
    
    //关联业务
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRefresh:) name:@"relatedBusiness" object:nil];
    
    //返回 -1 ~ 8
    remindArray = [[NSArray alloc] initWithObjects:@"不提醒",@"准时",@"提前5分钟",@"提前10分钟",@"提前30分钟",@"提前1小时",@"提前2小时",@"提前6小时",@"提前1天",@"提前2天", nil];
    _taskDetailDict = [NSMutableDictionary dictionary];
    
    _commentParams = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [_commentParams setObject:_uid forKey:@"trendsId"];
    [_commentParams setObject:@5 forKey:@"objectType"];
    [_commentParams setObject:@1 forKey:@"pageNo"];
    [_commentParams setObject:@10 forKey:@"pageSize"];

    [self sendRequestToDetail];
    
    [self.tableView addFooterWithTarget:self action:@selector(sendRequestToCommentForReloadMore)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self addObserverOfKeyBoard];
    
    if (typeStr && [typeStr isEqualToString:@"Hidden"] && textViewReview.text && textViewReview.text.length > 0) {
        [self creatKeyBoardView];
//        [textViewReview becomeFirstResponder];
    }else{
        if (flagOfTaskType && [flagOfTaskType isEqualToString:@"1"]) {
             keyboardContainerView.hidden = YES;
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    strReview = textViewReview.text;
    [textViewReview resignFirstResponder];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self removeObserverOfKeyBoard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)notificationRefresh:(NSNotification *)notification {
    if (_refreshBlock) {
        _refreshBlock([notification object]);
    }
}
- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue {
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
}

- (void)sendRequestToDetail {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [params setObject:_uid forKey:@"taskId"];
    
    [self.view beginLoading];
    NSString *action = [NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, GET_OFFICE_TASK_DETAIL];
    __weak typeof(self) weak_self = self;
    [AFNHttp post:action params:params success:^(id responseObj) {
        [self.view endLoading];
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            if ([responseObj objectForKey:@"taskDetail"]) {
                NSDictionary *bodyDic = [responseObj objectForKey:@"taskDetail"];
                [self getDataSoucerForTableView:bodyDic];
                [self sendRequestToComment];
            }
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self sendRequestToDetail];
            };
            [comRequest loginInBackground];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 1) {
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"已被删除";
            }
            kShowHUD(desc,nil);
            [weak_self.navigationController popViewControllerAnimated:YES];
        } else {
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            kShowHUD(desc,nil);
        }
    } failure:^(NSError *error) {
        [self.view endLoading];
        NSLog(@"任务详情信息 error:%@", error);
    }];
}

- (void)sendRequestToComment {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, TREND_DETAILS_COMMENT_LIST] params:_commentParams success:^(id responseObj) {
            [self.tableView footerEndRefreshing];
            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
            for (NSDictionary *tempDict in responseObj[@"comments"]) {
                OAComment *comment = [NSObject objectOfClass:@"OAComment" fromJSON:tempDict];
                for (NSDictionary *tempAltsDict in tempDict[@"alts"]) {
                    User *altUser = [NSObject objectOfClass:@"User" fromJSON:tempAltsDict];
                    [comment.altsArray addObject:altUser];
                }
                [tempArray addObject:comment];
            }
            
            XLFormSectionDescriptor *section;
            if (!tempArray.count) {
                _isComment = NO;
            }
            else if ([_commentParams[@"pageNo"] isEqualToNumber:@1]) {
                _isComment = YES;
                section = [XLFormSectionDescriptor formSectionWithTitle:[NSString stringWithFormat:@"评论(%@)", responseObj[@"totalCount"]]];
                [self.form addFormSection:section];
            }
            else {
                section = self.form.formSections.lastObject;
            }
            
            for (OAComment *tempComment in tempArray) {
                XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:[NSString stringWithFormat:@"%@", tempComment.id] rowType:XLFormRowDescriptorTypeTotal];
                row.value = tempComment;
                row.action.formBlock = ^(XLFormRowDescriptor *rowDescriptor) {
                    OAComment *comment = rowDescriptor.value;
                    if ([appDelegateAccessor.moudle.userId isEqualToString:[NSString stringWithFormat:@"%@", comment.creator.id]]) {
                        _deleteRow = row;
                        commentID = [comment.id integerValue];
                        [self showAlertViewForDeleteComment];
                    }else{
                        ///负责将当前user的姓名 添加到输入框内容中
                        ///拼接@姓名到编辑框
                        NSString *strText = @"";
                        if (textViewReview.text) {
                            strText = textViewReview.text;
                        }
                        strReview = [NSString stringWithFormat:@"%@ @%@ ",strText, comment.creator.name];
                        
                        [self creatKeyBoardView];
                        [textViewReview becomeFirstResponder];
                        textViewReview.text = strReview;
                    }
                };
                XLTotalCell *cell = (XLTotalCell*)[row cellForFormController:self];
                cell.contentLabel.delegate = self;
                [section addFormRow:row];
            }
            
            if (tempArray.count == 10) {
                self.tableView.footerHidden = NO;
            }
            else {
                self.tableView.footerHidden = YES;
            }
            
        } failure:^(NSError *error) {
            [self.tableView footerEndRefreshing];
        }];
    });
}

- (void)sendRequestToCommentForRefresh {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, TREND_DETAILS_COMMENT_LIST] params:_commentParams success:^(id responseObj) {
            XLFormSectionDescriptor *lastSection = self.form.formSections.lastObject;
            if ([responseObj[@"totalCount"] integerValue]) {
                lastSection.title = [NSString stringWithFormat:@"评论(%@)", responseObj[@"totalCount"]];
                [self.tableView reloadData];

//                NSLog(@"numberOfSection:%ti",self.tableView.numberOfSections);
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.tableView.numberOfSections-1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                
            }
            else {
                _isComment = NO;
                [self.form removeFormSection:lastSection];
            }
            
        } failure:^(NSError *error) {
        }];
    });
}

- (void)sendRequestToCommentForReloadMore {
    [_commentParams setObject:@([_commentParams[@"pageNo"] integerValue] + 1) forKey:@"pageNo"];
    [self sendRequestToComment];
}

#pragma mark - right nav Bar
- (void)customRightNavBar:(NSInteger )type {
    NSString *title = @"";
    NSInteger tag = 0;
    if (type == 0) {
        title = @"删除";
        tag = 0;
    } else if (type == 2){
        title = @"退出";
        tag = 1;
    } else {
        return;
    }
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(deleteButtonPress:)];
    rightButtonItem.tag = tag;
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}



///根据详情 设置菜单按钮  0 创建人  1 责任人  2  参与人
-(void)addRightBtnMenu:(NSDictionary *)item withType: (NSInteger )type{
    /*
     if (curUserStatus == 0) {
     // 创建人：完成/重启，删除
     mTopView.setRightImage1(R.drawable.menu_show_more_active);
     } else if (curUserStatus == 1) {
     // 已接受任务的责任人：完成/重启
     if (2 == detail.getTaskDetail().getTaskStatus()) {
     // 未完成
     mTopView.setRightText(getString(R.string.common_finish));
     } else if (3 == detail.getTaskDetail().getTaskStatus()) {
     // 已完成
     mTopView.setRightText(getString(R.string.restart_string));
     }
     } else if (curUserStatus == 2) {
     // 参与人：退出
     mTopView.setRightText(getString(R.string.common_quit_text));
     }
     */
    //右上角按钮------->删除，退出，隐藏
    /*
     任务----不同身份操作权限
     创建人：删除，完成，重启，修改详情中的所有内容
     负责人：接受，拒绝，完成，重启，修改除负责人之外的所有信息
     参与人：退出任务 编辑提醒时间
     */
    
    //status值    1待接收,2未完成,3已完成,4被拒绝
    NSInteger statusValue = 0;
    if (item) {
        statusValue = [[item objectForKey:@"taskStatus"] integerValue];
    }
    
    ///创建人
    if (type == 0) {
        
        ///待接收状态
        if (statusValue == 1) {
            UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStyleDone target:self action:@selector(deleteButtonPress:)];
            rightButtonItem.tag = 0;
            self.navigationItem.rightBarButtonItem = rightButtonItem;
        }else{
            UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_showMore_active"] style:UIBarButtonItemStylePlain target:self action:@selector(moreOptionMenu)];
            self.navigationItem.rightBarButtonItem = rightItem;
        }

    }else if(type == 1){
        ///责任人
        UIBarButtonItem *rightButtonItem;
        ///已完成
        if (statusValue == 3) {
            rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"重启" style:UIBarButtonItemStyleDone target:self action:@selector(showAlertByResetThisTask)];
        }else if (statusValue == 2) {
            rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(showAlertByOverThisTask)];
        }
        self.navigationItem.rightBarButtonItem = rightButtonItem;
    }else if (type == 2){
        ///参与人
        UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStyleDone target:self action:@selector(deleteButtonPress:)];
        rightButtonItem.tag = 1;
        self.navigationItem.rightBarButtonItem = rightButtonItem;
    }
}

///更多操作按钮
-(void)moreOptionMenu{
    //status值    1待接收,2未完成,3已完成,4被拒绝
    NSInteger statusValue = 0;
    if (_taskDetailDict) {
        statusValue = [[_taskDetailDict objectForKey:@"taskStatus"] integerValue];
    }
    NSString *item = @"";
    NSString *title = nil;
    UIActionSheet *sheet;
    ///已完成
    if (statusValue == 3) {
        item = @"重启任务";
    }else if (statusValue == 4) {
        item = @"分配给他人";
        NSString *nameStr = @"";
        NSString *reasonStr = @"无";
        if ([_taskDetailDict objectForKey:@"owner"] && [[_taskDetailDict objectForKey:@"owner"] objectForKey:@"name"]) {
            nameStr = [[_taskDetailDict objectForKey:@"owner"] safeObjectForKey:@"name"];
        }
        if ([_taskDetailDict objectForKey:@"reason"]) {
            reasonStr = [_taskDetailDict safeObjectForKey:@"reason"];
        }
        
        title = [NSString stringWithFormat:@"\"%@\"拒绝接受该任务\n\n拒绝理由\n\n%@:%@", nameStr, nameStr, reasonStr];
    }
    else{
        item = @"完成任务";
    }
    
    sheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除任务", item, nil];
    sheet.tintColor = [UIColor blackColor];
    sheet.tag = 20101;
    [sheet showInView:self.view];
}

///重启任务
-(void)showAlertByResetThisTask{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否重启当前任务" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 2001;
    [alert show];
}

///完成任务
-(void)showAlertByOverThisTask{
    NSLog(@"完成任务");
    [self changOneTask:@"2"];
}


#pragma mark - Private Method
- (NSString*)getRemindTimeWithMinuteCount:(NSInteger)minute {
    NSInteger _minute = 0;
    NSInteger _hour = 0;
    NSInteger _day = 0;
    
    _day = minute/3600/24;
    _hour = minute/3600;
    _minute = minute/60;
    
    if (_day) {
        return [NSString stringWithFormat:@"提前%ld天", _day];
    }else if (_hour) {
        return [NSString stringWithFormat:@"提前%ld小时", _hour];
    }else if (_minute) {
        return [NSString stringWithFormat:@"提前%ld分钟", _minute];
    }else {
        return @"准时";
    }
}
#pragma mark - event response
- (void)deleteButtonPress:(UIBarButtonItem *)item {
    switch (item.tag) {
        case 0:
            [self showAlertViewForDelegate];
            break;
        case 1:
            [self showAlertViewForQuit];
            break;
            
        default:
            break;
    }
}
#pragma mark - 底部View
- (void)customBottomView:(NSString *)type {
    flagOfTaskType = type;
    //传值过来标记显示格式
    if ([type isEqualToString:@"0"]) {
        [self creatKeyBoardView];
    } else {
        NSInteger viewHeight = 50;
        NSInteger btnWidth = (kScreen_Width - 20 * 4) / 3;
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height - viewHeight, kScreen_Width, viewHeight)];
        bottomView.backgroundColor = [UIColor whiteColor];
        bottomView.layer.borderColor = [UIColor colorWithHexString:@"cbcdcd"].CGColor;
        bottomView.layer.borderWidth = 1;
        NSArray *titleArr = @[@"接受", @"拒绝", @"评论"];
        for (int i = 0; i < [titleArr count]; i++) {
            UIButton *actionBtn = [UIButton createButtonWithFrame:CGRectMake( 20 + (20 + btnWidth) * i, 5, btnWidth, viewHeight - 10) Target:self Selector:@selector(bottomButtonAction:) Image:nil ImagePressed:nil];
            [actionBtn setTitle:titleArr[i] forState:UIControlStateNormal];

            actionBtn.titleLabel.font = [UIFont systemFontOfSize:16];
            [actionBtn.layer setMasksToBounds:YES];
            [actionBtn.layer setCornerRadius:6];
            [actionBtn.layer setBorderWidth:1];
            actionBtn.layer.borderColor = [UIColor colorWithHexString:@"cbcdcd"].CGColor;
            [actionBtn setTitleColor:[UIColor colorWithHexString:@"585858"] forState:UIControlStateNormal];
            actionBtn.tag = 200 + i;
            [bottomView addSubview:actionBtn];
        }
        [self.view addSubview:bottomView];
    }
}
// 底部按钮点击事件 100@艾特 200接受 201拒绝 202评论
- (void)bottomButtonAction:(UIButton *)button {
    switch (button.tag) {
        case 100:
            NSLog(@"艾特好友");
            [self pushToAddressBook];
            [self creatKeyBoardView];
            
            if ([flagOfTaskType isEqualToString:@"1"]) {
                typeStr = @"Hidden";
            }else{
                typeStr = @"NoHidden";
            }
            
            break;
        case 200:
            NSLog(@"接受");
            [self deleteOrQuitOneTask:_taskID url:GET_OFFICE_TASK_ACCEPT];
            break;
        case 201:
            NSLog(@"拒绝");
            [self showAlertViewForRefuse];
            break;
        case 202:
            NSLog(@"评论");
            [self creatKeyBoardView];
            [textViewReview becomeFirstResponder];
            typeStr = @"Hidden";
            break;
        default:
            break;
    }
}
#pragma mark - 选择好友
- (void)pushToAddressBook {
    __weak typeof(self) weak_self = self;
    ExportAddressViewController *controller = [[ExportAddressViewController alloc] init];
    controller.title = @"通讯录";
//    controller.typeOfViewFrom = ViewFromCommentAt;
    controller.valueBlock = ^(NSArray *selectedContact){
        [weak_self initSelectContactNameStr:selectedContact];
    };
    [self.navigationController pushViewController:controller animated:YES];
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
    [textViewReview becomeFirstResponder];
    textViewReview.text = strReview;
}
#pragma mark - 创建键盘view
-(void)creatKeyBoardView{
    if (keyboardContainerView == nil) {
        NSLog(@"clickReview---new->");
        keyboardContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height - 44, kScreen_Width, 44)];
        keyboardContainerView.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];;
        keyboardContainerView.layer.borderColor = [UIColor lightGrayColor].CGColor;;
        keyboardContainerView.layer.borderWidth = 0.5;
        
        //@ 按钮
        NSString *imageName = @"feed_comments_at.png";
        UIButton *aitBtn = [UIButton createButtonWithFrame:CGRectMake(12, 9, 26, 26) Target:self Selector:@selector(bottomButtonAction:) Image:imageName ImagePressed:imageName];
        aitBtn.tag = 100;
        [keyboardContainerView addSubview:aitBtn];
        
        textViewReview = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(50, 7, kScreen_Width-60, 30)];
        
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
        
        [self.view addSubview:keyboardContainerView];
        
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
    if ((self.view.bounds.size.height-keyboardBounds.size.height-keyboardContainerView.frame.size.height) < self.tableView.contentSize.height) {
        [self.tableView setContentOffset:CGPointMake(0.0, self.tableView.contentSize.height-(self.view.bounds.size.height-keyboardBounds.size.height-keyboardContainerView.frame.size.height)) animated:YES];
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
//    [self restTableviewConset];
    
    // commit animations
    [UIView commitAnimations];
}

-(void)restTableviewConset{
    [self.tableView setContentOffset:CGPointMake(0.0, self.tableView.contentSize.height-(self.view.bounds.size.height-keyboardContainerView.frame.size.height)) animated:YES];
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
    
    if ([typeStr isEqualToString:@"NoHidden"]) {
        keyboardContainerView.hidden = NO;
    } else if ([typeStr isEqualToString:@"Hidden"]) {
        keyboardContainerView.hidden = YES;
    }
    if (textViewReview.text && ![[textViewReview.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""] && textViewReview.text.length > 0) {
        ///有内容  发送
        [self sendACommentToSever];
    }
    return NO;
}
#pragma mark - 发表  获取  评论
- (void)sendACommentToSever {
    
    NSArray *arrayAtId = nil;
    ///读取缓存
//    NSArray *arrayCache = [FMDB_SKT_CACHE select_AddressBook_AllData];
    NSArray *arrayCache = [[FMDBManagement sharedFMDBManager] getAddressBookDataSource];
    if (arrayCache) {
        arrayAtId = [CommonFuntion getAtUserIds:textViewReview.text atArray:arrayCache isAddressBookArray:TRUE];
    }
    NSLog(@"arrayAtId:%@",arrayAtId);
    
    if (arrayAtId && arrayAtId.count > 9) {
        kShowHUD(@"你最多能@9人");
        return;
    }
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    long long trendsId = -1;
    if ([_taskDetailDict objectForKey:@"id"]) {
        trendsId = [[_taskDetailDict objectForKey:@"id"] longLongValue];
    }
    [params setObject:[NSNumber numberWithLongLong:trendsId] forKey:@"trendsId"];
    NSString *transString = [NSString stringWithString:[textViewReview.text stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [params setObject:transString forKey:@"content"];
    ///(类型(1:动态 2：博客 3：知识库 4:日程 5:任务 6:日报 7:周报 8:月报 9:审批))
    [params setObject:@"5" forKey:@"objectType"];
    
    ///（@人id集合,以“,”分隔开）
    [params setObject:[CommonFuntion getStringStaffIds:arrayAtId] forKey:@"staffIds"];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    // 发起请求
    __weak typeof(self) weak_self = self;
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA,TREND_ADD_A_COMMENT] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@" responseObj:%@",responseObj);
        //字典转模型
        NSDictionary *resultdic = responseObj;
        if (resultdic && [[resultdic objectForKey:@"status"] integerValue] == 0) {
            strReview = @"";
            textViewReview.text = @"";
            NSLog(@"发表评论成功");

            OAComment *item = [NSObject objectOfClass:@"OAComment" fromJSON:responseObj[@"comment"]];
            for (NSDictionary *tempAltsDict in responseObj[@"comment"][@"alts"]) {
                User *altUser = [NSObject objectOfClass:@"User" fromJSON:tempAltsDict];
                [item.altsArray addObject:altUser];
            }
            
            XLFormSectionDescriptor *commentSection;
            if (_isComment) {
                [self sendRequestToCommentForRefresh];
                commentSection = self.form.formSections.lastObject;
            }
            else {
                _isComment = YES;
                commentSection = [XLFormSectionDescriptor formSectionWithTitle:@"评论(1)"];
                [self.form addFormSection:commentSection];
            }
            
            XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:[NSString stringWithFormat:@"%@", item.id] rowType:XLFormRowDescriptorTypeTotal];
            row.value = item;
            row.action.formBlock = ^(XLFormRowDescriptor *rowDescriptor) {
                OAComment *comment = rowDescriptor.value;
                if ([appDelegateAccessor.moudle.userId isEqualToString:[NSString stringWithFormat:@"%@", comment.creator.id]]) {
                    _deleteRow = row;
                    commentID = [comment.id integerValue];
                    [self showAlertViewForDeleteComment];
                }else{
                    ///负责将当前user的姓名 添加到输入框内容中
                    ///拼接@姓名到编辑框
                    NSString *strText = @"";
                    if (textViewReview.text) {
                        strText = textViewReview.text;
                    }
                    strReview = [NSString stringWithFormat:@"%@ @%@ ",strText, comment.creator.name];
                    
                    [self creatKeyBoardView];
                    [textViewReview becomeFirstResponder];
                    textViewReview.text = strReview;
                }
            };
            XLTotalCell *cell = (XLTotalCell*)[row cellForFormController:self];
            cell.contentLabel.delegate = self;
            [commentSection addFormRow:row beforeRow:commentSection.formRows.firstObject];
            
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self sendACommentToSever];
            };
            [comRequest loginInBackground];
        } else{
            NSString *desc = [resultdic safeObjectForKey:@"desc"];
            NSLog(@"desc:%@",desc);
        }
    } failure:^(NSError *error) {
        [hud hide:YES];
        NSLog(@"error:%@",error);
    }];
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
#pragma mark - Table view data source
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == self.tableView)
    {
        strReview = textViewReview.text;
        [textViewReview resignFirstResponder];
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        if ([typeStr isEqualToString:@"NoHidden"]) {
            keyboardContainerView.hidden = NO;
        } else if ([typeStr isEqualToString:@"Hidden"]) {
//            keyboardContainerView.hidden = YES;
            if (typeStr && [typeStr isEqualToString:@"Hidden"] && textViewReview.text && textViewReview.text.length > 0) {
                [self creatKeyBoardView];
                //        [textViewReview becomeFirstResponder];
            }else{
                if (flagOfTaskType && [flagOfTaskType isEqualToString:@"1"]) {
                    keyboardContainerView.hidden = YES;
                }
            }
        }
    }
    
//    if (sktPickView) {
//        [sktPickView removeFromSuperview];
//        sktPickView = nil;
//        [self.tableView reloadData];
//    }
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components {
    
    User *user = [components objectForKey:@"altUser"];
    
    InfoViewController *infoController = [[InfoViewController alloc] init];
    infoController.title = @"个人信息";
    if ([appDelegateAccessor.moudle.userId integerValue] == [user.id integerValue]) {
        infoController.infoTypeOfUser = InfoTypeMyself;
    }else{
        infoController.infoTypeOfUser = InfoTypeOthers;
        infoController.userId = [user.id integerValue];
    }
    [self.navigationController pushViewController:infoController animated:YES];
}

#pragma mark - 提示框 -----> 删除，退出，拒绝任务   101删除 102退出 103拒绝  104重新分配任务 105删除评论
//删除任务
- (void)showAlertViewForDelegate {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除提示" message:@"删除后，该任务的评论文档等所有内容都将一起删除、且无法恢复！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    alert.tag = 101;
    [alert show];
}
//退出任务
- (void)showAlertViewForQuit {
    NSString *taskName = [NSString stringWithFormat:@"您确认要退出[%@]任务吗？", _taskNameStr];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:taskName delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alert.tag = 102;
    [alert show];
}
//拒绝任务
- (void)showAlertViewForRefuse {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"拒绝后，将向任务创建者发送通知，请问是否需要说明拒绝理由？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拒绝", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].clearButtonMode = UITextFieldViewModeWhileEditing;
    [alert textFieldAtIndex:0].placeholder = @"拒绝理由";
    alert.tag = 103;
    [alert show];
}
//重新非配任务
- (void)showAlertViewForCreate:(NSString *)ownerName {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"重新分配" message:[NSString stringWithFormat:@"是否重新分配给%@", ownerName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 104;
    [alert show];
}
//删除评论
- (void)showAlertViewForDeleteComment {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认删除评论" message:Nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 105;
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ///---
    
    if(alertView.tag == 101)
    {
        if(buttonIndex == 0)
        {
            return;
        } else if (buttonIndex == 1) {
            NSLog(@"删除任务");
            [self deleteOrQuitOneTask:_taskID url:GET_OFFICE_TASK_DELETE];
        }
        
    } else if(alertView.tag == 102)
    {
        if(buttonIndex == 0)
        {
            return;
        } else if (buttonIndex == 1) {
            [self deleteOrQuitOneTask:_taskID url:GET_OFFICE_TASK_QUIT];
            NSLog(@"退出任务");
        }
        
    } else if (alertView.tag == 103) {
        if (buttonIndex == 0) {
            return;
        } else if (buttonIndex == 1) {
            _reasonStr = [alertView textFieldAtIndex:0].text;
            
            if (_reasonStr == nil || [_reasonStr isEmpty] || _reasonStr.length == 0 || [[_reasonStr stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
                [CommonFuntion showToast:@"拒绝理由不能为空" inView:self.view];
                return;
            }
            [self deleteOrQuitOneTask:_taskID url:GET_OFFICE_TASK_REFUSE];
            NSLog(@"拒绝接受任务");
        }
    } else if (alertView.tag == 104) {
        if (buttonIndex == 0) {
            
        }else if (buttonIndex == 1) {
            XLFormRowDescriptor *rowDescriptor = [self.form  formRowWithTag:@"owner"];
//            rowDescriptor.value = @{@"text" : @"责任人",
//                                    @"image" : _ownerIcon,
//                                    @"uid" : @(_taskID),
//                                    @"isEdit" : isWonerEdit};
            [self editOneTaskOfDetail:nil withRowDestriptor:rowDescriptor];
        }
    } else if (alertView.tag == 105) {
        if (buttonIndex == 0) {
            
        } else if (buttonIndex == 1) {
            [self deleteOneComment:commentID];
        }
    }else if(alertView.tag == 2001){
        if(buttonIndex == 0)
        {
            return;
        } else if (buttonIndex == 1) {
             NSLog(@"重启任务");
            [self changOneTask:@"3"];
        }
    }
}
#pragma mark - delete Or Quit Tasks （删除/改变/拒绝/接受任务）
- (void)deleteOrQuitOneTask:(long long)taskID url:(NSString *)action {
    //存储 taskID 和 action
    long long saveTaskID = taskID;
    NSString *saveAction = action;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:[NSString stringWithFormat:@"%lld", taskID] forKey:@"taskId"];
    
    if ([action isEqualToString:GET_OFFICE_TASK_CHANGE]) {
//        NSInteger status;
//        [params setObject:[NSString stringWithFormat:@"%ld", status] forKey:@"status"];
    } else if ([action isEqualToString:GET_OFFICE_TASK_REFUSE]) {
        [params setObject:_reasonStr forKey:@"reason"];
    } else {
        
    }
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, action] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@"操作成功:%@", responseObj);
        if ([[responseObj objectForKey:@"status"] integerValue] == 0) {
            NSLog(@"%@", [responseObj objectForKey:@"desc"]);
            if (_RefreshTaskListBlock) {
                _RefreshTaskListBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self deleteOrQuitOneTask:saveTaskID url:saveAction];
            };
            [comRequest loginInBackground];
        } else {
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            kShowHUD(desc,nil);
        }
    } failure:^(NSError *error) {
        [hud hide:YES];
        NSLog(@"操作失败: %@", error);
    }];
    
}
#pragma 编辑任务详情接口
- (void)editOneTaskOfDetail:(NSString *)flagForMember withRowDestriptor:(XLFormRowDescriptor *)rowDestriptor {
    NSString *saveFlagForMember = flagForMember;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    /*
     参数：taskName(任务名称)
     priority(级别)
     description(描述)
     remind(提醒时间)
     planFinishDate(计划完成时间)
     memberIds(参与人)
     */
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    XLFormRowDescriptor *rowDescroptor;
    
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:_uid forKey:@"taskId"];
    
    rowDescroptor = [self.form formRowWithTag:@"title"];
    NSLog(@"任务名称%@", rowDescroptor.value);
    NSString *taskNameStr = @"";
    if (rowDescroptor.value && [rowDescroptor.value objectForKey:@"content"]) {
        taskNameStr = [rowDescroptor.value safeObjectForKey:@"content"];
    }
    [params setObject:taskNameStr forKey:@"taskName"];
    
    rowDescroptor = [self.form formRowWithTag:@"describe"];
    NSLog(@"任务描述%@", rowDescroptor.value);
    NSString *descStr = @"";
    if (rowDescroptor.value && [rowDescroptor.value objectForKey:@"value"]) {
        descStr = [rowDescroptor.value safeObjectForKey:@"value"];
    }
    [params setObject:descStr forKey:@"description"];
    
    rowDescroptor = [self.form formRowWithTag:@""];
    [params setObject:[_taskDetailDict safeObjectForKey:@"priority"] forKey:@"priority"];
    NSLog(@"级别暂无级别");
    //关联业务
    rowDescroptor = [self.form formRowWithTag:@"business"];
    if (rowDescroptor.value) {
        if ([[rowDescroptor.value allKeys] containsObject:@"businessType"]) {
            [params setObject:[rowDescroptor.value objectForKey:@"businessType"] forKey:@"businessType"]; //业务类型
        }
        if ([[rowDescroptor.value allKeys] containsObject:@"businessId"]) {
            [params setObject:[rowDescroptor.value objectForKey:@"businessId"] forKey:@"businessId"]; //业务id
        }    }
    
    rowDescroptor = [self.form formRowWithTag:@"owner"];
    NSString *ownerID = @"";
//    if ([_againTask isEqualToString:@"1"]) {
//        [params setObject:[NSString stringWithFormat:@"%lld", _taskID] forKey:@"belongId"];
//    } else {
        if (rowDescroptor.value && [rowDescroptor.value objectForKey:@"uid"]) {
            ownerID = [rowDescroptor.value safeObjectForKey:@"uid"];
        }
        [params setObject:ownerID forKey:@"belongId"];
//    }

    rowDescroptor = [self.form formRowWithTag:@"members"];
    NSMutableArray *menbersArr = [NSMutableArray arrayWithCapacity:0];
    if (rowDescroptor.value && [rowDescroptor.value count] > 0 && [[rowDescroptor.value allKeys] containsObject:@"uid"] && [rowDescroptor.value objectForKey:@"uid"]) {
        menbersArr = [rowDescroptor.value objectForKey:@"uid"];
    }
    NSString *menberIDsStr;
    if ([menbersArr count] > 0) {
        menberIDsStr = [menbersArr componentsJoinedByString:@","];
    } else {
        menberIDsStr = @"";
    }
    [params setObject:menberIDsStr forKey:@"memberIds"];
    
    rowDescroptor = [self.form formRowWithTag:@"ends"];
    NSLog(@"计划完成时间%@", rowDescroptor.value);
    NSString *endTimeStr = @"";
    if (rowDescroptor.value && [rowDescroptor.value objectForKey:@"value"]) {
        endTimeStr = [rowDescroptor.value safeObjectForKey:@"value"];
    }
    [params setObject:endTimeStr forKey:@"planFinishDate"];
    
    rowDescroptor = [self.form formRowWithTag:@"reminds"];
    NSLog(@"提醒时间%@", rowDescroptor.value);
    NSString *remindTimeStr = @"";
    NSString *indexStr = @"";
    if (rowDescroptor.value && [rowDescroptor.value objectForKey:@"value"]) {
        remindTimeStr = [rowDescroptor.value safeObjectForKey:@"value"];
    } else {
        remindTimeStr = @"不提醒";
        indexStr = @"-1";
    }
    NSInteger index = [remindArray indexOfObject:remindTimeStr] - 1;
    [params setObject:[NSString stringWithFormat:@"%ld", index] forKey:@"remind"];
    
    NSString *creatID = @"";
    if ([_againTask isEqualToString:@"1"]) {
        if ([_taskDetailDict objectForKey:@"createdBy"] && [[_taskDetailDict objectForKey:@"createdBy"] objectForKey:@"id"]) {
            creatID = [NSString stringWithFormat:@"%@", [[_taskDetailDict objectForKey:@"createdBy"] safeObjectForKey:@"id"]];
        }
        if (![creatID isEqualToString:appDelegateAccessor.moudle.userId]) {
            _changeOwnerType = @"2";
            
        } else {
            _changeOwnerType = @"1";
        }
    } else {
        _changeOwnerType = [_taskDetailDict safeObjectForKey:@"taskStatus"];
    }
    [params setObject:_changeOwnerType forKey:@"status"];
    
    __weak typeof(self) weak_self = self;
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, GET_OFFICE_TASK_CREATE] params:params success:^(id responseObj) {
        [hud hide:YES];
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            if ([flagForMember isEqualToString:@"member"] || [rowDestriptor.tag isEqualToString:@"describe"]) {
                [weak_self sendRequestToDetail];
            }
            [weak_self updateFormRow:rowDestriptor];
            if (_RefreshTaskListBlock) {
                _RefreshTaskListBlock();
            }
            if ([_againTask isEqualToString:@"1"]) {
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self editOneTaskOfDetail:saveFlagForMember withRowDestriptor:rowDescroptor];
            };
            [comRequest loginInBackground];
        }  else {
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            kShowHUD(desc,nil);
        }
    } failure:^(NSError *error) {
        [hud hide:YES];
        NSLog(@"新建任务失败：%@", error);
    }];
}

//赋值
- (void)getDataSoucerForTableView:(NSDictionary *)dict {
    
    self.form = nil;
    [self.tableView  reloadData];
    XLFormDescriptor *form = [XLFormDescriptor formDescriptor];
    self.form = form;
    
    NSDictionary *sourceDict = [NSDictionary dictionaryWithDictionary:dict];
    _changeOwnerType = @"";
    
    [_taskDetailDict removeAllObjects];
    _taskDetailDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    long long createUserID = 0; //创建人ID
    long long ownerUserID = 0; //负责人ID
    NSMutableArray *menberIDArr = [NSMutableArray arrayWithCapacity:0]; //存储参与人ID
    NSInteger statusValue; //status值    1待接收,2未完成,3已完成,4被拒绝
    
    if (sourceDict) {
        _taskID = [[sourceDict objectForKey:@"id"] longLongValue];
        
        if ([sourceDict objectForKey:@"taskStatus"]) {
            statusValue = [[sourceDict objectForKey:@"taskStatus"] integerValue];
        }
        if ([sourceDict objectForKey:@"createdBy"] && [[sourceDict objectForKey:@"createdBy"] objectForKey:@"id"]) {
            createUserID = [[[sourceDict objectForKey:@"createdBy"] objectForKey:@"id"] longLongValue];
        }
        if ([sourceDict objectForKey:@"owner"] && [[sourceDict objectForKey:@"owner"] objectForKey:@"id"]) {
            ownerUserID = [[[sourceDict objectForKey:@"owner"] objectForKey:@"id"] longLongValue];
        }
        if ([sourceDict objectForKey:@"members"] && [[sourceDict objectForKey:@"members"] count] != 0) {
            for (NSDictionary *menberDic in [sourceDict objectForKey:@"members"]) {
                if (menberDic && [menberDic objectForKey:@"id"]) {
                    [menberIDArr addObject:[menberDic objectForKey:@"id"]];
                }
            }
        }
    }
    //底部UI显示规则： 任务状态为待接收 + 创建人不是当前用户 + 负责人是当前用户
    NSString *flagStr = @"";
    if (statusValue == 1 && createUserID != [appDelegateAccessor.moudle.userId longLongValue] && ownerUserID == [appDelegateAccessor.moudle.userId longLongValue]) {
        flagStr = @"1"; //接受， 拒绝， 评论
    } else {
        flagStr = @"0"; //评论
    }
    
    [self customBottomView:flagStr];
    
    
    //拒绝弹框
    NSLog(@"%@", appDelegateAccessor.moudle.userId);
    if (statusValue == 4 && createUserID == [appDelegateAccessor.moudle.userId longLongValue]) {
        _againTask = @"1";
        //显示弹框
        [self showActionSheet:sourceDict];
    } else {
        _againTask = @"0";
    }
    
    
    
    //右上角按钮------->删除，退出，隐藏
    /*
    任务----不同身份操作权限
    创建人：删除，完成，重启，修改详情中的所有内容
    负责人：接受，拒绝，完成，重启，修改除负责人之外的所有信息
    参与人：退出任务 编辑提醒时间
     */
    typeForItem = 0;
    //①创建人
    if (createUserID == [appDelegateAccessor.moudle.userId longLongValue]) {
        typeForItem = 0;
        _creatFlag = 0;
        _ownerFlag = 0;
    }
    //②负责人
    if (ownerUserID == [appDelegateAccessor.moudle.userId longLongValue] && createUserID != [appDelegateAccessor.moudle.userId longLongValue]) {
        typeForItem = 1;
        _ownerFlag = 0;
        _creatFlag = 1;
    }
    //③参与人
    NSLog(@"当前用户%lld", [appDelegateAccessor.moudle.userId longLongValue]);
    for (NSString *userID in menberIDArr) {
        if (ownerUserID != [appDelegateAccessor.moudle.userId longLongValue] && createUserID != [appDelegateAccessor.moudle.userId longLongValue] && [userID longLongValue] == [appDelegateAccessor.moudle.userId longLongValue]){
            typeForItem = 2;
            _ownerFlag = 1;
            _creatFlag = 1;
        }
    }
//    [self customRightNavBar:typeForItem];
    [self addRightBtnMenu:sourceDict withType:typeForItem];
    
    
    //可以改变任务状态： 当前用户是创建人或者负责人
    //1待接收,2未完成,3已完成,4被拒绝
    NSString *imgNameStr = @"";
    NSString *isEnabledFlag = @""; //标记改变任务状态的图片是(0)否(1)可以进行点击
    NSString *taskType = @""; //改变任务状态标记值 未完成（2）完成（3）
    if (ownerUserID == [appDelegateAccessor.moudle.userId longLongValue] || createUserID == [appDelegateAccessor.moudle.userId longLongValue] ) {
        isEnabledFlag = @"0";
        if (statusValue == 3) {
            taskType = @"3";
            imgNameStr = @"home_today_task_done";
        } else if (statusValue == 1 || statusValue == 4) {
            imgNameStr = @"task_not_done_disable";
            isEnabledFlag = @"1";
        } else {
            taskType = @"2";
            imgNameStr = @"home_today_task";
        }
    } else if (ownerUserID != [appDelegateAccessor.moudle.userId longLongValue] && createUserID != [appDelegateAccessor.moudle.userId longLongValue]) {
        isEnabledFlag = @"1";
        if (statusValue == 3) {
            imgNameStr = @"task_done_disable";
        } else {
            imgNameStr = @"task_not_done_disable";
        }
    } else {
        
    }
    //1待接收,2未完成,3已完成,4被拒绝,5已过期
    ///白色代表该任务未完成或待接受，绿色代表该任务已完成，红色代表该任务已过期
    //taskStatus 1今天 2明天 3将来 4已过期 5待接收 6被拒绝 7已完成
    if (statusValue == 3) {
        ///完成
        imgNameStr = @"task_icon_over.png";
    }else if (statusValue == 5){
        ///过期
        imgNameStr = @"task_icon_invalid.png";
    }else{
        ///未完成
        imgNameStr = @"task_icon_notcompleted.png";
    }
    
    //任务，当我为负责人且不是创建人同时满足状态为待接受的任务才出现查看日历，点击查看日历，自动跳转至当天的日程首页；其他情况下为编辑功能
    NSString *editOrDateStr = @""; //0笔头 1日历 2全都不显示
    if (ownerUserID == [appDelegateAccessor.moudle.userId longLongValue] && createUserID != [appDelegateAccessor.moudle.userId longLongValue] && statusValue == 1) {
        editOrDateStr = @"0";
    } else {
        editOrDateStr = @"1";
    }
    
    if (statusValue == 1) {
        if (_creatFlag == 0) {
            //可以进行全部操作
            isAllEdit = @"1";
            isWonerEdit = @"1";
            isRemindEdit = @"1";
        } else {
            //不可以进行任何操作
            isAllEdit = @"0";
            isWonerEdit = @"0";
            isRemindEdit = @"0";
        }
    } else {
        //页面可编辑逻辑处理
        if (_creatFlag == 0) {
            //可以进行全部操作
            isAllEdit = @"1";
            isWonerEdit = @"1";
            isRemindEdit = @"1";
        } else if (_creatFlag != 0 && _ownerFlag == 0) {
            //不能修改负责人
            isAllEdit = @"1";
            isWonerEdit = @"0";
            isRemindEdit = @"1";
        } else if (_creatFlag != 0 && _ownerFlag != 0) {
            //可以修改提醒时间
            isAllEdit = @"0";
            isWonerEdit = @"0";
            isRemindEdit = @"1";
        }

    }
    NSString *createbAtStr = @"";
    NSString *createdByNameStr = @"";
    if ([sourceDict objectForKey:@"createdAt"]) {
        createbAtStr = [CommonFuntion getStringForTime:[[sourceDict objectForKey:@"createdAt"] longLongValue]];
    }
    NSLog(@"%@--%@", [sourceDict objectForKey:@"createdAt"], [[sourceDict objectForKey:@"createdBy"] objectForKey:@"name"]);
    if ([sourceDict objectForKey:@"createdBy"] && [[sourceDict objectForKey:@"createdBy"] objectForKey:@"name"]) {
        createdByNameStr = [[sourceDict objectForKey:@"createdBy"] objectForKey:@"name"];
    }
    section = [XLFormSectionDescriptor formSectionWithTitle:[NSString stringWithFormat:@"该任务于%@由\"%@\"创建", createbAtStr, createdByNameStr]];
    [self.form addFormSection:section];
    
    __weak __block typeof(self) weak_self = self;
    // 任务名称
    NSString *taskDateStr = @"";
    if ([dict objectForKey:@"date"]) {
       taskDateStr = [[CommonFuntion getStringForTime:[[dict safeObjectForKey:@"date"] integerValue]] substringToIndex:10];
    }
    _taskNameStr = [sourceDict safeObjectForKey:@"name"];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"title" rowType:XLFormRowDescriptorTypeTaskImageText];
    row.value = @{@"image" : imgNameStr,
                  @"content" : _taskNameStr,
                  @"taskID" : _uid,
                  @"flag" : isEnabledFlag,
                  @"type" : taskType,
                  @"date" : taskDateStr,
                  @"isEdit" : isAllEdit,
                  @"isEditOrDate" : editOrDateStr};
    row.action.formBlock = ^(XLFormRowDescriptor *rowDescriptor) {
//        [weak_self changOneTask:taskType];
    };
    [section addFormRow:row];
    // 任务描述
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"describe" rowType:XLFormRowDescriptorTypeTextValue];
    if ([[sourceDict allKeys] containsObject:@"description"] && [sourceDict objectForKey:@"description"]) {
        valueStr = [sourceDict safeObjectForKey:@"description"];
    }
    row.value = @{@"text" : @"任务描述",
                  @"value" : valueStr,
                  @"isEdit" : isAllEdit};
    valueStr = [row.value objectForKey:@"value"];
    [row.cellConfig setObject:[UIFont systemFontOfSize:16] forKey:@"m_textLabel.font"];
    [row.cellConfig setObject:kTitleColor forKey:@"m_textLabel.textColor"];
    [row.cellConfig setObject:[UIColor lightGrayColor] forKey:@"m_valueLabel.textColor"];
    row.action.formBlock = ^(XLFormRowDescriptor *sender) {
        EditTextForDetailController *controller = [[EditTextForDetailController alloc] init];
        controller.title = @"编辑";
        controller.textStr = valueStr;
        controller.backTextViewValveBlock = ^(NSString *string) {
            XLFormRowDescriptor *rowDescriptor = [weak_self.form formRowWithTag:@"describe"];
            rowDescriptor.value = @{@"text" : @"任务描述",
                                    @"value" : string,
                                    @"isEdit" : isAllEdit
                                    };
            valueStr = string;
            [weak_self editOneTaskOfDetail:nil withRowDestriptor:rowDescriptor];
            
        };
        [weak_self.navigationController pushViewController:controller animated:YES];
    };
    [section addFormRow:row];
    
    // 关联业务
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"business" rowType:XLFormRowDescriptorTypeTextValue];
    NSString *value = @"";
    NSString *businessType = @"";
    NSString *businessId = @"";
    NSString *isEditBusiness = @"";
    if ([CommonFuntion checkNullForValue:[sourceDict objectForKey:@"from"]]) {
        value = [NSString stringWithFormat:@"%@-%@", [[sourceDict objectForKey:@"from"] safeObjectForKey:@"sourceName"], [[sourceDict objectForKey:@"from"] safeObjectForKey:@"name"]];
        businessType = [[sourceDict objectForKey:@"from"] safeObjectForKey:@"sourceId"];
        businessId = [[sourceDict objectForKey:@"from"] safeObjectForKey:@"id"];
        isEditBusiness = @"0";
    } else {
        value = @"未填写";
        isEditBusiness = isAllEdit;
    }
    row.value = @{@"text" : @"关联业务",
                  @"value" : value,
                  @"isEdit" : isEditBusiness,
                  @"businessType" : businessType,
                  @"businessId" : businessId};
    [row.cellConfig setObject:[UIFont systemFontOfSize:16] forKey:@"m_textLabel.font"];
    [row.cellConfig setObject:kTitleColor forKey:@"m_textLabel.textColor"];
    [row.cellConfig setObject:[UIColor lightGrayColor] forKey:@"m_valueLabel.textColor"];
    row.action.formBlock = ^(XLFormRowDescriptor *sender) {
        if ([[sender.value objectForKey:@"isEdit"] isEqualToString:@"0"]) {
            [weak_self pushIntoBussinessView:sender];
        } else {
            RelatedBusinessController *controller = [[RelatedBusinessController alloc] init];
            weak_self.refreshBlock = ^(NSDictionary *fromDic){
                XLFormRowDescriptor *rowDescriptor = [weak_self.form formRowWithTag:@"business"];
                rowDescriptor.value = @{@"text" : @"关联业务",
                                        @"value" : [[fromDic objectForKey:@"dataSource"] objectForKey:@"name"],
                                        @"isEdit" : @"0",
                                        @"businessType" : [fromDic objectForKey:@"type"],
                                        @"businessId" : [NSString stringWithFormat:@"%@", [[fromDic objectForKey:@"dataSource"] safeObjectForKey:@"id"]]};
                [weak_self editOneTaskOfDetail:nil withRowDestriptor:rowDescriptor];
            };
            
            [self.navigationController pushViewController:controller animated:YES];
        }
    };
    [section addFormRow:row];
    
    
    // 责任人
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"owner" rowType:XLFormRowDescriptorTypeTextImage];
    AddressBook *owner = [NSObject objectOfClass:@"AddressBook" fromJSON:dict[@"owner"]];
    row.value = @{@"text" : @"责任人",
                  @"image" : owner.icon,
                  @"uid" : owner.id,
                  @"isEdit" : isWonerEdit};
    [row.cellConfig setObject:[UIFont systemFontOfSize:16] forKey:@"m_textLabel.font"];
    row.action.formBlock = ^(XLFormRowDescriptor *descriptor) {
        AddressSelectedController *addressSelectedController = [[AddressSelectedController alloc] init];
        addressSelectedController.title = @"选择责任人";
        addressSelectedController.selectedBlock = ^(AddressBook *item) {
            XLFormRowDescriptor *rowDestriptor = [weak_self.form formRowWithTag:@"owner"];
            rowDestriptor.value = @{@"text" : @"责任人",
                                    @"image" : item.icon,
                                    @"uid" : item.id,
                                    @"isEdit" : isWonerEdit};
            if (createUserID == [appDelegateAccessor.moudle.userId longLongValue]) {
                if (createUserID == [item.id longLongValue]) {
                    // 责任人为创建人，转为一般状态
                    _changeOwnerType = @"2";
                }else {
                    _changeOwnerType = @"1";
                }
            }
            if ([_againTask isEqualToString:@"1"]) {
                [weak_self showAlertViewForCreate:item.name];
                _taskID = [item.id longLongValue];
            } else {
                [weak_self editOneTaskOfDetail:nil withRowDestriptor:rowDestriptor];
            }
        };
        [weak_self.navigationController pushViewController:addressSelectedController animated:YES];
    };
    [section addFormRow:row];
    
    // 参与人
    NSArray *membersArry;
    NSMutableArray *idsArray = [NSMutableArray arrayWithCapacity:0];
    if (sourceDict && [sourceDict objectForKey:@"members"]) {
        membersArry = [sourceDict objectForKey:@"members"];
        if ([membersArry count] > 0) {
            for (NSDictionary *dict in membersArry) {
                [idsArray addObject:[dict objectForKey:@"id"]];
            }
        }
    }
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"members" rowType:XLFormRowDescriptorTypeTextImages];
    row.value = @{@"text" : @"参与人",
                  @"images" : (NSArray*)[sourceDict objectForKey:@"members"],
                  @"uid" : idsArray,
                  @"isEdit" : isAllEdit};
    row.action.formBlock = ^(XLFormRowDescriptor *rowDescriptor) {
        if ([[rowDescriptor.value objectForKey:@"images"] count]) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in rowDescriptor.value[@"images"]) {
                AddressBook *item = [NSObject objectOfClass:@"AddressBook" fromJSON:tempDict];
                [tempArray addObject:item];
            }
            EditAddressViewController *editAddressController = [[EditAddressViewController alloc] init];
            editAddressController.title = @"参与人";
            editAddressController.sourceModel = [ExportAddress initWithArray:tempArray];
            editAddressController.refreshBlock = ^(NSArray *array) {
                NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
                for (AddressBook *tempItem in array) {
                    if ([tempItem.id isEqualToNumber:@(createUserID)] || [tempItem.id isEqualToNumber:@(ownerUserID)]) {
                        continue;
                    }
                    [tempArray addObject:tempItem];
                }
                
                XLFormRowDescriptor *rowDescriptor = [weak_self.form formRowWithTag:@"members"];
                rowDescriptor.value = @{@"text" : @"参与人",
                                        @"images" : [weak_self modelChangeForDictionary:tempArray],
                                        @"uid" : newMemberIds,
                                        @"isEdit" : isAllEdit};
                [self updateFormRow:rowDescriptor];
                [weak_self.tableView reloadData];
                [weak_self editOneTaskOfDetail:@"member" withRowDestriptor:rowDescriptor];
            };
            [weak_self.navigationController pushViewController:editAddressController animated:YES];
        }else {
            ExportAddressViewController *exportController = [[ExportAddressViewController alloc] init];
            exportController.title = @"选择参与人";
            exportController.valueBlock = ^(NSArray *array) {
                NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
                for (AddressBook *tempItem in array) {
                    if ([tempItem.id isEqualToNumber:@(createUserID)] || [tempItem.id isEqualToNumber:@(ownerUserID)]) {
                        continue;
                    }
                    [tempArray addObject:tempItem];
                }
                XLFormRowDescriptor *rowDescriptor = [weak_self.form formRowWithTag:@"members"];
                
                rowDescriptor.value = @{@"text" : @"参与人",
                                        @"images" : [weak_self modelChangeForDictionary:tempArray],
                                        @"uid" : newMemberIds,
                                        @"isEdit" : isAllEdit};
                [self updateFormRow:rowDescriptor];
                [weak_self.tableView reloadData];
                [weak_self editOneTaskOfDetail:nil withRowDestriptor:rowDescriptor];
            };
            
            [weak_self.navigationController pushViewController:exportController animated:YES];
        }
    };
    [row.cellConfig setObject:[UIFont systemFontOfSize:16] forKey:@"m_textLabel.font"];
    [row.cellConfig setObject:kTitleColor forKey:@"m_textLabel.textColor"];
    [row.cellConfig setObject:[UIColor lightGrayColor] forKey:@"m_valueLabel.textColor"];
    [section addFormRow:row];
    
    
    // 截止时间
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"ends" rowType:XLFormRowDescriptorTypeTextValue];
    NSString *lastDateStr = @"";
    if ([sourceDict objectForKey:@"date"]) {
        lastDateStr = [CommonFuntion getStringForTime:[[sourceDict objectForKey:@"date"] longLongValue]];
//        lastDateStr = [NSString transDateWithTimeInterval:[sourceDict objectForKey:@"date"] andCustomFormate:@"yyyy-MM-dd HH:mm"];
    }
    row.value = @{@"text" : @"截止时间",
                  @"value" : lastDateStr,
                  @"isEdit" : isAllEdit};
    [row.cellConfig setObject:[UIFont systemFontOfSize:16] forKey:@"m_textLabel.font"];
    [row.cellConfig setObject:kTitleColor forKey:@"m_textLabel.textColor"];
    [row.cellConfig setObject:[UIColor lightGrayColor] forKey:@"m_valueLabel.textColor"];
    row.action.formBlock = ^(XLFormRowDescriptor *sender) {
        [weak_self showPickerViewByType:DATE_PICKERVIEW withData:lastDateStr];
    };
    [section addFormRow:row];
    
    // 提醒时间
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"reminds" rowType:XLFormRowDescriptorTypeTextValue];
    NSString *remindName = @"";
    if ([[sourceDict allKeys] containsObject:@"remind"] && [sourceDict objectForKey:@"remind"]) {
        NSInteger index = [[sourceDict objectForKey:@"remind"]integerValue] + 1;
            remindName = remindArray[index];
    } else {
        remindName = @"不提醒";
    }
    row.value = @{@"text" : @"提醒时间",
                  @"value" : remindName,
                  @"isEdit" : isRemindEdit};
    [row.cellConfig setObject:[UIFont systemFontOfSize:16] forKey:@"m_textLabel.font"];
    [row.cellConfig setObject:kTitleColor forKey:@"m_textLabel.textColor"];
    [row.cellConfig setObject:[UIColor lightGrayColor] forKey:@"m_valueLabel.textColor"];
    row.action.formBlock = ^(XLFormRowDescriptor *sender) {
        [weak_self showPickerViewByType:PICKERVIEW withData:lastDateStr];
        [self deselectFormRow:sender];
    };
    [section addFormRow:row];

    // 附件
    if ([[sourceDict allKeys] containsObject:@"files"] && [[sourceDict objectForKey:@"files"] count] > 0) {
        section = [XLFormSectionDescriptor formSectionWithTitle:@"附件"];
        [self.form addFormSection:section];
        for (NSDictionary *dict in [sourceDict objectForKey:@"files"]) {
            row = [XLFormRowDescriptor formRowDescriptorWithTag:@"files" rowType:XLFormRowDescriptorTypeFiles];
            NSInteger size = [[dict safeObjectForKey:@"size"] integerValue];
//            double newSize = size / 1024.0;  [NSString stringWithFormat:@"%.2fkb", newSize
            row.value = @{@"image" : @"file_document_32",
                          @"text" : [dict safeObjectForKey:@"name"],
                          @"detail" : @(size),
                          @"url" : [dict safeObjectForKey:@"url"]};
            [row.cellConfig setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"accessoryType"];
            [section addFormRow:row];
        }
    }
}

#pragma mark -- UIAcitonSheet Action
- (void)showActionSheet:(NSDictionary *)dict {
    NSString *nameStr = @"";
    NSString *reasonStr = @"无";
    if ([dict objectForKey:@"owner"] && [[dict objectForKey:@"owner"] objectForKey:@"name"]) {
        nameStr = [[dict objectForKey:@"owner"] safeObjectForKey:@"name"];
    }
    if ([dict objectForKey:@"reason"]) {
        reasonStr = [dict safeObjectForKey:@"reason"];
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除任务", @"分配给他人", nil];
    sheet.title = [NSString stringWithFormat:@"\"%@\"拒绝接受该任务\n\n拒绝理由\n\n%@:%@", nameStr, nameStr, reasonStr];
    sheet.tintColor = [UIColor blackColor];
    sheet.tag = 201;
    [sheet showInView:self.view];
}
- (void)showActionDeleteCommentSheent {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:Nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:Nil otherButtonTitles:@"删除", nil];
    sheet.tag = 202;
    [sheet showInView:self.view];
}
#pragma mark - 201拒绝任务提示框 202删除评论
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 201) {
        switch (buttonIndex) {
            case 0:
                NSLog(@"删除任务");
                [self deleteOrQuitOneTask:_taskID url:GET_OFFICE_TASK_DELETE];
                break;
            case 1:
                NSLog(@"分配给他人");
                [self pushToAddressBookController];
                break;
            case 2:
                NSLog(@"取消");
                break;
                
            default:
                break;
        }
    } else if (actionSheet.tag == 202) {
        switch (buttonIndex) {
            case 0:
                [self showAlertViewForDeleteComment];
                break;
            case 1:
                
                break;
                
            default:
                break;
        }
    }else if (actionSheet.tag == 20101) {
        
        NSInteger statusValue = 0;
        if (_taskDetailDict) {
            statusValue = [[_taskDetailDict objectForKey:@"taskStatus"] integerValue];
        }
        
        ///完成  重启  删除
        switch (buttonIndex) {
            case 0:
                NSLog(@"删除");
                [self showAlertViewForDelegate];
                break;
            case 1:
                NSLog(@"3重启/完成/4分配");
                ///已完成 标记为重启
                if (statusValue == 3) {
                    [self showAlertByResetThisTask];
                }else if (statusValue == 4) {
                    ///分配给他人
                    [self pushToAddressBookController];
                }
                else{
                    [self showAlertByOverThisTask];
                }
                break;
            case 2:
                NSLog(@"取消");
                break;
                
            default:
                break;
        }
    }else if (actionSheet.tag == 20102) {
        
        NSInteger statusValue = 0;
        if (_taskDetailDict) {
            statusValue = [[_taskDetailDict objectForKey:@"taskStatus"] integerValue];
        }
        
        ///完成  重启  删除
        switch (buttonIndex) {
            case 0:
                NSLog(@"删除");
                [self showAlertViewForDelegate];
            case 1:
                NSLog(@"取消");
                break;
                
            default:
                break;
        }
    }
}


#pragma mark - 重新分配负责人
- (void)pushToAddressBookController {
    AddressSelectedController *selectedController = [[AddressSelectedController alloc] init];
    selectedController.title = @"选择同事";
    selectedController.selectedBlock = ^(AddressBook *item) {
        XLFormRowDescriptor *rowDescriptor = [self.form  formRowWithTag:@"owner"];
        rowDescriptor.value = @{@"text" : @"责任人",
                                @"image" : item.icon,
                                @"uid" : item.id,
                                @"isEdit" : isWonerEdit};
        //        _taskID = [item.id longLongValue];

        [self showAlertViewForCreate:item.name];
        _ownerIcon = item.icon;
    };
    [self.navigationController pushViewController:selectedController animated:YES];
}

#pragma mark - 删除评论
- (void)deleteOneComment:(long long)uid {
    //存储uid
    long long saveUid = uid;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:@"5" forKey:@"objectType"];
    [params setObject:[NSString stringWithFormat:@"%lld", uid] forKey:@"commentId"];
    [params setObject:_uid forKey:@"trendsId"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, TREND_DELETE_A_COMMENT] params:params success:^(id responseObj) {
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            
            if (_deleteRow) {
                [self.form removeFormRow:_deleteRow];
            }
            
            [self sendRequestToCommentForRefresh];
            
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self deleteOneComment:saveUid];
            };
            [comRequest loginInBackground];
        }else{
            NSString *desc = @"";
            if ([responseObj objectForKey:@"desc"]) {
                desc = [responseObj safeObjectForKey:@"desc"];
            }
            if ([desc isEqualToString:@""]) {
                desc = @"删除失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        
    }];
}
#pragma mark - 时间
///根据类型显示pickerview
-(void)showPickerViewByType:(NSString *)type withData:(NSString *)data{
    strReview = textViewReview.text;
    [textViewReview resignFirstResponder];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (sktPickView == nil) {
        
        __weak typeof(XLFTaskDetailViewController) *addViewController = self ;
        //        datepicker
        //        pickerview
        sktPickView= [[SKTPickerView alloc]initWithContent:remindArray data:data byType:type];
        sktPickView.delegate = self;
        [sktPickView addButton:Button_OK  handler:^(SKTPickerViewItem *item) {
            NSLog(@"click Button_OK");
            [addViewController removeSktPickView];
        }];
        
        
        [sktPickView addButton:Button_PRE handler:^(SKTPickerViewItem *item) {
            NSLog(@"click Button_PRE");
            [addViewController removeSktPickView];
        }];
        
        [sktPickView addButton:Button_NEXT  handler:^(SKTPickerViewItem *item) {
            NSLog(@"click Button_NEXT");
            [addViewController removeSktPickView];
        }];
        
        [sktPickView show:self.view];
    }
}
///remove SktPickView
-(void)removeSktPickView{
    sktPickView = nil;
    [self.tableView reloadData];
    [self editOneTaskOfDetail:nil withRowDestriptor:nil];
}
#pragma mark - datepicker回调
-(void)selectedDate:(NSString *)selected{
    NSLog(@"日期 selectedDate:%@",selected);
     __weak typeof(self) weak_self = self;
    XLFormRowDescriptor *rowDescriptor = [self.form formRowWithTag:@"ends"];
    rowDescriptor.value = @{@"text" : @"截止时间", @"value" : selected, @"isEdit" : isAllEdit};;
    rowDescriptor.action.formBlock = ^(XLFormRowDescriptor *sender) {
        [weak_self showPickerViewByType:DATE_PICKERVIEW withData:selected];
    };
    [self updateFormRow:rowDescriptor];
}

#pragma mark - pickerview回调
-(void)selectedData:(NSString *)selected{
    NSLog(@"pickerview selectedData:%@",selected);
    ///提醒时间
    XLFormRowDescriptor *rowDescriptor = [self.form formRowWithTag:@"reminds"];
    rowDescriptor.value = @{@"text" : @"提醒时间", @"value" : selected, @"isEdit" : isRemindEdit};
    [self updateFormRow:rowDescriptor];
}
- (void)changOneTask:(NSString *)type {
    NSString *saveType = type;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:_uid forKey:@"taskId"];
    [params setObject:type forKey:@"status"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, GET_OFFICE_TASK_CHANGE] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@"操作成功:%@", responseObj);
        if ([[responseObj objectForKey:@"status"] integerValue] == 0) {
            NSLog(@"%@", [responseObj objectForKey:@"desc"]);
            [self sendRequestToDetail];
            if (_RefreshTaskListBlock) {
                _RefreshTaskListBlock();
            }
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self selectedData:saveType];
            };
            [comRequest loginInBackground];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [hud hide:YES];
        NSLog(@"操作失败: %@", error);
    }];
}
//将model转换为dict
- (NSMutableArray *)modelChangeForDictionary:(NSArray *)modelArray {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableArray *newMembersArr = [NSMutableArray arrayWithCapacity:0];
    newMemberIds = [NSMutableArray arrayWithCapacity:0];
    for (AddressBook *tempItem  in modelArray) {
        [dict setObject:tempItem.id forKey:@"id"];
        [dict setObject:tempItem.name forKey:@"name"];
        [dict setObject:tempItem.icon forKey:@"icon"];
        [newMembersArr addObject:[dict mutableCopy]];
        [newMemberIds addObject:[NSString stringWithFormat:@"%@", tempItem.id]];
        [dict removeAllObjects];
    }
    NSLog(@"新参与人详情数组%ld--%@---%@",newMembersArr.count , newMembersArr, newMemberIds);
    return newMembersArr;
}

- (void)pushIntoBussinessView:(XLFormRowDescriptor *)formRow {
    if (formRow.value) {
        //            businessId = 280;  //id
        //            businessType = 201;  //类型 iD
        _sourceType = [[formRow.value objectForKey:@"businessType"] integerValue];
        NSInteger sectionId = [[formRow.value objectForKey:@"businessId"] integerValue];
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
            default:
                break;
        }
        
    }
}/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
