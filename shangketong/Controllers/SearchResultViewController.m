//
//  SearchResultViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SearchResultViewController.h"
#import "CommonConstant.h"
#import "CommonModuleFuntion.h"
#import "CommonFuntion.h"
#import "AFNHttp.h"
#import "SearchHistoryCell.h"
#import "CampaignCell.h"
#import "ContactCell.h"
#import "SaleLeadSearchResultCell.h"
#import "SaleOpportunityCell.h"
#import "CommonDetailViewController.h"
@interface SearchResultViewController ()<UITableViewDataSource,UITableViewDelegate,SWTableViewCellDelegate,ContactCellDelegate>{
    ///页码
    NSInteger pageNo;
    
    ///销售机会  单位
    NSString *currencyUnit;
}

@end

@implementation SearchResultViewController


- (void)loadView
{
    [super loadView];
    self.title = @"搜索结果";
    self.view.backgroundColor = VIEW_BG_COLOR;
    [self initTableview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self readTestData];
    
    [self.tableviewSearch reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}


#pragma mark - 初始化数据
-(void)initData{
    pageNo = 1;
    self.arraySearch = [[NSMutableArray alloc] init];
}

#pragma mark - 读取测试数据
-(void)readTestData{
    [self setDataByViewFromFlag];
}

///根据页面标识 设置数据
-(void)setDataByViewFromFlag{
    if ([self.typeFromView isEqualToString:@"CampaignViewController"]) {
        id jsondata = [CommonFuntion readJsonFile:@"campaign-data"];
        NSLog(@"jsondata:%@",jsondata);
        
        NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"campaigns"];
        [self.arraySearch addObjectsFromArray:array];
    }else if ([self.typeFromView isEqualToString:@"ContactViewController"]) {
        ///联系人
        id jsondata = [CommonFuntion readJsonFile:@"contact-list-data"];
        NSLog(@"jsondata:%@",jsondata);
        
        NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"contacts"];
        [self.arraySearch addObjectsFromArray:array];
    }else if ([self.typeFromView isEqualToString:@"SMSContactSearchViewController"]){
        ///群发联系人
        id jsondata = [CommonFuntion readJsonFile:@"contact-list-data"];
        NSLog(@"jsondata:%@",jsondata);
        
        NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"contacts"];
        [self.arraySearch addObjectsFromArray:array];
    }
    else if ([self.typeFromView isEqualToString:@"CustomerViewController"]) {
        id jsondata = [CommonFuntion readJsonFile:@"customer-list-data"];
        NSLog(@"jsondata:%@",jsondata);
        
        NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"accounts"];
        [self.arraySearch addObjectsFromArray:array];
    }else if ([self.typeFromView isEqualToString:@"SMSCustomerSearchViewController"]) {
        ///群发短信 客户
        id jsondata = [CommonFuntion readJsonFile:@"customer-list-data"];
        NSLog(@"jsondata:%@",jsondata);
        
        NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"accounts"];
        [self.arraySearch addObjectsFromArray:array];
    }
    else if ([self.typeFromView isEqualToString:@"SaleLeadViewController"]) {
        ///销售线索
        id jsondata = [CommonFuntion readJsonFile:@"salelead-data"];
        NSLog(@"jsondata:%@",jsondata);
        
        NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"leads"];
        [self.arraySearch addObjectsFromArray:array];
    }else if ([self.typeFromView isEqualToString:@"SalesOpportunityViewController"]) {
        ///销售机会
        id jsondata = [CommonFuntion readJsonFile:@"sale-opportunity-data"];
        NSLog(@"jsondata:%@",jsondata);
        
        NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"opportunities"];
        [self.arraySearch addObjectsFromArray:array];
        currencyUnit = [[jsondata objectForKey:@"body"] objectForKey:@"currencyUnit"];
    }
    else{
        id jsondata = [CommonFuntion readJsonFile:@"contact-list-data"];
        NSLog(@"jsondata:%@",jsondata);
        
        NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"contacts"];
        [self.arraySearch addObjectsFromArray:array];
        
    }
}



#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewSearch = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.tableviewSearch.delegate = self;
    self.tableviewSearch.dataSource = self;
    self.tableviewSearch.sectionFooterHeight = 0;
    self.tableviewSearch.backgroundColor = VIEW_BG_COLOR;
    
    [self.view addSubview:self.tableviewSearch];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewSearch setTableFooterView:v];
    
    
    ///市场活动
    if ([self.typeFromView isEqualToString:@"CampaignViewController"]) {
        NSLog(@"registerNib CampaignCell");
        [self.tableviewSearch registerNib:[UINib nibWithNibName:@"CampaignCell" bundle:nil] forCellReuseIdentifier:@"CampaignCellIdentify"];
    }else if ([self.typeFromView isEqualToString:@"ContactViewController"] || [self.typeFromView isEqualToString:@"SMSContactSearchViewController"]) {
        ///联系人
        [self.tableviewSearch registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCellIdentify"];
    }
    
}

#pragma mark - 根据搜索关键词获取列表

///获取活动市场数据列表
-(void)getCampaignList{
    //组装参数
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInteger:pageNo] forKey:@"pageNo"];
    
    [self getSearchResultWithAction:@"" andParams:params];
}


/// action 接口
/// params 参数
-(void)getSearchResultWithAction:(NSString *)action andParams:(NSDictionary *)params{
    // 发起请求
    [AFNHttp post:action params:params success:^(id responseObj) {
        //字典转模型
        NSLog(@"responseObj:%@",responseObj);
        NSDictionary *info = responseObj;
        
        if ([[info objectForKey:@"scode"] integerValue] == 0) {
 
        }else{
        }
        
        [self.tableviewSearch reloadData];
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        [self.tableviewSearch reloadData];
    }];

}


#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.arraySearch) {
        return [self.arraySearch count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.typeFromView isEqualToString:@"SalesOpportunityViewController"]) {
        ///销售机会
        return 60.0;
    }
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.typeFromView isEqualToString:@"CampaignViewController"]) {
        ///市场活动
        static NSString *cellIdentifier = @"CampaignCellIdentify";
        
        CampaignCell *cell = (CampaignCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"CampaignCell" owner:self options:nil];
            cell = (CampaignCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        cell.delegate = self;
        [cell setCellFrame];
//        [cell setLeftAndRightBtn:[self.arraySearch objectAtIndex:indexPath.row]];
        [cell setCellDetails:[self.arraySearch objectAtIndex:indexPath.row]];
        return cell;
    }else if ([self.typeFromView isEqualToString:@"ContactViewController"] || [self.typeFromView isEqualToString:@"SMSContactSearchViewController"]) {
        
        ///联系人  群发短信联系人
        static NSString *cellIdentifier = @"ContactCellIdentify";
        ContactCell *cell = (ContactCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ContactCell" owner:self options:nil];
            cell = (ContactCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        cell.ccdelegate = self;
        [cell setCellFrame];
        [cell setCellDetails:[self.arraySearch objectAtIndex:indexPath.row]];
        [cell setCallBtnShow:[self.arraySearch objectAtIndex:indexPath.row] index:indexPath];
        return cell;
    }else if ([self.typeFromView isEqualToString:@"CustomerViewController"] || [self.typeFromView isEqualToString:@"SMSCustomerSearchViewController"]) {
        ///客户
        SearchHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchHistoryCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SearchHistoryCell" owner:self options:nil];
            cell = (SearchHistoryCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        
        [cell setCellFrame];
        [cell setCellDetails:[self.arraySearch objectAtIndex:indexPath.row]];
        
        return cell;
    }else if ([self.typeFromView isEqualToString:@"SaleLeadViewController"]) {
        ///销售线索
        SaleLeadSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SaleLeadSearchResultCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SaleLeadSearchResultCell" owner:self options:nil];
            cell = (SaleLeadSearchResultCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        [cell setCellDetails:[self.arraySearch objectAtIndex:indexPath.row]];
        
        return cell;
    }else if ([self.typeFromView isEqualToString:@"SalesOpportunityViewController"]) {
        ///销售机会
        SaleOpportunityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SaleOpportunityCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SaleOpportunityCell" owner:self options:nil];
            cell = (SaleOpportunityCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        [cell setCellDetails:[self.arraySearch objectAtIndex:indexPath.row] currencyUnit:currencyUnit index:indexPath];
        return cell;
    }
    
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ///判断是否可选择
    //    if (indexPath.row/2 == 0) {
    //        [searchTextField resignFirstResponder];
    //        //        [self dismissViewControllerAnimated:YES completion:nil];
    //        [self.navigationController popViewControllerAnimated:YES];
    //    }
    if ([self.typeFromView isEqualToString:@"SMSContactSearchViewController"]){
        ///群发短信联系人
        
    }else if([self.typeFromView isEqualToString:@"SMSCustomerSearchViewController"]){
        ///群发短信客户
    }else{
        
        CommonDetailViewController *controller = [[CommonDetailViewController alloc] init];
        
        ///客户1   销售机会2  联系人3  销售线索4  市场活动5
        NSInteger type = 0;
        
        if ([self.typeFromView isEqualToString:@"CustomerViewController"]) {
            ///客户
            type = 1;
        }else if ([self.typeFromView isEqualToString:@"SalesOpportunityViewController"]) {
            ///销售机会
            type = 2;
        }else if ([self.typeFromView isEqualToString:@"ContactViewController"]) {
            ///联系人
            type = 3;
        }
        else if ([self.typeFromView isEqualToString:@"SaleLeadViewController"]) {
            ///销售线索
            type = 4;
            controller.currencyUnit = currencyUnit;
            /*
             controller.groupNameOfSaleOpportunity = @"";
             */
            
        }else if ([self.typeFromView isEqualToString:@"CampaignViewController"]) {
            /// 活动市场
            type = 5;
        }
        
        
        controller.typeOfDetail = type;
        controller.itemDetails = [self.arraySearch objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:controller animated:YES];
        
    }
}


#pragma mark - SWTableViewDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            //        NSLog(@"utility buttons closed");
            break;
        case 1:
            //        NSLog(@"left utility buttons open");
            break;
        case 2:
            //        NSLog(@"right utility buttons open");
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            //        NSLog(@"left button 0 was pressed");
            break;
        default:
            break;
    }
}


- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return NO;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [self.tableviewSearch indexPathForCell:cell];
    NSLog(@"click index:%ti",indexPath.row);
    NSDictionary *item = [self.arraySearch objectAtIndex:indexPath.row];
    
    ///市场活动
    if ([self.typeFromView isEqualToString:@"CampaignViewController"]) {
        [self  CampaignViewCellEvent:cell item:item WithIndex:index];
    }else if ([self.typeFromView isEqualToString:@"ContactViewController"]) {
        ///联系人
    }
    
}

-(void)CampaignViewCellEvent:(SWTableViewCell *)cell item:(NSDictionary *)item WithIndex:(NSInteger)index{
    switch (index) {
        case 0:
        {
            BOOL isFollow = FALSE;
            if ([item objectForKey:@"isFollow"]) {
                isFollow = [[item objectForKey:@"isFollow"] boolValue];
            }
            if (isFollow) {
                NSLog(@"取消关注...");
            }else{
                NSLog(@"关注...");
            }
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        default:
            break;
    }
}


#pragma mark - 拨打联系人事件回调
-(void)callCantact:(NSInteger)index{
    NSLog(@"callCantact:%li",index);
}

@end
