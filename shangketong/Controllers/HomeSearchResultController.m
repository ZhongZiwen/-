//
//  HomeSearchResultController.m
//  
//
//  Created by sungoin-zjp on 15/12/25.
//
//

#import "HomeSearchResultController.h"
#import "HomeSearchOtherResultController.h"
//#import "SearchResultCell.h"
#import "HomeSearchResultCell.h"

#import "ContactDetailViewController.h"
#import "CustomerDetailViewController.h"
#import "OpportunityDetailController.h"
#import "LeadDetailViewController.h"

#import "Contact.h"
#import "Customer.h"
#import "SaleChance.h"
#import "Lead.h"


#import "CommonNoDataView.h"

@interface HomeSearchResultController ()<UITableViewDataSource,UITableViewDelegate>{
}


@property (nonatomic, strong) UITableView *tableview;
///数据源
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) CommonNoDataView *commonNoDataView;

@end

@implementation HomeSearchResultController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = _searchText;
    
    [self initData];
    [self initTableview];
    
    ///请求数据
    [self sendCmdToSearchByKeyWord];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
}

///初始化数据
-(void)initData{
    self.dataSource = [[NSMutableArray alloc] init];
}

#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStyleGrouped];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.sectionFooterHeight = 0;
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
    self.tableview.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    [self.view addSubview:self.tableview];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableview setTableFooterView:v];
}


#pragma mark -- tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_flagFromWhere == 0) {
        return [self.dataSource count];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (_flagFromWhere == 0) {
         NSInteger allCount =  [[[self.dataSource objectAtIndex:section] objectForKey:@"numberOfRow"] integerValue];
        if (allCount -2 > 0) {
            return 2;
        }
        return allCount;
    }
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_flagFromWhere == 0) {
        return 120;
    }
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSInteger otherCount =  [[[self.dataSource objectAtIndex:section] objectForKey:@"numberOfRow"] integerValue] -2;
    if (otherCount > 0) {
        return 40;
    }
    return 0.1;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 60)];
    headView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 40, 40)];
    UILabel *lableSectionName = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, kScreen_Width-90, 20)];
    lableSectionName.font = [UIFont systemFontOfSize:16.0];
    
    UILabel *lableCountAll= [[UILabel alloc] initWithFrame:CGRectMake(80, 30, kScreen_Width-90, 20)];
    lableCountAll.font = [UIFont systemFontOfSize:14.0];
    lableCountAll.textColor = [UIColor lightGrayColor];
    
    NSString *imgName = @"";
    NSString *sectionName = @"";
    NSString *allCount = [NSString stringWithFormat:@"%@个结果",[[self.dataSource objectAtIndex:section] objectForKey:@"numberOfRow"]];
    
    
    ///根据不同数据类型的cell  传入type 以作区分标记
    NSString *cellType = [[self.dataSource objectAtIndex:section] objectForKey:@"sectionKey"];
    

    if ([cellType isEqualToString:@"contacts"]) {
        sectionName = @"联系人";
        imgName = @"searchServer_contact.png";
    }else if ([cellType isEqualToString:@"customers"]) {
       sectionName = @"客户";
        imgName = @"searchServer_account.png";
    }else if ([cellType isEqualToString:@"opportunitys"]) {
        sectionName = @"销售机会";
        imgName = @"searchServer_Opportunity.png";
    }else if ([cellType isEqualToString:@"clues"]) {
        sectionName = @"销售线索";
        imgName = @"searchServer_lead.png";
    }
    
    
    imgIcon.image = [UIImage imageNamed:imgName];
    lableSectionName.text = sectionName;
    lableCountAll.text = allCount;
    
    [headView addSubview:imgIcon];
    [headView addSubview:lableSectionName];
    [headView addSubview:lableCountAll];
    
    return headView;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    NSInteger otherCount =  [[[self.dataSource objectAtIndex:section] objectForKey:@"numberOfRow"] integerValue] -2;
    if (otherCount > 0) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
        footerView.backgroundColor = [UIColor whiteColor];
        UIButton *btnMore = [UIButton buttonWithType:UIButtonTypeCustom];
        btnMore.frame = CGRectMake(kScreen_Width/2, 0, kScreen_Width/2, 40);
        btnMore.titleLabel.font = [UIFont systemFontOfSize:14.0];
        btnMore.titleLabel.textColor = LIGHT_BLUE_COLOR;
        btnMore.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        btnMore.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
        [btnMore setTitleColor:LIGHT_BLUE_COLOR forState:UIControlStateNormal];
        [btnMore addTarget:self action:@selector(searchMoreData:) forControlEvents:UIControlEventTouchUpInside];
        btnMore.tag = section;

        [btnMore setTitle:[NSString stringWithFormat:@"查看其他%ti个结果",otherCount] forState:UIControlStateNormal];
        [footerView addSubview:btnMore];
        
        return footerView;
    }
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_flagFromWhere == 0) {
        
        HomeSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeSearchResultCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"HomeSearchResultCell" owner:self options:nil];
            cell = (HomeSearchResultCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        
//        ///根据不同数据类型的cell  传入type 以作区分标记
//        NSString *cellType = [[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"sectionKey"];
//        NSDictionary *item = [[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"data"] objectAtIndex:indexPath.row];
        
        [cell setCellDetails:[[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"data"] objectAtIndex:indexPath.row] byCellType:[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"sectionKey"]];
        
        return cell;
    }
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_flagFromWhere == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        ///根据不同数据类型的cell  传入type 以作区分标记
        NSString *cellType = [[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"sectionKey"];
        NSDictionary *item = [[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"data"] objectAtIndex:indexPath.row];
        if ([cellType isEqualToString:@"contacts"]) {
            [self gotoContactDetails:item];
        }else if ([cellType isEqualToString:@"customers"]) {
            [self gotoCustomerDetails:item];
        }else if ([cellType isEqualToString:@"opportunitys"]) {
            [self gotoOpportunitysDetails:item];
        }else if ([cellType isEqualToString:@"clues"]) {
            [self gotoCluesDetails:item];
        }
    }
}


///查看更多数据结果
-(void)searchMoreData:(id)sender{
    UIButton *btn = (UIButton *)sender;
    
    ///根据不同数据类型的cell  传入type 以作区分标记
    NSString *cellType = [[self.dataSource objectAtIndex:btn.tag] objectForKey:@"sectionKey"];

    ///更多结果
    HomeSearchOtherResultController *controller = [[HomeSearchOtherResultController alloc] init];
    controller.searchType = cellType;
    controller.searchText = self.searchText;
    controller.searchCount = [[self.dataSource objectAtIndex:btn.tag] objectForKey:@"numberOfRow"];
    [self.navigationController pushViewController:controller animated:YES];
    
}


#pragma mark - 页面跳转
///联系人详情
-(void)gotoContactDetails:(NSDictionary *)item{
    Contact *contact = [NSObject objectOfClass:@"Contact" fromJSON:item];
    // 缓存最近浏览
    [[FMDBManagement sharedFMDBManager] casheCRMRecentlyDataSourceWithName:kTableName_contact item:contact];
    
    ContactDetailViewController *detailController = [[ContactDetailViewController alloc] init];
    detailController.title = @"联系人";
    detailController.id = contact.id;
    [self.navigationController pushViewController:detailController animated:YES];
}

///客户详情
-(void)gotoCustomerDetails:(NSDictionary *)item{
    Customer *customer = [NSObject objectOfClass:@"Contact" fromJSON:item];
    // 缓存最近浏览
    [[FMDBManagement sharedFMDBManager] casheCRMRecentlyDataSourceWithName:kTableName_customer item:customer];
    CustomerDetailViewController *detailController = [[CustomerDetailViewController alloc] init];
    detailController.title = @"客户";
    detailController.id = customer.id;
    [self.navigationController pushViewController:detailController animated:YES];
}


///销售机会
-(void)gotoOpportunitysDetails:(NSDictionary *)item{
    SaleChance *saleChance = [NSObject objectOfClass:@"SaleChance" fromJSON:item];
    // 缓存最近浏览
    [[FMDBManagement sharedFMDBManager] casheCRMRecentlyDataSourceWithName:kTableName_opportunity item:item];
    OpportunityDetailController *detailController = [[OpportunityDetailController alloc] init];
    detailController.title = @"销售机会";
    detailController.id = saleChance.id;
    [self.navigationController pushViewController:detailController animated:YES];
}

///销售线索
-(void)gotoCluesDetails:(NSDictionary *)item{
    Lead *leadItem = [NSObject objectOfClass:@"Lead" fromJSON:item];
    // 缓存最近浏览
    [[FMDBManagement sharedFMDBManager] casheCRMRecentlyDataSourceWithName:kTableName_lead item:leadItem];
    
    LeadDetailViewController *leadDetailController = [[LeadDetailViewController alloc] init];
    leadDetailController.title = @"销售线索";
    leadDetailController.id = leadItem.id;
    [self.navigationController pushViewController:leadDetailController animated:YES];
}


#pragma mark - 根据关键词请求
-(void)sendCmdToSearchByKeyWord{
    [self clearViewNoData];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:self.searchText forKey:@"name"];
    
    NSLog(@"params:%@",params);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_CRM, HOME_SEARCH_ACTION] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@"responseObj:%@",responseObj);
        //字典转模型
        NSDictionary *resultdic = responseObj;
        
        if ([resultdic objectForKey:@"status"] && [[resultdic objectForKey:@"status"] integerValue] == 0) {
            [self analysisJson:resultdic];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self sendCmdToSearchByKeyWord];
            };
            [comRequest loginInBackground];
        }else{
            NSString *desc = @"";
            if ([responseObj objectForKey:@"desc"]) {
                desc = [responseObj safeObjectForKey:@"desc"];
            }
            if ([desc isEqualToString:@""]) {
                desc = @"查询失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        if (!self.dataSource || [self.dataSource count] == 0) {
            [self setViewNoData:@"加载失败"];
        }
        [self.tableview reloadData];
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        [hud hide:YES];
        kShowHUD(NET_ERROR);
        if (!self.dataSource || [self.dataSource count] == 0) {
            [self setViewNoData:@"加载失败"];
        }
    }];
}


///数据解析
- (void)analysisJson:(NSDictionary *)jsonObject {
    
    ///分组数据
    NSMutableDictionary *sectionData;
    
    ///clues
    if ([[jsonObject allKeys] containsObject:@"clues"] && [[jsonObject objectForKey:@"clueCount"] integerValue] > 0) {
        sectionData = [[NSMutableDictionary alloc] init];
        [sectionData setObject:@"clues" forKey: @"sectionKey"];
        [sectionData setObject:@"销售线索" forKey: @"sectionName"];
        [sectionData setObject:[jsonObject objectForKey:@"clueCount"] forKey: @"numberOfRow"];
        NSArray *array = [jsonObject objectForKey:@"clues"];
        [sectionData setObject:array forKey: @"data"];
        
        [self.dataSource addObject:sectionData];
    }
    
    ///contacts
    if ([[jsonObject allKeys] containsObject:@"contacts"] && [[jsonObject objectForKey:@"contactCount"] integerValue] > 0) {
        sectionData = [[NSMutableDictionary alloc] init];
        [sectionData setObject:@"contacts" forKey: @"sectionKey"];
        [sectionData setObject:@"联系人" forKey: @"sectionName"];
        [sectionData setObject:[jsonObject objectForKey:@"contactCount"] forKey: @"numberOfRow"];
        NSArray *array = [jsonObject objectForKey:@"contacts"];
        [sectionData setObject:array forKey: @"data"];
        
        [self.dataSource addObject:sectionData];
    }
    
    ///opportunitys
    if ([[jsonObject allKeys] containsObject:@"opportunitys"] && [[jsonObject objectForKey:@"opportunityCount"] integerValue] > 0) {
        sectionData = [[NSMutableDictionary alloc] init];
        [sectionData setObject:@"opportunitys" forKey: @"sectionKey"];
        [sectionData setObject:@"销售机会" forKey: @"sectionName"];
        [sectionData setObject:[jsonObject objectForKey:@"opportunityCount"] forKey: @"numberOfRow"];
        NSArray *array = [jsonObject objectForKey:@"opportunitys"];
        [sectionData setObject:array forKey: @"data"];
        
        [self.dataSource addObject:sectionData];
    }
    
    ///customers
    if ([[jsonObject allKeys] containsObject:@"customers"] && [[jsonObject objectForKey:@"customerCount"] integerValue] > 0) {
        sectionData = [[NSMutableDictionary alloc] init];
        [sectionData setObject:@"customers" forKey: @"sectionKey"];
        [sectionData setObject:@"客户" forKey: @"sectionName"];
        [sectionData setObject:[jsonObject objectForKey:@"customerCount"] forKey: @"numberOfRow"];
        NSArray *array = [jsonObject objectForKey:@"customers"];
        [sectionData setObject:array forKey: @"data"];
        
        [self.dataSource addObject:sectionData];
    }
    
    NSLog(@"self.dataSource %@", self.dataSource);
    
    if (!self.dataSource || [self.dataSource count] == 0) {
        [self setViewNoData:@"暂无数据"];
    }
    
}


#pragma mark - 没有数据时的view
-(void)setViewNoData:(NSString *)title{
    if (self.commonNoDataView == nil) {
        self.commonNoDataView = [CommonFuntion commonNoDataViewIcon:@"list_empty.png" Title:title optionBtnTitle:@""];
    }
    [self.tableview addSubview:self.commonNoDataView];
}

-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
    }
}



@end
