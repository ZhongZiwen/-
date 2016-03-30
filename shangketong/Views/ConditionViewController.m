//
//  ConditionViewController.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/17.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ConditionViewController.h"
#import <XLForm.h>
#import "CustomViewController.h"

static NSString *const kPeriodType = @"periodType";
static NSString *const kDeparts = @"departs";

@interface ConditionViewController ()

@end

@implementation ConditionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonPress)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"应用" style:UIBarButtonItemStyleDone target:self action:@selector(confirmButtonPress)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:@"筛选"];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPeriodType rowType:XLFormRowDescriptorTypeSelectorPush title:@"时间范围"];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"本周"];
    row.selectorTitle = @"选择时间";
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"本周"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"本月"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"本季度"]];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDeparts rowType:XLFormRowDescriptorTypeSelectorPush title:@"查看范围"];
    row.action.viewControllerClass = [CustomViewController class];
    [section addFormRow:row];
    
    self.form = form;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)cancelButtonPress {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)confirmButtonPress {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
