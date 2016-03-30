//
//  ChangeCompanyViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-7-15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ChangeCompanyViewController.h"
#import "CommonConstant.h"
#import "CommonFuntion.h"
#import "ChangeCompanyCell.h"
#import "AFNHttp.h"
#import <MBProgressHUD.h>
#import "RootTabBarController.h"
#import "NSUserDefaults_Cache.h"
#import "Dynamic_Data.h"
#import "FMDB_SKT_CACHE.h"
#import "IM_FMDB_FILE.h"
#import "CommonModuleFuntion.h"
#import "LLC_NSUserDefaults_Cache.h"

@interface ChangeCompanyViewController ()<UITableViewDataSource,UITableViewDelegate>{
    ///当前选中的公司下标
    NSInteger indexSelect;
    
    ///底部view
    UIView *bottomView;
    BOOL isShowFooterView;
    NSArray *arrayCompany;
}

@property(strong,nonatomic) UITableView *tableviewChangeCompany;


@end

@implementation ChangeCompanyViewController

- (void)loadView
{
    [super loadView];

    self.view.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    [self initTableview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    arrayCompany = [NSUserDefaults_Cache getCurCompanyLogined];
    [self initSelectdeCompany];
    isShowFooterView = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableviewChangeCompany reloadData];
    [self creatBottomView];
}

#pragma mark - 初始化数据
-(void)initSelectdeCompany{
    indexSelect = 0;
    NSInteger count = 0;
    if (arrayCompany) {
        count = [arrayCompany count];
    }
    Boolean isFound = FALSE;
    for (int i=0; !isFound && i<count; i++) {
        if ([appDelegateAccessor.moudle.userId longLongValue] == [[[arrayCompany objectAtIndex:i] safeObjectForKey:@"id"] longLongValue]) {
            isFound = TRUE;
            indexSelect = i;
        }
    }
}


#pragma mark - 底部view
-(void)creatBottomView{
    NSLog(@"contentSize.height:%f",self.tableviewChangeCompany.contentSize.height);
    NSLog(@"kScreen_Height:%f",kScreen_Height);
    if (self.tableviewChangeCompany.contentSize.height < kScreen_Height) {
        isShowFooterView = YES;
        return;
    }
    
    isShowFooterView = NO;
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height-60, kScreen_Width, 60)];
//    bottomView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
//    bottomView.alpha = 0.7;
    
    UIButton *btnChange = [UIButton buttonWithType:UIButtonTypeCustom];
    btnChange.frame = CGRectMake(10, 15, kScreen_Width-20, 35);
    [btnChange setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnChange.titleLabel.font = [UIFont systemFontOfSize:14.0];
//    [btnChange setBackgroundImage:[UIImage imageNamed:@"UMS_account_login.png"] forState:UIControlStateNormal];
//    btnChange.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    
    btnChange.layer.cornerRadius = 3;
    [btnChange.layer setMasksToBounds:YES];
    //    btnChange.imageView.layer.cornerRadius = 5;
    NSString *title = @"";
    if ([self.title isEqualToString:@"登录"]) {
        title = @"进入首页";
    }else{
        title = @"进入";
    }
    [btnChange setTitle:title forState:UIControlStateNormal];
    [btnChange addTarget:self action:@selector(changeCompany) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:btnChange];
    
    [self.view addSubview:bottomView];
}

#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewChangeCompany = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStyleGrouped];
    self.tableviewChangeCompany.delegate = self;
    self.tableviewChangeCompany.dataSource = self;
    self.tableviewChangeCompany.sectionFooterHeight = 0;
    self.tableviewChangeCompany.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    self.tableviewChangeCompany.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
    [self.view addSubview:self.tableviewChangeCompany];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewChangeCompany setTableFooterView:v];
}


#pragma mark - tableview delegate

/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableviewChangeCompany)
    {
        NSLog(@"contentOffset y:%f",scrollView.contentOffset.y);

        if (scrollView.contentOffset.y > 45) {
            bottomView.hidden = NO;
        }else
        {
            bottomView.hidden = YES;
        }
        
        
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.frame.size.height) {
        //滑到底部加载更多
        NSLog(@"滑到底部加载更多");
    }
    if (scrollView.contentOffset.y == 0) {
        //滑到顶部更新
        NSLog(@"滑到顶部更新");
    }
}
*/

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 120)];
    headView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreen_Width, 40)];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:14.0];
    label.textColor = [UIColor grayColor];
    label.text = @"请选择要进入的公司";
    [headView addSubview:label];
    
    return headView;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (isShowFooterView) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 60)];
        footerView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
        
        UIButton *btnChange = [UIButton buttonWithStyle:StrapPrimaryStyle andTitle:@"" andFrame:CGRectMake(10, 15, kScreen_Width-20, 35) target:self action:@selector(changeCompany)];
        
//        UIButton *btnChange = [UIButton buttonWithType:UIButtonTypeCustom];
//        btnChange.frame = CGRectMake(10, 15, kScreen_Width-20, 35);
//        [btnChange setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        btnChange.titleLabel.font = [UIFont systemFontOfSize:14.0];
//        [btnChange setBackgroundImage:[UIImage imageNamed:@"UMS_account_login.png"] forState:UIControlStateNormal];
//        btnChange.backgroundColor = COMMEN_LABEL_COROL;
//        btnChange.layer.cornerRadius = 3;
//        [btnChange.layer setMasksToBounds:YES];
        //    btnChange.imageView.layer.cornerRadius = 5;
        NSString *title = @"";
        if ([self.title isEqualToString:@"登录"]) {
            title = @"进入首页";
        }else{
            title = @"进入";
        }
        [btnChange setTitle:title forState:UIControlStateNormal];
//        [btnChange addTarget:self action:@selector(changeCompany) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:btnChange];
        
        return footerView;
    }
    return nil;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 60.0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (arrayCompany) {
        return [arrayCompany count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChangeCompanyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChangeCompanyCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ChangeCompanyCell" owner:self options:nil];
        cell = (ChangeCompanyCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    [cell setCellDetails:[arrayCompany objectAtIndex:indexPath.row]];
    if (indexSelect == indexPath.row) {
        cell.imgCheck.image = [UIImage imageNamed:@"quickSelect_blue.png"];
    }else{
        cell.imgCheck.image = [UIImage imageNamed:@"quickSelect_gray.png"];
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    indexSelect = indexPath.row;
    [self.tableviewChangeCompany reloadData];
}


#pragma mark - 进入事件
-(void)changeCompany{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    long long companyId = [[[arrayCompany objectAtIndex:indexSelect] objectForKey:@"id"] longLongValue];
    NSLog(@"companyId:%lli",companyId);
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithLongLong:companyId] forKey:@"tenantId"];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",kNetPath_Web_Server_Base,kNetPath_ChooseCompany] params:params success:^(id responseObj) {
        [hud hide:YES];
        //字典转模型
        NSLog(@"切换公司事件 responseObj:%@",responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {

            NSString *functionCodes = responseObj[@"functionCodes"];
            
            ///置空实例
            [FMDB_SKT_CACHE setFMDB_SKT_CACHE_NULL:nil];
            // 删除FMDB
            [[FMDBManagement sharedFMDBManager] deleteFMDB];
            // 删除通讯录请求时间
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAddressBookServerTime];
            NSLog(@"上次登录的公司id: %@", appDelegateAccessor.moudle.userCompanyId);
            //清除IM缓存
            if ([responseObj objectForKey:@"id"]) {
                if ([appDelegateAccessor.moudle.userId integerValue] != [[responseObj safeObjectForKey:@"id"] integerValue]) {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IMAddressServerTime"];
//                    [IM_FMDB_FILE delete_IM_AllRecentContact];
//                    [IM_FMDB_FILE delete_IM_ConversationList];
//                    [IM_FMDB_FILE delete_IM_AllGroupMessageList];
//                    [IM_FMDB_FILE delete_IM_AllAddressBook];
//                    [IM_FMDB_FILE delete_IM_LastMessageList];
                    [IM_FMDB_FILE setIM_FMDB_FILE_NULL:nil];
                    [IM_FMDB_FILE removeIM_FMDB];
                }
            }
            [appDelegateAccessor removeTimer];
            [appDelegateAccessor removeHeartTimer];
            [appDelegateAccessor deleteWebSocket];
            [appDelegateAccessor _reconnect];
            appDelegateAccessor.moudle.userId =[responseObj safeObjectForKey:@"id"] ;
            appDelegateAccessor.moudle.userName = [responseObj safeObjectForKey:@"name"];
            appDelegateAccessor.moudle.userCompanyId = [responseObj safeObjectForKey:@"companyId"];
            appDelegateAccessor.moudle.IM_tokenString = [responseObj safeObjectForKey:@"token"];
            appDelegateAccessor.moudle.userFunctionCodes = [responseObj safeObjectForKey:@"functionCodes"];
            appDelegateAccessor.moudle.isOpen_cluePool = [[responseObj safeObjectForKey:@"cluePoolOpen"] integerValue];
            appDelegateAccessor.moudle.isOpen_customerPool = [[responseObj safeObjectForKey:@"customerPoolOpen"] integerValue];
            ///缓存登录信息
            [NSUserDefaults_Cache setUserInfo:responseObj];
            
            [NSUserDefaults_Cache setUserLoginStatus:true];
            [NSUserDefaults_Cache setUserLogOutStatus:0];
            
            ///设置动态相关缓存路径
            [Dynamic_Data setDynamicCacheFilePathByUserLoginInfo];
            
            ///初始化办公/CRM模块设置
            [CommonModuleFuntion initOAandCRMModuleOption];

            ///预加载
            [self setupRootViewController];
            [appDelegateAccessor getAllReportAndApprove];
        }else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self changeCompany];
            };
            [comRequest loginInBackground];
        }else{
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"切换公司失败";
            }
            NSLog(@"desc:%@",desc);
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        NSLog(@"error:%@",error);
        [CommonFuntion showToast:NET_ERROR inView:self.view];
    }];
}

- (void)setupRootViewController
{
    RootTabBarController *rootTabbarController = [[RootTabBarController alloc] init];
    appDelegateAccessor.window.rootViewController = rootTabbarController;
}

@end
