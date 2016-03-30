//
//  SalesOpportunityNewViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SalesOpportunityNewViewController.h"
#import <XLForm.h>
#import <MBProgressHUD.h>
#import "AFNHttp.h"
#import "ColumnModel.h"
#import "ColumnSelectModel.h"
#import "PresentViewController.h"
#import "PresentItem.h"
#import "XLFormCustomDateCell.h"

@interface SalesOpportunityNewViewController ()

@property (nonatomic, strong) NSMutableArray *sourceArray;
@end

@implementation SalesOpportunityNewViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    // 自定义返回按钮 开启手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonItemPress)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleBordered target:self action:@selector(rightButtonItemPress)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _sourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    XLFormDescriptor *form = [XLFormDescriptor formDescriptor];
    self.form = form;
    
    NSMutableDictionary *params=[NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [params setObject:_typeId forKey:@"typeId"];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP, kNetPath_SaleChance_Create] params:params success:^(id responseObj) {
        [hud hide:YES];
        if ([[responseObj objectForKey:@"status"] integerValue]) {  // 加载失败
            
            return;
        }
        
        for (NSDictionary *tempDict in [responseObj objectForKey:@"columns"]) {
            ColumnModel *item = [NSObject objectOfClass:@"ColumnModel" fromJSON:tempDict];
            for (NSDictionary *selectDict in tempDict[@"select"]) {
                ColumnSelectModel *selectItem = [NSObject objectOfClass:@"ColumnSelectModel" fromJSON:selectDict];
                [item.selectArray addObject:selectItem];
            }
            [item configResultWithDictionary:tempDict];
            [_sourceArray addObject:item];
        }
        
        [self createXLForm];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        NSLog(@"error:%@",error);
    }];

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
    
}

- (void)addMoreButtonPress {
    
}

#pragma mark - Private method
- (void)createXLForm {
    
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSection];
    [self.form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"type" rowType:XLFormRowDescriptorTypeText title:@"业务类型"];
    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [row.cellConfig setObject:[UIColor lightGrayColor] forKey:@"textField.textColor"];
    [row.cellConfig setObject:[UIColor blackColor] forKey:@"textLabel.textColor"];
    row.value = @"默认业务类型";
    row.disabled = @1;
    [section addFormRow:row];
    
    for (ColumnModel *columnItem in _sourceArray) {
        
        switch ([columnItem.columnType integerValue]) {
            case 1: {   // 文本
                row = [XLFormRowDescriptor formRowDescriptorWithTag:columnItem.name rowType:XLFormRowDescriptorTypeText title:columnItem.name];
                [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
                if ([columnItem.required integerValue]) {
                    [row.cellConfigAtConfigure setObject:@"点击填写" forKey:@"textField.placeholder"];
                }else {
                    [row.cellConfigAtConfigure setObject:@"必填" forKey:@"textField.placeholder"];
                }
                [section addFormRow:row];
            }
                break;
            case 2: {   // 文本域
                row = [XLFormRowDescriptor formRowDescriptorWithTag:columnItem.name rowType:XLFormRowDescriptorTypeTextView];
                if ([columnItem.required integerValue]) {
                    [row.cellConfigAtConfigure setObject:columnItem.name forKey:@"textView.placeholder"];
                }else {
                    [row.cellConfigAtConfigure setObject:[NSString stringWithFormat:@"%@(必填)", columnItem.name] forKey:@"textView.placeholder"];
                }
                [section addFormRow:row];
            }
                break;
            case 3: {   // 单选框
                row = [XLFormRowDescriptor formRowDescriptorWithTag:columnItem.name rowType:XLFormRowDescriptorTypeSelectorPush title:columnItem.name];
                row.selectorTitle = columnItem.name;    // 进去单选界面的title
                if ([columnItem.required integerValue]) {
                    row.noValueDisplayText = @"点击填写";
                }else {
                    row.noValueDisplayText = @"必填";
                }
                NSMutableArray *optionsArray = [[NSMutableArray alloc] initWithCapacity:columnItem.selectArray.count];
                for (ColumnSelectModel *tempSelect in columnItem.selectArray) {
                    XLFormOptionsObject *object = [XLFormOptionsObject formOptionsObjectWithValue:tempSelect.id displayText:tempSelect.value];
                    [optionsArray addObject:object];
                }
                row.selectorOptions = optionsArray;
                [section addFormRow:row];
            }
                break;
            case 4: {   // 多选框
                row = [XLFormRowDescriptor formRowDescriptorWithTag:columnItem.name rowType:XLFormRowDescriptorTypeMultipleSelector title:columnItem.name];
                row.selectorTitle = columnItem.name;    // 进入多选界面的title
                if ([columnItem.required integerValue]) {
                    row.noValueDisplayText = @"点击填写";
                }else {
                    row.noValueDisplayText = @"必填";
                }
                NSMutableArray *optionsArray = [[NSMutableArray alloc] initWithCapacity:columnItem.selectArray.count];
                for (ColumnSelectModel *tempSelect in columnItem.selectArray) {
                    XLFormOptionsObject *object = [XLFormOptionsObject formOptionsObjectWithValue:tempSelect.id displayText:tempSelect.value];
                    [optionsArray addObject:object];
                }
                row.selectorOptions = optionsArray;
                [section addFormRow:row];
            }
                break;
            case 5: {   // 整数
                row = [XLFormRowDescriptor formRowDescriptorWithTag:columnItem.name rowType:XLFormRowDescriptorTypeInteger title:columnItem.name];
                [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
                if ([columnItem.required integerValue]) {
                    [row.cellConfigAtConfigure setObject:@"点击填写" forKey:@"textField.placeholder"];
                }else {
                    [row.cellConfigAtConfigure setObject:@"必填" forKey:@"textField.placeholder"];
                }
                [section addFormRow:row];
            }
                break;
            case 6: {   // 浮点数
                row = [XLFormRowDescriptor formRowDescriptorWithTag:columnItem.name rowType:XLFormRowDescriptorTypeDecimal title:columnItem.name];
                [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
                if ([columnItem.required integerValue]) {
                    [row.cellConfigAtConfigure setObject:@"点击填写" forKey:@"textField.placeholder"];
                }else {
                    [row.cellConfigAtConfigure setObject:@"必填" forKey:@"textField.placeholder"];
                }
                [section addFormRow:row];
            }
                break;
            case 7: {   // 日期
                row = [XLFormRowDescriptor formRowDescriptorWithTag:columnItem.name rowType:XLFormRowDescriptorTypeCustomDate title:columnItem.name];
                [row.cellConfig setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"accessoryType"];
                if ([columnItem.required integerValue]) {
                    row.noValueDisplayText = @"点击填写";
                }else {
                    row.noValueDisplayText = @"必填";
                }
                [section addFormRow:row];
            }
                break;
            case 8: {   // 创建section
                section = [XLFormSectionDescriptor formSectionWithTitle:columnItem.name];
                [self.form addFormSection:section];
            }
                break;
            default:
                break;
        }
    }
    
    /**
     * 添加更多信息
     */
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, kScreen_Width, 64);
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitle:@"＋添加更多条目" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addMoreButtonPress) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableFooterView = button;
}

- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue {
    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];
    
    if ([formRow.rowType isEqualToString:XLFormRowDescriptorTypeCustomDate] && [oldValue isEqual:[NSNull null]]) {
        [self updateFormRow:formRow];
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

@end
