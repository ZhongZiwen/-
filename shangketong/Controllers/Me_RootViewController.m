//
//  Me_RootViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "Me_RootViewController.h"
#import "InfoViewController.h"
#import "FeedViewController.h"
#import "FavorViewController.h"
#import "WebViewController.h"
#import "SettingViewController.h"
#import "WorkGroupRecordViewController.h"
#import "TitleImageCell.h"
#import "MeHeaderTableViewCell.h"
#import "CommonStaticVar.h"
#import "GBMoudle.h"
#import "CommonConstant.h"
#import "HelpViewController.h"
#import "NSUserDefaults_Cache.h"

#import "RootMenuCell.h"
#import "RootMenuHeaderCell.h"
#import "CommonModuleFuntion.h"

#define kCellIdentifier @"TitleImageCell"
#define kCellIdentifier_header @"MeHeaderTableViewCell"

@interface Me_RootViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation Me_RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initTableview];
    [self initMenuData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableview reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStyleGrouped];
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
     NSArray *sourceArray = @[@{@"image":@"mysetting_feed", @"title":@"我的动态",@"switch":@YES,@"group":@"groupA",@"eventIndex":@"1",@"unreadmsg":@"0",@"tag":@"1"},
                               @{@"image":@"mysetting_fav", @"title":@"我的收藏",@"switch":@YES,@"group":@"groupA",@"eventIndex":@"2",@"unreadmsg":@"0",@"tag":@"2"},
                               @{@"image":@"mysetting_salesdoc", @"title":@"帮助",@"switch":@YES,@"group":@"groupA",@"eventIndex":@"3",@"unreadmsg":@"0",@"tag":@"3"},
                               @{@"image":@"mysetting_set", @"title":@"设置",@"switch":@YES,@"group":@"groupB",@"eventIndex":@"4",@"unreadmsg":@"0",@"tag":@"4"}];
    
    
    NSMutableArray *meptions = [[NSMutableArray alloc] init];
    if (sourceArray) {
        for (int i=0; i<sourceArray.count; i++) {
            RootMenuModel *model = [RootMenuModel initWithDictionary:sourceArray[i]];
            [meptions addObject:model];
        }
        [self.dataSource addObjectsFromArray:[CommonModuleFuntion getOptionsModuleShow:meptions]];
    }
    NSLog(@"self.dataSource:%@",self.dataSource);
    [self.tableview reloadData];
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
        return [self.dataSource count]+1;
    }
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    if (self.dataSource) {
        return [[self.dataSource objectAtIndex:section-1] count];
    }
    return 0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 80.0;
    }
    return 45.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        RootMenuHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RootMenuHeaderCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RootMenuHeaderCell" owner:self options:nil];
            cell = (RootMenuHeaderCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
         NSDictionary *userInfo = [NSUserDefaults_Cache getUserInfo];
         [cell setCellDetails:userInfo];
        return cell;
    }else{
        RootMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RootMenuCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RootMenuCell" owner:self options:nil];
            cell = (RootMenuCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        
        [cell setCellDetails:(RootMenuModel *)([[self.dataSource objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row]) withType:2];
        
        return cell;
    }
    
    return nil;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        InfoViewController *infoController = [[InfoViewController alloc] init];
        infoController.title = @"个人信息";
        infoController.hidesBottomBarWhenPushed = YES;
        infoController.infoTypeOfUser = InfoTypeMyself;
        [self.navigationController pushViewController:infoController animated:YES];
    }else{
        RootMenuModel *itemModel = [[self.dataSource objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
        
        NSInteger eventIndex = [itemModel.menu_eventindex integerValue];
        
        
        switch (eventIndex) {
           
            case 1:
            {
                WorkGroupRecordViewController *feedController = [[WorkGroupRecordViewController alloc] init];
                feedController.title = @"我的动态";
                feedController.typeOfView = @"feed";
                [CommonStaticVar setFlagOfWorkGroupViewFrom:@"feed"];
                
                feedController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:feedController animated:YES];
                
            }
                break;
            case 2:
            {
                WorkGroupRecordViewController *favorController = [[WorkGroupRecordViewController alloc] init];
                favorController.title = @"我的收藏";
                favorController.typeOfView = @"favorite";
                [CommonStaticVar setFlagOfWorkGroupViewFrom:@"favorite"];
                favorController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:favorController animated:YES];
            }
                break;
            case 3:
            {
                HelpViewController *favorController = [[HelpViewController alloc] init];
                favorController.title = @"帮助";
                favorController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:favorController animated:YES];
            }
                break;
            case 4:
            {
                SettingViewController *settingController = [[SettingViewController alloc] init];
                settingController.title = @"设置";
                settingController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:settingController animated:YES];
            }
                break;
            default:
                break;
        }
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
