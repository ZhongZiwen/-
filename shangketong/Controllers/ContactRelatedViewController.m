//
//  ContactRelatedViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-7-21.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ContactRelatedViewController.h"
#import "CommonFuntion.h"
#import "CommonConstant.h"
#import "AFNHttp.h"
#import "ContactCell.h"
#import "CommonDetailViewController.h"
#import "Select_Table_View.h"

@interface ContactRelatedViewController ()<UITableViewDataSource,UITableViewDelegate,SWTableViewCellDelegate>{
    ///页码
    NSInteger pageNo;
}

@property(strong,nonatomic) UITableView *tableviewContact;
@property(strong,nonatomic) NSMutableArray *arrayContact;

@end

@implementation ContactRelatedViewController


- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = VIEW_BG_COLOR;
    
    [self addNarBarBtn];
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

#pragma mark - nar  btn
-(void)addNarBarBtn{
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItemPress)];
    self.navigationItem.rightBarButtonItem = addItem;
}


///新增
- (void)addItemPress
{
    NSArray *array = @[@"名片扫描", @"手工输入"];
    Select_Table_View *selectView = [[Select_Table_View alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) dataArray:array];
    
    __weak typeof(self) weak_self = self;
    selectView.BackIndexBlock = ^(NSInteger index) {
        //根据返回不同的下标进行不同的事件处理
        [weak_self pushDifferenceController:index];
    };
    __weak typeof(selectView) weak_selectView = selectView;
    selectView.RemoveViewBlock = ^(){
        //移除视图
        [weak_selectView removeFromSuperview];
    };
    selectView.backgroundColor = [UIColor clearColor];
    [self.view.window addSubview:selectView];
}
- (void)pushDifferenceController:(NSInteger)index {
    switch (index) {
        case 0:
            NSLog(@"我是第%ld行", index);
            break;
        case 1:
            NSLog(@"我是第%ld行", index);
            break;
        case 2:
            NSLog(@"我是第%ld行", index);
            break;
        case 3:
            NSLog(@"我是第%ld行", index);
            break;
        case 4:
            NSLog(@"我是第%ld行", index);
            break;
        default:
            break;
    }
}

#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewContact = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStylePlain];
    [self.tableviewContact registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCellIdentify"];
    self.tableviewContact.delegate = self;
    self.tableviewContact.dataSource = self;
    self.tableviewContact.sectionFooterHeight = 0;
    [self.view addSubview:self.tableviewContact];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewContact setTableFooterView:v];
}


#pragma mark - 获取联系人列表
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
    cell.delegate = self;
    [cell setCellFrame];
    [cell setLeftAndRightBtn:[self.arrayContact objectAtIndex:indexPath.row]];
    [cell setCellDetails:[self.arrayContact objectAtIndex:indexPath.row]];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CommonDetailViewController *controller = [[CommonDetailViewController alloc] init];
    controller.typeOfDetail = 3;
    controller.itemDetails = [self.arrayContact objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
}



#pragma mark - SWTableViewDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
        //        NSLog(@"utility buttons closed");
        break;
        case 1:
        //        NSLog(@"left utility buttons open");
        break;
        case 2:
        //        NSLog(@"right utility buttons open");
        break;
        default:
        break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        //        NSLog(@"left button 0 was pressed");
        break;
        default:
        break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [self.tableviewContact indexPathForCell:cell];
    NSLog(@"click index:%ld",indexPath.row);
    NSDictionary *item = [self.arrayContact objectAtIndex:indexPath.row];
    
    switch (index) {
        case 0:
        {
            NSString *address = @"";
            if ([item objectForKey:@"address"]) {
                address = [item objectForKey:@"address"];
            }
            if ([address isEqualToString:@""]) {
                NSLog(@"没有地址...");
            }else{
                NSLog(@"地址...");
            }
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 1:
        {
            NSString *mobile = @"";
            if ([item objectForKey:@"mobile"]) {
                mobile = [item objectForKey:@"mobile"];
            }
            if ([mobile isEqualToString:@""]) {
                NSLog(@"没有手机号...");
            }else{
                NSLog(@"手机号...");
            }
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        default:
        break;
    }
}


- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
        // set to NO to disable all left utility buttons appearing
        return NO;
        break;
        case 2:
        // set to NO to disable all right utility buttons appearing
        return YES;
        break;
        default:
        break;
    }
    
    return YES;
}



@end
