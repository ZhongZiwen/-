//
//  SitDetailsViewController.m
//  
//
//  Created by sungoin-zjp on 16/1/5.
//
//

#import "SitDetailsViewController.h"
#import "CommonStaticVar.h"
#import "NSString+JsonHandler.h"
#import "CommonFunc.h"
#import "SitDetailNavCell.h"
#import "NavigationListViewController.h"


@interface SitDetailsViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>{
    ///是否处于编辑状态
    bool isEditting;
    
    NSDictionary *dicSitInfos;//座席详情
    
    ///
    BOOL isInagent ;
    BOOL isOutagent;
    BOOL isInagentOld ;
    BOOL isOutagentOld;
    
    NSInteger inNums,outNums;
    
    
    ///导航ID集合
    NSString *navIds;
    
    Boolean isAllowForNOorPhone;
}

@property(nonatomic,strong) UIScrollView *scrollview;
@property(nonatomic,strong) NSMutableArray *dataSource;


@end

@implementation SitDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"坐席详情";
    self.view.backgroundColor = COLOR_BG;
    self.tfJieruNum.text = [self.navigationDic safeObjectForKey:@"navigationName"];
    [self initTextFiledDele];
    [self addTapGestureEvent];
    [self initViewFrame];
    [self initTableview];
    
    [self initData];
//    [self getGroupsAll];
    [self getDetailInfo];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self hideKeyBoard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 初始化数据
-(void)initData{
    self.scrollview.hidden = YES;
    
    isEditting = FALSE;
    self.dataSource = [[NSMutableArray alloc] init];
}


#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewNav.delegate = self;
    self.tableviewNav.dataSource = self;
    self.tableviewNav.sectionFooterHeight = 0;
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewNav setTableFooterView:v];
    self.tableviewNav.scrollEnabled = NO;
}

#pragma mark - 初始化编辑框属性
-(void)initTextFiledDele{
    self.tfJieruNum.delegate = self;
    self.tfPhone.delegate = self;
    self.tfUserName.delegate = self;
    self.tfJobNumber.delegate = self;
    
    self.tfJieruNum.clearButtonMode =  UITextFieldViewModeWhileEditing;
    self.tfUserName.clearButtonMode =  UITextFieldViewModeWhileEditing;
    self.tfPhone.clearButtonMode =  UITextFieldViewModeWhileEditing;
    self.tfJobNumber.clearButtonMode =  UITextFieldViewModeWhileEditing;
}


///boss 可编辑
-(void)addEditBtn{
    if (![[CommonStaticVar getAccountType] isEqualToString:@"boss"]) {
        return;
    }
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonAction)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
}


#pragma mark -编辑/完成事件
- (void)rightBarButtonAction {
    if (!isEditting) {
        isEditting = TRUE;
        self.tableviewNav.hidden = YES;
        self.labelNavTag.hidden = NO;
        self.btnArrow.hidden = NO;
        self.btnNavBarName.hidden = NO;
        
        self.tfUserName.enabled = YES;
        self.tfJobNumber.enabled = YES;
        self.tfPhone.enabled = YES;
        
        self.navigationItem.rightBarButtonItem.title = @"完成";
        self.title = @"编辑";
        
        self.headviewDetail.frame = CGRectMake(0, 0, kScreen_Width, 200);
        self.btnDelete.hidden = NO;
        self.btnArrow.selected = NO;
        
        if ([self.btnNavBarName.titleLabel.text isEqualToString:@"未加入任何分组"]) {
            [self.btnNavBarName setTitle:@"请选择分组" forState:UIControlStateNormal];
        }
        [self.btnArrow setImage:[UIImage imageNamed:@"btn_to_right_gray.png"] forState:UIControlStateNormal];
        
        self.scrollview.contentSize = CGSizeMake(kScreen_Width, kScreen_Height-64);
        
        self.btnNavBarName.enabled = YES;
        self.btnArrow.hidden = NO;
        
    }
    else {
        [self hideKeyBoard];
        
        if (![self checkFormat]) {
            return;
        }
        //保存修改的坐席
        [self saveModify];
    }
}

//检查格式
- (bool)checkFormat {
    
    //检查格式
    if (self.tfUserName.text.length < 1) {
        [CommonFuntion showToast:@"请输入姓名" inView:self.view];
        return NO;
    }
    
    if (self.tfUserName.text.length > 6) {
        
        [CommonFuntion showToast:@"姓名长度不能超过6位" inView:self.view];
        return NO;
    }
    
    if (self.tfJobNumber.text.length != 4) {
        [CommonFuntion showToast:@"请输入4位工号" inView:self.view];
        return NO;
    }
    
    if (![CommonFunc checkStringIsNum:self.tfJobNumber.text]) {
        [CommonFuntion showToast:@"工号由数字组成" inView:self.view];
        return NO;
    }
    
    if (self.tfPhone.text.length < 1) {
        [CommonFuntion showToast:@"电话不能为空!" inView:self.view];
        return NO;
    }
    
    if (self.tfPhone.text.length > 0 && (self.tfPhone.text.length < 11 || self.tfPhone.text.length > 15)) {
        [CommonFuntion showToast:@"请输入11-15位电话号码" inView:self.view];
        return NO;
    }
    
    if (!navIds || navIds.length < 1) {
        [CommonFuntion showToast:@"请至少选择一个分组!" inView:self.view];
        return NO;
    }
    
    return YES;
}

#pragma mark - 刷新数据
- (void)notifyData {
    ///默认隐藏
    self.scrollview.hidden = NO;
    
    self.tfUserName.text = [dicSitInfos safeObjectForKey:@"USERNAME"];
    self.tfJobNumber.text = [dicSitInfos safeObjectForKey:@"USERCODE"];
    self.tfPhone.text = [dicSitInfos safeObjectForKey:@"PHONENO"];
    

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
    
//    [self setViewByEditingStatus];
    
    
    NSString *dept_name = [dicSitInfos safeObjectForKey:@"DEPT_NAME"];
    NSString *dept_id = [dicSitInfos safeObjectForKey:@"DEPT_ID"];
   
    
    if (dept_name) {
        NSArray *deptNameArr = [dept_name componentsSeparatedByString:@","];
        NSArray *deptIDArr = [dept_id componentsSeparatedByString:@","];
        
        for (int i = 0; i < deptNameArr.count; i++) {
            if ([deptNameArr objectAtIndex:i] && [deptIDArr objectAtIndex:i]) {
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[deptNameArr objectAtIndex:i],@"name",
                                      [deptIDArr objectAtIndex:i],@"id", nil];
                if (dict) {
                    [self.dataSource addObject:dict];
                }
            }
        }
        
        if (self.dataSource.count && ![self.dataSource containsObject:self.groupName]) {
            self.groupName = [[self.dataSource firstObject] safeObjectForKey:@"name"];
            self.groupId = [[self.dataSource firstObject] safeObjectForKey:@"id"];
        }
        
        if ([self.dataSource count] > 1) {//groupName
            [self.btnNavBarName setTitle:[NSString stringWithFormat:@"%@ 等",self.groupName] forState:UIControlStateNormal];
            self.btnArrow.hidden = NO;
            [self.btnArrow setImage:[UIImage imageNamed:@"btn_circle_down_blue.png"] forState:UIControlStateNormal];
        }
        else {
            [self.btnNavBarName setTitle:self.groupName forState:UIControlStateNormal];
            self.btnArrow.hidden = YES;
        }
    }
    else {
        
        if (isEditting) {
            self.btnArrow.hidden = NO;
        }else{
            self.btnArrow.hidden = YES;
        }
        [self.btnNavBarName setTitle:@"请选择分组" forState:UIControlStateNormal];
    }
    
    //去掉上面显示的
//    if (self.dataSource) {
//        [self.dataSource removeObject:self.groupName];
//    }
    
    self.tableviewNav.hidden = NO;
    self.labelNavTag.hidden = YES;
    self.btnArrow.hidden = YES;
    self.btnNavBarName.hidden = YES;
    
    CGRect tbRect = self.tableviewNav.frame;
    tbRect.size.height = [self.dataSource count] * 50.0f+40;
    self.tableviewNav.frame = tbRect;
    [self.tableviewNav reloadData];
    
//    if (tbRect.origin.y + tbRect.size.height > self.scrollview.frame.size.height) {
        self.scrollview.contentSize = CGSizeMake(kScreen_Width, tbRect.origin.y + tbRect.size.height );
//    }
}



///初始化权限显示
-(void)setJieTingAndWaiHuView{
}

// 根据是否是编辑状态设置view
-(void)setViewByEditingStatus
{
    self.tableviewNav.hidden = YES;
}



-(void)setViewByModifyResult:(BOOL)isOK{
    ///保存成功
    if (isOK) {
        [self setJieTingAndWaiHuView];
    }else{
        isEditting = YES;
        self.tfUserName.enabled = YES;
        self.tfJobNumber.enabled = YES;
        self.tfPhone.enabled = YES;
        
        self.navigationItem.rightBarButtonItem.title = @"完成";
        self.title = @"编辑";
        
        
        self.btnDelete.hidden = NO;
        self.btnArrow.selected = NO;

        if ([self.btnNavBarName.titleLabel.text isEqualToString:@"未加入任何分组"]) {
            [self.btnNavBarName setTitle:@"请选择分组" forState:UIControlStateNormal];
        }
        [self.btnArrow setImage:[UIImage imageNamed:@"btn_to_right_gray.png"] forState:UIControlStateNormal];
        
        
        self.scrollview.contentSize = CGSizeMake(kScreen_Width, kScreen_Height-64);
        
        self.btnNavBarName.enabled = YES;
        self.btnArrow.hidden = NO;
    
        self.tableviewNav.hidden = YES;
    }
}


#pragma mark - switch事件
- (IBAction)switchbtnClickEvent:(id)sender {
}

- (IBAction)switchValueChange:(id)sender {
}

#pragma mark - 删除事件
- (IBAction)deleteSitAction:(id)sender {
    [self showDeleteAlert];
}

#pragma mark - UIAlertView

///删除提示框
-(void)showDeleteAlert{
    
    if (self.tfUserName.text && [[self.tfUserName.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@"boss"]) {
        [CommonFuntion showToast:@"boss不能删除" inView:self.view];
        return;
    }
    
    UIAlertView *alertCall = [[UIAlertView alloc] initWithTitle:nil message: @"确定删除此坐席?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alertCall show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //删除
    if (buttonIndex == 1) {
        [self deleteThisSit];
    }
}

#pragma mark - 展开事件
///展开或者选择
- (IBAction)showNaListOrSelectNav:(id)sender {
    if (isEditting) {
        
        NSLog(@"跳转到导航页面--->");
        __weak typeof(self) weak_self = self;
        NavigationListViewController *controller = [[NavigationListViewController alloc] init];
        controller.navigationDic = self.navigationDic;
        controller.navigationType = @"all";
        controller.navigationSelectedIds = navIds;
        controller.SelectNavigation = ^(NSString *strNames, NSString *strIds){
            navIds = strIds;
            [weak_self refreshGroupData:strNames navigationIds:strIds];
        };
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        if (self.btnArrow.hidden) {
            return;
        }
        
        self.btnArrow.selected = !self.btnArrow.selected;
        self.tableviewNav.hidden = !self.btnArrow.selected;
        if (!self.tableviewNav.hidden) {
            self.tableviewNav.frame = CGRectMake(0, 150, kScreen_Width, 0);
            CGRect tbRect = self.tableviewNav.frame;
            tbRect.size.height = [self.dataSource count] * 50.0f;
            self.tableviewNav.frame = tbRect;
            NSLog(@"tableviewNav ypoint:%f",tbRect.origin.y);
            
            [self.tableviewNav reloadData];
            
            self.scrollview.contentSize = CGSizeMake(kScreen_Width, tbRect.origin.y + self.tableviewNav.frame.size.height );
            
            //定义动画效果
            __block CGRect oRect = self.tableviewNav.frame;
            CGRect tmpRect = oRect;
            tmpRect.size.height = 1.0;
            self.tableviewNav.frame = tmpRect;
            [UIView animateWithDuration:0.5 animations:^{
                self.tableviewNav.frame = oRect;
            }];
        }
        else {
            self.scrollview.contentSize = CGSizeMake(kScreen_Width, kScreen_Height-64);
            
            //定义动画效果
            self.tableviewNav.hidden = NO;
            __block CGRect oRect = self.tableviewNav.frame;
            [UIView animateWithDuration:0.5 animations:^{
                CGRect tmpRect = self.tableviewNav.frame;
                tmpRect.size.height = 1.0;
                self.tableviewNav.frame = tmpRect;
            } completion:^(BOOL finished) {
                self.tableviewNav.hidden = YES;
                self.tableviewNav.frame = oRect;
            }];
        }
        [self.tableviewNav reloadData];
    }
}


// 根据选的分组 刷新View显示
-(void)refreshGroupData:(NSString *)strNames navigationIds:(NSString *)strIds
{
    if(!strNames || [strNames isEqualToString:@""]){
        NSLog(@"refreshGroupData--->");
        [self.btnNavBarName setTitle:@"请选择分组" forState:UIControlStateNormal];
    }else{
        
        if (strNames) {
            NSArray *deptNameArr = [strNames componentsSeparatedByString:@","];
            NSArray *deptIDArr = [strIds componentsSeparatedByString:@","];
            
            self.dataSource = [[NSMutableArray alloc] init];
            for (int i = 0; i < deptNameArr.count; i++) {
                if ([deptNameArr objectAtIndex:i] && [deptIDArr objectAtIndex:i]) {
                    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[deptNameArr objectAtIndex:i],@"name",
                                          [deptIDArr objectAtIndex:i],@"id", nil];
                    if (dict) {
                        [self.dataSource addObject:dict];
                    }
                }
            }
            
            
            if (self.dataSource.count && ![self.dataSource containsObject:self.groupName]) {
                self.groupName = [[self.dataSource firstObject] safeObjectForKey:@"name"];
//                self.groupId = [[self.dataSource firstObject] safeObjectForKey:@"id"];
            }
            
            if ([self.dataSource count] > 1) {//groupName
                [self.btnNavBarName setTitle:[NSString stringWithFormat:@"%@ 等",self.groupName] forState:UIControlStateNormal];
                
            }
            else {
                [self.btnNavBarName setTitle:self.groupName forState:UIControlStateNormal];
            }
        }
        else {
           
            [self.btnNavBarName setTitle:@"请选择分组" forState:UIControlStateNormal];
        }
        
    }
    
    //去掉上面显示的
    if (self.dataSource) {
        [self.dataSource removeObject:self.groupName];
    }
    
}

#pragma mark - 验证是否符合
-(void)verificationOfPara:(NSString *)info andByTag:(NSString *)strTag{
    
    /*
     detailContactInfo.name = [resultDict safeObjectForKey:@"USERNAME"];
     detailContactInfo.jobNumber = [resultDict safeObjectForKey:@"USERCODE"];
     detailContactInfo.userId = [resultDict safeObjectForKey:@"ID"];
     detailContactInfo.departmentNameList = [resultDict safeObjectForKey:@"DEPT_NAME"];
     detailContactInfo.phoneNumber = [resultDict safeObjectForKey:@"PHONENO"];
     detailContactInfo.departmentIdList = [resultDict safeObjectForKey:@"DEPT_ID"];
     */
    
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
                  [dicSitInfos safeObjectForKey:@"ID"],@"userId", nil];
    }else if([strTag isEqualToString:@"no"]){
        //工号
        strUrl = LLC_CHECK_USER_CODE_ACTION;
        errorInfos = @"校验工号失败";
        params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:info,@"userCode",
                  [dicSitInfos safeObjectForKey:@"ID"],@"userId", nil];
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
    
    if (self.tfUserName == textField) {
        
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
        
    }else if (self.tfJobNumber == textField) {
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
        
        
    }else if (self.tfPhone == textField) {
        
        
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



-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}


#pragma mark - tableview delegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headview =[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
    headview.backgroundColor = COLOR_BG;
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 120, 20)];
    labelTitle.textColor = [UIColor blackColor];
    labelTitle.font = [UIFont systemFontOfSize:15.0];
    labelTitle.text = @"接听分组";
    [headview addSubview:labelTitle];
    return headview;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

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
    SitDetailNavCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SitDetailNavCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SitDetailNavCell" owner:self options:nil];
        cell = (SitDetailNavCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    [cell setCellDetail:[self.dataSource objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - 网络请求
//获取坐席详情
- (void)getDetailInfo {
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];

    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    [params setValue:[self.sitDetail safeObjectForKey:@"sitId"] forKey:@"sitId"];
    
    NSLog(@"params:%@",params);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_SIT_DETAIL_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [self addEditBtn];
            NSDictionary *resultDict = [jsonResponse objectForKey:@"resultMap"];
            dicSitInfos = resultDict;
            navIds = [dicSitInfos safeObjectForKey:@"DEPT_ID"];
            NSLog(@"获取坐席详情:%@",resultDict);
            
            [self notifyData];
            
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
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
    
}


// 查询所有部门
- (void)getGroupsAll {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_DEPT_LIST_ACTION] params:params success:^(id jsonResponse) {
        NSLog(@"分组数据jsonResponse:%@",jsonResponse);
        
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            NSArray *deptList;
            
            /*
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
             */
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
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
}

///保存
- (void)saveModify {
    
    bool isNameModified = YES,
    isPhoneModified = YES,
    isJobNumberModified = YES,
    isGroupsModifed = YES;

    
    
    if (isNameModified || isPhoneModified || isGroupsModifed) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        
        [params setObject:[dicSitInfos safeObjectForKey:@"ID"] forKey:@"sitId"];
        
        
        if (self.tfUserName.text) {
            [params setObject:self.tfUserName.text forKey:@"sitName"];
        }
        if (self.tfJobNumber.text ) {
            [params setObject:self.tfJobNumber.text forKey:@"gh"];
        }
        
        if (self.tfPhone.text) {
            [params setObject:self.tfPhone.text forKey:@"phone"];
        }

        [params setObject:navIds forKey:@"deptIdStr"];
        
        
        Boolean inAgent = TRUE;
        Boolean outAgent = FALSE;
        isOutagent = FALSE;
        isInagent = TRUE;
        
        
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
        
        NSLog(@"保存 params:%@",params);
        //
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        [hud show:YES];
        
        // 发起请求
        [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_EDIT_SIT_DETAIL_ACTION] params:params success:^(id jsonResponse) {
            [hud hide:YES];
            
            NSLog(@"jsonResponse:%@",jsonResponse);
            if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:LLC_NOTIFICATON_SIT_LIST object:self];
                [CommonFuntion showToast:@"编辑成功!" inView:self.view];
                [self actionSuccess];
                
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

///删除坐席
- (void)deleteThisSit {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.groupId,@"deptId",
                                   [self.sitDetail safeObjectForKey:@"sitId"],@"sitId", nil];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_DELETE_SIT_DETAIL_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        if ([[jsonResponse objectForKey:@"status"] integerValue] == 1) {
            [CommonFuntion showToast:@"删除成功!" inView:self.view];
            [self actionSuccess];
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


#pragma mark - view适配
-(void)initViewFrame{
    
    self.headviewDetail.frame = CGRectMake(0, 0, kScreen_Width, 150);
    self.headviewDetail.backgroundColor = [UIColor whiteColor];
    
    self.tfJieruNum.enabled = NO;
    self.tfJieruNum.frame = CGRectMake(100, 10, kScreen_Width-120, 30);
    
    self.tfUserName.frame = CGRectMake(100, 10, kScreen_Width-120, 30);
    self.tfJobNumber.frame = CGRectMake(100, 60, kScreen_Width-120, 30);
    self.tfPhone.frame = CGRectMake(100, 110, kScreen_Width-120, 30);
    
    
    self.btnNavBarName.frame = CGRectMake(100, 152, kScreen_Width-20, 50);
    self.btnArrow.frame = CGRectMake(kScreen_Width-35, 165, 20, 20);
    
    
    self.btnDelete.frame = CGRectMake(0, 235, kScreen_Width, 50);
    self.tableviewNav.frame = CGRectMake(0, 150, kScreen_Width, kScreen_Height-150);
    
    
    self.scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    self.scrollview.showsVerticalScrollIndicator = YES;
    self.scrollview.contentSize = CGSizeMake(kScreen_Width, kScreen_Height-64);
    self.scrollview.delegate = self;
    
    [self.scrollview addSubview:self.headviewDetail];
    [self.scrollview addSubview:self.btnDelete];
    [self.scrollview addSubview:self.tableviewNav];
    [self.view addSubview:self.scrollview];
    
    ///默认隐藏
    self.scrollview.hidden = YES;
    self.btnDelete.hidden = YES;
    self.tableviewNav.hidden = YES;
}

#pragma mark - 点击事件
-(void)addTapGestureEvent{
    //在整个view上加事件 在键盘弹出的情况下 点击其他地方隐藏键盘
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}



-(void)viewTapped:(UITapGestureRecognizer*)tap
{
    [self hideKeyBoard];
}

// 隐藏键盘
-(void)hideKeyBoard{
    [self.tfPhone resignFirstResponder];
    [self.tfUserName resignFirstResponder];
    [self.tfJobNumber resignFirstResponder];
}


@end
