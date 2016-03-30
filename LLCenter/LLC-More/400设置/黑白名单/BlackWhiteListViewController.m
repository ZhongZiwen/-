//
//  BlackWhiteListViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-11.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "BlackWhiteListViewController.h"
#import "NavDropView.h"
#import "BlackWhiteCell.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"
#import "CommonNoDataView.h"
#import "AddNewBlackWhiteViewController.h"
#import "CustomNarTitleView.h"
#import "SmartConditionModel.h"

@interface BlackWhiteListViewController ()<UITableViewDataSource,UITableViewDelegate,SWTableViewCellDelegate>{
    
    ///删除时参数id
    NSString *curDeleteXH;
}

@property (nonatomic, assign) NSInteger curIndex;

@property(strong,nonatomic) UITableView *tableviewContact;
@property(strong,nonatomic) NSMutableArray *arrayContact;


@property (nonatomic, strong) CommonNoDataView *commonNoDataView;

@property (nonatomic, strong) CustomNarTitleView *customTitleView;

@end

@implementation BlackWhiteListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super customBackButton];
    self.view.backgroundColor = COLOR_BG;
    _curIndex = 0;
    [self addNarMenu];
    [self addNarBar];
    [self initData];
//    [self addTestData];
    [self initTableview];
    [self findBlackAndWhiteList];
}


#pragma mark - Nar Bar
-(void)addNarBar{
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBarButtonAction)];
    [self.navigationItem setRightBarButtonItem:addButton];
}

-(void)addBarButtonAction{
    AddNewBlackWhiteViewController *controller = [[AddNewBlackWhiteViewController alloc] init];
    __weak typeof(self) weak_self = self;
    controller.NotifyBlackWhiteList = ^(){
        [weak_self findBlackAndWhiteList];
    };
    if (_curIndex == 0) {
        controller.title = @"新建黑名单";
    }else{
        controller.title = @"新建白名单";
    }
    controller.indexOfBW = _curIndex;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Title 菜单
-(void)addNarMenu{

    NSMutableArray *arraySour = [[NSMutableArray alloc] init];
    SmartConditionModel *model1 = [[SmartConditionModel alloc] init];
    model1.name = @"黑名单";
    [arraySour addObject:model1];
    
    SmartConditionModel *model2 = [[SmartConditionModel alloc] init];
    model2.name = @"白名单";
    [arraySour addObject:model2];

    _curIndex = 0;
    __weak typeof(self) weak_self = self;
    self.customTitleView.sourceArray = arraySour;
    self.customTitleView.index = 0;
    self.customTitleView.valueBlock = ^(NSInteger index) {
        weak_self.curIndex = index;
        [weak_self findBlackAndWhiteList];
    };
    self.navigationItem.titleView = self.customTitleView;
}


- (void)customDownMenuWithType:(TableViewCellType)type andSource:(NSArray *)sourceArray andDefaultIndex:(NSInteger)index andBlock:(void (^)(NSInteger))block {
    
    NavDropView *dropView = [[NavDropView alloc] initWithFrame:CGRectMake(0, 0, 200, 30) andType:type andSource:sourceArray andDefaultIndex:index andController:self];
    dropView.menuIndexClick = block;
    self.navigationItem.titleView = dropView;
    self.navigationItem.titleView.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
}




- (CustomNarTitleView*)customTitleView {
    if (!_customTitleView) {
        _customTitleView = [[CustomNarTitleView alloc] init];
//        _customTitleView.defalutTitleString = @"黑名单";
        _customTitleView.superViewController = self;
    }
    return _customTitleView;
}


#pragma mark - 初始化数据
-(void)initData{
    self.arrayContact = [[NSMutableArray alloc] init];
}


-(void)addTestData{
    NSMutableDictionary *item;
    for (int i=0; i<10; i++) {
        item = [[NSMutableDictionary alloc] init];
        [item setObject:@"13918537484" forKey:@"phone"];
        [item setObject:@"上海" forKey:@"address"];
        [item setObject:@"备注信息..." forKey:@"remark"];
        [self.arrayContact addObject:item];
    }
}

#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewContact = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-64) style:UITableViewStylePlain];
    [self.tableviewContact registerNib:[UINib nibWithNibName:@"BlackWhiteCell" bundle:nil] forCellReuseIdentifier:@"BlackWhiteCellIdentify"];
    self.tableviewContact.delegate = self;
    self.tableviewContact.dataSource = self;
    self.tableviewContact.sectionFooterHeight = 0;
    [self.view addSubview:self.tableviewContact];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewContact setTableFooterView:v];
}



#pragma mark - tableview delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.arrayContact) {
        return [self.arrayContact count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"BlackWhiteCellIdentify";
    BlackWhiteCell *cell = (BlackWhiteCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"BlackWhiteCell" owner:self options:nil];
        cell = (BlackWhiteCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    cell.delegate = self;
    
    [cell setLeftAndRightBtn];
    [cell setCellDetails:[self.arrayContact objectAtIndex:indexPath.row]];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}



#pragma mark - SWTableViewDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            //        NSLog(@"utility buttons closed");
            break;
        case 1:
            //        NSLog(@"left utility buttons open");
            break;
        case 2:
            //        NSLog(@"right utility buttons open");
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            //        NSLog(@"left button 0 was pressed");
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [self.tableviewContact indexPathForCell:cell];
    NSLog(@"click index:%ld",indexPath.row);
    NSDictionary *item = [self.arrayContact objectAtIndex:indexPath.row];
    
    switch (index) {
        case 0:
        {
            curDeleteXH = @"";
            if ([item safeObjectForKey:@"XH"]) {
                curDeleteXH = [item safeObjectForKey:@"XH"];
            }
            NSLog(@"1删除");
            NSString *title = @"";
            if (_curIndex == 0) {
                title = @"是否删除当前黑名单";
            }else{
                title = @"是否删除当前白名单";
            }
            UIAlertView *alertDelete = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertDelete.tag = 101;
            [alertDelete show];
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        
        default:
            break;
    }
}


- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return NO;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}


#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            NSLog(@"删除2");
            //删除
            
            if (![CommonFunc checkNetworkState]) {
                [CommonFuntion showToast:@"无网络可用,加载失败" inView:self.view];
                return;
            }
            [self deleteBlackAndWhiteList];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 请求服务器数据

-(void)findBlackAndWhiteList{
    [self.arrayContact removeAllObjects];
    [self clearViewNoData];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rDict setObject:[NSString stringWithFormat:@"%ti",_curIndex+1] forKey:@"type"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    
    NSLog(@"rParam:%@",rParam);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_BLACK_AND_WHITE_LIST_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"黑白名单jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"] != [NSNull null]) {
                //
                NSArray *arr = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"];
                if (arr && [arr count] > 0) {
                    [self.arrayContact addObjectsFromArray:arr];
                }
                
            }
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self findBlackAndWhiteList];
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
        [self.tableviewContact reloadData];
        [self notifyNoDataView];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        [self.tableviewContact reloadData];
        [self notifyNoDataView];
    }];
}

#pragma mark - 删除黑白名单中单个号码接口
-(void)deleteBlackAndWhiteList{

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    ///传入：id
    [rDict setValue:curDeleteXH forKey:@"id"];
    [rDict setObject:[NSString stringWithFormat:@"%ti",_curIndex+1] forKey:@"type"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    
    NSLog(@"rParam:%@",rParam);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_DELETE_BLACK_AND_WHITE_LIST_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"删除黑白名jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            [CommonFuntion showToast:@"删除成功" inView:self.view];
            [self findBlackAndWhiteList];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self deleteBlackAndWhiteList];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"删除失败";
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
    if (self.arrayContact && [self.arrayContact count] > 0) {
         [self clearViewNoData];
    }else{
        if (_curIndex == 0) {
            [self setViewNoData:@"暂无黑名单"];
        }else{
            [self setViewNoData:@"暂无白名单"];
        }
    }
}

-(void)setViewNoData:(NSString *)title{
    if (self.commonNoDataView == nil) {
        self.commonNoDataView = [CommonFunc commonNoDataViewIcon:@"list_empty.png" Title:title optionBtnTitle:@""];
    }
    
    [self.tableviewContact addSubview:self.commonNoDataView];
}

-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
        self.commonNoDataView = nil;
    }
}


@end
