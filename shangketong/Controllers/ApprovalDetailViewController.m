//
//  ApprovalDetailViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/2.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ApprovalDetailViewController.h"
#import "AFNHttp.h"
#import "CommonConstant.h"
#import "WRNewItem.h"
#import "XLFTextValueCell.h"
#import "XLFSelectorTextImageCell.h"
#import "XLFTextImageCell.h"
#import "XLFTextImagesCell.h"
#import "XLFImageTextDetailCell.h"
#import "XLFApprovalImageTitleCell.h"
#import "XLFImageTextCell.h"
#import "ApprovalStatusListController.h"
#import "ApprovalEditViewController.h"
#import "InputViewController.h"
#import "KnowledgeFileDetailsViewController.h"
#import "Approval.h"
#import "UIMessageInputView.h"
#import "ExportAddressViewController.h"
#import "AddressBook.h"
#import "AFHTTPRequestOperationManager.h"
#import "CommentItem.h"
#import "Comment.h"
#import "XLFormCommentCell.h"
#import "CommonFuntion.h"
#import "XLTotalCell.h"
#import "AFNHttp.h"

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
#import "MJRefresh.h"
#import "OAComment.h"
#import "InfoViewController.h"

@interface ApprovalDetailViewController ()<UIActionSheetDelegate, UIAlertViewDelegate, UIMessageInputViewDelegate, TTTAttributedLabelDelegate>{
    NSInteger commentID; //评论ID
    
    ///类型标记  是不是待接收状态   1是
    NSString *flagOfApprovalType;
}

@property (nonatomic, strong) NSDictionary *sourceDict;
@property (nonatomic, strong) UIView *toolView;
@property (nonatomic, strong) UIMessageInputView *msgInputView;
@property (nonatomic, copy) NSString *staffIdsString;

@property (nonatomic, assign) PushControllerType sourceType;

@property (strong, nonatomic) NSMutableDictionary *commentParams;
@property (strong, nonatomic) XLFormRowDescriptor *deleteRow;   // 删除评论时标记行
@property (assign, nonatomic) BOOL isComment;       // 是否有评论

- (void)sendRequestToComment;
- (void)sendRequestToCommentForRefresh;
- (void)sendRequestToCommentForReloadMore;
@end

@implementation ApprovalDetailViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    self.title = @"审批明细";
    
    [self.view addSubview:self.msgInputView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
     [self.msgInputView prepareToShow];
    
    [self.msgInputView notifyInputView:self.msgInputView.inputTextView.text];
    if (flagOfApprovalType && [flagOfApprovalType isEqualToString:@"1"]) {
        if (self.msgInputView.inputTextView.text && self.msgInputView.inputTextView.text.length > 0) {
            [self.msgInputView notAndBecomeFirstResponder];
            self.msgInputView.isAlwaysShow = YES;
            [self.view bringSubviewToFront:self.msgInputView];
        }else{
            self.msgInputView.isAlwaysShow = NO;
            [self.view bringSubviewToFront:self.toolView];
        }
    }
    [_msgInputView isAndResignFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.msgInputView prepareToDismiss];
}

//- (void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
//    
//    [self.msgInputView prepareToDismiss];
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    flagOfApprovalType = @"0";
    XLFormDescriptor *form = [XLFormDescriptor formDescriptor];
    self.form = form;
    
    [self.tableView setHeight:kScreen_Height - 50];

    _commentParams = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [_commentParams setObject:@(_approval.m_id) forKey:@"trendsId"];
    [_commentParams setObject:@9 forKey:@"objectType"];
    [_commentParams setObject:@1 forKey:@"pageNo"];
    [_commentParams setObject:@10 forKey:@"pageSize"];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:@(_approval.m_id) forKey:@"id"];
    if (_approval.m_runId) {
        [params setObject:@(_approval.m_runId) forKey:@"runId"];
    }
    
    [self.view beginLoading];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, kNetPath_Approve_Detail] params:params success:^(id responseObj) {
        [self.view endLoading];
        if ([[responseObj objectForKey:@"status"] integerValue] == 0) {
            [self createXLFormWithSource:responseObj];
            [self sendRequestToComment];
        } else if ([[responseObj objectForKey:@"status"] integerValue] == 4) {
            [self blackRefreshAlertView:[responseObj objectForKey:@"desc"]];
        }
    } failure:^(NSError *error) {
        [self.view endLoading];
        kShowHUD(@"无法连接到网络，请检查您的网络配置");
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [self.tableView addFooterWithTarget:self action:@selector(sendRequestToCommentForReloadMore)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createXLFormWithSource:(NSDictionary*)sourceDict {
    
    NSLog(@"dataSource = %@", sourceDict);
    
    _sourceDict = sourceDict;
    _approval.m_flowName = [sourceDict safeObjectForKey:@"flowName"];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSection];
    [self.form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"title" rowType:XLFormRowDescriptorTypeTextValue];
    row.value = @{@"text" : [NSString stringWithFormat:@"%@%@", _approval.m_flowName, _approval.m_approveNo],
                  @"value" : [NSString stringWithFormat:@"申请人：%@", _sourceDict[@"examine"][@"applyUser"][@"name"]],
                  @"isEdit" : @0};
    [row.cellConfig setObject:[UIFont systemFontOfSize:16] forKey:@"m_textLabel.font"];
    [row.cellConfig setObject:[UIColor blackColor] forKey:@"m_textLabel.color"];
    [row.cellConfig setObject:[UIColor lightGrayColor] forKey:@"m_valueLabel.textColor"];
    [section addFormRow:row];
    
    // 审批状态
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"status" rowType:XLFormRowDescriptorTypeImageTextDetail];
    [row.cellConfig setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"accessoryType"];
    row.action.formBlock = ^(XLFormRowDescriptor *descriptor) {
        if ([_sourceDict[@"log"] count]) {
            ApprovalStatusListController *statusListController = [[ApprovalStatusListController alloc] init];
            statusListController.title = @"审批状态";
            statusListController.sourceArray = [[NSArray alloc] initWithArray:_sourceDict[@"log"]];
            [self.navigationController pushViewController:statusListController animated:YES];
        }
    };
    // 判断申请人是否为本人 才能执行撤回、删除和修改提交工作
    switch ([_sourceDict[@"examine"][@"approveStatus"] integerValue]) {
        case 1: {   // 等待审批或审批中
            
            if ([_sourceDict[@"examine"][@"applyUser"][@"id"] integerValue] == [appDelegateAccessor.moudle.userId integerValue]) {
                UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"撤回" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonItemPress:)];
                rightButtonItem.tag = 1;
                self.navigationItem.rightBarButtonItem = rightButtonItem;
            }
            
//            row.value = @{@"status" : [NSNumber numberWithInteger:[_sourceDict[@"examine"][@"approveStatus"] integerValue]],
//                          @"detail" : [NSString stringWithFormat:@"等待%@审批", _sourceDict[@"examine"][@"reviewUsers"][@"name"]],
//                          @"remark" : [_sourceDict[@"examine"] safeObjectForKey:@"remark"]};
            row.value = @{@"status" : [NSNumber numberWithInteger:[_sourceDict[@"examine"][@"approveStatus"] integerValue]],
                          @"detail" : [NSString stringWithFormat:@"等待%@审批", _sourceDict[@"examine"][@"reviewUsers"][@"name"]],
                          @"remark" : @""};
            
            // 判断审批人是否为自己，是的话则显示同意、拒绝审批UI
            if ([_sourceDict[@"examine"][@"reviewUsers"][@"id"] integerValue] == [appDelegateAccessor.moudle.userId integerValue]) {
                
                flagOfApprovalType = @"1";
                self.msgInputView.isAlwaysShow = NO;
                [self.tableView setHeight:kScreen_Height - 50];
                [self.view addSubview:self.toolView];
            }
        }
            break;
        case 2: {   // 撤回
            if ([_sourceDict[@"examine"][@"applyUser"][@"id"] integerValue] == [appDelegateAccessor.moudle.userId integerValue]) {
                UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_showMore"] style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonItemPress:)];
                rightButtonItem.tag = 2;
                self.navigationItem.rightBarButtonItem = rightButtonItem;
            }
            
            row.value = @{@"status" : [NSNumber numberWithInteger:[_sourceDict[@"examine"][@"approveStatus"] integerValue]],
                          @"detail" : @"已撤回",
                          @"remark" : @""};
        }
            break;
        case 3: {   // 通过审批
//            row.value = @{@"status" : [NSNumber numberWithInteger:[_sourceDict[@"examine"][@"approveStatus"] integerValue]],
//                          @"detail" : @"已通过",
//                          @"remark" : [_sourceDict[@"examine"] safeObjectForKey:@"remark"]};
            row.value = @{@"status" : [NSNumber numberWithInteger:[_sourceDict[@"examine"][@"approveStatus"] integerValue]],
                          @"detail" : @"已通过",
                          @"remark" : @""};
        }
            break;
        case 4: {   // 拒绝
            if ([_sourceDict[@"examine"][@"applyUser"][@"id"] integerValue] == [appDelegateAccessor.moudle.userId integerValue]) {
                UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_showMore"] style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonItemPress:)];
                rightButtonItem.tag = 4;
                self.navigationItem.rightBarButtonItem = rightButtonItem;
            }

//            NSString *timeString = [NSString msgRemindApprovalTransDateWithTimeInterval:[_sourceDict[@"examine"] safeObjectForKey:@"reviewTime"]];
            NSString *timeString = [self changeTime:[_sourceDict[@"examine"] safeObjectForKey:@"reviewTime"]];
            
            row.value = @{@"status" : [NSNumber numberWithInteger:[_sourceDict[@"examine"][@"approveStatus"] integerValue]],
                          @"detail" : [NSString stringWithFormat:@"%@ 被 %@ 拒绝", timeString, _sourceDict[@"examine"][@"reviewUsers"][@"name"]],
                          @"remark" : [_sourceDict[@"examine"] safeObjectForKey:@"remark"]};
        }
            break;
        default:
            break;
    }
    [section addFormRow:row];
    
    // 显示我处理的状态
    if ([_sourceDict objectForKey:@"previousRun"] != [NSNull null]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"previousRun" rowType:XLFormRowDescriptorTypeApprovalImageTitle];
        row.value = [_sourceDict objectForKey:@"previousRun"];
        [section addFormRow:row];
    }
    
    // 基本信息
    if ([[_sourceDict objectForKey:@"examine"] objectForKey:@"columnList"] && [[[_sourceDict objectForKey:@"examine"] objectForKey:@"columnList"] count]) {
        section = [XLFormSectionDescriptor formSectionWithTitle:@"基本信息"];
        [self.form addFormSection:section];
        
        for (NSDictionary *tempDict in _sourceDict[@"examine"][@"columnList"]) {
            
            NSString *valueStr = @"";
            
            WRNewItem *item = [WRNewItem initWithDictionary:tempDict];
            row = [XLFormRowDescriptor formRowDescriptorWithTag:item.m_name rowType:XLFormRowDescriptorTypeTextValue];
            
            if (item.m_columnType == 3) {   // 单选
                for (NSDictionary *tempDict in item.m_selectArray) {
                    if ([[tempDict objectForKey:@"id"] integerValue] == [item.m_result integerValue]) {
                        valueStr = [tempDict safeObjectForKey:@"value"];
                    }
                }
            }else if (item.m_columnType == 4) { // 多选
                NSArray *resultArray = [item.m_result componentsSeparatedByString:@","];
                for (int i = 0; i < resultArray.count; i ++) {
                    NSString *tempStr = resultArray[i];
                    for (NSDictionary *tempDict in item.m_selectArray) {
                        if ([[tempDict objectForKey:@"id"] integerValue] == [tempStr integerValue]) {
                            if (i == 0) {
                                valueStr = [tempDict safeObjectForKey:@"value"];
                            }else {
                                valueStr = [NSString stringWithFormat:@"%@,%@", valueStr, [tempDict safeObjectForKey:@"value"]];
                            }
                        }
                    }
                }
            }else if (item.m_columnType == 7) { // 时间
                if ([CommonFuntion checkNullForValue:item.m_result]) {
                    
                    if (!item.m_fullDate) {
                        valueStr = [CommonFuntion transDateWithTimeInterval:[item.m_result longLongValue] withFormat:@"yyyy-MM-dd HH:mm"];
                    }else{
                        valueStr = [CommonFuntion transDateWithTimeInterval:[item.m_result longLongValue] withFormat:@"yyyy-MM-dd"];
                    }
                    
                }else {
                    valueStr = @"";
                }
            }else {     // 其他
                valueStr = item.m_result;
            }
            row.value = @{@"text" : item.m_name,
                          @"value" : valueStr,
                          @"isEdit" : @0};
            [row.cellConfig setObject:[UIFont systemFontOfSize:15] forKey:@"m_textLabel.font"];
            [row.cellConfig setObject:[UIColor colorWithRed:(CGFloat)70/255.0 green:(CGFloat)154/255.0 blue:(CGFloat)234/255.0 alpha:1.0] forKey:@"m_textLabel.textColor"];
            [row.cellConfig setObject:[UIColor blackColor] forKey:@"m_valueLabel.textColor"];
            [section addFormRow:row];
        }
    }
    
    // 显示抄送人
    if ([[_sourceDict[@"examine"] allKeys] containsObject:@"ccUsers"]) {
        if ([_sourceDict[@"examine"][@"ccUsers"] count]) {
            row = [XLFormRowDescriptor formRowDescriptorWithTag:@"ccUsers" rowType:XLFormRowDescriptorTypeTextImages];
            row.value = @{@"text" : @"抄送人",
                          @"images" : (NSArray*)_sourceDict[@"examine"][@"ccUsers"],
                          @"isEdit" : @0};
            [section addFormRow:row];
        }
    }

    if ([CommonFuntion checkNullForValue:[_sourceDict objectForKey:@"from"]]) {
        section = [XLFormSectionDescriptor formSectionWithTitle:@"关联业务"];
        [self.form addFormSection:section];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"business" rowType:XLFormRowDescriptorTypeTextValue];
        row.value = @{@"text" : [[_sourceDict objectForKey:@"from"] safeObjectForKey:@"sourceName"],
                      @"value" : [[_sourceDict objectForKey:@"from"] safeObjectForKey:@"name"],
                      @"isEdit" : @0,
                      @"businessId" : [[_sourceDict objectForKey:@"from"] safeObjectForKey:@"id"],
                      @"businessType" : [[_sourceDict objectForKey:@"from"] safeObjectForKey:@"sourceId"]};
        row.action.formBlock = ^(XLFormRowDescriptor *rowDescriptor) {
            [self pushIntoBussinessView:rowDescriptor];
        };
        [section addFormRow:row];
    }
    // 显示附件
    if ([CommonFuntion checkNullForValue:[_sourceDict objectForKey:@"file"]]) {
        section = [XLFormSectionDescriptor formSectionWithTitle:@"附件"];
        [self.form addFormSection:section];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"file" rowType:XLFormRowDescriptorTypeImageText];
        [row.cellConfig setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"accessoryType"];
        row.value = [_sourceDict objectForKey:@"file"];
        row.action.formBlock = ^(XLFormRowDescriptor *rowDescriptor) {
            KnowledgeFileDetailsViewController *fileDetailsController = [[KnowledgeFileDetailsViewController alloc] init];
            fileDetailsController.detailsOld = rowDescriptor.value;
            fileDetailsController.viewFrom = @"other";
            fileDetailsController.isNeedRightNavBtn = YES;
            [self.navigationController pushViewController:fileDetailsController animated:YES];
        };
        [section addFormRow:row];
    }
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
                        NSString *strText = _msgInputView.inputTextView.text;
                        _msgInputView.inputTextView.text = [NSString stringWithFormat:@"%@ @%@ ", strText, comment.creator.name];
                        [_msgInputView.inputTextView becomeFirstResponder];
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

#pragma mark - event response
- (void)rightButtonItemPress:(UIBarButtonItem*)sender {
    if (sender.tag == 1) {      // 撤回
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否要撤回该审批" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"撤回", nil];
        [alertView show];
    }else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除", @"修改并重新提交", nil];
        [actionSheet showInView:self.view];
    }
}

- (void)agreeBtnPress {
    __weak typeof(self) weak_self = self;
    InputViewController *inputController = [[InputViewController alloc] init];
    inputController.title = @"同意申请";
    inputController.rightButtonString = @"提交";
    inputController.placeholderString = @"请输入审批意见";
    inputController.delegateType = ValueDelegateTypeNone;
    inputController.approvalAssignable = [[_sourceDict objectForKey:@"assignable"] integerValue];
    inputController.approvalIsLastNode = [[_sourceDict objectForKey:@"isLastNode"] integerValue];
    inputController.approvalId = _approval.m_id;
    if ([CommonFuntion checkNullForValue:[_sourceDict objectForKey:@"reveiwers"]]) {
        inputController.approvalReveiwer = [[NSArray alloc] initWithArray:[_sourceDict objectForKey:@"reveiwers"]];
    }
    inputController.refreshBlock = ^{
        if (weak_self.refreshDataSource) {
            weak_self.refreshDataSource();
        }
    };
    [self.navigationController pushViewController:inputController animated:YES];
}

- (void)refuseBtnPress {
    __weak typeof(self) weak_self = self;
    InputViewController *inputController = [[InputViewController alloc] init];
    inputController.title = @"拒绝申请";
    inputController.rightButtonString = @"提交";
    inputController.placeholderString = @"请输入拒绝的理由";
    inputController.delegateType = ValueDelegateTypeNone;
    inputController.approvalAssignable = [[_sourceDict objectForKey:@"assignable"] integerValue];
    inputController.approvalIsLastNode = [[_sourceDict objectForKey:@"isLastNode"] integerValue];
    inputController.approvalId = _approval.m_id;
    if ([CommonFuntion checkNullForValue:[_sourceDict objectForKey:@"reveiwers"]]) {
        inputController.approvalReveiwer = [[NSArray alloc] initWithArray:[_sourceDict objectForKey:@"reveiwers"]];
    }
    inputController.refreshBlock = ^{
        if (weak_self.refreshDataSource) {
            weak_self.refreshDataSource();
        }
    };
    [self.navigationController pushViewController:inputController animated:YES];
}

- (void)commentBtnPress {
//    self.toolView.hidden = YES;
//    self.msgInputView.hidden = NO;
    [self.view bringSubviewToFront:self.msgInputView];
    [self.msgInputView notAndBecomeFirstResponder];
}

#pragma mark --  AlertView
- (void)blackRefreshAlertView:(NSString *)string {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:string delegate:self cancelButtonTitle:@"确认" otherButtonTitles: nil];
    alertView.tag = 200;
    [alertView show];
}

#pragma mark - UIMessageInputViewDelegate
- (void)messageInputView:(UIMessageInputView *)inputView sendText:(NSString *)text {
    [self.msgInputView isAndResignFirstResponder];
    
    __weak typeof(self) weak_self = self;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *params=[NSMutableDictionary dictionary];
        [params addEntriesFromDictionary:COMMON_PARAMS];
        [params setObject:@(_approval.m_id) forKey:@"trendsId"];
        NSString *transString = [NSString stringWithString:[text stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [params setObject:transString forKey:@"content"];
        
        
//        [params setObject:(_staffIdsString ? _staffIdsString : @"") forKey:@"staffIds"];
        
        NSArray *arrayAtId = nil;
        ///读取缓存
        //    NSArray *arrayCache = [FMDB_SKT_CACHE select_AddressBook_AllData];
        NSArray *arrayCache = [[FMDBManagement sharedFMDBManager] getAddressBookDataSource];
        if (arrayCache) {
            arrayAtId = [CommonFuntion getAtUserIds:text atArray:arrayCache isAddressBookArray:TRUE];
        }
        NSLog(@"arrayAtId:%@",arrayAtId);
        
        
        if (arrayAtId && arrayAtId.count > 9) {
            kShowHUD(@"你最多能@9人");
//            self.msgInputView.inputTextView.text = [params safeObjectForKey:@"content"];
            return;
        }
        
        [params setObject:[CommonFuntion getStringStaffIds:arrayAtId] forKey:@"staffIds"];
        
        [params setObject:@(9) forKey:@"objectType"];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
        
        [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA, TREND_ADD_A_COMMENT] params:params success:^(id responseObj) {
            [hud hide:YES];
            if ([[responseObj objectForKey:@"status"] integerValue] == 0) {
                ///情况输入框
                [self.msgInputView notifyInputView:@""];
                ///隐藏输入框
                if (flagOfApprovalType && [flagOfApprovalType isEqualToString:@"1"]) {
                    self.msgInputView.isAlwaysShow = NO;
                    [self.view bringSubviewToFront:self.toolView];
                }

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
                        NSString *strText = _msgInputView.inputTextView.text;
                        _msgInputView.inputTextView.text = [NSString stringWithFormat:@"%@ @%@ ", strText, comment.creator.name];
                        [_msgInputView.inputTextView becomeFirstResponder];
                    }
                };
                XLTotalCell *cell = (XLTotalCell*)[row cellForFormController:self];
                cell.contentLabel.delegate = self;
                [commentSection addFormRow:row beforeRow:commentSection.formRows.firstObject];
            } else {
//                self.msgInputView.inputTextView.text = [params safeObjectForKey:@"content"];
                kShowHUD(@"评论失败",nil);
                return;
            }
        } failure:^(NSError *error) {
            [hud hide:YES];
            kShowHUD(@"评论失败",nil);
//            self.msgInputView.inputTextView.text = [params safeObjectForKey:@"content"];
        }];
//    });
    
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

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (flagOfApprovalType && [flagOfApprovalType isEqualToString:@"1"]) {
        if (self.msgInputView.inputTextView.text && self.msgInputView.inputTextView.text.
            length > 0) {
            self.msgInputView.isAlwaysShow = YES;
            [self.view bringSubviewToFront:self.msgInputView];
        }else{
            self.msgInputView.isAlwaysShow = NO;
            [self.view bringSubviewToFront:self.toolView];
        }
    }else{
        
    }
    [_msgInputView isAndResignFirstResponder];
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
    if ((self.view.bounds.size.height-keyboardBounds.size.height-self.msgInputView.frame.size.height) < self.tableView.contentSize.height) {
        [self.tableView setContentOffset:CGPointMake(0.0, self.tableView.contentSize.height-(self.view.bounds.size.height-keyboardBounds.size.height-self.msgInputView.frame.size.height)) animated:YES];
    }
     */
}

-(void)keyboardWillHide:(NSNotification *)note{
    /*
    [self.tableView setContentOffset:CGPointMake(0.0, self.tableView.contentSize.height-(self.view.bounds.size.height-self.msgInputView.frame.size.height)) animated:YES];
     */
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 211) {
        if (buttonIndex == 0) {
            
        } else if (buttonIndex == 1) {
            [self deleteOneComment:commentID];
        }
        return;
    }
    
    if (alertView.tag == 200) {
        if (self.refreshDataSource) {
            self.refreshDataSource();
        }
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if (buttonIndex) {
        // 撤回操作
        NSMutableDictionary *params=[NSMutableDictionary dictionary];
        [params addEntriesFromDictionary:COMMON_PARAMS];
        [params setObject:@(_approval.m_id) forKey:@"id"];
        
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        [hud show:YES];
        [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, kNetPath_Approve_Reback] params:params success:^(id responseObj) {
            [hud hide:YES];
            if (![[responseObj objectForKey:@"status"] integerValue]) {
                if (self.refreshDataSource) {
                    self.refreshDataSource();
                }
                [self.navigationController popViewControllerAnimated:YES];
            }else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@", responseObj[@"desc"]] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView show];
            }
        } failure:^(NSError *error) {
            [hud hide:YES];
        }];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) { // 删除
        NSMutableDictionary *params=[NSMutableDictionary dictionary];
        [params addEntriesFromDictionary:COMMON_PARAMS];
        [params setObject:@(_approval.m_id) forKey:@"id"];
        
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        [hud show:YES];
        [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, kNetPath_Approve_Delete] params:params success:^(id responseObj) {
            [hud hide:YES];
            if (![[responseObj objectForKey:@"status"] integerValue]) {
                if (self.refreshDataSource) {
                    self.refreshDataSource();
                }
                [self.navigationController popViewControllerAnimated:YES];
            }else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@", responseObj[@"desc"]] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView show];
            }
        } failure:^(NSError *error) {
            [hud hide:YES];
        }];
    }
    
    if (buttonIndex == 1) { // 修改并重新提交
        ApprovalEditViewController *editController = [[ApprovalEditViewController alloc] init];
        editController.title = @"编辑申请";
        editController.flowName = _approval.m_flowName;
        editController.sourceDict = _sourceDict;
        [self.navigationController pushViewController:editController animated:YES];
    }
}

#pragma mark - setters and getters
- (UIView*)toolView {
    if (!_toolView) {
        
        NSInteger sizeWidth = (kScreen_Width-4*20)/3;
        NSString *btnTextColor = @"585858";
        
        _toolView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height - 50, kScreen_Width, 50)];
//        _toolView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        _toolView.backgroundColor = [UIColor whiteColor];
        [_toolView.layer setBorderWidth:1];
        _toolView.layer.borderColor = [UIColor colorWithHexString:@"cbcdcd"].CGColor;
        
        UIButton *agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        agreeBtn.frame = CGRectMake(20, 7, sizeWidth, 36);
        agreeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [agreeBtn.layer setMasksToBounds:YES];
        [agreeBtn.layer setCornerRadius:6];
        [agreeBtn.layer setBorderWidth:1];
        agreeBtn.layer.borderColor = [UIColor colorWithHexString:@"cbcdcd"].CGColor;

        [agreeBtn setTitle:@"同意" forState:UIControlStateNormal];
        [agreeBtn setTitleColor:[UIColor colorWithHexString:btnTextColor] forState:UIControlStateNormal];
        [agreeBtn addTarget:self action:@selector(agreeBtnPress) forControlEvents:UIControlEventTouchUpInside];
        [_toolView addSubview:agreeBtn];
        
        UIButton *refuseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        refuseBtn.frame = CGRectMake(sizeWidth+40, 7, sizeWidth, 36);
        refuseBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [refuseBtn setTitle:@"拒绝" forState:UIControlStateNormal];
        [refuseBtn.layer setMasksToBounds:YES];
        [refuseBtn.layer setCornerRadius:6];
        [refuseBtn.layer setBorderWidth:1];
         refuseBtn.layer.borderColor = [UIColor colorWithHexString:@"cbcdcd"].CGColor;
        [refuseBtn setTitleColor:[UIColor colorWithHexString:btnTextColor] forState:UIControlStateNormal];
        [refuseBtn addTarget:self action:@selector(refuseBtnPress) forControlEvents:UIControlEventTouchUpInside];
        [_toolView addSubview:refuseBtn];
        
        UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        commentBtn.frame = CGRectMake(sizeWidth*2+60, 7, sizeWidth, 36);
        commentBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [commentBtn.layer setMasksToBounds:YES];
        [commentBtn.layer setCornerRadius:6];
        [commentBtn.layer setBorderWidth:1];
        commentBtn.layer.borderColor = [UIColor colorWithHexString:@"cbcdcd"].CGColor;
        [commentBtn setTitle:@"评论" forState:UIControlStateNormal];
        [commentBtn setTitleColor:[UIColor colorWithHexString:btnTextColor] forState:UIControlStateNormal];
        [commentBtn addTarget:self action:@selector(commentBtnPress) forControlEvents:UIControlEventTouchUpInside];
        [_toolView addSubview:commentBtn];
    }
    return _toolView;
}

- (UIMessageInputView*)msgInputView {
    if (!_msgInputView) {
        __weak typeof(self) weak_self = self;
        _msgInputView = [UIMessageInputView initMessageInputViewWithType:UIMessageInputViewTypeSimple andRootView:self.view placeHolder:@"输入评论内容"];
        _msgInputView.atBlock = ^{
            ExportAddressViewController *exportController = [[ExportAddressViewController alloc] init];
            exportController.valueBlock = ^(NSArray *array) {
                for (int i = 0; i < array.count; i ++) {
                    AddressBook *item = array[i];
                    if (i == 0) {
                        weak_self.staffIdsString = [NSString stringWithFormat:@"%@", item.id];
                        weak_self.msgInputView.inputTextView.text = [NSString stringWithFormat:@"%@@%@ ", weak_self.msgInputView.inputTextView.text, item.name];
                    }else {
                        weak_self.staffIdsString = [NSString stringWithFormat:@"%@,%@", weak_self.staffIdsString, item.id];
                        weak_self.msgInputView.inputTextView.text = [NSString stringWithFormat:@"%@@%@ ", weak_self.msgInputView.inputTextView.text, item.name];
                    }
                }
                
                if (flagOfApprovalType && [flagOfApprovalType isEqualToString:@"1"]) {
                    if (weak_self.msgInputView.inputTextView.text && self.msgInputView.inputTextView.text.length > 0) {
                        [weak_self.msgInputView notifyInputView:weak_self.msgInputView.inputTextView.text];
                        //            [self.msgInputView notAndBecomeFirstResponder];
                        weak_self.msgInputView.isAlwaysShow = YES;
                        [weak_self.view bringSubviewToFront:weak_self.msgInputView];
                    }
                }
                
                
            };
            [weak_self.navigationController pushViewController:exportController animated:YES];
        };
        _msgInputView.delegate = self;
    }
    return _msgInputView;
}




#pragma mark - 删除评论
- (void)deleteOneComment:(long long)uid {
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    //存储uid
    long long saveUid = uid;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:@"9" forKey:@"objectType"];
    [params setObject:[NSString stringWithFormat:@"%lld", uid] forKey:@"commentId"];
    [params setObject:@(_approval.m_id) forKey:@"trendsId"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, TREND_DELETE_A_COMMENT] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@"responseObj:%@",responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            
            if (_deleteRow) {
                [self.form removeFormRow:_deleteRow];
            }
            
            [self sendRequestToCommentForRefresh];
            
        }else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
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
        [hud hide:YES];
    }];
}



//删除评论
- (void)showAlertViewForDeleteComment {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认删除评论" message:Nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 211;
    [alert show];
}
- (void)pushIntoBussinessView:(XLFormRowDescriptor *)formRow {
    if (formRow.value) {
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
}


- (NSString *)changeTime:(NSString *)longTime{
    NSDate *lastDate = [[NSDate alloc] initWithTimeIntervalSince1970:[longTime longLongValue] / 1000.0];
    
    NSString *dateStr;      // 年月日
    NSString *hour;         // 时
    if ([lastDate year] == [[NSDate date] year]) {  // 今年
        NSInteger days = [CommonFuntion getTimeDaysSinceToady:[CommonFuntion getStringForTime:[longTime longLongValue]]];
        if (days == 0) {
            dateStr = @"今天";
        } else if (days == 1) {
            dateStr = @"昨天";
        } else {     // 非今天或昨天 显示xx月xx日
            dateStr = [lastDate stringMonthDay];
        }
    }
    hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]];
    
    return [NSString stringWithFormat:@"%@ %@:%02d",dateStr,hour,(int)[lastDate minute]];
    
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
