//
//  NavigationListViewController.m
//  
//
//  Created by sungoin-zjp on 16/1/6.
//
//

#import "NavigationListViewController.h"
#import "CommonFunc.h"
#import "MJRefresh.h"
#import "CommonNoDataView.h"
#import "NavigationItemCell.h"
#import "LLCenterSheetMenuModel.h"
#import "NSString+JsonHandler.h"
#import "AddNewNavigationViewController.h"
#import "CommonStaticVar.h"


@interface NavigationListViewController ()<UITableViewDataSource,UITableViewDelegate>{
    
    NSMutableString *strSelectedName;
    NSMutableString *strSelectedIds;
}


@property(strong,nonatomic) UITableView *tableview;
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property(strong,nonatomic) NSMutableArray *dataSource;

@end

@implementation NavigationListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"加入分组";
    self.view.backgroundColor = COLOR_BG;
    [self addBackBtn];
    
    [self addNarBarByOption];
    
    [self initData];
    [self initTableview];
    ///获取列表
    [self getGroups];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self RegistNotificationForUpdate];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeNotificationForUpdate];
}


-(void)addNarBarByOption{
    ///开通IVR功能
    if ([CommonStaticVar getIvrStatus] == 1) {
        
        ///boss可增加
        if (![[CommonStaticVar getAccountType] isEqualToString:@"boss"]) {
            return;
        }
        
        ///当前导航是否有开再下一级导航的权限0-是，1-否
        if ([[self.navigationDic safeObjectForKey:@"navigationHasChild"] integerValue] != 0) {
            return;
        }
        
        ///没有设置下级导航
        if([[self.navigationDic safeObjectForKey:@"navigationsetChild"] integerValue] == 0){
            return;
        }
        
        [self addNarBar];
    }
}

#pragma mark - 注册通知
-(void)RegistNotificationForUpdate
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUIForUpdateNavigationList) name:LLC_NOTIFICATON_NAVIGATION_LIST object:nil];
}
// 移除通知
-(void)removeNotificationForUpdate
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LLC_NOTIFICATON_NAVIGATION_LIST object:nil];
}

-(void)refreshUIForUpdateNavigationList{
    [self getGroups];
}

#pragma mark - 初始化data
-(void)initData{
    self.dataSource = [[NSMutableArray alloc] init];
}



#pragma mark - Nar Bar

-(void)addBackBtn{
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPress)];
    self.navigationItem.leftBarButtonItem = leftButton;
}

-(void)addNarBar{
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightBarButtonAction)];
    self.navigationItem.rightBarButtonItem = addButton;
}

-(void)backButtonPress{
    [self showBackAlert];
}


///新增
-(void)rightBarButtonAction{
    AddNewNavigationViewController *controller = [[AddNewNavigationViewController alloc] init];
    controller.navigationDic = self.navigationDic;
    __weak typeof(self) weak_self = self;
    controller.NotifyNavigationList = ^(){
        [weak_self getGroups];
    };
    [self.navigationController pushViewController:controller animated:YES];
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
    NavigationItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NavigationItemCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"NavigationItemCell" owner:self options:nil];
        cell = (NavigationItemCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    
    [cell setCellDetail:[self.dataSource objectAtIndex:indexPath.row]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    LLCenterSheetMenuModel *model = [self.dataSource objectAtIndex:indexPath.row];
    if([model.selectedFlag isEqualToString:@"yes"]){
        model.selectedFlag = @"";
    }else{
        model.selectedFlag = @"yes";
    }
    [self.tableview reloadData];
}


#pragma mark - 上拉下拉刷新相关事件
//集成刷新控件
- (void)setupRefresh
{
    NSString *dateKey = @"llcsitlist";
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [self.tableview addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:dateKey];
    
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
    [self getGroups];
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

- (void)getGroups {
    
    [self clearViewNoData];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    NSString *action = @"";
    
    if([self.navigationType isEqualToString:@"all"]){
        action = LLC_GET_GH_AND_ISDEPT_ACTION;
    }else{
        action = LLC_GET_GH_AND_ISDEPT_ACTION;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,action] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"分组数据jsonResponse:%@",jsonResponse);
        
        NSArray *deptList;
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
             deptList = [[[jsonResponse objectForKey:@"resultMap"] objectForKey:@"childs"] toJsonValue];
        }
        
//        if([self.navigationType isEqualToString:@"all"]){
//            deptList = [[[jsonResponse objectForKey:@"resultMap"] objectForKey:@"childs"] toJsonValue];
//        }else{
//            deptList = [[[jsonResponse objectForKey:@"resultMap"] objectForKey:@"childs"] toJsonValue];
//        }
        
        [self.dataSource removeAllObjects];
        if(deptList == nil || [deptList count] == 0){
            [self setViewNoData:@""];
        }else{
            [self transFormData:deptList];
        }
        [self reloadRefeshView];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        [self.dataSource removeAllObjects];
        [self setViewNoData:@"加载失败"];
        [self reloadRefeshView];
    }];
}


///数据转换
-(void)transFormData:(NSArray *)array{
    LLCenterSheetMenuModel *model;
    NSInteger count = 0;
    if (array) {
        count = [array count];
    }
    NSDictionary *item;
    for (int i=0; i<count; i++) {
        item = [array objectAtIndex:i];
        model = [[LLCenterSheetMenuModel alloc]init];
        model.title = [item safeObjectForKey:@"DEPT_NAME"];
        model.itmeId = [item safeObjectForKey:@"DEPT_ID"];
        model.selectedFlag = @"";
        [self.dataSource addObject:model];
    }
    [self initSelectedFlagByDefauleData];
}

///当前导航是否已选择
-(BOOL)isSelectedNavigation:(NSString *)itemId{
    NSInteger count = 0;
    if (self.dataSource) {
        count = [self.dataSource count];
    }
    LLCenterSheetMenuModel *model;
    for (int i=0; i<count; i++) {
        model = [self.dataSource objectAtIndex:i];
        if([model.itmeId isEqualToString:itemId]){
            return YES;
        }
    }
    return FALSE;
}

///用默认数据初始化选择状态
-(void)initSelectedFlagByDefauleData{
    NSArray *arrDefault = [self.navigationSelectedIds componentsSeparatedByString:@","];
    NSInteger countDefault = 0;
    if(arrDefault){
        countDefault = [arrDefault count];
    }
    
    NSInteger countAll = 0;
    if(self.dataSource){
        countAll = [self.dataSource count];
    }
    LLCenterSheetMenuModel *model;
    BOOL isFound = FALSE;
    for(int i=0; i<countDefault; i++){
        isFound = FALSE;
        for(int k=0; !isFound && k<countAll; k++){
            model = [self.dataSource objectAtIndex:k];
            if([[arrDefault objectAtIndex:i] isEqualToString:model.itmeId])
            {
                isFound = TRUE;
                model.selectedFlag = @"yes";
            }
        }
    }
    [self.tableview reloadData];
}

///已选择的导航
-(void)selectedNavitions{
    strSelectedName = [[NSMutableString alloc] init];
    strSelectedIds = [[NSMutableString alloc] init];
    NSInteger count = 0;
    if (self.dataSource) {
        count = [self.dataSource count];
    }
    LLCenterSheetMenuModel *model;
    for (int i=0; i<count; i++) {
        model = [self.dataSource objectAtIndex:i];
        if([model.selectedFlag isEqualToString:@"yes"]){
            
            if ([strSelectedName isEqualToString:@""]) {
                [strSelectedName appendString:model.title];
            }else{
                [strSelectedName appendString:@","];
                [strSelectedName appendString:model.title];
            }
            
            
            if ([strSelectedIds isEqualToString:@""]) {
                [strSelectedIds appendString:model.itmeId];
            }else{
                [strSelectedIds appendString:@","];
                [strSelectedIds appendString:model.itmeId];
            }
        }
    }
    
    NSLog(@"strSelectedName:%@",strSelectedName);
    NSLog(@"strSelectedIds:%@",strSelectedIds);
}


#pragma mark - UIAlertView

///删除提示框
-(void)showBackAlert{
    [self selectedNavitions];
    
    if (![self.navigationSelectedIds isEqualToString:strSelectedIds]) {
        UIAlertView *alertCall = [[UIAlertView alloc] initWithTitle:nil message: @"添加已选择的分组到坐席?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        [alertCall show];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //删除
    if (buttonIndex == 1) {
        if (self.SelectNavigation) {
            self.SelectNavigation(strSelectedName,strSelectedIds);
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
