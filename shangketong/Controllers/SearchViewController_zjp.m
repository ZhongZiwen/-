//
//  SearchViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#define TAG_DEFAULT @"default"
#define TAG_NO_SEARCH_DATA @"nodata"

#import "SearchViewController_zjp.h"
#import "CommonFuntion.h"
#import "CommonModuleFuntion.h"
#import "CommonConstant.h"
#import "SearchResultViewController.h"
#import "CommonDetailViewController.h"
#import "SearchHistoryCell.h"
#import "CampaignCell.h"
#import "ContactCell.h"
#import "CustomerSearchCell.h"
#import "SaleLeadSearchCell.h"
#import "SaleOpportunityCell.h"

@interface SearchViewController_zjp ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UISearchBarDelegate,SWTableViewCellDelegate,ContactCellDelegate,CustomerCellDelegate,SaleOpportunityCellDelegate>{
    UITextField *searchTextField;
    UISearchBar *searchBar;
    //    UISearchDisplayController *searchDisplayController;
    
    ///搜索结果
    NSMutableArray *arraySearchResults;
    NSArray *arrayShow;
    
    ///是否显示headview
    BOOL isShowHeadView;
    
    ///搜索网络数据
    UIButton *btnSearchServiceData;
    
    
    ///最近搜索历史
    NSMutableArray *arrayLatelySearch;
    
    ///销售机会  单位
    NSString *currencyUnit;
}

@end

@implementation SearchViewController_zjp


- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = VIEW_BG_COLOR;
    
    [self initSearchBarView];
    [self initTableview];
    [self addTouchesEvent];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self readTestData];
    [self addTableViewHeadView];
    [self addTableViewFootView];
    
    [self.tableviewSearch reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [searchBar becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


#pragma mark - 初始化数据
-(void)initData{
    ///默认状态
    self.typeSearchStatus = TAG_DEFAULT;
    isShowHeadView = YES;
    self.arraySearch = [[NSMutableArray alloc] init];
    arraySearchResults = [[NSMutableArray alloc] init];
    arrayLatelySearch = [[NSMutableArray alloc] init];
}

#pragma mark - 读取测试数据
-(void)readTestData{
    if ([self.typeSearchStatus isEqualToString:TAG_DEFAULT]) {
        
    }
    ///加载默认搜索历史
    [self addTestSearchData];
    arrayShow = arrayLatelySearch;
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
    }else if ([self.typeFromView isEqualToString:@"SMSContactSearchViewController"]) {
        ///群发短信联系人
        /*
        id jsondata = [CommonFuntion readJsonFile:@"contact-list-data"];
        NSLog(@"jsondata:%@",jsondata);
        
        NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"contacts"];
        [self.arraySearch addObjectsFromArray:array];
         */
    }
    else if ([self.typeFromView isEqualToString:@"CustomerViewController"]) {
        ///客户
        id jsondata = [CommonFuntion readJsonFile:@"customer-list-data"];
        NSLog(@"jsondata:%@",jsondata);
        
        NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"accounts"];
        [self.arraySearch addObjectsFromArray:array];
    }else if ([self.typeFromView isEqualToString:@"SMSCustomerSearchViewController"]) {
        ///群发短信客户
        /*
        id jsondata = [CommonFuntion readJsonFile:@"customer-list-data"];
        NSLog(@"jsondata:%@",jsondata);
        
        NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"accounts"];
        [self.arraySearch addObjectsFromArray:array];
         */
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

///最近搜索数据
-(void)addTestSearchData{
    if ([self.typeFromView isEqualToString:@"SMSContactSearchViewController"]) {
        ///群发短信联系人
        id jsondata = [CommonFuntion readJsonFile:@"contact-list-data"];
        NSLog(@"jsondata:%@",jsondata);
        
        NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"contacts"];
        [arrayLatelySearch addObjectsFromArray:array];
    }else if ([self.typeFromView isEqualToString:@"SMSCustomerSearchViewController"]) {
        ///群发短信客户
        id jsondata = [CommonFuntion readJsonFile:@"customer-list-data"];
        NSLog(@"jsondata:%@",jsondata);
        
        NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"accounts"];
        [arrayLatelySearch addObjectsFromArray:array];
    }
    else{
        NSMutableDictionary *item;
        for (int i=0; i<30; i++) {
            item = [[NSMutableDictionary alloc] init];
            [item setObject:[NSString stringWithFormat:@"searchStr:%i",i] forKey:@"name"];
            [arrayLatelySearch addObject:item];
        }
    }
}


#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewSearch = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) style:UITableViewStylePlain];
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
    }else if ([self.typeFromView isEqualToString:@"CustomerViewController"]) {
    }
}

#pragma mark - tableview 添加headview
-(void)addTableViewHeadView{
    if (arrayLatelySearch == nil || [arrayLatelySearch count] == 0) {
        return;
    }
    NSString *lastSearchStr = @"";
    if (arrayLatelySearch) {
        lastSearchStr = [[arrayLatelySearch objectAtIndex:0] objectForKey:@"name"];
    }
    NSLog(@"lastSearchStr:%@",lastSearchStr);
    
    if ([self.typeSearchStatus isEqualToString:TAG_DEFAULT] && ![self.typeFromView isEqualToString:@"SMSContactSearchViewController"] && ![self.typeFromView isEqualToString:@"SMSCustomerSearchViewController"]) {
        UIButton *btnLastSearch = [UIButton buttonWithType:UIButtonTypeCustom];
        btnLastSearch.frame = CGRectMake(0, 0, kScreen_Width, 40);
        btnLastSearch.backgroundColor = [UIColor whiteColor];
        btnLastSearch.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btnLastSearch.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        [btnLastSearch setTitle:[NSString stringWithFormat:@"查找“%@”",lastSearchStr] forState:UIControlStateNormal];
        [btnLastSearch setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        btnLastSearch.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [btnLastSearch addTarget:self action:@selector(searchByLastSearchStr) forControlEvents:UIControlEventTouchUpInside];
        self.tableviewSearch.tableHeaderView = btnLastSearch;
    }else{
    }
}

///根据上一次搜索词进行搜索
-(void)searchByLastSearchStr{
    NSLog(@"searchByLastSearchStr--->");
    if (arrayLatelySearch == nil || [arrayLatelySearch count] == 0) {
        return;
    }
    NSString *lastSearchStr = @"";
    if (arrayLatelySearch) {
        lastSearchStr = [[arrayLatelySearch objectAtIndex:0] objectForKey:@"name"];
    }
    searchBar.text = lastSearchStr;
    [self searchByKeyWord:lastSearchStr];
    [self.tableviewSearch reloadData];
    ///滑动到最顶部
    [self.tableviewSearch setContentOffset:CGPointZero animated:NO];
}

#pragma mark - tableview 添加footview
-(void)addTableViewFootView{
    if (arrayLatelySearch == nil || [arrayLatelySearch count] == 0) {
        return;
    }
    
    if ([self.typeSearchStatus isEqualToString:TAG_DEFAULT] && ![self.typeFromView isEqualToString:@"SMSContactSearchViewController"] && ![self.typeFromView isEqualToString:@"SMSCustomerSearchViewController"]) {
        UIButton *btnLastSearch = [UIButton buttonWithType:UIButtonTypeCustom];
        btnLastSearch.frame = CGRectMake(0, 0, kScreen_Width, 40);
        [btnLastSearch setTitle:@"清空搜索历史" forState:UIControlStateNormal];
        [btnLastSearch setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        btnLastSearch.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [btnLastSearch addTarget:self action:@selector(clearLocalSearchHistory) forControlEvents:UIControlEventTouchUpInside];
        self.tableviewSearch.tableFooterView = btnLastSearch;
    }else{
    }
}

///清空搜索历史  清除本地缓存
-(void)clearLocalSearchHistory{
    NSLog(@"clearLocalSearchHistory--->");
}

#pragma mark - 初始化searchbar
-(void)initSearchBarView{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
    headView.backgroundColor = [UIColor colorWithHexString:@"0x28303b"];
    headView.alpha = 0.9;
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(5, 25, self.view.bounds.size.width-50, 30)];
    searchBar.delegate = self;
    searchBar.placeholder = @"搜索";
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.keyboardType = UIKeyboardTypeNamePhonePad;
    searchBar.contentMode = UIViewContentModeLeft;
    //    [self.searchbar setBarTintColor:[UIColor clearColor]];
    //    self.searchbar.searchBarStyle = UISearchBarStyleMinimal;
    [headView addSubview:searchBar];
    
    
    for (UIView *view in searchBar.subviews) {
        // for later iOS7.0(include)
        if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
            [[view.subviews objectAtIndex:0] removeFromSuperview];
            break;
        }
    }
    
    
    
    /*
    btnSearchServiceData = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSearchServiceData.frame = CGRectMake(0,0 , kScreen_Width, 40);
    btnSearchServiceData.backgroundColor = [UIColor grayColor];
    [btnSearchServiceData setTitle:@"点击搜索网络数据" forState:UIControlStateNormal];
    [btnSearchServiceData setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btnSearchServiceData addTarget:self action:@selector(searchSeviceData) forControlEvents:UIControlEventTouchUpInside];
    
    searchBar.inputAccessoryView = btnSearchServiceData;
    */
    
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCancel.frame = CGRectMake(self.view.bounds.size.width-50, 20, 50, 40);
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(cancelEvent) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:btnCancel];
    
    [self.view addSubview:headView];
}


///取消事件
///
-(void)cancelEvent{
    //    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.tableviewSearch)
    {
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableviewSearch)
    {
        ///去掉UItableview headerview黏性
        CGFloat sectionHeaderHeight = 25.0;
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if ([self.typeSearchStatus isEqualToString:TAG_DEFAULT]) {
        if (arrayLatelySearch == nil  || [arrayLatelySearch count] == 0) {
            return nil;
        }
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 25)];
        headView.backgroundColor = [UIColor colorWithRed:235.0f/255 green:235.0f/255 blue:235.0f/255 alpha:1.0f];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 150, 25)];
        label.text = @"";
        label.font = [UIFont systemFontOfSize:14.0];
        [headView addSubview:label];
        if ([self.typeFromView isEqualToString:@"SMSContactSearchViewController"] || [self.typeFromView isEqualToString:@"SMSCustomerSearchViewController"]) {
            label.text = @"最近浏览";
        }else{
            label.text = @"搜索历史";
        }
        
        return headView;
    }else if (arrayShow == nil || [arrayShow count] == 0){
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 25)];
        headView.backgroundColor = [UIColor clearColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 250, 25)];
        label.text = @"";
        label.font = [UIFont systemFontOfSize:12.0];
        [headView addSubview:label];
        label.text = @"本地数据中无匹配数据";
        return headView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([self.typeSearchStatus isEqualToString:TAG_DEFAULT]) {
        if (arrayLatelySearch == nil  || [arrayLatelySearch count] == 0) {
            return 1.0;
        }
        return 25.0;
    }else if (arrayShow == nil || [arrayShow count] == 0){
        return 25.0;
    }
    return 1.;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (arrayShow) {
        return [arrayShow count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.typeSearchStatus isEqualToString:TAG_DEFAULT] && [self.typeFromView isEqualToString:@"SaleLeadViewController"]) {
        ///销售线索
        return 70.0;
    }else if ([self.typeFromView isEqualToString:@"SalesOpportunityViewController"]) {
        ///销售机会
        return 60.0;
    }
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ///默认 群发短信客户
    if (([self.typeSearchStatus isEqualToString:TAG_DEFAULT] && ![self.typeFromView isEqualToString:@"SMSContactSearchViewController"]) || [self.typeFromView isEqualToString:@"SMSCustomerSearchViewController"]) {
        SearchHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchHistoryCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SearchHistoryCell" owner:self options:nil];
            cell = (SearchHistoryCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        
        [cell setCellFrame];
        [cell setCellDetails:[arrayShow objectAtIndex:indexPath.row]];
        
        return cell;
    }else if ([self.typeSearchStatus isEqualToString:@"CampaignViewController"]) {
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
        [cell setLeftAndRightBtn:[arrayShow objectAtIndex:indexPath.row]];
        [cell setCellDetails:[arrayShow objectAtIndex:indexPath.row]];
        return cell;
    }else if ([self.typeFromView isEqualToString:@"ContactViewController"] || [self.typeFromView isEqualToString:@"SMSContactSearchViewController"] ) {
        
        ///联系人 、 群发短信联系人
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
        [cell setCellDetails:[arrayShow objectAtIndex:indexPath.row]];
        [cell setCallBtnShow:[arrayShow objectAtIndex:indexPath.row] index:indexPath];
        return cell;
    }else if ([self.typeFromView isEqualToString:@"CustomerViewController"]) {
        ///客户
        CustomerSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomerSearchCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"CustomerSearchCell" owner:self options:nil];
            cell = (CustomerSearchCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        
        cell.ccdelegate= self;
        [cell setCellDetails:[arrayShow objectAtIndex:indexPath.row] index:indexPath];
        
        return cell;
        
    }if ([self.typeFromView isEqualToString:@"SaleLeadViewController"]) {
        ///销售线索
        SaleLeadSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SaleLeadSearchCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SaleLeadSearchCell" owner:self options:nil];
            cell = (SaleLeadSearchCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }

        [cell setCellDetails:[arrayShow objectAtIndex:indexPath.row]];
        
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
        cell.sodelegate = self;
        [cell setCellDetails:[arrayShow objectAtIndex:indexPath.row] currencyUnit:currencyUnit index:indexPath];
        [cell setFollowBtnShow:[arrayShow objectAtIndex:indexPath.row] index:indexPath];
        return cell;
    }
    
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ///群发短信  联系人
    if ([self.typeFromView isEqualToString:@"SMSContactSearchViewController"]) {
        
    }else if([self.typeFromView isEqualToString:@"SMSCustomerSearchViewController"]){
        ///群发短信客户
    }else{
        if ([self.typeSearchStatus isEqualToString:TAG_DEFAULT]) {
            
            searchBar.text = [[arrayShow objectAtIndex:indexPath.row] objectForKey:@"name"];
            [self searchByKeyWord:searchBar.text];
            [self.tableviewSearch reloadData];
            ///滑动到最顶部
            [self.tableviewSearch setContentOffset:CGPointZero animated:NO];
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
            controller.itemDetails = [arrayShow objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:controller animated:YES];
        }
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
    NSDictionary *item = [arrayShow objectAtIndex:indexPath.row];
    
    ///市场活动
    if ([self.typeSearchStatus isEqualToString:@"CampaignViewController"]) {
        [self  CampaignViewCellEvent:cell item:item WithIndex:index];
    }else if ([self.typeFromView isEqualToString:@"ContactViewController"]) {
        ///联系人
    }else if ([self.typeFromView isEqualToString:@"CustomerViewController"]) {
        ///客户
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

#pragma mark - 关注事件回调
-(void)followCustomer:(NSInteger)index{
    NSLog(@"followCustomer:%li",index);
    ///区分是哪个页面
    if ([self.typeFromView isEqualToString:@"SalesOpportunityViewController"]) {
        ///销售机会
    }else if ([self.typeFromView isEqualToString:@"CustomerViewController"]) {
        ///客户
    }
}

#pragma mark - 键盘事件
-(void)addTouchesEvent{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}


-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [searchTextField resignFirstResponder];
}


#pragma mark - 搜索相关

///根据关键词本地检索
-(void)searchByKeyWord:(NSString *)searchStr{
    self.typeSearchStatus = self.typeFromView;
    self.tableviewSearch.tableFooterView = nil;
    self.tableviewSearch.tableHeaderView = nil;
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewSearch setTableFooterView:v];
    [self searchResult:searchStr];
    if (arraySearchResults && [arraySearchResults count]>0) {
        arrayShow = arraySearchResults;
    }else{
        arrayShow = nil;
    }
}

- (void)searchBar:(UISearchBar *)searchBar2 textDidChange:(NSString *)searchText;
{
    ///群发短信  联系人/客户
    if ([self.typeFromView isEqualToString:@"SMSContactSearchViewController"] || [self.typeFromView isEqualToString:@"SMSCustomerSearchViewController"]) {
        
    }else{
        if (searchText!=nil && searchText.length>0) {
            [self searchByKeyWord:searchText];
        }
        else
        {
            self.typeSearchStatus = TAG_DEFAULT;
            ///添加headview  footview
            [self addTableViewHeadView];
            [self addTableViewFootView];
            ///若输入为空 则显示本地记录数据
            arrayShow = arrayLatelySearch;
        }
        [self.tableviewSearch reloadData];
        ///滑动到最顶部
        [self.tableviewSearch setContentOffset:CGPointZero animated:NO];
    }
}


///搜索事件
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchbar {
    //    [self searchBar:searchBar textDidChange:nil];
    [searchBar resignFirstResponder];
    NSLog(@"searchBarSearchButtonClicked-->");
    
    ///添加相关客户  不跳到到搜索结果页面
    if ([self.typeGoSearchResult isEqualToString:@"no"]) {
        
    }else{
        ///搜索事件
        [self searchSeviceDataByKeyWord:searchbar.text];
    }
    
}

///根据输入的关键词做匹配
-(void)searchResult:(NSString *)searchStr{
    [arraySearchResults removeAllObjects];
    
    NSInteger countAll = 0;
    if (self.arraySearch) {
        countAll = [self.arraySearch count];
    }
    
    //所有数据
    for(int i=0; i < countAll; i++)
    {
        NSString *name = [[NSString alloc]init];
        name = [[self.arraySearch objectAtIndex:i]objectForKey:@"name"];
        if ([CommonFuntion searchResult:name searchText:searchStr]){
            [arraySearchResults addObject:[self.arraySearch objectAtIndex:i]];
        }
    }
}


#pragma mark -   搜索网络数据
///keyboardview event
-(void)searchSeviceData{
    NSString *searchStr = searchBar.text;
    [self searchSeviceDataByKeyWord:searchStr];
}


///搜索事件
-(void)searchSeviceDataByKeyWord:(NSString *)keyWord{
    SearchResultViewController *controller = [[SearchResultViewController alloc] init];
    controller.keyWord = keyWord;
    controller.typeFromView = self.typeFromView;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
