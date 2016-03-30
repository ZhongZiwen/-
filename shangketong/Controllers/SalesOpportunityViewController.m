//
//  SalesOpportunityViewController.m
//  shangketong
//  CRM - 销售机会
//  Created by sungoin-zjp on 15-6-19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SalesOpportunityViewController.h"
#import <MBProgressHUD.h>
#import "AFNHttp.h"
#import "CommonFuntion.h"
#import "CommonConstant.h"
#import "SaleOpportunityGroupCell.h"
#import "SaleOpportunityCell.h"
#import "SearchViewController_zjp.h"
#import "SaleOpportunityActivityIndicatorCell.h"
#import "CommonDetailViewController.h"
#import "SalesOpportunityNewViewController.h"
#import "TypeActionSheet.h"
#import "TypeModel.h"

@interface SalesOpportunityViewController ()<UITableViewDataSource,UITableViewDelegate,SWTableViewCellDelegate>{
    UIActivityIndicatorView *act;
    
    ///用来标记不同的cell
    NSString *typeCell;
    ///单位 （元）
    NSString *currencyUnit;
}

@property (nonatomic, assign) NSInteger curIndex;
@end

@implementation SalesOpportunityViewController

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = VIEW_BG_COLOR;
    [self addNarBtn];
    [self initTableviewAndDate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self addTestData];
    [self.tableviewSaleOpportunity reloadData];
    
//    [self addActivityIndicatorView];
}


#pragma mark - add nar btn
-(void)addNarBtn{
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchItemPress)];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItemPress)];
    self.navigationItem.rightBarButtonItems = @[addItem, searchItem];
}

- (void)searchItemPress
{
    SearchViewController_zjp *controller = [[SearchViewController_zjp alloc] init];
    controller.typeFromView = @"SalesOpportunityViewController";
    controller.typeSearchStatus = @"default";
    controller.typeGoSearchResult = @"yes";
    [self.navigationController pushViewController:controller animated:YES];
}


- (void)addItemPress {
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP, kNetPath_SaleChance_Types] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@"销售机会类型 = %@", responseObj);
        if ([[responseObj objectForKey:@"status"] integerValue])   // 加载失败
            return;

        NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *tempDict in responseObj[@"saleChanceTypes"]) {
            TypeModel *item = [NSObject objectOfClass:@"TypeModel" fromJSON:tempDict];
            [array addObject:item];
        }
        
        TypeActionSheet *actionSheet = [[TypeActionSheet alloc] initWithTitle:@"选择销售机会类型"];
        actionSheet.sourceArray = array;
        actionSheet.valueBlock = ^(TypeModel *item) {
            SalesOpportunityNewViewController *newController = [[SalesOpportunityNewViewController alloc] init];
            newController.title = @"创建销售机会";
            newController.typeId = item.id;
            [self.navigationController pushViewController:newController animated:YES];
        };
        [actionSheet show];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        NSLog(@"error:%@",error);
    }];
}

#pragma mark - 初始化数据
-(void)initData{
    self.isOpen = NO;
    currencyUnit = @"";
    typeCell = @"sub";
    self.arraySaleOpportunity = [[NSMutableArray alloc] init];
}

#pragma mark - 测试数据
-(void)addTestData{
    id jsondata = [CommonFuntion readJsonFile:@"sale-opportunity-group-data"];
    
    NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"stageMoney"];
    [self.arraySaleOpportunity addObjectsFromArray:array];
    
    
    currencyUnit = [[jsondata objectForKey:@"body"] objectForKey:@"currencyUnit"];
    
    
    ///数据组装
    NSInteger count = 0;
    if (self.arraySaleOpportunity) {
        count = [self.arraySaleOpportunity count];
    }
    for (int i=0; i<count; i++) {
        NSDictionary *itemOld =[self.arraySaleOpportunity objectAtIndex:i];
        NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:itemOld];
        ///默认为空数组
        [mutableItemNew setObject:[[NSMutableArray alloc] init] forKey:@"opportunities"];
        ///添加标记变量-用来区分加载cell  默认为nodata
        [mutableItemNew setObject:@"nodata" forKey:@"flag"];
        ///添加标记  -- 未展开
        [mutableItemNew setValue:@(NO) forKey:@"open"];
        //修改数据
        [self.arraySaleOpportunity setObject: mutableItemNew atIndexedSubscript:i];
    }
    NSLog(@"self.arraySaleOpportunity:%@",self.arraySaleOpportunity);
}

///修改标记变量 表示loading
-(void)modifyDataForLoading:(NSInteger)index{
    
    NSDictionary *itemOld =[self.arraySaleOpportunity objectAtIndex:index];
    NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:itemOld];
    [mutableItemNew setObject:[NSArray arrayWithObjects:@"1", nil] forKey:@"opportunities"];
    ///添加标记变量-用来区分加载cell  加载中
    [mutableItemNew setObject:@"loading" forKey:@"flag"];
    [mutableItemNew setValue:@(YES) forKey:@"open"];
    //修改数据
    [self.arraySaleOpportunity setObject: mutableItemNew atIndexedSubscript:index];
}


-(void)modifyData:(NSInteger)index{
    ///测试数据
    id jsondata = [CommonFuntion readJsonFile:@"sale-opportunity-data"];
    NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"opportunities"];
    
    ///分组下的数据
    NSDictionary *itemOld =[self.arraySaleOpportunity objectAtIndex:index];
    NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:itemOld];
    [mutableItemNew setObject:array forKey:@"opportunities"];
    ///添加标记变量-用来区分加载cell  正常的subview cell
    [mutableItemNew setObject:@"subcell" forKey:@"flag"];
    [mutableItemNew setValue:@(YES) forKey:@"open"];
    //修改数据
    [self.arraySaleOpportunity setObject: mutableItemNew atIndexedSubscript:index];
    typeCell = @"subcell";
}

///从服务器端获取数据 然后做UI刷新
-(void)getDataFromServer{
    [NSTimer scheduledTimerWithTimeInterval:3.0
                                     target:self
                                   selector:@selector(notifyUIByServiceData)
                                   userInfo:nil repeats:NO];
}


///根据服务器端返回数据 做UI刷新
-(void)notifyUIByServiceData{
    self.tableviewSaleOpportunity.userInteractionEnabled = YES;
    ///更新数据
    [self modifyData:self.selectedIndex];
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:self.selectedIndex];
    [self.tableviewSaleOpportunity reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
}



#pragma mark - 初始化tableview
-(void)initTableviewAndDate{
    self.tableviewSaleOpportunity = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.tableviewSaleOpportunity registerNib:[UINib nibWithNibName:@"SaleOpportunityCell" bundle:nil] forCellReuseIdentifier:@"SaleOpportunityCellIdentify"];
    self.tableviewSaleOpportunity.delegate = self;
    self.tableviewSaleOpportunity.dataSource = self;
    self.tableviewSaleOpportunity.sectionFooterHeight = 0;
    self.isOpen = NO;
    [self.view addSubview:self.tableviewSaleOpportunity];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewSaleOpportunity setTableFooterView:v];
}


#pragma mark - tableview delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 49)];
    headview.backgroundColor = [UIColor whiteColor];
    headview.tag = section;
    //    [headview addLineUp:NO andDown:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewTap:)];
    [headview addGestureRecognizer:tap];
    
    ///底部分割线
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(15, 49, kScreen_Width-15, 1)];
    line.image = [UIImage imageNamed:@"line.png"];
    [headview addSubview:line];
    
    ///title
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 49)];
    labelTitle.font = [UIFont systemFontOfSize:15.0];
    labelTitle.textAlignment = NSTextAlignmentLeft;
    labelTitle.text = [self getGroupName:section];
    [headview addSubview:labelTitle];
    
    
    UILabel *labelMoney = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width-155, 0, 120, 49)];
    labelMoney.font = [UIFont systemFontOfSize:12.0];
    labelMoney.textAlignment = NSTextAlignmentRight;
    labelMoney.text = [self getStagesMoney:section];
    [headview addSubview:labelMoney];
    
    
    
    ///icon
    UIImageView *icon = [[UIImageView alloc] init];
    icon.frame = CGRectMake(kScreen_Width-30, 17, 15, 15);
    
    NSDictionary *dict = [self.arraySaleOpportunity objectAtIndex:headview.tag];
    BOOL isOpen = [[dict objectForKey:@"open"] boolValue];
    if (isOpen) {
        icon.image = [UIImage imageNamed:@"filter_slider_stage_select.png"];
    }else{
        icon.image = [UIImage imageNamed:@"filter_slider_stage_normal.png"];
    }
    
    icon.tag = 1001+section;
    [headview addSubview:icon];
    
    
    return headview;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableviewSaleOpportunity) {
        if (self.arraySaleOpportunity) {
            return [self.arraySaleOpportunity count];
        }
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableviewSaleOpportunity) {
        NSDictionary *dict = [self.arraySaleOpportunity objectAtIndex:section];
        if ([[dict objectForKey:@"open"] boolValue]) {
            return [[dict objectForKey:@"opportunities"] count];
        }else {
            return 0;
        }
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableviewSaleOpportunity) {
        if ([typeCell isEqualToString:@"actIndicator"]) {
            SaleOpportunityActivityIndicatorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SaleOpportunityActivityIndicatorCellIdentify"];
            if (!cell)
            {
                NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SaleOpportunityActivityIndicatorCell" owner:self options:nil];
                cell = (SaleOpportunityActivityIndicatorCell*)[array objectAtIndex:0];
                [cell awakeFromNib];
            }
            [cell setCellFrame];
            return cell;
        }else{
            SaleOpportunityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SaleOpportunityCellIdentify"];
            if (!cell)
            {
                NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SaleOpportunityCell" owner:self options:nil];
                cell = (SaleOpportunityCell*)[array objectAtIndex:0];
                [cell awakeFromNib];
            }
            cell.delegate = self;
            
            [cell setCellDetails:[[[self.arraySaleOpportunity objectAtIndex:indexPath.section] objectForKey:@"opportunities"] objectAtIndex:indexPath.row] currencyUnit:currencyUnit index:indexPath];
            [cell setLeftAndRightBtn:[[[self.arraySaleOpportunity objectAtIndex:indexPath.section] objectForKey:@"opportunities"] objectAtIndex:indexPath.row]];
            
            return cell;
        }
    }
    return nil;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableviewSaleOpportunity) {
        
        NSLog(@"indexPath:%ti",indexPath.section);
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        CommonDetailViewController *controller = [[CommonDetailViewController alloc] init];
        controller.typeOfDetail = 2;
        controller.itemDetails = [[[self.arraySaleOpportunity objectAtIndex:indexPath.section] objectForKey:@"opportunities"] objectAtIndex:indexPath.row] ;
        controller.currencyUnit = currencyUnit;
        ///
        controller.groupNameOfSaleOpportunity = [self getGroupName:indexPath.section];
        
        [self.navigationController pushViewController:controller animated:YES];
        
    }
}


#pragma mark - headerViewTap
- (void)headerViewTap:(UITapGestureRecognizer*)sender {
    UIView *headview = sender.view;
    self.selectedIndex = headview.tag;
    
    NSLog(@"headerViewTap---section:%li",headview.tag);
    UIImageView *icon = (UIImageView*)[headview viewWithTag:headview.tag+1001];
    [UIView animateWithDuration:0.2 animations:^{
        icon.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:^(BOOL finished) {
    }];
    
    if (self.isOpen) {
        
        if (self.oldTag == headview.tag) {
            [self animationRowsWithSectionTag:headview.tag complete:^{
                self.isOpen = NO;
            }];
        }else {
            [self animationRowsWithSectionTag:self.oldTag complete:^{
                [self animationRowsWithSectionTag:headview.tag complete:^{
                }];
            }];
        }
    }else {
        [self animationRowsWithSectionTag:headview.tag complete:^{
            self.isOpen = YES;
        }];
    }
    self.oldTag = headview.tag;
    
}

- (void)animationRowsWithSectionTag:(NSInteger)tag complete:(void(^)())complete {
    
    NSDictionary *dict = [self.arraySaleOpportunity objectAtIndex:tag];
    BOOL isOpen = [[dict objectForKey:@"open"] boolValue];
    if (isOpen) {
        [self setGroupSectionOpenFlag:tag flag:NO];
    }else{
        [self setGroupSectionOpenFlag:tag flag:YES];
        [self judgeIsLoadedData:tag];
    }

    // 刷新指定section
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:tag];
    [self.tableviewSaleOpportunity reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
    
    complete();
}

///判断是否已经加载了数据
-(void)judgeIsLoadedData:(NSInteger)section{
    if ([[[self.arraySaleOpportunity objectAtIndex:section] objectForKey:@"flag"] isEqualToString:@"nodata"] ) {
        NSLog(@"modify data--->");
        typeCell = @"actIndicator";
        [self modifyDataForLoading:section];
        self.tableviewSaleOpportunity.userInteractionEnabled = NO;
        ///加载数据
        [self getDataFromServer];
        
    }else{
        typeCell = @"subcell";
    }
}

///设置分组展开标志
-(void)setGroupSectionOpenFlag:(NSInteger)section flag:(BOOL)flag{
    NSDictionary *itemOld =[self.arraySaleOpportunity objectAtIndex:section];
    NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:itemOld];
    ///添加标记  -- 未展开
    [mutableItemNew setValue:@(flag) forKey:@"open"];
    //修改数据
    [self.arraySaleOpportunity setObject: mutableItemNew atIndexedSubscript:section];
}


#pragma maek - 获取分组名称(name_percent)
-(NSString *)getGroupName:(NSInteger)section{
    NSDictionary *item = [self.arraySaleOpportunity objectAtIndex:section];
    ///stageName
    NSString *stageName = @"";
    if ([item objectForKey:@"stageName"]) {
        stageName = [item objectForKey:@"stageName"];
    }
#warning percent类型？
    NSInteger percent = 0;
    if ([item objectForKey:@"percent"]) {
        percent = [[item objectForKey:@"percent"] integerValue];
    }
    
    NSString *name_percent = [NSString stringWithFormat:@"%@(%ti%%)",stageName,percent];
    return name_percent;
}

#pragma maek - 获取分组Money(money元)
-(NSString *)getStagesMoney:(NSInteger)section{
     NSDictionary *item = [self.arraySaleOpportunity objectAtIndex:section];
    ///price
    long long money = 0;
    if ([item objectForKey:@"money"]) {
        money = [[item objectForKey:@"money"] longLongValue];
    }
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    //    formatter.numberStyle = kCFNumberFormatterCurrencyStyle;
    [formatter setPositiveFormat:@"###,##0;"];
    
    NSString *stringMoney = @"0";
    if (money > 0) {
        stringMoney = [NSString stringWithFormat:@"%@%@",[[formatter stringFromNumber:[NSNumber numberWithLongLong:money]] stringByReplacingOccurrencesOfString:@"￥" withString:@""],currencyUnit];
    }else{
        stringMoney = [NSString stringWithFormat:@"%@%@",@"0",currencyUnit];
    }
    
    return stringMoney;
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
    NSIndexPath *indexPath = [self.tableviewSaleOpportunity indexPathForCell:cell];
    NSLog(@"click section:%ti  row:%ti",indexPath.section,indexPath.row-1);
    NSDictionary *item = [[[self.arraySaleOpportunity objectAtIndex:indexPath.section] objectForKey:@"opportunities"] objectAtIndex:indexPath.row-1];
    
    switch (index) {
        case 0:
        {
            BOOL isFollow = FALSE;
            if ([item objectForKey:@"isFollow"]) {
                isFollow = [[item objectForKey:@"isFollow"] boolValue];
            }
            if (isFollow) {
                NSLog(@"取消关注...");
            }else{
                NSLog(@"关注...");
            }
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

@end
