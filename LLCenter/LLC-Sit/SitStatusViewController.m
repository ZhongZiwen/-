//
//  SitStatusViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-12.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "SitStatusViewController.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"
#import "CommonNoDataView.h"
#import "SitStatusCell.h"
#import "ContactsInfo.h"
#import "ContactBookDetailViewController.h"

@interface SitStatusViewController ()<UITableViewDataSource,UITableViewDelegate>{
    
    BOOL isRequestSuccess;
    
    ///旋转角度
    CGFloat imageviewAngle;
    ///旋转ImageView
    UIImageView *imageView;
    ///旋转状态
    RotateState rotateState;
    
    ///请求状态
    BOOL isRequestStatus;
}

@property(strong,nonatomic) UITableView *tableviewSitStatus;
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property(strong,nonatomic) NSArray *arrayData;
@property(strong,nonatomic) NSMutableArray *arrayMutableData;
@end

@implementation SitStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title  =@"坐席状态";
    self.view.backgroundColor = COLOR_BG;
//    [self addNarBar];
    [self buildBarButtonItem];
    self.arrayMutableData = [[NSMutableArray alloc] init];
//    [self readTestData];
    [self initTableview];
    [self getSiteStatus];
    [self.tableviewSitStatus reloadData];
}


#pragma mark  添加 RightBarButtonItem
-(void)buildBarButtonItem{
    [super customBackButton];
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_data_notify.png"]];
    imageView.autoresizingMask = UIViewAutoresizingNone;
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.bounds=CGRectMake(0, 0, 20, 20);
    //设置视图为圆形
    imageView.layer.masksToBounds=YES;
//    imageView.layer.cornerRadius=20.f;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 20, 20);
    [button addSubview:imageView];
    [button addTarget:self action:@selector(animate) forControlEvents:UIControlEventTouchUpInside];
    imageView.center = button.center;
    //设置RightBarButtonItem
    UIBarButtonItem  *barItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barItem;
    
}


#pragma mark  点击 RightBarButtonItem
- (void)animate {
    //改变ImageView旋转状态
    if (rotateState==RotateStateStop) {
        rotateState=RotateStateRunning;
        [self rotateAnimate];
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [self getSiteStatus];
    }else{
        rotateState=RotateStateStop;
    }
}


#pragma mark 旋转动画
-(void)rotateAnimate{
    imageviewAngle+=90;
    //0.3秒旋转90度
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        imageView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(imageviewAngle));
    } completion:^(BOOL finished) {
        if (rotateState==RotateStateRunning) {
            [self rotateAnimate];
        }
    }];
}


#pragma mark - Nar Bar
-(void)addNarBar{
    [super customBackButton];
    
    UIButton *rightButton=[UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame=CGRectMake(0, 0, 21, 20);
    [rightButton setBackgroundImage:[UIImage imageNamed:@"icon_data_notify.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"icon_data_notify.png"] forState:UIControlStateHighlighted];
    
    [rightButton addTarget:self action:@selector(rightBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    [self.navigationItem setRightBarButtonItem:rightBarButton];
}


///刷新
-(void)rightBarButtonAction{
    [self getSiteStatus];
}


#pragma mark - 初始化数据
-(void)initData{
    
    if (self.arrayMutableData && [self.arrayMutableData count] > 0) {
        [self.arrayMutableData removeAllObjects];
    }
    
    [self.arrayMutableData addObjectsFromArray:self.arrayData];
    ///初始化open标记
    NSInteger count = 0;
    if (self.arrayMutableData) {
        count = [self.arrayMutableData count];
    }
    NSDictionary *item;
    NSMutableDictionary *mutableItemNew;
    for (int i=0; i<count; i++) {
        item = [self.arrayMutableData objectAtIndex:i];
        mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:item];
        [mutableItemNew setValue:@(YES) forKey:@"open"];
        [self.arrayMutableData setObject: mutableItemNew atIndexedSubscript:i];
    }
    
    NSLog(@"self.arrayMutableData:%@",self.arrayMutableData);
}


#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewSitStatus = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-64) style:UITableViewStyleGrouped];
    self.tableviewSitStatus.delegate = self;
    self.tableviewSitStatus.dataSource = self;
    self.tableviewSitStatus.sectionFooterHeight = 0;
    self.tableviewSitStatus.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:self.tableviewSitStatus];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewSitStatus setTableFooterView:v];
    
}


#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.arrayMutableData) {
        return [self.arrayMutableData count];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSDictionary *dict = [self.arrayMutableData objectAtIndex:section];
    if ([[dict objectForKey:@"open"] boolValue]) {
        return [[dict objectForKey:@"seats"] count];
    }else {
        return 0;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 40)];
    headview.backgroundColor = [UIColor whiteColor];
    headview.tag = section;
    //    [headview addLineUp:NO andDown:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewTap:)];
    [headview addGestureRecognizer:tap];
    
    ///底部分割线
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 39, DEVICE_BOUNDS_WIDTH, 1)];
    line.image = [UIImage imageNamed:@"line.png"];
    [headview addSubview:line];
    
    
    ///title
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 120, 39)];
    labelTitle.font = [UIFont boldSystemFontOfSize:13.0];
    
    labelTitle.textAlignment = NSTextAlignmentLeft;
    labelTitle.textColor = COLOR_LIGHT_BLUE;
    labelTitle.text = [self getHeadViewTitle:section];
    [headview addSubview:labelTitle];
    
    
    ///title
    UILabel *labelTitleInfo = [[UILabel alloc] initWithFrame:CGRectMake(150, 0, (DEVICE_BOUNDS_WIDTH-150-30), 39)];
    labelTitleInfo.font = [UIFont boldSystemFontOfSize:13.0];
    labelTitleInfo.textAlignment = NSTextAlignmentLeft;
    labelTitleInfo.textColor = COLOR_LIGHT_BLUE;
    labelTitleInfo.text = [self getHeadViewTitleInfos:section];
    [headview addSubview:labelTitleInfo];
    
    
    NSLog(@"---viewForHeaderInSection--->");
    ///icon
    UIImageView *icon = [[UIImageView alloc] init];
    icon.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-31, 16, 14, 8);
    
    NSDictionary *dict = [self.arrayMutableData objectAtIndex:headview.tag];
    BOOL isOpen = [[dict objectForKey:@"open"] boolValue];
    if (isOpen) {
        icon.image = [UIImage imageNamed:@"btn_to_up_blue.png"];
    }else{
        icon.image = [UIImage imageNamed:@"btn_to_down_blue.png"];
    }
    
    icon.tag = 1001+section;
    [headview addSubview:icon];
    
    return headview;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SitStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SitStatusCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SitStatusCell" owner:self options:nil];
        cell = (SitStatusCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    NSArray *arrSeats = [[self.arrayMutableData objectAtIndex:indexPath.section] objectForKey:@"seats"];
    
    if (arrSeats && indexPath.row < [arrSeats count]) {
        [cell setCellDetails:[arrSeats objectAtIndex:indexPath.row]];
        __weak typeof(self) weak_self = self;
        cell.GotoDetailsBlock = ^(){
            [weak_self gotoSitDetailsView:indexPath];
        };
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self gotoSitDetailsView:indexPath];
}

///跳转到详情页面
-(void)gotoSitDetailsView:(NSIndexPath *)indexPath{
    NSDictionary *dict = [self.arrayMutableData objectAtIndex:indexPath.section];
    NSArray *arrSeats = [dict objectForKey:@"seats"];
    NSDictionary *item =[arrSeats objectAtIndex:indexPath.row];
    
    ContactsInfo *contactsInfo = [[ContactsInfo alloc] init];
    contactsInfo.userId = [item objectForKey:@"sitId"];
    contactsInfo.departmentIdList = [item objectForKey:@"sitId"];
    NSLog(@"sitId:%@",[item objectForKey:@"sitId"]);
    ContactBookDetailViewController *cdVc = [[ContactBookDetailViewController alloc] init];
    ContactsInfo *currentCellDataInfo = contactsInfo;
    cdVc.detailContactInfo = currentCellDataInfo;
    
    __weak typeof(self) weak_self = self;
    cdVc.NotifySitStatusListBlock = ^(){
        [weak_self getSiteStatus];
    };
    
    [self.navigationController pushViewController:cdVc animated:YES];
}


-(void)getCellDetail:(NSDictionary *)item{

    ContactsInfo *contactsInfo = [[ContactsInfo alloc] init];
    
    if ([item objectForKey:@"sitName"] && ![[item objectForKey:@"sitName"] isKindOfClass:NSClassFromString(@"NSNull")]) {
        contactsInfo.name = [NSString stringWithFormat:@"%@",[item safeObjectForKey:@"sitName"]];
    }
    
    if ([item objectForKey:@"PHONENO"] && ![[item objectForKey:@"PHONENO"] isKindOfClass:NSClassFromString(@"NSNull")]) {
        contactsInfo.phoneNumber = [NSString stringWithFormat:@"%@",[item safeObjectForKey:@"PHONENO"]];
    }
    
    if ([item objectForKey:@"sitNo"] && ![[item objectForKey:@"sitNo"] isKindOfClass:NSClassFromString(@"NSNull")]) {
        contactsInfo.jobNumber = [NSString stringWithFormat:@"%@",[item safeObjectForKey:@"sitNo"]];
    }
    
    contactsInfo.userId = [item objectForKey:@"sitId"];
    contactsInfo.departmentNameList = [NSString stringWithFormat:@"%@",@""];
    contactsInfo.departmentIdList = [NSString stringWithFormat:@"%@",[item objectForKey:@"sitId"]];
}


#pragma mark - headerViewTap
- (void)headerViewTap:(UITapGestureRecognizer*)sender {
    
    UIView *headview = sender.view;
    NSLog(@"headerViewTap---section:%li",headview.tag);
    NSDictionary *dict = [self.arrayMutableData objectAtIndex:headview.tag];
    BOOL isOpen = [[dict objectForKey:@"open"] boolValue];
    UIImageView *icon = (UIImageView*)[headview viewWithTag:headview.tag+1001];
    
    [UIView animateWithDuration:0.2 animations:^{
        icon.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:^(BOOL finished) {
        
    }];
    
    if (isOpen) {
        [self animationRowsWithSectionTag:headview.tag complete:^{
        }];
    }else {
        [self animationRowsWithSectionTag:headview.tag complete:^{
        }];
    }
}

- (void)animationRowsWithSectionTag:(NSInteger)tag complete:(void(^)())complete {
    
    // 更新数据源
    NSMutableDictionary *dict = [self.arrayMutableData objectAtIndex:tag];
    NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:dict];
    [mutableItemNew setValue:@(!([[dict objectForKey:@"open"] boolValue])) forKey:@"open"];
    //修改数据
    [self.arrayMutableData setObject: mutableItemNew atIndexedSubscript:tag];
    
    // 刷新指定section
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:tag];
    [self.tableviewSitStatus reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
    
    complete();
}



#pragma mark - 获取headview title信息
-(NSString *)getHeadViewTitle:(NSInteger)section{
    ///stageName
    NSString *navName = @"";
    if ([[self.arrayMutableData objectAtIndex:section] objectForKey:@"navigationName"]) {
        navName = [[self.arrayMutableData objectAtIndex:section] objectForKey:@"navigationName"];
    }
    ///最多显示8个，多出部门用...表示
    if (navName.length>6) {
        navName = [NSString stringWithFormat:@"%@...",[navName substringToIndex:6]];
    }
    
    return navName;
}


-(NSString *)getHeadViewTitleInfos:(NSInteger)section{
    
    ///该导航下座席总数量
    NSInteger navigationNum = 0;
    if ([[self.arrayMutableData objectAtIndex:section] objectForKey:@"navigationNum"]) {
        navigationNum = [[[self.arrayMutableData objectAtIndex:section] objectForKey:@"navigationNum"] integerValue];
    }
    
    ///该导航下座席在线数量
    NSInteger navigationOnlineNum = 0;
    if ([[self.arrayMutableData objectAtIndex:section] objectForKey:@"navigationOnlineNum"]) {
        navigationOnlineNum = [[[self.arrayMutableData objectAtIndex:section] objectForKey:@"navigationOnlineNum"] integerValue];
    }
    
    ///导航上排队数量
    NSInteger navigationLineNum = 0;
    if ([[self.arrayMutableData objectAtIndex:section] objectForKey:@"navigationLineNum"]) {
        navigationLineNum = [[[self.arrayMutableData objectAtIndex:section] objectForKey:@"navigationLineNum"] integerValue];
    }
    NSString *name_percent = [NSString stringWithFormat:@"(%ti/%ti)   排队:%ti",navigationOnlineNum,navigationNum,navigationLineNum];
    return name_percent;
}


#pragma mark - 没有数据时的view
-(void)notifyNoDataView{
    if (self.arrayData && [self.arrayData count] > 0) {
        [self clearViewNoData];
    }else{
        if (isRequestSuccess) {
            [self setViewNoData:@"暂无坐席"];
        }else{
            [self setViewNoData:@"加载失败"];
        }
    }
}

-(void)setViewNoData:(NSString *)title{
    if (self.commonNoDataView == nil) {
        self.commonNoDataView = [CommonFunc commonNoDataViewIcon:@"list_empty.png" Title:title optionBtnTitle:@""];
    }
    
    [self.tableviewSitStatus addSubview:self.commonNoDataView];
}

-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
    }
}


#pragma mark - 网络请求
-(void)getSiteStatus{
    [self clearViewNoData];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_SIT_STATUS_ACTION] params:params success:^(id jsonResponse) {
        
        rotateState=RotateStateStop;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        NSLog(@"坐席状态jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            isRequestSuccess = TRUE;
            id data = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"];
            if ([data respondsToSelector:@selector(count)] && [data count] > 0) {
                self.arrayData = data;
                [self initData];
            }
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getSiteStatus];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            isRequestSuccess = FALSE;
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        [self.tableviewSitStatus reloadData];
        [self notifyNoDataView];
        
    } failure:^(NSError *error) {
        rotateState=RotateStateStop;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        NSLog(@"%@",error);
        [self.tableviewSitStatus reloadData];
        isRequestSuccess = FALSE;
        [self notifyNoDataView];
    }];
}


@end
