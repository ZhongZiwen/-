//
//  ContactBookAddNewLevel2ViewController.m
//  lianluozhongxin
//
//  Created by Vescky on 14-7-7.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "ContactBookAddNewLevel2ViewController.h"
#import "NSString+JsonHandler.h"
#import "LLCenterUtility.h"

#define Group_Name_Cell_Height 50.0f

@interface ContactBookAddNewLevel2ViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate> {
    NSMutableArray *selectedGroups;
}
@end

@implementation ContactBookAddNewLevel2ViewController
@synthesize detailContactInfo,fromViewController,dataSource,delegate,selectedGroupsIDList,groupDataType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"加入分组";
    
//    tbView.frame = CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT);
    [tbView setScrollEnabled:YES];
    
    [super customBackButton];
    [self initData];
    [self getGroups];
    
//    UIButton* filterButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];//
//    [filterButton setTitle:@"完成" forState:UIControlStateNormal];
//    [filterButton setTitleColor:GetColorWithRGB(0, 110, 255) forState:UIControlStateNormal];
//    [filterButton setTitleColor:GetColorWithRGB(0, 150, 255) forState:UIControlStateHighlighted];
//    [filterButton setShowsTouchWhenHighlighted:YES];
//    filterButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
//    [filterButton addTarget:self action:@selector(rightBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem* actionItem= [[UIBarButtonItem alloc] initWithCustomView:filterButton];
//    [self.navigationItem setRightBarButtonItem:actionItem];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    //
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([delegate respondsToSelector:@selector(selectedGroupsDidChanged:)]) {
        [delegate selectedGroupsDidChanged:selectedGroups];
    }
}

#pragma mark - Private
- (void)getGroups {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    NSString *action = LLC_GET_DEPT_LIST_ACTION;
    if (groupDataType == GroupDataChildren) {
        action = LLC_GET_GH_AND_ISDEPT_ACTION;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,action] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"分组数据jsonResponse:%@",jsonResponse);
        NSArray *deptList;
        if (groupDataType == GroupDataChildren) {
            deptList = [[[jsonResponse objectForKey:@"resultMap"] objectForKey:@"childs"] toJsonValue];
        }
        else {
            deptList = [[[jsonResponse objectForKey:@"resultMap"] objectForKey:@"deptList"] toJsonValue];
        }
        if (deptList) {
            NSLog(@"%@",deptList);
            tbView.hidden = NO;
            for (int i = 0; i < [deptList count]; i++) {
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      [[deptList objectAtIndex:i] objectForKey:@"DEPT_NAME"],@"groupName",
                                      [[deptList objectAtIndex:i] objectForKey:@"DEPT_ID"],@"groupID",
                                      [self isGoupSelected:[deptList objectAtIndex:i]],@"isSelected", nil];
                CellDataInfo *cInfo = [[CellDataInfo alloc] initWithCellDataInfo:dict];
                if (cInfo) {
                    [dataSource addObject:cInfo];
                }
                if ([[dict safeObjectForKey:@"isSelected"] intValue]) {
                    [selectedGroups addObject:dict];
                }
            }
            CGRect tbRect = tbView.frame;
            tbRect.size.height = [dataSource count] * Group_Name_Cell_Height > self.view.frame.size.height ? self.view.frame.size.height : [dataSource count] * Group_Name_Cell_Height;
            tbView.frame = tbRect;
            [tbView reloadData];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
}

- (void)initData {
    if (!dataSource) {
        dataSource = [[NSMutableArray alloc] init];
    }
    
    if (!selectedGroups) {
        selectedGroups = [[NSMutableArray alloc] init];
    }
    
    
//    //默认初始化
//    if (!dataSource || [dataSource count] < 1) {
//        
//        NSArray *arr = [[NSArray alloc] initWithObjects:@"销售一部",@"销售二部",@"销售三部",@"研发一部",@"研发二部", nil];
//        for (int i = 0; i < [arr count]; i++) {
//            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[arr objectAtIndex:i],@"groupName",@"0",@"isSelected", nil];
//            CellDataInfo *cInfo = [[CellDataInfo alloc] initWithCellDataInfo:dict];
//            if (cInfo) {
//                [dataSource addObject:cInfo];
//            }
//        }
//    }
//    
//    
//    for (int i = 0; i < [dataSource count]; i++) {
//        CellDataInfo *cInfo = [dataSource objectAtIndex:i];
//        if ([[cInfo.cellDataInfo objectForKey:@"isSelected"] intValue] == 1) {
//            [selectedGroups addObject:[cInfo.cellDataInfo objectForKey:@"groupName"]];
//        }
//    }
//    
//    [tbView reloadData];
//    
    
}

- (NSString*)isGoupSelected:(NSDictionary*)dict {
//    NSString *gId = [dict objectForKey:@"DEPT_NAME"];
//    for (int i = 0; i < [selectedGroupsIDList count]; i++) {
//        if ([gId isEqualToString:[selectedGroupsIDList objectAtIndex:i]]) {
//            return @"1";
//        }
//    }
//    return @"0";
    
    NSString *gId = [dict objectForKey:@"DEPT_ID"];
    for (int i = 0; i < [selectedGroupsIDList count]; i++) {
        if ([gId longLongValue] == [[selectedGroupsIDList objectAtIndex:i] longLongValue]) {
            return @"1";
        }
    }
    return @"0";
}

- (void)removeItemInSelectedGroups:(NSDictionary*)dict {
    for (int i = 0; i < [selectedGroups count]; i++) {
        NSDictionary *tmp = [selectedGroups objectAtIndex:i];
        if ([[dict safeObjectForKey:@"groupID"] longLongValue] == [[tmp safeObjectForKey:@"groupID"] longLongValue]) {
            [selectedGroups removeObjectAtIndex:i];
            break;
        }
    }
}

- (void)rightBarButtonAction {
    [CommonFuntion showToast:@"保存成功!" inView:self.view];
    if ([delegate respondsToSelector:@selector(selectedGroupsDidChanged:)]) {
        [delegate selectedGroupsDidChanged:selectedGroups];
    }
}

#pragma mark - Button Action
- (IBAction)btnAction:(id)sender {
    [CommonFuntion showToast:@"添加成功" inView:self.view];
    if (fromViewController) {
        [self.navigationController popToViewController:fromViewController animated:YES];
        return;
    }
    
    int viewControllersCount = [self.navigationController.viewControllers count];
    if (viewControllersCount > 3) {
        UIViewController *backToViewController = [self.navigationController.viewControllers objectAtIndex:viewControllersCount-3];
        [self.navigationController popToViewController:backToViewController animated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSLog(@"count:%i",[dataSource count]);
    return [dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GroupNameCell";//cell重用标识
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];//设置这个cell的重用标识
    
    CellDataInfo *currentCellDataInfo = [dataSource objectAtIndex:indexPath.row];
    
    //若cell为nil，重新alloc一个cell
    if(!cell){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"GroupNameCell" owner:self options:nil] objectAtIndex:0];
    }
    
    cell.tag = indexPath.row;
    
    if([cell respondsToSelector:@selector(setCellDataInfo:)]){
        [cell performSelector:@selector(setCellDataInfo:) withObject:currentCellDataInfo];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return Group_Name_Cell_Height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tbView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"Cell No.%d clicked",indexPath.row);
    
    CellDataInfo *currentCellDataInfo = [dataSource objectAtIndex:indexPath.row];
    NSString *s = [[currentCellDataInfo.cellDataInfo objectForKey:@"isSelected"] boolValue] ? @"0" : @"1";
    NSLog(@"s:%@",s);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:currentCellDataInfo.cellDataInfo];
    [dict setObject:s forKey:@"isSelected"];
    
    currentCellDataInfo.cellDataInfo = dict;
    
    //刷新单个cell
    [tbView reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if ([s isEqualToString:@"1"]) {
        [selectedGroups addObject:dict];
    }
    else {
        [self removeItemInSelectedGroups:dict];
    }
    NSLog(@"selectedGroups:%i",[selectedGroups count]);
    if ([delegate respondsToSelector:@selector(selectedGroupsDidChanged:)]) {
        [delegate selectedGroupsDidChanged:selectedGroups];
    }
    
    
//    if ([delegate respondsToSelector:@selector(allGroupsStatusDisChanged:)]) {
//        [delegate allGroupsStatusDisChanged:dataSource];
//    }
}

@end
