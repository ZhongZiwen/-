//
//  RootNavigationViewController.m
//  
//
//  Created by sungoin-zjp on 16/1/8.
//
//

#import "RootNavigationViewController.h"
#import "CommonStaticVar.h"
#import "EditItemModel.h"
#import "LLcenterSheetMenuView.h"
#import "LLCenterSheetMenuModel.h"
#import "TPKeyboardAvoidingTableView.h"
#import "CommonFunc.h"
#import "EditItemTypeCellA.h"
#import "EditItemTypeCellB.h"
#import "EditItemTypeCellI.h"
#import "NavigationSeatCell.h"
#import "EditNavigationSeatCell.h"
#import "SelectAreaTypeViewController.h"
#import "SelectTimeTypeViewController.h"
#import "SortNavigationSeatsViewController.h"
#import "MJRefresh.h"

@interface RootNavigationViewController ()<UITableViewDataSource,UITableViewDelegate,LLCenterSheetMenuDelegate>{
    ///彩铃
    NSMutableArray *soureRing;
    ///进入下级导航的方式
    NSMutableArray *sourceEnterNavigationWay;
    ///下级导航按键长度
    NSMutableArray *sourceChildNavKeyNumLength;
    ///接听策略
    NSMutableArray *sourceStrategy;

    ///是否是编辑状态
    BOOL isEditingStarus;
    ///是否显示导航列表
    BOOL isShowNavigationList;
    
    ///导航还是坐席
    NSString *typeAction;
    ///导航列表或者坐席列表
    NSMutableArray *navigationList;
    NSMutableArray *sitList;
    
    ///标记修改item的下标
    NSInteger indexChangedItem;
    
    ///开关下标
    NSIndexPath *indexSwitich;
    
    //分页加载
    int listPage;
    
    NSInteger pageSize;
}

@property(strong,nonatomic) TPKeyboardAvoidingTableView *tableview;
@property(strong,nonatomic) NSMutableArray *dataSource;
///all data (详情+导航列表)
@property(strong,nonatomic) NSMutableArray *dataSourceAll;

@end

@implementation RootNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"分组详情";
    self.view.backgroundColor = COLOR_BG;
    
    [self initTableview];
    
    if (self.navigationDic == nil) {
        [self getNavigationDetails];
    }else{
        [self initNavigationData];
    }
}

///初始化当前导航数据
-(void)initNavigationData{
    [self initData];
    [self initDataWithActionTypeDetail];
    [self getNavigationDictionary];
    [self getNavigationListOrSitList];
}


#pragma mark - 初始化数据
-(void)initData{
    indexChangedItem = -1;
    listPage = 1;
    isShowNavigationList = FALSE;
    isEditingStarus = FALSE;
    
    soureRing = [[NSMutableArray alloc] init];
    sourceEnterNavigationWay = [[NSMutableArray alloc] init];
    sourceChildNavKeyNumLength = [[NSMutableArray alloc] init];
    sourceStrategy = [[NSMutableArray alloc] init];

    self.dataSource = [[NSMutableArray alloc] init];
    self.dataSourceAll = [[NSMutableArray alloc] init];
    navigationList = [[NSMutableArray alloc] init];
    sitList = [[NSMutableArray alloc] init];
    
    ///初始化导航信息
    ///进入方式
    if ([[self.navigationDic safeObjectForKey:@"navigationType"] isEqualToString:@"0"]) {
        self.enterNavigationWay = EnterNavWayByKeyNum;
    }else{
        self.enterNavigationWay = EnterNavWayShunt;
    }
    
    ///设置了下级导航  显示下级导航
    if([[self.navigationDic safeObjectForKey:@"navigationsetChild"] integerValue] == 1){
        NSLog(@"设置了下级分组  显示下级分组");
        self.navigationsetChild = @"yes";
    }else{
        ///未设置下级导航  显示坐席列表
        self.navigationsetChild = @"no";
    }
    
    ///当前导航是否有开再下一级导航的权限0-是，1-否
    if ([[self.navigationDic safeObjectForKey:@"navigationHasChild"] integerValue] == 0) {
        self.childNavigationHasChild = @"yes";
    }else{
        self.childNavigationHasChild = @"no";
    }
    
    ///初始化按键长度与进入方式
    [self initKeyNumLengthAndEndWay];
    
    ///开通IVR
    if ([CommonStaticVar getIvrStatus] == 1) {
        ///当前导航是否打开下级导航 是的话 请求导航  否的话请求坐席
        ///设置了下级导航
        if([self.navigationsetChild isEqualToString:@"yes"]){
            typeAction = @"navigation";
            NSLog(@"----typeAction--1->");
        }else{
            typeAction = @"sit";
            NSLog(@"----typeAction--2->");
        }
    }else{
        ///未开通IVR
        typeAction = @"sit";
        NSLog(@"----typeAction--3->");
    }
}


#pragma mark - Nar Bar
-(void)addNavBar{
    if (![[CommonStaticVar getAccountType] isEqualToString:@"boss"]) {
        return;
    }
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonAction)];
    self.navigationItem.rightBarButtonItem = rightButton;
}


///编辑/保存
-(void)rightBarButtonAction{
    ///编辑
    if (!isEditingStarus) {
        [self.tableview setFooterHidden:YES];
        isEditingStarus = TRUE;
        self.navigationItem.rightBarButtonItem.title = @"保存";
        self.title = @"分组设置";
        
        [self.dataSource  removeAllObjects];
        [self.dataSourceAll removeAllObjects];
        [self initDataWithActionTypeEditing];
        
    }else{
        ///保存
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        
        if (![CommonFunc checkNetworkState]) {
            [CommonFuntion showToast:@"无网络可用,加载失败" inView:self.view];
            return;
        }

        
        ///已开通IVR
        if ([CommonStaticVar getIvrStatus] == 1) {
            if (![self childNavigationKeyNumIsAllow]) {
                return;
            }
        }
        
        
        [self editNavition];
    }
}


////判断下级导航按键是否超出范围
-(BOOL)childNavigationKeyNumIsAllow{
    
    NSString *keyNumLength = @"";
    NSArray *array0 = [[self.dataSourceAll objectAtIndex:0] objectForKey:@"content"];
    for (int k=0; k<[array0 count]; k++) {
        EditItemModel *item  = (EditItemModel*) [array0 objectAtIndex:k];
        
        if (item.keyStr && item.keyStr.length > 0) {
            if ([item.keyStr isEqualToString:@"keyLength"]) {
                keyNumLength = item.content;
            }
        }
    }
    NSLog(@"keyNumLength:%@",keyNumLength);
    if (![keyNumLength isEqualToString:@""]) {
        if ([self.dataSourceAll count] == 2) {
            NSArray *array = [[self.dataSourceAll objectAtIndex:1] objectForKey:@"content"];
            for (int k=0; k<[array count]; k++) {
                EditItemModel *item  = (EditItemModel*) [array objectAtIndex:k];
                
                if (item.keyStr && item.keyStr.length > 0) {
                    //                    [rDict setValue:item.content forKey:item.keyStr];
                    NSLog(@"key: %@   value: %@",item.keyStr,item.content);
                    
                    if (item.content == nil || [[item.content stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
                        [CommonFuntion showToast:@"下级分组按键不能为空" inView:self.view];
                        return FALSE;
                    }else if(![CommonFunc checkStringIsNum:item.content]){
                        ///是否为纯数字组成
                        [CommonFuntion showToast:@"分组按键由数字组成" inView:self.view];
                        return FALSE;
                    }
                    else if (item.content.length != [keyNumLength integerValue]){
                        [CommonFuntion showToast:[NSString stringWithFormat:@"下级分组按键长度应为%@",keyNumLength] inView:self.view];
                        return FALSE;
                        
                    }
                }
            }
        }
    }
    
    return TRUE;
}


#pragma mark - 数据初始化及方法
///初始化进入按键长度与进入方式
-(void)initKeyNumLengthAndEndWay{
    
    ///进入下级导航方式
    NSDictionary *item = [[NSDictionary alloc] initWithObjectsAndKeys:@"0",@"id",@"按键进入",@"name", nil];
    [sourceEnterNavigationWay addObject:item];
    item = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"id",@"分流进入",@"name", nil];
    [sourceEnterNavigationWay addObject:item];
    
    
    ///下级导航按键长度
    item = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"id",@"1",@"name", nil];
    [sourceChildNavKeyNumLength addObject:item];
    item = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"id",@"2",@"name", nil];
    [sourceChildNavKeyNumLength addObject:item];
    item = [[NSDictionary alloc] initWithObjectsAndKeys:@"3",@"id",@"3",@"name", nil];
    [sourceChildNavKeyNumLength addObject:item];
    item = [[NSDictionary alloc] initWithObjectsAndKeys:@"4",@"id",@"4",@"name", nil];
    [sourceChildNavKeyNumLength addObject:item];
    item = [[NSDictionary alloc] initWithObjectsAndKeys:@"5",@"id",@"5",@"name", nil];
    [sourceChildNavKeyNumLength addObject:item];
    item = [[NSDictionary alloc] initWithObjectsAndKeys:@"6",@"id",@"6",@"name", nil];
    [sourceChildNavKeyNumLength addObject:item];
    
    ///接听策略
    item = [[NSDictionary alloc] initWithObjectsAndKeys:@"0",@"id",@"顺序接听",@"name", nil];
    [sourceStrategy addObject:item];
    item = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"id",@"随机接听",@"name", nil];
    [sourceStrategy addObject:item];
    item = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"id",@"平均接听",@"name", nil];
    [sourceStrategy addObject:item];
    
    
    
    ///进入方式
    NSMutableArray *array0 = [[NSMutableArray alloc] init];
    NSInteger count = 0;
    if (sourceEnterNavigationWay) {
        count = [sourceEnterNavigationWay count];
    }
    for (int i=0; i<count; i++) {
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = [[sourceEnterNavigationWay objectAtIndex:i] safeObjectForKey:@"id"];
        model.title = [[sourceEnterNavigationWay objectAtIndex:i] safeObjectForKey:@"name"];
        model.selectedFlag = @"no";
        [array0 addObject:model];
    }
    
    count = 0;
    ///按键长度
    NSMutableArray *array3 = [[NSMutableArray alloc] init];
    if (sourceChildNavKeyNumLength) {
        count = [sourceChildNavKeyNumLength count];
    }
    for (int i=0; i<count; i++) {
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = [[sourceChildNavKeyNumLength objectAtIndex:i] safeObjectForKey:@"id"];
        model.title = [[sourceChildNavKeyNumLength objectAtIndex:i] safeObjectForKey:@"name"];
        model.selectedFlag = @"no";
        [array3 addObject:model];
    }
    
    count = 0;
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
    
    
    [sourceEnterNavigationWay removeAllObjects];
    [sourceChildNavKeyNumLength removeAllObjects];
    [sourceStrategy removeAllObjects];
    
    [sourceEnterNavigationWay addObjectsFromArray:array0];
    [sourceChildNavKeyNumLength addObjectsFromArray:array3];
    [sourceStrategy addObjectsFromArray:array4];
    
}

///根据进入导航方式ID获取其对应的name
-(NSString *)getEnterNavWayNameById:(NSString *)enterWayId{
    NSString *name = @"";
    NSInteger count = 0;
    if (sourceEnterNavigationWay) {
        count = [sourceEnterNavigationWay count];
    }
    LLCenterSheetMenuModel *model ;
    BOOL isFound = FALSE;
    for (int i=0; !isFound && i<count; i++) {
        model = (LLCenterSheetMenuModel*)[sourceEnterNavigationWay objectAtIndex:i];
        if ([model.itmeId isEqualToString:enterWayId]) {
            name = model.title;
            isFound = TRUE;
        }
    }
    return name;
}

///根据进入导航方式ID获取其对应的name
-(NSString *)getNavKeyNumLengthNameById:(NSString *)keyNumLengthId{
    NSString *name = @"";
    NSInteger count = 0;
    if (sourceChildNavKeyNumLength) {
        count = [sourceChildNavKeyNumLength count];
    }
    LLCenterSheetMenuModel *model ;
    BOOL isFound = FALSE;
    for (int i=0; !isFound && i<count; i++) {
        model = (LLCenterSheetMenuModel*)[sourceChildNavKeyNumLength objectAtIndex:i];
        if ([model.itmeId isEqualToString:keyNumLengthId]) {
            name = model.title;
            isFound = TRUE;
        }
    }
    return name;
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

///初始化按键长度
-(void)initOptionsDataOfKeyNumLength{
    NSString *keyLengthId =  [self.navigationDic safeObjectForKey:@"childNavigationKeyLength"];
    NSInteger count = 0;
    LLCenterSheetMenuModel *model ;
    
    ///按键长度
    if (sourceChildNavKeyNumLength) {
        count = [sourceChildNavKeyNumLength count];
    }
    for (int i=0; i<count; i++) {
        model = (LLCenterSheetMenuModel*)[sourceChildNavKeyNumLength objectAtIndex:i];
        if ([keyLengthId isEqualToString:model.itmeId]) {
            model.selectedFlag = @"yes";
        }else{
            model.selectedFlag = @"no";
        }
    }
}


///初始化进入下级导航方式
-(void)initOptionsDataOfChildWay{
    NSString *enterNavigationWayId = [self.navigationDic safeObjectForKey:@"navigationType"];
    ///进入方式
    NSInteger count = 0;
    if (sourceEnterNavigationWay) {
        count = [sourceEnterNavigationWay count];
    }
    LLCenterSheetMenuModel *model ;
    for (int i=0; i<count; i++) {
        model = (LLCenterSheetMenuModel*)[sourceEnterNavigationWay objectAtIndex:i];
        if ([enterNavigationWayId isEqualToString:model.itmeId]) {
            model.selectedFlag = @"yes";
        }else{
            model.selectedFlag = @"no";
        }
    }
}


#pragma mark - 初始化选择条件数据
-(void)initOptionsData{
    /*
    ///进入方式
    NSMutableArray *array0 = [[NSMutableArray alloc] init];
    NSInteger count = 0;
    if (sourceEnterNavigationWay) {
        count = [sourceEnterNavigationWay count];
    }
    for (int i=0; i<count; i++) {
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = [[sourceEnterNavigationWay objectAtIndex:i] safeObjectForKey:@"id"];
        model.title = [[sourceEnterNavigationWay objectAtIndex:i] safeObjectForKey:@"name"];
        model.selectedFlag = @"no";
        [array0 addObject:model];
    }
    */
    NSInteger count = 0;
    ///彩铃
    NSMutableArray *array1 = [[NSMutableArray alloc] init];
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
    
    /*
    ///按键长度
    NSMutableArray *array3 = [[NSMutableArray alloc] init];
    if (sourceChildNavKeyNumLength) {
        count = [sourceChildNavKeyNumLength count];
    }
    for (int i=0; i<count; i++) {
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = [[sourceChildNavKeyNumLength objectAtIndex:i] safeObjectForKey:@"id"];
        model.title = [[sourceChildNavKeyNumLength objectAtIndex:i] safeObjectForKey:@"name"];
        model.selectedFlag = @"no";
        [array3 addObject:model];
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
    */
    
    
    [soureRing removeAllObjects];
    [soureRing addObjectsFromArray:array1];
    
    /*
    [sourceEnterNavigationWay removeAllObjects];
    [soureRing removeAllObjects];
    [sourceChildNavKeyNumLength removeAllObjects];
    [sourceStrategy removeAllObjects];
    
    [sourceEnterNavigationWay addObjectsFromArray:array0];
    [soureRing addObjectsFromArray:array1];
    [sourceChildNavKeyNumLength addObjectsFromArray:array3];
    [sourceStrategy addObjectsFromArray:array4];
     */
    
    
    NSLog(@"soureRing:%@",soureRing);
}


///根据详情信息 设置弹框默认选项√
-(void)initByDetailsData{
    NSString *ringId = [self.navigationDic safeObjectForKey:@"navigationRingId"];
    NSString *enterNavigationWayId = [self.navigationDic safeObjectForKey:@"navigationType"];
    NSString *keyLengthId =  [self.navigationDic safeObjectForKey:@"childNavigationKeyLength"];
    NSString *answerStrategy =  [self.navigationDic safeObjectForKey:@"answerStrategy"];
    NSLog(@"keyLengthId:%@",keyLengthId);
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
    
    
    ///默认进入导航方式
    if (sourceEnterNavigationWay) {
        count = [sourceEnterNavigationWay count];
    }
    isFound = FALSE;
    
    for (int i=0; !isFound && i<count; i++) {
        model = [sourceEnterNavigationWay objectAtIndex:i];
        if ([model.itmeId isEqualToString:enterNavigationWayId]) {
            model.selectedFlag = @"yes";
            isFound = TRUE;
        }
    }
    
    
    ///导航按键长度
    if (sourceChildNavKeyNumLength) {
        count = [sourceChildNavKeyNumLength count];
    }
    isFound = FALSE;
    
    for (int i=0; !isFound && i<count; i++) {
        model = [sourceChildNavKeyNumLength objectAtIndex:i];
        if ([model.itmeId isEqualToString:keyLengthId]) {
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

#pragma mark - 根据操作类型 详情 初始化数据源
-(void)initDataWithActionTypeDetail{
    
    NSString *navigationName = [self.navigationDic safeObjectForKey:@"navigationName"];
    NSString *ringName = [self.navigationDic safeObjectForKey:@"navigationRingName"];
    NSString *ringId = [self.navigationDic safeObjectForKey:@"navigationRingId"];
    NSString *enterNavigationWayId = [self.navigationDic safeObjectForKey:@"navigationType"];
    NSString *enterNavigationWay = [self getEnterNavWayNameById:enterNavigationWayId];
    NSString *answerStrategy =  [self.navigationDic safeObjectForKey:@"answerStrategy"];
    
    ///是否显示彩铃
    BOOL isShowRing = FALSE;
    ///是否显示接听策略
    BOOL isShowStrage = FALSE;
    
    EditItemModel *model;
    
    model = [[EditItemModel alloc] init];
    model.title = @"分组名称:";
    model.content = navigationName;
    model.placeholder = @"1-100个中英文、数字特殊字符";
    model.cellType = @"cellA";
//    model.keyStr = @"navigationName";
    model.keyStr = @"";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    
    ///已开通IVR
    if ([CommonStaticVar getIvrStatus] == 1) {

        ///已开通彩铃
        if ([CommonStaticVar getRingStatus] == 1) {
            isShowRing = TRUE;
        }
        
    }else{
        ///已开通彩铃
        if ([CommonStaticVar getRingStatus] == 1) {
            isShowRing = TRUE;
        }
        isShowStrage = TRUE;
    }
    
    if (isShowRing) {
        model = [[EditItemModel alloc] init];
        model.title = @"彩铃:";
        model.itemId = ringId;
        model.content = ringName;
        model.placeholder = @"(当电话转接到本层后播放音频)";
        model.cellType = @"cellB";
        model.keyStr = @"ringId";
        model.keyType = @"ringId";
        model.enabled = @"no";
        [self.dataSource addObject:model];
    }
    
    
    
    ///设置了下级导航
    if([self.navigationsetChild isEqualToString:@"yes"]){
        model = [[EditItemModel alloc] init];
        model.title = @"进入下级分组方式:";
        model.itemId = enterNavigationWayId;
        model.content = enterNavigationWay;
        model.placeholder = @"";
        model.cellType = @"cellB";
        model.keyStr = @"enterNavigationWay";
        model.keyType = @"enterNavigationWay";
        model.enabled = @"no";
        [self.dataSource addObject:model];
    }else{
        isShowStrage = TRUE;
    }
    
    
    if (isShowStrage) {
        model = [[EditItemModel alloc] init];
        model.title = @"接听策略:";
        model.itemId = answerStrategy;
        model.content = [self getAnswerStrategy:answerStrategy];
        model.placeholder = @"";
        model.cellType = @"cellB";
        model.keyStr = @"answerStrategy";
        model.keyType = @"answerStrategy";
        model.enabled = @"no";
        [self.dataSource addObject:model];
    }
    
    [self updateAllDataSource:@""];
    
    NSLog(@"self.dataSource:%@",self.dataSource);
    for (int i=0; i<[self.dataSource count]; i++) {
        EditItemModel *item  = (EditItemModel*) [self.dataSource objectAtIndex:i];
        NSLog(@"%@  %@",item.title,item.cellType);
    }
}


#pragma mark - 根据操作类型 编辑详情 初始化数据源
-(void)initDataWithActionTypeEditing{

    NSString *navigationName = [self.navigationDic safeObjectForKey:@"navigationName"];
    NSString *ringName = [self.navigationDic safeObjectForKey:@"navigationRingName"];
    NSString *ringId = [self.navigationDic safeObjectForKey:@"navigationRingId"];
//    NSString *enterNavigationWayId = [self.navigationDic safeObjectForKey:@"navigationType"];
//    NSString *enterNavigationWay = [self getEnterNavWayNameById:enterNavigationWayId];
    NSString *answerStrategy =  [self.navigationDic safeObjectForKey:@"answerStrategy"];
    
    ///是否显示彩铃
    BOOL isShowRing = FALSE;
    ///是否显示接听策略
    BOOL isShowStrage = FALSE;
    
    EditItemModel *model;
    
    model = [[EditItemModel alloc] init];
    model.title = @"分组名称:";
    model.content = navigationName;
    model.placeholder = @"1-100个中英文、数字特殊字符";
    model.cellType = @"cellA";
    //    model.keyStr = @"navigationName";
    model.keyStr = @"";
    model.keyType = @"";
    model.itemTag = @"分组名称";
    [self.dataSource addObject:model];
    
    
    ///已开通IVR
    if ([CommonStaticVar getIvrStatus] == 1) {
        ///已开通彩铃
        if ([CommonStaticVar getRingStatus] == 1) {
            isShowRing = TRUE;
        }
    }else{
        ///已开通彩铃
        if ([CommonStaticVar getRingStatus] == 1) {
            isShowRing = TRUE;
        }
        isShowStrage = TRUE;
    }
    
    if (isShowRing) {
        model = [[EditItemModel alloc] init];
        model.title = @"彩铃:";
        model.itemId = ringId;
        model.content = ringName;
        model.placeholder = @"(当电话转接到本层后播放音频)";
        model.cellType = @"cellB";
        model.keyStr = @"ringId";
        model.keyType = @"ringId";
        model.itemTag = @"彩铃";
        [self.dataSource addObject:model];
    }
    

    ///已开通IVR
    if ([CommonStaticVar getIvrStatus] == 1) {
        ///设置了下级导航
        if([self.navigationsetChild isEqualToString:@"yes"]){
            model = [[EditItemModel alloc] init];
            model.title = @"是否有下级分组:";
            ///默认不选中
            model.content = @"1";
            model.placeholder = @"";
            model.cellType = @"cellI";
            model.keyStr = @"hasChildNavigation";
            model.itemTag = @"是否有下级分组";
            [self.dataSource addObject:model];
            NSLog(@"------0---->");
            [self updateDataSourceByNavHasChild];
        }else{
            ///有开启下级导航的权限
            if ([self.childNavigationHasChild isEqualToString:@"yes"]) {
                
                ///接听策略
                model = [[EditItemModel alloc] init];
                model.title = @"接听策略:";
                model.itemId = answerStrategy;
                model.content = [self getAnswerStrategy:answerStrategy];
                model.placeholder = @"";
                model.cellType = @"cellB";
                model.keyStr = @"answerStrategy";
                model.keyType = @"answerStrategy";
                model.itemTag = @"接听策略";
                [self.dataSource addObject:model];
                
                
                model = [[EditItemModel alloc] init];
                model.title = @"是否有下级分组:";
                ///默认不选中
                model.content = @"0";
                model.placeholder = @"";
                model.cellType = @"cellI";
                model.keyStr = @"hasChildNavigation";
                model.itemTag = @"是否有下级分组";
                [self.dataSource addObject:model];
                NSLog(@"------01---->");
                [self updateDataSourceByNavHasChild];
            }else{
                
                ///接听策略
                model = [[EditItemModel alloc] init];
                model.title = @"接听策略:";
                model.itemId = answerStrategy;
                model.content = [self getAnswerStrategy:answerStrategy];
                model.placeholder = @"";
                model.cellType = @"cellB";
                model.keyStr = @"answerStrategy";
                model.keyType = @"answerStrategy";
                model.itemTag = @"接听策略";
                [self.dataSource addObject:model];
                
                
                [self updateAllDataSource:@""];
            }
        }
    }else{
        ///接听策略
        model = [[EditItemModel alloc] init];
        model.title = @"接听策略:";
        model.itemId = answerStrategy;
        model.content = [self getAnswerStrategy:answerStrategy];
        model.placeholder = @"";
        model.cellType = @"cellB";
        model.keyStr = @"answerStrategy";
        model.keyType = @"answerStrategy";
        model.itemTag = @"接听策略";
        [self.dataSource addObject:model];
        
        
        [self updateAllDataSource:@""];
    }
    
    ///根导航
    if ([typeAction isEqualToString:@"sit"]) {
        [self updateAllDataSource:@"sit"];
    }
    
    
    NSLog(@"self.dataSource:%@",self.dataSource);
    for (int i=0; i<[self.dataSource count]; i++) {
        EditItemModel *item  = (EditItemModel*) [self.dataSource objectAtIndex:i];
        NSLog(@"%@  %@",item.title,item.cellType);
    }
}

///根据标识  获取其对应的下标
-(NSInteger)getIndexOfItemByTag:(NSString *)tag{
    NSInteger index = -1;
    
    NSInteger count = 0;
    if (self.dataSource) {
        count = [self.dataSource count];
    }
    
    BOOL isFound = FALSE;
    EditItemModel *model;
    for (int i=0; !isFound && i<count; i++) {
        model = [self.dataSource objectAtIndex:i];
        
        if ([tag isEqualToString:model.itemTag]) {
            index = i;
            isFound = TRUE;
        }
    }
    return index;
}

///根据标识删除对应item
-(void)remveItemByTag:(NSString *)tag{

    NSInteger count = 0;
    if (self.dataSource) {
        count = [self.dataSource count];
    }
    
    BOOL isFound = FALSE;
    EditItemModel *model;
    for (int i=0; !isFound && i<count; i++) {
        model = [self.dataSource objectAtIndex:i];
        if ([tag isEqualToString:model.itemTag]) {
            isFound = TRUE;
            [self.dataSource removeObjectAtIndex:i];
        }
    }
}

///根据标识删除对应item
-(BOOL)isExistItemByTag:(NSString *)tag{
    
    NSInteger count = 0;
    if (self.dataSource) {
        count = [self.dataSource count];
    }
    
    BOOL isFound = FALSE;
    EditItemModel *model;
    for (int i=0; !isFound && i<count; i++) {
        model = [self.dataSource objectAtIndex:i];
        if ([tag isEqualToString:model.itemTag]) {
            isFound = TRUE;
        }
    }
    return isFound;
}


///根据是否有下级导航更新数据源
-(void)updateDataSourceByNavHasChild{
    ///导航名称
    ///彩铃
    ///是否有下级导航
    ///按键进入
    ///1
    
    NSString *enterNavigationWayId = [self.navigationDic safeObjectForKey:@"navigationType"];
    NSString *enterNavigationWay = [self getEnterNavWayNameById:enterNavigationWayId];
    
    NSLog(@"enterNavigationWayId:%@",enterNavigationWayId);
    NSLog(@"enterNavigationWay:%@",enterNavigationWay);
    
    
    NSInteger index = [self getIndexOfItemByTag:@"是否有下级分组"];
    EditItemModel *itemChildNav = (EditItemModel *)[self.dataSource objectAtIndex:index];
    ///是否有下级导航
    ///没有
    if ([itemChildNav.content  isEqualToString:@"0"]) {
        [self remveItemByTag:@"进入下级分组方式"];
        [self remveItemByTag:@"下级分组按键长度"];

        [self updateAllDataSource:@""];
    }else{
        
        EditItemModel *model;
        
        model = [[EditItemModel alloc] init];
        model.title = @"进入下级分组方式:";
        model.itemId = enterNavigationWayId;
        model.content = enterNavigationWay;
        model.placeholder = @"";
        model.cellType = @"cellB";
        model.keyStr = @"enterNavigationWay";
        model.keyType = @"enterNavigationWay";
        model.itemTag = @"进入下级分组方式";
        [self.dataSource addObject:model];
        
        [self updateDataSourceByEnterWay];
    }
    ///清除痕迹
    [self initOptionsDataOfChildWay];
    [self initOptionsDataOfKeyNumLength];
    [self.tableview reloadData];
}


///根据进入方式更新数据源
-(void)updateDataSourceByEnterWay{
    NSString *keyLengthId =  [self.navigationDic safeObjectForKey:@"childNavigationKeyLength"];
    NSString *keyLength =[self getNavKeyNumLengthNameById:keyLengthId];
    
    NSInteger index = [self getIndexOfItemByTag:@"进入下级分组方式"];
    EditItemModel *itemChildNav = (EditItemModel *)[self.dataSource objectAtIndex:index];
    
    //下级按键方式进入
    if ([itemChildNav.itemId  isEqualToString:@"0"]) {
        NSLog(@"按键进入--0-->");
        BOOL isAddRow = [self isExistItemByTag:@"下级分组按键长度"];
        
        ///不存在
        if (!isAddRow) {
            EditItemModel *model;
            model = [[EditItemModel alloc] init];
            model.title = @"下级分组按键长度:";
            NSLog(@"2keyLengthId:%@",keyLengthId);
            model.itemId = keyLengthId;
            model.content = keyLength;
            model.placeholder = @"";
            model.cellType = @"cellB";
            model.keyStr = @"keyLength";
            model.keyType = @"keyLength";
            model.itemTag = @"下级分组按键长度";
            [self.dataSource addObject:model];
            
        }
        [self updateAllDataSource:@"navigationlist"];
        
    }else{
        [self remveItemByTag:@"下级分组按键长度"];
        [self updateAllDataSource:@""];
    }
    ///清除痕迹
    [self initOptionsDataOfKeyNumLength];
}


#pragma mark - 刷新数据源
-(void)updateAllDataSource:(NSString *)action{
    isShowNavigationList = FALSE;
    [self.dataSourceAll removeAllObjects];
    
    NSMutableDictionary *dicDataSource = [[NSMutableDictionary alloc] init];
    NSMutableArray *arraySection = [[NSMutableArray alloc] init];
    
    [dicDataSource setObject:@"分组信息" forKey:@"head"];
    [dicDataSource setObject:self.dataSource forKey:@"content"];
    
    [self.dataSourceAll addObject:dicDataSource];
    
    if ([action isEqualToString:@"detail"]) {
        
    }else if ([action isEqualToString:@"navigationlist"]) {
        NSLog(@"展示下级分组列表");
        [self addNavitationListData];
    }else if ([action isEqualToString:@"sit"]) {
        NSLog(@"展示坐席列表");
        [self addNavigationSitData];
    }
    NSLog(@"self.dataSourceAll:%@",self.dataSourceAll);
    [self.tableview reloadData];
}

///添加导航列表
-(void)addNavitationListData{
    
     NSMutableDictionary *dicDataSource = [[NSMutableDictionary alloc] init];
     NSMutableArray *arraySection = [[NSMutableArray alloc] init];
    ///展示下级导航列表
    dicDataSource = [[NSMutableDictionary alloc] init];
    
    NSInteger count = 0;
    if(navigationList){
        count = [navigationList count];
    }
    
    NSDictionary *item;
    EditItemModel *model;
    for (int i=0; i<count; i++) {
        
        item = [navigationList objectAtIndex:i];
        model = [[EditItemModel alloc] init];
        model.title = [item safeObjectForKey:@"childNavigationName"];
        model.content = [item safeObjectForKey:@"childNavigationKeyPress"];
        
        model.cellType = @"cellA";
        if (isEditingStarus) {
            model.placeholder = @"请输入进入分组按键";
            model.keyStr = @"nextNavigationKey";
            model.keyType = [item safeObjectForKey:@"childNavigationId"];
        }else{
            model.placeholder = @"";
            model.keyStr = @"";
            model.keyType = @"";
        }

        [arraySection addObject:model];
    }
    
    if (count > 0) {
        isShowNavigationList = TRUE;
        [dicDataSource setObject:@"下级分组列表" forKey:@"head"];
        [dicDataSource setObject:arraySection forKey:@"content"];
        
        [self.dataSourceAll addObject:dicDataSource];
    }
}

///添加坐席列表数据
-(void)addNavigationSitData{
    
    ///存在坐席
    if (sitList && [sitList count] > 0) {
        NSMutableDictionary *dicDataSource = [[NSMutableDictionary alloc] init];
        ///展示坐席列表
        dicDataSource = [[NSMutableDictionary alloc] init];
        
        [dicDataSource setObject:@"坐席列表" forKey:@"head"];
        [dicDataSource setObject:sitList forKey:@"content"];
        [self.dataSourceAll addObject:dicDataSource];
    }
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
    
    [self setupRefresh];
}


#pragma mark - 上拉下拉刷新相关事件
//集成刷新控件
- (void)setupRefresh
{
    NSString *dateKey = @"llcnavgationsettingview";
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    //    [self.tableview addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:dateKey];
    //上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableview addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 自动刷新(一进入程序就下拉刷新)
    //    [self.tableviewCampaign headerBeginRefreshing];
}


// 结束加载
-(void)reloadRefeshView{
    // 刷新列表
    [self.tableview reloadData];
    [self.tableview footerEndRefreshing];
    [self.tableview headerEndRefreshing];
}

// 下拉
- (void)headerRereshing
{
    NSLog(@"headerRereshing--下拉-->");
    
    if ([self.tableview isFooterRefreshing]) {
        [self.tableview headerEndRefreshing];
        return;
    }
    
    ///下拉
    listPage = 1;
    [self getNavigationListOrSitList];
}

// 上拉
- (void)footerRereshing
{
    NSLog(@"footerRereshing--上拉-->");
    
    if ([self.tableview isHeaderRefreshing]) {
        [self.tableview footerEndRefreshing];
        return;
    }
    //上拉加载更多
    [self getNavigationListOrSitList];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}



#pragma mark - tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.dataSourceAll) {
        return [self.dataSourceAll count];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.dataSourceAll objectAtIndex:section] objectForKey:@"content"] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 40;
    }
    return 20;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if ([typeAction isEqualToString:@"navigation"]) {
        
    }else if ([typeAction isEqualToString:@"sit"]) {
    }
    
    if ([typeAction isEqualToString:@"navigation"]) {
        if ( section == 1 && navigationList && [navigationList count]>0) {
            UIView *headview =[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
            headview.backgroundColor = COLOR_BG;
            
            UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 80, 20)];
            labelTitle.textColor = [UIColor blackColor];
            labelTitle.font = [UIFont systemFontOfSize:15.0];
            labelTitle.text = @"下级分组";
            [headview addSubview:labelTitle];
            
            return headview;
        }
    }else if ([typeAction isEqualToString:@"sit"]) {
        
        if (section == 1 && sitList && [sitList count]>0) {
            UIView *headview =[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
            headview.backgroundColor = COLOR_BG;
            
            UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 20)];
            labelTitle.textColor = [UIColor blackColor];
            labelTitle.font = [UIFont systemFontOfSize:15.0];
            labelTitle.text = @"坐席列表";
            [headview addSubview:labelTitle];
            
            ///编辑状态  当为顺序接听时 才显示排序按钮
            if (isEditingStarus &&  self.listenStrategy == ListenStrategySequence) {
                UIButton *btnSort = [UIButton buttonWithType:UIButtonTypeCustom];
                btnSort.frame = CGRectMake(kScreen_Width-30, 10, 20, 20);
                [btnSort setBackgroundImage:[UIImage imageNamed:@"icon_sort.png"] forState:UIControlStateNormal];
                [btnSort addTarget:self action:@selector(sortSeats) forControlEvents:UIControlEventTouchUpInside];
                [headview addSubview:btnSort];
            }
            
            return headview;
        }
    }
    
    return nil;
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
            
            ///播放音频
            cell.SelectDataActionBlock = ^(NSInteger action){
                NSLog(@"播放音频");
            };
            
            if (isEditingStarus) {
                cell.SelectDataTypeBlock = ^(NSInteger type){
                    
                    NSInteger flag = -1;
                    ///1彩铃  2时间类型 3 地区类型  4接听策略 5进入方式 6按键长度
                    
                    if ([item.itemTag isEqualToString:@"彩铃"]) {
                        flag = 1;
                    }else if ([item.itemTag isEqualToString:@"接听策略"]) {
                        flag = 4;
                    }else if ([item.itemTag isEqualToString:@"进入下级分组方式"]) {
                        flag = 5;
                    }else if ([item.itemTag isEqualToString:@"下级分组按键长度"]) {
                        flag = 6;
                    }
                    
                    [weak_self showMenuByFlag:flag withIndexPath:indexPath];
                };
            }
            
            [cell setCellDetail:item];
            return cell;
        }else if ([item.cellType isEqualToString:@"cellI"]) {
            EditItemTypeCellI *cell = [tableView dequeueReusableCellWithIdentifier:@"EditItemTypeCellIIdentify"];
            if (!cell)
            {
                NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"EditItemTypeCellI" owner:self options:nil];
                cell = (EditItemTypeCellI*)[array objectAtIndex:0];
                [cell awakeFromNib];
            }
            
            __weak typeof(self) weak_self = self;
            cell.SwitchDefaultBlock = ^(NSString *valueString){
                NSLog(@"valueString:%@",valueString);
                
                if ([typeAction isEqualToString:@"navigation"]) {
                    ///提示
                    if ([valueString isEqualToString:@"0"]) {
                        if (navigationList && navigationList.count > 0) {
                            [weak_self notifyDataSource:indexPath valueString:@"1" idString:@""];
                            [weak_self.tableview reloadData];
                            
                            indexSwitich = indexPath;
                            [weak_self showAlertByOffChild];
                        }else{
                            [weak_self notifyDataSource:indexPath valueString:valueString idString:@""];
                            ///刷新数据源
                            [weak_self updateDataSourceByNavHasChild];
                        }
                        
                    }else{
                        [weak_self notifyDataSource:indexPath valueString:valueString idString:@""];
                        ///刷新数据源
                        [weak_self updateDataSourceByNavHasChild];
                    }
                    
                }else if ([typeAction isEqualToString:@"sit"]) {
                    ///提示
                    if ([valueString isEqualToString:@"1"]) {
                        
                        if (sitList && sitList.count > 0) {
                            [weak_self notifyDataSource:indexPath valueString:@"0" idString:@""];
                            [weak_self.tableview reloadData];
                            indexSwitich = indexPath;
                            [weak_self showAlertByOffSit];
                        }else{
                            [weak_self notifyDataSource:indexPath valueString:valueString idString:@""];
                            ///刷新数据源
                            [weak_self updateDataSourceByNavHasChild];
                        }
                        
                    }else{
                        [weak_self notifyDataSource:indexPath valueString:valueString idString:@""];
                        ///刷新数据源
                        [weak_self updateDataSourceByNavHasChild];
                    }
                }
                
            };
            
            [cell setCellDetail:item];
            return cell;
        }
    }else{
    
        if ([typeAction isEqualToString:@"navigation"]) {
            
            EditItemTypeCellA *cell = [tableView dequeueReusableCellWithIdentifier:@"EditItemTypeCellAIdentify"];
            if (!cell)
            {
                NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"EditItemTypeCellA" owner:self options:nil];
                cell = (EditItemTypeCellA*)[array objectAtIndex:0];
                [cell awakeFromNib];
            }
            
            __weak typeof(self) weak_self = self;
            cell.textValueChangedBlock = ^(NSString *valueString){
                [weak_self notifyDataSource:indexPath valueString:valueString idString:@""];
            };
            
            [cell setCellDetail:item];
            return cell;
            
        }else if ([typeAction isEqualToString:@"sit"]) {
            ///座席
            if (!isEditingStarus) {
                NavigationSeatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NavigationSeatCellIdentify"];
                if (!cell)
                {
                    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"NavigationSeatCell" owner:self options:nil];
                    cell = (NavigationSeatCell*)[array objectAtIndex:0];
                    [cell awakeFromNib];
                }
                
                NSDictionary *item = [[[self.dataSourceAll objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];
                [cell setCellDetails:item];
                
                return cell;
            }else{
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
                    [weak_self gotoAreaTypeView:@"sit" andNavigationSitItem:[sitList objectAtIndex:index]];
                };
                
                ///时间
                cell.ChangeTimeTypeBlock = ^(NSInteger index){
                    NSLog(@"index:%ti",index);
                    [weak_self gotoTimeTypeView:@"sit" andNavigationSitItem:[sitList objectAtIndex:index]];
                };
                
                return cell;
            }
        }
        
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
    NSDictionary *item = [sitList objectAtIndex:index];
    ///修改本地数据
    NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:item];
    [mutableItemNew setObject:duration forKey:@"WAITDURATION"];
    //修改数据
    [sitList setObject: mutableItemNew atIndexedSubscript:index];
    
    [self.tableview reloadData];
}


#pragma mark - 弹框
///根据flag 弹框  ///1彩铃  2时间类型 3 地区类型  4接听策略 5进入方式 6按键长度
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
    }else if (flag == 4){
        title = @"接听策略";
        type = 0;
        array = sourceStrategy;
    }
    else if (flag == 5){
        title = @"进入下级分组方式";
        type = 0;
        array = sourceEnterNavigationWay;
    }else if (flag == 6){
        title = @"下级分组按键长度";
        type = 0;
        array = sourceChildNavKeyNumLength;
    }
    
    if (array == nil || [array count] == 0) {
        NSLog(@"选择数据源为空");
        NSString *strMsg = @"";
        if (flag == 1) {
            strMsg = @"彩铃加载失败";
        }else if (flag == 4){
            strMsg = @"接听策略加载失败";
        }
        else if (flag == 5){
            strMsg = @"分组方式加载失败";
        }else if (flag == 6){
            strMsg = @"按键长度加载失败";
        }
        [CommonFuntion showToast:strMsg inView:self.view];
        return;
    }
    
    
    sheet = [[LLcenterSheetMenuView alloc]initWithlist:array headTitle:title footBtnTitle:@"" cellType:type menuFlag:flag];
    sheet.delegate = self;
    
    [sheet showInView:nil];
}


-(void)didSelectSheetMenuIndex:(NSInteger)index menuType:(SheetMenuType)menuT menuFlag:(NSInteger)flag{
    ///1彩铃  2时间类型 3 地区类型  4接听策略 5进入方式 6按键长度
    NSLog(@"index:%ti",index);
    ///彩铃
    if (flag == 1){
        [self changeSelectedFlag:soureRing index:index];
        
        ///@"请选择彩铃";
        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[soureRing objectAtIndex:index];
        NSLog(@"title:%@   ids:%@",model.title,model.itmeId);
        NSInteger index = [self getIndexOfItemByTag:@"彩铃"];
        
        [self notifyDataSource:[NSIndexPath indexPathForRow:index inSection:0] valueString:model.title idString:model.itmeId];
    }else if (flag == 4){
        ///接听策略
        [self changeSelectedFlag:sourceStrategy index:index];
        
        ///@"请选择接听策略";
        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[sourceStrategy objectAtIndex:index];
        NSLog(@"title:%@   ids:%@",model.title,model.itmeId);
        NSInteger ringIndex = 1;
        
        ///已开通IVR
        if ([CommonStaticVar getIvrStatus] == 1) {
            ///已开通彩铃
            if ([CommonStaticVar getRingStatus] == 1) {
                ringIndex = 2;
            }else{
                ringIndex = 1;
            }
        }else{
            ///已开通彩铃
            if ([CommonStaticVar getRingStatus] == 1) {
                ringIndex = 2;
            }else{
                ringIndex = 1;
            }
        }
        NSInteger index = [self getIndexOfItemByTag:@"接听策略"];
        if ([model.itmeId isEqualToString:@"0"]) {
            self.listenStrategy = ListenStrategySequence;
        }else if ([model.itmeId isEqualToString:@"1"]) {
            self.listenStrategy = ListenStrategyRandom;
        }else if ([model.itmeId isEqualToString:@"2"]) {
            self.listenStrategy = ListenStrategyAverage;
        }
        
        [self notifyDataSource:[NSIndexPath indexPathForRow:index inSection:0] valueString:model.title idString:model.itmeId];
        
    }else if (flag == 5){
        ///进入方式
        [self changeSelectedFlag:sourceEnterNavigationWay index:index];
        
        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[sourceEnterNavigationWay objectAtIndex:index];
        NSLog(@"title:%@   ids:%@",model.title,model.itmeId);
        NSInteger ringIndex = 2;
        
 
        
        ///已开通IVR
        if ([CommonStaticVar getIvrStatus] == 1) {
            ///已开通彩铃
            if ([CommonStaticVar getRingStatus] == 1) {
                ///设置了下级导航
                if([self.navigationsetChild isEqualToString:@"yes"]){
                    ringIndex = 3;
                   
                }else{
                    ringIndex = 4;
                }
            }else{
                ///设置了下级导航
                if([self.navigationsetChild isEqualToString:@"yes"]){
                    ringIndex = 2;
                }else{
                    ringIndex = 3;
                }
            }
        }

        NSInteger index = [self getIndexOfItemByTag:@"进入下级分组方式"];
        [self notifyDataSource:[NSIndexPath indexPathForRow:index inSection:0] valueString:model.title idString:model.itmeId];
        
        [self updateDataSourceByEnterWay];
        
    }else if (flag == 6){
        ///按键长度
        [self changeSelectedFlag:sourceChildNavKeyNumLength index:index];
        
        ///@"请选择类型";
        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[sourceChildNavKeyNumLength objectAtIndex:index];
        NSLog(@"title:%@   ids:%@",model.title,model.itmeId);
        NSInteger ringIndex = 3;
        
        ///已开通彩铃
        if ([CommonStaticVar getRingStatus] == 1) {
            ringIndex = 4;
            NSLog(@"----keyIndex---2-->");
        }else{
            ///设置了下级导航  或  有开启下级导航的权限
            ringIndex = 3;
            NSLog(@"----keyIndex---3-->");
        }
        
        ///已开通IVR
        if ([CommonStaticVar getIvrStatus] == 1) {
            ///已开通彩铃
            if ([CommonStaticVar getRingStatus] == 1) {
                ///设置了下级导航
                if([self.navigationsetChild isEqualToString:@"yes"]){
                    ringIndex = 4;
                    
                }else{
                    ringIndex = 5;
                }
            }else{
                ///设置了下级导航
                if([self.navigationsetChild isEqualToString:@"yes"]){
                    ringIndex = 3;
                }else{
                    ringIndex = 4;
                }
            }
        }
        
        NSLog(@"keyIndex:%ti",ringIndex);
        NSInteger index = [self getIndexOfItemByTag:@"下级分组按键长度"];
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


#pragma mark - UIAlertView

///没有下级导航
-(void)showAlertByOffChild{

    UIAlertView *alertCall = [[UIAlertView alloc] initWithTitle:nil message: @"此操作将会删除所有分组及其关联的坐席" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alertCall.tag = 100;
    [alertCall show];
}

///删除坐席
-(void)showAlertByOffSit{
    
    UIAlertView *alertCall = [[UIAlertView alloc] initWithTitle:nil message: @"此操作将会删除分组下的所有坐席" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alertCall.tag = 101;
    [alertCall show];
}


#pragma mark - 座席排序
-(void)sortSeats{
    SortNavigationSeatsViewController *contorller = [[SortNavigationSeatsViewController alloc] init];
    contorller.dataSourceOld = sitList;
    contorller.navitaionId = [self.navigationDic safeObjectForKey:@"navigationId"];
    __weak typeof(self) weak_self = self;
    contorller.NotifyNavigationSitList = ^(NSMutableArray *array){
        ///刷新座席列表  使用本地数据
        [sitList removeAllObjects];
        [sitList addObjectsFromArray:array];
        [weak_self updateAllDataSource:@"sit"];
        [weak_self.tableview reloadData];
    };
    
    [self.navigationController pushViewController:contorller animated:YES];
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
    [alert textFieldAtIndex:0].text = [[sitList objectAtIndex:indexChangedItem]safeObjectForKey:@"WAITDURATION"];
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
    }else if(alertView.tag == 100)
    {
        ///关闭下级导航
        if(buttonIndex == 0)
        {
            return;
        }
        
        if (buttonIndex == 1) {
            /*
            ///删除导航或坐席
            if ([typeAction isEqualToString:@"navigation"]) {
                [navigationList removeAllObjects];
                [self notifyDataSource:indexSwitich valueString:@"0" idString:@""];
                ///刷新数据源
                [self updateDataSourceByNavHasChild];
            }else if ([typeAction isEqualToString:@"sit"]) {
                [sitList removeAllObjects];
                [self notifyDataSource:indexSwitich valueString:@"1" idString:@""];
                ///刷新数据源
                [self updateDataSourceByNavHasChild];
            }
             */
            
            ///删除导航
            [self deleteNavigationListOrSitList];
        }
    }else if(alertView.tag == 101)
    {
        ///关闭下级导航
        if(buttonIndex == 0)
        {
            return;
        }
        
        if (buttonIndex == 1) {
            /*
             ///删除导航或坐席
             if ([typeAction isEqualToString:@"navigation"]) {
             [navigationList removeAllObjects];
             [self notifyDataSource:indexSwitich valueString:@"0" idString:@""];
             ///刷新数据源
             [self updateDataSourceByNavHasChild];
             }else if ([typeAction isEqualToString:@"sit"]) {
             [sitList removeAllObjects];
             [self notifyDataSource:indexSwitich valueString:@"1" idString:@""];
             ///刷新数据源
             [self updateDataSourceByNavHasChild];
             }
             */
            
            ///删除坐席
            [self deleteNavigationSitList];
        }
    }
}

#pragma mark - 坐席 时间、地区策略
///跳转到地区页面
-(void)gotoAreaTypeView:(NSString *)navigationOrSit andNavigationSitItem:(NSDictionary *)sitItem{
    NSString *navigationId = [self.navigationDic  safeObjectForKey:@"navigationId"];
    SelectAreaTypeViewController *controller = [[SelectAreaTypeViewController alloc] init];
    controller.navigationOrSit = navigationOrSit;
    controller.navigationId = navigationId;
    controller.detail = sitItem;
    if (self.enterNavigationWay == EnterNavWayShunt) {
        controller.flagOfNeedJudge = @"yes";
    }else{
        controller.flagOfNeedJudge = @"no";
    }
    ///导航详情  地区策略
    controller.areaStrategyNavDic = self.navigationDic;
    [self.navigationController pushViewController:controller animated:YES];
}


///跳转到时间页面
-(void)gotoTimeTypeView:(NSString *)navigationOrSit andNavigationSitItem:(NSDictionary *)sitItem{
    NSString *navigationId = [self.navigationDic  safeObjectForKey:@"navigationId"];
    SelectTimeTypeViewController *controller = [[SelectTimeTypeViewController alloc] init];
    controller.navigationOrSit = navigationOrSit;
    controller.navigationId = navigationId;
    controller.detail = sitItem;
    
    if (self.enterNavigationWay == EnterNavWayShunt) {
        controller.flagOfNeedJudge = @"yes";
    }else{
        controller.flagOfNeedJudge = @"no";
    }
    controller.flagOfNeedJudge = @"no";
    
    ///导航详情  时间策略
    controller.timeStrategyNavDic = self.navigationDic;
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - 网络请求

#pragma mark 获取初始化导航字典信息

#pragma mark 获取导航详情
-(void)getNavigationDetails{
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rDict setValue:self.navigationIdIvr forKey:@"navigationId"];
    
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
    
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_NAVIGATION_DETAILS_ACTION] params:rParam success:^(id jsonResponse) {
        
        [hud hide:YES];
        NSLog(@"导航详情jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            if ([jsonResponse objectForKey:@"resultMap"]) {
                self.navigationDic = [jsonResponse objectForKey:@"resultMap"];
                if (self.navigationDic) {
                    [self initNavigationData];
                }else{
                     [CommonFuntion showToast:@"加载失败" inView:self.view];
                }
                
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


-(void)getNavigationDictionary{
//    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:hud];
//    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_INIT_NAVIGATION_ACTION] params:params success:^(id jsonResponse) {
//        [hud hide:YES];
        
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
                [self initByDetailsData];
                
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
//        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
    
}


#pragma mark - 删除根导航的坐席列表
-(void)deleteNavigationSitList{
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    ///非根目录则传
    
    [rDict setValue:[self.navigationDic safeObjectForKey:@"navigationId"] forKey:@"navigationId"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    [rParam setObject:jsonString forKey:@"data"];
    
    NSLog(@"rParam:%@",rParam);
    
    NSString *url = LLC_DELETE_NAVIGATION_SIT_ACTION;
    
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,url] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        NSLog(@"删除导航/坐席jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            [CommonFuntion showToast:@"删除成功" inView:self.view];
            
            [sitList removeAllObjects];
            [self notifyDataSource:indexSwitich valueString:@"1" idString:@""];
            ///刷新数据源
            [self updateDataSourceByNavHasChild];
            
            if (self.NotifySitListBlock) {
                self.NotifySitListBlock();
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self deleteNavigationSitList];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"删除失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        
    }];
    
}



#pragma mark - 删除导航的下级导航列表
-(void)deleteNavigationListOrSitList{
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    ///非根目录则传
    
    [rDict setValue:[self.navigationDic safeObjectForKey:@"navigationId"] forKey:@"navigationId"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    [rParam setObject:jsonString forKey:@"data"];
    
    NSLog(@"rParam:%@",rParam);
    
//    NSString *url = @"";
//    if ([typeAction isEqualToString:@"navigation"]) {
//        url = LLC_DELETE_NAVIGATION_CHILD_SIT_ACTION;
//    }else if ([typeAction isEqualToString:@"sit"]) {
//        url = LLC_DELETE_NAVIGATION_CHILD_SIT_ACTION;
//    }
    
    NSString *url = LLC_DELETE_NAVIGATION_CHILD_SIT_ACTION;
//    if ([typeAction isEqualToString:@"navigation"]) {
//        url = LLC_DELETE_NAVIGATION_CHILD_SIT_ACTION;
//    }else if ([typeAction isEqualToString:@"sit"]) {
//        url = LLC_DELETE_NAVIGATION_CHILD_SIT_ACTION;
//    }
    
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,url] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        NSLog(@"删除导航/坐席jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            [CommonFuntion showToast:@"删除成功" inView:self.view];
            
            [navigationList removeAllObjects];
            [self notifyDataSource:indexSwitich valueString:@"0" idString:@""];
            ///刷新数据源
            [self updateDataSourceByNavHasChild];
            
            if (self.NotifySitListBlock) {
                self.NotifySitListBlock();
            }
            
//            ///删除导航或坐席
//            if ([typeAction isEqualToString:@"navigation"]) {
//                [navigationList removeAllObjects];
//                [self notifyDataSource:indexSwitich valueString:@"0" idString:@""];
//                ///刷新数据源
//                [self updateDataSourceByNavHasChild];
//            }else if ([typeAction isEqualToString:@"sit"]) {
//                [sitList removeAllObjects];
//                [self notifyDataSource:indexSwitich valueString:@"1" idString:@""];
//                ///刷新数据源
//                [self updateDataSourceByNavHasChild];
//            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self deleteNavigationListOrSitList];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"删除失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        
    }];
    
}


#pragma mark - 获取当前导航的下级导航列表/坐席列表
-(void)getNavigationListOrSitList{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    ///非根目录则传
    
    [rDict setValue:[self.navigationDic safeObjectForKey:@"navigationId"] forKey:@"navigationId"];
    [rDict setValue:[NSString stringWithFormat:@"%i",listPage] forKey:@"pageSize"];
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    [rDict setValue:[NSString stringWithFormat:@"%i",listPage] forKey:@"pageSize"];
    [rParam setObject:jsonString forKey:@"data"];
    
    NSLog(@"rParam:%@",rParam);
    
    NSString *url = @"";
    if ([typeAction isEqualToString:@"navigation"]) {
        url = LLC_GET_CUR_NAVIGATION_CHILDNAVIGATION_ACTION;
    }else if ([typeAction isEqualToString:@"sit"]) {
        url = LLC_GET_CUR_NAVIGATION_SITS_ACTION;
    }
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,url] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        [self addNavBar];
        NSLog(@"导航/坐席jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            [self setViewRequestSusscess:jsonResponse];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getNavigationListOrSitList];
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

// 请求成功时数据处理
-(void)setViewRequestSusscess:(NSDictionary *)jsonResponse
{
    id data;
    if ([typeAction isEqualToString:@"navigation"]) {
        data = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"childNavigationList"];
        
        
        
        if ([data respondsToSelector:@selector(count)] && [data count] > 0) {

            if (listPage == 1) {
                [navigationList removeAllObjects];
                pageSize = [data count];
            }
            
            ///添加当前页数据到列表中...
            [navigationList addObjectsFromArray:data];
            
            ///页码++
            if ([data count] == pageSize) {
                listPage++;
                [self.tableview setFooterHidden:NO];
            }else
            {
                ///隐藏上拉刷新
                [self.tableview setFooterHidden:YES];
            }
            
        }else{
            ///隐藏上拉刷新
            [self.tableview setFooterHidden:YES];
        }
        
        if (!isEditingStarus) {
          
            ///设置了下级导航 并且是按键进入下级导航
            if([self.navigationsetChild isEqualToString:@"yes"] && [[self.navigationDic safeObjectForKey:@"navigationType"] integerValue] == 0){
//                [self updateAllDataSource:@"navigationlist"];
            }
        }
        
    }else if ([typeAction isEqualToString:@"sit"]) {
        data = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"sitList"];
        if ([data respondsToSelector:@selector(count)] && [data count] > 0) {
            if (listPage == 1) {
                [sitList removeAllObjects];
                pageSize = [data count];
            }
            ///添加当前页数据到列表中...
            [sitList addObjectsFromArray:data];
            
            ///页码++
            if ([data count] == pageSize) {
                listPage++;
                [self.tableview setFooterHidden:NO];
            }else
            {
                ///隐藏上拉刷新
                [self.tableview setFooterHidden:YES];
            }
        }else{
            ///隐藏上拉刷新
            [self.tableview setFooterHidden:YES];
        }
        [self updateAllDataSource:@"sit"];
    }
}

// 请求失败时数据处理
-(void)setViewRequestFaild:(NSString *)desc
{
    
}

#pragma mark - 编辑等待时长
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
    
    [rDict setValue: [self.navigationDic safeObjectForKey:@"navigationId"] forKey:@"navigationId"];
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

#pragma mark - 编辑导航

-(NSDictionary *)getParamIVR{
    
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    NSMutableString *strKeyNum = [[NSMutableString alloc] init];
    NSMutableString *nextNavigationId = [[NSMutableString alloc] init];
    
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
            if ([CommonStaticVar getIvrStatus] == 1) {
                if ([typeAction isEqualToString:@"navigation"]) {
                    for (int k=0; k<[array count]; k++) {
                        EditItemModel *item  = (EditItemModel*) [array objectAtIndex:k];
                        
                        if (item.keyStr && item.keyStr.length > 0) {
                            //                    [rDict setValue:item.content forKey:item.keyStr];
                            NSLog(@"key: %@   value: %@",item.keyStr,item.content);
                            if ([strKeyNum isEqualToString:@""]) {
                                [strKeyNum appendString:item.content];
                            }else{
                                [strKeyNum appendString:@","];
                                [strKeyNum appendString:item.content];
                            }
                        }
                        
                        if (item.keyType && item.keyType.length > 0) {
                            //                    [rDict setValue:item.keyType forKey:@"nextNavigationId"];
                            
                            if ([nextNavigationId isEqualToString:@""]) {
                                [nextNavigationId appendString:item.keyType];
                            }else{
                                [nextNavigationId appendString:@","];
                                [nextNavigationId appendString:item.keyType];
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    [rDict setValue:[self.navigationDic safeObjectForKey:@"navigationName"] forKey:@"navigationName"];
    [rDict setValue:[self.navigationDic safeObjectForKey:@"navigationId"] forKey:@"navigationId"];
    
    ///是按键进入方式
    if (strKeyNum && strKeyNum.length > 0) {
        [rDict setValue:nextNavigationId forKey:@"nextNavigationId"];
        [rDict setValue:strKeyNum forKey:@"nextNavigationKey"];
    }
    else{
        ///补全参数
        [rDict setValue:@"" forKey:@"nextNavigationId"];
        [rDict setValue:@"" forKey:@"nextNavigationKey"];
    }
    
    /*
     sitRingId
     hasChildNavigation
     navigationKey
     enterNavigationWay
     keyLength
     */
    ///补全参数
    
    if (![rDict objectForKey:@"navigationKey"]) {
        [rDict setValue:@"" forKey:@"navigationKey"];
    }
    if (![rDict objectForKey:@"enterNavigationWay"]) {
        [rDict setValue:@"" forKey:@"enterNavigationWay"];
    }
    if (![rDict objectForKey:@"keyLength"]) {
        [rDict setValue:@"" forKey:@"keyLength"];
    }
    
    if (![rDict objectForKey:@"ringId"]) {
        [rDict setValue:@"" forKey:@"ringId"];
    }
    
    if (![rDict objectForKey:@"sitRingId"]) {
        [rDict setValue:@"" forKey:@"sitRingId"];
    }
    
    if (![rDict objectForKey:@"hasChildNavigation"]) {
        [rDict setValue:@"0" forKey:@"hasChildNavigation"];
    }
    if (![rDict objectForKey:@"answerStrategy"]) {
        [rDict setValue:@"" forKey:@"answerStrategy"];
    }
    
    return rDict;
}


-(void)editNavition{
    NSDictionary *rDict = [self getParamIVR];
    
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
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_EDIT_NAVIGATION_ACTION] params:rParam success:^(id jsonResponse) {
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
    if (self.NotifySitListBlock) {
        self.NotifySitListBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
