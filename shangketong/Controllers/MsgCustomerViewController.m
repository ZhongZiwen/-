//
//  MsgCustomerViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MsgCustomerViewController.h"
#import "CommonFuntion.h"
#import "CommonConstant.h"
#import "AFNHttp.h"
#import "CustomerCell.h"
#import "MassMsgViewController.h"
#import "MsgSelectedContactOrCustomerViewController.h"
#import "SearchViewController_zjp.h"
#import "UIViewController+NavDropMenu.h"


@interface MsgCustomerViewController ()<UITableViewDataSource,UITableViewDelegate,MsgSelectedContactDelegate,MassMsgDelegate,SWTableViewCellDelegate>{
    ///页码
    NSInteger pageNo;
    
    ///选中的联系人
    NSMutableArray *selectedArray;
    
    ///底部view
    UIView *bottomView;
    ///已选中信息
    UILabel *labelSelectedCount;
}

@end

@implementation MsgCustomerViewController

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = VIEW_BG_COLOR;
    [self addNarBarBtn];
    [self initTableview];
    [self creatBottomView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self customDownMenuWithType:TableViewCellTypeDefault andSource:@[@"我负责的客户", @"我参与的客户", @"全部客户", @"我关注的客户", @"7天未跟进的客户", @"待审批的客户", @"最近浏览"] andDefaultIndex:0 andBlock:^(NSInteger index) {
        
    }];
    
  //  [self readTestData];
    
    [self.tableviewCustomer reloadData];
    [self getContactList];
}

#pragma mark - 已选中联系人回调
-(void)notifySelectedArray:(NSArray *)selectedArr{
    [selectedArray removeAllObjects];
    [selectedArray addObjectsFromArray:selectedArr];
    [self.tableviewCustomer reloadData];
    labelSelectedCount.text = [NSString stringWithFormat:@"已选择:%li",[selectedArray count]];
}

#pragma mark - 发送短信结果回调
-(void)resultOfMassMsg:(BOOL)isSuccess desc:(NSString *)desc{
    if (isSuccess) {
        [self.navigationController popViewControllerAnimated:NO];
        
        [selectedArray removeAllObjects];
        [self.tableviewCustomer reloadData];
        labelSelectedCount.text = [NSString stringWithFormat:@"已选择:%li",[selectedArray count]];
    }else{
        if (![desc isEqualToString:@""]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:desc
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"确定", nil];
            [alert show];
            
            [alert dismissWithClickedButtonIndex:0 animated:YES];
        }
        
    }
}

#pragma mark - 初始化数据
-(void)initData{
    self.arrayCustomer = [[NSMutableArray alloc] init];
    selectedArray = [[NSMutableArray alloc] init];
}

#pragma mark - nar  btn
-(void)addNarBarBtn{
    ///发短信
    if ([self.typeViewFrom isEqualToString:@"msgCustomer"]) {
        UIBarButtonItem *nextStep = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(pressNextStep)];
        self.navigationItem.rightBarButtonItem = nextStep;
    }else if ([self.typeViewFrom isEqualToString:@"addCustomer"]) {
        ///添加相关客户
        UIBarButtonItem *btnOk = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(pressOk)];
        self.navigationItem.rightBarButtonItem = btnOk;
        
        UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchItemPress)];
        self.navigationItem.rightBarButtonItems = @[btnOk,searchItem];
    }
}

///下一步
- (void)pressNextStep
{
    MassMsgViewController *controller = [[MassMsgViewController alloc] init];
    controller.delegate = self;
    controller.typeContact = @"customer";
    controller.arrayAllContact = selectedArray ;
    [self.navigationController pushViewController:controller animated:YES];
}


///确定
- (void)pressOk
{
    NSLog(@"%@", selectedArray);
    if (_BackCustomersBlock) {
        _BackCustomersBlock(selectedArray);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

///搜索事件
-(void)searchItemPress{
    SearchViewController_zjp *controller = [[SearchViewController_zjp alloc] init];
    controller.typeFromView = @"SMSCustomerSearchViewController";
    controller.typeSearchStatus = @"default";
    ///发短信
    if ([self.typeViewFrom isEqualToString:@"msgCustomer"]) {
        controller.typeGoSearchResult = @"yes";
    }else if ([self.typeViewFrom isEqualToString:@"addCustomer"]) {
        ///添加相关客户
        controller.typeGoSearchResult = @"no";
    }
    
    [self.navigationController pushViewController:controller animated:YES];
}



#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewCustomer = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height-40) style:UITableViewStylePlain];
    [self.tableviewCustomer registerNib:[UINib nibWithNibName:@"CustomerCell" bundle:nil] forCellReuseIdentifier:@"CustomerCellIdentify"];
    self.tableviewCustomer.delegate = self;
    self.tableviewCustomer.dataSource = self;
    self.tableviewCustomer.sectionFooterHeight = 0;
    [self.view addSubview:self.tableviewCustomer];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewCustomer setTableFooterView:v];
    
    self.tableviewCustomer.tableHeaderView = [self creatHeadView];
}

#pragma mark - HeadView
///创建Head View
-(UIView *)creatHeadView{
    ///发短信
    if ([self.typeViewFrom isEqualToString:@"msgCustomer"]) {
    }else if ([self.typeViewFrom isEqualToString:@"addCustomer"]) {
        ///添加相关客户
    }
    
    ///发短信
    if ([self.typeViewFrom isEqualToString:@"msgCustomer"]) {
        UIView *searView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44)];
        searView.backgroundColor = [UIColor colorWithRed:215.0f/255 green:215.0f/255 blue:215.0f/255 alpha:1.0f];
        
        UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSearch.frame = CGRectMake(5, 7, kScreen_Width-10, 30);
        [btnSearch setBackgroundImage:[UIImage imageNamed:@"img_searchbar_view_bg.png"] forState:UIControlStateNormal];
        [btnSearch addTarget:self action:@selector(gotoSearchView) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *content = @"搜索客户";
        CGSize sizeContent = [CommonFuntion getSizeOfContents:content Font:[UIFont systemFontOfSize:14.0] withWidth:kScreen_Width-20 withHeight:20];
        
        NSInteger vX = (kScreen_Width - (sizeContent.width + 22))/2;
        UIImageView *imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(vX, 13, 22, 22)];
        imgIcon.image = [UIImage imageNamed:@"img_search_icon.png"];
        
        UILabel *labelTag = [[UILabel alloc] initWithFrame:CGRectMake(vX+22, 5, sizeContent.width, 36)];
        labelTag.font = [UIFont systemFontOfSize:14.0];
        labelTag.textColor = [UIColor grayColor];
        labelTag.text = content;
        
        [searView addSubview:btnSearch];
        [searView addSubview:imgIcon];
        [searView addSubview:labelTag];
        
        return searView;
    }else if ([self.typeViewFrom isEqualToString:@"addCustomer"]) {
        ///添加相关客户
        return nil;
    }
    return nil;
}

///跳转到搜索页面
-(void)gotoSearchView{
    SearchViewController_zjp *controller = [[SearchViewController_zjp alloc] init];
    controller.typeFromView = @"SMSCustomerSearchViewController";
    controller.typeSearchStatus = @"default";
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Bottom View
-(void)creatBottomView{
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height-40, kScreen_Width, 40)];
    bottomView.backgroundColor = [UIColor colorWithRed:244.0f/255 green:244.0f/255 blue:244.0f/255 alpha:1.0f];
    
    labelSelectedCount = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 200, 20)];
    labelSelectedCount.font = [UIFont systemFontOfSize:12.0];
    labelSelectedCount.textColor = [UIColor grayColor];
    labelSelectedCount.text = [NSString stringWithFormat:@"已选择:%ti",[selectedArray count]];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, kScreen_Width, 44);
    [btn addTarget:self action:@selector(gotoSelectedView) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(kScreen_Width-30, 14, 6, 11)];
    imgIcon.image = [UIImage imageNamed:@"cellAccessory.png"];
    
    
    [bottomView addSubview:btn];
    [bottomView addSubview:labelSelectedCount];
    [bottomView addSubview:imgIcon];
    
    [self.view addSubview:bottomView];
}

///已选中联系人页面
-(void)gotoSelectedView{
    
    if ([selectedArray count] == 0) {
        return;
    }
    MsgSelectedContactOrCustomerViewController *controller = [[MsgSelectedContactOrCustomerViewController alloc] init];
    controller.delegate = self;
    controller.typeContact = @"customer";
    controller.arrayAllContact = selectedArray;
    controller.title = @"已选择客户";
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - 获取客户列表
-(void)getContactList{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInteger:pageNo] forKey:@"pageNo"];
    [params setObject:@"" forKey:@""];
    [params setObject:@"" forKey:@""];
    
    NSString *testUrl = @"http://192.168.5.54:9080/skt-user/mobile/customer/getCustomerList.do";
    // 发起请求
    __weak typeof(self) weak_self = self;
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP, GET_CRM_CUSTOMER_LIST_ACTION] params:params success:^(id responseObj) {
        //字典转模型
        NSLog(@"responseObj:%@",responseObj);
        NSDictionary *info = responseObj;
        
        if ([[info objectForKey:@"status"] integerValue] == 0) {
            
            if ([info objectForKey:@"customers"]) {
                //[weak_self readTestData:];
                [weak_self.arrayCustomer addObjectsFromArray:[info objectForKey:@"customers"]];
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
        [self.tableviewCustomer reloadData];
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        [self.tableviewCustomer reloadData];
    }];
}


#pragma mark - tableview delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.arrayCustomer) {
        return [self.arrayCustomer count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CustomerCellIdentify";
    CustomerCell *cell = (CustomerCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"CustomerCell" owner:self options:nil];
        cell = (CustomerCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    NSDictionary *item = [self.arrayCustomer objectAtIndex:indexPath.row];
    cell.delegate = self;
    [cell setCellFrame];
    [cell setLeftAndRightBtn:item];
    [cell setCellDetails:item];
    
    ///发短信
    if ([self.typeViewFrom isEqualToString:@"msgCustomer"]) {
        NSString *phone = @"";
        if ([item objectForKey:@"phone"]) {
            phone = [item objectForKey:@"phone"];
        }
        if (![[phone stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
            long long contactId = [[item objectForKey:@"id"] longLongValue];
            if ([self isSelectedContact:contactId]) {
                [cell setSelectedIconShow:@"yes"];
            }else{
                [cell setSelectedIconShow:@"no"];
            }
        }
    }else if ([self.typeViewFrom isEqualToString:@"addCustomer"]) {
        ///添加相关客户
        long long contactId = [[item objectForKey:@"id"] longLongValue];
        if ([self isSelectedContact:contactId]) {
            [cell setSelectedIconShow:@"yes"];
        }else{
            [cell setSelectedIconShow:@"no"];
        }
    }
    
    
    
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ///发短信
    if ([self.typeViewFrom isEqualToString:@"msgCustomer"]) {
        ///手机号码不为空则可添加到已选择
        NSString *phone = @"";
        if ([[self.arrayCustomer objectAtIndex:indexPath.row] objectForKey:@"phone"]) {
            phone = [[self.arrayCustomer objectAtIndex:indexPath.row] objectForKey:@"phone"];
        }
        if (![[phone stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
            [self setContactSelectStatus:indexPath];
            [self.tableviewCustomer reloadData];
            labelSelectedCount.text = [NSString stringWithFormat:@"已选择:%li",[selectedArray count]];
        }
    }else if ([self.typeViewFrom isEqualToString:@"addCustomer"]) {
        ///添加相关客户
        [self setContactSelectStatus:indexPath];
        [self.tableviewCustomer reloadData];
        labelSelectedCount.text = [NSString stringWithFormat:@"已选择:%li",[selectedArray count]];
    }
    
}


///设置联系人选中状态
-(void)setContactSelectStatus:(NSIndexPath *)indexPath{
    
    //判断是否已经选中  如选中则删除掉  否则标记为添加
    NSDictionary *item = [self.arrayCustomer objectAtIndex:indexPath.row];
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
    NSIndexPath *indexPath = [self.tableviewCustomer indexPathForCell:cell];
    NSLog(@"click index:%ld",indexPath.row);
    NSDictionary *item = [self.arrayCustomer objectAtIndex:indexPath.row];
    
    switch (index) {
        case 0:
        {
            BOOL isFollow = FALSE;
            if ([item objectForKey:@"isFollow"]) {
                isFollow = [[item objectForKey:@"isFollow"] boolValue];
            }
            if (isFollow) {
                NSLog(@"取消关注...");
            }else{
                NSLog(@"关注...");
            }
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 1:
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
        case 2:
        {
            NSString *phone = @"";
            if ([item objectForKey:@"phone"]) {
                phone = [item objectForKey:@"phone"];
            }
            if ([phone isEqualToString:@""]) {
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
