//
//  KonwledgeSearchViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-8-18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "KonwledgeSearchViewController.h"
#import "SearchTextCell.h"
#import "CommonConstant.h"
#import "NSUserDefaults_Cache.h"
#import "CommonNoDataView.h"
#import "CommonFuntion.h"
#import "MJRefresh.h"
#import "AFNHttp.h"
#import <MBProgressHUD.h>
#import "KnowledgeFileCell.h"
#import "KnowledgeFileDetailsViewController.h"

///每页条数
#define PageSize 15

@interface KonwledgeSearchViewController ()<UITableViewDataSource, UITableViewDelegate>{
    ///清除搜索历史
    //    UIButton *btnFooterClear;
    UIView *footerClearView;
    
    ///用来标记当前搜索历史
    NSString *key_search_history;
    
    NSInteger pageNo;//页数下标
    MBProgressHUD *hud;
    
    ///标记不同的cell
    NSString *statusOfCell;
}
@property (nonatomic, strong) NSString *serachBarText;
@property (nonatomic, strong) NSMutableArray *searchHistoryArr; //搜索历史
@property (nonatomic, strong) NSMutableArray *searchHistoryArrBackup;
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;


@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation KonwledgeSearchViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    statusOfCell = @"nosearch";
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    
    [self initSearchHistoryKey];
    [self initFooterBtn];
    [self initSearchBarView];
    [self initTableview];
    [self initSearchHistory];
    [self.searchBar becomeFirstResponder];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 根据标记初始化key
-(void)initSearchHistoryKey{
    key_search_history = search_history_flag_key;
}

#pragma mark - 搜索历史按钮
///搜索历史按钮
-(void)initFooterBtn{
    footerClearView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 50)];
    footerClearView.backgroundColor = [UIColor clearColor];
    
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(15, 1, kScreen_Width, 1)];
    line.image = [UIImage imageNamed:@"line.png"];
    
    
    UIButton *btnFooterClear = [UIButton buttonWithType:UIButtonTypeCustom];
    btnFooterClear.frame = CGRectMake(0, 2, kScreen_Width, 50);
    btnFooterClear.backgroundColor = [UIColor clearColor];
    btnFooterClear.titleLabel.textAlignment = NSTextAlignmentCenter;
    btnFooterClear.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [btnFooterClear setTitle:@"清空搜索历史" forState:UIControlStateNormal];
    [btnFooterClear setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btnFooterClear addTarget:self action:@selector(clearHistory) forControlEvents:UIControlEventTouchUpInside];
    
    [footerClearView addSubview:line];
    [footerClearView addSubview:btnFooterClear];
    
}



///初始化搜索历史
-(void)initSearchHistory{
    _searchHistoryArrBackup = [[NSMutableArray alloc] init];
    _searchHistoryArr = [[NSMutableArray alloc] init];
    
    NSArray *searchHistory = [NSUserDefaults_Cache getSearchHistoryDataByHsitroyFlag:key_search_history];
    
    if (searchHistory && [searchHistory count] > 0) {
        [_searchHistoryArr removeAllObjects];
        [_searchHistoryArr  addObjectsFromArray:searchHistory];
        [_searchHistoryArrBackup addObjectsFromArray:searchHistory];
    }
    [self notifyHistoryView];
}

///清除搜索历史
-(void)clearHistory{
    [_searchHistoryArr removeAllObjects];
    [_searchHistoryArrBackup removeAllObjects];
    [NSUserDefaults_Cache setSearchHistoryData:_searchHistoryArrBackup byHsitroyFlag:key_search_history];
    [self.tableView reloadData];
    [self notifyHistoryView];
}

#pragma mark - 缓存搜索关键词
///
-(void)saveSearchHistory{
    
    ///对搜索关键字做保存操作
    if(_searchHistoryArrBackup == nil){
        _searchHistoryArrBackup = [[NSMutableArray alloc] init];
    }
    if ([_searchHistoryArrBackup containsObject:_serachBarText]) {
        ///如果不存在则保存在首位
        [_searchHistoryArrBackup removeObject:_serachBarText];
        [_searchHistoryArrBackup insertObject:_serachBarText atIndex:0];
        
    }else{
        ///最多保存15条
        if ([_searchHistoryArrBackup count] > 15) {
            [_searchHistoryArrBackup removeLastObject];
        }
        [_searchHistoryArrBackup insertObject:_serachBarText atIndex:0];
    }
    
    
    ///知识库
    [NSUserDefaults_Cache setSearchHistoryData:_searchHistoryArrBackup byHsitroyFlag:key_search_history];
}


-(void)notifyHistoryView{
    [self clearViewNoData];
    if (_searchHistoryArr == nil || [_searchHistoryArr count] == 0) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        [self.tableView setTableFooterView:v];
        [self setViewNoData:0];
    }else{
        self.tableView.tableFooterView = footerClearView;
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
        [self.tableView layoutIfNeeded];
    }
}


#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.sectionFooterHeight = 0;
    self.tableView.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
    self.tableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    [self.view addSubview:self.tableView];
    //    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    //    [self.tableView setTableFooterView:v];
    
    ///添加上拉和下拉
    [self setupRefresh];
    [self.tableView setFooterHidden:YES];
    [self.tableView setHeaderHidden:YES];
    
}
#pragma mark - 初始化searchbar
-(void)initSearchBarView{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 64)];
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(5, 25, kScreen_Width - 50, 30)];
    topView.backgroundColor = [UIColor colorWithRed:200.0f/255 green:200.0f/255 blue:200.0f/255 alpha:1.0f];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索";
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
    [self.navigationController popViewControllerAnimated:NO];
    NSLog(@"返回上一界面");
}
#pragma mark -- tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([statusOfCell isEqualToString:@"headsearch"]) {
        return 1;
    }else if ([statusOfCell isEqualToString:@"nosearch"]){
        if (_searchHistoryArr != nil && [_searchHistoryArr count] > 0) {
            return [_searchHistoryArr count];
        }
    }else if ([statusOfCell isEqualToString:@"searching"]){
        if (_searchHistoryArr != nil && [_searchHistoryArr count] > 0) {
            return [_searchHistoryArr count];
        }
    }
    
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ///顶部搜索栏
    if ([statusOfCell isEqualToString:@"headsearch"]) {
        SearchTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCellIdentifier"];
        if (!cell) {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SearchTextCell" owner:self options:nil];
            cell = (SearchTextCell *)[array objectAtIndex:0];
            [cell awakeFromNib];
            [cell setFrameForAllPhone];
        }
        cell.clipsToBounds = YES;
        cell.selectedBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
        cell.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
        cell.searchLabel.text = [NSString stringWithFormat:@"搜索%@%@%@",@"\"", _serachBarText, @"\""];
        return cell;

    }else if ([statusOfCell isEqualToString:@"nosearch"]){
        ///搜索历史
        static NSString *identifier = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        }
        cell.textLabel.text = [_searchHistoryArr objectAtIndex:indexPath.row];
        return cell;
    }else if ([statusOfCell isEqualToString:@"searching"]){
        KnowledgeFileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KnowledgeFileCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"KnowledgeFileCell" owner:self options:nil];
            cell = (KnowledgeFileCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        
        [cell setCellFrame:[_searchHistoryArr objectAtIndex:indexPath.row]];
        [cell setContentDetails:[_searchHistoryArr objectAtIndex:indexPath.row]];
        
        return cell;
    }
    return nil;
}
- (NSString *)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    if ([statusOfCell isEqualToString:@"nosearch"] && _searchHistoryArr != nil && [_searchHistoryArr count] > 0){
        return @"搜索历史";
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([statusOfCell isEqualToString:@"headsearch"]) {
        
    }else if ([statusOfCell isEqualToString:@"nosearch"]){
        
    }else if ([statusOfCell isEqualToString:@"searching"]){
        
    }
    
    if ([statusOfCell isEqualToString:@"headsearch"]) {
        return 60;
    }else if ([statusOfCell isEqualToString:@"nosearch"]){
        return 44;
    }else if ([statusOfCell isEqualToString:@"searching"]){
        return 50;
    }
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([statusOfCell isEqualToString:@"headsearch"]) {
        if (_serachBarText == nil) {
            return;
        }
        ///缓存搜索关键词
        [self saveSearchHistory];
        statusOfCell = @"searching";
        pageNo = 1;
        [hud show:YES];
        [_searchHistoryArr removeAllObjects];
        [self.tableView reloadData];
        ///网络搜索
        [self getKnowledgeByKeyWord];
    }else if ([statusOfCell isEqualToString:@"nosearch"]){
        self.tableView.tableFooterView = nil;
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        [self.tableView setTableFooterView:v];
        _serachBarText = [_searchHistoryArr objectAtIndex:indexPath.row];
        _searchBar.text = _serachBarText;
        statusOfCell = @"searching";
        pageNo = 1;
        [hud show:YES];
        [_searchHistoryArr removeAllObjects];
        [self.tableView reloadData];
        ///网络搜索
        [self getKnowledgeByKeyWord];
        
        
    }else if ([statusOfCell isEqualToString:@"searching"]){
        __weak typeof(self) weak_self = self;
        KnowledgeFileDetailsViewController *controller = [[KnowledgeFileDetailsViewController alloc] init];
        controller.detailsOld = [_searchHistoryArr objectAtIndex:indexPath.row];
        controller.indexRow = indexPath.row;
        controller.viewFrom = @"knowledge";
        controller.isNeedRightNavBtn = YES;
        ///更新收藏状态
        controller.UpdateFavStatus = ^(NSInteger row, NSString *action){
            [weak_self updateFavFlag:action index:row];
        };
        
        ///删除动态
        controller.DeleteFileFromService = ^(void){
            [weak_self.navigationController popViewControllerAnimated:NO];
        };
        
        controller.DismissSearchViewBlock = ^(void){
//            [self.navigationController popViewControllerAnimated:NO];
        };
        
        [self.navigationController pushViewController:controller animated:YES];
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
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;
{
    [self.tableView setFooterHidden:YES];
    [self.tableView setHeaderHidden:YES];
    _serachBarText = searchText;
    NSLog(@"searchText:%@", searchText);
    if (searchText != nil && ![[searchText stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""] && searchText.length > 0) {
        [self clearViewNoData];
        [_searchHistoryArr removeAllObjects];
        statusOfCell = @"headsearch";
        
        self.tableView.tableFooterView = nil;
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        [self.tableView setTableFooterView:v];
        [self.tableView reloadData];
        
    } else {
        statusOfCell = @"nosearch";
        [_searchHistoryArr removeAllObjects];
        [_searchHistoryArr addObjectsFromArray:_searchHistoryArrBackup];
        
        [self.tableView reloadData];
        [self notifyHistoryView];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (_serachBarText == nil) {
        return;
    }
    self.tableView.tableFooterView = nil;
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
    
    ///缓存搜索关键词
    [self saveSearchHistory];
    ///网络搜索
    statusOfCell = @"searching";
    pageNo = 1;
    [hud show:YES];
    [_searchHistoryArr removeAllObjects];
    [self.tableView reloadData];
    [self getKnowledgeByKeyWord];
}



#pragma mark - 根据关键词网络搜索
-(void)getKnowledgeByKeyWord{
    
    [self clearViewNoData];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    [params setObject:[NSNumber numberWithInt:11] forKey:@"type"];
    [params setObject:[NSNumber numberWithInteger:pageNo] forKey:@"pageNo"];
    [params setObject:[NSNumber numberWithInt:PageSize] forKey:@"pageSize"];
    [params setObject:_serachBarText forKey:@"searchName"];
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA,SEARCH_KNOWLEDGE_FILE] params:params success:^(id responseObj) {
        [hud hide:YES];
        //字典转模型
        NSLog(@"搜索知识库 responseObj:%@",responseObj);
        //字典转模型
        NSDictionary *resultdic = responseObj;
        
        if (resultdic && [[resultdic objectForKey:@"status"] integerValue] == 0) {
            [self setViewRequestSusscess:resultdic];
        }else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getKnowledgeByKeyWord];
            };
            [comRequest loginInBackground];
        }
        else{
            NSString *desc = [resultdic safeObjectForKey:@"desc"];
            ///加载失败 做相应处理
            [self setViewRequestFaild:desc];
        }
        ///刷新UI
        [self reloadRefeshView];
    } failure:^(NSError *error) {
        [hud hide:YES];
        NSLog(@"error:%@",error);
        ///网络失败 做相应处理
        [self setViewRequestFaild:NET_ERROR];
        ///刷新UI
        [self reloadRefeshView];
    }];
}


// 请求成功时数据处理
-(void)setViewRequestSusscess:(NSDictionary *)resultdic
{
    NSArray  *array = nil;
    
    if ([resultdic objectForKey:@"directorys"] ) {
        array = [resultdic  objectForKey:@"directorys"];
    }
    
    NSLog(@"count:%ti",[array count]);
    ///有数据返回
    if (array && [array count] > 0) {
        ///缓存第一页数据
        if(pageNo == 1)
        {
            [_searchHistoryArr removeAllObjects];
        }
        
        ///页码++
        if ([array count] == PageSize) {
            pageNo++;
            [self.tableView setFooterHidden:NO];
        }else
        {
            ///隐藏上拉刷新
            [self.tableView setFooterHidden:YES];
        }
        
        ///添加当前页数据到列表中...
        [_searchHistoryArr addObjectsFromArray:array];
    }else{
        ///返回为空
        ///隐藏上拉刷新
  
        [self.tableView setFooterHidden:YES];
        ///若是第一页 读取是否存在缓存
        if(pageNo == 1)
        {
            NSLog(@"setViewNoData:1");
            [self setViewNoData:1];
        }
    }
}

// 请求失败时数据处理
-(void)setViewRequestFaild:(NSString *)desc
{
    ///若是第一页 读取是否存在缓存
    if(pageNo == 1)
    {
        
    }
    [CommonFuntion showToast:desc inView:self.view];
}



#pragma mark - 上拉下拉刷新相关事件
//集成刷新控件
- (void)setupRefresh
{
    NSString *dateKey = @"searchknowledge";
    
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:dateKey];
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

// 下拉
- (void)headerRereshing
{
    NSLog(@"headerRereshing--下拉-->");
    
    if ([self.tableView isFooterRefreshing]) {
        [self.tableView headerEndRefreshing];
        return;
    }
    
    pageNo = 1;
    [self getKnowledgeByKeyWord];
}

// 上拉
- (void)footerRereshing
{
    NSLog(@"footerRereshing--上拉-->");
    
    if ([self.tableView isHeaderRefreshing]) {
        [self.tableView footerEndRefreshing];
        return;
    }
    [self getKnowledgeByKeyWord];
}



#pragma mark - 更新收藏标记
-(void)updateFavFlag:(NSString *)action index:(NSInteger)row{
    NSLog(@"updateFavFlag  action:%@  section:%ti",action,row);
    NSInteger isfav = 1;
    if ([action isEqualToString:KNOWLEDGE_ADD_COLLECTION]) {
        isfav = 0;
    }else if([action isEqualToString:KNOWLEDGE_CANCEL_COLLECTION]){
        isfav = 1;
    }
    NSDictionary *item = [_searchHistoryArr objectAtIndex:row];
    ///修改本地数据
    NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:item];
    [mutableItemNew setObject:[NSNumber numberWithInteger:isfav] forKey:@"hasFavorite"];
    //修改数据
    [_searchHistoryArr setObject: mutableItemNew atIndexedSubscript:row];
    ///刷新当前cell
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:row inSection:0],nil] withRowAnimation:UITableViewRowAnimationNone];
}

@end
