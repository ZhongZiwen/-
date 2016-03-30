//
//  AddNewNavigationViewController.m
//  
//
//  Created by sungoin-zjp on 16/1/6.
//
//

#import "AddNewNavigationViewController.h"

#import "EditItemModel.h"
#import "LLcenterSheetMenuView.h"
#import "LLCenterSheetMenuModel.h"
#import "TPKeyboardAvoidingTableView.h"
#import "CommonFunc.h"
#import "EditItemTypeCellA.h"
#import "EditItemTypeCellB.h"
#import "EditItemTypeCellI.h"

#import "SelectAreaTypeViewController.h"
#import "SelectTimeTypeViewController.h"
#import "AddSitToNavigationViewController.h"
#import "SitListViewController.h"
#import "CustomTabBarViewController.h"

@interface AddNewNavigationViewController ()<UITableViewDataSource,UITableViewDelegate,LLCenterSheetMenuDelegate>{
    ///彩铃
    NSMutableArray *soureRing;
    ///接听策略
    NSMutableArray *sourceStrategy;
    
    ///选择的时间策略与地区策略
    NSDictionary *timeStrategy;
    NSDictionary *areaStrategy;
    
    ///新导航的id
    NSString *newNavigationId;
}

@property(strong,nonatomic) TPKeyboardAvoidingTableView *tableview;
@property(strong,nonatomic) NSMutableArray *dataSource;


@end

@implementation AddNewNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"添加分组";
    self.view.backgroundColor = COLOR_BG;
    
    [self addNavBar];
    [self initTableview];
    [self initData];

    [self initDataWithActionType];
    [self getNavigationDictionary];
}


#pragma mark - Nar Bar
-(void)addNavBar{
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonAction)];
    self.navigationItem.rightBarButtonItem = rightButton;
}


///保存
-(void)rightBarButtonAction{
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (![CommonFunc checkNetworkState]) {
        [CommonFuntion showToast:@"无网络可用,加载失败" inView:self.view];
        return;
    }
    
    
    EditItemModel *itemNavName = (EditItemModel *)[self.dataSource objectAtIndex:0];
    if ([[itemNavName.content stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        [CommonFuntion showToast:@"分组名称不能为空" inView:self.view];
        return;
    }
    
    if ([CommonFunc isStringNullObject:itemNavName.content]) {
        [CommonFuntion showToast:@"分组名称不能为null" inView:self.view];
        return;
    }
    
    ///按键进入
    if (self.enterNavigationWay == EnterNavWayByKeyNum) {
        EditItemModel *itemKeyNum = (EditItemModel *)[self.dataSource objectAtIndex:1];
        if ([[itemKeyNum.content stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
            [CommonFuntion showToast:@"分组按键不能为空" inView:self.view];
            return;
        }
        
        if (self.childNavigationKeyLength > 0 && self.childNavigationKeyLength < 7) {
            
            if (itemKeyNum.content.length != self.childNavigationKeyLength) {
                [CommonFuntion showToast:[NSString  stringWithFormat:@"分组按键长度为%ti",self.childNavigationKeyLength] inView:self.view];
                return;
            }
        }
    }
    
    [self addNavition];
}

///添加坐席到当前导航
-(void)addSitToNavigation:(NSString *)navigationId{
    AddSitToNavigationViewController *controller = [[AddSitToNavigationViewController alloc] init];
    controller.navigationId = navigationId;
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - 初始化数据
-(void)initData{
    
    NSLog(@"self.navigationDic:%@",self.navigationDic);
    
    newNavigationId = @"";
    soureRing = [[NSMutableArray alloc] init];
    sourceStrategy = [[NSMutableArray alloc] init];
    self.dataSource = [[NSMutableArray alloc] init];
    
    ///初始化导航信息
    ///进入方式
    if ([[self.navigationDic safeObjectForKey:@"navigationType"] isEqualToString:@"0"]) {
        self.enterNavigationWay = EnterNavWayByKeyNum;
    }else{
        self.enterNavigationWay = EnterNavWayShunt;
    }
    
    ///按键长度
    self.childNavigationKeyLength = [[self.navigationDic safeObjectForKey:@"childNavigationKeyLength"] integerValue];
}

///初始化接听策略
-(void)initStrategy{

    ///接听策略
    NSDictionary *item = [[NSDictionary alloc] initWithObjectsAndKeys:@"0",@"id",@"顺序接听",@"name", nil];
    [sourceStrategy addObject:item];
    item = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"id",@"随机接听",@"name", nil];
    [sourceStrategy addObject:item];
    item = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"id",@"平均接听",@"name", nil];
    [sourceStrategy addObject:item];
}


#pragma mark - 根据操作类型 新增/编辑 初始化数据源
-(void)initDataWithActionType{
    
    EditItemModel *model;

    model = [[EditItemModel alloc] init];
    model.title = @"分组名称:";
    model.content = @"";
    model.placeholder = @"1-100个中英文、数字特殊字符";
    model.cellType = @"cellA";
    model.keyStr = @"navigationName";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    ///按键进入
    if (self.enterNavigationWay == EnterNavWayByKeyNum) {
        model = [[EditItemModel alloc] init];
        model.title = @"分组按键:";
        model.content = @"";
        if (self.childNavigationKeyLength > 0 && self.childNavigationKeyLength < 7) {
            model.placeholder = [NSString stringWithFormat:@"请输入%ti位分组按键",self.childNavigationKeyLength];
        }else{
            model.placeholder = @"请输入分组按键";
        }
        
        model.cellType = @"cellA";
        model.keyStr = @"navigationKey";
        model.keyType = @"";
        [self.dataSource addObject:model];
    }
    
    ///分流方式
    if (self.enterNavigationWay == EnterNavWayShunt) {
        
        model = [[EditItemModel alloc] init];
        model.title = @"彩铃:";
        model.itemId = @"";
        model.content = @"";
        model.placeholder = @"(当电话转接到本层后播放音频)";
        model.cellType = @"cellB";
        model.keyStr = @"ringId";
        model.keyType = @"ringId";
        [self.dataSource addObject:model];
        
        ///时间类型  全部时间1 星期时间 2  节假日3
        NSString *timeType = [self.navigationDic safeObjectForKey:@"timeType"];
        timeType = [CommonFunc getNavTimeType:timeType];
        
        model = [[EditItemModel alloc] init];
        model.title = @"时间类型:";
        model.itemId = @"";
        model.content = timeType;
        model.placeholder = @"";
        model.cellType = @"cellB";
        model.keyStr = @"";
        model.keyType = @"";
        [self.dataSource addObject:model];
        
        NSString *areaName = @"";
        ///全部地区
        if ([[self.navigationDic safeObjectForKey:@"areaCode"] isEqualToString:@"1"]) {
            areaName = @"全部地区";
        }else{
            areaName = [self.navigationDic safeObjectForKey:@"areaName"];
        }
        
        model = [[EditItemModel alloc] init];
        model.title = @"地区类型:";
        model.itemId = @"";
        model.content = areaName;
        model.placeholder = @"";
        model.cellType = @"cellB";
        model.keyStr = @"";
        model.keyType = @"";
        [self.dataSource addObject:model];
    }
    
    model = [[EditItemModel alloc] init];
    model.title = @"接听策略:";
    model.itemId = @"0";
    model.content = [self getAnswerStrategy:@"0"];
    model.placeholder = @"";
    model.cellType = @"cellB";
    model.keyStr = @"answerStrategy";
    model.keyType = @"answerStrategy";
    [self.dataSource addObject:model];
    
    
    NSLog(@"self.dataSource:%@",self.dataSource);
    for (int i=0; i<[self.dataSource count]; i++) {
        EditItemModel *item  = (EditItemModel*) [self.dataSource objectAtIndex:i];
        NSLog(@"%@  %@",item.title,item.cellType);
    }
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


#pragma mark - 初始化选择条件数据
-(void)initOptionsData{
    ///初始化接听策略
    [self initStrategy];
    
    
    NSInteger  count = 0;
    ///彩铃
    NSMutableArray *array1 = [[NSMutableArray alloc] init];
    count = 0;
    if (soureRing) {
        count = [soureRing count];
    }
    
    ///默认空彩铃
    LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
    model.itmeId = @"";
    model.title = @"(请选择)";
    model.selectedFlag = @"no";
    [array1 addObject:model];
    
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
        if (i == 0) {
            model.selectedFlag = @"yes";
        }
        
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
    self.tableview = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStyleGrouped];
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
    return 50.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditItemModel* item = (EditItemModel*) [self.dataSource objectAtIndex:indexPath.row];
    
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
            //            NSLog(@"index:%ti valueString:%@",indexPath.row,valueString);
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
            ///1彩铃  2时间 3地区 4接听策略
            
            NSInteger falg = 1;
            ///按键进入
            if (self.enterNavigationWay == EnterNavWayByKeyNum) {
                ///接听策略
                if (indexPath.row == 2) {
                    falg = 4;
                }
            }else{
                if (indexPath.row == 1) {
                    falg = 1;
                }else if (indexPath.row == 2) {
                    falg = 2;
                }else if (indexPath.row == 3) {
                    falg = 3;
                }else if (indexPath.row == 4) {
                    falg = 4;
                }
            }
            
            [weak_self showMenuByFlag:falg withIndexPath:indexPath];
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
    
}


#pragma mark - 弹框
///根据flag 弹框  1彩铃  2时间类型 3 地区类型 4接听策略
-(void)showMenuByFlag:(NSInteger)flag withIndexPath:(NSIndexPath *)indexPath{
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (flag == 2) {
        [self navigationTimeType:indexPath];
        return;
    }else if (flag == 3){
        [self navigationAreaType:indexPath];
        return;
    }
    
    
    NSArray *array = nil;
    NSString *title = @"";
    /// 0单选  1多选
    NSInteger type = 0;
    LLcenterSheetMenuView *sheet;
    
    if (flag == 1){
        title = @"彩铃";
        type = 0;
        array = soureRing;
    }else if (flag == 4){
        title = @"接听策略";
        type = 0;
        array = sourceStrategy;
    }
    
    if (array == nil || [array count] == 0) {
        NSLog(@"选择数据源为空");
        NSString *strMsg = @"";
        if (flag == 1) {
            strMsg = @"彩铃加载失败";
        }else if (flag == 4){
            strMsg = @"接听策略加载失败";
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
        [self notifyDataSource:[NSIndexPath indexPathForRow:1 inSection:0] valueString:model.title idString:model.itmeId];
    }else if (flag == 4){
        ///接听策略
        [self changeSelectedFlag:sourceStrategy index:index];
        
        
        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[sourceStrategy objectAtIndex:index];
        NSLog(@"title:%@   ids:%@",model.title,model.itmeId);
        NSInteger index = 2;
        ///按键进入
        if (self.enterNavigationWay == EnterNavWayByKeyNum) {
            index = 2;
        }else{
            index = 4;;
        }

        [self notifyDataSource:[NSIndexPath indexPathForRow:index inSection:0] valueString:model.title idString:model.itmeId];
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
    
    NSString *navigationId = [self.navigationDic  safeObjectForKey:@"navigationId"];
    
    SelectTimeTypeViewController *controller = [[SelectTimeTypeViewController alloc] init];
    controller.viewFromFlag = @"addnavi";
    controller.navigationOrSit = @"navigation";
    controller.navigationId = navigationId;
    controller.detail = self.navigationDic;
    controller.flagOfNeedJudge = @"yes";
    __weak typeof(self) weak_self = self;
    controller.TimeTypeAddNaviBlock = ^(NSString *timeType,NSDictionary *newNaviInfo,NSDictionary *dicSelectedTimeType){
        NSLog(@"newNaviInfo:%@",newNaviInfo);
        self.navigationDic = newNaviInfo;
        timeStrategy = dicSelectedTimeType;
        [weak_self notifyDataSource:indexPath valueString:timeType idString:@""];
        [weak_self.tableview reloadData];
    };
    
    [self.navigationController pushViewController:controller animated:YES];
    
}

#pragma mark - 导航选择地区类型
-(void)navigationAreaType:(NSIndexPath *)indexPath{
    
    NSString *navigationId = [self.navigationDic  safeObjectForKey:@"navigationId"];
    
    SelectAreaTypeViewController *controller = [[SelectAreaTypeViewController alloc] init];
    controller.viewFromFlag = @"addnavi";
    controller.navigationOrSit = @"navigation";
    controller.navigationId = navigationId;
    controller.detail = self.navigationDic;
    controller.flagOfNeedJudge = @"yes";
    
    __weak typeof(self) weak_self = self;
    controller.AreaTypeAddNaviBlock = ^(NSString *areaType,NSDictionary *newNaviInfo,NSDictionary *dicSelectedAreaType){
        ///返回地区类型 和具体的地区值
        NSLog(@"areaType:%@",areaType);
        self.navigationDic = newNaviInfo;
        areaStrategy = dicSelectedAreaType;
        [weak_self notifyDataSource:indexPath valueString:areaType idString:@""];
        [weak_self.tableview reloadData];
    };
    
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - 获取地区策略
-(NSDictionary *)getAreaTypeDefault{
    NSString *aeraType = [self.navigationDic safeObjectForKey:@"timeType"];
    
    NSMutableDictionary *dicAreaType = [NSMutableDictionary dictionaryWithDictionary:nil];
    [dicAreaType setValue:aeraType forKey:@"navigationAreaType"];
    
    NSString *areaCode = @"";
    NSString *areaName = @"";
    ///全部
    if ([aeraType isEqualToString:@"1"]) {
        
    }else{
        areaCode = [[self.navigationDic safeObjectForKey:@"areaCode"]stringByReplacingOccurrencesOfString:@";" withString:@","];
        areaName = [self.navigationDic safeObjectForKey:@"areaName"];
    }
    [dicAreaType setValue:areaCode forKey:@"navigationAreaCode"];
    ///导航地区策略的名称
    [dicAreaType setValue:areaName forKey:@"navigationAreaName"];
    
    return dicAreaType;
}

#pragma mark - 获取时间策略
-(NSDictionary *)getTimeTypeDefault{
    NSString *timeType = @"";
    timeType = [self.navigationDic safeObjectForKey:@"timeType"];
    
    NSMutableDictionary *dicTimeType = [NSMutableDictionary dictionaryWithDictionary:nil];
    [dicTimeType setValue:timeType forKey:@"navigationTimeType"];
    ///节假日
    if ([timeType isEqualToString:@"3"]) {
        [dicTimeType setValue:@"" forKey:@"navigationWeek"];
        
        NSString *sTime = @"";
        NSString *eTime = @"";
        if ([self.navigationDic objectForKey:@"startTime"] && [[self.navigationDic objectForKey:@"startTime"] count] > 0) {
            sTime = [[self.navigationDic objectForKey:@"startTime"] objectAtIndex:0];
        }
        
        if ([self.navigationDic objectForKey:@"endTime"] && [[self.navigationDic objectForKey:@"endTime"] count] > 0) {
            eTime = [[self.navigationDic objectForKey:@"endTime"] objectAtIndex:0];
        }
        [dicTimeType setValue:sTime forKey:@"navigationPointStartTime"];
        [dicTimeType setValue:eTime forKey:@"navigationPointEndTime"];
        
    }else if ([timeType isEqualToString:@"2"]){
        
        ///星期
        [dicTimeType setValue:[self getParamDataByArray:[self.navigationDic objectForKey:@"appointTimeWeek"]] forKey:@"navigationWeek"];
        [dicTimeType setValue:[self getParamDataByArray:[self.navigationDic objectForKey:@"startTime"]] forKey:@"navigationPointStartTime"];
        [dicTimeType setValue:[self getParamDataByArray:[self.navigationDic objectForKey:@"endTime"]] forKey:@"navigationPointEndTime"];
    }else if ([timeType isEqualToString:@"1"]){
        ///全部
        [dicTimeType setValue:@"" forKey:@"navigationWeek"];
        [dicTimeType setValue:@"" forKey:@"navigationPointStartTime"];
        [dicTimeType setValue:@"" forKey:@"navigationPointEndTime"];
    }
    return dicTimeType;
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


///选择的坐席
-(void)showAlertForAddSits{
    
    UIAlertView *alertCall = [[UIAlertView alloc] initWithTitle:nil message: @"批量添加坐席?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertCall.tag = 101;
    [alertCall show];
}


#pragma mark alertView的回调函数
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 101)
    {
        if(buttonIndex == 0)
        {
            [self backtoNavigationView];
        }
        else if(buttonIndex == 1)
        {
            [self addSitToNavigation:newNavigationId];
        }
    }
}

-(void)backtoNavigationView{

    if (self.NotifyNavigationList) {
        self.NotifyNavigationList();
    }
    [self.navigationController popViewControllerAnimated:YES];
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
                
                ///初始化数据
                [self initOptionsData];
                
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


#pragma mark - 新建导航

-(void)addNavition{

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
    
    [rDict setValue:[self.navigationDic safeObjectForKey:@"navigationId"] forKey:@"parentId"];
    
    if (timeStrategy) {
        [rDict addEntriesFromDictionary:timeStrategy];
    }else{
        [rDict addEntriesFromDictionary:[self getTimeTypeDefault]];
//        [rDict setValue:@"" forKey:@"navigationTimeType"];
//        [rDict setValue:@"" forKey:@"navigationWeek"];
//        [rDict setValue:@"" forKey:@"navigationPointStartTime"];
//        [rDict setValue:@"" forKey:@"navigationPointEndTime"];
    }
    ///地区
    if (areaStrategy) {
        [rDict addEntriesFromDictionary:areaStrategy];
    }else{
        [rDict addEntriesFromDictionary:[self getAreaTypeDefault]];
    }
   
    ///补全参数
    if (![rDict objectForKey:@"ringId"]) {
        [rDict setValue:@"" forKey:@"ringId"];
    }
    if (![rDict objectForKey:@"navigationKey"]) {
        [rDict setValue:@"0" forKey:@"navigationKey"];
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_ADD_FINAL_NAVIGATION_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"新建导航jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [CommonFuntion showToast:@"新建分组成功" inView:self.view];
            
            ///通知更新坐席列表
            [self sendNotificationUpdateSitList];
            
            newNavigationId = [[jsonResponse objectForKey:@"resultMap"] safeObjectForKey:@"navigationId"];
            
            if (newNavigationId && newNavigationId.length > 0) {
                [self showAlertForAddSits];
            }else{
                [self actionSuccess];
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self addNavition];
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

//通知UI刷新
-(void)sendNotificationUpdateSitList{
    [[NSNotificationCenter defaultCenter] postNotificationName:LLC_NOTIFICATON_SIT_LIST object:self];
}

@end
