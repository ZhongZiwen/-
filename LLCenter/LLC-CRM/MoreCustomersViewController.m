//
//  MoreCustomersViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-7-6.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "MoreCustomersViewController.h"
#import "CommonFunc.h"
#import "LLCenterUtility.h"
#import "MoreCustomerCell.h"
#import "MoreCustomerItemCell.h"
#import "AddMoreContactViewController.h"

@interface MoreCustomersViewController ()<UITableViewDataSource,UITableViewDelegate,GoToCustomerDetailsDelegate>{
    
    ///已经分组的联系人
    NSMutableArray *arrayGroupLinkMan;
}

@end

@implementation MoreCustomersViewController


- (void)loadView
{
    [super loadView];
    self.title = @"更多";
    self.view.backgroundColor = [UIColor whiteColor];
    [super customBackButton];
    [self addNarBar];
    [self initTableview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initGroupData];
    [self.tableviewCustomers reloadData];
    [self eventOfBtnClick];
}

-(void)addNarBar{
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewContact)];
    self.navigationItem.rightBarButtonItem = addButton;
}

///新建联系人
-(void)addNewContact{
    AddMoreContactViewController *controller = [[AddMoreContactViewController alloc] init];
    __weak typeof(self) weak_self = self;
    controller.NotifyContactList = ^(){
        NSLog(@"NotifyContactList---->");
        if (weak_self.NotifyLinkmanData) {
            weak_self.NotifyLinkmanData();
        }
//        [weak_self.navigationController popViewControllerAnimated:YES];
    };
    controller.cusDetails = self.cusDetails;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - 初始化数据
-(void)initData{
    arrayGroupLinkMan = [[NSMutableArray alloc] init];
    
}

#pragma mark - 将联系人分组
-(void)initGroupData{
    
    NSInteger count = 0;
    if (self.arrayAllLinkMan) {
        count = [self.arrayAllLinkMan count];
    }
    NSMutableDictionary *grouDic = [[NSMutableDictionary alloc] init];
    NSDictionary *item;
    for(int i=0; i< count; i++)
    {
        item = [self.arrayAllLinkMan objectAtIndex:i];
        NSString *typeIdKey = [item safeObjectForKey:@"TYPE"];
        
        if ([grouDic objectForKey:typeIdKey]) {
            NSMutableArray *arrNew = [[NSMutableArray alloc] initWithArray:[grouDic objectForKey:typeIdKey]];
            [arrNew addObject:item];
            [grouDic setObject:arrNew forKey:typeIdKey];
        }else
        {
            NSArray *arr = [[NSArray alloc] initWithObjects:item, nil];
            [grouDic setObject:arr forKey:typeIdKey];
        }
    }
    
    NSMutableDictionary *groupDic2 = nil;
    NSString *groupName = @"";
    if (grouDic) {
        
        for (id keyInDictionary in [grouDic allKeys]){
            id objectForKey = [grouDic objectForKey:keyInDictionary];
            groupDic2 = [[NSMutableDictionary alloc] init];
            
            groupName = [[objectForKey objectAtIndex:0] safeObjectForKey:@"FIELD_VALUE"];
            if ([groupName isEqualToString:@""]) {
                groupName = @"未知";
            }
            [groupDic2 setObject:groupName forKey:@"groupName"];
            [groupDic2 setObject:objectForKey forKey:@"linkmanlist"];
            [arrayGroupLinkMan addObject:groupDic2];
        }
        
    }
    
    NSLog(@"arrayGroupLinkMan:%@",arrayGroupLinkMan);
    
}

#pragma mark - 读取测试数据
-(void)readTestData{
    id jsondata = [CommonFunc readJsonFile:@"more-customers"];
    NSLog(@"jsondata:%@",jsondata);
    
    NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"cst"];
    [arrayGroupLinkMan addObjectsFromArray:array];
    
    NSLog(@"arrayCustomers count:%@",arrayGroupLinkMan);
}


#pragma mark - 初始化tablview
-(void)initTableview{
    
    self.tableviewCustomers = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT) style:UITableViewStylePlain];
    self.tableviewCustomers.delegate = self;
    self.tableviewCustomers.dataSource = self;
    self.tableviewCustomers.sectionFooterHeight = 0;
    self.tableviewCustomers.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableviewCustomers];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewCustomers setTableFooterView:v];

}

#pragma mark - 点击事件回调
-(void)eventOfBtnClick{
//    NSLog(@"------eventOfBtnClick----->");
//    MoreCustomerItemCell *moreItem = [[MoreCustomerItemCell alloc] init];
//
//    [moreItem itemClick:^(NSInteger index) {
//        NSLog(@"点击事件回调:%li",index);
//    }];
}


#pragma mark - tableview delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (arrayGroupLinkMan) {
        return [arrayGroupLinkMan count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MoreCustomerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCustomerCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MoreCustomerCell" owner:self options:nil];
        cell = (MoreCustomerCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.labelTitleName.text = [[arrayGroupLinkMan objectAtIndex:indexPath.row] objectForKey:@"groupName"];
    [cell setCellDetails:[[arrayGroupLinkMan objectAtIndex:indexPath.row] objectForKey:@"linkmanlist"] indexPath:indexPath];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - 跳转到详情页面
-(void)gotoCustomerDetails:(NSDictionary *)item{
    NSLog(@"gotoCustomerDetails item name:%@",[item objectForKey:@"name"]);
    
    [self.navigationController popViewControllerAnimated:YES];
    if (self.RequestDataByLinkman) {
        self.RequestDataByLinkman(item);
    }
    
}

@end
