//
//  MsgContactViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MsgContactViewController.h"
#import "CommonFuntion.h"
#import "CommonConstant.h"
#import "AFNHttp.h"
#import "ContactCell.h"
#import "MassMsgViewController.h"
#import "MsgSelectedContactOrCustomerViewController.h"
//#import "ContactSearchViewController.h"
#import "SearchViewController_zjp.h"

@interface MsgContactViewController ()<UITableViewDataSource,UITableViewDelegate,MsgSelectedContactDelegate,MassMsgDelegate>{
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

@implementation MsgContactViewController

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
    
//    [self readTestData];
    
    [self.tableviewContact reloadData];
}


#pragma mark - 读取测试数据
-(void)readTestData{
    id jsondata = [CommonFuntion readJsonFile:@"contact-list-data"];
    NSLog(@"jsondata:%@",jsondata);
    
    NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"contacts"];
    [self.arrayContact addObjectsFromArray:array];
}


#pragma mark - 已选中联系人回调
-(void)notifySelectedArray:(NSArray *)selectedArr{
    [selectedArray removeAllObjects];
    [selectedArray addObjectsFromArray:selectedArr];
    [self.tableviewContact reloadData];
    labelSelectedCount.text = [NSString stringWithFormat:@"已选择联系人:%li",[selectedArray count]];
}


#pragma mark - 发送短信结果回调
-(void)resultOfMassMsg:(BOOL)isSuccess desc:(NSString *)desc{
    if (isSuccess) {
        [self.navigationController popViewControllerAnimated:NO];
        
        [selectedArray removeAllObjects];
        [self.tableviewContact reloadData];
        labelSelectedCount.text = [NSString stringWithFormat:@"已选择联系人:%li",[selectedArray count]];
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
    self.arrayContact = [[NSMutableArray alloc] init];
    selectedArray = [[NSMutableArray alloc] init];
}

#pragma mark - nar  btn
-(void)addNarBarBtn{

    UIBarButtonItem *nextStep = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(pressNextStep)];
    self.navigationItem.rightBarButtonItem = nextStep;
}

///下一步
- (void)pressNextStep
{
    MassMsgViewController *controller = [[MassMsgViewController alloc] init];
    controller.delegate = self;
    controller.typeContact = @"contact";
    controller.arrayAllContact = selectedArray ;
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewContact = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height-40) style:UITableViewStylePlain];
    [self.tableviewContact registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCellIdentify"];
    self.tableviewContact.delegate = self;
    self.tableviewContact.dataSource = self;
    self.tableviewContact.sectionFooterHeight = 0;
    [self.view addSubview:self.tableviewContact];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewContact setTableFooterView:v];
    

    self.tableviewContact.tableHeaderView = [self creatHeadView];
}

#pragma mark - HeadView
///创建Head View
-(UIView *)creatHeadView{
    UIView *searView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44)];
    searView.backgroundColor = [UIColor colorWithRed:215.0f/255 green:215.0f/255 blue:215.0f/255 alpha:1.0f];
    
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSearch.frame = CGRectMake(5, 7, kScreen_Width-10, 30);
    [btnSearch setBackgroundImage:[UIImage imageNamed:@"img_searchbar_view_bg.png"] forState:UIControlStateNormal];
    [btnSearch addTarget:self action:@selector(gotoSearchView) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *content = @"搜索联系人";
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
}

///跳转到搜索页面
-(void)gotoSearchView{
    
    SearchViewController_zjp *controller = [[SearchViewController_zjp alloc] init];
    controller.typeFromView = @"SMSContactSearchViewController";
    controller.typeSearchStatus = @"default";
    controller.typeGoSearchResult = @"yes";
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Bottom View
-(void)creatBottomView{
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height-40, kScreen_Width, 40)];
    bottomView.backgroundColor = [UIColor colorWithRed:244.0f/255 green:244.0f/255 blue:244.0f/255 alpha:1.0f];
    
    labelSelectedCount = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 200, 20)];
    labelSelectedCount.font = [UIFont systemFontOfSize:12.0];
    labelSelectedCount.textColor = [UIColor grayColor];
    labelSelectedCount.text = [NSString stringWithFormat:@"已选择联系人:%li",[selectedArray count]];
    
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
    controller.typeContact = @"contact";
    controller.arrayAllContact = selectedArray;
    controller.title = @"已选择联系人";
    [self.navigationController pushViewController:controller animated:YES];
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

    [cell setCellFrame];
    [cell setCellDetails:[self.arrayContact objectAtIndex:indexPath.row]];
    
    NSDictionary *item = [self.arrayContact objectAtIndex:indexPath.row];
    NSString *mobile = @"";
    if ([item objectForKey:@"mobile"]) {
        mobile = [item objectForKey:@"mobile"];
    }
    if (![[mobile stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        long long contactId = [[item objectForKey:@"id"] longLongValue];
        if ([self isSelectedContact:contactId]) {
            [cell setSelectedBtnShow:@"yes"];
        }else{
            [cell setSelectedBtnShow:@"no"];
        }
    }
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ///手机号码不为空则可添加到已选择
    NSString *mobile = @"";
    if ([[self.arrayContact objectAtIndex:indexPath.row] objectForKey:@"mobile"]) {
        mobile = [[self.arrayContact objectAtIndex:indexPath.row] objectForKey:@"mobile"];
    }
    if (![[mobile stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        [self setContactSelectStatus:indexPath];
        [self.tableviewContact reloadData];
        labelSelectedCount.text = [NSString stringWithFormat:@"已选择联系人:%li",[selectedArray count]];
    }
}


///设置联系人选中状态
-(void)setContactSelectStatus:(NSIndexPath *)indexPath{
    
    //判断是否已经选中  如选中则删除掉  否则标记为添加
    NSDictionary *item = [self.arrayContact objectAtIndex:indexPath.row];
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
