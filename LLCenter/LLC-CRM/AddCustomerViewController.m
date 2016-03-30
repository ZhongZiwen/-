//
//  AddCustomerViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-10.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AddCustomerViewController.h"
#import "EditItemTypeCellA.h"
#import "EditItemTypeCellB.h"
#import "EditItemTypeCellC.h"
#import "EditItemTypeCellD.h"
#import "LLCenterUtility.h"
#import "EditItemModel.h"
#import "LLcenterSheetMenuView.h"
#import "LLCenterSheetMenuModel.h"
#import "TPKeyboardAvoidingTableView.h"
#import "CommonFunc.h"


@interface AddCustomerViewController ()<UITableViewDataSource,UITableViewDelegate,LLCenterSheetMenuDelegate>{
    ///来源
    NSMutableArray *arraySource;
    ///类型
    NSMutableArray *arrayCustomerType;
    ///联系人类型
    NSMutableArray *arrayLinkManType;
    ///标签
    NSMutableArray *arrayTag;
    ///客户类型 服务器端返回
    NSString *cusType;
}


@property(strong,nonatomic) TPKeyboardAvoidingTableView *tableviewAddCustomer;
@property(strong,nonatomic) NSMutableArray *dataSource;
@end

@implementation AddCustomerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"创建客户";
    self.view.backgroundColor = COLOR_BG;
    [self addNarBar];
    ///默认公司客户
    cusType = @"company";
     [self initDataWithType:0];
    [self initTableview];
    [self getinitAddCustomerDetail];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    ///公司客户还是个人客户
    NSInteger isCompCustomer = 0;
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (![CommonFunc checkNetworkState]) {
        [CommonFuntion showToast:@"无网络可用,加载失败" inView:self.view];
        return;
    }
    
    
    EditItemModel *modelEdit = (EditItemModel *)[[[self.dataSource objectAtIndex:0] objectForKey:@"content"] objectAtIndex:0];
    
    EditItemModel *modelBase = (EditItemModel *)[[[self.dataSource objectAtIndex:1] objectForKey:@"content"] objectAtIndex:0];
    
    ///公司客户
    if ([modelEdit.content integerValue] == 0) {
        isCompCustomer = 0;
        if ([modelBase.content isEqualToString:@""]) {
            [CommonFuntion showToast:@"公司名称不能为空" inView:self.view];
            return;
        }
        
        EditItemModel *modelLinkMan = (EditItemModel *)[[[self.dataSource objectAtIndex:2] objectForKey:@"content"] objectAtIndex:0];
        
        if ([modelLinkMan.content isEqualToString:@""]) {
            [CommonFuntion showToast:@"联系人姓名不能为空" inView:self.view];
            return;
        }
        
        EditItemModel *modelLinkType = (EditItemModel *)[[[self.dataSource objectAtIndex:2] objectForKey:@"content"] objectAtIndex:1];
        
        if ([modelLinkType.content isEqualToString:@""]) {
            [CommonFuntion showToast:@"联系人类型不能为空" inView:self.view];
            return;
        }
        
        
        EditItemModel *modelLinkPhone = (EditItemModel *)[[[self.dataSource objectAtIndex:2] objectForKey:@"content"] objectAtIndex:2];
        
        if (![modelLinkPhone.content isEqualToString:@""]) {
            if (![CommonFunc isValidatePhoneNumber:modelLinkPhone.content]) {
                [CommonFuntion showToast:@"请输入正确的手机号" inView:self.view];
                return;
            }
            
        }
        
        
        EditItemModel *modelTel = (EditItemModel *)[[[self.dataSource objectAtIndex:2] objectForKey:@"content"] objectAtIndex:3];
        
        if (![modelTel.content isEqualToString:@""]) {
            if (![CommonFunc checkStringIsNum:modelTel.content]) {
                [CommonFuntion showToast:@"请输入正确的固话" inView:self.view];
                return;
            }
        }
        
        
        EditItemModel *modelQQ= (EditItemModel *)[[[self.dataSource objectAtIndex:2] objectForKey:@"content"] objectAtIndex:4];
        
        if (![modelQQ.content isEqualToString:@""]) {
            if (![CommonFunc checkStringIsNum:modelQQ.content]) {
                [CommonFuntion showToast:@"请输入正确的QQ号码" inView:self.view];
                return;
            }
        }
        
        
        EditItemModel *modelLinkEmail = (EditItemModel *)[[[self.dataSource objectAtIndex:2] objectForKey:@"content"] objectAtIndex:5];
        
        if (![modelLinkEmail.content isEqualToString:@""]) {
            if (![CommonFunc isValidateEmail:modelLinkEmail.content]) {
                [CommonFuntion showToast:@"请输入正确的邮箱" inView:self.view];
                return;
            }
            
        }
        
    }else{
        isCompCustomer = 1;
        if ([modelBase.content isEqualToString:@""]) {
            [CommonFuntion showToast:@"联系人姓名不能为空" inView:self.view];
            return;
        }
        
        EditItemModel *modelLinkType = (EditItemModel *)[[[self.dataSource objectAtIndex:2] objectForKey:@"content"] objectAtIndex:0];
        
        if ([modelLinkType.content isEqualToString:@""]) {
            [CommonFuntion showToast:@"联系人类型不能为空" inView:self.view];
            return;
        }
        
        EditItemModel *modelLinkPhone = (EditItemModel *)[[[self.dataSource objectAtIndex:2] objectForKey:@"content"] objectAtIndex:1];
        
        if (![modelLinkPhone.content isEqualToString:@""]) {
            if (![CommonFunc isValidatePhoneNumber:modelLinkPhone.content]) {
                [CommonFuntion showToast:@"请输入正确的手机号" inView:self.view];
                return;
            }
            
        }
        
        EditItemModel *modelTel = (EditItemModel *)[[[self.dataSource objectAtIndex:2] objectForKey:@"content"] objectAtIndex:2];
        
        if (![modelTel.content isEqualToString:@""]) {
            if (![CommonFunc checkStringIsNum:modelTel.content]) {
                [CommonFuntion showToast:@"请输入正确的固话" inView:self.view];
                return;
            }
        }
        
        
        EditItemModel *modelQQ= (EditItemModel *)[[[self.dataSource objectAtIndex:2] objectForKey:@"content"] objectAtIndex:3];
        
        if (![modelQQ.content isEqualToString:@""]) {
            if (![CommonFunc checkStringIsNum:modelQQ.content]) {
                [CommonFuntion showToast:@"请输入正确的QQ号码" inView:self.view];
                return;
            }
        }
        
        EditItemModel *modelLinkEmail = (EditItemModel *)[[[self.dataSource objectAtIndex:2] objectForKey:@"content"] objectAtIndex:4];
        
        if (![modelLinkEmail.content isEqualToString:@""]) {
            if (![CommonFunc isValidateEmail:modelLinkEmail.content]) {
                [CommonFuntion showToast:@"请输入正确的邮箱" inView:self.view];
                return;
            }
            
        }
    }
    
    
    for (int i=0; i<[self.dataSource count]; i++) {
        NSArray *array = [[self.dataSource objectAtIndex:i] objectForKey:@"content"];
        for (int k=0; k<[array count]; k++) {
            EditItemModel *item  = (EditItemModel*) [array objectAtIndex:k];
            NSLog(@"%@  %@  %@",item.title,item.content,item.itemId);
        }
    }
    
    ///新增客户
    [self addNewCustomer];

    
}

#pragma mark - 初始化选择条件数据
-(void)initOptionsData{
    
    ///客户来源
    NSMutableArray *array1 = [[NSMutableArray alloc] init];
    NSInteger count = 0;
    if (arraySource) {
        count = [arraySource count];
    }
    for (int i=0; i<count; i++) {
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = [[arraySource objectAtIndex:i] safeObjectForKey:@"id"];
        model.title = [[arraySource objectAtIndex:i] safeObjectForKey:@"name"];
        ///默认选中项
        if ([[[arraySource objectAtIndex:i] safeObjectForKey:@"default"] integerValue] == 1) {
            model.selectedFlag = @"yes";
            [self notifyDataSource:[NSIndexPath indexPathForRow:2 inSection:1] valueString:model.title idString:model.itmeId];
        }else{
            model.selectedFlag = @"no";
        }
        [array1 addObject:model];
    }
    
    ///客户类型
    NSMutableArray *array2 = [[NSMutableArray alloc] init];
    if (arrayCustomerType) {
        count = [arrayCustomerType count];
    }
    for (int i=0; i<count; i++) {
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = [[arrayCustomerType objectAtIndex:i] safeObjectForKey:@"id"];
        model.title = [[arrayCustomerType objectAtIndex:i] safeObjectForKey:@"name"];
        ///默认选中项
        if ([[[arrayCustomerType objectAtIndex:i] safeObjectForKey:@"default"] integerValue] == 1) {
            model.selectedFlag = @"yes";
            [self notifyDataSource:[NSIndexPath indexPathForRow:3 inSection:1] valueString:model.title idString:model.itmeId];
        }else{
            model.selectedFlag = @"no";
        }
        [array2 addObject:model];
    }
    
    
    ///联系人类型
    NSMutableArray *array3 = [[NSMutableArray alloc] init];
    if (arrayLinkManType) {
        count = [arrayLinkManType count];
    }
    for (int i=0; i<count; i++) {
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = [[arrayLinkManType objectAtIndex:i] safeObjectForKey:@"id"];
        model.title = [[arrayLinkManType objectAtIndex:i] safeObjectForKey:@"name"];
        ///默认选中项
        if ([[[arrayLinkManType objectAtIndex:i] safeObjectForKey:@"default"] integerValue] == 1) {
            model.selectedFlag = @"yes";
            
            EditItemModel *modelEdit = (EditItemModel *)[[[self.dataSource objectAtIndex:0] objectForKey:@"content"] objectAtIndex:0];
            ///公司客户
            if ([modelEdit.content integerValue] == 0) {
                [self notifyDataSource:[NSIndexPath indexPathForRow:1 inSection:2] valueString:model.title idString:model.itmeId];
            }else{
                [self notifyDataSource:[NSIndexPath indexPathForRow:0 inSection:2] valueString:model.title idString:model.itmeId];
            }
            
        }else{
            model.selectedFlag = @"no";
        }
        [array3 addObject:model];
    }
    
    ///标签
    NSMutableArray *array4 = [[NSMutableArray alloc] init];
    if (arrayTag) {
        count = [arrayTag count];
    }
    for (int i=0; i<count; i++) {
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = [[arrayTag objectAtIndex:i] safeObjectForKey:@"id"];
        model.title = [[arrayTag objectAtIndex:i] safeObjectForKey:@"name"];
        ///默认选中项
        if ([[[arrayTag objectAtIndex:i] safeObjectForKey:@"default"] integerValue] == 1) {
            model.selectedFlag = @"yes";
            ///修改数据源选中标记
            [self notifyDataSource:[NSIndexPath indexPathForRow:1 inSection:1] valueString:model.title idString:@""];
        }else{
            model.selectedFlag = @"no";
        }
        [array4 addObject:model];
    }
    [arraySource removeAllObjects];
    [arrayCustomerType removeAllObjects];
    [arrayLinkManType removeAllObjects];
    [arrayTag removeAllObjects];
    
    [arraySource addObjectsFromArray:array1];
    [arrayCustomerType addObjectsFromArray:array2];
    [arrayLinkManType addObjectsFromArray:array3];
    [arrayTag addObjectsFromArray:array4];
    
    [self.tableviewAddCustomer reloadData];
    
    NSLog(@"arraySource:%@",arraySource);
    NSLog(@"arrayCustomerType:%@",arrayCustomerType);
    NSLog(@"arrayLinkManType:%@",arrayLinkManType);
    NSLog(@"arrayTag:%@",arrayTag);
}


#pragma mark - 根据客户类型 初始化数据  0公司客户 1个人客户
-(void)initDataWithType:(NSInteger)type{
    
    arraySource = [[NSMutableArray alloc] init];
    arrayCustomerType = [[NSMutableArray alloc] init];
    arrayLinkManType = [[NSMutableArray alloc] init];
    arrayTag = [[NSMutableArray alloc] init];
    

    self.dataSource = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *dicDataSource = [[NSMutableDictionary alloc] init];
    NSMutableArray *arraySection = [[NSMutableArray alloc] init];
    
    ///客户类型
    EditItemModel *model = [[EditItemModel alloc] init];
    model.title = @"客户类型:";
    model.content = @"0";
    model.cellType = @"cellD";
    model.keyStr = @"";
    model.keyType = @"";
    [arraySection addObject:model];
    
    
    [dicDataSource setObject:@"" forKey:@"head"];
    [dicDataSource setObject:arraySection forKey:@"content"];
    
    [self.dataSource addObject:dicDataSource];
    
    
    ///基本信息
    arraySection = [[NSMutableArray alloc] init];
    dicDataSource = [[NSMutableDictionary alloc] init];
    
    model = [[EditItemModel alloc] init];
    model.title = @"公司名称:";
    model.content = @"";
    model.placeholder = @"请输入公司名称(必填)";
    model.cellType = @"cellA";
    model.keyStr = @"customerName";
    model.keyType = @"";
    [arraySection addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.itemId = @"";
    model.title = @"标签:";
    model.content = @"";
    model.placeholder = @"标签";
    model.cellType = @"cellC";
    model.keyStr = @"";
    model.keyType = @"";
    [arraySection addObject:model];
    
    
    model = [[EditItemModel alloc] init];
    model.itemId = @"";
    model.title = @"来源:";
    model.content = @"";
    model.placeholder = @"";
    model.cellType = @"cellB";
    model.keyStr = @"customerSource";
    model.keyType = @"customerSource";
    [arraySection addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.itemId = @"";
    model.title = @"类型:";
    model.content = @"";
    model.placeholder = @"";
    model.cellType = @"cellB";
    model.keyStr = @"customerCategory";
    model.keyType = @"customerCategory";
    [arraySection addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"地址:";
    model.content = @"";
    model.placeholder = @"请输入地址信息";
    model.cellType = @"cellA";
    model.keyStr = @"customerAddress";
    model.keyType = @"";
    [arraySection addObject:model];
    
    [dicDataSource setObject:@"基本信息" forKey:@"head"];
    [dicDataSource setObject:arraySection forKey:@"content"];
    
    [self.dataSource addObject:dicDataSource];
    
    
    
    ///联系信息
    arraySection = [[NSMutableArray alloc] init];
    dicDataSource = [[NSMutableDictionary alloc] init];
    
    model = [[EditItemModel alloc] init];
    model.title = @"姓名:";
    model.content = @"";
    model.placeholder = @"请输入姓名(必填)";
    model.cellType = @"cellA";
    model.keyStr = @"linkmanName";
    model.keyType = @"";
    [arraySection addObject:model];
    
    
    model = [[EditItemModel alloc] init];
    model.itemId = @"";
    model.title = @"联系人类型:";
    model.content = @"";
    model.placeholder = @"";
    model.cellType = @"cellB";
    model.keyStr = @"linkmanCategory";
    model.keyType = @"linkmanCategory";
    [arraySection addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"手机:";
    model.content = @"";
    model.placeholder = @"请输入手机号码";
    model.cellType = @"cellA";
    model.keyStr = @"linkmanMobilePhone";
    model.keyType = @"";
    [arraySection addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"固话:";
    model.content = @"";
    model.placeholder = @"请输入固话号码";
    model.cellType = @"cellA";
    model.keyStr = @"linkmanPhone";
    model.keyType = @"";
    [arraySection addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"QQ:";
    model.content = @"";
    model.placeholder = @"请输入QQ号码";
    model.cellType = @"cellA";
    model.keyStr = @"linkmanQQ";
    model.keyType = @"";
    [arraySection addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"邮箱:";
    model.content = @"";
    model.placeholder = @"请输入邮箱地址";
    model.cellType = @"cellA";
    model.keyStr = @"linkmanEmail";
    model.keyType = @"";
    [arraySection addObject:model];
    
    
    [dicDataSource setObject:@"联系信息" forKey:@"head"];
    [dicDataSource setObject:arraySection forKey:@"content"];
    
    [self.dataSource addObject:dicDataSource];
    
    NSLog(@"self.dataSource:%@",self.dataSource);
    for (int i=0; i<[self.dataSource count]; i++) {
        NSArray *array = [[self.dataSource objectAtIndex:i] objectForKey:@"content"];
        for (int k=0; k<[array count]; k++) {
            EditItemModel *item  = (EditItemModel*) [array objectAtIndex:k];
            NSLog(@"%@  %@",item.title,item.cellType);
        }
    }
}


-(UIView *)creatHeadView{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 50)];
    return headView;
}


#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewAddCustomer = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-64) style:UITableViewStyleGrouped];
    self.tableviewAddCustomer.delegate = self;
    self.tableviewAddCustomer.dataSource = self;
    self.tableviewAddCustomer.sectionFooterHeight = 0;
    
    [self.view addSubview:self.tableviewAddCustomer];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewAddCustomer setTableFooterView:v];

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
        return 20;
    }
    return 30;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return nil;
    }
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 30)];
    
    NSString *imgName = @"";
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7, 23, 15)];
    if (section == 1) {
        imgName = @"icon_customer_baseinfo.png";
    }else{
        imgName = @"icon_customer_contactinfo.png";
    }
    icon.image = [UIImage imageNamed:imgName];
    
    
    headView.backgroundColor = [UIColor whiteColor];
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(43, 5, 100, 20)];
    labelTitle.font = [UIFont systemFontOfSize:15.0];
    labelTitle.tintColor = [UIColor blackColor];
    labelTitle.text = [[self.dataSource objectAtIndex:section] objectForKey:@"head"];
    
    [headView addSubview:icon];
    [headView addSubview:labelTitle];
    
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
    
        __weak typeof(self) weak_self = self;
        cell.textValueChangedBlock = ^(NSString *valueString){
//            NSLog(@"index:%ti valueString:%@",indexPath.row,valueString);
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
        __weak typeof(self) weak_self = self;
        cell.SelectDataTypeBlock = ^(NSInteger type){
            ///1 标签 2来源 3类型 4联系人类型
            NSInteger falg = 1;
            ///标签
            if (indexPath.section == 1 && indexPath.row == 1) {
                falg = 1;
            }else if (indexPath.section == 1 && indexPath.row == 2) {
                ///来源
                falg = 2;
            }else if (indexPath.section == 1 && indexPath.row == 3) {
                ///类型
                falg = 3;
            }else  {
                ///联系人类型
                falg = 4;
            }
            [weak_self showMenuByFlag:falg withIndexPath:indexPath];
        };
        [cell setCellDetail:item];
        return cell;
    }else if ([item.cellType isEqualToString:@"cellC"]) {
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
    }else if ([item.cellType isEqualToString:@"cellD"]) {
        EditItemTypeCellD *cell = [tableView dequeueReusableCellWithIdentifier:@"EditItemTypeCellDIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"EditItemTypeCellD" owner:self options:nil];
            cell = (EditItemTypeCellD*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        __weak typeof(self) weak_self = self;
        cell.SelectCustomerTypeBlock = ^(NSInteger type){
            [weak_self changeCustomerType:type];
        };
        [cell setCellDetail:item andLeftTitle:@"公司客户" andRightTitle:@"个人客户"];
        return cell;
    }
    
    return nil;
}


#pragma mark - 刷新数据源
///更改客户类型 并刷新UI展示
-(void)changeCustomerType:(NSInteger)type{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    NSLog(@"changeCustomerType:%ti",type);
    
    EditItemModel *model = (EditItemModel *)[[[self.dataSource objectAtIndex:0] objectForKey:@"content"] objectAtIndex:0];
    
    if ([model.content integerValue] == type) {
        return;
    }
    NSLog(@"需要刷新数据");
    model.content = [NSString stringWithFormat:@"%ti",type];
    
    NSMutableArray *arraySection = [[NSMutableArray alloc] init];
    [arraySection addObject:model];
//    NSLog(@"arraySection:%@",arraySection);
    

    NSMutableDictionary *mutableItemNew0 = [[NSMutableDictionary alloc] init];
    [mutableItemNew0 setObject:@"" forKey:@"head"];
    [mutableItemNew0 setObject:arraySection forKey:@"content"];
    [self.dataSource removeObjectAtIndex:0];
    [self.dataSource insertObject:mutableItemNew0 atIndex:0];
//    NSLog(@"mutableItemNew0:%@",mutableItemNew0);
    
    
    
    EditItemModel *modelB;
    ///  公司名称修改为姓名
    ///个人客户修改为公司客户
    if (type == 0) {
        
        modelB = (EditItemModel *)[[[self.dataSource objectAtIndex:1] objectForKey:@"content"] objectAtIndex:0];
        modelB.title = @"公司名称:";
        modelB.keyStr = @"customerName";
        modelB.keyType = @"";
        modelB.placeholder = @"请输入公司名称(必填)";
        
    }else{
        modelB = (EditItemModel *)[[[self.dataSource objectAtIndex:1] objectForKey:@"content"] objectAtIndex:0];
        modelB.title = @"联系人姓名:";
        modelB.keyStr = @"linkmanName";
        modelB.keyType = @"";
        modelB.placeholder = @"请输入姓名(必填)";
    }
    
    NSMutableArray *arraySectionB = [[NSMutableArray alloc] init];
    NSArray *arraySectionBOld = [[self.dataSource objectAtIndex:1] objectForKey:@"content"];
    [arraySectionB addObjectsFromArray:arraySectionBOld];
    [arraySectionB replaceObjectAtIndex:0 withObject:modelB];
    
    
//    NSDictionary *item10 = [arraySectionBOld objectAtIndex:0];
//    NSMutableDictionary *mutableItemNew10 = [NSMutableDictionary dictionaryWithDictionary:modelB];
//    [arraySectionB setObject: mutableItemNew10 atIndexedSubscript:0];
    
    
    NSDictionary *item100 = [self.dataSource objectAtIndex:1];
    NSMutableDictionary *mutableItemNew100 = [NSMutableDictionary dictionaryWithDictionary:item100];
    [mutableItemNew100 setObject:arraySectionB forKey:@"content"];
    [self.dataSource replaceObjectAtIndex:1 withObject:mutableItemNew100];
    //修改数据
//    [self.dataSource setObject: mutableItemNew100 atIndexedSubscript:1];
   

    ///如果是公司客户 则添加姓名  如果是个人客户 则删除姓名
    ///个人客户修改为公司客户
    
    NSMutableArray *arraySectionC;
    NSArray *arraySectionCOld;
    if (type == 0) {
        EditItemModel *model = [[EditItemModel alloc] init];
        model.title = @"姓名:";
        model.content = @"";
        model.placeholder = @"请输入姓名";
        model.cellType = @"cellA";
        model.keyStr = @"linkmanName";
        arraySectionC = [[NSMutableArray alloc] init];
        arraySectionCOld = [[self.dataSource objectAtIndex:2] objectForKey:@"content"];
        [arraySectionC addObjectsFromArray:arraySectionCOld];
        [arraySectionC insertObject:model atIndex:0];
        
    }else{
        ///移除姓名项
        arraySectionC = [[NSMutableArray alloc] init];
        arraySectionCOld = [[self.dataSource objectAtIndex:2] objectForKey:@"content"];
        [arraySectionC addObjectsFromArray:arraySectionCOld];
        [arraySectionC removeObjectAtIndex:0];
    }
//    NSLog(@"arraySectionC:%@",arraySectionC);
    
    NSDictionary *item20 = [self.dataSource objectAtIndex:2];
    NSMutableDictionary *mutableItemNew20 = [NSMutableDictionary dictionaryWithDictionary:item20];
    [mutableItemNew20 setObject:arraySectionC forKey:@"content"];
    [self.dataSource replaceObjectAtIndex:2 withObject:mutableItemNew20];
    
//    NSLog(@"self.dataSource:%@",self.dataSource);
    
    [self.tableviewAddCustomer reloadData];
}


///更新数据源
-(void)notifyDataSource:(NSIndexPath *)indexPath valueString:(NSString *)valueStr idString:(NSString *)ids{
    ///是公司客户还是个人客户
    EditItemModel *model = (EditItemModel *)[[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"content"] objectAtIndex:indexPath.row];
    model.content = valueStr;
    model.itemId = ids;
    
    NSMutableArray *arraySection = [[NSMutableArray alloc] init];
    NSArray *arraySectionOld = [[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"content"];
    [arraySection addObjectsFromArray:arraySectionOld];
    [arraySection replaceObjectAtIndex:indexPath.row withObject:model];
    
    
    NSDictionary *item = [self.dataSource objectAtIndex:indexPath.section];
    NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:item];
    [mutableItemNew setObject:arraySection forKey:@"content"];
    [self.dataSource replaceObjectAtIndex:indexPath.section withObject:mutableItemNew];
    

//    [self.tableviewAddCustomer reloadData];
}



#pragma mark - 弹框
///根据flag 弹框  1 标签 2来源 3类型 4联系人类型
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
        NSLog(@"arrayTag :%@",arrayTag);
        for (int i=0; i<[arrayTag count]; i++) {
            LLCenterSheetMenuModel *item  = (LLCenterSheetMenuModel*) [arrayTag objectAtIndex:i];
            NSLog(@"%@  %@",item.title,item.selectedFlag);
        }
        
        array = [self getTagsArrayByData];
        NSLog(@"array:%@",array);
        
        
    }else if (flag == 2){
        title = @"来源";
        type = 0;
        array = arraySource;
    }else if (flag == 3){
        title = @"类型";
        type = 0;
        array = arrayCustomerType;
    }else if (flag == 4){
        title = @"联系人类型";
        type = 0;
        array = arrayLinkManType;
    }
    
    if (array == nil || [array count] == 0) {
        NSLog(@"选择数据源为空");
        NSString *strMsg = @"";
        if (flag == 1) {
            strMsg = @"标签加载失败";
        }else if (flag == 2){
            strMsg = @"来源加载失败";
        }else if (flag == 3){
            strMsg = @"类型加载失败";
        }else if (flag == 4){
            strMsg = @"联系人类型加载失败";
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

        ///修改数据源选中标记
        NSString *tags = [self getTagsBySelected:selectedArray];
        [weak_self notifyDataSource:[NSIndexPath indexPathForRow:1 inSection:1] valueString:tags idString:@""];
        [weak_self.tableviewAddCustomer reloadData];
    };
    
    [sheet showInView:nil];
}


-(void)didSelectSheetMenuIndex:(NSInteger)index menuType:(SheetMenuType)menuT menuFlag:(NSInteger)flag{
    
    NSLog(@"index:%ti",index);
    
    if (flag == 2){
        ///@"请选择来源";
        
        [self changeSelectedFlag:arraySource index:index];

        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[arraySource objectAtIndex:index];
         NSLog(@"title:%@   ids:%@",model.title,model.itmeId);
        [self notifyDataSource:[NSIndexPath indexPathForRow:2 inSection:1] valueString:model.title idString:model.itmeId];
        
    }else if (flag == 3){
        [self changeSelectedFlag:arrayCustomerType index:index];
       ///@"请选择类型";
        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[arrayCustomerType objectAtIndex:index];
        NSLog(@"title:%@   ids:%@",model.title,model.itmeId);
        
        [self notifyDataSource:[NSIndexPath indexPathForRow:3 inSection:1] valueString:model.title idString:model.itmeId];
    }else if (flag == 4){
        [self changeSelectedFlag:arrayLinkManType index:index];
        
       ///@"请选择类型";
        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[arrayLinkManType objectAtIndex:index];
        NSLog(@"title:%@   ids:%@",model.title,model.itmeId);
        
        
        EditItemModel *modelEdit = (EditItemModel *)[[[self.dataSource objectAtIndex:0] objectForKey:@"content"] objectAtIndex:0];
        ///公司客户
        if ([modelEdit.content integerValue] == 0) {
            [self notifyDataSource:[NSIndexPath indexPathForRow:1 inSection:2] valueString:model.title idString:model.itmeId];
        }else{
            [self notifyDataSource:[NSIndexPath indexPathForRow:0 inSection:2] valueString:model.title idString:model.itmeId];
        }
    }
    
    [self.tableviewAddCustomer reloadData];
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

-(NSArray *)getTagsArrayByData{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger count = 0;
    if (arrayTag) {
        count = [arrayTag count];
    }
    LLCenterSheetMenuModel *mode;
    LLCenterSheetMenuModel *modeO;
    for (int i=0; i<count; i++) {
        modeO = [arrayTag objectAtIndex:i];
        mode = [[LLCenterSheetMenuModel alloc] init];
        mode = [modeO copy];
        [array addObject:mode];
    }
    return array;
}

///根据选择获取标签
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

///更新选择的标签
-(void)changeTagSelectFlag:(NSArray *)array{
    NSInteger countSelect = 0;
    if (array) {
        countSelect = [array count];
    }
    NSInteger countTag = [arrayTag count];
    LLCenterSheetMenuModel *model;
    LLCenterSheetMenuModel *modelSelect;
    BOOL isFound = FALSE;
    ///标记全部清空 将当前选中的重新做标记
    for (int i=0; i<countTag; i++) {
        model = (LLCenterSheetMenuModel *)[arrayTag objectAtIndex:i];
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

#pragma mark - 请求服务器数据


-(void)getinitAddCustomerDetail{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_CUSTOMER_DETAILS_DICTIONARY_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"新建客户jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            if ([jsonResponse objectForKey:@"resultMap"]) {
                
                /*
                 arraySource = [[NSMutableArray alloc] init];
                 arrayCustomerType = [[NSMutableArray alloc] init];
                 arrayLinkManType = [[NSMutableArray alloc] init];
                 arrayTag = [[NSMutableArray alloc] init];
                 */
                
                
                ///类型
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"customerCategory"] != [NSNull null]) {
                    NSArray *customerCategory = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"customerCategory"];
                    NSLog(@"customerCategory:%@",customerCategory);
                    if (customerCategory) {
                        [arrayCustomerType addObjectsFromArray:customerCategory];
                    }
                }
                
                ///来源
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"customerSource"] != [NSNull null]) {
                    NSArray *customerSource = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"customerSource"];
                    NSLog(@"customerSource:%@",customerSource);
                    if (customerSource) {
                        [arraySource addObjectsFromArray:customerSource];
                    }
                }
                
                ///标签
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"customerTag"] != [NSNull null]) {
                    NSArray *customerTag = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"customerTag"];
                    NSLog(@"customerTag:%@",customerTag);
                    if (customerTag) {
                        [arrayTag addObjectsFromArray:customerTag];
                    }
                }
                
                
                ///联系人类型
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"linkmanCategory"] != [NSNull null]) {
                    NSArray *linkmanCategory = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"linkmanCategory"];
                    NSLog(@"linkmanCategory:%@",linkmanCategory);
                    if (linkmanCategory) {
                        [arrayLinkManType addObjectsFromArray:linkmanCategory];
                    }
                }
                ///客户类型
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"customerType"] != [NSNull null]) {
                    cusType = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"customerType"];
                }
                
                ///初始化数据
                [self initOptionsData];
                if ([cusType isEqualToString:@"personal"]) {
                    [self changeCustomerType:1];
                }else{
                    [self changeCustomerType:0];
                }
                
            }else{
                NSLog(@"data------>:<null>");
                [CommonFuntion showToast:@"加载异常" inView:self.view];
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getinitAddCustomerDetail];
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

#pragma mark - 新建客户

-(void)addNewCustomer{
    
    ///客户分类，公司名称（必传，且对其做校验），标签（以ID加“,”分割传入），客户来源，客户类型，地址，联系人姓名（必传），联系人类型（必传），手机，固话，QQ，邮箱

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];

    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    for (int i=0; i<[self.dataSource count]; i++) {
        NSArray *array = [[self.dataSource objectAtIndex:i] objectForKey:@"content"];
        for (int k=0; k<[array count]; k++) {
            EditItemModel *item  = (EditItemModel*) [array objectAtIndex:k];
            
            if (item.keyType && item.keyType.length > 0) {
                if (item.keyStr && item.keyStr.length > 0) {
                    [rDict setValue:item.itemId forKey:item.keyStr];
                    NSLog(@"key: %@   value: %@",item.keyStr,item.content);
                }
            }else{
                if (item.keyStr && item.keyStr.length > 0) {
                    [rDict setValue:item.content forKey:item.keyStr];
                    NSLog(@"key: %@   value: %@",item.keyStr,item.content);
                }
            }
        }
    }
    
    EditItemModel *model = (EditItemModel *)[[[self.dataSource objectAtIndex:0] objectForKey:@"content"] objectAtIndex:0];
    
    if ([model.content integerValue] == 0) {
        [rDict setValue:@"company" forKey:@"customerType"];
    }else{
         [rDict setValue:@"personal" forKey:@"customerType"];
         [rDict setValue:[NSString stringWithFormat:@"个人-%@",[rDict safeObjectForKey:@"linkmanName"]] forKey:@"customerName"];
    }
    
    
    [rDict setValue:[self getTagsIdBySelect:arrayTag]
             forKey:@"customerTag"];
    NSLog(@"rDict:%@",rDict);
    
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_SAVE_CUSTOMER_INFO_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"新建客户jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [CommonFuntion showToast:@"保存成功" inView:self.view];
            if (self.NotifyCustomerList) {
                self.NotifyCustomerList();
            }
            [self.navigationController popViewControllerAnimated:YES];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self addNewCustomer];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"保存失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
}



@end
