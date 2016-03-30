//
//  SelectHolidayTimeViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SelectHolidayTimeViewController.h"
#import "LLCenterUtility.h"
#import "NSDate+Utils.h"
#import "EditItemModel.h"
#import "TPKeyboardAvoidingTableView.h"
#import "CommonFunc.h"
#import "EditItemTypeCellF.h"
#import "LLCenterPickerView.h"

@interface SelectHolidayTimeViewController ()<UITableViewDataSource,UITableViewDelegate>{
    ///结束时间的最小时间
    NSDate *minDate;
}


@property(strong,nonatomic) TPKeyboardAvoidingTableView *tableview;
@property(strong,nonatomic) NSMutableArray *dataSource;

@end

@implementation SelectHolidayTimeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = COLOR_BG;
    self.title = @"节假日";
    [self addNavBar];
    [self initTableview];
    [self initData];
    [self initDataWithActionType];
    [self.tableview reloadData];
}



#pragma mark - Nav Bar
-(void)addNavBar{
    [super customBackButton];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonPress)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
}

#pragma mark-  保存事件
-(void)saveButtonPress {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
   
    EditItemModel *itemStart = (EditItemModel *)[self.dataSource objectAtIndex:0];
    if (itemStart.content == nil || [itemStart.content isEqualToString:@""]) {
        [CommonFuntion showToast:@"开始时间不能为空" inView:self.view];
        return;
    }
    
    EditItemModel *itemEnd = (EditItemModel *)[self.dataSource objectAtIndex:1];
    if (itemEnd.content == nil || [itemEnd.content isEqualToString:@""]) {
        [CommonFuntion showToast:@"结束时间不能为空" inView:self.view];
        return;
    }
    
    
    EditItemModel *item;
    for (int i=0; i<[self.dataSource count]; i++) {
        
        item = (EditItemModel*) [self.dataSource objectAtIndex:i];
        
        if (item.keyStr && item.keyStr.length > 0) {
            NSLog(@"key: %@   value: %@",item.keyStr,item.content);
        }
    }
    
    if (self.SelectDateTimeDoneBlock) {
        self.SelectDateTimeDoneBlock(itemStart.content,itemEnd.content);
    }
    [self.navigationController popViewControllerAnimated:YES];
  
}


#pragma mark - 初始化数据
-(void)initData{
    self.dataSource = [[NSMutableArray alloc] init];
}


#pragma mark - 根据操作类型 新增/编辑 初始化数据源
-(void)initDataWithActionType{

    NSString *startTime = @"";
    NSString *endTime = @"";
 
    if (self.holidayStartTime) {
        startTime = self.holidayStartTime;
    }
    
    if (self.holidayEndTime) {
        endTime = self.holidayEndTime;
    }
    
    
    NSLog(@"initDataWithActionType startTime:%@",startTime);
    NSLog(@"initDataWithActionType endTime:%@",endTime);
    

    EditItemModel *model;
    
    model = [[EditItemModel alloc] init];
    model.title = @"开始时间:";
    model.itemId = @"";
    model.content = startTime;
    model.placeholder = @"";
    model.cellType = @"cellF";
    model.keyStr = @"startTime";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"结束时间:";
    model.itemId = @"";
    model.content = endTime;
    model.placeholder = @"";
    model.cellType = @"cellF";
    model.keyStr = @"endTime";
    model.keyType = @"";
    [self.dataSource addObject:model];
    

    NSLog(@"self.dataSource:%@",self.dataSource);
    for (int i=0; i<[self.dataSource count]; i++) {
        EditItemModel *item  = (EditItemModel*) [self.dataSource objectAtIndex:i];
        NSLog(@"%@  %@",item.title,item.cellType);
    }
}


#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableview = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-64) style:UITableViewStyleGrouped];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.sectionFooterHeight = 0;
    
    [self.view addSubview:self.tableview];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableview setTableFooterView:v];
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}


#pragma mark - tableview


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource  count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditItemModel* item = (EditItemModel*) [self.dataSource objectAtIndex:indexPath.row];
    
    if ([item.cellType isEqualToString:@"cellG"]) {
        return 80.0;
    }
    return 50.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditItemModel* item = (EditItemModel*) [self.dataSource objectAtIndex:indexPath.row];
    
     if ([item.cellType isEqualToString:@"cellF"]) {
        EditItemTypeCellF *cell = [tableView dequeueReusableCellWithIdentifier:@"EditItemTypeCellFIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"EditItemTypeCellF" owner:self options:nil];
            cell = (EditItemTypeCellF*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        __weak typeof(self) weak_self = self;
        cell.SelectDataTypeBlock = ^(NSInteger type){
            ///
            NSInteger falg = 1;
            
            ///开始时间 结束时间
            if (indexPath.row == 0) {
                falg = 0;
            }else{
                falg = 1;
            }
            
            [weak_self showDataPickerByFlag:falg];
            
        };
        [cell setCellDetail:item];
        return cell;
    }
    return nil;
}



///更新数据源
-(void)notifyDataSource:(NSIndexPath *)indexPath valueString:(NSString *)valueStr idString:(NSString *)ids{
    EditItemModel *model = (EditItemModel *)[self.dataSource objectAtIndex:indexPath.row];
    model.content = valueStr;
    model.itemId = ids;
    [self.tableview reloadData];
}



#pragma mark - 日期选择
/// 0 开始日期 1结束日期
-(void)showDataPickerByFlag:(NSInteger)flag{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    ///开始日期
    if (flag == 0) {
        [self showDatePickForDateTypeJJRStart];
    }else if (flag == 1){
        [self showDatePickForDateTypeJJREnd];
    }
}


#pragma mark - 节假日时间选择处理
-(void)showDatePickForDateTypeJJRStart{
    __weak typeof(self) weak_self = self;
    
    NSDate *dateNow = [NSDate date];
    LLCenterPickerView *llsheet = [[LLCenterPickerView alloc]initWithCurDate:dateNow andMinDate:dateNow headTitle:@"开始时间" dateType:2];
    llsheet.selectedDateBlock = ^(NSString *time,NSDate *date){
        NSString *startTime = @"";
        NSLog(@"-----date:%@",date);
        minDate = date;
        if (date == nil) {
            NSTimeZone *zone = [NSTimeZone systemTimeZone];
            NSInteger interval = [zone secondsFromGMTForDate: dateNow];
            minDate = [dateNow  dateByAddingTimeInterval: interval];
        }
        startTime = [CommonFunc dateToString:minDate Format:@"yyyy-MM-dd HH:mm"];
        NSLog(@"-----startTime:%@",startTime);
        
        [weak_self notifyDataSource:[NSIndexPath indexPathForRow:0 inSection:0] valueString:startTime idString:@""];
        [weak_self.tableview reloadData];
    };
    [llsheet showInView:nil];
}

///结束时间
-(void)showDatePickForDateTypeJJREnd{
    __weak typeof(self) weak_self = self;
    
    LLCenterPickerView *llsheet;
    if (minDate == nil) {
        NSDate *dateNow = [NSDate date];
        llsheet = [[LLCenterPickerView alloc]initWithCurDate:dateNow andMinDate:nil headTitle:@"结束时间" dateType:2];
    }else{
        NSLog(@"minDate:%@",minDate);
        llsheet = [[LLCenterPickerView alloc]initWithCurDate:minDate andMinDate:minDate headTitle:@"结束时间" dateType:2];
    }
    
    llsheet.selectedDateBlock = ^(NSString *time,NSDate *date){
        NSLog(@"-----time:%@",time);
        NSLog(@"-----date:%@",date);
        
        NSString *stopTime = @"";
        if (date == nil) {
            NSDate *dateNow = [NSDate date];
            NSTimeZone *zone = [NSTimeZone systemTimeZone];
            NSInteger interval = [zone secondsFromGMTForDate: dateNow];
            NSDate *dateT = [dateNow  dateByAddingTimeInterval: interval];
            stopTime = [CommonFunc dateToString:dateT Format:@"yyyy-MM-dd HH:mm"];
        }else{
            stopTime = [CommonFunc dateToString:date Format:@"yyyy-MM-dd HH:mm"];
        }
        
        [weak_self notifyDataSource:[NSIndexPath indexPathForRow:1 inSection:0] valueString:stopTime idString:@""];
        [weak_self.tableview reloadData];
    };
    [llsheet showInView:nil];
}



@end
