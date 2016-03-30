//
//  DefaultSettingViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-13.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "DefaultSettingViewController.h"
#import "CommonFunc.h"
#import "LLCenterUtility.h"
#import "CommonNoDataView.h"

@interface DefaultSettingViewController (){
    ///是否处于编辑状态
    BOOL isEditing;
    ///当前选择的类型
    NSString *curType;
}
@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@end

@implementation DefaultSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"默认设置";
    [super customBackButton];
    isEditing = FALSE;
    self.view.backgroundColor = COLOR_BG;
    [self intViewFrame];
    curType = @"";
    self.viewContentBg.hidden = YES;
    ///默认不可编辑
    self.btnCompanyCustomer.enabled = NO;
    self.btnPersonalCustomer.enabled = NO;
    ///初始化默认设置
    [self initDefaultSetting];
}


#pragma mark - Nav Bar
-(void)addNavBar{
    
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonPress)];
    self.navigationItem.rightBarButtonItem = rightButton;
}


#pragma mark-  保存事件
-(void)saveButtonPress {
    if (isEditing) {
        if (![CommonFunc checkNetworkState]) {
            [CommonFuntion showToast:@"无网络可用,加载失败" inView:self.view];
            return;
        }
        ///保存操作
        [self updateDefaultSetting];
    }else{
        isEditing = TRUE;
        self.btnCompanyCustomer.enabled = YES;
        self.btnPersonalCustomer.enabled = YES;
        self.navigationItem.rightBarButtonItem.title = @"保存";
    }
}

///选择客户类型
- (IBAction)selectCustomerType:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    
    ///公司客户
    if (tag == 10) {
        curType = @"company";
    }else if(tag == 11){
        ///个人客户
        curType = @"personal";
    }
    [self notifySelect];
}

///刷新view
-(void)notifySelect{
    NSString *companyImg = @"img_select_unselect.png";
    NSString *personalImg = @"img_select_unselect.png";
    
    if ([curType isEqualToString:@"company"]) {
        [self.btnCompanyCustomer setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnPersonalCustomer setTitleColor:COLOR_LIGHT_BLUE forState:UIControlStateNormal];
        companyImg = @"button_status_selected.png";
        personalImg = @"button_status_unselected.png";
    }else{
        [self.btnCompanyCustomer setTitleColor:COLOR_LIGHT_BLUE forState:UIControlStateNormal];
        [self.btnPersonalCustomer setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        companyImg = @"button_status_unselected.png";
        personalImg = @"button_status_selected.png";
    }
    [self.btnCompanyCustomer setBackgroundImage:[UIImage imageNamed:companyImg] forState:UIControlStateNormal];
    [self.btnPersonalCustomer setBackgroundImage:[UIImage imageNamed:personalImg] forState:UIControlStateNormal];
}


///初始化view frame
-(void)intViewFrame{
    NSInteger width = (DEVICE_BOUNDS_WIDTH-25*3)/2;
    self.btnCompanyCustomer.frame = CGRectMake(25, 55, width, 40);
    self.btnPersonalCustomer.frame = CGRectMake(width+25+25, 55, width, 40);
    self.viewContentBg.frame = CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 110);
}


#pragma mark - 网络请求

#pragma mark -初始化默认设置
-(void)initDefaultSetting{
    [self clearViewNoData];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_INIT_DEFAULT_SETTING_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"默认设置jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            if ([jsonResponse objectForKey:@"resultMap"] ) {
                [self addNavBar];
                self.viewContentBg.hidden = NO;
                curType = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"];
                [self notifySelect];
            }else{
                NSLog(@"data------>:<null>");
                [CommonFuntion showToast:@"加载异常" inView:self.view];
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self initDefaultSetting];
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
        [self notifyNoDataView];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        [self notifyNoDataView];
    }];
}


#pragma mark - 修改默认设置
-(void)updateDefaultSetting{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    ///传入：外呼线路类型（单向还是双向）
    ///传入：circuit
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    [rDict setValue:curType forKey:@"defaultSet"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_SAVE_DEFAULT_SETTING_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"修改默认设置jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [CommonFuntion showToast:@"编辑成功" inView:self.view];
            isEditing = FALSE;
            self.navigationItem.rightBarButtonItem.title = @"编辑";
            self.btnCompanyCustomer.enabled = FALSE;
            self.btnPersonalCustomer.enabled = FALSE;
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self updateDefaultSetting];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"编辑失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
}



#pragma mark - 没有数据时的view
-(void)notifyNoDataView{
    if (![self.viewContentBg isHidden]) {
        [self clearViewNoData];
    }else{
        [self setViewNoData:@"加载失败"];
    }
}

-(void)setViewNoData:(NSString *)title{
    if (self.commonNoDataView == nil) {
        self.commonNoDataView = [CommonFunc commonNoDataViewIcon:@"list_empty.png" Title:title optionBtnTitle:@""];
    }
    
    [self.view addSubview:self.commonNoDataView];
}

-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
    }
}

@end
