//
//  ChangeStatusViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-7-9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ChangeStatusViewController.h"
#import "CommonConstant.h"

@interface ChangeStatusViewController ()<UITableViewDataSource,UITableViewDelegate>{
    
}

@end

@implementation ChangeStatusViewController

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = TABLEVIEW_BG_COLOR;
    
    [self addNarOkBtn];
    [self initTableview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self.tableviewChangeStatus reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

#pragma mark - Nar btn
-(void)addNarOkBtn{
    UIBarButtonItem *okButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain
                                                                target:self action:@selector(okBtnPressed)];
    self.navigationItem.rightBarButtonItem = okButton;
}

-(void)okBtnPressed{
    
    NSDictionary *itemSelected = [self.arrayChangeStatus objectAtIndex:self.selectedIndex];
    if (self.notifyActivityStatusBlock) {
        self.notifyActivityStatusBlock([itemSelected safeObjectForKey:@"value"],[[itemSelected safeObjectForKey:@"id"] integerValue]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 初始化数据
-(void)initData{
//    if ([self.typeOfStatus isEqualToString:@"salelead"]) {
//        ///销售线索
//        self.arrayChangeStatus =  appDelegateAccessor.moudle.arraySaleLeadtatusStatusNames;
//    }else if ([self.typeOfStatus isEqualToString:@"campaign"]){
//        ///市场活动
//        self.arrayChangeStatus =  appDelegateAccessor.moudle.arrayCampaignsStatusNames;
//    }
    
    NSLog(@"self.arraySaleStatus:%@",self.arrayChangeStatus);
    self.selectedIndex = [self getIndexDefaultSelected:self.selectedIndex];
    NSLog(@"getIndexDefaultSelected index:%li",self.selectedIndex);
}

///获取默认销售状态
-(NSInteger)getIndexDefaultSelected:(NSInteger)value{
    NSLog(@"getIndexDefaultSelected id:%li",value);
    NSInteger selected = -1;
    NSInteger count = 0;
    if (self.arrayChangeStatus) {
        count = [self.arrayChangeStatus count];
    }
    for (int i=0; selected == -1 && i<count; i++) {
        if (value == [[[self.arrayChangeStatus objectAtIndex:i] objectForKey:@"id"] integerValue]) {
            selected = i;
        }
    }
    return selected;
}

#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewChangeStatus = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStylePlain];
    self.tableviewChangeStatus.delegate = self;
    self.tableviewChangeStatus.dataSource = self;
    self.tableviewChangeStatus.sectionFooterHeight = 0;
    [self.view addSubview:self.tableviewChangeStatus];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewChangeStatus setTableFooterView:v];
}


#pragma mark - tableview delegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.arrayChangeStatus) {
        return [self.arrayChangeStatus count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"ClueHighSeaPoolSearchCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    
    cell.textLabel.text = [[self.arrayChangeStatus objectAtIndex:indexPath.row] safeObjectForKey:@"value"];
    if (self.selectedIndex == indexPath.row) {
        cell.accessoryType  = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType  = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndex = indexPath.row;
    [self.tableviewChangeStatus reloadData];
}

@end
