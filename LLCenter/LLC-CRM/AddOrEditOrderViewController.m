//
//  AddOrEditOrderViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AddOrEditOrderViewController.h"
#import "LLCenterUtility.h"
#import "NSDate+Utils.h"
#import "EditItemModel.h"
#import "LLcenterSheetMenuView.h"
#import "LLCenterSheetMenuModel.h"
#import "TPKeyboardAvoidingTableView.h"
#import "CommonFunc.h"
#import "EditItemTypeCellA.h"
#import "EditItemTypeCellB.h"
#import "EditItemTypeCellF.h"
#import "EditItemTypeCellRemarkEdit.h"
#import "CommonNoDataView.h"
#import "LLCenterPickerView.h"

@interface AddOrEditOrderViewController ()<UITableViewDataSource,UITableViewDelegate,LLCenterSheetMenuDelegate>{
    
    ///付款方式
    NSMutableArray *soureType;
    ///状态
    NSMutableArray *sourceStatus;
    ///收货人
    NSMutableArray *sourceConsignee;
    ///当前选择的收货人
    NSDictionary *curConsigneeItem;
}

@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property(strong,nonatomic) TPKeyboardAvoidingTableView *tableview;
@property(strong,nonatomic) NSMutableArray *dataSource;

@end

@implementation AddOrEditOrderViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = COLOR_BG;
    [self addNavBar];
    [self initTableview];
    [self initData];
    [self initDataWithActionType];
    ///测试数据
//    [self readTestSaleDictionaryData];
    [self getOrderDictionary];
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
    
    EditItemModel *itemTitle = (EditItemModel *)[[[self.dataSource objectAtIndex:0] objectForKey:@"content"] objectAtIndex:0];
    
    if ([[itemTitle.content stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        [CommonFuntion showToast:@"订单名称不能为空" inView:self.view];
        return;
    }
    
    
    if ([CommonFunc isStringNullObject:itemTitle.content]) {
        [CommonFuntion showToast:@"订单名称不能为null" inView:self.view];
        return;
    }
    
    EditItemModel *itemAmt = (EditItemModel *)[[[self.dataSource objectAtIndex:0] objectForKey:@"content"] objectAtIndex:2];
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
    
    EditItemModel *itemStage = (EditItemModel *)[[[self.dataSource objectAtIndex:0] objectForKey:@"content"] objectAtIndex:3];
    if ([itemStage.content isEqualToString:@""]) {
        [CommonFuntion showToast:@"付款方式不能为空" inView:self.view];
        return;
    }
    
    EditItemModel *itemStatus = (EditItemModel *)[[[self.dataSource objectAtIndex:0] objectForKey:@"content"] objectAtIndex:5];
    if ([itemStatus.content isEqualToString:@""]) {
        [CommonFuntion showToast:@"状态不能为空" inView:self.view];
        return;
    }
    
    
    EditItemModel *itemRemark = (EditItemModel *)[[[self.dataSource objectAtIndex:0] objectForKey:@"content"] objectAtIndex:6];
    if (itemRemark.content.length > 150) {
        [CommonFuntion showToast:@"备注最大长度为150" inView:self.view];
        return;
    }
    
    if ([CommonFunc isStringNullObject:itemRemark.content]) {
        [CommonFuntion showToast:@"备注不能为null" inView:self.view];
        return;
    }
    
    ///发送请求
    [self addOrEditOrder];
}

#pragma mark - 初始化数据
-(void)initData{
    sourceConsignee = [[NSMutableArray alloc] init];
    soureType = [[NSMutableArray alloc] init];
    sourceStatus = [[NSMutableArray alloc] init];
    self.dataSource = [[NSMutableArray alloc] init];
    [self initConsigneeData];
}


#pragma mark - 测试数据
-(void)readTestData{
    /*
     orderId(订单ID)
     orderName(订单名称)
     orderSerialNo(订单编号)
     orderAmount(订单总金额)
     paymentMethod(付款方式)
     orderStatus(状态)
     orderRemark(备注)
     deliveryDate(发货时间)
     consigneeId(收货人ID)
     orderCreateDate(订单创建时间)
     orderUpdateDate(订单更新时间)
     */
    
    
}






///根据详情信息 设置弹框默认选项
-(void)initByDtailsData{
    NSString * statusId = [self.detail safeObjectForKey:@"orderStatusId"];
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
        [self notifyDataSource:[NSIndexPath indexPathForRow:3 inSection:0] valueString:model.title idString:model.itmeId];
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
    NSString *orderNo = @"";
    NSString *sendDate = @"";
    
    NSString *remark = @"";
    
    
    ///新增
    if ([self.actionType  isEqualToString:@"add"]) {

    }else if ([self.actionType  isEqualToString:@"edit"]) {
        ///编辑
        titleName = [self.detail safeObjectForKey:@"orderName"];
        statusName = [self.detail safeObjectForKey:@"orderStatusName"];
        typeName = [self.detail safeObjectForKey:@"paymentMethodName"];
        
        statusId = [self.detail safeObjectForKey:@"orderStatusId"];
        typeId = [self.detail safeObjectForKey:@"paymentMethodId"];
        
        
        amt = [self.detail safeObjectForKey:@"orderAmount"];
        orderNo = [self.detail safeObjectForKey:@"orderSerialNo"];
        sendDate = [self.detail safeObjectForKey:@"deliveryDate"];
        
        
        remark = [self.detail safeObjectForKey:@"orderRemark"];
        
        
        ///收货人ID
        NSString  *consigneeId = [self.detail safeObjectForKey:@"consigneeId"];
        [self getConsigneeById:consigneeId];

    }
    
    
    NSMutableDictionary *dicDataSource = [[NSMutableDictionary alloc] init];
    NSMutableArray *arraySection = [[NSMutableArray alloc] init];
    
    EditItemModel *model;
    
    model = [[EditItemModel alloc] init];
    model.title = @"订单名称:";
    model.content = titleName;
    model.placeholder = @"请输入订单名称";
    model.cellType = @"cellA";
    model.keyStr = @"orderName";
    model.keyType = @"";
    [arraySection addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"订单编号:";
    model.content = orderNo;
    model.placeholder = @"请输入订单编号";
    model.cellType = @"cellA";
    model.keyStr = @"orderSerialNo";
    model.keyType = @"";
    [arraySection addObject:model];
    
    
    
    model = [[EditItemModel alloc] init];
    model.title = @"总金额:";
    model.content = amt;
    model.placeholder = @"请输入订单总金额";
    model.cellType = @"cellA";
    model.keyStr = @"orderAmount";
    model.keyType = @"";
    [arraySection addObject:model];
    
    
    model = [[EditItemModel alloc] init];
    model.title = @"付款方式:";
    model.itemId = typeId;
    model.content = typeName;
    model.placeholder = @"";
    model.cellType = @"cellB";
    model.keyStr = @"paymentMethod";
    model.keyType = @"paymentMethod";
    [arraySection addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"发货日期:";
    model.itemId = @"";
    model.content = sendDate;
    model.placeholder = @"";
    model.cellType = @"cellF";
    model.keyStr = @"deliveryDate";
    model.keyType = @"";
    [arraySection addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"状态:";
    model.itemId = statusId;
    model.content = statusName;
    model.placeholder = @"";
    model.cellType = @"cellB";
    model.keyStr = @"orderStatus";
    model.keyType = @"orderStatus";
    [arraySection addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"沟通备注:";
    model.content = remark;
    model.placeholder = @"请输入备注(150字以内)";
    model.cellType = @"cellRemarkEdit";
    model.keyStr = @"orderRemark";
    model.keyType = @"";
    [arraySection addObject:model];
    
    
    [dicDataSource setObject:@"" forKey:@"head"];
    [dicDataSource setObject:arraySection forKey:@"content"];
    [self.dataSource addObject:dicDataSource];
    
    
    ////section 2 收货人信息
    arraySection = [[NSMutableArray alloc] init];
    dicDataSource = [[NSMutableDictionary alloc] init];
    
    model = [[EditItemModel alloc] init];
    model.title = @"收货人:";
    model.itemId = @"";
    model.content = @"";
    model.placeholder = @"";
    model.cellType = @"cellB";
    model.keyStr = @"consigneeId";
    model.keyType = @"consigneeId";
    [arraySection addObject:model];
    
    
//    curConsigneeItem
    model = [[EditItemModel alloc] init];
    model.title = @"手机:";
    model.content = @"";
    model.placeholder = @"";
    model.cellType = @"cellA";
    model.keyStr = @"";
    model.keyType = @"";
    [arraySection addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"固话:";
    model.content = @"";
    model.placeholder = @"";
    model.cellType = @"cellA";
    model.keyStr = @"";
    model.keyType = @"";
    [arraySection addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"邮箱:";
    model.content = @"";
    model.placeholder = @"";
    model.cellType = @"cellA";
    model.keyStr = @"";
    model.keyType = @"";
    [arraySection addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"地址:";
    model.content = @"";
    model.placeholder = @"";
    model.cellType = @"cellA";
    model.keyStr = @"";
    model.keyType = @"";
    [arraySection addObject:model];
    
    [dicDataSource setObject:@"" forKey:@"head"];
    [dicDataSource setObject:arraySection forKey:@"content"];
    [self.dataSource addObject:dicDataSource];
    
    [self updateConsigneeInfo];
    
    NSLog(@"self.dataSource:%@",self.dataSource);
    for (int i=0; i<[self.dataSource count]; i++) {
        NSArray *array = [[self.dataSource objectAtIndex:i] objectForKey:@"content"];
        for (int k=0; k<[array count]; k++) {
            EditItemModel *item  = (EditItemModel*) [array objectAtIndex:k];
            NSLog(@"%@  %@",item.title,item.cellType);
        }
    }
}


#pragma mark - 根据选择的收货人 更新显示信息
-(void)updateConsigneeInfo{
    NSString *consigneeName = @"";
    NSString *consigneeId = @"";
    NSString *consigneePhone = @"";
    NSString *consigneePostCode = @"";
    NSString *consigneeTel = @"";
    NSString *consigneeAddress = @"";
    
    if (curConsigneeItem) {
        consigneeId = [curConsigneeItem safeObjectForKey:@"ID"];
        consigneeName = [curConsigneeItem safeObjectForKey:@"NAME"];
        consigneePhone = [curConsigneeItem safeObjectForKey:@"MOBILE"];
        consigneePostCode = [curConsigneeItem safeObjectForKey:@"EMAIL"];
        consigneeTel = [curConsigneeItem safeObjectForKey:@"WORKPHONE"];
//        consigneeAddress = [curConsigneeItem safeObjectForKey:@"ADDRESS"];
        consigneeAddress = self.customer_address;
    }
    
    NSLog(@"updateConsigneeInfo curConsigneeItem:%@",curConsigneeItem);
    
    ///收货人姓名
    EditItemModel *model = (EditItemModel *)[[[self.dataSource objectAtIndex:1] objectForKey:@"content"] objectAtIndex:0];
    model.content = consigneeName;
    model.itemId = consigneeId;
    
    
    ///手机
    model = (EditItemModel *)[[[self.dataSource objectAtIndex:1] objectForKey:@"content"] objectAtIndex:1];
    model.content = consigneePhone;
    
    ///固话
    model = (EditItemModel *)[[[self.dataSource objectAtIndex:1] objectForKey:@"content"] objectAtIndex:2];
    model.content = consigneeTel;
    
    ///邮箱
    model = (EditItemModel *)[[[self.dataSource objectAtIndex:1] objectForKey:@"content"] objectAtIndex:3];
    model.content = consigneePostCode;
    
    ///地址
    model = (EditItemModel *)[[[self.dataSource objectAtIndex:1] objectForKey:@"content"] objectAtIndex:4];
    model.content = consigneeAddress;

    [self.tableview reloadData];
    
}

#pragma mark - 根据收货人ID获取收货人
-(void)getConsigneeById:(NSString *)consigneeId{
    NSInteger count = 0;
    if (self.arrayAllLinkMan) {
        count = [self.arrayAllLinkMan count];
    }
    BOOL isFound = FALSE;
    for (int i=0; !isFound && i<count; i++) {
        if ([consigneeId isEqualToString:[[self.arrayAllLinkMan objectAtIndex:i] safeObjectForKey:@"ID"]] ) {
            isFound = TRUE;
            curConsigneeItem = [self.arrayAllLinkMan objectAtIndex:i];
        }
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

///初始化收货人
-(void)initConsigneeData{
    ///类型
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSInteger count = 0;
    if (self.arrayAllLinkMan) {
        count = [self.arrayAllLinkMan count];
    }
    
    if (count > 0) {
        ///默认空联系人
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = @"";
        model.title = @"(不选择)";
        model.selectedFlag = @"no";
        [array addObject:model];
    }
    
    ///收货人ID
    NSString  *consigneeId = [self.detail safeObjectForKey:@"consigneeId"];
    
    for (int i=0; i<count; i++) {
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = [[self.arrayAllLinkMan objectAtIndex:i] safeObjectForKey:@"ID"];
        model.title = [[self.arrayAllLinkMan objectAtIndex:i] safeObjectForKey:@"NAME"];
        if ([consigneeId isEqualToString:model.itmeId]) {
            model.selectedFlag = @"yes";
        }else{
            model.selectedFlag = @"no";
        }
        
        [array addObject:model];
    }
    [sourceConsignee removeAllObjects];
    [sourceConsignee addObjectsFromArray:array];
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


#pragma mark - tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.dataSource) {
        return [self.dataSource count];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.dataSource objectAtIndex:section] objectForKey:@"content"] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditItemModel* item = (EditItemModel*) [[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];
    if ([item.cellType isEqualToString:@"cellRemarkEdit"]) {
        return 65.0;
    }
    return 50.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditItemModel* item = (EditItemModel*) [[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];
    
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
            ///1状态  2类型 3收货人
            NSInteger falg = 1;
            if (indexPath.section == 0) {
                if (indexPath.row == 5) {
                    falg = 1;
                }else if (indexPath.row == 3) {
                    falg = 2;
                }
            }else if (indexPath.section == 1){
                if (indexPath.row == 0) {
                    falg = 3;
                }
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
            
            [weak_self showDataPickerByFlag:0];
            
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
    EditItemModel *model = (EditItemModel *)[[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];
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
    }else if (flag == 3){
        title = @"收货人";
        type = 0;
        array = sourceConsignee;
    }
    
    if (array == nil || [array count] == 0) {
        NSLog(@"选择数据源为空");
        NSString *strMsg = @"";
        if (flag == 1) {
            strMsg = @"状态加载失败";
        }else if (flag == 2){
            strMsg = @"付款方式加载失败";
        }else if (flag == 2){
            strMsg = @"收货人加载失败";
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
        
        [self notifyDataSource:[NSIndexPath indexPathForRow:3 inSection:0] valueString:model.title idString:model.itmeId];
    }else if (flag == 3){
        ///清空收货人
        if (index == 0) {
            curConsigneeItem = nil;
        }else{
            curConsigneeItem = [self.arrayAllLinkMan objectAtIndex:index-1];
        }
        [self changeSelectedFlag:sourceConsignee index:index];
        
        ///@"请选择收货人";
        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[sourceConsignee objectAtIndex:index];
        NSLog(@"title:%@   ids:%@",model.title,model.itmeId);
        if (index == 0) {
            [self notifyDataSource:[NSIndexPath indexPathForRow:0 inSection:1] valueString:@"" idString:@""];
        }else{
            [self notifyDataSource:[NSIndexPath indexPathForRow:0 inSection:1] valueString:model.title idString:model.itmeId];
        }
        
        [self updateConsigneeInfo];
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
/// 0 发货日期
-(void)showDataPickerByFlag:(NSInteger)flag{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    ///开始日期
    __weak typeof(self) weak_self = self;
    NSDate *dateNow = nil;
    ///新增
    if ([self.actionType  isEqualToString:@"add"]) {
        dateNow = [NSDate dateWithDaysFromNow:1];
    }
    
    
    LLCenterPickerView *llsheet = [[LLCenterPickerView alloc]initWithCurDate:dateNow andMinDate:dateNow headTitle:@"发货日期" dateType:1];
    llsheet.selectedDateBlock = ^(NSString *time,NSDate *date){
        NSString *sendDate = @"";
        NSLog(@"-----date:%@",date);
        if (date == nil) {
            ///新增
            if ([self.actionType  isEqualToString:@"add"]) {
                sendDate = [CommonFunc dateToString:[NSDate dateWithDaysFromNow:1] Format:@"yyyy-MM-dd"];
            }else{
                sendDate = [CommonFunc dateToString:[NSDate date] Format:@"yyyy-MM-dd"];
            }
            
        }else{
            sendDate = [CommonFunc dateToString:date Format:@"yyyy-MM-dd"];
        }

        [weak_self notifyDataSource:[NSIndexPath indexPathForRow:4 inSection:0] valueString:sendDate idString:@""];
        [weak_self.tableview reloadData];
    };
    [llsheet showInView:nil];
}

#pragma mark - 网络请求

#pragma mark 获取合同字典信息
-(void)getOrderDictionary{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_INIT_ORDER_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"订单字典jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            if ([jsonResponse objectForKey:@"resultMap"]) {
                
                ///付款方式
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"paymentMethod"] != [NSNull null]) {
                    NSArray *paymentMethod = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"paymentMethod"];
                    NSLog(@"paymentMethod:%@",paymentMethod);
                    if (paymentMethod) {
                        [soureType addObjectsFromArray:paymentMethod];
                    }
                }
                
                
                ///状态
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"orderStatus"] != [NSNull null]) {
                    NSArray *orderStatus = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"orderStatus"];
                    NSLog(@"orderStatus:%@",orderStatus);
                    if (orderStatus) {
                        [sourceStatus addObjectsFromArray:orderStatus];
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
                [weak_self getOrderDictionary];
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

-(void)addOrEditOrder{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    EditItemModel *item;
    
    for (int i=0; i<[self.dataSource count]; i++) {
        NSArray *array = [[self.dataSource objectAtIndex:i] objectForKey:@"content"];
        for (int k=0; k<[array count]; k++) {
            EditItemModel *item  = (EditItemModel*) [array objectAtIndex:k];
            
            if (item.keyType && item.keyType.length > 0) {
                if (item.keyStr && item.keyStr.length > 0) {
                    [rDict setValue:item.itemId forKey:item.keyStr];
                }
            }else{
                if (item.keyStr && item.keyStr.length > 0) {
                    [rDict setValue:item.content forKey:item.keyStr];
                }
            }
            
        }
    }
    
    
    ///编辑
    if ([self.actionType isEqualToString:@"edit"]) {
        [rDict setValue:[self.detail safeObjectForKey:@"orderId"] forKey:@"orderId"];
    }
    
    [rDict setValue:self.customerId forKey:@"customerId"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_SAVE_ORDER_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        NSLog(@"新建/编辑订单jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            [CommonFuntion showToast:@"保存成功" inView:self.view];
            
            [self actionSuccess];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self addOrEditOrder];
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
        if (self.NotifyOrderList) {
            self.NotifyOrderList();
        }
    }else{
        if (self.NotifyOrderDetail) {
            self.NotifyOrderDetail();
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}


@end
