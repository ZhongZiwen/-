//
//  ScheduleEditViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ScheduleEditViewController.h"
#import <XLForm.h>
#import "DateAndTimeValueTrasformer.h"
#import "XLFScheduleThemeCell.h"
#import "ScheduleTypeViewController.h"
#import "AFNHttp.h"
#import <MBProgressHUD.h>
#import "NSDate+Utils.h"
#import "XLEditScheduleDetailCell.h"
#import "ScheduleType.h"

@interface ScheduleEditViewController ()

@end

@implementation ScheduleEditViewController

- (void)loadView {
    [super loadView];
    
    self.title = @"修改日程";
    self.view.backgroundColor = kView_BG_Color;
    
    // 自定义返回按钮 开启手势返回
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(leftButtonItemPress)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"修改" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonItemPress)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"dict = %@", _scheduleSourceDict);
    
    XLFormDescriptor *form = [XLFormDescriptor formDescriptor];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"title" rowType:XLFormRowDescriptorTypeEditScheduleDetail];
    row.value = @{@"type" : @([_rowDescriptor.value[@"type"] integerValue]),
                  @"typeName" : _rowDescriptor.value[@"typeName"],
                  @"name" : _rowDescriptor.value[@"name"]};
    row.action.formBlock = ^(XLFormRowDescriptor *descriptor) {
        ScheduleTypeViewController *typeController = [[ScheduleTypeViewController alloc] init];
        typeController.title = @"选择类型";
        typeController.rowDescriptor = descriptor;
        typeController.valueBlock = ^(ScheduleType *itemType) {
            NSLog(@"--->dict:%@",itemType);
            XLFormRowDescriptor *myRow = [self.form formRowWithTag:@"title"];
            myRow.value = @{@"type" : itemType.color,
                            @"typeName" : itemType.name,
                            @"name" : [_scheduleSourceDict objectForKey:@"content"]};;
            [self updateFormRow:myRow];
            [_scheduleSourceDict setObject:itemType.id forKey:@"scheduleType"];
            [_scheduleSourceDict setObject:itemType.color forKey:@"scheduleTypeColor"];
//            [_scheduleSourceDict setObject:formRow.value[@"name"] forKey:@"content"];
            
//            [_scheduleSourceDict setObject:[myRow.value objectForKey:@"name"] forKey:@"content"];
//            [_scheduleSourceDict setObject:@([[myRow.value objectForKey:@"type"] integerValue]) forKey:@"scheduleType"];
        };
        [self.navigationController pushViewController:typeController animated:YES];
    };
    [section addFormRow:row];
    
    
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    // 全天
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"all-day" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"全天"];
    row.value = @(![_scheduleSourceDict[@"isAllDay"] boolValue]);
    [section addFormRow:row];
    
    // 开始
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"starts" rowType:XLFormRowDescriptorTypeDateTimeInline title:@"开始"];
    XLFormDateCell * dateCell = (XLFormDateCell *)[row cellForFormController:self];
    if ([_scheduleSourceDict[@"isAllDay"] integerValue]) {   // 非全天
        row.valueTransformer = [DateTimeValueTrasformer class];
        [dateCell setFormDatePickerMode:XLFormDateDatePickerModeDateTime];
    }else {
        row.valueTransformer = [DateValueTrasformer class];
        [dateCell setFormDatePickerMode:XLFormDateDatePickerModeDate];
    }
    row.value = [NSDate dateFromString:_scheduleSourceDict[@"startDate"] withFormat:@"yyyy-MM-dd HH:mm"];
    [section addFormRow:row];
    
    // 结束
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"ends" rowType:XLFormRowDescriptorTypeDateTimeInline title:@"结束"];
    dateCell = (XLFormDateCell *)[row cellForFormController:self];
    if ([_scheduleSourceDict[@"isAllDay"] integerValue]) {   // 非全天
        row.valueTransformer = [DateTimeValueTrasformer class];
        [dateCell setFormDatePickerMode:XLFormDateDatePickerModeDateTime];
    }else {
        row.valueTransformer = [DateValueTrasformer class];
        [dateCell setFormDatePickerMode:XLFormDateDatePickerModeDate];
    }
    row.value = [NSDate dateFromString:_scheduleSourceDict[@"endDate"] withFormat:@"yyyy-MM-dd HH:mm"];
    [section addFormRow:row];
    
    self.form = form;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue {
    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];
    
    if ([formRow.tag isEqualToString:@"title"]) {
        [_scheduleSourceDict setObject:formRow.value[@"name"] forKey:@"content"];
        NSLog(@"_scheduleSourceDict:%@",_scheduleSourceDict );
        
    } else if ([formRow.tag isEqualToString:@"all-day"]) {
        
        [_scheduleSourceDict setObject:@(![formRow.value integerValue]) forKey:@"isAllDay"];
        
        XLFormRowDescriptor * startDateDescriptor = [self.form formRowWithTag:@"starts"];
        XLFormRowDescriptor * endDateDescriptor = [self.form formRowWithTag:@"ends"];
        XLFormDateCell * dateStartCell = (XLFormDateCell *)[[self.form formRowWithTag:@"starts"] cellForFormController:self];
        XLFormDateCell * dateEndCell = (XLFormDateCell *)[[self.form formRowWithTag:@"ends"] cellForFormController:self];
        
        
        XLFormRowDescriptor * remindDescriptor = [self.form formRowWithTag:@"remind"];
        
        if ([[formRow.value valueData] boolValue] == YES){
            startDateDescriptor.valueTransformer = [DateValueTrasformer class];
            endDateDescriptor.valueTransformer = [DateValueTrasformer class];
            [dateStartCell setFormDatePickerMode:XLFormDateDatePickerModeDate];
            [dateEndCell setFormDatePickerMode:XLFormDateDatePickerModeDate];
        }
        else{
            startDateDescriptor.valueTransformer = [DateTimeValueTrasformer class];
            endDateDescriptor.valueTransformer = [DateTimeValueTrasformer class];
            [dateStartCell setFormDatePickerMode:XLFormDateDatePickerModeDateTime];
            [dateEndCell setFormDatePickerMode:XLFormDateDatePickerModeDateTime];
        }
        [self updateFormRow:startDateDescriptor];
        [self updateFormRow:endDateDescriptor];
        [self updateFormRow:remindDescriptor];
        
    }else if ([formRow.tag isEqualToString:@"starts"]) {
        
        [_scheduleSourceDict setObject:[newValue stringTimestamp] forKey:@"startDate"];
        
    }else if ([formRow.tag isEqualToString:@"ends"]) {
        
        [_scheduleSourceDict setObject:[newValue stringTimestamp] forKey:@"endDate"];
    }
}

- (void)sendRequest {
    
    NSLog(@"_scheduleSourceDict:%@",_scheduleSourceDict);
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params addEntriesFromDictionary:_scheduleSourceDict];
    [params removeObjectForKey:@"scheduleTypeColor"];
    
    NSLog(@"params = %@", params);
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, kNetPath_Schedule_Update] params:params success:^(id responseObj) {
        [hud hide:YES];

        if (![[responseObj objectForKey:@"status"] integerValue]) {
            
            NSString *detailStr = @"";
            if ([_scheduleSourceDict[@"isAllDay"] integerValue]) {   // 不是全天
                detailStr = [NSString stringWithFormat:@"%@ - %@", _scheduleSourceDict[@"startDate"], _scheduleSourceDict[@"endDate"]];
            }else {
                detailStr = [NSString stringWithFormat:@"%@ - %@", [_scheduleSourceDict[@"startDate"] substringToIndex:10], [_scheduleSourceDict[@"endDate"] substringToIndex:10]];
            }
            XLFormRowDescriptor *row = [self.form formRowWithTag:@"title"];
            NSDictionary *dict = @{@"type" : _scheduleSourceDict[@"scheduleTypeColor"],
                                   @"typeName" : [row.value objectForKey:@"typeName"],
                                   @"name" : _scheduleSourceDict[@"content"],
                                   @"detail" : detailStr,
                                   @"isPrivate" : _scheduleSourceDict[@"privateFlag"],
                                   @"isAllDay" : _scheduleSourceDict[@"isAllDay"],
                                   @"startDate" : _scheduleSourceDict[@"startDate"],
                                   @"endDate" : _scheduleSourceDict[@"endDate"],
                                   @"isEdit" : @1};
            if (self.valueBlock) {
                self.valueBlock(dict);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSError *error) {
        [hud hide:YES];
    }];
}

#pragma mark - event response
- (void)leftButtonItemPress {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonItemPress {
    
    [self sendRequest];
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
