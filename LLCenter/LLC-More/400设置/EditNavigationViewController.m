//
//  EditNavigationViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-23.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "EditNavigationViewController.h"
#import "LLCenterUtility.h"
#import "EditItemModel.h"
#import "LLcenterSheetMenuView.h"
#import "LLCenterSheetMenuModel.h"
#import "TPKeyboardAvoidingTableView.h"
#import "CommonFunc.h"
#import "EditItemTypeCellA.h"
#import "EditItemTypeCellB.h"
#import "EditItemTypeCellI.h"
#import "CommonNoDataView.h"
#import "SelectTimeTypeViewController.h"
#import "SelectAreaTypeViewController.h"

@interface EditNavigationViewController ()<UITableViewDataSource,UITableViewDelegate,LLCenterSheetMenuDelegate>{
    
    ///彩铃
    NSMutableArray *soureRing;
    ///座席提示音
    NSMutableArray *sourceSeatRing;
    ///进入下级导航的方式
    NSMutableArray *sourceEnterNavigationWay;
    ///下级导航按键长度
    NSMutableArray *sourceChildNavKeyNumLength;
    
    ///标记是否需要连续返回两次页面
    /// 有下级导航改为无  无改为有
    BOOL isGotoSuperView;
}

@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property(strong,nonatomic) TPKeyboardAvoidingTableView *tableview;

///section 1
@property(strong,nonatomic) NSMutableArray *dataSource;
///all data
@property(strong,nonatomic) NSMutableArray *dataSourceAll;
@end

@implementation EditNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑导航";
    self.view.backgroundColor = COLOR_BG;
    [super customBackButton];
    [self initTableview];
    [self initData];
    ///测试数据
//    [self readTestData];
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
    
    ///非根导航
    if ([self.isRootNavigation isEqualToString:@"no"]) {
         EditItemModel *itemNavName = (EditItemModel *)[[[self.dataSourceAll objectAtIndex:0] objectForKey:@"content"] objectAtIndex:0];
        
        if ([[itemNavName.content stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
            [CommonFuntion showToast:@"导航名称不能为空" inView:self.view];
            return;
        }
        
        if ([CommonFunc isStringNullObject:itemNavName.content]) {
            [CommonFuntion showToast:@"导航名称不能为null" inView:self.view];
            return;
        }
        
        if (itemNavName.content.length>100 ) {
            [CommonFuntion showToast:@"导航名称为1-100个中英文、数字特殊字符" inView:self.view];
            return;
        }
        
        ///按键进入
        if (self.enterNavigationWay == EnterNavWayByKeyNum) {
            EditItemModel *itemKeyNum = (EditItemModel *)[[[self.dataSourceAll objectAtIndex:0] objectForKey:@"content"] objectAtIndex:1];
            if ([[itemKeyNum.content stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
                [CommonFuntion showToast:@"导航按键不能为空" inView:self.view];
                return;
            }
            
            if (self.curNavigationKeyLength > 0 && self.curNavigationKeyLength < 7) {
                
                if (itemKeyNum.content.length != self.curNavigationKeyLength) {
                    [CommonFuntion showToast:[NSString  stringWithFormat:@"导航按键长度为%ti",self.curNavigationKeyLength] inView:self.view];
                    return;
                }
                
            }
        }

    }
    
    if (![self childNavigationKeyNumIsAllow]) {
        return;
    }
    
    ///发送请求
    [self editNavition];
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
                        [CommonFuntion showToast:@"下级导航按键不能为空" inView:self.view];
                        return FALSE;
                    }else if(![CommonFunc checkStringIsNum:item.content]){
                        ///是否为纯数字组成
                        [CommonFuntion showToast:@"导航按键由数字组成" inView:self.view];
                        return FALSE;
                    }
                    else if (item.content.length != [keyNumLength integerValue]){
                        [CommonFuntion showToast:[NSString stringWithFormat:@"下级导航按键长度应为%@",keyNumLength] inView:self.view];
                        return FALSE;
                        
                    }
                }
            }
        }
    }

    return TRUE;
}

#pragma mark - 初始化数据
-(void)initData{
    soureRing = [[NSMutableArray alloc] init];
    sourceSeatRing = [[NSMutableArray alloc] init];
    sourceEnterNavigationWay = [[NSMutableArray alloc] init];
    sourceChildNavKeyNumLength = [[NSMutableArray alloc] init];
    self.dataSource = [[NSMutableArray alloc] init];
    self.dataSourceAll = [[NSMutableArray alloc] init];
    
}


///获取下级导航id集合
-(NSString *)getChildNarIds{
    NSInteger count = 0;
    if(self.sourChildNavigation){
        count = [self.sourChildNavigation count];
    }
    NSMutableString *strIds = [[NSMutableString alloc] init];
    NSDictionary *item;
    for (int i=0; i<count; i++) {
        item = [self.sourChildNavigation objectAtIndex:i];
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
     navigationsetChild(当前导航的是否设置了下级导航0-否，1-是)
     navigationType(进入下级导航的方式 0-按键，1-分流)
     childNavigationKeyLength(下级导航的按键长度)

     */
    /*
    self.detail = [[NSDictionary alloc] initWithObjectsAndKeys:@"11111",@"navigationId",@"导航001",@"navigationName",@"啦啊啦啦啦.mp3",@"navigationRingName",@"10033454302",@"navigationRingId",@"http://www.cailing.mp3",@"navigationRingUrl",@"123456",@"navigationKeyPress",@"3002301",@"sitRingId",@"嘿咻嘿嘿.mp4",@"sitRingName",@"1",@"navigationsetChild",@"0",@"navigationType",@"2",@"childNavigationKeyLength", nil];
     */
    [self readTestNavigationData];
}


-(void)readTestNavigationData{
    
    ///彩铃
    NSDictionary *item = [[NSDictionary alloc] initWithObjectsAndKeys:@"232324",@"id",@"dingdadingda.avi",@"name", nil];
    [soureRing addObject:item];
    item = [[NSDictionary alloc] initWithObjectsAndKeys:@"10033454302",@"id",@"啦啊啦啦啦.mp3",@"name", nil];
    [soureRing addObject:item];
    
    ///座席提示音
    item = [[NSDictionary alloc] initWithObjectsAndKeys:@"3002301",@"id",@"嘿咻嘿嘿.mp4",@"name", nil];
    [sourceSeatRing addObject:item];
    item = [[NSDictionary alloc] initWithObjectsAndKeys:@"3340002",@"id",@"29843444.rmvb",@"name", nil];
    [sourceSeatRing addObject:item];
    
    
    ///初始化选择数据
    [self initOptionsData];
    [self initByDetailsData];
    
}


///初始化进入下级导航方式
-(void)initEnterWayOptionAndKeyNumLength{
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
}


///根据详情信息 设置弹框默认选项√
-(void)initByDetailsData{
    NSString *ringId = [self.detail safeObjectForKey:@"navigationRingId"];
    NSString *sitRingId = [self.detail safeObjectForKey:@"sitRingId"];
     NSString *enterNavigationWayId = [self.detail safeObjectForKey:@"navigationType"];
     NSString *keyLengthId =  [self.detail safeObjectForKey:@"childNavigationKeyLength"];
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
    
    ///默认座席提示音
    if (sourceSeatRing) {
        count = [sourceSeatRing count];
    }
    isFound = FALSE;
    
    for (int i=0; !isFound && i<count; i++) {
        model = [sourceSeatRing objectAtIndex:i];
        if ([model.itmeId isEqualToString:sitRingId]) {
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
    
    [self.tableview reloadData];
}


#pragma mark - 根据操作类型 新增/编辑 初始化数据源
-(void)initDataWithActionType{
    
    NSString *navigationName = [self.detail safeObjectForKey:@"navigationName"];
    NSString *navigationKey = [self.detail safeObjectForKey:@"navigationKey"];
    NSString *ringName = [self.detail safeObjectForKey:@"navigationRingName"];
    NSString *ringId = [self.detail safeObjectForKey:@"navigationRingId"];
    NSString *sitRingName = [self.detail safeObjectForKey:@"sitRingName"];
    NSString *sitRingId = [self.detail safeObjectForKey:@"sitRingId"];
    NSString *navigationsetChild = [self.detail safeObjectForKey:@"navigationsetChild"];
    NSLog(@"navigationsetChild:%@",navigationsetChild);
    ///从详情里获取
    NSLog(@"ringId:%@",[self.detail objectForKey:@"navigationRingId"]);
 
    
    if ([self.detail objectForKey:@"navigationRingId"] == nil) {
        NSLog(@"----nil--->");
    }else if ([self.detail objectForKey:@"navigationRingId"] == NULL) {
        NSLog(@"----NULL--->");
    }else if ([self.detail objectForKey:@"navigationRingId"] == [NSNull null]) {
        NSLog(@"----[NSNull null]--->");
    }else if ([self.detail objectForKey:@"navigationRingId"] == Nil) {
        NSLog(@"----Nil--->");
    }else if ([self.detail objectForKey:@"navigationRingId"] == [NSNull class]) {
        NSLog(@"----[NSNull class]--->");
    }else if (![self.detail objectForKey:@"navigationRingId"]) {
        NSLog(@"----空--->");
    }
    
//    else if ([[self.detail objectForKey:@"navigationRingId"] isEqualToString:@"null"]) {
//        NSLog(@"---is-string null-->");
//    }
    
    
    
    
    EditItemModel *model;

    model = [[EditItemModel alloc] init];
    model.title = @"导航名称:";
    model.content = navigationName;
    model.placeholder = @"1-100个中英文、数字特殊字符";
    model.cellType = @"cellA";
    ///是根导航 则不可编辑
    if ([self.isRootNavigation isEqualToString:@"yes"]) {
        model.keyStr = @"";
    }else{
        model.keyStr = @"navigationName";
    }
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    
    ///非根目录
    if ([self.isRootNavigation isEqualToString:@"no"]) {
        ///按键进入
        if (self.enterNavigationWay == EnterNavWayByKeyNum) {
            model = [[EditItemModel alloc] init];
            model.title = @"导航按键:";
            model.content = navigationKey;
            if (self.curNavigationKeyLength > 0 && self.curNavigationKeyLength < 7) {
                model.placeholder = [NSString stringWithFormat:@"请输入%ti位导航按键",self.curNavigationKeyLength];
            }else{
                model.placeholder = @"请输入导航按键";
            }
            model.cellType = @"cellA";
            model.keyStr = @"navigationKey";
            model.keyType = @"";
            [self.dataSource addObject:model];
        }
    }
    
    
    model = [[EditItemModel alloc] init];
    model.title = @"彩铃:";
    model.itemId = ringId;
    model.content = ringName;
    model.placeholder = @"(当电话转接到本层后播放音频)";
    model.cellType = @"cellB";
    model.keyStr = @"ringId";
    model.keyType = @"ringId";
    [self.dataSource addObject:model];
    
    
    ///非根目录 根目录没有座席提示音
    if ([self.isRootNavigation isEqualToString:@"no"]) {
        model = [[EditItemModel alloc] init];
        model.title = @"坐席提示音:";
        model.itemId = sitRingId;
        model.content = sitRingName;
        model.placeholder = @"(来电后接起坐席电话播放音频)";
        model.cellType = @"cellB";
        model.keyStr = @"sitRingId";
        model.keyType = @"sitRingId";
        [self.dataSource addObject:model];
    }
    
    ///非根目录
    if ([self.isRootNavigation isEqualToString:@"no"]) {
        ///分流方式
        if (self.enterNavigationWay == EnterNavWayShunt) {
            ///时间类型  全部时间1 星期时间 2  节假日3
            NSString *timeType = [self.detail safeObjectForKey:@"timeType"];
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
            if ([[self.detail safeObjectForKey:@"areaCode"] isEqualToString:@"1"]) {
                areaName = @"全部地区";
            }else{
                areaName = [self.detail safeObjectForKey:@"areaName"];
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
    }
    
    NSLog(@"self.navigationsetChild:%@",navigationsetChild);
    NSLog(@"self.childNavigationHasChild:%@",self.childNavigationHasChild);
    
    ///1是  0否 
    ///当前导航有设置下级导航
    if ([navigationsetChild isEqualToString:@"1"]) {
        
        model = [[EditItemModel alloc] init];
        model.title = @"是否有下级导航:";
        ///默认不选中
        model.content = navigationsetChild;
        model.placeholder = @"";
        model.cellType = @"cellI";
        model.keyStr = @"hasChildNavigation";
        [self.dataSource addObject:model];
        NSLog(@"------0---->");
        [self updateDataSourceByNavHasChild];
        
    }else{
        ///有开启下级导航的权限
        if ([self.childNavigationHasChild isEqualToString:@"yes"]) {
            model = [[EditItemModel alloc] init];
            model.title = @"是否有下级导航:";
            ///默认不选中
            model.content = navigationsetChild;
            model.placeholder = @"";
            model.cellType = @"cellI";
            model.keyStr = @"hasChildNavigation";
            [self.dataSource addObject:model];
            NSLog(@"------01---->");
            [self updateDataSourceByNavHasChild];
        }else{
            [self updateChildNavigationByAction:@"delete"];
        }
    }
    
    /*
    ///当前导航是否有开再下一级导航的权限 yes no
    if([self.childNavigationHasChild isEqualToString:@"yes"]){
        model = [[EditItemModel alloc] init];
        model.title = @"是否有下级导航:";
        ///默认不选中
        model.content = navigationsetChild;
        model.placeholder = @"";
        model.cellType = @"cellI";
        model.keyStr = @"hasChildNavigation";
        [self.dataSource addObject:model];
        NSLog(@"------0---->");
        [self updateDataSourceByNavHasChild];
    }else{
        [self updateChildNavigationByAction:@"delete"];
    }
    */
    
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
    [self.dataSourceAll removeAllObjects];
    
    NSMutableDictionary *dicDataSource = [[NSMutableDictionary alloc] init];
    NSMutableArray *arraySection = [[NSMutableArray alloc] init];
    
    [dicDataSource setObject:@"导航信息" forKey:@"head"];
    [dicDataSource setObject:self.dataSource forKey:@"content"];
    
    [self.dataSourceAll addObject:dicDataSource];
    
    /*
    NSDictionary *section0 = [self.dataSourceAll objectAtIndex:0];
    NSMutableDictionary *mutableSection0 = [NSMutableDictionary dictionaryWithDictionary:section0];
    [mutableSection0 setObject:self.dataSource forKey:@"content"];
    [self.dataSource replaceObjectAtIndex:0 withObject:mutableSection0];
    */
    
    ///添加下级导航列表
    if ([action isEqualToString:@"add"]) {
        
        dicDataSource = [[NSMutableDictionary alloc] init];
        arraySection = [[NSMutableArray alloc] init];
        
        NSInteger count = 0;
        if(self.sourChildNavigation){
            count = [self.sourChildNavigation count];
        }
        
        NSDictionary *item;
        EditItemModel *model;
        for (int i=0; i<count; i++) {
            item = [self.sourChildNavigation objectAtIndex:i];
            model = [[EditItemModel alloc] init];
            model.title = [item safeObjectForKey:@"childNavigationName"];
            model.content = [item safeObjectForKey:@"childNavigationKeyPress"];
            model.placeholder = @"请输入进入导航按键";
            model.cellType = @"cellA";
            model.keyStr = @"nextNavigationKey";
            model.keyType = [item safeObjectForKey:@"childNavigationId"];
            
            [arraySection addObject:model];
        }
        
        
        [dicDataSource setObject:@"下级导航列表" forKey:@"head"];
        [dicDataSource setObject:arraySection forKey:@"content"];
        
        [self.dataSourceAll addObject:dicDataSource];
        
    }else if ([action isEqualToString:@"delete"]) {
        ///删除下级导航列表
        if (self.dataSourceAll && [self.dataSourceAll count] == 2) {
            [self.dataSourceAll removeObjectAtIndex:1];
        }
    }
    
    
    NSLog(@"self.dataSourceAll:%@",self.dataSourceAll);
    
}



///根据是否有下级导航更新数据源
-(void)updateDataSourceByNavHasChild{
    ///导航名称
    ///导航按键
    ///彩铃
    ///座席提示音
    ///时间类型
    ///地区类型
    ///是否有下级导航
    ///按键进入
    ///1

    NSString *enterNavigationWayId = [self.detail safeObjectForKey:@"navigationType"];
    NSString *enterNavigationWay = [self getEnterNavWayNameById:enterNavigationWayId];

    NSLog(@"enterNavigationWayId:%@",enterNavigationWayId);
    NSLog(@"enterNavigationWay:%@",enterNavigationWay);
    
    EditItemModel *itemChildNav ;
    
    ///非根目录
    if ([self.isRootNavigation isEqualToString:@"no"]) {
        ///按键进入
        if (self.enterNavigationWay == EnterNavWayByKeyNum) {
            itemChildNav = (EditItemModel *)[self.dataSource objectAtIndex:4];
        }else{
            itemChildNav = (EditItemModel *)[self.dataSource objectAtIndex:5];
        }
    }else{
        ///根目录
        itemChildNav = (EditItemModel *)[self.dataSource objectAtIndex:2];
    }
    
    
    ///是否有下级导航
    ///没有
    if ([itemChildNav.content  isEqualToString:@"0"]) {
        ///非根目录
        if ([self.isRootNavigation isEqualToString:@"no"]) {
            ///按键进入
            if (self.enterNavigationWay == EnterNavWayByKeyNum) {
                ///删除掉尾部两数据
                if ([self.dataSource count] == 7) {
                    [self.dataSource removeLastObject];
                }
                if ([self.dataSource count] == 6 ) {
                    [self.dataSource removeLastObject];
                }
            }else{
                ///删除掉尾部两数据
                if ([self.dataSource count] == 8) {
                    [self.dataSource removeLastObject];
                }
                if ([self.dataSource count] == 7 ) {
                    [self.dataSource removeLastObject];
                }
            }
        }else{
            ///删除掉尾部两数据
            if ([self.dataSource count] == 5) {
                [self.dataSource removeLastObject];
            }
            if ([self.dataSource count] == 4 ) {
                [self.dataSource removeLastObject];
            }
        }
        NSLog(@"------1---->");
        [self updateChildNavigationByAction:@"delete"];
    }else{
        
        EditItemModel *model;
        
        model = [[EditItemModel alloc] init];
        model.title = @"进入下级导航方式:";
        model.itemId = enterNavigationWayId;
        model.content = enterNavigationWay;
        model.placeholder = @"";
        model.cellType = @"cellB";
        model.keyStr = @"enterNavigationWay";
        model.keyType = @"enterNavigationWay";
        [self.dataSource addObject:model];
        
        NSLog(@"------01---->");
        [self updateDataSourceByEnterWay];
    }
    ///清除痕迹
    [self initOptionsDataOfChildWay];
    [self initOptionsDataOfKeyNumLength];
    [self.tableview reloadData];
}

///根据进入方式更新数据源
-(void)updateDataSourceByEnterWay{
    NSString *keyLengthId =  [self.detail safeObjectForKey:@"childNavigationKeyLength"];
    NSString *keyLength =[self getNavKeyNumLengthNameById:keyLengthId];
    
    
    EditItemModel *itemChildNav ;
    ///非根目录
    if ([self.isRootNavigation isEqualToString:@"no"]) {
        ///按键进入
        if (self.enterNavigationWay == EnterNavWayByKeyNum) {
            itemChildNav = (EditItemModel *)[self.dataSource objectAtIndex:5];
        }else{
            itemChildNav = (EditItemModel *)[self.dataSource objectAtIndex:6];
        }
    }else{
        NSLog(@"updateDataSourceByEnterWay isRootNavigation yes");
        itemChildNav = (EditItemModel *)[self.dataSource objectAtIndex:3];
    }
    
    ///非根目录
    if ([self.isRootNavigation isEqualToString:@"no"]) {
        //下级按键方式进入
        if ([itemChildNav.itemId  isEqualToString:@"0"]) {
            
            BOOL isAddRow = FALSE;
            ///按键进入
            if (self.enterNavigationWay == EnterNavWayByKeyNum) {
                if ([self.dataSource count] == 7) {
                    if (self.dataSourceAll ) {
                        if ([self.dataSourceAll count] > 1) {
                            return;
                        }
                    }
                }else{
                    isAddRow = TRUE;
                }
            }else{
                if ([self.dataSource count] == 8) {
                    if (self.dataSourceAll ) {
                        if ([self.dataSourceAll count] > 1) {
                            return;
                        }
                    }
                }else{
                    isAddRow = TRUE;
                }
            }
            if (isAddRow) {
                EditItemModel *model;
                model = [[EditItemModel alloc] init];
                model.title = @"下级导航按键长度:";
                NSLog(@"2keyLengthId:%@",keyLengthId);
                model.itemId = keyLengthId;
                model.content = keyLength;
                model.placeholder = @"";
                model.cellType = @"cellB";
                model.keyStr = @"keyLength";
                model.keyType = @"keyLength";
                [self.dataSource addObject:model];
                
            }
            [self updateChildNavigationByAction:@"add"];
            
        }else{

            BOOL isDeleteRow = FALSE;
            ///分流进入
            if (self.enterNavigationWay == EnterNavWayByKeyNum) {
                if ([self.dataSource count] == 7) {
                    isDeleteRow = TRUE;
                }else{
                    
                }
            }else{
                if ([self.dataSource count] == 8) {
                    isDeleteRow = TRUE;
                }else{
                    
                }
            }
            ///删除掉尾部数据
            if (isDeleteRow) {
                [self.dataSource removeLastObject];
            }
            [self updateChildNavigationByAction:@"delete"];
        }
    }else{
        if ([itemChildNav.itemId  isEqualToString:@"0"]) {
            BOOL isAddRow = FALSE;
            if ([self.dataSource count] == 5) {
                NSLog(@"count 5");
                if (self.dataSourceAll) {
                    if ([self.dataSourceAll count] > 1) {
                        NSLog(@"dataall return");
                        return;
                    }
                }
            }else{
                isAddRow = TRUE;
            }
            if (isAddRow) {
                EditItemModel *model;
                model = [[EditItemModel alloc] init];
                model.title = @"下级导航按键长度:";
                model.itemId = keyLengthId;
                model.content = keyLength;
                model.placeholder = @"";
                model.cellType = @"cellB";
                model.keyStr = @"keyLength";
                model.keyType = @"keyLength";
                [self.dataSource addObject:model];
            }
            NSLog(@"updateChildNavigationByAction add");
            [self updateChildNavigationByAction:@"add"];
        }else{
            BOOL isDeleteRow = FALSE;
            if ([self.dataSource count] == 4) {
                
            }else{
                isDeleteRow = TRUE;
            }
            ///删除掉尾部数据
            if (isDeleteRow) {
                [self.dataSource removeLastObject];
            }
            [self updateChildNavigationByAction:@"delete"];
        }
        
    }
    ///清除痕迹
    [self initOptionsDataOfKeyNumLength];
    
    
}

#pragma mark - 初始化选择条件数据
-(void)initOptionsData{
    ///进入方式与按键长度
    [self initEnterWayOptionAndKeyNumLength];
    
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
    
    ///座席铃声
    NSMutableArray *array2 = [[NSMutableArray alloc] init];
    if (sourceSeatRing) {
        count = [sourceSeatRing count];
    }
    if (count > 0) {
        ///默认座席铃声
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = @"";
        model.title = @"(请选择)";
        model.selectedFlag = @"no";
        [array2 addObject:model];
    }
    for (int i=0; i<count; i++) {
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = [[sourceSeatRing objectAtIndex:i] safeObjectForKey:@"id"];
        model.title = [[sourceSeatRing objectAtIndex:i] safeObjectForKey:@"name"];
        model.selectedFlag = @"no";
        [array2 addObject:model];
    }
    
    
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
    
    
    [sourceEnterNavigationWay removeAllObjects];
    [soureRing removeAllObjects];
    [sourceSeatRing removeAllObjects];
    [sourceChildNavKeyNumLength removeAllObjects];
    
    [sourceEnterNavigationWay addObjectsFromArray:array0];
    [soureRing addObjectsFromArray:array1];
    [sourceSeatRing addObjectsFromArray:array2];
    [sourceChildNavKeyNumLength addObjectsFromArray:array3];
    
    
    NSLog(@"soureRing:%@",soureRing);
    NSLog(@"sourceSeatRing:%@",sourceSeatRing);
    
}

///初始化进入下级导航方式
-(void)initOptionsDataOfChildWay{
     NSString *enterNavigationWayId = [self.detail safeObjectForKey:@"navigationType"];
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

///初始化按键长度
-(void)initOptionsDataOfKeyNumLength{
    NSString *keyLengthId =  [self.detail safeObjectForKey:@"childNavigationKeyLength"];;
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
            NSLog(@"name---->:%@",name);
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


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 40;
    }
    return 20;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section == 1 && self.sourChildNavigation && [self.sourChildNavigation count]>0) {
        UIView *headview =[[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 40)];
        headview.backgroundColor = COLOR_BG;
        
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 80, 20)];
        labelTitle.textColor = [UIColor blackColor];
        labelTitle.font = [UIFont systemFontOfSize:15.0];
        labelTitle.text = @"下级导航";
        [headview addSubview:labelTitle];

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
    return 10;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditItemModel* item = (EditItemModel*) [[[self.dataSourceAll objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];
    
    
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
            ///1彩铃 2座席提示音 3进入方式 4按键长度
            ///导航名称
            ///导航按键
            ///彩铃
            ///座席提示音
            ///时间类型
            ///地区类型
            ///是否有下级导航
            ///按键进入
            ///1
            if (indexPath.section == 0) {
                NSInteger falg = 1;
                ///是根目录
                if ([self.isRootNavigation isEqualToString:@"yes"]) {
                    if (indexPath.row == 1) {
                        falg = 1;
                    }else if (indexPath.row == 3) {
                        falg = 3;
                    }else if (indexPath.row == 4) {
                        falg = 4;
                    }
                }else{
                    ///按键进入
                    if (self.enterNavigationWay == EnterNavWayByKeyNum) {
                        
                        if (indexPath.row == 2) {
                            falg = 1;
                        }else if (indexPath.row == 3) {
                            falg = 2;
                        }else if (indexPath.row == 5) {
                            falg = 3;
                        }else if (indexPath.row == 6) {
                            falg = 4;
                        }
                    }else{
                        if (indexPath.row == 1) {
                            falg = 1;
                        }else if (indexPath.row == 2) {
                            falg = 2;
                        }else if (indexPath.row == 6) {
                            falg = 3;
                        }else if (indexPath.row == 7) {
                            falg = 4;
                        }else if (indexPath.row == 3) {
                            ///时间
                            falg = 5;
                        }else if (indexPath.row == 4) {
                            ///地区
                            falg = 6;
                        }
                    }
                }
                [weak_self showMenuByFlag:falg withIndexPath:indexPath];
            }
            
        };
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
            
            if (weak_self.sourChildNavigation && [weak_self.sourChildNavigation count] > 0) {
                [CommonFuntion showToast:@"该导航存在子导航,请先删除子导航" inView:self.view];
                [weak_self notifyDataSource:indexPath valueString:@"1" idString:@""];
                [weak_self.tableview reloadData];
                return ;
            }else{
                [weak_self notifyDataSource:indexPath valueString:valueString idString:@""];
                ///刷新数据源
                [weak_self updateDataSourceByNavHasChild];
            }
            
        };
        
        [cell setCellDetail:item];
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


#pragma mark - 弹框
///根据flag 弹框  1 彩铃 2座席提示音 3进入方式4 按键长度
-(void)showMenuByFlag:(NSInteger)flag withIndexPath:(NSIndexPath *)indexPath{
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    ///分流进入时
    if (self.enterNavigationWay == EnterNavWayShunt) {
        NSLog(@"-----分流进入时---flag:%ti",flag);
        if (flag == 5) {
            [self navigationTimeType:indexPath];
            return;
        }else if (flag == 6){
            [self navigationAreaType:indexPath];
            return;
        }
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
    }else if (flag == 2){
        title = @"坐席提示音";
        type = 0;
        array = sourceSeatRing;
    }else if (flag == 3){
        title = @"进入下级导航方式";
        type = 0;
        array = sourceEnterNavigationWay;
    }else if (flag == 4){
        title = @"下级导航按键长度";
        type = 0;
        array = sourceChildNavKeyNumLength;
    }
    
    if (array == nil || [array count] == 0) {
        NSLog(@"选择数据源为空");
        NSString *strMsg = @"";
        if (flag == 1) {
            strMsg = @"彩铃加载失败";
        }else if (flag == 2){
            strMsg = @"坐席提示音加载失败";
        }else if (flag == 3){
            strMsg = @"导航方式加载失败";
        }else if (flag == 4){
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
    
    NSLog(@"index:%ti",index);
    ///彩铃
    if (flag == 1){
        [self changeSelectedFlag:soureRing index:index];
        
        ///@"请选择状态";
        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[soureRing objectAtIndex:index];
        NSLog(@"title:%@   ids:%@",model.title,model.itmeId);
        NSInteger ringIndex = 2;
        ///根目录
        if ([self.isRootNavigation isEqualToString:@"yes"]) {
            ringIndex = 1;
        }else{
            ///按键进入
            if (self.enterNavigationWay == EnterNavWayByKeyNum) {
                ringIndex = 2;
            }else{
                ringIndex = 1;;
            }
        }

        [self notifyDataSource:[NSIndexPath indexPathForRow:ringIndex inSection:0] valueString:model.title idString:model.itmeId];
    }else if (flag == 2){
        ///座席
        [self changeSelectedFlag:sourceSeatRing index:index];
        
        ///@"请选择阶段";
        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[sourceSeatRing objectAtIndex:index];
        NSLog(@"title:%@   ids:%@",model.title,model.itmeId);
        NSInteger ringIndex = 3;
        ///根目录
        if ([self.isRootNavigation isEqualToString:@"yes"]) {
            ringIndex = 1;
        }else{
            ///按键进入
            if (self.enterNavigationWay == EnterNavWayByKeyNum) {
                ringIndex = 3;
            }else{
                ringIndex = 2;;
            }
            [self notifyDataSource:[NSIndexPath indexPathForRow:ringIndex inSection:0] valueString:model.title idString:model.itmeId];
        }
        
    }else if (flag == 3){
        ///进入方式
        [self changeSelectedFlag:sourceEnterNavigationWay index:index];
        
        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[sourceEnterNavigationWay objectAtIndex:index];
        NSLog(@"title:%@   ids:%@",model.title,model.itmeId);
        NSInteger ringIndex = 5;
        ///根目录
        if ([self.isRootNavigation isEqualToString:@"yes"]) {
            ringIndex = 3;
        }else{
            ///按键进入
            if (self.enterNavigationWay == EnterNavWayByKeyNum) {
                ringIndex = 5;
            }else{
                ringIndex = 6;;
            }
        }
        
        [self notifyDataSource:[NSIndexPath indexPathForRow:ringIndex inSection:0] valueString:model.title idString:model.itmeId];
        
        [self updateDataSourceByEnterWay];
        
    }else if (flag == 4){
        ///按键长度
        [self changeSelectedFlag:sourceChildNavKeyNumLength index:index];
        
        ///@"请选择类型";
        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[sourceChildNavKeyNumLength objectAtIndex:index];
        NSLog(@"title:%@   ids:%@",model.title,model.itmeId);
        NSInteger ringIndex = 6;
        ///根目录
        if ([self.isRootNavigation isEqualToString:@"yes"]) {
            ringIndex = 4;
        }else{
            ///按键进入
            if (self.enterNavigationWay == EnterNavWayByKeyNum) {
                ringIndex = 6;
            }else{
                ringIndex = 7;;
            }
        }
        [self notifyDataSource:[NSIndexPath indexPathForRow:ringIndex inSection:0] valueString:model.title idString:model.itmeId];
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
    controller.flagOfNeedJudge = @"yes";
    __weak typeof(self) weak_self = self;
    controller.TimeTypeBlock = ^(NSString *timeType){
        ///返回时间类型 和具体的时间值
        ///类型在UI上展示出来
        
        ///重新请求详情信息
        [self getNavigationDetails];
        [weak_self notifyDataSource:[NSIndexPath indexPathForRow:3 inSection:0] valueString:timeType idString:@""];
        [weak_self.tableview reloadData];
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
    controller.flagOfNeedJudge = @"yes";
    
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
                
                ///座席提示音
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"] != [NSNull null]) {
                    NSArray *sitRingList = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"];
                    NSLog(@"sitRingList:%@",sitRingList);
                    if (sitRingList) {
                        [sourceSeatRing addObjectsFromArray:sitRingList];
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
    EditItemModel *item;
    /*
    for (int i=0; i<[self.dataSourceAll count]; i++) {
        
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
    */
    
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

    NSLog(@"----非编辑座席----");
    ///是根导航 则name不可编辑
    if ([self.isRootNavigation isEqualToString:@"yes"]) {
        ///
        [rDict setValue:[self.detail safeObjectForKey:@"navigationName"] forKey:@"navigationName"];
    }
    [rDict setValue:[self.detail safeObjectForKey:@"navigationId"] forKey:@"navigationId"];
    
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
    if (![rDict objectForKey:@"sitRingId"]) {
        [rDict setValue:@"" forKey:@"sitRingId"];
    }
    if (![rDict objectForKey:@"hasChildNavigation"]) {
        [rDict setValue:@"0" forKey:@"hasChildNavigation"];
    }
    if (![rDict objectForKey:@"answerStrategy"]) {
        [rDict setValue:@"" forKey:@"answerStrategy"];
    }
    
    
    //[rDict setValue:self.customerId forKey:@"customerId"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_EDIT_NAVIGATION_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"编辑导航jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [CommonFuntion showToast:@"保存成功" inView:self.view];
            
            ///详情中
            NSInteger setChild = 0;
            NSString *navigationsetChild = [self.detail safeObjectForKey:@"navigationsetChild"];
            if (![navigationsetChild isEqualToString:@""]) {
                setChild = [navigationsetChild integerValue];
            }
            NSInteger hasChildNavigation = [[rDict objectForKey:@"hasChildNavigation"] integerValue];
            
            ///需要连续返回两个页面
            if (setChild != hasChildNavigation) {
                isGotoSuperView = YES;
            }else{
                isGotoSuperView = NO;
            }
            
            
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
        self.NotifyNavigationList(isGotoSuperView);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
