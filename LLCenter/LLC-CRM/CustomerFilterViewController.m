//
//  CustomerFilterViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-7-4.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//
#define ICON_COLOR0 [UIColor colorWithRed:239.0f/255 green:239.0f/255 blue:244.0f/255 alpha:1.0f]
#import "CustomerFilterViewController.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"
#import "LLcenterSheetMenuView.h"
#import "LLCenterSheetMenuModel.h"
#import "CommonStaticVar.h"
#import "UserSession.h"


@interface CustomerFilterViewController ()<LLCenterSheetMenuDelegate>{
    NSMutableArray *arrayByTag;
    NSMutableArray *arrayByBelong;
    Boolean isDismissHUD;
    
    ///当前选择的数据
    NSString *stateFlag;
    NSString *ownerId;
    
    NSInteger indexStateFlag;
    NSInteger indexOwnerId;
    
    ///stateflag   owner
    NSString *flagOfSheet;
}

@end

@implementation CustomerFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"筛选";
    isDismissHUD = NO;

    [super customBackButton];
    [self addNarBar];
    [self setCurViewFrame];
    self.imgLineVSplit1.image = [CommonFunc createImageWithColor:ICON_COLOR0];
    self.imgLineVSplit2.image = [CommonFunc createImageWithColor:ICON_COLOR0];
//    [self readTestData];
    
    [self initData];
    [self getCustomerStateFlag];
    
    ///boss
    if ([[CommonStaticVar getAccountType] isEqualToString:@"boss"]) {
        [self getUserList];
    }else{
        ///非boss  无法选择操作
        NSString *userName = @"";
        NSDictionary *lInfo = [[UserSession shareSession] getLoginInfo];
        if (lInfo) {
            userName = [lInfo safeObjectForKey:@"userName"];
        }
        self.labelByBelong.text = userName;
        self.labelByBelong.textColor = [UIColor grayColor];
        self.btnByBelong.enabled = NO;
        self.imgArrowBelong.hidden = YES;
    }
}


#pragma mark - Nar Bar
-(void)addNarBar{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonAction)];
}

-(void)rightBarButtonAction{
    if (self.RequestDataByFilter) {
        self.RequestDataByFilter(stateFlag,ownerId,NO);
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - 读取测试数据
-(void)readTestData{
    ///筛选条件
    id jsondata = [CommonFunc readJsonFile:@"customer-filter"];
    NSLog(@"jsondata:%@",jsondata);
    
    arrayByTag = [[jsondata objectForKey:@"body"] objectForKey:@"list"];
}


#pragma mark - 初始化数据
-(void)initData{
    flagOfSheet = @"";
    indexStateFlag = 0;
    indexOwnerId = 0;
    stateFlag = self.customerStateFlag;
    ownerId = self.ownerId;
    
    NSLog(@"stateFlag:%@  ownerId:%@",stateFlag,ownerId);
    
    arrayByBelong = [[NSMutableArray alloc] init];
    arrayByTag = [[NSMutableArray alloc] init];
    
    NSDictionary *stateFlagDefault = [NSDictionary dictionaryWithObjectsAndKeys:@"不限",@"FLAGVALUE",@"",@"ID", nil];
    NSDictionary *ownerDefault = [NSDictionary dictionaryWithObjectsAndKeys:@"不限",@"USERNAME",@"",@"ID", nil];
    
    [arrayByTag addObject:stateFlagDefault];
    [arrayByBelong addObject:ownerDefault];
}

#pragma mark - 根据请求结果初始化UI
-(void)initOwnerNamebyResult{
//    ownerId
    NSString *userName = @"";
    NSInteger count = 0;
    Boolean isFound = FALSE;
    if (arrayByBelong) {
        count = [arrayByBelong count];
    }
    for (int i=0; !isFound && i<count; i++) {
        if ([[[arrayByBelong objectAtIndex:i] safeObjectForKey:@"ID"] isEqualToString:ownerId]) {
            isFound = TRUE;
            userName = [[arrayByBelong objectAtIndex:i] safeObjectForKey:@"USERNAME"];
            indexOwnerId = i;
        }
    }
    
    if (![userName isEqualToString:@""]) {
        self.labelByBelong.text = userName;
    }
}

-(void)initCustomerStateFlagbyResult{
    //    customerStateFlag
    
    NSString *flagValue = @"不限";
    NSInteger count = 0;
    Boolean isFound = FALSE;
    if (arrayByTag) {
        count = [arrayByTag count];
    }
    for (int i=0; !isFound && i<count; i++) {
        if ([[[arrayByTag objectAtIndex:i] safeObjectForKey:@"ID"] isEqualToString:stateFlag]) {
            isFound = TRUE;
            flagValue = [[arrayByTag objectAtIndex:i] safeObjectForKey:@"FLAGVALUE"];
            indexStateFlag = i;
        }
    }
    
    if (![flagValue isEqualToString:@""]) {
        self.labelByTag.text = flagValue;
    }
}


#pragma mark - 客户标签
-(void)getCustomerStateFlag{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_CUSTOMER_STATE_FLAG_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"客户标签jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            id data = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"];
            if ([data respondsToSelector:@selector(count)] && [data count] > 0) {
                [arrayByTag addObjectsFromArray:[[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"]];
                
                [self initCustomerStateFlagbyResult];
            }
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getCustomerStateFlag];
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
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
    
}

/*
 {
 FLAGVALUE = "\U7ef4\U62a4\U5ba2\U6237";
 ID = "f87f6ac2-04ea-4da5-9c02-76b93b34d086";
 }
 */


#pragma mark - 客户所属用户
-(void)getUserList{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_CUSTOMER_BELONG_USER_LIST_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"客户所属用户jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [arrayByBelong addObjectsFromArray:[[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"]];
            
            [self initOwnerNamebyResult];
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getUserList];
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
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
}

/*
 {
 EMAIL = "<null>";
 ID = "bd31eecd-2382-4f18-8df4-dc2967f491ed";
 LOGINNAME = boss;
 MOBILE = "<null>";
 USERCODE = 9898;
 USERNAME = boss;
 }
 */



///弹框事件  tag: 101-按标签  102-按所有者
- (IBAction)btnAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    NSLog(@"btnAction tag:%li",tag);
    if (tag == 101) {
        [self showCustomerStateFlagSheetView];
    }else if(tag == 102){
        [self showOwnerNameSheetView];
    }
}

///标签
-(void)showCustomerStateFlagSheetView{
    flagOfSheet = @"stateflag";
    LLcenterSheetMenuView *sheet = [[LLcenterSheetMenuView alloc]initWithlist:[self getDataForStateFlagSheetMenu] headTitle:@"请选择标签" footBtnTitle:@"" cellType:0 menuFlag:0];
    sheet.delegate = self;
    [sheet showInView:nil];
}

///所有者
-(void)showOwnerNameSheetView{
    flagOfSheet = @"owner";
    LLcenterSheetMenuView *sheet = [[LLcenterSheetMenuView alloc]initWithlist:[self getDataForOwnerSheetMenu] headTitle:@"请选择所有者" footBtnTitle:@"" cellType:0 menuFlag:1];
    sheet.delegate = self;
    [sheet showInView:nil];
}


-(NSArray *)getDataForStateFlagSheetMenu{
    LLCenterSheetMenuModel *model;
    NSMutableArray *array = [[NSMutableArray  alloc] init];
    NSInteger count = 0;
    if (arrayByTag) {
        count = [arrayByTag count];
    }
    NSDictionary *item;
    for (int i=0; i<count; i++) {
        item = [arrayByTag objectAtIndex:i];
        model = [[LLCenterSheetMenuModel alloc]init];
       
        NSString *flagValue = @"";
        if ([item objectForKey:@"FLAGVALUE"]) {
            flagValue = [item safeObjectForKey:@"FLAGVALUE"];
        }
        
        model.title = flagValue;
        
        if (indexStateFlag == i) {
            model.selectedFlag = @"yes";
        }else{
            model.selectedFlag = @"";
        }
        
        [array addObject:model];
    }
    
    return array;
}


-(NSArray *)getDataForOwnerSheetMenu{
    LLCenterSheetMenuModel *model;
    NSMutableArray *array = [[NSMutableArray  alloc] init];
    NSInteger count = 0;
    if (arrayByBelong) {
        count = [arrayByBelong count];
    }
    NSDictionary *item;
    for (int i=0; i<count; i++) {
        item = [arrayByBelong objectAtIndex:i];
        model = [[LLCenterSheetMenuModel alloc]init];
        NSString *userName = @"";
        if ([item objectForKey:@"USERNAME"]) {
            userName = [item safeObjectForKey:@"USERNAME"];
        }
        
        model.title = userName;
        if (indexOwnerId == i) {
            model.selectedFlag = @"yes";
        }else{
            model.selectedFlag = @"";
        }
        [array addObject:model];
    }
    
    return array;
}


#pragma mark - sheetview回调
-(void)didSelectSheetMenuIndex:(NSInteger)index menuType:(SheetMenuType)menuT menuFlag:(NSInteger)flag{
    NSLog(@"didSelectSheetMenuIndex index:%li",index);
    if ([flagOfSheet isEqualToString:@"stateflag"]) {
        indexStateFlag = index;
        stateFlag = [[arrayByTag objectAtIndex:index] safeObjectForKey:@"ID"];
        self.labelByTag.text = [[arrayByTag objectAtIndex:index] safeObjectForKey:@"FLAGVALUE"];
    }else if ([flagOfSheet isEqualToString:@"owner"]){
        indexOwnerId = index;
        ownerId = [[arrayByBelong objectAtIndex:index] safeObjectForKey:@"ID"];
        self.labelByBelong.text = [[arrayByBelong objectAtIndex:index] safeObjectForKey:@"USERNAME"];
    }
}


-(void)setCurViewFrame{
    NSInteger vX = DEVICE_BOUNDS_WIDTH-320;
    self.viewFilter.frame = CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 120);
    self.btnByTag.frame = CGRectMake(141, 0, 180+vX, 60);
    self.labelByTag.frame = CGRectMake(150, 20, 120+vX, 20);
    self.imgArrowTag.frame = CGRectMake(280+vX, 26, 12, 7);
    
    
    self.btnByBelong.frame = CGRectMake(141, 60, 180+vX, 60);
    self.labelByBelong.frame = CGRectMake(150, 80, 120+vX, 20);
    self.imgArrowBelong.frame = CGRectMake(280+vX, 86, 12, 7);
    
    self.imgLine1.frame = CGRectMake(0, 59, DEVICE_BOUNDS_WIDTH, 1);
    self.imgLine2.frame = CGRectMake(0, 119, DEVICE_BOUNDS_WIDTH, 1);
}
@end
