//
//  AddMoreContactViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-11.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AddMoreContactViewController.h"
#import "LLCenterUtility.h"
#import "EditItemModel.h"
#import "LLcenterSheetMenuView.h"
#import "LLCenterSheetMenuModel.h"
#import "TPKeyboardAvoidingTableView.h"
#import "CommonFunc.h"
#import "EditItemTypeCellA.h"
#import "EditItemTypeCellB.h"
#import "LLCCustomerDetailViewController.h"

@interface AddMoreContactViewController ()<UITableViewDataSource,UITableViewDelegate,LLCenterSheetMenuDelegate>{
    ///联系人类型
    NSMutableArray *arrayLinkManType;
    

}
@property(strong,nonatomic) TPKeyboardAvoidingTableView *tableviewAddContact;
@property(strong,nonatomic) NSMutableArray *dataSource;

@end

@implementation AddMoreContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"创建联系人";
    self.view.backgroundColor = COLOR_BG;
    [self addNarBar];
    
    ///公司
    NSString *companyName = @"";
    if ([self.cusDetails objectForKey:@"CUSTOMER_NAME"] ) {
        companyName = [self.cusDetails safeObjectForKey:@"CUSTOMER_NAME"];
    }
    [self initDataWithCustomerName:companyName];
    [self initTableview];
    [self getinitAddCustomerDetail];
}

#pragma mark - Nar Bar
-(void)addNarBar{
    [super customBackButton];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonPress)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
}


#pragma mark-  保存事件
-(void)saveButtonPress {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (![CommonFunc checkNetworkState]) {
        [CommonFuntion showToast:@"无网络可用,加载失败" inView:self.view];
        return;
    }
    
    EditItemModel *itemName = (EditItemModel *)[self.dataSource objectAtIndex:1];
    
    if ([itemName.content isEqualToString:@""]) {
        [CommonFuntion showToast:@"姓名不能为空" inView:self.view];
        return;
    }else{
        ///验证姓名是否有效
        
    }
    
    
     EditItemModel *itemType = (EditItemModel *)[self.dataSource objectAtIndex:2];
    if ([itemType.content isEqualToString:@""]) {
        [CommonFuntion showToast:@"联系人类型不能为空" inView:self.view];
        return;
    }
    
    
    EditItemModel *itemPhone = (EditItemModel *)[self.dataSource objectAtIndex:3];
    if (![itemPhone.content isEqualToString:@""]) {
        
        if (![CommonFunc isValidatePhoneNumber:itemPhone.content]) {
            [CommonFuntion showToast:@"请输入正确的手机号" inView:self.view];
            return;
        }
        
    }
    
    EditItemModel *itemEmail = (EditItemModel *)[self.dataSource objectAtIndex:6];
    if (![itemEmail.content isEqualToString:@""]) {
       
        if (![CommonFunc isValidateEmail:itemEmail.content]) {
             [CommonFuntion showToast:@"请输入正确的邮箱" inView:self.view];
            return;
        }
        
    }
    
    ///新建联系人
    [self addNewContact];
}


#pragma mark - 初始化选择条件数据
-(void)initOptionsData{
    NSInteger count = 0;
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
            [self notifyDataSource:[NSIndexPath indexPathForRow:2 inSection:1] valueString:model.title idString:model.itmeId];
        }else{
            model.selectedFlag = @"no";
        }
        [array3 addObject:model];
    }
    [arrayLinkManType removeAllObjects];
    [arrayLinkManType addObjectsFromArray:array3];
    
    [self.tableviewAddContact reloadData];

}

#pragma mark - 根据客户类型 初始化数据  0公司客户 1个人客户
-(void)initDataWithCustomerName:(NSString *)customerName{
    
    arrayLinkManType = [[NSMutableArray alloc] init];
    self.dataSource = [[NSMutableArray alloc] init];

    EditItemModel *model;
    
    model = [[EditItemModel alloc] init];
    model.title = @"对应客户:";
    model.content = customerName;
    model.placeholder = @"";
    model.cellType = @"cellA";
    model.keyStr = @"";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"姓名:";
    model.content = @"";
    model.placeholder = @"请输入姓名(必填)";
    model.cellType = @"cellA";
    model.keyStr = @"linkmanName";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    
    model = [[EditItemModel alloc] init];
    model.itemId = @"";
    model.title = @"联系人类型:";
    model.content = @"";
    model.placeholder = @"";
    model.cellType = @"cellB";
    model.keyStr = @"linkmanCategory";
    model.keyType = @"linkmanCategory";
    [self.dataSource addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"手机:";
    model.content = @"";
    model.placeholder = @"请输入手机号码";
    model.cellType = @"cellA";
    model.keyStr = @"linkmanMobilePhone";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"固话:";
    model.content = @"";
    model.placeholder = @"请输入固话号码";
    model.cellType = @"cellA";
    model.keyStr = @"linkmanPhone";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"QQ:";
    model.content = @"";
    model.placeholder = @"请输入QQ号码";
    model.cellType = @"cellA";
    model.keyStr = @"linkmanQQ";
    model.keyType = @"";
    [self.dataSource addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"邮箱:";
    model.content = @"";
    model.placeholder = @"请输入邮箱地址";
    model.cellType = @"cellA";
    model.keyStr = @"linkmanEmail";
    model.keyType = @"";
    [self.dataSource addObject:model];

    
    NSLog(@"self.dataSource:%@",self.dataSource);
    for (int i=0; i<[self.dataSource count]; i++) {
        EditItemModel *item  = (EditItemModel*) [self.dataSource objectAtIndex:i];
        NSLog(@"%@  %@",item.title,item.cellType);
    }
}



#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewAddContact = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-64) style:UITableViewStyleGrouped];
    self.tableviewAddContact.delegate = self;
    self.tableviewAddContact.dataSource = self;
    self.tableviewAddContact.sectionFooterHeight = 0;
    
    [self.view addSubview:self.tableviewAddContact];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewAddContact setTableFooterView:v];
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}


#pragma mark - tableview


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource  count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditItemModel* item = (EditItemModel*) [self.dataSource objectAtIndex:indexPath.row];
    
    
    if ([item.cellType isEqualToString:@"cellA"]) {
        EditItemTypeCellA *cell = [tableView dequeueReusableCellWithIdentifier:@"EditItemTypeCellAIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"EditItemTypeCellA" owner:self options:nil];
            cell = (EditItemTypeCellA*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        
        ///对应客户
        if (indexPath.row == 0) {
            cell.textFieldContent.enabled = NO;
            cell.textFieldContent.textColor = [UIColor lightGrayColor];
        }else{
            cell.textFieldContent.enabled = YES;
            cell.textFieldContent.textColor = [UIColor blackColor];
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

            [weak_self showMenuByFlag:4 withIndexPath:indexPath];
        };
        [cell setCellDetail:item];
        return cell;
    }
    return nil;
}


///更新数据源
-(void)notifyDataSource:(NSIndexPath *)indexPath valueString:(NSString *)valueStr idString:(NSString *)ids{
    ///是公司客户还是个人客户
    EditItemModel *model = (EditItemModel *)[self.dataSource objectAtIndex:indexPath.row];
    model.content = valueStr;
    model.itemId = ids;
    
}


#pragma mark - 弹框
///
-(void)showMenuByFlag:(NSInteger)flag withIndexPath:(NSIndexPath *)indexPath{
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    NSArray *array = nil;
    NSString *title = @"联系人类型";
    /// 0单选  1多选
    NSInteger type = 0;
    LLcenterSheetMenuView *sheet;
    array = arrayLinkManType;
    
    if (array == nil || [array count] == 0) {
        NSLog(@"选择数据源为空");
        NSString *strMsg = @"";
        strMsg = @"联系人类型加载失败";
        [CommonFuntion showToast:strMsg inView:self.view];
        return;
    }
    sheet = [[LLcenterSheetMenuView alloc]initWithlist:array headTitle:title footBtnTitle:@"" cellType:type menuFlag:flag];
    sheet.delegate = self;
    
    [sheet showInView:nil];
}


-(void)didSelectSheetMenuIndex:(NSInteger)index menuType:(SheetMenuType)menuT menuFlag:(NSInteger)flag{
    
    NSLog(@"index:%ti",index);
    
    if (flag == 4){
        [self changeSelectedFlag:arrayLinkManType index:index];
        
        ///@"请选择类型";
        LLCenterSheetMenuModel *model = (LLCenterSheetMenuModel*)[arrayLinkManType objectAtIndex:index];
        NSLog(@"title:%@   ids:%@",model.title,model.itmeId);
        
        [self notifyDataSource:[NSIndexPath indexPathForRow:2 inSection:0] valueString:model.title idString:model.itmeId];
    }
    
    [self.tableviewAddContact reloadData];
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



#pragma mark - 请求服务器数据

-(void)getinitAddCustomerDetail{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_CUSTOMER_DETAILS_DICTIONARY_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"客户字典jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            if ([jsonResponse objectForKey:@"resultMap"]) {
                
                ///联系人类型
                if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"linkmanCategory"] != [NSNull null]) {
                    NSArray *linkmanCategory = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"linkmanCategory"];
                    NSLog(@"linkmanCategory:%@",linkmanCategory);
                    if (linkmanCategory) {
                        [arrayLinkManType addObjectsFromArray:linkmanCategory];
                    }
                }
                
                ///初始化数据
                [self initOptionsData];
                
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



#pragma mark - 新建联系人

-(void)addNewContact{
    
    ///传入：客户ID，联系人名字（必传，需要检验），联系人类型，手机，固话，QQ，邮箱
    ///传入：customerId、linkmanName、linkmanCategory、linkmanMobilePhone、linkmanPhone、linkmanQQ、linkmanEmail
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    EditItemModel *item;
    for (int i=0; i<[self.dataSource count]; i++) {
        
        item = (EditItemModel*) [self.dataSource objectAtIndex:i];
        
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
    [rDict setValue:[self.cusDetails objectForKey:@"CUSTOMER_ID"] forKey:@"customerId"];
   
     NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_SAVE_LINKMAN_INFO_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"新建联系人jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [CommonFuntion showToast:@"保存成功" inView:self.view];
            if (self.NotifyContactList) {
                self.NotifyContactList();
            }
            
            for (UIViewController *vcCD in self.navigationController.viewControllers) {
                if ([vcCD isKindOfClass:[LLCCustomerDetailViewController class]]) {
                    [self.navigationController popToViewController:vcCD animated:YES];
                }
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self addNewContact];
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
