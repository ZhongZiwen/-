//
//  OrderDetailViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "LLCenterUtility.h"
#import "EditItemModel.h"
#import "TPKeyboardAvoidingTableView.h"
#import "CommonFunc.h"
#import "EditItemTypeCellRemarkShow.h"
#import "DetailCellA.h"
#import "DetailCellB.h"
#import "CommonNoDataView.h"
#import "AddOrEditOrderViewController.h"

@interface OrderDetailViewController ()<UITableViewDataSource,UITableViewDelegate>{
    
    ///当前选择的收货人
    NSDictionary *curConsigneeItem;
    
}
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property(strong,nonatomic) TPKeyboardAvoidingTableView *tableview;
@property(strong,nonatomic) NSMutableArray *dataSource;
@property(strong,nonatomic) NSDictionary *detail;
@end


@implementation OrderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"订单";
    self.view.backgroundColor = COLOR_BG;
    [super customBackButton];
    
    [self getOrderDetail];
    [self initTableview];
    [self.tableview reloadData];
}

#pragma mark - add nav bar
-(void)addNavBar{
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editDetail)];
    self.navigationItem.rightBarButtonItem = editButton;
}

///编辑详情
-(void)editDetail{
    
    AddOrEditOrderViewController *aec = [[AddOrEditOrderViewController alloc] init];
    aec.title = @"编辑订单";
    aec.actionType = @"edit";
    aec.customerId = self.customerId;
    aec.detail = self.detail;
    aec.arrayAllLinkMan = self.arrayAllLinkMan;
    aec.customer_address = self.customer_address;
    __weak typeof(self) weak_self = self;
    aec.NotifyOrderDetail = ^{
        [weak_self getOrderDetail];
        if (weak_self.NotifyOrderList) {
            weak_self.NotifyOrderList();
        }
    };
    
    [self.navigationController pushViewController:aec animated:YES];
    
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


#pragma mark - 根据客户类型 初始化数据
-(void)initDataWithDetail{
    if (self.dataSource) {
        [self.dataSource removeAllObjects];
    }
    ///收货人ID
    curConsigneeItem = nil;
    NSString  *consigneeId = [self.detail safeObjectForKey:@"consigneeId"];
    [self getConsigneeById:consigneeId];
    
    self.dataSource = [[NSMutableArray alloc] init];
    EditItemModel *model;
    
    model = [[EditItemModel alloc] init];
    model.title = @"订单名称:";
    model.content = [self.detail safeObjectForKey:@"orderName"];
    model.placeholder = @"";
    model.cellType = @"cellB";
    model.keyStr = @"";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    
    ///订单号、总金额
    model = [[EditItemModel alloc] init];
    model.title = [NSString stringWithFormat:@"订单号: %@",[self.detail safeObjectForKey:@"orderSerialNo"]];
    model.content = [NSString stringWithFormat:@"总金额: %@",[self.detail safeObjectForKey:@"orderAmount"]];
    model.placeholder = @"";
    model.cellType = @"cellA";
    model.keyStr = @"";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    
    ///付款方式、发货日期
    model = [[EditItemModel alloc] init];
    model.title = [NSString stringWithFormat:@"付款方式: %@",[self.detail safeObjectForKey:@"paymentMethodName"]];
    model.content = [NSString stringWithFormat:@"发货日期: %@",[self.detail safeObjectForKey:@"deliveryDate"]];
    model.placeholder = @"";
    model.cellType = @"cellA";
    model.keyStr = @"";
    model.keyType = @"";
    [self.dataSource addObject:model];

    ///状态
    model = [[EditItemModel alloc] init];
    model.title = [NSString stringWithFormat:@"状态: %@",[self.detail safeObjectForKey:@"orderStatusName"]];
    model.content = @"";
    model.placeholder = @"";
    model.cellType = @"cellA";
    model.keyStr = @"";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    
    model = [[EditItemModel alloc] init];
    model.title = @"沟通备注:";
    model.content = [self.detail safeObjectForKey:@"orderRemark"];
    model.placeholder = @"";
    model.cellType = @"cellRemarkShow";
    model.keyStr = @"";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    
    
    NSString *consigneeName = @"";
    NSString *consigneePhone = @"";
    NSString *consigneePostCode = @"";
    NSString *consigneeTel = @"";
    NSString *consigneeAddress = @"";
    
    if (curConsigneeItem) {
        consigneeName = [curConsigneeItem safeObjectForKey:@"NAME"];
        consigneePhone = [curConsigneeItem safeObjectForKey:@"MOBILE"];
        consigneePostCode = [curConsigneeItem safeObjectForKey:@"EMAIL"];
        consigneeTel = [curConsigneeItem safeObjectForKey:@"WORKPHONE"];
//        consigneeAddress = [curConsigneeItem safeObjectForKey:@"ADDRESS"];
        consigneeAddress = self.customer_address;
    }
    
    
    ///收货人、手机
    model = [[EditItemModel alloc] init];
    model.title = [NSString stringWithFormat:@"收货人: %@",consigneeName];
    model.content = [NSString stringWithFormat:@"手机: %@",consigneePhone];
    model.placeholder = @"";
    model.cellType = @"cellA";
    model.keyStr = @"";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    
    ///固话
    model = [[EditItemModel alloc] init];
    model.title = [NSString stringWithFormat:@"固话: %@",consigneeTel];
    model.content = [NSString stringWithFormat:@"邮箱: %@",consigneePostCode];
    model.placeholder = @"";
    model.cellType = @"cellA";
    model.keyStr = @"";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    
    ///地址
    model = [[EditItemModel alloc] init];
    model.title = [NSString stringWithFormat:@"地址: %@",consigneeAddress];
    model.content = @"";
    model.placeholder = @"";
    model.cellType = @"cellA";
    model.keyStr = @"";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    
    NSString *orderCreateDate = [self.detail safeObjectForKey:@"orderCreateDate"];
    if (orderCreateDate && orderCreateDate.length > 10) {
        orderCreateDate = [orderCreateDate substringToIndex:10];
    }
    
    NSString *orderUpdateDate = [self.detail safeObjectForKey:@"orderUpdateDate"];
    if (orderUpdateDate && orderUpdateDate.length > 10) {
        orderUpdateDate = [orderUpdateDate substringToIndex:10];
    }
    
    ///创建日期、更新日期
    model = [[EditItemModel alloc] init];
    model.title = [NSString stringWithFormat:@"创建日期: %@",orderCreateDate];
    model.content = [NSString stringWithFormat:@"更新日期: %@",orderUpdateDate];
    model.placeholder = @"";
    model.cellType = @"cellA";
    model.keyStr = @"";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    
    
    NSLog(@"self.dataSource:%@",self.dataSource);
    for (int i=0; i<[self.dataSource count]; i++) {
        EditItemModel *item  = (EditItemModel*) [self.dataSource objectAtIndex:i];
        NSLog(@"%@  %@",item.title,item.cellType);
    }
}


#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableview = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-64) style:UITableViewStyleGrouped];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.sectionFooterHeight = 0;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableview];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableview setTableFooterView:v];
    
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
    if ([item.cellType isEqualToString:@"cellE"]) {
        return 50.0;
    }else if ([item.cellType isEqualToString:@"cellRemarkShow"]) {
        return [EditItemTypeCellRemarkShow getCellHeight:item];
    }
    return 50.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditItemModel* item = (EditItemModel*) [self.dataSource objectAtIndex:indexPath.row];
    
    if ([item.cellType isEqualToString:@"cellA"]) {
        DetailCellA *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCellAIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"DetailCellA" owner:self options:nil];
            cell = (DetailCellA*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        
        [cell setCellDetail:item];
        return cell;
    }else if ([item.cellType isEqualToString:@"cellB"]) {
        DetailCellB *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCellBIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"DetailCellB" owner:self options:nil];
            cell = (DetailCellB*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        
        [cell setCellDetail:item];
        return cell;
    }
    else if ([item.cellType isEqualToString:@"cellRemarkShow"]) {
        EditItemTypeCellRemarkShow *cell = [tableView dequeueReusableCellWithIdentifier:@"EditItemTypeCellRemarkShowIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"EditItemTypeCellRemarkShow" owner:self options:nil];
            cell = (EditItemTypeCellRemarkShow*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        
        [cell setCellDetail:item];
        return cell;
    }
    return nil;
}


#pragma mark - 没有数据时的view
-(void)notifyNoDataView{
    if (self.detail) {
        [self clearViewNoData];
    }else{
        [self setViewNoData:@"加载失败"];
    }
}

-(void)setViewNoData:(NSString *)title{
    if (self.commonNoDataView == nil) {
        self.commonNoDataView = [CommonFunc commonNoDataViewIcon:@"list_empty.png" Title:title optionBtnTitle:@""];
    }
    
    [self.tableview addSubview:self.commonNoDataView];
}

-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
    }
}



#pragma mark - 网络请求
-(void)getOrderDetail{
    self.navigationItem.rightBarButtonItem = nil;
    self.detail = nil;
    [self clearViewNoData];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rDict setValue:self.orderId forKey:@"orderId"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    
    NSLog(@"rParam:%@",rParam);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_ORDER_DETAILS_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"订单详情jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            self.detail = [jsonResponse objectForKey:@"resultMap"] ;
            
            if (self.detail) {
                [self addNavBar];
                [self initDataWithDetail];
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getOrderDetail];
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
        [self.tableview reloadData];
        [self notifyNoDataView];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        [self.tableview reloadData];
        [self notifyNoDataView];
    }];
    
}


@end
