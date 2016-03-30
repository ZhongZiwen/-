//
//  CRMDetailBaseViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 16/1/6.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import "CRMDetailBaseViewController.h"
#import "ActivityDetailViewController.h"
#import "LeadDetailViewController.h"
#import "CustomerDetailViewController.h"
#import "ContactDetailViewController.h"
#import "OpportunityDetailController.h"
#import "InfoViewController.h"
#import "ActivityRecordDetailController.h"
#import "MapViewViewController.h"
#import "ActivityController.h"
#import "LeadViewController.h"
#import "CustomerViewController.h"
#import "LeadListViewController.h"
#import "OpportunityListController.h"
#import "CustomerListController.h"
#import "ContactViewController.h"
#import "ContactListViewController.h"
#import "OpportunityViewController.h"
#import "OpportunityDetailController.h"
#import "OpportunityAddContactController.h"
#import "TaskScheduleListController.h"
#import "ApprovalListViewController.h"
#import "FileListController.h"
#import "ProductListViewController.h"
#import "LeadChangeToCustomerController.h"
#import "AddressSelectedController.h"
#import "CRM_TaskNewViewController.h"
#import "CRM_ScheduleNewViewController.h"
#import "CRM_ContactNewViewController.h"
#import "CRM_OpportunityNewViewController.h"
#import "AddToMessageController.h"
#import "PhotoAssetLibraryViewController.h"
#import "RecordSendViewController.h"
#import "EditActivityViewController.h"
#import "FileListDetailController.h"
#import "SearchResultListController.h"

#import "Helper.h"
#import "MJRefresh.h"
#import "UIImageView+LBBlurredImage.h"
#import "SectionHeaderView.h"
#import "UIMessageInputView_zbs.h"
#import "CustomActionSheet.h"
#import "PopoverView.h"
#import "Reason.h"
#import "Directory.h"

#import "CustomNavigationView.h"

#import "DetailFirstCell.h"
#import "DetailInfoCell.h"
#import "DetailInfoSectionCell.h"
#import "DetailFollowRecord_userCell.h"
#import "DetailFollowRecord_systemCell.h"

#define kCellIdentifier_first @"DetailFirstCell"
#define kCellIdentifier_followUser @"DetailFollowRecord_userCell"
#define kCellIdentifier_followSystem @"DetailFollowRecord_systemCell"
#define kCellIdentifier_info @"DetailInfoCell"
#define kCellIdentifier_infoSection @"DetailInfoSectionCell"

#define kKeyboardView_Height 216.0
#define kNavBar_change_point 50

@interface CRMDetailBaseViewController ()<UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, TTTAttributedLabelDelegate, UIMessageInputViewDelegate>

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) CustomNavigationView *navCustomView;  // 自定义导航栏
@property (strong, nonatomic) UIView *footerView;           // 跟进记录视图的footerView
@property (strong, nonatomic) UIView *footerViewDatas;           // 跟进记录视图的footerView
@property (strong, nonatomic) UIView *infoFooterView;       // 信息详情视图的footerView
@property (strong, nonatomic) SectionHeaderView *sectionHeaderView;
@property (strong, nonatomic) UIMessageInputView_zbs *inputView;
@property (strong, nonatomic) CustomActionSheet *actionSheet;
@property (strong, nonatomic) UIButton *editButton;

@property (strong, nonatomic) NSMutableDictionary *followParams;    // 跟进记录的请求参数

@property (copy, nonatomic) NSString *requestPathForDetail;         // 详情
@property (copy, nonatomic) NSString *requestPathForFollowRecord;   // 跟进记录
@property (copy, nonatomic) NSString *requestPathForEditOrSave;     // 编辑资料
@property (copy, nonatomic) NSString *requestPathSendRecord;        // 快速记录
@property (copy, nonatomic) NSString *requestPathFocus;             // 关注&取消关注
@property (copy, nonatomic) NSString *requestPathTransfer;          // 转化
@property (copy, nonatomic) NSString *requestPathTrash;             // 废弃
@property (copy, nonatomic) NSString *requestPathDelete;            // 删除
@property (copy, nonatomic) NSString *requestPathNewTask;           // 新建任务
@property (copy, nonatomic) NSString *requestPathNewSchedule;       // 新建日程

@property (assign, nonatomic) NSInteger segmentIndex;


@end

@implementation CRMDetailBaseViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    // 收起键盘
    [_inputView.inputTextView resignFirstResponder];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopVoice" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
//    [self.inputView prepareToDismiss];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = kView_BG_Color;
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    [self.view addSubview:self.backgroundImageView];
    [self.view addSubview:self.navCustomView];
    [self.view addSubview:self.tableView];
    
    [self.inputView prepareToShowWithView:self.view];

//    // 隐藏导航栏,给导航栏设置空的图片
//    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
//    // 隐藏导航栏底部阴影
//    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    @weakify(self);
    self.navCustomView.backButtonClickedBlock = ^{
        @strongify(self);
        [self backButtonPress];
    };
    self.navCustomView.rightButtonClickedBlock = ^{
        @strongify(self);
        [self rightButtonPress];
    };
    
    _followParams = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [_followParams setObject:@1 forKey:@"pageNo"];
    [_followParams setObject:@10 forKey:@"pageSize"];
    
    if ([self isKindOfClass:[ActivityDetailViewController class]]) {
        self.sectionHeaderView.type = SectionHeaderViewTypeActivity;
        _requestPathForDetail = kNetPath_Activity_Detail;
        _requestPathForFollowRecord = kNetPath_Activity_FollowRecord;
        _requestPathForEditOrSave = kNetPath_Activity_EditOrSave;
        _requestPathSendRecord = kNetPath_Activity_SendRecord;
        _requestPathFocus = kNetPath_Activity_FocusOrCancel;
        _requestPathTransfer = kNetPath_Activity_Transfer;
        _requestPathDelete = kNetPath_Activity_Delete;
        _requestPathNewTask = kNetPath_Activity_CreateTask;
        _requestPathNewSchedule = kNetPath_Activity_CreateSchedule;
        
    }
    else if ([self isKindOfClass:[LeadDetailViewController class]]) {
        self.sectionHeaderView.type = SectionHeaderViewTypeLead;
        _requestPathForDetail = kNetPath_Lead_Detail;
        _requestPathForFollowRecord = kNetPath_Lead_FollowRecord;
        _requestPathForEditOrSave = kNetPath_Lead_EditOrSave;
        _requestPathSendRecord = kNetPath_Lead_SendRecord;
        _requestPathTransfer = kNetPath_Lead_Transfer;
        _requestPathTrash = kNetPath_Lead_Trash;
        _requestPathDelete = kNetPath_Lead_Delete;
        _requestPathNewTask = kNetPath_Lead_CreateTask;
        _requestPathNewSchedule = kNetPath_Lead_CreateSchedule;
        
        [self.view addSubview:self.editButton];
    }
    else if ([self isKindOfClass:[CustomerDetailViewController class]]) {
        self.sectionHeaderView.type = SectionHeaderViewTypeCustomer;
        _requestPathForDetail = kNetPath_Customer_Detail;
        _requestPathForFollowRecord = kNetPath_Customer_FollowRecord;
        _requestPathForEditOrSave = kNetPath_Customer_EditOrSave;
        _requestPathSendRecord = kNetPath_Customer_SendRecord;
        _requestPathFocus = kNetPath_Customer_FocusOrCancel;
        _requestPathTransfer = kNetPath_Customer_Transfer;
        _requestPathTrash = kNetPath_Customer_Trash;
        _requestPathDelete = kNetPath_Customer_Delete;
        _requestPathNewTask = kNetPath_Customer_CreateTask;
        _requestPathNewSchedule = kNetPath_Customer_CreateSchedule;
        
    }
    else if ([self isKindOfClass:[ContactDetailViewController class]]) {
        self.sectionHeaderView.type = SectionHeaderViewTypeContact;
        _requestPathForDetail = kNetPath_Contact_Detail;
        _requestPathForFollowRecord = kNetPath_Contact_FollowRecord;
        _requestPathForEditOrSave = kNetPath_Contact_EditOrSave;
        _requestPathSendRecord = kNetPath_Contacts_SendRecord;
        _requestPathTransfer = kNetPath_Contact_Transfer;
        _requestPathDelete = kNetPath_Contact_Delete;
        _requestPathNewTask = kNetPath_Contact_CreateTask;
        _requestPathNewSchedule = kNetPath_Contact_CreateSchedule;
        
    }
    else if ([self isKindOfClass:[OpportunityDetailController class]]) {
        self.sectionHeaderView.type = SectionHeaderViewTypeOpportunity;
        _requestPathForDetail = kNetPath_SaleChance_Detail;
        _requestPathForFollowRecord = kNetPath_SaleChance_FollowRecord;
        _requestPathForEditOrSave = kNetPath_SaleChance_EditOrSave;
        _requestPathSendRecord = kNetPath_SaleChance_SendRecord;
        _requestPathFocus = kNetPath_SaleChance_FocusOrCancel;
        _requestPathTransfer = kNetPath_SaleChance_Transfer;
        _requestPathDelete = kNetPath_SaleChance_Delete;
        _requestPathNewTask = kNetPath_SaleChance_CreateTask;
        _requestPathNewSchedule = kNetPath_SaleChance_CreateSchedule;
    }
    
    // 销售线索
    self.sectionHeaderView.saleLeadBlock = ^{
        @strongify(self);
        LeadListViewController *leadListController = [[LeadListViewController alloc] init];
        leadListController.title = @"销售线索";
        leadListController.activityId = self.id;
        leadListController.refreshBlock = ^{
            [self sendRequestForRefreshHeaderView];
        };
        [self.navigationController pushViewController:leadListController animated:YES];
    };
    // 销售机会
    self.sectionHeaderView.saleOpportunityBlock = ^{
        @strongify(self);
        OpportunityListController *opportunityListController = [[OpportunityListController alloc] init];
        opportunityListController.title = @"销售机会";
        if ([self isKindOfClass:[CustomerDetailViewController class]]) {
            opportunityListController.customerId = self.detailItem.id;
            opportunityListController.fromType = OpportunityListFromTypeCustomer;
            opportunityListController.requestListPath = kNetPath_SaleChance_ListFromCustomer;
            opportunityListController.requestInitPath = kNetPath_Customer_NewOpportunity;
            opportunityListController.requestSavePath = kNetPath_Customer_SaveNewOpportunity;
        }
        else if ([self isKindOfClass:[ContactDetailViewController class]]) {
            opportunityListController.customerId = self.detailItem.customer.id;
            opportunityListController.contactId = self.detailItem.id;
            opportunityListController.fromType = OpportunityListFromTypeContact;
            opportunityListController.requestListPath = kNetPath_SaleChance_ListFromContact;
            opportunityListController.requestInitPath = kNetPath_Contact_NewOpportunity;
            opportunityListController.requestSavePath = kNetPath_Contact_SaveNewOpportunity;
        }
        opportunityListController.refreshBlock = ^{
            [self sendRequestForRefreshHeaderView];
        };
        [self.navigationController pushViewController:opportunityListController animated:YES];
    };
    // 客户
    self.sectionHeaderView.customerBlock = ^{
        @strongify(self);
        CustomerListController *customerListController = [[CustomerListController alloc] init];
        customerListController.title = @"客户";
        customerListController.activityId = self.id;
        customerListController.refreshBlock = ^{
            [self sendRequestForRefreshHeaderView];
        };
        [self.navigationController pushViewController:customerListController animated:YES];
    };
    // 联系人
    self.sectionHeaderView.contacterBlock = ^{
        @strongify(self);
        ContactListViewController *contactController = [[ContactListViewController alloc] init];
        contactController.title = @"联系人";
        if ([self isKindOfClass:[CustomerDetailViewController class]]) {
            contactController.customerId = self.detailItem.id;
            contactController.fromType = ContactListFromTypeCustomer;
            contactController.requestListPath = kNetPath_Contact_ListFromCustomer;
            contactController.requestInitPath = kNetPath_Customer_NewContact;
            contactController.requestScanfPath = kNetPath_Customer_ScanningFromCustomer;
            contactController.requestSavePath = kNetPath_Customer_SaveNewContact;
        }
        else if ([self isKindOfClass:[OpportunityDetailController class]]) {
            contactController.customerId = self.detailItem.customer.id;
            contactController.fromType = ContactListFromTypeOpportunity;
            contactController.requestListPath = kNetPath_SaleChance_ContactList;
            contactController.requestInitPath = kNetPath_SaleChance_ContactNewInit;
            contactController.requestScanfPath = kNetPath_SaleChance_ContactScanInit;
            contactController.requestSavePath = kNetPath_SaleChance_ContactAdd;
        }
        contactController.refreshBlock = ^{
            [self sendRequestForRefreshHeaderView];
        };
        [self.navigationController pushViewController:contactController animated:YES];
    };
    // 日程任务
    self.sectionHeaderView.taskScheduleBlock = ^{
        @strongify(self);
        TaskScheduleListController *taskScheduleController = [[TaskScheduleListController alloc] init];
        if ([self isKindOfClass:[ActivityDetailViewController class]]) {
            taskScheduleController.requestPath = kNetPath_Activity_TaskScheduleList;
            taskScheduleController.task_createPath = kNetPath_Activity_CreateTask;
            taskScheduleController.schedule_createPath = kNetPath_Activity_CreateSchedule;
        }
        else if ([self isKindOfClass:[LeadDetailViewController class]]) {
            taskScheduleController.requestPath = kNetPath_Lead_TaskScheduleList;
            taskScheduleController.task_createPath = kNetPath_Lead_CreateTask;
            taskScheduleController.schedule_createPath = kNetPath_Lead_CreateSchedule;
        }
        else if ([self isKindOfClass:[CustomerDetailViewController class]]) {
            taskScheduleController.requestPath = kNetPath_Customer_TaskScheduleList;
            taskScheduleController.task_createPath = kNetPath_Customer_CreateTask;
            taskScheduleController.schedule_createPath = kNetPath_Customer_CreateSchedule;
        }
        else if ([self isKindOfClass:[ContactDetailViewController class]]) {
            taskScheduleController.requestPath = kNetPath_Contact_TaskScheduleList;
            taskScheduleController.task_createPath = kNetPath_Contact_CreateTask;
            taskScheduleController.schedule_createPath = kNetPath_Contact_CreateSchedule;
        }
        else if ([self isKindOfClass:[OpportunityDetailController class]]) {
            taskScheduleController.requestPath = kNetPath_SaleChance_TaskScheduleList;
            taskScheduleController.task_createPath = kNetPath_SaleChance_CreateTask;
            taskScheduleController.schedule_createPath = kNetPath_SaleChance_CreateSchedule;
        }
        taskScheduleController.refreshBlock = ^{
            [self sendRequestForRefreshHeaderView];
        };
        [self.navigationController pushViewController:taskScheduleController animated:YES];
    };
    // 审批
    self.sectionHeaderView.approvalBlock = ^{
        @strongify(self);
        ApprovalListViewController *approvalController = [[ApprovalListViewController alloc] init];
        if ([self isKindOfClass:[ActivityDetailViewController class]]) {
            approvalController.requestPath = kNetPath_Activity_ApprovalList;
        }
        else if ([self isKindOfClass:[LeadDetailViewController class]]) {
            approvalController.requestPath = kNetPath_Lead_ApprovalList;
        }
        else if ([self isKindOfClass:[CustomerDetailViewController class]]) {
            approvalController.requestPath = kNetPath_Customer_ApprovalList;
        }
        else if ([self isKindOfClass:[ContactDetailViewController class]]) {
            approvalController.requestPath = kNetPath_Contact_ApprovalList;
        }
        else if ([self isKindOfClass:[OpportunityDetailController class]]) {
            approvalController.requestPath = kNetPath_SaleChance_ApprovalList;
        }
        approvalController.refreshBlock = ^{
            [self sendRequestForRefreshHeaderView];
        };
        [self.navigationController pushViewController:approvalController animated:YES];
    };
    // 产品
    self.sectionHeaderView.productBlock = ^{
        @strongify(self);
        ProductListViewController *productController = [[ProductListViewController alloc] init];
        productController.title = @"产品清单";
        productController.refreshBlock = ^{
            [self sendRequestForRefreshHeaderView];
        };
        [self.navigationController pushViewController:productController animated:YES];
    };
    // 文档
    self.sectionHeaderView.fileBlock = ^{
        @strongify(self);
        FileListController *fileListController = [[FileListController alloc] init];
        if ([self isKindOfClass:[ActivityDetailViewController class]]) {
            fileListController.title = @"市场活动文档";
            fileListController.requestPath = kNetPath_Activity_FileList;

        }
        else if ([self isKindOfClass:[CustomerDetailViewController class]]) {
            fileListController.title = @"客户文档";
            fileListController.requestPath = kNetPath_Customer_FileList;
        }
        else if ([self isKindOfClass:[OpportunityDetailController class]]) {
            fileListController.title = @"销售机会文档";
            fileListController.requestPath = kNetPath_SaleChance_FileList;
        }
        [self.navigationController pushViewController:fileListController animated:YES];
    };
    
    [self.tableView addFooterWithTarget:self action:@selector(sendRequestForReloadMoreFollowRecord)];
    
    // 获取详情
    [self.navCustomView startAnimation];
    [self sendRequestForDetail];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)backButtonPress {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editButtonPress {
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (ColumnModel *tempColumn in _detailItem.columnsArray) {
        if ([tempColumn.editAble integerValue]) {
            continue;
        }
        ColumnModel *column = [tempColumn copy];
        [tempArray addObject:column];
    }
    @weakify(self);
    EditActivityViewController *editActivityController = [[EditActivityViewController alloc] init];
    editActivityController.title = [NSString stringWithFormat:@"编辑%@", self.title];
    editActivityController.id = _detailItem.id;
    editActivityController.sourceArray = tempArray;
    editActivityController.requestPath = _requestPathForEditOrSave;
    editActivityController.refreshBlock = ^{
        @strongify(self);
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
        [params setObject:_id forKey:@"id"];
        [self.view beginLoading];
        [[Net_APIManager sharedManager] request_Common_CRMDetail_WithPath:_requestPathForDetail params:params block:^(id data, NSError *error) {
            [self.view endLoading];
            if (data) {
                
                CRMDetail *tempDetailItem = [NSObject objectOfClass:@"CRMDetail" fromJSON:data];
                
                // 当前销售阶段
                tempDetailItem.currentStage = [NSObject objectOfClass:@"OpportunityStage" fromJSON:data[@"currentOpportunity"]];
                
                // 销售阶段
                NSMutableArray *tempOpportunity = [[NSMutableArray alloc] initWithCapacity:0];
                for (NSDictionary *tempDict in data[@"opportunityList"]) {
                    OpportunityStage *item = [NSObject objectOfClass:@"OpportunityStage" fromJSON:tempDict];
                    [tempOpportunity addObject:item];
                }
                tempDetailItem.stageListArray = tempOpportunity;
                
                // 跟进状态
                NSMutableArray *tempFollowArray = [[NSMutableArray alloc] initWithCapacity:0];
                for (NSDictionary *tempDict in data[@"followList"]) {
                    ValueIdModel *item = [NSObject objectOfClass:@"ValueIdModel" fromJSON:tempDict];
                    [tempFollowArray addObject:item];
                }
                tempDetailItem.followListArray = tempFollowArray;
                
                // 活动状态
                NSMutableArray *tempActivityArray = [[NSMutableArray alloc] initWithCapacity:0];
                for (NSDictionary *tempDict in data[@"activityList"]) {
                    ValueIdModel *item = [NSObject objectOfClass:@"ValueIdModel" fromJSON:tempDict];
                    [tempActivityArray addObject:item];
                }
                tempDetailItem.activityListArray = tempActivityArray;
                
                // 团队成员
                NSMutableArray *tempStaffArray = [[NSMutableArray alloc] initWithCapacity:0];
                for (NSDictionary *tempDict in data[@"staffs"]) {
                    DetailStaffModel *item = [NSObject objectOfClass:@"DetailStaffModel" fromJSON:tempDict];
                    [tempStaffArray addObject:item];
                }
                [tempDetailItem configStaffArray:tempStaffArray];
                
                // 详细资料
                NSMutableArray *tempColumnArray = [[NSMutableArray alloc] initWithCapacity:0];
                for (NSDictionary *tempDict in data[@"columns"]) {
                    
                    ColumnModel *item = [NSObject objectOfClass:@"ColumnModel" fromJSON:tempDict];
                    for (NSDictionary *selectedDict in tempDict[@"select"]) {
                        ColumnSelectModel *selectItem = [NSObject objectOfClass:@"ColumnSelectModel" fromJSON:selectedDict];
                        [item.selectArray addObject:selectItem];
                    }
                    [item configResultWithDictionary:tempDict];
                    [tempColumnArray addObject:item];
                }
                tempDetailItem.columnsArray = tempColumnArray;
                [tempDetailItem configColumnsShowArray];
                
                // 权限
                NSMutableArray *tempCodesArray = [[NSMutableArray alloc] initWithCapacity:0];
                for (NSDictionary *tempDict in data[@"codes"]) {
                    Code *item = [NSObject objectOfClass:@"Code" fromJSON:tempDict];
                    [tempCodesArray addObject:item];
                    
                    // 显示编辑按钮
                    if ([appDelegateAccessor.moudle.userFunctionCodes rangeOfString:kCrm_activityEdit].location != NSNotFound && [item.code isEqualToNumber:@1005] && [item.status isEqualToNumber:@0]) { // 市场活动
                        [self.view addSubview:self.editButton];
                    }
                    else if ([appDelegateAccessor.moudle.userFunctionCodes rangeOfString:kCrm_customerEdit].location != NSNotFound && [item.code isEqualToNumber:@2005] && [item.status isEqualToNumber:@0]) { // 客户
                        [self.view addSubview:self.editButton];
                    }
                    else if ([appDelegateAccessor.moudle.userFunctionCodes rangeOfString:kCrm_chanceEdit].location != NSNotFound && [item.code isEqualToNumber:@3005] && [item.status isEqualToNumber:@0]) { // 销售机会
                        [self.view addSubview:self.editButton];
                    }
                    else if ([appDelegateAccessor.moudle.userFunctionCodes rangeOfString:kCrm_contactEdit].location != NSNotFound && [item.code isEqualToNumber:@4005] && [item.status isEqualToNumber:@0]) {
                        [self.view addSubview:self.editButton];
                    }
                }
                tempDetailItem.codesArray = tempCodesArray;
                
                // 跟进记录数组
                tempDetailItem.followRecordArray = _detailItem.followRecordArray;
                
                // 活动类型数组
                tempDetailItem.recordTypeArray = _detailItem.recordTypeArray;
                
                _detailItem = tempDetailItem;
                
                // tableHeaderView
                [self configTableViewHeaderView];
                
                // 业务
                [self.sectionHeaderView configDataSourceWithDetailItem:_detailItem];
                
                [_tableView reloadData];
            }
        }];
    };
    
    [self.navigationController pushViewController:editActivityController animated:YES];
}

- (void)rightButtonPress {
    
    NSMutableArray *tempTitleArray;
    NSMutableArray *tempImageArray;
    
    NSString *deleteStr;
    NSString *backPoolStr;
    if ([self isKindOfClass:[ActivityDetailViewController class]]) {
        deleteStr = @"删除该市场活动";
    }
    else if ([self isKindOfClass:[LeadDetailViewController class]]) {
        deleteStr = @"删除该销售线索";
        backPoolStr = @"退回销售线索池";
    }
    else if ([self isKindOfClass:[CustomerDetailViewController class]]) {
        deleteStr = @"删除该客户";
        backPoolStr = @"退回客户池";
    }
    else if ([self isKindOfClass:[ContactDetailViewController class]]) {
        deleteStr = @"删除该联系人";
    }
    else if ([self isKindOfClass:[OpportunityDetailController class]]) {
        deleteStr = @"删除该销售机会";
    }
    // 关注
    PopoverItem *focusItem = [PopoverItem initItemWithTitle:([_detailItem.focus integerValue] ? @"关注" : @"取消关注") image:nil target:self action:@selector(focusChanged)];
    // 转换为我的客户
    PopoverItem *changeCustomerItem = [PopoverItem initItemWithTitle:@"转换为我的客户" image:nil target:self action:@selector(changeCustomer)];
    // 转移给他人
    PopoverItem *transferItem = [PopoverItem initItemWithTitle:@"转移给他人" image:nil target:self action:@selector(transferToOther)];
    // 废弃
    PopoverItem *trashItem = [PopoverItem initItemWithTitle:@"废弃" image:nil target:self action:@selector(trash)];
    // 退回公海池
    PopoverItem *backPoolItem = [PopoverItem initItemWithTitle:backPoolStr image:nil target:self action:@selector(backPool)];
    // 删除
    PopoverItem *deleteItem = [PopoverItem initItemWithTitle:deleteStr image:nil target:self action:@selector(delete)];
    // 新建任务
    PopoverItem *newTaskItem = [PopoverItem initItemWithTitle:@"新建任务" image:[UIImage imageNamed:@"followup_task"] target:self action:@selector(newTask)];
    // 新建日程
    PopoverItem *newScheduleItem = [PopoverItem initItemWithTitle:@"新建日程" image:[UIImage imageNamed:@"followup_schedule"] target:self action:@selector(newSchedule)];
    // 新建联系人
    PopoverItem *newContactItem = [PopoverItem initItemWithTitle:@"新建联系人" image:[UIImage imageNamed:@"add_contact"] target:self action:@selector(newContacter)];
    // 新建销售机会
    PopoverItem *newSaleChanceItem = [PopoverItem initItemWithTitle:@"新建销售机会" image:[UIImage imageNamed:@"sales_step"] target:self action:@selector(newSaleOpportunity)];
    // 添加已有联系人
    PopoverItem *addContactItem = [PopoverItem initItemWithTitle:@"添加已有联系人" image:[UIImage imageNamed:@"add_contact"] target:self action:@selector(addContact)];
    // 发短信给销售线索
    PopoverItem *msgToSaleChanceItem = [PopoverItem initItemWithTitle:@"发短信给销售线索" image:[UIImage imageNamed:@"sms_toleads"] target:self action:@selector(sendMsgToSaleChance)];
    // 发短信给客户
    PopoverItem *msgToCustomerItem = [PopoverItem initItemWithTitle:@"发短信给客户" image:[UIImage imageNamed:@"sms_toleads"] target:self action:@selector(sendMsgToCustomer)];
    
    if ([self isKindOfClass:[ActivityDetailViewController class]]) {
        tempTitleArray = [[NSMutableArray alloc] initWithObjects:focusItem, nil];
        for (Code *tempCode in _detailItem.codesArray) {
            if ([tempCode.code isEqualToNumber:@1001] && [tempCode.status isEqualToNumber:@0]) {
                [tempTitleArray addObject:transferItem];
            }
            else if ([appDelegateAccessor.moudle.userFunctionCodes rangeOfString:kCrm_activityDelete].location != NSNotFound && [tempCode.code isEqualToNumber:@1000] && [tempCode.status isEqualToNumber:@0]) {
                [tempTitleArray addObject:deleteItem];
            }
        }
        tempImageArray = [[NSMutableArray alloc] initWithObjects:newTaskItem, newScheduleItem, msgToSaleChanceItem, msgToCustomerItem, nil];
    }
    else if ([self isKindOfClass:[LeadDetailViewController class]]) {
        // 线索池未开启时，不显示废弃和退回公海池
        if (appDelegateAccessor.moudle.isOpen_cluePool) {
            tempTitleArray = [[NSMutableArray alloc] initWithObjects:transferItem, nil];
        }
        else {
            tempTitleArray = [[NSMutableArray alloc] initWithObjects:transferItem, trashItem, backPoolItem, nil];
        }
        
        if ([appDelegateAccessor.moudle.userFunctionCodes rangeOfString:kCrm_leadConvert].location != NSNotFound) {
            [tempTitleArray insertObject:changeCustomerItem atIndex:0];
        }
        
        if ([appDelegateAccessor.moudle.userFunctionCodes rangeOfString:kCrm_leadDelete].location != NSNotFound && ![_detailItem.claimStatus isEqualToString:@"3"]) {
            [tempTitleArray addObject:deleteItem];
        }
        tempImageArray = [[NSMutableArray alloc] initWithObjects:newTaskItem, newScheduleItem, nil];
    }
    else if ([self isKindOfClass:[CustomerDetailViewController class]]) {
        tempTitleArray = [[NSMutableArray alloc] initWithObjects:focusItem, nil];
        for (Code *tempCode in _detailItem.codesArray) {
            if ([tempCode.code isEqualToNumber:@2001] && [tempCode.status isEqualToNumber:@0]) {
                [tempTitleArray addObject:transferItem];
            }
            else if ([tempCode.code isEqualToNumber:@2007] && [tempCode.status isEqualToNumber:@0] && !appDelegateAccessor.moudle.isOpen_customerPool) {
                [tempTitleArray addObject:trashItem];
            }
            else if ([tempCode.code isEqualToNumber:@2006] && [tempCode.status isEqualToNumber:@0] && !appDelegateAccessor.moudle.isOpen_customerPool) {
                [tempTitleArray addObject:backPoolItem];
            }
            else if ([appDelegateAccessor.moudle.userFunctionCodes rangeOfString:kCrm_customerDelete].location != NSNotFound && [tempCode.code isEqualToNumber:@2000] && [tempCode.status isEqualToNumber:@0]) {
                [tempTitleArray addObject:deleteItem];
            }
        }
        tempImageArray = [[NSMutableArray alloc] initWithObjects:newTaskItem, newScheduleItem, newContactItem, newSaleChanceItem, nil];
    }
    else if ([self isKindOfClass:[ContactDetailViewController class]]) {
        tempTitleArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (Code *tempCode in _detailItem.codesArray) {
            if ([tempCode.code isEqualToNumber:@4001] && [tempCode.status isEqualToNumber:@0]) {
                [tempTitleArray addObject:transferItem];
            }
            else if ([appDelegateAccessor.moudle.userFunctionCodes rangeOfString:kCrm_contactDelete].location != NSNotFound && [tempCode.code isEqualToNumber:@4000] && [tempCode.status isEqualToNumber:@0]) {
                [tempTitleArray addObject:deleteItem];
            }
        }
        tempImageArray = [[NSMutableArray alloc] initWithObjects:newTaskItem, newScheduleItem, newSaleChanceItem, nil];
    }
    else if ([self isKindOfClass:[OpportunityDetailController class]]) {
        tempTitleArray = [[NSMutableArray alloc] initWithObjects:focusItem, nil];
        for (Code *tempCode in _detailItem.codesArray) {
            if ([tempCode.code isEqualToNumber:@3001] && [tempCode.status isEqualToNumber:@0]) {
                [tempTitleArray addObject:transferItem];
            }
            else if ([appDelegateAccessor.moudle.userFunctionCodes rangeOfString:kCrm_chanceDelete].location != NSNotFound && [tempCode.code isEqualToNumber:@3000] && [tempCode.status isEqualToNumber:@0]) {
                [tempTitleArray addObject:deleteItem];
            }
        }
        tempImageArray = [[NSMutableArray alloc] initWithObjects:newTaskItem, newScheduleItem, addContactItem, nil];
    }
    
    PopoverView *pop = [[PopoverView alloc] initWithImageItems:tempImageArray titleItems:tempTitleArray];
    [pop show];
}

- (void)focusChanged {
    NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [tempParams setObject:_id forKey:@"id"];
    [tempParams setObject:@(![_detailItem.focus integerValue]) forKey:@"type"];
    [[Net_APIManager sharedManager] request_Common_FocusOrCancel_WithPath:_requestPathFocus params:tempParams block:^(id data, NSError *error) {
        if (data) {
            if ([_detailItem.focus isEqualToNumber:@0]) {
                [NSObject showHudTipStr:@"取消关注成功"];
            }
            else {
                [NSObject showHudTipStr:@"关注成功"];
            }
            _detailItem.focus = @(![_detailItem.focus integerValue]);
        }
        else {
            if ([_detailItem.focus isEqualToNumber:@0]) {
                [NSObject showHudTipStr:@"取消关注失败"];
            }
            else {
                [NSObject showHudTipStr:@"关注失败"];
            }
        }
    }];
}

- (void)changeCustomer {
    LeadChangeToCustomerController *changeController = [[LeadChangeToCustomerController alloc] init];
    changeController.title = @"转换销售线索";
    changeController.id = _detailItem.id;
    [self.navigationController pushViewController:changeController animated:YES];
}

- (void)transferToOther {
    AddressSelectedController *addressBookController = [[AddressSelectedController alloc] init];
    addressBookController.title = @"选择同事";
    addressBookController.selectedBlock = ^(AddressBook *item) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"%@转移后将无法恢复，请确认是否将【%@】转移给【%@】", self.title, _detailItem.name, item.name] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
            [params setObject:item.id forKey:@"userId"];
            [self.view beginLoading];
            [[Net_APIManager sharedManager] request_Common_Transfer_WithPath:_requestPathTransfer params:params block:^(id data, NSError *error) {
                [self.view endLoading];
                if (data) {
                    [NSObject showHudTipStr:@"转移成功"];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else if (error.code == STATUS_SESSION_UNAVAILABLE) {
                    CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                    comRequest.RequestAgainBlock = ^(){
                        [NSObject showHudTipStr:@"转移失败，请重试"];
                    };
                    [comRequest loginInBackground];
                }
                else {
                    [NSObject showHudTipStr:@"转移失败!"];
                }
            }];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:confirmAction];
        [self presentViewController:alertController animated:YES completion:nil];
    };
    [self.navigationController pushViewController:addressBookController animated:YES];
}

- (void)trash {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"您确定要废弃此%@吗?", self.title] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confireAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
        [tempParams setObject:_detailItem.id forKey:@"id"];
        [self.view beginLoading];
        [[Net_APIManager sharedManager] request_Common_Trash_WithPath:_requestPathTrash params:tempParams block:^(id data, NSError *error) {
            [self.view endLoading];
            if (data) {
                [NSObject showHudTipStr:@"废弃成功"];
                [self.navigationController.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIViewController *obj, NSUInteger idx, BOOL *stop) {
                    if ([obj isKindOfClass:[SearchResultListController class]]) {
                        SearchResultListController *searchListController = (SearchResultListController*)obj;
                        [self.navigationController popToViewController:searchListController animated:YES];
                        *stop = YES;
                    }
                    if ([obj isKindOfClass:[SearchViewController class]]) {
                        SearchViewController *searchController = (SearchViewController*)obj;
                        [self.navigationController popToViewController:searchController animated:YES];
                        *stop = YES;
                    }
                    if ([obj isKindOfClass:[LeadListViewController class]]) {
                        LeadListViewController *leadListController = (LeadListViewController*)obj;
                        [leadListController deleteAndRefreshDataSource];
                        [self.navigationController popToViewController:leadListController animated:YES];
                        *stop = YES;
                    }
                    if ([obj isKindOfClass:[CustomerListController class]]) {
                        CustomerListController *customerListController = (CustomerListController*)obj;
                        [customerListController deleteAndRefreshDataSource];
                        [self.navigationController popToViewController:customerListController animated:YES];
                        *stop = YES;
                    }
                    if ([obj isKindOfClass:[LeadViewController class]]) {
                        LeadViewController *leadController = (LeadViewController*)obj;
                        [leadController deleteAndRefreshDataSource];
                        [self.navigationController popToViewController:leadController animated:YES];
                        *stop = YES;
                    }
                    if ([obj isKindOfClass:[CustomerViewController class]]) {
                        CustomerViewController *customerController = (CustomerViewController*)obj;
                        [customerController deleteAndRefreshDataSource];
                        [self.navigationController popToViewController:customerController animated:YES];
                        *stop = YES;
                    }
                }];
            }
            else if (error.code == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^(){
                    [NSObject showHudTipStr:@"废弃失败，请重试"];
                };
                [comRequest loginInBackground];
            }
            else {
                [NSObject showHudTipStr:@"操作失败"];
            }
        }];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:confireAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)backPool {
    NSString *requestPath;
    NSString *requestPathForReason;
    if ([self isKindOfClass:[LeadDetailViewController class]]) {
        requestPath = kNetPath_Lead_BackToPool;
        requestPathForReason = kNetPath_Lead_BackReason;
    }
    else if ([self isKindOfClass:[CustomerDetailViewController class]]) {
        requestPath = kNetPath_Customer_BackToPool;
        requestPathForReason = kNetPath_Customer_BackReason;
    }
    
    @weakify(self);
    self.actionSheet.title = @"选择退回原因";
    _actionSheet.actionType = ActionSheetTypeFromReason;
    _actionSheet.selectedBlock = ^(id obj, ActionSheetTypeFrom fromType) {
        @strongify(self);
        Reason *item = obj;
        
        NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
        [tempParams setObject:self.detailItem.group.id forKey:@"groupId"];
        [tempParams setObject:item.id forKey:@"reasonId"];
        [tempParams setObject:@"" forKey:@"remark"];
        [self.view beginLoading];
        [[Net_APIManager sharedManager] request_Common_BackToPool_WithPath:requestPath params:tempParams block:^(id data, NSError *error) {
            [self.view endLoading];
            if (data) {
                [NSObject showHudTipStr:@"退回成功"];
                [self.navigationController.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIViewController *obj, NSUInteger idx, BOOL * stop) {
                    if ([obj isKindOfClass:[SearchResultListController class]]) {
                        SearchResultListController *searchListController = (SearchResultListController*)obj;
                        [self.navigationController popToViewController:searchListController animated:YES];
                        *stop = YES;
                    }
                    if ([obj isKindOfClass:[LeadListViewController class]]) {
                        LeadListViewController *leadListController = (LeadListViewController*)obj;
                        [leadListController deleteAndRefreshDataSource];
                        [self.navigationController popToViewController:leadListController animated:YES];
                        *stop = YES;
                    }
                    if ([obj isKindOfClass:[CustomerListController class]]) {
                        CustomerListController *customerListController = (CustomerListController*)obj;
                        [customerListController deleteAndRefreshDataSource];
                        [self.navigationController popToViewController:customerListController animated:YES];
                        *stop = YES;
                    }
                    if ([obj isKindOfClass:[LeadViewController class]]) {
                        LeadViewController *leadController = (LeadViewController*)obj;
                        [leadController deleteAndRefreshDataSource];
                        [self.navigationController popToViewController:leadController animated:YES];
                        *stop = YES;
                    }
                    if ([obj isKindOfClass:[CustomerViewController class]]) {
                        CustomerViewController *customerController = (CustomerViewController*)obj;
                        [customerController deleteAndRefreshDataSource];
                        [self.navigationController popToViewController:customerController animated:YES];
                        *stop = YES;
                    }
                }];
            }
            else if (error.code == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^(){
                    [NSObject showHudTipStr:@"退回失败，请重试"];
                };
                [comRequest loginInBackground];
            }
            else {
                [NSObject showHudTipStr:@"退回失败"];
            }
        }];
    };
    
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_Common_BackReason_WithPath:requestPathForReason block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            for (NSDictionary *tempDict in data[@"reasons"]) {
                Reason *item = [NSObject objectOfClass:@"Reason" fromJSON:tempDict];
                [tempArray addObject:item];
            }
            
            _actionSheet.sourceArray = tempArray;
            [_actionSheet show];
        }
    }];
}

- (void)delete {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"删除该%@后，活动记录等相关信息都将被彻底删除，请确认是否删除？", self.title] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self.view beginLoading];
        [[Net_APIManager sharedManager] request_Common_Delete_WithPath:_requestPathDelete params:COMMON_PARAMS block:^(id data, NSError *error) {
            [self.view endLoading];
            if (data) {
                [NSObject showHudTipStr:@"删除成功"];
                [self.navigationController.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop) {
                    
                    if ([viewController isKindOfClass:[SearchResultListController class]]) {
                        SearchResultListController *searchListController = (SearchResultListController*)viewController;
                        [self.navigationController popToViewController:searchListController animated:YES];
                        *stop = YES;
                    }
                    if ([viewController isKindOfClass:[SearchViewController class]]) {
                        SearchViewController *searchController = (SearchViewController*)viewController;
                        [self.navigationController popToViewController:searchController animated:YES];
                        *stop = YES;
                    }
                    if ([viewController isKindOfClass:[LeadListViewController class]]) {
                        LeadListViewController *leadListController = (LeadListViewController*)viewController;
                        [leadListController deleteAndRefreshDataSource];
                        [self.navigationController popToViewController:leadListController animated:YES];
                        *stop = YES;
                    }
                    
                    if ([viewController isKindOfClass:[CustomerListController class]]) {
                        CustomerListController *customerListController = (CustomerListController*)viewController;
                        [customerListController deleteAndRefreshDataSource];
                        [self.navigationController popToViewController:customerListController animated:YES];
                        *stop = YES;
                    }
                    
                    if ([viewController isKindOfClass:[ContactListViewController class]]) {
                        ContactListViewController *contactListController = (ContactListViewController*)viewController;
                        [contactListController deleteAndRefreshDataSource];
                        [self.navigationController popToViewController:contactListController animated:YES];
                        *stop = YES;
                    }
                    if ([viewController isKindOfClass:[OpportunityListController class]]) {
                        OpportunityListController *opportunityListController = (OpportunityListController*)viewController;
                        [opportunityListController deleteAndRefreshDataSource];
                        [self.navigationController popToViewController:opportunityListController animated:YES];
                        *stop = YES;
                    }
                    
                    if ([viewController isKindOfClass:[ActivityController class]]) {
                        ActivityController *activityController = (ActivityController*)viewController;
                        [activityController deleteAndRefreshDataSource];
                        [self.navigationController popToViewController:activityController animated:YES];
                        *stop = YES;
                    }
                    
                    if ([viewController isKindOfClass:[LeadViewController class]]) {
                        LeadViewController *leadController = (LeadViewController*)viewController;
                        [leadController deleteAndRefreshDataSource];
                        [self.navigationController popToViewController:leadController animated:YES];
                        *stop = YES;
                    }
                    
                    if ([viewController isKindOfClass:[CustomerViewController class]]) {
                        CustomerViewController *customerController = (CustomerViewController*)viewController;
                        [customerController deleteAndRefreshDataSource];
                        [self.navigationController popToViewController:customerController animated:YES];
                        *stop = YES;
                    }
                    
                    if ([viewController isKindOfClass:[ContactViewController class]]) {
                        ContactViewController *contactController = (ContactViewController*)viewController;
                        [contactController deleteAndRefreshDataSource];
                        [self.navigationController popToViewController:contactController animated:YES];
                        *stop = YES;
                    }
                    if ([viewController isKindOfClass:[OpportunityViewController class]]) {
                        OpportunityViewController *opportunityController = (OpportunityViewController*)viewController;
                        [opportunityController deleteAndRefreshDataSource];
                        [self.navigationController popToViewController:opportunityController animated:YES];
                        *stop = YES;
                    }
                }];
            }
            else if (error.code == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^(){
                    [NSObject showHudTipStr:@"删除失败，请重试"];
                };
                [comRequest loginInBackground];
            }
        }];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)newTask {
    CRM_TaskNewViewController *newController = [[CRM_TaskNewViewController alloc] init];
    newController.title = @"新建任务";
    newController.requestPath = _requestPathNewTask;
    newController.refreshBlock = ^{
        [self sendRequestForRefreshHeaderView];
    };
    [self.navigationController pushViewController:newController animated:YES];
}

- (void)newSchedule {
    CRM_ScheduleNewViewController *newController = [[CRM_ScheduleNewViewController alloc] init];
    newController.title = @"新建日程";
    newController.requestPath = _requestPathNewSchedule;
    newController.refreshBlock = ^{
        [self sendRequestForRefreshHeaderView];
    };
    [self.navigationController pushViewController:newController animated:YES];
}

- (void)newContacter {
    @weakify(self);
    CRM_ContactNewViewController *newController = [[CRM_ContactNewViewController alloc] init];
    newController.title = @"新建联系人";
    newController.requestInitPath = kNetPath_Customer_NewContact;
    newController.requestSavePath = kNetPath_Customer_SaveNewContact;
    newController.customerId = _detailItem.id;
    newController.refreshBlock = ^{
        @strongify(self);
        [self sendRequestForRefreshHeaderView];
    };
    [self.navigationController pushViewController:newController animated:YES];
}

- (void)newSaleOpportunity {
    @weakify(self);
    CRM_OpportunityNewViewController *newOpportunityController = [[CRM_OpportunityNewViewController alloc] init];
    newOpportunityController.title = @"新建销售机会";
    if ([self isKindOfClass:[CustomerDetailViewController class]]) {
        newOpportunityController.customerId = _detailItem.id;
        newOpportunityController.requestInitPath = kNetPath_Customer_NewOpportunity;
        newOpportunityController.requestSavePath = kNetPath_Customer_SaveNewOpportunity;
    }
    else if ([self isKindOfClass:[ContactDetailViewController class]]) {
        newOpportunityController.customerId = _detailItem.customer.id;
        newOpportunityController.requestInitPath = kNetPath_Contact_NewOpportunity;
        newOpportunityController.requestSavePath = kNetPath_Contact_SaveNewOpportunity;
    }
    newOpportunityController.refreshBlock = ^{
        @strongify(self);
        [self sendRequestForRefreshHeaderView];
    };
    [self.navigationController pushViewController:newOpportunityController animated:YES];
}

- (void)addContact {
    OpportunityAddContactController *addContactController = [[OpportunityAddContactController alloc] init];
    addContactController.title = @"添加联系人";
    addContactController.refreshBlock = ^{
        [self sendRequestForRefreshHeaderView];
    };
    [self.navigationController pushViewController:addContactController animated:YES];
}

- (void)sendMsgToSaleChance {
    AddToMessageController *leadListController = [[AddToMessageController alloc] init];
    leadListController.title = @"销售线索";
    leadListController.activityId = _id;
    leadListController.addType = AddToMessageTypeLead;
    [self.navigationController pushViewController:leadListController animated:YES];
}

- (void)sendMsgToCustomer {
    AddToMessageController *customerListController = [[AddToMessageController alloc] init];
    customerListController.title = @"客户";
    customerListController.activityId = _id;
    customerListController.addType = AddToMessageTypeCustomer;
    [self.navigationController pushViewController:customerListController animated:YES];
}

#pragma mark - public method
- (void)sendRequestForActivityRecordType {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[Net_APIManager sharedManager] request_ActivityRecord_Type_WithBlock:^(id data, NSError *error) {
            if (data) {
                NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
                for (NSString *keyStr in [data[@"records"] allKeys]) {
                    ValueIdModel *item = [[ValueIdModel alloc] init];
                    item.id = keyStr;
                    item.value = data[@"records"][keyStr];
                    [tempArray addObject:item];
                }
                _detailItem.recordTypeArray = tempArray;
            }
            else {
                if (error.code == STATUS_SESSION_UNAVAILABLE) {
                    CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                    comRequest.RequestAgainBlock = ^(){
                        [self sendRequestForActivityRecordType];
                    };
                    [comRequest loginInBackground];
                }
            }
        }];
    });
}

- (void)sendRequestForDetail {
    NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [tempParams setObject:_id forKey:@"id"];
    [[Net_APIManager sharedManager] request_Common_CRMDetail_WithPath:_requestPathForDetail params:tempParams block:^(id data, NSError *error) {
        if (data) {
            
            _detailItem = [NSObject objectOfClass:@"CRMDetail" fromJSON:data];
            
            // 当前销售阶段
            _detailItem.currentStage = [NSObject objectOfClass:@"OpportunityStage" fromJSON:data[@"currentOpportunity"]];
            
            // 销售阶段
            NSMutableArray *tempOpportunity = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"opportunityList"]) {
                OpportunityStage *item = [NSObject objectOfClass:@"OpportunityStage" fromJSON:tempDict];
                [tempOpportunity addObject:item];
            }
            _detailItem.stageListArray = tempOpportunity;
            
            // 跟进状态
            NSMutableArray *tempFollowArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"followList"]) {
                ValueIdModel *item = [NSObject objectOfClass:@"ValueIdModel" fromJSON:tempDict];
                [tempFollowArray addObject:item];
            }
            _detailItem.followListArray = tempFollowArray;
            
            // 活动状态
            NSMutableArray *tempActivityArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"activityList"]) {
                ValueIdModel *item = [NSObject objectOfClass:@"ValueIdModel" fromJSON:tempDict];
                [tempActivityArray addObject:item];
            }
            _detailItem.activityListArray = tempActivityArray;
            
            // 团队成员
            NSMutableArray *tempStaffArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"staffs"]) {
                DetailStaffModel *item = [NSObject objectOfClass:@"DetailStaffModel" fromJSON:tempDict];
                [tempStaffArray addObject:item];
            }
            [_detailItem configStaffArray:tempStaffArray];
            
            // 详细资料
            NSMutableArray *tempColumnArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"columns"]) {

                ColumnModel *item = [NSObject objectOfClass:@"ColumnModel" fromJSON:tempDict];
                for (NSDictionary *selectedDict in tempDict[@"select"]) {
                    ColumnSelectModel *selectItem = [NSObject objectOfClass:@"ColumnSelectModel" fromJSON:selectedDict];
                    [item.selectArray addObject:selectItem];
                }
                [item configResultWithDictionary:tempDict];
                [tempColumnArray addObject:item];
            }
            _detailItem.columnsArray = tempColumnArray;
            [_detailItem configColumnsShowArray];
            
            // 权限
            NSMutableArray *tempCodesArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"codes"]) {
                Code *item = [NSObject objectOfClass:@"Code" fromJSON:tempDict];
                [tempCodesArray addObject:item];
                
                // 显示编辑按钮
                if ([appDelegateAccessor.moudle.userFunctionCodes rangeOfString:kCrm_activityEdit].location != NSNotFound && [item.code isEqualToNumber:@1005] && [item.status isEqualToNumber:@0]) { // 市场活动
                    [self.view addSubview:self.editButton];
                }
                else if ([appDelegateAccessor.moudle.userFunctionCodes rangeOfString:kCrm_customerEdit].location != NSNotFound && [item.code isEqualToNumber:@2005] && [item.status isEqualToNumber:@0]) { // 客户
                    [self.view addSubview:self.editButton];
                }
                else if ([appDelegateAccessor.moudle.userFunctionCodes rangeOfString:kCrm_chanceEdit].location != NSNotFound && [item.code isEqualToNumber:@3005] && [item.status isEqualToNumber:@0]) { // 销售机会
                    [self.view addSubview:self.editButton];
                }
                else if ([appDelegateAccessor.moudle.userFunctionCodes rangeOfString:kCrm_contactEdit].location != NSNotFound && [item.code isEqualToNumber:@4005] && [item.status isEqualToNumber:@0]) {
                    [self.view addSubview:self.editButton];
                }
            }
            _detailItem.codesArray = tempCodesArray;
            
            // tableHeaderView
            [self configTableViewHeaderView];
            
            // 业务
            [self.sectionHeaderView configDataSourceWithDetailItem:_detailItem];
            
            // 获取跟进记录
            [self sendRequestForFollowRecord];
            
            // 获取活动类型
            [self sendRequestForActivityRecordType];
        }
        else {
            if (error.code == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^(){
                    [self sendRequestForDetail];
                };
                [comRequest loginInBackground];
            }
            else if (error.code == 1) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
}

- (void)sendRequestForFollowRecord {
    [[Net_APIManager sharedManager] request_Common_CRMFollowRecord_WithPath:_requestPathForFollowRecord params:_followParams block:^(id data, NSError *error) {
        [self.navCustomView stopAnimation];
        [self.tableView footerEndRefreshing];
        if (data) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *tempDict in data[@"followRecords"]) {
                Record *followRecord = [NSObject objectOfClass:@"Record" fromJSON:tempDict];
                for (NSDictionary *alts in tempDict[@"alts"]) {
                    User *atUser = [NSObject objectOfClass:@"User" fromJSON:alts];
                    [followRecord.altsArray addObject:atUser];
                }
                for (NSDictionary *imageDict in tempDict[@"imageFiles"]) {
                    FileModel *imageItem = [NSObject objectOfClass:@"FileModel" fromJSON:imageDict];
                    [followRecord.imageFilesArray addObject:imageItem];
                }
                
                // 汇总时间
                [followRecord configMarkedTime];
                
                [tempArray addObject:followRecord];
            }
            
            // 标记是否显示汇总时间
            for (int i = 0; i < tempArray.count; i ++) {
                Record *preItem;
                Record *currentItem = tempArray[i];
                if (i) {
                    preItem = tempArray[i - 1];
                }
                
                if (preItem && [preItem.markedTime isEqualToString:currentItem.markedTime]) {
                    currentItem.isShowMarkedTime = NO;
                }
                else {
                    currentItem.isShowMarkedTime = YES;
                }
            }
            
            if ([_followParams[@"pageNo"] isEqualToNumber:@1]) {
                _detailItem.followRecordArray = tempArray;
            }
            else {
                [_detailItem.followRecordArray addObjectsFromArray:tempArray];
            }
            
            if (tempArray.count == 10) {
                self.tableView.footerHidden = NO;
            }
            else {
                self.tableView.footerHidden = YES;
            }
            
            if (_detailItem.followRecordArray.count > 0) {
                _tableView.tableFooterView = nil;
            }else if (_detailItem.followRecordArray.count == 1) {
                _tableView.tableFooterView = self.footerViewDatas;
            }
            else {
                _tableView.tableFooterView = self.footerView;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        }
        else {
            if (error.code == STATUS_SESSION_UNAVAILABLE) {
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^(){
                    [self sendRequestForFollowRecord];
                };
                [comRequest loginInBackground];
            }
        }
    }];
}

- (void)sendRequestForRefreshFollowRecord {
    [_followParams setObject:@1 forKey:@"pageNo"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequestForFollowRecord];
    });
}

- (void)sendRequestForReloadMoreFollowRecord {
    [_followParams setObject:@([_followParams[@"pageNo"] integerValue] + 1) forKey:@"pageNo"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sendRequestForFollowRecord];
    });
}

- (void)sendRecordWithObj:(Record *)record {
    [[Net_APIManager sharedManager] request_Common_SendRecord_WithPath:_requestPathSendRecord obj:record block:^(id data, NSError *error) {
        if (data) {
            [self sendRequestForFollowRecord];
            [_inputView isAndResignFirstResponder];
        }
    }];
}

- (void)sendRequestForRefreshHeaderView {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
        [tempParams setObject:_id forKey:@"id"];
        [[Net_APIManager sharedManager] request_Common_CRMDetail_WithPath:_requestPathForDetail params:tempParams block:^(id data, NSError *error) {
            if (data) {
                CRMDetail *tempItem = [NSObject objectOfClass:@"CRMDetail" fromJSON:data];
                _detailItem.saleLeadNum = tempItem.saleLeadNum;
                _detailItem.customerNum = tempItem.customerNum;
                _detailItem.contactNum = tempItem.contactNum;
                _detailItem.saleChanceNum = tempItem.saleChanceNum;
                _detailItem.taskScheduleNum = tempItem.taskScheduleNum;
                _detailItem.approvalNum = tempItem.approvalNum;
                _detailItem.fileNum = tempItem.fileNum;
                _detailItem.productNum = tempItem.productNum;
                
                [self.sectionHeaderView configDataSourceWithDetailItem:_detailItem];
            }
        }];
    });
}

- (void)configTableViewHeaderView {
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
    UIImageWriteToSavedPhotosAlbum(originalImage, self, selectorToCall, NULL);
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// 保存图片后到相册后，调用的相关方法，查看是否保存成功
- (void) imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo {
    if (paramError == nil){
        
        Record *record = [[Record alloc] init];
        record.recordId = @"A001";
        record.recordContent = _inputView.inputTextView.text;
        record.simpleImage = paramImage;
        [self sendRecordWithObj:record];
        
        _inputView.inputTextView.text = @"";
        
//        PhotoAssetLibraryViewController *photoAssetController = [[PhotoAssetLibraryViewController alloc] init];
//        photoAssetController.maxCount = 9;
//        photoAssetController.confirmBtnClickedBlock = ^(NSArray *array) {
//            Record *record = [[Record alloc] init];
//            record.recordId = @"A001";
//            record.recordContent = _inputView.inputTextView.text;
//            record.recordImages = [[NSMutableArray alloc] initWithArray:array];
//            [self sendRecordWithObj:record];
//            
//            _inputView.inputTextView.text = @"";
//        };
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:photoAssetController];
//        [self presentViewController:nav animated:YES completion:^{
//            [photoAssetController autoAddCameraPhoto];
//        }];
    }
    else {
        NSLog(@"An error happened while saving the image.");
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIMessageInputViewDelegate
- (void)messageInputViewRecord {
    [_inputView isAndResignFirstResponder];
    self.actionSheet.title = @"选择要添加的活动类型";
    _actionSheet.sourceArray = _detailItem.recordTypeArray;
    _actionSheet.actionType = ActionSheetTypeFromActivity;
    @weakify(self);
    _actionSheet.selectedBlock = ^(id obj, ActionSheetTypeFrom fromType) {
        @strongify(self);
        ValueIdModel *item = obj;
        
        if ([item.id isEqualToString:@"A003"]) {
            MapViewViewController *controller = [[MapViewViewController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            controller.typeOfMap = @"location";
            controller.LocationResultBlock = ^(CLLocationCoordinate2D locCoordinate,NSString *location){
                
                Record *record = [[Record alloc] init];
                record.recordId = item.id;
                record.position = location;
                record.latitude = [NSString stringWithFormat:@"%f", locCoordinate.latitude];
                record.longitude = [NSString stringWithFormat:@"%f", locCoordinate.longitude];
                
                RecordSendViewController *recordController = [[RecordSendViewController alloc] init];
                recordController.title = @"添加活动记录";
                recordController.curRecord = record;
                recordController.sendNextRecord = ^(Record *record) {
                    [self sendRecordWithObj:record];
                };
                [self.navigationController pushViewController:recordController animated:YES];
            };
            [self.navigationController pushViewController:controller animated:YES];
            return;
        }
        
        Record *record = [[Record alloc] init];
        record.recordId = item.id;
        RecordSendViewController *recorSendController = [[RecordSendViewController alloc] init];
        recorSendController.title = @"添加活动记录";
        recorSendController.curRecord = record;
        recorSendController.sendNextRecord = ^(Record *nextRecord) {
            [self sendRecordWithObj:nextRecord];
        };
        [self.navigationController pushViewController:recorSendController animated:YES];
    };
    [_actionSheet show];
}

- (void)messageInputView:(UIMessageInputView_zbs *)inputView photoType:(NSInteger)photoType {
    // 拍照
    if (photoType == 0) {
        if (![Helper checkCameraAuthorizationStatus]) {
            return;
        }
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;//设置可编辑
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];//进入照相界面
        return;
    }
    
    // 相册
    if (![Helper checkPhotoLibraryAuthorizationStatus]) {
        return;
    }
    
    PhotoAssetLibraryViewController *photoAssetController = [[PhotoAssetLibraryViewController alloc] init];
    photoAssetController.maxCount = 9;
    photoAssetController.confirmBtnClickedBlock = ^(NSArray *array) {
        Record *record = [[Record alloc] init];
        record.recordId = @"A001";
        record.recordContent = _inputView.inputTextView.text;
        record.recordImages = [[NSMutableArray alloc] initWithArray:array];
        [self sendRecordWithObj:record];
        
        _inputView.inputTextView.text = @"";
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:photoAssetController];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)messageInputView:(UIMessageInputView_zbs *)inputView sendText:(NSString *)text {
    Record *record = [Record initRecordForSend];
    record.recordId = @"A001";
    record.recordContent = text;
    [self sendRecordWithObj:record];
}

- (void)messageInputView:(UIMessageInputView_zbs *)inputView sendVoice:(NSString *)file duration:(NSTimeInterval)duration {
    Record *record = [Record initRecordForSend];
    record.recordId = @"A001";
    record.recordAudioFile = file;
    record.recordAudioSecond = [NSNumber numberWithInteger:duration * 1000];
    [self sendRecordWithObj:record];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_inputView.inputTextView resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    UIColor * color = [UIColor colorWithHexString:@"0x2e3440"];
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY > kNavBar_change_point) {
        CGFloat alpha = MIN(1, 1 - ((kNavBar_change_point + 64 - offsetY) / 64));
        _navCustomView.backgroundColor = [color colorWithAlphaComponent:alpha];
    }
    else {
        _navCustomView.backgroundColor = [color colorWithAlphaComponent:0];
    }
    
//    UIColor * color = [UIColor colorWithHexString:@"0x2e3440"];
//    CGFloat offsetY = scrollView.contentOffset.y;
//    UIImage *image;
//    if (offsetY > kNavBar_change_point) {
//        CGFloat alpha = MIN(1, 1 - ((kNavBar_change_point + 64 - offsetY) / 64));
//        image = [UIImage imageWithColor:[color colorWithAlphaComponent:alpha]];
//    }
//    else {
//        image = [UIImage imageWithColor:[color colorWithAlphaComponent:0]];
//    }
//    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat y = scrollView.contentOffset.y;
    if (y < -64) {
        [self.navCustomView startAnimation];
        [self sendRequestForRefreshFollowRecord];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 详细资料
    if (_segmentIndex) {
        return _detailItem.columnsShowArray.count + 1;
    }
    
    return _detailItem.followRecordArray.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return [DetailFirstCell cellHeight];
    }
    
    if (_segmentIndex) {    // 详细资料
        ColumnModel *item = _detailItem.columnsShowArray[indexPath.row - 1];
        if ([item.columnType integerValue] == 8) {
            return [DetailInfoSectionCell cellHeight];
        }else {
            return [DetailInfoCell cellHeightWithModel:item];
        }
    }
    
    // 跟进记录
    Record *item = _detailItem.followRecordArray[indexPath.row - 1];
    if ([item.type integerValue] == 1) {
        return [DetailFollowRecord_userCell cellHeightWithObj:item];
    }else {
        return [DetailFollowRecord_systemCell cellHeight];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 64.0f;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.sectionHeaderView;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        DetailFirstCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_first forIndexPath:indexPath];
        cell.valueBlock = ^(NSInteger index) {
            self.segmentIndex = index;
        };
        return cell;
    }
    
    // 详细资料
    if (_segmentIndex) {
        ColumnModel *item = _detailItem.columnsShowArray[indexPath.row - 1];
        if ([item.columnType integerValue] == 8) {
            DetailInfoSectionCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_infoSection forIndexPath:indexPath];
            [cell configWithModel:item];
            return cell;
        }
        
        DetailInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_info forIndexPath:indexPath];
        cell.headerViewTapBlock = ^{
            InfoViewController *infoController = [[InfoViewController alloc] init];
            infoController.title = @"个人信息";
            if ([appDelegateAccessor.moudle.userId integerValue] == [item.objectResult.id integerValue]) {
                infoController.infoTypeOfUser = InfoTypeMyself;
            }else{
                infoController.infoTypeOfUser = InfoTypeOthers;
                infoController.userId = [item.objectResult.id integerValue];
            }
            [self.navigationController pushViewController:infoController animated:YES];
        };
        [cell configWithModel:item];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:15.0f];
        return cell;
    }
    
    // 跟进记录
    Record *item = _detailItem.followRecordArray[indexPath.row - 1];
    if ([item.type integerValue] == 1) {
        DetailFollowRecord_userCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_followUser forIndexPath:indexPath];
        cell.contentLabel.delegate = self;
        cell.handleVC = self;
        [cell configWithModel:item];
        cell.detailBtnClickedBlock = ^{
            
            [self.view endEditing:YES];
            
            ActivityRecordDetailController *recordDetailController = [[ActivityRecordDetailController alloc] init];
            recordDetailController.title = @"活动记录详情";
            recordDetailController.record = item;
            recordDetailController.deleteRecordSuccessBlock = ^{
                [_detailItem.followRecordArray removeObjectAtIndex:indexPath.row - 1];
                [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                
                if (!_detailItem.followRecordArray.count) {
                    _tableView.tableFooterView = self.footerView;
                }else if (_detailItem.followRecordArray.count == 1) {
                    _tableView.tableFooterView = self.footerViewDatas;
                }
            };
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
            [self.navigationItem setBackBarButtonItem:backItem];
            [self.navigationController pushViewController:recordDetailController animated:YES];
        };
        cell.headerViewClickedBlock = ^{
            InfoViewController *infoController = [[InfoViewController alloc] init];
            infoController.title = @"个人信息";
            if ([appDelegateAccessor.moudle.userId integerValue] == [item.user.id integerValue]) {
                infoController.infoTypeOfUser = InfoTypeMyself;
            }else{
                infoController.infoTypeOfUser = InfoTypeOthers;
                infoController.userId = [item.user.id integerValue];
            }
            [self.navigationController pushViewController:infoController animated:YES];
        };
        cell.fileBtnClickedBlock = ^{
            Directory *directory = [[Directory alloc] init];
            directory.id = item.file.id;
            directory.size = item.file.size;
            directory.name = item.file.name;
            directory.url = item.file.url;
            [directory configFileTypeAndSize];
            FileListDetailController *detailController = [[FileListDetailController alloc] init];
            detailController.title = item.file.name;
            detailController.directory = directory;
            [self.navigationController pushViewController:detailController animated:YES];
        };
        cell.positionBtnClickedBlock = ^{
            MapViewViewController *mapController = [[MapViewViewController alloc] init];
            mapController.title = @"查看地理位置";
            mapController.typeOfMap = @"show";
            mapController.location = item.position;
            mapController.latitude = [item.latitude doubleValue];
            mapController.longitude = [item.longitude doubleValue];
            [self.navigationController pushViewController:mapController animated:YES];
        };
        return cell;
    }
    
    DetailFollowRecord_systemCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_followSystem forIndexPath:indexPath];
    [cell configWithModel:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components {
    User *user = [components objectForKey:@"value"];
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

#pragma mark - setters and getters
- (void)setSegmentIndex:(NSInteger)segmentIndex {
    if (_segmentIndex == segmentIndex) {
        return;
    }
    
    if (segmentIndex) { // 详细资料
        _tableView.footerHidden = YES;
        
        if (_detailItem.columnsArray.count) {
            _tableView.tableFooterView = nil;
        }
        else {
            _tableView.tableFooterView = self.infoFooterView;
        }

        if (_editButton) {
            _editButton.hidden = NO;
            [_tableView setHeight:kScreen_Height - CGRectGetMinY(_tableView.frame) - 50];
        }
        else {
            [_tableView setHeight:kScreen_Height - CGRectGetMinY(_tableView.frame)];
        }
        
        _inputView.hidden = YES;
    }else { // 跟进记录
        if (!(_detailItem.followRecordArray.count % 10)) {
            _tableView.footerHidden = NO;
        }
        [_tableView setHeight:kScreen_Height - CGRectGetMinY(_tableView.frame) - 50];
        _inputView.hidden = NO;
        _editButton.hidden = YES;
        if (_detailItem.followRecordArray.count > 1) {
            _tableView.tableFooterView = nil;
        }else if (_detailItem.followRecordArray.count == 1) {
            _tableView.tableFooterView = self.footerViewDatas;
        }
        else {
            _tableView.tableFooterView = self.footerView;
        }
    }
    
    _segmentIndex = segmentIndex;
    
    [_tableView reloadData];
}

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"table_bgView" ofType:@"jpg"]];
        _backgroundImageView = [[UIImageView alloc] initWithImage:image];
        _backgroundImageView.frame = self.view.bounds;
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImageView.clipsToBounds = YES;
    }
    return _backgroundImageView;
}

- (CustomNavigationView *)navCustomView {
    if (!_navCustomView) {
        _navCustomView = [[CustomNavigationView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 64.0f)];
        _navCustomView.titleString = self.title;
    }
    return _navCustomView;
}

- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setY:64.0f];
        [_tableView setWidth:kScreen_Width];
        [_tableView setHeight:kScreen_Height - CGRectGetMinY(_tableView.frame) - 50];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass:[DetailFirstCell class] forCellReuseIdentifier:kCellIdentifier_first];
        [_tableView registerClass:[DetailFollowRecord_userCell class] forCellReuseIdentifier:kCellIdentifier_followUser];
        [_tableView registerClass:[DetailFollowRecord_systemCell class] forCellReuseIdentifier:kCellIdentifier_followSystem];
        [_tableView registerClass:[DetailInfoCell class] forCellReuseIdentifier:kCellIdentifier_info];
        [_tableView registerClass:[DetailInfoSectionCell class] forCellReuseIdentifier:kCellIdentifier_infoSection];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = self.footerView;
    }
    return _tableView;
}

- (UIView*)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] init];
        [_footerView setWidth:kScreen_Width];
        [_footerView setHeight:300];
        _footerView.backgroundColor = kView_BG_Color;
        
        UIImage *image = [UIImage imageNamed:@"list_empty"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [imageView setWidth:image.size.width];
        [imageView setHeight:image.size.height];
        [imageView setCenterX:kScreen_Width / 2];
        [imageView setCenterY:CGRectGetHeight(_footerView.bounds) / 2 - 15];
        [_footerView addSubview:imageView];
        
        UILabel *tipLabel = [[UILabel alloc] init];
        [tipLabel setY:CGRectGetMaxY(imageView.frame)];
        [tipLabel setWidth:kScreen_Width];
        [tipLabel setHeight:30];
        tipLabel.font = [UIFont systemFontOfSize:15];
        tipLabel.textColor = [UIColor lightGrayColor];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.text = @"暂无跟进记录";
        [_footerView addSubview:tipLabel];
    }
    return _footerView;
}

- (UIView*)footerViewDatas {
    if (!_footerViewDatas) {
        _footerViewDatas = [[UIView alloc] init];
        [_footerViewDatas setWidth:kScreen_Width];
        [_footerViewDatas setHeight:300];
        _footerViewDatas.backgroundColor = kView_BG_Color;
        
    }
    return _footerViewDatas;
}

- (UIView*)infoFooterView {
    if (!_infoFooterView) {
        _infoFooterView = [[UIView alloc] init];
        [_infoFooterView setWidth:kScreen_Width];
        [_infoFooterView setHeight:300];
        _infoFooterView.backgroundColor = kView_BG_Color;
        
        UIImage *image = [UIImage imageNamed:@"list_empty"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [imageView setWidth:image.size.width];
        [imageView setHeight:image.size.height];
        [imageView setCenterX:kScreen_Width / 2];
        [imageView setCenterY:CGRectGetHeight(_footerView.bounds) / 2 - 15];
        [_infoFooterView addSubview:imageView];
        
        UILabel *tipLabel = [[UILabel alloc] init];
        [tipLabel setY:CGRectGetMaxY(imageView.frame)];
        [tipLabel setWidth:kScreen_Width];
        [tipLabel setHeight:30];
        tipLabel.font = [UIFont systemFontOfSize:15];
        tipLabel.textColor = [UIColor lightGrayColor];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.text = @"获取资料失败";
        [_infoFooterView addSubview:tipLabel];
    }
    return _infoFooterView;
}

- (SectionHeaderView*)sectionHeaderView {
    if (!_sectionHeaderView) {
        _sectionHeaderView = [[SectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 64)];
    }
    return _sectionHeaderView;
}

- (UIMessageInputView_zbs*)inputView {
    if (!_inputView) {
        _inputView = [UIMessageInputView_zbs initMessageInputViewWithType:UIMessageInputViewTypeRecord placeHolder:@"快速记录"];
        _inputView.isAlwaysShow = YES;
        _inputView.delegate = self;
    }
    return _inputView;
}

- (CustomActionSheet*)actionSheet {
    if (!_actionSheet) {
        _actionSheet = [[CustomActionSheet alloc] init];
    }
    return _actionSheet;
}

- (UIButton*)editButton {
    if (!_editButton) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _editButton.backgroundColor = kView_BG_Color;
        [_editButton setY:kScreen_Height - 50];
        [_editButton setWidth:kScreen_Width];
        [_editButton setHeight:50];
        [_editButton addLineUp:YES andDown:NO];
        _editButton.hidden = YES;
        [_editButton setImage:[UIImage imageNamed:@"edit_doc"] forState:UIControlStateNormal];
        [_editButton setTitle:@"编辑资料" forState:UIControlStateNormal];
        [_editButton setTitleColor:kNavigationTintColor forState:UIControlStateNormal];
        [_editButton addTarget:self action:@selector(editButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editButton;
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
