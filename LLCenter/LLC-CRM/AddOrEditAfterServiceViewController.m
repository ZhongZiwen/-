//
//  AddOrEditAfterServiceViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AddOrEditAfterServiceViewController.h"
#import "LLCenterUtility.h"
#import "EditItemModel.h"
#import "LLcenterSheetMenuView.h"
#import "LLCenterSheetMenuModel.h"
#import "TPKeyboardAvoidingTableView.h"
#import "CommonFunc.h"
#import "EditItemTypeCellA.h"
#import "EditItemTypeCellB.h"
#import "EditItemTypeCellRemarkEdit.h"
#import "CommonNoDataView.h"


@interface AddOrEditAfterServiceViewController ()<UITableViewDataSource,UITableViewDelegate,LLCenterSheetMenuDelegate>{
    
    ///类型
    NSMutableArray *soureType;
    ///状态
    NSMutableArray *sourceStatus;
}

@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property(strong,nonatomic) TPKeyboardAvoidingTableView *tableview;
@property(strong,nonatomic) NSMutableArray *dataSource;

@end

@implementation AddOrEditAfterServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = COLOR_BG;
    [self addNavBar];
    [self initTableview];
    [self initData];
    [self initDataWithActionType];
    ///测试数据
//        [self readTestSaleDictionaryData];
    [self getAfterServiceDictionary];
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
        [CommonFuntion showToast:@"售后主题不能为空" inView:self.view];
        return;
    }
    
    if ([CommonFunc isStringNullObject:itemTitle.content]) {
        [CommonFuntion showToast:@"销售主题不能为null" inView:self.view];
        return;
    }
    
    EditItemModel *itemStage = (EditItemModel *)[self.dataSource objectAtIndex:1];
    if ([itemStage.content isEqualToString:@""]) {
        [CommonFuntion showToast:@"类型不能为空" inView:self.view];
        return;
    }
    
    EditItemModel *itemStatus = (EditItemModel *)[self.dataSource objectAtIndex:2];
    if ([itemStatus.content isEqualToString:@""]) {
        [CommonFuntion showToast:@"状态不能为空" inView:self.view];
        return;
    }
    
    
    EditItemModel *itemRemark = (EditItemModel *)[self.dataSource objectAtIndex:3];
    if (itemRemark.content.length > 150) {
        [CommonFuntion showToast:@"备注最大长度为150" inView:self.view];
        return;
    }
    
    if ([CommonFunc isStringNullObject:itemRemark.content]) {
        [CommonFuntion showToast:@"备注不能为null" inView:self.view];
        return;
    }
    
    ///发送请求
    [self addOrEditAfterService];
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
     serviceId(售后ID)
     serviceTitle(售后主题)
     serviceType(售后类型)
     serviceStatus(售后状态)
     serviceRemark(沟通状态)
     serviceCreateDate(售后创建时间)
     serviceUpdateDate(售后更新时间)
     */
    /*
     self.detail = [[NSDictionary alloc] initWithObjectsAndKeys:@"11111",@"saleId",@"400号码购买",@"saleTitle",@"跟进中",@"saleStatusName",@"101010",@"saleStatusId",@"咨询",@"saleTypeName",@"4564735634",@"saleTypeId",@"有购买意向",@"saleStageName",@"3432",@"saleStageId",@"2015-10-13",@"saleCreateDate",@"2015-10-15",@"saleUpdateDate",@"备注备注备注备注备注备注备注备注备注注",@"saleRemark", nil];
     */
    [self initDataWithActionType];
}



///根据详情信息 设置弹框默认选项
-(void)initByDtailsData{
   NSString * statusId = [self.detail safeObjectForKey:@"serviceStatusId"];
    NSString * typeId = [self.detail safeObjectForKey:@"serviceTypeId"];
    
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
}

#pragma mark - 根据操作类型 新增/编辑 初始化数据源
-(void)initDataWithActionType{
    NSString *titleName = @"";
    NSString *statusName = @"";
    NSString *typeName = @"";
    NSString *statusId = @"";
    NSString *typeId = @"";
    NSString *remark = @"";
    ///新增
    if ([self.actionType  isEqualToString:@"add"]) {
        
    }else if ([self.actionType  isEqualToString:@"edit"]) {
        ///编辑
        titleName = [self.detail safeObjectForKey:@"serviceTitle"];
        statusName = [self.detail safeObjectForKey:@"serviceStatusName"];
        typeName = [self.detail safeObjectForKey:@"serviceTypeName"];
        
        statusId = [self.detail safeObjectForKey:@"serviceStatusId"];
        typeId = [self.detail safeObjectForKey:@"serviceTypeId"];
        remark = [self.detail safeObjectForKey:@"serviceRemark"];
    }
    
    
    EditItemModel *model;
    
    model = [[EditItemModel alloc] init];
    model.title = @"售后主题:";
    model.content = titleName;
    model.placeholder = @"请输入售后主题";
    model.cellType = @"cellA";
    model.keyStr = @"serviceTitle";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    
    model = [[EditItemModel alloc] init];
    model.title = @"类型:";
    model.itemId = typeId;
    model.content = typeName;
    model.placeholder = @"";
    model.cellType = @"cellB";
    model.keyStr = @"serviceType";
    model.keyType = @"serviceType";
    [self.dataSource addObject:model];
    
    
    model = [[EditItemModel alloc] init];
    model.title = @"状态:";
    model.itemId = statusId;
    model.content = statusName;
    model.placeholder = @"";
    model.cellType = @"cellB";
    model.keyStr = @"serviceStatus";
    model.keyType = @"serviceStatus";
    [self.dataSource addObject:model];
    
    
    model = [[EditItemModel alloc] init];
    model.title = @"沟通备注:";
    model.content = remark;
    model.placeholder = @"请输入备注(150字以内)";
    model.cellType = @"cellRemarkEdit";
    model.keyStr = @"serviceRemark";
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
        ///新增  填充默认选择项
        if ([self.actionType  isEqualToString:@"add"]) {
            if ([[[soureType objectAtIndex:i] safeObjectForKey:@"default"] integerValue] == 1) {
                model.selectedFlag = @"yes";
                [self notifyDataSource:[NSIndexPath indexPathForRow:1 inSection:0] valueString:model.title idString:model.itmeId];
            }else{
                model.selectedFlag = @"no";
            }
        }else{
            model.selectedFlag = @"no";
        }
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
        ///新增  填充默认选择项
        if ([self.actionType  isEqualToString:@"add"]) {
            if ([[[sourceStatus objectAtIndex:i] safeObjectForKey:@"default"] integerValue] == 1) {
                model.selectedFlag = @"yes";
                [self notifyDataSource:[NSIndexPath indexPathForRow:2 inSection:0] valueString:model.title idString:model.itmeId];
            }else{
                model.selectedFlag = @"no";
            }
        }else{
            model.selectedFlag = @"no";
        }
        [array3 addObject:model];
    }
    
    
    [soureType removeAllObjects];
    [sourceStatus removeAllObjects];
    
    [soureType addObjectsFromArray:array1];
    [sourceStatus addObjectsFromArray:array3];
    
    [self.tableview reloadData];
    
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
            if (indexPath.row == 1) {
                falg = 2;
            }else if (indexPath.row == 2) {
                falg = 1;
            }
            [weak_self showMenuByFlag:falg withIndexPath:indexPath];
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
///根据flag 弹框  2 类型 1状态
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
        title = @"类型";
        type = 0;
        array = soureType;
    }
    
    if (array == nil || [array count] == 0) {
        NSLog(@"选择数据源为空");
        NSString *strMsg = @"";
        if (flag == 1) {
            strMsg = @"状态加载失败";
        }else if (flag == 2){
            strMsg = @"类型加载失败";
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
        
        [self notifyDataSource:[NSIndexPath indexPathForRow:2 inSection:0] valueString:model.title idString:model.itmeId];
    }else if (flag == 2){
        [self changeSelectedFlag:soureType index:index];
        
        ///@"请选择类型";
        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[soureType objectAtIndex:index];
        NSLog(@"title:%@   ids:%@",model.title,model.itmeId);
        
        [self notifyDataSource:[NSIndexPath indexPathForRow:1 inSection:0] valueString:model.title idString:model.itmeId];
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

#pragma mark 获取售后字典信息
-(void)getAfterServiceDictionary{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_AFTER_SERVICE_DICTIONARY_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"售后字典jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            if ([jsonResponse objectForKey:@"resultMap"]) {
                
                
                ///类型
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"serviceTypeList"] != [NSNull null]) {
                    NSArray *serviceTypeList = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"serviceTypeList"];
                    NSLog(@"serviceTypeList:%@",serviceTypeList);
                    if (serviceTypeList) {
                        [soureType addObjectsFromArray:serviceTypeList];
                    }
                }
                
                
                ///状态
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"serviceStatusList"] != [NSNull null]) {
                    NSArray *serviceStatusList = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"serviceStatusList"];
                    NSLog(@"serviceStatusList:%@",serviceStatusList);
                    if (serviceStatusList) {
                        [sourceStatus addObjectsFromArray:serviceStatusList];
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
                [weak_self getAfterServiceDictionary];
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


#pragma mark - 新建、编辑售后服务

-(void)addOrEditAfterService{
    
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
        [rDict setValue:[self.detail safeObjectForKey:@"serviceId"] forKey:@"serviceId"];
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
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_SAVE_AFTER_SERVICE_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"新建/编辑售后jsonResponse:%@",jsonResponse);
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
                [weak_self addOrEditAfterService];
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
        if (self.NotifyAfterServiceList) {
            self.NotifyAfterServiceList();
        }
    }else{
        if (self.NotifyAfterServiceDetail) {
            self.NotifyAfterServiceDetail();
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
