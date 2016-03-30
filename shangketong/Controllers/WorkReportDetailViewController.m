//
//  WorkReportDetailViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "WorkReportDetailViewController.h"
#import "CommonConstant.h"
#import "NSDate+Utils.h"
#import "AFNHttp.h"
#import "SBJson.h"
#import "AFHTTPRequestOperationManager.h"
#import "WorkReportItem.h"
#import "WRNewItem.h"
#import "XLFTextValueCell.h"
#import "XLFTextImageCell.h"
#import "XLFTextImagesCell.h"
#import "XLFSelectorTextImageCell.h"
#import "XLFormCommentCell.h"
#import "WRWorkResultCell.h"
#import "WRNewViewController.h"
#import "UIMessageInputView.h"
#import "AddressBook.h"
#import "ExportAddressViewController.h"
#import "InfoViewController.h"
#import "Comment.h"
#import "CommentItem.h"
#import "XLTotalCell.h"

#import "OAComment.h"
#import "MJRefresh.h"

static NSString *const kActivityRecords = @"activityRecords";
static NSString *const kReviewUsers = @"reviewUsers";
static NSString *const kCcUsers = @"ccUsers";

@interface WorkReportDetailViewController ()<UIActionSheetDelegate, UIAlertViewDelegate, UIMessageInputViewDelegate, TTTAttributedLabelDelegate>{
    NSInteger commentID; //评论ID
}

@property (nonatomic, strong) NSDictionary *editSourceDict;
@property (nonatomic, strong) UIMessageInputView *msgInputView;
@property (nonatomic, copy) NSString *staffIdsString;

@property (strong, nonatomic) NSMutableDictionary *commentParams;
@property (strong, nonatomic) XLFormRowDescriptor *deleteRow;   // 删除评论时标记行
@property (assign, nonatomic) BOOL isComment;       // 是否有评论

- (void)sendRequestToComment;
- (void)sendRequestToCommentForRefresh;
- (void)sendRequestToCommentForReloadMore;
@end

@implementation WorkReportDetailViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.msgInputView prepareToShow];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.msgInputView prepareToDismiss];
}

//- (void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
////    [self.msgInputView prepareToDismiss];
//}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;

    if (_curIndex == 0) {
        self.title = [NSString stringWithFormat:@"我的%@", _reportItem.m_reportTypeName];
        if (_reportItem.m_readStatus) { // 我的报告 未阅
            UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_showMore"] style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonItemPress)];
            self.navigationItem.rightBarButtonItem = rightButtonItem;
        }
    }else {
        self.title = [NSString stringWithFormat:@"%@的%@", _reportItem.m_creatorName, _reportItem.m_reportTypeName];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _commentParams = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [_commentParams setObject:@(_reportItem.m_reportID) forKey:@"trendsId"];
    [_commentParams setObject:@(_reportItem.m_reportTypeIndex + 6) forKey:@"objectType"];
    [_commentParams setObject:@1 forKey:@"pageNo"];
    [_commentParams setObject:@10 forKey:@"pageSize"];
    
    XLFormDescriptor *form = [XLFormDescriptor formDescriptor];
    self.form = form;
    
    [self.tableView setHeight:kScreen_Height - 50];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:[NSNumber numberWithInteger:_reportItem.m_reportID] forKey:@"id"];
    [params setObject:_reportItem.m_reportType forKey:@"type"];
    
    [self.view beginLoading];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",kNetPath_Oa_Server_Base,REPORT_DETAILS] params:params success:^(id responseObj) {
        [self.view endLoading];
        if ([[responseObj objectForKey:@"status"] integerValue] == 0) {
            [self createXLFormWithSource:responseObj];
            [self sendRequestToComment];
        } else if ([[responseObj objectForKey:@"status"] integerValue] == 2) {
            [self blackRefreshAlertView:[responseObj objectForKey:@"desc"]];
        }
        
    } failure:^(NSError *error) {
        [self.view endLoading];
        NSLog(@"error:%@",error);
        kShowHUD(@"无法连接到网络，请检查您的网络配置");
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [self.tableView addFooterWithTarget:self action:@selector(sendRequestToCommentForReloadMore)];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 
- (void)blackRefreshAlertView:(NSString *)string {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:string delegate:self cancelButtonTitle:@"确认" otherButtonTitles: nil];
    alertView.tag = 200;
    [alertView show];
}
#pragma mark - event response
- (void)rightButtonItemPress {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"编辑", @"删除", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - private method
- (void)createXLFormWithSource:(NSDictionary*)sourceDict {
    NSLog(@"sourceDict:%@",sourceDict);
    _reportItem.m_readStatus = [[sourceDict safeObjectForKey:@"readStatus"] boolValue];
    
     NSDictionary *reveiwer = nil;
    if ([sourceDict objectForKey:@"reviewUsers"]) {
        reveiwer = [sourceDict objectForKey:@"reviewUsers"];
    }
    if (reveiwer && (id)reveiwer != [NSNull null]) {
        _reportItem.m_reveiwerId = [reveiwer safeObjectForKey:@"id"];
    }
    // 显示评论或批阅视图
    if (_reportItem.m_readStatus && [_reportItem.m_reveiwerId integerValue] == [appDelegateAccessor.moudle.userId integerValue]) {  // 批阅
        _msgInputView.isApprove = YES;
        _msgInputView.placeHolder = @"输入批阅内容";
    }else { // 评论
        _msgInputView.isApprove = NO;
        _msgInputView.placeHolder = @"输入评论内容";
    }
    
    // 编辑报告
    if (_curIndex == 0 && _reportItem.m_readStatus) {
        _editSourceDict = [[NSDictionary alloc] initWithDictionary:sourceDict];
    }
    
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    NSString *string = @"";
    
    // 标题
    if (![[sourceDict objectForKey:@"readStatus"] integerValue]) {
        string = [NSString stringWithFormat:@"该报告于%@由%@批为\"已阅\"", [NSString transDateWithTimeInterval:[sourceDict objectForKey:@"reportTime"] andCustomFormate:@"yy-MM-dd"], [[sourceDict objectForKey:@"reviewUsers"] objectForKey:@"name"]];
    }
    section = [XLFormSectionDescriptor formSectionWithTitle:string];
    [self.form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"title" rowType:XLFormRowDescriptorTypeTextValue];
    switch (_reportItem.m_reportTypeIndex) {
        case 0:
            string = [NSString transDateWithTimeInterval:[sourceDict objectForKey:@"reportTime"] andCustomFormate:@"yyyy-MM-dd"];
            break;
        case 1:
            string = [NSString transDateToWeekWithTimeInterval:[sourceDict objectForKey:@"reportTime"]];
            break;
        case 2:
//            string = [NSString transDateWithTimeInterval:[sourceDict objectForKey:@"reportTime"] andCustomFormate:@"yyyy年MM月"];
            string  = [CommonFuntion transDateWithTimeInterval:[[sourceDict safeObjectForKey:@"reportTime"] longLongValue] withFormat:@"yyyy年MM月"];
            break;
        default:
            break;
    }
    row.value = @{@"text" : [NSString stringWithFormat:@"%@日期", _reportItem.m_reportTypeName],
                  @"value" : string,
                  @"isEdit" : @0};
    [section addFormRow:row];
    
    // 工作自动汇总
    if (![[sourceDict objectForKey:@"statics"] integerValue]) {
        NSArray *array = @[@"当日工作自动汇总", @"本周工作自动汇总", @"本月工作自动汇总"];
        section = [XLFormSectionDescriptor formSectionWithTitle:array[_reportItem.m_reportTypeIndex]];
        [self.form addFormSection:section];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:kActivityRecords rowType:XLFormRowDescriptorTypeWorkReportActivityRecords];
        row.value = @(_reportItem.m_reportTypeIndex);
        [section addFormRow:row];
    }

    // 基本信息
    if ([[sourceDict objectForKey:@"columnList"] count]) {
        section = [XLFormSectionDescriptor formSection];
        [self.form addFormSection:section];
        
        for (NSDictionary *tempDict in [sourceDict objectForKey:@"columnList"]) {
            WRNewItem *item = [WRNewItem initWithDictionary:tempDict];
            
            row = [XLFormRowDescriptor formRowDescriptorWithTag:item.m_name rowType:XLFormRowDescriptorTypeTextValue];
            if (item.m_columnType == 3) {

                NSString *valueStr = @"";
               for (NSDictionary *tempDict in item.m_selectArray) {
                  if ([item.m_result isEqualToString:[NSString stringWithFormat:@"%@",tempDict[@"id"]]]) {
                      valueStr = tempDict[@"value"];
                      break;
                   }
                }
                
                row.value = @{@"text" : item.m_name,
                              @"value" : valueStr,
                              @"isEdit" : @0};
            }else if (item.m_columnType == 4) {
                
                NSMutableString *strMutable = [[NSMutableString alloc] init];
                NSArray *array = [item.m_result componentsSeparatedByString:@","];
                for (NSString *valueStr in array) {
                    for (NSDictionary *optionObj in item.m_selectArray) {
                         if ([valueStr isEqualToString:[NSString stringWithFormat:@"%@",optionObj[@"id"]]]) {
                             if ([strMutable isEqualToString:@""]) {
                                 [strMutable appendString:optionObj[@"value"]];
                             }else{
                                 [strMutable appendString:@","];
                                 [strMutable appendString:optionObj[@"value"]];
                             }
                        }
                    }
                }
                row.value = @{@"text" : item.m_name,
                              @"value" : strMutable,
                              @"isEdit" : @0};

            }
            else{
                NSString *valueStr = @"";
                
                if ([CommonFuntion checkNullForValue:item.m_result]) {
                    
                    if (!item.m_fullDate) {
                        valueStr = [CommonFuntion transDateWithTimeInterval:[item.m_result longLongValue] withFormat:@"yyyy-MM-dd HH:mm"];
                    }else{
                        valueStr = [CommonFuntion transDateWithTimeInterval:[item.m_result longLongValue] withFormat:@"yyyy-MM-dd"];
                    }
                    
                }else {
                    valueStr = @"";
                }

                
                row.value = @{@"text" : item.m_name,
                              @"value" : (item.m_columnType == 7 ? valueStr : [NSString stringWithFormat:@"%@", item.m_result]),
                              @"isEdit" : @0};
            }
            
            
            [row.cellConfig setObject:[UIFont systemFontOfSize:15] forKey:@"m_textLabel.font"];
            [row.cellConfig setObject:[UIColor colorWithRed:(CGFloat)70/255.0 green:(CGFloat)154/255.0 blue:(CGFloat)234/255.0 alpha:1.0] forKey:@"m_textLabel.textColor"];
            [section addFormRow:row];
        }
    }
    
    // 显示批阅人和抄送人
    section = [XLFormSectionDescriptor formSection];
    [self.form  addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReviewUsers rowType:XLFormRowDescriptorTypeTextImage];
    row.value = @{@"text" : @"批阅人",
                  @"image" : [[sourceDict objectForKey:@"reviewUsers"] safeObjectForKey:@"icon"],
                  @"uid" : [[sourceDict objectForKey:@"reviewUsers"] objectForKey:@"id"],
                  @"isEdit" : @0};
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCcUsers rowType:XLFormRowDescriptorTypeTextImages];
    row.value = @{@"text" : @"抄送人",
                  @"images" : [sourceDict objectForKey:@"ccUsers"],
                  @"isEdit" : @0};
    [section addFormRow:row];
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

- (void)backViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIMessageInputViewDelegate
- (void)messageInputView:(UIMessageInputView *)inputView sendText:(NSString *)text {
    [self.msgInputView isAndResignFirstResponder];
    
    __block NSString *pathString = @"";
    
    __block NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        if (inputView.isApprove) {  // 批阅
            NSMutableArray *jsonArray = [[NSMutableArray alloc] initWithCapacity:0];
            [jsonArray addObject:@{@"id" : @(_reportItem.m_reportID),
                                   @"type" : _reportItem.m_reportType}];
            
            MySBJsonWriter *jsonParser = [[MySBJsonWriter alloc]init];
            NSString *jsonString =[jsonParser stringWithObject:jsonArray];
            [params setObject:jsonString forKey:@"json"];
            
            pathString = [NSString stringWithFormat:@"%@%@",kNetPath_Oa_Server_Base, kNetPath_Report_Approve];
            
        }else {  // 评论
            [params setObject:@(_reportItem.m_reportID) forKey:@"trendsId"];
            NSString *transString = [NSString stringWithString:[text stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [params setObject:transString forKey:@"content"];
//            [params setObject:(_staffIdsString ? _staffIdsString : @"") forKey:@"staffIds"];
            [params setObject:@(_reportItem.m_reportTypeIndex + 6) forKey:@"objectType"];
            
            NSArray *arrayAtId = nil;
            ///读取缓存
            NSArray *arrayCache = [[FMDBManagement sharedFMDBManager] getAddressBookDataSource];
            if (arrayCache) {
                arrayAtId = [CommonFuntion getAtUserIds:text atArray:arrayCache isAddressBookArray:TRUE];
            }
            NSLog(@"arrayAtId:%@",arrayAtId);
            
            
            if (arrayAtId && arrayAtId.count > 9) {
                kShowHUD(@"你最多能@9人");
                return;
            }
            
            [params setObject:[CommonFuntion getStringStaffIds:arrayAtId] forKey:@"staffIds"];
            
            NSLog(@"params:%@",params);
            pathString = [NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA, TREND_ADD_A_COMMENT];
        }
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript",@"text/plain", nil];
        manager.requestSerializer.timeoutInterval = 15;
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [manager POST:pathString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            ///图片
        } success:^(AFHTTPRequestOperation *operation,id responseObject) {
            [hud hide:YES];
            NSLog(@"评论或批阅结果 = %@ desc = %@", responseObject, [responseObject objectForKey:@"desc"]);
//            dispatch_async(dispatch_get_main_queue(), ^{
         
            [self.msgInputView notifyInputView:@""];
            
                if ([[responseObject objectForKey:@"status"] integerValue]) {
                    kShowHUD(@"操作失败",nil);
                    return;
                }
                
                if (inputView.isApprove) {  // 批阅
                    kShowHUD(@"批阅成功");
                    NSString *string = [NSString stringWithFormat:@"该报告于%@由%@批为\"已阅\"", [[NSDate new] stringYearMonthDayForLine], appDelegateAccessor.moudle.userName];
                    XLFormSectionDescriptor *section = [[self.form formSections] firstObject];
                    section.title = string;
                    [self.tableView reloadData];

                    if (self.refreshBlock) {
                        self.refreshBlock();
                    }
                    
                    self.msgInputView.isApprove = NO;
                    self.msgInputView.placeHolder = @"输入评论内容";
                    
                    ///内容不为空
                    if (text && text.length > 0 && [self respondsToSelector:@selector(messageInputView:sendText:)]) {
                        [self messageInputView:self.msgInputView sendText:text];
                    }
                    
                }else { // 评论
                    
                    OAComment *item = [NSObject objectOfClass:@"OAComment" fromJSON:responseObject[@"comment"]];
                    for (NSDictionary *tempAltsDict in responseObject[@"comment"][@"alts"]) {
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
                }
//            });
            
        } failure:^(AFHTTPRequestOperation *operation,NSError *error) {
            NSLog(@"------%@", error);
            [hud hide:YES];
            if (inputView.isApprove) {  // 批阅
                kShowHUD(@"批阅失败");
            }else{
                kShowHUD(@"评论失败");
            }
        }];
//    });
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.msgInputView isAndResignFirstResponder];
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

#pragma mark - UITableViewDelegate
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    XLFormRowDescriptor *row = [self.form formRowAtIndex:indexPath];
//    if (![row.value isKindOfClass:[OAComment class]]) {
//        return;
//    }
//    
//    OAComment *comment = row.value;
//    
//    if ([appDelegateAccessor.moudle.userId isEqualToString:[NSString stringWithFormat:@"%@", comment.creator.id]]) {
//        _deleteRow = row;
//        commentID = [comment.id integerValue];
//        [self showAlertViewForDeleteComment];
//    }else{
//        ///负责将当前user的姓名 添加到输入框内容中
//        ///拼接@姓名到编辑框
//        NSString *strText = _msgInputView.inputTextView.text;
//       _msgInputView.inputTextView.text = [NSString stringWithFormat:@"%@ @%@ ", strText, comment.creator.name];
//        [_msgInputView.inputTextView becomeFirstResponder];
//    }
//}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;
    
    if (buttonIndex == 0) { // 编辑
        __weak typeof(self) weak_self = self;
        WRNewViewController *editReportController = [[WRNewViewController alloc] init];
        editReportController.title = [NSString stringWithFormat:@"修改%@", _reportItem.m_reportTypeName];
        editReportController.reportType = _reportItem.m_reportTypeIndex;
        editReportController.newType = WorkReportNewTypeEdit;
        editReportController.editDataSource = _editSourceDict;
        editReportController.refreshBlock = ^{
            if (weak_self.refreshBlock) {
                weak_self.refreshBlock();
            }
        };
        [self.navigationController pushViewController:editReportController animated:YES];
    }else { // 删除
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"删除提示" message:@"删除后，该工作报告的评论、文档等所有内容都将一起删除、且无法恢复！\n\n请确认是否删除?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
        [alertView show];
    }
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
        if (self.refreshBlock) {
            self.refreshBlock();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if (buttonIndex == alertView.cancelButtonIndex)
        return;
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:[NSNumber numberWithInteger:_reportItem.m_reportID] forKey:@"id"];
    [params setObject:_reportItem.m_reportType forKey:@"type"];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Report_Delete] params:params success:^(id responseObj) {
        [hud hide:YES];
        if (![[responseObj objectForKey:@"status"] integerValue]) {
            if (self.refreshBlock) {
                self.refreshBlock();
            }
            kShowHUD(@"工作报告删除成功", nil);
            
            [self performSelector:@selector(backViewController) withObject:nil afterDelay:2.0f];

        }else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[responseObj objectForKey:@"desc"] delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
            [alertView show];
        }
    } failure:^(NSError *error) {
        [hud hide:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"无法连接网络，请检查您的网络配置" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
        [alertView show];
    }];
}


#pragma mark - setters and getters
- (UIMessageInputView*)msgInputView {
    if (!_msgInputView) {
        __weak typeof(self) weak_self = self;
        _msgInputView = [UIMessageInputView initMessageInputViewWithType:UIMessageInputViewTypeWorkReport andRootView:self.view];
        _msgInputView.atBlock = ^{
            ExportAddressViewController *exportController = [[ExportAddressViewController alloc] init];
            exportController.title = @"通讯录";
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
    [params setObject:@(_reportItem.m_reportTypeIndex + 6) forKey:@"objectType"];
    [params setObject:[NSString stringWithFormat:@"%lld", uid] forKey:@"commentId"];
    [params setObject:@(_reportItem.m_reportID) forKey:@"trendsId"];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
