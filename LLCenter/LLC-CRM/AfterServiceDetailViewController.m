//
//  AfterServiceDetailViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AfterServiceDetailViewController.h"
#import "LLCenterUtility.h"
#import "EditItemModel.h"
#import "TPKeyboardAvoidingTableView.h"
#import "CommonFunc.h"
#import "EditItemTypeCellRemarkShow.h"
#import "DetailCellA.h"
#import "DetailCellB.h"
#import "CommonNoDataView.h"
#import "AddOrEditAfterServiceViewController.h"


@interface AfterServiceDetailViewController ()<UITableViewDataSource,UITableViewDelegate>{
    
}
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property(strong,nonatomic) TPKeyboardAvoidingTableView *tableview;
@property(strong,nonatomic) NSMutableArray *dataSource;
@property(strong,nonatomic) NSDictionary *detail;
@end

@implementation AfterServiceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"售后服务";
    self.view.backgroundColor = COLOR_BG;
    [super customBackButton];

//    [self readTestData];
    [self initTableview];
    [self getAfterServiceDetail];
    [self.tableview reloadData];
}

#pragma mark - add nav bar
-(void)addNavBar{
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editDetail)];
    self.navigationItem.rightBarButtonItem = editButton;
}

///编辑详情
-(void)editDetail{
    AddOrEditAfterServiceViewController *aec = [[AddOrEditAfterServiceViewController alloc] init];
    aec.title = @"编辑售后服务";
    aec.actionType = @"edit";
    aec.customerId = self.customerId;
    aec.detail = self.detail;
    __weak typeof(self) weak_self = self;
    aec.NotifyAfterServiceDetail = ^{
        [weak_self getAfterServiceDetail];
        if (weak_self.NotifyAfterServiceList) {
            weak_self.NotifyAfterServiceList();
        }
    };
    
    [self.navigationController pushViewController:aec animated:YES];
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
    
    self.detail = [[NSDictionary alloc] initWithObjectsAndKeys:@"11111",@"serviceId",@"400号码购买售后",@"serviceTitle",@"已处理",@"serviceStatusName",@"30002",@"serviceStatusId",@"故障排查",@"serviceTypeName",@"10001",@"serviceTypeId",@"2015-10-13",@"serviceCreateDate",@"2015-10-15",@"serviceUpdateDate",@"备注备注备注备注备注备注备注备注备注注",@"serviceRemark", nil];
    
    [self initDataWithDetail];
}

#pragma mark - 根据客户类型 初始化数据  0公司客户 1个人客户
-(void)initDataWithDetail{
    self.dataSource = [[NSMutableArray alloc] init];
    EditItemModel *model;
    
    model = [[EditItemModel alloc] init];
    model.title = @"售后主题:";
    model.content = [self.detail safeObjectForKey:@"serviceTitle"];
    model.placeholder = @"";
    model.cellType = @"cellB";
    model.keyStr = @"";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    ///类型 状态
    model = [[EditItemModel alloc] init];
    model.title = [NSString stringWithFormat:@"类型: %@",[self.detail safeObjectForKey:@"serviceTypeName"]];
    model.content = [NSString stringWithFormat:@"状态: %@",[self.detail safeObjectForKey:@"serviceStatusName"]];
    model.placeholder = @"";
    model.cellType = @"cellA";
    model.keyStr = @"";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    
    NSString *serviceCreateDate = [self.detail safeObjectForKey:@"serviceCreateDate"];
    if (serviceCreateDate && serviceCreateDate.length > 10) {
        serviceCreateDate = [serviceCreateDate substringToIndex:10];
    }
    
    NSString *serviceUpdateDate = [self.detail safeObjectForKey:@"serviceUpdateDate"];
    if (serviceUpdateDate && serviceUpdateDate.length > 10) {
        serviceUpdateDate = [serviceUpdateDate substringToIndex:10];
    }
    
    ///创建时间/更新时间
    model = [[EditItemModel alloc] init];
    model.title = [NSString stringWithFormat:@"创建时间: %@",serviceCreateDate];
    model.content = [NSString stringWithFormat:@"更新时间: %@",serviceUpdateDate];
    model.placeholder = @"";
    model.cellType = @"cellA";
    model.keyStr = @"";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    
    model = [[EditItemModel alloc] init];
    model.title = @"沟通备注:";
    model.content = [self.detail safeObjectForKey:@"serviceRemark"];
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
-(void)getAfterServiceDetail{
    self.detail = nil;
    [self clearViewNoData];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rDict setValue:self.serviceId forKey:@"serviceId"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    
    NSLog(@"rParam:%@",rParam);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_AFTER_SERVICE_DETAILS_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"售后详情jsonResponse:%@",jsonResponse);
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
                [weak_self getAfterServiceDetail];
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
