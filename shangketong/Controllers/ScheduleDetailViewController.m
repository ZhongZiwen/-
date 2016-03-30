//
//  ScheduleDetailViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ScheduleDetailViewController.h"
#import "NSDate+Utils.h"
#import "AFNHttp.h"
#import <XLForm.h>
#import "ScheduleEditViewController.h"
#import "XLFormScheduleTitleCell.h"
#import "XLFTextValueCell.h"
#import "XLFTextImagesCell.h"
#import "ExportAddress.h"
#import "ScheduleAcceptMemberPreController.h"
#import "ScheduleSelectedListController.h"
#import "InputViewController.h"
#import "XLScheduleDetailTitleCell.h"
#import "RelatedBusinessController.h"
#import "HPGrowingTextView.h"
#import "UIButton+Create.h"
#import "FMDB_SKT_CACHE.h"
#import "AddressBook.h"
#import "ExportAddressViewController.h"
#import "CommonFuntion.h"
#import "XLTotalCell.h"
#import "CommentItem.h"
#import "OAComment.h"
#import "MJRefresh.h"
#import "InfoViewController.h"

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
#import "EditTextForDetailController.h"

static NSString *const kBusiness = @"business";                 // 关联业务
static NSString *const kAcceptMember = @"acceptMember";     // 参与人
static NSString *const kWaitingMember = @"waitingMember";   // 待确认
static NSString *const kRejectMember = @"rejectMember";     // 已拒绝
static NSString *const kRepeat = @"repeat";                 // 重复
static NSString *const kReminder = @"reminder";             // 提醒
static NSString *const kRemark = @"remark";                 // 备注
static NSString *const kPrivate = @"private";               // 私密

@interface ScheduleDetailViewController ()<UIActionSheetDelegate, UIAlertViewDelegate,HPGrowingTextViewDelegate, TTTAttributedLabelDelegate>{
    ///用来存储请求成功后用来刷新UI的数据
    NSDictionary *dataSuccuss;
    
    UIView *keyboardContainerView; //底部view
    HPGrowingTextView *textViewReview;//键盘
    NSString *strReview;
    
    //标记 页面滑动需不需要 隐藏 底部view
    NSString *typeStr;
    
    NSInteger commentID; //评论ID
    NSString *valueStr;
    
    ///当前提醒方式
    NSInteger selectedReminderType;
    NSInteger selectedReminderTypeOld;
    NSDictionary *dicReminderTypeOld;
    NSDictionary *dicReminderTypeNew;
    
    
    ///任务类型标记  是不是待接收状态   1是
    NSString *flagOfTaskType;
}

@property (nonatomic, strong) NSMutableDictionary *sourceDict;
@property (strong, nonatomic) UIBarButtonItem *rightButtonItem;
@property (strong, nonatomic) UIView *toolView;
@property (assign, nonatomic) BOOL isEdit;
@property (assign, nonatomic) BOOL isCreater;               // 是否为创建人
@property (assign, nonatomic) BOOL isAcceptMember;          // 是否为参与人

@property (nonatomic, assign) PushControllerType sourceType;

@property (strong, nonatomic) NSMutableDictionary *commentParams;
@property (strong, nonatomic) XLFormRowDescriptor *deleteRow;   // 删除评论时标记行
@property (assign, nonatomic) BOOL isComment;       // 是否有评论

@property (nonatomic, copy) void(^refreshBlock)(NSDictionary *);

- (void)sendRequestToDetail;
- (void)sendRequestToComment;
- (void)sendRequestToCommentForRefresh;
- (void)sendRequestToCommentForReloadMore;
- (void)updateXLFormRowDescriptor;
@end

@implementation ScheduleDetailViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    self.title = @"日程详情";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _commentParams = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [_commentParams setObject:@4 forKey:@"objectType"];
    [_commentParams setObject:@(_scheduleId) forKey:@"trendsId"];
    [_commentParams setObject:@1 forKey:@"pageNo"];
    [_commentParams setObject:@10 forKey:@"pageSize"];
    
    //关联业务
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRefresh:) name:@"relatedBusiness" object:nil];
    
    XLFormDescriptor *form = [XLFormDescriptor formDescriptor];
    self.form = form;
    
    [self sendRequestToDetail];
    
    [self.tableView addFooterWithTarget:self action:@selector(sendRequestToCommentForReloadMore)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [textViewReview resignFirstResponder];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if (typeStr && [typeStr isEqualToString:@"Hidden"] ) {
        if (textViewReview.text && textViewReview.text.length > 0) {
            [self creatKeyBoardView];
//            [textViewReview becomeFirstResponder];
        }else{
            keyboardContainerView.hidden = YES;
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    strReview = textViewReview.text;
    [textViewReview resignFirstResponder];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    [textViewReview resignFirstResponder];
//    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
//}
- (void)notificationRefresh:(NSNotification *)notification {
    if (_refreshBlock) {
        _refreshBlock([notification object]);
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
- (void)sendRequestToDetail {
    NSMutableDictionary *params=[NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [params setObject:@(_scheduleId) forKey:@"id"];
    
    [self.view beginLoading];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, kNetPath_Schedule_Info] params:params success:^(id responseObj) {
        [self.view endLoading];
        if (![[responseObj objectForKey:@"status"] integerValue]) {
            
            // 是否为创建人，或者是否为参与人，满足这些条件是显示rightButtonItem
            for (NSDictionary *tempDict in [responseObj objectForKey:@"acceptMember"]) {
                if ([[tempDict objectForKey:@"id"] integerValue] == [appDelegateAccessor.moudle.userId integerValue]) {
                    _isAcceptMember = YES;
                    break;
                }
            }
            
            if ([[responseObj objectForKey:@"createdBy"] integerValue] == [appDelegateAccessor.moudle.userId integerValue]) {
                _isCreater = YES;
            }
            
            if (_isCreater || _isAcceptMember) {
                _isEdit = YES;
                self.navigationItem.rightBarButtonItem = self.rightButtonItem;
            }
            
            [self transitionDataSource:responseObj];
            [self createXLFormWithSource:responseObj];
            [self sendRequestToComment];
        }else{
            kShowHUD([responseObj objectForKey:@"desc"], nil);
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSError *error) {
        [self.view endLoading];
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
                        NSString *strText = textViewReview.text;
                        textViewReview.text = [NSString stringWithFormat:@"%@ @%@ ", strText, comment.creator.name];
                        [textViewReview becomeFirstResponder];
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

- (void)transitionDataSource:(NSDictionary*)dict {
    _sourceDict = [[NSMutableDictionary alloc] init];
    
    // 日程id
    [_sourceDict setObject:[dict safeObjectForKey:@"id"] forKey:@"id"];
    // 日程名称
    [_sourceDict setObject:[dict safeObjectForKey:@"name"] forKey:@"content"];
    // 日程开始时间
    NSString *startDateStr = @"";
    if ([dict objectForKey:@"startDate"]) {
        startDateStr = [CommonFuntion getStringForTime:[[dict safeObjectForKey:@"startDate"] longLongValue]] ;
    }
    [_sourceDict setObject:startDateStr forKey:@"startDate"];
    // 日程结束时间
    NSString *endDateStr = @"";
    if ([dict objectForKey:@"endDate"]) {
        endDateStr = [CommonFuntion getStringForTime:[[dict safeObjectForKey:@"endDate"] longLongValue]] ;
    }
    [_sourceDict setObject:endDateStr forKey:@"endDate"];
    // 提醒类型 -1 不提醒 0准时 1 五分钟 2十分钟 3 三十分钟 4提前一小时 5提前2小时 6提前6小时 7提前1天 8提前2天 9当天上午9天 10 一天前9点
    [_sourceDict setObject:[dict safeObjectForKey:@"reminderType"] forKey:@"remindType"];
    
    if ([dict objectForKey:@"colorType"]) {
        [_sourceDict setObject:[[dict objectForKey:@"colorType"] safeObjectForKey:@"id"] forKey:@"scheduleType"];
        [_sourceDict setObject:[[dict objectForKey:@"colorType"] safeObjectForKey:@"color"] forKey:@"scheduleTypeColor"];
    }else{
        [_sourceDict setObject:@0 forKey:@"scheduleType"];
        [_sourceDict setObject:@5 forKey:@"scheduleTypeColor"];
    }
    
    ///关联业务
    if ([CommonFuntion checkNullForValue:[dict objectForKey:@"from"]]) {
        [_sourceDict setObject:[[dict objectForKey:@"from"] safeObjectForKey:@"sourceId"] forKey:@"businessType"];
        [_sourceDict setObject:[[dict objectForKey:@"from"] safeObjectForKey:@"id"] forKey:@"businessId"];
    }
    
    
    // 是否全天
    [_sourceDict setObject:[dict safeObjectForKey:@"isAllDay"] forKey:@"isAllDay"];
    // 是否重复
    [_sourceDict setObject:[dict safeObjectForKey:@"isRepeat"] forKey:@"isRepeat"];
    // 重复类型
    [_sourceDict setObject:[dict safeObjectForKey:@"repeatType"] forKey:@"repeatType"];
    //结束重复类型
    [_sourceDict setObject:[dict safeObjectForKey:@"repeatEndType"] forKey:@"repeatEndType"];
    //结束重复时间
    NSString *repeatEndTime = @"";
    if ([CommonFuntion checkNullForValue:[dict objectForKey:@"repeatEndTime"]]) {
        repeatEndTime = [NSString transDateWithTimeInterval:[dict safeObjectForKey:@"repeatEndTime"] andFormate:@"yyyy-MM-dd"];
    }
    [_sourceDict setObject:repeatEndTime forKey:@"repeatEndTime"];
    // 是否私密
    [_sourceDict setObject:[dict safeObjectForKey:@"isPrivate"] forKey:@"privateFlag"];
    // 描述
    [_sourceDict setObject:[dict safeObjectForKey:@"description"] forKey:@"remark"];
    // 增加的参与人
    [_sourceDict setObject:@"" forKey:@"addStaffIds"];
    // 删除的参与人
    [_sourceDict setObject:@"" forKey:@"delStaffIds"];

}

- (void)createXLFormWithSource:(NSDictionary*)dict {
//    self.form = nil;
//    [self.tableView  reloadData];
//    XLFormDescriptor *form = [XLFormDescriptor formDescriptor];
//    self.form = form;
    
    __weak __block typeof(self) weak_self = self;
    
    if ([CommonFuntion checkNullForValue:[dict objectForKey:@"waitingMember"]]) {
        NSArray *memberArray = [NSArray arrayWithArray:[dict objectForKey:@"waitingMember"]];
        if (memberArray.count > 0) {
            for (NSDictionary *tempDict in [dict objectForKey:@"waitingMember"]) {
                if ([[tempDict objectForKey:@"id"] integerValue] == [appDelegateAccessor.moudle.userId integerValue]) {
                    _isEdit = NO;
                    typeStr = @"Hidden";
                    flagOfTaskType = @"1";
                    [self.tableView setHeight:kScreen_Height - 44];
                    [self.view addSubview:self.toolView];
                    break;
                } else {
                    typeStr = @"NoHidden";
                    flagOfTaskType = @"0";
                    [self.tableView setHeight:kScreen_Height - 40];
                    [self creatKeyBoardView];
                }
            }
        } else {
            typeStr = @"NoHidden";
            [self.tableView setHeight:kScreen_Height - 40];
            [self creatKeyBoardView];
        }
    } else {
        typeStr = @"NoHidden";
        [self.tableView setHeight:kScreen_Height - 40];
        [self creatKeyBoardView];
    }
    
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;

    NSString *valueString = @"";
    
    // 标题
    NSString *createdTime = [NSString transDateWithTimeInterval:[dict objectForKey:@"createdAt"] andCustomFormate:@"yyyy-MM-dd"];
    section = [XLFormSectionDescriptor formSectionWithTitle:[NSString stringWithFormat:@"该日程于%@由\"%@\"创建", createdTime, [dict objectForKey:@"createdName"]]];
    [self.form addFormSection:section];
    
    NSString *detailStr = @"";
    if ([_sourceDict[@"isAllDay"] integerValue]) {   // 不是全天
        detailStr = [NSString stringWithFormat:@"%@ - %@", [NSString transDateWithTimeInterval:dict[@"startDate"] andFormate:@"yyyy-MM-dd HH:mm"], [NSString transDateWithTimeInterval:dict[@"endDate"] andFormate:@"yyyy-MM-dd HH:mm"]];
    }else {
        detailStr = [NSString stringWithFormat:@"%@ - %@", [NSString transDateWithTimeInterval:dict[@"startDate"] andFormate:@"yyyy-MM-dd"], [NSString transDateWithTimeInterval:dict[@"endDate"] andFormate:@"yyyy-MM-dd"]];
    }
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"title" rowType:XLFormRowDescriptorTypeScheduleDetaileTitle];
    
    NSString *scheduleTypeName = [[dict objectForKey:@"colorType"] safeObjectForKey:@"name"];
    if ([_sourceDict[@"scheduleType"] integerValue] == 0) {
        scheduleTypeName = @"其他";
    }
    
    row.value = @{@"type" : _sourceDict[@"scheduleTypeColor"],
                  @"typeName" : scheduleTypeName,
                  @"name" : _sourceDict[@"content"],
                  @"detail" : detailStr,
                  @"isPrivate": dict[@"isPrivate"],
                  @"isEdit" : @(_isEdit)};
    row.action.formBlock = ^(XLFormRowDescriptor *descriptor) {
        ScheduleEditViewController *editController = [[ScheduleEditViewController alloc] init];
        editController.rowDescriptor = descriptor;
        editController.scheduleSourceDict = weak_self.sourceDict;
        editController.valueBlock = ^(NSDictionary *dict) {
    
            [weak_self.sourceDict setObject:dict[@"type"] forKey:@"scheduleTypeColor"];
            [weak_self.sourceDict setObject:dict[@"name"] forKey:@"content"];
            [weak_self.sourceDict setObject:dict[@"isAllDay"] forKey:@"isAllDay"];
            [weak_self.sourceDict setObject:dict[@"startDate"] forKey:@"startDate"];
            [weak_self.sourceDict setObject:dict[@"endDate"] forKey:@"endDate"];
            
            XLFormRowDescriptor *rowDescriptor = [weak_self.form formRowWithTag:@"title"];
            rowDescriptor.value = dict;
            [weak_self updateFormRow:rowDescriptor];
            
            if (weak_self.RefreshForPlanControllerBlock) {
                weak_self.RefreshForPlanControllerBlock();
            }
        };
        [self.navigationController pushViewController:editController animated:YES];
    };
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [self.form addFormSection:section];
    
    
    // 关联业务
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBusiness rowType:XLFormRowDescriptorTypeTextValue];
    NSString *value = @"";
    NSString *businessType = @"";
    NSString *businessId = @"";
    NSString *isEditBusiness = @"";
    if ([CommonFuntion checkNullForValue:[dict objectForKey:@"from"]]) {
        value = [NSString stringWithFormat:@"%@-%@", [[dict objectForKey:@"from"] safeObjectForKey:@"sourceName"], [[dict objectForKey:@"from"] safeObjectForKey:@"name"]];
        businessType = [[dict objectForKey:@"from"] safeObjectForKey:@"sourceId"];
        businessId = [[dict objectForKey:@"from"] safeObjectForKey:@"id"];
        isEditBusiness = @"0";
    } else {
        value = @"未填写";
        if (_isEdit) {
            isEditBusiness = @"1";
        } else {
            isEditBusiness = @"0";
        }
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
                
                NSString *name = [NSString stringWithFormat:@"%@-%@",[self getBusinessNameByCode:[[fromDic objectForKey:@"type"] integerValue]],[[fromDic objectForKey:@"dataSource"] objectForKey:@"name"]];
                
                dataSuccuss = @{@"text" : @"关联业务",
                                @"value" : name,
                                @"isEdit" : @"0",
                                @"businessType" : [fromDic objectForKey:@"type"],
                                @"businessId" : [NSString stringWithFormat:@"%@", [[fromDic objectForKey:@"dataSource"] safeObjectForKey:@"id"]]};
                
                NSLog(@"dataSuccuss:%@",[dataSuccuss description]);
                
                NSMutableDictionary *params=[NSMutableDictionary dictionary];
                [params addEntriesFromDictionary:_sourceDict];
                [params setObject:[fromDic objectForKey:@"type"] forKey:@"businessType"];
                [params setObject:[NSString stringWithFormat:@"%@", [[fromDic objectForKey:@"dataSource"] safeObjectForKey:@"id"]] forKey:@"businessId"];
                
                // 发送更改请求
                [weak_self sendRequest:kBusiness andParams:params];
            };
            [self.navigationController pushViewController:controller animated:YES];
        }
    };
    [section addFormRow:row];

    
    // 参与人
    @weakify(self);
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAcceptMember rowType:XLFormRowDescriptorTypeTextImages];
    NSArray *membersArry;
    NSMutableArray *idsArray = [NSMutableArray arrayWithCapacity:0];
    if (dict && [CommonFuntion checkNullForValue:[dict objectForKey:@"acceptMember"]]) {
        membersArry = [dict objectForKey:@"acceptMember"];
        if ([membersArry count] > 0) {
            for (NSDictionary *dict in membersArry) {
                [idsArray addObject:[dict objectForKey:@"id"]];
            }
        }
    }
    row.value = @{@"text" : @"参与人",
                  @"images" : (NSArray*)[dict objectForKey:@"acceptMember"],
                  @"isEdit" : @(_isCreater),
                  @"uid" : idsArray};
    row.action.formBlock = ^(XLFormRowDescriptor *rowDescriptor) {
        @strongify(self);
        if ([[rowDescriptor.value objectForKey:@"images"] count]) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in rowDescriptor.value[@"images"]) {
                AddressBook *item = [NSObject objectOfClass:@"AddressBook" fromJSON:tempDict];
                [tempArray addObject:item];
            }
            
            ScheduleAcceptMemberPreController *memberPreController = [[ScheduleAcceptMemberPreController alloc] init];
            memberPreController.title = @"参与人";
            memberPreController.sourceModel = [ExportAddress initWithArray:tempArray];
            memberPreController.scheduleSourceDict = self.sourceDict;
            memberPreController.refreshBlock = ^{
                [self updateXLFormRowDescriptor];
            };
            [self.navigationController pushViewController:memberPreController animated:YES];
        }
        else {
            ExportAddressViewController *exportController = [[ExportAddressViewController alloc] init];
            exportController.title = @"选择参与人";
            exportController.valueBlock = ^(NSArray *array) {
                NSString *string = @"";
                for (int i = 0; i < array.count; i ++) {
                    AddressBook *item = array[i];
                    if (i == 0) {
                        string = [NSString stringWithFormat:@"%@", item.id];
                    }else {
                        string = [NSString stringWithFormat:@"%@,%@", string, item.id];
                    }
                }
                NSMutableDictionary *params=[NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
                [params addEntriesFromDictionary:_sourceDict];
                [params setObject:string forKey:@"addStaffIds"];
                
                [self.view beginLoading];
                [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, kNetPath_Schedule_Update] params:params success:^(id responseObj) {
                    [self.view endLoading];
                    if (![[responseObj objectForKey:@"status"] integerValue]) {
                        [self updateXLFormRowDescriptor];
                    }
                } failure:^(NSError *error) {
                    [self.view endLoading];
                }];
            };
            [self.navigationController pushViewController:exportController animated:YES];
        }
    };
    [section addFormRow:row];
    
    // 待确认
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kWaitingMember rowType:XLFormRowDescriptorTypeTextImages];
    NSArray *waitingMembersArry ;
    NSMutableArray *waitingIdsArray = [NSMutableArray arrayWithCapacity:0];
    if (dict && [CommonFuntion checkNullForValue:[dict objectForKey:@"waitingMember"]]) {
        waitingMembersArry = [dict objectForKey:@"waitingMember"];
        
        if ([waitingMembersArry count] > 0) {
            for (NSDictionary *dict in waitingMembersArry) {
                [waitingIdsArray addObject:[dict objectForKey:@"id"]];
            }
        }
    }
    row.value = @{@"text" : @"待确认",
                  @"images" : waitingMembersArry,
                  @"isEdit" : @0};

    [section addFormRow:row];
    // 已拒绝
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kRejectMember rowType:XLFormRowDescriptorTypeTextImages];
    NSArray *rejectMembersArry;
    NSMutableArray *rejectIdsArray = [NSMutableArray arrayWithCapacity:0];
    if (dict && [CommonFuntion checkNullForValue:[dict objectForKey:@"rejectMember"]]) {
        rejectMembersArry = [dict objectForKey:@"rejectMember"];
        if ([rejectMembersArry count] > 0) {
            for (NSDictionary *dict in rejectMembersArry) {
                [rejectIdsArray addObject:[dict objectForKey:@"id"]];
            }
            row.value = @{@"text" : @"已拒绝",
                          @"images" : rejectMembersArry,
                          @"isEdit" : @0,
                          @"uid" : rejectIdsArray};
            
        } else {
            row.value = @{@"text" : @"已拒绝",
                          @"images" : rejectMembersArry,
                          @"isEdit" : @0,
                          @"uid" : rejectIdsArray};
        }
    } else {
        row.value = @{@"text" : @"已拒绝",
                      @"images" : rejectMembersArry,
                      @"isEdit" : @0,
                      @"uid" : rejectIdsArray};
    }
    [section addFormRow:row];
#warning 产品要求暂时先封掉这个模块12月25号。
    /*
    // 重复
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kRepeat rowType:XLFormRowDescriptorTypeTextValue];
    if ([[dict objectForKey:@"isRepeat"] integerValue]) {
        valueString = @"不重复";
    }else { // 重复 1 2 3
        NSArray *titleArray = @[@"每天重复", @"每周重复", @"每月重复"];
        valueString = titleArray[[dict[@"repeatType"] integerValue] - 1];
    }

    row.value = @{@"text" : @"重复",
                  @"value" : [self getRepeatShowInfo],
                  @"isEdit" : @(_isEdit)};
    row.action.formBlock = ^(XLFormRowDescriptor *descriptor) {
        ScheduleSelectedListController *listController = [[ScheduleSelectedListController alloc] init];
        listController.title = @"设置重复";
        NSArray *tempArray = @[@{@"title" : @"不重复", @"tag" : @(0)}, @{@"title" : @"每天重复", @"tag" : @1}, @{@"title" : @"每周重复", @"tag" : @2}, @{@"title" : @"每月重复", @"tag" : @3}];
        listController.flagOfPlanUpdate = @"update-schedule";
        listController.dicPlanInfo = _sourceDict;
        listController.dataSource = [[NSArray alloc] initWithArray:tempArray];
        listController.rowDescriptor = descriptor;
        listController.valueBlock = ^(NSDictionary *dict, NSInteger tag) {
            XLFormRowDescriptor *rDescriptor = [weak_self.form formRowWithTag:kRepeat];
            rDescriptor.value = dict;
            [weak_self updateFormRow:rDescriptor];
            
            // 不重复
            [weak_self.sourceDict setObject:@1 forKey:@"isRepeat"];
            [weak_self.sourceDict setObject:@"" forKey:@"repeatType"];
            
            // 发送更改请求
            [weak_self sendRequest:kRepeat andParams:_sourceDict];
        };
        
        
        listController.valueDateBlock = ^(){
            NSLog(@"_source:%@",_sourceDict);
            XLFormRowDescriptor *rDescriptor = [weak_self.form formRowWithTag:kRepeat];
            rDescriptor.value =  @{@"text" : @"重复",
                                   @"value" : [self getRepeatShowInfo],
                                   @"isEdit" : @(_isEdit)};;
            [weak_self updateFormRow:rDescriptor];
            if (weak_self.RefreshForPlanControllerBlock) {
                weak_self.RefreshForPlanControllerBlock();
            }
        };
        
        [weak_self.navigationController pushViewController:listController animated:YES];
    };
    [section addFormRow:row];
    
    */
    
    // 提醒
    selectedReminderType = -1;
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kReminder rowType:XLFormRowDescriptorTypeTextValue];
    if ([dict objectForKey:@"reminderType"] == [NSNull null]) {
        valueString = @"不提醒";
        selectedReminderType = -1;
    }else if ([[dict objectForKey:@"reminderType"] integerValue] == -1) {
        valueString = @"不提醒";
        selectedReminderType = -1;
    }else {
        NSArray *valueArray = @[@"准时", @"提前5分钟", @"提前10分钟", @"提前30分钟", @"提前1小时", @"提前2小时", @"提前6小时", @"提前1天", @"提前2天", @"当天（上午9点）", @"1天前（上午9点）"];
        valueString = valueArray[[_sourceDict[@"remindType"] integerValue]];
        selectedReminderType = [[_sourceDict safeObjectForKey:@"remindType"] integerValue];
    }
    selectedReminderTypeOld = selectedReminderType;

    dicReminderTypeOld = @{@"text" : @"提醒",
                           @"value" : valueString,
                           @"isEdit" : @(_isEdit)};
    row.value = dicReminderTypeOld;
    row.action.formBlock = ^(XLFormRowDescriptor *descriptor) {
        NSArray *sourceArray;
        if ([[dict objectForKey:@"isAllDay"] integerValue]) {
            sourceArray = @[@{@"title" : @"不提醒", @"tag" : @(-1)}, @{@"title" : @"准时", @"tag" : @0}, @{@"title" : @"提前5分钟", @"tag" : @1}, @{@"title" : @"提前10分钟", @"tag" : @2}, @{@"title" : @"提前30分钟", @"tag" : @3}, @{@"title" : @"提前1小时", @"tag" : @4}, @{@"title" : @"提前2小时", @"tag" : @5}, @{@"title" : @"提前6小时", @"tag" : @6}, @{@"title" : @"提前1天", @"tag" : @7}, @{@"title" : @"提前2天", @"tag" : @8}];
            sourceArray = [[NSArray alloc] initWithArray:sourceArray];
        }else {
            sourceArray = @[@{@"title" : @"不提醒", @"tag" : @(-1)}, @{@"title" : @"当天（上午9点）", @"tag" : @9}, @{@"title" : @"1天前（上午9点）", @"tag" : @10}];
            sourceArray = [[NSArray alloc] initWithArray:sourceArray];
        }
        ScheduleSelectedListController *listController = [[ScheduleSelectedListController alloc] init];
        listController.title = @"设置提醒";
        listController.dataSource = sourceArray;
        listController.rowDescriptor = descriptor;

        NSMutableDictionary *mutablDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ti",selectedReminderType],@"repeatType", nil];
        listController.dicPlanInfo = mutablDic;
        
        listController.valueBlock = ^(NSDictionary *dict, NSInteger tag) {
            
            [weak_self.sourceDict setObject:@(tag) forKey:@"remindType"];
            ///选择之后的标记
            selectedReminderTypeOld = selectedReminderType;
            selectedReminderType = tag;
            
            dicReminderTypeNew = dict;
            // 发送更改请求
            [weak_self sendRequest:kReminder andParams:_sourceDict];
            
            XLFormRowDescriptor *rDescriptor = [weak_self.form formRowWithTag:kReminder];
            rDescriptor.value = dict;
            [weak_self updateFormRow:rDescriptor];
        };
        [weak_self.navigationController pushViewController:listController animated:YES];
    };
    [section addFormRow:row];
    
    // 备注
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kRemark rowType:XLFormRowDescriptorTypeTextValue];
    if ([[dict safeObjectForKey:@"description"] length]) {
        valueString = [dict safeObjectForKey:@"description"];
        valueStr = valueString;
    }else {
        valueString = @"无备注";
    }
    row.value = @{@"text" : @"备注",
                  @"value" : valueString,
                  @"isEdit" : @(_isEdit)};
    row.action.formBlock = ^(XLFormRowDescriptor *rowDescriptor) {
        
        EditTextForDetailController *controller = [[EditTextForDetailController alloc] init];
        controller.title = @"编辑";
        controller.textStr = valueStr;
        controller.backTextViewValveBlock = ^(NSString *string) {
            XLFormRowDescriptor *rowDescriptor = [weak_self.form formRowWithTag:kRemark];
            rowDescriptor.value = @{@"text" : @"备注",
                                    @"value" : string,
                                    @"isEdit" : @(_isEdit)};
            valueStr = string;
            [weak_self.sourceDict setObject:string forKey:@"remark"];
            [weak_self sendRequest:kRemark andParams:_sourceDict];
            [weak_self updateFormRow:rowDescriptor];
//            [weak_self editOneTaskOfDetail:nil withRowDestriptor:rowDescriptor];
            
        };
        [weak_self.navigationController pushViewController:controller animated:YES];
//        InputViewController *inputController = [[InputViewController alloc] init];
//        inputController.title = @"编辑";
//        inputController.rightButtonString = @"确定";
//        inputController.placeholderString = @"添加备注";
//        inputController.textString = [rowDescriptor.value objectForKey:@"value"];
//        inputController.rowDescriptor = rowDescriptor;
//        inputController.delegateType = ValueDelegateTypeBlock;
//        inputController.valueBlock = ^(NSDictionary *dict) {
//            
//            [weak_self.sourceDict setObject:[dict safeObjectForKey:@"value"] forKey:@"remark"];
//
//            // 发送更改请求
//            [weak_self sendRequest:kRemark andParams:_sourceDict];
//            
//            XLFormRowDescriptor *rDescriptor = [weak_self.form formRowWithTag:kRemark];
//            rDescriptor.value = dict;
//            [weak_self updateFormRow:rDescriptor];
//        };
//        [weak_self.navigationController pushViewController:inputController animated:YES];
    };
    [section addFormRow:row];
    
    /*
    // 私密
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPrivate rowType:XLFormRowDescriptorTypeTextValue];
    if ([[dict objectForKey:@"isPrivate"] integerValue]) {
        valueString = @"公开";
    }else {
        valueString = @"仅参与人和上级可见";
    }
    row.value = @{@"text" : @"私密",
                  @"value" : valueString,
                  @"isEdit" : @(_isEdit)};
    row.action.formBlock = ^(XLFormRowDescriptor *rowDescriptor) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"公开", @"仅参与人和上级可见", nil];
        actionSheet.tag = 203;
        [actionSheet showInView:weak_self.view];
    };
    [section addFormRow:row];
     */
}

///actionType  区分是谁的请求  做数据的刷新
- (void)sendRequest:(NSString *)actionType  andParams:(NSDictionary *)paramsT{
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params addEntriesFromDictionary:paramsT];
    [params removeObjectForKey:@"scheduleTypeColor"];
    
    NSLog(@"---%@", appDelegateAccessor.moudle.userId);
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, kNetPath_Schedule_Update] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@"修改日程结果 = %@", responseObj);
        NSLog(@"desc = %@", [responseObj objectForKey:@"desc"]);
        if ([[responseObj objectForKey:@"status"] integerValue] == 0) {
            
            ///关联业务
            if ([actionType isEqualToString:kBusiness]) {
                [_sourceDict setObject:[dataSuccuss safeObjectForKey:@"businessType"] forKey:@"businessType"];
                [_sourceDict setObject:[dataSuccuss safeObjectForKey:@"businessId"] forKey:@"businessId"];
                
                XLFormRowDescriptor *rowDescriptor = [self.form formRowWithTag:kBusiness];
                rowDescriptor.value = dataSuccuss;
                [self updateFormRow:rowDescriptor];
            }
            
            ///提醒
            if ([actionType isEqualToString:kReminder]) {
                dicReminderTypeOld = dicReminderTypeNew;
                selectedReminderTypeOld = selectedReminderType;
            }
            
            if (_RefreshForPlanControllerBlock) {
                _RefreshForPlanControllerBlock();
            }
        }else{
            ///提醒
            if ([actionType isEqualToString:kReminder]) {
                selectedReminderType = selectedReminderTypeOld;
                XLFormRowDescriptor *rDescriptor = [self.form formRowWithTag:kReminder];
                rDescriptor.value = dicReminderTypeOld;
                [self updateFormRow:rDescriptor];
            }
        }
    } failure:^(NSError *error) {
        [hud hide:YES];
        ///提醒
        if ([actionType isEqualToString:kReminder]) {
            selectedReminderType = selectedReminderTypeOld;
            XLFormRowDescriptor *rDescriptor = [self.form formRowWithTag:kReminder];
            rDescriptor.value = dicReminderTypeOld;
            [self updateFormRow:rDescriptor];
        }
    }];
}

- (void)updateXLFormRowDescriptor {
    //注释掉异步，防止崩溃。崩溃原因：同一个数组在一线程中进行读取，在另一个线程中进行写入
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *params=[NSMutableDictionary dictionary];
        [params addEntriesFromDictionary:COMMON_PARAMS];
        [params setObject:@(_scheduleId) forKey:@"id"];
        
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        [hud show:YES];
        
        [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, kNetPath_Schedule_Info] params:params success:^(id responseObj) {
            [hud hide:YES];
            NSLog(@"日程详情 = %@", responseObj);
//            [self createXLFormWithSource:responseObj];
            [self transitionDataSource:responseObj];
            
//            dispatch_async(dispatch_get_main_queue(), ^{
            
                if (![[responseObj objectForKey:@"status"] integerValue]) {
                    XLFormRowDescriptor *row;
                    // 参与人
                    row = [self.form formRowWithTag:kAcceptMember];
                    row.value = @{@"text" : @"参与人",
                                  @"images" : (NSArray*)[responseObj objectForKey:@"acceptMember"],
                                  @"isEdit" : @1};
                    row.action.formBlock = ^(XLFormRowDescriptor *rowDescriptor) {
                        if ([[rowDescriptor.value objectForKey:@"images"] count]) {
                            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
                            for (NSDictionary *tempDict in rowDescriptor.value[@"images"]) {
                                AddressBook *item = [NSObject objectOfClass:@"AddressBook" fromJSON:tempDict];
                                [tempArray addObject:item];
                            }
                            
                            ScheduleAcceptMemberPreController *memberPreController = [[ScheduleAcceptMemberPreController alloc] init];
                            memberPreController.title = @"参与人";
                            memberPreController.sourceModel = [ExportAddress initWithArray:tempArray];
                            memberPreController.scheduleSourceDict = self.sourceDict;
                            memberPreController.refreshBlock = ^{
                                [self updateXLFormRowDescriptor];
                            };
                            [self.navigationController pushViewController:memberPreController animated:YES];
                        }
                        else {
                            ExportAddressViewController *exportController = [[ExportAddressViewController alloc] init];
                            exportController.title = @"选择参与人";
                            exportController.valueBlock = ^(NSArray *array) {
                                NSString *string = @"";
                                for (int i = 0; i < array.count; i ++) {
                                    AddressBook *item = array[i];
                                    if (i == 0) {
                                        string = [NSString stringWithFormat:@"%@", item.id];
                                    }else {
                                        string = [NSString stringWithFormat:@"%@,%@", string, item.id];
                                    }
                                }
                                NSMutableDictionary *params=[NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
                                [params addEntriesFromDictionary:_sourceDict];
                                [params setObject:string forKey:@"addStaffIds"];
                                
                                [self.view beginLoading];
                                [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, kNetPath_Schedule_Update] params:params success:^(id responseObj) {
                                    [self.view endLoading];
                                    if (![[responseObj objectForKey:@"status"] integerValue]) {
                                        [self updateXLFormRowDescriptor];
                                    }
                                } failure:^(NSError *error) {
                                    [self.view endLoading];
                                }];
                            };
                            [self.navigationController pushViewController:exportController animated:YES];
                        }
                    };
                    [self updateFormRow:row];
                    
                    // 待确认
                    row = [self.form formRowWithTag:kWaitingMember];
                    if ([[responseObj objectForKey:@"waitingMember"] count]) {
                        row.hidden = @(NO);
                        
                        row.value = @{@"text" : @"待确认",
                                      @"images" : (NSArray*)[responseObj objectForKey:@"waitingMember"],
                                      @"isEdit" : @0};
                        
                    }else {
//                        row.hidden = @(YES);
                    }
                    [self updateFormRow:row];
                    
                    // 已拒绝
                    row = [self.form formRowWithTag:kRejectMember];
                    if ([[responseObj objectForKey:@"rejectMember"] count]) {
                        row.hidden = @(NO);
                        row.value = @{@"text" : @"已拒绝",
                                      @"images" : (NSArray*)[responseObj objectForKey:@"rejectMember"],
                                      @"isEdit" : @0};
                    }else {
//                        row.hidden = @(YES);
                    }
                    [self updateFormRow:row];
                }
            [self.tableView reloadData];

//            });
        } failure:^(NSError *error) {
            [hud hide:YES];
            
        }];
//    });
}

#pragma mark - event response
- (void)rightBarButtonItemPress {
    if (_isCreater) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除", nil];
        actionSheet.tag = 201;
        [actionSheet showInView:self.view];
    }else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"退出", nil];
        actionSheet.tag = 202;
        [actionSheet showInView:self.view];
    }
}

- (void)agreeBtnPress {
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:@([appDelegateAccessor.moudle.userId integerValue]) forKey:@"staffId"];
    [params setObject:@(_scheduleId) forKey:@"scheduleId"];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];

    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, kNetPath_Schedule_Receive] params:params success:^(id responseObj) {
        [hud hide:YES];
        if (![[responseObj objectForKey:@"status"] integerValue]) {
            if (self.RefreshForPlanControllerBlock) {
                self.RefreshForPlanControllerBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            NSString *desc = @"";
            desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"接受失败";
            }
            kShowHUD(desc,nil);
        }
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:NET_ERROR inView:self.view];

    }];
}

- (void)refuseBtnPress {
    id obj=NSClassFromString(@"UIAlertController");
    if (obj) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否拒绝接受该日程" message:@"拒绝后，将向日程创建者发送通知，请输入拒绝理由" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
            textField.placeholder = @"拒绝理由";
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *refuseAction = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            UITextField *textField = alertController.textFields.lastObject;
            
            NSMutableDictionary *params=[NSMutableDictionary dictionary];
            [params addEntriesFromDictionary:COMMON_PARAMS];
            [params setObject:@([appDelegateAccessor.moudle.userId integerValue]) forKey:@"staffId"];
            [params setObject:@(_scheduleId) forKey:@"scheduleId"];
            [params setObject:textField.text forKey:@"refuseInfo"];
             __weak typeof(self) weak_self = self;
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:hud];
            [hud show:YES];
            
            [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, kNetPath_Schedule_Refuse] params:params success:^(id responseObj) {
                [hud hide:YES];
                // 请求成功
                if (![[responseObj objectForKey:@"status"] integerValue]) {
                    
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
                    
                    if (self.RefreshForPlanControllerBlock) {
                        self.RefreshForPlanControllerBlock();
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                }else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
                    CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                    comRequest.RequestAgainBlock = ^(){
                        [weak_self refuseBtnPress];
                    };
                    [comRequest loginInBackground];
                }
                else{
                    NSString *desc = @"";
                    desc = [responseObj safeObjectForKey:@"desc"];
                    if ([desc isEqualToString:@""]) {
                        desc = @"拒绝失败";
                    }
                    kShowHUD(desc,nil);
                }
            } failure:^(NSError *error) {
                [hud hide:YES];
                [CommonFuntion showToast:NET_ERROR inView:self.view];
            }];
        }];
        refuseAction.enabled = NO;
        [alertController addAction:cancelAction];
        [alertController addAction:refuseAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
//评论按钮点击事件
- (void)commentBtnPress {
    [self creatKeyBoardView];
    [textViewReview becomeFirstResponder];
}

#pragma mark - NSNotification
- (void)alertTextFieldDidChange:(NSNotification*)notification {
    UIAlertController *alertController = (UIAlertController*)self.presentedViewController;
    if (alertController) {
        UITextField *textField = alertController.textFields.firstObject;
        UIAlertAction *refuseAction = alertController.actions.lastObject;
        refuseAction.enabled = textField.text.length > 0;
    }
}

//删除评论
- (void)showAlertViewForDeleteComment {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认删除评论" message:Nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 211;
    [alert show];
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;
    
    if (actionSheet.tag == 201) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"删除提示" message:@"删除后，该日程的评论、文档等所有内容都将一起删除、且无法恢复！\n\n请确认是否删除？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        alertView.tag = 201;
        [alertView show];
    }
    
    if (actionSheet.tag == 202) {
        XLFormRowDescriptor *rowDescriptor = [self.form formRowWithTag:@"title"];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"你确定要退出【%@】日程吗？", [rowDescriptor.value objectForKey:@"name"]] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 202;
        [alertView show];
    }
    
    if (actionSheet.tag == 203) {
        
        [_sourceDict setObject:@(!buttonIndex) forKey:@"privateFlag"];
        
        // 发送更改请求
        [self sendRequest:kPrivate andParams:_sourceDict];
        
        NSArray *array = @[@"公开", @"仅参与人和上级可见"];
        XLFormRowDescriptor *rowDescriptor = [self.form formRowWithTag:kPrivate];
        rowDescriptor.value = @{@"text" : @"私密",
                                @"value" : array[buttonIndex],
                                @"isEdit" : @1};
        [self updateFormRow:rowDescriptor];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex == buttonIndex)
        return;
    
    if (alertView.tag == 201 || alertView.tag == 202) {
        NSMutableDictionary *params=[NSMutableDictionary dictionary];
        [params addEntriesFromDictionary:COMMON_PARAMS];
        
        __weak typeof(self) weak_self = self;
        NSString *pathString;
        if (alertView.tag == 201) {
            pathString = [NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, kNetPath_Schedule_Delete];
            [params setObject:@(_scheduleId) forKey:@"id"];
        }else {
            pathString = [NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, kNetPath_Schedule_Quit];
            [params setObject:appDelegateAccessor.moudle.userId forKey:@"staffId"];
            [params setObject:@(_scheduleId) forKey:@"scheduleId"];
        }
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        [hud show:YES];
        [AFNHttp post:pathString params:params success:^(id responseObj) {
            [hud hide:YES];
            if ([[responseObj objectForKey:@"status"] integerValue] == 0) {
                if (_RefreshForPlanControllerBlock) {
                    _RefreshForPlanControllerBlock();
                }
                [self.navigationController popViewControllerAnimated:YES];
            }else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^(){
                    [weak_self refuseBtnPress];
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
            [CommonFuntion showToast:NET_ERROR inView:self.view];
        }];
    }else if (alertView.tag == 211){
        if (buttonIndex == 0) {
            
        } else if (buttonIndex == 1) {
            [self deleteOneComment:commentID];
        }
    }
}

#pragma mark - setters and getters
- (UIBarButtonItem*)rightButtonItem {
    if (!_rightButtonItem) {
        _rightButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_showMore"] style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonItemPress)];
    }
    return _rightButtonItem;
}

- (UIView*)toolView {
    if (!_toolView) {
        _toolView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height - 44, kScreen_Width, 44)];
        _toolView.backgroundColor = [UIColor whiteColor];
        [_toolView.layer setBorderWidth:1];
        _toolView.layer.borderColor = [UIColor colorWithHexString:@"cbcdcd"].CGColor;
        
        NSInteger sizeWidth = (kScreen_Width-4*20)/3;
        NSString *btnTextColor = @"585858";
        
        UIButton *agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        agreeBtn.frame = CGRectMake(20, 4, sizeWidth, 36);
        agreeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [agreeBtn.layer setMasksToBounds:YES];
        [agreeBtn.layer setCornerRadius:6];
        [agreeBtn.layer setBorderWidth:1];
        agreeBtn.layer.borderColor = [UIColor colorWithHexString:@"cbcdcd"].CGColor;
        [agreeBtn setTitle:@"接受" forState:UIControlStateNormal];
        [agreeBtn setTitleColor:[UIColor colorWithHexString:btnTextColor] forState:UIControlStateNormal];
        [agreeBtn addTarget:self action:@selector(agreeBtnPress) forControlEvents:UIControlEventTouchUpInside];
        [_toolView addSubview:agreeBtn];
        
        UIButton *refuseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        refuseBtn.frame =CGRectMake(sizeWidth+40, 4, sizeWidth, 36);
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
        commentBtn.frame = CGRectMake(sizeWidth*2+60, 4, sizeWidth, 36);
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - 信息获取
///获取关联业务名称
//type类型 客户， 联系人， 销售机会， 销售线索， 市场活动
//public final static int CRM_TYPE_ACTIVITY = 201;             //市场活动
//public final static int CRM_TYPE_CLUE = 202;                 //销售线索
//public final static int CRM_TYPE_CUSTOMER = 203;             //客户
//public final static int CRM_TYPE_CONTRACT = 204;             //联系人
//public final static int CRM_TYPE_OPPORTUNITY = 205;          //销售机会
-(NSString *)getBusinessNameByCode:(NSInteger)code{
    NSString *name = @"";
    switch (code) {
        case 201:
            name = @"市场活动";
            break;
        case 202:
            name = @"销售线索";
            break;
        case 203:
            name = @"客户";
            break;
        case 204:
            name = @"联系人";
            break;
        case 205:
            name = @"销售机会";
            break;
        default:
            break;
    }
    return name;
}

///根据日程重复信息  获取显示文本
-(NSString *)getRepeatShowInfo{

    NSMutableString *valueString = [[NSMutableString alloc] init];
    if ([[_sourceDict objectForKey:@"isRepeat"] integerValue] == 0) {
        // 重复 1 2 3
        if ([[_sourceDict objectForKey:@"repeatType"] integerValue] == 1) {
            [valueString appendString:@"每1天重复一次,"];
        } else if ([[_sourceDict objectForKey:@"repeatType"] integerValue] == 2) {
            [valueString appendString:@"每1周重复一次,"];
        } else if ([[_sourceDict objectForKey:@"repeatType"] integerValue] == 3) {
            [valueString appendString:@"每1月重复一次,"];
        }
        
        if ([[_sourceDict objectForKey:@"repeatEndType"] integerValue] == 1) {
            // 永不停止
            [valueString appendString:@"无限循环"];
        } else if ([[_sourceDict objectForKey:@"repeatEndType"] integerValue] == 2) {
            // 到XX停止
            NSString *stopStr = [_sourceDict objectForKey:@"repeatEndTime"];
            [valueString appendString:@"直到"];
            [valueString appendString:stopStr];
            [valueString appendString:@"结束"];
        }
        
    }else {
        [valueString appendString:@"不重复"];
    }
    return valueString;
}
#pragma mark -- 评论
//@人
- (void)bottomButtonAction {
    [self pushToAddressBook];
}
//@进入通讯录
- (void)pushToAddressBook {
    __weak typeof(self) weak_self = self;
    ExportAddressViewController *controller = [[ExportAddressViewController alloc] init];
    controller.title = @"通讯录";
    controller.valueBlock = ^(NSArray *selectedContact){
        [weak_self initSelectContactNameStr:selectedContact];
    };
    [self.navigationController pushViewController:controller animated:YES];
}
//返回选择的联系人
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
//创建键盘view
-(void)creatKeyBoardView{
    if (keyboardContainerView == nil) {
        NSLog(@"clickReview---new->");
        keyboardContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height - 44, kScreen_Width, 44)];
        keyboardContainerView.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];;
        keyboardContainerView.layer.borderColor = [UIColor lightGrayColor].CGColor;;
        keyboardContainerView.layer.borderWidth = 0.5;
        
        //@ 按钮
        NSString *imageName = @"feed_comments_at.png";
        UIButton *aitBtn = [UIButton createButtonWithFrame:CGRectMake(12, 9, 26, 26) Target:self Selector:@selector(bottomButtonAction) Image:imageName ImagePressed:imageName];
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
-(void)keyboardWillShow:(NSNotification *)note{
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

-(void)keyboardWillHide:(NSNotification *)note{
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
            
            if (typeStr && [typeStr isEqualToString:@"Hidden"] ) {
                if (textViewReview.text && textViewReview.text.length > 0) {
                    [self creatKeyBoardView];
                    //            [textViewReview becomeFirstResponder];
                }else{
                    keyboardContainerView.hidden = YES;
                }
            }
        }
    }
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

#pragma mark - 发送评论
//发送评论
- (void)sendACommentToSever {

    NSArray *arrayAtId = nil;
    ///读取缓存
//    NSArray *arrayCache = [FMDB_SKT_CACHE select_AddressBook_AllData];
    NSArray *arrayCache = [[FMDBManagement sharedFMDBManager] getAddressBookDataSource];
    NSLog(@"arrayCache:%@",arrayCache);
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
    
    long long planId = -1;
    if ([_sourceDict objectForKey:@"id"]) {
        planId = [[_sourceDict objectForKey:@"id"] longLongValue];
    }
    [params setObject:[NSNumber numberWithLongLong:planId] forKey:@"trendsId"];
    NSString *transString = [NSString stringWithString:[textViewReview.text stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [params setObject:transString forKey:@"content"];
    ///(类型(1:动态 2：博客 3：知识库 4:日程 5:任务 6:日报 7:周报 8:月报 9:审批))
    [params setObject:@"4" forKey:@"objectType"];
    
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
                    NSString *strText = textViewReview.text;
                    textViewReview.text = [NSString stringWithFormat:@"%@ @%@ ", strText, comment.creator.name];
                    [textViewReview becomeFirstResponder];
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


#pragma mark - 删除评论
- (void)deleteOneComment:(long long)uid {
    
    //存储uid
    long long saveUid = uid;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:@"4" forKey:@"objectType"];
    [params setObject:[NSString stringWithFormat:@"%lld", uid] forKey:@"commentId"];
    [params setObject:[_sourceDict objectForKey:@"id"] forKey:@"trendsId"];
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
        [CommonFuntion showToast:NET_ERROR inView:self.view];
    }];
    
}

-(void)pushIntoBussinessView:(XLFormRowDescriptor *)formRow {
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
}

@end
