//
//  PlanAdvancedSearchViewController.m
//  DemoMapViewPOI
//
//  Created by sungoin-zjp on 15-5-13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PlanAdvancedSearchViewController.h"
#import "CommonConstant.h"
#import "CommonFuntion.h"
#import "PlanSearchTypeCell.h"
#import "PlanSearchSwitherTableViewCell.h"
#import "AFNHttp.h"
#import "NSUserDefaults_Cache.h"

@interface PlanAdvancedSearchViewController (){
    
    NSMutableArray *arrayTypeIds;
}

@property(nonatomic,strong) NSMutableArray *arraySalesParameter;

@end

@implementation PlanAdvancedSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = self.strType;
    
    UIBarButtonItem *okButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(okButtonItem)];
    self.navigationItem.rightBarButtonItem = okButtonItem;
   
    

    [self initData];
    [self initSearchOptionTableviewe];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
-(void)initData{
    arrayTypeIds = [[NSMutableArray alloc] init];
    self.arraySalesParameter = [[NSMutableArray alloc] init];
    if (appDelegateAccessor.moudle.arrayScheduleColorType) {
        [self.arraySalesParameter addObjectsFromArray:appDelegateAccessor.moudle.arrayScheduleColorType];
    }
    if (self.typeIds && self.typeIds.length > 0) {
        [arrayTypeIds addObjectsFromArray:[self.typeIds componentsSeparatedByString:@","]];
    }
    
    NSInteger count = 0;
    if (self.arraySalesParameter) {
        count = [self.arraySalesParameter count];
    }
    for (int i=0; i<count; i++) {
        NSDictionary *itemOld =[self.arraySalesParameter objectAtIndex:i];
        NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:itemOld];
        ///添加选中标记
        if ([self isSelectedType:[itemOld safeObjectForKey:@"id"]]) {
            [mutableItemNew setValue:@(YES) forKey:@"select"];
        }else{
            [mutableItemNew setValue:@(NO) forKey:@"select"];
        }
        //修改数据
        [self.arraySalesParameter setObject: mutableItemNew atIndexedSubscript:i];
    }
}

///确定按钮
-(void)okButtonItem{
    NSMutableString *strTypeIds = [[NSMutableString alloc] init];
    NSInteger count = 0;
    if (self.arraySalesParameter) {
        count = [self.arraySalesParameter count];
    }
    NSDictionary *item;
    for (int i=0; i<count; i++) {
        item =[self.arraySalesParameter objectAtIndex:i];
        if ([[item safeObjectForKey:@"select"] boolValue]) {
            if (![strTypeIds isEqualToString:@""]) {
                [strTypeIds appendString:@","];
            }
            [strTypeIds appendString:[item safeObjectForKey:@"id"]];
        }
    }
    
    NSLog(@"strTypeIds:%@",strTypeIds);
    if (self.notifyScheduleDataBlock) {
        ///缓存选择条件
        if(self.flagFromWhereIntoPlan == 0){
            NSDictionary *dicFilter = [NSDictionary dictionaryWithObjectsAndKeys:self.isFinish, @"isFinish",self.showTask, @"showTask",self.showXB, @"showXB",nil];
            [NSUserDefaults_Cache setPlanFilterValue:dicFilter];
        }
        self.notifyScheduleDataBlock(self.isFinish,self.showTask,self.showXB,strTypeIds);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 初始化tableview

-(void)initSearchOptionTableviewe{
    
    self.tableviewPlanSearchOption = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableviewPlanSearchOption.delegate = self;
    self.tableviewPlanSearchOption.dataSource = self;
    self.tableviewPlanSearchOption.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
    self.tableviewPlanSearchOption.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    
    [self.view addSubview:self.tableviewPlanSearchOption];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewPlanSearchOption setTableFooterView:v];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.strType isEqualToString:@"高级检索"]) {
        NSInteger count = 2;
        if (self.arraySalesParameter && [self.arraySalesParameter count]>0 ) {
            count++;
        }
        return count;
    }else if([self.strType isEqualToString:@"选择类型"]){
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (self.arraySalesParameter) {
            return [self.arraySalesParameter count];
        }
        return 0;
    }else if (section == 1){
        return 2;
    }else if(section == 2){
        return 1;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 40.0;
    }
    return 20.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1.;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 35.0)];
        
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 300, 21)];
        labelTitle.font = [UIFont systemFontOfSize:12.0];
        labelTitle.textColor = GROUP_HEAD_TITLE_COLOR;
        if ([self.strType isEqualToString:@"高级检索"]) {
            labelTitle.text = @"筛选类型";
        }else if([self.strType isEqualToString:@"选择类型"]){
            labelTitle.text = @"选择类型,便于您区分和统计日程";
        }
        
        [headView addSubview:labelTitle];
        return headView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        PlanSearchTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlanSearchTypeCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PlanSearchTypeCell" owner:self options:nil];
            cell = (PlanSearchTypeCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
      
        [self setContentValue1:cell forCurIndex:indexPath];
        return cell;
    }else{
        PlanSearchSwitherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlanSearchSwitherTableViewCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PlanSearchSwitherTableViewCell" owner:self options:nil];
            cell = (PlanSearchSwitherTableViewCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
       [cell.switchBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                cell.switchBtn.tag = 1001;
            }else{
                cell.switchBtn.tag = 1002;
            }
            
        }else if (indexPath.section == 2){
            cell.switchBtn.tag = 1003;
        }
        
        [self setContentValue2:cell forCurIndex:indexPath];
        return cell;
    }
    
}

// cell section 0 详情
-(void)setContentValue1:(PlanSearchTypeCell *)cell forCurIndex:(NSIndexPath *)index
{
    NSInteger row = index.row;
    UIColor *color;
    if ([[self.arraySalesParameter objectAtIndex:row] safeObjectForKey:@"color"]) {
       color = [CommonFuntion getColorValueByColorType:[[[self.arraySalesParameter objectAtIndex:row] safeObjectForKey:@"color"] integerValue]];
    }
    cell.imgIcon.image = [CommonFuntion createImageWithColor:color];
    
    NSString *nameStr = @"";
    if ([[self.arraySalesParameter objectAtIndex:row] safeObjectForKey:@"name"]) {
        nameStr = [[self.arraySalesParameter objectAtIndex:row] safeObjectForKey:@"name"];
    }
    cell.labelTitle.text = nameStr;
    
    BOOL select = [[[self.arraySalesParameter objectAtIndex:row] safeObjectForKey:@"select"] boolValue];
    if (select) {
        cell.imgSelected.hidden = NO;
    }else{
        cell.imgSelected.hidden = YES;
    }
}

// cell section 1 2 详情
-(void)setContentValue2:(PlanSearchSwitherTableViewCell *)cell forCurIndex:(NSIndexPath *)index
{
    NSInteger section = index.section;
    NSInteger row = index.row;
    if(section == 1){
        if (row == 0) {
            cell.labelTitle.text = @"显示任务";
            if ([self.showTask isEqualToString:@"1"]) {
                [cell.switchBtn setOn:YES];
            }else{
                [cell.switchBtn setOn:NO];
            }
            
        }else if(row == 1){
            cell.labelTitle.text = @"显示已完成任务";
            if ([self.isFinish isEqualToString:@"1"]) {
                [cell.switchBtn setOn:YES];
            }else{
                [cell.switchBtn setOn:NO];
            }
        }
    }else if (section == 2){
        cell.labelTitle.text = @"显示当天喜报";
        if ([self.showXB isEqualToString:@"1"]) {
            [cell.switchBtn setOn:YES];
        }else{
            [cell.switchBtn setOn:NO];
        }
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        NSInteger row = indexPath.row;
        
        NSDictionary *itemOld =[self.arraySalesParameter objectAtIndex:row];
        NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:itemOld];
        
        ///修改本地数据
        [mutableItemNew setValue:@(!([[mutableItemNew objectForKey:@"select"] boolValue])) forKey:@"select"];
        //修改数据
        [self.arraySalesParameter setObject: mutableItemNew atIndexedSubscript:row];
        
        [self.tableviewPlanSearchOption reloadData];
    }
    
}

///判断当前类型是否被选中
-(BOOL)isSelectedType:(NSString *)type{
    BOOL isSelected = FALSE;
    
    NSInteger count = 0;
    if (arrayTypeIds) {
        count = [arrayTypeIds count];
    }
    
    for (int i=0; !isSelected && i<count; i++) {
        if ([[arrayTypeIds objectAtIndex:i] isEqualToString:type]) {
            isSelected = TRUE;
        }
    }
    return isSelected;
}

-(void) switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    NSString *rlt = @"0";
    if ([switchButton isOn]) {
        rlt = @"1";
    }
    NSInteger tag = switchButton.tag;
    if (tag == 1001) {
        self.showTask = rlt;
    }else if (tag == 1002){
        self.isFinish = rlt;
    }else if (tag == 1003){
        self.showXB = rlt;
    }
    
}

#pragma mark -- 获取数据
- (void)getDataSourceForChooseType {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, GET_OFFICE_SCHEDULE_GET_TYPE] params:params success:^(id responseObj) {
        NSLog(@"获取日程类型成功：%@", responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            if ([responseObj  objectForKey:@"salesParameter"]) {
                NSArray *typeArr = [responseObj objectForKey:@"salesParameter"];
                
            }
        }
        [self.tableviewPlanSearchOption reloadData];
    } failure:^(NSError *error) {
        NSLog(@"获取日程类型失败：%@", error);
    }];
}
@end
