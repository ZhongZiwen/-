//
//  AddSitToNavigationViewController.m
//  
//
//  Created by sungoin-zjp on 16/1/6.
//
//

#import "AddSitToNavigationViewController.h"
#import "CommonFunc.h"
#import "MJRefresh.h"
#import "CommonNoDataView.h"
#import "AddSitToNavigationCell.h"
#import "NavigationListViewController.h"

@interface AddSitToNavigationViewController ()<UITableViewDataSource,UITableViewDelegate>{
    //分页加载
    int listPage;
    NSInteger pageSize;
    ///坐席ids
    NSString *strSitIds;
}

@property(strong,nonatomic) UITableView *tableview;
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property(strong,nonatomic) NSMutableArray *dataSource;

@end

@implementation AddSitToNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"添加坐席";
    self.view.backgroundColor = COLOR_BG;
    
    [self addBackBarBtn];
    [self initData];
    [self initTableview];
    
    [self getNavigationSitList];
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

#pragma mark - 初始化data
-(void)initData{
    self.dataSource = [[NSMutableArray alloc] init];
    listPage = 1;
    strSitIds = @"";
}


#pragma mark - Nar Bar
-(void)addBackBarBtn{
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPress)];
    self.navigationItem.leftBarButtonItem = leftButton;
}

-(void)addNarBar{
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonAction)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

-(void)cancelButtonPress{

    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[NavigationListViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
    [self notifyData];
}

///保存
-(void)rightBarButtonAction{
    strSitIds = [self getCheckedSitIds];
    NSLog(@"strSitIds:%@",strSitIds);
    
    if ([strSitIds isEqualToString:@""]) {
        [CommonFuntion showToast:@"请选择坐席" inView:self.view];
        return;
    }
    [self showAlertBySelected];
}


///选择的坐席
-(void)showAlertBySelected{
    
    UIAlertView *alertCall = [[UIAlertView alloc] initWithTitle:nil message: @"添加选择的坐席到当前分组?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertCall.tag = 101;
    [alertCall show];
}


#pragma mark alertView的回调函数
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 101)
    {
        if(buttonIndex == 0)
        {
            return;
        }
        else if(buttonIndex == 1)
        {
            [self addSitsToNavigation];
        }
    }
}


#pragma maerk - 获取选择坐席
-(NSString *)getCheckedSitIds{
    NSInteger count = 0;
    if(self.dataSource){
        count = [self.dataSource count];
    }
    NSMutableString *strIds = [[NSMutableString alloc] init];
    NSDictionary *item;
    for (int k=0; k<count; k++) {
        item = [self.dataSource objectAtIndex:k];
        ///选中的坐席
        if ([[item objectForKey:@"checked"] boolValue]) {
            if ([strIds isEqualToString:@""]) {
                [strIds appendString:[item safeObjectForKey:@"sitId"]];
            }else{
                [strIds appendString:@","];
                [strIds appendString:[item safeObjectForKey:@"sitId"]];
            }
        }
    }
    return strIds;
}

#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStylePlain];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.sectionFooterHeight = 0;
    
    [self.view addSubview:self.tableview];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableview setTableFooterView:v];
    
    ///下拉刷新
    [self setupRefresh];
}


#pragma mark - tableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataSource) {
        return [self.dataSource count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddSitToNavigationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddSitToNavigationCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"AddSitToNavigationCell" owner:self options:nil];
        cell = (AddSitToNavigationCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    
    [cell setCellDetail:[self.dataSource objectAtIndex:indexPath.row]];
    
//    __weak typeof(self) weak_self = self;
//    cell.CheckBoxBlock = ^(void){
//        [weak_self updateCheckBoxStatus:indexPath.row];
//    };
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self updateCheckBoxStatus:indexPath.row];
}


#pragma mark - 上拉下拉刷新相关事件
//集成刷新控件
- (void)setupRefresh
{
    NSString *dateKey = @"llcallsitlist";
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [self.tableview addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:dateKey];
    //上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableview addFooterWithTarget:self action:@selector(footerRereshing)];
}


// 结束加载
-(void)reloadRefeshView{
    // 刷新列表
    [self.tableview reloadData];
    [self.tableview headerEndRefreshing];
}


// 下拉
- (void)headerRereshing
{
    NSLog(@"headerRereshing--下拉-->");
    
    if ([self.tableview isFooterRefreshing]) {
        [self.tableview headerEndRefreshing];
        return;
    }
    
    ///下拉
    listPage = 1;
    [self getNavigationSitList];
}

// 上拉
- (void)footerRereshing
{
    NSLog(@"footerRereshing--上拉-->");
    
    if ([self.tableview isHeaderRefreshing]) {
        [self.tableview footerEndRefreshing];
        return;
    }
    //上拉加载更多
    [self getNavigationSitList];
}


#pragma mark - 没有数据时的view
-(void)setViewNoData:(NSString *)title{
    if (self.dataSource == nil || [self.dataSource count] == 0) {
        self.commonNoDataView = [CommonFunc commonNoDataViewIcon:@"list_empty.png" Title:title optionBtnTitle:@""];
    }
    [self.tableview addSubview:self.commonNoDataView];
}

-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
    }
}

#pragma mark - 网络请求
#pragma mark - 获取当前导航的坐席列表
-(void)getNavigationSitList{
    
    [self clearViewNoData];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    ///非根目录则传

    [rDict setValue:[NSString stringWithFormat:@"%i",listPage] forKey:@"pageNo"];
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_QUERY_BATCH_SEATS_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"坐席jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [self setViewRequestSusscess:jsonResponse];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getNavigationSitList];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            [self setViewNoData:@"加载失败"];
            [CommonFuntion showToast:desc inView:self.view];
        }
        [self reloadRefeshView];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        [self reloadRefeshView];
        if (!self.dataSource || [self.dataSource count] == 0) {
            [self setViewNoData:@"加载失败"];
        }
    }];
    
}


// 请求成功时数据处理
-(void)setViewRequestSusscess:(NSDictionary *)jsonResponse
{
    id data = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"resultList"];
    
    
    if ([data respondsToSelector:@selector(count)] && [data count] > 0) {
        
        if (listPage == 1) {
            [self addNarBar];
            [self.dataSource removeAllObjects];
            pageSize = [data count];
        }
        
        ///添加check标识
        [self transData:data];
        
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
        if (!self.dataSource || [self.dataSource count] == 0) {
            [self setViewNoData:@"暂无坐席"];
        }
    }
}

// 请求失败时数据处理
-(void)setViewRequestFaild:(NSString *)desc
{
     [self setViewNoData:@"加载失败"];
}


///添加check标识
-(void)transData:(NSArray *)array{
    
    NSInteger count = 0;
    if (array) {
        count = [array count];
    }
    
    NSDictionary *item;
    NSMutableDictionary *mutableItem;
    
    for (int i=0; i<count; i++) {
        item = [array objectAtIndex:i];
        mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
        [mutableItem setObject:@(NO) forKey:@"checked"];
        [self.dataSource addObject:mutableItem];
    }
}


///更新check标识
-(void)updateCheckBoxStatus:(NSInteger)index{
    NSLog(@"----updateCheckBoxStatus--:%ti",index);
    NSDictionary *item = [self.dataSource objectAtIndex:index];
    
    NSMutableDictionary *mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
    [mutableItem setObject:@(![[item objectForKey:@"checked"] boolValue]) forKey:@"checked"];
    [self.dataSource replaceObjectAtIndex:index withObject:mutableItem];
    [self.tableview reloadData];
}


#pragma mark - 网络请求
#pragma mark - 添加坐席到导航

-(void)addSitsToNavigation{

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    [rDict setValue: self.navigationId forKey:@"navigationId"];
    [rDict setValue:strSitIds forKey:@"sitIds"];
    
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_ADD_BATCH_SEATS_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            [CommonFuntion showToast:@"添加成功" inView:self.view];
            [self actionSuccess];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self addSitsToNavigation];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"添加失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
    
}

#pragma mark - 返回到前一页
-(void)actionSuccess{
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(gobackView)
                                   userInfo:nil repeats:NO];
}

-(void)gobackView{
    [self cancelButtonPress];
}

#pragma mark - 刷新数据
//当前view消失时发送通知
-(void)notifyData{
    [NSTimer scheduledTimerWithTimeInterval:0.2
                                     target:self
                                   selector:@selector(sendNotificationUpdateNavigationList)
                                   userInfo:nil repeats:NO];
}

//通知UI刷新
-(void)sendNotificationUpdateNavigationList{
    [[NSNotificationCenter defaultCenter] postNotificationName:LLC_NOTIFICATON_NAVIGATION_LIST object:self];
}

@end
