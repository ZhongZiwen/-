//
//  Today_HomeViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "Today_HomeViewController.h"
#import "WeatherInfo.h"
#import "CommonConstant.h"
#import "CommonFuntion.h"
#import "TodayScheuleCell.h"
#import "TodayScheduleExpMenuCell.h"
#import "PlanViewController.h"
#import "HomeSeacherController.h"
#import "AFNHttp.h"
#import "CommonModuleFuntion.h"
#import "MJRefresh.h"
#import "TaskNewViewController.h"
#import "ScheduleNewViewController.h"
#import "XLFTaskDetailViewController.h"
#import "ScheduleDetailViewController.h"
#import "TodayPlanLaterController.h"
#import "VictoryViewController.h"
#import "QuickAddView.h"
#import "WRNewViewController.h"
#import "QuickSettingViewController.h"
#import "ReleaseViewController.h"
#import "CustomerNewViewController.h"
#import "NSUserDefaults_Cache.h"
#import "MapViewViewController.h"
#import "Record.h"
#import "RecordSendViewController.h"
#import "ContactNewViewController.h"
#import "ApprovalApplyViewController.h"
#import "LeadNewViewController.h"
#import "OpportunityNewViewController.h"
#import "MsgViewController.h"
#import "WebViewController.h"

#import "WorkGroupRecordViewController.h"
#import "ActivityDetailViewController.h"
#import "LeadDetailViewController.h"
#import "CustomerDetailViewController.h"
#import "ContactDetailViewController.h"
#import "OpportunityDetailController.h"
#import "Lead.h"
#import "Contact.h"
#import "Customer.h"
#import "SaleChance.h"

#import "SheetPhoneView.h"


@interface Today_HomeViewController ()<UITableViewDataSource,UITableViewDelegate,TodayScheduleMenuItemDelegate,TodayScheduleDetailDelegate, UIAlertViewDelegate, UIActionSheetDelegate>{
    ///顶部日期 6月4日 星期四
    UILabel *labelDateMMDDWW;
    ///天气信息  多云26～19
    UILabel *labelWeather;
    ///城市 上海市
    UILabel *labelCity;
    ///获取天气成功 定位图标  获取失败  笑脸
    UIImageView *imgIconForWeather;
    ///城市名称
    NSString *cityName;
    
    ///点击cell事件标志  0 正常 1 展开事件
    NSInteger tagOfDidselect;
    
    NSMutableDictionary *newDic; //存储 处理过之后的新数据
    
    NSInteger scheduleOrTaskId; //某个任务或者日程的id
    NSString *refuseString; //拒绝理由
    long long startTime, endTime;
    NSString *startStr, *endStr;
    UIView *addPlanOrTaskView;
    
}
@property (nonatomic, strong) NSMutableArray *taskDataSouceArr;
@property (nonatomic, strong) NSMutableArray *schedulesDataSouceArr;

@property (nonatomic, strong) UIButton *quickAddBtn;
@property (nonatomic, strong) QuickAddView *quickAddView;
@property (nonatomic, assign) PushControllerType sourceType;

@end

@implementation Today_HomeViewController


- (void)loadView
{
    [super loadView];
//    self.view.backgroundColor = kView_BG_Color;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ///读取本地文件缓存
    [CommonModuleFuntion getDynamicCacheData];
    
    [self initTableview];
    [self initData];
    [self getLocation];
    [self setupRefresh];
    [self.tableviewTodaySchedule reloadData];
    [self.view addSubview:self.quickAddBtn];
    [self creatHeadViewForTableview];
//    self.tableviewTodaySchedule.frame = CGRectMake(0, 64, self.tableviewTodaySchedule.frame.size.width, self.tableviewTodaySchedule.frame.size.height - 64 - 50);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addNotificationOfWeather];
    [self getDataSouceForScheduleList];
    self.quickAddView.sourceArray = [[FMDBManagement sharedFMDBManager] getQuickDataSource];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeNotificationOdWeather];
}

#pragma mark - 添加测试数据
- (void)getDataSouce:(NSMutableDictionary *)dict {
    if (self.selectIndex) {
        [self openOrCloseMenu:self.selectIndex];
        self.selectIndex = nil;
    }
    
    self.arrayTodaySchedule = [[NSMutableArray alloc] init];
    _taskDataSouceArr = [NSMutableArray arrayWithCapacity:0];
    _schedulesDataSouceArr = [NSMutableArray arrayWithCapacity:0];
    _taskDataSouceArr = [dict objectForKey:@"tasks"];
    _schedulesDataSouceArr = [dict objectForKey:@"schedules"];
    for (NSMutableDictionary *dic in _taskDataSouceArr) {
        newDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        [newDic setObject:@"tasks" forKey:@"flag"];
        if ([dic objectForKey:@"date"] && [[dic allKeys] containsObject:@"date"]) {
            [newDic setObject:[dic objectForKey:@"date"] forKey:@"startDate"];
        }
        [_arrayTodaySchedule addObject:newDic];
    }
    for (NSMutableDictionary *dic in _schedulesDataSouceArr) {
        newDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        [newDic setObject:@"schedules" forKey:@"flag"];
        [_arrayTodaySchedule addObject:newDic];
    }
    NSMutableDictionary *victorDict = [NSMutableDictionary dictionary];
    if ([[dict allKeys] containsObject:@"victoryOpportunity"] && [CommonFuntion checkNullForValue:[dict objectForKey:@"victoryOpportunity"]]) {
        [victorDict setObject:@"victor" forKey:@"flag"];
        [victorDict addEntriesFromDictionary:[dict objectForKey:@"victoryOpportunity"]];
    }
    NSLog(@"%ld", _arrayTodaySchedule.count);
    NSArray *resultArrSort = [_arrayTodaySchedule sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *str1 = [NSString stringWithFormat:@"%@" ,[obj1 objectForKey:@"startDate"]];
        NSString *str2 = [NSString stringWithFormat:@"%@" ,[obj2 objectForKey:@"startDate"]];
        return [str1 compare:str2];
    }];
    [_arrayTodaySchedule removeAllObjects];
    NSMutableArray *newArr = [[NSMutableArray alloc] init]; //存储不是 “全天” 的字典
    for (NSDictionary *dic in resultArrSort) {
        if ([[dic allKeys] containsObject:@"isAllDay"] && [[dic objectForKey:@"isAllDay"] integerValue] == 0) {
            [_arrayTodaySchedule addObject:dic];
        } else {
            [newArr addObject:dic];
        }
    }
    NSLog(@"%ld-- %ld----%ld", _arrayTodaySchedule.count, resultArrSort.count, newArr.count);
    for (NSDictionary *dic in newArr) {
        [_arrayTodaySchedule addObject:dic];
    }
    if ([[victorDict allKeys] count] > 1) {
        [_arrayTodaySchedule addObject:victorDict];
    }
    if (_arrayTodaySchedule.count > 0) {
        addPlanOrTaskView.hidden = YES;
    } else {
        addPlanOrTaskView.hidden = NO;
    }
}

#pragma mark - 初始化数据
-(void)initData{
    tagOfDidselect = 0;
    NSString *date = [CommonFuntion dateToString:[NSDate date] Format:DATE_FORMAT_MdEEEE];
    labelDateMMDDWW.text = date;
}

#pragma mark - headview
- (UIView *)creatHeadView{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 130)];
    headView.backgroundColor = [UIColor clearColor];
    
    labelDateMMDDWW = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, kScreen_Width, 35)];
    labelDateMMDDWW.font = [UIFont systemFontOfSize:24.0];
    labelDateMMDDWW.textColor = LIGHT_BLUE_COLOR;
    labelDateMMDDWW.textAlignment = NSTextAlignmentCenter;
    
    cityName = [CommonFuntion getCurDateZone:[NSDate date]];
    CGSize sizeName = [CommonFuntion getSizeOfContents:cityName Font:[UIFont systemFontOfSize:15.0] withWidth:MAX_WIDTH_OR_HEIGHT withHeight:20];
    
    // 20 10 size.width
    imgIconForWeather = [[UIImageView alloc] initWithFrame:CGRectMake((kScreen_Width-20-10-sizeName.width)/2, 60, 20, 20)];
    imgIconForWeather.image = [UIImage imageNamed:@"defineEmotionGroup.png"];
    
    
    labelCity = [[UILabel alloc] initWithFrame:CGRectMake(imgIconForWeather.frame.origin.x+imgIconForWeather.frame.size.width+10, 60, sizeName.width, 20)];
    labelCity.font = [UIFont systemFontOfSize:15.0];
    labelCity.textColor = [UIColor darkGrayColor];
    labelCity.textAlignment = NSTextAlignmentCenter;
    labelCity.text = cityName;
    
    
    labelWeather = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, kScreen_Width, 20)];
    labelWeather.font = [UIFont systemFontOfSize:15.0];
    labelWeather.textColor = [UIColor darkGrayColor];
    labelWeather.textAlignment = NSTextAlignmentCenter;
    labelWeather.text = @"";
    
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 100, 100, 20)];
    labelTitle.font = [UIFont systemFontOfSize:12.0];
    labelTitle.tintColor = [UIColor grayColor];
    labelTitle.text = @"今日工作";
    
    UIButton *btnMore = [UIButton buttonWithType:UIButtonTypeCustom];
    btnMore.frame = CGRectMake(kScreen_Width-50, 100, 40, 20);
    [btnMore setTitle:@"更多" forState:UIControlStateNormal];
    btnMore.titleLabel.font = [UIFont systemFontOfSize:12.0];
    btnMore.titleLabel.textAlignment = NSTextAlignmentRight;
    [btnMore setTitleColor:LIGHT_BLUE_COLOR forState:UIControlStateNormal];
    [btnMore addTarget:self action:@selector(gotoPlanView) forControlEvents:UIControlEventTouchUpInside];
    
    [headView addSubview:labelTitle];
    [headView addSubview:btnMore];
    [headView addSubview:labelDateMMDDWW];
    [headView addSubview:labelWeather];
    [headView addSubview:labelCity];
    [headView addSubview:imgIconForWeather];
    
    return headView;
}
- (void)creatHeadViewForTableview{
    addPlanOrTaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 200, kScreen_Width, 150)];
    addPlanOrTaskView.backgroundColor = [UIColor clearColor];
    
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
    [btnAddNewPlan addTarget:self action:@selector(addNewPlanOrTask) forControlEvents:UIControlEventTouchUpInside];
    btnAddNewPlan.titleLabel.font = [UIFont systemFontOfSize:15.0];
    
    //给控件赋值
    
    labelTag.text = @"目前没有任何日程和任务";
    btnAddNewPlan.hidden = NO;
    [btnAddNewPlan setTitle:@"马上安排" forState:UIControlStateNormal];
    [btnAddNewPlan setTitleColor:COMMEN_LABEL_COROL forState:UIControlStateNormal];
    [addPlanOrTaskView addSubview:imgIcon];
    [addPlanOrTaskView addSubview:labelTag];
    [addPlanOrTaskView addSubview:btnAddNewPlan];
    [self.tableviewTodaySchedule addSubview:addPlanOrTaskView];
}
- (void)addNewPlanOrTask {
    [self showActionSheetNext];
}

#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewTodaySchedule = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStylePlain];
    self.tableviewTodaySchedule.delegate = self;
    self.tableviewTodaySchedule.dataSource = self;
    self.tableviewTodaySchedule.sectionFooterHeight = 0;
    self.tableviewTodaySchedule.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
    self.tableviewTodaySchedule.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableviewTodaySchedule];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewTodaySchedule setTableFooterView:v];
    self.tableviewTodaySchedule.tableHeaderView = [self creatHeadView];
}
#pragma mark - tableview delegate
/*
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section != 0) {
        return nil;
    }
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 25)];
    headView.backgroundColor = [UIColor whiteColor];
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 2, 100, 20)];
    labelTitle.font = [UIFont systemFontOfSize:12.0];
    labelTitle.tintColor = [UIColor grayColor];
    labelTitle.text = @"今日工作";

    UIButton *btnMore = [UIButton buttonWithType:UIButtonTypeCustom];
    btnMore.frame = CGRectMake(kScreen_Width-50, 2, 40, 20);
    [btnMore setTitle:@"更多" forState:UIControlStateNormal];
    btnMore.titleLabel.font = [UIFont systemFontOfSize:12.0];
    btnMore.titleLabel.textAlignment = NSTextAlignmentRight;
    [btnMore setTitleColor:LIGHT_BLUE_COLOR forState:UIControlStateNormal];
    [btnMore addTarget:self action:@selector(gotoPlanView) forControlEvents:UIControlEventTouchUpInside];
    
    [headView addSubview:labelTitle];
    [headView addSubview:btnMore];
    return headView;
}
 */
///日程页面
-(void)gotoPlanView{
    PlanViewController *controller = [[PlanViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.flagFromWhereIntoPlan = 0;
    [self.navigationController pushViewController:controller animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if (section == 0) {
//        return 25.0;
//    }
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.arrayTodaySchedule) {
        return [self.arrayTodaySchedule count];
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isOpen) {
        if (self.selectIndex.section == section) {
            return 1+1;
        }
    }
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isOpen && self.selectIndex.section == indexPath.section && indexPath.row != 0) {
        TodayScheduleExpMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TodayScheduleExpMenuCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"TodayScheduleExpMenuCell" owner:self options:nil];
            cell = (TodayScheduleExpMenuCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
            cell.backgroundColor = [UIColor colorWithHexString:@"f0fff4"];
        }
        cell.delegate = self;
        [cell setCellFrame];
        
        NSDictionary *dic = [[NSDictionary alloc] init];
        dic = _arrayTodaySchedule[indexPath.section];
        [cell setCellContentDetails:dic indexPath:indexPath];
        return cell;
    }else{
        TodayScheuleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TodayScheuleCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"TodayScheuleCell" owner:self options:nil];
            cell = (TodayScheuleCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
            [cell setCellFrame];
        }
        cell.delegate = self;
        //日程，任务 字体颜色     喜报红色
        cell.labelDateArea.textColor = LIGHT_BLUE_COLOR;
        cell.labelName.textColor = [UIColor blackColor];
        cell.labelFrom.textColor = [UIColor colorWithHexString:@"8899a6"];
        NSDictionary *dic = [[NSDictionary alloc] init];
        //需要作区分
        dic = _arrayTodaySchedule[indexPath.section];
        if ([[dic objectForKey:@"flag"] isEqualToString:@"schedules"]) {
            cell.labelName.text = [dic objectForKey:@"name"];
            if ([[dic objectForKey:@"isAllDay"] integerValue] == 0) {
                cell.labelDateArea.text = @"全天";
            } else {
                NSString *startTime = [[CommonFuntion getStringForTime:[[dic objectForKey:@"startDate"] integerValue]] substringWithRange:NSMakeRange(11, 5)];
                NSString *endTime = [[CommonFuntion getStringForTime:[[dic objectForKey:@"endDate"] integerValue]]substringWithRange:NSMakeRange(11, 5)];
                cell.labelDateArea.numberOfLines = 0;
                cell.labelDateArea.text = [NSString stringWithFormat:@"%@\n-\n%@", startTime, endTime];
                NSLog(@"cell.labelDateArea:%@", cell.labelDateArea.text);
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
           
            NSInteger colorValue = 5;
            if (createID != [appDelegateAccessor.moudle.userId integerValue] && myStateValue == 10) {
                UIImage *image = [UIImage imageNamed:@"home_today_unaccept.png"];
                cell.btnFlagIcon.backgroundColor = [UIColor clearColor];
                [cell.btnFlagIcon setImage:image forState:UIControlStateNormal];
            } else {
                if ([dic objectForKey:@"colorType"] && [[dic objectForKey:@"colorType"] objectForKey:@"color"]) {
                    colorValue = [[[dic objectForKey:@"colorType"] objectForKey:@"color"] integerValue];
                }
                UIColor *color = [CommonFuntion getColorValueByColorType:colorValue];
                cell.btnFlagIcon.layer.cornerRadius = 5;
                cell.btnFlagIcon.backgroundColor = color;
                [cell.btnFlagIcon setImage:nil forState:UIControlStateNormal];
            }
        } else if ([[dic objectForKey:@"flag"] isEqualToString:@"tasks"]) {
            NSString *timeStr = [CommonFuntion getStringForTime:[[dic objectForKey:@"date"] integerValue]];
            cell.labelDateArea.text = [timeStr substringWithRange:NSMakeRange(11, 5)];
            cell.labelName.text = [dic objectForKey:@"name"];
            NSDate *date = [NSDate date];
            double now = [date timeIntervalSince1970] * 1000;
            if ([[dic objectForKey:@"date"] doubleValue] > now) {
                cell.imgFlag.hidden = NO;
            } else {
                cell.imgFlag.hidden = YES;
            }
            NSInteger statusValue= [[dic objectForKey:@"taskStatus"] integerValue];
            NSInteger creatId = 0;
            NSInteger ownerId = 0;
            if ([CommonFuntion checkNullForValue:[dic objectForKey:@"createdBy"]]) {
                creatId = [[[dic objectForKey:@"createdBy"] safeObjectForKey:@"id"] integerValue];
            }
            if ([CommonFuntion checkNullForValue:[dic objectForKey:@"owner"]]) {
                ownerId = [[[dic objectForKey:@"owner"] safeObjectForKey:@"id"] integerValue];
            }
            NSString *imgNameStr = @"";
            //创建人 1，2，3，4，5
            //负责人（不是创创建人）1， 2， 3， 5
            //参与人 2，3，5
            //1待接收,2未完成,3已完成,4被拒绝,5已过期
            if (creatId == [appDelegateAccessor.moudle.userId integerValue]) {
                if (statusValue == 3) {
                    cell.imgExpIcon.hidden = YES;
                    imgNameStr = @"home_today_task_done.png";
                } else {
                    imgNameStr = @"home_today_task.png";
                }
            } else if (creatId != [appDelegateAccessor.moudle.userId integerValue] && ownerId == [appDelegateAccessor.moudle.userId integerValue]) {
                if (statusValue == 3) {
                    cell.imgExpIcon.hidden = YES;
                    imgNameStr = @"task_done_disable";
                } else if (statusValue == 1) {
                    imgNameStr = @"home_today_unaccept.png";
                } else if (statusValue == 5) {
                    imgNameStr = @"task_not_done_disable.png";
                } else {
                    imgNameStr = @"home_today_task.png";
                }
            } else {
                if (statusValue == 3) {
                    cell.imgExpIcon.hidden = YES;
                    imgNameStr = @"task_done_disable";
                } else if (statusValue == 5) {
                    imgNameStr = @"task_not_done_disable.png";
                } else {
                    imgNameStr = @"home_today_task.png";
                }
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
            
            cell.btnFlagIcon.layer.cornerRadius = 0;
            cell.btnFlagIcon.backgroundColor = [UIColor clearColor];
            [cell.btnFlagIcon setImage:[UIImage imageNamed:imgNameStr] forState:UIControlStateNormal];
        } else {
            cell.labelDateArea.textColor = [UIColor redColor];
            cell.labelName.textColor = [UIColor redColor];
            cell.labelFrom.textColor = [UIColor redColor];;
            cell.labelDateArea.text = @"喜报";
            cell.labelName.text = @"签新单啦！！！";
            cell.labelFrom.text = [NSString stringWithFormat:@"%@元/%@个", [dic objectForKey:@"money"], [dic objectForKey:@"count"]];
            cell.btnFlagIcon.layer.cornerRadius = 0;
            cell.btnFlagIcon.backgroundColor = [UIColor clearColor];
            [cell.btnFlagIcon setImage:[UIImage imageNamed:@"home_today_win"] forState:UIControlStateNormal];
        }
        //无需作区分
        //用来标记 cell的风格  1没有labelFrom  2签单  3有labelFrom
        NSInteger flagType = 0;
        if ([CommonFuntion checkNullForValue:[dic objectForKey:@"from"]]) {
            NSString *belongName = [[dic objectForKey:@"from"] safeObjectForKey:@"sourceName"];
            NSString *name = [[dic objectForKey:@"from"] safeObjectForKey:@"name"];
            cell.labelFrom.text = [NSString stringWithFormat:@"来自%@：%@", belongName, name];
            flagType = 3;
        } else if ([[dic objectForKey:@"flag"] isEqualToString:@"victor"]) {
       
            flagType = 2;
        } else {
            cell.labelFrom.hidden = YES;
            flagType = 1;
        }

        [cell setCellContentDetails:dic indexPath:indexPath];
        [cell setCellFrameByType:flagType];
        return cell;
    }
}
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [[NSDictionary alloc] init];
    dic = _arrayTodaySchedule[indexPath.section];
    NSInteger typeCount = [[dic objectForKey:@"status"] integerValue];
    if (typeCount == 2) {
        NSLog(@"没有二级菜单");
    } else {
        ///已选中行
        if (self.selectIndex) {
            TodayScheuleCell *cell = (TodayScheuleCell *)[tableView cellForRowAtIndexPath:self.selectIndex];
            [UIView animateWithDuration:0.2 animations:^{
                cell.imgExpIcon.transform = CGAffineTransformMakeRotation(0);
            } completion:^(BOOL finished) {
                
            }];
        }
        
        ///当前行
        TodayScheuleCell *cell = (TodayScheuleCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (self.selectIndex == nil ||(self.selectIndex && self.selectIndex.section != indexPath.section) ) {
            [UIView animateWithDuration:0.2 animations:^{
                cell.imgExpIcon.transform = CGAffineTransformMakeRotation(M_PI);
            } completion:^(BOOL finished) {
            }];
        }
        
        [self openOrCloseMenu:indexPath];
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didSelectCellRowFirstDo:(BOOL)firstDoInsert nextDo:(BOOL)nextDoInsert
{
    self.isOpen = firstDoInsert;
    [self.tableviewTodaySchedule beginUpdates];
    
    NSInteger section = self.selectIndex.section;
    NSInteger contentCount = 1;
    NSMutableArray* rowToInsert = [[NSMutableArray alloc] init];
    for (NSUInteger i = 1; i < contentCount + 1; i++) {
        NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:i inSection:section];
        [rowToInsert addObject:indexPathToInsert];
    }
    
    if (firstDoInsert)
    {
        [self.tableviewTodaySchedule insertRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        [self.tableviewTodaySchedule deleteRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [self.tableviewTodaySchedule endUpdates];
    
    if (nextDoInsert) {
        self.isOpen = YES;
        self.selectIndex = [self.tableviewTodaySchedule indexPathForSelectedRow];
        [self didSelectCellRowFirstDo:YES nextDo:NO];
    }
}
#pragma mark 点击展开按钮事件
////展开按钮事件
-(void)openMenuView:(id)sender{
    TodayScheuleCell *cell;
    if (isIOS8) {
        cell = (TodayScheuleCell *)[[sender superview] superview] ;
    }else{
        cell = (TodayScheuleCell *)[[[sender superview] superview] superview];
    }
    NSIndexPath* indexPath=[self.tableviewTodaySchedule indexPathForCell:cell];
    
    NSLog(@"展开按钮事件indexPath:%@",indexPath);
    
    tagOfDidselect = 1;
    [self openOrCloseMenu:indexPath];
    //     [self tableView:self.tableviewTodaySchedule didSelectRowAtIndexPath:indexPath];
}


-(void)openOrCloseMenu:(NSIndexPath *)indexPath{
    NSDictionary *dict = _arrayTodaySchedule[indexPath.section];
    //添加限制。点击行为任务且任务状态为完成（3),则不展开二级菜单
    if ([[dict safeObjectForKey:@"flag"] isEqualToString:@"tasks"]) {
        if ([[dict safeObjectForKey:@"taskStatus"] integerValue] == 3) {
            return;
        }
    }
    if (indexPath.row == 0) {
        if ([indexPath isEqual:self.selectIndex]) {
            self.isOpen = NO;
            [self didSelectCellRowFirstDo:NO nextDo:NO];
            self.selectIndex = nil;
        }else
        {
            if (!self.selectIndex) {
                self.selectIndex = indexPath;
                [self didSelectCellRowFirstDo:YES nextDo:NO];
            }else
            {
                [self didSelectCellRowFirstDo:NO nextDo:YES];
            }
        }
    }else
    {
        NSInteger row = indexPath.row-1;
    }
}


#pragma mark - 详情事件
-(void)clickDetailsEvent:(NSInteger)index{
    NSLog(@"clickDetailsEvent index:%li",index);
    NSDictionary *dict = _arrayTodaySchedule[index];
    NSInteger dataId = [[dict safeObjectForKey:@"id"] integerValue];
    __weak typeof(self) weak_self = self;
    if ([[dict safeObjectForKey:@"flag"] isEqualToString:@"tasks"]) {
        XLFTaskDetailViewController *taskController = [[XLFTaskDetailViewController alloc] init];
        taskController.uid = [NSString stringWithFormat:@"%ld", dataId];
        taskController.title = @"任务详情";
        taskController.RefreshTaskListBlock = ^(){
            [weak_self getDataSouceForScheduleList];
        };
        taskController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:taskController animated:YES];
    } else if ([[dict safeObjectForKey:@"flag"] isEqualToString:@"schedules"]) {
        ScheduleDetailViewController *scheduleController = [[ScheduleDetailViewController alloc] init];
        scheduleController.scheduleId = dataId;
        scheduleController.RefreshForPlanControllerBlock = ^(){
            [weak_self getDataSouceForScheduleList];
        };
        scheduleController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:scheduleController animated:YES];
    } else if ([[dict safeObjectForKey:@"flag"] isEqualToString:@"victor"]) {
        VictoryViewController *controller = [[VictoryViewController alloc] init];
        controller.title = @"当天签单";
        controller.strStartDate = @"";
        controller.strEndDate = @"";
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
        
    }
}

#pragma mark - 菜单按钮事件
- (void)clickMenuItemEvent:(NSInteger)tag withDataType:(DataSourceType)dataType withDataId:(NSInteger)dataId {
    scheduleOrTaskId = dataId;
    NSDictionary *dic = [[NSDictionary alloc] init];
    dic = _arrayTodaySchedule[self.selectIndex.section];
    // 日程  1下一步 2延时 3删除 4接受 5拒绝 6退出
    switch (dataType) {
        case DataSourceTypeSchedule:
        {
            switch (tag) {
                case 1:
                    [self showActionSheetNext];
                    break;
                case 2:
                    [self showActionSheetLater:@"日程"];
                    break;
                case 3:
                    [self showAlertViewForDelegate:@"日程"];
                    break;
                case 4:
                    //接受调用接口
                    [self changeOneSchedule:scheduleOrTaskId url:GET_OFFICE_SCHEDULE_GET_RECEIVE];
                    break;
                case 5:
                    [self showAlertViewForRefuse:@"日程"];
                    break;
                case 6:
                    [self showAlertViewForQuit:@"日程"];
                    break;
                case 7:
                {
                    if ([CommonFuntion checkNullForValue:[dic objectForKey:@"address"]]) {
                        [self checkAddressView:[dic safeObjectForKey:@"address"]];
                    }
                }
                    break;
                case 8:
                    [self clickFromEvent:dic];
                    break;
                case 9:
                    if ([CommonFuntion checkNullForValue:[dic objectForKey:@"linkMans"]]) {
                        if ([[dic objectForKey:@"linkMans"] count] > 0) {
                            [self showPhoneNumberView:[dic objectForKey:@"linkMans"]];
                        }
                    }
                    break;
                default:
                    break;
            }

        }
            break;
        case DataSourceTypeTask:
        {  // 任务  1完成 2延时 3删除 4接受 5拒绝  6退出
            switch (tag) {
                case 1:
                    [self changeOneTask:dataId url:GET_OFFICE_TASK_CHANGE];
                    break;
                case 2:
                    [self showActionSheetLater:@"任务"];
//                    [self changeOneTask:dataId url:GET_OFFICE_TASK_CREATE];
                    break;
                case 3:
                    [self showAlertViewForDelegate:@"任务"];
                    break;
                case 4:
                    [self changeOneTask:dataId url:GET_OFFICE_TASK_ACCEPT];
                    break;
                case 5:
                    [self showAlertViewForRefuse:@"任务"];
//                    [self changeOneTask:dataId url:GET_OFFICE_TASK_REFUSE];
                    break;
                case 6:
                    [self showAlertViewForQuit:@"任务"];
//                    [self changeOneTask:dataId url:GET_OFFICE_TASK_QUIT];
                    break;
                case 7:
                {
                    if ([CommonFuntion checkNullForValue:[dic objectForKey:@"address"]]) {
                        [self checkAddressView:[dic safeObjectForKey:@"address"]];
                    }
                }
                    break;
                case 8:
                    [self clickFromEvent:dic];
                    break;
                case 9:
                    if ([CommonFuntion checkNullForValue:[dic objectForKey:@"linkMans"]]) {
                        if ([[dic objectForKey:@"linkMans"] count] > 0) {
                            [self showPhoneNumberView:[dic objectForKey:@"linkMans"]];
                        }
                    }

                    break;
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    NSLog(@"clickMenuItemEvent:section:%li  %li",self.selectIndex.section,tag);
}
#pragma mark - 获取定位信息
///获取当前位置信息
-(void)getLocation{
    if(self.locationManager == nil){
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    if ([CLLocationManager locationServicesEnabled])
    {
        // 判断是否iOS 8
        if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization]; // 永久授权
        }
        
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        self.locationManager.distanceFilter=10.0f;
        
        [self.locationManager stopUpdatingLocation];
        [self.locationManager startUpdatingLocation];
    }else{
        NSLog(@"未获取到定位授权");
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"didChangeAuthorizationStatus----->");
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"didUpdateLocations----->");
    [manager stopUpdatingLocation];
    //GPS坐标  WGS84坐标系
    if ([locations count] > 0) {
        CLLocation* loc = [locations objectAtIndex:0];
        //        NSLog(@"loc:%@",loc);
        
        //        CLLocation *newLoc = [[CLLocation alloc] initWithLatitude:29.58518 longitude:117.996785];
        
        CLGeocoder *geo = [[CLGeocoder alloc] init];
        [geo reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
            
            for (CLPlacemark * placemark in placemarks)
            {
                NSString *curAddress = @"";
                if([placemark.addressDictionary objectForKey:@"FormattedAddressLines"] != NULL)
                {
                    curAddress = [[placemark.addressDictionary objectForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                }
                else{
                    curAddress = @"";
                }
                
                NSLog(@"地址:%@", curAddress);
                NSString *city = [placemark.addressDictionary objectForKey:@"City"];
                NSLog(@"City:%@ ",city);
                cityName = city;
                
                if ([cityName hasSuffix:@"市辖区"]) {
                    cityName = [cityName substringToIndex:cityName.length-3];
                }
                
                NSLog(@"cityName:%@",cityName);
                
                NSLog(@"%@",[placemark.addressDictionary objectForKey:@"State"]);
                NSLog(@"%@",[placemark.addressDictionary objectForKey:@"SubLocality"]);
                
                
                NSString *name = @"";
                if ([placemark.addressDictionary objectForKey:@"SubLocality"]) {
                    name = [placemark.addressDictionary objectForKey:@"SubLocality"];
                }
                if (name && name.length > 1) {
                    name = [name substringToIndex:name.length-1];
                }else{
                    name = [city substringToIndex:city.length-1];
                }
                cityName = name;
                
                
                NSLog(@"cityName:%@",cityName);
                if ([cityName isEqualToString:@"徐汇"]) {
                    cityName = @"上海";
                }
                
                [WeatherInfo getWeatherInfosByCityName:cityName];
            }
        }];
    }
}

#pragma mark - 天气信息相关
///注册通知
-(void)addNotificationOfWeather{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyWeatherInfosUI:) name:@"weather_infos" object:nil];
}
///移除通知
-(void)removeNotificationOdWeather{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"weather_infos" object:nil];
}

///刷新天气信息UI
-(void)notifyWeatherInfosUI:(NSNotification*) notification{
    NSDictionary *info = [notification object];
    NSLog(@"weather:%@  temperature:%@",[info objectForKey:@"weather"],[info objectForKey:@"temperature"]);
    
    ///根据获取到的天气信息 更新UI显示
    NSString *weather = [NSString stringWithFormat:@"%@ %@",[info objectForKey:@"weather"],[info objectForKey:@"temperature"]];
    labelWeather.text = weather;
     CGSize sizeWeather = [CommonFuntion getSizeOfContents:weather Font:[UIFont systemFontOfSize:15.0] withWidth:MAX_WIDTH_OR_HEIGHT withHeight:20];
    
    ///天气 图标 城市
    CGSize sizeName = [CommonFuntion getSizeOfContents:cityName Font:[UIFont systemFontOfSize:15.0] withWidth:MAX_WIDTH_OR_HEIGHT withHeight:20];
    
    ///图标 8
    
    CGFloat wd = sizeWeather.width+5+sizeName.width+5+8;
    labelWeather.frame = CGRectMake((kScreen_Width-wd)/2, 50, sizeWeather.width, 20);
    imgIconForWeather.frame = CGRectMake(labelWeather.frame.origin.x+sizeWeather.width+5, 56, 8, 10);
    imgIconForWeather.image = [UIImage imageNamed:@"today_location.png"];
    
    
    labelCity.frame = CGRectMake(imgIconForWeather.frame.origin.x+8+5, 50, sizeName.width, 20);
    labelCity.text = cityName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)getDataSouceForScheduleList {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    NSString *startDate = @"";
    NSString *endDate = @"";
    NSString *todayDate = [CommonFuntion dateToString:[NSDate date]];
    startDate = endDate = [todayDate substringToIndex:10];

    [params setObject:startDate forKey:@"startDate"];
    [params setObject:endDate forKey:@"endDate"];
    long long userID = [appDelegateAccessor.moudle.userId longLongValue];
    [params setObject:[NSString stringWithFormat:@"%lld", userID] forKey:@"id"];
    [params setObject:@"1" forKey:@"showTask"];
    [params setObject:@"1" forKey:@"isFinish"];
    [params setObject:@"" forKey:@"types"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, GET_OFFICE_SCHEDULE_GET_LIST] params:params success:^(id responseObj) {
        NSLog(@"获取日程列表成功%@", responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            if (responseObj && [responseObj objectForKey:@"schedules"]) {
                [self getDataSouce:responseObj];
            }
            [_tableviewTodaySchedule reloadData];
        }
        [self reloadRefeshView];
    } failure:^(NSError *error) {
        NSLog(@"获取日程列表失败:%@", error);
    }];
    
}
#pragma mark -  上拉加载 下来刷新
//集成刷新控件
- (void)setupRefresh
{
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [self.tableviewTodaySchedule addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"todaySchedule"];
    // 自动刷新(一进入程序就下拉刷新)
    //    [self.tableviewCampaign headerBeginRefreshing];
}

// 结束加载
-(void)reloadRefeshView{
    // 刷新列表
    [self.tableviewTodaySchedule reloadData];
    [self.tableviewTodaySchedule footerEndRefreshing];
    [self.tableviewTodaySchedule headerEndRefreshing];
}

// 下拉
- (void)headerRereshing
{
    NSLog(@"headerRereshing--下拉-->");
    
    if ([self.tableviewTodaySchedule isFooterRefreshing]) {
        [self.tableviewTodaySchedule headerEndRefreshing];
        return;
    }
    [self getDataSouceForScheduleList];
}
#pragma mark - 二级菜单点击事件
// 任务  1完成 2延时 3删除 4接受 5拒绝  6退出
- (void)changeOneTask:(long long)taskID url:(NSString *)action {
    //存储 taskID 和 action
    long long saveTaskID = taskID;
    NSString *saveAction = action;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:[NSString stringWithFormat:@"%lld", taskID] forKey:@"taskId"];
    
    if ([action isEqualToString:GET_OFFICE_TASK_REFUSE]) {
        [params setObject:refuseString forKey:@"reason"];
    } else if ([action isEqualToString:GET_OFFICE_TASK_CHANGE]) {
        [params setObject:@"2" forKey:@"status"];
    }
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, action] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@"操作成功:%@", responseObj);
        if ([[responseObj objectForKey:@"status"] integerValue] == 0) {
            NSLog(@"%@", [responseObj objectForKey:@"desc"]);
            kShowHUD(@"操作成功");
            [self getDataSouceForScheduleList];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self changeOneTask:saveTaskID url:saveAction];
            };
            [comRequest loginInBackground];
        } else {
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            kShowHUD(desc,nil);
        }
    } failure:^(NSError *error) {
        [hud hide:YES];
        NSLog(@"操作失败: %@", error);
    }];
    
}

// 日程  1下一步 2延时 3删除 4接受 5拒绝
- (void)changeOneSchedule:(long long)scheduleID url:(NSString *)action {
    //存储 taskID 和 action
    long long saveTaskID = scheduleID;
    NSString *saveAction = action;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.tableviewTodaySchedule addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    if ([action isEqualToString:GET_OFFICE_SCHEDULE_DEL]) {
        [params setObject:[NSString stringWithFormat:@"%lld", scheduleID] forKey:@"id"];
    } else {
        [params setObject:[NSString stringWithFormat:@"%lld", scheduleID] forKey:@"scheduleId"];
        [params setObject:appDelegateAccessor.moudle.userId forKey:@"staffId"];

    }
    if ([action isEqualToString:GET_OFFICE_SCHEDULE_REFUSE]) {
        [params setObject:refuseString forKey:@"refuseInfo"];
    }
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, action] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@"操作成功:%@", responseObj);
        if ([[responseObj objectForKey:@"status"] integerValue] == 0) {
            NSLog(@"%@", [responseObj objectForKey:@"desc"]);
            kShowHUD(@"操作成功");
            [self getDataSouceForScheduleList];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self changeOneTask:saveTaskID url:saveAction];
            };
            [comRequest loginInBackground];
        } else {
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            kShowHUD(desc,nil);
        }
    } failure:^(NSError *error) {
        [hud hide:YES];
        NSLog(@"操作失败: %@", error);
    }];
}
#pragma mark - arlertView delegate
//删除
- (void)showAlertViewForDelegate:(NSString *)string {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除提示" message:[NSString stringWithFormat:@"删除后，该%@的评论文档等所有内容都将一起删除、且无法恢复！", string] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    if ([string isEqualToString:@"日程"]) {
        alert.tag = 101;
    } else {
        alert.tag = 102;
    }
    [alert show];
}
//退出
- (void)showAlertViewForQuit:(NSString *)string {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"您确认要退出[%@]吗？", string] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    if ([string isEqualToString:@"日程"]) {
        alert.tag = 103;
    } else {
        alert.tag = 104;
    }
    [alert show];
}
//拒绝
- (void)showAlertViewForRefuse:(NSString *)string {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"拒绝后，将向%@创建者发送通知，请问是否需要说明拒绝理由？", string] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拒绝", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].clearButtonMode = UITextFieldViewModeWhileEditing;
    [alert textFieldAtIndex:0].placeholder = @"拒绝理由";
    if ([string isEqualToString:@"日程"]) {
        alert.tag = 105;
    } else {
        alert.tag = 106;
    }
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            NSLog(@"删除日程");
            [self changeOneSchedule:scheduleOrTaskId url:GET_OFFICE_SCHEDULE_DEL];
        } else {
            NSLog(@"确定");
        }
    } else if (alertView.tag == 102) {
        if (buttonIndex == 1) {
            NSLog(@"删除任务");
            [self changeOneTask:scheduleOrTaskId url:GET_OFFICE_TASK_DELETE];
        } else {
            NSLog(@"确定");
        }
    } else if (alertView.tag == 103) {
        if (buttonIndex == 1) {
            NSLog(@"退出日程");
            [self changeOneSchedule:scheduleOrTaskId url:GET_OFFICE_SCHEDULE_DEL];
        }
    } else if (alertView.tag == 104) {
        if (buttonIndex == 1) {
            NSLog(@"退出任务");
            [self changeOneTask:scheduleOrTaskId url:GET_OFFICE_SCHEDULE_QUIT];
        } else {

        }
    } else if (alertView.tag == 105) {
        if (buttonIndex == 1) {
            NSLog(@"拒绝日程");
            refuseString = [alertView textFieldAtIndex:0].text;
            if (refuseString == nil || [refuseString isEmpty] || refuseString.length == 0 || [[refuseString stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
                [CommonFuntion showToast:@"拒绝理由不能为空" inView:self.view];
                return;
            }
             [self changeOneSchedule:scheduleOrTaskId url:GET_OFFICE_SCHEDULE_REFUSE];
        } else {

        }
    } else if (alertView.tag == 106) {
        if (buttonIndex == 1) {
            NSLog(@"拒绝任务");
            refuseString = [alertView textFieldAtIndex:0].text;
            if (refuseString == nil || [refuseString isEmpty] || refuseString.length == 0 || [[refuseString stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
                [CommonFuntion showToast:@"拒绝理由不能为空" inView:self.view];
                return;
            }
            [self changeOneTask:scheduleOrTaskId url:GET_OFFICE_TASK_REFUSE];
        } else {
            
        }
    } else {

    }
}
#pragma mark - action sheet
//201下一步 202延时
- (void)showActionSheetNext{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"新建日程", @"新建任务", nil];
    sheet.tag = 201;
    [sheet showInView:self.view];
}
- (void)showActionSheetLater:(NSString *)string {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"1小时之后", @"2小时之后", @"明天", @"后天", @"7天之后", @"自定义", nil];
    if ([string isEqualToString:@"日程"]) {
        sheet.tag = 202;
    } else {
        sheet.tag = 203;
    }
    [sheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    NSDictionary *dict = _arrayTodaySchedule[self.selectIndex.section];
    if (actionSheet.tag == 201) {
        if (buttonIndex == 0) {
            NSLog(@"日程");
            ScheduleNewViewController *controller = [[ScheduleNewViewController alloc] init];
//            controller.dateString = _scheduleDateString;
            controller.userId = [appDelegateAccessor.moudle.userId integerValue]; //[[dict safeObjectForKey:@"createdBy"] integerValue];
            controller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:controller animated:YES];
        } else if (buttonIndex == 1) {
            NSLog(@"任务");
            TaskNewViewController *controller = [[TaskNewViewController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:controller animated:YES];
        }else {
            
        }
    } else if (actionSheet.tag == 202) {
        NSDictionary *dict = _arrayTodaySchedule[self.selectIndex.section];
        startTime = [[dict safeObjectForKey:@"startDate"] longLongValue];
        endTime = [[dict safeObjectForKey:@"endDate"] longLongValue];
        startStr = [CommonFuntion getStringForTime:startTime];
        endStr = [CommonFuntion getStringForTime:endTime];
        if (buttonIndex == 5) {
            NSLog(@"自定义");
            TodayPlanLaterController *controller = [[TodayPlanLaterController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            controller.startDate = startStr;
            controller.endDate = endStr;
            controller.title = @"日程延时";
            controller.CommitLaterTimeBlock = ^(NSString *startString, NSString *endString) {
                startStr = startString;
                endStr = endString;
                [self changeScheduleFinishDate];
            };
            [self.navigationController pushViewController:controller animated:YES];
        } else if (buttonIndex == 6) {
            NSLog(@"取消");
        } else {
            if (buttonIndex == 0) {
                startStr = [self changeOneDateValue:1 withOldTime:startTime];
                endStr = [self changeOneDateValue:1 withOldTime:endTime];
            } else if (buttonIndex == 1) {
                startStr = [self changeOneDateValue:2 withOldTime:startTime];
                endStr = [self changeOneDateValue:2 withOldTime:endTime];
            } else if (buttonIndex == 2) {
                startStr = [self changeOneDateValue:24 withOldTime:startTime];
                endStr = [self changeOneDateValue:24 withOldTime:endTime];
            } else if (buttonIndex == 3) {
                startStr = [self changeOneDateValue:24 * 2 withOldTime:startTime];
                endStr = [self changeOneDateValue:24 * 2 withOldTime:endTime];
            } else if (buttonIndex == 4) {
                startStr = [self changeOneDateValue:24 * 7 withOldTime:startTime];
                endStr = [self changeOneDateValue:24 * 7 withOldTime:endTime];
            }
            [self changeScheduleFinishDate];
        }
    } else if (actionSheet.tag == 203) {
        NSDictionary *dict = _arrayTodaySchedule[self.selectIndex.section];
        startTime = [[dict safeObjectForKey:@"date"] longLongValue];
        if (buttonIndex == 5) {
            NSLog(@"自定义");
            TodayPlanLaterController *controller = [[TodayPlanLaterController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            controller.title = @"任务延时";
            controller.startDate = [CommonFuntion getStringForTime:startTime];
            controller.CommitLaterTimeBlock = ^(NSString *startString, NSString *endString) {
                startStr = startString;
                [self changeTaskFinishDate];
            };
            [self.navigationController pushViewController:controller animated:YES];
        } else if (buttonIndex == 6) {
            NSLog(@"取消");
        } else {
            if (buttonIndex == 0) {
               startStr = [self changeOneDateValue:1 withOldTime:startTime];
            } else if (buttonIndex == 1) {
                startStr = [self changeOneDateValue:2 withOldTime:startTime];
            } else if (buttonIndex == 2) {
                startStr = [self changeOneDateValue:24 withOldTime:startTime];
            } else if (buttonIndex == 3) {
                startStr = [self changeOneDateValue:24 * 2 withOldTime:startTime];
            } else if (buttonIndex == 4) {
                startStr = [self changeOneDateValue:24 * 7 withOldTime:startTime];
            }
            [self changeTaskFinishDate];
        }

    } else if (actionSheet.tag == 500) {
        if (buttonIndex == actionSheet.cancelButtonIndex)
            return;
        
        if (actionSheet.tag == 500) {
            NSArray *array = @[@"新建日报", @"新建周报", @"新建月报"];
            WRNewViewController *newReportController = [[WRNewViewController alloc] init];
            newReportController.title = array[buttonIndex];
            newReportController.newType = WorkReportNewTypeNew;
            newReportController.reportType = buttonIndex;
            newReportController.refreshBlock = ^{
                
            };
            newReportController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:newReportController animated:YES];
        }

    }
}
//日程延时
- (void)changeScheduleFinishDate {
    __weak typeof(self) weak_self = self;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.tableviewTodaySchedule addSubview:hud];
    [hud show:YES];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:[NSString stringWithFormat:@"%ld", scheduleOrTaskId] forKey:@"id"];
    [params setObject:startStr forKey:@"startDate"];
    [params setObject:endStr forKey:@"endDate"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, GET_OFFICE_SCHEDULE_LATER] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@"操作成功:%@", responseObj);
        if ([[responseObj objectForKey:@"status"] integerValue] == 0) {
            NSLog(@"%@", [responseObj objectForKey:@"desc"]);
            kShowHUD(@"操作成功");
            [self getDataSouceForScheduleList];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self changeScheduleFinishDate];
            };
            [comRequest loginInBackground];
        } else {
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            kShowHUD(desc,nil);
        }
    } failure:^(NSError *error) {
        [hud hide:YES];
        NSLog(@"操作失败: %@", error);
    }];

}
//任务延时
- (void)changeTaskFinishDate {
    __weak typeof(self) weak_self = self;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.tableviewTodaySchedule addSubview:hud];
    [hud show:YES];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:[NSString stringWithFormat:@"%ld", scheduleOrTaskId] forKey:@"taskId"];
    [params setObject:startStr forKey:@"planFinishDate"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, GET_OFFICE_TASK_CREATE] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@"操作成功:%@", responseObj);
        if ([[responseObj objectForKey:@"status"] integerValue] == 0) {
            NSLog(@"%@", [responseObj objectForKey:@"desc"]);
            kShowHUD(@"操作成功");
            [self getDataSouceForScheduleList];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self changeTaskFinishDate];
            };
            [comRequest loginInBackground];
        } else {
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            kShowHUD(desc,nil);
        }
    } failure:^(NSError *error) {
        [hud hide:YES];
        NSLog(@"操作失败: %@", error);
    }];
}
- (void)checkAddressView:(NSString *)addressString {
    NSString *urlStr = [NSString stringWithFormat:@"http://map.baidu.com/mobile/webapp/search/search/wd=%@&qt=s&searchFlag=bigBox&version=5&exptype=dep&c=undefined&src_from=webapp_all_bigbox/", addressString];
    WebViewController *positionController = [WebViewController webViewControllerWithUrlStr:urlStr];
    [self.navigationController pushViewController:positionController animated:YES];
}
#pragma mark - 根据差值改变时间
- (NSString *)changeOneDateValue:(NSInteger)dateTime withOldTime:(long long)oldTime {
    NSString *newDate = @"";
    if (oldTime) {
        oldTime = oldTime + dateTime * 60 * 60 *1000;
        newDate = [CommonFuntion getStringForTime:oldTime];
    }
    return newDate;
}
#pragma mark - 快捷操作 “+”
- (UIButton*)quickAddBtn {
    if (!_quickAddBtn) {
        UIImage *image = [UIImage imageNamed:@"today_quick_add"];
        _quickAddBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_quickAddBtn setWidth:image.size.width];
        [_quickAddBtn setHeight:image.size.height];
        [_quickAddBtn setX:kScreen_Width - 20 - CGRectGetWidth(_quickAddBtn.bounds)];
        [_quickAddBtn setY:kScreen_Height - 20 - CGRectGetHeight(_quickAddBtn.bounds)];
//        _quickAddBtn.layer.shadowOpacity  = 0.8;
//        _quickAddBtn.layer.shadowOffset = CGSizeMake(2,3);
//        _quickAddBtn.layer.shadowRadius = 4;
        [_quickAddBtn setImage:image forState:UIControlStateNormal];
        [_quickAddBtn setImage:image forState:UIControlStateHighlighted];
        [_quickAddBtn addTarget:self action:@selector(quickAddBtnPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _quickAddBtn;
}
- (void)quickAddBtnPress {
    [self.tabBarController.view addSubview:self.quickAddView];
    [_quickAddView popAnimationShow];
}

- (QuickAddView*)quickAddView {
    if (!_quickAddView) {
        _quickAddView = [[QuickAddView alloc] initWithFrame:kScreen_Bounds];
        @weakify(self);
        _quickAddView.tapClickBlock = ^(NSString *string) {
            @strongify(self);
            
            if (![string isEqualToString:@"设置"]) {
                [self.quickAddView popAnimationDismiss];
            }
            
            if ([string isEqualToString:@"设置"]) {
                [self quickToSetting];
            }
            else if ([string isEqualToString:@"发布动态"]) {
                [self quickToSendRelease];
            }
            else if ([string isEqualToString:@"新建客户"]) {
                [self quickToNewCustomer];
            }
            else if ([string isEqualToString:@"新建日程"]) {
                [self quickToNewSchedule];
            }
            else if ([string isEqualToString:@"快速签到"]) {
                [self quickToSignIn];
            }
            else if ([string isEqualToString:@"名片扫描"]) {
                [self quickToScanfNewContact];
            }
            else if ([string isEqualToString:@"新建联系人"]) {
                [self quickToNewContact];
            }
            else if ([string isEqualToString:@"提交审批"]) {
                [self quickToNewApproval];
            }
            else if ([string isEqualToString:@"新建销售线索"]) {
                [self quickToNewLead];
            }
            else if ([string isEqualToString:@"新建任务"]) {
                [self quickToNewTask];
            }
            else if ([string isEqualToString:@"新建工作报告"]) {
                [self quickToNewReport];
            }
            else if ([string isEqualToString:@"新建销售机会"]) {
                [self quickToNewSaleChance];
            }
            else if ([string isEqualToString:@"群发短信"]) {
                [self quickToSMS];
            }
        };
    }
    return _quickAddView;
}
- (void)quickToSetting {
    QuickSettingViewController *quickSettingController = [[QuickSettingViewController alloc] init];
    UINavigationController *settingNav = [[UINavigationController alloc] initWithRootViewController:quickSettingController];
    [kKeyWindow.rootViewController presentViewController:settingNav animated:YES completion:nil];
}

- (void)quickToSendRelease {
    ReleaseViewController *releaseController = [[ReleaseViewController alloc] init];
    releaseController.title = @"发布动态";
    releaseController.typeOfOptionDynamic = TypeOfOptionDynamicRelease;
    releaseController.typeOfRelease = @"zone";
    releaseController.ReleaseSuccessNotifyData = ^(){
    };
    releaseController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:releaseController animated:YES];
}

- (void)quickToNewCustomer {
    CustomerNewViewController *customerNewController = [[CustomerNewViewController alloc] init];
    customerNewController.title = @"创建客户";
    customerNewController.params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    customerNewController.refreshBlock = ^{
        
    };
    customerNewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:customerNewController animated:YES];
}

///日程
- (void)quickToNewSchedule {
    
    NSDictionary *userInfo = [NSUserDefaults_Cache getUserInfo];
    ScheduleNewViewController *controller = [[ScheduleNewViewController alloc] init];
    
    controller.dateString = [CommonFuntion dateToString:[NSDate date] Format:@"yyyy-MM-dd HH:mm"];
    controller.userId = [[userInfo safeObjectForKey:@"id"] integerValue];
    
    controller.userName = [userInfo safeObjectForKey:@"name"];
    controller.userIcon = [userInfo safeObjectForKey:@"icon"];
    controller.title = @"新建日程";
    controller.refreshBlock = ^{
        
    };
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)quickToSignIn {
    MapViewViewController *mapController = [[MapViewViewController alloc] init];
    mapController.hidesBottomBarWhenPushed = YES;
    mapController.typeOfMap = @"location";
    mapController.LocationResultBlock = ^(CLLocationCoordinate2D locCoordinate,NSString *location){
        Record *record = [[Record alloc] init];
        record.recordId = @"A003";
        record.position = location;
        record.latitude = [NSString stringWithFormat:@"%f", locCoordinate.latitude];
        record.longitude = [NSString stringWithFormat:@"%f", locCoordinate.longitude];
        
        RecordSendViewController *recordController = [[RecordSendViewController alloc] init];
        recordController.title = @"添加拜访签到记录";
        recordController.curRecord = record;
        recordController.isQuickSignIn = YES;
        recordController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:recordController animated:YES];
    };
    mapController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mapController animated:YES];
}

- (void)quickToNewContact {
    ContactNewViewController *newController = [[ContactNewViewController alloc] init];
    newController.title = @"新建联系人";
    newController.requestInitPath = kNetPath_Contact_New;
    newController.requestAddPath = kNetPath_Contact_EditOrSave;
    newController.params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    newController.refreshBlock = ^{
        
    };
    newController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:newController animated:YES];
}

- (void)quickToScanfNewContact {
    ContactNewViewController *newController = [[ContactNewViewController alloc] init];
    newController.title = @"新建联系人";
    newController.requestInitPath = kNetPath_Contact_New;
    newController.requestAddPath = kNetPath_Contact_EditOrSave;
    newController.requestScanningPath = kNetPath_Contact_Scanning;
    newController.params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    newController.isScanning = YES;
    newController.refreshBlock = ^{
        
    };
    newController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:newController animated:YES];
}

///审批
- (void)quickToNewApproval {
    ApprovalApplyViewController *applyController = [[ApprovalApplyViewController alloc] init];
    applyController.title = @"申请类型";
    applyController.applyType = ApplyFlowTypeApprovalType;
    applyController.refreshBlock = ^{
        
    };
    applyController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:applyController animated:YES];
}

- (void)quickToNewLead {
    LeadNewViewController *newController = [[LeadNewViewController alloc] init];
    newController.title = @"创建销售线索";
    newController.params = [[NSMutableDictionary alloc] initWithDictionary:COMMON_PARAMS];
    newController.refreshBlock = ^{
    };
    newController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:newController animated:YES];
}

///任务
- (void)quickToNewTask {
    TaskNewViewController *newTaskController = [[TaskNewViewController alloc] init];
    newTaskController.title = @"新建任务";
    newTaskController.refreshBlock = ^{
        
    };
    newTaskController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:newTaskController animated:YES];
}

///工作报告
- (void)quickToNewReport {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"写日报", @"写周报", @"写月报", nil];
    actionSheet.tag = 500;
    [actionSheet showInView:self.view];
}

- (void)quickToNewSaleChance {
    OpportunityNewViewController *newController = [[OpportunityNewViewController alloc] init];
    newController.title = @"创建销售机会";
    newController.refreshBlock = ^{
        
    };
    newController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:newController animated:YES];
}

- (void)quickToSMS {
    MsgViewController *controller = [[MsgViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

///备忘 ----  点击来自XXX事件
-(void)clickFromEvent:(NSDictionary *)item {
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"from"]]) {
        _sourceType = [[[item objectForKey:@"from"] objectForKey:@"sourceId"] integerValue];
        NSInteger sectionId = [[[item objectForKey:@"from"] objectForKey:@"id"] integerValue];
        switch (_sourceType) {
            case PushControllerTypeActivity:
            {
                ActivityDetailViewController *controller = [[ActivityDetailViewController alloc] init];
                controller.id = @(sectionId);
                controller.title = @"市场活动";
                [self.navigationController pushViewController:controller animated:YES];
            }
                NSLog(@"市场活动");
                break;
            case PushControllerTypeClue:
            {
                LeadDetailViewController *controller = [[LeadDetailViewController alloc] init];
                Lead *lead = [[Lead alloc] init];
                lead.id = @(sectionId);
                controller.id = lead.id;
                controller.title = @"销售线索";
                [self.navigationController pushViewController:controller animated:YES];
            }
                NSLog(@"销售线索");
                break;
            case PushControllerTypeCustomer:
            {
                CustomerDetailViewController *controller = [[CustomerDetailViewController alloc] init];
                Customer *tomer = [[Customer alloc] init];
                tomer.id = @(sectionId);
                controller.id = tomer.id;
                controller.title = @"客户";
                [self.navigationController pushViewController:controller animated:YES];
            }
                NSLog(@"客户");
                break;
            case PushControllerTypeContract:
            {
                ContactDetailViewController *controller = [[ContactDetailViewController alloc] init];
                Contact *tact = [[Contact alloc] init];
                tact.id = @(sectionId);
                controller.id = tact.id;
                controller.title = @"联系人";
                [self.navigationController pushViewController:controller animated:YES];
            }
                NSLog(@"联系人");
                break;
            case PushControllerTypeOpportunity:
            {
                OpportunityDetailController *controller = [[OpportunityDetailController alloc] init];
                SaleChance *chance = [[SaleChance alloc] init];
                chance.id = @(sectionId);
                controller.id = chance.id;
                controller.title = @"销售机会";
                [self.navigationController pushViewController:controller animated:YES];
            }
                NSLog(@"销售机会");
                break;
            default:
                break;
        }
    }
}
- (void)showPhoneNumberView:(NSArray *)array {
    NSMutableArray *phoneArray = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *dic in array) {
//        if ([CommonFuntion checkNullForValue:[dic objectForKey:@"name"]] && [CommonFuntion checkNullForValue:[dic objectForKey:@"phone"]]) {
            [phoneArray addObject:dic];
//        }
    }
    SheetPhoneView *phoneView = [[SheetPhoneView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) dataArray:phoneArray];
    
    __weak typeof(phoneView) weak_phoneView = phoneView;
    phoneView.RemoveViewBlock = ^(){
        //移除视图
        [weak_phoneView removeFromSuperview];
    };
    phoneView.backgroundColor = [UIColor grayColor];
    phoneView.alpha = 0.3;
    [kKeyWindow addSubview:phoneView];
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
