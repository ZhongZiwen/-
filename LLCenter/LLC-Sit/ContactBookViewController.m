//
//  ContactBookViewController.m
//  lianluozhongxin
//
//  Created by Vescky on 14-6-24.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "ContactBookViewController.h"
#import "ContactsInfo.h"
#import "ContactBookAddNewLevel1ViewController.h"
#import "NSString+JsonHandler.h"
#import "ContactBookCell.h"
#import "CommonStaticVar.h"
#import "SitStatusViewController.h"
#import "LLCenterMenuPopView.h"
#import "MJRefresh.h"
#import "CommonFunc.h"
#import "CommonNoDataView.h"
#import "CustomPopView.h"

@interface ContactBookViewController (){
}

@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@end

@implementation ContactBookViewController

#pragma mark - life-cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"坐席";
    [self initData];
    [self setupRefresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initView];
    [self getDataFromServer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private
- (void)initData {
    dataSource = [[NSMutableArray alloc] init];
    
//    NSArray *groups = [[NSArray alloc] initWithObjects:@"销售业务组",@"产品设计组", @"增值业务组",@"售后服务组",@"研发组",nil];
//    
//    for (int i = 0; i < [groups count]; i++) {
//        NSString *groupTitle = [groups objectAtIndex:i];
//        int groupCount = arc4random() % 10 + 1;
//        NSMutableArray *groupArray = [[NSMutableArray alloc] initWithCapacity:groupCount];
//        for (int j = 0; j < groupCount; j++) {
//            ContactsInfo *contactsInfo = [[ContactsInfo alloc] init];
//            contactsInfo.name = [NSString stringWithFormat:@"%@No.%d",groupTitle,j];
//            contactsInfo.phoneNumber = [NSString stringWithFormat:@"%d%d21231000",i,j];
//            contactsInfo.jobNumber = [NSString stringWithFormat:@"%d",arc4random() % 5000];
//            [groupArray addObject:contactsInfo];
//        }
//        
//        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:groupTitle,@"title",groupArray,@"data", nil];
//        CellDataInfo *cInfo = [[CellDataInfo alloc] initWithCellDataInfo:dict expandable:YES expanded:YES];
//        [dataSource addObject:cInfo];
//    }
//    
//    [tbView reloadData];
    
    //
}

- (void)initView {
    
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
    self.tabBarController.navigationItem.rightBarButtonItems = nil;
    ///boss可增加
    if (![[CommonStaticVar getAccountType] isEqualToString:@"boss"]) {
        return;
    }
    
    
    UIButton *rightButton=[UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame=CGRectMake(0, 0, 25, 16);
    [rightButton setBackgroundImage:[UIImage imageNamed:@"icon_more_function.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"icon_more_function.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(rightBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.tabBarController.navigationItem.rightBarButtonItem = rightBarButton;
    
    
//    UIButton* filterButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];//
//    [filterButton setImage:[UIImage imageNamed:@"contact_add_new.png"] forState:UIControlStateNormal];
//    [filterButton setTitleColor:GetColorWithRGB(0, 110, 255) forState:UIControlStateNormal];
//    [filterButton setTitleColor:GetColorWithRGB(0, 150, 255) forState:UIControlStateHighlighted];
//    [filterButton setShowsTouchWhenHighlighted:YES];
//    [filterButton addTarget:self action:@selector(rightBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem* actionItem= [[UIBarButtonItem alloc] initWithCustomView:filterButton];
////    [self.navigationItem setRightBarButtonItem:actionItem];
//    self.tabBarController.navigationItem.rightBarButtonItem = actionItem;
    
}


-(void)addNavBar{
    
}

- (void)rightBarButtonAction {
    /*
    NSLog(@"self.navigationController.view.frame:%@",NSStringFromCGRect(self.navigationController.view.frame));
    NSLog(@"self.view.frame:%@",NSStringFromCGRect(self.view.frame));
    
    ContactBookAddNewLevel1ViewController *addNew = [[ContactBookAddNewLevel1ViewController alloc] init];
    [self.navigationController pushViewController:addNew animated:YES];
    */
    
    [self showPopView];
}


-(void)showPopView{
    CustomPopView *popView = [[CustomPopView alloc] initWithPoint:CGPointMake(0, 64+64) titles:@[@"新增坐席", @"查看坐席状态"] imageNames:@[@"icon_add_sit.png", @"icon_status_sit.png"]];
    __weak typeof(self) weak_self = self;
    popView.selectBlock = ^(NSInteger index) {
        if (index == 0) {
            [weak_self addNewSitView];
        }else if (index == 1){
            [self gotoSitStatus];
        }
    };
    [popView show];
}

///新增座席
-(void)addNewSitView{
    NSLog(@"self.navigationController.view.frame:%@",NSStringFromCGRect(self.navigationController.view.frame));
    NSLog(@"self.view.frame:%@",NSStringFromCGRect(self.view.frame));
    
    ContactBookAddNewLevel1ViewController *addNew = [[ContactBookAddNewLevel1ViewController alloc] init];
//    [self.navigationController pushViewController:addNew animated:YES];
    [self.tabBarController.navigationController pushViewController:addNew animated:YES];
}

///座席状态
-(void)gotoSitStatus{
    SitStatusViewController *statusC = [[SitStatusViewController alloc] init];
    [self.tabBarController.navigationController pushViewController:statusC animated:YES];
}


- (float)getContactBookCellHeight:(CellDataInfo*)cInfo {
    if (cInfo.expanded) {
        return [[cInfo.cellDataInfo objectForKey:@"data"] count] * 50.f + 40.f;
    }
    else {
        return 40.0f;
    }
}

- (void)getDataFromServer {
    [self clearViewNoData];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_SIT_LIST_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            NSString *data = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"];
            NSArray *arr = [data toJsonValue];
            NSLog(@"arr:%@",arr);
            
            if (arr && arr.count > 0) {
                //                tbView.hidden = NO;
                labelTips.hidden = YES;
                //                [self fillDataSource:arr];
                [self fillDataSourceByThreeGroup:arr];
                [tbView reloadData];
            }
            else {
                //                tbView.hidden = YES;
                labelTips.hidden = YES;
                labelTips.text = @"请添加坐席";
                [self setViewNoData:@"请添加坐席"];
            }
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getDataFromServer];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
            
            //            tbView.hidden = YES;
            labelTips.hidden = YES;
            labelTips.text = @"暂无数据~";
            [self setViewNoData:@"暂无坐席"];
        }
        [self reloadRefeshView];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        [self reloadRefeshView];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        //        tbView.hidden = YES;
        labelTips.hidden = YES;
        labelTips.text = @"暂无数据~";
        [self setViewNoData:@"暂无坐席"];
    }];
}

// 2014-12-19
-(void)fillDataSourceByThreeGroup:(NSArray *)arr{
    
    if (dataSource) {
        [dataSource removeAllObjects];
    }
    
    // 接听座席组，外呼座席组，未分配座席
    NSArray *inList = nil;
    NSArray *outList = nil;
    NSArray *otherList = nil;
    
    if (arr != nil  && [arr count] > 0) {
        NSDictionary *dic = [arr objectAtIndex:0];
        
        NSLog(@"席座数据:%@",dic);
        
        if (dic != nil && [dic objectForKey:@"inList"] != nil) {
            inList = [dic objectForKey:@"inList"];
            [self setSourceDataByGroup:inList andGroupName:@"接听坐席组"];
        }
        
        if (dic != nil && [dic objectForKey:@"outList"] != nil) {
            outList = [dic objectForKey:@"outList"];
            [self setSourceDataByGroup:outList andGroupName:@"外呼坐席组"];
        }
        
        if (dic != nil && [dic objectForKey:@"otherList"] != nil) {
            otherList = [dic objectForKey:@"otherList"];
            [self setSourceDataByGroup:otherList andGroupName:@"未分配坐席"];
        }

    }
//    NSLog(@"inList:%@",inList);
//    NSLog(@"outList:%@",outList);
//    NSLog(@"otherList:%@",otherList);
}

// 根据组数据重新组织
-(void)setSourceDataByGroup:(NSArray *)groupData andGroupName:(NSString *)groupName
{
    /*
     { 
     ID : a0ab5e31-e7c8-41d7-a56c-453144a6374c ,
     USERNAME : \U4e8c\U4e8c\U5c14\U5c14 , 
     USERCODE : 2349 , 
     INPHONE :null, 
     OUTNPHONE :null
     }
  userId,name,jobNumber,phoneNumber,departmentNameList,departmentIdList
     
     */
    NSInteger count = 0;
    if (groupData != nil) {
        count = [groupData count];
    }
    NSLog(@"count:%li",(long)count);
   
    // 组织的数据
    NSMutableArray *groupArray = [[NSMutableArray alloc] init];
    //
    for (int j = 0; j < count; j++) {
        NSDictionary *dict = [groupData objectAtIndex:j];
        ContactsInfo *contactsInfo = [[ContactsInfo alloc] init];
        
        if ([dict objectForKey:@"USERNAME"] && ![[dict objectForKey:@"USERNAME"] isKindOfClass:NSClassFromString(@"NSNull")]) {
            contactsInfo.name = [NSString stringWithFormat:@"%@",[dict safeObjectForKey:@"USERNAME"]];
        }
        
        if ([dict objectForKey:@"PHONENO"] && ![[dict objectForKey:@"PHONENO"] isKindOfClass:NSClassFromString(@"NSNull")]) {
                contactsInfo.phoneNumber = [NSString stringWithFormat:@"%@",[dict safeObjectForKey:@"PHONENO"]];
        }
        
        if ([dict objectForKey:@"USERCODE"] && ![[dict objectForKey:@"USERCODE"] isKindOfClass:NSClassFromString(@"NSNull")]) {
            contactsInfo.jobNumber = [NSString stringWithFormat:@"%@",[dict safeObjectForKey:@"USERCODE"]];
        }
        
        contactsInfo.userId = [dict objectForKey:@"ID"];
        contactsInfo.departmentNameList = [NSString stringWithFormat:@"%@",groupName];
        contactsInfo.departmentIdList = [NSString stringWithFormat:@"%@",[dict objectForKey:@"ID"]];
        [groupArray addObject:contactsInfo];
    }
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:groupName,@"title",groupArray,@"data", nil];
    // 默认都展开
    CellDataInfo *cInfo = [[CellDataInfo alloc] initWithCellDataInfo:dict expandable:YES expanded:YES];
    [dataSource addObject:cInfo];
}


// 未使用
- (void)fillDataSource:(NSArray*)arr {
    if (dataSource) {
        [dataSource removeAllObjects];
    }
    
    NSInteger count = 0;
    if (arr != nil ) {
        count = [arr count];
    }
    NSLog(@"count = %li",(long)count);
    
    for (int i = 0; i < [arr count]; i++) {
        
        /*
         NSDictionary *departmentDict = [arr objectAtIndex:i];
         NSArray *departmentMembers = [departmentDict objectForKey:@"agents"];
         NSString *departmentName = [departmentDict objectForKey:@"deptName"];
         */
        
        NSDictionary *departmentDict = [arr objectAtIndex:i];
        
        NSLog(@"departmentDict:%@",departmentDict);
        
        NSArray *departmentMembers = [departmentDict objectForKey:@"agents"];
        NSString *departmentName = [departmentDict objectForKey:@"deptName"];
        
        
        NSMutableArray *groupArray = [[NSMutableArray alloc] init];
        
        for (int j = 0; j < [departmentMembers count]; j++) {
            NSDictionary *dict = [departmentMembers objectAtIndex:j];
            ContactsInfo *contactsInfo = [[ContactsInfo alloc] init];
            
            
            if ([dict objectForKey:@"USERNAME"] && ![[dict objectForKey:@"USERNAME"] isKindOfClass:NSClassFromString(@"NSNull")]) {
                contactsInfo.name = [NSString stringWithFormat:@"%@",[dict safeObjectForKey:@"USERNAME"]];
            }
            if ([dict objectForKey:@"BIND_PHONENO"] && ![[dict objectForKey:@"BIND_PHONENO"] isKindOfClass:NSClassFromString(@"NSNull")]) {
                contactsInfo.phoneNumber = [NSString stringWithFormat:@"%@",[dict safeObjectForKey:@"BIND_PHONENO"]];
            }
            if ([dict objectForKey:@"USERCODE"] && ![[dict objectForKey:@"USERCODE"] isKindOfClass:NSClassFromString(@"NSNull")]) {
                contactsInfo.jobNumber = [NSString stringWithFormat:@"%@",[dict safeObjectForKey:@"USERCODE"]];
            }
            
            contactsInfo.userId = [dict objectForKey:@"ID"];
            contactsInfo.departmentNameList = [NSString stringWithFormat:@"%@",[dict objectForKey:@"DEPT_NAME"]];
            contactsInfo.departmentIdList = [NSString stringWithFormat:@"%@",[dict safeObjectForKey:@"DEPT_ID"]];
            [groupArray addObject:contactsInfo];
        }
        
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:departmentName,@"title",groupArray,@"data", nil];
        CellDataInfo *cInfo = [[CellDataInfo alloc] initWithCellDataInfo:dict expandable:YES expanded:YES];
        [dataSource addObject:cInfo];
    }
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    static NSString *CellIdentifier = @"ContactBookCell";//cell重用标识
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];//设置这个cell的重用标识
    
    //若cell为nil，重新alloc一个cell
    if(!cell){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ContactBookCell" owner:self options:nil] objectAtIndex:0];
    }
     */
    
    ContactBookCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactBookCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ContactBookCell" owner:self options:nil];
        cell = (ContactBookCell*)[array objectAtIndex:0];
        [cell setCellViewFrame];
    }
    
    CellDataInfo *currentCellDataInfo = [dataSource objectAtIndex:indexPath.row];
    
    cell.tag = indexPath.row;
    
    [cell setCellDataInfo:currentCellDataInfo];
    [cell setParentViewController:self];
    
    /*
    if([cell respondsToSelector:@selector(setCellDataInfo:)]){
        [cell performSelector:@selector(setCellDataInfo:) withObject:currentCellDataInfo];
    }
    if([cell respondsToSelector:@selector(setParentViewController:)]){
        [cell performSelector:@selector(setParentViewController:) withObject:self];
    }
     */
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CellDataInfo *cInfo = [dataSource objectAtIndex:indexPath.row];
    return [self getContactBookCellHeight:cInfo];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@",NSStringFromCGRect(tbView.frame));
    [tbView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"Cell No.%ld clicked",indexPath.row);
    
    CellDataInfo *currentCellDataInfo = [dataSource objectAtIndex:indexPath.row];
    if (currentCellDataInfo.expandable) {
        currentCellDataInfo.expanded = !currentCellDataInfo.expanded;
        //刷新单个cell
        [tbView reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}



#pragma mark - 上拉下拉刷新相关事件
//集成刷新控件
- (void)setupRefresh
{
    NSString *dateKey = @"crmcustomer";
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [tbView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:dateKey];

}


// 结束加载
-(void)reloadRefeshView{
    // 刷新列表
    [tbView reloadData];
    [tbView headerEndRefreshing];
}

// 下拉
- (void)headerRereshing
{
    NSLog(@"headerRereshing--下拉-->");
    [self getDataFromServer];
}



#pragma mark - 没有数据时的view
-(void)setViewNoData:(NSString *)title{
    if (dataSource == nil || [dataSource count] == 0) {
        self.commonNoDataView = [CommonFunc commonNoDataViewIcon:@"list_empty.png" Title:title optionBtnTitle:@""];
    }
    [tbView addSubview:self.commonNoDataView];
}

-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
    }
}


@end
