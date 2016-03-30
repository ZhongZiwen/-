//
//  EditCustomerViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "EditCustomerViewController.h"
#import "EditItemTypeCellA.h"
#import "EditItemTypeCellB.h"
#import "EditItemTypeCellC.h"
#import "LLCenterUtility.h"
#import "EditItemModel.h"
#import "LLcenterSheetMenuView.h"
#import "LLCenterSheetMenuModel.h"
#import "TPKeyboardAvoidingTableView.h"
#import "CommonFunc.h"
#import "CommonStaticVar.h"

@interface EditCustomerViewController ()<UITableViewDataSource,UITableViewDelegate,LLCenterSheetMenuDelegate>{
    ///联系人姓名
    NSString *linkmanName;
    
    ///组装后的标签
    NSMutableArray *arrCusTagsNew;
    ///所有者
    NSMutableArray *arrayByBelong;
    
    ////所有者ID
    NSString *belongId;
}

@property(strong,nonatomic) TPKeyboardAvoidingTableView *tableviewCustomerDetails;
@property(strong,nonatomic) NSMutableArray *dataSource;

@end

@implementation EditCustomerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑详细";
    self.view.backgroundColor = COLOR_BG;
    [self addNarBar];
    [self initOptionsData];
    [self initDataSource];
    [self initTableview];
    [self getUserList];
}


#pragma mark - Nar Bar
-(void)addNarBar{
    [super setFlagOfSubView];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPress)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonPress)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
}

#pragma mark  取消按钮事件
- (void)cancelButtonPress {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark  保存事件
-(void)saveButtonPress {
    
    NSLog(@"mainLinkMan:%@",self.mainLinkMan);
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (![CommonFunc checkNetworkState]) {
        [CommonFuntion showToast:@"无网络可用,加载失败" inView:self.view];
        return;
    }
    

    for (int i=0; i<[self.dataSource count]; i++) {
        NSArray *array = [[self.dataSource objectAtIndex:i] objectForKey:@"content"];
        for (int k=0; k<[array count]; k++) {
            EditItemModel *item  = (EditItemModel*) [array objectAtIndex:k];
            
            if ([item.keyStr isEqualToString:@"linkmanMobilePhone"]) {

                if (![item.content isEqualToString:@""]) {
                    if (![CommonFunc isValidatePhoneNumber:item.content]) {
                        [CommonFuntion showToast:@"请输入正确的手机号" inView:self.view];
                        return;
                    }
                }
            }
            NSLog(@"%@  %@  %@",item.title,item.content,item.itemId);
        }
    }
    
    ///编辑
    [self updateCustomerInfo];
}


#pragma mark - 编辑联系人接口
-(void)updateCustomerInfo{
    
    ///编辑联系人接口
    ///传入：联系人ID，联系人名字（需要校验），客户标签，所有者，手机，固话，地址，客户ID
    ///传入：linkmanId，linkmanName，customerTag，customerOwnerId，linkmanMobilePhone，linkmanPhone，，customerId
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rDict setValue:[self.cusDetails objectForKey:@"CUSTOMER_ID"] forKey:@"customerId"];
    [rDict setValue:[self.mainLinkMan objectForKey:@"ID"] forKey:@"linkmanId"];
    
    
    for (int i=0; i<[self.dataSource count]; i++) {
        NSArray *array = [[self.dataSource objectAtIndex:i] objectForKey:@"content"];
        for (int k=0; k<[array count]; k++) {
            EditItemModel *item  = (EditItemModel*) [array objectAtIndex:k];

            if (item.keyType && item.keyType.length > 0) {
                if (item.keyStr && item.keyStr.length > 0) {
                    [rDict setValue:item.itemId forKey:item.keyStr];
                }
            }else{
                if (item.keyStr && item.keyStr.length > 0) {
                    [rDict setValue:item.content forKey:item.keyStr];
                }
            }
        }
    }

    
    [rDict setValue:[self getTagsIdBySelect:arrCusTagsNew] forKey:@"customerTag"];
    
    NSLog(@"rDict:%@",rDict);
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
     NSLog(@"rParam:%@",rParam);

    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_EDIT_CUSTOMER_INFO_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"编辑客户jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [CommonFuntion showToast:@"编辑成功" inView:self.view];
            
            if (self.NotifyCustomerDetails) {
                self.NotifyCustomerDetails();
            }
            [self.navigationController popViewControllerAnimated:YES];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self updateCustomerInfo];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)initDataSource{
    NSLog(@"self.cusDetails:%@",self.cusDetails);

    if (self.cusDetails == nil) {
        return;
    }
    
    if (self.mainLinkMan == nil) {
        return;
    }
    
    self.dataSource = [[NSMutableArray alloc] init];
    NSMutableDictionary *dicDataSource = [[NSMutableDictionary alloc] init];
    NSMutableArray *arraySection = [[NSMutableArray alloc] init];
    
    ///基本信息
    arraySection = [[NSMutableArray alloc] init];
    dicDataSource = [[NSMutableDictionary alloc] init];
    
    
    NSString *contactMain = @"";
    NSString *contactMainFlag = @"";
    
    ///基本信息
    if (self.mainLinkMan != nil) {
        if ([self.mainLinkMan objectForKey:@"NAME"]) {
            contactMain = [self.mainLinkMan safeObjectForKey:@"NAME"];
        }
        if ([self.mainLinkMan objectForKey:@"FIELD_VALUE"]) {
            contactMainFlag = [self.mainLinkMan safeObjectForKey:@"FIELD_VALUE"];
        }
    }
    
    if ([contactMainFlag isEqualToString:@""]) {
        contactMainFlag = @"主联系人";
    }
    
    EditItemModel *model = [[EditItemModel alloc] init];
    model = [[EditItemModel alloc] init];
    model.title = [NSString stringWithFormat:@"%@:",contactMainFlag];
    model.content = contactMain;
    model.placeholder = @"请输入联系人姓名";
    model.cellType = @"cellA";
    model.keyStr = @"linkmanName";
    model.keyType = @"";
    [arraySection addObject:model];
    linkmanName = contactMain;
    
    
    ///公司
    NSString *companyName = @"";
    if ([self.cusDetails objectForKey:@"CUSTOMER_NAME"] ) {
        companyName = [self.cusDetails safeObjectForKey:@"CUSTOMER_NAME"];
    }
    
    model = [[EditItemModel alloc] init];
    model.title = @"公司:";
    model.content = companyName;
    model.placeholder = @"请输入公司名称";
    model.cellType = @"cellA";
    model.keyStr = @"";
    model.keyType = @"";
    [arraySection addObject:model];
    
    ///所有者
    NSString *belong = @"";
    if ([self.cusDetails objectForKey:@"OWNER_NAME"] ) {
        belong = [self.cusDetails safeObjectForKey:@"OWNER_NAME"];
    }
    
    model = [[EditItemModel alloc] init];
    model.title = @"所有者:";
    model.content = belong;
    model.itemId = [self.cusDetails objectForKey:@"OWNER_ID"] ;
    model.placeholder = @"";
    model.cellType = @"cellB";
    model.keyStr = @"customerOwnerId";
    model.keyType = @"customerOwnerId";
    [arraySection addObject:model];
    
    
    ///标签
    NSString *belongTag = @"";
    if ([self.cusDetails objectForKey:@"STATE_FLAG"]) {
        belongTag = [self.cusDetails safeObjectForKey:@"STATE_FLAG"];
    }
    
    NSArray *arrayTags = [belongTag componentsSeparatedByString:@","];
    NSLog(@"arrayTags:%@",arrayTags);
    if (arrayTags && [arrayTags count] > 0) {
        [self initTagWithDefaultData:arrayTags];
    }
    
    model = [[EditItemModel alloc] init];
    model.itemId = @"";
    model.title = @"标签:";
    model.content = [self getTagsByDefault:arrayTags];
    model.placeholder = @"标签";
    model.cellType = @"cellC";
     model.keyType = @"";
    [arraySection addObject:model];
    
    
    [dicDataSource setObject:@"基本信息" forKey:@"head"];
    [dicDataSource setObject:arraySection forKey:@"content"];
    [self.dataSource addObject:dicDataSource];
    
    
    ///联系信息
    arraySection = [[NSMutableArray alloc] init];
    dicDataSource = [[NSMutableDictionary alloc] init];
    NSString *phoneNum = @"";
    NSString *familyPhoneNum = @"";
    NSString *address = @"";
    ///联系信息
    if (self.mainLinkMan != nil) {
        ///手机
        if ([self.mainLinkMan objectForKey:@"MOBILE"]) {
            phoneNum = [self.mainLinkMan safeObjectForKey:@"MOBILE"];
        }
        
        
        
        
        ///固话
        if ([self.mainLinkMan objectForKey:@"WORKPHONE"]) {
            familyPhoneNum = [self.mainLinkMan safeObjectForKey:@"WORKPHONE"];
        }
        
        
        
    }
    
    model = [[EditItemModel alloc] init];
    model.title = @"手机:";
    model.content = phoneNum;
    model.placeholder = @"请输入手机号码";
    model.cellType = @"cellA";
    model.keyStr = @"linkmanMobilePhone";
    model.keyType = @"";
    [arraySection addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"固话:";
    model.content = familyPhoneNum;
    model.placeholder = @"请输入固话号码";
    model.cellType = @"cellA";
    model.keyStr = @"linkmanPhone";
    model.keyType = @"";
    [arraySection addObject:model];
    


    ///地址
    if ([self.cusDetails objectForKey:@"CUSTOMER_ADDRESS"] ) {
        address = [self.cusDetails safeObjectForKey:@"CUSTOMER_ADDRESS"];
    }
    
    model = [[EditItemModel alloc] init];
    model.title = @"地址:";
    model.content = address;
    model.placeholder = @"请输入地址信息";
    model.cellType = @"cellA";
    model.keyStr = @"customerAddress";
    model.keyType = @"";
    [arraySection addObject:model];
    
    [dicDataSource setObject:@"联系信息" forKey:@"head"];
    [dicDataSource setObject:arraySection forKey:@"content"];
    
    if (arraySection && [arraySection count] > 0) {
        [self.dataSource addObject:dicDataSource];
    }
    
    NSLog(@"self.dataSource:%@",self.dataSource);
}



#pragma mark - 初始化选择条件数据
-(void)initOptionsData{
    arrCusTagsNew = [[NSMutableArray alloc] init];
    
    NSDictionary *item;
    NSInteger count = 0;
    if (self.arrayCusTags) {
        count = [self.arrayCusTags count];
    }
    NSLog(@"self.arrayCusTags:%@",self.arrayCusTags);
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i=0; i<count; i++) {
        item = [self.arrayCusTags objectAtIndex:i];
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = [item safeObjectForKey:@"id"];
        model.title = [item safeObjectForKey:@"name"];
        model.selectedFlag = @"no";
        [array addObject:model];
    }

    [arrCusTagsNew addObjectsFromArray:array];
    
}

///初始化所有者
-(void)initOwerUser:(NSArray *)arrayOwerUser{
    belongId = @"";
    arrayByBelong = [[NSMutableArray alloc] init];
    
    NSDictionary *item;
    NSInteger count = 0;
    if (arrayOwerUser) {
        count = [arrayOwerUser count];
    }
    NSLog(@"arrayOwerUser:%@",arrayOwerUser);
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i=0; i<count; i++) {
        item = [arrayOwerUser objectAtIndex:i];
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = [item safeObjectForKey:@"ID"];
        model.title = [item safeObjectForKey:@"USERNAME"];
        model.selectedFlag = @"no";
        [array addObject:model];
    }
    
    [arrayByBelong addObjectsFromArray:array];
    
    [self initBelongWithDefaultData];
}


-(void)initTagWithDefaultData:(NSArray *)array{
    LLCenterSheetMenuModel *model;
    NSInteger count = 0;
    NSInteger countTags = 0;
    BOOL isFound = FALSE;
    if (array) {
        count = [array count];
    }
    
    if (arrCusTagsNew) {
        countTags = [arrCusTagsNew count];
    }
   
    for (int i=0; i<count; i++) {
        isFound = FALSE;
        ///
        for (int k=0; !isFound && k<countTags; k++) {
            model = (LLCenterSheetMenuModel *)[arrCusTagsNew objectAtIndex:k];
            
            if ([model.title isEqualToString:[array objectAtIndex:i]]) {
                model.selectedFlag = @"yes";
                isFound = TRUE;
            }
        }
    }
}

///所有者初始化
-(void)initBelongWithDefaultData{
    ///所有者
    NSString *belong = @"";
    if ([self.cusDetails objectForKey:@"OWNER_NAME"] ) {
        belong = [self.cusDetails safeObjectForKey:@"OWNER_NAME"];
    }
    
    LLCenterSheetMenuModel *model;
    NSInteger count = 0;

    if (arrayByBelong) {
        count = [arrayByBelong count];
    }
    
    ///
    for (int k=0; k<count; k++) {
        model = (LLCenterSheetMenuModel *)[arrayByBelong objectAtIndex:k];
        model.selectedFlag = @"no";
        if ([model.title isEqualToString:belong]) {
            model.selectedFlag = @"yes";
        }
    }
    
}


#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewCustomerDetails = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-64) style:UITableViewStyleGrouped];
    self.tableviewCustomerDetails.delegate = self;
    self.tableviewCustomerDetails.dataSource = self;
    self.tableviewCustomerDetails.sectionFooterHeight = 0;
    
    [self.view addSubview:self.tableviewCustomerDetails];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewCustomerDetails setTableFooterView:v];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

#pragma mark - tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.dataSource) {
        return [self.dataSource count];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.dataSource objectAtIndex:section] objectForKey:@"content"] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 50;
    }
    return 30;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView ;
    UIView *headViewContent;
    if (section == 0) {
        headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 50)];
        headViewContent = [[UIView alloc] initWithFrame:CGRectMake(0, 20, DEVICE_BOUNDS_WIDTH, 30)];
        headView.backgroundColor = COLOR_BG;
        headViewContent.backgroundColor = [UIColor whiteColor];
    }else{
        
        headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 30)];
        headView.backgroundColor = [UIColor whiteColor];
    }
    
    NSString *imgName = @"";
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7, 23, 15)];
    if (section == 0) {
        imgName = @"icon_customer_baseinfo.png";
    }else{
        imgName = @"icon_customer_contactinfo.png";
    }
    icon.image = [UIImage imageNamed:imgName];
    
    
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(43, 5, 100, 20)];
    labelTitle.font = [UIFont systemFontOfSize:15.0];
    labelTitle.tintColor = [UIColor blackColor];
    labelTitle.text = [[self.dataSource objectAtIndex:section] objectForKey:@"head"];
    
    if (section == 0) {
        [headViewContent addSubview:icon];
        [headViewContent addSubview:labelTitle];
        [headView addSubview:headViewContent];
    }else{
        [headView addSubview:icon];
        [headView addSubview:labelTitle];
    }
    
    return headView;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditItemModel* item = (EditItemModel*) [[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];
    
    if ([item.cellType isEqualToString:@"cellA"]) {
        EditItemTypeCellA *cell = [tableView dequeueReusableCellWithIdentifier:@"EditItemTypeCellAIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"EditItemTypeCellA" owner:self options:nil];
            cell = (EditItemTypeCellA*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        cell.textFieldContent.enabled = TRUE;
        cell.textFieldContent.textColor = [UIColor blackColor];
        if (indexPath.section == 0 && (indexPath.row ==1 ) ) {
            cell.textFieldContent.enabled = FALSE;
            cell.textFieldContent.textColor = [UIColor darkGrayColor];
        }
        
        __weak typeof(self) weak_self = self;
        cell.textValueChangedBlock = ^(NSString *valueString){
            NSLog(@"index:%ti valueString:%@",indexPath.row,valueString);
            [weak_self notifyDataSource:indexPath valueString:valueString idString:@""];
        };
        
        [cell setCellDetail:item];
        return cell;
    }else if ([item.cellType isEqualToString:@"cellB"]) {
        EditItemTypeCellB *cell = [tableView dequeueReusableCellWithIdentifier:@"EditItemTypeCellBIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"EditItemTypeCellB" owner:self options:nil];
            cell = (EditItemTypeCellB*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        
        ///判断是否有权限 是否为普通用户
        if ([[CommonStaticVar getAccountType] isEqualToString:@"boss"]) {
            cell.btnContent.enabled = YES;
            cell.imgArrow.image = [UIImage imageNamed:@"btn_to_right_gray.png"];
            cell.imgArrow.hidden = NO;
            
            [cell.btnContent setTitleColor:COLOR_LIGHT_BLUE forState:UIControlStateNormal];
            
        }else{
            cell.btnContent.enabled = NO;
            cell.imgArrow.image = [UIImage imageNamed:@"btn_to_right_gray.png"];
            cell.imgArrow.hidden = YES;
            [cell.btnContent setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        }
        
        __weak typeof(self) weak_self = self;
        cell.SelectDataTypeBlock = ^(NSInteger type){
            ///5 所有者
            NSInteger falg = 5;
            
            [weak_self showMenuByFlag:falg withIndexPath:indexPath];
        };
        [cell setCellDetail:item];
        return cell;
    }
    else if ([item.cellType isEqualToString:@"cellC"]) {
        EditItemTypeCellC *cell = [tableView dequeueReusableCellWithIdentifier:@"EditItemTypeCellCIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"EditItemTypeCellC" owner:self options:nil];
            cell = (EditItemTypeCellC*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        __weak typeof(self) weak_self = self;
        cell.SelectTagsBlock = ^(){
            [weak_self showMenuByFlag:1 withIndexPath:indexPath];
        };
        [cell setCellDetail:item];
        return cell;
    }
    
    return nil;
}


#pragma mark - 弹框
///根据flag 弹框  1 标签
-(void)showMenuByFlag:(NSInteger)flag withIndexPath:(NSIndexPath *)indexPath{
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    NSArray *array = nil;
    NSString *title = @"";
    /// 0单选  1多选
    NSInteger type = 0;
    LLcenterSheetMenuView *sheet;
    if (flag == 1) {
        title = @"标签";
        type = 1;
        NSLog(@"arrayTag :%@",arrCusTagsNew);
        for (int i=0; i<[arrCusTagsNew count]; i++) {
            LLCenterSheetMenuModel *item  = (LLCenterSheetMenuModel*) [arrCusTagsNew objectAtIndex:i];
            NSLog(@"%@  %@",item.title,item.selectedFlag);
        }
        
        array = [self getTagsArrayBySelectData];
        NSLog(@"array:%@",array);
        
        
    }else if(flag == 5){
        ///所有者
        title = @"所有者";
        type = 0;
        array = arrayByBelong;
    }
    
    if (array == nil || [array count] == 0) {
        NSLog(@"选择数据源为空");
        
        NSString *strMsg = @"";
        if (flag == 1) {
            strMsg = @"标签加载失败";
        }else if (flag == 5){
            strMsg = @"所有者加载失败";
        }
        [CommonFuntion showToast:strMsg inView:self.view];
        return;
    }
    
    sheet = [[LLcenterSheetMenuView alloc]initWithlist:array headTitle:title footBtnTitle:@"" cellType:type menuFlag:flag];
    sheet.delegate = self;
    __weak typeof(self) weak_self = self;
    sheet.selectedMenuItemBlock = ^(NSArray *selectedArray,NSInteger flag){
        NSLog(@"flag:%ti",flag);
        NSLog(@"selectedArray:%@",selectedArray);
        ///标签
        
        ///修改选择条件数据源
        [weak_self changeTagSelectFlag:selectedArray];
        
//      ///修改数据源选中标记
        NSString *tags = [self getTagsBySelected:selectedArray];
        NSLog(@"tags:%@",tags);
        [weak_self notifyDataSource:[NSIndexPath indexPathForRow:3 inSection:0] valueString:tags idString:@""];
        [weak_self.tableviewCustomerDetails reloadData];
    };
    
    [sheet showInView:nil];
}


-(void)didSelectSheetMenuIndex:(NSInteger)index menuType:(SheetMenuType)menuT menuFlag:(NSInteger)flag{
    
    NSLog(@"index:%ti",index);
    
    if (flag == 5){
        ///@"请选择来源";
        
        [self changeSelectedFlag:arrayByBelong index:index];
        
        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[arrayByBelong objectAtIndex:index];
        NSLog(@"title:%@   ids:%@",model.title,model.itmeId);
        [self notifyDataSource:[NSIndexPath indexPathForRow:2 inSection:0] valueString:model.title idString:model.itmeId];
    }
    
    [self.tableviewCustomerDetails reloadData];
}

-(void)changeSelectedFlag:(NSArray *)array index:(NSInteger)index{
    LLCenterSheetMenuModel *modelTmp;
    for (int i=0; i<[array count]; i++) {
        modelTmp = (LLCenterSheetMenuModel*)[array objectAtIndex:i];
        if (i==index) {
            modelTmp.selectedFlag = @"yes";
        }else{
            modelTmp.selectedFlag = @"no";
        }
    }
}

///更新选择的标签
-(void)changeTagSelectFlag:(NSArray *)array{
    NSInteger countSelect = 0;
    if (array) {
        countSelect = [array count];
    }
    NSInteger countTag = [arrCusTagsNew count];
    LLCenterSheetMenuModel *model;
    LLCenterSheetMenuModel *modelSelect;
    BOOL isFound = FALSE;
    ///标记全部清空 将当前选中的重新做标记
    for (int i=0; i<countTag; i++) {
        model = (LLCenterSheetMenuModel *)[arrCusTagsNew objectAtIndex:i];
        model.selectedFlag = @"no";
        isFound = FALSE;
        for (int k=0; !isFound && k<countSelect; k++) {
            modelSelect = [array objectAtIndex:k];
            if ([model.title isEqualToString:modelSelect.title]) {
                isFound = TRUE;
                model.selectedFlag = @"yes";
            }
        }
    }
    NSLog(@"changeTagSelectFlag--->");
}

#pragma mark - 刷新数据源
///更新数据源
-(void)notifyDataSource:(NSIndexPath *)indexPath valueString:(NSString *)valueStr idString:(NSString *)ids{
    
    EditItemModel *model = (EditItemModel *)[[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];
    NSLog(@"notifyDataSource:%@",model);
    model.content = valueStr;
    model.itemId = ids;
    
    /*
    NSMutableArray *arraySection = [[NSMutableArray alloc] init];
    NSArray *arraySectionOld = [[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"content"];
    [arraySection addObjectsFromArray:arraySectionOld];
    [arraySection replaceObjectAtIndex:indexPath.row withObject:model];
    
    
    NSDictionary *item = [self.dataSource objectAtIndex:indexPath.section];
    NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:item];
    [mutableItemNew setObject:arraySection forKey:@"content"];
    [self.dataSource replaceObjectAtIndex:indexPath.section withObject:mutableItemNew];
    */
    
    
    //    [self.tableviewAddCustomer reloadData];
}


///获取标签字符串
-(NSString *)getTagsBySelected:(NSArray *)array{
    NSInteger count = 0;
    if (array) {
        count = [array count];
    }
    LLCenterSheetMenuModel *modelTmp;
    NSMutableString *strTags = [[NSMutableString alloc] init];
    for (int i=0; i<count; i++) {
        modelTmp = (LLCenterSheetMenuModel*)[array objectAtIndex:i];
        if ([strTags isEqualToString:@""]) {
            [strTags appendString:modelTmp.title];
        }else{
            [strTags appendString:@","];
            [strTags appendString:modelTmp.title];
        }
    }
    return strTags;
}


///获取标签字符串
-(NSString *)getTagsByDefault:(NSArray *)array{
    NSInteger count = 0;
    if (array) {
        count = [array count];
    }
    
    NSMutableString *strTags = [[NSMutableString alloc] init];
    for (int i=0; i<count; i++) {
        
        if ([strTags isEqualToString:@""]) {
            [strTags appendString:[array objectAtIndex:i]];
        }else{
            [strTags appendString:@","];
            [strTags appendString:[array objectAtIndex:i]];
        }
    }
    return strTags;
}


///获取标签字符串ids
-(NSString *)getTagsIdBySelect:(NSArray *)array{

    NSInteger count = 0;
    if (array) {
        count = [array count];
    }
    LLCenterSheetMenuModel *mode;
    NSMutableString *strTags = [[NSMutableString alloc] init];
    for (int i=0; i<count; i++) {
        mode = (LLCenterSheetMenuModel *)[array objectAtIndex:i];
        if ([mode.selectedFlag isEqualToString:@"yes"]) {
            if ([strTags isEqualToString:@""]) {
                [strTags appendString:mode.itmeId];
            }else{
                [strTags appendString:@","];
                [strTags appendString:mode.itmeId];
            }
        }
    }
    return strTags;
}


-(NSArray *)getTagsArrayBySelectData{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger count = 0;
    if (arrCusTagsNew) {
        count = [arrCusTagsNew count];
    }
    LLCenterSheetMenuModel *mode;
    LLCenterSheetMenuModel *modeO;
    for (int i=0; i<count; i++) {
        modeO = [arrCusTagsNew objectAtIndex:i];
        mode = [[LLCenterSheetMenuModel alloc] init];
        mode = [modeO copy];
        [array addObject:mode];
    }
    return array;
}




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
            NSArray *arr = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"];
            [self initOwerUser:arr];
            
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


@end
