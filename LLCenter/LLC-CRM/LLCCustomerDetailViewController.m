//
//  LLCCustomerDetailViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-7-2.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#define pageSize 15

#import "LLCCustomerDetailViewController.h"
#import "CommonFunc.h"
#import "LLCenterUtility.h"
#import "MJRefresh.h"
#import "CustomerDetailCellB.h"
#import "MoreCustomersViewController.h"
#import "EditCustomerViewController.h"
#import "CustomPopView.h"
#import "CustomerDetailCellC.h"
#import "AFSoundPlaybackHelper.h"
#import "SaleOpportunityViewController.h"
#import "AfterServiceViewController.h"
#import "ContractViewController.h"
#import "OrderViewController.h"
#import "SaleOpportunityDetailViewController.h"
#import "AfterServiceDetailViewController.h"
#import "ContractDetailViewController.h"
#import "OrderDetailViewController.h"



@interface LLCCustomerDetailViewController ()<UITableViewDataSource,UITableViewDelegate>{
    
    ///分页加载
    int listPage,lastPosition;
    
    ///联系人列表
    NSArray *arrayLinkMan;
    ///主联系人
    NSDictionary *mainLinkMan;
    ///客户标签
    NSArray *arrayCustomerTag;
    
    ///标识客户类型,company：企业客户，personal:个人客户。
    NSString *customer_type;
    
    ///上次点击的坐标
    NSInteger preSection;
}

@end

@implementation LLCCustomerDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"详细信息";
    self.view.backgroundColor = COLOR_BG;
    [super customBackButton];
    [self addNarBar];
    [self initData];
    self.btnMoreBaseInfo.hidden = YES;
    self.viewHeadInfos.hidden = YES;
    [self initTableView];
    [self getCustomerLinkmanDetail];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [AFSoundPlaybackHelper stop_helper];
}



#pragma mark - Nar Bar

-(void)addNarBar{

    UIButton *rightButton=[UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame=CGRectMake(0, 0, 25, 16);
    [rightButton setBackgroundImage:[UIImage imageNamed:@"icon_more_function.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"icon_more_function.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(rightBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    [self.navigationItem setRightBarButtonItem:rightBarButton];
    
}

-(void)rightBarButtonAction{
    [self showPopView];
}


-(void)showPopView{
    CustomPopView *popView = [[CustomPopView alloc] initWithPoint:CGPointMake(0, 64+64) titles:@[@"编辑联系人信息", @"查看销售机会", @"查看售后服务", @"查看合同", @"查看订单"] imageNames:@[@"icon_edit_linkman.png", @"icon_look_sale.png",@"icon_look_afterservice.png", @"icon_look_contract.png",@"icon_look_order.png"]];
    popView.selectBlock = ^(NSInteger index) {
        NSLog(@"index = %ti", index);
        if (index == 0) {
            [self editCustomerView];
        }else if (index == 1) {
            [self saleOpportunityView];
        }else if(index == 2){
            [self afterServiceView];
        }else if(index == 3){
            [self contractView];
        }else if(index == 4){
            [self orderView];
        }
    };
    [popView show];
}


#pragma mark - 页面跳转
///编辑联系人信息
-(void)editCustomerView{
    EditCustomerViewController *controller = [[EditCustomerViewController alloc] init];
    controller.cusDetails = self.dicDetails;
    controller.mainLinkMan = mainLinkMan;
    controller.arrayCusTags = arrayCustomerTag;
    
    __weak typeof(self) weak_self = self;
    controller.NotifyCustomerDetails = ^(){
        [weak_self getCustomerLinkmanDetail];
        
        ///编辑成功后更新列表数据
        if (weak_self.NotifyCustomerList) {
            weak_self.NotifyCustomerList();
        }
    };
    
    [self.navigationController pushViewController:controller animated:YES];
}


///销售机会
-(void)saleOpportunityView{
    SaleOpportunityViewController *sov = [[SaleOpportunityViewController alloc] init];
    sov.customerId = [self.dicDetails safeObjectForKey:@"CUSTOMER_ID"];
    [self.navigationController pushViewController:sov animated:YES];
}


///售后服务
-(void)afterServiceView{
    AfterServiceViewController *sov = [[AfterServiceViewController alloc] init];
    sov.customerId = [self.dicDetails safeObjectForKey:@"CUSTOMER_ID"];
    [self.navigationController pushViewController:sov animated:YES];
}


///合同
-(void)contractView{
    ContractViewController *sov = [[ContractViewController alloc] init];
    sov.customerId = [self.dicDetails safeObjectForKey:@"CUSTOMER_ID"];
    [self.navigationController pushViewController:sov animated:YES];
}


///订单
-(void)orderView{
    OrderViewController *sov = [[OrderViewController alloc] init];
    sov.customerId = [self.dicDetails safeObjectForKey:@"CUSTOMER_ID"];
    sov.arrayAllLinkMan = arrayLinkMan;
    sov.customer_address = @"";
    ///地址
    if ([self.dicDetails objectForKey:@"CUSTOMER_ADDRESS"] ) {
        sov.customer_address = [self.dicDetails safeObjectForKey:@"CUSTOMER_ADDRESS"];
    }
    [self.navigationController pushViewController:sov animated:YES];
}



#pragma mark - 跳转到详情页面
///销售机会
-(void)gotoSaleViewDetais:(NSString *)saleId{
    SaleOpportunityDetailViewController *sod = [[SaleOpportunityDetailViewController alloc] init];
    sod.saleId = saleId;
    sod.customerId = [self.dicDetails safeObjectForKey:@"CUSTOMER_ID"];
    
    __weak typeof(self) weak_self = self;
    sod.NotifySaleOpportunitysList = ^{
        listPage = 1;
        [weak_self getCustomerRecordLog];
    };
    [self.navigationController pushViewController:sod animated:YES];
}

///售后服务
-(void)gotoAfterServiceViewDetais:(NSString *)serviceId{
    AfterServiceDetailViewController *sod = [[AfterServiceDetailViewController alloc] init];
    sod.serviceId = serviceId;
    sod.customerId = [self.dicDetails safeObjectForKey:@"CUSTOMER_ID"];
    
    __weak typeof(self) weak_self = self;
    sod.NotifyAfterServiceList = ^{
        listPage = 1;
        [weak_self getCustomerRecordLog];
    };
    [self.navigationController pushViewController:sod animated:YES];
}


///合同
-(void)gotoContractViewDetais:(NSString *)contractId{
    ContractDetailViewController *sod = [[ContractDetailViewController alloc] init];
    sod.contractId = contractId;
    sod.customerId = [self.dicDetails safeObjectForKey:@"CUSTOMER_ID"];
    
    __weak typeof(self) weak_self = self;
    sod.NotifyContractList = ^{
        listPage = 1;
        [weak_self getCustomerRecordLog];
    };
    [self.navigationController pushViewController:sod animated:YES];
}

///订单
-(void)gotoOrderViewDetais:(NSString *)orderId{
    OrderDetailViewController *sod = [[OrderDetailViewController alloc] init];
    sod.orderId = orderId;
    sod.customerId = [self.dicDetails safeObjectForKey:@"CUSTOMER_ID"];
    sod.arrayAllLinkMan = arrayLinkMan;
    sod.customer_address = @"";
    ///地址
    if ([self.dicDetails objectForKey:@"CUSTOMER_ADDRESS"] ) {
        sod.customer_address = [self.dicDetails safeObjectForKey:@"CUSTOMER_ADDRESS"];
    }
    __weak typeof(self) weak_self = self;
    sod.NotifyOrderList = ^{
        listPage = 1;
        [weak_self getCustomerRecordLog];
    };
    [self.navigationController pushViewController:sod animated:YES];
}


#pragma mark - 初始化数据
-(void)initData{
    preSection = -1;
    customer_type = @"personal";
    mainLinkMan = nil;
    self.arrayDetails = [[NSMutableArray alloc] init];
    self.arrayDetailsNew = [[NSMutableArray alloc] init];
    
    ///获取当前联系人对应的业务、通讯日志
}

#pragma mark - 初始化tableview
-(void)initTableView{
    listPage = 1;
    self.tableviewDetails = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-64) style:UITableViewStylePlain];
    self.tableviewDetails.delegate = self;
    self.tableviewDetails.dataSource = self;
    self.tableviewDetails.sectionFooterHeight = 0;
    self.tableviewDetails.backgroundColor = [UIColor whiteColor];
    self.tableviewDetails.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:self.tableviewDetails];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewDetails setTableFooterView:v];
    
//    self.tableviewDetails.tableHeaderView = self.viewHeadInfos;
    
    [self setupRefresh];
    
}

#pragma mark - 更多联系人
- (IBAction)moreCustomer:(id)sender {
    __weak typeof(self) weak_self = self;
    
    MoreCustomersViewController *controller = [[MoreCustomersViewController alloc] init];
    controller.arrayAllLinkMan = arrayLinkMan;
    
    controller.RequestDataByLinkman = ^(NSDictionary *linkman){
        mainLinkMan = linkman;
        [weak_self setHeadViewDetails];
        [weak_self notifyView];
    };
    
    controller.NotifyLinkmanData = ^(){
        [weak_self getCustomerLinkmanDetail];
    };
    controller.cusDetails = self.dicDetails;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)notifyView{
    self.tableviewDetails.tableHeaderView = nil;
    self.tableviewDetails.tableHeaderView = self.viewHeadInfos;
}


#pragma mark - 根据信息 填充headview
-(void)setHeadViewDetails{
    
    if (self.dicDetails == nil) {
        return;
    }
    self.viewHeadInfos.hidden = NO;
    NSInteger vX = DEVICE_BOUNDS_WIDTH-320;
    self.viewHeadBaseInfo.frame = CGRectMake(0, 15, DEVICE_BOUNDS_WIDTH, 150);
    ///基本信息
    self.btnMoreBaseInfo.frame = CGRectMake(255+vX, 5, 60, 30);
    ///主联系人
    
    
    NSString *contactMain = @"";
    NSString *contactMainFlag = @"";
    
    if (mainLinkMan != nil) {
        if ([mainLinkMan objectForKey:@"NAME"]) {
            contactMain = [mainLinkMan safeObjectForKey:@"NAME"];
        }
        if ([mainLinkMan objectForKey:@"FIELD_VALUE"]) {
            contactMainFlag = [mainLinkMan safeObjectForKey:@"FIELD_VALUE"];
        }
    }
    
    if ([contactMainFlag isEqualToString:@""]) {
        contactMainFlag = @"主联系人";
    }
    
    self.labelContantMain.text = [NSString stringWithFormat:@"%@: %@",contactMainFlag,contactMain];
    self.labelContantMain.frame = CGRectMake(15, 50, 245+vX, 20);
    
    ///公司
    NSString *companyName = @"";
    if ([self.dicDetails objectForKey:@"CUSTOMER_NAME"] ) {
        companyName = [self.dicDetails safeObjectForKey:@"CUSTOMER_NAME"];
    }
    self.labelCompanyName.text = [NSString stringWithFormat:@"公司: %@",companyName];
    self.labelCompanyName.frame = CGRectMake(15, 83, 245+vX, 20);
    
    ///所有者
    NSString *belong = @"";
    if ([self.dicDetails objectForKey:@"OWNER_NAME"] ) {
        belong = [self.dicDetails safeObjectForKey:@"OWNER_NAME"];
    }
    belong = [NSString stringWithFormat:@"所有者: %@",belong];
    self.labelBelong.text = belong;
    
    CGSize sizeBelong = [CommonFunc getSizeOfContents:belong Font:[UIFont systemFontOfSize:15.0] withWidth:200 withHeight:20];
    self.labelBelong.frame = CGRectMake(15, 115, sizeBelong.width, 20);
    
    
    self.labelTagBelong.hidden = YES;
    ///标签
    NSString *belongTag = @"";
    if ([self.dicDetails objectForKey:@"STATE_FLAG"]) {
        belongTag = [self.dicDetails safeObjectForKey:@"STATE_FLAG"];
    }


    NSArray *arrayTag = [belongTag componentsSeparatedByString:@","];

    self.scrollviewTag.frame = CGRectMake(self.labelBelong.frame.origin.x+self.labelBelong.frame.size.width+10, 115,DEVICE_BOUNDS_WIDTH-130 , 20);
    self.scrollviewTag.showsHorizontalScrollIndicator = NO;
    
    for(UIView *item in self.scrollviewTag.subviews){
        if([item isKindOfClass:[UILabel class]]){
            NSInteger tag = [item tag];
            if(tag>=1000){
                [item removeFromSuperview];
            }
        }
    }
    
    if (![belongTag isEqualToString:@""]) {
        self.labelTagBelong.hidden = NO;
        CGSize sizeBelongTag = [CommonFunc getSizeOfContents:belongTag Font:[UIFont systemFontOfSize:12.0] withWidth:180 withHeight:20];
        
        NSInteger count = 0;
        if (arrayTag) {
            count = [arrayTag count];
        }
        CGFloat x = 0.0;
        for (int i=0; i<count; i++) {
            CGSize sizeTag = [CommonFunc getSizeOfContents:[arrayTag objectAtIndex:i] Font:[UIFont systemFontOfSize:12.0] withWidth:110 withHeight:20];
            
            UILabel *labelTag = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, sizeTag.width+5, 20)];
            labelTag.text = [arrayTag objectAtIndex:i];
            labelTag.textAlignment = NSTextAlignmentCenter;
            labelTag.font = [UIFont systemFontOfSize:12.0];
            labelTag.layer.cornerRadius = 5;
            [[labelTag layer] setMasksToBounds:YES];
            labelTag.backgroundColor = [UIColor colorWithRed:89.0f/255 green:174.0f/255 blue:231.0f/255 alpha:1.0f];
            labelTag.textColor = [UIColor whiteColor];
            labelTag.tag = i+1000;
            [self.scrollviewTag addSubview:labelTag];
            x += (sizeTag.width+10);
            
        }
        self.scrollviewTag.contentSize = CGSizeMake(x, 20);
        
        
        self.labelTagBelong.hidden = YES;
        
        self.labelTagBelong.frame = CGRectMake(self.labelBelong.frame.origin.x+sizeBelong.width +10, 115, sizeBelongTag.width+10, 20);

        self.labelTagBelong.text = belongTag;
        self.labelTagBelong.layer.cornerRadius = 5;
        [[self.labelTagBelong layer] setMasksToBounds:YES];
        self.labelTagBelong.backgroundColor = [UIColor colorWithRed:89.0f/255 green:174.0f/255 blue:231.0f/255 alpha:1.0f];
    }
    
    
    
    
    
    
    NSString *phoneNum = @"";
    NSString *familyPhoneNum = @"";
    NSString *address = @"";
    ///联系信息
    if (mainLinkMan != nil) {
        ///手机
        if ([mainLinkMan objectForKey:@"MOBILE"]) {
            phoneNum = [mainLinkMan safeObjectForKey:@"MOBILE"];
        }
        
        self.labelPhoneNum.text = [NSString stringWithFormat:@"手机: %@",phoneNum];
        self.btnCallPhone.hidden = YES;
        self.labelPhoneNum.hidden = YES;
        if (![phoneNum isEqualToString:@""]) {
            self.btnCallPhone.hidden = NO;
            self.labelPhoneNum.hidden = NO;
        }
        self.labelPhoneNum.frame = CGRectMake(15, 50, 245+vX, 20);
        self.btnCallPhone.frame = CGRectMake(280+vX, 50, 20, 20);
        
        
        ///固话
        if ([mainLinkMan objectForKey:@"WORKPHONE"]) {
            familyPhoneNum = [mainLinkMan safeObjectForKey:@"WORKPHONE"];
        }
        
        self.labelFamilyPhone.text = [NSString stringWithFormat:@"固话: %@",familyPhoneNum];
        self.btnCallFamilyPhone.hidden = YES;
        self.labelFamilyPhone.hidden = YES;
        if (![familyPhoneNum isEqualToString:@""]) {
            self.btnCallFamilyPhone.hidden = NO;
            self.labelFamilyPhone.hidden = NO;
        }
        self.labelFamilyPhone.frame = CGRectMake(15, 85, 245+vX, 20);
        self.btnCallFamilyPhone.frame = CGRectMake(280+vX, 80, 20, 20);
        
    }
    
    ///地址
    if ([self.dicDetails objectForKey:@"CUSTOMER_ADDRESS"] ) {
        address = [self.dicDetails safeObjectForKey:@"CUSTOMER_ADDRESS"];
    }
    
    self.labelAddress.text = [NSString stringWithFormat:@"地址: %@",address];
    self.btnCopyAddress.hidden = YES;
    self.labelAddress.hidden = YES;
    if (![address isEqualToString:@""]) {
        self.btnCopyAddress.hidden = NO;
        self.labelAddress.hidden = NO;
    }
    self.labelAddress.frame = CGRectMake(15, 120, 245+vX, 20);
    self.btnCopyAddress.frame = CGRectMake(280+vX, 110, 20, 20);

    
//    self.viewHeadContactWay.frame = CGRectMake(0, 180, DEVICE_BOUNDS_WIDTH, 150);
    
    
    ///判断是否有联系信息
    
    ///判断是否显示当前行
    NSInteger heightContactInfoItem = 0;
    if ([phoneNum isEqualToString:@""]) {
        heightContactInfoItem += 0;
    }else{
        heightContactInfoItem += 30;
        self.labelPhoneNum.frame = CGRectMake(15, 50, 245+vX, 20);
    }
    
    ///固话
    if ([familyPhoneNum isEqualToString:@""]) {
        heightContactInfoItem += 0;
    }else{
        
        self.labelFamilyPhone.hidden = NO;
        self.labelFamilyPhone.frame = CGRectMake(15, 50+heightContactInfoItem, 245+vX, 20);
        self.btnCallFamilyPhone.frame = CGRectMake(280+vX, 50+heightContactInfoItem, 20, 20);
        
        heightContactInfoItem += 30;
    }
    
    ///地址
    if ([address isEqualToString:@""]) {
        self.labelAddress.hidden = YES;
        heightContactInfoItem += 0;
    }else{
        self.labelAddress.hidden = NO;
        self.labelAddress.frame = CGRectMake(15, 50+heightContactInfoItem, 245+vX, 20);
        self.btnCopyAddress.frame = CGRectMake(280+vX, 50+heightContactInfoItem, 20, 20);
        heightContactInfoItem += 30;
    }
    NSLog(@"heightContactInfoItem:%ti",heightContactInfoItem);
    
    ///联系信息view frame
    if (heightContactInfoItem == 0) {
        self.viewHeadContactWay.hidden = YES;
        self.viewHeadContactWay.frame = CGRectMake(0, 180, 0, 0);
        heightContactInfoItem = 0;
    }else{
         self.viewHeadContactWay.hidden = NO;
        self.viewHeadContactWay.frame = CGRectMake(0, 180, DEVICE_BOUNDS_WIDTH, 50+heightContactInfoItem);
        heightContactInfoItem = 50+heightContactInfoItem+15;
    }
    
//    ///判断是否有联系信息
//    NSInteger heightContactWay = 0;
//    self.viewHeadContactWay.hidden = YES;
    
    
    ///headview frame
    self.viewHeadInfos.frame = CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 15+150+15 + heightContactInfoItem);
    self.viewHeadInfos.backgroundColor = CUSTOMER_DETAIL_VIEW_BG_COLOR;
    
    self.tableviewDetails.tableHeaderView = self.viewHeadInfos;
}


#pragma mark - 获取客户及联系人详情
-(void)getCustomerLinkmanDetail{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    [params setValue:self.customerId forKey:@"customerId"];
    NSLog(@"params:%@",params);
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_CUSTOMER_LINKMAN_INFO_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"客户及联系人详情jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            ///标签
            if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"customerTag"] != [NSNull null]) {
                arrayCustomerTag = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"customerTag"];
                NSLog(@"arrayCustomerTag:%@",arrayCustomerTag);
            }
            
            if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"] != [NSNull null]) {
                self.dicDetails = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"];
                
                ///客户类型
                customer_type = [[[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"] safeObjectForKey:@"CUSTOMER_TYPE"];
                
                if (customer_type && [customer_type isEqualToString:@"company"]) {
                    self.btnMoreBaseInfo.hidden = NO;
                }else{
                    self.btnMoreBaseInfo.hidden = YES;
                }
                
                arrayLinkMan = [[[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"] objectForKey:@"LINKMAN_LIST"];
                mainLinkMan = nil;
                if (arrayLinkMan && [arrayLinkMan respondsToSelector:@selector(count)] && [arrayLinkMan count] > 0) {
                    mainLinkMan = [arrayLinkMan objectAtIndex:0];
                }
                
                [self setHeadViewDetails];
                [self getCustomerRecordLog];
            }else{
                NSLog(@"data------>:<null>");
                [CommonFuntion showToast:@"详情异常" inView:self.view];
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getCustomerLinkmanDetail];
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
            self.navigationItem.rightBarButtonItem = nil;
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        self.navigationItem.rightBarButtonItem = nil;
    }];
}

/*
 {
 ADDRESS = "<null>";
 "CUSTOMER_ID" = "41324bb4-3fd5-4359-b7a4-5962e229aa09";
 "CUSTOMER_NAME" = "\U4fee\U6539\U540d\U79f0\U518d\U6d4b\U8bd5";
 "LINKMAN_ID" = "ab7548fa-03c0-484f-ad10-3ab5515a0df7";
 "LINKMAN_NAME" = 31313;
 MOBILE = 135665455444;
 "OWNER_ID" = "bd31eecd-2382-4f18-8df4-dc2967f491ed";
 "OWNER_NAME" = boss;
 "STATE_FLAG" = "\U7ef4\U62a4\U5ba2\U6237";
 WORKPHONE = 021545454545;
 }
 */

#pragma mark - 通讯日志
-(void)getCustomerRecordLog{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [params setValue:self.customerId forKey:@"customerId"];
    [params setValue:[NSNumber numberWithInteger:pageSize] forKey:@"numPerPage"];
    [params setValue:[NSNumber numberWithInteger:listPage] forKey:@"currentPage"];
    
    NSLog(@"params:%@",params);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_CUSTOMER_RECORD_LIST_INFO_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"通讯日志jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [self setViewRequestSusscess:jsonResponse];
        }
        else {
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            ///加载失败 做相应处理
            [self setViewRequestFaild:desc];
            [CommonFuntion showToast:desc inView:self.view];
        }
        ///刷新UI
        [self reloadRefeshView];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
}

/*
 {
 CREATETIME = "2015-08-10 16:41:21";
 DETAIL = "\U552e\U540e\U592b\U4e3a\U6076\U670d\U52a1\U8303\U56f4 | \U7b54\U7591 | \U65e0\U9700\U5904\U7406";
 LOGTYPE = 2;
 NUM = 1;
 OPERATIONTYPE = 1;
 OPERATORNAME = boss;
 REMARK = "4\U963f\U65af\U5927\U6cd5";
 }
 */


// 请求成功时数据处理
-(void)setViewRequestSusscess:(NSDictionary *)jsonResponse
{
    id data = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"];
    if ([data respondsToSelector:@selector(count)] && [data count] > 0) {
        if(listPage == 1)
        {
            [self.arrayDetails removeAllObjects];
            [self.arrayDetailsNew removeAllObjects];
        }
        
        ///添加当前页数据到列表中...
        [self.arrayDetails addObjectsFromArray:data];
        [self initRecordLogData];
        
        ///页码++
        if ([data count] == pageSize) {
            listPage++;
            [self.tableviewDetails setFooterHidden:NO];
        }else
        {
            ///隐藏上拉刷新
            [self.tableviewDetails setFooterHidden:YES];
        }
        
        
    }else{
        ///隐藏上拉刷新
        [self.tableviewDetails setFooterHidden:YES];
    }
    
    
}


// 请求失败时数据处理
-(void)setViewRequestFaild:(NSString *)desc
{
   
}

///初始化通讯日志及业务日志信息
-(void)initRecordLogData{
    
    ///初始化open标记
    NSInteger count = 0;
    if (self.arrayDetails) {
        count = [self.arrayDetails count];
    }
    NSDictionary *item;
    NSMutableDictionary *mutableItemNew;
    for (int i=0; i<count; i++) {
        item = [self.arrayDetails objectAtIndex:i];
        mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:item];
        
        [mutableItemNew setValue:@(NO) forKey:@"open"];
        
        [self.arrayDetails setObject: mutableItemNew atIndexedSubscript:i];
    }
    
    NSLog(@"self.arrayMutableData:%@",self.arrayDetails);
}


#pragma mark - 外呼
- (IBAction)callEvent:(id)sender {
    
    UIButton *btn = (UIButton*)sender;
    NSInteger tag = btn.tag;
    NSString *phoneNum = @"";
    if (tag == 100) {
        ///手机
        if ([mainLinkMan objectForKey:@"MOBILE"]) {
            phoneNum = [mainLinkMan safeObjectForKey:@"MOBILE"];
        }
    }else if(tag == 101){
        ///固话
        if ([mainLinkMan objectForKey:@"WORKPHONE"]) {
            phoneNum = [mainLinkMan safeObjectForKey:@"WORKPHONE"];
        }
    }
    
    if ([phoneNum isEqualToString:@""]) {
        return;
    }
    
    
    if (![phoneNum isEqualToString:@""]) {
        UIAlertView *alertCall = [[UIAlertView alloc] initWithTitle:@"是否外呼?" message:phoneNum delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        alertCall.tag = tag;
        [alertCall show];
    }
}

///外呼
-(void)callOut:(NSString *)phoneNum{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    [params setValue:phoneNum forKey:@"destPhoneNo"];
    NSLog(@"params:%@",params);
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_OUT_CALL_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"外呼jsonResponse:%@",jsonResponse);
        if (jsonResponse && [jsonResponse objectForKey:@"status"]) {
            if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
                [CommonFuntion showToast:@"呼叫成功" inView:self.view];
            }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
                __weak typeof(self) weak_self = self;
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^(){
                    [weak_self callOut:phoneNum];
                };
                [comRequest loginInBackgroundLLC];
            }
            else {
                NSString *desc = @"";
                if ([jsonResponse objectForKey:@"desc"]) {
                    desc = [jsonResponse safeObjectForKey:@"desc"];
                }
                NSLog(@"desc:%@",desc);
                if ([desc isEqualToString:@""]) {
                    desc = @"呼叫失败";
                }
                [CommonFuntion showToast:desc inView:self.view];
            }
        }else{
            [CommonFuntion showToast:@"呼叫失败" inView:self.view];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //外呼
    if (buttonIndex == 1) {
        NSString *phoneNum = @"";
        if (alertView.tag == 100) {
            ///手机
            if ([mainLinkMan objectForKey:@"MOBILE"]) {
                phoneNum = [mainLinkMan safeObjectForKey:@"MOBILE"];
            }
        }else if (alertView.tag == 101){
            ///固话
            if ([mainLinkMan objectForKey:@"WORKPHONE"]) {
                phoneNum = [mainLinkMan safeObjectForKey:@"WORKPHONE"];
            }
        }
        NSLog(@"phoneNum:%@",phoneNum);

        [self callOut:phoneNum];
    }
    
}


#pragma  mark - 复制
- (IBAction)copyAddress:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.labelAddress.text;
}



#pragma mark - 上拉下拉刷新相关事件
//集成刷新控件
- (void)setupRefresh
{
    NSString *dateKey = @"customerdetails";
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [self.tableviewDetails addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:dateKey];
    //上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableviewDetails addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 自动刷新(一进入程序就下拉刷新)
    //    [self.tableviewCampaign headerBeginRefreshing];
}


// 结束加载
-(void)reloadRefeshView{
    // 刷新列表
    [self.tableviewDetails reloadData];
    [self.tableviewDetails footerEndRefreshing];
    [self.tableviewDetails headerEndRefreshing];
}

// 下拉
- (void)headerRereshing
{
    NSLog(@"headerRereshing--下拉-->");
    
    if ([self.tableviewDetails isFooterRefreshing]) {
        [self.tableviewDetails headerEndRefreshing];
        return;
    }
    
    ///下拉
    listPage = 1;
    [self getCustomerLinkmanDetail];
}

// 上拉
- (void)footerRereshing
{
    NSLog(@"footerRereshing--上拉-->");
    
    if ([self.tableviewDetails isHeaderRefreshing]) {
        [self.tableviewDetails footerEndRefreshing];
        return;
    }
    
    //上拉加载更多
    [self getCustomerRecordLog];
}



#pragma mark - tableview delegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 90;
    }
    return 50;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSDictionary *item = [self.arrayDetails objectAtIndex:section];
    BOOL isCallInfo = FALSE;
    if([[item safeObjectForKey:@"OPERATIONTYPE"]  isEqualToString:@"call"]){
        isCallInfo = TRUE;
    }
    
    NSInteger yPoint = 0;
    ///第一行  业务与通讯日志数据
    UIView *headviewTop = nil;
    if (section == 0) {
        headviewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 40)];
        ///title
        UILabel *labelHead = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 40)];
        labelHead.font = [UIFont systemFontOfSize:15.0];
        labelHead.textAlignment = NSTextAlignmentLeft;
        labelHead.text = @"业务及通讯日志";
        [headviewTop addSubview:labelHead];
        yPoint = 40;
    }
    
    UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, yPoint, DEVICE_BOUNDS_WIDTH, 50)];
    headview.backgroundColor = [UIColor whiteColor];
    headview.tag = section;
    //    [headview addLineUp:NO andDown:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewTap:)];
    [headview addGestureRecognizer:tap];
    
    ///顶部分割线
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 1)];
    line.image = [UIImage imageNamed:@"line.png"];
    [headview addSubview:line];
    
    
    NSInteger width = (DEVICE_BOUNDS_WIDTH-320)/2;
    ///title
    UILabel *labelDateTime = [[UILabel alloc] initWithFrame:CGRectMake(15, 1, 110, 49)];
    labelDateTime.font = [UIFont systemFontOfSize:15.0];
    labelDateTime.textAlignment = NSTextAlignmentLeft;
    labelDateTime.text = @"";
    [headview addSubview:labelDateTime];
    
    
    ///title
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(120, 1, 90+width, 49)];
    labelTitle.font = [UIFont systemFontOfSize:15.0];
    labelTitle.textAlignment = NSTextAlignmentLeft;
    labelTitle.text = @"";
    [headview addSubview:labelTitle];
    
    
    ///duration
    UILabel *labelDuratin = [[UILabel alloc] initWithFrame:CGRectMake(215+width, 1, 75+width, 49)];
    labelDuratin.font = [UIFont systemFontOfSize:15.0];
    labelDuratin.textAlignment = NSTextAlignmentLeft;
    labelDuratin.text = @"";
    [headview addSubview:labelDuratin];
    
    ///icon
    UIImageView *icon = [[UIImageView alloc] init];
    icon.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-45, 15, 20, 20);
    [headview addSubview:icon];
    
    
    if (section == [self.arrayDetails count]-1) {
        ///底部分割线
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 49, DEVICE_BOUNDS_WIDTH, 1)];
        line.image = [UIImage imageNamed:@"line.png"];
        [headview addSubview:line];
    }
    
    if (isCallInfo) {
        labelDateTime.text = [self getVoiceDateTime:item];
        labelTitle.text = [self getVoiceTitleName:item];
        labelDuratin.text = [self getVoiceDuration:item];
        BOOL isOpen = [[item objectForKey:@"open"] boolValue];
        if (isOpen) {
            icon.image = [UIImage imageNamed:@"btn_circle_up_blue.png"];
        }else{
            icon.image = [UIImage imageNamed:@"btn_circle_down_blue.png"];
        }
        
        icon.tag = 1001+section;
    }else{
        labelDateTime.text = [self getVoiceDateTime:item];
        labelTitle.text = [self getTitleName:item];
        labelDuratin.text = [item safeObjectForKey:@"STATUS"];
        icon.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-35, 17, 12, 18);
        icon.image = [UIImage imageNamed:@"btn_to_right_gray.png"];
    }
    
    UIView *headviewFinal = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 50+yPoint)];
    if (headviewTop) {
        [headviewFinal addSubview:headviewTop];
    }
    [headviewFinal addSubview:headview];
    
    
    return headviewFinal;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.arrayDetails) {
        return [self.arrayDetails count];
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    BOOL isCallInfo = FALSE;
    NSDictionary *item = [self.arrayDetails objectAtIndex:section];
    if([[item safeObjectForKey:@"OPERATIONTYPE"]  isEqualToString:@"call"]){
        isCallInfo = TRUE;
    }
    
    ///通讯信息
    if (isCallInfo) {
        if ([[item objectForKey:@"open"] boolValue]) {
            return 1;
        }else {
            return 0;
        }
    }else{
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50.0;
    
    BOOL isCallInfo = FALSE;
    if([[[self.arrayDetails objectAtIndex:indexPath.row] safeObjectForKey:@"OPERATIONTYPE"]  isEqualToString:@"call"]){
        isCallInfo = TRUE;
    }

    ///通讯信息
    if (isCallInfo) {
        return [CustomerDetailCellC getCellContentHeight:nil indexPath:indexPath];
    }else{
        return [CustomerDetailCellB getCellContentHeight:[self.arrayDetails objectAtIndex:indexPath.row] indexPath:indexPath];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CustomerDetailCellC *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomerDetailCellCIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"CustomerDetailCellC" owner:self options:nil];
        cell = (CustomerDetailCellC*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    [cell setCellDetails:[self.arrayDetails objectAtIndex:indexPath.section] indexPath:indexPath];
    
    return cell;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSLog(@"didSelectRowAtIndexPath:%ti",indexPath.section);
    
}


#pragma mark - headerViewTap
- (void)headerViewTap:(UITapGestureRecognizer*)sender {
    
    UIView *headview = sender.view;
    NSLog(@"headerViewTap---section:%li",headview.tag);
    NSDictionary *item = [self.arrayDetails objectAtIndex:headview.tag];
    
    
    
    BOOL isCallInfo = FALSE;
    if([[item safeObjectForKey:@"OPERATIONTYPE"]  isEqualToString:@"call"]){
        isCallInfo = TRUE;
    }
    
    
    ///通讯信息
    if (isCallInfo) {
        ///先收起展开的item
        if (preSection != -1 && preSection != headview.tag) {
            [self animationRowsWithSectionItem:[self.arrayDetails objectAtIndex:preSection] andView:headview];
        }
        preSection = headview.tag;
        
        
        BOOL isOpen = [[item objectForKey:@"open"] boolValue];
        UIImageView *icon = (UIImageView*)[headview viewWithTag:headview.tag+1001];
        
        [UIView animateWithDuration:0.2 animations:^{
            icon.transform = CGAffineTransformMakeRotation(M_PI);
        } completion:^(BOOL finished) {
            
        }];
        
        if (isOpen) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:headview.tag];
            CustomerDetailCellC *cell = (CustomerDetailCellC *)[self.tableviewDetails cellForRowAtIndexPath:indexPath];
            [cell stopPlay];
            
            [self animationRowsWithSectionTag:headview.tag complete:^{
            }];
        }else {
            [self animationRowsWithSectionTag:headview.tag complete:^{
            }];
        }
    }else{
        NSString *operationType = @"";
        NSInteger logType = 0;
        if ([item objectForKey:@"LOGTYPE"]) {
            logType = [[item safeObjectForKey:@"LOGTYPE"] integerValue];
        }
        if ([item objectForKey:@"OPERATIONTYPE"]) {
            operationType = [item safeObjectForKey:@"OPERATIONTYPE"];
        }
        
        NSString *logId = @"";
        if ([item objectForKey:@"BUSINESSID"]) {
            logId = [item safeObjectForKey:@"BUSINESSID"];
        }
    

        ///ID返回为空
        if ([logId isEqualToString:@""]) {
            [CommonFuntion showToast:@"日志ID为空" inView:self.view];
            return;
        }
        
        ///新增、修改
        if ([operationType isEqualToString:@"1"] || [operationType isEqualToString:@"2"]) {
            
            switch (logType) {
                case 1:
                    ///销售
                    [self gotoSaleViewDetais:logId];
                    break;
                case 2:
                    ///售后
                    [self gotoAfterServiceViewDetais:logId];
                    break;
                case 3:
                    ///合同
                    [self gotoContractViewDetais:logId];
                    break;
                case 4:
                    ///订单
                    [self gotoOrderViewDetais:logId];
                    break;
                    
                default:
                    break;
            }
            
        }else if ([operationType isEqualToString:@"3"]) {
            ///
            [CommonFuntion showToast:@"当前业务已被删除" inView:self.view];
        }else if ([operationType isEqualToString:@"fax"]) {
//            title = @"传真";
        }else if ([operationType isEqualToString:@"mail"]) {
//            title = @"邮件";
        }
        
        
    }
}


-(void)animationRowsWithSectionItem:(NSDictionary *)item andView:(UIView *)headview{
    BOOL isOpen = [[item objectForKey:@"open"] boolValue];
    UIImageView *icon = (UIImageView*)[headview viewWithTag:headview.tag+1001];
    
    [UIView animateWithDuration:0.2 animations:^{
        icon.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:^(BOOL finished) {
        
    }];
    
    if (isOpen) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:preSection];
        CustomerDetailCellC *cell = (CustomerDetailCellC *)[self.tableviewDetails cellForRowAtIndexPath:indexPath];
        [cell stopPlay];
        
        [self animationRowsWithSectionTag:preSection complete:^{
        }];
        
        
    }
}

- (void)animationRowsWithSectionTag:(NSInteger)tag complete:(void(^)())complete {
    
    // 更新数据源
    NSMutableDictionary *item = [self.arrayDetails objectAtIndex:tag];
    
    NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:item];
    [mutableItemNew setValue:@(!([[item objectForKey:@"open"] boolValue])) forKey:@"open"];
    //修改数据
    [self.arrayDetails setObject: mutableItemNew atIndexedSubscript:tag];
    
    // 刷新指定section
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:tag];
    [self.tableviewDetails reloadSections:set withRowAnimation:UITableViewRowAnimationFade];

    complete();
}

///刷新展开状态
-(void)refreshOpenStatus:(NSInteger)section{
    ///初始化open标记
    NSInteger count = 0;
    if (self.arrayDetails) {
        count = [self.arrayDetails count];
    }
    NSDictionary *item;
    NSMutableDictionary *mutableItemNew;
    for (int i=0; i != section && i<count; i++) {
        item = [self.arrayDetails objectAtIndex:i];
        mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:item];
        
        [mutableItemNew setValue:@(NO) forKey:@"open"];
        
        [self.arrayDetails setObject: mutableItemNew atIndexedSubscript:i];
    }
}

///获取通讯日志日期时间
-(NSString *)getVoiceDateTime:(NSDictionary *)item{
    
    NSString *callDate = @"";
    if ([item objectForKey:@"CREATETIME"]) {
        callDate = [item safeObjectForKey:@"CREATETIME"];
    }
//    NSLog(@"callDate:%@",callDate);
    if (callDate.length > 16) {
        callDate = [callDate substringToIndex:16];
        callDate = [callDate substringFromIndex:5];
    }
    return callDate;
}

///获取通讯日志title
-(NSString *)getVoiceTitleName:(NSDictionary *)item{
    NSString *callTitle = @"电话";
    return callTitle;
}

///获取通讯日志时长
-(NSString *)getVoiceDuration:(NSDictionary *)item{
    ///duration
    ///TotleTime
    int  totleTime = 0;
    if ([item objectForKey:@"DETAIL"] ) {
        totleTime = [[item safeObjectForKey:@"DETAIL"] intValue];
    }
    return [NSString stringWithFormat:@"%i秒",totleTime];
}


///获取日志title
-(NSString *)getTitleName:(NSDictionary *)item{
    NSString *operationType = @"";
    NSString *logType = @"";
    NSString *title = @"";
    
    if ([item objectForKey:@"OPERATIONTYPE"]) {
        operationType = [item safeObjectForKey:@"OPERATIONTYPE"];
    }
    
    if ([item objectForKey:@"LOGTYPE"]) {
        logType = [item safeObjectForKey:@"LOGTYPE"];
    }
    
    if ([operationType isEqualToString:@"fax"]) {
        title = @"传真";
    }else if ([operationType isEqualToString:@"mail"]) {
        title = @"邮件";
    }else if ([operationType isEqualToString:@"1"]) {
        
        title = [NSString stringWithFormat:@"新增%@",[self getLogTypeName:[logType integerValue]]];
        
    }else if ([operationType isEqualToString:@"2"]) {
        title = [NSString stringWithFormat:@"修改%@",[self getLogTypeName:[logType integerValue]]];
    }else if ([operationType isEqualToString:@"3"]) {
        title = [NSString stringWithFormat:@"删除%@",[self getLogTypeName:[logType integerValue]]];
    }
    return title;
}


///获取日志类型对应的name
-(NSString *)getLogTypeName:(NSInteger)logtype{
    NSString *typeName = @"";
    
    switch (logtype) {
        case 1:
            typeName = @"销售";
            break;
        case 2:
            typeName = @"售后";
            break;
        case 3:
            typeName = @"合同";
            break;
        case 4:
            typeName = @"订单";
            break;
            
        default:
            typeName = @"";
            break;
    }
    return typeName;
}

@end
