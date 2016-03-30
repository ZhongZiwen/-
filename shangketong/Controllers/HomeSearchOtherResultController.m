//
//  HomeSearchOtherResultController.m
//  
//
//  Created by sungoin-zjp on 15/12/25.
//
//
#define pageSize 8

#import "HomeSearchOtherResultController.h"
#import "SearchResultCell.h"

#import "ContactDetailViewController.h"
#import "CustomerDetailViewController.h"
#import "OpportunityDetailController.h"
#import "LeadDetailViewController.h"

#import "Contact.h"
#import "Customer.h"
#import "SaleChance.h"
#import "Lead.h"

#import "MJRefresh.h"

@interface HomeSearchOtherResultController ()<UITableViewDataSource,UITableViewDelegate>{
    NSString *curSearchUrl;
    //分页加载
    int listPage,lastPosition;
}

@property (nonatomic, strong) UITableView *tableview;
///数据源
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation HomeSearchOtherResultController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"更多结果";
    self.view.backgroundColor = [UIColor whiteColor];
    [self initData];
    [self initSearchUrlBySearchType];
    [self initTableview];
    
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
    listPage = 1;
    self.dataSource = [[NSMutableArray alloc] init];
}

///初始化请求Url
-(void)initSearchUrlBySearchType{
    if ([self.searchType isEqualToString:@"contacts"]) {
        curSearchUrl =RELATED_CONTACT;
    }else if ([self.searchType isEqualToString:@"customers"]) {
        curSearchUrl = RELATED_CUSTOMER;
    }else if ([self.searchType isEqualToString:@"opportunitys"]) {
        curSearchUrl = RELATED_SALE_CHANCE;
    }else if ([self.searchType isEqualToString:@"clues"]) {
        curSearchUrl = RELATED_SALE_LEAD;
    }
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
    
    [self setupRefresh];
}


#pragma mark -- tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (self.dataSource) {
        return [self.dataSource count];
    }
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
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
    NSString *allCount = [NSString stringWithFormat:@"%@个结果",self.searchCount];
    
    if ([self.searchType isEqualToString:@"contacts"]) {
        sectionName = @"联系人";
        imgName = @"searchServer_contact.png";
    }else if ([self.searchType isEqualToString:@"customers"]) {
        sectionName = @"客户";
        imgName = @"searchServer_account.png";
    }else if ([self.searchType isEqualToString:@"opportunitys"]) {
        sectionName = @"销售机会";
        imgName = @"searchServer_Opportunity.png";
    }else if ([self.searchType isEqualToString:@"clues"]) {
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



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SearchResultCell" owner:self options:nil];
        cell = (SearchResultCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    
    //        ///根据不同数据类型的cell  传入type 以作区分标记
    
    [cell setCellDetails:[self.dataSource objectAtIndex:indexPath.row] byCellType:self.searchType];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ///根据不同数据类型的cell  传入type 以作区分标记

    NSDictionary *item = [self.dataSource objectAtIndex:indexPath.row];
    if ([self.searchType isEqualToString:@"contacts"]) {
        [self gotoContactDetails:item];
    }else if ([self.searchType isEqualToString:@"customers"]) {
        [self gotoCustomerDetails:item];
    }else if ([self.searchType isEqualToString:@"opportunitys"]) {
        [self gotoOpportunitysDetails:item];
    }else if ([self.searchType isEqualToString:@"clues"]) {
        [self gotoCluesDetails:item];
    }
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



#pragma mark - 上拉下拉刷新相关事件
//集成刷新控件
- (void)setupRefresh
{
    //上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableview addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 自动刷新(一进入程序就下拉刷新)
    //    [self.tableviewCampaign headerBeginRefreshing];
}


// 结束加载
-(void)reloadRefeshView{
    // 刷新列表
    [self.tableview reloadData];
    [self.tableview footerEndRefreshing];
}

// 上拉
- (void)footerRereshing
{
    NSLog(@"footerRereshing--上拉-->");
    //上拉加载更多
    [self sendCmdToSearchByKeyWord];
}




#pragma mark - 网络请求
-(void)sendCmdToSearchByKeyWord{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:self.searchText forKey:@"name"];
    [params setObject:[NSNumber numberWithInt:listPage] forKey:@"pageNo"];
    [params setObject:[NSNumber numberWithInt:pageSize] forKey:@"pageSize"];
    
    NSLog(@"params:%@",params);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_CRM, curSearchUrl] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@"responseObj:%@",responseObj);
        //字典转模型
        NSDictionary *resultdic = responseObj;
        
        
        if ([resultdic objectForKey:@"status"] && [[resultdic objectForKey:@"status"] integerValue] == 0) {
            [self setViewRequestSusscess:resultdic];
            
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
        
        [self.tableview reloadData];
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        [hud hide:YES];
        kShowHUD(NET_ERROR);
    }];
}



// 请求成功时数据处理
-(void)setViewRequestSusscess:(NSDictionary *)jsonResponse
{
    
    NSArray *data = nil;
    
    if ([self.searchType isEqualToString:@"contacts"]) {
        data = [jsonResponse objectForKey:@"contacts"];
    }else if ([self.searchType isEqualToString:@"customers"]) {
        data = [jsonResponse objectForKey:@"customers"];
    }else if ([self.searchType isEqualToString:@"opportunitys"]) {
        data = [jsonResponse objectForKey:@"saleChances"];
    }else if ([self.searchType isEqualToString:@"clues"]) {
        data = [jsonResponse objectForKey:@"saleLeads"];
    }
    
    if ([CommonFuntion checkNullForValue:data] && [data count] > 0) {
        ///添加当前页数据到列表中...
        [self.dataSource addObjectsFromArray:data];
        
        ///页码++
        if ([data count] == pageSize) {
            listPage++;
            [self.tableview setFooterHidden:NO];
        }else
        {
            ///隐藏上拉刷新
            [self.tableview setFooterHidden:YES];
        }
        
    }else{
        ///隐藏上拉刷新
        [self.tableview setFooterHidden:YES];
    }
}

@end
