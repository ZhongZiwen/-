//
//  SelectAreaTypeViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-27.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "SelectAreaTypeViewController.h"
#import "SelectAreaTypeCell.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"
#import "CommonStaticVar.h"
#import "AreaTypeViewController.h"


@interface SelectAreaTypeViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSString *curSelectedAreaType;
    
    ///地区策略
    NSDictionary *areaStrategyData;
    ///编辑之后的地区策略
    NSMutableDictionary *areaStrategyDataNew;
    ///未编辑之前的地区类型
    NSString *areaModleOld;
}

@property(strong,nonatomic) UITableView *tableview;
@property(strong,nonatomic) NSMutableArray *dataSource;

@end

@implementation SelectAreaTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"地区类型";
    [super customBackButton];
    [self addNavBar];
    self.view.backgroundColor = COLOR_BG;
    
    [self initData];
    [self initTableview];
    
    ///获取座席地区策略
    if ([self.navigationOrSit isEqualToString:@"sit"]) {
        [self getSitAreaStrategy];
    }else{
        [self notifyDataSourceByDefaultData];
    }
    
    [self.tableview reloadData];
}


#pragma mark - Nav Bar
-(void)addNavBar{
    ///新建导航页面
    if ([self.viewFromFlag isEqualToString:@"addnavi"]) {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(okButtonPress)];
        self.navigationItem.rightBarButtonItem = rightButton;
    }else{
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonPress)];
        self.navigationItem.rightBarButtonItem = rightButton;
    }
}

#pragma mark-  完成事件
-(void)okButtonPress {
    [self getSelectedAreaType];
}

#pragma mark-  保存事件
-(void)saveButtonPress {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    if (![CommonFunc checkNetworkState]) {
        [CommonFuntion showToast:@"无网络可用,加载失败" inView:self.view];
        return;
    }
    
    ///全部
    if ([curSelectedAreaType isEqualToString:@"1"]) {
        
    }else{
        NSString *areaCode = @"";
        NSDictionary *strategy = nil;;
        
        if (areaStrategyDataNew && [areaStrategyDataNew objectForKey:@"areaCode"]) {
            strategy = areaStrategyDataNew;
        }else{
            if (![areaModleOld isEqualToString:@"1"]) {
                strategy = self.detail;;
            }
        }
        
        
        if (strategy) {
            areaCode = [[strategy safeObjectForKey:@"areaCode"]stringByReplacingOccurrencesOfString:@";" withString:@","];
        }
       
        ///没选择地区
        if (!areaCode || [areaCode isEqualToString:@""] ) {
            [CommonFuntion showToast:@"请选择地区" inView:self.view];
            return;
        }
    }
    
    [self editSitAreaType];
}

#pragma mark - 初始化数据
-(void)initData{
    areaModleOld = @"";
    areaStrategyDataNew = [[NSMutableDictionary alloc] init];
    self.dataSource = [[NSMutableArray alloc] init];
    
    ///从座席信息获取到当前选择的方式
    
    NSMutableDictionary *item1 = [[NSMutableDictionary alloc] init];
    [item1 setObject:@"全部地区" forKey:@"title"];
    [item1 setObject:@"" forKey:@"content"];
    [item1 setObject:@(NO) forKey:@"checked"];
    
    
    NSMutableDictionary *item2 = [[NSMutableDictionary alloc] init];
    [item2 setObject:@"自定义地区" forKey:@"title"];
    [item2 setObject:@"" forKey:@"content"];
    [item2 setObject:@(NO) forKey:@"checked"];
    
    
    [self.dataSource addObject:item1];
    [self.dataSource addObject:item2];
}

#pragma mark - 刷新数据
///
-(void)notifyDataSourceByDefaultData{
    /*
     {
     areaCode = 1;
     areaName = "<null>";
     }
     
     NSString *areaName = @"";
     ///全部地区
     if ([[navigationDic safeObjectForKey:@"areaCode"] isEqualToString:@"1"]) {
     areaName = @"全部地区";
     }else{
     areaName = [navigationDic safeObjectForKey:@"areaName"];
     }
     */
    
    ///座席
    if ([self.navigationOrSit isEqualToString:@"sit"]) {
        areaModleOld = [areaStrategyData safeObjectForKey:@"areaCode"];
        NSString *content = @"";
        NSString *model = [areaStrategyData safeObjectForKey:@"areaCode"];
        ///全部1
        if ([model integerValue] == 1 ) {
            content = @"";
        }else {
            ///自定义
            content = @"";
        }
        
        [self notifyDataSoureByAreaModel:model andContent:content];
        
    }else{
        ///导航
        areaModleOld = [self.detail safeObjectForKey:@"areaCode"];
        NSString *content = @"";
        NSString *model = [self.detail safeObjectForKey:@"areaCode"];
        ///全部1
        if ([model integerValue] == 1 ) {
            content = @"";
        }else {
            ///自定义
            content = [self.detail safeObjectForKey:@"areaName"];;
        }
        
        [self notifyDataSoureByAreaModel:model andContent:content];
    }
    
    
}



///根据地区类型 和 content  刷新数据
-(void)notifyDataSoureByAreaModel:(NSString *) model andContent:(NSString *)content{
    NSLog(@"notifyDataSoureByAreaModel:%@  content:%@",model,content);
    NSDictionary *item;
    NSMutableDictionary *mutableItem;
    ///座席
    if ([self.navigationOrSit isEqualToString:@"sit"]) {
        
        
        
    }else{
        
    }
    
    ///全部
    if ([model integerValue] == 1) {
        item = [self.dataSource objectAtIndex:0];
        mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
        [mutableItem setObject:@(YES) forKey:@"checked"];
        [mutableItem setObject:content forKey:@"content"];
        [self.dataSource replaceObjectAtIndex:0 withObject:mutableItem];
        
        curSelectedAreaType = @"1";
    } else {
        /// 自定义
        item = [self.dataSource objectAtIndex:1];
        mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
        [mutableItem setObject:@(YES) forKey:@"checked"];
        [mutableItem setObject:content forKey:@"content"];
        [self.dataSource replaceObjectAtIndex:1 withObject:mutableItem];
        
        curSelectedAreaType = @"2";
    }
    
    [self.tableview reloadData];
}



#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT-64) style:UITableViewStyleGrouped];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.sectionFooterHeight = 0;
    [self.view addSubview:self.tableview];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableview setTableFooterView:v];
    ///需提示地区策略范围
    if ([self.flagOfNeedJudge isEqualToString:@"yes"]) {
        self.tableview.tableHeaderView = [self creatHeadViewForTableView];
    }
}

#pragma mark - 创建HeadView
-(UIView *)creatHeadViewForTableView{
    UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 40)];
    headview.backgroundColor = COLOR_BG;
    
    
    UILabel *labelNotice = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, DEVICE_BOUNDS_WIDTH-30, 20)];
    labelNotice.textColor = [UIColor grayColor];
    labelNotice.font = [UIFont systemFontOfSize:13.0];
    labelNotice.text = @"地区策略设置请在分组地区范围内,超出不会生效";
    
    [headview addSubview:labelNotice];
    
    return headview;
}


#pragma mark - tableview delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    ///需提示地区策略范围
    if ([self.flagOfNeedJudge isEqualToString:@"yes"]) {
        return 1;
    }
    return 20;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.dataSource) {
        return [self.dataSource count];
    }
    return 0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ///座席
    SelectAreaTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectAreaTypeCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SelectAreaTypeCell" owner:self options:nil];
        cell = (SelectAreaTypeCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
        [cell setCellFrame:1];
    }
    NSDictionary *item = [self.dataSource objectAtIndex:indexPath.row];
    
    [cell setCellDetail:item];
    
    if (indexPath.row == 0) {
        cell.imgArrow.hidden = YES;
    }else{
        cell.imgArrow.hidden = NO;
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self updateDataSource:indexPath.row];
    if (indexPath.row == 0) {
        
    }
    
    if(indexPath.row == 1){
        [self gotoCustomerAreaTypeView];
    }
}


///跳转到地区页面
-(void)gotoCustomerAreaTypeView{
    AreaTypeViewController *controller = [[AreaTypeViewController alloc] init];
    controller.navigationOrSitId = self.navigationId;
    controller.navigationOrSit = self.navigationOrSit;
    controller.flagOfNeedJudge = self.flagOfNeedJudge;
    
    if ([self.navigationOrSit isEqualToString:@"sit"]) {
        controller.areaStrategyNavDic = self.areaStrategyNavDic;
        if (areaStrategyDataNew && [areaStrategyDataNew objectForKey:@"areaCode"]) {
            controller.areaStrategyData = areaStrategyDataNew;
        }else{
            controller.areaStrategyData = areaStrategyData;
        }
    }else{
        if (areaStrategyDataNew && [areaStrategyDataNew objectForKey:@"areaCode"]) {
            controller.areaStrategyData = areaStrategyDataNew;
        }else{
            controller.areaStrategyData = self.detail;
        }
    }
    
    __weak typeof(self) weak_self = self;
    controller.SelectAreaDoneBlock = ^(NSString *areaCode,NSString *areaName){
        NSLog(@"SelectAreaDoneBlock areaName:%@",areaName);
        [areaStrategyDataNew setObject:areaCode forKey:@"areaCode"];
        [areaStrategyDataNew setObject:areaName forKey:@"areaName"];
        NSLog(@"SelectAreaDoneBlock areaStrategyDataNew:%@",areaStrategyDataNew);
        ///自定义地区
        [weak_self notifyDataSoureByAreaModel:areaCode andContent:areaName];
    };
    
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - 更新UI 修改数据源
-(void)updateDataSource:(NSInteger)index{
    BOOL isRequest = FALSE;
    NSDictionary *item;
    NSMutableDictionary *mutableItem;
    item = [self.dataSource objectAtIndex:index];
    if (index == 0) {
        if (![[item objectForKey:@"checked"] boolValue]) {
            mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
            [mutableItem setObject:@(YES) forKey:@"checked"];
            [self.dataSource replaceObjectAtIndex:0 withObject:mutableItem];
        }
        
        item = [self.dataSource objectAtIndex:1];
        mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
        [mutableItem setObject:@(NO) forKey:@"checked"];
        [self.dataSource replaceObjectAtIndex:1 withObject:mutableItem];
        
       curSelectedAreaType = @"1";
        
    }else{
        if (![[item objectForKey:@"checked"] boolValue]) {
            mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
            [mutableItem setObject:@(YES) forKey:@"checked"];
            [self.dataSource replaceObjectAtIndex:1 withObject:mutableItem];
        }
        
        item = [self.dataSource objectAtIndex:0];
        mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
        [mutableItem setObject:@(NO) forKey:@"checked"];
        [self.dataSource replaceObjectAtIndex:0 withObject:mutableItem];
        
        curSelectedAreaType = @"2";
    }
    
    [self.tableview reloadData];

}



#pragma mark - 请求失败时  还原到初始数据
-(void)setSelectedToDefault{
    [self.dataSource removeAllObjects];
    
    ///从座席信息获取到当前选择的方式
    
    NSMutableDictionary *item1 = [[NSMutableDictionary alloc] init];
    [item1 setObject:@"全部地区" forKey:@"title"];
    [item1 setObject:@(NO) forKey:@"checked"];
    
    
    NSMutableDictionary *item2 = [[NSMutableDictionary alloc] init];
    [item2 setObject:@"自定义地区" forKey:@"title"];
    [item2 setObject:@(NO) forKey:@"checked"];
    
    
    [self.dataSource addObject:item1];
    [self.dataSource addObject:item2];
}



#pragma mark - 网络请求


#pragma mark 获取座席地区策略
-(void)getSitAreaStrategy{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rDict setValue:self.navigationId forKey:@"navigationId"];
    [rDict setValue:[self.detail safeObjectForKey:@"SITID"] forKey:@"sitId"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    
    NSLog(@"rParam:%@",rParam);
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_SEAT_AREA_STRATEGY_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"地区策略jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            if ([jsonResponse objectForKey:@"resultMap"]) {
                areaStrategyData = [jsonResponse objectForKey:@"resultMap"];
                [self notifyDataSourceByDefaultData];
            }else{
                NSLog(@"data------>:<null>");
                [CommonFuntion showToast:@"加载异常" inView:self.view];
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getSitAreaStrategy];
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


#pragma mark - 编辑地区策略
-(void)editSitAreaType{
    /*
     sitId
     sitAreaType
     sitAreaCode
     
     
     navigationId
     navigationAreaType
     navigationAreaCode
     navigationAreaName
     */
    
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    NSString *urlString = @"";
    ///导航
    if ([self.navigationOrSit isEqualToString:@"navigation"]) {
        urlString = LLC_EDIT_NAVIGATION_AREA_ACTION;
        
        [rDict setValue:self.navigationId forKey:@"navigationId"];
        
        
        
        
        NSString *areaCode = @"";
        NSString *areaName = @"";
        ///全部
        if ([curSelectedAreaType isEqualToString:@"1"]) {
            [rDict setValue:@"1" forKey:@"navigationAreaType"];
        }else{
            [rDict setValue:@"0" forKey:@"navigationAreaType"];
            NSDictionary *strategy = self.detail;
            if (areaStrategyDataNew && [areaStrategyDataNew objectForKey:@"areaCode"]) {
                strategy = areaStrategyDataNew;
            }
            areaCode = [[strategy safeObjectForKey:@"areaCode"]stringByReplacingOccurrencesOfString:@";" withString:@","];
            areaName = [strategy safeObjectForKey:@"areaName"];
        }
        [rDict setValue:areaCode forKey:@"navigationAreaCode"];
        ///导航地区策略的名称
        [rDict setValue:areaName forKey:@"navigationAreaName"];
        
    }else{
        ///座席
        urlString = LLC_EDIT_NAVIGATION_SIT_AREA_ACTION;
        [rDict setValue:self.navigationId forKey:@"navigationId"];
        [rDict setValue:[self.detail safeObjectForKey:@"SITID"] forKey:@"sitId"];
        [rDict setValue:curSelectedAreaType forKey:@"sitAreaType"];
        
        NSString *areaCode = @"";
        ///全部
        if ([curSelectedAreaType isEqualToString:@"1"]) {
            
        }else{
            NSDictionary *strategy = areaStrategyData;
            if (areaStrategyDataNew && [areaStrategyDataNew objectForKey:@"areaCode"]) {
                strategy = areaStrategyDataNew;
            }
            areaCode = [[strategy safeObjectForKey:@"areaCode"]stringByReplacingOccurrencesOfString:@";" withString:@","];
        }
        [rDict setValue:areaCode forKey:@"sitAreaCode"];
    }
    
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,urlString] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"地区策略jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [CommonFuntion showToast:@"保存成功" inView:self.view];
            [self actionSuccess];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self editSitAreaType];
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


#pragma mark - 新建导航时地区类型
-(void)getSelectedAreaType{
    NSString *areaTypeShow = @"";
    NSMutableDictionary *newDetail = [[NSMutableDictionary alloc] initWithDictionary:self.detail];
    NSMutableDictionary *dicAreaType = [NSMutableDictionary dictionaryWithDictionary:nil];
    

    NSString *areaCode = @"";
    NSString *areaName = @"";
    
    
    ///全部
    if ([curSelectedAreaType isEqualToString:@"1"]) {
        [dicAreaType setValue:@"1" forKey:@"navigationAreaType"];
        areaTypeShow = @"全部地区";
        areaCode = @"1";
    }else{
        [dicAreaType setValue:@"0" forKey:@"navigationAreaType"];
        NSDictionary *strategy = self.detail;
        if (areaStrategyDataNew && [areaStrategyDataNew objectForKey:@"areaCode"]) {
            strategy = areaStrategyDataNew;
        }
        areaCode = [[strategy safeObjectForKey:@"areaCode"]stringByReplacingOccurrencesOfString:@";" withString:@","];
        areaName = [strategy safeObjectForKey:@"areaName"];
        
        areaTypeShow =areaName;
    }
    [dicAreaType setValue:areaCode forKey:@"navigationAreaCode"];
    ///导航地区策略的名称
    [dicAreaType setValue:areaName forKey:@"navigationAreaName"];
    
    [newDetail setValue:areaName forKey:@"areaName"];
    [newDetail setValue:areaCode forKey:@"areaCode"];
    
    NSLog(@"areaTypeShow:%@",areaTypeShow);
    NSLog(@"dicAreaType:%@",dicAreaType);
    NSLog(@"newDetail:%@",newDetail);
    
    if (self.AreaTypeAddNaviBlock) {
        self.AreaTypeAddNaviBlock(areaTypeShow,newDetail,dicAreaType);
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - 返回到前一页
-(void)actionSuccess{
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(gobackView)
                                   userInfo:nil repeats:NO];
}

-(void)gobackView{
    
//    if (self.NotifyNavigationSitList) {
//        self.NotifyNavigationSitList();
//    }
    
    
    if ([self.navigationOrSit isEqualToString:@"sit"]) {
        
    }else{
        
        NSString *infos = @"";
        
        ///节全部
        if ([curSelectedAreaType isEqualToString:@"1"]) {
            infos = @"全部地区";
        }else {
            infos = @"";
            ///自定义地区
            if (areaStrategyDataNew && [areaStrategyDataNew objectForKey:@"areaCode"]) {
                infos = [areaStrategyDataNew objectForKey:@"areaName"];
            }else{
                infos = [self.detail objectForKey:@"areaName"];
            }
        }
        ///刷新  获取到文本信息
        if (self.AreaTypeBlock) {
            self.AreaTypeBlock(infos);
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
