//
//  AddNewBlackWhiteViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-16.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AddNewBlackWhiteViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "CommonFunc.h"
#import "EditItemModel.h"
#import "EditItemTypeCellA.h"
#import "LLCenterUtility.h"


@interface AddNewBlackWhiteViewController ()<UITableViewDataSource,UITableViewDelegate>{
}

@property(strong,nonatomic) TPKeyboardAvoidingTableView *tableviewAdd;
@property(strong,nonatomic) NSMutableArray *dataSource;
@end

@implementation AddNewBlackWhiteViewController

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
    
    EditItemModel *modelLinkPhone = (EditItemModel *)[self.dataSource objectAtIndex:0] ;
    if ([modelLinkPhone.content isEqualToString:@""]) {
        [CommonFuntion showToast:@"手机号码不能为空" inView:self.view];
        return;
    }
    
    if (![CommonFunc isValidatePhoneNumber:modelLinkPhone.content]) {
        [CommonFuntion showToast:@"请输入正确的手机号" inView:self.view];
        return;
    }

    [self addNewBW];
}



#pragma mark - 新建黑白名单

-(void)addNewBW{
    
    ///传入：传入：类型（黑名单还是白名单），号码（校验）
    ///传入：type，number，remark
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    EditItemModel *item;
    for (int i=0; i<[self.dataSource count]; i++) {
        item = (EditItemModel*) [self.dataSource objectAtIndex:i];
        
        if (item.keyStr && item.keyStr.length > 0) {
            [rDict setValue:item.content forKey:item.keyStr];
            NSLog(@"key: %@   value: %@",item.keyStr,item.content);
        }
    }
    [rDict setObject:[NSString stringWithFormat:@"%ti",self.indexOfBW+1] forKey:@"type"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_ADD_BLACK_AND_WHITE_LIST_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"新建黑白名单jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            [CommonFuntion showToast:@"保存成功" inView:self.view];
            if (self.NotifyBlackWhiteList) {
                self.NotifyBlackWhiteList();
            }
            [self.navigationController popViewControllerAnimated:YES];
            
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self addNewBW];
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



#pragma mark -  初始化数据
-(void)initDataSource{
    
    self.dataSource = [[NSMutableArray alloc] init];
    
    EditItemModel *model;
    model = [[EditItemModel alloc] init];

    model.title = @"手机:";
    model.content = @"";
    model.placeholder = @"请输入手机号码";
    model.cellType = @"cellA";
    model.keyStr = @"number";
    [self.dataSource addObject:model];
    
    model = [[EditItemModel alloc] init];
    model.title = @"备注:";
    model.content = @"";
    model.placeholder = @"请输入备注";
    model.cellType = @"cellA";
    model.keyStr = @"remark";
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
//            NSLog(@"index:%ti valueString:%@",indexPath.row,valueString);
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
