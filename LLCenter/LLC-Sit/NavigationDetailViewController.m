//
//  NavigationDetailViewController.m
//  
//
//  Created by sungoin-zjp on 16/1/8.
//
//

#import "NavigationDetailViewController.h"
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
#import "AFSoundPlaybackHelper.h"

@interface NavigationDetailViewController ()<UITableViewDataSource,UITableViewDelegate,LLCenterSheetMenuDelegate>{
    
    ///导航信息 请求获取到
    NSDictionary *navigationDicAll;
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
    ///标记修改item的下标
    NSInteger indexChangedItem;
    
    //分页加载
    int listPage;
    NSInteger pageSize;

}

@property(strong,nonatomic) TPKeyboardAvoidingTableView *tableview;
@property(strong,nonatomic) NSMutableArray *dataSource;
///all data (详情+坐席列表)
@property(strong,nonatomic) NSMutableArray *dataSourceAll;
///section 2  座席列表  用于缓存更改信息
@property(strong,nonatomic) NSMutableArray *dataSourceSeats;

@end

@implementation NavigationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"分组详情";
    self.view.backgroundColor = COLOR_BG;
    
    [self initTableview];
    
    soureRing = [[NSMutableArray alloc] init];
    sourceEnterNavigationWay = [[NSMutableArray alloc] init];
    sourceChildNavKeyNumLength = [[NSMutableArray alloc] init];
    sourceStrategy = [[NSMutableArray alloc] init];
    
    ///初始化按键长度与进入方式
    [self initKeyNumLengthAndEndWay];
    ///获取导航详情
    [self getNavigationDetails];
    [self getNavigationDictionary];
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
        
        EditItemModel *itemNavName = (EditItemModel *)[[[self.dataSourceAll objectAtIndex:0] objectForKey:@"content"] objectAtIndex:0];
        
        if ([[itemNavName.content stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
            [CommonFuntion showToast:@"分组名称不能为空" inView:self.view];
            return;
        }
        
        if ([CommonFunc isStringNullObject:itemNavName.content]) {
            [CommonFuntion showToast:@"分组名称不能为null" inView:self.view];
            return;
        }
        
        if (itemNavName.content.length>100 ) {
            [CommonFuntion showToast:@"分组名称为1-100个中英文、数字特殊字符" inView:self.view];
            return;
        }
        
        ///按键进入
        if (self.enterNavigationWay == EnterNavWayByKeyNum) {
            EditItemModel *itemKeyNum = (EditItemModel *)[[[self.dataSourceAll objectAtIndex:0] objectForKey:@"content"] objectAtIndex:1];
            if ([[itemKeyNum.content stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
                [CommonFuntion showToast:@"分组按键不能为空" inView:self.view];
                return;
            }
            
            if (self.curNavigationKeyLength > 0 && self.curNavigationKeyLength < 7) {
                
                if (itemKeyNum.content.length != self.curNavigationKeyLength) {
                    [CommonFuntion showToast:[NSString  stringWithFormat:@"分组按键长度为%ti",self.curNavigationKeyLength] inView:self.view];
                    return;
                }
                
            }
        }
        
        [self editNavition];
    }
}


#pragma mark - 根据导航详情  初始化信息
///根导航详情信息
-(void)initDetailsData:(id)jsondata{
    self.navigationDic = [jsondata objectForKey:@"resultMap"];
    if (self.navigationDic) {
        [self addNavBar];
        [self initData];
        ///获取当前导航下的坐席列表
        [self getNavigationSitList];
        ///构建详情UI元素
        [self initDataWithActionTypeDetail];
    }
}


#pragma mark - 初始化数据
-(void)initData{
    
    
    
    
    listPage = 1;
    indexChangedItem = -1;
    isEditingStarus = FALSE;
    self.listenStrategy = 1;
    
    self.dataSource = [[NSMutableArray alloc] init];
    self.dataSourceAll = [[NSMutableArray alloc] init];
    self.dataSourceSeats = [[NSMutableArray alloc] init];
    
    ///初始化导航信息
    ///进入方式
    if ([[self.navigationDic safeObjectForKey:@"currentType"] isEqualToString:@"0"]) {
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
    
    ///按键.长度
    self.curNavigationKeyLength = [[self.navigationDic safeObjectForKey:@"childNavigationKeyLength"] integerValue];
    
    
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
    NSDictionary *item2 = [[NSDictionary alloc] initWithObjectsAndKeys:@"0",@"id",@"顺序接听",@"name", nil];
    [sourceStrategy addObject:item2];
    item2 = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"id",@"随机接听",@"name", nil];
    [sourceStrategy addObject:item2];
    item2 = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"id",@"平均接听",@"name", nil];
    [sourceStrategy addObject:item2];
    
    
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
            self.listenStrategy = 0;
            break;
        case 1:
            answerStrategy = @"随机接听";
            self.listenStrategy = 1;
            break;
        case 2:
            answerStrategy = @"平均接听";
            self.listenStrategy = 2;
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
    
    
    [soureRing removeAllObjects];
    [soureRing addObjectsFromArray:array1];

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
    
    count = 0;
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
    NSString *navigationKey = [self.navigationDic safeObjectForKey:@"navigationKey"];
    NSString *ringName = [self.navigationDic safeObjectForKey:@"navigationRingName"];
    NSString *ringId = [self.navigationDic safeObjectForKey:@"navigationRingId"];
    NSString *enterNavigationWayId = [self.navigationDic safeObjectForKey:@"navigationType"];
    NSString *enterNavigationWay = [self getEnterNavWayNameById:enterNavigationWayId];
    NSString *answerStrategy =  [self.navigationDic safeObjectForKey:@"answerStrategy"];
    
    ///是否显示彩铃
    BOOL isShowRing = FALSE;
    
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
    
    ///按键进入
    if (self.enterNavigationWay == EnterNavWayByKeyNum) {
        model = [[EditItemModel alloc] init];
        model.title = @"分组按键:";
        model.content = navigationKey;
//        if (self.curNavigationKeyLength > 0 && self.curNavigationKeyLength < 7) {
//            model.placeholder = [NSString stringWithFormat:@"请输入%ti位导航按键",self.curNavigationKeyLength];
//        }else{
//            model.placeholder = @"请输入导航按键";
//        }
        model.cellType = @"cellA";
//        model.keyStr = @"navigationKey";
        model.keyStr = @"";
        model.keyType = @"";
        [self.dataSource addObject:model];
    }
    
    
    ///已开通IVR
    if ([CommonStaticVar getIvrStatus] == 1) {
        ///分流方式
        if (self.enterNavigationWay == EnterNavWayShunt) {
            ///已开通彩铃
            if ([CommonStaticVar getRingStatus] == 1) {
                isShowRing = TRUE;
            }
        }
    }else{
        ///已开通彩铃
        if ([CommonStaticVar getRingStatus] == 1) {
            isShowRing = TRUE;
        }
    }
    
    if (isShowRing) {
        if (ringName.length > 0) {
            model = [[EditItemModel alloc] init];
            model.title = @"彩铃:";
            model.itemId = ringId;
            model.content = ringName;
            model.placeholder = @"";
            model.cellType = @"cellB";
            model.keyStr = @"ringId";
            model.keyType = @"ringId";
            model.enabled = @"no";
            [self.dataSource addObject:model];
        }
    }
    
    ///分流方式
    if (self.enterNavigationWay == EnterNavWayShunt) {
        ///时间类型  全部时间1 星期时间 2  节假日3
        NSString *timeType = [self.navigationDic safeObjectForKey:@"timeType"];
        timeType = [CommonFunc getNavTimeType:timeType];
        
        model = [[EditItemModel alloc] init];
        model.title = @"时间类型:";
        model.itemId = @"";
        model.content = timeType;;
        model.placeholder = @"";
        model.cellType = @"cellB";
        model.keyStr = @"";
        model.keyType = @"";
        model.enabled = @"no";
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
        model.content = areaName;;
        model.placeholder = @"";
        model.cellType = @"cellB";
        model.keyStr = @"";
        model.keyType = @"";
        model.enabled = @"no";
        [self.dataSource addObject:model];
    }
    
    
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
    
    [self updateAllDataSource];
    
    NSLog(@"self.dataSource:%@",self.dataSource);
    for (int i=0; i<[self.dataSource count]; i++) {
        EditItemModel *item  = (EditItemModel*) [self.dataSource objectAtIndex:i];
        NSLog(@"%@  %@",item.title,item.cellType);
    }
}


#pragma mark - 根据操作类型 编辑详情 初始化数据源
-(void)initDataWithActionTypeEditing{
    
    NSString *navigationName = [self.navigationDic safeObjectForKey:@"navigationName"];
    NSString *navigationKey = [self.navigationDic safeObjectForKey:@"navigationKey"];
    NSString *ringName = [self.navigationDic safeObjectForKey:@"navigationRingName"];
    NSString *ringId = [self.navigationDic safeObjectForKey:@"navigationRingId"];
    NSString *enterNavigationWayId = [self.navigationDic safeObjectForKey:@"navigationType"];
    NSString *enterNavigationWay = [self getEnterNavWayNameById:enterNavigationWayId];
    NSString *answerStrategy =  [self.navigationDic safeObjectForKey:@"answerStrategy"];
    
    ///是否显示彩铃
    BOOL isShowRing = FALSE;
    
    EditItemModel *model;
    
    model = [[EditItemModel alloc] init];
    model.title = @"分组名称:";
    model.content = navigationName;
    model.placeholder = @"1-100个中英文、数字特殊字符";
    model.cellType = @"cellA";
    model.keyStr = @"navigationName";
    model.keyType = @"";
    model.itemTag = @"分组名称";
    [self.dataSource addObject:model];
    
    ///按键进入
    if (self.enterNavigationWay == EnterNavWayByKeyNum) {
        model = [[EditItemModel alloc] init];
        model.title = @"分组按键:";
        model.content = navigationKey;
        if (self.curNavigationKeyLength > 0 && self.curNavigationKeyLength < 7) {
            model.placeholder = [NSString stringWithFormat:@"请输入%ti位分组按键",self.curNavigationKeyLength];
        }else{
            model.placeholder = @"请输入分组按键";
        }
        model.cellType = @"cellA";
        model.keyStr = @"navigationKey";
        model.keyType = @"";
        model.itemTag = @"分组按键";
        [self.dataSource addObject:model];
    }
    
    
    ///已开通IVR
    if ([CommonStaticVar getIvrStatus] == 1) {
        ///分流方式
        if (self.enterNavigationWay == EnterNavWayShunt) {
            ///已开通彩铃
            if ([CommonStaticVar getRingStatus] == 1) {
                isShowRing = TRUE;
            }
        }
    }else{
        ///已开通彩铃
        if ([CommonStaticVar getRingStatus] == 1) {
            isShowRing = TRUE;
        }
    }
    
    if (isShowRing) {
        model = [[EditItemModel alloc] init];
        model.title = @"彩铃:";
        model.itemId = ringId;
        model.content = ringName;
        model.placeholder = @"";
        model.cellType = @"cellB";
        model.keyStr = @"ringId";
        model.keyType = @"ringId";
        model.itemTag = @"彩铃";
        [self.dataSource addObject:model];
    }
    
    ///分流方式
    if (self.enterNavigationWay == EnterNavWayShunt) {
        ///时间类型  全部时间1 星期时间 2  节假日3
        NSString *timeType = [self.navigationDic safeObjectForKey:@"timeType"];
        timeType = [CommonFunc getNavTimeType:timeType];
        
        model = [[EditItemModel alloc] init];
        model.title = @"时间类型:";
        model.itemId = @"";
        model.content = timeType;;
        model.placeholder = @"";
        model.cellType = @"cellB";
        model.keyStr = @"";
        model.keyType = @"";
        model.itemTag = @"时间类型";
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
        model.content = areaName;;
        model.placeholder = @"";
        model.cellType = @"cellB";
        model.keyStr = @"";
        model.keyType = @"";
        model.itemTag = @"地区类型";
        [self.dataSource addObject:model];
    }
    
    
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
    
    [self updateAllDataSource];
    
    
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


#pragma mark - 刷新数据源
-(void)updateAllDataSource{

    [self.dataSourceAll removeAllObjects];
    
    NSMutableDictionary *dicDataSource = [[NSMutableDictionary alloc] init];
    
    [dicDataSource setObject:@"分组信息" forKey:@"head"];
    [dicDataSource setObject:self.dataSource forKey:@"content"];
    
    [self.dataSourceAll addObject:dicDataSource];
    
    ///存在坐席
    if (self.dataSourceSeats && [self.dataSourceSeats count] > 0) {
        ///展示坐席列表
        dicDataSource = [[NSMutableDictionary alloc] init];
        
        [dicDataSource setObject:@"坐席列表" forKey:@"head"];
        [dicDataSource setObject:self.dataSourceSeats forKey:@"content"];
        [self.dataSourceAll addObject:dicDataSource];
    }
    
    NSLog(@"self.dataSourceAll:%@",self.dataSourceAll);
    [self.tableview reloadData];
}


#pragma mark - 播放音频
-(void)playSoundByUrl:(NSString *)urlSound{
    NSString *urlString = [self.navigationDic safeObjectForKey:@"navigationRingUrl"];
    NSLog(@"playNavigationRing urlString:%@",urlString);
    
    [AFSoundPlaybackHelper  playAndCacheWithUrl:urlString];
    
    /*
    [AFSoundPlaybackHelper stop_helper];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AFSoundItem *item = [[AFSoundItem alloc] initWithStreamingURL:[NSURL URLWithString:urlString]];
        [AFSoundPlaybackHelper setAFSoundPlaybackHelper:[[AFSoundPlayback alloc] initWithItem:item]];
        
        [AFSoundPlaybackHelper play_helper];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AFSoundPlaybackHelper getAFSoundPlaybackHelper] listenFeedbackUpdatesWithBlock:^(AFSoundItem *item) {
                NSLog(@"Item duration: %ld - time elapsed: %ld", (long)item.duration, (long)item.timePlayed);
            } andFinishedBlock:^(void){
                NSLog(@"andFinishedBlock");
            }];
        });
    });
     */
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
    [self getNavigationDetails];
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
    [self getNavigationSitList];
}



-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}


#pragma mark - tableview

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 40;
    }
    return 20;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1 && self.dataSourceSeats && [self.dataSourceSeats count]>0) {
        UIView *headview =[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
        headview.backgroundColor = COLOR_BG;
        
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 20)];
        labelTitle.textColor = [UIColor blackColor];
        labelTitle.font = [UIFont systemFontOfSize:15.0];
        labelTitle.text = @"坐席列表";
        [headview addSubview:labelTitle];
        
        ///编辑状态  当为顺序接听时 才显示排序按钮
        if (isEditingStarus &&  self.listenStrategy == ListenStrategySequence) {
            if (self.dataSourceSeats && [self.dataSourceSeats count] > 0) {
                
                UIButton *btnSort = [UIButton buttonWithType:UIButtonTypeCustom];
                btnSort.frame = CGRectMake(kScreen_Width-30, 10, 20, 20);
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
            
            ///播放音频
            cell.SelectDataActionBlock = ^(NSInteger action){
                NSLog(@"播放音频");
                [weak_self playSoundByUrl:@""];
            };
            
            cell.SelectDataTypeBlock = ^(NSInteger type){
                ///1彩铃  2时间类型 3地区类型  4接听策略
                
                NSInteger flag = -1;
                if ([item.itemTag isEqualToString:@"彩铃"]) {
                    flag = 1;
                }else if ([item.itemTag isEqualToString:@"时间类型"]) {
                    flag = 2;
                }else if ([item.itemTag isEqualToString:@"地区类型"]) {
                    flag = 3;
                }
                else if ([item.itemTag isEqualToString:@"接听策略"]) {
                    flag = 4;
                }

                [weak_self showMenuByFlag:flag withIndexPath:indexPath];
            };
            [cell setCellDetail:item];
            return cell;
        }
    }else{
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
                [weak_self gotoAreaTypeView:@"sit" andNavigationSitItem:[self.dataSourceSeats objectAtIndex:index]];
            };
            
            ///时间
            cell.ChangeTimeTypeBlock = ^(NSInteger index){
                NSLog(@"index:%ti",index);
                [weak_self gotoTimeTypeView:@"sit" andNavigationSitItem:[self.dataSourceSeats objectAtIndex:index]];
            };
            
            return cell;
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
    NSDictionary *item = [self.dataSourceSeats objectAtIndex:index];
    ///修改本地数据
    NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:item];
    [mutableItemNew setObject:duration forKey:@"WAITDURATION"];
    //修改数据
    [self.dataSourceSeats setObject: mutableItemNew atIndexedSubscript:index];
    
    [self.tableview reloadData];
}




#pragma mark - 弹框
///根据flag 弹框  ///1彩铃  2时间类型 3地区类型  4接听策略
-(void)showMenuByFlag:(NSInteger)flag withIndexPath:(NSIndexPath *)indexPath{
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    if (flag == -1) {
        return;
    }
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
    ///1彩铃  2时间类型 3地区类型  4接听策略
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

        NSInteger index = [self getIndexOfItemByTag:@"接听策略"];
        
        if ([model.itmeId isEqualToString:@"0"]) {
            self.listenStrategy = ListenStrategySequence;
        }else if ([model.itmeId isEqualToString:@"1"]) {
            self.listenStrategy = ListenStrategyRandom;
        }else if ([model.itmeId isEqualToString:@"2"]) {
            self.listenStrategy = ListenStrategyAverage;
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


#pragma mark - 座席排序
-(void)sortSeats{
    SortNavigationSeatsViewController *contorller = [[SortNavigationSeatsViewController alloc] init];
    contorller.dataSourceOld = self.dataSourceSeats;
    contorller.navitaionId = [self.navigationDic safeObjectForKey:@"navigationId"];
    __weak typeof(self) weak_self = self;
    contorller.NotifyNavigationSitList = ^(NSMutableArray *array){
        ///刷新座席列表  使用本地数据
        [weak_self.dataSourceSeats removeAllObjects];
        [weak_self.dataSourceSeats addObjectsFromArray:array];
        [weak_self updateAllDataSource];
        [weak_self.tableview reloadData];
    };
    
    [self.navigationController pushViewController:contorller animated:YES];
}


#pragma mark - 导航选择时间类型
-(void)navigationTimeType:(NSIndexPath *)indexPath{
    NSString *navigationId = [self.navigationDic  safeObjectForKey:@"navigationId"];
    
    SelectTimeTypeViewController *controller = [[SelectTimeTypeViewController alloc] init];
    controller.navigationOrSit = @"navigation";
    controller.navigationId = navigationId;
    controller.detail = self.navigationDic;
    controller.flagOfNeedJudge = @"yes";
    __weak typeof(self) weak_self = self;
    controller.TimeTypeBlock = ^(NSString *timeType){
        ///返回时间类型 和具体的时间值
        ///类型在UI上展示出来
        ///重新请求详情信息
        ///已开通IVR
        NSInteger indexRow = 0;
        if ([CommonStaticVar getIvrStatus] == 1) {
            ///已开通彩铃
            if ([CommonStaticVar getRingStatus] == 1) {
                indexRow = 2;
            }else{
                indexRow = 1;
            }
        }else{
            ///已开通彩铃
            if ([CommonStaticVar getRingStatus] == 1) {
                indexRow = 2;
            }else{
                indexRow = 1;
            }
        }
        
        NSLog(@"indexRow:%ti",indexRow);
        NSLog(@"indexPath row:%ti",indexPath.row);
        [weak_self notifyDataSource:[NSIndexPath indexPathForRow:indexRow inSection:0] valueString:timeType idString:@""];
        [weak_self.tableview reloadData];
        [self getNavigationDetailsOnly];
    };
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - 导航选择地区类型
-(void)navigationAreaType:(NSIndexPath *)indexPath{
    NSString *navigationId = [self.navigationDic  safeObjectForKey:@"navigationId"];
    
    SelectAreaTypeViewController *controller = [[SelectAreaTypeViewController alloc] init];
    controller.navigationOrSit = @"navigation";
    controller.navigationId = navigationId;
    controller.detail = self.navigationDic;
    controller.flagOfNeedJudge = @"yes";
    
    __weak typeof(self) weak_self = self;
    controller.AreaTypeBlock = ^(NSString *areaType){
        ///返回地区类型 和具体的地区值
        ///类型在UI上展示出来
        NSLog(@"areaType:%@",areaType);
        
        NSInteger indexRow = 0;
        if ([CommonStaticVar getIvrStatus] == 1) {
            ///已开通彩铃
            if ([CommonStaticVar getRingStatus] == 1) {
                indexRow = 3;
            }else{
                indexRow = 2;
            }
        }else{
            ///已开通彩铃
            if ([CommonStaticVar getRingStatus] == 1) {
                indexRow = 3;
            }else{
                indexRow = 2;
            }
        }
        NSLog(@"indexRow:%ti",indexRow);
        NSLog(@"indexPath row:%ti",indexPath.row);
        [weak_self notifyDataSource:[NSIndexPath indexPathForRow:indexRow inSection:0] valueString:areaType idString:@""];
        [weak_self.tableview reloadData];
        [self getNavigationDetailsOnly];
    };
    
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
    [alert textFieldAtIndex:0].text = [[self.dataSourceSeats objectAtIndex:indexChangedItem]safeObjectForKey:@"WAITDURATION"];
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
    
    ///导航详情  时间策略
    controller.timeStrategyNavDic = self.navigationDic;
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - 网络请求
#pragma mark 获取导航详情

-(void)getNavigationDetailsOnly{
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    if ([self.navigationDic safeObjectForKey:@"ivrId"].length > 0) {
        [rDict setValue:[self.navigationDic safeObjectForKey:@"ivrId"] forKey:@"navigationId"];
    }else{
        [rDict setValue:[self.navigationDic safeObjectForKey:@"navigationId"] forKey:@"navigationId"];
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_NAVIGATION_DETAILS_ACTION] params:rParam success:^(id jsonResponse) {
        NSLog(@"导航详情jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            if ([jsonResponse objectForKey:@"resultMap"]) {
                self.navigationDic = [jsonResponse objectForKey:@"resultMap"];
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getNavigationDetailsOnly];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
//            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
//        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
    
}


-(void)getNavigationDetails{
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    if ([self.navigationDic safeObjectForKey:@"ivrId"].length > 0) {
        [rDict setValue:[self.navigationDic safeObjectForKey:@"ivrId"] forKey:@"navigationId"];
    }else{
        [rDict setValue:[self.navigationDic safeObjectForKey:@"navigationId"] forKey:@"navigationId"];
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
    
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_NAVIGATION_DETAILS_ACTION] params:rParam success:^(id jsonResponse) {
        
        [hud hide:YES];
        NSLog(@"导航详情jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            if ([jsonResponse objectForKey:@"resultMap"]) {
                
                [self initDetailsData:jsonResponse];
                
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

#pragma mark 获取初始化导航字典信息
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

#pragma mark - 获取当前导航的坐席列表
-(void)getNavigationSitList{
    
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
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_CUR_NAVIGATION_SITS_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        if(listPage == 1)
        {
            [self.dataSourceSeats removeAllObjects];
        }
        
        NSLog(@"坐席jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [self setViewRequestSusscess:jsonResponse];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getNavigationSitList];
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
        [self updateAllDataSource];
        [self reloadRefeshView];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        [self reloadRefeshView];
    }];
}


// 请求成功时数据处理
-(void)setViewRequestSusscess:(NSDictionary *)jsonResponse
{
    id data = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"sitList"];
    
    if ([data respondsToSelector:@selector(count)] && [data count] > 0) {
        
        if (listPage == 1) {
            [self.dataSourceSeats removeAllObjects];
            pageSize = [data count];
        }
        
        ///添加当前页数据到列表中...
        [self.dataSourceSeats addObjectsFromArray:data];
        
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


#pragma mark - 编辑导航设置

-(void)editNavition{
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    EditItemModel *item;
    
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
   
    
    [rDict setValue:[self.navigationDic safeObjectForKey:@"navigationId"] forKey:@"navigationId"];
    
    ///参数补全
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
    
    [rDict setValue:@"" forKey:@"nextNavigationId"];
    [rDict setValue:@"" forKey:@"nextNavigationKey"];
    
    //    [rDict setValue:self.customerId forKey:@"customerId"];
    
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
            
            //            isGotoSuperView
            
            
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
