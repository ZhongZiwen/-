//
//  MsgViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MsgViewController.h"
#import "CommonConstant.h"
#import "SMSContactViewController.h"
#import "SMSCustomerViewController.h"

@interface MsgViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation MsgViewController

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = VIEW_BG_COLOR;
    self.title = @"群发短信";
    [self initTableview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self.tableviewMsg reloadData];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


#pragma mark - 初始化数据
-(void)initData{
    self.arrayMsg = [NSArray arrayWithObjects:@"发短信给客户联系人",@"发短信给客户", nil];
}

#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewMsg = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStyleGrouped];
    self.tableviewMsg.delegate = self;
    self.tableviewMsg.dataSource = self;
    self.tableviewMsg.sectionFooterHeight = 0;
    self.tableviewMsg.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
    self.tableviewMsg.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    [self.view addSubview:self.tableviewMsg];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewMsg setTableFooterView:v];
}



#pragma mark - tableview delegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.arrayMsg) {
        return [self.arrayMsg count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"MsgCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    }
    [self setContentDetails:cell indexPath:indexPath];
    return cell;
}

-(void)setContentDetails:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath{
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"menu_real_contact.png"];
    }else if(indexPath.row == 1){
        cell.imageView.image = [UIImage imageNamed:@"menu_account.png"];
    }
    
    cell.textLabel.text = [self.arrayMsg objectAtIndex:indexPath.row];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!indexPath.row) {
        ///联系人
        SMSContactViewController *contactController = [[SMSContactViewController alloc] init];
        contactController.title = @"联系人";
        [self.navigationController pushViewController:contactController animated:YES];
    }else if (indexPath.row == 1){
        ///客户
        SMSCustomerViewController *customerController = [[SMSCustomerViewController alloc] init];
        customerController.title = @"客户";
        [self.navigationController pushViewController:customerController animated:YES];
    }
}

@end
