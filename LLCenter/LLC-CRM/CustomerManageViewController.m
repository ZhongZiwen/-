//
//  CustomerManageViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-7-2.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#define pageSize 15

#import "CustomerManageViewController.h"
#import "LLCenterUtility.h"
#import "MJRefresh.h"
#import "LLCCustomerCell.h"
#import "CommonFunc.h"
#import "CommonNoDataView.h"
#import "CommonStaticVar.h"
#import "LLCenterMenuPopView.h"
#import "CustomerFilterViewController.h"
#import "AddCustomerViewController.h"

#import "AFSoundManager.h"
#import "LLCCustomerDetailViewController.h"



@interface CustomerManageViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UISearchDisplayDelegate,UISearchBarDelegate>{
    ///筛选条件
    NSDictionary *filterDictionary;
    
    UITextField *searchTextField;
    
    UISearchBar *searchBar;
    UISearchDisplayController *searchDisplayController;
    
    
    ///正常状态
    NSInteger listPage,lastPosition;
    NSInteger pageCount;
    
    ///处于搜索状态 页码
    NSInteger searchListPage,searchLastPosition;;
    ///搜索结果
    NSMutableArray *arraySearchResults;
    BOOL isSearchingStatus;
    
    ///搜索关键词
    NSString *searchKeyWord;
    
    NSString *customerStateFlag;
    NSString *ownerId;
    
    BOOL isRequestData;
    
    
    int soundDuration;
}

/*
 ///复制到黏贴板
 UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
 pasteboard.string = self.label.text;
 */

@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property (nonatomic, strong) AFSoundPlayback *playback;
@end

@implementation CustomerManageViewController

- (void)loadView
{
    [super loadView];
    
    
    customerStateFlag = @"";
    ownerId = @"";
    isRequestData = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDataFromServivr) name:@"customermanage_info_refreshed" object:nil];
    
    [self addSearchView];
    [self initTableview];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.navigationItem.title = @"CRM";
    [self initData];
    [self notifyDataByViewChange];
    ///获取用户权限
    [self getJurisdictionStatus];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear---->");
    [self addNarBar];

    searchKeyWord = @"";
    searchDisplayController.active = NO;
    [self cancelSearch];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
    self.tabBarController.navigationController.navigationBar.hidden = NO;
}

///页面切换时重新请求数据
-(void)notifyDataByViewChange{
    listPage = 1;
    searchListPage = 1;
    
    [self getDataFromServivr];
}

#pragma mark - Nar Bar
-(void)addNarBar{
    
    UIButton *filterButton=[UIButton buttonWithType:UIButtonTypeCustom];
    filterButton.frame=CGRectMake(0, 0, 21, 20);
    [filterButton setBackgroundImage:[UIImage imageNamed:@"account_filter.png"] forState:UIControlStateNormal];
    [filterButton setBackgroundImage:[UIImage imageNamed:@"account_filter.png"] forState:UIControlStateHighlighted];
    [filterButton addTarget:self action:@selector(leftBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *filterBarButton = [[UIBarButtonItem alloc] initWithCustomView:filterButton];
//    [self.tabBarController.navigationItem setLeftBarButtonItem:filterBarButton];
    
    
    UIButton *addButton=[UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame=CGRectMake(0, 0, 21, 20);
    [addButton setBackgroundImage:[UIImage imageNamed:@"account_create.png"] forState:UIControlStateNormal];
    [addButton setBackgroundImage:[UIImage imageNamed:@"account_create.png"] forState:UIControlStateHighlighted];
    [addButton addTarget:self action:@selector(rightBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithCustomView:addButton];
//    [self.tabBarController.navigationItem setRightBarButtonItem:addBarButton];
    [self.tabBarController.navigationItem setRightBarButtonItems:@[addBarButton,filterBarButton]];
}


///筛选
-(void)leftBarButtonAction{
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    __weak typeof(self) weak_self = self;
    CustomerFilterViewController *controller = [[CustomerFilterViewController alloc] init];
    
    controller.customerStateFlag = customerStateFlag;
    controller.ownerId = ownerId;
    isRequestData = YES;
    controller.RequestDataByFilter = ^(NSString *stateflagId,NSString *ownerid,BOOL isRequest){
        isRequestData = isRequest;
        customerStateFlag = stateflagId;
        ownerId = ownerid;
        isSearchingStatus = FALSE;
        listPage = 1;
        if (self.dataSource) {
            [self.dataSource removeAllObjects];
        }
        if (self.dataSourceShow) {
            [self.dataSourceShow removeAllObjects];
        }
        
        if (arraySearchResults) {
            [arraySearchResults removeAllObjects];
        }
        [weak_self.tableviewCustomer reloadData];
        [weak_self getDataFromServivr];
    };
    
    [self.tabBarController.navigationController pushViewController:controller animated:YES];
}


///新增客户
-(void)rightBarButtonAction{
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    __weak typeof(self) weak_self = self;
    
    AddCustomerViewController *controller = [[AddCustomerViewController alloc] init];
    
    
    isRequestData = YES;
    controller.NotifyCustomerList = ^(){
        isRequestData = NO;
        isSearchingStatus = FALSE;
        listPage = 1;
        if (weak_self.dataSource) {
            [weak_self.dataSource removeAllObjects];
        }
        if (weak_self.dataSourceShow) {
            [weak_self.dataSourceShow removeAllObjects];
        }
        
        if (arraySearchResults) {
            [arraySearchResults removeAllObjects];
        }
        [weak_self.tableviewCustomer reloadData];
        [weak_self getDataFromServivr];
    };
    
   
    [self.tabBarController.navigationController pushViewController:controller animated:YES];
}


#pragma mark - 添加搜索栏
-(void)addTableHeadSearchView{
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH,44)];
    searchBar.placeholder = @"搜索";
    searchBar.translucent = YES;
    searchBar.backgroundColor = LLC_COLOR_SEARCHBAR_BG;
    searchBar.delegate = self;
    [searchBar sizeToFit];
    //
    
    self.tableviewCustomer.tableHeaderView = searchBar;
    
    //
    // 用 searchbar 初始化 SearchDisplayController
    // 并把 searchDisplayController 和当前 controller 关联起来
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.delegate = self;
    
    ///去除多余得分割线
    UIView *vs = [[UIView alloc] initWithFrame:CGRectZero];
    [searchDisplayController.searchResultsTableView setTableFooterView:vs];
}


#pragma mark - add top searchview
-(void)addSearchView{
    
    /*
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 50)];
    
    UIImageView *iconSearch = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 19, 21)];
    iconSearch.image = [UIImage imageNamed:@"search_more_icon.png"];
    
    [headView addSubview:iconSearch];
    
    searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(45, 0, DEVICE_BOUNDS_WIDTH-45, 50)];
    searchTextField.borderStyle = UITextBorderStyleRoundedRect;
    searchTextField.font = [UIFont systemFontOfSize:14.0];
    searchTextField.placeholder = @"搜索";
    searchTextField.returnKeyType = UIReturnKeySearch;
    searchTextField.borderStyle = UITextBorderStyleNone;
    searchTextField.clearButtonMode = UITextFieldViewModeAlways;
    //设置为无文字就灰色不可点
    //    searchTextField.enablesReturnKeyAutomatically = YES;
    searchTextField.delegate = self;
    [searchTextField addTarget:self action:@selector(textValueChange:) forControlEvents:UIControlEventEditingChanged];
    
    [headView addSubview:searchTextField];
    
    
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 49, DEVICE_BOUNDS_WIDTH, 1)];
    line.image = [UIImage imageNamed:@"line.png"];
    
    [headView addSubview:line];
    
    [self.view addSubview:headView];
    
    
    */
}


#pragma mark - 初始化tablview
-(void)initTableview{
    
    NSInteger height = 0;
    if (DEVICE_IS_IPHONE6) {
        
    }
    height = 64+44;
    
    self.tableviewCustomer = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-height) style:UITableViewStylePlain];
    self.tableviewCustomer.delegate = self;
    self.tableviewCustomer.dataSource = self;
    self.tableviewCustomer.sectionFooterHeight = 0;
    self.tableviewCustomer.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableviewCustomer];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewCustomer setTableFooterView:v];
    
    [self addTableHeadSearchView];
    
    [self setupRefresh];
}


-(void)addNodataView{
    NSLog(@"add  no data view");
    
    
    
}


#pragma mark - 初始化数据
- (void)initData {
    ///展示的数据
    self.dataSourceShow = [[NSMutableArray alloc] init];
    ///存储正常加载结果
    self.dataSource = [[NSMutableArray alloc] init];
    listPage = 1;
    lastPosition = 0;
    ///存储搜索结果
    isSearchingStatus = FALSE;
    arraySearchResults = [[NSMutableArray alloc] init];
    searchListPage = 1;
    searchLastPosition = 0;
}

#pragma mark - 获取数据
-(void)getDataFromServivr{
    [self clearViewNoData];
    /*
     customerName
     companyId
     ownerId
     numPerPage
     currentPage
     */
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [params setValue:searchKeyWord forKey:@"customerName"];
    [params setValue:customerStateFlag forKey:@"customerFlagId"];
    [params setValue:ownerId forKey:@"ownerId"];
    
    [params setObject:[NSNumber numberWithInteger:pageSize] forKey:@"numPerPage"];
    if (isSearchingStatus) {
        NSLog(@"搜索状态下");
        [params setObject:[NSNumber numberWithInteger:searchListPage] forKey:@"currentPage"];
    }else{
        NSLog(@"正常状态下");
        [params setObject:[NSNumber numberWithInteger:listPage] forKey:@"currentPage"];
    }
    
    
    NSLog(@"params:%@",params);
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_CUSTOMER_LIST_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"jsonResponse:%@",[jsonResponse description]);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [self setViewRequestSusscess:jsonResponse];
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getDataFromServivr];
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
        
        NSLog(@"------>:%@",self.dataSourceShow);
        [self reloadRefeshView];
        [searchDisplayController.searchResultsTableView reloadData];
        
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        [self reloadRefeshView];
        [searchDisplayController.searchResultsTableView reloadData];
        NSLog(@"%@",error);
        
        if (isSearchingStatus) {
            NSLog(@"搜索状态下");
            if (searchListPage == 1 && [arraySearchResults count] == 0) {
                [self setViewNoData:@"加载失败"];
            }
        }else{
            NSLog(@"正常状态下");
            if (listPage == 1 && [self.dataSourceShow count] == 0) {
                [self setViewNoData:@"加载失败"];
            }
        }
    }];
}

// 请求成功时数据处理
-(void)setViewRequestSusscess:(NSDictionary *)result
{
    if (isSearchingStatus) {
        if (searchListPage == 1) {
            if (arraySearchResults) {
                [arraySearchResults removeAllObjects];
            }
        }
    }else{
        if (listPage == 1) {
            if (self.dataSource) {
                [self.dataSource removeAllObjects];
            }
            if (self.dataSourceShow) {
                [self.dataSourceShow removeAllObjects];
            }
        }
    }
    
    
    id data = [[result objectForKey:@"resultMap"] objectForKey:@"data"];
    NSLog(@"data:%@",data);
    if ([data respondsToSelector:@selector(count)] && [data count] > 0) {
        
        if (isSearchingStatus) {
            NSLog(@"搜索状态下");
            [self fillSearchDataSource:data];
            searchLastPosition = arraySearchResults.count;
        }else{
            NSLog(@"正常状态下");
            [self fillDataSource:data];
            lastPosition = self.dataSource.count;
        }
        
        ///页码++
        if ([data count] == pageSize) {
            if (isSearchingStatus) {
                NSLog(@"搜索状态下++");
                searchListPage++;
                [searchDisplayController.searchResultsTableView setFooterHidden:NO];
            }else{
                NSLog(@"正常状态下++");
                listPage++;
                [self.tableviewCustomer setFooterHidden:NO];
            }
            
        }else
        {
            ///隐藏上拉刷新
            if (isSearchingStatus) {
                [searchDisplayController.searchResultsTableView setFooterHidden:YES];
            }else{
                [self.tableviewCustomer setFooterHidden:YES];
            }
        }
        
    }
    else {
        NSLog(@"无数据");
        ///隐藏上拉刷新
        if (isSearchingStatus) {
            [searchDisplayController.searchResultsTableView setFooterHidden:YES];
        }else{
            [self.tableviewCustomer setFooterHidden:YES];
        }
        
        if (isSearchingStatus) {
            NSLog(@"搜索状态下");
            if (searchListPage == 1 && [arraySearchResults count] == 0) {
                [self setViewNoData:@"暂无客户"];
            }
        }else{
            NSLog(@"正常状态下");
            if (listPage == 1 && [self.dataSourceShow count] == 0) {
                [self setViewNoData:@"暂无客户"];
            }
        }
    }
}


#pragma mark - 没有数据时的view
-(void)setViewNoData:(NSString *)title{
    if (self.commonNoDataView == nil) {
        self.commonNoDataView = [CommonFunc commonNoDataViewIcon:@"list_empty.png" Title:title optionBtnTitle:@""];
    }
    
    [self.tableviewCustomer addSubview:self.commonNoDataView];
}

-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
    }
}


/*
 {
 "CUSTOMER_ID" = "b1759cb9-92bd-4306-be95-46e072eecd57";
 "CUSTOMER_NAME" = 89897;
 "LINKMAN_ID" = "52b76ccf-ff58-4fa6-ba98-cc253ba15d17";
 "LINKMAN_NAME" = asdfasdfads;
 NUM = 15;
 "OWNER_ID" = "bd31eecd-2382-4f18-8df4-dc2967f491ed";
 }
 */

- (void)fillDataSource:(NSArray*)data {
    
//    for (int i = 0; i < [data count]; i++) {
//        [self.dataSource addObject:[data objectAtIndex:i]];
//    }
    
    [self.dataSource addObjectsFromArray:data];
    [self.dataSourceShow removeAllObjects];
    [self.dataSourceShow addObjectsFromArray:self.dataSource];
    
    [self.tableviewCustomer reloadData];
    
    
    if (listPage > 1 && lastPosition <= self.dataSource.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastPosition-1 inSection:0];
        [self.tableviewCustomer scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
    else {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableviewCustomer scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}

- (void)fillSearchDataSource:(NSArray*)data {
    
//    for (int i = 0; i < [data count]; i++) {
//        [arraySearchResults addObject:[data objectAtIndex:i]];
//    }
    
    [arraySearchResults addObjectsFromArray:data];
    
    [self.tableviewCustomer reloadData];
    [searchDisplayController.searchResultsTableView reloadData];
    
    /*
    if (searchListPage > 1 && searchListPage <= arraySearchResults.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:searchLastPosition-1 inSection:0];
        [self.tableviewCustomer scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
    else {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableviewCustomer scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
     */
}



#pragma mark - 上拉下拉刷新相关事件
//集成刷新控件
- (void)setupRefresh
{
    NSString *dateKey = @"crmcustomer";
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [self.tableviewCustomer addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:dateKey];
    //上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableviewCustomer addFooterWithTarget:self action:@selector(footerRereshing)];
    
    
    
    [searchDisplayController.searchResultsTableView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:dateKey];
    [searchDisplayController.searchResultsTableView addFooterWithTarget:self action:@selector(footerRereshing)];
    
    
    // 自动刷新(一进入程序就下拉刷新)
    //    [self.tableviewCampaign headerBeginRefreshing];
}


// 结束加载
-(void)reloadRefeshView{
    // 刷新列表
    [self.tableviewCustomer reloadData];
    [self.tableviewCustomer footerEndRefreshing];
    [self.tableviewCustomer headerEndRefreshing];
    
    
    [searchDisplayController.searchResultsTableView reloadData];
    [searchDisplayController.searchResultsTableView footerEndRefreshing];
    [searchDisplayController.searchResultsTableView headerEndRefreshing];
}

// 下拉
- (void)headerRereshing
{
    NSLog(@"headerRereshing--下拉-->");
    
    if ([self.tableviewCustomer isFooterRefreshing]) {
        [self.tableviewCustomer headerEndRefreshing];
        return;
    }
    if (isSearchingStatus) {
        NSLog(@"搜索状态下拉");
        if ([searchDisplayController.searchResultsTableView isFooterRefreshing]) {
            [searchDisplayController.searchResultsTableView headerEndRefreshing];
            return;
        }
        searchListPage = 1;
    }else{
        NSLog(@"正常状态下拉");
        
        if ([self.tableviewCustomer isFooterRefreshing]) {
            [self.tableviewCustomer headerEndRefreshing];
            return;
        }
        
        
        //下拉刷新
        listPage = 1;

    }
    
    [self getDataFromServivr];
}

// 上拉
- (void)footerRereshing
{
    NSLog(@"footerRereshing--上拉-->");
    
    if (isSearchingStatus) {
         NSLog(@"搜索状态上拉");
        if ([searchDisplayController.searchResultsTableView isHeaderRefreshing]) {
            [searchDisplayController.searchResultsTableView footerEndRefreshing];
            return;
        }
    }else{
        NSLog(@"正常状态上拉");
        if ([self.tableviewCustomer isHeaderRefreshing]) {
            [self.tableviewCustomer footerEndRefreshing];
            return;
        }
    }
    
    [self getDataFromServivr];
}


#pragma mark - tableview delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableviewCustomer) {
        if (self.dataSourceShow) {
            return [self.dataSourceShow count];
        }
    }else{
        if (arraySearchResults) {
            return [arraySearchResults count];
        }
    }
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LLCCustomerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LLCCustomerCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"LLCCustomerCell" owner:self options:nil];
        cell = (LLCCustomerCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    [cell setCellFrame];
    
    if (tableView == self.tableviewCustomer) {
        [cell setCellDetails:[self.dataSourceShow objectAtIndex:indexPath.row]];
    }else{
        [cell setCellDetails:[arraySearchResults objectAtIndex:indexPath.row]];
    }
    
    
    /*
    if (isSearchingStatus) {
        cell.labelName.text = [NSString stringWithFormat:@"s搜索姓名:%ti",indexPath.row];
    }else{
        cell.labelName.text = [NSString stringWithFormat:@"正常姓名:%ti",indexPath.row];
    }
     */
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    LLCCustomerDetailViewController *controller = [[LLCCustomerDetailViewController alloc] init];
    
    NSDictionary *item;
    if (tableView == self.tableviewCustomer) {
        item = [self.dataSourceShow objectAtIndex:indexPath.row];
    }else{
        item = [arraySearchResults objectAtIndex:indexPath.row];
    }
    
    controller.customerId = [item safeObjectForKey:@"CUSTOMER_ID"];
    
    __weak typeof(self) weak_self = self;
    controller.NotifyCustomerList = ^(){
        isRequestData = NO;
        isSearchingStatus = FALSE;
        listPage = 1;
        if (weak_self.dataSource) {
            [weak_self.dataSource removeAllObjects];
        }
        if (weak_self.dataSourceShow) {
            [weak_self.dataSourceShow removeAllObjects];
        }
        
        if (arraySearchResults) {
            [arraySearchResults removeAllObjects];
        }
        [weak_self.tableviewCustomer reloadData];
        [weak_self getDataFromServivr];
    };
    
    [self.tabBarController.navigationController pushViewController:controller animated:YES];
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    if (scrollView == self.tableviewCustomer) {
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
//    }
}

#pragma mark - 搜索相关
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    /*
    [textField resignFirstResponder];
    NSString *strSearch = textField.text;
    NSLog(@"strSearch:%@",strSearch);
    if (![[strSearch stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        isSearchingStatus = TRUE;
//        [self removeHeadRefreshView];
        if (self.dataSourceShow) {
            [self.dataSourceShow removeAllObjects];
        }
        [self.tableviewCustomer reloadData];
        ///搜索网络数据
        searchListPage = 1;
        searchKeyWord = strSearch;
        [self getDataFromServivr];
    }
    ///
    return YES;
    */
    return YES;
}

-(void)textValueChange:(UITextField *)textField {
    /*
    NSString *strT = textField.text;
    NSLog(@"textValueChange strT:%@",strT);
    searchKeyWord = strT;
    if ([strT isEqualToString:@""]) {
        [self clearViewNoData];
        if (self.dataSourceShow) {
            [self.dataSourceShow removeAllObjects];
        }
        if(self.dataSource){
            [self.dataSourceShow addObjectsFromArray:self.dataSource];
        }
        isSearchingStatus = FALSE;
//        [self addHeadRefreshView];
        [self.tableviewCustomer reloadData];
        
        if (self.dataSourceShow && [self.dataSourceShow count] > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableviewCustomer scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        }
    }
    */
}



#pragma mark - searchbar delegate
-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
    NSLog(@"searchDisplayControllerWillEndSearch");
    self.tabBarController.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = NO;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar1
{
    NSLog(@"searchBarTextDidBeginEditing");
    self.tabBarController.tabBar.hidden = YES;
    self.tabBarController.navigationController.navigationBar.hidden = YES;
    searchBar.showsCancelButton = YES;
    //    NSLog(@"subview count:%li",(unsigned long)[self.searchBar.subviews count]);
    for(id cc in [searchBar.subviews[0] subviews])
        //    for(id cc in [self.searchBar subviews])
    {
        //        NSLog(@"subview:%@",cc);
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            [btn setTitle:@"取消"  forState:UIControlStateNormal];
//            [btn setTitleColor:COLOR_LIGHT_BLUE forState:UIControlStateNormal];
        }
        
        if([cc isKindOfClass:[UITextField class]])
        {
            UITextField *txt = (UITextField *)cc;
            txt.placeholder = @"搜索";
        }
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"searchBarCancelButtonClicked");
    self.tabBarController.tabBar.hidden = NO;
     self.tabBarController.navigationController.navigationBar.hidden = NO;
    searchKeyWord = @"";
    [self cancelSearch];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar2{
    NSLog(@"searchBarSearchButtonClicked");
    NSString *strSearch = searchBar2.text;
    NSLog(@"strSearch:%@",strSearch);
    if (![[strSearch stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        isSearchingStatus = TRUE;
        //        [self removeHeadRefreshView];
        if (arraySearchResults) {
            [arraySearchResults removeAllObjects];
        }
        
        ///搜索网络数据
        searchListPage = 1;
        searchKeyWord = strSearch;
        [self getDataFromServivr];
        [self.tableviewCustomer reloadData];
        [searchDisplayController.searchResultsTableView reloadData];
    }
}


#pragma mark - 搜索相关
- (void)searchBar:(UISearchBar *)searchBar2 textDidChange:(NSString *)searchText;
{
    NSLog(@"searchText:%@",searchText);
    searchKeyWord = searchText;
    if ([searchKeyWord isEqualToString:@""]) {
        [self cancelSearch];
    }
}


-(void)cancelSearch{
    NSLog(@"cancelSearch---->");
    [self clearViewNoData];
    /*
    if (self.dataSourceShow) {
        [self.dataSourceShow removeAllObjects];
    }
    if(self.dataSource){
        [self.dataSourceShow addObjectsFromArray:self.dataSource];
    }
    */
    
    [arraySearchResults removeAllObjects];
    isSearchingStatus = FALSE;
    //        [self addHeadRefreshView];
    [searchDisplayController.searchResultsTableView reloadData];
    [self.tableviewCustomer reloadData];
    
    
    if (self.dataSourceShow && [self.dataSourceShow count] > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableviewCustomer scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}





#pragma mark - 播放音频
-(void)playSoundByUrl:(NSString *)urlSound{
    if (_playback) {
        [_playback pause];
        _playback = nil;
        
    }
    
    __weak typeof(self) weak_self = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AFSoundItem *item = [[AFSoundItem alloc] initWithStreamingURL:[NSURL URLWithString:urlSound]];
        
        _playback = [[AFSoundPlayback alloc] initWithItem:item];
        [_playback play];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_playback listenFeedbackUpdatesWithBlock:^(AFSoundItem *item) {
                NSLog(@"Item duration: %ld - time elapsed: %ld", (long)item.duration, (long)item.timePlayed);
            } andFinishedBlock:^(void){
                NSLog(@"andFinishedBlock");
            }];
        });
    });
}


#pragma mark - 获取用户开通权限状态
-(void)getJurisdictionStatus{
    
    [CommonStaticVar setIvrStatus:0];
    [CommonStaticVar setRingStatus:0];
    [CommonStaticVar setRingtoneStatus:0];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_IVR_STATUS_ACTION] params:params success:^(id jsonResponse) {
        
        
        NSLog(@"获取用户开通权限状态:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            if ([jsonResponse objectForKey:@"resultMap"]) {
                ///ivrStatus(ivr是否开通：1-是，0-否)
                ///ringStatus(彩铃是否开通：1-是，0-否)
                ///ringtoneStatus (炫铃是否开通：1-是，0-否)
                /*
                 resultMap =     {
                 ivrStatus = 1;
                 ringStatus = 0;
                 };
                 */
                
                NSDictionary *resultMap = [jsonResponse objectForKey:@"resultMap"];
                
                ///ivr是否开通：1-是，0-否
                NSInteger  ivrStatus = 0;
                if ([resultMap objectForKey:@"ivrStatus"]) {
                    ivrStatus = [[resultMap safeObjectForKey:@"ivrStatus"] integerValue];
                }
                [CommonStaticVar setIvrStatus:ivrStatus];
                
                ///彩铃是否开通：1-是，0-否
                NSInteger ringStatus = 0;
                if ([resultMap objectForKey:@"ringStatus"]) {
                    ringStatus = [[resultMap safeObjectForKey:@"ringStatus"] integerValue];
                }
                [CommonStaticVar setRingStatus:ringStatus];
                
                ///炫铃是否开通：1-是，0-否
                NSInteger ringtoneStatus = 0;
                if ([resultMap objectForKey:@"ringtoneStatus"]) {
                    ringtoneStatus = [[resultMap safeObjectForKey:@"ringtoneStatus"] integerValue];
                }
                [CommonStaticVar setRingtoneStatus:ringtoneStatus];
                
            }else{
                NSLog(@"data------>:<null>");
                
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getJurisdictionStatus];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"获取失败";
            }
        }
        
    } failure:^(NSError *error) {
        NSLog(@"获取用户开通权限状态 error:%@",error);
    }];
    
}


@end
