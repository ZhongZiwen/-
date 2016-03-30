//
//  AddTagsViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-13.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AddTagsViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "CommonFunc.h"
#import "EditItemModel.h"
#import "EditItemTypeCellA.h"
#import "LLCenterUtility.h"

@interface AddTagsViewController ()<UITableViewDataSource,UITableViewDelegate>{
}

@property(strong,nonatomic) TPKeyboardAvoidingTableView *tableviewAdd;
@property(strong,nonatomic) NSMutableArray *dataSource;

@end

@implementation AddTagsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
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
        [CommonFuntion showToast:@"标签不能为空" inView:self.view];
        return;
    }
    
    if ([CommonFunc isStringNullObject:modelTag.content]) {
        [CommonFuntion showToast:@"标签名称不能为null" inView:self.view];
        return;
    }
    
    [self addNewTag];
}



#pragma mark -  初始化数据
-(void)initDataSource{
    
    self.dataSource = [[NSMutableArray alloc] init];
    
    EditItemModel *model;
    model = [[EditItemModel alloc] init];
    
    model.title = @"标签名称:";
    model.content = @"";
    model.placeholder = @"请输入标签名称";
    model.cellType = @"cellA";
    model.keyStr = @"flagName";
    [self.dataSource addObject:model];
    
    
    NSLog(@"self.dataSource:%@",self.dataSource);
    for (int i=0; i<[self.dataSource count]; i++) {
        EditItemModel *item  = (EditItemModel*) [self.dataSource objectAtIndex:i];
        NSLog(@"%@  %@",item.title,item.cellType);
    }
}



#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewAdd = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-64) style:UITableViewStyleGrouped];
    self.tableviewAdd.delegate = self;
    self.tableviewAdd.dataSource = self;
    self.tableviewAdd.sectionFooterHeight = 0;
    
    [self.view addSubview:self.tableviewAdd];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewAdd setTableFooterView:v];
    
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
            NSLog(@"index:%ti valueString:%@",indexPath.row,valueString);
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

#pragma mark - 新增标签

-(void)addNewTag{
    
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

    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_SAVE_CUSTOMER_STATEFLAG_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"新增标签jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [CommonFuntion showToast:@"保存成功" inView:self.view];
            [self actionSuccess];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self addNewTag];
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
    if (self.NotifyTagsList) {
        self.NotifyTagsList();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
