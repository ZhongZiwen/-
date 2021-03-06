//
//  EditNavigationSeatViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-26.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "EditNavigationNoIVRSeatViewController.h"
#import "LLCenterUtility.h"
#import "EditItemModel.h"
#import "LLcenterSheetMenuView.h"
#import "LLCenterSheetMenuModel.h"
#import "TPKeyboardAvoidingTableView.h"
#import "CommonFunc.h"
#import "EditItemTypeCellA.h"
#import "EditItemTypeCellB.h"
#import "EditItemTypeCellI.h"
#import "EditNavigationSeatCell.h"
#import "CommonNoDataView.h"
#import "SortNavigationSeatsViewController.h"
#import "AreaTypeViewController.h"
#import "SelectAreaTypeViewController.h"
#import "SelectTimeTypeViewController.h"

@interface EditNavigationNoIVRSeatViewController ()<UITableViewDataSource,UITableViewDelegate,LLCenterSheetMenuDelegate>{
    
    ///彩铃
    NSMutableArray *soureRing;
    ///接听策略
    NSMutableArray *sourceStrategy;
    
    ///标记修改item的下标
    NSInteger indexChangedItem;
}

@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property(strong,nonatomic) TPKeyboardAvoidingTableView *tableview;

///section 1  导航信息
@property(strong,nonatomic) NSMutableArray *dataSource;
///section 2  座席列表  用于缓存更改信息
@property(strong,nonatomic) NSMutableArray *dataSourceNavigationSeats;
///all data
@property(strong,nonatomic) NSMutableArray *dataSourceAll;

@end

@implementation EditNavigationNoIVRSeatViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑导航";
    self.view.backgroundColor = COLOR_BG;
    [super customBackButton];
    [self initTableview];
    [self initData];

    [self getNavigationDictionary];
}


#pragma mark - Nav Bar
-(void)addNavBar{
    
    
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
    
    EditItemModel *itemNavName = (EditItemModel *)[[[self.dataSourceAll objectAtIndex:0] objectForKey:@"content"] objectAtIndex:0];
    
    if ([[itemNavName.content stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        [CommonFuntion showToast:@"导航名称不能为空" inView:self.view];
        return;
    }
    
    if ([CommonFunc isStringNullObject:itemNavName.content]) {
        [CommonFuntion showToast:@"导航名称不能为null" inView:self.view];
        return;
    }
    
    ///发送请求
    [self editNavition];
}

#pragma mark - 初始化数据
-(void)initData{
    indexChangedItem = -1;
    soureRing = [[NSMutableArray alloc] init];
    
    sourceStrategy = [[NSMutableArray alloc] init];
    self.dataSource = [[NSMutableArray alloc] init];
    self.dataSourceNavigationSeats = [[NSMutableArray alloc] init];
    self.dataSourceAll = [[NSMutableArray alloc] init];
    
    
    [self.dataSourceNavigationSeats addObjectsFromArray:self.sourNavigationSeatsOld];
}


///获取下级导航id集合
-(NSString *)getChildNarIds{
    NSInteger count = 0;
    if(self.dataSourceNavigationSeats){
        count = [self.dataSourceNavigationSeats count];
    }
    NSMutableString *strIds = [[NSMutableString alloc] init];
    NSDictionary *item;
    for (int i=0; i<count; i++) {
        item = [self.dataSourceNavigationSeats objectAtIndex:i];
        if ([strIds isEqualToString:@""]) {
            [strIds appendString:[item safeObjectForKey:@"childNavigationId"]];
        }else{
            [strIds appendString:@","];
            [strIds appendString:[item safeObjectForKey:@"childNavigationId"]];
        }
    }
    return strIds;
}

#pragma mark - 测试数据
-(void)readTestData{
    
    /*
     navigationId(导航ID)
     navigationName(导航名称)
     navigationRingName(当前彩铃名称)
     navigationRingId(当前彩铃ID)
     navigationRingUrl(当前彩铃url)
     navigationKey(当前导航按键，按键进入时返回)
     timeType(时间类型，分流进入时返回)
     areaType(地区类型，分流进入时返回)
     sitRingId(当前导航的座席提示音)
     sitRingName(当前导航的座席提示音名称)
     answerStrategy(当前导航的接听策略，最后一级导航时返回)
     childNavigationHasChild (当前导航的下级导航是否有开再下一级导航的权限)
     navigationsetChild(当前导航的是否设置了下级导航0-是，1-否)
     navigationType(进入下级导航的方式 0-按键，1-分流)
     childNavigationKeyLength(下级导航的按键长度)
     
     */
    /*
     self.detail = [[NSDictionary alloc] initWithObjectsAndKeys:@"11111",@"navigationId",@"导航001",@"navigationName",@"啦啊啦啦啦.mp3",@"navigationRingName",@"10033454302",@"navigationRingId",@"http://www.cailing.mp3",@"navigationRingUrl",@"123456",@"navigationKeyPress",@"3002301",@"sitRingId",@"嘿咻嘿嘿.mp4",@"sitRingName",@"1",@"navigationsetChild",@"0",@"navigationType",@"2",@"childNavigationKeyLength", nil];
     */
}





///初始化接听策略
-(void)initListenStrategy{
    
    ///接听策略
    NSDictionary *item = [[NSDictionary alloc] initWithObjectsAndKeys:@"0",@"id",@"顺序接听",@"name", nil];
    [sourceStrategy addObject:item];
    item = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"id",@"随机接听",@"name", nil];
    [sourceStrategy addObject:item];
    item = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"id",@"平均接听",@"name", nil];
    [sourceStrategy addObject:item];
}


///根据详情信息 设置弹框默认选项√
-(void)initByDetailsData{
    NSString *ringId = [self.detail safeObjectForKey:@"navigationRingId"];
    NSString *answerStrategy =  [self.detail safeObjectForKey:@"answerStrategy"];

    ///默认铃声
    NSInteger count = 0;
    if (soureRing) {
        count = [soureRing count];
    }
    BOOL isFound = FALSE;
    LLCenterSheetMenuModel *model;
    for (int i=0; !isFound && i<count; i++) {
        model = [soureRing objectAtIndex:i];
        if ([model.itmeId isEqualToString:ringId]) {
            model.selectedFlag = @"yes";
            isFound = TRUE;
        }
    }
    
    
    ///接听策略
    if (sourceStrategy) {
        count = [sourceStrategy count];
    }
    isFound = FALSE;
    
    for (int i=0; !isFound && i<count; i++) {
        model = [sourceStrategy objectAtIndex:i];
        if ([model.itmeId isEqualToString:answerStrategy]) {
            model.selectedFlag = @"yes";
            isFound = TRUE;
            if ([answerStrategy isEqualToString:@"0"]) {
                self.listenStrategy = ListenStrategySequence;
            }else if ([answerStrategy isEqualToString:@"1"]) {
                self.listenStrategy = ListenStrategyRandom;
            }else if ([answerStrategy isEqualToString:@"2"]) {
                self.listenStrategy = ListenStrategyAverage;
            }
            
        }
    }
    
    [self.tableview reloadData];
}

///(0-顺序接听,1-随机接听,2-平均接听)
-(NSString *)getAnswerStrategy:(NSString *)flag{
    NSString *answerStrategy = @"";
    
    NSInteger intFlag = [flag integerValue];
    switch (intFlag) {
        case 0:
            answerStrategy = @"顺序接听";
            break;
        case 1:
            answerStrategy = @"随机接听";
            break;
        case 2:
            answerStrategy = @"平均接听";
            break;
            
        default:
            break;
    }
    
    return answerStrategy;
}

#pragma mark - 根据操作类型 新增/编辑 初始化数据源
-(void)initDataWithActionType{
    
    NSString *navigationName = [self.detail safeObjectForKey:@"navigationName"];
    NSString *ringName = [self.detail safeObjectForKey:@"navigationRingName"];
    NSString *ringId = [self.detail safeObjectForKey:@"navigationRingId"];
    NSString *answerStrategy =  [self.detail safeObjectForKey:@"answerStrategy"];
    ///从详情里获取
    
    EditItemModel *model;
    
    model = [[EditItemModel alloc] init];
    model.title = @"导航名称:";
    model.content = navigationName;
    model.placeholder = @"1-100个中英文、数字特殊字符";
    model.cellType = @"cellA";
    model.keyStr = @"";
    model.keyType = @"";
    [self.dataSource addObject:model];
    

    
    ///彩铃开通了
    if (self.ringStatus == 1) {
        model = [[EditItemModel alloc] init];
        model.title = @"彩铃:";
        model.cellType = @"cellB";
        model.placeholder = @"(当电话转接到本层后播放音频)";
        model.itemId = ringId;
        model.content = ringName;
        model.keyStr = @"ringId";
        model.keyType = @"ringId";
        [self.dataSource addObject:model];
    }
    
    
    
    model = [[EditItemModel alloc] init];
    model.title = @"接听策略:";
    model.itemId = answerStrategy;
    model.content = [self getAnswerStrategy:answerStrategy];
    model.placeholder = @"";
    model.cellType = @"cellB";
    model.keyStr = @"callModel";
    model.keyType = @"callModel";
    [self.dataSource addObject:model];
    
    
    [self updateChildNavigationByAction:@""];
    
    NSLog(@"self.dataSource:%@",self.dataSource);
    for (int i=0; i<[self.dataSource count]; i++) {
        EditItemModel *item  = (EditItemModel*) [self.dataSource objectAtIndex:i];
        NSLog(@"%@  %@",item.title,item.cellType);
    }
    
    [self.tableview reloadData];
}


///根据进入方式 更新数据源   添加下级导航列表还是删除下级导航列表section2

-(void)updateChildNavigationByAction:(NSString *)action{
    NSLog(@"updateChildNavigationByAction:%@",action);
    /*
    [self.dataSourceAll removeAllObjects];
    
    NSMutableDictionary *dicDataSource = [[NSMutableDictionary alloc] init];
    NSMutableArray *arraySection = [[NSMutableArray alloc] init];
    
    [dicDataSource setObject:@"导航信息" forKey:@"head"];
    [dicDataSource setObject:self.dataSource forKey:@"content"];
    
    [self.dataSourceAll addObject:dicDataSource];
    */
    
    if (self.dataSourceAll && [self.dataSourceAll count] > 1) {
        NSLog(@"---updateChildNavigationByAction-1->");
        NSDictionary *section0 = [self.dataSourceAll objectAtIndex:0];
        NSMutableDictionary *mutableSection0 = [NSMutableDictionary dictionaryWithDictionary:section0];
        [mutableSection0 setObject:self.dataSource forKey:@"content"];
        [self.dataSourceAll replaceObjectAtIndex:0 withObject:mutableSection0];
    }else{
        NSMutableDictionary *dicDataSource = [[NSMutableDictionary alloc] init];
        NSMutableArray *arraySection = [[NSMutableArray alloc] init];
        
        [dicDataSource setObject:@"导航信息" forKey:@"head"];
        [dicDataSource setObject:self.dataSource forKey:@"content"];
        
        [self.dataSourceAll addObject:dicDataSource];
        
    }
    
    [self initSectionSeats];
    
   
    
    NSLog(@"self.dataSourceAll:%@",self.dataSourceAll);
    
}

///初始化座席列表
-(void)initSectionSeats{
    
    if (self.dataSourceAll && [self.dataSourceAll count] > 1) {
        [self.dataSourceAll removeObjectAtIndex:1];
    }
    
    NSMutableDictionary *dicDataSource = [[NSMutableDictionary alloc] init];
    NSMutableArray *arraySection = [[NSMutableArray alloc] init];
    
    NSInteger count = 0;
    if(self.dataSourceNavigationSeats){
        count = [self.dataSourceNavigationSeats count];
    }
    
    
    [dicDataSource setObject:@"下级导航列表" forKey:@"head"];
    [dicDataSource setObject:self.dataSourceNavigationSeats forKey:@"content"];
    
    [self.dataSourceAll addObject:dicDataSource];
    
}


#pragma mark - 初始化选择条件数据
-(void)initOptionsData{
    ///接听策略
    [self initListenStrategy];
    
    NSInteger count = 0;
    ///彩铃
    NSMutableArray *array1 = [[NSMutableArray alloc] init];
    count = 0;
    if (soureRing) {
        count = [soureRing count];
    }
    if (count > 0) {
        ///默认空彩铃
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = @"";
        model.title = @"(请选择)";
        model.selectedFlag = @"no";
        [array1 addObject:model];
    }
    for (int i=0; i<count; i++) {
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = [[soureRing objectAtIndex:i] safeObjectForKey:@"id"];
        model.title = [[soureRing objectAtIndex:i] safeObjectForKey:@"name"];
        model.selectedFlag = @"no";
        [array1 addObject:model];
    }
    
    ///接听策略
    NSMutableArray *array4 = [[NSMutableArray alloc] init];
    if (sourceStrategy) {
        count = [sourceStrategy count];
    }
    for (int i=0; i<count; i++) {
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = [[sourceStrategy objectAtIndex:i] safeObjectForKey:@"id"];
        model.title = [[sourceStrategy objectAtIndex:i] safeObjectForKey:@"name"];
        model.selectedFlag = @"no";
        [array4 addObject:model];
    }
    

    [soureRing removeAllObjects];
    [sourceStrategy removeAllObjects];
    [soureRing addObjectsFromArray:array1];
    [sourceStrategy addObjectsFromArray:array4];
    
    
    NSLog(@"soureRing:%@",soureRing);
    
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


#pragma mark - 座席排序
-(void)sortSeats{
    SortNavigationSeatsViewController *contorller = [[SortNavigationSeatsViewController alloc] init];
    contorller.dataSourceOld = self.dataSourceNavigationSeats;
    contorller.navitaionId = [self.detail safeObjectForKey:@"navigationId"];
    __weak typeof(self) weak_self = self;
    contorller.NotifyNavigationSitList = ^(NSMutableArray *array){
        ///刷新座席列表  使用本地数据
        [weak_self.dataSourceNavigationSeats removeAllObjects];
        [weak_self.dataSourceNavigationSeats addObjectsFromArray:array];
        [weak_self initSectionSeats];
        [weak_self.tableview reloadData];
    };
    
    [self.navigationController pushViewController:contorller animated:YES];
}

#pragma mark - tableview

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 40;
    }
    return 20;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1 && self.dataSourceNavigationSeats && [self.dataSourceNavigationSeats count] > 0) {
        UIView *headview =[[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 40)];
        headview.backgroundColor = COLOR_BG;
        
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 20)];
        labelTitle.textColor = [UIColor blackColor];
        labelTitle.font = [UIFont systemFontOfSize:15.0];
        labelTitle.text = @"坐席列表";
        [headview addSubview:labelTitle];
        
        
        ///当为顺序接听时 才显示排序按钮
        if (self.listenStrategy == ListenStrategySequence) {
            if (self.dataSourceNavigationSeats && [self.dataSourceNavigationSeats count] > 0) {
                
                UIButton *btnSort = [UIButton buttonWithType:UIButtonTypeCustom];
                btnSort.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-40, 5, 30, 30);
                [btnSort setBackgroundImage:[UIImage imageNamed:@"icon_sort.png"] forState:UIControlStateNormal];
                [btnSort addTarget:self action:@selector(sortSeats) forControlEvents:UIControlEventTouchUpInside];
                [headview addSubview:btnSort];
            }
        }
        
        return headview;
    }
    return nil;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.dataSourceAll) {
        return [self.dataSourceAll count];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.dataSourceAll objectAtIndex:section] objectForKey:@"content"] count];
}




-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 20;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditItemModel* item = (EditItemModel*) [[[self.dataSourceAll objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];
    
    ///导航信息
    if (indexPath.section == 0) {
        if ([item.cellType isEqualToString:@"cellA"]) {
            EditItemTypeCellA *cell = [tableView dequeueReusableCellWithIdentifier:@"EditItemTypeCellAIdentify"];
            if (!cell)
            {
                NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"EditItemTypeCellA" owner:self options:nil];
                cell = (EditItemTypeCellA*)[array objectAtIndex:0];
                [cell awakeFromNib];
            }
            
            __weak typeof(self) weak_self = self;
            cell.textValueChangedBlock = ^(NSString *valueString){
                NSLog(@"index:%ti valueString:%@",indexPath.row,valueString);
                [weak_self notifyDataSource:indexPath valueString:valueString idString:@""];
            };
            
            [cell setCellDetail:item];
            return cell;
        }else if ([item.cellType isEqualToString:@"cellB"]) {
            EditItemTypeCellB *cell = [tableView dequeueReusableCellWithIdentifier:@"EditItemTypeCellBIdentify"];
            if (!cell)
            {
                NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"EditItemTypeCellB" owner:self options:nil];
                cell = (EditItemTypeCellB*)[array objectAtIndex:0];
                [cell awakeFromNib];
            }
            __weak typeof(self) weak_self = self;
            cell.SelectDataTypeBlock = ^(NSInteger type){
               
                ///导航名称
                ///彩铃
                ///接听策略
            
                if (indexPath.section == 0) {
                    
                    NSInteger falg = 0;
                    ///彩铃开通了
                    if (self.ringStatus == 1) {
                        if (indexPath.row == 1) {
                            falg = 1;
                        }else if (indexPath.row == 2) {
                            falg = 2;
                        }
                    }else{
                        ///隐藏彩铃
                        if (indexPath.row == 1) {
                            falg = 2;
                        }
                    }

                    [weak_self showMenuByFlag:falg withIndexPath:indexPath];
                }
                
            };
            [cell setCellDetail:item];
            return cell;
        }
    }else{
        ///座席
        EditNavigationSeatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditNavigationSeatCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"EditNavigationSeatCell" owner:self options:nil];
            cell = (EditNavigationSeatCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
            [cell setCellFrame:1];
        }
        NSDictionary *item = [[[self.dataSourceAll objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];
        
        [cell setCellDetail:item withIndexPath:indexPath];
        
        
        __weak typeof(self) weak_self = self;
        ///修改等待时长
        cell.ChangeDurationBlock = ^(NSInteger index){
            NSLog(@"index:%ti",index);
            [weak_self showEditViewForWaitDuration:index];
        };
        
        
        ///地区
        cell.ChangeAreaTypeBlock = ^(NSInteger index){
            NSLog(@"index:%ti",index);
            [weak_self gotoAreaTypeView:@"sit" andNavigationSitItem:[self.dataSourceNavigationSeats objectAtIndex:index]];
        };
        
        ///时间
        cell.ChangeTimeTypeBlock = ^(NSInteger index){
            NSLog(@"index:%ti",index);
            [weak_self gotoTimeTypeView:@"sit" andNavigationSitItem:[self.dataSourceNavigationSeats objectAtIndex:index]];
        };
        
        return cell;
    }
    
    return nil;
}


///更新数据源
-(void)notifyDataSource:(NSIndexPath *)indexPath valueString:(NSString *)valueStr idString:(NSString *)ids{
    
    EditItemModel *model = (EditItemModel *)[[[self.dataSourceAll objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];
    model.content = valueStr;
    model.itemId = ids;
}

///修改等待时长
-(void)notifyDataSourceNavigationSeat:(NSString *)duration withIndex:(NSInteger)index{
    NSDictionary *item = [self.dataSourceNavigationSeats objectAtIndex:index];
    ///修改本地数据
    NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:item];
    [mutableItemNew setObject:duration forKey:@"WAITDURATION"];
    //修改数据
    [self.dataSourceNavigationSeats setObject: mutableItemNew atIndexedSubscript:index];
    
    [self.tableview reloadData];
}

///跳转到地区页面
-(void)gotoAreaTypeView:(NSString *)navigationOrSit andNavigationSitItem:(NSDictionary *)sitItem{
    NSString *navigationId = [self.detail  safeObjectForKey:@"navigationId"];
    SelectAreaTypeViewController *controller = [[SelectAreaTypeViewController alloc] init];
    controller.navigationOrSit = navigationOrSit;
    controller.navigationId = navigationId;
    controller.detail = sitItem;
    controller.flagOfNeedJudge = @"no";
    ///导航详情  地区策略
    controller.areaStrategyNavDic = self.detail;
    [self.navigationController pushViewController:controller animated:YES];
}


///跳转到时间页面
-(void)gotoTimeTypeView:(NSString *)navigationOrSit andNavigationSitItem:(NSDictionary *)sitItem{
    NSString *navigationId = [self.detail  safeObjectForKey:@"navigationId"];
    SelectTimeTypeViewController *controller = [[SelectTimeTypeViewController alloc] init];
    controller.navigationOrSit = navigationOrSit;
    controller.navigationId = navigationId;
    controller.detail = sitItem;
    controller.flagOfNeedJudge = @"no";
    ///导航详情  时间策略
    controller.timeStrategyNavDic = self.detail;
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - 弹框修改等待时间
-(void)showEditViewForWaitDuration:(NSInteger)index{
    indexChangedItem = index;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改等待时长" message:nil
                                                   delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [alert textFieldAtIndex:0].placeholder = @"15-60秒之间";
    [alert textFieldAtIndex:0].clearButtonMode = UITextFieldViewModeWhileEditing;
    [alert textFieldAtIndex:0].text = [[self.dataSourceNavigationSeats objectAtIndex:indexChangedItem]safeObjectForKey:@"WAITDURATION"];
    [alert setTag:1001];
    [alert show];
}

#pragma mark alertView的回调函数
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1001)
    {
        if(buttonIndex == 0)
        {
            return;
        }
        else if(buttonIndex == 1)
        {
            if([[alertView textFieldAtIndex:0].text length] < 1)
            {
                [CommonFuntion showToast:@"等待时长不能为空" inView:self.view];
            }
            else
            {
                //修改等待时长
                //组装参数
                NSString *duration = [alertView textFieldAtIndex:0].text;
                NSLog(@"duration:%@",duration);
                
                if ([duration integerValue] < 15 || [duration integerValue] > 60) {
                    [CommonFuntion showToast:@"等待时长为15-60秒之间" inView:self.view];
                    return;
                }
                
                [self editSitWaitDuration:duration];
            }
        }
    }
    
}

#pragma mark - 弹框
///根据flag 弹框  1彩铃 2座席提示音 3进入方式 4按键长度 5接听策略 6时间类型 7 地区类型
-(void)showMenuByFlag:(NSInteger)flag withIndexPath:(NSIndexPath *)indexPath{
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];

    
    NSArray *array = nil;
    NSString *title = @"";
    /// 0单选  1多选
    NSInteger type = 0;
    LLcenterSheetMenuView *sheet;
    
    if (flag == 1){
        title = @"彩铃";
        type = 0;
        array = soureRing;
    }else if (flag == 2){
        title = @"接听策略";
        type = 0;
        array = sourceStrategy;

    }
    
    if (array == nil || [array count] == 0) {
        NSLog(@"选择数据源为空");
        NSString *strMsg = @"";
        ///彩铃开通了
        if (self.ringStatus == 1) {
            if (flag == 1) {
                strMsg = @"彩铃加载失败";
            }
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
    ///彩铃
    if (flag == 1){
        [self changeSelectedFlag:soureRing index:index];
        
        ///@"请选择状态";
        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[soureRing objectAtIndex:index];
        NSLog(@"title:%@   ids:%@",model.title,model.itmeId);

        

        ///彩铃开通了
        if (self.ringStatus == 1) {
            [self notifyDataSource:[NSIndexPath indexPathForRow:1 inSection:0] valueString:model.title idString:model.itmeId];
        }else{
        }

        
    }else if (flag == 2){
        ///接听策略
        [self changeSelectedFlag:sourceStrategy index:index];
        
        
        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[sourceStrategy objectAtIndex:index];
        NSLog(@"title:%@   ids:%@",model.title,model.itmeId);
        if ([model.itmeId isEqualToString:@"0"]) {
            self.listenStrategy = ListenStrategySequence;
        }else if ([model.itmeId isEqualToString:@"1"]) {
            self.listenStrategy = ListenStrategyRandom;
        }else if ([model.itmeId isEqualToString:@"2"]) {
            self.listenStrategy = ListenStrategyAverage;
        }
        
        ///彩铃开通了
        if (self.ringStatus == 1) {
            [self notifyDataSource:[NSIndexPath indexPathForRow:2 inSection:0] valueString:model.title idString:model.itmeId];
        }else{
            [self notifyDataSource:[NSIndexPath indexPathForRow:1 inSection:0] valueString:model.title idString:model.itmeId];
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


#pragma mark - 导航选择时间类型
-(void)navigationTimeType:(NSIndexPath *)indexPath{
    NSString *navigationId = [self.detail  safeObjectForKey:@"navigationId"];

    SelectTimeTypeViewController *controller = [[SelectTimeTypeViewController alloc] init];
    controller.navigationOrSit = @"navigation";
    controller.navigationId = navigationId;
    controller.detail = self.detail;
    __weak typeof(self) weak_self = self;
    controller.TimeTypeBlock = ^(NSString *timeType){
        ///返回时间类型 和具体的时间值
        ///类型在UI上展示出来
        ///重新请求详情信息
        
        [weak_self notifyDataSource:[NSIndexPath indexPathForRow:3 inSection:0] valueString:timeType idString:@""];
        [weak_self.tableview reloadData];
        [self getNavigationDetails];
    };
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - 导航选择地区类型
-(void)navigationAreaType:(NSIndexPath *)indexPath{
    NSString *navigationId = [self.detail  safeObjectForKey:@"navigationId"];
    
    SelectAreaTypeViewController *controller = [[SelectAreaTypeViewController alloc] init];
    controller.navigationOrSit = @"navigation";
    controller.navigationId = navigationId;
    controller.detail = self.detail;
    
    __weak typeof(self) weak_self = self;
    controller.AreaTypeBlock = ^(NSString *areaType){
        ///返回地区类型 和具体的地区值
        ///类型在UI上展示出来
        
        [weak_self notifyDataSource:[NSIndexPath indexPathForRow:4 inSection:0] valueString:areaType idString:@""];
        [weak_self.tableview reloadData];
        [self getNavigationDetails];
    };
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - 网络请求

#pragma mark 获取初始化导航字典信息
-(void)getNavigationDictionary{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_INIT_NAVIGATION_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"初始化导航jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            if ([jsonResponse objectForKey:@"resultMap"]) {
                
                ///彩铃
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"] != [NSNull null]) {
                    NSArray *ringList = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"];
                    NSLog(@"ringList:%@",ringList);
                    if (ringList) {
                        [soureRing addObjectsFromArray:ringList];
                    }
                }
                
                
                ///地区
                [self addNavBar];
                ///初始化数据
                [self initOptionsData];
                [self initByDetailsData];
                [self initDataWithActionType];
                
            }else{
                NSLog(@"data------>:<null>");
                [CommonFuntion showToast:@"加载异常" inView:self.view];
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getNavigationDictionary];
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



///编辑座席等待时长
-(void)editSitWaitDuration:(NSString *)duration{
    /*
     sitId
     sitWaitDuration
     */
    
    NSDictionary *item = [[[self.dataSourceAll objectAtIndex:1] objectForKey:@"content"] objectAtIndex:indexChangedItem];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rDict setValue: [self.detail safeObjectForKey:@"navigationId"] forKey:@"navigationId"];
    [rDict setValue:[item safeObjectForKey:@"SITID"] forKey:@"sitId"];
    [rDict setValue:duration forKey:@"sitWaitDuration"];
    
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_EDIT_SEAT_WAIT_DURATION_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"修改等待时长jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [CommonFuntion showToast:@"修改成功" inView:self.view];
            ///修改成功刷新数据
            [self notifyDataSourceNavigationSeat:duration withIndex:indexChangedItem];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self editSitWaitDuration:duration];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"修改失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
    
}


#pragma mark 获取导航详情
-(void)getNavigationDetails{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    ///非根目录则传
    //    if (self.navigationId) {
    [rDict setValue:[self.detail  safeObjectForKey:@"navigationId"] forKey:@"navigationId"];
    //    }
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    
    NSLog(@"rParam:%@",rParam);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_NAVIGATION_DETAILS_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"导航详情jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            if ([jsonResponse objectForKey:@"resultMap"]) {
                self.detail = [jsonResponse objectForKey:@"resultMap"] ;
            }else{
                NSLog(@"data------>:<null>");
                [CommonFuntion showToast:@"加载异常" inView:self.view];
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getNavigationDetails];
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




#pragma mark - 编辑导航设置

-(void)editNavition{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    for (int i=0; i<[self.dataSourceAll count]; i++) {
        NSArray *array = [[self.dataSourceAll objectAtIndex:i] objectForKey:@"content"];
        
        if (i == 0) {
            for (int k=0; k<[array count]; k++) {
                EditItemModel *item  = (EditItemModel*) [array objectAtIndex:k];
                
                if (item.keyType && item.keyType.length > 0) {
                    if (item.keyStr && item.keyStr.length > 0) {
                        [rDict setValue:item.itemId forKey:item.keyStr];
                        NSLog(@"key: %@   value: %@",item.keyStr,item.content);
                    }
                }else{
                    if (item.keyStr && item.keyStr.length > 0) {
                        [rDict setValue:item.content forKey:item.keyStr];
                        NSLog(@"key: %@   value: %@",item.keyStr,item.content);
                    }
                }
                
            }
        }else if (i == 1){
            
        }
    }
    ///彩铃未开通 不可编辑
    if (self.ringStatus == 0) {
        [rDict setValue:[self.detail safeObjectForKey:@"navigationRingId"] forKey:@"ringId"];
    }
    
    [rDict setValue:[self.detail safeObjectForKey:@"navigationId"] forKey:@"navigationId"];
//    [rDict setValue:[self.detail safeObjectForKey:@"navigationName"] forKey:@"navigationName"];
    
    NSLog(@"rDict:%@",rDict);

    //    [rDict setValue:self.customerId forKey:@"customerId"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_EDIT_NAVIGATION_IVR_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"编辑导航jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [CommonFuntion showToast:@"保存成功" inView:self.view];
            [self actionSuccess];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self editNavition];
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
    if (self.NotifyNavigationList) {
        self.NotifyNavigationList();
    }
    [self.navigationController popViewControllerAnimated:YES];
}




@end
