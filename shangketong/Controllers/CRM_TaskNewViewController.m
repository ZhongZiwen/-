//
//  CRM_TaskNewViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CRM_TaskNewViewController.h"
#import "AddressSelectedController.h"
#import "ExportAddressViewController.h"
#import "InputViewController.h"
#import "AddressBook.h"
#import <XLForm.h>

@interface CRM_TaskNewViewController ()

@end

@implementation CRM_TaskNewViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    // 自定义返回按钮 开启手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(backButtonItemPress)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"提交" target:self action:@selector(rightButtonItemPress)];
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
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    AddressBook *item = [[AddressBook alloc] init];
    item.id = @([appDelegateAccessor.moudle.userId integerValue]);
    item.name = appDelegateAccessor.moudle.userName;
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"responsibility" rowType:XLFormRowDescriptorTypeSelectorPush title:@"负责人"];
    row.selectorTitle = @"通讯录";
    row.noValueDisplayText = @"点击选择(必填)";
    row.value = item;
    row.action.viewControllerClass = [AddressSelectedController class];
    [section addFormRow:row];
    
    // 截止时间
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"endTime" rowType:XLFormRowDescriptorTypeDateTime title:@"截止时间"];
    row.value = [self getBeginDate];
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
        // 参与人
        addRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"attend" rowType:XLFormRowDescriptorTypeSelectorPush title:@"参与人"];
        addRow.noValueDisplayText = @"点击选择";
        addRow.selectorTitle = @"通讯录";
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)backButtonItemPress {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonItemPress {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    
    XLFormRowDescriptor *row;
    row = [self.form formRowWithTag:@"name"];
    if (row.value) {
        [params setObject:row.value forKey:@"taskName"];
    }else {
        kShowHUD(@"任务名称不能为空");
        return;
    }
    
    row = [self.form formRowWithTag:@"responsibility"];
    if (row.value) {
        AddressBook *item = row.value;
        [params setObject:item.id forKey:@"belongId"];
    }else {
        kShowHUD(@"负责人不能为空");
        return;
    }
    
    row = [self.form formRowWithTag:@"endTime"];
    [params setObject:[row.value stringTimestamp] forKey:@"planFinishDate"];
    
    row = [self.form formRowWithTag:@"remindTime"];
    [params setObject:[row.value formValue] forKey:@"remind"];
    
    row = [self.form formRowWithTag:@"important"];
    [params setObject:([row.value formValue] ? : @"1") forKey:@"priority"];
    
    row = [self.form formRowWithTag:@"attend"];
    [params setObject:([row.value formValue] ? : @"") forKey:@"memberIds"];
    
    row = [self.form formRowWithTag:@"detail"];
    [params setObject:(row.value ? : @"") forKey:@"description"];
    
    [self.view beginLoading];
    [[Net_APIManager sharedManager] request_Common_CreateTaskSchedule_WithParams:params path:_requestPath block:^(id data, NSError *error) {
        [self.view endLoading];
        if (data) {
            if (self.refreshBlock) {
                self.refreshBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if (error.code == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [self rightButtonItemPress];
            };
            [comRequest loginInBackground];
        }
    }];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
