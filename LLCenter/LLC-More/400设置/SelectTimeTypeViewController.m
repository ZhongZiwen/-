//
//  SelectTimeTypeViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SelectTimeTypeViewController.h"
#import "SelectAreaTypeCell.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"
#import "CommonStaticVar.h"
#import "TimeTypeViewController.h"
#import "SelectHolidayTimeViewController.h"


@interface SelectTimeTypeViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSString *curSelectedTimeType;
    ///时间策略
    NSDictionary *timeStrategyData;
    ///编辑之后的星期数据
    NSMutableDictionary *timeStrategyDataNew;
    ///未编辑之前的时间类型
    NSString *timeModleOld ;
    
    ///节假日时间
    NSString *holidayStartTime;
    NSString *holidayEndTime;
}

@property(strong,nonatomic) UITableView *tableview;
@property(strong,nonatomic) NSMutableArray *dataSource;

@end

@implementation SelectTimeTypeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"时间类型";
    [super customBackButton];
    [self addNavBar];
    self.view.backgroundColor = COLOR_BG;
    [self initData];
    [self initTableview];
    ///获取座席时间策略
    if ([self.navigationOrSit isEqualToString:@"sit"]) {
        [self getSeatTimeStrategy];
    }else{
        timeStrategyData = self.detail;
        [self notifyDataSourceByDefaultData];
    }
    [self.tableview reloadData];
}

#pragma mark - Nav Bar
-(void)addNavBar{
    ///新建导航页面
    if ([self.viewFromFlag isEqualToString:@"addnavi"]) {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(okButtonPress)];
        self.navigationItem.rightBarButtonItem = rightButton;
    }else{
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonPress)];
        self.navigationItem.rightBarButtonItem = rightButton;
    }
}

#pragma mark-  保存事件
-(void)okButtonPress {
    [self getSelectedDateTime];
}

#pragma mark-  保存事件
-(void)saveButtonPress {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (![CommonFunc checkNetworkState]) {
        [CommonFuntion showToast:@"无网络可用,加载失败" inView:self.view];
        return;
    }
    
    
    ///导航
    if ([self.navigationOrSit isEqualToString:@"navigation"]) {
        ///全部时间1 星期时间 2  节假日3
        ///节假日
        if ([curSelectedTimeType isEqualToString:@"0"]) {
            NSString *sTime = @"";
            NSString *eTime = @"";
            
            if (holidayStartTime && holidayStartTime.length > 0 && holidayEndTime && holidayEndTime.length > 0) {
                sTime = holidayStartTime;
                eTime = holidayEndTime;
            }else{
                
                if ([timeModleOld isEqualToString:@"3"]) {
                    if ([self.detail objectForKey:@"startTime"] && [[self.detail objectForKey:@"startTime"] count] > 0) {
                        sTime = [[self.detail objectForKey:@"startTime"] objectAtIndex:0];
                    }
                    
                    if ([self.detail objectForKey:@"endTime"] && [[self.detail objectForKey:@"endTime"] count] > 0) {
                        eTime = [[self.detail objectForKey:@"endTime"] objectAtIndex:0];
                    }
                }
            }
            
            ///没选择时间
            if (!sTime || !eTime || [sTime isEqualToString:@""] || [eTime isEqualToString:@""]) {
                [CommonFuntion showToast:@"请选择日期范围" inView:self.view];
                return;
            }
            
        }else if ([curSelectedTimeType isEqualToString:@"1"]){
            
            NSString *weekAppoint = @"";
            if ([timeModleOld isEqualToString:@"2"]) {
                
            }
            
            NSDictionary *strategy = nil;
            if (timeStrategyDataNew && [timeStrategyDataNew objectForKey:@"appointTimeWeek"]) {
                strategy = timeStrategyDataNew;
            }else{

                if ([timeModleOld isEqualToString:@"2"]) {
                    strategy = timeStrategyData;
                }
            }
            
            if (strategy) {
                weekAppoint = [self getParamDataByArray:[strategy objectForKey:@"appointTimeWeek"]];
            }
            
            ///没选择时间
            if (!weekAppoint  || [weekAppoint isEqualToString:@""]) {
                [CommonFuntion showToast:@"请选择星期时间" inView:self.view];
                return;
            }
            
        }else if ([curSelectedTimeType isEqualToString:@"2"]){
            ///全部
        }
        
    }else{
         /// 星期 3   周一到周五2    全部1
        if ([curSelectedTimeType isEqualToString:@"0"]) {
           
        }else if ([curSelectedTimeType isEqualToString:@"1"]){
            NSString *weekAppoint = @"";

            NSDictionary *strategy = nil;
            if (timeStrategyDataNew && [timeStrategyDataNew objectForKey:@"appointTimeWeek"]) {
                strategy = timeStrategyDataNew;
            }else{
                if ([timeModleOld isEqualToString:@"3"]) {
                    strategy = timeStrategyData;
                }
            }
            
            NSLog(@"strategy:%@",strategy);
            if (strategy) {
                weekAppoint = [self getParamDataByArray:[strategy objectForKey:@"appointTimeWeek"]];
            }
            
            ///没选择时间
            if (!weekAppoint  || [weekAppoint isEqualToString:@""]) {
                [CommonFuntion showToast:@"请选择星期时间" inView:self.view];
                return;
            }
        }else if ([curSelectedTimeType isEqualToString:@"2"]){
            ///全部
        }
    }
    
    
    [self editSitTimeype];
}


#pragma mark - 初始化数据
-(void)initData{
    self.dataSource = [[NSMutableArray alloc] init];
    timeStrategyDataNew = [[NSMutableDictionary alloc] init];
    holidayStartTime = @"";
    holidayEndTime = @"";
    timeModleOld = @"";
    
    ///从座席信息获取到当前选择的方式
    NSMutableDictionary *item1 = [[NSMutableDictionary alloc] init];
    
    ///座席跳转而来
    if ([self.navigationOrSit isEqualToString:@"sit"]) {
        [item1 setObject:@"周一到周五" forKey:@"title"];
        [item1 setObject:@"00:00~23:59" forKey:@"content"];
        [item1 setObject:@(NO) forKey:@"checked"];
    }else{
        ///导航
        [item1 setObject:@"节假日" forKey:@"title"];
        [item1 setObject:@"" forKey:@"content"];
        [item1 setObject:@(NO) forKey:@"checked"];
    }
    
    
    NSMutableDictionary *item2 = [[NSMutableDictionary alloc] init];
    [item2 setObject:@"星期" forKey:@"title"];
    [item2 setObject:@"" forKey:@"content"];
    [item2 setObject:@(NO) forKey:@"checked"];
    
    
    NSMutableDictionary *item3 = [[NSMutableDictionary alloc] init];
    [item3 setObject:@"全部时间" forKey:@"title"];
    [item3 setObject:@"00:00~23:59" forKey:@"content"];
    [item3 setObject:@(NO) forKey:@"checked"];
    
    
    [self.dataSource addObject:item1];
    [self.dataSource addObject:item2];
    [self.dataSource addObject:item3];
}


#pragma mark - 刷新数据

///根据时间类型 和 content  刷新数据
-(void)notifyDataSoureByTimeModel:(NSString *) model andContent:(NSString *)content{
    NSLog(@"notifyDataSoureByTimeModel:%@  content:%@",model,content);
    NSDictionary *item;
    NSMutableDictionary *mutableItem;
    ///座席
    if ([self.navigationOrSit isEqualToString:@"sit"]) {
        /// 星期 3   周一到周五2    全部1

        ///全部
        if ([model integerValue] == 1) {
            item = [self.dataSource objectAtIndex:2];
            mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
            [mutableItem setObject:@(YES) forKey:@"checked"];
            [mutableItem setObject:content forKey:@"content"];
            [self.dataSource replaceObjectAtIndex:2 withObject:mutableItem];
            
            curSelectedTimeType = @"2";
        }
        ///周一到周五
        if ([model integerValue] == 2) {
            item = [self.dataSource objectAtIndex:0];
            mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
            [mutableItem setObject:@(YES) forKey:@"checked"];
            [mutableItem setObject:content forKey:@"content"];
            [self.dataSource replaceObjectAtIndex:0 withObject:mutableItem];
            
            curSelectedTimeType = @"0";
        }
        
        ///星期时间
        if ([model integerValue] == 3) {
            item = [self.dataSource objectAtIndex:1];
            mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
            [mutableItem setObject:@(YES) forKey:@"checked"];
            [mutableItem setObject:content forKey:@"content"];
            [self.dataSource replaceObjectAtIndex:1 withObject:mutableItem];
            
            curSelectedTimeType = @"1";
        }
        
        
    }else{
        ///全部时间1 星期时间 2  节假日3
        ///全部
        if ([model integerValue] == 1) {
            item = [self.dataSource objectAtIndex:2];
            mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
            [mutableItem setObject:@(YES) forKey:@"checked"];
            [mutableItem setObject:content forKey:@"content"];
            [self.dataSource replaceObjectAtIndex:2 withObject:mutableItem];
            
            curSelectedTimeType = @"2";
        }
        ///节假日
        if ([model integerValue] == 3) {
            item = [self.dataSource objectAtIndex:0];
            mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
            [mutableItem setObject:@(YES) forKey:@"checked"];
            [mutableItem setObject:content forKey:@"content"];
            [self.dataSource replaceObjectAtIndex:0 withObject:mutableItem];
            
            curSelectedTimeType = @"0";
        }
        
        ///星期时间
        if ([model integerValue] == 2) {
            item = [self.dataSource objectAtIndex:1];
            mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
            [mutableItem setObject:@(YES) forKey:@"checked"];
            [mutableItem setObject:content forKey:@"content"];
            [self.dataSource replaceObjectAtIndex:1 withObject:mutableItem];
            
            curSelectedTimeType = @"1";
        }
        
    }
    [self.tableview reloadData];
}

///刷新数据
-(void)notifyDataSourceByDefaultData{
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
    
    
    ///座席
    if ([self.navigationOrSit isEqualToString:@"sit"]) {
        /// 星期 3   周一到周五2    全部1
        timeModleOld = [timeStrategyData safeObjectForKey:@"timeModle"];
        NSString *content = @"";
        NSString *model = [timeStrategyData safeObjectForKey:@"timeModle"];
        ///全部1   ///周一到周五2
        if ([model integerValue] == 1 || [model integerValue] == 2) {
            NSString *sTime = [[timeStrategyData objectForKey:@"startTime"] objectAtIndex:0];
            NSString *eTime = [[timeStrategyData objectForKey:@"endTime"] objectAtIndex:0];
            if (sTime.length > 0 && eTime.length > 0) {
                content = [NSString stringWithFormat:@"%@~%@",sTime,eTime];
            }
            
        }
        
        ///星期时间
        if ([model integerValue] == 3) {
            content = [self getTimeTimeByXQ:[timeStrategyData objectForKey:@"appointTimeWeek"]];
        }

        [self notifyDataSoureByTimeModel:model andContent:content];
        
    }else{
        ///导航时间策略
        ///全部时间1 星期时间 2  节假日3
        
        timeModleOld = [self.detail safeObjectForKey:@"timeType"];
        NSString *content = @"";
        NSString *model = [self.detail safeObjectForKey:@"timeType"];
        ///全部1
        if ([model integerValue] == 1) {
            NSString *sTime = @"";
            NSString *eTime = @"";
            if ([self.detail objectForKey:@"startTime"] && [[self.detail objectForKey:@"startTime"] count] > 0) {
                sTime = [[self.detail objectForKey:@"startTime"] objectAtIndex:0];
            }
            
            if ([self.detail objectForKey:@"endTime"] && [[self.detail objectForKey:@"endTime"] count] > 0) {
                eTime = [[self.detail objectForKey:@"endTime"] objectAtIndex:0];
            }
            if (sTime.length > 0 && eTime.length > 0) {
                content = [NSString stringWithFormat:@"%@~%@",sTime,eTime];
            }
            
        }
        
        ///节假日3
        if ([model integerValue] == 3) {
            NSString *sTime = @"";
            NSString *eTime = @"";
            if ([self.detail objectForKey:@"startTime"] && [[self.detail objectForKey:@"startTime"] count] > 0) {
                sTime = [[self.detail objectForKey:@"startTime"] objectAtIndex:0];
            }
            
            if ([self.detail objectForKey:@"endTime"] && [[self.detail objectForKey:@"endTime"] count] > 0) {
                eTime = [[self.detail objectForKey:@"endTime"] objectAtIndex:0];
            }
            
            holidayStartTime = sTime;
            holidayEndTime = eTime;
            
            if (sTime.length > 0 && eTime.length > 0) {
                content = [NSString stringWithFormat:@"%@~%@",sTime,eTime];
            }
        }
        
        
        if ([model integerValue] == 2) {
            ///星期时间
            content = [self getTimeTimeByXQ:[self.detail objectForKey:@"appointTimeWeek"]];
        }
        
        [self notifyDataSoureByTimeModel:model andContent:content];
        
    }
}

///根据星期 获取其对应的文本
-(NSString *)getTimeTimeByXQ:(NSArray *)arrWeek{
    NSInteger count = 0;
    if (arrWeek) {
        count = [arrWeek count];
    }
    
    ///对星期做排序
    NSArray *resultkArrSortWeek = [arrWeek sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        return [[NSString stringWithFormat:@"%ti",[obj1 integerValue]] compare:[NSString stringWithFormat:@"%ti",[obj2 integerValue]]];
    }];
     
    
    NSMutableString *strWeekValue = [[NSMutableString alloc] init];
    NSString *week = @"";
    for (int i=0; i<count; i++) {
        NSInteger weekFlag = [[resultkArrSortWeek objectAtIndex:i] integerValue];
        switch (weekFlag) {
            case 1:
                week = @"周一";
                break;
            case 2:
                week = @"周二";
                break;
            case 3:
               week = @"周三";
                break;
            case 4:
                week = @"周四";
                break;
            case 5:
               week = @"周五";
                break;
            case 6:
                week = @"周六";
                break;
            case 7:
                week = @"周日";
                break;
                
            default:
                break;
        }
        
        
        if ([strWeekValue isEqualToString:@""]) {
            [strWeekValue appendString:week];
        }else{
            [strWeekValue appendString:@","];
            [strWeekValue appendString:week];
        }
    }
    
    return strWeekValue;
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
    
    ///需提示时间策略范围
    if ([self.flagOfNeedJudge isEqualToString:@"yes"]) {
        self.tableview.tableHeaderView = [self creatHeadViewForTableView];
    }
    
}


#pragma mark - 创建HeadView
-(UIView *)creatHeadViewForTableView{
    UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 40)];
    headview.backgroundColor = COLOR_BG;
    

    UILabel *labelNotice = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, DEVICE_BOUNDS_WIDTH-30, 20)];
    labelNotice.textColor = [UIColor grayColor];
    labelNotice.font = [UIFont systemFontOfSize:13.0];
    labelNotice.text = @"时间策略设置请在分组时间范围内,超出不会生效";
    
    [headview addSubview:labelNotice];
    
    return headview;
}

#pragma mark - tableview delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    ///需提示时间策略范围
    if ([self.flagOfNeedJudge isEqualToString:@"yes"]) {
        return 1;
    }
    return 20;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.dataSource) {
        return [self.dataSource count];
    }
    return 0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ///座席
    SelectAreaTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectAreaTypeCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SelectAreaTypeCell" owner:self options:nil];
        cell = (SelectAreaTypeCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
        [cell setCellFrame:1];
    }
    NSDictionary *item = [self.dataSource objectAtIndex:indexPath.row];
    
    [cell setCellDetail:item];
    
    if (indexPath.row == 0) {
        ///座席
        if ([self.navigationOrSit isEqualToString:@"sit"]) {
            cell.imgArrow.hidden = YES;
        }else{
            ///导航
            cell.imgArrow.hidden = NO;
        }
    }else if (indexPath.row == 1){
        cell.imgArrow.hidden = NO;
    }else if (indexPath.row == 2){
        cell.imgArrow.hidden = YES;
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self updateDataSource:indexPath.row];
    if (indexPath.row == 0) {
        ///座席
        if ([self.navigationOrSit isEqualToString:@"sit"]) {
        }else{
            [self gotoHolidayTimeView];
        }
    }else if(indexPath.row == 1){
        [self gotoCustomeTimeTypeView];
    }else if (indexPath.row == 2){
        
    }
}


///节假日
-(void)gotoHolidayTimeView{
    SelectHolidayTimeViewController *controller = [[SelectHolidayTimeViewController alloc] init];
    controller.holidayStartTime = holidayStartTime;
    controller.holidayEndTime = holidayEndTime;
    __weak typeof(self) weak_self = self;
    controller.SelectDateTimeDoneBlock = ^(NSString *sTime,NSString *eTime){
        NSLog(@"sTime:%@",sTime);
        NSLog(@"eTime:%@",eTime);
        holidayStartTime = sTime;
        holidayEndTime = eTime;
        ///节假日
        NSString *content = [NSString stringWithFormat:@"%@~%@",holidayStartTime,holidayEndTime];
        [weak_self notifyDataSoureByTimeModel:@"3" andContent:content];
        
    };
    [self.navigationController pushViewController:controller animated:YES];
}


///跳转到时间页面
-(void)gotoCustomeTimeTypeView{
    TimeTypeViewController *controller = [[TimeTypeViewController alloc] init];
    controller.navigationOrSitId = self.navigationId;
    controller.arrayDefaultTime = self.arrayDefaultTime;
    controller.navigationOrSit = self.navigationOrSit;
    controller.flagOfNeedJudge = self.flagOfNeedJudge;

    if ([self.navigationOrSit isEqualToString:@"sit"]) {
        controller.timeStrategyNavDic = self.timeStrategyNavDic;
        if (timeStrategyDataNew && [timeStrategyDataNew objectForKey:@"appointTimeWeek"]) {
            controller.timeStrategyData = timeStrategyDataNew;
        }else{
            controller.timeStrategyData = timeStrategyData;
        }
    }else{
        if (timeStrategyDataNew && [timeStrategyDataNew objectForKey:@"appointTimeWeek"]) {
            controller.timeStrategyData = timeStrategyDataNew;
        }else{
            controller.timeStrategyData = self.detail;
        }
    }
    
    __weak typeof(self) weak_self = self;
    controller.SelectDateTimeDoneBlock = ^(NSArray *appointTime,NSArray *startTime,NSArray *endTime){
        
        if ([curSelectedTimeType isEqualToString:@"0"]) {
            
        }else{
            
        }
        
        [timeStrategyDataNew setObject:appointTime forKey:@"appointTimeWeek"];
        [timeStrategyDataNew setObject:startTime forKey:@"startTime"];
        [timeStrategyDataNew setObject:endTime forKey:@"endTime"];
        
        ///星期时间
        NSString *content = [weak_self getTimeTimeByXQ:appointTime];
        
        if ([self.navigationOrSit isEqualToString:@"sit"]) {
            [weak_self notifyDataSoureByTimeModel:@"3" andContent:content];
        }else{
            [weak_self notifyDataSoureByTimeModel:@"2" andContent:content];
        }
        
        
    };
    
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - 更新UI 修改数据源
-(void)updateDataSource:(NSInteger)index{
    BOOL isRequest = FALSE;
    NSDictionary *item;
    NSMutableDictionary *mutableItem;
    item = [self.dataSource objectAtIndex:index];
    if (index == 0) {
        if (![[item objectForKey:@"checked"] boolValue]) {
            mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
            [mutableItem setObject:@(YES) forKey:@"checked"];
            [self.dataSource replaceObjectAtIndex:0 withObject:mutableItem];
            
        }
        
        item = [self.dataSource objectAtIndex:1];
        mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
        [mutableItem setObject:@(NO) forKey:@"checked"];
        [self.dataSource replaceObjectAtIndex:1 withObject:mutableItem];
        
        item = [self.dataSource objectAtIndex:2];
        mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
        [mutableItem setObject:@(NO) forKey:@"checked"];
        [self.dataSource replaceObjectAtIndex:2 withObject:mutableItem];
        
        curSelectedTimeType = @"0";
        
    }else if (index == 1) {
        if (![[item objectForKey:@"checked"] boolValue]) {
            mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
            [mutableItem setObject:@(YES) forKey:@"checked"];
            [self.dataSource replaceObjectAtIndex:1 withObject:mutableItem];
        }
        
        item = [self.dataSource objectAtIndex:0];
        mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
        [mutableItem setObject:@(NO) forKey:@"checked"];
        [self.dataSource replaceObjectAtIndex:0 withObject:mutableItem];
        
        item = [self.dataSource objectAtIndex:2];
        mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
        [mutableItem setObject:@(NO) forKey:@"checked"];
        [self.dataSource replaceObjectAtIndex:2 withObject:mutableItem];
        
        curSelectedTimeType = @"1";
    }else if (index == 2) {
        if (![[item objectForKey:@"checked"] boolValue]) {
            mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
            [mutableItem setObject:@(YES) forKey:@"checked"];
            [self.dataSource replaceObjectAtIndex:2 withObject:mutableItem];
            
        }
        
        item = [self.dataSource objectAtIndex:0];
        mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
        [mutableItem setObject:@(NO) forKey:@"checked"];
        [self.dataSource replaceObjectAtIndex:0 withObject:mutableItem];
        
        item = [self.dataSource objectAtIndex:1];
        mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
        [mutableItem setObject:@(NO) forKey:@"checked"];
        [self.dataSource replaceObjectAtIndex:1 withObject:mutableItem];
        curSelectedTimeType = @"2";
        isRequest = TRUE;
    }
    
    [self.tableview reloadData];
}


#pragma mark - 网络请求

#pragma mark - 初始座席时间策略
#pragma mark 获取座席时间策略
-(void)getSeatTimeStrategy{

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rDict setValue:self.navigationId forKey:@"navigationId"];
    [rDict setValue:[self.detail safeObjectForKey:@"SITID"] forKey:@"sitId"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    
    NSLog(@"rParam:%@",rParam);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_SEAT_TIME_STRATEGY_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"时间策略jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            if ([jsonResponse objectForKey:@"resultMap"]) {
                timeStrategyData = [jsonResponse objectForKey:@"resultMap"];
                NSLog(@"timeModleName:%@",[timeStrategyData safeObjectForKey:@"timeModleName"]);
                
                [self notifyDataSourceByDefaultData];
                
            }else{
                NSLog(@"data------>:<null>");
                [CommonFuntion showToast:@"加载异常" inView:self.view];
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getSeatTimeStrategy];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
    
}

///根据数据获取参数格式 ,分割
-(NSString *)getParamDataByArray:(NSArray *)dataArray{
    NSLog(@"getParamDataByArray dataArray:%@",dataArray);
    NSInteger count = 0;
    if (dataArray) {
        count = [dataArray count];
    }
    NSMutableString *strParamValue = [[NSMutableString alloc] init];
    for (int i=0; i<count; i++) {
        if ([strParamValue isEqualToString:@""]) {
            [strParamValue appendString:[NSString stringWithFormat:@"%@",[dataArray objectAtIndex:i]]];
        }else{
            [strParamValue appendString:@","];
            [strParamValue appendString:[NSString stringWithFormat:@"%@",[dataArray objectAtIndex:i] ]];
        }
    }
    NSLog(@"getParamDataByArray strParamValue :%@",strParamValue);
    return strParamValue;
}

#pragma mark - 保存时间策略
-(void)editSitTimeype{
    /*
     sitId
     sitTimeType
     sitWeek
     sitPointStartTime
     sitPointEndTime
     */
    
    NSLog(@"editSitTimeype---->");
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    
    NSString *urlString = @"";
    ///导航
    if ([self.navigationOrSit isEqualToString:@"navigation"]) {
        urlString = LLC_EDIT_NAVIGATION_TIME_ACTION;
        ///全部时间1 星期时间 2  节假日3
        
        [rDict setValue:self.navigationId forKey:@"navigationId"];
        
#warning 这里修改了timeType的值 其他部分未做修改
        NSString *timeType = @"1";
        if ([curSelectedTimeType isEqualToString:@"0"]) {
            timeType = @"3";
        }else if ([curSelectedTimeType isEqualToString:@"1"]) {
            timeType = @"2";
        }else if ([curSelectedTimeType isEqualToString:@"2"]) {
            timeType = @"1";
        }
        
        [rDict setValue:timeType forKey:@"navigationTimeType"];
        ///节假日
        if ([curSelectedTimeType isEqualToString:@"0"]) {
            [rDict setValue:@"" forKey:@"navigationWeek"];
            
            if (holidayStartTime && holidayStartTime.length > 0) {
                [rDict setValue:holidayStartTime forKey:@"navigationPointStartTime"];
                [rDict setValue:holidayEndTime forKey:@"navigationPointEndTime"];
            }else{
                NSString *sTime = @"";
                NSString *eTime = @"";
                if ([self.detail objectForKey:@"startTime"] && [[self.detail objectForKey:@"startTime"] count] > 0) {
                    sTime = [[self.detail objectForKey:@"startTime"] objectAtIndex:0];
                }
                
                if ([self.detail objectForKey:@"endTime"] && [[self.detail objectForKey:@"endTime"] count] > 0) {
                    eTime = [[self.detail objectForKey:@"endTime"] objectAtIndex:0];
                }
                [rDict setValue:sTime forKey:@"navigationPointStartTime"];
                [rDict setValue:eTime forKey:@"navigationPointEndTime"];
            }
            
        }else if ([curSelectedTimeType isEqualToString:@"1"]){
            NSDictionary *strategy = timeStrategyData;
            if (timeStrategyDataNew && [timeStrategyDataNew objectForKey:@"appointTimeWeek"]) {
                strategy = timeStrategyDataNew;
            }
            ///星期
            [rDict setValue:[self getParamDataByArray:[strategy objectForKey:@"appointTimeWeek"]] forKey:@"navigationWeek"];
            [rDict setValue:[self getParamDataByArray:[strategy objectForKey:@"startTime"]] forKey:@"navigationPointStartTime"];
            [rDict setValue:[self getParamDataByArray:[strategy objectForKey:@"endTime"]] forKey:@"navigationPointEndTime"];
        }else if ([curSelectedTimeType isEqualToString:@"2"]){
            ///全部
            [rDict setValue:@"" forKey:@"navigationWeek"];
            [rDict setValue:@"" forKey:@"navigationPointStartTime"];
            [rDict setValue:@"" forKey:@"navigationPointEndTime"];
        }
        
    }else{
        NSLog(@"editSitTimeype---sit->");
        ///座席
        urlString = LLC_EDIT_NAVIGATION_SIT_TIME_ACTION;
        [rDict setValue:self.navigationId forKey:@"navigationId"];
        [rDict setValue:[self.detail safeObjectForKey:@"SITID"] forKey:@"sitId"];
        
#warning 这里修改了timeType的值 其他部分未做修改
        ///周一至周五2  星期3  全部1
        NSString *timeType = @"1";
        if ([curSelectedTimeType isEqualToString:@"0"]) {
            timeType = @"2";
        }else if ([curSelectedTimeType isEqualToString:@"1"]) {
            timeType = @"3";
        }else if ([curSelectedTimeType isEqualToString:@"2"]) {
            timeType = @"1";
        }
        
        [rDict setValue:timeType forKey:@"sitTimeType"];
        ///座席时间类型（0-周一到周五，1-星期，2-全部）
        ///周一到周五
        if ([curSelectedTimeType isEqualToString:@"0"]) {
            [rDict setValue:@"1,2,3,4,5" forKey:@"sitWeek"];
            [rDict setValue:@"00:00" forKey:@"sitPointStartTime"];
            [rDict setValue:@"23:59" forKey:@"sitPointEndTime"];
        }else if ([curSelectedTimeType isEqualToString:@"1"]){
            NSDictionary *strategy = timeStrategyData;
            if (timeStrategyDataNew && [timeStrategyDataNew objectForKey:@"appointTimeWeek"]) {
                strategy = timeStrategyDataNew;
            }
            
            [rDict setValue:[self getParamDataByArray:[strategy objectForKey:@"appointTimeWeek"]] forKey:@"sitWeek"];
            [rDict setValue:[self getParamDataByArray:[strategy objectForKey:@"startTime"]] forKey:@"sitPointStartTime"];
            [rDict setValue:[self getParamDataByArray:[strategy objectForKey:@"endTime"]] forKey:@"sitPointEndTime"];
        }else if ([curSelectedTimeType isEqualToString:@"2"]){
            [rDict setValue:@"" forKey:@"sitWeek"];
            [rDict setValue:@"" forKey:@"sitPointStartTime"];
            [rDict setValue:@"" forKey:@"sitPointEndTime"];
        }
        ///流水号
        [rDict setValue:[self.detail safeObjectForKey:@"LSH"] forKey:@"lsh"];
    }

    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,urlString] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"全部时间jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [CommonFuntion showToast:@"保存成功" inView:self.view];
            [self actionSuccess];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self editSitTimeype];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"保存失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];

}


#pragma mark - 新建导航时时间类型
-(void)getSelectedDateTime{
    
    /*
     {
     desc = "<null>";
     resultMap =     {
     answerStrategy = 0;
     answerStrategyDesc = "";
     appointTimeWeek =         (
     1
     );
     areaCode = 1;
     areaName = "<null>";
     areaType = "<null>";
     childNavigationHasChildDesc = "\U53ef\U4ee5\U65b0\U589e";
     childNavigationKeyLength = 1;
     endTime =         (
     "23:59"
     );
     maxLevel = 10;
     navigationHasChild = 0;
     navigationId = 4008290377;
     navigationKey = "<null>";
     navigationLevel = 0;
     navigationName = 4008290377;
     navigationRingId = 116909264;
     navigationRingName = "backgroud.wav";
     navigationRingUrl = "http://www.sungoin.cn//voices/temp/rings/4008290377/2015080317465798.mp3";
     navigationType = 0;
     navigationsetChild = 1;
     sitRingId = "<null>";
     sitRingName = "<null>";
     startTime =         (
     "00:00"
     );
     timeType = 1;
     };
     status = 1;
     }
     
     */
    
    
    
//    [self.detail safeObjectForKey:@"timeType"];
    
    
    
    ///全部时间1 星期时间 2  节假日3
    ///节假日
    if ([curSelectedTimeType isEqualToString:@"0"]) {
        NSString *sTime = @"";
        NSString *eTime = @"";
        
        if (holidayStartTime && holidayStartTime.length > 0 && holidayEndTime && holidayEndTime.length > 0) {
            sTime = holidayStartTime;
            eTime = holidayEndTime;
        }else{
            
            if ([timeModleOld isEqualToString:@"3"]) {
                if ([self.detail objectForKey:@"startTime"] && [[self.detail objectForKey:@"startTime"] count] > 0) {
                    sTime = [[self.detail objectForKey:@"startTime"] objectAtIndex:0];
                }
                
                if ([self.detail objectForKey:@"endTime"] && [[self.detail objectForKey:@"endTime"] count] > 0) {
                    eTime = [[self.detail objectForKey:@"endTime"] objectAtIndex:0];
                }
            }
        }
        
        ///没选择时间
        if (!sTime || !eTime || [sTime isEqualToString:@""] || [eTime isEqualToString:@""]) {
            [CommonFuntion showToast:@"请选择日期范围" inView:self.view];
            return;
        }
        
    }else if ([curSelectedTimeType isEqualToString:@"1"]){
        
        NSString *weekAppoint = @"";
        if ([timeModleOld isEqualToString:@"2"]) {
            
        }
        
        NSDictionary *strategy = nil;
        if (timeStrategyDataNew && [timeStrategyDataNew objectForKey:@"appointTimeWeek"]) {
            strategy = timeStrategyDataNew;
        }else{
            
            if ([timeModleOld isEqualToString:@"2"]) {
                strategy = timeStrategyData;
            }
        }
        
        if (strategy) {
            weekAppoint = [self getParamDataByArray:[strategy objectForKey:@"appointTimeWeek"]];
        }
        
        ///没选择时间
        if (!weekAppoint  || [weekAppoint isEqualToString:@""]) {
            [CommonFuntion showToast:@"请选择星期时间" inView:self.view];
            return;
        }
        
    }else if ([curSelectedTimeType isEqualToString:@"2"]){
        ///全部
    }
    
    
    
    NSString *timeTypeShow = @"";
    NSMutableDictionary *newDetail = [[NSMutableDictionary alloc] initWithDictionary:self.detail];
    
    
    NSMutableDictionary *dicNavTime = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    NSString *timeType = @"1";
    if ([curSelectedTimeType isEqualToString:@"0"]) {
        timeType = @"3";
    }else if ([curSelectedTimeType isEqualToString:@"1"]) {
        timeType = @"2";
    }else if ([curSelectedTimeType isEqualToString:@"2"]) {
        timeType = @"1";
    }
    
    ///新值
    [newDetail setValue:timeType forKey:@"timeType"];
    
    [dicNavTime setValue:timeType forKey:@"navigationTimeType"];
    ///节假日
    if ([curSelectedTimeType isEqualToString:@"0"]) {
        [dicNavTime setValue:@"" forKey:@"navigationWeek"];
        
        if (holidayStartTime && holidayStartTime.length > 0) {
            [dicNavTime setValue:holidayStartTime forKey:@"navigationPointStartTime"];
            [dicNavTime setValue:holidayEndTime forKey:@"navigationPointEndTime"];
            
            NSArray *arrStartTime = [NSArray arrayWithObject:holidayStartTime];
            NSArray *arrEndTime = [NSArray arrayWithObject:holidayEndTime];
            ///新值
            [newDetail setValue:arrStartTime forKey:@"startTime"];
            [newDetail setValue:arrEndTime forKey:@"endTime"];
            
        }else{
            NSString *sTime = @"";
            NSString *eTime = @"";
            if ([self.detail objectForKey:@"startTime"] && [[self.detail objectForKey:@"startTime"] count] > 0) {
                sTime = [[self.detail objectForKey:@"startTime"] objectAtIndex:0];
            }
            
            if ([self.detail objectForKey:@"endTime"] && [[self.detail objectForKey:@"endTime"] count] > 0) {
                eTime = [[self.detail objectForKey:@"endTime"] objectAtIndex:0];
            }
            [dicNavTime setValue:sTime forKey:@"navigationPointStartTime"];
            [dicNavTime setValue:eTime forKey:@"navigationPointEndTime"];
        }
        timeTypeShow = @"节假日";
    }else if ([curSelectedTimeType isEqualToString:@"1"]){
        NSDictionary *strategy = timeStrategyData;
        if (timeStrategyDataNew && [timeStrategyDataNew objectForKey:@"appointTimeWeek"]) {
            strategy = timeStrategyDataNew;
        }
        ///星期
        [dicNavTime setValue:[self getParamDataByArray:[strategy objectForKey:@"appointTimeWeek"]] forKey:@"navigationWeek"];
        [dicNavTime setValue:[self getParamDataByArray:[strategy objectForKey:@"startTime"]] forKey:@"navigationPointStartTime"];
        [dicNavTime setValue:[self getParamDataByArray:[strategy objectForKey:@"endTime"]] forKey:@"navigationPointEndTime"];
        
        ///新值
        [newDetail setValue:[strategy objectForKey:@"appointTimeWeek"] forKey:@"appointTimeWeek"];
        [newDetail setValue:[strategy objectForKey:@"startTime"] forKey:@"startTime"];
        [newDetail setValue:[strategy objectForKey:@"endTime"] forKey:@"endTime"];
        timeTypeShow = @"星期时间";
        
    }else if ([curSelectedTimeType isEqualToString:@"2"]){
        ///全部
        [dicNavTime setValue:@"" forKey:@"navigationWeek"];
        [dicNavTime setValue:@"" forKey:@"navigationPointStartTime"];
        [dicNavTime setValue:@"" forKey:@"navigationPointEndTime"];
        
        timeTypeShow = @"全部时间";
    }
    
    NSLog(@"timeTypeShow:%@",timeTypeShow);
    NSLog(@"dicNavTime:%@",dicNavTime);
    NSLog(@"newDetail:%@",newDetail);
    
    if (self.TimeTypeAddNaviBlock) {
        self.TimeTypeAddNaviBlock(timeTypeShow,newDetail,dicNavTime);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 返回到前一页
-(void)actionSuccess{
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(gobackView)
                                   userInfo:nil repeats:NO];
}

-(void)gobackView{
    //    if (self.NotifyNavigationSitList) {
    //        self.NotifyNavigationSitList();
    //    }
    
    
    if ([self.navigationOrSit isEqualToString:@"sit"]) {
        
    }else{
        
        
        NSString *infos = @"";
        
        ///节假日
        if ([curSelectedTimeType isEqualToString:@"0"]) {
            infos = @"节假日";
        }else if ([curSelectedTimeType isEqualToString:@"1"]){
            infos = @"星期时间";
            ///星期
        }else if ([curSelectedTimeType isEqualToString:@"2"]){
            ///全部
            infos = @"全部时间";
        }
        
        ///刷新  获取到文本信息
        if (self.TimeTypeBlock) {
            self.TimeTypeBlock(infos);
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}



@end
