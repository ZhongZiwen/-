//
//  SalesOpportunityRelatedViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-7-21.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SalesOpportunityRelatedViewController.h"
#import "CommonConstant.h"
#import "CommonFuntion.h"
#import "SaleOpportunityCell.h"
#import "CommonDetailViewController.h"

@interface SalesOpportunityRelatedViewController ()<UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate>{
    ///单位 （元）
    NSString *currencyUnit;
}

@property(strong,nonatomic) UITableView *tableviewRelated;
@property(strong,nonatomic) NSMutableArray *arrayRelated;

@end

@implementation SalesOpportunityRelatedViewController

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = VIEW_BG_COLOR;
    [self addRightNarBtn];
    [self initTableview];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self readTestData];
    [self.tableviewRelated reloadData];
}


#pragma mark - 读取测试数据
-(void)readTestData{
    id jsondata = [CommonFuntion readJsonFile:@"sale-opportunity-data"];
    NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"opportunities"];
    [self.arrayRelated addObjectsFromArray:array];
    NSLog(@"arrayRelated count:%li",[self.arrayRelated count]);
    
    currencyUnit = [[jsondata objectForKey:@"body"] objectForKey:@"currencyUnit"];
}

#pragma mark - 初始化数据
-(void)initData{
    self.arrayRelated = [[NSMutableArray alloc] init];
}


#pragma mark - 右侧更多按钮
-(void)addRightNarBtn{
    
    UIButton *option = [UIButton buttonWithType:UIButtonTypeCustom];
    option.frame = CGRectMake(0, 0, 20, 4);
    [option setBackgroundImage:[UIImage imageNamed:@"more.png"]
                      forState:UIControlStateNormal];
    
    [option setBackgroundImage:[UIImage imageNamed:@"more.png"]
                      forState:UIControlStateHighlighted];
    
    
    [option addTarget:self action:@selector(newSaleOpportunity)
     forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:option];
    self.navigationItem.rightBarButtonItem = rightItem;
}

///新建销售机会
-(void)newSaleOpportunity{
    
}

#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewRelated = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStylePlain];
    [self.tableviewRelated registerNib:[UINib nibWithNibName:@"SaleOpportunityCell" bundle:nil] forCellReuseIdentifier:@"SaleOpportunityCellIdentify"];
    self.tableviewRelated.delegate = self;
    self.tableviewRelated.dataSource = self;
    self.tableviewRelated.sectionFooterHeight = 0;
    [self.view addSubview:self.tableviewRelated];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewRelated setTableFooterView:v];
}

#pragma mark - tableview delegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.arrayRelated) {
        return [self.arrayRelated count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SaleOpportunityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SaleOpportunityCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SaleOpportunityCell" owner:self options:nil];
        cell = (SaleOpportunityCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    cell.delegate = self;
    
    [cell setCellDetails:[self.arrayRelated objectAtIndex:indexPath.row]  currencyUnit:currencyUnit index:indexPath];
    [cell setLeftAndRightBtn:[self.arrayRelated objectAtIndex:indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CommonDetailViewController *controller = [[CommonDetailViewController alloc] init];
    controller.typeOfDetail = 2;
    controller.itemDetails = [self.arrayRelated objectAtIndex:indexPath.row] ;
    controller.currencyUnit = currencyUnit;
#warning 获取stageName+winRate
    controller.groupNameOfSaleOpportunity = @"3(%15)";
    
    [self.navigationController pushViewController:controller animated:YES];
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
    NSIndexPath *indexPath = [self.tableviewRelated indexPathForCell:cell];
    NSLog(@"click section:%ti  row:%ti",indexPath.section,indexPath.row);
    NSDictionary *item = [self.arrayRelated objectAtIndex:indexPath.row];
    
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
