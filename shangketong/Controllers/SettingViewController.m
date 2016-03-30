//
//  SettingViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SettingViewController.h"
#import "AFNHttp.h"
#import "CommonConstant.h"
#import "LogoutCell.h"
#import "FeedbackViewController.h"
#import "ChangeCompanyViewController.h"
#import "GuideViewController.h"
#import "SettingPasswordController.h"
#import "SDImageCache.h"
#import "Dynamic_Data.h"
#import "NSUserDefaults_Cache.h"
#import "FMDB_SKT_CACHE.h"
#import "CommonFuntion.h"
#import <MBProgressHUD.h>
#import "IM_FMDB_FILE.h"
#import "CommonCheckVersion.h"

#import "LLC_NSUserDefaults_Cache.h"
#import "MenuItemSwitchCell.h"
#import "FMDB_LLC_AUDIO.h"
#import "LocalCacheUtil.h"

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
{
    ///是否可切换公司
    BOOL isCanChangeCompany;
}

@property(strong,nonatomic) UITableView *tableviewSetting;
@property(strong,nonatomic) NSMutableArray *arraySetting;
@end

@implementation SettingViewController

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = kView_BG_Color;
    [self initTableview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self.tableviewSetting reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

#pragma mark - 初始化数据
-(void)initData{
    isCanChangeCompany = FALSE;
    NSArray *arrayCompany = [NSUserDefaults_Cache getCurCompanyLogined];
    if (arrayCompany && [arrayCompany count] > 1) {
        isCanChangeCompany = TRUE;
    }
    self.arraySetting = [[NSMutableArray alloc] init];
    NSArray *sectionArr;
    ///显示版本信息
    if ([[CommonCheckVersion getShowSKTVersionView] isEqualToString:@"show"]) {
        sectionArr = @[@{@"title":@"版本更新",@"cellType":@"cellA",@"eventIndex":@"0"}];
        [self.arraySetting addObject:sectionArr];
    }
    
    ///常规显示信息
    sectionArr = @[@{@"title":@"关于",@"cellType":@"cellB",@"eventIndex":@"1"},
                     @{@"title":@"清空缓存",@"cellType":@"cellB",@"eventIndex":@"2"},
                      @{@"title":@"意见反馈",@"cellType":@"cellB",@"eventIndex":@"3"},
                      @{@"title":@"联系我们",@"cellType":@"cellB",@"eventIndex":@"4"}];
    [self.arraySetting addObject:sectionArr];
    
    // 修改密码
    sectionArr = @[@{@"title" : @"修改密码", @"cellType" : @"cellB", @"eventIndex" : @"9"}];
    [self.arraySetting addObject:sectionArr];
    
    ///常规显示信息
    sectionArr = @[@{@"title":@"消息通知",@"cellType":@"cellD",@"eventIndex":@"7"},
                   @{@"title":@"消息提示音",@"cellType":@"cellD",@"eventIndex":@"8"}];
    [self.arraySetting addObject:sectionArr];
    
    
    ///显示切换公司
    if (isCanChangeCompany) {
        sectionArr = @[@{@"title":@"切换公司",@"cellType":@"cellB",@"eventIndex":@"5"}];
        [self.arraySetting addObject:sectionArr];
    }
    
    sectionArr = @[@{@"title":@"退出登录",@"cellType":@"cellC",@"eventIndex":@"6"}];
    [self.arraySetting addObject:sectionArr];
}


#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewSetting = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStyleGrouped];
    self.tableviewSetting.delegate = self;
    self.tableviewSetting.dataSource = self;
    self.tableviewSetting.sectionFooterHeight = 0;
    self.tableviewSetting.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
    self.tableviewSetting.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    [self.view addSubview:self.tableviewSetting];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewSetting setTableFooterView:v];
}


#pragma mark - tableview delegate

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 120)];
        headView.backgroundColor = VIEW_BG_COLOR;
        
        UIImageView *imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake((kScreen_Width-60)/2, 20, 60, 60)];
        imgIcon.image = [UIImage imageNamed:@"logo_skt.png"];
        [headView addSubview:imgIcon];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, kScreen_Width, 20)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:17.0];
        label.textColor = [UIColor grayColor];
//        label.text = [NSString stringWithFormat:@"商客通%@(%@)",SKT_VERSION_NO,BETA_NO];
        label.text = [NSString stringWithFormat:@"商客通%@",SKT_VERSION_NO];
        [headView addSubview:label];
        
        return headView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 120.0;
    }
    return 15.0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
   
    if (self.arraySetting) {
        return [self.arraySetting count];
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self.arraySetting objectAtIndex:section] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *item = [[self.arraySetting objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if ([[item objectForKey:@"cellType"] isEqualToString:@"cellA"]) {
        
        static NSString *cellIdentifier = @"SettingCellAIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            cell.accessoryType  = UITableViewCellAccessoryNone;
        }
        
        [self setContentDetails:cell withTitle:[item objectForKey:@"title"]];
        
        if (isNewVersion) {
            NSDictionary *versionInfo = [CommonCheckVersion getSKTAppVersionInfo];
            NSString *newVersionCode = [versionInfo safeObjectForKey:@"versionName"];
            NSString *newTag = @"new";
            
            NSMutableAttributedString *versionCodeStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"v%@ %@",newVersionCode,newTag]];
            NSRange redRange = NSMakeRange([[versionCodeStr string] rangeOfString:@"new"].location, [[versionCodeStr string] rangeOfString:@"new"].length);
            [versionCodeStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:redRange];
            [cell.detailTextLabel setAttributedText:versionCodeStr];

        }else{
            cell.detailTextLabel.text = @"已是最新版本";
        }
        return cell;
        
    }else if ([[item objectForKey:@"cellType"] isEqualToString:@"cellB"]) {
        
        static NSString *cellIdentifier = @"SettingCellBIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell==nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
        }
        [self setContentDetails:cell withTitle:[item objectForKey:@"title"]];
        return cell;
        
    }else if ([[item objectForKey:@"cellType"] isEqualToString:@"cellC"]) {
        LogoutCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogoutCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"LogoutCell" owner:self options:nil];
            cell = (LogoutCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        [cell setCellDetails:@"退出登录"];
        return cell;
    }else if ([[item objectForKey:@"cellType"] isEqualToString:@"cellD"]) {
        MenuItemSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemSwitchCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MenuItemSwitchCell" owner:self options:nil];
            cell = (MenuItemSwitchCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        [cell setCellDetail:item];
        __weak typeof(self) weak_self = self;
        cell.NotifySwitchBlock = ^(){
            [weak_self.tableviewSetting reloadData];
        };
        return cell;
    }
    
    return nil;
}

-(void)setContentDetails:(UITableViewCell *)cell withTitle:(NSString *)title{
    cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    cell.textLabel.text = title;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger cellEventIndex = [[[[self.arraySetting objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"eventIndex"] integerValue];
    
    switch (cellEventIndex) {
        case 0:
            [self checkVersion];
            break;
        case 1:
            [self aboutSKT];
            break;
        case 2:
            [self clearCache];
            break;
        case 3:
            [self feedback];
            break;
        case 4:
            [self contactWithSKT];
            break;
        case 5:
            [self changeCompany];
            break;
        case 6:
            [self logout];
            break;
        case 9: {   // 修改密码
            SettingPasswordController *setPassword = [[SettingPasswordController alloc] init];
            [self.navigationController pushViewController:setPassword animated:YES];
        }
        default:
            break;
    }
}

#pragma mark - 点击事件

///关于
-(void)aboutSKT{
    UIAlertView *alertAbout = [[UIAlertView alloc] initWithTitle:@"关于" message:[NSString stringWithFormat:@"产品名称:商客通 \n版本号:%@ \n开发者:商客通尚景科技（上海）股份有限公司 \n网址:www.sunke.com \n服务电话:400-999-0000",SKT_VERSION_NO] delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    [alertAbout show];
}

///清空缓存
-(void)clearCache{
    UIAlertView *alertClearCache = [[UIAlertView alloc] initWithTitle:@"确认清空缓存?" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alertClearCache.tag = 101;
    [alertClearCache show];
}

///意见反馈
-(void)feedback{
    FeedbackViewController *controller = [[FeedbackViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

///联系我们
-(void)contactWithSKT{
//    @"业务咨询: 4000500907"
//    @"技术支持: 4000826869"
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles: @"商业咨询: 400-999-0000",@"技术支持: 400-999-0000",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}

///切换公司
-(void)changeCompany{
    ChangeCompanyViewController *controller = [[ChangeCompanyViewController alloc] init];
    controller.title = @"切换公司";
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - UIActionSheet
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex:%ti",buttonIndex);
    NSString *title = @"400-999-0000";
    if (buttonIndex == 0) {
        ///业务咨询
        title = [NSString stringWithFormat:@"拨打商业咨询:%@",title];
        [CommonFuntion callToCurPhoneNum:@"4009990000" atView:self.view];
    }else if (buttonIndex == 1) {
        ///技术支持
        title = [NSString stringWithFormat:@"拨打技术支持:%@",title];
        [CommonFuntion callToCurPhoneNum:@"4009990000" atView:self.view];
    }
    
//    UIAlertView *alertClearCache = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
//    alertClearCache.tag = 301;
//    [alertClearCache show];
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //删除缓存
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            NSLog(@"清除缓存");
            [self clearData];
            [CommonFuntion showToast:@"清除缓存成功" inView:self.view];
        }
    }else if (alertView.tag == 202){
        if (buttonIndex == 1) {
            NSLog(@"退出登录");
            [self sendCmdLogout];
        }
    }else if (alertView.tag == 301){
        if (buttonIndex == 1) {
            NSLog(@"拨打电话");
            [CommonFuntion callToCurPhoneNum:@"4009990000" atView:self.view];
        }
    }
    
    
    // 未点击按钮
    if(alertView.tag == 998)
    {
        NSLog(@"点击--998-->");
        flagOfBecomeActive = 1;
        if(buttonIndex == 0)
        {
        }
        else if(buttonIndex == 1)
        {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:SKT_URL_APPATORE]];
            
        }
    }
    
    
    if(alertView.tag == 999)
    {
        NSLog(@"点击--999-->");
        flagOfBecomeActive = 1;
        if(buttonIndex == 0)
        {
            //强制更新版本
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:SKT_URL_APPATORE]];
        }
    }
}


-(void)clearData{
    ///清除图片相关缓存
    [[SDImageCache sharedImageCache] getSize];
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDisk];

    
    
    ///通讯录请求参数
    //    [NSUserDefaults_Cache setAddressBookServiceTime:@""];
    ///清除通讯录相关缓存
//    [FMDB_SKT_CACHE delete_AddressBook_AllDataCache];
//    [NSUserDefaults_Cache setAddressBookLatelyContacts:nil];

    
    [FMDB_SKT_CACHE delete_Campaign_AllDataCache];
    [FMDB_SKT_CACHE closeDataBase];
    
    ///清除音频缓存
    [self clearAudioCahce];
}

///清除音频缓存
-(void)clearAudioCahce{

    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dir = [docDir stringByAppendingPathComponent:@"AudioDownload"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSLog(@"clearAudioCahce dir:%@",dir);
    if([fileManager removeItemAtPath:dir error:nil]){
        NSLog(@"删除音频缓存成功");
    }else{
        NSLog(@"删除音频缓存失败");
    }
    [[FMDB_LLC_AUDIO sharedFMDB_LLC_AUDIO_Manager] deleteFMDB];
}

#pragma mark - 退出登录
-(void)logout{
    
    UIAlertView *alertLogout = [[UIAlertView alloc] initWithTitle:@"确定退出吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出", nil];
    alertLogout.tag = 202;
    [alertLogout show];
}

-(void)sendCmdLogout{
    ///标记登录状态
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:appDelegateAccessor.window];
    [appDelegateAccessor.window addSubview:hud];
    [hud show:YES];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",kNetPath_Web_Server_Base,kNetPath_Logout] params:nil success:^(id responseObj) {
        [hud hide:YES];
        //字典转模型
        NSLog(@"退出登录 responseObj:%@",responseObj);
        [LocalCacheUtil clearCacheBylogoutComplete:1];
        GuideViewController *guideController = [[GuideViewController alloc] init];
        appDelegateAccessor.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:guideController];
        
    } failure:^(NSError *error) {
        NSLog(@"退出登录error:%@",error);
        [hud hide:YES];
        [LocalCacheUtil clearCacheBylogoutComplete:1];
        GuideViewController *guideController = [[GuideViewController alloc] init];
        guideController.flagToLoginView = @"yes";
        appDelegateAccessor.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:guideController];
        
    }];
}



#pragma mark - 检测版本
///检测版本
-(void)checkVersion{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",kNetPath_User_Server_Base,SKT_CHECK_APP_VERSION] params:params success:^(id responseObj) {
        [hud hide:YES];
        //字典转模型
        NSLog(@"检测版本信息 responseObj:%@",responseObj);
        if ([[responseObj objectForKey:@"status"] intValue] == 0) {
            ///存储当前信息
            [CommonCheckVersion setSKTAppVersionInfo:responseObj];
            
            Boolean isShowUpdate = TRUE;
            if ([responseObj objectForKey:@"showUpdate"] != nil) {
                isShowUpdate = [[responseObj objectForKey:@"showUpdate"] boolValue];
            }
            if (!isShowUpdate) {
                ///显示版本信息
                [CommonCheckVersion setShowSKTVersionView:@"show"];
            }else{
                ///不显示版本信息
                [CommonCheckVersion setShowSKTVersionView:@"notshow"];
//                ///刷新UI 数据
//                [self initData];
//                [self.tableviewSetting reloadData];
            }
            
            
            ///如果有新版本  且显示
            NSString *versionCode = [responseObj safeObjectForKey:@"versionCode"];

            if (versionCode && [SKT_VERSION_CODE compare:versionCode] == -1 && !isShowUpdate) {
                isNewVersion = YES;
                
                Boolean isNeedUpdate = TRUE;
                NSString *updateRemark = @"";
                if ([responseObj objectForKey:@"needUpdate"] != nil) {
                    isNeedUpdate = [[responseObj objectForKey:@"needUpdate"] boolValue];
                }
                if ([responseObj objectForKey:@"remark"] != nil) {
                    updateRemark = [responseObj objectForKey:@"remark"];
                }
                
                if(!isNeedUpdate){
                    
                    NSLog(@"---强制更新--->");
                    if (updateRemark == nil || [updateRemark isEqualToString:@""]) {
                        updateRemark = @"有可用的新版本，更新之后才能正常使用";
                    }
                    flagOfBecomeActive = 0;
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"版本提示" message:updateRemark delegate:self cancelButtonTitle:@"立即升级" otherButtonTitles:nil, nil];
                    [alert setTag:999];
                    [alert show];
                    
                }else
                {
                    flagOfBecomeActive = 0;
                    if (updateRemark == nil || [updateRemark isEqualToString:@""]) {
                        updateRemark = @"有可用的新版本，是否更新？";
                    }
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"版本提示" message:updateRemark delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"立即升级", nil];
                    [alert setTag:998];
                    
                    [alert show];
                }
            }
            
        }else{
            [CommonFuntion showToast:@"获取版本信息失败" inView:self.view];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        NSLog(@"checkSKTVersion  error:%@",error);
        [CommonFuntion showToast:NET_ERROR inView:self.view];
    }];
    
}




@end
