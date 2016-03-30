//
//  RelatedSearchController.m
//  shangketong
//
//  Created by 蒋 on 15/12/12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "RelatedSearchController.h"
#import "CommonConstant.h"
#import "NSUserDefaults_Cache.h"
#import "CommonNoDataView.h"
#import "CommonFuntion.h"
#import "AFNHttp.h"
//客户 联系人  销售机会  销售线索  市场活动 cell
#import "CustomerTableViewCell.h"
#import "Customer.h"
#import "ContactTableViewCell.h"
#import "Contact.h"
#import "OpportunityTableViewCell.h"
#import "SaleChance.h"
#import "LeadTableViewCell.h"
#import "Lead.h"
#import "ActivityCell.h"
#import "ActivityModel.h"
#import "MJRefresh.h"

#import "ApprovalNewApplyViewController.h"


@interface RelatedSearchController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>{
    ///控制是否显示搜索(XXXX)view
    ///当编辑框不为空时显示
    BOOL isShowHeadSearch;
    NSInteger pageNo;
}
@property (nonatomic, strong) NSString *serachBarText;
@property (nonatomic, strong) NSMutableArray *searchHistoryArr; //搜索历史
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) NSMutableArray *resultArray; //保存原数据类型（json）
@property (nonatomic, assign) BOOL isShow; //标记cell title
@end

@implementation RelatedSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    isShowHeadSearch = FALSE;
    _isShow = FALSE;
    [self initSearchBarView];
    [self initTableview];
    [self initSearchHistory];
    self.title = _titleName;
    
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
///初始化历史数据
-(void)initSearchHistory{
    _searchHistoryArr = [[NSMutableArray alloc] init];
    _resultArray = [NSMutableArray arrayWithCapacity:0];
    
//    NSDictionary *dict = @{@"201" : @"activity",
//                           @"202" : @"lead",
//                           @"203" : @"customer",
//                           @"204" : @"contact",
//                           @"205" : @"opportunity"};
    NSDictionary *dict = @{@"201" : @"activity",
                           @"202" : @"lead",
                           @"203" : @"customer",
                           @"204" : @"contact"};
    NSString *keyString = @"";
    keyString = dict[_businessCode];
    FMDBManagement *fmdb = [[FMDBManagement alloc] init];
    NSArray *readHistoryArray = [NSArray arrayWithArray:[fmdb getCRMRecentlyDataSourceWithName:keyString]];
    //读取缓存
    if (readHistoryArray && [readHistoryArray count] > 0) {
        _isShow = TRUE;
        [_searchHistoryArr removeAllObjects];
        [_resultArray removeAllObjects];
        [_searchHistoryArr  addObjectsFromArray:readHistoryArray];
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
        [array addObjectsFromArray:[self changeModelToDictionary:readHistoryArray]];
        [_resultArray addObjectsFromArray:[self changeModelToDictionary:readHistoryArray]];
    }
    [self notifyHistoryView];
}

-(void)notifyHistoryView{
    [self clearViewNoData];
    if (_searchHistoryArr == nil || [_searchHistoryArr count] == 0) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        [self.tableView setTableFooterView:v];
        [self setViewNoData:0];
    }
}

#pragma mark - 没有数据时的view
-(void)setViewNoData:(NSInteger)type{
    NSString *msg = @"";
    ///搜索历史
    if (type == 0) {
        msg = @"请在搜索框中输入关键字";
    }else if (type == 1){
        msg = @"无结果";
    }
    if (self.commonNoDataView == nil) {
        self.commonNoDataView = [CommonFuntion commonNoDataViewIcon:@"list_empty.png" Title:msg optionBtnTitle:@""];
    }
    [self.tableView addSubview:self.commonNoDataView];
}

-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
        self.commonNoDataView = nil;
        [self.tableView layoutIfNeeded];
    }
}

#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.sectionFooterHeight = 0;
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
    self.tableView.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
    self.tableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    [self.view addSubview:self.tableView];
}
#pragma mark - 初始化searchbar
-(void)initSearchBarView{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 64)];
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(5, 25, kScreen_Width - 50, 30)];
    topView.backgroundColor = [UIColor colorWithRed:200.0f/255 green:200.0f/255 blue:200.0f/255 alpha:1.0f];
    _searchBar.delegate = self;
    _searchBar.placeholder = [NSString stringWithFormat:@"搜索%@", _titleName];
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchBar.keyboardType = UIKeyboardTypeNamePhonePad;
    _searchBar.contentMode = UIViewContentModeLeft;
    [topView addSubview:_searchBar];
    
    for (UIView *view in _searchBar.subviews) {
        // for later iOS7.0(include)
        if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
            [[view.subviews objectAtIndex:0] removeFromSuperview];
            break;
        }
    }
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(kScreen_Width - 50, 20, 50, 40);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [cancelBtn setTitleColor:LIGHT_BLUE_COLOR forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:cancelBtn];
    
    [self.view addSubview:topView];
}
#pragma mark -- Button Action
//取消事件
-(void)cancelBtnAction{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -- tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isShowHeadSearch) {
        return 1;
    }
    if (_searchHistoryArr != nil && [_searchHistoryArr count] > 0) {
        return [_searchHistoryArr count];
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CellIdentifier";
    switch ([_businessCode integerValue]) {
        case 203:
        {
            CustomerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[CustomerTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            }
            Customer *customModel = _searchHistoryArr[indexPath.row];
            [cell configWithModel:customModel];
            return cell;
        }
            break;
        case 204:
        {
            ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[ContactTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            }
            Contact *contactModel = _searchHistoryArr[indexPath.row];
            [cell configWithModel:contactModel];
            return cell;
        }
            break;
        case 205:
        {
            OpportunityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[OpportunityTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            }
            SaleChance *saleModel = _searchHistoryArr[indexPath.row];
            [cell configWithModel:saleModel];
            return cell;
        }
            break;
        case 202:
        {
            LeadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[LeadTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            }
            Lead *leadModel = _searchHistoryArr[indexPath.row];
            [cell configWithModel:leadModel];
            return cell;
        }
            break;
        case 201:
        {
            ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[ActivityCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            }
            ActivityModel *actModel = _searchHistoryArr[indexPath.row];
            [cell configWithItem:actModel isSwipeable:NO];
            return cell;
        }
            break;
        default:
            break;
    }
    return nil;
}
- (NSString *)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    if (_searchHistoryArr != nil && _searchHistoryArr.count > 0 && _isShow) {
        return @"最近浏览";
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (_activityType) {
        case 0:
        {
           return [CustomerTableViewCell cellHeight];
        }
            break;
        case 1:
            return [ContactTableViewCell cellHeight];
            break;
        case 2:
            return [OpportunityTableViewCell cellHeight];
            break;
        case 3:
            return [LeadTableViewCell cellHeight];
            break;
        case 4:
            return [ActivityCell cellHeight];
            break;
            
        default:
            break;
    }
    return 0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    ///审批
    if (self.flagOfRelevance && [self.flagOfRelevance isEqualToString:@"approval"]) {
        NSDictionary *dict = @{@"type" : self.businessCode,
                               @"dataSource" : _resultArray[indexPath.row]};
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"relatedBusiness" object:dict];
        
        for (UIViewController *vcCD in self.navigationController.viewControllers) {
            if ([vcCD isKindOfClass:[ApprovalNewApplyViewController class]]) {
                [self.navigationController popToViewController:vcCD animated:YES];
            }
        }
       
    }else{
        //type类型 客户， 联系人， 销售机会， 销售线索， 市场活动
        NSArray *typeArray = @[@"203", @"204", @"205", @"202", @"201"];
        NSDictionary *dict = @{@"type" : typeArray[_activityType],
                               @"dataSource" : _resultArray[indexPath.row]};
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"relatedBusiness" object:dict];
        
        [self.navigationController popToViewController:self.navigationController.viewControllers[2] animated:YES];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView)
    {
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }
}

#pragma mark -- SearchBar Delegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    //点击return 之后在这里跳转
    _serachBarText = searchBar.text;
    pageNo = 1;
    [self getResultDataSourceFromServer:searchBar.text];
}
#pragma mark --  界面跳转
- (void)getResultDataSourceFromServer:(NSString *)string {
    _isShow = FALSE;
    //客户， 联系人， 销售机会， 销售线索， 市场活动 ------- 接口
    NSArray *actionArray = @[RELATED_CUSTOMER, RELATED_CONTACT, RELATED_SALE_CHANCE, RELATED_SALE_LEAD, RELATED_MARKET];
    //客户 customers   联系人contacts  销售机会saleChances 销售线索saleLeads  市场活动marketDirectorys  -------- json串中对应的不同的key
    NSArray *actionKey = @[@"customers", @"contacts", @"saleChances", @"saleLeads", @"marketDirectorys"];
//    name搜索关键字 pageNo分页 pageSize分页条数
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:string forKey:@"name"];
    [params setObject:@(pageNo) forKey:@"pageNo"];
    [params setObject:@"20" forKey:@"pageSize"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_CRM, actionArray[_activityType]] params:params success:^(id responseObj) {
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            if ([CommonFuntion checkNullForValue:[responseObj objectForKey:actionKey[_activityType]]]) {
                [_searchHistoryArr removeAllObjects];
                [_resultArray removeAllObjects];
                [_resultArray addObjectsFromArray:[responseObj objectForKey:actionKey[_activityType]]];
                [self setupRefresh];
                if (_resultArray.count == 0) {
                    [self clearViewNoData];
                    [self setViewNoData:1];
                } else {
                    [self clearViewNoData];
                    [self changDataSourceForModel:_resultArray];
                    
                }
            }
        } else {
            [_searchHistoryArr removeAllObjects];
            [self setViewNoData:1];
        }
        [self reloadRefeshView];
        [_tableView reloadData];
    } failure:^(NSError *error) {
        [_searchHistoryArr removeAllObjects];
        [self setViewNoData:1];
        [_tableView reloadData];
    }];
}
//字典转model
- (void)changDataSourceForModel:(NSMutableArray *)array {
    if (pageNo == 1) {
        [_searchHistoryArr removeAllObjects];
    }
    if (array.count == 20) {
        pageNo++;
    }
    switch (_activityType) {
        case 0:
        {
            for (NSDictionary *dict in array) {
                Customer *customModel = [NSObject objectOfClass:@"Customer" fromJSON:dict];
                [_searchHistoryArr addObject:customModel];
            }
        }
            break;
        case 1:
        {
            for (NSDictionary *dict in array) {
                Contact *contactModel = [NSObject objectOfClass:@"Contact" fromJSON:dict];
                [_searchHistoryArr addObject:contactModel];
            }
        }
            break;
        case 2:
        {
            for (NSDictionary *dict in array) {
                
                SaleChance *saleModel = [NSObject objectOfClass:@"SaleChance" fromJSON:dict];
                [_searchHistoryArr addObject:saleModel];
            }
        }
            break;
        case 3:
        {
            for (NSDictionary *dict in array) {
                Lead *leadModel = [NSObject objectOfClass:@"Lead" fromJSON:dict];
                [_searchHistoryArr addObject:leadModel];
            }
        }
            break;
        case 4:
        {
            for (NSDictionary *dict in array) {
                ActivityModel *actModel = [NSObject objectOfClass:@"ActivityModel" fromJSON:dict];
                [_searchHistoryArr addObject:actModel];
            }
        }
            break;
        default:
            break;
    }
}
//model转字典
- (NSMutableArray *)changeModelToDictionary:(NSArray *)dataArray {
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
    switch ([_businessCode integerValue]) {
        case 203:
        {
            for (Customer *model in dataArray) {
                NSDictionary *dict = @{@"id" : model.id,
                                       @"name" : model.name};
                [newArray addObject:dict];
            }
            return newArray;
        }
            break;
        case 204:
        {
            for (Contact *model in dataArray) {
                NSDictionary *dict = @{@"id" : model.id,
                                       @"name" : model.name};
                [newArray addObject:dict];
            }
            
            return newArray;
        }
            break;
        case 205:
        {
//            for (SaleChance *model in dataArray) {
//                NSDictionary *dict = @{@"id" : model.id,
//                                       @"name" : model.name};
//                [newArray addObject:dict];
//            }
//            NSMutableArray *saleArray = [NSMutableArray arrayWithCapacity:0];
//            for (NSDictionary *dict in dataArray) {
//                NSDictionary *newdict = @{@"id" : [dict safeObjectForKey:@"id"],
//                                       @"name" : [dict safeObjectForKey:@"name"]};
//                [saleArray addObject:newdict];
//            }
            for (NSDictionary *dict in dataArray) {
                
                SaleChance *saleModel = [NSObject objectOfClass:@"SaleChance" fromJSON:dict];
                [newArray addObject:saleModel];
            }
            return newArray;
        }
            break;
        case 202:
        {
            for (Lead *model in dataArray) {
                NSDictionary *dict = @{@"id" : model.id,
                                       @"name" : model.name};
                [newArray addObject:dict];
            }
            return newArray;
        }
            break;
        case 201:
        {
            for (ActivityModel *model in dataArray) {
                NSDictionary *dict = @{@"id" : model.id,
                                       @"name" : model.name};
                [newArray addObject:dict];
            }
            return newArray;
        }
            break;
        default:
            break;
    }
    return newArray;
}
//集成刷新控件
- (void)setupRefresh
{
    //上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
}

// 结束加载
-(void)reloadRefeshView{
    // 刷新列表
    [self.tableView reloadData];
    [self.tableView footerEndRefreshing];
    [self.tableView headerEndRefreshing];
}
// 上拉
- (void)footerRereshing
{
    NSLog(@"footerRereshing--上拉-->");
    
    if ([self.tableView isHeaderRefreshing]) {
        [self.tableView footerEndRefreshing];
        return;
    }
    [self getResultDataSourceFromServer:_serachBarText];
}
@end
