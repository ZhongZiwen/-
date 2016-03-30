//
//  TaskNewViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TaskNewViewController.h"
#import "AddressSelectedController.h"
#import "ExportAddressViewController.h"
#import "EditAddressViewController.h"
#import "InputViewController.h"
#import "AddressBook.h"
#import "AFNHttp.h"
#import <XLForm.h>
#import "AddressBook.h"
#import "ExportAddress.h"
#import "NSUserDefaults_Cache.h"
#import "XLFSelectorTextDetailCell.h"
#import "RelatedBusinessController.h"

@interface TaskNewViewController ()

@property (nonatomic, copy) void(^RefreshBussineBlock)(NSDictionary *);
@end

@implementation TaskNewViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    // 自定义返回按钮 开启手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonItemPress)];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleBordered target:self action:@selector(rightButtonItemPress)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    //关联业务
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRefresh:) name:@"relatedBusiness" object:nil];
}

- (void)notificationRefresh:(NSNotification *)notification {
    if (_RefreshBussineBlock) {
        _RefreshBussineBlock([notification object]);
    }
}

// 限制textField字数
- (void)textFieldDidChange:(UITextField *)textField {
//    if (textField.text.length > MAX_LIMIT_TEXTFIELD) {
//        textField.text = [textField.text substringToIndex:MAX_LIMIT_TEXTFIELD];
//    }
    
    if (textField.text.length > MAX_LIMIT_TEXTFIELD_SPE) {
        textField.text = [textField.text substringToIndex:MAX_LIMIT_TEXTFIELD_SPE];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    XLFormDescriptor *form = [XLFormDescriptor formDescriptor];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"name" rowType:XLFormRowDescriptorTypeName title:@"任务名称"];
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfigAtConfigure setObject:@"必填" forKey:@"textField.placeholder"];
    [section addFormRow:row];
    
    AddressBook *address = [[AddressBook alloc] init];
//    [address.selectedArray  addObject:[self getDefaultAttentPeople]];
    address = [self getDefaultAttentPeople];
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"responsibility" rowType:XLFormRowDescriptorTypeSelectorPush title:@"责任人"];
    row.selectorTitle = @"责任人";
    row.value = address;
    row.action.viewControllerClass = [AddressSelectedController class];
    [section addFormRow:row];
    // 截止时间
    NSDate *endDate = [self getBeginDate];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"endTime" rowType:XLFormRowDescriptorTypeDateTime title:@"截止时间"];
    row.value = endDate;
    [section addFormRow:row];
    // 提醒时间
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"remindTime" rowType:XLFormRowDescriptorTypeSelectorPush title:@"提醒时间"];
    row.selectorTitle = @"提醒";
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(-1) displayText:@"不提醒"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(-1) displayText:@"不提醒"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"准时"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"提前5分钟"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"提前10分钟"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"提前30分钟"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"提前1小时"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"提前2小时"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(6) displayText:@"提前6小时"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(7) displayText:@"提前1天"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(8) displayText:@"提前2天"]];
    [section addFormRow:row];
    // 添加更多信息行
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"more" rowType:XLFormRowDescriptorTypeButton title:@"+点击添加更多信息"];
    [row.cellConfig setObject:[UIColor lightGrayColor] forKey:@"textLabel.textColor"];
    [row.cellConfig setObject:[UIFont systemFontOfSize:14] forKey:@"textLabel.font"];
    row.action.formBlock = ^(XLFormRowDescriptor *sender) {
        [self deselectFormRow:sender];
        
        // 附加信息
        XLFormSectionDescriptor *addSection;
        XLFormRowDescriptor *addRow;
        addSection = [XLFormSectionDescriptor formSectionWithTitle:@"附加信息"];
        [self.form addFormSection:addSection];
        // 重要度
        addRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"important" rowType:XLFormRowDescriptorTypeSelectorPush title:@"重要度"];
        addRow.noValueDisplayText = @"点击选择";
        addRow.selectorTitle = @"重要度";
        addRow.value = [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"一般"];
        addRow.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"一般"],
                                   [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"重要"]];
        [addSection addFormRow:addRow];
        
        // 关联业务
        addRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"business" rowType:XLFormRowDescriptorTypeSelectorTextDetail];
        __weak typeof(self) weak_self = self;
        addRow.value = @{@"text" : @"关联业务",
                         @"detail" : @"点击选择"};
        addRow.action.formBlock = ^(XLFormRowDescriptor *sender) {
            RelatedBusinessController *controller = [[RelatedBusinessController alloc] init];
            weak_self.RefreshBussineBlock = ^(NSDictionary *fromDic){
                XLFormRowDescriptor *rowDescriptor = [weak_self.form formRowWithTag:@"business"];
                rowDescriptor.value = @{@"text" : @"关联业务",
                                        @"detail" : [[fromDic objectForKey:@"dataSource"] objectForKey:@"name"],
                                        @"businessType" : [fromDic objectForKey:@"type"],
                                        @"businessId" : [NSString stringWithFormat:@"%@", [[fromDic objectForKey:@"dataSource"] safeObjectForKey:@"id"]]};
                [weak_self updateFormRow:rowDescriptor];
            };
            [self.navigationController pushViewController:controller animated:YES];
        };
        [addSection addFormRow:addRow];

        // 参与人
        addRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"attend" rowType:XLFormRowDescriptorTypeSelectorPush title:@"参与人"];
        addRow.selectorTitle = @"选择参与人";
        addRow.noValueDisplayText = @"点击选择";
        addRow.action.viewControllerClass = [ExportAddressViewController class];
        [addSection addFormRow:addRow];
        
        // 任务描述
        addRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"detail" rowType:XLFormRowDescriptorTypeSelectorPush title:@"任务描述"];
        addRow.noValueDisplayText = @"添加详情描述";
        addRow.selectorTitle = @"编辑";
        addRow.action.viewControllerClass = [InputViewController class];
        [addSection addFormRow:addRow];
        
        [sender setHidden:@1];
        [self updateFormRow:sender];
    };
    [section addFormRow:row];
    
    self.form = form;
}

///获取开始时间
-(NSDate *)getBeginDate{
    
    NSDate *beginDate;
    ///默认开始时间为下个整点时间，周期30分钟，结束时间即为开始时间+30分
    ///当前时间  30分钟之前 默认下个整点 如2：10  开始3：00  结束 3：30
    ///当前时间  30分钟之后 默认下个整点半 如2：34 开始 3：30  结束 4：00

    NSDate *date = [NSDate date];
    
    NSInteger minute = [CommonFuntion getCurDateMinute:[NSDate date]];
    //    NSLog(@"date:%@",date);
    
    if (minute <= 30) {
        beginDate = [NSDate getOneDateHour:1 minute:0 second:0 byDate:date ? date : [NSDate date]];
        beginDate = [NSDate setOneDate:beginDate Minute:0];
    }else{
        beginDate = [NSDate getOneDateHour:1 minute:0 second:0 byDate:date ? date : [NSDate date]];
        beginDate = [NSDate setOneDate:beginDate Minute:30];
    }
    
    return beginDate;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)backButtonItemPress {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonItemPress {
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    
    XLFormRowDescriptor *row;
    row = [self.form formRowWithTag:@"name"];
    if (row.value) {
        [params setObject:row.value forKey:@"taskName"];
    }else {
        kShowHUD(@"任务名称不能为空");
        return;
    }
    NSString *creatUserId = @"";
    row = [self.form formRowWithTag:@"responsibility"];
    if (row.value) {
        AddressBook *item = row.value;
        [params setObject:item.id forKey:@"belongId"];
        creatUserId = [item.id stringValue];
    }else {
        return;
    }
    
    row = [self.form formRowWithTag:@"endTime"];
    [params setObject:[row.value stringTimestamp] forKey:@"planFinishDate"];
    
    row = [self.form formRowWithTag:@"remindTime"];
    [params setObject:[row.value formValue] forKey:@"remind"];
    
    row = [self.form formRowWithTag:@"important"];
    [params setObject:([row.value formValue] ? : @"1") forKey:@"priority"];
    
    row = [self.form formRowWithTag:@"attend"];
    NSMutableArray *memberArray = [NSMutableArray arrayWithCapacity:0];
    if ([row.value formValue]) {
        [memberArray addObjectsFromArray:[[row.value formValue] componentsSeparatedByString:@","]];
        if ([memberArray containsObject:creatUserId]) {
            [memberArray removeObject:creatUserId];
        }
        if ([memberArray containsObject:appDelegateAccessor.moudle.userId]) {
            [memberArray removeObject:appDelegateAccessor.moudle.userId];
        }
    }
    [params setObject:[memberArray componentsJoinedByString:@","] forKey:@"memberIds"];
    
    row = [self.form formRowWithTag:@"detail"];
    [params setObject:(row.value ? : @"") forKey:@"description"];
    
    row = [self.form formRowWithTag:@"business"];
    if (row.value) {
        if ([[row.value allKeys] containsObject:@"businessType"]) {
            [params setObject:[row.value objectForKey:@"businessType"] forKey:@"businessType"]; //业务类型
        }
        if ([[row.value allKeys] containsObject:@"businessId"]) {
            [params setObject:[row.value objectForKey:@"businessId"] forKey:@"businessId"]; //业务id
        }
    }
    [self.view beginLoading];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, GET_OFFICE_TASK_CREATE] params:params success:^(id responseObj) {
        [self.view endLoading];
        NSLog(@"新建任务成功：%@", responseObj);
        NSLog(@"desc: %@", [responseObj objectForKey:@"desc"]);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            if (self.refreshBlock) {
                self.refreshBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self rightButtonItemPress];
            };
            [comRequest loginInBackground];
        } else{
            self.navigationItem.rightBarButtonItem.enabled = YES;
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            kShowHUD(desc,nil);
        }
    } failure:^(NSError *error) {
        [self.view endLoading];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        NSLog(@"新建任务失败：%@", error);
    }];
}

- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue {
    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];
    
    NSIndexPath *indexPath = [self.form indexPathOfFormRow:formRow];
    id cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[XLFormTextFieldCell class]]) {
        XLFormTextFieldCell *textFieldCell = cell;
        [textFieldCell.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    
    if ([formRow.tag isEqualToString:@"attend"]) {
        if ([formRow.value formValue]) {
            formRow.selectorTitle = @"编辑参与人";
            formRow.action.viewControllerClass = [EditAddressViewController class];
        }else {
            formRow.selectorTitle = @"选择参与人";
            formRow.action.viewControllerClass = [ExportAddressViewController class];
        }
    }else if ([formRow.tag isEqualToString:@"remindTime"]) {
        if ([formRow.value formValue]) {
            
        }else {
            formRow.value = [XLFormOptionsObject formOptionsObjectWithValue:@(-1) displayText:@"不提醒"];
        }
    }
    
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

///初始化默认参与人
-(AddressBook *)getDefaultAttentPeople{
    AddressBook *user = [[AddressBook alloc] init];
    NSDictionary *userInfo = [NSUserDefaults_Cache getUserInfo];
    user.id = [NSNumber numberWithLong:[[userInfo safeObjectForKey:@"id"] longLongValue]];
    user.name = [userInfo safeObjectForKey:@"name"];
    user.icon = [userInfo safeObjectForKey:@"icon"];
    NSLog(@"user.name:%@",user.name);
    return user;
}
@end
