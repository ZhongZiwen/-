//
//  PlanViewController.m
//  DemoMapViewPOI
//
//  Created by sungoin-zjp on 15-5-12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#define FORMAT_YYYYMM @"yyyy年MM月"

#import "PlanViewController.h"
#import "CommonFuntion.h"
#import "PlanCell.h"
#import "ScheduleNewViewController.h"
#import "PlanAdvancedSearchViewController.h"
#import "CommonConstant.h"
#import "AFNHttp.h"
#import "AddressSelectedController.h"
#import "ScheduleDetailViewController.h"
#import "ConfirmedPlanController.h"
#import "XLFTaskDetailViewController.h"
#import <MBProgressHUD.h>
#import "TodayDateCell.h"
#import "AddressBook.h"
#import "VictoryViewController.h"
#import "NSUserDefaults_Cache.h"
#import "TaskNewViewController.h"


@interface PlanViewController ()<PlanDelegate,UIActionSheetDelegate>{
     NSMutableDictionary *eventsByDate;
    
    ///顶部标记年月
    UILabel *labelYearMonth;
    ///当列表为空时  显示head
    UIView *viewHeaderOfTableview;
    NSMutableDictionary *newDic; //存储 处理过之后的新数据
    
    ///显示已完成任务1
    NSString *isFinish;
    ///显示任务1
    NSString *showTask;
    ///显示喜报1
    NSString *showXB;
    ///筛选类型 ,
    NSString *typeIds;
    UIView *topView; //待接受日程View
    UILabel *countLabel; //待接收日程个数Label
    NSString *todayDateStr; //存储今天日期
    NSString *monthDateStr; //存储当前年月
    
    NSString *taskType; //改变任务状态标记值 未完成（2）完成（3）
    NSInteger schedulesID; //当前任务ID
}
@property (nonatomic, strong) NSMutableArray *dataSouceArray; //存储所有的数据源
@property (nonatomic, strong) NSMutableArray *relustsArray; //存储具体某一天的数据源
@property (nonatomic, strong) NSMutableArray *taskDataSouceArr;
@property (nonatomic, strong) NSMutableArray *schedulesDataSouceArr;

@property (nonatomic, strong) NSMutableArray *beconfirmedArr;//存储待接收任务数据
@property (nonatomic, strong) NSString *reasonStr; //拒绝理由

@property (copy, nonatomic) NSString *scheduleDateString;
@end

@implementation PlanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _beconfirmedArr = [NSMutableArray arrayWithArray:0];
    
    NSDate *todayDate = [NSDate date];
    todayDateStr = [[CommonFuntion dateToString:todayDate] substringToIndex:10];
    
    if (_flagFromWhereIntoPlan == 0) {
        self.title = @"我的日程";
        _userId = [appDelegateAccessor.moudle.userId integerValue];
    }
    [self creatNarRightBtn];
    //[self creatTopYearMonthView];
    
    [self initData];
    
    [self  GoTodayTouch];
    ///获取日程筛选类型
    [self getScheduleColorType];
    
    NSDate *date = [NSDate date];
    monthDateStr = [[CommonFuntion dateToString:date] substringToIndex:7];
    [self getScheduleDaysOfEveryMonth];
    
//    //代办日程
//    [self getDataSoucerForBeConfirmed];
   
    [self transitionExample];
    
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [self.calendar repositionViews];
}

///初始化筛选条件
-(void)initData{
    NSDictionary *filter = nil;
    
    ///是当前用户 则读取缓存
    if (self.flagFromWhereIntoPlan == 0) {
        filter = [NSUserDefaults_Cache getPlanFilterValue];
    }
    
    if (filter) {
        isFinish = [filter objectForKey:@"isFinish"];
        showTask = [filter objectForKey:@"showTask"];
        showXB = [filter objectForKey:@"showXB"];
    }else{
        isFinish = @"1";
        showTask = @"1";
        showXB = @"1";
        NSDictionary *dicFilter = [NSDictionary dictionaryWithObjectsAndKeys:isFinish, @"isFinish",showTask, @"showTask",showXB, @"showXB",nil];
        [NSUserDefaults_Cache setPlanFilterValue:dicFilter];
    }
    typeIds = @"";
}

#pragma mark - 初始化日历控件
-(void)initCalendView{
    if (!self.calendarContentView) {
        self.calendarMenuView = [[JTCalendarMenuView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 0)];
        self.calendarMenuView.userInteractionEnabled = YES;
        
        self.calendarContentView = [[JTCalendarContentView alloc] init];
        self.calendarContentView.userInteractionEnabled = YES;
        
        [self.view addSubview:self.calendarMenuView];
        [self.view addSubview:self.calendarContentView];
        
        self.calendar = [JTCalendar new];
        {
            ///默认显示周
            self.calendar.calendarAppearance.isWeekMode = YES;
            
            self.calendar.calendarAppearance.useCacheSystem = NO;
            self.calendar.calendarAppearance.calendar.firstWeekday = 2; // Sunday == 1, Saturday == 7
            self.calendar.calendarAppearance.dayCircleRatio = 9. / 10.;
            self.calendar.calendarAppearance.ratioContentMenu = 2.;
            self.calendar.calendarAppearance.focusSelectedDayChangeMode = YES;
            
            /*
             // Customize the text for each month
             self.calendar.calendarAppearance.monthBlock = ^NSString *(NSDate *date, JTCalendar *jt_calendar){
             NSCalendar *calendar = jt_calendar.calendarAppearance.calendar;
             NSDateComponents *comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
             NSInteger currentMonthIndex = comps.month;
             
             static NSDateFormatter *dateFormatter;
             if(!dateFormatter){
             dateFormatter = [NSDateFormatter new];
             dateFormatter.timeZone = jt_calendar.calendarAppearance.calendar.timeZone;
             }
             
             while(currentMonthIndex <= 0){
             currentMonthIndex += 12;
             }
             
             NSString *monthText = [[dateFormatter standaloneMonthSymbols][currentMonthIndex - 1] capitalizedString];
             
             return [NSString stringWithFormat:@"%ld\n%@", comps.year, monthText];
             };
             */
        }
        
        [self.calendar setMenuMonthsView:self.calendarMenuView];
        [self.calendar setContentView:self.calendarContentView];
        [self.calendar setDataSource:self];
        
        //    [self createRandomEvents];
    }
    if (self.calendar.calendarAppearance.isWeekMode) {
        self.calendarContentView.frame = CGRectMake(0, topView.frame.size.height + 100, kScreen_Width, 50);
    }
        [self.calendar reloadData];
       // [self GoTodayTouch];
        [self initGesture];
    
}

#pragma mark - JTCalendarDataSource

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    if(eventsByDate[key] && [eventsByDate[key] count] > 0){
        return YES;
    }
    return NO;
}

- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    NSArray *events = eventsByDate[key];
    NSLog(@"Date: %@ - %ld events", date, [events count]);
    _dateStr = [[CommonFuntion dateToString:date] substringToIndex:10];
    _scheduleDateString = [CommonFuntion dateToString:date];
    if ([todayDateStr isEqualToString:_dateStr]) {
        self.tableviewContent.tableFooterView.hidden = NO;
    } else {
        self.tableviewContent.tableFooterView.hidden = YES;
    }
    [self getDataSoucerForBeConfirmed];
    [self getDataSouceForScheduleList];
    NSLog(@"选中的Date: %@----%@----%@", _dateStr, todayDateStr,_scheduleDateString);
}

- (void)calendarDidLoadPreviousPage
{
    NSLog(@"Previous page loaded");
    NSLog(@"date:%@",self.calendarMenuView.currentDate);
    
    labelYearMonth.text = monthDateStr = [CommonFuntion dateToString:self.calendarMenuView.currentDate Format:FORMAT_YYYYMM];
    monthDateStr = [monthDateStr stringByReplacingOccurrencesOfRegex:@"年" withString:@"-"];
    monthDateStr = [monthDateStr stringByReplacingOccurrencesOfRegex:@"月" withString:@""];
    [self getScheduleDaysOfEveryMonth];
}

- (void)calendarDidLoadNextPage
{
    NSLog(@"Next page loaded");
    NSLog(@"date:%@",self.calendarMenuView.currentDate);
    labelYearMonth.text = monthDateStr = [CommonFuntion dateToString:self.calendarMenuView.currentDate Format:FORMAT_YYYYMM];
    monthDateStr = [monthDateStr stringByReplacingOccurrencesOfRegex:@"年" withString:@"-"];
    monthDateStr = [monthDateStr stringByReplacingOccurrencesOfRegex:@"月" withString:@""];
    [self getScheduleDaysOfEveryMonth];
}

#pragma mark - Transition examples
///
- (void)transitionExample
{
    CGFloat newHeight = 250.0;
    if(self.calendar.calendarAppearance.isWeekMode){
        newHeight = 50.0;
    }
    
    self.calendarContentView.frame = CGRectMake(0, topView.frame.size.height+ 100, kScreen_Width, newHeight);
    [self.calendar reloadAppearance];
    self.tableviewContent.frame = CGRectMake(0, self.calendarContentView.frame.origin.y+self.calendarContentView.frame.size.height, kScreen_Width, kScreen_Height-40-self.calendarContentView.frame.origin.y-self.calendarContentView.frame.size.height);
    [self.view layoutIfNeeded];
    
}

#pragma mark - Fake data

- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy HH:mm:ss";
    }
    
    return dateFormatter;
}

- (void)createRandomEvents
{
    eventsByDate = [NSMutableDictionary new];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:[NSDate date]];
    NSDate *localeDate = [[NSDate date] dateByAddingTimeInterval:interval];
    NSLog(@"localeDate:%@",localeDate);
    for(int i = 0; i < 30; ++i){

        // Generate 30 random dates between now and 60 days later
        NSDate *randomDate = [NSDate dateWithTimeInterval:(rand() % (3600 * 24 * 60)) sinceDate:localeDate];

        // Use the date as key for eventsByDate
        NSString *key = [[self dateFormatter] stringFromDate:randomDate];
        NSLog(@"key:%@",key);
        if(!eventsByDate[key]){
            eventsByDate[key] = [NSMutableArray new];
        }
        
        [eventsByDate[key] addObject:randomDate];
    }
}


#pragma mark - 弹框actionsheet
- (void)addNewPlanOrTask {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"新建日程", @"新建任务", nil];
    actionSheet.tag = 200;
    [actionSheet showInView:self.view];
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;
    
    if (actionSheet.tag == 200) {
        
        if (buttonIndex == 0) {
            [self addNewPlan];
        }else if (buttonIndex == 1){
            [self addNewTask];
        }
    }
}

///新建任务
-(void)addNewTask{
    
    TaskNewViewController *newController = [[TaskNewViewController alloc] init];
    newController.title = @"新建任务";
    newController.refreshBlock = ^{
        [self getDataSouceForScheduleList];
    };
    [self.navigationController pushViewController:newController animated:YES];
}



#pragma mark - nar rightbtn 检索  新建
-(void)creatNarRightBtn{
    self.navigationItem.rightBarButtonItem = nil;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewPlanOrTask)];
    
    UIButton *searchButton=[UIButton buttonWithType:UIButtonTypeCustom];
    searchButton.frame=CGRectMake(0, 0, 30, 40);
    [searchButton setImage:[UIImage imageNamed:@"search_bar_filter_normal.png"] forState:UIControlStateNormal];
//    [searchButton setImage:[UIImage imageNamed:@"search_bar_filter_click.png"] forState:UIControlStateHighlighted];
    [searchButton addTarget:self action:@selector(searchView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBarButton = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    if (_flagFromWhereIntoPlan == 0) {
        self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:addButton,searchBarButton, nil];
    } else {
        self.navigationItem.rightBarButtonItem = searchBarButton;
    }
    
}

///新建日程
-(void)addNewPlan{
    NSLog(@"新建日程--->");
    __weak typeof(self) weak_self = self;
    
//    NewScheduleViewController *controller = [[NewScheduleViewController alloc] init];
//    controller.title = @"新建日程";
//    controller.userId = self.userId;
//    controller.userName = self.userName;
//    controller.userIcon = self.userIcon;
//    controller.dateString = _scheduleDateString;
//    controller.notifyScheduleDataBlock = ^(){
//        NSLog(@"新建--notifyScheduleDataBlock->");
//        ///获取待确认日程  重新请求数据
//        [weak_self getDataSoucerForBeConfirmed];
//    };
//    [self.navigationController pushViewController:controller animated:YES];
    ScheduleNewViewController *newController = [[ScheduleNewViewController alloc] init];
    newController.dateString = _scheduleDateString;
    newController.userId = self.userId;
    newController.userName = self.userName;
    newController.userIcon = self.userIcon;
    newController.title = @"新建日程";
    newController.refreshBlock = ^{
        [self getDataSouceForScheduleList];
    };
    [self.navigationController pushViewController:newController animated:YES];
}

///高级检索
-(void)searchView{
    NSLog(@"检索--->");
    __weak typeof(self) weak_self = self;

    PlanAdvancedSearchViewController *controller = [[PlanAdvancedSearchViewController alloc] init];
    controller.strType = @"高级检索";
    controller.flagFromWhereIntoPlan = self.flagFromWhereIntoPlan;
    controller.typeIds = typeIds;
    controller.isFinish = isFinish;
    controller.showTask = showTask;
    controller.showXB = showXB;
    controller.notifyScheduleDataBlock = ^(NSString *finish,NSString *task,NSString *xb,NSString *types){
        NSLog(@"检索--notifyScheduleDataBlock->");
        isFinish = finish;
        showTask = task;
        typeIds = types;
        showXB = xb;
        ///重新请求数据
        [weak_self getDataSouceForScheduleList];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - 顶部view yyyy年MM月
-(void)creatTopYearMonthView{
    CGFloat vX = 220;
    CGFloat vY = 30;
    if (_flagFromWhereIntoPlan == 0) {
        if (_beconfirmedArr.count > 0) {
            if (!topView) {
                topView = [[UIView alloc] init];
                topView.backgroundColor = [UIColor colorWithHexString:@"fbf0b4"];
                CGFloat vWidth = kScreen_Width - 320;
                UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, vX + vWidth / 2, vY)];
                textLabel.text = @"您有待确认日程";
                textLabel.textColor = [UIColor colorWithHexString:@"e29500"];
                textLabel.textAlignment = NSTextAlignmentRight;
                textLabel.userInteractionEnabled = YES;
                
                countLabel = [[UILabel alloc] initWithFrame:CGRectMake(vX + vWidth / 2 + 5, 5, 20, 20)];
                countLabel.backgroundColor = [UIColor redColor];
                countLabel.textColor = [UIColor whiteColor];
                countLabel.textAlignment = NSTextAlignmentCenter;
                countLabel.layer.masksToBounds = YES;
                countLabel.layer.cornerRadius = 10;
                countLabel.userInteractionEnabled = YES;
                
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreen_Width - 30, 9, 8, 12)];
                [imgView setImage:[UIImage imageNamed:@"schedule_remind_accessory.png"]];
                imgView.userInteractionEnabled = YES;
                [topView addSubview:imgView];
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushToBeConfirmedController)];
                [topView addGestureRecognizer:tap];
                
                [topView addSubview:textLabel];
                [topView addSubview:countLabel];
            }
            topView.frame = CGRectMake(0, 64, kScreen_Width, vY);
            countLabel.text = [NSString stringWithFormat:@"%ld", _beconfirmedArr.count];
        } else {
            topView.frame = CGRectZero;
        }

    } else {
        topView.frame = CGRectZero;
    }
    if (!labelYearMonth) {
        labelYearMonth = [[UILabel alloc] init];
        labelYearMonth.textColor = [UIColor blackColor];
        labelYearMonth.font = [UIFont systemFontOfSize:19.];
        labelYearMonth.text = [CommonFuntion dateToString:[NSDate date] Format:FORMAT_YYYYMM];
        [self.view addSubview:labelYearMonth];
    }
    labelYearMonth.frame = CGRectMake(15,74 + topView.frame.size.height, kScreen_Width, 30);
    [self.view addSubview:topView];

    [self creatBottomView];
    [self initCalendView];
    [self initContentTableview];
}
- (void)refreshTopYearMonthView {
    NSInteger vH = topView.frame.size.height;
    topView.frame = CGRectZero;
    labelYearMonth.frame = CGRectMake(labelYearMonth.frame.origin.x, labelYearMonth.frame.origin.y - vH, labelYearMonth.frame.size.width, labelYearMonth.frame.size.height);
    _calendarContentView.frame = CGRectMake(_calendarContentView.frame.origin.x, _calendarContentView.frame.origin.y - vH, kScreen_Width, _calendarContentView.frame.size.height);
    _tableviewContent.frame = CGRectMake(_tableviewContent.frame.origin.x, _tableviewContent.frame.origin.y - vH, _tableviewContent.frame.size.width, _tableviewContent.frame.size.height);
}
#pragma mark - 跳转到待接收日程列表界面
- (void)pushToBeConfirmedController {
    ConfirmedPlanController *controller = [[ConfirmedPlanController alloc] init];
    controller.title = @"待确认日程";
    __weak typeof(self) weak_self = self;
    controller.backDataSoucerBlock = ^(NSArray *array) {
        _beconfirmedArr = [NSMutableArray arrayWithArray:array];
        if (_beconfirmedArr.count == 0) {
            [weak_self refreshTopYearMonthView];
        } else {
            countLabel.text = [NSString stringWithFormat:@"%ld", _beconfirmedArr.count];
        }
        [weak_self getDataSouceForScheduleList];
    };
    controller.dataSoucerArrayOld =  _beconfirmedArr;
    [self.navigationController pushViewController:controller animated:YES];
}
#pragma mark - 底部view
-(void)creatBottomView{
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height-40, kScreen_Width, 40)];
    bottomView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 1)];
    line.image = [CommonFuntion createImageWithColor:[UIColor colorWithRed:215.0f/255 green:215.0f/255 blue:215.0f/255 alpha:1.0f]];
    [bottomView addSubview:line];
    
    UIButton *btnToday = [UIButton buttonWithType:UIButtonTypeCustom];
    btnToday.frame = CGRectMake(15, 5, 60, 30);
    [btnToday setTitle:@"今天" forState:UIControlStateNormal];
    [btnToday addTarget:self action:@selector(GoTodayTouch) forControlEvents:UIControlEventTouchUpInside];
    [btnToday setTitleColor:COMMEN_LABEL_COROL forState:UIControlStateNormal];
    [bottomView addSubview:btnToday];
    
    
    UIButton *btnOthersPlan = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOthersPlan.frame = CGRectMake(kScreen_Width-140, 5, 120, 30);
    [btnOthersPlan setTitle:@"查看他人日程" forState:UIControlStateNormal];
    [btnOthersPlan addTarget:self action:@selector(gotoOthersPlan) forControlEvents:UIControlEventTouchUpInside];
    [btnOthersPlan setTitleColor:COMMEN_LABEL_COROL forState:UIControlStateNormal];
    [bottomView addSubview:btnOthersPlan];
    
    if (_flagFromWhereIntoPlan == 1) {
        btnOthersPlan.hidden = YES;
        btnToday.frame = CGRectMake((kScreen_Width - 60) / 2, 5, 60, 30);
    } else {
        btnOthersPlan.hidden = NO;
    }
    [self.view addSubview:bottomView];
}

///今天
-(void)GoTodayTouch{
//    NSTimeZone *zone = [NSTimeZone systemTimeZone];
//    NSInteger interval = [zone secondsFromGMTForDate:[NSDate date]];
//    NSDate *localeDate = [[NSDate date] dateByAddingTimeInterval:interval];
    self.tableviewContent.tableFooterView.hidden = NO;
    [self.calendar reloadData];
    [self.calendar setCurrentDate:[NSDate date]];
    
    labelYearMonth.text = monthDateStr = [CommonFuntion dateToString:self.calendarMenuView.currentDate Format:FORMAT_YYYYMM];
    monthDateStr = [monthDateStr stringByReplacingOccurrencesOfRegex:@"年" withString:@"-"];
    monthDateStr = [monthDateStr stringByReplacingOccurrencesOfRegex:@"月" withString:@""];
    
    
    NSDate *nowDate = [NSDate date];
    _dateStr = [[CommonFuntion dateToString:nowDate] substringToIndex:10];
    [self getDataSoucerForBeConfirmed];
    [self getDataSouceForScheduleList];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kJTCalendarDaySelected" object:[NSDate date]];
}

///查看他人日程
-(void)gotoOthersPlan{
    ///
    __weak typeof(self) weak_self = self;
    AddressSelectedController *addressController = [[AddressSelectedController alloc] init];
    addressController.title = @"选择同事";
    addressController.flagForPopViewAnimation = @"no";
    addressController.selectedBlock = ^(AddressBook *addressModel){
        if ([appDelegateAccessor.moudle.userId integerValue] == [addressModel.id integerValue]) {
            return;
        }
        
        /*
        weak_self.flagFromWhereIntoPlan = 1;
        weak_self.userId = [addressModel.id integerValue];
        weak_self.title = addressModel.name;
//        [weak_self creatBottomView];
        [weak_self creatTopYearMonthView];
        [weak_self creatNarRightBtn];
//        [self creatHeadViewForTableview];
        [weak_self getDataSouceForScheduleList];
        NSLog(@"");
        */
        
        ///查看他人日程
        PlanViewController *scheduleController = [[PlanViewController alloc] init];
        scheduleController.title = addressModel.name;
        scheduleController.flagFromWhereIntoPlan = 1;
        scheduleController.userId = [addressModel.id integerValue];
        scheduleController.hidesBottomBarWhenPushed = YES;
        [weak_self.navigationController pushViewController:scheduleController animated:YES];
        
    };
    [self.navigationController pushViewController:addressController animated:YES];
}

#pragma mark - 上下滑动事件
-(void)initGesture
{
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [[self calendarContentView] addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    
    [[self calendarContentView] addGestureRecognizer:recognizer];
}

///
-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionDown) {
        NSLog(@"swipe down");
        if (!self.calendar.calendarAppearance.isWeekMode) {
            return;
        }
        self.calendar.calendarAppearance.isWeekMode = NO;
        [self transitionExample];
    }
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionUp) {
        NSLog(@"swipe up");
        if (self.calendar.calendarAppearance.isWeekMode) {
            return;
        }
        self.calendar.calendarAppearance.isWeekMode = YES;
        [self transitionExample];
    }
}


#pragma mark - 初始化tableview
-(void)initContentTableview{
    if (!self.tableviewContent) {
        
        self.tableviewContent = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableviewContent.dataSource = self;
        self.tableviewContent.delegate = self;
        self.tableviewContent.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
        self.tableviewContent.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
        [self.view addSubview:self.tableviewContent];
        
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        [self.tableviewContent setTableFooterView:v];
    }
    self.tableviewContent.frame = CGRectMake(0, self.calendarContentView.frame.origin.y+self.calendarContentView.frame.size.height, kScreen_Width, kScreen_Height-40-self.calendarContentView.frame.origin.y-self.calendarContentView.frame.size.height);
    
//    if (_dataSouceArray == nil || _dataSouceArray.count == 0) {
//         viewHeaderOfTableview = [self creatHeadViewForTableview];
//    }
}

#pragma mark - 添加测试数据
- (void)getDataSouce:(NSDictionary *)dict {
    
    self.dataSouceArray = [[NSMutableArray alloc] init];
    self.relustsArray = [[NSMutableArray alloc] init];
    _taskDataSouceArr = [NSMutableArray arrayWithCapacity:0];
    _schedulesDataSouceArr = [NSMutableArray arrayWithCapacity:0];
    
    if ([[dict allKeys] containsObject:@"tasks"]) {
        _taskDataSouceArr = [dict objectForKey:@"tasks"];
    }
    if ([[dict allKeys] containsObject:@"schedules"]) {
        _schedulesDataSouceArr = [dict objectForKey:@"schedules"];
    }
    NSMutableDictionary *victorDict = [NSMutableDictionary dictionary];
    
    ///显示喜报
    if ([showXB isEqualToString:@"1"]) {
        if ([[dict allKeys] containsObject:@"victoryOpportunity"] && [CommonFuntion checkNullForValue:[dict objectForKey:@"victoryOpportunity"]]) {
            [victorDict setObject:@"victor" forKey:@"flag"];
            [victorDict addEntriesFromDictionary:[dict objectForKey:@"victoryOpportunity"]];
        }
    }
    
#warning 数据权限前段不做逻辑处理，服务器返回什么就显示什么
    for (NSMutableDictionary *dic in _taskDataSouceArr) {
        //对数据进行过滤，查看他人日程的时候，不显示待接收，只显示自己是参与人或者负责人的日程和任务
//        NSInteger statusValue = 0; //任务状态
//        NSInteger ownerID = 0; //负责人ID
//        NSInteger creatID = 0;
//        NSMutableArray *idsArray = [NSMutableArray arrayWithCapacity:0];
        newDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        [newDic setObject:@"tasks" forKey:@"flag"];
        [newDic setObject:[dic objectForKey:@"date"] forKey:@"startDate"];
        if (_flagFromWhereIntoPlan == 1) {
//            if (dic && [CommonFuntion checkNullForValue:[dic objectForKey:@"createdBy"]]) {
//                creatID = [[[dic objectForKey:@"createdBy"] safeObjectForKey:@"id"] integerValue];
//            }
////            if (creatID != _userId) {
//                if (dic && [dic objectForKey:@"status"]) {
//                    statusValue = [[dic safeObjectForKey:@"status"] integerValue];
//                }
//                if (dic && [CommonFuntion checkNullForValue:[dic objectForKey:@"owner"]]) {
//                    ownerID = [[[dic objectForKey:@"owner"] safeObjectForKey:@"id"] integerValue];
//                }
//                if (dic && [CommonFuntion checkNullForValue:[dic objectForKey:@"members"]]) {
//                    NSArray *membersArray = [dic objectForKey:@"members"];
//                    for (NSDictionary *memberDict in membersArray) {
//                        if (memberDict && [memberDict objectForKey:@"id"]) {
//                            [idsArray addObject:[memberDict safeObjectForKey:@"id"]];
//                        }
//                    }
//                }
//                NSLog(@"%d", [idsArray containsObject:[NSString stringWithFormat:@"%ld", ownerID]]);
//                if (statusValue != 1) {
//                    if (ownerID == _userId || [idsArray containsObject:[NSString stringWithFormat:@"%ld", ownerID]]) {
                        [_dataSouceArray addObject:newDic];
//                    }
//                }
//            }
        } else {
            [_dataSouceArray addObject:newDic];
        }
    }
    for (NSMutableDictionary *dic in _schedulesDataSouceArr) {
        NSInteger myState; //查看他人日程时，剔除掉待接收日程
        if (_flagFromWhereIntoPlan == 1) {
//            if (dic && [dic objectForKey:@"myState"]) {
//                myState = [[dic safeObjectForKey:@"myState"] integerValue];
//                if (myState == 20 || myState == 30 || myState == 40) {
                    newDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                    [newDic setObject:@"schedules" forKey:@"flag"];
                    [_dataSouceArray addObject:newDic];
//                }
//            }
        } else {
            newDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            [newDic setObject:@"schedules" forKey:@"flag"];
            [_dataSouceArray addObject:newDic];
        }
    }

    if ([_dateStr isEqualToString:todayDateStr] &&  ([[victorDict allKeys] count] > 1 || _dataSouceArray.count > 0)) {
        NSMutableDictionary *todayDict = [NSMutableDictionary dictionaryWithCapacity:0];
        long long now = [[NSDate date] timeIntervalSince1970];
        now = now * 1000;
        NSString *timeStr = [[CommonFuntion getStringForTime:now] substringWithRange:NSMakeRange(11, 5)];
        [todayDict setObject:@"today" forKey:@"flag"];
        [todayDict setObject:timeStr forKey:@"time"];
        [todayDict setObject:[NSString stringWithFormat:@"%lld", now] forKey:@"startDate"];
        [_dataSouceArray addObject:todayDict];
    }

    NSArray *resultArrSort = [_dataSouceArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *str1 = [NSString stringWithFormat:@"%@" ,[obj1 objectForKey:@"startDate"]];
        NSString *str2 = [NSString stringWithFormat:@"%@" ,[obj2 objectForKey:@"startDate"]];
        return [str1 compare:str2];
    }];
    [_dataSouceArray removeAllObjects];
    NSMutableArray *newArr = [[NSMutableArray alloc] init]; //存储不是 “全天” 的字典
    for (NSDictionary *dic in resultArrSort) {
        //  0全天 1非全天
        if ([[dic allKeys] containsObject:@"isAllDay"] && [[dic objectForKey:@"isAllDay"] integerValue] == 0) {
            [_dataSouceArray addObject:dic];
        } else {
            [newArr addObject:dic];
        }
    }
    for (NSDictionary *dic in newArr) {
        [_dataSouceArray addObject:dic];
    }
    if ([[victorDict allKeys] count] > 1) {
        [_dataSouceArray addObject:victorDict];
    }
    if (_dataSouceArray && [_dataSouceArray count] == 0) {
        self.tableviewContent.tableHeaderView = [self creatHeadViewForTableview];
    } else {
        self.tableviewContent.tableHeaderView = nil;
    }
}

-(UIView *)creatHeadViewForTableview{
    UIView *viewHeadTableview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 150)];
    viewHeadTableview.backgroundColor = [UIColor clearColor];
    
    NSInteger sizeOfIcon = 70;
    UIImageView *imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake((kScreen_Width-sizeOfIcon)/2, 10, sizeOfIcon, sizeOfIcon)];
    imgIcon.image = [UIImage imageNamed:@"schedule_empty.png"];
    
    
    UILabel *labelTag = [[UILabel alloc] initWithFrame:CGRectMake((kScreen_Width-200)/2, imgIcon.frame.origin.y+sizeOfIcon+10, 200, 20)];
    labelTag.textAlignment = NSTextAlignmentCenter;
    labelTag.textColor = [UIColor grayColor];
    labelTag.font = [UIFont systemFontOfSize:15.0];
    
    
    UIButton *btnAddNewPlan = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAddNewPlan.frame = CGRectMake((kScreen_Width-100)/2, labelTag.frame.origin.y+20+10, 100, 30);
    [btnAddNewPlan setTitleColor:LIGHT_BLUE_COLOR forState:UIControlStateNormal];
    [btnAddNewPlan addTarget:self action:@selector(addNewPlan) forControlEvents:UIControlEventTouchUpInside];
    btnAddNewPlan.titleLabel.font = [UIFont systemFontOfSize:15.0];
    
    //给控件赋值
    
    if (_flagFromWhereIntoPlan == 0) {
        labelTag.text = @"今天没有日程";
        btnAddNewPlan.hidden = NO;
        [btnAddNewPlan setTitle:@"添加新日程" forState:UIControlStateNormal];
        [btnAddNewPlan setTitleColor:COMMEN_LABEL_COROL forState:UIControlStateNormal];
    }else {
        labelTag.text = @"今天没有会议和活动";
        btnAddNewPlan.hidden = YES;
//        [btnAddNewPlan setTitle:@"为他创建日程" forState:UIControlStateNormal];
    }
    
    [viewHeadTableview addSubview:imgIcon];
    [viewHeadTableview addSubview:labelTag];
    [viewHeadTableview addSubview:btnAddNewPlan];
    
    return viewHeadTableview;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [_dataSouceArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (_dataSouceArray && [[_dataSouceArray[indexPath.row] objectForKey:@"flag"] isEqualToString:@"today"]) {
//        return 15;
//    }
    return 55.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_dataSouceArray && ![[_dataSouceArray[indexPath.row] objectForKey:@"flag"] isEqualToString:@"today"]) {
        PlanCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlanCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PlanCell" owner:self options:nil];
            cell = (PlanCell *)[array objectAtIndex:0];
            [cell awakeFromNib];
            cell.delegate = self;
        }
        [self setContentValue:cell forCurIndex:indexPath];
        return cell;
    }
    TodayDateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TodayDateCellIdentifier"];
    if (!cell) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"TodayDateCell" owner:self options:nil];
        cell = (TodayDateCell *)[array objectAtIndex:0];
        [cell awakeFromNib];
        [cell setFrameForAllPhones];
    }
    cell.dateLabel.text = [_dataSouceArray[indexPath.row] objectForKey:@"time"];
    UIImage *image = [CommonFuntion createImageWithColor:[UIColor redColor]];
    cell.imgLine.image = image;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
// cell group 详情
-(void)setContentValue:(PlanCell *)cell forCurIndex:(NSIndexPath *)index
{
    NSInteger typeForCell = -1; //标记左滑之后显示情况 1删除 0接受+拒绝 2退出
    //默认黑色 喜报红色
    cell.labelTime.textColor = [UIColor blackColor];
    cell.labelTitleA.textColor = [UIColor blackColor];
    cell.labelTitleB.textColor = [UIColor colorWithHexString:@"8899a6"];
    
    NSDictionary *dic = [[NSDictionary alloc] init];
    //需要作区分
    dic = _dataSouceArray[index.row];
    
    [cell setCellDetails:dic indexPath:index];

    if ([[dic safeObjectForKey:@"flag"] isEqualToString:@"schedules"]) {
        cell.labelTitleA.text = [dic safeObjectForKey:@"name"];
        if ([[dic safeObjectForKey:@"isAllDay"] integerValue] == 0) {
            cell.labelTime.text = @"全天";
            cell.labelTitleB.hidden = YES;
            cell.imgIcon.hidden = YES;
        } else {
            NSString *startTime = [[CommonFuntion getStringForTime:[[dic objectForKey:@"startDate"] longLongValue]] substringWithRange:NSMakeRange(11, 5)];
            cell.labelTime.text = startTime;
            long long keepTime = [[dic safeObjectForKey:@"endDate"] longLongValue] / 1000 - [[dic safeObjectForKey:@"startDate"] longLongValue]  / 1000;
//            if ([dic objectForKey:@"isRecur"] && [[dic safeObjectForKey:@"isRecur"] integerValue] == 1) {
//                keepTime = keepTime % (3600 * 24);
//            }
            NSString *str = [self getDateStringByTime:keepTime];
            if (str && str.length > 0) {
                cell.labelTitleB.text = str;
                cell.labelTitleB.hidden = NO;
                cell.imgIcon.hidden = NO;
            } else {
                cell.labelTitleB.hidden = YES;
                cell.imgIcon.hidden = YES;
            }
        }
        //待接收日程  ①当前用户不是此日程的创建人 ②当前日程为待接受
        long long createID; //创建人id
        NSInteger myStateValue = 0; //日程状态
        if ([dic objectForKey:@"createdBy"]) {
            createID = [[dic safeObjectForKey:@"createdBy"] longLongValue];
        }
        if ([dic objectForKey:@"myState"]) {
            myStateValue = [[dic objectForKey:@"myState"] integerValue];
        }
        
        UIImage *image;
        if (createID != [appDelegateAccessor.moudle.userId longLongValue] && myStateValue == 10) {
            cell.labelTitleA.textColor = [UIColor colorWithHexString:@"e29500"];
            image = [UIImage imageNamed:@"home_today_unaccept.png"];
            typeForCell = 0;
        } else {
            if (createID == [appDelegateAccessor.moudle.userId longLongValue]) {
                typeForCell = 1;
            } else {
                typeForCell = 2;
            }
            cell.labelTitleA.textColor = [UIColor blackColor];
            NSInteger colorType = 5;
            if ([dic objectForKey:@"colorType"] && [[dic objectForKey:@"colorType"] objectForKey:@"color"]) {
                colorType = [[[dic objectForKey:@"colorType"] safeObjectForKey:@"color"] integerValue];
            }
            
            UIColor *color = [CommonFuntion getColorValueByColorType:colorType];
            image = [CommonFuntion createImageWithColor:color];
        }
//        cell.btnSelect.layer.cornerRadius = cell.btnSelect.frame.size.width/2;
//        cell.btnSelect.layer.masksToBounds = YES;
        [cell.btnSelect setImage:nil forState:UIControlStateNormal];
        [cell.btnSelect setBackgroundImage:image forState:UIControlStateNormal];
    } else if ([[dic objectForKey:@"flag"] isEqualToString:@"tasks"]) {
        NSString *timeStr = [CommonFuntion getStringForTime:[[dic objectForKey:@"date"] longLongValue]];
        cell.labelTime.text = [timeStr substringWithRange:NSMakeRange(11, 5)];
        cell.labelTitleA.text = [dic safeObjectForKey:@"name"];
        NSInteger statusValue = 0;
        if ([dic objectForKey:@"taskStatus"]) {
            statusValue = [[dic objectForKey:@"taskStatus"] integerValue];
        }
        NSString *imgNameStr = @"";
        //待接受任务  ①当前用户不是创建人 ②当前任务状态不为空 ③当前任务为待接收（1）④当前用户是责任人
        long long createID; //创建人id
        long long ownerID = 0; //责任人id
        //1待接收,2未完成,3已完成,4被拒绝
        if ([CommonFuntion checkNullForValue:[dic objectForKey:@"createdBy"]]) {
            createID = [[[dic objectForKey:@"createdBy"] safeObjectForKey:@"id"] longLongValue];
        }
        if ([CommonFuntion checkNullForValue:[dic objectForKey:@"owner"]]) {
            ownerID = [[[dic objectForKey:@"owner"] safeObjectForKey:@"id"] longLongValue];
        }
        //创建人 1，2，3，4，5
        //负责人（不是创创建人）1， 2， 3， 5
        //参与人 2，3，5
        //1待接收,2未完成,3已完成,4被拒绝,5已过期
        
//        任务----不同身份操作权限
//        创建人：删除，完成，重启，修改详情中的所有内容
//        负责人：接受，拒绝，完成，重启，修改除负责人之外的所有信息
//        参与人：退出任务

        if (createID == [appDelegateAccessor.moudle.userId integerValue]) {
            if (statusValue == 3) {
                imgNameStr = @"home_today_task_done.png";
            } else {
                imgNameStr = @"home_today_task.png";
            }
            typeForCell = 1;
        } else if (createID != [appDelegateAccessor.moudle.userId integerValue] && ownerID == [appDelegateAccessor.moudle.userId integerValue]) {
            if (statusValue == 3) {
                imgNameStr = @"task_done_disable";
            } else if (statusValue == 1) {
                typeForCell = 0;
                imgNameStr = @"home_today_unaccept.png";
            } else if (statusValue == 5) {
                imgNameStr = @"task_not_done_disable.png";
            } else {
                imgNameStr = @"home_today_task.png";
            }
        } else {
            if (statusValue == 3) {
                imgNameStr = @"task_done_disable";
            } else if (statusValue == 5) {
                imgNameStr = @"task_not_done_disable.png";
            } else {
                imgNameStr = @"home_today_task.png";
            }
            typeForCell = 2;
        }
        
        
        //1待接收,2未完成,3已完成,4被拒绝,5已过期
        ///白色代表该任务未完成或待接受，绿色代表该任务已完成，红色代表该任务已过期
        //taskStatus 1今天 2明天 3将来 4已过期 5待接收 6被拒绝 7已完成
        if (statusValue == 3) {
            ///完成
            imgNameStr = @"task_icon_over.png";
        }else if (statusValue == 5){
            ///过期
            imgNameStr = @"task_icon_invalid.png";
        }else{
            ///未完成
            imgNameStr = @"task_icon_notcompleted.png";
        }
        
        
//        if (createID != [appDelegateAccessor.moudle.userId longLongValue] && count == 1 && ownerID == [appDelegateAccessor.moudle.userId longLongValue]) {
//            imgNameStr = @"home_today_unaccept.png";
//            cell.labelTitleA.textColor = [UIColor colorWithHexString:@"e29500"];
//        } else {
//            cell.labelTitleA.textColor = [UIColor blackColor];
//            if (ownerID == [appDelegateAccessor.moudle.userId longLongValue] || createID == [appDelegateAccessor.moudle.userId longLongValue]) {
//                if (count == 3) {
//                    taskType = @"3";
//                    imgNameStr = @"home_today_task_done";
//                } else {
//                    taskType = @"2";
//                    imgNameStr = @"home_today_task";
//                }
//            } else {
//                if (count == 3) {
//                    imgNameStr = @"task_done_disable";
//                } else {
//                    imgNameStr = @"task_not_done_disable";
//                }
//            }
//        }
        cell.labelTitleB.hidden = YES;
        cell.imgIcon.hidden = YES;
//        cell.btnSelect.layer.cornerRadius = 0;
//        cell.btnSelect.layer.masksToBounds = YES;
        [cell.btnSelect setImage:[UIImage imageNamed:imgNameStr] forState:UIControlStateNormal];
        [cell.btnSelect setBackgroundImage:nil forState:UIControlStateNormal];
    } else {
        cell.labelTitleB.hidden = NO;
        cell.imgIcon.hidden = YES;
        cell.labelTime.text = @"喜报";
        cell.labelTitleA.text = @"签新单啦！！！";
        cell.labelTitleB.text = [NSString stringWithFormat:@"%@元/%@个", [dic objectForKey:@"money"], [dic objectForKey:@"count"]];
        cell.labelTime.textColor = [UIColor redColor];
        cell.labelTitleA.textColor = [UIColor redColor];
        cell.labelTitleB.textColor = [UIColor redColor];
        
        [cell.btnSelect setImage:[UIImage imageNamed:@"home_today_win"] forState:UIControlStateNormal];
        [cell.btnSelect setBackgroundImage:nil forState:UIControlStateNormal];
    }
    
    if (_flagFromWhereIntoPlan == 0) {
        [cell setLeftAndRightBtn:typeForCell withItemDetail:dic];
    }
  
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [[NSDictionary alloc] init];
    //需要作区分
    __weak typeof(self) weak_self = self;
    dic = _dataSouceArray[indexPath.row];
    if ([[dic objectForKey:@"flag"] isEqualToString:@"schedules"]) {
//        if (dic && [dic objectForKey:@"isPrivate"]) {
//            if ([[dic safeObjectForKey:@"isPrivate"] integerValue] == 0) {
//                kShowHUD(@"此日程为私密日程,您无权查看",nil);
//            } else {
                ScheduleDetailViewController *scheduleDetailController = [[ScheduleDetailViewController alloc] init];
                scheduleDetailController.scheduleId = [[_dataSouceArray[indexPath.row] objectForKey:@"id"] integerValue];
                scheduleDetailController.RefreshForPlanControllerBlock = ^() {
                    [weak_self getDataSouceForScheduleList];
                };
                [self.navigationController pushViewController:scheduleDetailController animated:YES];
//            }
//        }
    } else if ([[dic objectForKey:@"flag"] isEqualToString:@"tasks"]){
        NSLog(@"任务详情");
        XLFTaskDetailViewController *controller = [[XLFTaskDetailViewController alloc] init];
        controller.uid = [_dataSouceArray[indexPath.row] safeObjectForKey:@"id"];
        controller.RefreshTaskListBlock = ^(){
            [weak_self getDataSouceForScheduleList];
        };
        controller.title = @"任务详情";
        [self.navigationController pushViewController:controller animated:YES];
    } else if ([[dic objectForKey:@"flag"] isEqualToString:@"victor"]) {
        NSLog(@"喜报");
        VictoryViewController *controller = [[VictoryViewController alloc] init];
        controller.title = @"当天签单";
        NSString *dateString = @"";
        if (_scheduleDateString) {
            dateString = _scheduleDateString;
        }
        controller.strStartDate = dateString;
        controller.strEndDate = dateString;
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];

    }
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [self.tableviewContent indexPathForCell:cell];
    NSLog(@"click index:%ld",indexPath.row);
    NSDictionary *item = [_dataSouceArray objectAtIndex:indexPath.row];
    schedulesID = [[item safeObjectForKey:@"id"] integerValue];
    
    ///任务
    if ([[item objectForKey:@"flag"] isEqualToString:@"tasks"]){
        
        NSLog(@"index:%ti",index);
        NSLog(@"indexPath section:%ti   row:%ti",indexPath.section,indexPath.row);
        
        UIButton *btn =  (UIButton*)[cell.rightUtilityButtons objectAtIndex:index];
        NSString *btnActionTitle = btn.titleLabel.text;
        NSLog(@"btn  title:%@",btnActionTitle);
        
        if ([btnActionTitle isEqualToString:@"删除"]) {
            [self changOneTask:@"" withTaskId:[NSString  stringWithFormat:@"%ti",schedulesID] withAction:GET_OFFICE_TASK_DELETE];
        }else if ([btnActionTitle isEqualToString:@"完成"]) {
            [self changOneTask:@"2" withTaskId:[NSString  stringWithFormat:@"%ti",schedulesID] withAction:GET_OFFICE_TASK_CHANGE];
        }else if ([btnActionTitle isEqualToString:@"重启"]) {
            [self changOneTask:@"3" withTaskId:[NSString  stringWithFormat:@"%ti",schedulesID] withAction:GET_OFFICE_TASK_CHANGE];
        }else if ([btnActionTitle isEqualToString:@"接收"]) {
            [self changOneTask:@"" withTaskId:[NSString  stringWithFormat:@"%ti",schedulesID] withAction:GET_OFFICE_TASK_ACCEPT];
        }else if ([btnActionTitle isEqualToString:@"拒绝"]) {
            [self showAlertViewForRefuseTask];
        }else if ([btnActionTitle isEqualToString:@"退出"]) {
            [self changOneTask:@"" withTaskId:[NSString  stringWithFormat:@"%ti",schedulesID] withAction:GET_OFFICE_TASK_QUIT];
        }
        
    }else{
        NSInteger userID = [[item safeObjectForKey:@"createdBy"] integerValue];
        NSInteger myStateValue = 0; //日程状态
        NSInteger flagForDelOrAccept; //0删除 1接受 2退出
        if ([item objectForKey:@"myState"]) {
            myStateValue = [[item objectForKey:@"myState"] integerValue];
        }
        if (userID != [appDelegateAccessor.moudle.userId longLongValue] && myStateValue != 20 && myStateValue != 30 && myStateValue != 40) {
            flagForDelOrAccept = 1;
        } else {
            if (userID == [appDelegateAccessor.moudle.userId longLongValue]) {
                flagForDelOrAccept = 0;
            } else {
                flagForDelOrAccept = 2;
            }
        }
        switch (index) {
            case 0:
                // 删除GET_OFFICE_SCHEDULE_DEL  接受GET_OFFICE_SCHEDULE_GET_RECEIVE
                if (flagForDelOrAccept == 0) {
                    [self changeSchedules:[NSString stringWithFormat:@"%ld", schedulesID] delete: GET_OFFICE_SCHEDULE_DEL];
                } else if (flagForDelOrAccept == 1){
                    [self changeSchedules:[NSString stringWithFormat:@"%ld", schedulesID] delete: GET_OFFICE_SCHEDULE_GET_RECEIVE];
                } else {
                    [self changeSchedules:[NSString stringWithFormat:@"%ld", schedulesID] delete: GET_OFFICE_SCHEDULE_QUIT];
                }
                [cell hideUtilityButtonsAnimated:YES];
                break;
            case 1:
                //拒绝
                [self showAlertViewForRefuse];
                [cell hideUtilityButtonsAnimated:YES];
                break;
            default:
                break;
        }
    }
}
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}
- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    if (_flagFromWhereIntoPlan == 1) {
        return NO;
    }
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return NO;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    return YES;
}

#pragma mark - Alert View
- (void)showAlertViewForRefuse {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否拒绝接受该日程" message:@"拒绝后，将向日程创建者发送通知，请输入拒绝理由" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拒绝", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].clearButtonMode = UITextFieldViewModeWhileEditing;
    [alert textFieldAtIndex:0].placeholder = @"拒绝理由";
    alert.tag = 100;
    [alert show];
}

///任务拒绝
- (void)showAlertViewForRefuseTask {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否拒绝接受该任务" message:@"拒绝后，将向任务创建者发送通知，请输入拒绝理由" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拒绝", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].clearButtonMode = UITextFieldViewModeWhileEditing;
    [alert textFieldAtIndex:0].placeholder = @"拒绝理由";
    alert.tag = 101;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        if (buttonIndex == 0) {
            return;
        } else if (buttonIndex == 1) {
            _reasonStr = [alertView textFieldAtIndex:0].text;
            if (_reasonStr.length == 0) {
                kShowHUD(@"拒绝理由不能为空", nil);
                return;
            }
            [self changeSchedules:[NSString stringWithFormat:@"%ld", schedulesID] delete:GET_OFFICE_SCHEDULE_REFUSE];
            NSLog(@"拒绝接受日程");
        }
    }else if (alertView.tag == 101) {
        if (buttonIndex == 0) {
            return;
        } else if (buttonIndex == 1) {
            _reasonStr = [alertView textFieldAtIndex:0].text;
            if (_reasonStr.length == 0) {
                kShowHUD(@"拒绝理由不能为空", nil);
                return;
            }
            [self changOneTask:@"" withTaskId:[NSString  stringWithFormat:@"%ti",schedulesID] withAction:GET_OFFICE_TASK_REFUSE];
            NSLog(@"拒绝接受任务");
        }
    }
}

#pragma mark - cell事件
-(void)clickSelectBtnEvent:(long long)planID{
 
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.tableviewContent addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:[NSString stringWithFormat:@"%lld", planID] forKey:@"taskId"];
   // [params setObject:[NSString stringWithFormat:@"%ld", status] forKey:@"status"];
    [params setObject:taskType forKey:@"status"];
    
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, GET_OFFICE_TASK_CHANGE] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@"操作成功:%@", responseObj);
        if ([[responseObj objectForKey:@"status"] integerValue] == 0) {
            NSLog(@"%@", [responseObj objectForKey:@"desc"]);
            [self getDataSouceForScheduleList];
            
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                
            };
            [comRequest loginInBackground];
        }
        [_tableviewContent reloadData];
    } failure:^(NSError *error) {
        [hud hide:YES];
        NSLog(@"操作失败: %@", error);
    }];

}

//毫秒转换成 DD:HH:mm
- (NSString *)getDateStringByTime:(long long)duration {
    duration = duration / 60; //转化为分钟
    long hours = duration / 60; //小时
    long day = hours / 24; //天数
    long newHours = hours % 24; //剩余小时数
    long min = duration % 60; //有小时的情况剩余分钟数
    if (day > 0) {
        return [NSString stringWithFormat:@"%ld天%ld小时%ld分", day , newHours, min];
    } else {
        if (hours > 0 && min >= 0) {
            return [NSString stringWithFormat:@"%ld小时%ld分", hours, min];
        } else {
            return [NSString stringWithFormat:@"%ld分", duration];
        }
    }
    
    return nil;
}
- (void)getDataSouceForScheduleList {
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    NSString *startDate = @"";
    NSString *endDate = @"";
    if (_dateStr && _dateStr.length > 0) {
        startDate = endDate = [_dateStr substringToIndex:10];
    }

    [params setObject:startDate forKey:@"startDate"];
    [params setObject:endDate forKey:@"endDate"];
    [params setObject:[NSString stringWithFormat:@"%ld", _userId] forKey:@"uid"];
    [params setObject:showTask forKey:@"showTask"];
    [params setObject:isFinish forKey:@"isFinish"];
    [params setObject:typeIds forKey:@"types"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, GET_OFFICE_SCHEDULE_GET_LIST] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@"获取日程列表成功%@", responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            if ([responseObj objectForKey:@"schedules"]) {
                [self getDataSouce:responseObj];
            }
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getDataSouceForScheduleList];
            };
            [comRequest loginInBackground];
        }  else {
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            kShowHUD(desc,nil);
        }
        [_tableviewContent reloadData];
    } failure:^(NSError *error) {
        [hud hide:YES];
        NSLog(@"获取日程列表失败:%@", error);
    }];
    
}


#pragma mark - 获取日程筛选类型
-(void)getScheduleColorType{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA,GET_OFFICE_SCHEDULE_GET_TYPE] params:params success:^(id responseObj) {
        
        //字典转模型
        NSLog(@"获取日程筛选类型 responseObj:%@",responseObj);
        NSArray *array = nil;
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            array =  [responseObj objectForKey:@"salesParameter"];
            
            ///添加默认类型 其他（5，0，其他）
            NSDictionary *other = [NSDictionary dictionaryWithObjectsAndKeys:@"5",@"color",@"0",@"id",@"其他",@"name", nil];
            NSMutableArray *arrType = [[NSMutableArray alloc] init];
            if (array != nil && [array count] > 0) {
                [arrType addObjectsFromArray:array];
            }
            [arrType addObject:other];
            appDelegateAccessor.moudle.arrayScheduleColorType = arrType;
            NSLog(@"appDelegateAccessor.moudle.arrayScheduleColorType:%@",appDelegateAccessor.moudle.arrayScheduleColorType);
            [self initTypeIdSelected];
            //代办日程
            [self getDataSoucerForBeConfirmed];
            
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getScheduleColorType];
            };
            [comRequest loginInBackground];
        }  else {
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            kShowHUD(desc,nil);
            ///添加默认类型 其他（5，0，其他）
            NSDictionary *other = [NSDictionary dictionaryWithObjectsAndKeys:@"5",@"color",@"0",@"id",@"其他",@"name", nil];
            NSMutableArray *arrType = [[NSMutableArray alloc] init];
            
            [arrType addObject:other];
            appDelegateAccessor.moudle.arrayScheduleColorType = arrType;
            [self initTypeIdSelected];
            //代办日程
            [self getDataSoucerForBeConfirmed];
        }

    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        ///添加默认类型 其他（5，0，其他）
        NSDictionary *other = [NSDictionary dictionaryWithObjectsAndKeys:@"5",@"color",@"0",@"id",@"其他",@"name", nil];
        NSMutableArray *arrType = [[NSMutableArray alloc] init];
        
        [arrType addObject:other];
        appDelegateAccessor.moudle.arrayScheduleColorType = arrType;
        [self initTypeIdSelected];
        //代办日程
        [self getDataSoucerForBeConfirmed];
    }];
}


-(void)initTypeIdSelected{
    
    if (appDelegateAccessor.moudle.arrayScheduleColorType && [appDelegateAccessor.moudle.arrayScheduleColorType count] > 1) {
        NSMutableString *ids = [[NSMutableString alloc] initWithString:@""];
        NSInteger count  = [appDelegateAccessor.moudle.arrayScheduleColorType count];
        NSDictionary *item;
        for (int i=0; i<count; i++) {
            item = [appDelegateAccessor.moudle.arrayScheduleColorType objectAtIndex:i];
            
            if ([ids isEqualToString:@""]) {
                [ids appendString:[NSString stringWithFormat:@"%@",[item safeObjectForKey:@"id"]]];
            }else{
                [ids appendString:[NSString stringWithFormat:@",%@",[item safeObjectForKey:@"id"]]];
            }
        }
        typeIds = ids;
    }else{
        typeIds = @"";
    }
}

#pragma mark - 获取待接收日程
- (void)getDataSoucerForBeConfirmed {
    __weak typeof(self) weak_self = self;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, GET_OFFICE_SCHEDULE_GET_BECONFIRMED] params:params success:^(id responseObj) {
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            if ([responseObj objectForKey:@"schedules"]) {
                _beconfirmedArr = [responseObj  objectForKey:@"schedules"];
                if (_beconfirmedArr.count == 0) {
                    [weak_self refreshTopYearMonthView];
                }
            } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
                __weak typeof(self) weak_self = self;
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^(){
                    [weak_self getDataSoucerForBeConfirmed];
                };
                [comRequest loginInBackground];
            }
            [self creatTopYearMonthView];
        } else {
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            kShowHUD(desc,nil);
        }
    } failure:^(NSError *error) {
        [self creatTopYearMonthView];
    }];
}
#pragma mark - delete or Accept or Refuse Schedules
- (void)changeSchedules:(NSString *)ID delete:(NSString *)action {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
  //  删除GET_OFFICE_SCHEDULE_DEL  接受GET_OFFICE_SCHEDULE_GET_RECEIVE 退出GET_OFFICE_SCHEDULE_QUIT 拒绝GET_OFFICE_SCHEDULE_REFUSE
   
//    拒绝日程 scheduleId日程id staffId拒绝人的id refuseInfo拒绝理由
//    退出日程 staffId退出人的id  scheduleId日程id
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    if ([action isEqualToString:GET_OFFICE_SCHEDULE_DEL]) {
        [params setObject:ID forKey:@"id"];
    } else if ([action isEqualToString:GET_OFFICE_SCHEDULE_GET_RECEIVE]) {
        [params setObject:ID forKey:@"scheduleId"];
        [params setObject:appDelegateAccessor.moudle.userId forKey:@"staffId"];
    } else if ([action isEqualToString:GET_OFFICE_SCHEDULE_QUIT]){
        [params setObject:ID forKey:@"scheduleId"];
        [params setObject:appDelegateAccessor.moudle.userId forKey:@"staffId"];
        
    } else if ([action isEqualToString:GET_OFFICE_SCHEDULE_REFUSE]) {
        [params setObject:_reasonStr forKey:@"refuseInfo"];
        [params setObject:ID forKey:@"scheduleId"];
        [params setObject:appDelegateAccessor.moudle.userId forKey:@"staffId"];
    }
    __weak typeof(self) weak_self = self;
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, action] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSDictionary *dict = (NSDictionary *)responseObj;
        if (dict && [[dict safeObjectForKey:@"status"] integerValue] == 0) {
            [weak_self getDataSoucerForBeConfirmed];
            [weak_self getDataSouceForScheduleList];
        } else {
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            kShowHUD(desc,nil);
        }
    } failure:^(NSError *error) {
        [hud hide:YES];
        kShowHUD(NET_ERROR,nil);
    }];

}
#pragma mark - 获取日历天数
- (void)getScheduleDaysOfEveryMonth {
    __weak typeof(self) weak_self = self;
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
//    uid 用户的id  month 月份xxxx-xx  showTask 是否显示任务 isFinish 是否显示已完成任务
    [params setObject:monthDateStr forKey:@"month"];
    [params setObject:[NSString stringWithFormat:@"%ld", _userId] forKey:@"uid"];
    [params setObject:showTask forKey:@"showTask"];
    [params setObject:isFinish forKey:@"isFinish"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, GET_OFFICE_SCHEDULE_DAYS] params:params success:^(id responseObj) {
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            NSDictionary *dict = (NSDictionary *)responseObj;
            [weak_self getNewDaysWithNSDictionary:dict];
            [self.calendar reloadData];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getScheduleDaysOfEveryMonth];
            };
            [comRequest loginInBackground];
        }  else {
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            kShowHUD(desc,nil);
        }
        [_tableviewContent reloadData];
    } failure:^(NSError *error) {
        kShowHUD(NET_ERROR,nil);
    }];

}
- (void)getNewDaysWithNSDictionary:(NSDictionary *)dict {
    appDelegateAccessor.moudle.arrayScheduleAndTask = [NSMutableArray arrayWithCapacity:0];
    NSArray *dayArray;
    if ([CommonFuntion checkNullForValue:[dict objectForKey:@"days"]]) {
       dayArray =  [dict objectForKey:@"days"];
    }
    NSString *strYM = [dict objectForKey:@"ym"];
    for (NSString *daysStr in dayArray) {
        [appDelegateAccessor.moudle.arrayScheduleAndTask addObject:[NSString stringWithFormat:@"%@-%@", strYM, daysStr]];
    }
    NSLog(@"----%@---", appDelegateAccessor.moudle.arrayScheduleAndTask);
}



#pragma mark - 任务   完成/重启/删除/接收/拒绝/退出     2完成  3重启
- (void)changOneTask:(NSString *)type withTaskId:(NSString *)taskId withAction:(NSString *)action{
    __weak typeof(self) weak_self = self;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:taskId forKey:@"taskId"];
    
    
    if ([action isEqualToString:GET_OFFICE_TASK_CHANGE]) {
        [params setObject:type forKey:@"status"];
    }
    
    if ([action isEqualToString:GET_OFFICE_TASK_REFUSE]) {
        [params setObject:_reasonStr forKey:@"reason"];
    }
    
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, action] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@"操作成功:%@", responseObj);
        if ([[responseObj objectForKey:@"status"] integerValue] == 0) {
            NSLog(@"%@", [responseObj objectForKey:@"desc"]);
            [weak_self getDataSoucerForBeConfirmed];
            [weak_self getDataSouceForScheduleList];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self changOneTask:type withTaskId:taskId withAction:action];
            };
            [comRequest loginInBackground];
        }else{
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if (desc && desc.length > 0) {
                kShowHUD(desc,nil);
            }
        }
    } failure:^(NSError *error) {
        [hud hide:YES];
        kShowHUD(NET_ERROR,nil);
        NSLog(@"操作失败: %@", error);
    }];
}


@end
