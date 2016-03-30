//
//  HomeSeacherController.m
//  valkofasdngae
//
//  Created by 蒋 on 15/7/13.
//  Copyright (c) 2015年 蒋. All rights reserved.
//

#import "HomeSeacherController.h"
#import "HomeSearchResultController.h"
#import "SearchTextCell.h"
#import "CommonConstant.h"
#import "NSUserDefaults_Cache.h"
#import "CommonNoDataView.h"
#import "CommonFuntion.h"
#import "MsgSearchGuideView.h"

@interface HomeSeacherController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>{
    ///控制是否显示搜索(XXXX)view
    ///当编辑框不为空时显示
    BOOL isShowHeadSearch;
    ///清除搜索历史
//    UIButton *btnFooterClear;
    UIView *footerClearView;
    
    ///用来标记当前搜索历史
    NSString *key_search_history;
}
@property (nonatomic, strong) NSString *serachBarText;
@property (nonatomic, strong) NSMutableArray *searchHistoryArr; //搜索历史
@property (nonatomic, strong) NSMutableArray *searchHistoryArrBackup;
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property (nonatomic, strong) MsgSearchGuideView *guideView;//搜索提示
@end

@implementation HomeSeacherController

- (void)viewDidLoad {
    [super viewDidLoad];
    isShowHeadSearch = FALSE;
    
    [self initSearchHistoryKey];
    [self initFooterBtn];
    [self initSearchBarView];
    [self initTableview];
    [self initSearchHistory];
    
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


#pragma mark - 根据标记初始化key
-(void)initSearchHistoryKey{
    key_search_history = @"";
    ///首页
    if (self.flagToHomeSearch == 0) {
        key_search_history = @"";
    }else if (self.flagToHomeSearch == 1) {
        ///知识库
        key_search_history = search_history_flag_key;
    }
}

#pragma mark - 搜索历历史按钮
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
    if (_serachBarText == nil) {
        return;
    }
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
    if (type == 0) {
        msg = @"您可以搜到：销售线索、客户、联系人、销售机会";
    }else if (type == 1){
        msg = @"无结果";;
    }
    if (self.guideView == nil) {
        self.guideView = [[MsgSearchGuideView alloc] initWithFrame:CGRectMake(0, (kScreen_Height-140)/2-80, kScreen_Width, 140)];
        self.guideView.imgName = @"";
        self.guideView.imgNameOne = @"icon_search_lead";
        self.guideView.imgNameTwo = @"icon_search_customer";
        self.guideView.imgNameThree = @"icon_search_contact";
        self.guideView.imgNameFour = @"icon_search_opportunity";
        self.guideView.labelTitle = msg;
        self.guideView.btnTitle = @"";
    }
    [self.tableView addSubview:self.guideView];

//    NSString *msg = @"";
//    ///搜索历史
//    if (type == 0) {
//        msg = @"请在搜索框中输入关键字";
//    }else if (type == 1){
//        msg = @"无结果";
//    }
//    if (self.commonNoDataView == nil) {
//        self.commonNoDataView = [CommonFuntion commonNoDataViewIcon:@"list_empty.png" Title:msg optionBtnTitle:@""];
//    }
//    [self.tableView addSubview:self.commonNoDataView];
}

-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
        [self.tableView layoutIfNeeded];
    }
    if (self.guideView) {
        [self.guideView removeFromSuperview];
        [self.tableView layoutIfNeeded];
    }
}



#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.sectionFooterHeight = 0;
    self.tableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    self.tableView.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
    
    [self.view addSubview:self.tableView];
//    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
//    [self.tableView setTableFooterView:v];
    
}
#pragma mark - 初始化searchbar
-(void)initSearchBarView{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 64)];
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(5, 25, kScreen_Width - 50, 30)];
//    topView.backgroundColor = [UIColor colorWithRed:200.0f/255 green:200.0f/255 blue:200.0f/255 alpha:1.0f];
    topView.backgroundColor = COMM_SEARCHBAR_BACKGROUNDCOLOR;
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
    [self.navigationController popViewControllerAnimated:YES];
    NSLog(@"返回上一界面");
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
    if (!isShowHeadSearch) {
        static NSString *identifier = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        }
        cell.textLabel.text = [_searchHistoryArr objectAtIndex:indexPath.row];
        return cell;
    } else {
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
    }
    return nil;
}
- (NSString *)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    if (_searchHistoryArr != nil && _searchHistoryArr.count > 0) {
        return @"搜索历史";
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_searchHistoryArr != nil && _searchHistoryArr.count > 0) {
        return 44;
    }
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ///缓存搜索关键词
    [self saveSearchHistory];
    if (!isShowHeadSearch) {
        _serachBarText = [_searchHistoryArr objectAtIndex:indexPath.row];
    }

    [self pushToSearchResultControllerWithText:_serachBarText];
    
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
    _serachBarText = searchText;
    NSLog(@"J_%@", searchText);
    if (searchText != nil && ![[searchText stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""] && searchText.length > 0) {
         [self clearViewNoData];
        [_searchHistoryArr removeAllObjects];

        isShowHeadSearch = TRUE;
        self.tableView.tableFooterView = nil;
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        [self.tableView setTableFooterView:v];
        [self.tableView reloadData];
        
    } else {
        isShowHeadSearch = FALSE;
        [_searchHistoryArr removeAllObjects];
        [_searchHistoryArr addObjectsFromArray:_searchHistoryArrBackup];
   
        [self.tableView reloadData];
        [self notifyHistoryView];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    ///缓存搜索关键词
    [self saveSearchHistory];
    //点击return 之后在这里跳转
    [self pushToSearchResultControllerWithText:_serachBarText];
}
#pragma mark --  界面跳转
- (void)pushToSearchResultControllerWithText:(NSString *)text {
    HomeSearchResultController *controller = [[HomeSearchResultController alloc] init];
    controller.searchText = text;
    controller.flagFromWhere = _flagToHomeSearch;
    [self.navigationController pushViewController:controller animated:YES];
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
