//
//  MsgSelectedContactOrCustomerViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MsgSelectedContactOrCustomerViewController.h"
#import "CommonFuntion.h"
#import "CommonConstant.h"
#import "ContactCell.h"
#import "CustomerCell.h"
@interface MsgSelectedContactOrCustomerViewController ()<UITableViewDataSource,UITableViewDelegate>{
    ///选中的联系人
    NSMutableArray *selectedArray;
}

@end

@implementation MsgSelectedContactOrCustomerViewController

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = VIEW_BG_COLOR;
    [self initTableview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.delegate && [self.delegate respondsToSelector:@selector(notifySelectedArray:)]) {
        [self.delegate notifySelectedArray:selectedArray];
    }
}


#pragma mark - 初始化数据
-(void)initData{
    selectedArray = [[NSMutableArray alloc] init];
    [selectedArray addObjectsFromArray:self.arrayAllContact];
}


#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewSelected = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStylePlain];
    if ([self.typeContact isEqualToString:@"contact"]) {
        [self.tableviewSelected registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCellIdentify"];
    }else if ([self.typeContact isEqualToString:@"customer"]){
        [self.tableviewSelected registerNib:[UINib nibWithNibName:@"CustomerCell" bundle:nil] forCellReuseIdentifier:@"CustomerCellIdentify"];
    }
    
    self.tableviewSelected.delegate = self;
    self.tableviewSelected.dataSource = self;
    self.tableviewSelected.sectionFooterHeight = 0;
    [self.view addSubview:self.tableviewSelected];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewSelected setTableFooterView:v];
}


#pragma mark - tableview delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.arrayAllContact) {
        return [self.arrayAllContact count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.typeContact isEqualToString:@"contact"]) {
        return 50.0;
    }else if ([self.typeContact isEqualToString:@"customer"]){
        return 60.0;
    }
    return 50.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ///联系人
    if ([self.typeContact isEqualToString:@"contact"]) {
        static NSString *cellIdentifier = @"ContactCellIdentify";
        ContactCell *cell = (ContactCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ContactCell" owner:self options:nil];
            cell = (ContactCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        
        [cell setCellFrame];
        [cell setCellDetails:[self.arrayAllContact objectAtIndex:indexPath.row]];
        
        NSDictionary *item = [self.arrayAllContact objectAtIndex:indexPath.row];
        long long contactId = [[item objectForKey:@"id"] longLongValue];
        if ([self isSelectedContact:contactId]) {
            [cell setSelectedBtnShow:@"yes"];
        }else{
            [cell setSelectedBtnShow:@"no"];
        }
        
        return cell;
    }else if ([self.typeContact isEqualToString:@"customer"]){
        static NSString *cellIdentifier = @"CustomerCellIdentify";
        CustomerCell *cell = (CustomerCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"CustomerCell" owner:self options:nil];
            cell = (CustomerCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        [cell setCellFrame];
        [cell setCellDetails:[self.arrayAllContact objectAtIndex:indexPath.row]];
        NSDictionary *item = [self.arrayAllContact objectAtIndex:indexPath.row];
        long long contactId = [[item objectForKey:@"id"] longLongValue];
        if ([self isSelectedContact:contactId]) {
            [cell setSelectedIconShow:@"yes"];
        }else{
            [cell setSelectedIconShow:@"no"];
        }
        return cell;
    }
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self setContactSelectStatus:indexPath];
    [self.tableviewSelected reloadData];
}


///设置联系人选中状态
-(void)setContactSelectStatus:(NSIndexPath *)indexPath{
    
    //判断是否已经选中  如选中则删除掉  否则标记为添加
    NSDictionary *item = [self.arrayAllContact objectAtIndex:indexPath.row];
    long long contactId = [[item objectForKey:@"id"] longLongValue];
    //已选中 则删除
    if ([self isSelectedContact:contactId]) {
        [self delectSelected:contactId];
    }else
    {
        // 添加
        [selectedArray addObject:item];
    }
}


///判断联系人是否选中
-(BOOL)isSelectedContact:(long long)contactId{
    BOOL isSelected = FALSE;
    
    NSInteger count = 0;
    if (selectedArray) {
        count = [selectedArray count];
    }
    
    for (int i=0; !isSelected && i<count; i++) {
        if ([[[selectedArray objectAtIndex:i] objectForKey:@"id"] longLongValue] == contactId) {
            isSelected = TRUE;
        }
    }
    
    return isSelected;
}

///删除已选中数组中得某个人
-(void)delectSelected:(long long)contactId
{
    BOOL isDeleted = FALSE;
    NSInteger count = 0;
    if (selectedArray) {
        count = [selectedArray count];
    }
    for(int i=0; !isDeleted && i<count; i++)
    {
        if ([[[selectedArray objectAtIndex:i] objectForKey:@"id"] longLongValue] == contactId)
        {
            [selectedArray removeObjectAtIndex:i];
            count--;
            isDeleted = TRUE;
        }
    }
}


@end
