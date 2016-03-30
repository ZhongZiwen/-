//
//  ContactBookDetailViewController.m
//  lianluozhongxin
//
//  Created by Vescky on 14-7-7.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "ContactBookDetailViewController.h"

#import "SimpleActionSheet.h"
#import "ContactBookAddNewLevel2ViewController.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"
#import "NSString+JsonHandler.h"
#import "CommonStaticVar.h"


#define Expand_Button_Reviewing_Status_Image [UIImage imageNamed:@"btn_circle_down_blue.png"]
#define Expand_Button_Editting_Status_Image [UIImage imageNamed:@"btn_to_right_gray.png"]

@interface ContactBookDetailViewController ()<UITextFieldDelegate,SimpleActionSheetDelegate,ContactBookAddNewLevel2ViewControllerDelegate> {
    bool isEditting,firstInit;
//    UIButton* rightButton;
    
    NSDictionary *dicSitInfos;//座席详情
    
    Boolean isAllowForNOorPhone;
    Boolean isFirstLoadView;
    
    NSInteger inNums,outNums;
    
    NSInteger heightScrContent;
    
    BOOL isNeedSelectGroup;//是否需要选择组别
    
    ///
    BOOL isInagent ;
    BOOL isOutagent;
    BOOL isInagentOld ;
    BOOL isOutagentOld;
}
@end

@implementation ContactBookDetailViewController
@synthesize detailContactInfo,groupName,groupId;

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
    isFirstLoadView  = YES;
    [self setCurViewFrame];

    tfPhone.delegate = self;
    tfUserName.delegate = self;
    tfJobNumber.delegate = self;
    [self setTextFiledCleafMode];
    
    //在整个view上加事件 在键盘弹出的情况下 点击其他地方隐藏键盘
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    
    inNums = 0;
    outNums = 0;
    scView.hidden = YES;
    firstInit = YES;
    
    switchJieTing.hidden = YES;
    switchWaiHu.hidden = YES;
    
    [self getGroupsAll];
    [self initView];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    [self refreshData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self hideKeyBoard];
}

-(void)viewTapped:(UITapGestureRecognizer*)tap
{
    [self hideKeyBoard];
}

// 隐藏键盘
-(void)hideKeyBoard{
    [tfPhone resignFirstResponder];
    [tfUserName resignFirstResponder];
    [tfJobNumber resignFirstResponder];
}

// clear icon  --zjp
-(void)setTextFiledCleafMode
{
    tfUserName.clearButtonMode =  UITextFieldViewModeWhileEditing;
    tfPhone.clearButtonMode =  UITextFieldViewModeWhileEditing;
    tfJobNumber.clearButtonMode =  UITextFieldViewModeWhileEditing;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private
- (void)initView {
    self.title = @"坐席详情";
    [super customBackButton];
    
    
    
    isEditting = FALSE;//非编辑状态
    
    [self getDetailInfo];
    
}

///boss 可编辑
-(void)addEditBtn{
    if (![[CommonStaticVar getAccountType] isEqualToString:@"boss"]) {
        return;
    }
    
    //costomize right button
//    rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];//
//    [rightButton setTitle:@"编辑" forState:UIControlStateNormal];
//    [rightButton setTitleColor:GetColorWithRGB(0, 110, 255) forState:UIControlStateNormal];
//    [rightButton setTitleColor:GetColorWithRGB(0, 150, 255) forState:UIControlStateHighlighted];
//    [rightButton setShowsTouchWhenHighlighted:YES];
//    rightButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
//    [rightButton addTarget:self action:@selector(rightBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem* actionItem= [[UIBarButtonItem alloc] initWithCustomView:rightButton];
//    [self.navigationItem setRightBarButtonItem:actionItem];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonAction)];
    self.navigationItem.rightBarButtonItem = rightButton;

}

// 根据接听按钮是否打开 控制组别View是否显示
-(void)isHideGrouTypepView:(Boolean)isHide
{
    label_site_type_tag.hidden = isHide;
    btnGroupClick.hidden = isHide;
    btnExpand.hidden = isHide;
    labelGroupName.hidden = isHide;
//    tbView.hidden = isHide;
    
    if (isHide) {
        NSLog(@"isHide----->");
        view_content_bg.frame = [CommonFunc setViewFrameOffset:view_content_bg.frame byX:0 byY:0 ByWidth:0 byHeight:-50];
    }else
    {
        if (isFirstLoadView) {
            isFirstLoadView  = NO;
        }else
        {
            NSLog(@"isShow----->");
            view_content_bg.frame = [CommonFunc setViewFrameOffset:view_content_bg.frame byX:0 byY:0 ByWidth:0 byHeight:50];
        }
    }
    
}

// 根据是否是编辑状态设置view
-(void)setViewByEditingStatus
{
    tbView.hidden = YES;
    if (isEditting) {
         [self setJieTingAndWaiHuByEdit];
//        switchJieTing.hidden = NO;
//        switchWaiHu.hidden = NO;
        if (inNums > 0) {
            switchJieTing.enabled = YES;
            [self.view sendSubviewToBack:btnJieTingBg];
            btnJieTingBg.hidden = YES;
        }else
        {
            ///非包年套餐用户：接听坐席总数无限制
            if (inNums == -1) {
                switchJieTing.enabled = YES;
                [self.view sendSubviewToBack:btnJieTingBg];
                btnJieTingBg.hidden = YES;
            }else{
                if (switchJieTing.isOn) {
                    switchJieTing.enabled = YES;
                    [self.view sendSubviewToBack:btnJieTingBg];
                    btnJieTingBg.hidden = YES;
                }else{
                    switchJieTing.enabled = NO;
                    [self.view bringSubviewToFront:btnJieTingBg];
                    btnJieTingBg.hidden = NO;
                }
            }
        }
        
        if (outNums > 0) {
            switchWaiHu.enabled = YES;
            [self.view sendSubviewToBack:btnWaiHuBg];
            btnWaiHuBg.hidden = YES;
        }else
        {
            if (switchWaiHu.isOn) {
                switchWaiHu.enabled = YES;
                [self.view sendSubviewToBack:btnWaiHuBg];
                btnWaiHuBg.hidden = YES;
            }else{
                switchWaiHu.enabled = NO;
                [self.view bringSubviewToFront:btnWaiHuBg];
                btnWaiHuBg.hidden = NO;
            }
        }
    }else
    {
        switchJieTing.hidden = YES;
        switchWaiHu.hidden = YES;
        btnJieTingBg.hidden = YES;
        btnWaiHuBg.hidden = YES;
        switchJieTing.enabled = NO;
        switchWaiHu.enabled = NO;
    }
}

- (void)refreshData {
    
    if (firstInit) {
        dataSource = [[NSMutableArray alloc] init];
        if (detailContactInfo.name && ![detailContactInfo.name isKindOfClass:NSClassFromString(@"NSNull")] && ![detailContactInfo.name isEqualToString:@"<null>"]) {
            tfUserName.text = detailContactInfo.name;
        }
        if (detailContactInfo.jobNumber && ![detailContactInfo.jobNumber isKindOfClass:NSClassFromString(@"NSNull")] && ![detailContactInfo.jobNumber isEqualToString:@"<null>"]) {
            tfJobNumber.text = detailContactInfo.jobNumber;
        }
        if (detailContactInfo.phoneNumber && ![detailContactInfo.phoneNumber isKindOfClass:NSClassFromString(@"NSNull")] && ![detailContactInfo.phoneNumber isEqualToString:@"<null>"]&& ![detailContactInfo.phoneNumber isEqualToString:@"null"]) {
            tfPhone.text = detailContactInfo.phoneNumber;
        }
        
//        BOOL isInagent = FALSE;
//        BOOL isOutagent = FALSE;
        NSInteger inNum = 0;
        NSInteger outNum = 0;
        if (dicSitInfos != nil) {
            
            if ([dicSitInfos objectForKey:@"INAGENT"]) {
                isInagent = [[dicSitInfos safeObjectForKey:@"INAGENT"] boolValue];
            }

            if ([dicSitInfos objectForKey:@"OUTAGENT"]) {
                isOutagent = [[dicSitInfos safeObjectForKey:@"OUTAGENT"] boolValue];
            }
            
            if ([dicSitInfos objectForKey:@"IN_NUM"]) {
                inNum = [[dicSitInfos safeObjectForKey:@"IN_NUM"] integerValue];
            }
            
            if ([dicSitInfos objectForKey:@"OUT_NUM"]) {
                outNum = [[dicSitInfos safeObjectForKey:@"OUT_NUM"] integerValue];
            }
        }
        isInagentOld = isInagent;
        isOutagentOld = isInagent;
        
        if (isInagent) {
            [switchJieTing setOn:YES];
            [self isHideGrouTypepView:NO];
        }else
        {
            [switchJieTing setOn:NO];
            [self isHideGrouTypepView:YES];
        };
        
        
        if (isOutagent) {
            [switchWaiHu setOn:YES];
        }else
        {
            [switchWaiHu setOn:NO];
        };
        
        [self setJieTingAndWaiHuView];
        /*
        if (inNum > 0) {
            switchJieTing.enabled = YES;
            [self.view sendSubviewToBack:btnJieTingBg];
            btnJieTingBg.hidden = YES;
        }else
        {
           switchJieTing.enabled = NO;
            [self.view bringSubviewToFront:btnJieTingBg];
            btnJieTingBg.hidden = NO;
        }
        
        if (outNum > 0) {
            switchWaiHu.enabled = YES;
            [self.view sendSubviewToBack:btnWaiHuBg];
            btnWaiHuBg.hidden = YES;
        }else
        {
            switchWaiHu.enabled = NO;
            [self.view bringSubviewToFront:btnWaiHuBg];
            btnWaiHuBg.hidden = NO;
        }
        
        if (isEditting) {
            
        }
         */
        
        inNums = inNum;
        outNums = outNum;
        
        [self setViewByEditingStatus];
        
        label_jieting_show.text = [NSString stringWithFormat:@"剩余接听坐席数%li个",(long)inNum];
        label_waihu_show.text = [NSString stringWithFormat:@"剩余外呼坐席数%li个",(long)outNum];
        
        firstInit = NO;
    }
    
//    tfJobNumber.text = detailContactInfo.jobNumber;
//    tfPhone.text = detailContactInfo.phoneNumber;
//    labelGroupName.text = [NSString stringWithFormat:@"%@ 等",detailContactInfo.departmentNameList];
    
//    if (dataSource.count && ![dataSource containsObject:groupName]) {
//        groupName = [[dataSource firstObject] objectForKey:@"name"];
//        groupId = [[dataSource firstObject] objectForKey:@"id"];
//    }
    
    if (detailContactInfo.departmentNameList && [detailContactInfo.departmentNameList isKindOfClass:NSClassFromString(@"NSString")]) {
        NSArray *deptNameArr = [detailContactInfo.departmentNameList componentsSeparatedByString:@","];
        NSArray *deptIDArr = [detailContactInfo.departmentIdList componentsSeparatedByString:@","];
        
        dataSource = [[NSMutableArray alloc] init];
        for (int i = 0; i < deptNameArr.count; i++) {
            if ([deptNameArr objectAtIndex:i] && [deptIDArr objectAtIndex:i]) {
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[deptNameArr objectAtIndex:i],@"name",
                                      [deptIDArr objectAtIndex:i],@"id", nil];
                if (dict) {
                    [dataSource addObject:dict];
                }
            }
        }
        
        if (dataSource.count && ![dataSource containsObject:groupName]) {
            groupName = [[dataSource firstObject] safeObjectForKey:@"name"];
            groupId = [[dataSource firstObject] safeObjectForKey:@"id"];
        }
        
        if ([dataSource count] > 1) {//groupName
            labelGroupName.text = [NSString stringWithFormat:@"%@ 等",groupName];
            btnExpand.hidden = NO;
        }
        else {
            labelGroupName.text = [[dataSource objectAtIndex:0] safeObjectForKey:@"name"];
            labelGroupName.text = groupName;
//            if (!isEditting) {
                btnExpand.hidden = YES;
//            }else{
//                btnExpand.hidden = NO;
//            }
        }
    }
    else {
        /*
        if (isEditting) {
            labelGroupName.text = @"未加入任何分组";
        }
        else {
            labelGroupName.text = @"未加入任何分组";
        }
        */
        
        
        if (isNeedSelectGroup) {
            if (isEditting) {
                btnExpand.hidden = NO;
            }else{
                btnExpand.hidden = YES;
            }
            labelGroupName.text = @"未加入任何分组";
        }else{
            
            labelGroupName.text = @"未加入任何分组";
            btnExpand.hidden = YES;
        }
        
    }
    
    //去掉上面显示的
    if (dataSource) {
        [dataSource removeObject:groupName];
    }
    
    CGRect tbRect = tbView.frame;
    tbRect.size.height = [dataSource count] * 50.0f;
    tbView.frame = tbRect;
    [tbView reloadData];
    
    if (tbRect.origin.y + tbRect.size.height > scView.frame.size.height) {
        scView.contentSize = CGSizeMake(scView.frame.size.width, tbRect.origin.y + tbRect.size.height + heightScrContent);
    }
}

- (void)rightBarButtonAction {
    
    if (!isEditting) {
        tfUserName.enabled = YES;
        tfJobNumber.enabled = YES;
        tfPhone.enabled = YES;
        
        self.navigationItem.rightBarButtonItem.title = @"完成";
        self.title = @"编辑";
        
        
        btnDelete.hidden = NO;
        btnExpand.selected = NO;
//        btnExpand.hidden = NO;
        
        
        
        if (isNeedSelectGroup) {
            if ([labelGroupName.text isEqualToString:@"未加入任何分组"]) {
                labelGroupName.text = @"请选择分组";
            }
            [btnExpand setImage:Expand_Button_Editting_Status_Image forState:UIControlStateNormal];
        }else
        {
            NSLog(@"----无任何组别---->");
            labelGroupName.text = @"无任何分组";
            btnExpand.hidden = YES;
            
            [btnExpand setImage:nil forState:UIControlStateNormal];
            
        }
        
        scView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + heightScrContent);
        
        if (switchJieTing.isOn) {
            label_site_type_tag.hidden = NO;
            btnGroupClick.hidden = NO;
            btnExpand.hidden = NO;
            labelGroupName.hidden = NO;
        }else
        {
            isFirstLoadView  = NO;
            label_site_type_tag.hidden = YES;
            btnGroupClick.hidden = YES;
            btnExpand.hidden = YES;
            labelGroupName.hidden = YES;
        };
        
    }
    else {
        if (![self checkFormat]) {
            return;
        }
        
        if (switchJieTing.isOn) {
            label_site_type_tag.hidden = NO;
            btnGroupClick.hidden = NO;
            btnExpand.hidden = NO;
            labelGroupName.hidden = NO;
        }else
        {
            isFirstLoadView  = NO;
            label_site_type_tag.hidden = YES;
            btnGroupClick.hidden = YES;
            btnExpand.hidden = YES;
            labelGroupName.hidden = YES;
        };
        
        
        
        if (!isNeedSelectGroup) {
            labelGroupName.text = @"未加入任何分组";
        }

        tfUserName.enabled = NO;
        tfJobNumber.enabled = NO;
        tfPhone.enabled = NO;
        
        self.navigationItem.rightBarButtonItem.title = @"编辑";
        self.title = @"坐席详情";
        

        
        btnDelete.hidden = YES;
        btnExpand.selected = NO;
        [btnExpand setImage:Expand_Button_Reviewing_Status_Image forState:UIControlStateNormal];
        
        scView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + heightScrContent);
        
        if ([dataSource count] > 1) {//groupName
            btnExpand.hidden = NO;
        }
        else {
            btnExpand.hidden = YES;
        }
        
        
        //保存修改的坐席
        [self saveModify];
    }
    
    isEditting = !isEditting;
    [self setViewByEditingStatus];
    
    
    if (!isNeedSelectGroup) {
        btnExpand.hidden = YES;
    }else
    {
        
    }
    
    
}

- (bool)checkFormat {
    
    //检查格式
    if (tfUserName.text.length < 1) {
        [CommonFuntion showToast:@"请输入姓名" inView:self.view];
        return NO;
    }
    
    if (tfUserName.text.length > 6) {

        [CommonFuntion showToast:@"姓名长度不能超过6位" inView:self.view];
        return NO;
    }
    
    if (tfJobNumber.text.length != 4) {
        [CommonFuntion showToast:@"请输入4位工号" inView:self.view];
        return NO;
    }
    
    if (![CommonFunc checkStringIsNum:tfJobNumber.text]) {
        [CommonFuntion showToast:@"工号由数字组成" inView:self.view];
        return NO;
    }
    
    if(!switchJieTing.isOn && !switchWaiHu.isOn)
    {
        
    }else{
        if (tfPhone.text.length < 1) {
            [CommonFuntion showToast:@"电话不能为空!" inView:self.view];
            return NO;
        }
        
        if (tfPhone.text.length > 0 && (tfPhone.text.length < 11 || tfPhone.text.length > 15)) {
            [CommonFuntion showToast:@"请输入11-15位电话号码" inView:self.view];
            return NO;
        }
    }
    
    
    
    /*
    if (![CommonFunc checkStringIsNum:tfPhone.text]) {
        [SVProgressHUD showErrorWithStatus:@"电话号码由数字组成"];
        return NO;
    }
    */
    
    
    // 接听坐席必须选分组
    id groupI = detailContactInfo.departmentIdList;
    if (switchJieTing.isOn) {
        /*
        if (isNeedSelectGroup) {
            if (detailContactInfo.departmentIdList == nil
                || groupI == [NSNull null]
                || [detailContactInfo.departmentIdList isEqualToString:@"<null>"] || [detailContactInfo.departmentIdList isEqualToString:@""]) {
                [CommonFuntion showToast:@"请选择分组" inView:self.view];
                return NO;
            }
        }else
        {
            
        }
        */
        
    }
    return YES;
}

//获取坐席详情
- (void)getDetailInfo {
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
//    
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:detailContactInfo.departmentIdList,@"deptId",
//                                   detailContactInfo.userId,@"sitId", nil];
    
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   detailContactInfo.userId,@"sitId", nil];
    
    NSLog(@"params:%@",params);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_SIT_DETAIL_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            scView.hidden = NO;
            [self addEditBtn];
            NSDictionary *resultDict = [jsonResponse objectForKey:@"resultMap"];
            dicSitInfos = resultDict;
            NSLog(@"获取坐席详情:%@",resultDict);
            
            detailContactInfo.name = [resultDict safeObjectForKey:@"USERNAME"];
            detailContactInfo.jobNumber = [resultDict safeObjectForKey:@"USERCODE"];
            detailContactInfo.userId = [resultDict safeObjectForKey:@"ID"];
            detailContactInfo.departmentNameList = [resultDict safeObjectForKey:@"DEPT_NAME"];
            detailContactInfo.phoneNumber = [resultDict safeObjectForKey:@"PHONENO"];
            detailContactInfo.departmentIdList = [resultDict safeObjectForKey:@"DEPT_ID"];
            [self refreshData];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getDetailInfo];
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
            scView.hidden = YES;
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        scView.hidden = YES;
    }];
}

- (void)saveModify {
    
    bool isNameModified = YES,
    isPhoneModified = YES,
    isJobNumberModified = YES,
    isGroupsModifed = YES;
//    if (![tfUserName.text isEqualToString:detailContactInfo.name]) {
//        isNameModified = YES;
//    }
//    if (![tfJobNumber.text isEqualToString:detailContactInfo.jobNumber]) {
//        isJobNumberModified = YES;
//    }
//    if (![tfPhone.text isEqualToString:detailContactInfo.phoneNumber]) {
//        isPhoneModified = YES;
//    }
//    NSString *groupsString = @"";
//    for (int i = 0; i < [dataSource count]; i++) {
//        if (i == [dataSource count] - 1) {
//            groupsString = [groupsString stringByAppendingString:[dataSource objectAtIndex:i]];
//        }
//    }
    
    if (isNameModified || isPhoneModified || isGroupsModifed) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        if (detailContactInfo.userId) {
            [params setObject:detailContactInfo.userId forKey:@"sitId"];
        }
        if (tfUserName.text) {
            [params setObject:tfUserName.text forKey:@"sitName"];
        }
        if (tfJobNumber.text ) {
            [params setObject:tfJobNumber.text forKey:@"gh"];
        }
        
        if(isNeedSelectGroup){
            if (detailContactInfo.departmentIdList) {
                [params setObject:detailContactInfo.departmentIdList forKey:@"deptIdStr"];
            }
        }
        
        if (tfPhone.text) {
            [params setObject:tfPhone.text forKey:@"phone"];
        }
        
        Boolean inAgent = FALSE;
        Boolean outAgent = FALSE;
        isOutagent = FALSE;
        isInagent = FALSE;
        
        if(switchJieTing.isOn){
            inAgent = TRUE;
            isInagent = TRUE;
        }
        
        if(switchWaiHu.isOn){
            outAgent = TRUE;
            isOutagent = TRUE;
        }
        
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
        
        /*
         用NSNumber包一层：
         
         [tempDate setObject:[NSNumber numberWithBool:YES] forKey:@"Flag"];
         
         取出来用的时候相应的：
         
         NSNumber* n = [tempDate objectForKey...];
         BOOL b = [n boolValue];
         */
        
        /*
        [params setObject:[NSNumber numberWithBool:inAgent] forKey:@"inAgent"];
        [params setObject:[NSNumber numberWithBool:outAgent] forKey:@"outAgent"];
         */
        
        NSLog(@"params:%@",params);
        //
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        [hud show:YES];
        
        // 发起请求
        [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_EDIT_SIT_DETAIL_ACTION] params:params success:^(id jsonResponse) {
            [hud hide:YES];
            
            NSLog(@"jsonResponse:%@",jsonResponse);
            if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
                [CommonFuntion showToast:@"编辑成功!" inView:self.view];
                if (self.NotifySitStatusListBlock) {
                    self.NotifySitStatusListBlock();
                }
                [self performSelector:@selector(goBack) withObject:nil afterDelay:1.0];
                //                [self setViewByModifyResult:YES];
                //                [self getDetailInfo];
                
            }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
                __weak typeof(self) weak_self = self;
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^(){
                    [weak_self saveModify];
                };
                [comRequest loginInBackgroundLLC];
            }
            else {
                
                NSString *desc = [jsonResponse objectForKey:@"desc"];
                if (desc == nil || [desc isEqualToString:@""]) {
                    desc = @"编辑坐席失败";
                }
                
                [CommonFuntion showToast:desc inView:self.view];
                [self setViewByModifyResult:NO];
            }
            
        } failure:^(NSError *error) {
            [hud hide:YES];
            [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
            [self setViewByModifyResult:NO];
        }];
    }
    
}

- (void)deleteThisSit {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:groupId,@"deptId",
                                   detailContactInfo.userId,@"sitId", nil];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_DELETE_SIT_DETAIL_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            [CommonFuntion showToast:@"删除成功!" inView:self.view];
            if (self.NotifySitStatusListBlock) {
                self.NotifySitStatusListBlock();
            }
            [self performSelector:@selector(goBack) withObject:nil afterDelay:1.0];
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self deleteThisSit];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            
            NSString *desc = [jsonResponse objectForKey:@"desc"];
            if (desc == nil || [desc isEqualToString:@""]) {
                desc = @"删除失败";
            }
            
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];

}


// 查询所有部门
- (void)getGroupsAll {
    isNeedSelectGroup = NO;

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_DEPT_LIST_ACTION] params:params success:^(id jsonResponse) {
        NSLog(@"分组数据jsonResponse:%@",jsonResponse);
        
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            NSArray *deptList;
            
            deptList = [[[jsonResponse objectForKey:@"resultMap"] objectForKey:@"deptList"] toJsonValue];
            
            // 根据部门count判断是否可以进行选择
            if (deptList && [deptList count] > 0) {
                NSLog(@"%@",deptList);
                isNeedSelectGroup = YES;
            }else
            {
                NSLog(@"所有部门分组《 1");
                isNeedSelectGroup = NO;
            }
        }
        else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getGroupsAll];
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
        isNeedSelectGroup = NO;
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
}

#pragma mark - switch开关
-(void)setSwitchValue
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL swtichOn = [userDefaults boolForKey:SWITCH_JIETING_KEY];
    if (swtichOn) {
        [switchJieTing setOn:YES];
    }else
    {
        [switchJieTing setOn:NO];
    };
    
    swtichOn = [userDefaults boolForKey:SWITCH_WAIHU_KEY];
    if (swtichOn) {
        [switchWaiHu setOn:YES];
    }else
    {
        [switchWaiHu setOn:NO];
    };
}


- (IBAction)switchBgClickEvent:(id)sender {
    
    UIButton *buttonBg = (UIButton*)sender;
    NSInteger tag = buttonBg.tag;
    if (tag == 100) {
        if (!switchJieTing.enabled) {
            NSLog(@"不可点击---接听-->");
            if (inNums == 0 && isEditting) {

                [CommonFuntion showToast:@"无接听权限" inView:self.view];
            }
        }
        
    }else if (tag == 101)
    {
        if (!switchWaiHu.enabled) {
            NSLog(@"不可点击---外呼-->");
            if (outNums == 0 && isEditting) {
                [CommonFuntion showToast:@"无外呼权限" inView:self.view];
            }
        }
    }
}


-(IBAction)switchValueChange:(id)sender{
    
    NSLog(@"点击事件---->");
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    //    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger tag = switchButton.tag;
    // 接听
    if (tag == 100) {
        if (isButtonOn) {
            NSLog(@"打开提醒---接听-->");
            //            [userDefaults setBool:YES forKey:SWITCH_JIETING_KEY];
            tfPhone.enabled = YES;
            [self isHideGrouTypepView:NO];
        }else {
            NSLog(@"关闭提醒---接听-->");
            //            [userDefaults setBool:NO forKey:SWITCH_JIETING_KEY];
            
            if (!switchWaiHu.isOn) {
                tfPhone.text = @"";
                tfPhone.enabled = NO;
            }
            [self isHideGrouTypepView:YES];
            
        }
    }else if (tag == 101)
    {
        // 外呼
        if (isButtonOn) {
            NSLog(@"打开提醒---外呼-->");
            //            [userDefaults setBool:YES forKey:SWITCH_WAIHU_KEY];
            tfPhone.enabled = YES;
        }else {
            NSLog(@"关闭提醒---外呼-->");
            //            [userDefaults setBool:NO forKey:SWITCH_WAIHU_KEY];
            
            if (!switchJieTing.isOn) {
                tfPhone.text = @"";
                tfPhone.enabled = NO;
            }
        }
    }
}



#pragma mark - Button Action
- (IBAction)btnAction:(id)sender {
    UIButton *btn = (UIButton*)sender;
    NSLog(@"btnAction----》");
    if (btn.tag == 100) {
        //展开或者隐藏
        if (isEditting) {
            
            if(!isNeedSelectGroup){
                NSLog(@"不可跳转----》");
                return;
            }
            NSLog(@"跳转----》");
            //编辑状态下，跳转到ContactBookAddNewLevel2ViewController
            ContactBookAddNewLevel2ViewController *level2 = [[ContactBookAddNewLevel2ViewController alloc] init];
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            for (int i = 0; i < [dataSource count]; i++) {
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[[dataSource objectAtIndex:i] objectForKey:@"name"],@"groupName",
                                      [[dataSource objectAtIndex:i] objectForKey:@"id"],@"groupID",
                                      @"1",@"isSelected", nil];
                CellDataInfo *cInfo = [[CellDataInfo alloc] initWithCellDataInfo:dict];
                [arr addObject:cInfo];
            }
            
//          level2.dataSource = arr;
            level2.groupDataType = GroupDataAll;
            level2.delegate = self;
            id departmentIdListT = detailContactInfo.departmentIdList;

            if (detailContactInfo.departmentIdList != nil &&
                departmentIdListT != [NSNull null] &&
                ![detailContactInfo.departmentIdList isEqualToString:@"<null>"]) {

                NSArray *sArr = [detailContactInfo.departmentIdList componentsSeparatedByString:@","];
                level2.selectedGroupsIDList = [NSMutableArray arrayWithArray:sArr];
            }
            
//          level2.selectedGroupsIDList = dataSource;
            [self.navigationController pushViewController:level2 animated:YES];
            return;
        }
        else {
            if (btnExpand.hidden) {
                return;
            }
            
            
            btnExpand.selected = !btnExpand.selected;
            tbView.hidden = !btnExpand.selected;
            if (!tbView.hidden) {
                
                CGRect tbRect = tbView.frame;
                tbRect.size.height = [dataSource count] * 50.0f;
                tbView.frame = tbRect;
                
                [tbView reloadData];
                UIView *topView = [self.view viewWithTag:555];

                scView.contentSize = CGSizeMake(self.view.frame.size.width, topView.frame.origin.y + topView.frame.size.height + tbView.frame.size.height + heightScrContent);
                
                //定义动画效果
                __block CGRect oRect = tbView.frame;
                CGRect tmpRect = oRect;
                tmpRect.size.height = 1.0;
                tbView.frame = tmpRect;
                [UIView animateWithDuration:0.5 animations:^{
                    tbView.frame = oRect;
                }];
            }
            else {
                scView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+ heightScrContent);
                
                //定义动画效果
                tbView.hidden = NO;
                __block CGRect oRect = tbView.frame;
                [UIView animateWithDuration:0.5 animations:^{
                    CGRect tmpRect = tbView.frame;
                    tmpRect.size.height = 1.0;
                    tbView.frame = tmpRect;
                } completion:^(BOOL finished) {
                    tbView.hidden = YES;
                    tbView.frame = oRect;
                }];
            }
        }
    }
    else if (btn.tag == 101) {
        //删除
        SimpleActionSheet *sAs = [[SimpleActionSheet alloc] init];
        [sAs setAlertDescription:@"确定要删除此坐席?"];
        [sAs setButtonsTitle:[NSArray arrayWithObjects:@"删除",@"取消", nil]];
        sAs.delegate = self;
        [sAs showOnWindow:self.view.window];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"dataSource:%lu",(unsigned long)[dataSource count]);
    return [dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GroupNameCell";//cell重用标识
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];//设置这个cell的重用标识
    
    //若cell为nil，重新alloc一个cell
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    }
    cell.backgroundColor = [UIColor whiteColor];//GetColorWithRGB(252, 252, 252);
    
    UILabel *dLabel = [[UILabel alloc] initWithFrame:CGRectMake(88.0, 10.0, 200.0, 30.0)];
    dLabel.text = [[dataSource objectAtIndex:indexPath.row] safeObjectForKey:@"name"];
    dLabel.textColor = GetColorWithRGB(40, 135, 255);
    dLabel.font = [UIFont systemFontOfSize:16.0];
    dLabel.backgroundColor = [UIColor whiteColor];//[UIColor clearColor];
    [cell.contentView addSubview:dLabel];
//    cell.detailTextLabel.text = [dataSource objectAtIndex:indexPath.row];
//    cell.detailTextLabel.textColor = GetColorWithRGB(40, 135, 255);
//    cell.detailTextLabel.font = [UIFont systemFontOfSize:16.0];
//    cell.detailTextLabel.frame = dRect;
    cell.detailTextLabel.text = @" ";
    cell.textLabel.textColor = GetColorWithRGB(128, 128, 128);
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"     ";//所在组别:
        cell.textLabel.textAlignment = 0;
    }
    else {
        cell.textLabel.text = @"     ";
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 49.0f, 320.0f, 1.0f)];
    lineView.backgroundColor = GetColorWithRGB(240, 240, 240);
    [cell.contentView addSubview:lineView];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

#pragma mark - 验证是否符合
-(void)verificationOfPara:(NSString *)info andByTag:(NSString *)strTag{
    NSLog(@"verificationOfPara--->");
    isAllowForNOorPhone = false;
    NSMutableDictionary *params = nil;
    NSString *errorInfos = @"";
    NSString *strUrl = @"";
    // 电话号码
    if([strTag isEqualToString:@"phone"]){
        strUrl = LLC_CHECK_BIND_PHONE_ACTION;
        errorInfos = @"校验电话号码失败";
        params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:info,@"phoneNum",
                  detailContactInfo.userId,@"userId", nil];
    }else if([strTag isEqualToString:@"no"]){
        //工号
        strUrl = LLC_CHECK_USER_CODE_ACTION;
        errorInfos = @"校验工号失败";
        params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:info,@"userCode",
                  detailContactInfo.userId,@"userId", nil];
    }
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,strUrl] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"校验结果:%@",jsonResponse);
        
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            isAllowForNOorPhone = YES;
        }
        else {
            
            NSString *desc = [jsonResponse objectForKey:@"desc"];
            if (desc == nil || [desc isEqualToString:@""]) {
                desc = errorInfos;
            }
            
            [CommonFuntion showToast:desc inView:self.view];
            
            //            if([strTag isEqualToString:@"phone"]){
            ////                tfPhone.text = @"";
            //                [tfPhone becomeFirstResponder];
            //            }else
            //            {
            ////                tfJobNumber.text = @"";
            //                [tfJobNumber becomeFirstResponder];
            //            }
            
            isAllowForNOorPhone = NO;
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        isAllowForNOorPhone = NO;
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
    NSLog(@"");
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
        
    }else if (tfJobNumber == textField) {
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
        NSLog(@"textFieldDidEndEditing-验证工号是否重复-->");
        // 验证工号是否重复
        [self verificationOfPara:number andByTag:@"no"];
        
        
    }else if (tfPhone == textField) {
        
        if(!switchJieTing.isOn && !switchWaiHu.isOn)
        {
            return;
        }
        
        
        NSString *phone = textField.text;
        if (phone == nil || phone.length < 1 || (phone != nil && phone.length > 0 && (phone.length < 11 || phone.length > 15))) {
            [CommonFuntion showToast:@"请输入11-15位电话号码" inView:self.view];
//            [tfPhone becomeFirstResponder];
            return;
        }
        
        
         NSLog(@"textFieldDidEndEditing-验证是否已经被绑定-->");
        // 验证是否已经被绑定
        [self verificationOfPara:phone andByTag:@"phone"];
    }
}

#pragma mark - SimpleActionSheetDelegate
- (void)buttonDidClickedAtIndex:(int)index {
    if (index == 0) {
        [self deleteThisSit];
    }
}

#pragma mark - 管理分组viewcontroller的代理 
- (void)selectedGroupsDidChanged:(NSArray*)arr {
    NSMutableArray *rArr = [NSMutableArray arrayWithArray:arr];
    if (!rArr || [rArr count] < 1) {
//        return;
    }
    NSString *deptName = @"",*deptId = @"";
    for (int i = 0; i < [rArr count]; i++) {
        NSDictionary *dict = [rArr objectAtIndex:i];
        if (i == [rArr count]-1) {
            deptName = [deptName stringByAppendingFormat:@"%@",[dict safeObjectForKey:@"groupName"]];
            deptId = [deptId stringByAppendingFormat:@"%@",[dict safeObjectForKey:@"groupID"]];
        }
        else {
            deptName = [deptName stringByAppendingFormat:@"%@,",[dict safeObjectForKey:@"groupName"]];
            deptId = [deptId stringByAppendingFormat:@"%@,",[dict safeObjectForKey:@"groupID"]];
        }
    }
    
    detailContactInfo.departmentNameList = deptName;
    detailContactInfo.departmentIdList = deptId;
    
    NSLog(@"departmentNameList:%@",detailContactInfo.departmentNameList);
    NSLog(@"departmentIdList:%@",detailContactInfo.departmentIdList);
    
    // 刷新分组View显示
    [self refreshGroupData];
    
    //点击了完成按钮，需要隐藏删除按钮
//    btnDelete.hidden = YES;
}

// 根据选的分组 刷新View显示
-(void)refreshGroupData
{
    if(!detailContactInfo.departmentNameList || [detailContactInfo.departmentNameList isEqualToString:@""]){
        NSLog(@"refreshGroupData--->");
        labelGroupName.text = @"请选择分组";
    }else{
        
        if (detailContactInfo.departmentNameList && [detailContactInfo.departmentNameList isKindOfClass:NSClassFromString(@"NSString")]) {
            NSArray *deptNameArr = [detailContactInfo.departmentNameList componentsSeparatedByString:@","];
            NSArray *deptIDArr = [detailContactInfo.departmentIdList componentsSeparatedByString:@","];
            
            dataSource = [[NSMutableArray alloc] init];
            for (int i = 0; i < deptNameArr.count; i++) {
                if ([deptNameArr objectAtIndex:i] && [deptIDArr objectAtIndex:i]) {
                    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[deptNameArr objectAtIndex:i],@"name",
                                          [deptIDArr objectAtIndex:i],@"id", nil];
                    if (dict) {
                        [dataSource addObject:dict];
                    }
                }
            }
            
            if (dataSource.count && ![dataSource containsObject:groupName]) {
                groupName = [[dataSource firstObject] safeObjectForKey:@"name"];
                groupId = [[dataSource firstObject] safeObjectForKey:@"id"];
            }
            
            if ([dataSource count] > 1) {//groupName
                labelGroupName.text = [NSString stringWithFormat:@"%@ 等",groupName];
                //            btnExpand.hidden = NO;
            }
            else {
                labelGroupName.text = [[dataSource objectAtIndex:0] safeObjectForKey:@"name"];
                labelGroupName.text = groupName;
                if (!isEditting) {
                    //                btnExpand.hidden = YES;
                }
            }
        }
        else {
            /*
            if (isEditting) {
                labelGroupName.text = @"未加入任何分组";
            }
            else {
                labelGroupName.text = @"未加入任何分组";
            }
             */
            if (isNeedSelectGroup) {
                labelGroupName.text = @"请选择分组";
            }else{
                labelGroupName.text = @"无任何分组";
            }
        }
        
    }
    
    //去掉上面显示的
    if (dataSource) {
        [dataSource removeObject:groupName];
    }
    
}



#pragma mark - UI适配
-(void)setCurViewFrame
{
    self.view.frame = CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT);
    view_lin4.hidden = YES;
    
    if (DEVICE_IS_IPHONE6) {
        heightScrContent = 60;
        scView.frame = [CommonFunc setViewFrameOffset:scView.frame byX:0 byY:0 ByWidth:DEVICE_BOUNDS_WIDTH - 320 byHeight:50];
        [self setFrameByIphone6];
    }else if(DEVICE_IS_IPHONE6_PLUS)
    {
        heightScrContent = 60;
        scView.frame = [CommonFunc setViewFrameOffset:scView.frame byX:0 byY:0 ByWidth:DEVICE_BOUNDS_WIDTH - 320 byHeight:100];
        [self setFrameByIphone6];
    }else if(!DEVICE_IS_IPHONE5)
    {
        heightScrContent = 200;
    }else
    {
        heightScrContent = 60;
    }
}


///初始化权限显示
-(void)setJieTingAndWaiHuView{
    ///接听权限 外呼权限
    if(isInagent && isOutagent){
        
    }else{
        if (isInagent || isOutagent) {
            if (isInagent) {
                label_waihu_tag.hidden = YES;
                switchWaiHu.hidden = YES;
                btnWaiHuBg.hidden = YES;
            }
            
            if (isOutagent) {
                label_jieting_tag.hidden = YES;
                switchJieTing.hidden = YES;
                btnJieTingBg.hidden = YES;
                
                label_waihu_tag.frame = CGRectMake(56, 200, 75, 20);
                switchWaiHu.frame = CGRectMake(118, 197, 50, 30);
                btnWaiHuBg.frame = CGRectMake(118, 197, 50, 30);
            }
        }else{
            label_jieting_tag.hidden = YES;
            switchJieTing.hidden = YES;
            btnJieTingBg.hidden = YES;
            label_waihu_tag.hidden = YES;
            switchWaiHu.hidden = YES;
            btnWaiHuBg.hidden = YES;
        }
        
    }
}

///点击编辑时设置接听与外呼权限的显示
-(void)setJieTingAndWaiHuByEdit{
    
    label_jieting_tag.hidden = NO;
    switchJieTing.hidden = NO;
    btnJieTingBg.hidden = NO;
    
    label_waihu_tag.hidden = NO;
    switchWaiHu.hidden = NO;
    btnWaiHuBg.hidden = NO;
    
    NSInteger hei = 50;
    label_jieting_tag.frame = CGRectMake(56, 200+hei, 75, 20);
    switchJieTing.frame = CGRectMake(118, 195+hei, 50, 30);
    btnJieTingBg.frame = CGRectMake(118, 197+hei, 50, 30);
    
    
    label_waihu_tag.frame = CGRectMake(190+(DEVICE_BOUNDS_WIDTH-320)/2, 200+hei, 75, 20);
    switchWaiHu.frame = CGRectMake(252+(DEVICE_BOUNDS_WIDTH-320)/2, 195+hei, 50, 30);
    btnWaiHuBg.frame = CGRectMake(252+(DEVICE_BOUNDS_WIDTH-320)/2, 197+hei, 50, 30);
    
    /*
    ///接听权限 外呼权限
    if(isInagent && isOutagent){
        
    }else{
        if (isInagent) {
            label_jieting_tag.hidden = NO;
            switchJieTing.hidden = NO;
            btnJieTingBg.hidden = NO;
            
            label_waihu_tag.hidden = YES;
            switchWaiHu.hidden = YES;
            btnWaiHuBg.hidden = YES;
        }
        if (isOutagent) {
            label_jieting_tag.hidden = YES;
            switchJieTing.hidden = YES;
            btnJieTingBg.hidden = YES;
            
            label_waihu_tag.hidden = NO;
            switchWaiHu.hidden = NO;
            btnWaiHuBg.hidden = NO;
            
            label_jieting_tag.frame = CGRectMake(56, 200, 75, 20);
            switchJieTing.frame = CGRectMake(118, 197, 50, 30);
            btnJieTingBg.frame = CGRectMake(118, 197, 50, 30);
            
            
            label_waihu_tag.frame = CGRectMake(190+DEVICE_BOUNDS_WIDTH-320, 200, 75, 20);
            switchWaiHu.frame = CGRectMake(252+DEVICE_BOUNDS_WIDTH-320, 197, 50, 30);
            btnWaiHuBg.frame = CGRectMake(252+DEVICE_BOUNDS_WIDTH-320, 197, 50, 30);
        }
    }
     */
}


-(void)setViewByModifyResult:(BOOL)isOK{
    ///保存成功
    if (isOK) {
        [self setJieTingAndWaiHuView];
    }else{
        isEditting = YES;
        [self setJieTingAndWaiHuByEdit];
        tfUserName.enabled = YES;
        tfJobNumber.enabled = YES;
        tfPhone.enabled = YES;
        
        self.navigationItem.rightBarButtonItem.title = @"完成";
        self.title = @"编辑";
        
        
        btnDelete.hidden = NO;
        btnExpand.selected = NO;
        //        btnExpand.hidden = NO;
        
        
        
        if (isNeedSelectGroup) {
            if ([labelGroupName.text isEqualToString:@"未加入任何分组"]) {
                labelGroupName.text = @"请选择分组";
            }
            [btnExpand setImage:Expand_Button_Editting_Status_Image forState:UIControlStateNormal];
        }else
        {
            NSLog(@"----无任何组别---->");
            labelGroupName.text = @"无任何分组";
            btnExpand.hidden = YES;
            
            [btnExpand setImage:nil forState:UIControlStateNormal];
            
        }
        
        scView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + heightScrContent);
        
        if (switchJieTing.isOn) {
            label_site_type_tag.hidden = NO;
            btnGroupClick.hidden = NO;
            btnExpand.hidden = NO;
            labelGroupName.hidden = NO;
        }else
        {
            isFirstLoadView  = NO;
            label_site_type_tag.hidden = YES;
            btnGroupClick.hidden = YES;
            btnExpand.hidden = YES;
            labelGroupName.hidden = YES;
        }
        
        tbView.hidden = YES;
        if (isEditting) {
            [self setJieTingAndWaiHuByEdit];
            //        switchJieTing.hidden = NO;
            //        switchWaiHu.hidden = NO;
            if (inNums > 0) {
                switchJieTing.enabled = YES;
                [self.view sendSubviewToBack:btnJieTingBg];
                btnJieTingBg.hidden = YES;
            }else
            {
                ///非包年套餐用户：接听坐席总数无限制
                if (inNums == -1) {
                    switchJieTing.enabled = YES;
                    [self.view sendSubviewToBack:btnJieTingBg];
                    btnJieTingBg.hidden = YES;
                }else{
                    if (switchJieTing.isOn || isInagentOld) {
                        switchJieTing.enabled = YES;
                        [self.view sendSubviewToBack:btnJieTingBg];
                        btnJieTingBg.hidden = YES;
                    }else{
                        switchJieTing.enabled = NO;
                        [self.view bringSubviewToFront:btnJieTingBg];
                        btnJieTingBg.hidden = NO;
                    }
                }
                
                
            }
            
            if (outNums > 0) {
                switchWaiHu.enabled = YES;
                [self.view sendSubviewToBack:btnWaiHuBg];
                btnWaiHuBg.hidden = YES;
            }else
            {
                if (switchWaiHu.isOn || isOutagentOld) {
                    switchWaiHu.enabled = YES;
                    [self.view sendSubviewToBack:btnWaiHuBg];
                    btnWaiHuBg.hidden = YES;
                }else{
                    switchWaiHu.enabled = NO;
                    [self.view bringSubviewToFront:btnWaiHuBg];
                    btnWaiHuBg.hidden = NO;
                }
            }
        }else
        {
            switchJieTing.hidden = YES;
            switchWaiHu.hidden = YES;
            btnJieTingBg.hidden = YES;
            btnWaiHuBg.hidden = YES;
            switchJieTing.enabled = NO;
            switchWaiHu.enabled = NO;
        }
    }
}



-(void)setFrameByIphone6
{
    NSInteger vX = DEVICE_BOUNDS_WIDTH - 320;
    
    view_content_bg.frame = [CommonFunc setViewFrameOffset:view_content_bg.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
    view_line1.frame = [CommonFunc setViewFrameOffset:view_line1.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    view_line2.frame = [CommonFunc setViewFrameOffset:view_line2.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    view_line3.frame = [CommonFunc setViewFrameOffset:view_line3.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
    view_lin4.hidden = YES;
    view_lin4.frame = [CommonFunc setViewFrameOffset:view_lin4.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    view_lin5.frame = [CommonFunc setViewFrameOffset:view_lin5.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
    
    view_lin6.frame = [CommonFunc setViewFrameOffset:view_lin6.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
    tfUserName.frame = [CommonFunc setViewFrameOffset:tfUserName.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    tfJobNumber.frame = [CommonFunc setViewFrameOffset:tfJobNumber.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    tfPhone.frame = [CommonFunc setViewFrameOffset:tfPhone.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
    label_jieting_show.frame = [CommonFunc setViewFrameOffset:label_jieting_show.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    label_waihu_show.frame = [CommonFunc setViewFrameOffset:label_waihu_show.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
//    switchJieTing.frame = [CommonFunc setViewFrameOffset:switchJieTing.frame byX:vX byY:0 ByWidth:0 byHeight:0];
//    btnJieTingBg.frame = [CommonFunc setViewFrameOffset:btnJieTingBg.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    
    /*
    label_waihu_tag.frame = [CommonFunc setViewFrameOffset:label_waihu_tag.frame byX:vX/2 byY:0 ByWidth:0 byHeight:0];
    switchWaiHu.frame = [CommonFunc setViewFrameOffset:switchWaiHu.frame byX:vX/2 byY:0 ByWidth:0 byHeight:0];
    btnWaiHuBg.frame = [CommonFunc setViewFrameOffset:btnWaiHuBg.frame byX:vX/2 byY:0 ByWidth:0 byHeight:0];
    */
    
    NSInteger hei = 50;
    label_jieting_tag.frame = CGRectMake(56, 200+hei, 75, 20);
    switchJieTing.frame = CGRectMake(118, 195+hei, 50, 30);
    btnJieTingBg.frame = CGRectMake(118, 197+hei, 50, 30);
    
    
    label_waihu_tag.frame = CGRectMake(190+(DEVICE_BOUNDS_WIDTH-320)/2, 200, 75, 20);
    switchWaiHu.frame = CGRectMake(252+(DEVICE_BOUNDS_WIDTH-320)/2, 195, 50, 30);
    btnWaiHuBg.frame = CGRectMake(252+(DEVICE_BOUNDS_WIDTH-320)/2, 197, 50, 30);
    
    labelGroupName.frame = [CommonFunc setViewFrameOffset:labelGroupName.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
    btnExpand.frame = [CommonFunc setViewFrameOffset:btnExpand.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    btnGroupClick.frame = [CommonFunc setViewFrameOffset:btnGroupClick.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
    tbView.frame = [CommonFunc setViewFrameOffset:tbView.frame byX:0 byY:0 ByWidth:vX byHeight:0];
}


@end
