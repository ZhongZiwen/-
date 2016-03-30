//
//  TeamMembersViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-7-7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TeamMembersViewController.h"
#import "CommonConstant.h"
#import "TeamMemberManageCell.h"
#import "TeamMemberOptionCell.h"
#import "ExportAddressViewController.h"
#import "AddressBook.h"

@interface TeamMembersViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *arrayAllTeamMember;
}

@end

@implementation TeamMembersViewController

/*
 {
 "canZHDApproval": false,
 "update": true,
 "delete": false,
 "transfer": true,
 "close": true,
 "release": true
 }
 */

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = VIEW_BG_COLOR;
    self.title = @"团队成员";
    
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加成员" style:UIBarButtonItemStyleDone target:self action:@selector(addNewMember)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    [self initTableview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self.tableviewTeamMembers reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark - 初始化数据
-(void)initData{
    arrayAllTeamMember = [[NSMutableArray alloc] init];
//    [arrayAllTeamMember addObjectsFromArray:self.arrayOwerTeamMembers];
    [arrayAllTeamMember addObjectsFromArray:self.arrayTeamMembers];
}

#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewTeamMembers = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStylePlain];
    self.tableviewTeamMembers.delegate = self;
    self.tableviewTeamMembers.dataSource = self;
    self.tableviewTeamMembers.sectionFooterHeight = 0;
    self.tableviewTeamMembers.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableviewTeamMembers.backgroundColor = VIEW_BG_COLOR;
    [self.view addSubview:self.tableviewTeamMembers];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewTeamMembers setTableFooterView:v];
}


#pragma mark - 添加成员
-(void)addNewMember{
//    __weak typeof(self) weak_self = self;
//    ExportAddressViewController *exportAddressController = [[ExportAddressViewController alloc] init];
//    exportAddressController.title = @"通讯录";
//    exportAddressController.typeOfViewFrom = ViewFromOtherAddOption;
//    
//    exportAddressController.SureSelectAddressBookBlock = ^(NSArray *selectedContact){
//        NSLog(@"选择的联系人:%@",selectedContact);
////        AddressBook
//        ///发送请求
//    };
//    
//    [self.navigationController pushViewController:exportAddressController animated:YES];
}

#pragma mark - tableview delegate

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
    headView.backgroundColor = VIEW_BG_COLOR;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreen_Width, 20)];
    if (section == 0) {
        label.text = @"所有者";
    }else if(section == 1){
        label.text = @"其他成员";
    }
    label.font = [UIFont systemFontOfSize:12.0];
    [headView addSubview:label];
    return headView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0 || section == 1) {
        return 20;
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (arrayAllTeamMember) {
        return [arrayAllTeamMember count] ;
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isOpen) {
        if (self.selectIndex.section == section) {
            return 1+1;
        }
    }
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isOpen&&self.selectIndex.section == indexPath.section&&indexPath.row!=0) {
        ///展开情况
        TeamMemberOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeamMemberOptionCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"TeamMemberOptionCell" owner:self options:nil];
            cell = (TeamMemberOptionCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        [cell.btnPermission addTarget:self action:@selector(actionPermission:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnDelete addTarget:self action:@selector(actionDelete:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }else{
        TeamMemberManageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeamMemberManageCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"TeamMemberManageCell" owner:self options:nil];
            cell = (TeamMemberManageCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        
        [cell setCellDetails:[arrayAllTeamMember objectAtIndex:indexPath.section] indexPath:indexPath];
        
//        if (indexPath.section < [self.arrayOwerTeamMembers count]) {
//            cell.imgOwnIcon.hidden = NO;
//        }else{
//            cell.imgOwnIcon.hidden = YES;
//        }
        
        return cell;
    }
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    ///已选中行
    if (self.selectIndex) {
        
        TeamMemberManageCell *cell = (TeamMemberManageCell *)[tableView cellForRowAtIndexPath:self.selectIndex];
        [UIView animateWithDuration:0.2 animations:^{
            cell.imgOpen.transform = CGAffineTransformMakeRotation(0);
        } completion:^(BOOL finished) {
            
        }];
    }
    
    ///当前行
    TeamMemberManageCell *cell = (TeamMemberManageCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (self.selectIndex == nil ||(self.selectIndex && self.selectIndex.section != indexPath.section) ) {
        [UIView animateWithDuration:0.2 animations:^{
            cell.imgOpen.transform = CGAffineTransformMakeRotation(M_PI);
        } completion:^(BOOL finished) {
        }];
    }
    
    [self openOrCloseMenu:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didSelectCellRowFirstDo:(BOOL)firstDoInsert nextDo:(BOOL)nextDoInsert
{
    self.isOpen = firstDoInsert;
    [self.tableviewTeamMembers beginUpdates];
    
    NSInteger section = self.selectIndex.section;
    NSInteger contentCount = 1;
    NSMutableArray* rowToInsert = [[NSMutableArray alloc] init];
    for (NSUInteger i = 1; i < contentCount + 1; i++) {
        NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:i inSection:section];
        [rowToInsert addObject:indexPathToInsert];
    }
    
    if (firstDoInsert)
    {
        [self.tableviewTeamMembers insertRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        [self.tableviewTeamMembers deleteRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [self.tableviewTeamMembers endUpdates];
    
    if (nextDoInsert) {
        self.isOpen = YES;
        self.selectIndex = [self.tableviewTeamMembers indexPathForSelectedRow];
        [self didSelectCellRowFirstDo:YES nextDo:NO];
    }
}

#pragma mark 点击展开按钮事件
////展开按钮事件
-(void)openMenuView:(id)sender{
    TeamMemberManageCell *cell;
    if (isIOS8) {
        cell = (TeamMemberManageCell *)[[sender superview] superview] ;
    }else{
        cell = (TeamMemberManageCell *)[[[sender superview] superview] superview];
    }
    NSIndexPath* indexPath=[self.tableviewTeamMembers indexPathForCell:cell];
    
    NSLog(@"展开按钮事件indexPath:%@",indexPath);
    
    [self openOrCloseMenu:indexPath];
    //     [self tableView:self.tableviewTodaySchedule didSelectRowAtIndexPath:indexPath];
}

-(void)openOrCloseMenu:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        if ([indexPath isEqual:self.selectIndex]) {
            self.isOpen = NO;
            [self didSelectCellRowFirstDo:NO nextDo:NO];
            self.selectIndex = nil;
        }else
        {
            if (!self.selectIndex) {
                self.selectIndex = indexPath;
                [self didSelectCellRowFirstDo:YES nextDo:NO];
            }else
            {
                [self didSelectCellRowFirstDo:NO nextDo:YES];
            }
        }
    }else
    {
        NSInteger row = indexPath.row-1;
    }
}

#pragma mark -权限事件
-(void)actionPermission:(id)sender{
    TeamMemberManageCell *cell;
    if (isIOS8) {
        cell = (TeamMemberManageCell *)[[sender superview] superview] ;
    }else{
        cell = (TeamMemberManageCell *)[[[sender superview] superview] superview];
    }
    NSIndexPath* indexPath=[self.tableviewTeamMembers indexPathForCell:cell];
    
    NSLog(@"actionPermission  section:%ti    row:%ti",indexPath.section,indexPath.row);
    ///section 即下标
}

#pragma mark -删除事件
-(void)actionDelete:(id)sender{
    TeamMemberManageCell *cell;
    if (isIOS8) {
        cell = (TeamMemberManageCell *)[[sender superview] superview] ;
    }else{
        cell = (TeamMemberManageCell *)[[[sender superview] superview] superview];
    }
    NSIndexPath* indexPath=[self.tableviewTeamMembers indexPathForCell:cell];
    
    NSLog(@"actionDelete indexPath:%@",indexPath);
    ///section 即下标
}

@end
