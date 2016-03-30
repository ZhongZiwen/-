//
//  ContactSearchResultViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ContactSearchResultViewController.h"
#import "CommonFuntion.h"
#import "CommonConstant.h"
#import "AFNHttp.h"
#import "ContactCell.h"
#import "CommonDetailViewController.h"


@interface ContactSearchResultViewController ()<UITableViewDataSource,UITableViewDelegate,ContactCellDelegate>{
    ///页码
    NSInteger pageNo;
}

@end

@implementation ContactSearchResultViewController

- (void)loadView
{
    [super loadView];
    self.title = @"搜索结果";
    self.view.backgroundColor = VIEW_BG_COLOR;
    [self initTableview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self readTestData];
    [self.tableviewContact reloadData];
}

#pragma mark - 读取测试数据
-(void)readTestData{
    id jsondata = [CommonFuntion readJsonFile:@"contact-list-data"];
    NSLog(@"jsondata:%@",jsondata);
    
    NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"contacts"];
    [self.arrayContact addObjectsFromArray:array];
    
}

#pragma mark - 初始化数据
-(void)initData{
    self.arrayContact = [[NSMutableArray alloc] init];
}

#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewContact = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStylePlain];
    [self.tableviewContact registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCellIdentify"];
    self.tableviewContact.delegate = self;
    self.tableviewContact.dataSource = self;
    self.tableviewContact.sectionFooterHeight = 0;
    self.tableviewContact.backgroundColor = VIEW_BG_COLOR;
    [self.view addSubview:self.tableviewContact];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewContact setTableFooterView:v];
}


#pragma mark - 根据搜索关键词获取联系人列表
-(void)getContactList{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInteger:pageNo] forKey:@"pageNo"];
    [params setObject:@"" forKey:@""];
    [params setObject:@"" forKey:@""];
    
    // 发起请求
    [AFNHttp post:GET_CRM_CONTACT_LIST_ACTION params:params success:^(id responseObj) {
        //字典转模型
        NSLog(@"responseObj:%@",responseObj);
        NSDictionary *info = responseObj;
        
        if ([[info objectForKey:@"scode"] integerValue] == 0) {
            
            if ([info objectForKey:@"body"]) {
                if ([[info objectForKey:@"body"] objectForKey:@"contacts"] && [[info objectForKey:@"body"] objectForKey:@"contacts"] != [NSNull null]) {
                    
                    [self.arrayContact addObjectsFromArray:[[info objectForKey:@"body"] objectForKey:@"contacts"]];
                }
                
                /*
                 ///是否有更多数据
                 if ([[info objectForKey:@"body"] objectForKey:@"hasMore"] && [[info objectForKey:@"body"] objectForKey:@"hasMore"] != [NSNull null]) {
                 if ([[[info objectForKey:@"body"] objectForKey:@"hasMore"] boolValue]) {
                 ///有更多数据
                 ///页码+
                 pageNo++;
                 }else{
                 ///无更多数据
                 ///去除加载更多
                 }
                 }
                 */
            }
            
        }else{
        }
        [self.tableviewContact reloadData];
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        [self.tableviewContact reloadData];
    }];
}


#pragma mark - tableview delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.arrayContact) {
        return [self.arrayContact count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"ContactCellIdentify";
    ContactCell *cell = (ContactCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ContactCell" owner:self options:nil];
        cell = (ContactCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    cell.ccdelegate = self;
    [cell setCellFrame];
    [cell setCellDetails:[self.arrayContact objectAtIndex:indexPath.row]];
    [cell setCallBtnShow:[self.arrayContact objectAtIndex:indexPath.row] index:indexPath];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*
    CommonDetailViewController *controller = [[CommonDetailViewController alloc] init];
    controller.typeOfDetail = 3;
    [self.navigationController pushViewController:controller animated:YES];
     */
    
}


#pragma mark - 拨打联系人事件回调
-(void)callCantact:(NSInteger)index{
    NSLog(@"callCantact:%li",index);
    
}

@end
