//
//  KnowledgeFileViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-5-27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "KnowledgeFileViewController.h"
#import "AppDelegate.h"
#import "GBMoudle.h"
#import "CommonConstant.h"
#import "CommonFuntion.h"
#import "AFNHttp.h"
#import <MBProgressHUD.h>
#import "KnowledgeDirectorieCell.h"
#import "KnowledgeFileCell.h"
#import "KnowledgeDepartmentCell.h"
#import "KnowledgeFileDetailsViewController.h"
#import "ChineseToPinyin.h"
#import "MJRefresh.h"
//#import "HomeSeacherController.h"
#import "KonwledgeSearchViewController.h"
#import "CommonNoDataView.h"

///每页条数
#define PageSize 15

@interface KnowledgeFileViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate>{
    UISearchBar *searchBar;
    UISearchDisplayController *searchDisplayController;
    NSMutableArray *filterArray;;
    
    ///索引
    NSMutableArray *keys;
    ///带分组的部门信息
    NSMutableDictionary *dicKeysDepartMents;
    
    
    NSInteger pageNo;//页数下标
    BOOL isMoreData;///是否有更多数据
}
@property (nonatomic, strong) UIView *searchView; //搜索View
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@end

@implementation KnowledgeFileViewController

- (void)loadView
{
    [super loadView];
    self.title = self.strTitle;
    self.view.backgroundColor = TABLEVIEW_BG_COLOR;
    
    [self initTableview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    ///请求部门列表
    if (self.typeKnowledge == 0 && self.typeKnowledgeRequest == 0) {
        ///部门
        [self getDepartmentFromService];
    }else{
        if (self.typeKnowledge != -1) {
            [self getKnowledgeFileFromService];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableviewKnowledgeFile reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initData{
    filterArray = [[NSMutableArray alloc] init];
    pageNo = 1;
    self.arrayFiles = [[NSMutableArray alloc] init];
    ///首页根目录
    if (self.typeKnowledge == -1) {
        NSArray *array = [[NSArray alloc] initWithObjects:@"公司知识库",@"我的知识库", nil];
        [self.arrayFiles addObjectsFromArray:array];
    }
}

#pragma mark - 获取部门列表

-(void)getDepartmentFromService{
    [self clearViewNoData];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA,KNOWLEDGE_GET_ALL_DEPARTMENT] params:params success:^(id responseObj) {
        [hud hide:YES];
        
        //字典转模型
        NSLog(@"部门列表 responseObj:%@",responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            
            if ([responseObj objectForKey:@"departments"]) {
                self.arrayDepartments = [responseObj objectForKey:@"departments"];
                [self getKeysFromDepartments:self.arrayDepartments];
            }
            
            if (self.arrayDepartments == nil || [self.arrayDepartments count] == 0) {
                [self setViewNoData];
            }
        }else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getDepartmentFromService];
            };
            [comRequest loginInBackground];
        }else{
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        
        [self.tableviewKnowledgeFile reloadData];
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        [hud hide:YES];
        [CommonFuntion showToast:NET_ERROR inView:self.view];
    }];
}


#pragma mark - 获取某部门下/我的知识库
/// 参数：type(1-部门 2-我的知识库 3-群组), id(部门/群组ID), sid(目录ID)
-(void)getKnowledgeFileFromService{
    
    [self clearViewNoData];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    NSString *url = @"";
    ///部门、群组
    if (self.typeKnowledge == 0 || self.typeKnowledge == 2) {
        url = KNOWLEDGE_GET_ALL_FILES;
        [params setObject:[NSNumber numberWithLongLong:self.departmengOrGroupId] forKey:@"id"];
        [params setObject:[NSNumber numberWithLongLong:self.typeKnowledge+1] forKey:@"type"];
        if (self.dirId != -1) {
            [params setObject:[NSNumber numberWithLongLong:self.dirId] forKey:@"sid"];
        }
    }else if (self.typeKnowledge == 1){
        ///我的知识库
        url = KNOWLEDGE_GET_ALL_FILES;
        [params setObject:[NSNumber numberWithLongLong:self.typeKnowledge+1] forKey:@"type"];
        if (self.dirId != -1) {
            [params setObject:[NSNumber numberWithLongLong:self.dirId] forKey:@"sid"];
        }
    }else if (self.typeKnowledge == 3){
        ///CRM-详情
        url = GET_CAMPAIGN_DETAILS_FILE;
        [params setObject:[NSNumber numberWithLongLong:0] forKey:@"type"];
        [params setObject:[NSNumber numberWithLongLong:self.dirId] forKey:@"id"];
    }
    
    [params setObject:[NSNumber numberWithInteger:pageNo] forKey:@"pageNo"];
    [params setObject:[NSNumber numberWithInt:PageSize] forKey:@"pageSize"];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA,url] params:params success:^(id responseObj) {
        
        //字典转模型
        NSLog(@"获取某部门下/我的知识库 responseObj:%@",responseObj);
        //字典转模型
        NSDictionary *resultdic = responseObj;
        
        if (resultdic && [[resultdic objectForKey:@"status"] integerValue] == 0) {
            [self setViewRequestSusscess:resultdic];
        }else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getKnowledgeFileFromService];
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
    
    if ([resultdic objectForKey:@"directorys"]) {
        array = [resultdic objectForKey:@"directorys"];
    }
    
//    if ([resultdic objectForKey:@"files"]) {
//        array = [resultdic objectForKey:@"files"];
//    }
    
    NSLog(@"count:%ti",[array count]);
    ///有数据返回
    if (array && [array count] > 0) {
        ///缓存第一页数据
        if(pageNo == 1)
        {
            [self.arrayFiles removeAllObjects];
        }
        
        ///页码++
        if ([array count] == PageSize) {
            pageNo++;
            isMoreData = YES;
            [self.tableviewKnowledgeFile setFooterHidden:NO];
        }else
        {
            ///隐藏上拉刷新
            [self.tableviewKnowledgeFile setFooterHidden:YES];
            isMoreData = NO;
        }
        
        ///添加当前页数据到列表中...
        [self.arrayFiles addObjectsFromArray:array];
    }else{
        ///返回为空
        ///隐藏上拉刷新
        isMoreData = NO;
        [self.tableviewKnowledgeFile setFooterHidden:YES];
        ///若是第一页 读取是否存在缓存
        if(pageNo == 1)
        {
            [self.arrayFiles removeAllObjects];
            [self setViewNoData];
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


#pragma mark - 没有数据时的view
-(void)setViewNoData{
    ///部门
    if (self.typeKnowledge == 0 && self.typeKnowledgeRequest == 0) {
        if (self.commonNoDataView == nil) {
            self.commonNoDataView = [CommonFuntion commonNoDataViewIcon:@"list_empty.png" Title:@"暂无部门" optionBtnTitle:@""];
        }
    }else{
        if (self.commonNoDataView == nil) {
            self.commonNoDataView = [CommonFuntion commonNoDataViewIcon:@"list_empty.png" Title:@"暂无文档" optionBtnTitle:@""];
        }
    }
    
    [self.tableviewKnowledgeFile addSubview:self.commonNoDataView];
}

-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
    }
}


///获取分组索引
-(void)getKeysFromDepartments:(NSArray *)departArray{
    keys = [[NSMutableArray alloc] init];
    dicKeysDepartMents = [[NSMutableDictionary alloc] init];
    NSDictionary *item;
    NSString *pinyin;
    NSString *key = @"";
    NSInteger count = 0;
    if (departArray) {
        count = [departArray count];
    }
    
    ///遍历部门
    for (int i=0; i<count; i++) {
        item = [departArray objectAtIndex:i] ;
        pinyin = @"";
        if ([item objectForKey:@"pinyin"]) {
            pinyin = [item safeObjectForKey:@"pinyin"];
        }
        
        if ([pinyin isEqualToString:@""]) {
            NSString *name = @"";
            if ([item objectForKey:@"name"]) {
                name = [item safeObjectForKey:@"name"];
            }
            pinyin = [ChineseToPinyin pinyinFromChiniseString:name];
        }
        
        if (pinyin.length > 0) {
            ///首字母
            unichar firstLetter = [pinyin characterAtIndex:0];
            
            if(isalpha(firstLetter)){
                key = [[pinyin substringToIndex:1] uppercaseString];
            }else
            {
                // 归于其他分类
                key = @"#";
                pinyin = @"#";
            }
            
            if ([keys containsObject:key]) {
                
            }else
            {
                [keys addObject:key];
            }
            
            ///修改本地数据
            NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:item];
            [mutableItemNew setObject:pinyin forKey:@"pinyin"];
            
            
            // 已存在分组 则只添加key对应的数据
            if ([dicKeysDepartMents objectForKey:key]) {
                
                NSMutableArray *arrNew = [[NSMutableArray alloc] initWithArray:[dicKeysDepartMents objectForKey:key]];
                [arrNew addObject:mutableItemNew];
                [dicKeysDepartMents setObject:arrNew forKey:key];
            }else
            {
                NSArray *arr = [[NSArray alloc] initWithObjects:mutableItemNew, nil];
                [dicKeysDepartMents setObject:arr forKey:key];
            }
        }
    }
    
    ///排序
    NSArray *resultkArrSort = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    [keys removeAllObjects];
    [keys addObjectsFromArray:resultkArrSort];
    
    if (keys != nil && [keys count] > 0) {
        // 将#放到最后
        if ([keys containsObject:@"#"]) {
            [keys removeObject:@"#"];
            if ([dicKeysDepartMents objectForKey:@"#"]) {
                [keys addObject:@"#"];
            }
        }
    }
}

#pragma mark - 初始化tablview
-(void)initTableview{
    ///公司、我的
    if (self.typeKnowledge == 0 && self.typeKnowledgeRequest == 0) {
        ///部门
        self.tableviewKnowledgeFile = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        //改变索引的颜色
        self.tableviewKnowledgeFile.sectionIndexColor = [UIColor grayColor];
        self.tableviewKnowledgeFile.sectionIndexBackgroundColor = [UIColor clearColor];
        self.tableviewKnowledgeFile.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    }else{
        self.tableviewKnowledgeFile = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        if (self.typeKnowledge != -1) {
            ///添加上拉和下拉
            [self setupRefresh];
        }
    }
    
    self.tableviewKnowledgeFile.delegate = self;
    self.tableviewKnowledgeFile.dataSource = self;
    self.tableviewKnowledgeFile.sectionFooterHeight = 0;
    self.tableviewKnowledgeFile.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
    self.tableviewKnowledgeFile.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    [self.view addSubview:self.tableviewKnowledgeFile];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewKnowledgeFile setTableFooterView:v];
    
    
    
    
    ///正常从知识库进来则添加搜索 其他情况不添加
    if(self.typeKnowledgeSearchView == 0){
        ///部门
        if (self.typeKnowledge == 0 && self.typeKnowledgeRequest == 0) {
            [self addTableHeadSearchView];
        }else{
            [self customSearchView];
        }
    }else{
        if (self.typeKnowledgeSearchViewFirst == 0) {
            self.tableviewKnowledgeFile.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height-108);
        }
    }
    /*
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, kScreen_Width, 44.0)];
    UIView *customTableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kScreen_Width, 44.0)];
    UINavigationBar *dummyNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 0.0, kScreen_Width, 44.0)]; [customTableHeaderView addSubview:dummyNavigationBar]; [customTableHeaderView addSubview:searchBar];
    
    self.tableviewKnowledgeFile.tableHeaderView = customTableHeaderView;
    */
    
    
    
    
    
//    [self.view addSubview:searchBar];
//    self.tableviewKnowledgeFile.frame = CGRectMake(0, 108, kScreen_Width, kScreen_Height-108);
//    [self.view addSubview:self.tableviewKnowledgeFile];
}


#pragma mark - 添加搜索栏
-(void)addTableHeadSearchView{
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width,44)];
    searchBar.placeholder = @"搜索";
    searchBar.translucent = YES;
    searchBar.delegate = self;
    [searchBar sizeToFit];
    //
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.contentMode = UIViewContentModeLeft;
    searchBar.backgroundImage = [CommonFuntion createImageWithColor:COLOR_SEARCHBAR_BG];
    self.tableviewKnowledgeFile.tableHeaderView = searchBar;
    
    //
    // 用 searchbar 初始化 SearchDisplayController
    // 并把 searchDisplayController 和当前 controller 关联起来
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    
    ///去除多余得分割线
    UIView *vs = [[UIView alloc] initWithFrame:CGRectZero];
    [searchDisplayController.searchResultsTableView setTableFooterView:vs];
    
    searchDisplayController.searchBar.tintColor = LIGHT_BLUE_COLOR;
}

#pragma mark - 搜索
- (void)customSearchView {
    _searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, 44)];
    _searchView.backgroundColor = COLOR_SEARCHBAR_BG;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10, 8, self.searchView.frame.size.width - 20, self.searchView.frame.size.height - 16);
    button.backgroundColor = [UIColor whiteColor];
    button.layer.cornerRadius = 5;
    [button addTarget:self action:@selector(gotoSearchController) forControlEvents:UIControlEventTouchUpInside];
    
    NSInteger vX = kScreen_Width / 2 - 27;
    UIImageView *imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(vX, 12, 22, 22)];
    imgIcon.image = [UIImage imageNamed:@"img_search_icon.png"];
    
    UILabel *labelTag = [[UILabel alloc] initWithFrame:CGRectMake(vX + 27, 7, 120, 30)];
    labelTag.font = [UIFont systemFontOfSize:14.0];
    labelTag.textColor = [UIColor grayColor];
    labelTag.text = @"搜索";
    
    [self.searchView addSubview:button];
    [self.searchView addSubview:imgIcon];
    [self.searchView addSubview:labelTag];
    [self.view addSubview:self.searchView];
    self.tableviewKnowledgeFile.tableHeaderView = self.searchView;
}
- (void)gotoSearchController {
//    ContactSearchViewController *controller = [[ContactSearchViewController alloc] init];
//    controller.flagToSearchController = @"contactControllerToSearch";
//    controller.dataSourceArr = appDelegateAccessor.moudle.arrayAllAddressBook;
    KonwledgeSearchViewController *controller = [[KonwledgeSearchViewController alloc] init];
    [self.navigationController pushViewController:controller animated:NO];
}


#pragma mark - 上拉下拉刷新相关事件
//集成刷新控件
- (void)setupRefresh
{
    NSString *dateKey = @"";
    dateKey = [NSString stringWithFormat:@"knowledge%ti",self.typeKnowledge];
    
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [self.tableviewKnowledgeFile addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:dateKey];
    //上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableviewKnowledgeFile addFooterWithTarget:self action:@selector(footerRereshing)];
}

// 结束加载
-(void)reloadRefeshView{
    // 刷新列表
    [self.tableviewKnowledgeFile reloadData];
    [self.tableviewKnowledgeFile footerEndRefreshing];
    [self.tableviewKnowledgeFile headerEndRefreshing];
}

// 下拉
- (void)headerRereshing
{
    NSLog(@"headerRereshing--下拉-->");
    
    if ([self.tableviewKnowledgeFile isFooterRefreshing]) {
        [self.tableviewKnowledgeFile headerEndRefreshing];
        return;
    }
    
    pageNo = 1;
    [self getKnowledgeFileFromService];
}

// 上拉
- (void)footerRereshing
{
    NSLog(@"footerRereshing--上拉-->");
    
    if ([self.tableviewKnowledgeFile isHeaderRefreshing]) {
        [self.tableviewKnowledgeFile footerEndRefreshing];
        return;
    }
    [self getKnowledgeFileFromService];
}



#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if (tableView == self.tableviewKnowledgeFile) {
        if (self.typeKnowledge == 0 && self.typeKnowledgeRequest == 0) {
            return 20.0;
        }
//    }
    return 0;
}

#pragma mark - tableview delegate
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    if (tableView == self.tableviewKnowledgeFile) {
        if (self.typeKnowledge == 0 && self.typeKnowledgeRequest == 0) {
            UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
            headView.backgroundColor = TABLEVIEW_BG_COLOR;
            UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 20)];
            labelTitle.font = [UIFont systemFontOfSize:12.0];
            labelTitle.tintColor = [UIColor redColor];
            labelTitle.text = [keys objectAtIndex:section];
            [headView addSubview:labelTitle];
            
            return headView;
        }
//    }
    return nil;
}

//返回索引数组
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
//    if (tableView == self.tableviewKnowledgeFile) {
        ///部门
        if (self.typeKnowledge == 0 && self.typeKnowledgeRequest == 0) {
            return keys;
        }
        return nil;
//    }
//    return nil;
}

//响应点击索引时的委托方法
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
//    if (tableView == self.tableviewKnowledgeFile) {
        ///部门
        if (self.typeKnowledge == 0 && self.typeKnowledgeRequest == 0) {
            NSInteger count = 0;
            for(NSString *character in keys)
            {
                if([character isEqualToString:title])
                {
                    return count;
                }
                count ++;
            }
        }
        return 0;
//    }
//    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    if (tableView == self.tableviewKnowledgeFile) {
        if (self.typeKnowledge == 0 && self.typeKnowledgeRequest == 0) {
            return [keys count];
        }
//    }
    return 1;
}

////返回每个索引的内容
//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (tableView == self.tableviewKnowledgeFile) {
//        if (self.typeKnowledge == 1) {
//            return [keys objectAtIndex:section];
//        }
//    }
//    return @"";
//}

//返回每个section的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (tableView == self.tableviewKnowledgeFile) {
        ///
        if (self.typeKnowledge == 0 && self.typeKnowledgeRequest == 0) {
            ///部门
            return [[dicKeysDepartMents objectForKey:[keys objectAtIndex:section]] count];
            
        }else{
            NSInteger count = 0;
            if (self.arrayFiles) {
                count = [self.arrayFiles count];
            }
            return count;
        }
//    }else{
//        return 0;
//    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.typeKnowledge == -1) {
        return 50.0;
    }
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (self.tableviewKnowledgeFile == tableView) {
        ///首页根目录
        if (self.typeKnowledge == -1) {
            static NSString *cellIdentifier = @"KnowledgeviewCellIdentifier";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell==nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                cell.accessoryType  = UITableViewCellAccessoryNone;
            }
            
            cell.textLabel.font = [UIFont systemFontOfSize:14.0];
            cell.textLabel.text = [self.arrayFiles objectAtIndex:indexPath.row];
            cell.imageView.image = [UIImage imageNamed:@"file_floder.png"];
            
            return cell;
        }else if (self.typeKnowledge == 0 && self.typeKnowledgeRequest == 0) {
            ///部门
            KnowledgeDepartmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KnowledgeDepartmentCellIdentify"];
            if (!cell)
            {
                NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"KnowledgeDepartmentCell" owner:self options:nil];
                cell = (KnowledgeDepartmentCell*)[array objectAtIndex:0];
                [cell awakeFromNib];
            }
            
            [cell setCellDetails:[[dicKeysDepartMents objectForKey:[keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]];
            
            return cell;
        }else{
            ///文件夹
            if ([[[self.arrayFiles objectAtIndex:indexPath.row] safeObjectForKey:@"type"] integerValue] == 0) {
                
                KnowledgeDirectorieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KnowledgeDirectorieCellIdentify"];
                if (!cell)
                {
                    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"KnowledgeDirectorieCell" owner:self options:nil];
                    cell = (KnowledgeDirectorieCell*)[array objectAtIndex:0];
                    [cell awakeFromNib];
                }
                
                [cell setCellFrame];
                [cell setContentDetails:[self.arrayFiles objectAtIndex:indexPath.row]];
                
                return cell;
            }else{
                KnowledgeFileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KnowledgeFileCellIdentify"];
                if (!cell)
                {
                    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"KnowledgeFileCell" owner:self options:nil];
                    cell = (KnowledgeFileCell*)[array objectAtIndex:0];
                    [cell awakeFromNib];
                }
               
                [cell setCellFrame:[self.arrayFiles objectAtIndex:indexPath.row]];
                [cell setContentDetails:[self.arrayFiles objectAtIndex:indexPath.row]];
                
                return cell;
            }
        }
    
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    if (tableView == self.tableviewKnowledgeFile) {
        ///首页根目录
        if (self.typeKnowledge == -1) {
            KnowledgeFileViewController *controller = [[KnowledgeFileViewController alloc] init];
            if (indexPath.row == 0) {
                controller.typeKnowledgeRequest = 0;
            }else{
                controller.typeKnowledgeRequest = 1;
            }
            controller.typeKnowledge = indexPath.row;
            controller.strTitle = [self.arrayFiles objectAtIndex:indexPath.row];
            controller.dirId = -1;
            controller.departmengOrGroupId = -1;
            controller.typeKnowledgeSearchView = 0;
            [self.navigationController pushViewController:controller animated:YES];
        }
        ///部门
        else if (self.typeKnowledge == 0 && self.typeKnowledgeRequest == 0) {
            NSDictionary *item = [[dicKeysDepartMents objectForKey:[keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
            NSLog(@"item:%@",item);
            searchDisplayController.active = NO;
            [self getKeysFromDepartments:self.arrayDepartments];
            [self.tableviewKnowledgeFile reloadData];
            
            KnowledgeFileViewController *controller = [[KnowledgeFileViewController alloc] init];
            ///获取文件
            controller.typeKnowledge = 0;
            controller.typeKnowledgeRequest = 1;
//            NSDictionary *item = [[dicKeysDepartMents objectForKey:[keys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
            controller.strTitle = [item safeObjectForKey:@"name"];
            controller.dirId = -1;
            controller.typeKnowledgeSearchView = self.typeKnowledgeSearchView;
            controller.typeKnowledgeSearchViewFirst = 1;
            controller.departmengOrGroupId = [[item safeObjectForKey:@"id"] longLongValue];
            
            [self.navigationController pushViewController:controller animated:YES];
        }else{

            ///文件夹
            if ([[[self.arrayFiles objectAtIndex:indexPath.row] safeObjectForKey:@"type"] integerValue] == 1) {
                KnowledgeFileViewController *controller = [[KnowledgeFileViewController alloc] init];
                controller.typeKnowledge = self.typeKnowledge;
                controller.typeKnowledgeRequest = 1;
                controller.strTitle = [[self.arrayFiles objectAtIndex:indexPath.row] safeObjectForKey:@"name"];
                controller.dirId = [[[self.arrayFiles objectAtIndex:indexPath.row] safeObjectForKey:@"id"] longLongValue];
                controller.departmengOrGroupId = self.departmengOrGroupId;
                controller.typeKnowledgeSearchView = self.typeKnowledgeSearchView;
                controller.typeKnowledgeSearchViewFirst = 1;
                [self.navigationController pushViewController:controller animated:YES];
            }else{
                __weak typeof(self) weak_self = self;
                KnowledgeFileDetailsViewController *controller = [[KnowledgeFileDetailsViewController alloc] init];
                controller.detailsOld = [self.arrayFiles objectAtIndex:indexPath.row];
                controller.indexRow = indexPath.row;
                controller.viewFrom = @"knowledge";
                controller.isNeedRightNavBtn = YES;
                ///更新收藏状态
                controller.UpdateFavStatus = ^(NSInteger row, NSString *action){
                    NSLog(@"----更新收藏状态--->");
                    [weak_self updateFavFlag:action index:row];
                };
                
                ///删除动态
                controller.DeleteFileFromService = ^(void){
                    [weak_self  getKnowledgeFileFromService];
                };
                
                [self.navigationController pushViewController:controller animated:YES];
            }
        }
//    }
//        else{
//        if (self.typeKnowledge == 0 && self.typeKnowledgeRequest == 0) {
//        }
//    }
}

#pragma mark -

#pragma mark - searchbar delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar1
{
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

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    ///刷新列表数据
    [self getKeysFromDepartments:self.arrayDepartments];
    [self.tableviewKnowledgeFile reloadData];
    ///滑动到最顶部
    [self.tableviewKnowledgeFile setContentOffset:CGPointZero animated:NO];
}


#pragma mark - 搜索相关
- (void)searchBar:(UISearchBar *)searchBar2 textDidChange:(NSString *)searchText;
{
    if (searchText != nil && searchText.length > 0) {
        ///根据关键词搜索
        [self searchResult:searchText];
    }
    else
    {
        ///清空search result
        ///
        [self getKeysFromDepartments:self.arrayDepartments];
    }
    //
    [self.tableviewKnowledgeFile reloadData];
    ///滑动到最顶部
    [self.tableviewKnowledgeFile setContentOffset:CGPointZero animated:NO];
}

///根据输入的关键词做匹配
-(void)searchResult:(NSString *)searchStr{
    NSLog(@"searchResult:%@",searchStr);
    [filterArray removeAllObjects];
    
    NSInteger countAll = 0;
    
    if (self.arrayDepartments) {
        countAll = [self.arrayDepartments count];
    }
    
    //所有数据
    for(int i=0; i < countAll; i++)
    {
        NSString *name = [[NSString alloc]init];
        name = [[self.arrayDepartments objectAtIndex:i]objectForKey:@"name"];
        NSLog(@"name:%@",name);
        if ([CommonFuntion searchResult:name searchText:searchStr]){
            [filterArray addObject:[self.arrayDepartments objectAtIndex:i]];
        }
    }
    NSLog(@"filterArray count:%ti",[filterArray count]);
    
    [self getKeysFromDepartments:filterArray];
    [self.tableviewKnowledgeFile reloadData];
}



#pragma mark - 更新收藏标记
-(void)updateFavFlag:(NSString *)action index:(NSInteger)row{
    NSLog(@"updateFavFlag  action:%@  section:%ti",action,row);
    
    ///我的知识库
    if (self.typeKnowledge == 1 && self.typeKnowledgeRequest == 1){
        pageNo = 1;
         [self getKnowledgeFileFromService];
    }else{
        NSInteger isfav = 1;
        if ([action isEqualToString:KNOWLEDGE_ADD_COLLECTION]) {
            isfav = 0;
        }else if([action isEqualToString:KNOWLEDGE_CANCEL_COLLECTION]){
            isfav = 1;
        }
        NSDictionary *item = [self.arrayFiles objectAtIndex:row];
        ///修改本地数据
        NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:item];
        [mutableItemNew setObject:[NSNumber numberWithInteger:isfav] forKey:@"hasFavorite"];
        //修改数据
        [self.arrayFiles setObject: mutableItemNew atIndexedSubscript:row];
        ///刷新当前cell
        [self.tableviewKnowledgeFile reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:row inSection:0],nil] withRowAnimation:UITableViewRowAnimationNone];
    }
    
}

@end
