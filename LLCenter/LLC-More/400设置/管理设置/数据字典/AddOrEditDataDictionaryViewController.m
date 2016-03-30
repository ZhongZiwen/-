//
//  AddOrEditDataDictionaryViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-19.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AddOrEditDataDictionaryViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "CommonFunc.h"
#import "EditItemModel.h"
#import "EditItemTypeCellA.h"
#import "EditItemTypeCellI.h"
#import "LLCenterUtility.h"


@interface AddOrEditDataDictionaryViewController ()<UITableViewDataSource,UITableViewDelegate>{
}

@property(strong,nonatomic) TPKeyboardAvoidingTableView *tableview;
@property(strong,nonatomic) NSMutableArray *dataSource;

@end

@implementation AddOrEditDataDictionaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if([self.actionType isEqualToString:@"add"]){
        self.title = [NSString stringWithFormat:@"新增%@",self.actionName];
    }else{
        self.title = [NSString stringWithFormat:@"编辑%@",self.actionName];
    }
    self.view.backgroundColor = COLOR_BG;
    [self addNarBar];
    [self initDataSource];
    [self initTableview];
}


#pragma mark - Nar Bar
-(void)addNarBar{
    [super customBackButton];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonPress)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
}


#pragma mark-  保存事件
-(void)saveButtonPress {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (![CommonFunc checkNetworkState]) {
        [CommonFuntion showToast:@"无网络可用,加载失败" inView:self.view];
        return;
    }
    
    
    EditItemModel *modelTag = (EditItemModel *)[self.dataSource objectAtIndex:0] ;
    if ([modelTag.content isEqualToString:@""]) {
        [CommonFuntion showToast:[NSString stringWithFormat:@"%@名称不能为空",self.actionName] inView:self.view];
        return;
        
    }
    
    
    if ([CommonFunc isStringNullObject:modelTag.content]) {
        [CommonFuntion showToast:[NSString stringWithFormat:@"%@名称不能为null",self.actionName] inView:self.view];
        return;
    }
    
    [self addOrEditDictionary];
}



#pragma mark -  初始化数据
-(void)initDataSource{
    
    self.dataSource = [[NSMutableArray alloc] init];
    
    NSString *name = @"";
    NSString *switchDefault = @"";
    ///新增
    if ([self.actionType isEqualToString:@"add"]) {
        name = @"";
        switchDefault = @"0";
    }else{
        name = [self.detail safeObjectForKey:@"name"];

        switchDefault = [self.detail safeObjectForKey:@"default"];;
        if ([switchDefault isEqualToString:@""]) {
            switchDefault = @"0";
        }
    }
    
    EditItemModel *model;
    model = [[EditItemModel alloc] init];
    
    model.title = [NSString stringWithFormat:@"%@:",self.actionName];
    model.content = name;
    model.placeholder = [NSString stringWithFormat:@"请输入%@名称",self.actionName];
    model.cellType = @"cellA";
    model.keyStr = self.paramName;
    [self.dataSource addObject:model];
    
    
    /*
    model = [[EditItemModel alloc] init];
    model.title = @"默认项:";
    model.content = switchDefault;
    model.placeholder = @"";
    model.cellType = @"cellI";
    model.keyStr = @"default";
    [self.dataSource addObject:model];
     */
    
    
    NSLog(@"self.dataSource:%@",self.dataSource);
    for (int i=0; i<[self.dataSource count]; i++) {
        EditItemModel *item  = (EditItemModel*) [self.dataSource objectAtIndex:i];
        NSLog(@"%@  %@",item.title,item.cellType);
    }
}



#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableview = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-64) style:UITableViewStyleGrouped];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.sectionFooterHeight = 0;
    
    [self.view addSubview:self.tableview];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableview setTableFooterView:v];
    
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
        
        __weak typeof(self) weak_self = self;
        cell.textValueChangedBlock = ^(NSString *valueString){
//            NSLog(@"index:%ti valueString:%@",indexPath.row,valueString);
            [weak_self notifyDataSource:indexPath valueString:valueString idString:@""];
        };
        
        [cell setCellDetail:item];
        return cell;
    }else if ([item.cellType isEqualToString:@"cellI"]) {
        EditItemTypeCellI *cell = [tableView dequeueReusableCellWithIdentifier:@"EditItemTypeCellIIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"EditItemTypeCellI" owner:self options:nil];
            cell = (EditItemTypeCellI*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        
        __weak typeof(self) weak_self = self;
        cell.SwitchDefaultBlock = ^(NSString *valueString){
            NSLog(@"valueString:%@",valueString);
            [weak_self notifyDataSource:indexPath valueString:valueString idString:@""];
        };
        
        [cell setCellDetail:item];
        return cell;
    }
    return nil;
}


///更新数据源
-(void)notifyDataSource:(NSIndexPath *)indexPath valueString:(NSString *)valueStr idString:(NSString *)ids{
    
    EditItemModel *model = (EditItemModel *)[self.dataSource objectAtIndex:indexPath.row];
    model.content = valueStr;
    model.itemId = ids;
}


#pragma mark - 网络请求

#pragma mark - 新增、编辑字典信息

-(void)addOrEditDictionary{
    
    ///传入：flagName
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    EditItemModel *item;
    for (int i=0; i<[self.dataSource count]; i++) {
        item = (EditItemModel*) [self.dataSource objectAtIndex:i];
        if (item.keyStr && item.keyStr.length > 0) {
            [rDict setValue:item.content forKey:item.keyStr];
        }
    }
   
    [rDict setValue:@"0" forKey:@"default"];
    ///编辑
    if ([self.actionType isEqualToString:@"edit"]) {
        [rDict setValue:[self.detail objectForKey:@"id"] forKey:self.paramId];
    }
    
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,self.urlName] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"新增、编辑字典信息jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [CommonFuntion showToast:@"保存成功" inView:self.view];
            [self actionSuccess];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self addOrEditDictionary];
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


#pragma mark - 返回到前一页
-(void)actionSuccess{
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(gobackView)
                                   userInfo:nil repeats:NO];
}

-(void)gobackView{
    if (self.NotifyDataDictionaryList) {
        self.NotifyDataDictionaryList();
    }
    [self.navigationController popViewControllerAnimated:YES];
}


@end
