//
//  DeleteSaleOpportunityViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-14.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "DeleteSaleOpportunityViewController.h"
#import "LLCSaleOpportunityCell.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"


@interface DeleteSaleOpportunityViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSString *strDeleteIds;
}

@property(strong,nonatomic) UITableView *tableview;
@property(strong,nonatomic) NSMutableArray *dataSource;

@end

@implementation DeleteSaleOpportunityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"销售机会";
    self.view.backgroundColor = COLOR_BG;
    [self addNavBar];
    [self initData];
    [self initTableview];
    [self.tableview reloadData];
}

#pragma mark - Nav Bar
-(void)addNavBar{
    [super setFlagOfSubView];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPress)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonPress)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
}

#pragma mark  取消按钮事件
- (void)cancelButtonPress {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark-  删除事件
-(void)deleteButtonPress {
    NSMutableString *strSaleId = [[NSMutableString alloc] init];
    
    NSInteger count = 0;
    if (self.dataSource) {
        count = [self.dataSource count];
    }
    NSDictionary *item;
    for (int i=0; i<count; i++) {
        item = [self.dataSource objectAtIndex:i];
        ///选中的情况下
        if ([item objectForKey:@"checked"] && [[item objectForKey:@"checked"] boolValue]) {
            
            if ([strSaleId isEqualToString:@""]) {
                [strSaleId appendString:[item safeObjectForKey:@"saleId"]];
            }else{
                [strSaleId appendString:@","];
                [strSaleId appendString:[item safeObjectForKey:@"saleId"]];
            }
        }
    }
    
    NSLog(@"strSaleId:%@",strSaleId);
    if ([strSaleId isEqualToString:@""]) {
        [CommonFuntion showToast:@"请选择要删除的销售机会" inView:self.view];
        return;
    }
    strDeleteIds = strSaleId;
    [self showDeleteAlert];
}


#pragma mark - 初始化数据
-(void)initData{
    strDeleteIds = @"";
    self.dataSource = [[NSMutableArray alloc] init];
    [self.dataSource addObjectsFromArray:self.dataSourceOld];
    
    NSInteger count = 0;
    if (self.dataSource) {
        count = [self.dataSource count];
    }
    NSDictionary *item;
    NSMutableDictionary *mutableItemNew;
    for (int i=0; i<count; i++) {
        item = [self.dataSource objectAtIndex:i];
        mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:item];
        
        [mutableItemNew setValue:@(NO) forKey:@"checked"];
        [self.dataSource setObject: mutableItemNew atIndexedSubscript:i];
    }
}

#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-64) style:UITableViewStyleGrouped];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.sectionFooterHeight = 0;
    [self.view addSubview:self.tableview];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableview setTableFooterView:v];

}


#pragma mark - tableview delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.dataSource) {
        return [self.dataSource count];
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LLCSaleOpportunityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LLCSaleOpportunityCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"LLCSaleOpportunityCell" owner:self options:nil];
        cell = (LLCSaleOpportunityCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
        [cell setCellFrameWithType:2];
    }
    
    [cell setCellDetail:[self.dataSource objectAtIndex:indexPath.section] anIndexPath:indexPath];
    
    __weak typeof(self) weak_self = self;
    cell.NotifyCheckBoxBlock = ^(NSInteger section){
        NSLog(@"section:%ti",section);
        [weak_self updateCheckBoxFlag:section];
    };
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self updateCheckBoxFlag:indexPath.section];
}





-(void)updateCheckBoxFlag:(NSInteger)section{
    // 更新数据源
    NSMutableDictionary *dict = [self.dataSource objectAtIndex:section];
    NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:dict];
    [mutableItemNew setValue:@(!([[dict objectForKey:@"checked"] boolValue])) forKey:@"checked"];
    //修改数据
    [self.dataSource setObject: mutableItemNew atIndexedSubscript:section];
    
    // 刷新指定section
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:section];
    [self.tableview reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark - UIAlertView

///删除提示框
-(void)showDeleteAlert{
    UIAlertView *alertCall = [[UIAlertView alloc] initWithTitle:nil message: @"删除当前已选择的销售机会?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alertCall show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //删除
    if (buttonIndex == 1) {
        [self deleteSaleOpportunity:strDeleteIds];
    }
}

#pragma mark - 网络请求
-(void)deleteSaleOpportunity:(NSString *)saleId{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rDict setValue:saleId forKey:@"saleId"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_DELETE_SALE_OPPORTUNITY_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"删除销售机会jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [CommonFuntion showToast:@"删除成功" inView:self.view];
            if (self.NotifySaleOpportunitysList) {
                self.NotifySaleOpportunitysList();
            }
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self deleteSaleOpportunity:saleId];
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

@end
