//
//  AddOrEditRingViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-16.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AddOrEditRingViewController.h"
#import "LLCenterUtility.h"
#import "NSDate+Utils.h"
#import "EditItemModel.h"
#import "LLcenterSheetMenuView.h"
#import "LLCenterSheetMenuModel.h"
#import "TPKeyboardAvoidingTableView.h"
#import "CommonFunc.h"
#import "EditItemTypeCellB.h"
#import "EditItemTypeCellD.h"
#import "EditItemTypeCellF.h"
#import "EditItemTypeCellG.h"
#import "EditItemTypeCellH.h"
#import "CommonNoDataView.h"
#import "LLCenterPickerView.h"


@interface AddOrEditRingViewController ()<UITableViewDataSource,UITableViewDelegate,LLCenterSheetMenuDelegate>{
    
    ///炫铃
    NSMutableArray *soureRing;
    
    ///结束时间的最小时间
    NSDate *minDate;
    
    ///当前时间类型  2(0) 节假日  3(0)星期日期
    NSString *curDateType;
}

@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property(strong,nonatomic) TPKeyboardAvoidingTableView *tableview;
@property(strong,nonatomic) NSMutableArray *dataSource;

@end

@implementation AddOrEditRingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = COLOR_BG;
    [self addNavBar];
    [self initTableview];
    [self initData];
    [self initDataWithActionType];
    ///测试数据
//        [self readTestSaleDictionaryData];
    [self getRingDictionary];
    [self.tableview reloadData];
}


#pragma mark - Nav Bar
-(void)addNavBar{
    [super customBackButton];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonPress)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
}

#pragma mark-  保存事件
-(void)saveButtonPress {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (![CommonFunc checkNetworkState]) {
        [CommonFuntion showToast:@"无网络可用,加载失败" inView:self.view];
        return;
    }
    
    ///节假日
    if ([curDateType isEqualToString:@"0"]) {
        EditItemModel *itemStart = (EditItemModel *)[self.dataSource objectAtIndex:1];
        if ([itemStart.content isEqualToString:@""]) {
            [CommonFuntion showToast:@"开始时间不能为空" inView:self.view];
            return;
        }
        
        EditItemModel *itemEnd = (EditItemModel *)[self.dataSource objectAtIndex:2];
        if ([itemEnd.content isEqualToString:@""]) {
            [CommonFuntion showToast:@"结束时间不能为空" inView:self.view];
            return;
        }
        
        
        if ([itemStart.content compare:itemEnd.content] == 1) {
            [CommonFuntion showToast:@"开始时间不能大于结束时间" inView:self.view];
            return;
        }
        
        /*
        EditItemModel *itemRing = (EditItemModel *)[self.dataSource objectAtIndex:3];
        if ([itemRing.content isEqualToString:@""]) {
            [SVProgressHUD showErrorWithStatus:@"炫铃不能为空"];
            return;
        }
         */
        
    }else{
        
        EditItemModel *itemWeek = (EditItemModel *)[self.dataSource objectAtIndex:1];
        if (![self isSelectedWeek:itemWeek.content]) {
            [CommonFuntion showToast:@"请选择指定星期" inView:self.view];
            return;
        }
        
        EditItemModel *itemStart = (EditItemModel *)[self.dataSource objectAtIndex:2];
        if ([itemStart.content isEqualToString:@""]) {
            [CommonFuntion showToast:@"开始时间不能为空" inView:self.view];
            return;
        }
        
        EditItemModel *itemEnd = (EditItemModel *)[self.dataSource objectAtIndex:3];
        if ([itemEnd.content isEqualToString:@""]) {
            [CommonFuntion showToast:@"结束时间不能为空" inView:self.view];
            return;
        }
        
        if ([itemStart.content compare:itemEnd.content] == 1) {
            [CommonFuntion showToast:@"开始时间不能大于结束时间" inView:self.view];
            return;
        }
        
        /*
        EditItemModel *itemRing = (EditItemModel *)[self.dataSource objectAtIndex:4];
        if ([itemRing.content isEqualToString:@""]) {
            [SVProgressHUD showErrorWithStatus:@"炫铃不能为空"];
            return;
        }
         */
    }
    
    
    ///发送请求
    [self addOrEditRing];
}

#pragma mark - 初始化数据
-(void)initData{
    soureRing = [[NSMutableArray alloc] init];
    self.dataSource = [[NSMutableArray alloc] init];
}


#pragma mark - 测试数据
-(void)readTestData{
    /*
     ringId(炫铃ID)
     ringtoneId(铃声ID)
     ringtoneName(铃声名称)
     timeType(时间类型)
     timeRange(时间范围)
     startTime(开始时间)
     endTime(结束时间)
     */
    
    [self initDataWithActionType];
}



///根据详情信息 设置弹框默认选项
-(void)initByDtailsData{
    NSString * ringtoneId = [self.detail safeObjectForKey:@"ringtoneId"];
    
    ///默认铃声
    NSInteger count = 0;
    if (soureRing) {
        count = [soureRing count];
    }
    BOOL isFound = FALSE;
    LLCenterSheetMenuModel *model;
    for (int i=0; !isFound && i<count; i++) {
        model = [soureRing objectAtIndex:i];
        if ([model.itmeId isEqualToString:ringtoneId]) {
            model.selectedFlag = @"yes";
            isFound = TRUE;
        }
    }
}

///根据返回权限判断
-(void)initMessageSetting:(NSString *)messageSetting{
    EditItemModel *model;
    ///节假日类型
    if ([curDateType isEqualToString:@"0"]) {
        model = (EditItemModel *)[self.dataSource objectAtIndex:4];
    }else{
        model = (EditItemModel *)[self.dataSource objectAtIndex:5];
    }
    model.placeholder = messageSetting;
    if ([messageSetting isEqualToString:@"yes"]) {
        
    }else{
        model.content = @"0";
    }
    
    [self.tableview reloadData];
}

#pragma mark - 根据操作类型 新增/编辑 初始化数据源
-(void)initDataWithActionType{
    NSString *timeType = @"1";
    NSString *timeRange = @"";
    NSString *startTime = @"";
    NSString *endTime = @"";
    NSString *curRingName = @"";
    NSString *curRingId = @"";
    NSString *curMessage = @"0";
    ///新增
    if ([self.actionType  isEqualToString:@"add"]) {
        
    }else if ([self.actionType  isEqualToString:@"edit"]) {
        ///编辑
        timeType = [self.detail safeObjectForKey:@"timeType"];
        
        startTime = [self.detail safeObjectForKey:@"startTime"];
        endTime = [self.detail safeObjectForKey:@"endTime"];
        curRingName = [self.detail safeObjectForKey:@"ringtoneName"];
        curRingId = [self.detail safeObjectForKey:@"ringtoneId"];
        curMessage = [self.detail safeObjectForKey:@"MessageSetting"];
        ///节假日
        if ([timeType isEqualToString:@"2"]) {
            timeType = @"0";
            timeRange = [self.detail safeObjectForKey:@"timeRange"];
            if (timeRange && timeRange.length >= 11 ) {
                startTime = [NSString stringWithFormat:@"%@ %@",[timeRange substringToIndex:10],startTime];
                endTime = [NSString stringWithFormat:@"%@ %@",[timeRange substringFromIndex:11],endTime];
            }
            
        }else{
            timeType = @"1";
        }
    }
    
    NSLog(@"initDataWithActionType startTime:%@",startTime);
    NSLog(@"initDataWithActionType endTime:%@",endTime);
    
    curDateType = timeType;
    
    EditItemModel *model;
    
    model = [[EditItemModel alloc] init];
    model.title = @"时间类型:";
    ///节假日
    model.content = timeType;
    
    
    model.placeholder = @"";
    model.cellType = @"cellD";
    model.keyStr = @"timeType";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    ///星期类型
    if ([curDateType isEqualToString:@"1"]) {
        [self.dataSource addObject:[self newAWeekDateData]];
    }
    
    
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
    
    model = [[EditItemModel alloc] init];
    model.title = @"炫铃选择:";
    model.itemId = curRingId;
    model.content = curRingName;
    model.placeholder = @"";
    model.cellType = @"cellB";
    model.keyStr = @"chooseRing";
    model.keyType = @"chooseRing";
    [self.dataSource addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"留意选项:";
    model.itemId = @"";
    model.content = curMessage;
    model.placeholder = @"yes";
    model.cellType = @"cellH";
    model.keyStr = @"MessageSetting";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    NSLog(@"self.dataSource:%@",self.dataSource);
    for (int i=0; i<[self.dataSource count]; i++) {
        EditItemModel *item  = (EditItemModel*) [self.dataSource objectAtIndex:i];
        NSLog(@"%@  %@",item.title,item.cellType);
    }
}


///判断是否选择了星期时间
-(BOOL)isSelectedWeek:(NSString*)weeksFlag{
    NSArray *arrWeek = [weeksFlag componentsSeparatedByString:@","];
    NSInteger count = 0;
    if (arrWeek) {
        count = [arrWeek count];
    }
    for (int i=0; i<count; i++) {
        if ([arrWeek[i] isEqualToString:@"1"]) {
            return YES;
        }
    }
    return NO;
}

///将1,2,3,4 修改为1,1,1,1....
-(NSString *)getWeekDayByStringContent:(NSString*)timeRange{
    NSArray *arrWeek = [timeRange componentsSeparatedByString:@","];
    NSInteger count = 0;
    if (arrWeek) {
        count = [arrWeek count];
    }
    
    ///默认为不选中
    NSString *week1 = @"0";
    NSString *week2 = @"0";
    NSString *week3 = @"0";
    NSString *week4 = @"0";
    NSString *week5 = @"0";
    NSString *week6 = @"0";
    NSString *week7 = @"0";

    for (int i=0; i<count; i++) {
        NSInteger weekFlag = [[arrWeek objectAtIndex:i] integerValue];
        switch (weekFlag) {
            case 1:
                week1 = @"1";
                break;
            case 2:
                week2 = @"1";
                break;
            case 3:
                week3 = @"1";
                break;
            case 4:
                week4 = @"1";
                break;
            case 5:
                week5 = @"1";
                break;
            case 6:
                week6 = @"1";
                break;
            case 7:
                week7 = @"1";
                break;
                
            default:
                break;
        }
    }
    NSString *weekValue = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@",week1,week2,week3,week4,week5,week6,week7];
    return weekValue;
}

-(EditItemModel *)newAWeekDateData{
    NSString *timeRange = [self.detail safeObjectForKey:@"timeRange"];
    NSString *weekValue = [self getWeekDayByStringContent:timeRange];
    ///根据详情  初始化 content
    EditItemModel *model = [[EditItemModel alloc] init];
    model.title = @"指定时间:";
    model.content = weekValue;
    model.placeholder = @"";
    model.cellType = @"cellG";
    model.keyStr = @"appointedTime";
    model.keyType = @"";
    return model;
}

#pragma mark - 初始化选择条件数据
-(void)initOptionsData{
    
    ///铃声选择
    NSMutableArray *array1 = [[NSMutableArray alloc] init];
    NSInteger count = 0;
    if (soureRing) {
        count = [soureRing count];
    }
    
    ///默认空炫铃
    LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
    model.itmeId = @"";
    model.title = @"(空炫铃)";
    model.selectedFlag = @"no";
    [array1 addObject:model];
    
    
    for (int i=0; i<count; i++) {
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = [[soureRing objectAtIndex:i] safeObjectForKey:@"id"];
        model.title = [[soureRing objectAtIndex:i] safeObjectForKey:@"name"];
        model.selectedFlag = @"no";
        [array1 addObject:model];
    }
    
    [soureRing removeAllObjects];
    [soureRing addObjectsFromArray:array1];
    
    
    NSLog(@"soureRing:%@",soureRing);
}

#pragma mark - 重置选择条件
-(void)resetOptionsData{
    NSInteger count = 0;
    if (soureRing) {
        count = [soureRing count];
    }
    LLCenterSheetMenuModel *model;
    for (int i=0; i<count; i++) {
        model = [soureRing objectAtIndex:i];
        model.selectedFlag = @"no";
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
    
    if ([item.cellType isEqualToString:@"cellB"]) {
        EditItemTypeCellB *cell = [tableView dequeueReusableCellWithIdentifier:@"EditItemTypeCellBIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"EditItemTypeCellB" owner:self options:nil];
            cell = (EditItemTypeCellB*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        __weak typeof(self) weak_self = self;
        cell.SelectDataTypeBlock = ^(NSInteger type){
            ///1铃声选择
            NSInteger falg = 1;
            [weak_self showMenuByFlag:falg withIndexPath:indexPath];
        };
        [cell setCellDetail:item];
        return cell;
    }else if ([item.cellType isEqualToString:@"cellF"]) {
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
            
            ///节假日类型
            if ([curDateType isEqualToString:@"0"]) {
                ///开始时间 结束时间
                if (indexPath.row == 1) {
                    falg = 0;
                }else{
                    falg = 1;
                }
            }else{
                ///开始时间 结束时间
                if (indexPath.row == 2) {
                    falg = 0;
                }else{
                    falg = 1;
                }
            }
            
            [weak_self showDataPickerByFlag:falg];
            
        };
        [cell setCellDetail:item];
        return cell;
    }else if ([item.cellType isEqualToString:@"cellD"]) {
        EditItemTypeCellD *cell = [tableView dequeueReusableCellWithIdentifier:@"EditItemTypeCellDIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"EditItemTypeCellD" owner:self options:nil];
            cell = (EditItemTypeCellD*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        __weak typeof(self) weak_self = self;
        cell.SelectCustomerTypeBlock = ^(NSInteger type){
            NSLog(@"type:%ti",type);
            [weak_self changeDateType:type];
        };
        [cell setCellDetail:item andLeftTitle:@"节假日" andRightTitle:@"星期时间"];
        return cell;
    }else if ([item.cellType isEqualToString:@"cellG"]) {
        EditItemTypeCellG *cell = [tableView dequeueReusableCellWithIdentifier:@"EditItemTypeCellGIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"EditItemTypeCellG" owner:self options:nil];
            cell = (EditItemTypeCellG*)[array objectAtIndex:0];
            [cell awakeFromNib];
            [cell setCellFrame];
        }
      
        [cell setCellDetail:item];
        
        __weak typeof(self) weak_self = self;
        cell.SelectWeekBlock = ^(NSInteger indexOfWeek){
            NSLog(@"indexOfWeek:%ti",indexOfWeek);
            NSString *newStatus = [weak_self getSelectedWeekStatus:item.content withIndex:indexOfWeek];
            [weak_self notifyDataSource:indexPath valueString:newStatus idString:@""];
        };
        
        return cell;
    }else if ([item.cellType isEqualToString:@"cellH"]) {
        EditItemTypeCellH *cell = [tableView dequeueReusableCellWithIdentifier:@"EditItemTypeCellHIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"EditItemTypeCellH" owner:self options:nil];
            cell = (EditItemTypeCellH*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        
        [cell setCellDetail:item];
        
        __weak typeof(self) weak_self = self;
        cell.SelectMessageBlock = ^(){
            
            NSString *select = item.content;
            if ([select isEqualToString:@"0"]) {
                select = @"1";
            }else{
                select = @"0";
            }
            [weak_self notifyDataSource:indexPath valueString:select idString:@""];
        };
        
        return cell;
    }
    return nil;
}


///更改时间类型
-(void)changeDateType:(NSInteger)type{
    
    if (type == [curDateType integerValue]) {
        return;
    }
    curDateType = [NSString stringWithFormat:@"%ti",type];
    
    ///节假日类型
    if ([curDateType isEqualToString:@"0"]) {
        [self.dataSource removeObjectAtIndex:1];
        [self notifyDataSource:[NSIndexPath indexPathForRow:1 inSection:0] valueString:@"" idString:@""];
        [self notifyDataSource:[NSIndexPath indexPathForRow:2 inSection:0] valueString:@"" idString:@""];
        [self notifyDataSource:[NSIndexPath indexPathForRow:3 inSection:0] valueString:@"" idString:@""];
        [self notifyDataSource:[NSIndexPath indexPathForRow:4 inSection:0] valueString:@"0" idString:@""];
    }else{
        ///星期时间
        [self.dataSource insertObject:[self newAWeekDateData] atIndex:1];
        [self notifyDataSource:[NSIndexPath indexPathForRow:2 inSection:0] valueString:@"" idString:@""];
        [self notifyDataSource:[NSIndexPath indexPathForRow:3 inSection:0] valueString:@"" idString:@""];
        [self notifyDataSource:[NSIndexPath indexPathForRow:4 inSection:0] valueString:@"" idString:@""];
        [self notifyDataSource:[NSIndexPath indexPathForRow:5 inSection:0] valueString:@"0" idString:@""];
    }
    
    [self resetOptionsData];
    minDate = nil;
    

    ///更新数据源
    [self notifyDataSource:[NSIndexPath indexPathForRow:0 inSection:0] valueString:curDateType idString:@""];
    
    [self.tableview reloadData];
}

///设置新的选择状态
-(NSString *)getSelectedWeekStatus:(NSString *)weeks withIndex:(NSInteger)index{
    NSMutableString *newWeeks = [[NSMutableString alloc] init];
    NSArray *arrWeek = [weeks componentsSeparatedByString:@","];
    NSInteger count = 0;
    if (arrWeek) {
        count = [arrWeek count];
    }

    for (int i=0; i<count; i++) {

        NSString *status = arrWeek[i];
        if (i == index-1) {
            if ([status isEqualToString:@"0"]) {
                status = @"1";
            }else{
                status = @"0";
            }
        }
        if ([newWeeks isEqualToString:@""]) {
            [newWeeks appendString:status];
        }else{
            [newWeeks appendString:@","];
            [newWeeks appendString:status];
        }
    }
    return newWeeks;
}

///更新数据源
-(void)notifyDataSource:(NSIndexPath *)indexPath valueString:(NSString *)valueStr idString:(NSString *)ids{
    EditItemModel *model = (EditItemModel *)[self.dataSource objectAtIndex:indexPath.row];
    model.content = valueStr;
    model.itemId = ids;
    [self.tableview reloadData];
}


#pragma mark - 弹框
///根据flag 弹框 1铃声
-(void)showMenuByFlag:(NSInteger)flag withIndexPath:(NSIndexPath *)indexPath{
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    NSArray *array = nil;
    NSString *title = @"";
    /// 0单选  1多选
    NSInteger type = 0;
    LLcenterSheetMenuView *sheet;
    
    if (flag == 1){
        title = @"炫铃选择";
        type = 0;
        array = soureRing;
    }
    
    if (array == nil || [array count] == 0) {
        NSLog(@"选择数据源为空");
        NSString *strMsg = @"";
        if (flag == 1) {
            strMsg = @"炫铃加载失败";
        }
        [CommonFuntion showToast:strMsg inView:self.view];
        return;
    }
    
    
    sheet = [[LLcenterSheetMenuView alloc]initWithlist:array headTitle:title footBtnTitle:@"" cellType:type menuFlag:flag];
    sheet.delegate = self;
    
    [sheet showInView:nil];
}


-(void)didSelectSheetMenuIndex:(NSInteger)index menuType:(SheetMenuType)menuT menuFlag:(NSInteger)flag{
    
    NSLog(@"index:%ti",index);
    
    if (flag == 1){
        [self changeSelectedFlag:soureRing index:index];
        
        ///@"请选择状态";
        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[soureRing objectAtIndex:index];
        NSLog(@"title:%@   ids:%@",model.title,model.itmeId);
        
        ///节假日类型
        if ([curDateType isEqualToString:@"0"]) {
            [self notifyDataSource:[NSIndexPath indexPathForRow:3 inSection:0] valueString:model.title idString:model.itmeId];
        }else{
            [self notifyDataSource:[NSIndexPath indexPathForRow:4 inSection:0] valueString:model.title idString:model.itmeId];
        }
    }
    
    [self.tableview reloadData];
}

-(void)changeSelectedFlag:(NSArray *)array index:(NSInteger)index{
    LLCenterSheetMenuModel *modelTmp;
    for (int i=0; i<[array count]; i++) {
        modelTmp = (LLCenterSheetMenuModel*)[array objectAtIndex:i];
        if (i==index) {
            modelTmp.selectedFlag = @"yes";
        }else{
            modelTmp.selectedFlag = @"no";
        }
    }
}


#pragma mark - 日期选择
/// 0 开始日期 1结束日期
-(void)showDataPickerByFlag:(NSInteger)flag{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    ///开始日期
    if (flag == 0) {
        ///节假日类型
        if ([curDateType isEqualToString:@"0"]) {
            [self showDatePickForDateTypeJJRStart];
        }else{
            [self showDatePickForDateTypeJWeekStart];
        }
    }else if (flag == 1){
        ///节假日类型
        if ([curDateType isEqualToString:@"0"]) {
            [self showDatePickForDateTypeJJREnd];
        }else{
            [self showDatePickForDateTypeJWeekEnd];
        }
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
        
        
        EditItemModel *model = (EditItemModel *)[self.dataSource objectAtIndex:2];
        if (model.content && model.content.length > 0 && [startTime compare:model.content] == 1) {
            [CommonFuntion showToast:@"开始时间不能大于结束时间" inView:self.view];
            return;
        }else{
            [weak_self notifyDataSource:[NSIndexPath indexPathForRow:1 inSection:0] valueString:startTime idString:@""];
            [weak_self.tableview reloadData];
        }
        
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
        
        ///结束时间不能
        EditItemModel *model = (EditItemModel *)[self.dataSource objectAtIndex:1];
        if (model.content && model.content.length > 0 && [stopTime compare:model.content] == -1) {
            [CommonFuntion showToast:@"开始时间不能大于结束时间" inView:self.view];
            return;
        }else{
            [weak_self notifyDataSource:[NSIndexPath indexPathForRow:2 inSection:0] valueString:stopTime idString:@""];
            [weak_self.tableview reloadData];
        }
        
        
    };
    [llsheet showInView:nil];
}


#pragma mark - 星期时间选择处理
///开始时间
-(void)showDatePickForDateTypeJWeekStart{
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
        
        
        EditItemModel *model = (EditItemModel *)[self.dataSource objectAtIndex:3];
        if (model.content && model.content.length > 0 && [startTime compare:model.content] == 1) {
            [CommonFuntion showToast:@"开始时间不能大于结束时间" inView:self.view];
            return;
        }else{
            [weak_self notifyDataSource:[NSIndexPath indexPathForRow:2 inSection:0] valueString:startTime idString:@""];
            [weak_self.tableview reloadData];
        }
        
    };
    [llsheet showInView:nil];
}

///结束时间  HH:mm
-(void)showDatePickForDateTypeJWeekEnd{
    __weak typeof(self) weak_self = self;
    
    LLCenterPickerView *llsheet;
    if (minDate == nil) {
        NSDate *date = [NSDate date];
        date = [NSDate setOneDate:date Hour:0 Minute:0];
        llsheet = [[LLCenterPickerView alloc]initWithCurDate:date andMinDate:nil headTitle:@"结束时间" dateType:0];
    }else{
        NSLog(@"minDate:%@",minDate);
        llsheet = [[LLCenterPickerView alloc]initWithCurDate:minDate andMinDate:minDate headTitle:@"结束时间" dateType:0];
    }
    
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
        
        EditItemModel *model = (EditItemModel *)[self.dataSource objectAtIndex:2];
        if (model.content && model.content.length > 0 && [stopTime compare:model.content] == -1) {
            [CommonFuntion showToast:@"开始时间不能大于结束时间" inView:self.view];
            return;
        }else{
            [weak_self notifyDataSource:[NSIndexPath indexPathForRow:3 inSection:0] valueString:stopTime idString:@""];
            [weak_self.tableview reloadData];
        }
        
    };
    [llsheet showInView:nil];
    
}

///将1,0,0,1 修改为1,3....
-(NSString *)getParamWeekDayByStringContent:(NSString*)timeRange{
    NSArray *arrWeek = [timeRange componentsSeparatedByString:@","];
    NSInteger count = 0;
    if (arrWeek) {
        count = [arrWeek count];
    }
    
    NSMutableString *strWeekValue = [[NSMutableString alloc] init];
    for (int i=0; i<count; i++) {
        NSInteger weekFlag = [[arrWeek objectAtIndex:i] integerValue];
        
        if (weekFlag == 1) {
            if ([strWeekValue isEqualToString:@""]) {
                [strWeekValue appendString:[NSString stringWithFormat:@"%i",i+1]];
            }else{
                [strWeekValue appendString:@","];
                [strWeekValue appendString:[NSString stringWithFormat:@"%i",i+1]];
            }
        }
    }
    return strWeekValue;
}

#pragma mark - 网络请求

#pragma mark 获取炫铃信息
-(void)getRingDictionary{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_INIT_RING_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"炫铃jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            if ([jsonResponse objectForKey:@"resultMap"]) {
                
                ///炫铃
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"] != [NSNull null]) {
                    NSArray *ringList = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"];
                    NSLog(@"ringList:%@",ringList);
                    if (ringList) {
                        [soureRing addObjectsFromArray:ringList];
                    }
                }
                NSString *messageSetting = [[jsonResponse objectForKey:@"resultMap"] safeObjectForKey:@"messageSetting"];
                ///初始化数据
                [self initOptionsData];
                [self initByDtailsData];
                [self initMessageSetting:messageSetting];
                
            }else{
                NSLog(@"data------>:<null>");
                
                [CommonFuntion showToast:@"加载异常" inView:self.view];
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getRingDictionary];
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


#pragma mark - 新建、编辑炫铃

-(void)addOrEditRing{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    EditItemModel *item;
    for (int i=0; i<[self.dataSource count]; i++) {
        
        item = (EditItemModel*) [self.dataSource objectAtIndex:i];
        
        if (item.keyType && item.keyType.length > 0) {
            if (item.keyStr && item.keyStr.length > 0) {
                [rDict setValue:item.itemId forKey:item.keyStr];
            }
        }else{
            if (item.keyStr && item.keyStr.length > 0) {
                [rDict setValue:item.content forKey:item.keyStr];
                NSLog(@"key: %@   value: %@",item.keyStr,item.content);
            }
        }
    }
    
    ///节假日用2
    if ([curDateType isEqualToString:@"0"]) {
        [rDict setValue:@"2" forKey:@"timeType"];
    }
    
    
    ///编辑
    if ([self.actionType isEqualToString:@"edit"]) {
        [rDict setValue:[self.detail safeObjectForKey:@"ringId"] forKey:@"ringId"];
    }
    
    if ([rDict objectForKey:@"appointedTime"]) {
        NSString *content = [rDict objectForKey:@"appointedTime"];
        if (content.length > 0) {
            content =  [self getParamWeekDayByStringContent:content];
            [rDict setValue:content forKey:@"appointedTime"];
        }
    }else{
        [rDict setValue:@"" forKey:@"appointedTime"];
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_SAVE_RING_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"新建/编辑炫铃jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [CommonFuntion showToast:@"保存成功" inView:self.view];
            
            [self actionSuccess];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self addOrEditRing];
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


#pragma mark - 返回到前一页
-(void)actionSuccess{
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(gobackView)
                                   userInfo:nil repeats:NO];
}

-(void)gobackView{
    
    if (self.NotifyRingList) {
        self.NotifyRingList();
    }
    [self.navigationController popViewControllerAnimated:YES];
}




@end
