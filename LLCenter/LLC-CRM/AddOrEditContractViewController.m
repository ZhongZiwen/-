//
//  AddOrEditContractViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AddOrEditContractViewController.h"
#import "LLCenterUtility.h"
#import "EditItemModel.h"
#import "LLcenterSheetMenuView.h"
#import "LLCenterSheetMenuModel.h"
#import "TPKeyboardAvoidingTableView.h"
#import "CommonFunc.h"
#import "EditItemTypeCellA.h"
#import "EditItemTypeCellB.h"
#import "EditItemTypeCellRemarkEdit.h"
#import "EditItemTypeCellF.h"
#import "CommonNoDataView.h"
#import "LLCenterPickerView.h"

@interface AddOrEditContractViewController ()<UITableViewDataSource,UITableViewDelegate,LLCenterSheetMenuDelegate>{
    
    ///付款方式
    NSMutableArray *soureType;
    ///状态
    NSMutableArray *sourceStatus;
    
    ///结束时间的最小时间
    NSDate *minDate;
}

@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property(strong,nonatomic) TPKeyboardAvoidingTableView *tableview;
@property(strong,nonatomic) NSMutableArray *dataSource;

@end



@implementation AddOrEditContractViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = COLOR_BG;
    [self addNavBar];
    [self initTableview];
    [self initData];
    [self initDataWithActionType];
    ///测试数据
//    [self readTestSaleDictionaryData];
    [self getContractDictionary];
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
    
    
    EditItemModel *itemTitle = (EditItemModel *)[self.dataSource objectAtIndex:0];
    
    if ([[itemTitle.content stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        [CommonFuntion showToast:@"合同名称不能为空" inView:self.view];
        return;
    }
    
    
    if ([CommonFunc isStringNullObject:itemTitle.content]) {
        [CommonFuntion showToast:@"合同名称不能为null" inView:self.view];
        return;
    }
    
    EditItemModel *itemAmt = (EditItemModel *)[self.dataSource objectAtIndex:1];
    if ([itemAmt.content isEqualToString:@""]) {
        [CommonFuntion showToast:@"总金额不能为空" inView:self.view];
        return;
    }
    
    if ([[itemAmt.content stringByReplacingOccurrencesOfString:@"." withString:@""] isEqualToString:@""]) {
        [CommonFuntion showToast:@"请输入正确格式的金额" inView:self.view];
        return;
    }
    
    if ([CommonFunc isPureInt:itemAmt.content]|| [CommonFunc isPureLong:itemAmt.content] || [CommonFunc isPureDecimal:itemAmt.content]){
        NSLog(@"----:%@",itemAmt.content);
    }else{
        [CommonFuntion showToast:@"请输入正确格式的金额" inView:self.view];
        return;
    }
    
    if (itemAmt.content.length > 12 ) {
        [CommonFuntion showToast:@"总金额不能超过12位" inView:self.view];
        return;
    }
    
    
    EditItemModel *itemStage = (EditItemModel *)[self.dataSource objectAtIndex:2];
    if ([itemStage.content isEqualToString:@""]) {
        [CommonFuntion showToast:@"付款方式不能为空" inView:self.view];
        return;
    }
    
    ///开始时间 结束时间
    EditItemModel *itemBegin = (EditItemModel *)[self.dataSource objectAtIndex:3];
    EditItemModel *itemEnd = (EditItemModel *)[self.dataSource objectAtIndex:4];
    
    if (![itemBegin.content isEqualToString:@""] && ![itemEnd.content isEqualToString:@""]) {
        ///开始时间大于结束时间
        if ([itemBegin.content compare:itemEnd.content] == NSOrderedDescending) {
            [CommonFuntion showToast:@"开始时间应小于结束时间" inView:self.view];
            return;
        }
    }
    
    
    EditItemModel *itemStatus = (EditItemModel *)[self.dataSource objectAtIndex:5];
    if ([itemStatus.content isEqualToString:@""]) {
        [CommonFuntion showToast:@"状态不能为空" inView:self.view];
        return;
    }
    
    EditItemModel *itemRemark = (EditItemModel *)[self.dataSource objectAtIndex:6];
    if (itemRemark.content.length > 150) {
        [CommonFuntion showToast:@"备注最大长度为150" inView:self.view];
        return;
    }
    
    if ([CommonFunc isStringNullObject:itemRemark.content]) {
        [CommonFuntion showToast:@"备注不能为null" inView:self.view];
        return;
    }
    
    ///发送请求
    [self addOrEditContract];
}

#pragma mark - 初始化数据
-(void)initData{
    soureType = [[NSMutableArray alloc] init];
    sourceStatus = [[NSMutableArray alloc] init];
    self.dataSource = [[NSMutableArray alloc] init];
}


#pragma mark - 测试数据
-(void)readTestData{
    /*
     contractId(合同ID)
     contractName(合同名称)
     contractAmount(合同总金额)
     paymentMethod(付款方式)
     contractStatus(状态)
     contractRemark(合同备注)
     contractStartTime(合同开始时间)
     contractEndTime(合同结束时间)
     contractCreateDate(合同创建时间)
     contractUpdateDate(合同更新时间)
     */
    
    [self initDataWithActionType];
}


///根据详情信息 设置弹框默认选项
-(void)initByDtailsData{
    NSString * statusId = [self.detail safeObjectForKey:@"contractStatusId"];
    NSString * typeId = [self.detail safeObjectForKey:@"paymentMethodId"];
    
    ///默认类型
    NSInteger count = 0;
    if (soureType) {
        count = [soureType count];
    }
    BOOL isFound = FALSE;
    LLCenterSheetMenuModel *model;
    for (int i=0; !isFound && i<count; i++) {
        model = [soureType objectAtIndex:i];
        if ([model.itmeId isEqualToString:typeId]) {
            model.selectedFlag = @"yes";
            isFound = TRUE;
        }
    }
    
    ///默认状态
    if (sourceStatus) {
        count = [sourceStatus count];
    }
    isFound = FALSE;
    
    for (int i=0; !isFound && i<count; i++) {
        model = [sourceStatus objectAtIndex:i];
        if ([model.itmeId isEqualToString:statusId]) {
            model.selectedFlag = @"yes";
            isFound = TRUE;
        }
    }
    
    
    ///默认付款方式
    if (soureType && [soureType count]>0) {
        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[soureType objectAtIndex:0];
        model.selectedFlag = @"yes";
        [self notifyDataSource:[NSIndexPath indexPathForRow:2 inSection:0] valueString:model.title idString:model.itmeId];
    }
    [self.tableview reloadData];
}

#pragma mark - 根据操作类型 新增/编辑 初始化数据源
-(void)initDataWithActionType{
    NSString *titleName = @"";
    NSString *statusName = @"";
    NSString *statusId = @"";
    NSString *typeName = @"";
    NSString *typeId = @"";
    
    NSString *amt = @"";
    NSString *startTime = @"";
    NSString *endTime = @"";
    
    NSString *remark = @"";
    ///新增
    if ([self.actionType  isEqualToString:@"add"]) {
        
    }else if ([self.actionType  isEqualToString:@"edit"]) {
        ///编辑
        titleName = [self.detail safeObjectForKey:@"contractName"];
        statusName = [self.detail safeObjectForKey:@"contractStatusName"];
        typeName = [self.detail safeObjectForKey:@"paymentMethodName"];
        
        statusId = [self.detail safeObjectForKey:@"contractStatusId"];
        typeId = [self.detail safeObjectForKey:@"paymentMethodId"];
        
        
        amt = [self.detail safeObjectForKey:@"contractAmount"];
        startTime = [self.detail safeObjectForKey:@"contractStartTime"];
        endTime = [self.detail safeObjectForKey:@"contractEndTime"];
        
        remark = [self.detail safeObjectForKey:@"contractRemark"];
    }
    
    
    EditItemModel *model;
    
    model = [[EditItemModel alloc] init];
    model.title = @"合同名称:";
    model.content = titleName;
    model.placeholder = @"请输入合同名称";
    model.cellType = @"cellA";
    model.keyStr = @"contractName";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    
    
    model = [[EditItemModel alloc] init];
    model.title = @"总金额:";
    model.content = amt;
    model.placeholder = @"请输入合同总金额";
    model.cellType = @"cellA";
    model.keyStr = @"contractAmount";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    
    model = [[EditItemModel alloc] init];
    model.title = @"付款方式:";
    model.itemId = typeId;
    model.content = typeName;
    model.placeholder = @"";
    model.cellType = @"cellB";
    model.keyStr = @"paymentMethod";
    model.keyType = @"paymentMethod";
    [self.dataSource addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"开始时间:";
    model.itemId = @"";
    model.content = startTime;
    model.placeholder = @"";
    model.cellType = @"cellF";
    model.keyStr = @"contractStartTime";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"结束时间:";
    model.itemId = @"";
    model.content = endTime;
    model.placeholder = @"";
    model.cellType = @"cellF";
    model.keyStr = @"contractEndTime";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    
    model = [[EditItemModel alloc] init];
    model.title = @"状态:";
    model.itemId = statusId;
    model.content = statusName;
    model.placeholder = @"";
    model.cellType = @"cellB";
    model.keyStr = @"contractStatus";
    model.keyType = @"contractStatus";
    [self.dataSource addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"沟通备注:";
    model.content = remark;
    model.placeholder = @"请输入备注(150字以内)";
    model.cellType = @"cellRemarkEdit";
    model.keyStr = @"contractRemark";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    
    NSLog(@"self.dataSource:%@",self.dataSource);
    for (int i=0; i<[self.dataSource count]; i++) {
        EditItemModel *item  = (EditItemModel*) [self.dataSource objectAtIndex:i];
        NSLog(@"%@  %@",item.title,item.cellType);
    }
}


#pragma mark - 初始化选择条件数据
-(void)initOptionsData{
    
    ///类型
    NSMutableArray *array1 = [[NSMutableArray alloc] init];
    NSInteger count = 0;
    if (soureType) {
        count = [soureType count];
    }
    for (int i=0; i<count; i++) {
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = [[soureType objectAtIndex:i] safeObjectForKey:@"id"];
        model.title = [[soureType objectAtIndex:i] safeObjectForKey:@"name"];
        model.selectedFlag = @"no";
        [array1 addObject:model];
    }
    
    
    ///状态
    NSMutableArray *array3 = [[NSMutableArray alloc] init];
    if (sourceStatus) {
        count = [sourceStatus count];
    }
    for (int i=0; i<count; i++) {
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = [[sourceStatus objectAtIndex:i] safeObjectForKey:@"id"];
        model.title = [[sourceStatus objectAtIndex:i] safeObjectForKey:@"name"];
        model.selectedFlag = @"no";
        [array3 addObject:model];
    }
    
    
    [soureType removeAllObjects];
    [sourceStatus removeAllObjects];
    
    [soureType addObjectsFromArray:array1];
    [sourceStatus addObjectsFromArray:array3];
    
    
    NSLog(@"soureType:%@",soureType);
    NSLog(@"sourceStatus:%@",sourceStatus);
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
    if ([item.cellType isEqualToString:@"cellRemarkEdit"]) {
        return 65.0;
    }
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
            ///1状态  2类型
            NSInteger falg = 1;
            if (indexPath.row == 5) {
                falg = 1;
            }else if (indexPath.row == 2) {
                falg = 2;
            }
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
            ///开始时间
            if (indexPath.row == 3) {
                falg = 0;
            }else{
                falg = 1;
            }
            
            [weak_self showDataPickerByFlag:falg];
            
        };
        [cell setCellDetail:item];
        return cell;
    }else if ([item.cellType isEqualToString:@"cellRemarkEdit"]) {
        EditItemTypeCellRemarkEdit *cell = [tableView dequeueReusableCellWithIdentifier:@"EditItemTypeCellRemarkEditIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"EditItemTypeCellRemarkEdit" owner:self options:nil];
            cell = (EditItemTypeCellRemarkEdit*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        
        __weak typeof(self) weak_self = self;
        cell.textValueChangedBlock = ^(NSString *valueString){
            NSLog(@"index:%ti valueString:%@",indexPath.row,valueString);
            [weak_self notifyDataSource:indexPath valueString:valueString idString:@""];
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
///根据flag 弹框 1状态 2 类型
-(void)showMenuByFlag:(NSInteger)flag withIndexPath:(NSIndexPath *)indexPath{
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    NSArray *array = nil;
    NSString *title = @"";
    /// 0单选  1多选
    NSInteger type = 0;
    LLcenterSheetMenuView *sheet;
    
    if (flag == 1){
        title = @"状态";
        type = 0;
        array = sourceStatus;
    }else if (flag == 2){
        title = @"付款方式";
        type = 0;
        array = soureType;
    }
    
    if (array == nil || [array count] == 0) {
        NSLog(@"选择数据源为空");
        NSString *strMsg = @"";
        if (flag == 1) {
            strMsg = @"状态加载失败";
        }else if (flag == 2){
            strMsg = @"付款方式加载失败";
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
        [self changeSelectedFlag:sourceStatus index:index];
        
        ///@"请选择状态";
        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[sourceStatus objectAtIndex:index];
        NSLog(@"title:%@   ids:%@",model.title,model.itmeId);
        
        [self notifyDataSource:[NSIndexPath indexPathForRow:5 inSection:0] valueString:model.title idString:model.itmeId];
    }else if (flag == 2){
        [self changeSelectedFlag:soureType index:index];
        
        ///@"请选择付款方式";
        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[soureType objectAtIndex:index];
        NSLog(@"title:%@   ids:%@",model.title,model.itmeId);
        
        [self notifyDataSource:[NSIndexPath indexPathForRow:2 inSection:0] valueString:model.title idString:model.itmeId];
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
     __weak typeof(self) weak_self = self;
    if (flag == 0) {
        NSDate *dateNow = [NSDate date];

        LLCenterPickerView *llsheet = [[LLCenterPickerView alloc]initWithCurDate:dateNow andMinDate:nil headTitle:@"开始时间" dateType:1];
        llsheet.selectedDateBlock = ^(NSString *time,NSDate *date){
            NSString *startTime = @"";
            NSLog(@"-----date:%@",date);
            minDate = date;
            if (date == nil) {
                minDate = dateNow;
            }
            startTime = [CommonFunc dateToString:minDate Format:@"yyyy-MM-dd"];
            NSLog(@"-----startTime:%@",startTime);
            
            EditItemModel *model = (EditItemModel *)[self.dataSource objectAtIndex:4];
            if (model.content && model.content.length > 0 && [startTime compare:model.content] == 1) {
                [CommonFuntion showToast:@"开始时间不能大于结束时间" inView:self.view];
                return;
            }else{
                [weak_self notifyDataSource:[NSIndexPath indexPathForRow:3 inSection:0] valueString:startTime idString:@""];
                [weak_self.tableview reloadData];
            }
        };
        [llsheet showInView:nil];
    }else if (flag == 1){
        //        [self showMenuByFlag:3];
        LLCenterPickerView *llsheet;
        if (minDate == nil) {
            NSDate *dateNow = [NSDate date];
            llsheet = [[LLCenterPickerView alloc]initWithCurDate:dateNow andMinDate:nil headTitle:@"结束时间" dateType:1];
        }else{
            NSLog(@"minDate:%@",minDate);
            llsheet = [[LLCenterPickerView alloc]initWithCurDate:minDate andMinDate:minDate headTitle:@"结束时间" dateType:1];
        }
        
        llsheet.selectedDateBlock = ^(NSString *time,NSDate *date){
            NSLog(@"-----time:%@",time);
            NSLog(@"-----date:%@",date);
            
           
            NSString *stopTime = @"";
            if (date == nil) {
               stopTime = [CommonFunc dateToString:[NSDate date] Format:@"yyyy-MM-dd"];
            }else{
                stopTime = [CommonFunc dateToString:date Format:@"yyyy-MM-dd"];
            }
            
            EditItemModel *model = (EditItemModel *)[self.dataSource objectAtIndex:3];
            if (model.content && model.content.length > 0 && [stopTime compare:model.content] == -1) {
                [CommonFuntion showToast:@"开始时间不能大于结束时间" inView:self.view];
                return;
            }else{
                [weak_self notifyDataSource:[NSIndexPath indexPathForRow:4 inSection:0] valueString:stopTime idString:@""];
                [weak_self.tableview reloadData];
            }
            
        };
        [llsheet showInView:nil];
    }
}

#pragma mark - 网络请求

#pragma mark 获取合同字典信息
-(void)getContractDictionary{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_INIT_CONTRACT_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"合同字典jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            if ([jsonResponse objectForKey:@"resultMap"]) {
                
                ///付款方式
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"paymentMethodList"] != [NSNull null]) {
                    NSArray *paymentMethodList = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"paymentMethodList"];
                    NSLog(@"paymentMethodList:%@",paymentMethodList);
                    if (paymentMethodList) {
                        [soureType addObjectsFromArray:paymentMethodList];
                    }
                }
                
                
                ///状态
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"contractStatusList"] != [NSNull null]) {
                    NSArray *contractStatusList = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"contractStatusList"];
                    NSLog(@"contractStatusList:%@",contractStatusList);
                    if (contractStatusList) {
                        [sourceStatus addObjectsFromArray:contractStatusList];
                    }
                }
                
                ///初始化数据
                [self initOptionsData];
                [self initByDtailsData];
                
            }else{
                NSLog(@"data------>:<null>");
                
                [CommonFuntion showToast:@"加载异常" inView:self.view];
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getContractDictionary];
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


#pragma mark - 新建、编辑合同

-(void)addOrEditContract{
    
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
    
    ///编辑
    if ([self.actionType isEqualToString:@"edit"]) {
        [rDict setValue:[self.detail safeObjectForKey:@"contractId"] forKey:@"contractId"];
    }
    
    [rDict setValue:self.customerId forKey:@"customerId"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_SAVE_CONTRACT_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"新建/编辑合同jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            [CommonFuntion showToast:@"保存成功" inView:self.view];
            
            [self actionSuccess];
            
            /*
             for (UIViewController *vcCD in self.navigationController.viewControllers) {
             if ([vcCD isKindOfClass:[CustomerDetailViewController class]]) {
             [self.navigationController popToViewController:vcCD animated:YES];
             }
             }
             */
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self addOrEditContract];
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
    
    if ([self.actionType isEqualToString:@"add"]) {
        if (self.NotifyContractList) {
            self.NotifyContractList();
        }
    }else{
        if (self.NotifyContractDetail) {
            self.NotifyContractDetail();
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}


@end
