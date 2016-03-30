//
//  CRM_RootViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CRM_RootViewController.h"
#import "MenuSettingViewController.h"
#import "DashboardViewController.h"
#import "ActivityRecViewController.h"
#import "LeadViewController.h"
#import "CustomerViewController.h"
#import "ContactViewController.h"
#import "OpportunityViewController.h"
#import "SalesOpportunityViewController.h"
#import "ActivityController.h"
#import "ProductViewController.h"
#import "PoolViewController.h"
#import "SDImageCache.h"
#import "ArrayDataSource.h"

#import "TitleImageCell.h"
#import "NSUserDefaults_Cache.h"
#import "CommonModuleFuntion.h"

#import "RootMenuCell.h"

#define kCellIdentifier @"TitleImageCell"

@interface CRM_RootViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation CRM_RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = TABLEVIEW_BG_COLOR;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initTableview];
    [self initSettingBtn];
    [self initMenuData];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    if ([self isViewLoaded] && [self.view window] == nil) {
        self.view = nil;
        ///清除图片相关缓存
        [[SDImageCache sharedImageCache] clearMemory];
        [[SDImageCache sharedImageCache] clearDisk];
    }
}


#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.tableview setY:64.0f];
    [self.tableview setWidth:kScreen_Width];
    [self.tableview setHeight:kScreen_Height - CGRectGetMinY(self.tableview.frame) - 49.0f];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.sectionFooterHeight = 0;
    self.tableview.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    self.tableview.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
    [self.view addSubview:self.tableview];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableview setTableFooterView:v];
}


#pragma mark - 初始化数据
-(void)initMenuData{
    self.dataSource = [[NSMutableArray alloc] init];
    NSArray *crmModuleOptions = [NSUserDefaults_Cache getCRMModuleOptions];
//    NSLog(@"crmModuleOptions:%@",crmModuleOptions);
    [self notifyTableview:crmModuleOptions];
}

///刷新数据
-(void)notifyTableview:(NSArray *)options{
    [self.dataSource removeAllObjects];
    
    NSMutableArray *crmOptions = [[NSMutableArray alloc] init];
    if (options) {
        for (int i=0; i<options.count; i++) {
            RootMenuModel *model = [RootMenuModel initWithDictionary:options[i]];
            [crmOptions addObject:model];
        }
        [self.dataSource addObjectsFromArray:[CommonModuleFuntion getOptionsModuleShow:crmOptions]];
    }
    [self.tableview reloadData];
}



-(void)initSettingBtn{
    UIButton *btnSetting = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSetting.frame = CGRectMake(kScreen_Width-40, kScreen_Height-90, 30, 30);
    [btnSetting setImage:[UIImage imageNamed:@"menu_item_setting"] forState:UIControlStateNormal];
    [btnSetting addTarget:self action:@selector(settingItemPress) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSetting];
}


- (void)settingItemPress
{
    __weak typeof(self) weak_self = self;
    MenuSettingViewController *menuSettingController = [[MenuSettingViewController alloc] init];
    menuSettingController.title = @"CRM设置";
    menuSettingController.sourceType = DataSourceTypeCRM;
    
    menuSettingController.notifyModuleOptions = ^(NSArray *options){
        [weak_self notifyTableview:options];
    };
    menuSettingController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:menuSettingController animated:YES];
}


#pragma mark - tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.5f;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.dataSource) {
        return [self.dataSource count];
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.dataSource) {
        return [[self.dataSource objectAtIndex:section] count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RootMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RootMenuCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RootMenuCell" owner:self options:nil];
        cell = (RootMenuCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    
    [cell setCellDetails:(RootMenuModel *)([[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]) withType:0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RootMenuModel *itemModel = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSInteger eventIndex = [itemModel.menu_eventindex integerValue];
    
    switch (eventIndex) {
        case 1:
        {
            DashboardViewController *instrumentController = [[DashboardViewController alloc] init];
            instrumentController.title = @"仪表盘";
            instrumentController.hidesBottomBarWhenPushed = YES;
            
            // 取消返回按钮的title
//            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

            [self.navigationController pushViewController:instrumentController animated:YES];
        }
            break;
        case 2:
        {
            ActivityController *activityController = [[ActivityController alloc] init];
            activityController.title = @"市场活动";
            activityController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:activityController animated:YES];
        }
            break;
        case 3:
        {
            PoolViewController *leadPoolController = [[PoolViewController alloc] init];
            leadPoolController.title = @"线索公海池";
            leadPoolController.poolType = PoolTypeLead;
            leadPoolController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:leadPoolController animated:YES];
        }
            break;
        case 4:
        {
            LeadViewController *leadController = [[LeadViewController alloc] init];
            leadController.title = @"销售线索";
            leadController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:leadController animated:YES];
        }
            break;
        case 5:
        {
            PoolViewController *customerPoolController = [[PoolViewController alloc] init];
            customerPoolController.title = @"客户公海池";
            customerPoolController.poolType = PoolTypeCustomer;
            customerPoolController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:customerPoolController animated:YES];
        }
            break;
        case 6:
        {
            CustomerViewController *accountController = [[CustomerViewController alloc] init];
            accountController.title = @"客户";
            accountController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:accountController animated:YES];
        }
            break;
        case 7:
        {
            ContactViewController *contactController = [[ContactViewController alloc] init];
            contactController.title = @"联系人";
            contactController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:contactController animated:YES];
        }
            break;
        
        case 8:
        {
            OpportunityViewController *opportunityController = [[OpportunityViewController alloc] init];
            opportunityController.title = @"销售机会";
            opportunityController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:opportunityController animated:YES];
        }
            break;
        case 9:
        {
            ActivityRecViewController *activityController = [[ActivityRecViewController alloc] init];
            activityController.title = @"我的活动记录";
            activityController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:activityController animated:YES];
        }
            break;
        case 10:
        {
            ProductViewController *productController = [[ProductViewController alloc] init];
            productController.title = @"产品";
            productController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:productController animated:YES];
        }
            break;
        default:
            break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
