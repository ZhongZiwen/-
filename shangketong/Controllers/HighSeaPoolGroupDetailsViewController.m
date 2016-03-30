//
//  HighSeaPoolGroupDetailsViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-3.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "HighSeaPoolGroupDetailsViewController.h"
#import <MBProgressHUD.h>
#import "CommonConstant.h"
#import "CommonFuntion.h"
#import "AFNHttp.h"
#import "AppDelegate.h"
#import "CustomStatusBarTopView.h"
#import "ClueHighSeaPoolGroupDetailCell.h"
#import "CustomerHighSeaPoolGroupDetailCell.h"
#import "HighSeaPoolAdvanceSearchViewController.h"
#import "LeadNewViewController.h"
#import "CustomerNewViewController.h"
#import "TypeActionSheet.h"
#import "TypeModel.h"

@interface HighSeaPoolGroupDetailsViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate,ClueHighSeaPoolGroupDetailDelegate,CustomerHighSeaPoolGroupDetailDelegate>{
    UISearchBar *searchBar;
    UISearchDisplayController *searchDisplayController;
    
    ///搜索结果
    NSMutableArray *arraySearchResults;

    ///页码
    NSInteger pageNo;
    
    ///高级检索
    UIButton *btnAdvanceSearch;
    
    ///已领取线索数
    NSString *contentStatusView;
    CustomStatusBarTopView *statusView;
}

@end

@implementation HighSeaPoolGroupDetailsViewController

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = kView_BG_Color;
    
    UIBarButtonItem *newButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newButtonItem)];
    self.navigationItem.rightBarButtonItem = newButtonItem;
    
    [self initTableview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initStatusBariew];
    [self readTestData];
    [self.tableviewHighSeaPools reloadData];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [statusView showTopViewMessage:contentStatusView];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [statusView hide];
}


#pragma mark - 读取测试数据
-(void)readTestData{
    
    if(self.typeOfPool && [self.typeOfPool isEqualToString:@"clue"]){
        id jsondata = [CommonFuntion readJsonFile:@"highseapool-group-clue-details-data"];
        NSLog(@"jsondata:%@",jsondata);
        
        NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"leads"];
        [self.arrayHighSeaPools addObjectsFromArray:array];
    }else if(self.typeOfPool && [self.typeOfPool isEqualToString:@"customer"]){
        id jsondata = [CommonFuntion readJsonFile:@"highseapool-group-customer-details-data"];
        NSLog(@"jsondata:%@",jsondata);
        
        NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"accounts"];
        [self.arrayHighSeaPools addObjectsFromArray:array];
    }

    NSLog(@"arrayHighSeaPools count:%li",[self.arrayHighSeaPools count]);
}


#pragma mark - 初始化数据
-(void)initData{
    contentStatusView = @"已领取线索数:7/100";
    pageNo = 1;
    arraySearchResults = [[NSMutableArray alloc] init];
    self.arrayHighSeaPools = [[NSMutableArray alloc] init];
}


#pragma mark - 初始化状态栏view
-(void)initStatusBariew{
    NSString *content = contentStatusView;
    CGSize sizeContent = [CommonFuntion getSizeOfContents:content Font:[UIFont systemFontOfSize:11.0] withWidth:kScreen_Width withHeight:20];
    
    statusView = [[CustomStatusBarTopView alloc] initWithFrame:CGRectMake(kScreen_Width-sizeContent.width, 0, sizeContent.width, 20)];
}


#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewHighSeaPools = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStylePlain];
    self.tableviewHighSeaPools.backgroundColor = VIEW_BG_COLOR;
    self.tableviewHighSeaPools.delegate = self;
    self.tableviewHighSeaPools.dataSource = self;
    self.tableviewHighSeaPools.sectionFooterHeight = 0;
    [self.view addSubview:self.tableviewHighSeaPools];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewHighSeaPools setTableFooterView:v];
    
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width,44)];
    searchBar.placeholder = @"搜索";
    searchBar.translucent = YES;
    searchBar.delegate = self;
    [searchBar sizeToFit];
    
    
    btnAdvanceSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAdvanceSearch.frame = CGRectMake(kScreen_Width-35, 12, 20, 20);
    [btnAdvanceSearch setImage:[UIImage imageNamed:@"search_bar_filter_normal.png"] forState:UIControlStateNormal];
    [btnAdvanceSearch setImage:[UIImage imageNamed:@"search_bar_filter_click.png"] forState:UIControlStateHighlighted];
    [btnAdvanceSearch addTarget:self action:@selector(goAdvanceSearchView) forControlEvents:UIControlEventTouchUpInside];
    [searchBar addSubview:btnAdvanceSearch];
    
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.contentMode = UIViewContentModeLeft;
    //    [searchBar setBarTintColor:[UIColor clearColor]];
    //    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    //    [searchBar setBackgroundColor:[UIColor blueColor]];
    searchBar.backgroundImage = [CommonFuntion createImageWithColor:COLOR_SEARCHBAR_BG];
    
    
    // 用 searchbar 初始化 SearchDisplayController
    // 并把 searchDisplayController 和当前 controller 关联起来
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.delegate = self;
    ///去除多余得分割线
    UIView *vs = [[UIView alloc] initWithFrame:CGRectZero];
    [searchDisplayController.searchResultsTableView setTableFooterView:vs];
    searchDisplayController.searchResultsTableView.backgroundColor = VIEW_BG_COLOR;
    self.tableviewHighSeaPools.tableHeaderView = searchBar;
    
}

///高级检索
-(void)goAdvanceSearchView{
    NSLog(@"goAdvanceSearchView-->");
    HighSeaPoolAdvanceSearchViewController *controller = [[HighSeaPoolAdvanceSearchViewController alloc] init];
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

#pragma mark - 获取公海池分组详情数据
-(void)getHighSeaPoolGroupDetails{
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    NSString *url = @"";
    if(self.typeOfPool && [self.typeOfPool isEqualToString:@"clue"]){
        url = GET_CLUE_HIGH_SEA_POOL_GROUP_DETAILS_ACTION;
    }else if(self.typeOfPool && [self.typeOfPool isEqualToString:@"customer"]){
        url = GET_CUSTOMER_HIGH_SEA_POOL_GROUP_DETAILS_ACTION;
    }
    
    [params setObject:[NSNumber numberWithInteger:pageNo] forKey:@"page"];
    [params setObject:@"" forKey:@""];
    
    // 发起请求
    [AFNHttp post:url params:params success:^(id responseObj) {
        //字典转模型
        NSLog(@"responseObj:%@",responseObj);
        NSDictionary *info = responseObj;
        
        if ([[info objectForKey:@"scode"] integerValue] == 0) {
            
            if ([info objectForKey:@"body"]) {
                if ([[info objectForKey:@"body"] objectForKey:@"highSeas"] && [[info objectForKey:@"body"] objectForKey:@"highSeas"] != [NSNull null]) {
                    
                    [self.arrayHighSeaPools addObjectsFromArray:[[info objectForKey:@"body"] objectForKey:@"highSeas"] ];
                    
                }
            }
            
        }else{
        }
        [self.tableviewHighSeaPools reloadData];
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        [self.tableviewHighSeaPools reloadData];
    }];
}

#pragma mark - event response
- (void)newButtonItem {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *scanfAction = [UIAlertAction actionWithTitle:@"名片扫描" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *inputAction = [UIAlertAction actionWithTitle:@"手工输入" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if ([self.typeOfPool isEqualToString:@"clue"]) {    // 线索公海池
            
            LeadNewViewController *newController = [[LeadNewViewController alloc] init];
            newController.title = @"创建销售线索";
            [self.navigationController pushViewController:newController animated:YES];
            return;
        }
        
        NSMutableDictionary *params=[NSMutableDictionary dictionary];
        [params addEntriesFromDictionary:COMMON_PARAMS];
        
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        [hud show:YES];
        [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP, kNetPath_Customer_CustomerType] params:params success:^(id responseObj) {
            [hud hide:YES];
            NSLog(@"客户类型 = %@", responseObj);
            if ([[responseObj objectForKey:@"status"] integerValue])   // 加载失败
                return;
            
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
            for (NSDictionary *tempDict in responseObj[@"customerTypes"]) {
                TypeModel *item = [NSObject objectOfClass:@"TypeModel" fromJSON:tempDict];
                [array addObject:item];
            }
            
            TypeActionSheet *actionSheet = [[TypeActionSheet alloc] initWithTitle:@"选择销售机会类型"];
            actionSheet.sourceArray = array;
            actionSheet.valueBlock = ^(TypeModel *item) {
                CustomerNewViewController *customerNewController = [[CustomerNewViewController alloc] init];
                customerNewController.title = @"创建客户";
                [self.navigationController pushViewController:customerNewController animated:YES];
            };
            [actionSheet show];
            
        } failure:^(NSError *error) {
            [hud hide:YES];
            NSLog(@"error:%@",error);
        }];

    }];
    [alertController addAction:cancelAction];
    [alertController addAction:scanfAction];
    [alertController addAction:inputAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)clickGetEvent:(NSInteger)index{
    NSLog(@"clickGetEvent:%li",index);
}

#pragma mark - tableview delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.tableviewHighSeaPools == tableView) {
        if (self.arrayHighSeaPools) {
            return [self.arrayHighSeaPools count];
        }
    }else if (searchDisplayController.searchResultsTableView){
        if (arraySearchResults) {
            return [arraySearchResults count];
        }
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.typeOfPool && [self.typeOfPool isEqualToString:@"clue"]){
        return 70.0;
    }else if(self.typeOfPool && [self.typeOfPool isEqualToString:@"customer"]){
        return 55.0;
    }
    return 1.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(self.typeOfPool && [self.typeOfPool isEqualToString:@"clue"]){
        ClueHighSeaPoolGroupDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClueHighSeaPoolGroupDetailCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ClueHighSeaPoolGroupDetailCell" owner:self options:nil];
            cell = (ClueHighSeaPoolGroupDetailCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        cell.delegate = self;
        [cell setCellFrame];
        if (self.tableviewHighSeaPools == tableView) {
            [cell setCellContentDetails:[self.arrayHighSeaPools objectAtIndex:indexPath.row] indexPath:indexPath];
        }else if (searchDisplayController.searchResultsTableView){
            [cell setCellContentDetails:[arraySearchResults objectAtIndex:indexPath.row] indexPath:indexPath];
        }
        
        return cell;
    }else if(self.typeOfPool && [self.typeOfPool isEqualToString:@"customer"]){
        CustomerHighSeaPoolGroupDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomerHighSeaPoolGroupDetailCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"CustomerHighSeaPoolGroupDetailCell" owner:self options:nil];
            cell = (CustomerHighSeaPoolGroupDetailCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        cell.delegate = self;
        [cell setCellFrame];
        if (self.tableviewHighSeaPools == tableView) {
            [cell setCellContentDetails:[self.arrayHighSeaPools objectAtIndex:indexPath.row] indexPath:indexPath];
        }else if (searchDisplayController.searchResultsTableView){
            [cell setCellContentDetails:[arraySearchResults objectAtIndex:indexPath.row] indexPath:indexPath];
        }
        
        return cell;
    }
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.tableviewHighSeaPools == tableView) {
        
    }else if (searchDisplayController.searchResultsTableView == tableView){
        [arraySearchResults removeAllObjects];
        searchBar.text = @"";
        [searchDisplayController setActive:NO animated:YES];
        btnAdvanceSearch.hidden = NO;
        [statusView showTopViewMessage:contentStatusView];
    }
//    if ([[[arrayShow objectAtIndex:indexPath.row] objectForKey:@"unclaimed"] integerValue] > 0) {
//    }
}

#pragma mark - searchbar delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar1
{
    [statusView hide];
    btnAdvanceSearch.hidden = YES;
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
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
        if([cc isKindOfClass:[UITextField class]])
        {
            UITextField *txt = (UITextField *)cc;
            txt.placeholder = @"搜索";
        }
    }
}

- (void)searchBar:(UISearchBar *)searchBar2 textDidChange:(NSString *)searchText;
{
    NSLog(@"textDidChange searchText:%@",searchText);
    if (searchText!=nil && searchText.length>0) {
        [self searchByKeyWord:searchText];
    }
    else
    {
        [arraySearchResults removeAllObjects];
    }
    [self.tableviewHighSeaPools reloadData];
    ///滑动到最顶部
    [self.tableviewHighSeaPools setContentOffset:CGPointZero animated:NO];
}

///根据关键词本地检索
-(void)searchByKeyWord:(NSString *)searchStr{
    [self searchResult:searchStr];
}

///根据输入的关键词做匹配
-(void)searchResult:(NSString *)searchStr{
    [arraySearchResults removeAllObjects];
    
    NSInteger countAll = 0;
    if (self.arrayHighSeaPools) {
        countAll = [self.arrayHighSeaPools count];
    }
    
    //所有数据
    for(int i=0; i < countAll; i++)
    {
        NSString *name = [[NSString alloc]init];
        name = [[self.arrayHighSeaPools objectAtIndex:i]objectForKey:@"name"];
        if ([CommonFuntion searchResult:name searchText:searchStr]){
            [arraySearchResults addObject:[self.arrayHighSeaPools objectAtIndex:i]];
        }
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"searchBarCancelButtonClicked--->");
    
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    NSLog(@"searchBarTextDidEndEditing--->");
    if (!searchDisplayController.active) {
        btnAdvanceSearch.hidden = NO;
        [statusView showTopViewMessage:contentStatusView];
    }
}

@end
