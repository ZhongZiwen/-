//
//  ContactBookAddNewLevel1ViewController.m
//  lianluozhongxin
//
//  Created by Vescky on 14-7-7.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "ContactBookAddNewLevel1ViewController.h"
#import "NavigationListViewController.h"
#import "NSString+JsonHandler.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"


@interface ContactBookAddNewLevel1ViewController ()<UITextFieldDelegate> {
//    UIButton* rightButton;
    
    NSInteger inNum ;
    
    NSString *selectedGroupNames;
    NSString *selectedGroupIds;
}

@end

@implementation ContactBookAddNewLevel1ViewController
@synthesize detailContactInfo;

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
    self.title = @"添加坐席";
    [self setCurViewFrame];
    labelGroups.text = @"请选择分组";
    tfJieruNum.text = [self.navigationDic safeObjectForKey:@"navigationName"];
    tfJieruNum.enabled = NO;
    tfPassword.delegate = self;
    tfPhone.delegate = self;
    tfUserName.delegate = self;
    tfUserNumber.delegate = self;
    [self setTextFiledCleafMode];
    
    //在整个view上加事件 在键盘弹出的情况下 点击其他地方隐藏键盘
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    
    [super customBackButton];
    
//    if (detailContactInfo) {
//        tfUserName.text = detailContactInfo.name;
//        tfUserNumber.text = detailContactInfo.jobNumber;
//        tfPhone.text = detailContactInfo.phoneNumber;
//    }
    
    inNum = 0;
    NSString *strRandom = @"";
    for(int i=0; i<6; i++)
    {
        strRandom = [ strRandom stringByAppendingFormat:@"%i",(arc4random() % 9)];
    }
    NSLog(@"随机数: %@", strRandom);
    
    tfPassword.text = strRandom;
    selectedGroupNames = @"";
    selectedGroupIds = @"";
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonAction)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    [self getGroups];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self hideKeyBoard];
}


-(void)viewTapped:(UITapGestureRecognizer*)tap
{
    [tfPassword resignFirstResponder];
    [tfPhone resignFirstResponder];
    [tfUserName resignFirstResponder];
    [tfUserNumber resignFirstResponder];
}

// 隐藏键盘
-(void)hideKeyBoard{
    [tfPassword resignFirstResponder];
    [tfPhone resignFirstResponder];
    [tfUserName resignFirstResponder];
    [tfUserNumber resignFirstResponder];
}

// clear icon  --zjp
-(void)setTextFiledCleafMode
{
    tfUserName.clearButtonMode =  UITextFieldViewModeWhileEditing;
    tfPhone.clearButtonMode =  UITextFieldViewModeWhileEditing;
    tfPassword.clearButtonMode =  UITextFieldViewModeWhileEditing;
    tfUserNumber.clearButtonMode =  UITextFieldViewModeWhileEditing;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rightBarButtonAction {
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (tfUserName.text.length < 1) {
        [CommonFuntion showToast:@"请输入姓名" inView:self.view];
        return;
    }
    if (tfUserName.text.length > 6) {
        [CommonFuntion showToast:@"姓名长度不能超过6位" inView:self.view];
        return;
    }
    if (tfUserNumber.text.length != 4) {
        [CommonFuntion showToast:@"请输入4位工号" inView:self.view];
        return;
    }
    
    if (![CommonFunc checkStringIsNum:tfUserNumber.text]) {
        [CommonFuntion showToast:@"工号由数字组成" inView:self.view];
        return;
    }
    
    
    if (tfPhone.text.length < 1) {
        [CommonFuntion showToast:@"电话不能为空!" inView:self.view];
        return;
    }
    
    
    if (tfPhone.text.length > 0 && (tfPhone.text.length < 11 || tfPhone.text.length > 15)) {
        [CommonFuntion showToast:@"请输入11-15位电话号码" inView:self.view];
        return;
    }
    
    
    
    /*
    if (![CommonFunc checkStringIsNum:tfPhone.text]) {
        [SVProgressHUD showErrorWithStatus:@"电话号码由数字组成"];
        return;
    }
    */
    
    NSString *password = tfPassword.text;
    if (password == nil || [password isEqualToString:@""]) {
        [CommonFuntion showToast:@"请输入密码" inView:self.view];
        //            [tfPassword becomeFirstResponder];
        return;
    }
    
    if (password.length < 6 || password.length > 16 || ![CommonFunc checkString:password inCharactersString:@""]) {
        [CommonFuntion showToast:@"密码由6-18位字母和数字组成" inView:self.view];
        //            [tfPassword becomeFirstResponder];
        return;
    }
    
    
    //有分组的，必须选择一个分组
    if (!selectedGroupIds || selectedGroupIds.length < 1) {
        [CommonFuntion showToast:@"请至少选择一个分组!" inView:self.view];
        return;
    }
    
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:tfUserName.text forKey:@"sitName"];
    [params setObject:tfUserNumber.text forKey:@"gh"];
    [params setObject:tfPhone.text forKey:@"phone"];
    [params setObject:password forKey:@"passWord"];
    
    Boolean inAgent = TRUE;
    Boolean outAgent = FALSE;
    
    
    if (inAgent) {
        [params setObject:@"true" forKey:@"inAgent"];
    }else
    {
        [params setObject:@"false" forKey:@"inAgent"];
    }
    
    if (outAgent) {
        [params setObject:@"true" forKey:@"outAgent"];
    }else
    {
        [params setObject:@"false" forKey:@"outAgent"];
    }
    
    
    
    
    [params setObject:[selectedGroupIds stringByReplacingOccurrencesOfString:@"," withString:@";"] forKey:@"deptIdStr"];
    
    
    NSLog(@"params:%@",params);
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_ADD_SIT_DETAIL_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            //保存成功
            [[NSNotificationCenter defaultCenter] removeObserver:self name:LLC_NOTIFICATON_SIT_LIST object:self];
            [CommonFuntion showToast:@"添加成功" inView:self.view];
            
            [self actionSuccess];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self rightBarButtonAction];
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
    if(self.NotifySitListBlock){
        self.NotifySitListBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}


// 获取工号和是否有下级部门 用于判断新增坐席是否需要选部门
- (void)getGroups {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_GH_AND_ISDEPT_ACTION] params:params success:^(id jsonResponse) {
        
        NSLog(@"jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            
            /*
            NSArray *deptList = [[[jsonResponse objectForKey:@"resultMap"] objectForKey:@"childs"] toJsonValue];
            if (deptList && [deptList isKindOfClass:NSClassFromString(@"NSArray")] && deptList.count > 0) {
                isNeedSelectGroup = TRUE;
                //有分组可选
                //                NSLog(@"有分组可选:%@",deptList);
                //                groupSelection.hidden = NO;
            }else{
                isNeedSelectGroup = FALSE;
                //如果为空就无需选择部门
            }
            
            if (isNeedSelectGroup) {
                labelGroups.text = @"请选择导航";
            }else
            {
                labelGroups.text = @"无任何导航";
            }
            */
            
            NSString *userCode = [[jsonResponse objectForKey:@"resultMap"] safeObjectForKey:@"userCode"];
            NSString *userName = [[jsonResponse objectForKey:@"resultMap"] safeObjectForKey:@"userName"];
            if ([userCode isKindOfClass:NSClassFromString(@"NSString")]) {
                tfUserNumber.text = userCode;
            }
            if ([userName isKindOfClass:NSClassFromString(@"NSString")]) {
                tfUserName.text = userName;
            }
            
            
            NSInteger outNum = 0;
            
            if ([jsonResponse objectForKey:@"resultMap"]  != nil) {
                
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"in_num"]) {
                    inNum = [[[jsonResponse objectForKey:@"resultMap"] safeObjectForKey:@"in_num"] integerValue];
                }
                
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"out_num"]) {
                    outNum = [[[jsonResponse objectForKey:@"resultMap"] safeObjectForKey:@"out_num"] integerValue];
                }
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getGroups];
            };
            [comRequest loginInBackgroundLLC];
        }else
        {
            NSString *desc = [jsonResponse objectForKey:@"desc"];
            if (desc == nil || [desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
            view_content_bg.hidden = YES;
            self.navigationItem.rightBarButtonItem = nil;
        }
        
        
    } failure:^(NSError *error) {
        view_content_bg.hidden = YES;
        self.navigationItem.rightBarButtonItem = nil;
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
    
}


#pragma mark - switch开关


-(void)setSwitchValue
{
   
}

- (IBAction)switchBgClickEvent:(id)sender{
    
   
}

-(IBAction)switchValueChange:(id)sender{
    
}

#pragma mark - Button Action
- (IBAction)btnAction:(id)sender {
    
    __weak typeof(self) weak_self = self;
    NavigationListViewController *controller = [[NavigationListViewController alloc] init];
    controller.navigationDic = self.navigationDic;
    controller.navigationType = @"child";
    controller.navigationSelectedIds = selectedGroupIds;
    controller.SelectNavigation = ^(NSString *strNames, NSString *strIds){
        selectedGroupNames = strNames;
        selectedGroupIds = strIds;
        [weak_self refreshGroupData:strNames navigationIds:strIds];
    };
    [self.navigationController pushViewController:controller animated:YES];
}


// 根据选的分组 刷新View显示
-(void)refreshGroupData:(NSString *)strNames navigationIds:(NSString *)strIds
{
    if(!strNames || [strNames isEqualToString:@""]){
        labelGroups.text = @"请选择分组";
    }else{
        NSArray *deptNameArr = [strNames componentsSeparatedByString:@","];
        if(deptNameArr && [deptNameArr count] > 0){
            if([deptNameArr count] > 1){
                labelGroups.text = [NSString stringWithFormat:@"%@ 等",[deptNameArr objectAtIndex:0] ];
            }else{
                labelGroups.text = [deptNameArr objectAtIndex:0] ;
            }
            
        }else{
            labelGroups.text = @"请选择分组";
        }
    }
}


#pragma mark - 验证是否符合
-(void)verificationOfPara:(NSString *)info andByTag:(NSString *)strTag{
    NSMutableDictionary *params = nil;
    NSString *errorInfos = @"";
    NSString *strUrl = @"";
    // 电话号码
    if([strTag isEqualToString:@"phone"]){
        strUrl = LLC_CHECK_BIND_PHONE_ACTION;
        errorInfos = @"校验电话号码失败";
        params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:info,@"phoneNum",
                  @"",@"userId", nil];
    }else if([strTag isEqualToString:@"no"]){
        //工号
        strUrl = LLC_CHECK_USER_CODE_ACTION;
        errorInfos = @"校验工号失败";
        params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:info,@"userCode",
                  @"",@"userId", nil];
    }
    
//    [SVProgressHUD showWithStatus:@"正在校验..."];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,strUrl] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"校验结果2:%@",jsonResponse);
        
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
        }
        else {
            
            NSString *desc = [jsonResponse objectForKey:@"desc"];
            if (desc == nil || [desc isEqualToString:@""]) {
                desc = errorInfos;
            }
            
            [CommonFuntion showToast:desc inView:self.view];
            
            //            if([strTag isEqualToString:@"phone"]){
            //                //                tfPhone.text = @"";
            //                [tfPhone becomeFirstResponder];
            //            }else
            //            {
            //                //                tfJobNumber.text = @"";
            //                [tfUserNumber becomeFirstResponder];
            //            }
            
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
}


#pragma mark - 编辑框事件
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self rightBarButtonAction];
    return YES;
}

// 开始编辑
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

// 结束编辑
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (tfUserName == textField) {
        
        NSString *name = textField.text;
        if (name == nil || [name isEqualToString:@""]) {
            [CommonFuntion showToast:@"请输入姓名" inView:self.view];
//            [tfUserName becomeFirstResponder];
            return;
        }
        
        if (name.length > 6) {
            [CommonFuntion showToast:@"姓名长度不能超过6位" inView:self.view];
//            [tfUserName becomeFirstResponder];
            return;
        }
        
    }else if (tfUserNumber == textField) {
        NSString *number = textField.text;
        if (number == nil || number.length != 4) {
            [CommonFuntion showToast:@"请输入4位工号" inView:self.view];
//            [tfUserNumber becomeFirstResponder];
            return;
        }
        
        if (![CommonFunc checkStringIsNum:number]) {
            [CommonFuntion showToast:@"工号由数字组成" inView:self.view];
            return;
        }
        NSLog(@"textFieldDidEndEditing-验证工号是否重复2-->");
        // 验证工号是否重复
        [self verificationOfPara:number andByTag:@"no"];
        
    }else if (tfPhone == textField) {
        
        
        
        NSString *phone = textField.text;
        if (phone == nil || phone.length < 1 || (phone != nil && phone.length > 0 && (phone.length < 11 || phone.length > 15))) {
            [CommonFuntion showToast:@"请输入11-15位电话号码" inView:self.view];
//            [tfPhone becomeFirstResponder];
            return;
        }
        
        if (![CommonFunc checkStringIsNum:phone]) {
            [CommonFuntion showToast:@"电话号码由数字组成" inView:self.view];
            return;
        }
        NSLog(@"textFieldDidEndEditing-验证是否已经被绑定2-->");
        // 验证是否已经被绑定
        [self verificationOfPara:phone andByTag:@"phone"];
        
    }else if (tfPassword == textField) {
        // 密码，默认初始密码为111111。由6-18位字母和数字组成
        NSString *passwork = textField.text;
        if (passwork == nil || [passwork isEqualToString:@""]) {
            [CommonFuntion showToast:@"请输入密码" inView:self.view];
//            [tfPassword becomeFirstResponder];
            return;
        }
        
        if (passwork.length < 6 || passwork.length > 16 || ![CommonFunc checkString:passwork inCharactersString:@""]) {
            [CommonFuntion showToast:@"密码由6-18位字母和数字组成" inView:self.view];
//            [tfPassword becomeFirstResponder];
            return;
        }
        
    }
}



#pragma mark - UI适配
-(void)setCurViewFrame
{
    self.view.frame = CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT);
    
    if (DEVICE_IS_IPHONE6) {
        [self setFrameByIphone6];
    }else if(DEVICE_IS_IPHONE6_PLUS)
    {
        [self setFrameByIphone6];
    }else if(!DEVICE_IS_IPHONE5)
    {
    }else
    {
    }
}

-(void)setFrameByIphone6
{
    NSInteger vX = DEVICE_BOUNDS_WIDTH - 320;
    
    groupSelection.frame = [CommonFunc setViewFrameOffset:groupSelection.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
    view_content_bg.frame = [CommonFunc setViewFrameOffset:view_content_bg.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    view_line1.frame = [CommonFunc setViewFrameOffset:view_line1.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    view_line2.frame = [CommonFunc setViewFrameOffset:view_line2.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    view_line3.frame = [CommonFunc setViewFrameOffset:view_line3.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    view_line4.frame = [CommonFunc setViewFrameOffset:view_line4.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    view_line5.frame = [CommonFunc setViewFrameOffset:view_line5.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    view_line6.frame = [CommonFunc setViewFrameOffset:view_line6.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
    tfJieruNum.frame = [CommonFunc setViewFrameOffset:tfJieruNum.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    tfUserName.frame = [CommonFunc setViewFrameOffset:tfUserName.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    tfUserNumber.frame = [CommonFunc setViewFrameOffset:tfUserNumber.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    tfPhone.frame = [CommonFunc setViewFrameOffset:tfPhone.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    tfPassword.frame = [CommonFunc setViewFrameOffset:tfPassword.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
    
    labelGroups.frame = [CommonFunc setViewFrameOffset:labelGroups.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
    
    btnExpand.frame = [CommonFunc setViewFrameOffset:btnExpand.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    btnGroupClick.frame = [CommonFunc setViewFrameOffset:btnGroupClick.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
    
}


@end
