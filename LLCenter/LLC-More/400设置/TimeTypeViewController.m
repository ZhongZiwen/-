//
//  TimeTypeViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TimeTypeViewController.h"
#import "TimeTypeModel.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"
#import "CommonStaticVar.h"
#import "CommonNoDataView.h"
#import "SelectTimeTypeCell.h"
#import "LLCenterPickerView.h"
#import "NSDate+Utils.h"
#import "TimeRangeModel.h"

@interface TimeTypeViewController ()<UITableViewDataSource,UITableViewDelegate>{
    ///结束时间的最小时间
    NSDate *minDate;
    
    ///标记
    NSInteger indexSelect;
    
    ///选择的值
    NSMutableString *strSelectWeek;
    NSMutableString *strSelectPointStartTime;
    NSMutableString *strSelectPointEndTime;
    
    ///当前选择的数据
    NSMutableArray *appointTimeWeekNew;
    NSMutableArray *startTimeNew;
    NSMutableArray *endTimeNew;
    
}

@property(strong,nonatomic) UITableView *tableview;
@property(strong,nonatomic) NSMutableArray *dataSource;
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;


@end

@implementation TimeTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑时间策略";
    [super customBackButton];
    self.view.backgroundColor = COLOR_BG;
    [self initData];
    [self initWeekTimeType];
    [self addNavBar];
    [self initTableview];
    [self.tableview reloadData];
    
    NSLog(@"compare:%ti",[@"05:45" compare:@"09:52"]);
    NSLog(@"compare:%ti",[@"10:45" compare:@"09:52"]);
    NSLog(@"compare:%ti",[@"05:45" compare:@"05:45"]);
}


#pragma mark - 初始化数据
-(void)initData{
    self.dataSource = [[NSMutableArray alloc] init];
    appointTimeWeekNew = [[NSMutableArray alloc] init];
    startTimeNew = [[NSMutableArray alloc] init];
    endTimeNew = [[NSMutableArray alloc] init];
}

///初始化默认数据
-(void)initWeekTimeType{
    
    ///星期时间默认选中数据
    /*
     appointTimeWeek =         (
     1,
     2,
     3
     );
     endTime =         (
     "23:59",
     "23:59",
     "23:59"
     );
     startTime =         (
     "00:00",
     "00:00",
     "00:00"
     );
     timeModle = 3;
     timeModleName = "\U5168\U90e8";
     */
    NSLog(@"self.timeStrategyData:%@",self.timeStrategyData);
    
    NSArray *startTime = [self.timeStrategyData objectForKey:@"startTime"];
    NSArray *endTime = [self.timeStrategyData objectForKey:@"endTime"];
    
    TimeTypeModel *model;
    NSMutableDictionary *item;
    for (int i=1; i<8; i++) {
        item = [[NSMutableDictionary alloc] init];
        ///周几
        [item setObject:[self getWeekNameByFlag:i] forKey:@"sitWeek"];
        
        ///判断是否已选择信息  如选择  则填充  否则默认数据
        NSInteger index = [self jugdeWeekIsSelected:i];
        if (index != -1) {
            [item setObject:@(YES) forKey:@"checked"];
            [item setObject:[NSString stringWithFormat:@"%i",i] forKey:@"sitWeekValue"];
            [item setObject:[startTime objectAtIndex:index] forKey:@"sitPointStartTime"];
            [item setObject:[endTime objectAtIndex:index] forKey:@"sitPointEndTime"];
        }else{
            [item setObject:@(NO) forKey:@"checked"];
            [item setObject:[NSString stringWithFormat:@"%i",i] forKey:@"sitWeekValue"];
            [item setObject:@"00:00" forKey:@"sitPointStartTime"];
            [item setObject:@"23:59" forKey:@"sitPointEndTime"];
        }
        
        model = [TimeTypeModel initWithDataSource:item];
        [self.dataSource addObject:model];
    }
}

///判断当前星期是否已选中  选中则返回其下标  否则返回-1
-(NSInteger)jugdeWeekIsSelected:(NSInteger)weekFlag{
    NSInteger selectedIndex = -1;
   NSString *timeTypeOld = @"";
    if ([self.navigationOrSit isEqualToString:@"sit"]) {
        if ([self.timeStrategyData objectForKey:@"appointTimeWeek"]) {
            NSArray *appointTimeWeek = [self.timeStrategyData objectForKey:@"appointTimeWeek"];
            NSInteger count = 0;
            if (appointTimeWeek) {
                count = [appointTimeWeek count];
            }
            BOOL isSelected = FALSE;
            for (int i=0; !isSelected && i<count; i++) {
                if ([[appointTimeWeek objectAtIndex:i] integerValue] == weekFlag) {
                    selectedIndex = i;
                    isSelected = TRUE;
                }
            }
            return selectedIndex;
        }else{
            return -1;
        }
    }else{
        timeTypeOld = @"2";
        BOOL isNew = TRUE;
        if ([self.timeStrategyData safeObjectForKey:@"timeType"].length > 0) {
            if([[self.timeStrategyData safeObjectForKey:@"timeType"] integerValue] == [timeTypeOld integerValue]){
                isNew = TRUE;
            }else{
                isNew = FALSE;
            }
        }else{
            isNew = TRUE;
        }
        
        if ([self.timeStrategyData objectForKey:@"appointTimeWeek"] && isNew) {
            
            NSArray *appointTimeWeek = [self.timeStrategyData objectForKey:@"appointTimeWeek"];
            NSInteger count = 0;
            if (appointTimeWeek) {
                count = [appointTimeWeek count];
            }
            BOOL isSelected = FALSE;
            for (int i=0; !isSelected && i<count; i++) {
                if ([[appointTimeWeek objectAtIndex:i] integerValue] == weekFlag) {
                    selectedIndex = i;
                    isSelected = TRUE;
                }
            }
            return selectedIndex;
        }else{
            return -1;
        }
    }
}


///获取周期文本信息
-(NSString *)getWeekNameByFlag:(NSInteger)flag{
    NSString *weekName = @"";
    switch (flag) {
        case 1:
            weekName = @"周一";
            break;
        case 2:
            weekName = @"周二";
            break;
        case 3:
            weekName = @"周三";
            break;
        case 4:
            weekName = @"周四";
            break;
        case 5:
            weekName = @"周五";
            break;
        case 6:
            weekName = @"周六";
            break;
        case 7:
            weekName = @"周日";
            break;
            
        default:
            break;
    }
    return weekName;
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
    
    if(![self getSelectedWeek]){
        [CommonFuntion showToast:@"至少选择一天" inView:self.view];
        return;
    }
    
    ///需判断时间策略范围
    if ([self.flagOfNeedJudge isEqualToString:@"yes"]) {
        ///判断是否在导航时间策略范围内
        if ([self.navigationOrSit isEqualToString:@"sit"]) {
            if (![self judgeSelectedTimeStrategy]) {
                return;
            }
        }
    }
    
    
    NSLog(@"appointTimeWeekNew:%@",appointTimeWeekNew);
    NSLog(@"startTimeNew:%@",startTimeNew);
    NSLog(@"endTimeNew:%@",endTimeNew);
    if (self.SelectDateTimeDoneBlock) {
        self.SelectDateTimeDoneBlock(appointTimeWeekNew,startTimeNew,endTimeNew);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - 座席时间范围判断

-(BOOL)isValidTimeDateSelected:(NSArray *)selectedArr andNavTimeArr:(NSArray *)navTimeArr{
    ///已选择的时间
    NSInteger countSelected = 0;
    if (selectedArr) {
        countSelected = [selectedArr count];
    }
    ///导航时间
    NSInteger countNavTime = 0;
    if (navTimeArr) {
        countNavTime = [navTimeArr count];
    }
    
//    TimeRangeModel *model;
//    for (int j=0; j<[navTimeArr count]; j++) {
//        model = (TimeRangeModel*)[navTimeArr objectAtIndex:j];
//        NSLog(@"nav week:%@ start:%@ end:%@",model.weekValue,model.weekStartTime,model.weekEndTime);
//    }
//    
//    for (int j=0; j<[selectedArr count]; j++) {
//        model = (TimeRangeModel*)[selectedArr objectAtIndex:j];
//        NSLog(@"selected week:%@ start:%@ end:%@",model.weekValue,model.weekStartTime,model.weekEndTime);
//    }

    BOOL isExist = FALSE;
    TimeRangeModel *modeSelect;
    TimeRangeModel *modeNavTime;
    ///遍历已选择的时间 判断其是否包含在导航时间范围内
    for (int i=0; i<countSelected; i++) {
        modeSelect = (TimeRangeModel *)[selectedArr objectAtIndex:i];
        
        isExist = FALSE;
        ///遍历导航时间
        for (int k=0; k<countNavTime; k++) {
            modeNavTime = (TimeRangeModel *)[navTimeArr objectAtIndex:k];
            ///先判断所选择的星期几在不在导航范围内
            if ([modeSelect.weekValue isEqualToString:modeNavTime.weekValue]) {
                NSLog(@"weekValue :%@",modeSelect.weekValue);
                isExist = TRUE;
                ///存在的话 判断开始时间和结束时间是不是在导航范围内

                if ([modeSelect.weekStartTime compare:modeNavTime.weekStartTime] == -1 ) {
                    [CommonFuntion showToast:[NSString stringWithFormat:@"%@开始时间不在分组时间策略范围内",[self getWeekNameByFlag:[modeSelect.weekValue integerValue]]] inView:self.view];
                    return FALSE;
                }
                if ([modeSelect.weekEndTime compare:modeNavTime.weekEndTime] > 0) {
                    [CommonFuntion showToast:[NSString stringWithFormat:@"%@结束时间不在分组时间策略范围内",[self getWeekNameByFlag:[modeSelect.weekValue integerValue]]] inView:self.view];
                    return FALSE;
                }
            }
        }
        
        ///在导航时间内不在当前选择的星期几
        if (!isExist) {
            [CommonFuntion showToast:[NSString stringWithFormat:@"%@不在分组时间策略范围内",[self getWeekNameByFlag:[modeSelect.weekValue integerValue]]] inView:self.view];
            return FALSE;
        }
        
    }
    return TRUE;
}

///通过导航行情 根据导航时间策略类型 获取到导航时间策略对应的时间数组
///并判断所选时间是否在导航时间范围内
-(BOOL)judgeSelectedTimeStrategy{
    ///导航时间
    NSArray *timeZoneNavigation ;
    ///3节假日  2星期  1全部
    NSString *timeType = [self.timeStrategyNavDic safeObjectForKey:@"timeType"];
    NSLog(@"timeType:%@",timeType);
    if ([timeType integerValue] == 3) {
        NSString *sTime = @"";
        NSString *eTime = @"";
        if ([self.timeStrategyNavDic objectForKey:@"startTime"] && [[self.timeStrategyNavDic objectForKey:@"startTime"] count] > 0) {
            sTime = [[self.timeStrategyNavDic objectForKey:@"startTime"] objectAtIndex:0];
        }
        
        if ([self.timeStrategyNavDic objectForKey:@"endTime"] && [[self.timeStrategyNavDic objectForKey:@"endTime"] count] > 0) {
            eTime = [[self.timeStrategyNavDic objectForKey:@"endTime"] objectAtIndex:0];
        }
        
//        NSLog(@"sTime:%@",sTime);
//        NSLog(@"eTime:%@",eTime);
        
        //2015-10-11
        timeZoneNavigation = [self transDateToWeekFormatByStrBeginDate:sTime andStrEndDate:eTime];
    }else if ([timeType integerValue] == 2){
        
        NSLog(@"星期类型");
        NSArray *startTime = [self.timeStrategyNavDic objectForKey:@"startTime"];
        NSArray *endTime = [self.timeStrategyNavDic objectForKey:@"endTime"];
        NSArray *appointTimeWeek = [self.timeStrategyNavDic objectForKey:@"appointTimeWeek"];
        
         timeZoneNavigation = [self transDateToWeekFormatByWeekArray:appointTimeWeek andStartTime:startTime andEndTime:endTime];
    }else{
        return TRUE;
    }
    
    ///已选择的时间
    NSArray *timeZoneSelected = [self transDateToWeekFormatByWeekArray:appointTimeWeekNew andStartTime:startTimeNew andEndTime:endTimeNew];
    
    return [self isValidTimeDateSelected:timeZoneSelected andNavTimeArr:timeZoneNavigation];
}

///将节假日日期转换为（星期几：开始时间：结束时间）（周日是“1”，周一是“2” ...）
-(NSArray *)transDateToWeekFormatByStrBeginDate:(NSString *)strBeginDate andStrEndDate:(NSString *)strEndDate{
    NSString *strBeginYMD = [strBeginDate substringToIndex:10];
    NSString *strEndYMD = [strEndDate substringToIndex:10];
    
    NSDate *beginDate = [CommonFunc stringToDate:strBeginYMD Format:@"yyyy-MM-dd"];
    NSDate *endDate = [CommonFunc stringToDate:strEndYMD Format:@"yyyy-MM-dd"];
//    NSLog(@"strBeginDate:%@ \n beginDate:%@",strBeginDate,beginDate);
//    NSLog(@"strEndDate:%@ \n endDate:%@",strEndDate,endDate);
    
    NSDate *bDate = beginDate;
    NSMutableArray *allWeekDays = [[NSMutableArray alloc] init];
    
    TimeRangeModel *model ;
    int i=0;
    for (;[bDate compare:endDate] <= 0 && i<7; ) {
//        NSLog(@"bDate:%@",bDate);
        model = [[TimeRangeModel alloc] init];
        ///根据日期 获取其对应的星期几 周日是“1”，周一是“2”
        NSInteger weekValue = [CommonFunc getWeekdayTagWithDate:bDate];
        ///星期几
        model.weekValue = [NSString stringWithFormat:@"%ti",[self transWeekValueToFormatValue:weekValue]];
        ///开始时间 ///结束时间
        if (i==0) {
            model.weekStartTime = [strBeginDate substringFromIndex:11];
        }else{
            model.weekStartTime = @"00:00";
        }
        model.weekEndTime = @"23:59";
        
        [allWeekDays addObject:model];
        bDate = [bDate dateByAddingDays:1];
        i++;
    }
    
    if (i<=6) {
        ///填补结束时间
        TimeRangeModel *model = [allWeekDays lastObject];
        model.weekEndTime = [strEndDate substringFromIndex:11];
    }
    
    
//    for (int j=0; j<[allWeekDays count]; j++) {
//        model = (TimeRangeModel*)[allWeekDays objectAtIndex:j];
//        NSLog(@"week:%@ start:%@ end:%@",model.weekValue,model.weekStartTime,model.weekEndTime);
//    }
    return allWeekDays;
}


///转换星期几对应的数值
-(NSInteger)transWeekValueToFormatValue:(NSInteger)value{
    ///周日是“1”，周一是“2”
    NSInteger valueNew = 1;
    switch (value) {
        case 1:
            valueNew = 7;
            break;
        case 2:
            valueNew = 1;
            break;
        case 3:
            valueNew = 2;
            break;
        case 4:
            valueNew = 3;
            break;
        case 5:
            valueNew = 4;
            break;
        case 6:
            valueNew = 5;
            break;
        case 7:
            valueNew = 6;
            break;
            
        default:
            break;
    }
    return valueNew;
}

///将星期时间转换为 （星期几：开始时间：结束时间）
-(NSArray *)transDateToWeekFormatByWeekArray:(NSArray *)appointTimeWeek andStartTime:(NSArray *)startTime andEndTime:(NSArray *)endTime{
    NSLog(@"transDateToWeekFormatByWeekArray--0->");
    NSInteger countWeek = 0;
    if (appointTimeWeek) {
        countWeek = [appointTimeWeek count];
    }
    NSLog(@"appointTimeWeek:%@",appointTimeWeek);
    NSLog(@"startTime:%@",startTime);
    NSLog(@"endTime:%@",endTime);
    if (!appointTimeWeek || !startTime || !endTime ||[startTime count] != countWeek || [endTime count] != countWeek ||[startTime count] != [endTime count]) {
        return nil;
    }
    NSLog(@"transDateToWeekFormatByWeekArray-1->");
   NSMutableArray *allWeekDays = [[NSMutableArray alloc] init];
    TimeRangeModel *model ;
    for (int i=0; i<countWeek; i++) {
        model = [[TimeRangeModel alloc] init];
        model.weekValue = [NSString stringWithFormat:@"%ti",[[appointTimeWeek objectAtIndex:i] integerValue]];
        model.weekStartTime = [startTime objectAtIndex:i];
        model.weekEndTime = [endTime objectAtIndex:i];
        [allWeekDays addObject:model];
    }
    
//    for (int j=0; j<[allWeekDays count]; j++) {
//        model = (TimeRangeModel*)[allWeekDays objectAtIndex:j];
//        NSLog(@"week:%@ start:%@ end:%@",model.weekValue,model.weekStartTime,model.weekEndTime);
//    }
    
    return allWeekDays;
}




#pragma mark - 获取选中的星期时间
-(BOOL)getSelectedWeek{
    [appointTimeWeekNew removeAllObjects];
    [startTimeNew removeAllObjects];
    [endTimeNew removeAllObjects];
    
    TimeTypeModel *model;
    BOOL isChecked = FALSE;
    for (int i=0; i<7; i++) {
        model = [self.dataSource objectAtIndex:i];
        ///选中的星期时间
        if (model.checked) {
            ///标记至少选择了一天
            isChecked = TRUE;
            
            [appointTimeWeekNew addObject:model.sitWeekValue];
            [startTimeNew addObject:model.sitPointStartTime];
            [endTimeNew addObject:model.sitPointEndTime];
        }
    }
    
    NSLog(@"appointTimeWeekNew:%@",appointTimeWeekNew);
    NSLog(@"startTimeNew:%@",startTimeNew);
    NSLog(@"endTimeNew:%@",endTimeNew);
    return  isChecked;
}



#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-64) style:UITableViewStyleGrouped];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.sectionFooterHeight = 0;
    [self.view addSubview:self.tableview];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableview setTableFooterView:v];
}



#pragma mark - tableview delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0)
         return 20;
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 20;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.dataSource) {
        return [self.dataSource count];
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SelectTimeTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectTimeTypeCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SelectTimeTypeCell" owner:self options:nil];
        cell = (SelectTimeTypeCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
        
    }
    
    TimeTypeModel *item = [self.dataSource objectAtIndex:indexPath.section];
    
    [cell setCellDetails:item andIndexPath:indexPath];
    
    __weak typeof(self) weak_self = self;
    cell.CheckBoxBlock = ^(NSInteger index){
        NSLog(@"CheckBoxBlock index:%ti",index);
        [weak_self updateDataSourceByWeek:index];
    };
    
    cell.StartTimeBlock = ^(NSInteger index){
        NSLog(@"StartTimeBlock index:%ti",index);
        [weak_self selectStartTime:index];
    };
    
    
    cell.EndTimeBlock = ^(NSInteger index){
        NSLog(@"EndTimeBlock index:%ti",index);
        [weak_self selectEndTime:index];
    };
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark - 选择开始时间
-(void)selectStartTime:(NSInteger)section{
    __weak typeof(self) weak_self = self;
    NSDate *date = [NSDate date];
    //    date = [NSDate setOneDate:date Hour:0 Minute:0];
    
    LLCenterPickerView *llsheet = [[LLCenterPickerView alloc]initWithCurDate:date andMinDate:nil headTitle:@"开始时间" dateType:0];
    llsheet.selectedDateBlock = ^(NSString *time,NSDate *date){
        NSLog(@"-----time:%@",time);
        NSString *startTime = @"";
        if (time == nil) {
            NSDate *dateNow = [NSDate date];
            NSTimeZone *zone = [NSTimeZone systemTimeZone];
            NSInteger interval = [zone secondsFromGMTForDate: dateNow];
            minDate = [dateNow  dateByAddingTimeInterval: interval];
            startTime = [CommonFunc dateToString:minDate Format:@"HH:mm"];
        }else{
            startTime = time;
            minDate = date;
        }
        /*
        TimeTypeModel *model = [self.dataSource objectAtIndex:section];
        if ([startTime compare:model.sitPointEndTime] == 1) {
            [CommonFuntion showToast:@"开始时间不能大于结束时间" inView:self.view];
            return;
        }else{
            [weak_self updateDataSourceTime:section time:startTime withFalg:@"start"];
        }
        */
        [weak_self updateDataSourceTime:section time:startTime withFalg:@"start"];
        
    };
    [llsheet showInView:nil];
}


#pragma mark - 选择结束时间
///结束时间  HH:mm
-(void)selectEndTime:(NSInteger)section{
    __weak typeof(self) weak_self = self;
    
    LLCenterPickerView *llsheet;
    /*
    if (minDate == nil) {
        NSDate *date = [NSDate date];
//        date = [NSDate setOneDate:date Hour:0 Minute:0];
        llsheet = [[LLCenterPickerView alloc]initWithCurDate:date andMinDate:nil headTitle:@"结束时间" dateType:0];
    }else{
        NSLog(@"minDate:%@",minDate);
        llsheet = [[LLCenterPickerView alloc]initWithCurDate:minDate andMinDate:minDate headTitle:@"结束时间" dateType:0];
    }
    */
    
    NSDate *date = [NSDate date];
    //        date = [NSDate setOneDate:date Hour:0 Minute:0];
    llsheet = [[LLCenterPickerView alloc]initWithCurDate:date andMinDate:nil headTitle:@"结束时间" dateType:0];
    
    llsheet.selectedDateBlock = ^(NSString *time,NSDate *date){
        NSLog(@"-----time:%@",time);
        NSString *stopTime = @"";
        if (time == nil) {
            NSDate *dateNow = [NSDate date];
            NSTimeZone *zone = [NSTimeZone systemTimeZone];
            NSInteger interval = [zone secondsFromGMTForDate: dateNow];
            minDate = [dateNow  dateByAddingTimeInterval: interval];
            stopTime = [CommonFunc dateToString:minDate Format:@"HH:mm"];
        }else{
            stopTime = time;
        }
        
        /*
        TimeTypeModel *model = [self.dataSource objectAtIndex:section];
        if ([model.sitPointStartTime compare:stopTime] == 1) {
            [CommonFuntion showToast:@"开始时间不能大于结束时间" inView:self.view];
            return;
        }else{
            [weak_self updateDataSourceTime:section time:stopTime withFalg:@"end"];
        }
         */
        [weak_self updateDataSourceTime:section time:stopTime withFalg:@"end"];
        
    };
    [llsheet showInView:nil];
    
}


#pragma maek - 更新数据源
///点击星期几
-(void)updateDataSourceByWeek:(NSInteger)section{
    TimeTypeModel *model = [self.dataSource objectAtIndex:section];
    model.checked = !model.checked;
    [self.tableview reloadData];
}

///更新开始时间与结束时间  start  end
-(void)updateDataSourceTime:(NSInteger)section  time:(NSString *)time  withFalg:(NSString *)flag{
    TimeTypeModel *model = [self.dataSource objectAtIndex:section];
    if ([flag isEqualToString:@"start"]) {
        model.sitPointStartTime = time;
    }else{
        model.sitPointEndTime = time;
    }
    [self.tableview reloadData];
}



@end
