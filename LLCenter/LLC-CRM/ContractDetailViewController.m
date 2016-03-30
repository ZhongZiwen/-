//
//  ContractDetailViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "ContractDetailViewController.h"
#import "LLCenterUtility.h"
#import "EditItemModel.h"
#import "TPKeyboardAvoidingTableView.h"
#import "CommonFunc.h"
#import "EditItemTypeCellRemarkShow.h"
#import "DetailCellA.h"
#import "DetailCellB.h"
#import "CommonNoDataView.h"
#import "AddOrEditContractViewController.h"

@interface ContractDetailViewController ()<UITableViewDataSource,UITableViewDelegate>{
    
}
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property(strong,nonatomic) TPKeyboardAvoidingTableView *tableview;
@property(strong,nonatomic) NSMutableArray *dataSource;
@property(strong,nonatomic) NSDictionary *detail;
@end

@implementation ContractDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"合同";
    self.view.backgroundColor = COLOR_BG;
    [super customBackButton];
    [self getContractDetail];
    [self initTableview];
    [self.tableview reloadData];
}

#pragma mark - add nav bar
-(void)addNavBar{
//    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editDetail)];
//    self.navigationItem.rightBarButtonItem = editButton;
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editDetail)];
    self.navigationItem.rightBarButtonItem = editButton;
}

///编辑详情
-(void)editDetail{
    
    AddOrEditContractViewController *aec = [[AddOrEditContractViewController alloc] init];
    aec.title = @"编辑合同";
    aec.actionType = @"edit";
    aec.customerId = self.customerId;
    aec.detail = self.detail;
    __weak typeof(self) weak_self = self;
    aec.NotifyContractDetail = ^{
        [weak_self getContractDetail];
        if (weak_self.NotifyContractList) {
            weak_self.NotifyContractList();
        }
    };
    
    [self.navigationController pushViewController:aec animated:YES];
    
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
    
    self.detail = [[NSDictionary alloc] initWithObjectsAndKeys:@"11111",@"contractId",@"400号码购买合同2",@"contractName",@"执行中",@"contractStatusName",@"30002",@"contractStatusId",@"888888",@"contractAmount",@"现金付款",@"paymentMethodName",@"10001",@"paymentMethodId",@"2015-10-13",@"contractStartTime",@"2015-10-15",@"contractEndTime",@"2015-10-14",@"contractCreateDate",@"2015-10-17",@"contractUpdateDate",@"备注备注备注备注备注备注备注备注备注注",@"contractRemark", nil];
    
    [self initDataWithDetail];
}

#pragma mark - 根据客户类型 初始化数据  0公司客户 1个人客户
-(void)initDataWithDetail{
    self.dataSource = [[NSMutableArray alloc] init];
    EditItemModel *model;
    
    model = [[EditItemModel alloc] init];
    model.title = @"合同名称:";
    model.content = [self.detail safeObjectForKey:@"contractName"];
    model.placeholder = @"";
    model.cellType = @"cellB";
    model.keyStr = @"";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    
    /// 金额  付款方式
    model = [[EditItemModel alloc] init];
    model.title = [NSString stringWithFormat:@"总金额: %@",[self.detail safeObjectForKey:@"contractAmount"]];
    model.content = [NSString stringWithFormat:@"付款方式: %@",[self.detail safeObjectForKey:@"paymentMethodName"]];
    model.placeholder = @"";
    model.cellType = @"cellA";
    model.keyStr = @"";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    
    ///开始时间/结束时间
    model = [[EditItemModel alloc] init];
    model.title = [NSString stringWithFormat:@"开始时间: %@",[self.detail safeObjectForKey:@"contractStartTime"]];
    model.content = [NSString stringWithFormat:@"结束时间: %@",[self.detail safeObjectForKey:@"contractEndTime"]];
    model.placeholder = @"";
    model.cellType = @"cellA";
    model.keyStr = @"";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    
    
    
    

    NSString *contractCreateDate = [self.detail safeObjectForKey:@"contractCreateDate"];
    if (contractCreateDate && contractCreateDate.length > 10) {
        contractCreateDate = [contractCreateDate substringToIndex:10];
    }
    
    NSString *contractUpdateDate = [self.detail safeObjectForKey:@"contractUpdateDate"];
    if (contractUpdateDate && contractUpdateDate.length > 10) {
        contractUpdateDate = [contractUpdateDate substringToIndex:10];
    }
    
    ///创建时间/更新时间
    model = [[EditItemModel alloc] init];
    model.title = [NSString stringWithFormat:@"创建时间: %@",contractCreateDate];
    model.content = [NSString stringWithFormat:@"更新时间: %@",contractUpdateDate];
    model.placeholder = @"";
    model.cellType = @"cellA";
    model.keyStr = @"";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    
    ///状态
    model = [[EditItemModel alloc] init];
    model.title = [NSString stringWithFormat:@"状态: %@",[self.detail safeObjectForKey:@"contractStatusName"]];
    model.content = @"";
    model.placeholder = @"";
    model.cellType = @"cellA";
    model.keyStr = @"";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"沟通备注:";
    model.content = [self.detail safeObjectForKey:@"contractRemark"];
    model.placeholder = @"";
    model.cellType = @"cellRemarkShow";
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
-(void)getContractDetail{
    self.detail = nil;
    [self clearViewNoData];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rDict setValue:self.contractId forKey:@"contractId"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    
    NSLog(@"rParam:%@",rParam);
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_CONTRACT_DETAILS_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"合同详情jsonResponse:%@",jsonResponse);
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
                [weak_self getContractDetail];
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
