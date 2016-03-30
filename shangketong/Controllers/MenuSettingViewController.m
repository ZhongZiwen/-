//
//  MenuSettingViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MenuSettingViewController.h"
#import "MenuSettingCell.h"
#import "NSUserDefaults_Cache.h"

#define kCellIdentifier @"MenuSettingCell"

@interface MenuSettingViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITableView *m_tableView;
@property (nonatomic, strong) NSMutableArray *m_dataSource;
@end

@implementation MenuSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _m_dataSource = [[NSMutableArray alloc] init];
    
    if (_sourceType == DataSourceTypeOffice) {
        
        [_m_dataSource addObjectsFromArray:[NSUserDefaults_Cache getOAModuleOptions]];
        /*
        _m_dataSource = @[@{@"image":@"menu_item_feed", @"title":@"工作圈"},
                          @{@"image":@"menu_item_colleague", @"title":@"通讯录"},
                          @{@"image":@"menu_item_workreport", @"title":@"工作报告"},
                          @{@"image":@"menu_item_approval", @"title":@"审批"},
                          @{@"image":@"menu_item_schedule", @"title":@"日程"},
                          @{@"image":@"menu_item_task", @"title":@"任务"},
                          @{@"image":@"menu_item_rescenter", @"title":@"知识库"}];
         */
    }else{
        /*
        _m_dataSource = @[@{@"image":@"menu_item_analysis", @"title":@"仪表盘"},
                          @{@"image":@"menu_item_campaign", @"title":@"市场活动"},
                          @{@"image":@"menu_item_lead", @"title":@"销售线索"},
                          @{@"image":@"menu_item_account", @"title":@"客户"},
                          @{@"image":@"menu_item_contact", @"title":@"联系人"},
                          @{@"image":@"menu_item_opportunity", @"title":@"销售机会"},
                          @{@"image":@"menu_item_activityRecord", @"title":@"活动记录"},
                          @{@"image":@"menu_item_product", @"title":@"产品"}];
         */
        [_m_dataSource addObjectsFromArray:[NSUserDefaults_Cache getCRMModuleOptions]];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = TABLEVIEW_BG_COLOR;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[MenuSettingCell class] forCellReuseIdentifier:kCellIdentifier];
    tableView.tableHeaderView = [self customHeaderView];
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.backgroundColor = TABLEVIEW_BG_COLOR;
    [self.view addSubview:tableView];
    _m_tableView = tableView;
    
    UIBarButtonItem *okButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(okButtonItem)];
    self.navigationItem.rightBarButtonItem = okButtonItem;
}

///确定按钮
-(void)okButtonItem{
    if (self.notifyModuleOptions) {
        self.notifyModuleOptions(_m_dataSource);
    }
    if (_sourceType == DataSourceTypeOffice) {
        [NSUserDefaults_Cache setOAModuleOptions:_m_dataSource];
    }else{
        [NSUserDefaults_Cache setCRMModuleOptions:_m_dataSource];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (UIView*)customHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 200, 30)];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = [NSString stringWithFormat:@"在%@页显示以下内容", self.title];
    [headerView addSubview:label];
    
    return headerView;
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _m_dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MenuSettingCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    NSString *imageStr = [_m_dataSource[indexPath.row] objectForKey:@"image"];
    NSString *titleStr = [_m_dataSource[indexPath.row] objectForKey:@"title"];
    BOOL isSwitch = YES;
    if (![[_m_dataSource[indexPath.row] objectForKey:@"switch"] boolValue]) {
        isSwitch = NO;
    }
    [cell setImageView:imageStr titleLabel:titleStr switchValue:isSwitch];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:10.0f];
    
    [cell.m_switch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    cell.m_switch.tag = indexPath.row;
    return cell;
}


-(void) switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isOn = [switchButton isOn];
    
    NSInteger tag = switchButton.tag;
    ///修改switch值
    
    NSDictionary *item = [_m_dataSource objectAtIndex:tag];
    ///修改本地数据
    NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:item];
    [mutableItemNew setValue:@(isOn) forKey:@"switch"];
    //修改数据
    [_m_dataSource setObject: mutableItemNew atIndexedSubscript:tag];
    
}



@end
