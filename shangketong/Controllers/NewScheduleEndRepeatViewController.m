//
//  NewScheduleEndRepeatViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-8-5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "NewScheduleEndRepeatViewController.h"
#import "NewScheduleEndRepeatModel.h"
#import "CommonFuntion.h"
#import "CommonConstant.h"

@interface NewScheduleEndRepeatViewController (){
    BOOL flagOfValueChange;
    
    BOOL isNever;
    NSString *selectedDate;
}

@property (nonatomic, strong) NewScheduleEndRepeatModel *selectContent;

@end

@implementation NewScheduleEndRepeatViewController
@synthesize rowDescriptor = _rowDescriptor;
@synthesize popoverController = __popoverController;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kView_BG_Color;
    self.title = @"结束条件";
    
    UIBarButtonItem *okButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(okButtonItem)];
    self.navigationItem.rightBarButtonItem = okButtonItem;
    
    flagOfValueChange = FALSE;
    _selectContent = [[NewScheduleEndRepeatModel alloc] init];
    _selectContent.selectedContent = [self.rowDescriptor.value displayText];
    
    ///修改日程详情
    if (self.flagOfPlanUpdate && [self.flagOfPlanUpdate isEqualToString:@"update-schedule"]) {
        NSLog(@"self.dicPlanInfo:%@",self.dicPlanInfo);
    }
    
    [self addRow];
}

-(void)okButtonItem{
    ///修改日程详情
    if (self.flagOfPlanUpdate && [self.flagOfPlanUpdate isEqualToString:@"update-schedule"]) {
        ///日期  是不是永不结束
        [self sendRequest];
    }else{
        self.rowDescriptor.value =  _selectContent;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)addRow {
    
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    XLFormDescriptor *form = [XLFormDescriptor formDescriptor];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    [section setFooterTitle:@"重复类型是按照您所设置的起止时间重复 如:起止时间为2015年8月5日--6日，每周重复就是每周四--周五重复。每天、每月同理"];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"never" rowType:XLFormRowDescriptorTypeBooleanCheck title:@"永不结束"];
    
    ///修改日程详情
    if (self.flagOfPlanUpdate && [self.flagOfPlanUpdate isEqualToString:@"update-schedule"]) {
        
        //下面两个字段如果在不重复的情况下不传。
        ///repeatEndType结束重复类型：1永不结束；2按日期结束
        ///repeatEndTime按日期结束的结束如期。
        
        if (self.dicPlanInfo && [[self.dicPlanInfo safeObjectForKey:@"repeatEndType"] integerValue] == 2) {
            ///按日期结束
            row.value = @NO;
        }else{
            ///永不结束
            row.value = @YES;
            _selectContent.selectedContent = @"永不结束";
        }
        
    }else{
        if (_selectContent.selectedContent == nil || [_selectContent.selectedContent isEqualToString:@"永不结束"]) {
            row.value = @YES;
        }else{
            row.value = @NO;
        }
    }

    [section addFormRow:row];
    
    // date
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"date" rowType:XLFormRowDescriptorTypeDate title:@"直到一个日期"];
    
    ///修改日程详情
    if (self.flagOfPlanUpdate && [self.flagOfPlanUpdate isEqualToString:@"update-schedule"]) {
        //下面两个字段如果在不重复的情况下不传。
        ///repeatEndType结束重复类型：1永不结束；2按日期结束
        ///repeatEndTime按日期结束的结束如期。
        
        if (self.dicPlanInfo && [[self.dicPlanInfo safeObjectForKey:@"repeatEndType"] integerValue] == 2) {
            _selectContent.selectedContent = [self.dicPlanInfo objectForKey:@"repeatEndTime"];
            NSDate *date =  [CommonFuntion stringToDate:[self.dicPlanInfo objectForKey:@"repeatEndTime"] Format:DATE_FORMAT_yyyyMMdd];
            row.value = date;
        }
        
    }else{
        if (_selectContent.selectedContent !=nil && ![_selectContent.selectedContent isEqualToString:@"永不结束"]) {
            NSDate *date = [CommonFuntion stringToDate:_selectContent.selectedContent Format:DATE_FORMAT_yyyyMMdd];
            row.value = date;
        }
    }
    
    [section addFormRow:row];
    
    self.form = form;
    
    ///修改日程详情
    if (self.flagOfPlanUpdate && [self.flagOfPlanUpdate isEqualToString:@"update-schedule"]) {
        
    }else{
    }
}


#pragma mark - XLFormDescriptorDelegate
-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
    if (!flagOfValueChange && [rowDescriptor.tag isEqualToString:@"never"]){
        flagOfValueChange = !flagOfValueChange;
        _selectContent.selectedContent = @"永不结束";
        XLFormRowDescriptor * dateDescriptor = [self.form formRowWithTag:@"date"];
        ///修改日程详情
        if (self.flagOfPlanUpdate && [self.flagOfPlanUpdate isEqualToString:@"update-schedule"]) {
            isNever = YES;
        }else{
            
        }
       
        dateDescriptor.value = nil;
        [self updateFormRow:dateDescriptor];
    }
    else if (!flagOfValueChange && [rowDescriptor.tag isEqualToString:@"date"]){
        
        flagOfValueChange = !flagOfValueChange;
        
        NSString *dateStr = [CommonFuntion dateToString:rowDescriptor.value Format:DATE_FORMAT_yyyyMMdd];
        _selectContent.selectedContent = dateStr;
        XLFormRowDescriptor * neverDescriptor = [self.form formRowWithTag:@"never"];
        neverDescriptor.value = @NO;
        [self updateFormRow:neverDescriptor];
        
        ///修改日程详情
        if (self.flagOfPlanUpdate && [self.flagOfPlanUpdate isEqualToString:@"update-schedule"]) {
            isNever = NO;
            selectedDate = dateStr;
        }else{
        }
        
    }else{
        flagOfValueChange = !flagOfValueChange;
    }
}



///修改日程重复事件
- (void)sendRequest{
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params addEntriesFromDictionary:self.dicPlanInfo];
    
    if (_selectContent.selectedContent == nil || [_selectContent.selectedContent isEqualToString:@"永不结束"]) {
        [params setObject:[NSNumber numberWithInt:1] forKey:@"repeatEndType"];
        [params setObject:@"" forKey:@"repeatEndTime"];
    }else{
        [params setObject:[NSNumber numberWithInt:2] forKey:@"repeatEndType"];
        [params setObject:_selectContent.selectedContent forKey:@"repeatEndTime"];
    }
    [params setObject:[NSNumber numberWithInteger:self.repeatType] forKey:@"repeatType"];
    [params setObject:@"0" forKey:@"isRepeat"];
    
    [params removeObjectForKey:@"scheduleTypeColor"];
    
    NSLog(@"params:%@",params);
    
    NSLog(@"---%@", appDelegateAccessor.moudle.userId);
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, kNetPath_Schedule_Update] params:params success:^(id responseObj) {
        [hud hide:YES];

        if ([[responseObj objectForKey:@"status"] integerValue] == 0) {
            
            ///修改成功  回刷UI以及数据
            
            if (_selectContent.selectedContent == nil || [_selectContent.selectedContent isEqualToString:@"永不结束"]) {
                [self.dicPlanInfo setObject:[NSNumber numberWithInt:1] forKey:@"repeatEndType"];
                [self.dicPlanInfo setObject:@"" forKey:@"repeatEndTime"];
            }else{
                [self.dicPlanInfo setObject:[NSNumber numberWithInt:2] forKey:@"repeatEndType"];
                [self.dicPlanInfo setObject:_selectContent.selectedContent forKey:@"repeatEndTime"];
            }
            [self.dicPlanInfo setObject:[NSNumber numberWithInteger:self.repeatType] forKey:@"repeatType"];
            [self.dicPlanInfo setObject:@0 forKey:@"isRepeat"];
            

            if (self.valueDateBlock) {
                self.valueDateBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
            
        }
    } failure:^(NSError *error) {
        [hud hide:YES];
    }];
}



@end
