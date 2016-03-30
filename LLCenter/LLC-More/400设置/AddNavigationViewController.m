//
//  AddNavigationViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-21.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AddNavigationViewController.h"
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


@interface AddNavigationViewController ()<UITableViewDataSource,UITableViewDelegate,LLCenterSheetMenuDelegate>{
    
    ///彩铃
    NSMutableArray *soureRing;
    ///座席提示音
    NSMutableArray *sourceSeatRing;
    ///进入下级导航的方式
    NSMutableArray *sourceEnterNavigationWay;
    ///下级导航按键长度
    NSMutableArray *sourceChildNavKeyNumLength;
}

@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property(strong,nonatomic) TPKeyboardAvoidingTableView *tableview;
@property(strong,nonatomic) NSMutableArray *dataSource;

@end


@implementation AddNavigationViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"新增分组";
    self.view.backgroundColor = COLOR_BG;
    [self addNavBar];
    [self initTableview];
    [self initData];
    ///测试数据
//    [self readTestData];
    [self initDataWithActionType];
    
    [self getNavigationDictionary];
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
    
    
    EditItemModel *itemNavName = (EditItemModel *)[self.dataSource objectAtIndex:1];
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
        EditItemModel *itemKeyNum = (EditItemModel *)[self.dataSource objectAtIndex:2];
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
    
    ///发送请求
    [self addNavition];
}

#pragma mark - 初始化数据
-(void)initData{
    soureRing = [[NSMutableArray alloc] init];
    sourceSeatRing = [[NSMutableArray alloc] init];
    sourceEnterNavigationWay = [[NSMutableArray alloc] init];
    sourceChildNavKeyNumLength = [[NSMutableArray alloc] init];
    self.dataSource = [[NSMutableArray alloc] init];
}


#pragma mark - 测试数据
-(void)readTestData{
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


#pragma mark - 根据操作类型 新增/编辑 初始化数据源
-(void)initDataWithActionType{

    EditItemModel *model;
    
    model = [[EditItemModel alloc] init];
    model.title = @"上级分组:";
    model.content = self.navigationName;
    model.placeholder = @"";
    model.cellType = @"cellA";
    model.keyStr = @"";
    model.keyType = @"";
    [self.dataSource addObject:model];

    
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
    
    model = [[EditItemModel alloc] init];
    model.title = @"彩铃:";
    model.itemId = @"";
    model.content = @"";
    model.placeholder = @"(当电话转接到本层后播放音频)";
    model.cellType = @"cellB";
    model.keyStr = @"ringId";
    model.keyType = @"ringId";
    [self.dataSource addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"坐席提示音:";
    model.itemId = @"";
    model.content = @"";
    model.placeholder = @"(来电后接起坐席电话播放音频)";
    model.cellType = @"cellB";
    model.keyStr = @"sitRingId";
    model.keyType = @"sitRingId";
    [self.dataSource addObject:model];
    
    ///当前导航的下级导航是否有开再下一级导航的权限 yes no
    if([self.childNavigationHasChild isEqualToString:@"yes"]){
        model = [[EditItemModel alloc] init];
        model.title = @"是否有下级分组:";
        ///默认不选中
        model.content = @"0";
        model.placeholder = @"";
        model.cellType = @"cellI";
        model.keyStr = @"hasChildNavigation";
        [self.dataSource addObject:model];
        
        [self updateDataSourceByNavHasChild];
    }
    
    
    NSLog(@"self.dataSource:%@",self.dataSource);
    for (int i=0; i<[self.dataSource count]; i++) {
        EditItemModel *item  = (EditItemModel*) [self.dataSource objectAtIndex:i];
        NSLog(@"%@  %@",item.title,item.cellType);
    }
}



///根据是否有下级导航更新数据源
-(void)updateDataSourceByNavHasChild{
    
    EditItemModel *itemChildNav ;
    ///按键进入
    if (self.enterNavigationWay == EnterNavWayByKeyNum) {
        itemChildNav = (EditItemModel *)[self.dataSource objectAtIndex:5];
    }else{
        itemChildNav = (EditItemModel *)[self.dataSource objectAtIndex:4];
    }
    
    ///是否有下级导航
    ///没有
    if ([itemChildNav.content  isEqualToString:@"0"]) {
        
        ///按键进入
        if (self.enterNavigationWay == EnterNavWayByKeyNum) {
            ///删除掉尾部两数据
            if ([self.dataSource count] == 8) {
                [self.dataSource removeLastObject];
            }
            if ([self.dataSource count] == 7 ) {
                [self.dataSource removeLastObject];
            }
        }else{
            ///删除掉尾部两数据
            if ([self.dataSource count] == 7) {
                [self.dataSource removeLastObject];
            }
            if ([self.dataSource count] == 6 ) {
                [self.dataSource removeLastObject];
            }
        }
        
        
    }else{
        EditItemModel *model;
        
        model = [[EditItemModel alloc] init];
        model.title = @"进入下级分组方式:";
        model.itemId = @"0";
        model.content = @"按键方式";
        model.placeholder = @"";
        model.cellType = @"cellB";
        model.keyStr = @"enterNavigationWay";
        model.keyType = @"enterNavigationWay";
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
    
    EditItemModel *itemChildNav ;
    ///按键进入
    if (self.enterNavigationWay == EnterNavWayByKeyNum) {
        itemChildNav = (EditItemModel *)[self.dataSource objectAtIndex:6];
    }else{
        itemChildNav = (EditItemModel *)[self.dataSource objectAtIndex:5];
    }
    
    //下级按键方式进入
    if ([itemChildNav.itemId  isEqualToString:@"0"]) {
        
        BOOL isAddRow = FALSE;
        ///按键进入
        if (self.enterNavigationWay == EnterNavWayByKeyNum) {
            if ([self.dataSource count] == 8) {
                return;
            }else{
                isAddRow = TRUE;
            }
        }else{
            if ([self.dataSource count] == 7) {
                return;
            }else{
                isAddRow = TRUE;
            }
        }
        if (isAddRow) {
            EditItemModel *model;
            model = [[EditItemModel alloc] init];
            model.title = @"下级分组按键长度:";
            model.itemId = @"1";
            model.content = @"1";
            model.placeholder = @"";
            model.cellType = @"cellB";
            model.keyStr = @"keyLength";
            model.keyType = @"keyLength";
            model.itemTag = @"下级分组按键长度";
            [self.dataSource addObject:model];
        }
        
    }else{
        BOOL isDeleteRow = FALSE;
        ///分流进入
        if (self.enterNavigationWay == EnterNavWayByKeyNum) {
            if ([self.dataSource count] == 8) {
                isDeleteRow = TRUE;
            }else{
                return;
            }
        }else{
            if ([self.dataSource count] == 7) {
                isDeleteRow = TRUE;
            }else{
                return;
            }
        }
        ///删除掉尾部数据
        if (isDeleteRow) {
            [self.dataSource removeLastObject];
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
    
    ///座席铃声
    NSMutableArray *array2 = [[NSMutableArray alloc] init];
    if (sourceSeatRing) {
        count = [sourceSeatRing count];
    }
    ///默认座席
    LLCenterSheetMenuModel *model2 = [[LLCenterSheetMenuModel alloc] init];
    model2.itmeId = @"";
    model2.title = @"(请选择)";
    model2.selectedFlag = @"no";
    [array2 addObject:model2];
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
    
    ///进入方式
    NSInteger count = 0;
    if (sourceEnterNavigationWay) {
        count = [sourceEnterNavigationWay count];
    }
    LLCenterSheetMenuModel *model ;
    for (int i=0; i<count; i++) {
        model = (LLCenterSheetMenuModel*)[sourceEnterNavigationWay objectAtIndex:i];
        if (i == 0) {
            model.selectedFlag = @"yes";
        }else{
            model.selectedFlag = @"no";
        }
    }
}

///初始化按键长度
-(void)initOptionsDataOfKeyNumLength{

    NSInteger count = 0;
    LLCenterSheetMenuModel *model ;
    
    ///按键长度
    if (sourceChildNavKeyNumLength) {
        count = [sourceChildNavKeyNumLength count];
    }
    for (int i=0; i<count; i++) {
        model = (LLCenterSheetMenuModel*)[sourceChildNavKeyNumLength objectAtIndex:i];
        if (i == 0) {
            model.selectedFlag = @"yes";
        }else{
            model.selectedFlag = @"no";
        }
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
            ///1彩铃 2座席提示音 3进入方式 4按键长度
            
            NSInteger falg = 1;
            ///按键进入
            if (self.enterNavigationWay == EnterNavWayByKeyNum) {
                
                if (indexPath.row == 3) {
                    falg = 1;
                }else if (indexPath.row == 4) {
                    falg = 2;
                }else if (indexPath.row == 6) {
                    falg = 3;
                }else if (indexPath.row == 7) {
                    falg = 4;
                }
            }else{
                if (indexPath.row == 2) {
                    falg = 1;
                }else if (indexPath.row == 3) {
                    falg = 2;
                }else if (indexPath.row == 5) {
                    falg = 3;
                }else if (indexPath.row == 6) {
                    falg = 4;
                }
            }
            
            [weak_self showMenuByFlag:falg withIndexPath:indexPath];
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
            [weak_self notifyDataSource:indexPath valueString:valueString idString:@""];
            ///刷新数据源
            [weak_self updateDataSourceByNavHasChild];
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
///根据flag 弹框  1 类型 2阶段 3状态
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
        title = @"坐席提示音";
        type = 0;
        array = sourceSeatRing;
    }else if (flag == 3){
        title = @"进入下级分组方式";
        type = 0;
        array = sourceEnterNavigationWay;
    }else if (flag == 4){
        title = @"下级分组按键长度";
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
            strMsg = @"分组方式加载失败";
        }else if (flag == 3){
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
        ///按键进入
        if (self.enterNavigationWay == EnterNavWayByKeyNum) {
            ringIndex = 3;
        }else{
            ringIndex = 2;;
        }
        
        [self notifyDataSource:[NSIndexPath indexPathForRow:ringIndex inSection:0] valueString:model.title idString:model.itmeId];
    }else if (flag == 2){
        ///座席
        [self changeSelectedFlag:sourceSeatRing index:index];
        
        ///@"请选择阶段";
        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[sourceSeatRing objectAtIndex:index];
        NSLog(@"title:%@   ids:%@",model.title,model.itmeId);
        NSInteger ringIndex = 3;
        ///按键进入
        if (self.enterNavigationWay == EnterNavWayByKeyNum) {
            ringIndex = 4;
        }else{
            ringIndex = 3;;
        }
        [self notifyDataSource:[NSIndexPath indexPathForRow:ringIndex inSection:0] valueString:model.title idString:model.itmeId];
    }else if (flag == 3){
        ///进入方式
        [self changeSelectedFlag:sourceEnterNavigationWay index:index];
        
        ///@"请选择类型";
        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[sourceEnterNavigationWay objectAtIndex:index];
        NSLog(@"title:%@   ids:%@",model.title,model.itmeId);
        NSInteger ringIndex = 5;
        ///按键进入
        if (self.enterNavigationWay == EnterNavWayByKeyNum) {
            ringIndex = 6;
        }else{
            ringIndex = 5;;
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
        ///按键进入
        if (self.enterNavigationWay == EnterNavWayByKeyNum) {
            ringIndex = 7;
        }else{
            ringIndex = 6;;
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


    [rDict setValue:self.navigationId forKey:@"parentId"];
    
    /*
    navigationKey
    enterNavigationWay
    keyLength
     */
    ///补全参数
    if (![rDict objectForKey:@"navigationKey"]) {
        [rDict setValue:@"" forKey:@"navigationKey"];
    }
    if (![rDict objectForKey:@"hasChildNavigation"]) {
        [rDict setValue:@"0" forKey:@"hasChildNavigation"];
    }
    if (![rDict objectForKey:@"enterNavigationWay"]) {
        [rDict setValue:@"" forKey:@"enterNavigationWay"];
    }
    if (![rDict objectForKey:@"keyLength"]) {
        [rDict setValue:@"" forKey:@"keyLength"];
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_ADD_NAVIGATION_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"新建导航jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [CommonFuntion showToast:@"保存成功" inView:self.view];
            [self actionSuccess];
            
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

@end
