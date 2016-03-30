//
//  MeInfoViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "InfoViewController.h"
#import <UIImageView+WebCache.h>
#import "UIView+Common.h"
#import "UIImageView+LBBlurredImage.h"
#import "UIViewController+Expand.h"

#import "EditInfoViewController.h"
#import "CustomPopView.h"

#import "MenuChoiceView.h"
#import "MeBusinessHeadCell.h"
#import "MeBusinessAchieveCell.h"
#import "MeBusinessBehaviourCell.h"
#import "MeInfoCell.h"

#import "AFNHttp.h"
#import <MBProgressHUD.h>
#import "CommonFuntion.h"
#import "AFHTTPRequestOperationManager.h"

#import "CommonConstant.h"
#import "CommonStaticVar.h"
#import "WorkGroupRecordCellA.h"
#import "WorkGroupRecordCellB.h"
#import "WorkGroupRecordDetailsViewController.h"
#import "MJRefresh.h"
#import "PhotoBroswerVC.h"
#import "MapViewViewController.h"
#import "ReleaseViewController.h"
#import "KnowledgeFileDetailsViewController.h"
#import "InfoViewController.h"
#import "MassMsgViewController.h"
#import "NSUserDefaults_Cache.h"
#import "AddressBookActionSheet.h"
#import "CommonModuleFuntion.h"
#import "AddressBook.h"
#import "ChatViewController.h"
#import "IM_FMDB_FILE.h"
#import "ZoomPicture.h"

#import "WorkGroupRecordViewController.h"
#import "ActivityDetailViewController.h"
#import "LeadDetailViewController.h"
#import "CustomerDetailViewController.h"
#import "ContactDetailViewController.h"
#import "OpportunityDetailController.h"
#import "Lead.h"
#import "Contact.h"
#import "Customer.h"
#import "SaleChance.h"
#import "AFSoundPlaybackHelper.h"
#import "DepartViewController.h"
#import "DepartGroupModel.h"

#import "ReportToServiceViewController.h"

#import "WRWorkResultHUD.h"

#define kCellIdentifier_busiHead @"MeBusinessHeadCell"
#define kCellIdentifier_busiAchieve @"MeBusinessAchieveCell"
#define kCellIdentifier_busiBehaviour @"MeBusinessBehaviourCell"
#define kCellIdentifier_info @"MeInfoCell"

#define TopImageHight 0.0f
///每页条数
#define PageSize 10

typedef NS_ENUM(NSInteger, TableViewSourceType) {
    TableViewSourceTypeTrends = 0,      // 动态
    TableViewSourceTypeInfomation = 1 ,  // 资料
    TableViewSourceTypeBusiness = 2    // 业务
    
};

@interface InfoViewController ()<UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate,WorkGroupDelegate,MassMsgDelegate,UITabBarControllerDelegate, TTTAttributedLabelDelegate>{
    NSInteger pageNo;//页数下标
    BOOL isMoreData;///是否有更多数据
    
    //变焦图片做底层
    UIImageView *_zoomImageView;
    CGFloat heightTop;
    CGFloat yTop;
    CGFloat heightNoData;
    
    ///是否请求数据
    BOOL isRequest;
    
    ///标记删除操作
    NSInteger indexDelete;
    long long trendIdDelete;
}

@property (strong, nonatomic) UIView *navCustomView;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) WRWorkResultHUD *hud;
@property (nonatomic, weak) UITableView *m_tableView;
@property (strong, nonatomic) UIView *footerTableView;
@property (strong, nonatomic) UIView *footerTableViewDatas;
@property (strong, nonatomic) UIButton *rightButton;

@property (nonatomic, strong) UIImageView *h_icon;
@property (nonatomic, strong) UILabel *h_name;
@property (nonatomic, strong) UILabel *h_detail;

///其他联系人联系方式   拨打电话  邮件 消息
@property (nonatomic, strong) UIView *h_contactway;
@property (nonatomic, strong) UIButton *h_call;
@property (nonatomic, strong) UIButton *h_email;
@property (nonatomic, strong) UIButton *h_msg;

///动态、业务、资料
@property (nonatomic, strong)MenuChoiceView *viewOfSectionHead;
@property (nonatomic, strong)MenuChoiceView *viewOfSectionHeadTable;

@property (nonatomic, assign) TableViewSourceType sourceType;

@property (nonatomic, strong) NSMutableDictionary *infoDict;

///动态
@property(strong,nonatomic) NSMutableArray *arrayWorkGroup;

/** 初始化table headerView*/
- (UIView*)customHeaderView;
- (void)startAnimation;
- (void)stopAnimation;
@end

@implementation InfoViewController

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /*
    NSData *infoData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"info_data" ofType:@"json"]];
    _infoDict = [NSJSONSerialization JSONObjectWithData:infoData options:NSJSONReadingAllowFragments error:nil];
     */
    
    isRequest = FALSE;
    heightNoData = 0;
    heightTop = 110;
    yTop = 85;
    if (self.infoTypeOfUser == InfoTypeOthers) {
        heightTop = 190;
        yTop = 125;
    }
    
    
    ///检查是否有网络
    if ([CommonFuntion checkNetworkState]) {
        _sourceType = TableViewSourceTypeTrends;
        
        _infoDict = [[NSMutableDictionary alloc] init];
        ///获取个人资料
        [self getUserDataFromService];
        [self initDynamicData];
        [self getCacheData];
        return;
    }else{
        [_m_tableView removeFromSuperview];
        self.view.backgroundColor = TABLEVIEW_BG_COLOR;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无法连接到网络,请检查您的网络配置。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alert.tag = 500;
        [alert show];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //    [_m_tableView setContentOffset:CGPointMake(0,-1) animated:NO];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopVoice" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = TABLEVIEW_BG_COLOR;
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    [self.view addSubview:self.backgroundImageView];
    [self.view addSubview:self.navCustomView];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [tableView setY:64];
    [tableView setWidth:kScreen_Width];
    [tableView setHeight:kScreen_Height - CGRectGetMinY(tableView.frame)];
//    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableHeaderView = [self customHeaderView];
    tableView.tableFooterView = self.footerTableView;
    tableView.backgroundColor = [UIColor clearColor];
    /*
    [tableView registerClass:[MeBusinessHeadCell class] forCellReuseIdentifier:kCellIdentifier_busiHead];
    [tableView registerClass:[MeBusinessAchieveCell class] forCellReuseIdentifier:kCellIdentifier_busiAchieve];
    [tableView registerClass:[MeBusinessBehaviourCell class] forCellReuseIdentifier:kCellIdentifier_busiBehaviour];

     */
    [tableView registerClass:[MeInfoCell class] forCellReuseIdentifier:kCellIdentifier_info];
    [self.view addSubview:tableView];
    _m_tableView = tableView;
    
//    [self addTopZoomView];
    
    
    ///添加上拉和下拉
    [self setupRefresh];
    
    //动态、业务、资料  sectionview
    [self initViewofSectionHead];
}

///顶部拉伸效果
-(void)addTopZoomView{
    ///顶部view拉伸效果
    _m_tableView.contentInset = UIEdgeInsetsMake(TopImageHight, 0, 0, 0);
    _zoomImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"common_headview_bg.png"]];
//    _zoomImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"top_image.png"]];
    
    _zoomImageView.frame = CGRectMake(0, -TopImageHight, kScreen_Width, TopImageHight);
    
    
    _zoomImageView.contentMode = UIViewContentModeScaleAspectFill;
    _m_tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _zoomImageView.autoresizesSubviews = YES;
    
    [_m_tableView addSubview:_zoomImageView];
    [_m_tableView sendSubviewToBack:_zoomImageView];
}

///动态、业务、资料  sectionview
-(void)initViewofSectionHead{
    __weak typeof(self) weak_self = self;
    if (self.viewOfSectionHead == nil) {
        self.viewOfSectionHead = [[MenuChoiceView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, 44) withDefaultIndex:TableViewSourceTypeTrends];
        self.viewOfSectionHead.menuArray = @[@"动态", @"资料"];
        self.viewOfSectionHead.selectedBlock = ^(NSInteger index) {
            NSLog(@"viewOfSectionHead index:%ti",index);
            [weak_self.viewOfSectionHeadTable setIndexSelect:index];
            weak_self.sourceType = index;
//            [weak_self.m_tableView setContentOffset:CGPointMake(0,-65) animated:NO];
        };
        
        [self.view addSubview:self.viewOfSectionHead];
        self.viewOfSectionHead.hidden = YES;
    }
}

-(void)narRightBtn{
    if (self.infoTypeOfUser == InfoTypeMyself) {

    }else{

        if (_infoDict) {
            NSLog(@"attentionItemPress3 _infoDict:%@",_infoDict);
            NSInteger isAttention = [[_infoDict safeObjectForKey:@"isAttention"] integerValue];
            if (isAttention == 1) {
                [_rightButton setTitle:@"关注" forState:UIControlStateNormal];
            }else{
                [_rightButton setTitle:@"已关注" forState:UIControlStateNormal];
            }
            
        }
        
    }
}

#pragma mark - Private Method
- (UIView*)customHeaderView {
    // index_header_backgroundview
    CGFloat height = 150;
    if (self.infoTypeOfUser == InfoTypeOthers) {
        height = 190;
    }
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, height)];
    bgView.backgroundColor = [UIColor clearColor];
    
    [self.h_icon setCenter:CGPointMake(kScreen_Width/2.0, 44)];
    [bgView addSubview:self.h_icon];
    
    [self.h_name setCenterY:90];
    [bgView addSubview:self.h_name];
    
    [self.h_detail setCenterY:120];
    [bgView addSubview:self.h_detail];
    
    ///非自己才显示联系方式栏
    if (self.infoTypeOfUser == InfoTypeOthers) {
        [self.h_contactway setCenterY:170];
        [bgView addSubview:self.h_contactway];
    }
    
    
    return bgView;
}

- (void)startAnimation {
    _titleLabel.hidden = YES;
    _hud.hidden = NO;
    [_hud startAnimationWith:@"加载中"];
}

- (void)stopAnimation {
    _titleLabel.hidden = NO;
    _hud.hidden = YES;
    [_hud stopAnimationWith:@"加载结束"];
}

#pragma mark - Event response
- (void)backButtonPress {
    [self.navigationController popViewControllerAnimated:YES];
}

// 跳转编辑
- (void)editItemPress {
    __weak typeof(self) weak_self = self;
    EditInfoViewController *editInfoController = [[EditInfoViewController alloc] init];
    editInfoController.title = @"编辑";
    editInfoController.userInfo = _infoDict;
    editInfoController.userIcon = _h_icon.image;
    editInfoController.UpdateUserInfosBlock = ^(NSDictionary* infos){
//        weak_self.infoDict = infos;
//        [weak_self notifyUserInfos];
        [weak_self getUserDataFromService];
    };
    [self.navigationController pushViewController:editInfoController animated:YES];
}

#pragma mark - 关注
-(void)attentionItemPress{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSString *url = @"";
    NSInteger isAttention = [[_infoDict safeObjectForKey:@"isAttention"] integerValue];
    if (isAttention == 0) {
        url = CANCEL_FOLLOW_ACTION;
    }else if (isAttention == 1){
        url = ADD_FOLLOW_ACTION;
    }
    
    long long uid = -1;
    if ([_infoDict objectForKey:@"uid"]) {
        uid = [[_infoDict safeObjectForKey:@"uid"] longLongValue];
    }
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:[NSNumber numberWithLongLong:uid] forKey:@"contactId"];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA,url] params:params success:^(id responseObj) {
        [hud hide:YES];
        //字典转模型
        NSLog(@"关注/取消关注 responseObj:%@",responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            
            if (isAttention == 0) {
                [_infoDict setObject:[NSNumber numberWithInteger:1] forKey:@"isAttention"];
            }else if (isAttention == 1){
                [_infoDict setObject:[NSNumber numberWithInteger:0] forKey:@"isAttention"];
            }
            NSLog(@"attentionItemPress2 _infoDict:%@",_infoDict);
            [self narRightBtn];
        }else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self attentionItemPress];
            };
            [comRequest loginInBackground];
        }else{
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"操作失败";
            }
            NSLog(@"desc:%@",desc);
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        NSLog(@"error:%@",error);
        
    }];
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (_sourceType == TableViewSourceTypeTrends) {
        if (self.arrayWorkGroup && [self.arrayWorkGroup count] > 0) {
            NSLog(@"TableViewSourceTypeTrends numberOfSectionsInTableView :%ti",[self.arrayWorkGroup count]);
            return [self.arrayWorkGroup count];
        }
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_sourceType == TableViewSourceTypeTrends) {
        if (section == 0) {
            return 64.0;
        }
        return 20.0;
    }
    return 64.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (_sourceType == TableViewSourceTypeTrends) {
//        if ( !isMoreData &&  self.arrayWorkGroup && (section == [self.arrayWorkGroup count]-1)) {
//            return 70.;
//        }
    }
    
    return 0.01;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    if (_sourceType == TableViewSourceTypeTrends && section != 0) {
        UIView *sectionHeaderView = [[UIView alloc] init];
        [sectionHeaderView setWidth:kScreen_Width];
        [sectionHeaderView setHeight:20.0];
        sectionHeaderView.backgroundColor = kView_BG_Color;
        return sectionHeaderView;
    }else{
        __weak __block typeof(self) weak_self = self;
//        MenuChoiceView *menuChoiceView = [[MenuChoiceView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, 44) withDefaultIndex:_sourceType];
//        menuChoiceView.menuArray = @[@"动态", @"业务", @"资料"];
//        menuChoiceView.selectedBlock = ^(NSInteger index) {
//            NSLog(@"index:%ti",index);
//            weak_self.sourceType = index;
//        };
        
        
        UIView *viewHead = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44+20)];
        viewHead.backgroundColor = kView_BG_Color;
        
        if (self.viewOfSectionHeadTable == nil) {
            self.viewOfSectionHeadTable = [[MenuChoiceView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44) withDefaultIndex:TableViewSourceTypeTrends];
            self.viewOfSectionHeadTable.menuArray = @[@"动态", @"资料"];
            self.viewOfSectionHeadTable.selectedBlock = ^(NSInteger index) {
                NSLog(@"viewOfSectionHeadTable index:%ti",index);
                weak_self.sourceType = index;
                [weak_self.viewOfSectionHead setIndexSelect:index];
//                [weak_self.m_tableView setContentOffset:CGPointMake(0,-65) animated:NO];
            };
        }
        [viewHead addSubview:self.viewOfSectionHeadTable];
        return viewHead;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    switch (_sourceType) {
        case TableViewSourceTypeTrends:
            height = [self getHeightByCellType:indexPath];
            break;
        case TableViewSourceTypeBusiness:
            if (indexPath.row == 0) {
                height = 100;
            }else {
                height = [MeBusinessAchieveCell cellHeight];
            }
            break;
        case TableViewSourceTypeInfomation: {
            
            NSArray *detailArray = [self getUserInfoDic];
            if (detailArray && [detailArray count] > indexPath.row) {
                height = [MeInfoCell cellHeightWith:detailArray[indexPath.row]];
            }else{
                height = 64.0f;
            }
            
        }
            break;
        default:
            break;
    }
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberRows = 0;
    switch (_sourceType) {
        case TableViewSourceTypeTrends:
            NSLog(@"TableViewSourceTypeTrends numberOfRowsInSection--->");
            if (self.arrayWorkGroup && [self.arrayWorkGroup count] > 0) {
                numberRows = 1;
            }else{
                numberRows = 0;
            }
            break;
        case TableViewSourceTypeBusiness:
            numberRows = 3;
            break;
        case TableViewSourceTypeInfomation:
            numberRows = 5;
            break;
        default:
            break;
    }
    return numberRows;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (_sourceType) {
        case TableViewSourceTypeTrends: {
            
//            if (indexPath.section == self.arrayWorkGroup.count - 1) {
//                CGRect rectInTableView = [self.m_tableView rectForRowAtIndexPath:indexPath];
//                CGRect rectInScreen = [self.m_tableView convertRect:rectInTableView toView:self.m_tableView.superview];
//                if (CGRectGetMaxY(rectInScreen) < kScreen_Height) {
//                    UIView *footerView = [[UIView alloc] init];
//                    [footerView setWidth:kScreen_Width];
//                    [footerView setHeight:kScreen_Height - CGRectGetMaxY(rectInScreen)];
//                    footerView.backgroundColor = [UIColor brownColor];
//                    self.m_tableView.tableFooterView = footerView;
//                }
//                else {
//                    self.m_tableView.tableFooterView = nil;
//                }
//                NSLog(@"last cell minY = %f, maxY = %f", CGRectGetMinY(rectInScreen), CGRectGetMaxY(rectInScreen));
//            }

            WorkGroupType type = [self getWorkTypeByIndex:indexPath.section];
            
            ///不可操作的评论
            if (type == WorkGroupTypeA) {
                static NSString *identifyA = @"WorkGroupRecordCellAIdentify";
                WorkGroupRecordCellA *cell = [tableView dequeueReusableCellWithIdentifier:identifyA];
                if (!cell)
                {
                    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"WorkGroupRecordCellA" owner:self options:nil];
                    cell = (WorkGroupRecordCellA*)[array objectAtIndex:0];
                    [cell awakeFromNib];
                }
                [cell setContentDetails:[self.arrayWorkGroup objectAtIndex:indexPath.section] indexPath:indexPath];
                
                return cell;
            }else if (type == WorkGroupTypeB) {
                WorkGroupRecordCellB *cell = [tableView dequeueReusableCellWithIdentifier:@"WorkGroupRecordCellBIdentify"];
                if (!cell)
                {
                    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"WorkGroupRecordCellB" owner:self options:nil];
                    cell = (WorkGroupRecordCellB*)[array objectAtIndex:0];
                    [cell awakeFromNib];
                }
                cell.delegate = self;
                cell.labelContent.delegate = self;
                NSDictionary *item;
                if ([[CommonStaticVar getTypeOfWorkGroupCellInfo] isEqualToString:@"comment"])  {
                    
                    ///消息 提到我的
                    if ([[[self.arrayWorkGroup objectAtIndex:indexPath.section] objectForKey:@"type"] integerValue] == 1) {
                        item = [[self.arrayWorkGroup objectAtIndex:indexPath.section] objectForKey:@"comment"];
                        
                        NSLog(@"comment-item:%@",item);
                    }else{
                        ///type == 0
                        item = [[self.arrayWorkGroup objectAtIndex:indexPath.section] objectForKey:@"feed"];
                    }
                    
                }else{
                    item = [self.arrayWorkGroup objectAtIndex:indexPath.section];
                }
                
                [cell setContentDetails:item indexPath:indexPath byCellStatus:WorkGroupTypeStatusCell];
                [cell addClickEventForCellView:item withIndex:indexPath];
                
                return cell;
            }
            return nil;
            
        }
            break;
        case TableViewSourceTypeBusiness: {
            if (indexPath.row == 0) {
                __weak typeof(self) weak_self = self;
                MeBusinessHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_busiHead forIndexPath:indexPath];
                cell.conditionBlock = ^(UIButton *button) {
                    CGPoint center = [button.superview convertPoint:button.center toView:weak_self.view];
                    CustomPopView *popView = [[CustomPopView alloc] initWithPoint:CGPointMake(0, center.y + 64 + 15) titles:@[@"包含下属的数据", @"包含团队成员的数据"] imageNames:@[@"accessory_message_normal", @"more_select"]];
                    popView.selectBlock = ^(NSInteger index) {
                        NSLog(@"index = %d", index);
                    };
                    [popView show];
                };
                return cell;
            }else {
                MeBusinessAchieveCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_busiAchieve forIndexPath:indexPath];
                if (indexPath.row == 1) {
                    [cell configWithSource:nil andChartType:ChartTypeCircle];
                }else {
                    [cell configWithSource:nil andChartType:ChartTypeFunnel];
                }
                return cell;
            }
        }
            break;
        case TableViewSourceTypeInfomation: {
            MeInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_info forIndexPath:indexPath];
            NSArray *titleArray = @[@"邮箱", @"电话", @"手机", @"自我介绍", @"业务专长"];
            NSArray *detailArray = [self getUserInfoDic];
            if (detailArray && [detailArray count] > indexPath.row) {
                [cell configWithTitleString:titleArray[indexPath.row] andDetailString:detailArray[indexPath.row]];
            }else{
                [cell configWithTitleString:titleArray[indexPath.row] andDetailString:@""];
            }
            
            [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:10.0f];
            
            return cell;
        }
            break;
        default:
            return nil;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_sourceType == TableViewSourceTypeTrends) {
        NSDictionary *item = [self.arrayWorkGroup objectAtIndex:indexPath.section];
        
        WorkGroupType type = [self getWorkTypeByIndex:indexPath.section];
        
        if (type == WorkGroupTypeA) {
            
            ///这里做其他判断跳转
            ///system
            
            
        }else{
            __weak typeof(self) weak_self = self;
            WorkGroupRecordDetailsViewController *controller = [[WorkGroupRecordDetailsViewController alloc] init];
            controller.isShowKeyBoardView = @"no";
            controller.hidesBottomBarWhenPushed = YES;
            controller.dicWorkGroupDetailsOld = item;
            controller.sectionOfDic = indexPath.section;
            ///更新赞的状态和数量
            controller.UpdatePriaseStatus = ^(NSInteger section){
                [weak_self updateFeedCountAndFlag:section];
            };
            
            ///更新收藏状态
            controller.UpdateFavStatus = ^(NSInteger section, NSString *action){
                [weak_self updateFavFlag:action index:section];
            };
            
            ///删除动态
            controller.DeleteTrendStatus = ^(NSInteger section){
                [weak_self deleteTrend:section];
            };
            
            ///评论动态
            controller.CommentTrendStatus = ^(NSInteger section,NSString *optionFlag){
                [weak_self updateReviewComment:section withFlag:optionFlag];
            };
            
            ///转发动态
            controller.UpdateByForwardTrend = ^(){
                ///重新请求数据
                [weak_self notifyDataByHeadRequest];
            };
            
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    UIColor * color = [UIColor colorWithHexString:@"0x2e3440"];
    CGFloat offsetY = sender.contentOffset.y;
    if (offsetY > 50) {
        CGFloat alpha = MIN(1, 1 - ((50 + 64 - offsetY) / 64));
        _navCustomView.backgroundColor = [color colorWithAlphaComponent:alpha];
    }
    else {
        _navCustomView.backgroundColor = [color colorWithAlphaComponent:0];
    }
    
    CGFloat y = sender.contentOffset.y;
    
    ///动态为空的情况  业务为空同理设置heightNoData
//    if (_sourceType == TableViewSourceTypeTrends && [self.arrayWorkGroup count] == 0) {
//        if (y <= -150){
//            CGRect frame = _zoomImageView.frame;
//            frame.origin.y = y;
//            frame.size.height =  -y+heightTop;
//            //            NSLog(@"height:%f",frame.size.height);
//            _zoomImageView.frame = frame;
//        }else if (y <= -64) {
//            CGRect frame = _zoomImageView.frame;
//            frame.origin.y = y;
//            frame.size.height =  -y+heightTop+heightNoData;
//            _zoomImageView.frame = frame;
//        }
//    }else{
//        if (y <= -64) {
//            CGRect frame = _zoomImageView.frame;
//            frame.origin.y = y;
//            frame.size.height =  -y+heightTop;
//            //            NSLog(@"height:%f",frame.size.height);
//            _zoomImageView.frame = frame;
//        }
//        
//    }
    
    CGFloat height = 150;
    if (self.infoTypeOfUser == InfoTypeOthers) {
        height = 190;
    }
    
    if (y >= height) {
        if(self.viewOfSectionHead){
            self.viewOfSectionHead.hidden = NO;
        }
    }else{
        if(self.viewOfSectionHead){
            self.viewOfSectionHead.hidden = YES;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat y = scrollView.contentOffset.y;
    if (y < -64) {
        [self startAnimation];
        [self headerRereshing];
    }
}


#pragma mark - setters and getters
- (void)setSourceType:(TableViewSourceType)sourceType {
    if (_sourceType == sourceType)
        return;
    _sourceType = sourceType;
    
    if (_sourceType == TableViewSourceTypeInfomation) {
        _m_tableView.tableFooterView = [[UIView alloc] init];
    }
    else if (_sourceType == TableViewSourceTypeTrends) {
        if (_arrayWorkGroup.count > 1) {
            _m_tableView.tableFooterView = nil;
        }else if (_arrayWorkGroup.count == 1) {
            _m_tableView.tableFooterView = self.footerTableViewDatas;
        }
        else {
            _m_tableView.tableFooterView = self.footerTableView;
        }
    }
    ///控制下拉上拉控件显示与隐藏
    [self setRereshingViewShow];
    [_m_tableView reloadData];
}

- (UIImageView*)h_icon {
    if (!_h_icon) {
        _h_icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _h_icon.layer.cornerRadius = 10;
        _h_icon.layer.masksToBounds = YES;
        _h_icon.contentMode = UIViewContentModeScaleAspectFill;
        _h_icon.clipsToBounds = YES;
        
        NSString *icon = @"";
        [_h_icon sd_setImageWithURL:[NSURL URLWithString:icon] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shouBigPhoto:)];
        _h_icon.userInteractionEnabled = YES;
        [_h_icon addGestureRecognizer:tap];
    }
    return _h_icon;
}

- (UILabel*)h_name {
    if (!_h_name) {
        _h_name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
        _h_name.font = [UIFont systemFontOfSize:16];
        _h_name.textAlignment = NSTextAlignmentCenter;
        _h_name.textColor = [UIColor whiteColor];
        _h_name.text = @"";
    }
    return _h_name;
}

- (UILabel*)h_detail {
    if (!_h_detail) {
        _h_detail = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
        _h_detail.font = [UIFont systemFontOfSize:14];
        _h_detail.textAlignment = NSTextAlignmentCenter;
        _h_detail.textColor = [UIColor whiteColor];
        _h_detail.text = [NSString stringWithFormat:@""];
    }
    return _h_detail;
}


- (UIView*)h_contactway {
    if (!_h_contactway) {
        _h_contactway = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 40)];
        _h_contactway.backgroundColor = [UIColor clearColor];
        
        UIImageView *imgline = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 1)];
        imgline.image = [CommonFuntion createImageWithColor:[UIColor colorWithRed:215.0f/255 green:215.0f/255 blue:215.0f/255 alpha:1.0f]];
        [_h_contactway addSubview:imgline];
        imgline.hidden = YES;
        ///三按钮
        [_h_contactway addSubview:self.h_call];
        [_h_contactway addSubview:self.h_email];
        [_h_contactway addSubview:self.h_msg];
        
        _h_call.hidden = NO;
        _h_email.hidden = NO;
        _h_msg.hidden = NO;
    }
    return _h_contactway;
}


- (UIButton*)h_call {
    if (!_h_call) {
        _h_call = [UIButton buttonWithType:UIButtonTypeCustom];
        _h_call.frame = CGRectMake((kScreen_Width/3-20)/2, 10, 20, 20);
        [_h_call setImage:[UIImage imageNamed:@"profile_homepage_tel.png"] forState:UIControlStateNormal];
        [_h_call setImage:[UIImage imageNamed:@"profile_homepage_tel_on.png"] forState:UIControlStateHighlighted];
        [_h_call addTarget:self action:@selector(callContact) forControlEvents:UIControlEventTouchUpInside];
    }
    return _h_call;
}

- (UIButton*)h_email {
    if (!_h_email) {
        _h_email = [UIButton buttonWithType:UIButtonTypeCustom];
        _h_email.frame = CGRectMake(kScreen_Width/3+(kScreen_Width/3-20)/2, 10, 20, 20);
        [_h_email setImage:[UIImage imageNamed:@"profile_homepage_mail.png"] forState:UIControlStateNormal];
        [_h_email setImage:[UIImage imageNamed:@"profile_homepage_mail_on.png"] forState:UIControlStateHighlighted];
        [_h_email addTarget:self action:@selector(emailContact) forControlEvents:UIControlEventTouchUpInside];
    }
    return _h_email;
}

- (UIButton*)h_msg {
    if (!_h_msg) {
        _h_msg = [UIButton buttonWithType:UIButtonTypeCustom];
        _h_msg.frame = CGRectMake(kScreen_Width-(kScreen_Width/3)+(kScreen_Width/3-20)/2, 10, 20, 20);
        [_h_msg setImage:[UIImage imageNamed:@"profile_homepage_msg_active.png"] forState:UIControlStateNormal];
        [_h_msg setImage:[UIImage imageNamed:@"profile_homepage_msg_active_on.png"] forState:UIControlStateHighlighted];
        [_h_msg addTarget:self action:@selector(msgContact) forControlEvents:UIControlEventTouchUpInside];
    }
    return _h_msg;
}

#pragma mark - 拨打电话  邮件  消息事件

-(void)showCallActionSheet{
    
    NSString *mobile = @"";
    if (_infoDict && [_infoDict objectForKey:@"mobile"]) {
        mobile = [_infoDict safeObjectForKey:@"mobile"];
    }
    
    NSString *phone = @"";
    if (_infoDict && [_infoDict objectForKey:@"phone"]) {
        phone = [_infoDict safeObjectForKey:@"phone"];
    }
    
    AddressBookActionSheet *actionSheet = [[AddressBookActionSheet alloc] initWithCancelTitle:@"取消" andMobile:mobile andPhone:phone];
    __weak typeof(self) weak_self = self;
    actionSheet.phoneBlock = ^(NSString *tel) {
        [weak_self takePhoneWithNumber:tel];
    };
    actionSheet.msgBlock = ^(NSString *tel) {
        [weak_self sendMessageWithRecipients:@[tel]];
    };
//    actionSheet.sendSMSBlock = ^(NSString *mobile){
//        NSLog(@"发送短信:%@",mobile);
//        [weak_self sendSMS:mobile];
//    };
//    
//    actionSheet.callContactBlock = ^(NSString *mobile){
//        NSLog(@"打电话:%@",mobile);
//        [weak_self callTA:mobile];
//    };
    [actionSheet show];
}



-(void)callContact{
    [self showCallActionSheet];
}


-(void)callTA:(NSString *)mobile{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        
        if (![mobile isEqualToString:@""]) {
            [CommonFuntion callToCurPhoneNum:mobile atView:self.view];
        }
        [CommonModuleFuntion setLatelyContactByMobile:mobile];
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"当前设备不支持拨打电话" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - 发送短信
-(void)sendSMS:(NSString *)mobile{
    AddressBook *contactItem = (AddressBook*)[CommonModuleFuntion getContactNameByMobile:mobile];
    
    MassMsgViewController *controller = [[MassMsgViewController alloc] init];
    controller.delegate = self;
    ///详情页面发送消息 直接传递name phone
    controller.typeContact = @"commondetailscall";
    controller.arrayAllContact = nil ;
    controller.contactName = contactItem.name;
    controller.contactPhone = mobile;
    [self.navigationController pushViewController:controller animated:YES];
    [CommonModuleFuntion setLatelyContactByMobile:mobile];
}

-(void)resultOfMassMsg:(BOOL)isSuccess desc:(NSString *)desc{
    if (isSuccess) {
        [CommonFuntion showToast:@"发送成功" inView:self.view];
    }else{
        [CommonFuntion showToast:desc inView:self.view];
    }
    
}


-(void)emailContact{
    
    NSString *email = @"";
    if (_infoDict && [_infoDict objectForKey:@"email"]) {
        email = [_infoDict safeObjectForKey:@"email"];
    }
    if (![email isEqualToString:@""]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles: [NSString stringWithFormat:@"发送邮件给:%@",email],nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        actionSheet.tag = 10086;
        [actionSheet showInView:self.view];
    }
}

-(void)msgContact{
//    MassMsgViewController *controller = [[MassMsgViewController alloc] init];
//    controller.delegate = self;
//    ///详情页面发送消息 直接传递name phone
//    controller.typeContact = @"commondetailscall";
//    controller.arrayAllContact = nil ;
//    controller.contactName = @"赵军平";
//    controller.contactPhone = @"13918745346";
//    [self.navigationController pushViewController:controller animated:YES];
    NSMutableArray *contactArray = [NSMutableArray arrayWithCapacity:0];
    [contactArray addObjectsFromArray:[IM_FMDB_FILE result_IM_AddressBookOneContact:_userId]];
    ChatViewController *controller = [[ChatViewController alloc] init];
    controller.usersArray = contactArray;
    controller.pushType = ControllerPushTypeStartChatVC;
    // 会话列表界面
    [self.navigationController pushViewController:controller animated:YES];
//    [CommonFuntion showToast:@"发消息" inView:self.view];
}


#pragma mark - 获取个人信息数据
-(void)getUserDataFromService{
    
    [self startAnimation];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    ///非自己
    if (self.infoTypeOfUser == InfoTypeOthers) {
        [params setObject:[NSNumber numberWithLongLong:self.userId] forKey:@"uid"];
//        [params setObject:[NSString stringWithFormat:@"%lld",self.userId] forKey:@"id"];
    }
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA,GET_CONTACT_INFO_ACTION] params:params success:^(id responseObj) {
        [self stopAnimation];
        //字典转模型
        NSLog(@"个人资料 responseObj:%@",responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            [_infoDict addEntriesFromDictionary:responseObj];
            
            [self narRightBtn];
            [self notifyUserInfos];
            [self notifyUserContactWay];
        }else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getUserDataFromService];
            };
            [comRequest loginInBackground];
        }else{
            NSString *desc = [responseObj safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            NSLog(@"desc:%@",desc);
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        [self stopAnimation];
        NSLog(@"error:%@",error);
        
    }];
}


///展示的个人信息
-(NSArray *)getUserInfoDic{
    NSArray *arrUserInfo = nil;
    if (_infoDict) {
        NSString *phone = [_infoDict safeObjectForKey:@"phone"];
        NSString *extension = [_infoDict safeObjectForKey:@"extension"];
        if (![extension isEqualToString:@""]) {
            phone = [NSString stringWithFormat:@"%@ - %@",phone,extension];
        }
        arrUserInfo = @[[_infoDict safeObjectForKey:@"email"], phone, [_infoDict safeObjectForKey:@"mobile"],[_infoDict safeObjectForKey:@"selfIntro"], [_infoDict safeObjectForKey:@"expertise"]];
    }
    return arrUserInfo;
}

///刷新UI显示
-(void)notifyUserInfos{
    _h_name.text = [_infoDict safeObjectForKey:@"name"];
    _h_detail.text = [NSString stringWithFormat:@"%@  %@", [_infoDict safeObjectForKey:@"depart"], [_infoDict safeObjectForKey:@"post"]];
    [_h_icon sd_setImageWithURL:[NSURL URLWithString:[_infoDict safeObjectForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
    [self.m_tableView reloadData];
    
    ///非自己
    if (self.infoTypeOfUser == InfoTypeMyself) {
        NSDictionary *userInfo = [NSUserDefaults_Cache getUserInfo];
        
        if(userInfo){
            NSString *name = [_infoDict safeObjectForKey:@"name"];
            NSString *icon = [_infoDict safeObjectForKey:@"icon"];
            
            NSMutableDictionary *dicInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
            if (![name isEqualToString:@""]) {
                [dicInfo setObject:name forKey:@"name"];
            }
            
            if (![icon isEqualToString:@""]) {
                [dicInfo setObject:icon forKey:@"icon"];
            }
            [NSUserDefaults_Cache setUserInfo:dicInfo];
        }
    }
    
}

///刷新UI显示
-(void)notifyUserContactWay{
    
    NSString *mobile = @"";
    if (_infoDict && [_infoDict objectForKey:@"mobile"]) {
        mobile = [_infoDict safeObjectForKey:@"mobile"];
    }
    
    NSString *email = @"";
    if (_infoDict && [_infoDict objectForKey:@"email"]) {
        email = [_infoDict safeObjectForKey:@"email"];
    }
    _h_call.hidden = NO;
    _h_call.enabled = YES;
    _h_email.hidden = NO;
    _h_email.enabled = YES;
    _h_msg.hidden = NO;
    if ([mobile isEqualToString:@""]) {
        _h_call.enabled = NO;
    }
    if ([email isEqualToString:@""]) {
        _h_email.enabled = NO;
    }
}


#pragma mark - 动态相关

-(void)initDynamicData{
    [CommonStaticVar setContentFont:15.0 color:COLOR_WORKGROUP_CONTENT];
    
    pageNo = 1;
    isMoreData = YES;
    self.arrayWorkGroup = [[NSMutableArray alloc] init];
}


#pragma mark  请求数据  不做缓存
-(void)getCacheData{
    [self getDataFromService];
}

///读取缓存数据
-(void)getCache{
}


#pragma mark  获取数据
-(void)getDataFromService{
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    ///我的动态
    NSString *url = MY_TRENDS_LIST;
    if (self.infoTypeOfUser == InfoTypeMyself) {
        [params setObject:appDelegateAccessor.moudle.userId forKey:@"uid"];
    }else{
        [params setObject:[NSNumber numberWithLongLong:self.userId] forKey:@"uid"];
    }
    
    [params setObject:[NSNumber numberWithInteger:pageNo] forKey:@"pageNo"];
    [params setObject:[NSNumber numberWithInt:PageSize] forKey:@"pageSize"];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA,url] params:params success:^(id responseObj) {
        [self stopAnimation];
        //字典转模型
        NSDictionary *resultdic = responseObj;
        
        if (resultdic && [[resultdic objectForKey:@"status"] integerValue] == 0) {
            [self setViewRequestSusscess:resultdic];
        }else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getDataFromService];
            };
            [comRequest loginInBackground];
        }
        else{
            NSString *desc = [resultdic safeObjectForKey:@"desc"];
            ///加载失败 做相应处理
            [self setViewRequestFaild:desc];
        }
        ///刷新UI
        [self reloadRefeshView];
    } failure:^(NSError *error) {
        [self stopAnimation];
        ///网络失败 做相应处理
        [self setViewRequestFaild:NET_ERROR];
        ///刷新UI
        [self reloadRefeshView];
    }];
}


// 请求成功时数据处理
-(void)setViewRequestSusscess:(NSDictionary *)resultdic
{
    NSArray  *array = nil;
    
    if ([resultdic objectForKey:@"feeds"] ) {
        array = [resultdic  objectForKey:@"feeds"];
    }
    
    NSLog(@"count:%ti",[array count]);
    ///有数据返回
    if (array && [array count] > 0) {
        ///缓存第一页数据
        if(pageNo == 1)
        {
            [self.arrayWorkGroup removeAllObjects];
        }
        
        ///页码++
        if ([array count] == PageSize) {
            pageNo++;
            isMoreData = YES;
            [self.m_tableView setFooterHidden:NO];
        }else
        {
            ///隐藏上拉刷新
            [self.m_tableView setFooterHidden:YES];
            isMoreData = NO;
        }
        
        ///添加当前页数据到列表中...
        [self.arrayWorkGroup addObjectsFromArray:array];
    }else{
        ///返回为空
        ///隐藏上拉刷新
        isMoreData = NO;
        [self.m_tableView setFooterHidden:YES];
        ///若是第一页 读取是否存在缓存
        if(pageNo == 1)
        {
            if (self.infoTypeOfUser == InfoTypeOthers) {
                heightNoData = -35;
            }else{
                heightNoData = -75;
            }
        }
    }
    
    if (_arrayWorkGroup.count > 1) {
        _m_tableView.tableFooterView = nil;
    }else if (_arrayWorkGroup.count == 1) {
        _m_tableView.tableFooterView = self.footerTableViewDatas;
    }
    else {
        _m_tableView.tableFooterView = self.footerTableView;
    }
}

// 请求失败时数据处理
-(void)setViewRequestFaild:(NSString *)desc
{
    ///若是第一页 读取是否存在缓存
    if(pageNo == 1)
    {
        if (self.infoTypeOfUser == InfoTypeOthers) {
            heightNoData = -35;
        }else{
            heightNoData = -75;
        }
    }
    [CommonFuntion showToast:desc inView:self.view];
}


#pragma mark  上拉下拉刷新相关事件
//集成刷新控件
- (void)setupRefresh
{
    NSString *dateKey = @"userinfo";
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
//    [self.m_tableView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:dateKey];
    //上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.m_tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 自动刷新(一进入程序就下拉刷新)
    //    [self.tableviewCampaign headerBeginRefreshing];
}

// 结束加载
-(void)reloadRefeshView{
    // 刷新列表
    [self setRereshingViewShow];
    [self.m_tableView reloadData];
    [self.m_tableView footerEndRefreshing];
    [self.m_tableView headerEndRefreshing];
}

// 下拉
- (void)headerRereshing
{
    NSLog(@"headerRereshing--下拉-->");
    
    if ([self.m_tableView isFooterRefreshing]) {
        [self.m_tableView headerEndRefreshing];
        return;
    }
    
    pageNo = 1;
    [self getDataFromService];
}

// 上拉
- (void)footerRereshing
{
    NSLog(@"footerRereshing--上拉-->");
    
    if ([self.m_tableView isHeaderRefreshing]) {
        [self.m_tableView footerEndRefreshing];
        return;
    }
    [self getDataFromService];
}

///控制下拉上拉控件显示与隐藏
-(void)setRereshingViewShow{
    
    if (_sourceType == TableViewSourceTypeTrends) {
        if (isMoreData) {
            [self.m_tableView setFooterHidden:NO];
        }else{
            [self.m_tableView setFooterHidden:YES];
        }
        [self.m_tableView setHeaderHidden:NO];
    }else{
        [self.m_tableView setFooterHidden:YES];
        [self.m_tableView setHeaderHidden:YES];
    }
}

#pragma mark  获取cell对应的type
-(WorkGroupType)getWorkTypeByIndex:(NSInteger)index{
    WorkGroupType type;
    NSInteger typeValue = 0;
    if ([[self.arrayWorkGroup objectAtIndex:index] objectForKey:@"type"]) {
        typeValue = [[[self.arrayWorkGroup objectAtIndex:index] objectForKey:@"type"]  integerValue];
    }
    ///moduleType  1OA  2CRM
    NSInteger moduleType = 1;
    if (![[[self.arrayWorkGroup objectAtIndex:index] safeObjectForKey:@"moduleType"] isEqualToString:@""]) {
        moduleType = [[[self.arrayWorkGroup objectAtIndex:index] safeObjectForKey:@"moduleType"]  integerValue];
    }
    
    type = WorkGroupTypeA;
    ///CRM
    if (moduleType == 2) {
        type = WorkGroupTypeB;
    }else if (moduleType == 1){
        if (typeValue == 0) {
            type = WorkGroupTypeA;
        }else{
            type = WorkGroupTypeB;
        }
    }
    return type;
}

#pragma mark - 获取cell对应type对应的height
-(CGFloat)getHeightByCellType:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    
    WorkGroupType type = [self getWorkTypeByIndex:indexPath.section];
    switch (type) {
        case WorkGroupTypeA:
            
            height = [WorkGroupRecordCellA getCellContentHeight:[self.arrayWorkGroup objectAtIndex:indexPath.section]];
            break;
        case WorkGroupTypeB:
        {
            NSDictionary *item;
            if ([[CommonStaticVar getTypeOfWorkGroupCellInfo] isEqualToString:@"comment"])  {
                
                ///消息 提到我的
                if ([[[self.arrayWorkGroup objectAtIndex:indexPath.section] objectForKey:@"type"] integerValue] == 1) {
                    item = [[self.arrayWorkGroup objectAtIndex:indexPath.section] objectForKey:@"comment"];
                }else{
                    ///type == 0
                    item = [[self.arrayWorkGroup objectAtIndex:indexPath.section] objectForKey:@"feed"];
                }
                
            }else{
                item = [self.arrayWorkGroup objectAtIndex:indexPath.section];
            }
            height = [WorkGroupRecordCellB getCellContentHeight:item byCellStatus:WorkGroupTypeStatusCell];
            break;
        }
            
        default:
            height = [WorkGroupRecordCellA getCellContentHeight:[self.arrayWorkGroup objectAtIndex:indexPath.section]];
            break;
    }
    return height;
}


#pragma mark - 动态相关事件

#pragma mark - WorkGroupDelegate cell点击事件

///点击头像事件
-(void)clickUserIconEvent:(NSInteger)section{
    NSLog(@"clickUserIconEvent section：%li",section);
    
    ///获取对应的item
    NSDictionary *item;
    /*
     if ([[CommonStaticVar getTypeOfWorkGroupCellInfo] isEqualToString:@"comment"])  {
     ///消息 提到我的
     if ([[[self.arrayWorkGroup objectAtIndex:section] objectForKey:@"type"] integerValue] == 1) {
     item = [[self.arrayWorkGroup objectAtIndex:section] objectForKey:@"comment"];
     }else{
     ///type == 0
     item = [[self.arrayWorkGroup objectAtIndex:section] objectForKey:@"feed"];
     }
     
     }else{
     item = [self.arrayWorkGroup objectAtIndex:section];
     }
     */
    ///user
    NSDictionary *user = nil;
    if ([CommonFuntion checkNullForValue:[[self.arrayWorkGroup objectAtIndex:section] objectForKey:@"user"]]) {
        if ([[self.arrayWorkGroup objectAtIndex:section] objectForKey:@"user"]) {
            user = [[self.arrayWorkGroup objectAtIndex:section] objectForKey:@"user"];
        }
    }
    ///获取到uid
    ///根据uid跳转页面
    
    
    InfoViewController *infoController = [[InfoViewController alloc] init];
    infoController.title = @"个人信息";
    if ([appDelegateAccessor.moudle.userId longLongValue] == [[user safeObjectForKey:@"id"] longLongValue]) {
        infoController.infoTypeOfUser = InfoTypeMyself;
    }else{
        infoController.infoTypeOfUser = InfoTypeOthers;
        infoController.userId = [[user safeObjectForKey:@"id"] longLongValue];
    }
    
    infoController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:infoController animated:YES];
}

///点击右上角菜单事件
-(void)clickRightMenuEvent:(NSInteger)section{
    NSLog(@"clickRightMenuEvent section：%li",section);
//    [self showRightActionSheetMenu:section];
    
    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];
    NSInteger  modelType = [[item objectForKey:@"moduleType"] integerValue];
    
    ///OA
    if (modelType == 1) {
        [self showRightActionSheetMenu:section];
    }else if (modelType == 2) {
        [self showRightActionSheetMenuCRM:section];
    }
}


#pragma mark  OA  点击右上角菜单按钮 弹出actionsheetview
///点击右上角菜单按钮 弹出actionsheetview
-(void)showRightActionSheetMenuCRM:(NSInteger)section{
    
    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];
    NSDictionary *user = nil;
    NSString *uid = @"";
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"user"]]) {
        user = [item objectForKey:@"user"];
    }
    if (user) {
        if ([user objectForKey:@"id"]) {
            uid = [user safeObjectForKey:@"id"];
        }
    }
    
    NSString *delete = @"删除";
    if ([appDelegateAccessor.moudle.userId longLongValue] == [uid longLongValue]) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles: delete,nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        actionSheet.destructiveButtonIndex = 0;
        actionSheet.tag = section;
        [actionSheet showInView:self.view];
        
    }
}


///点击文件事件
-(void)clickFileEvent:(NSInteger)section{
    NSLog(@"clickFileEvent row：%li",section);
    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];
    
    ///转发内容
    if ([[item objectForKey:@"type"] integerValue] == 2) {
        if ([CommonFuntion checkNullForValue:[item objectForKey:@"forward"]]) {
            if ([item objectForKey:@"forward"]) {
                item = [item objectForKey:@"forward"];
            }else{
                item = nil;
            }
        }else{
            item = nil;
        }
    }
    
    
    //    if ([item objectForKey:@"file"] && [item objectForKey:@"fileType"]) {
    //        if ([[item safeObjectForKey:@"fileType"]  integerValue] == 2) {
    //            ///文件
    //            fileItem = [item objectForKey:@"file"];
    //        }
    //    }
    
    if (item) {
        
        KnowledgeFileDetailsViewController *controller = [[KnowledgeFileDetailsViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        controller.detailsOld = [item objectForKey:@"file"];
        controller.viewFrom = @"other";
        controller.isNeedRightNavBtn = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        [CommonFuntion showToast:@"文件不存在" inView:self.view];
    }
}

///点击地址事件
-(void)clickAddressEvent:(NSInteger)section{
    NSLog(@"clickAddressEvent section：%li",section);
    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];
    NSDictionary *feedItem = nil;
    
    ///是转发信息
    if ([[item objectForKey:@"type"] integerValue] == 2) {
        ///
        if ([CommonFuntion checkNullForValue:[item objectForKey:@"forward"]]) {
            if ([item objectForKey:@"forward"]) {
                feedItem = [item objectForKey:@"forward"];
            }
        }
        
    }
    
    ///是转发动态
    if (feedItem) {
        item = feedItem;
    }
    
    double latitude = 0;
    double longitude = 0;
    if ([item objectForKey:@"latitude"]) {
        latitude = [[item safeObjectForKey:@"latitude"] doubleValue];
    }
    if ([item objectForKey:@"longitude"]) {
        longitude = [[item safeObjectForKey:@"longitude"] doubleValue];
    }
    ///location
    NSString *location = @"";
    if ([item objectForKey:@"position"]) {
        location = [item safeObjectForKey:@"position"];
    }
    NSString *locationDetail = @"";
    if ([item objectForKey:@"position"]) {
        locationDetail = [item safeObjectForKey:@"position"];
    }
    
    if (latitude !=0 && longitude !=0) {
        MapViewViewController *controller = [[MapViewViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        controller.typeOfMap = @"show";
        controller.latitude = latitude;
        controller.longitude = longitude;
        controller.location = location;
        controller.locationDetail = locationDetail;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

///展开或收起
-(void)clickExpContentEvent:(NSInteger)section{
    NSLog(@"clickExpContentEvent section：%li",section);
    
    NSDictionary *itemOld ;
    
    if ([[CommonStaticVar getTypeOfWorkGroupCellInfo] isEqualToString:@"comment"])  {
        
        ///消息 提到我的
        if ([[[self.arrayWorkGroup objectAtIndex:section] objectForKey:@"type"] integerValue] == 1) {
            itemOld = [[self.arrayWorkGroup objectAtIndex:section] objectForKey:@"comment"];
        }else{
            ///type == 0
            itemOld = [[self.arrayWorkGroup objectAtIndex:section] objectForKey:@"feed"];
        }
        
    }else{
        itemOld = [self.arrayWorkGroup objectAtIndex:section];
    }
    
    
    NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:itemOld];
    
    ///已经处于展开状态 则收起
    if ([itemOld objectForKey:@"isExp"] && [[itemOld objectForKey:@"isExp"] isEqualToString:@"yes"]) {
        [mutableItemNew setObject:@"no" forKey:@"isExp"];
    }else{
        ///标记为展开展开状态
        [mutableItemNew setObject:@"yes" forKey:@"isExp"];
    }
    
#warning 修改数据
    if ([[CommonStaticVar getTypeOfWorkGroupCellInfo] isEqualToString:@"comment"])  {
        NSDictionary *itemComment =[self.arrayWorkGroup objectAtIndex:section];
        NSMutableDictionary *mutableItemNewComment = [NSMutableDictionary dictionaryWithDictionary:itemComment];
        
        [mutableItemNewComment setObject:mutableItemNew forKey:@"comment"];
        //修改数据
        [self.arrayWorkGroup setObject: mutableItemNewComment atIndexedSubscript:section];
    }else{
        //修改数据
        [self.arrayWorkGroup setObject: mutableItemNew atIndexedSubscript:section];
    }
    
    ///刷新当前cell
    [self.m_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:section],nil] withRowAnimation:UITableViewRowAnimationNone];
    
    //    [self.tableviewWorkGroup scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewRowAnimationNone animated:YES];
    
    [self.m_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

///点击转发事件
-(void)clickRepostEvent:(NSInteger)section{
    NSLog(@"clickRepostEvent section：%li",section);
    
    __weak typeof(self) weak_self = self;
    ReleaseViewController *releaseController = [[ReleaseViewController alloc] init];
    releaseController.title = @"转发";
    releaseController.typeOfOptionDynamic = TypeOfOptionDynamicForward;
    releaseController.itemDynamic = [self.arrayWorkGroup objectAtIndex:section];
    releaseController.ReleaseSuccessNotifyData = ^(){
        ///重新请求数据
        [weak_self notifyDataByHeadRequest];
    };
    [self.navigationController pushViewController:releaseController animated:YES];
}

///加载第一页数据
-(void)notifyDataByHeadRequest{
    [self.m_tableView setContentOffset:CGPointZero animated:YES];
    pageNo = 1;
    [self.arrayWorkGroup removeAllObjects];
    [self getDataFromService];
}

///点击评论事件
-(void)clickReviewEvent:(NSInteger)section{
    NSLog(@"clickReviewEvent section：%li",section);
    WorkGroupRecordDetailsViewController *controller = [[WorkGroupRecordDetailsViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.isShowKeyBoardView = @"yes";
    controller.dicWorkGroupDetailsOld = [self.arrayWorkGroup objectAtIndex:section];
    [self.navigationController pushViewController:controller animated:YES];
}

///点击赞事件
-(void)clickPraiseEvent:(NSInteger)section{
    NSLog(@"clickPraiseEvent section：%li",section);
    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];
    long long trendsId = -1;
    if ([item objectForKey:@"id"]) {
        trendsId = [[item objectForKey:@"id"] longLongValue];
    }
    
    [self trendOption:FEED_UP_ADD withTrendsId:trendsId indexTrends:section];
    
    /*
     NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];
     
     ///是否已经赞
     NSString *isFeedUp = @"0";
     if ([item objectForKey:@"isFeedUp"]) {
     isFeedUp = [item objectForKey:@"isFeedUp"];
     }
     
     ///还没有赞
     if ([isFeedUp isEqualToString:@"0"]) {
     
     }
     */
    
}

///点击来自XXX事件
-(void)clickFromEvent:(NSInteger)section{
    NSLog(@"clickFromEvent section：%li",section);
    
    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"from"]]) {
        NSInteger type = [[[item objectForKey:@"from"] objectForKey:@"sourceId"] integerValue];
        NSInteger sectionId = [[[item objectForKey:@"from"] objectForKey:@"id"] integerValue];
        switch (type) {
            case PushControllerTypeActivity:
            {
                ActivityDetailViewController *controller = [[ActivityDetailViewController alloc] init];
                controller.id = @(sectionId);
                controller.title = @"市场活动";
                [self.navigationController pushViewController:controller animated:YES];
            }
                NSLog(@"市场活动");
                break;
            case PushControllerTypeClue:
            {
                LeadDetailViewController *controller = [[LeadDetailViewController alloc] init];
                Lead *lead = [[Lead alloc] init];
                lead.id = @(sectionId);
                controller.id = lead.id;
                controller.title = @"销售线索";
                [self.navigationController pushViewController:controller animated:YES];
            }
                NSLog(@"销售线索");
                break;
            case PushControllerTypeCustomer:
            {
                CustomerDetailViewController *controller = [[CustomerDetailViewController alloc] init];
                Customer *customer = [[Customer alloc] init];
                customer.id = @(sectionId);
                controller.id = customer.id;
                controller.title = @"客户";
                [self.navigationController pushViewController:controller animated:YES];
            }
                NSLog(@"客户");
                break;
            case PushControllerTypeContract:
            {
                ContactDetailViewController *controller = [[ContactDetailViewController alloc] init];
                Contact *tact = [[Contact alloc] init];
                tact.id = @(sectionId);
                controller.id = tact.id;
                controller.title = @"联系人";
                [self.navigationController pushViewController:controller animated:YES];
            }
                NSLog(@"联系人");
                break;
            case PushControllerTypeOpportunity:
            {
                OpportunityDetailController *controller = [[OpportunityDetailController alloc] init];
                SaleChance *chance = [[SaleChance alloc] init];
                chance.id = @(sectionId);
                controller.id = chance.id;
                controller.title = @"销售机会";
                [self.navigationController pushViewController:controller animated:YES];
            }
                NSLog(@"销售机会");
                break;
            case PushControllerTypeGroup:
            {
                [self gotoDepartMentOrGroup:item];
            }
                NSLog(@"群组");
                break;
            case PushControllerTypeDepartment:
            {
                [self gotoDepartMentOrGroup:item];
            }
                NSLog(@"部门");
                break;
                
            default:
                break;
        }
    }
}


///跳转到部门或群组
-(void)gotoDepartMentOrGroup:(NSDictionary *)item{
    
    NSDictionary *from =  [item objectForKey:@"from"];
    NSDictionary *fromItem = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:[[from objectForKey:@"id"] longValue]],@"id", [from objectForKey:@"name"],@"name",@1,@"hasChildren",@"",@"icon",@"",@"pinyin",nil];
    DepartGroupModel *model = [NSObject objectOfClass:@"DepartGroupModel" fromJSON:fromItem];
    
    DepartViewController *controll = [[DepartViewController alloc] init];
    UITabBarController *tabbarController = [[UITabBarController alloc] init];
    tabbarController.edgesForExtendedLayout = UIRectEdgeNone;
    tabbarController.title = model.name;
    tabbarController.viewControllers = [controll getTabBarItems:model andType:[[from objectForKey:@"sourceId"] integerValue]];
    tabbarController.hidesBottomBarWhenPushed = YES;
    tabbarController.delegate = self;
    [self.navigationController pushViewController:tabbarController animated:YES];
}


///点击内容中的@
-(void)clickContentCharType:(NSString *)type content:(NSString *)content atIndex:(NSIndexPath *)indexPath{
    NSLog(@"clickContentCharType type:%@ content:%@ index:%li",type,content,indexPath.section);
    
    NSDictionary *item;
    if ([[CommonStaticVar getTypeOfWorkGroupCellInfo] isEqualToString:@"comment"])  {
        
        ///消息 提到我的
        if ([[[self.arrayWorkGroup objectAtIndex:indexPath.section] objectForKey:@"type"] integerValue] == 1) {
            item = [[self.arrayWorkGroup objectAtIndex:indexPath.section] objectForKey:@"comment"];
        }else{
            ///type == 0
            item = [[self.arrayWorkGroup objectAtIndex:indexPath.section] objectForKey:@"feed"];
        }
        
    }else{
        item = [self.arrayWorkGroup objectAtIndex:indexPath.section];
    }
    
    NSLog(@"item:%@",item);
    ///未返回标记@集合的key
    /*
     long long uid = [CommonModuleFuntion getUidByAtName:[[content substringFromIndex:1] stringByReplacingOccurrencesOfString:@" " withString:@
     ""] fromAtList:[item objectForKey:@"user"]];
     NSLog(@"uid:%lld",uid);
     */
    
    long long uid = [CommonModuleFuntion getUidByAtName:[[content substringFromIndex:1] stringByReplacingOccurrencesOfString:@" " withString:@
                                                         ""] fromAtList:[item objectForKey:@"alts"]];
    NSLog(@"uid:%lld",uid);
    InfoViewController *infoController = [[InfoViewController alloc] init];
    infoController.title = @"个人信息";
    if ([appDelegateAccessor.moudle.userId longLongValue] == uid) {
        infoController.infoTypeOfUser = InfoTypeMyself;
    }else{
        infoController.infoTypeOfUser = InfoTypeOthers;
        infoController.userId = uid;
    }
    
    infoController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:infoController animated:YES];
    
}


///点击转发view区域 跳转到详情
-(void)clickRepostViewEvent:(NSInteger)section{
    NSLog(@"clickRepostViewEvent section：%li",section);
    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section] ;
    ///是转发信息
    if ([[item  objectForKey:@"type"] integerValue] == 2 ) {
        ///
         NSDictionary *feedItem = nil;
        if ([CommonFuntion checkNullForValue:[item objectForKey:@"forward"]]) {
            if ([item objectForKey:@"forward"]) {
                feedItem = [item objectForKey:@"forward"];
            }
        }
       
        
        ///存在转发内容
        if (feedItem) {
            WorkGroupRecordDetailsViewController *controller = [[WorkGroupRecordDetailsViewController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            controller.isShowKeyBoardView = @"no";
            controller.dicWorkGroupDetailsOld = feedItem;
            [self.navigationController pushViewController:controller animated:YES];
        }else{
            ///动态已经被删除
            [CommonFuntion showToast:@"该动态已被删除" inView:self.view];
        }
    }
}

///点击图片事件
-(void)clickImageViewEvent:(NSIndexPath *)imgIndexPath{
    [PhotoBroswerVC show:self type:PhotoBroswerVCTypeUserInfo index:imgIndexPath.row photoModelBlock:^NSArray *{
        
        WorkGroupRecordCellB *cell = (WorkGroupRecordCellB *)[self.m_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:imgIndexPath.section]];
        
        NSDictionary *item = [self.arrayWorkGroup objectAtIndex:imgIndexPath.section];
        //        NSLog(@"-----img  click--item:%@",item);
        ///转发内容
        if ([[item objectForKey:@"type"] integerValue] == 2) {
            if ([CommonFuntion checkNullForValue:[item objectForKey:@"forward"]]) {
                if ([item objectForKey:@"forward"]) {
                    item = [item objectForKey:@"forward"];
                }
            }
        }
        NSArray *arrayImg;
        
        /// fileType  0 不存在  1图片  2附件
        /// imageFiles 判断图片
        if ([item objectForKey:@"imageFiles"] && [item objectForKey:@"fileType"]) {
            if ([[item safeObjectForKey:@"fileType"]  integerValue] == 1) {
                arrayImg = [item objectForKey:@"imageFiles"];
            }
        }
        
        //        NSLog(@"-----img  click--arrimg:%@",arrayImg);
        NSString *imgSizeType = @"url";
        
        
        NSMutableArray *modelsM = [NSMutableArray arrayWithCapacity:arrayImg.count];
        
        
        NSInteger imgIndex = 0;
        if ([arrayImg count] > imgIndex) {
            NSLog(@"----imgIndex:%ti",imgIndex);
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            
            //源frame
            NSLog(@"cell.img1:%@",cell.img1);
            pbModel.sourceImageView = cell.img1;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        
        if ([arrayImg count] > imgIndex) {
            NSLog(@"----imgIndex:%ti",imgIndex);
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            NSLog(@"cell.img2:%@",cell.img2);
            UIImageView *imageV =(UIImageView *)cell.img2;
            pbModel.sourceImageView = imageV;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        if ([arrayImg count] > imgIndex) {
            NSLog(@"----imgIndex:%ti",imgIndex);
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            pbModel.sourceImageView = cell.img3;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        if ([arrayImg count] > imgIndex) {
            NSLog(@"----imgIndex:%ti",imgIndex);
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            pbModel.sourceImageView = cell.img4;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        if ([arrayImg count] > imgIndex) {
            NSLog(@"----imgIndex:%ti",imgIndex);
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            pbModel.sourceImageView = cell.img5;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        if ([arrayImg count] > imgIndex) {
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            pbModel.sourceImageView = cell.img6;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        if ([arrayImg count] > imgIndex) {
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            pbModel.sourceImageView = cell.img7;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        
        if ([arrayImg count] > imgIndex) {
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            pbModel.sourceImageView = cell.img8;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        
        if ([arrayImg count] > imgIndex) {
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = imgIndex+1;
            pbModel.image_HD_U = [[arrayImg objectAtIndex:imgIndex] objectForKey:imgSizeType];
            //源frame
            pbModel.sourceImageView = cell.img9;;
            
            [modelsM addObject:pbModel];
            imgIndex++;
        }
        for (int i=0; i<modelsM.count; i++) {
            NSLog(@"modelsM:%@",[modelsM objectAtIndex:i]);
        }
        
        return modelsM;
    }];
}


#pragma mark - cell点击事件处理


#pragma mark  点击右上角菜单按钮 弹出actionsheetview
///点击右上角菜单按钮 弹出actionsheetview
-(void)showRightActionSheetMenu:(NSInteger)section{
    
    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];
    NSDictionary *user = nil;
    NSString *uid = @"";
    if ([item objectForKey:@"user"]) {
        user = [item objectForKey:@"user"];
    }
    if (user) {
        if ([user objectForKey:@"id"]) {
            uid = [user safeObjectForKey:@"id"];
        }
    }
    
    NSInteger isfav = 0;
    if ([item objectForKey:@"isfav"]) {
        isfav = [[item objectForKey:@"isfav"] integerValue];
    }
    NSString *report = @"举报";
    NSString *fav = @"";
    NSString *delete = @"删除";
    ///已收藏
    if (isfav == 0) {
        fav = @"取消收藏";
    }else{
        fav = @"收藏";
    }
    
    ///是我的动态  举报 收藏 删除收藏等操作   有删除操作
    if ([appDelegateAccessor.moudle.userId longLongValue] == [uid longLongValue]) {
        
        ///判断可删除时 标红
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:report
                                      otherButtonTitles: fav,delete,nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        actionSheet.destructiveButtonIndex = 2;
        actionSheet.tag = section;
        [actionSheet showInView:self.view];
        
    }else{
        ///别人的动态   收藏   取消收藏  举报
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles: report,fav,nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        actionSheet.tag = section;
        [actionSheet showInView:self.view];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 10086) {
        if (buttonIndex == 0) {
            ///发邮件
            NSLog(@"发邮件");
            NSString *email = @"";
            if (_infoDict && [_infoDict objectForKey:@"email"]) {
                email = [_infoDict safeObjectForKey:@"email"];
            }
            if (![email isEqualToString:@""]) {
                
                [self sendEmailWithRecipients:@[email]];

//                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: [NSString stringWithFormat:@"mailto://%@",email]]];
            }
        }
    }else{
        
        NSDictionary *item = [self.arrayWorkGroup objectAtIndex:actionSheet.tag];
        NSDictionary *user = nil;
        NSString *uid = @"";
        if ([item objectForKey:@"user"]) {
            user = [item objectForKey:@"user"];
        }
        if (user) {
            if ([user objectForKey:@"id"]) {
                uid = [user safeObjectForKey:@"id"];
            }
        }
        
        
        NSInteger m_Type = [[item objectForKey:@"moduleType"] integerValue];
        ///OA
        if (m_Type == 1) {
            if (buttonIndex == 0) {
                //举报
                [self reportToService];
            }else if (buttonIndex == 1) {
                //收藏 取消收藏
                
                NSDictionary *item = [self.arrayWorkGroup objectAtIndex:actionSheet.tag];
                NSInteger isfav = 0;
                if ([item objectForKey:@"isfav"]) {
                    isfav = [[item objectForKey:@"isfav"] integerValue];
                }
                long long trendsId = -1;
                if ([item objectForKey:@"id"]) {
                    trendsId = [[item objectForKey:@"id"] longLongValue];
                }
                
                NSString *url = @"";
                ///已收藏
                if (isfav == 0) {
                    ///取消收藏
                    url = DELETE_FAVORITE;
                }else{
                    ///收藏
                    url = ADD_FAVORITE;
                }
                [self trendOption:url withTrendsId:trendsId indexTrends:actionSheet.tag];
                
            }else if(buttonIndex == 2) {
                ///我的动态
                if ([appDelegateAccessor.moudle.userId longLongValue] == [uid longLongValue]) {

                    //删除
                    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:actionSheet.tag];
                    trendIdDelete  = -1;
                    if ([item objectForKey:@"id"]) {
                        trendIdDelete = [[item objectForKey:@"id"] longLongValue];
                    }
                    indexDelete = actionSheet.tag;
                    
                    UIAlertView *alertDelete = [[UIAlertView alloc] initWithTitle:@"确认删除动态？" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
                    alertDelete.tag = 101;
                    [alertDelete show];

                }
                
            }else if(buttonIndex == 3) {
                //取消
            }
        } else if(m_Type == 2){
            ///CRM  只可删除
            if (buttonIndex == 0) {
                //删除
                NSDictionary *item = [self.arrayWorkGroup objectAtIndex:actionSheet.tag];
                trendIdDelete  = -1;
                if ([item objectForKey:@"id"]) {
                    trendIdDelete = [[item objectForKey:@"id"] longLongValue];
                }
                indexDelete = actionSheet.tag;
                
                UIAlertView *alertDelete = [[UIAlertView alloc] initWithTitle:@"确认删除活动记录？" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
                alertDelete.tag = 101;
                [alertDelete show];
            }
        }
        
    }
}


#pragma mark - 举报
-(void)reportToService{
    ReportToServiceViewController *controller = [[ReportToServiceViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - 收藏/取消收藏/赞/删除动态
-(void)trendOption:(NSString *)url  withTrendsId:(long long)trendsId indexTrends:(NSInteger)section{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    NSString *url_h = @"";
    if ([url isEqualToString:kNetPath_Common_DeleteActivity]) {
        url_h = MOBILE_SERVER_IP_CRM;
        [params setObject:[NSNumber numberWithLongLong:trendsId] forKey:@"id"];
    }else{
        url_h = MOBILE_SERVER_IP_OA;
        [params setObject:[NSNumber numberWithLongLong:trendsId] forKey:@"trendsId"];
    }
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",url_h,url] params:params success:^(id responseObj) {
        
        NSLog(@" responseObj:%@",responseObj);
        //字典转模型
        NSDictionary *resultdic = responseObj;
        
        if (resultdic && [[resultdic objectForKey:@"status"] integerValue] == 0) {
            [self setViewRequestSusscessByTrendOptions:url index:section];
        } else if ((resultdic && [[resultdic objectForKey:@"status"] integerValue] == 1) || (resultdic && [[resultdic objectForKey:@"status"] integerValue] == 2)) {
            NSString *desc = [resultdic safeObjectForKey:@"desc"];
            kShowHUD(desc,nil);
            //如果提示  该动态被删除，则刷新列表
            pageNo = 1;
            [self getDataFromService];
        }
        else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self trendOption:url withTrendsId:trendsId indexTrends:section];
            };
            [comRequest loginInBackground];
        }
        else{
            NSString *desc = [resultdic safeObjectForKey:@"desc"];
            NSLog(@"desc:%@",desc);
            ///失败 做相应处理
            if ([url isEqualToString:ADD_FAVORITE]) {
                [CommonFuntion showToast:@"收藏失败" inView:self.view];
            }else if([url isEqualToString:DELETE_FAVORITE]){
                [CommonFuntion showToast:@"取消收藏失败" inView:self.view];
            }else if([url isEqualToString:FEED_UP_ADD]){
                ///赞操作失败
            }else if([url isEqualToString:DELETE_DYNAMIC]){
                [CommonFuntion showToast:@"删除动态失败" inView:self.view];
            }else if([url isEqualToString:kNetPath_Common_DeleteActivity]){
                //                kShowHUD(@"删除动态失败");
                [CommonFuntion showToast:@"删除活动记录失败" inView:self.view];
            }
        }
        
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        [CommonFuntion showToast:NET_ERROR inView:self.view];
        
    }];
}

// 收藏/取消收藏/赞/删除动态操作请求成功时数据处理
-(void)setViewRequestSusscessByTrendOptions:(NSString *)action index:(NSInteger)section
{
    ///收藏 取消收藏
    if ([action isEqualToString:ADD_FAVORITE] || [action isEqualToString:DELETE_FAVORITE]) {
        if ([action isEqualToString:ADD_FAVORITE]) {
            [CommonFuntion showToast:@"收藏成功" inView:self.view];
        }else if([action isEqualToString:DELETE_FAVORITE]){
            [CommonFuntion showToast:@"取消收藏成功" inView:self.view];
        }
        [self updateFavFlag:action index:section];
        
    }else if ( [action isEqualToString:FEED_UP_ADD]){
        ///赞操作
        [self updateFeedCountAndFlag:section];
    }else if([action isEqualToString:DELETE_DYNAMIC]){
        [CommonFuntion showToast:@"删除动态成功" inView:self.view];
        [self deleteTrend:section];
    }else if([action isEqualToString:kNetPath_Common_DeleteActivity]){
        //                kShowHUD(@"删除动态失败");
        [CommonFuntion showToast:@"删除活动记录成功" inView:self.view];
        [self deleteTrend:section];
    }
}


#pragma mark - 更新收藏标记
-(void)updateFavFlag:(NSString *)action index:(NSInteger)section{
    NSLog(@"updateFavFlag  action:%@  section:%ti",action,section);
    NSInteger isfav = 1;
    if ([action isEqualToString:ADD_FAVORITE]) {
        isfav = 0;
    }else if([action isEqualToString:DELETE_FAVORITE]){
        isfav = 1;
    }
    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];
    ///修改本地数据
    NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:item];
    [mutableItemNew setObject:[NSNumber numberWithInteger:isfav] forKey:@"isfav"];
    //修改数据
    [self.arrayWorkGroup setObject: mutableItemNew atIndexedSubscript:section];
    ///刷新当前cell
    [self.m_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:section],nil] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - 刷新赞个数与标志
-(void)updateFeedCountAndFlag:(NSInteger)section{
    NSLog(@"updateFeedCountAndFlag  section:%ti",section);
    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];
    ///已经被赞的个数
    NSInteger feedUpCount = 0;
    if ([item objectForKey:@"feedUpCount"]) {
        feedUpCount = [[item objectForKey:@"feedUpCount"] integerValue];
    }
    feedUpCount ++;
    ///修改本地数据
    NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:item];
    [mutableItemNew setObject:[NSNumber numberWithInteger:0] forKey:@"isFeedUp"];
    [mutableItemNew setObject:[NSNumber numberWithInteger:feedUpCount] forKey:@"feedUpCount"];
    //修改数据
    [self.arrayWorkGroup setObject: mutableItemNew atIndexedSubscript:section];
    
    ///刷新当前cell
    [self.m_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:section],nil] withRowAnimation:UITableViewRowAnimationNone];
    
    /*
     dispatch_queue_t queue= dispatch_get_main_queue();
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), queue, ^{
     ///刷新当前cell
     [self.tableviewWorkGroup reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:section],nil] withRowAnimation:UITableViewRowAnimationNone];
     });
     */
}

#pragma mark - 本地数据删除动态
-(void)deleteTrend:(NSInteger)section{
    NSLog(@"deleteTrend ：%ti",section);
    if (self.arrayWorkGroup && [self.arrayWorkGroup count] > section) {
        [self.arrayWorkGroup removeObjectAtIndex:section];
        [self.m_tableView reloadData];
        NSLog(@"本地数据删除动态");
    }
    pageNo = 1;
    [self getDataFromService];
}


#pragma mark - 刷新评论个数
-(void)updateReviewComment:(NSInteger)section withFlag:(NSString *)optionFlag{
    NSLog(@"updateReviewComment");
    NSDictionary *item = [self.arrayWorkGroup objectAtIndex:section];
    ///已经评论的个数
    NSInteger commentCount = 0;
    if ([item objectForKey:@"commentCount"]) {
        commentCount = [[item objectForKey:@"commentCount"] integerValue];
    }
    if ([optionFlag isEqualToString:@"add"]) {
        commentCount ++;
    }else{
        commentCount --;
    }
    
    ///修改本地数据
    NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:item];
    [mutableItemNew setObject:[NSNumber numberWithInteger:commentCount] forKey:@"commentCount"];
    //修改数据
    [self.arrayWorkGroup setObject: mutableItemNew atIndexedSubscript:section];
    
    ///刷新当前cell
    [self.m_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:section],nil] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components {
    
    User *user = [components objectForKey:@"altUser"];
    
    if (user) {
        InfoViewController *infoController = [[InfoViewController alloc] init];
        infoController.title = @"个人信息";
        if ([appDelegateAccessor.moudle.userId integerValue] == [user.id integerValue]) {
            infoController.infoTypeOfUser = InfoTypeMyself;
        }else{
            infoController.infoTypeOfUser = InfoTypeOthers;
            infoController.userId = [user.id integerValue];
        }
        [self.navigationController pushViewController:infoController animated:YES];
        return;
    }
}

#pragma mark - delegate UIAlertView
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    ///网络异常
    if (alertView.tag == 500) {
        // 退出
        [self.navigationController popViewControllerAnimated:YES];
    }else if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            NSLog(@"删除动态");
            
            NSString *strUrl = @"";
            NSDictionary *item = [self.arrayWorkGroup objectAtIndex:indexDelete];
            NSInteger m_Type = [[item objectForKey:@"moduleType"] integerValue];
            
            if (m_Type == 1) {
                strUrl = DELETE_DYNAMIC;
            }else if(m_Type == 2){
                strUrl = kNetPath_Common_DeleteActivity;
            }
            [self trendOption:strUrl withTrendsId:trendIdDelete indexTrends:indexDelete];
        }
    }
}
#pragma mark - 显示头像大图
- (void)shouBigPhoto:(UITapGestureRecognizer *)tap {
    UIImageView *imgView = (UIImageView *)tap.view;
    [ZoomPicture showImage:imgView];
}

#pragma mark - setters and getters
- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        UIImage *image = [UIImage imageNamed:@"table_bgView.jpg"];
        _backgroundImageView = [[UIImageView alloc] initWithImage:image];
        _backgroundImageView.frame = self.view.bounds;
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImageView.clipsToBounds = YES;
    }
    return _backgroundImageView;
}

- (UIView*)navCustomView {
    if (!_navCustomView) {
        _navCustomView = [[UIView alloc] init];
        [_navCustomView setWidth:kScreen_Width];
        [_navCustomView setHeight:64];
        _navCustomView.backgroundColor = [[UIColor colorWithHexString:@"0x2e3440"] colorWithAlphaComponent:0];
        
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightButton setWidth:60];
        [_rightButton setHeight:30];
        [_rightButton setX:kScreen_Width - CGRectGetWidth(_rightButton.bounds) - 5];
        [_rightButton setCenterY:42];
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        if (_infoTypeOfUser == InfoTypeMyself) {
            [_rightButton setTitle:@"编辑" forState:UIControlStateNormal];
            [_rightButton addTarget:self action:@selector(editItemPress) forControlEvents:UIControlEventTouchUpInside];
        }
        else {

            [_rightButton addTarget:self action:@selector(attentionItemPress) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [_navCustomView addSubview:self.titleLabel];
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setX:5];
        [backButton setWidth:47];
        [backButton setHeight:30];
        [backButton setCenterY:CGRectGetMidY(_rightButton.frame)];
        [backButton setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        backButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, [UIImage imageNamed:@"nav_back"].size.width);
        [backButton addTarget:self action:@selector(backButtonPress) forControlEvents:UIControlEventTouchUpInside];
        [_navCustomView addSubview:backButton];
        [_navCustomView addSubview:_rightButton];
        
        [_navCustomView addSubview:self.hud];
    }
    return _navCustomView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setWidth:200];
        [_titleLabel setHeight:27];
        [_titleLabel setCenterX:kScreen_Width / 2.0];
        [_titleLabel setCenterY:CGRectGetMidY(_rightButton.frame)];
        _titleLabel.font = [UIFont systemFontOfSize:19];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = self.title;
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (WRWorkResultHUD *)hud {
    if (!_hud) {
        _hud = [[WRWorkResultHUD alloc] initWithFrame:CGRectMake(0, 0, 200, 27)];
        [_hud setCenterX:kScreen_Width / 2.0];
        [_hud setCenterY:CGRectGetMidY(_rightButton.frame)];
        _hud.titleFont = [UIFont systemFontOfSize:19];
        _hud.titleColor = [UIColor whiteColor];
    }
    return _hud;
}

- (UIView*)footerTableView {
    if (!_footerTableView) {
        _footerTableView = [[UIView alloc] init];
        [_footerTableView setWidth:kScreen_Width];
        [_footerTableView setHeight:300];
        _footerTableView.backgroundColor = kView_BG_Color;
        
        UIImage *image = [UIImage imageNamed:@"list_empty"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [imageView setWidth:image.size.width];
        [imageView setHeight:image.size.height];
        [imageView setCenterX:kScreen_Width / 2];
        [imageView setCenterY:CGRectGetHeight(_footerTableView.bounds) / 2 - 15];
        [_footerTableView addSubview:imageView];
        
        UILabel *tipLabel = [[UILabel alloc] init];
        [tipLabel setY:CGRectGetMaxY(imageView.frame)];
        [tipLabel setWidth:kScreen_Width];
        [tipLabel setHeight:30];
        tipLabel.font = [UIFont systemFontOfSize:15];
        tipLabel.textColor = [UIColor lightGrayColor];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.text = @"暂无动态";
        [_footerTableView addSubview:tipLabel];
    }
    return _footerTableView;
}

- (UIView*)footerTableViewDatas {
    if (!_footerTableViewDatas) {
        _footerTableViewDatas = [[UIView alloc] init];
        [_footerTableViewDatas setWidth:kScreen_Width];
        [_footerTableViewDatas setHeight:300];
        _footerTableViewDatas.backgroundColor = kView_BG_Color;
    }
    return _footerTableViewDatas;
}

@end
