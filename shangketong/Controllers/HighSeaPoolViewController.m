//
//  HighSeaPoolViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-3.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "HighSeaPoolViewController.h"
#import "CommonConstant.h"
#import "CommonFuntion.h"
#import "AFNHttp.h"
#import "AppDelegate.h"
#import "HighSeaPoolGroupDetailsViewController.h"

@interface HighSeaPoolViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation HighSeaPoolViewController


- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = kView_BG_Color;
    [self initTableview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.typeOfPool && [self.typeOfPool isEqualToString:@"clue"]){
//        self.title = @"线索公海池";
    }
    
    
    [self initData];
    [self readTestData];
    
    [self.tableviewHighSeaPool reloadData];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark - 读取测试数据
-(void)readTestData{
    id jsondata = [CommonFuntion readJsonFile:@"highseapool-data"];
    NSLog(@"jsondata:%@",jsondata);
    
    NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"highSeas"];
    [self.arrayHighSeaPool addObjectsFromArray:array];
    NSLog(@"arrayHighSeaPool count:%li",[self.arrayHighSeaPool count]);
}

#pragma mark - 初始化数据
-(void)initData{
    self.arrayHighSeaPool = [[NSMutableArray alloc] init];
}

#pragma mark - 初始化tablview
-(void)initTableview{
    
    self.tableviewHighSeaPool = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStylePlain];
    self.tableviewHighSeaPool.delegate = self;
    self.tableviewHighSeaPool.dataSource = self;
    self.tableviewHighSeaPool.sectionFooterHeight = 0;
    [self.view addSubview:self.tableviewHighSeaPool];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewHighSeaPool setTableFooterView:v];
}


#pragma mark - 获取公海池分组数据
-(void)getHighSeaPool{
     NSMutableDictionary *params=[NSMutableDictionary dictionary];
    NSString *url = @"";
    if(self.typeOfPool && [self.typeOfPool isEqualToString:@"clue"]){
        url = GET_CLUE_HIGH_SEA_POOL_ACTION;
    }else if(self.typeOfPool && [self.typeOfPool isEqualToString:@"customer"]){
        url = GET_CUSTOMER_HIGH_SEA_POOL_ACTION;
    }

    [params setObject:@"" forKey:@""];
    [params setObject:@"" forKey:@""];
    
    // 发起请求
    [AFNHttp post:url params:params success:^(id responseObj) {
        //字典转模型
        NSLog(@"responseObj:%@",responseObj);
        NSDictionary *info = responseObj;
        
        if ([[info objectForKey:@"scode"] integerValue] == 0) {
            
            if ([info objectForKey:@"body"]) {
                if ([[info objectForKey:@"body"] objectForKey:@"highSeas"] && [[info objectForKey:@"body"] objectForKey:@"highSeas"] != [NSNull null]) {
                    
                    self.arrayHighSeaPool = [[info objectForKey:@"body"] objectForKey:@"highSeas"] ;
                }
            }
            
        }else{
        }
        [self.tableviewHighSeaPool reloadData];
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        [self.tableviewHighSeaPool reloadData];
    }];
}


#pragma mark - tableview delegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.arrayHighSeaPool) {
        return [self.arrayHighSeaPool count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"ProductGroupCellIdentifier";
    
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
    
    cell.textLabel.text = [[self.arrayHighSeaPool objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"待领取(%li)",[[[self.arrayHighSeaPool objectAtIndex:indexPath.row] objectForKey:@"unclaimed"] integerValue]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(self.typeOfPool && [self.typeOfPool isEqualToString:@"clue"]){
        
    }else if(self.typeOfPool && [self.typeOfPool isEqualToString:@"customer"]){
    }
    
    HighSeaPoolGroupDetailsViewController *controller = [[HighSeaPoolGroupDetailsViewController alloc] init];
    controller.title = [[self.arrayHighSeaPool objectAtIndex:indexPath.row] objectForKey:@"name"];
    controller.typeOfPool = self.typeOfPool;
    controller.highSeaId = [[self.arrayHighSeaPool objectAtIndex:indexPath.row] objectForKey:@"id"];
    [self.navigationController pushViewController:controller animated:YES];
}



@end
