//
//  NewLeadHighSeaController.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "NewLeadHighSeaController.h"
#import <XLForm.h>
#import "PresentViewController.h"
#import "PresentItem.h"

static NSString *const kStatus = @"status";
static NSString *const kName = @"name";
static NSString *const kSex = @"sex";
static NSString *const kCompany = @"campany";
static NSString *const kDepartment = @"department";
static NSString *const kJob = @"job";
static NSString *const kTel = @"tel";
static NSString *const kPhone = @"phone";
static NSString *const kEmail = @"email";
static NSString *const kWeibo = @"weibo";
static NSString *const kProvince = @"province";
static NSString *const kAddress = @"address";
static NSString *const kMail = @"mail";
static NSString *const kSource = @"source";
static NSString *const kRemark = @"remark";
static NSString *const kBelongDepartment = @"belongDepartment";

@interface NewLeadHighSeaController ()

@property (nonatomic, strong) NSMutableArray *moreSourceArray;
@end

@implementation NewLeadHighSeaController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray *array = @[@"跟进状态", @"性别", @"部门", @"职务", @"电话", @"手机", @"电子邮件", @"微博", @"省份", @"地址", @"邮政编码", @"线索来源", @"备注"];
    _moreSourceArray = [NSMutableArray arrayWithCapacity:array.count];
    for (NSString *str in array) {
        PresentItem *item = [PresentItem initWithTitle:str];
        [_moreSourceArray addObject:item];
    }
    
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:@"创建销售线索"];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"基本信息"];
    [form addFormSection:section];
    
    // 跟进状态
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kStatus rowType:XLFormRowDescriptorTypeSelectorPickerView title:@"跟进状态"];
    row.hidden = @1;
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"未处理"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"未处理"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"已联系"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"关闭"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"已沟通"]];
    [row.cellConfig setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"accessoryType"];
    [section addFormRow:row];
    
    // 姓名
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName rowType:XLFormRowDescriptorTypeText title:@"姓名"];
    [row.cellConfig setObject:@"必填" forKey:@"textField.placeholder"];
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    // 性别
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSex rowType:XLFormRowDescriptorTypeSelectorPickerView title:@"性别"];
    row.hidden = @1;
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(-1) displayText:@"点击选择"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@""],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"男"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"女"]];
    [row.cellConfig setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"accessoryType"];
    [section addFormRow:row];
    
    // 公司名称
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCompany rowType:XLFormRowDescriptorTypeText title:@"公司名称"];
    [row.cellConfig setObject:@"必填" forKey:@"textField.placeholder"];
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    // 部门
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDepartment rowType:XLFormRowDescriptorTypeText title:@"部门"];
    row.hidden = @1;
    [row.cellConfig setObject:@"点击填写" forKey:@"textField.placeholder"];
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    // 职务
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kJob rowType:XLFormRowDescriptorTypeText title:@"职务"];
    row.hidden = @1;
    [row.cellConfig setObject:@"点击填写" forKey:@"textField.placeholder"];
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"联系信息"];
    section.hidden = @1;
    [form addFormSection:section];
    
    // 电话
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kTel rowType:XLFormRowDescriptorTypeInteger title:@"电话"];
    row.hidden = @1;
    [row.cellConfig setObject:@"点击填写" forKey:@"textField.placeholder"];
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    // 手机
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhone rowType:XLFormRowDescriptorTypeInteger title:@"手机"];
    row.hidden = @1;
    [row.cellConfig setObject:@"点击填写" forKey:@"textField.placeholder"];
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    // 电子邮件
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEmail rowType:XLFormRowDescriptorTypeEmail title:@"电子邮件"];
    row.hidden = @1;
    [row.cellConfig setObject:@"点击填写" forKey:@"textField.placeholder"];
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    // 微博
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kWeibo rowType:XLFormRowDescriptorTypeText title:@"微博"];
    row.hidden = @1;
    [row.cellConfig setObject:@"点击填写" forKey:@"textField.placeholder"];
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    // 省份
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kProvince rowType:XLFormRowDescriptorTypeText title:@"省份"];
    row.hidden = @1;
    [row.cellConfig setObject:@"点击填写" forKey:@"textField.placeholder"];
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    // 地址
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kAddress rowType:XLFormRowDescriptorTypeText title:@"地址"];
    row.hidden = @1;
    [row.cellConfig setObject:@"点击填写" forKey:@"textField.placeholder"];
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    // 邮政编码
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kMail rowType:XLFormRowDescriptorTypeText title:@"邮政编码"];
    row.hidden = @1;
    [row.cellConfig setObject:@"点击填写" forKey:@"textField.placeholder"];
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    // 其它信息
    section = [XLFormSectionDescriptor formSectionWithTitle:@"其它信息"];
    section.hidden = @1;
    [form addFormSection:section];
    
    // 线索来源
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSource rowType:XLFormRowDescriptorTypeSelectorPickerView title:@"线索来源"];
    row.hidden = @1;
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(-1) displayText:@"点击选择"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@""],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"研讨会"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"搜索引擎"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"客户介绍"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"其它"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"展会"]];
    [row.cellConfig setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"accessoryType"];
    [section addFormRow:row];
    
    // 备注
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kRemark rowType:XLFormRowDescriptorTypeTextView];
    row.hidden = @1;
    [row.cellConfigAtConfigure setObject:@"备注（点击输入）" forKey:@"textView.placeholder"];
    [section addFormRow:row];
    
    // 数据权限
    section = [XLFormSectionDescriptor formSectionWithTitle:@"数据权限"];
    [form addFormSection:section];
    
    // 所属部门
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kBelongDepartment rowType:XLFormRowDescriptorTypeSelectorPush title:@"所属部门"];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"客服部"];
    row.selectorTitle = @"所属部门";
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"上海分公司"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"销售部"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"客服部"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"技术部"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"销售一部"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"1"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(6) displayText:@"2"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(7) displayText:@"3"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(8) displayText:@"4"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(9) displayText:@"5"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(10) displayText:@"6"]];
    [section addFormRow:row];
    
    self.form = form;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, kScreen_Width, 64);
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitle:@"＋点击添加更多信息" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addMoreButtonPress) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableFooterView = button;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)addMoreButtonPress {
    if (![_moreSourceArray count])
        return;
    
    __weak __block NewLeadHighSeaController *copy_self = self;
    PresentViewController *presentController = [[PresentViewController alloc] init];
    presentController.title = @"添加更多项目";
    presentController.sourceArray = _moreSourceArray;
    presentController.addBlock = ^(PresentItem *item) {
        // 跟进状态
        if ([item.m_title isEqualToString:@"跟进状态"]) {
            XLFormRowDescriptor *row = [copy_self.form formRowWithTag:kStatus];
            row.hidden = @0;
        }
        // 性别
        if ([item.m_title isEqualToString:@"性别"]) {
            XLFormRowDescriptor *row = [copy_self.form formRowWithTag:kSex];
            row.hidden = @0;
        }
        // 部门
        if ([item.m_title isEqualToString:@"部门"]) {
            XLFormRowDescriptor *row = [copy_self.form formRowWithTag:kDepartment];
            row.hidden = @0;
        }
        // 职务
        if ([item.m_title isEqualToString:@"职务"]) {
            XLFormRowDescriptor *row = [copy_self.form formRowWithTag:kJob];
            row.hidden = @0;
        }
        // 电话
        if ([item.m_title isEqualToString:@"电话"]) {
            XLFormRowDescriptor *row = [copy_self.form formRowWithTag:kTel];
            row.sectionDescriptor.hidden = @0;
            row.hidden = @0;
        }
        // 手机
        if ([item.m_title isEqualToString:@"手机"]) {
            XLFormRowDescriptor *row = [copy_self.form formRowWithTag:kPhone];
            row.sectionDescriptor.hidden = @0;
            row.hidden = @0;
        }
        // 电子邮件
        if ([item.m_title isEqualToString:@"电子邮件"]) {
            XLFormRowDescriptor *row = [copy_self.form formRowWithTag:kEmail];
            row.sectionDescriptor.hidden = @0;
            row.hidden = @0;
        }
        // 微博
        if ([item.m_title isEqualToString:@"微博"]) {
            XLFormRowDescriptor *row = [copy_self.form formRowWithTag:kWeibo];
            row.sectionDescriptor.hidden = @0;
            row.hidden = @0;
        }
        // 省份
        if ([item.m_title isEqualToString:@"省份"]) {
            XLFormRowDescriptor *row = [copy_self.form formRowWithTag:kProvince];
            row.sectionDescriptor.hidden = @0;
            row.hidden = @0;
        }
        // 地址
        if ([item.m_title isEqualToString:@"地址"]) {
            XLFormRowDescriptor *row = [copy_self.form formRowWithTag:kAddress];
            row.sectionDescriptor.hidden = @0;
            row.hidden = @0;
        }
        // 邮政编码
        if ([item.m_title isEqualToString:@"邮政编码"]) {
            XLFormRowDescriptor *row = [copy_self.form formRowWithTag:kMail];
            row.sectionDescriptor.hidden = @0;
            row.hidden = @0;
        }
        // 线索来源
        if ([item.m_title isEqualToString:@"线索来源"]) {
            XLFormRowDescriptor *row = [copy_self.form formRowWithTag:kSource];
            row.sectionDescriptor.hidden = @0;
            row.hidden = @0;
        }
        // 备注
        if ([item.m_title isEqualToString:@"备注"]) {
            XLFormRowDescriptor *row = [copy_self.form formRowWithTag:kRemark];
            row.sectionDescriptor.hidden = @0;
            row.hidden = @0;
        }
    };
    presentController.deleteBlock = ^(PresentItem *item) {
        [copy_self.moreSourceArray removeObject:item];
//        if (![copy_self.moreSourceArray count]) {
//            copy_self.tableView.tableFooterView = nil;
//        }
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:presentController];
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

#pragma mark - UITableView_M
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
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
