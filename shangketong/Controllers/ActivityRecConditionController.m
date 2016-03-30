//
//  ActivityRecConditionController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ActivityRecConditionController.h"
#import "NSDate+Helper.h"
#import <XLForm.h>
#import "ValueIdModel.h"
#import "AddressBook.h"
#import "ExportAddress.h"
#import "ExportAddressViewController.h"
#import "ActivityRecSearchResultController.h"

@interface ActivityRecConditionController ()

@end

@implementation ActivityRecConditionController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"筛选" target:self action:@selector(rightButtonItemPress)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    XLFormDescriptor *form = [XLFormDescriptor formDescriptor];
    XLFormSectionDescriptor *section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    XLFormRowDescriptor *row;
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"begainTime" rowType:XLFormRowDescriptorTypeDateInline title:@"起始时间"];
    row.value = [NSDate dateStartOfWeek];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"endTime" rowType:XLFormRowDescriptorTypeDateInline title:@"截止时间"];
    row.value = [NSDate dateEndOfWeek];
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"responsibly" rowType:XLFormRowDescriptorTypeSelectorPush title:@"责任人"];
    row.action.viewControllerClass = [ExportAddressViewController class];
    row.selectorTitle = @"选择责任人";
    row.noValueDisplayText = @"点击选择(必选)";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"type" rowType:XLFormRowDescriptorTypeMultipleSelector title:@"类型"];
    row.noValueDisplayText = @"点击选择";
    [section addFormRow:row];
    
    self.form = form;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[Net_APIManager  sharedManager] request_ActivityRecord_Type_WithBlock:^(id data, NSError *error) {
            if (data) {
                NSMutableArray *valueArray = [NSMutableArray arrayWithCapacity:0];
                for (NSString *keyStr in [data[@"records"] allKeys]) {
                    ValueIdModel *item = [[ValueIdModel alloc] init];
                    item.id = keyStr;
                    item.value = data[@"records"][keyStr];
                    XLFormOptionsObject *object = [XLFormOptionsObject formOptionsObjectWithValue:item.id displayText:item.value];
                    [valueArray addObject:object];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    XLFormRowDescriptor *row = [self.form formRowWithTag:@"type"];
                    row.selectorOptions = valueArray;
                    row.selectorTitle = @"类型";
                    [self reloadFormRow:row];
                });
            }else {
                NSLog(@"获取活动记录类型失败");
            }
        }];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)rightButtonItemPress {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    [params setObject:@4 forKey:@"type"];
    
    // 起始时间
    XLFormRowDescriptor *row = [self.form formRowWithTag:@"begainTime"];
    NSDate *startDate = row.value;
    NSString *startTime = [startDate stringYearMonthDayForLine];
    [params setObject:startTime forKey:@"startTime"];
    
    // 结束时间
    row = [self.form formRowWithTag:@"endTime"];
    NSDate *endDate = row.value;
    NSString *endTime = [endDate stringYearMonthDayForLine];
    [params setObject:endTime forKey:@"endTime"];
    
    // 责任人
    row = [self.form formRowWithTag:@"responsibly"];
    ExportAddress *exportAddress = row.value;
    if (!exportAddress) {
        kShowHUD(@"请选择责任人");
        return;
    }
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:4];
    for (int i = 0; i < (exportAddress.selectedArray.count - 1 > 4 ? 4 : exportAddress.selectedArray.count - 1); i ++) {
        AddressBook *item = exportAddress.selectedArray[i];
        [tempArray addObject:item];
        
        if (i == 0) {
            [params setObject:item.id forKey:@"userId"];
        }
    }
    
    // 类型
    row = [self.form formRowWithTag:@"type"];
    NSString *typeId;
    for (int i = 0; i < [row.value count]; i ++) {
        XLFormOptionsObject *optionsObject = row.value[i];
        if (i == 0) {
            typeId = [NSString stringWithFormat:@"%@", optionsObject.formValue];
        }else {
            typeId = [NSString stringWithFormat:@"%@,%@", typeId, optionsObject.formValue];
        }
    }
    [params setObject:(typeId ? : @"") forKey:@"typeId"];
    
    ActivityRecSearchResultController *resultController = [[ActivityRecSearchResultController alloc] init];
    resultController.title = @"搜索结果";
    resultController.params = params;
    resultController.usersArray = [[NSArray alloc] initWithArray:tempArray];
    resultController.startDate = startDate;
    resultController.endDate = endDate;
    [self.navigationController pushViewController:resultController animated:YES];
}

#pragma mark - XLFormDescriptorDelegate
- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue {
    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];
    
    if ([formRow.tag isEqualToString:@"begainTime"]) {
        XLFormRowDescriptor *startDateDescriptor = [self.form formRowWithTag:@"begainTime"];
        XLFormRowDescriptor *endDateDescriptor = [self.form formRowWithTag:@"endTime"];
        
        if ([startDateDescriptor.value compare:endDateDescriptor.value] == NSOrderedDescending) {
            endDateDescriptor.value = [[NSDate alloc] initWithTimeInterval:(60*60*24) sinceDate:startDateDescriptor.value];
            [endDateDescriptor.cellConfig removeObjectForKey:@"detailTextLabel.attributedText"];
            [self updateFormRow:endDateDescriptor];
            
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
        }
    }
    else if ([formRow.tag isEqualToString:@"endTime"]) {
        XLFormRowDescriptor *startDateDescriptor = [self.form formRowWithTag:@"begainTime"];
        XLFormRowDescriptor *endDateDescriptor = [self.form formRowWithTag:@"endTime"];
        XLFormDateCell *dateEndCell = (XLFormDateCell*)[endDateDescriptor cellForFormController:self];
        if ([startDateDescriptor.value compare:endDateDescriptor.value] == NSOrderedDescending) {
            // startDateDescriptor is later than endDateDescriptor
            [dateEndCell update]; // force detailTextLabel update
            NSDictionary *strikeThroughAttribute = [NSDictionary dictionaryWithObject:@1
                                                                               forKey:NSStrikethroughStyleAttributeName];
            NSAttributedString* strikeThroughText = [[NSAttributedString alloc] initWithString:dateEndCell.detailTextLabel.text attributes:strikeThroughAttribute];
            [endDateDescriptor.cellConfig setObject:strikeThroughText forKey:@"detailTextLabel.attributedText"];
            [self updateFormRow:endDateDescriptor];
            
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
        }
        else{
            [endDateDescriptor.cellConfig removeObjectForKey:@"detailTextLabel.attributedText"];
            [self updateFormRow:endDateDescriptor];
            
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
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

@end
