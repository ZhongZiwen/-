//
//  CommonDetailViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//
///每页条数
#define PageSize 15
static NSUInteger kNumberOfPages = 2;

#import "CommonDetailViewController.h"
#import "CommonConstant.h"
#import "CommonFuntion.h"
#import "DetailContactCell.h"
#import "HPGrowingTextView.h"
#import "SheetMenuView.h"
#import "SheetMenuModel.h"
#import "DetailSegmentCell.h"
#import "DetailsReviewCell.h"
#import "DetailsRecordCell.h"
#import "CommonStaticVar.h"
#import "CommonModuleFuntion.h"
#import "PhotoBroswerVC.h"
#import "MapViewViewController.h"
#import "KnowledgeFileViewController.h"
#import "KnowledgeFileDetailsViewController.h"
#import "TeamMembersViewController.h"
#import "ChangeStatusViewController.h"
#import "SaleStageViewController.h"
#import "MassMsgViewController.h"
//#import "ProductRelatedViewController.h"
#import "CustomerRelatedViewController.h"
#import "SalesOpportunityRelatedViewController.h"
#import "ContactRelatedViewController.h"
#import "AFSoundManager.h"
#import "VoiceToolView.h"
#import "RecordVoice.h"
#import <MBProgressHUD.h>
#import "MJRefresh.h"
#import "AFNHttp.h"
#import "CommonDetailsCellA.h"
#import "CommonDetailsCellB.h"
#import "CommonDetailsCellC.h"
#import "CommonDetailsCellD.h"
#import "TeamMember.h"

#import "PhotoAssetLibraryViewController.h"
#import "PhotoBrowserViewController.h"
#import "PhotoAssetManager.h"
#import "PhotoAssetModel.h"
#import "ReleaseViewController.h"

#import "SalesCluesController.h"
#import "ExamineController.h"
#import "Select_Table_View.h"
#import "AddressBookViewController.h"
#import "AddressBook.h"
#import "TaskViewController.h"

#define ImageHight 0.0f

#define Voice_Size 150

@interface CommonDetailViewController ()<HPGrowingTextViewDelegate,DetailSegmentDelegate,SheetMenuDelegate,WorkGroupDelegate,DetailsRecordDelegate,TeamMemberClickDelegate,MassMsgDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,PhotoBrowserDelegate>
{
    
    ///团队成员tableview
    UITableView *tableviewHeadviewDetail4;
    ///所有者
    NSArray *arrayOwnerMembers;
    ///其他成员
    NSArray *arrayMembers;
    ///权限
    NSDictionary *permission;
    ///销售阶段
    NSArray *arrayStages;
    ///输单原因
    NSArray *arrayLostReasons;
    
    ///底部按钮  编辑资料
    UIButton *btnEditDetails;
    
    ///底部view
    UIView *keyboardContainerView;
    HPGrowingTextView *textViewReview;
    UIImageView *imgTextView;
    UIButton *btnVoice;
    UIButton *btnKeyBoard;
    UIButton *btnSpeaking;
    ///用来标记点击语音时隐藏的键盘
    NSInteger tagOfHideKeyBoard;
    CGFloat heightKeyBoard;
    
    ///用来区分是哪种情况下的弹框  1 类型  2 电话  3 更多
    NSString *sheetMenuTag;
    
    ///details1
    NSString *detail1Name;
    NSString *detail1AccountName;
    NSString *detail1StrExpireTime;
    
    //变焦图片做底层
    UIImageView *_zoomImageView;
    
    ///语音
    CGFloat xPointVoice;
    CGFloat yPointVoice;
    
    NSInteger pageNo;//页数下标
}
@property (nonatomic, assign) CRMInfoType infoTypeOfCRM;
@property (nonatomic, strong) AFSoundPlayback *playback;

///语音
@property (nonatomic, strong) VoiceToolView *voiceView;
@property (nonatomic, strong) RecordVoice *recordVoice;
@property (nonatomic, assign) BOOL isSendVoice;
@property (nonatomic, strong)  NSString *pathFile;
@property (nonatomic, strong)  NSString *nameFile;
///标记上一次点击的cell
@property (nonatomic, strong) DetailsReviewCell *preCell;


@property (nonatomic, strong) PhotoAssetLibraryViewController *assetLibraryController;


@end

@implementation CommonDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = TABLEVIEW_BG_COLOR;
    self.title = [self getTitle];
    ///测试数据
    [self initData];
    [self readTestData];
    [self initDataForSheetMenu];
    
    [self initHeadScrollView];
    
    [self initTableview];
    [self creatBottomKeyboardView];
    [self creatBottomEditDetailsBtn];
    
//    ///记录
//    [self getRecordList];
//    ///详情
//    [self getRecordDetails];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self addObserverOfKeyBoard];
    [CommonStaticVar setContentFont:14.0 color:COLOR_WORKGROUP_CONTENT];
    [self customNavRightItem];
//    [self.tableviewDetails setContentOffset:CGPointMake(0,-1) animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeObserverOfKeyBoard];
    [textViewReview resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 右上角按钮
- (void)customNavRightItem {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSelectView)];
    self.navigationItem.rightBarButtonItem = rightItem;
}
- (void)addSelectView {
    NSArray *array = [NSArray new];
    if (_typeOfDetail == 4) {
      array = @[@"跟进任务", @"跟进进度", @"更多操作"];
    } else if (self.typeOfDetail == 1 || self.typeOfDetail == 2 || self.typeOfDetail == 5) {
       array = @[@"跟进任务", @"跟进进度", @"发短信给销售线索", @"发短信给客户", @"更多操作"];
    }
    Select_Table_View *selectView = [[Select_Table_View alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) dataArray:array];
    
    __weak typeof(self) weak_self = self;
    __weak typeof(selectView) weak_selectView = selectView;
    selectView.BackIndexBlock = ^(NSInteger index) {
        //根据返回不同的下标进行不同的事件处理
        [weak_self pushDifferenceController:index];
        [weak_selectView removeFromSuperview];
    };
    selectView.RemoveViewBlock = ^(){
        //移除视图
        [weak_selectView removeFromSuperview];
    };
    selectView.backgroundColor = [UIColor clearColor];
    [self.view.window addSubview:selectView];
}
- (void)pushDifferenceController:(NSInteger)index {
    __weak typeof(self) weak_self = self;
    switch (index) {
        case 0:
            NSLog(@"我是第%ld行,此处跳转到新建任务", index);
        {
            
            
        }
            break;
        case 1:
            NSLog(@"我是第%ld行,此处跳转到新建日程", index);
        {
           
        }
            break;
        case 2:
            NSLog(@"我是第%ld行", index);
            break;
        case 3:
            NSLog(@"我是第%ld行", index);
        {
//            AddressBookViewController *controller = [[AddressBookViewController alloc] init];
//            controller.flagFromWhereIntoAddress = 2;
//            controller.title = @"通讯录";
//            controller.GetContactForOwnerBlock = ^(AddressBook *item) {
//                [weak_self showArlertViewForChangePerson:item.m_name];
//            };
//            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 4:
            NSLog(@"我是第%ld行", index);
            [self showArlertViewForDelete];
            break;
        default:
            break;
    }
}
#pragma mark - 
- (void)showArlertViewForDelete {
    UIAlertView *alView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"删除该市场活动后,活动记录等相关信息都将被彻底删除,请确认是否删除" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alView show];
}
- (void)showArlertViewForChangePerson:(NSString *)personName {
    UIAlertView *alView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"市场活动转移后将无法恢复,请确认是否将【%@】转移给【%@】", self.title, personName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alView show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSLog(@"确定删除此市场活动");
    }
}
#pragma mark - 读取测试数据
-(void)readTestData{
    
    ///客户
    if (self.typeOfDetail == 1) {
        ///评论数据
        id jsondata = [CommonFuntion readJsonFile:@"details-customer-data"];
        NSLog(@"jsondata:%@",jsondata);
        
        NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"feeds"];
        [self.arrayRecordList addObjectsFromArray:array];
    }else if(self.typeOfDetail == 2){
        ///销售机会
        ///评论数据
        id jsondata = [CommonFuntion readJsonFile:@"details-salesopportunity-data"];
        NSLog(@"jsondata:%@",jsondata);
        
        NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"feeds"];
        [self.arrayRecordList addObjectsFromArray:array];
    }else if(self.typeOfDetail == 3){
        ///联系人
        ///评论数据
        id jsondata = [CommonFuntion readJsonFile:@"details-contact-data"];
        NSLog(@"jsondata:%@",jsondata);
        
        NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"records"];
        [self.arrayRecordList addObjectsFromArray:array];
    }else if(self.typeOfDetail == 4){
        ///销售线索
        ///评论数据
        id jsondata = [CommonFuntion readJsonFile:@"details-lead-data"];
        NSLog(@"jsondata:%@",jsondata);
        
        NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"records"];
        [self.arrayRecordList addObjectsFromArray:array];
    }else if(self.typeOfDetail == 5){
        ///市场活动
        ///评论数据
        id jsondata = [CommonFuntion readJsonFile:@"details-campaign-data"];
        NSLog(@"jsondata:%@",jsondata);
        
        NSArray *array = [[jsondata objectForKey:@"body"] objectForKey:@"feeds"];
        [self.arrayRecordList addObjectsFromArray:array];
    }
    NSLog(@"arrayRecordList count:%li",[self.arrayRecordList count]);
    
    ///对数据做组织
    ///
    
    
    
    ///活动类型数据
    id jsondata2 = [CommonFuntion readJsonFile:@"details-activity-data"];
    NSLog(@"jsondata:%@",jsondata2);
    
    self.arrayActivityType = [[jsondata2 objectForKey:@"body"] objectForKey:@"types"];
    
    ///详细资料数据
    id jsondata3 ;
    if (self.typeOfDetail == 2) {
        jsondata3 = [CommonFuntion readJsonFile:@"sale-opportunity-details-data"];
        arrayStages = [[jsondata3 objectForKey:@"body"] objectForKey:@"stages"];
        NSLog(@"arrayStages:%@",arrayStages);
        
        arrayLostReasons = [[jsondata3 objectForKey:@"body"] objectForKey:@"lostReasons"];
        
    }else{
        jsondata3 = [CommonFuntion readJsonFile:@"details-infos-data"];
    }
    
    NSLog(@"jsondata3:%@",jsondata3);
    
    self.dicGroupHeadSum = [[jsondata3 objectForKey:@"body"] objectForKey:@"sum"];
    
    NSLog(@"self.dicGroupHeadSum:%@",self.dicGroupHeadSum);
    ///
    
    ///团队成员
    arrayOwnerMembers = [[jsondata3 objectForKey:@"body"] objectForKey:@"ownerMembers"];
    arrayMembers = [[jsondata3 objectForKey:@"body"] objectForKey:@"members"];
    ///权限
    permission = [[jsondata3 objectForKey:@"body"] objectForKey:@"permission"];
    
    
    NSMutableArray *array = [[NSMutableArray  alloc] init];
    [array addObjectsFromArray:arrayOwnerMembers];
    [array addObjectsFromArray:arrayMembers];
    self.arrayContacts = array;
}


#pragma mark - 获取title
-(NSString *)getTitle{
    NSString *title = @"";
    switch (self.typeOfDetail) {
        case 1:
            title = @"客户";
            break;
        case 2:
            title = @"销售机会";
            break;
        case 3:
            title = @"联系人";
            break;
        case 4:
            title = @"销售线索";
            break;
        case 5:
            title = @"市场活动";
            break;
            
        default:
            break;
    }
    return title;
}

#pragma mark - 初始化活动类型
-(void)initDataForSheetMenu{
    SheetMenuModel *model;
    NSMutableArray *array = [[NSMutableArray  alloc] init];
    NSInteger count = 0;
    if (self.arrayActivityType) {
        count = [self.arrayActivityType count];
    }
    NSDictionary *item;
    for (int i=0; i<count; i++) {
        item = [self.arrayActivityType objectAtIndex:i];
        model = [[SheetMenuModel alloc]init];
        model.icon = @"Notice_Remind.png";
        model.icon_selected = @"Notice_Remind.png";
        model.title = [item objectForKey:@"name"];
        [array addObject:model];
    }
    self.arrayActivitySheetMenu = array;
}

#pragma mark - 初始化数据
-(void)initData{
    pageNo = 1;
    self.arrayRecordList = [[NSMutableArray alloc] init];
    self.arrayRecordDetails = [[NSMutableArray alloc] init];
    detail1Name = @"";
    detail1AccountName = @"";
    detail1StrExpireTime = @"";
    ///默认为跟进记录
    self.infoTypeOfCRM = InfoTypeRecord;
}

#pragma mark - 初始化tablview
-(void)initTableview{
    
//    UIView *viewTbg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height-40)];
//    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height-40)];
//    [imageView setImage:[UIImage imageNamed:@"image"]];
//    
//    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleWidth;
//    imageView.clipsToBounds = YES;
//    imageView.contentMode = UIViewContentModeScaleAspectFill;
//    [viewTbg addSubview:imageView];
    
    
     self.tableviewDetails = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height-40) style:UITableViewStylePlain];
//    self.tableviewDetails.backgroundColor = [UIColor clearColor];
    self.tableviewDetails.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableviewDetails.sectionIndexBackgroundColor =  [UIColor clearColor];
//    self.tableviewDetails.backgroundView = nil;
    self.tableviewDetails.delegate = self;
     self.tableviewDetails.dataSource = self;
     self.tableviewDetails.sectionFooterHeight = 0;
     [self.view addSubview:self.tableviewDetails];
     UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
     [self.tableviewDetails setTableFooterView:v];
     self.tableviewDetails.tableHeaderView = self.headScrollview;
    
    ///顶部拉伸效果
    [self addTopZoomView];
    
    [self initHeadView];
}

///顶部拉伸效果
-(void)addTopZoomView{
    ///顶部view拉伸效果
    self.tableviewDetails.contentInset = UIEdgeInsetsMake(ImageHight, 0, 0, 0);
    _zoomImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"common_headview_bg.png"]];
    _zoomImageView.frame = CGRectMake(0, -ImageHight, kScreen_Width, ImageHight);
    
    _zoomImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.headScrollview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _zoomImageView.autoresizesSubviews = YES;
    
    [self.tableviewDetails addSubview:_zoomImageView];
    [self.tableviewDetails sendSubviewToBack:_zoomImageView];
}

#pragma mark - tableview delegate

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView == self.tableviewDetails) {
        return self.headview;
    }else if(tableView == tableviewHeadviewDetail4){
        return nil;
    }
    return self.headview;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (tableView == self.tableviewDetails) {
        return 50;
    }else if(tableView == tableviewHeadviewDetail4){
        return 0;
    }
    return 1;
}


/*
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (tableView == self.tableviewDetails) {
        return 0;
    }else if(tableView == tableviewHeadviewDetail4){
        return 10;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (tableView == self.tableviewDetails) {
        
    }else if(tableView == tableviewHeadviewDetail4){
        UIView *viewFoot = [[UIView alloc] initWithFrame:CGRectMake(40, 0, 40,260+(kScreen_Width-320))];
        UIImageView *imgM = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 6, 12)];
        imgM.image = [UIImage imageNamed:@"arrow_custom.png"];
        [viewFoot addSubview:imgM];
        viewFoot.transform = CGAffineTransformMakeRotation(M_PI/2);
        return viewFoot;
    }
    return nil;
}
*/

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableviewDetails) {
        ///跟进记录
        if (self.infoTypeOfCRM == InfoTypeRecord) {
            NSInteger count = 1;
            if (self.arrayRecordList) {
                count += [self.arrayRecordList count];
            }
            return count;
        }else{
            NSInteger count = 1;
            if (self.arrayRecordDetails) {
                count +=  [self.arrayRecordDetails count];
            }
            return count;
        }
        
    }else if(tableView == tableviewHeadviewDetail4){
        if (self.arrayContacts) {
            return [self.arrayContacts count];
        }
        return 0;
    }
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableviewDetails) {
        if (indexPath.row == 0) {
            return 45;
        }
        ///跟进记录
        if (self.infoTypeOfCRM == InfoTypeRecord) {
            CGFloat height = 0;
            if ([[self.arrayRecordList objectAtIndex:indexPath.row-1] objectForKey:@"stream"]) {
                
                if (indexPath.row == 1 ) {
                    height = [DetailsRecordCell getCellContentHeight:nil andCurItem:[self.arrayRecordList objectAtIndex:indexPath.row-1] indexPath:indexPath];
                }else{
                    height = [DetailsRecordCell getCellContentHeight:[self.arrayRecordList objectAtIndex:indexPath.row-2] andCurItem:[self.arrayRecordList objectAtIndex:indexPath.row-1] indexPath:indexPath];
                }
                
                //      height = [DetailsRecordCell getCellContentHeight:[self.arrayDetails objectAtIndex:indexPath.row-1] indexPath:indexPath];
            }else{
                
                
                if (indexPath.row == 1 ) {
                    height = [DetailsReviewCell getCellContentHeight:nil andCurItem:[self.arrayRecordList objectAtIndex:indexPath.row-1] indexPath:indexPath];
                }else{
                    height = [DetailsReviewCell getCellContentHeight:[self.arrayRecordList objectAtIndex:indexPath.row-2] andCurItem:[self.arrayRecordList objectAtIndex:indexPath.row-1] indexPath:indexPath];
                }
                
                
                //                height = [DetailsReviewCell getCellContentHeight:[self.arrayDetails objectAtIndex:indexPath.row-1] indexPath:indexPath];
            }
            if ([self.arrayRecordList count] == indexPath.row) {
                return height + 70;
            }else{
                return height;
            }
        }else{
            return [self getHeightOfDetailsCell:indexPath];
        }

    }else if(tableView == tableviewHeadviewDetail4){
        return 40.0;
    }
    return 45.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (tableView == self.tableviewDetails) {
        
        if (indexPath.row == 0) {
            /// 跟进记录 / 详细资料
            DetailSegmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailSegmentCellIdentify"];
            if (!cell)
            {
                NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"DetailSegmentCell" owner:self options:nil];
                cell = (DetailSegmentCell*)[array objectAtIndex:0];
                [cell awakeFromNib];
            }
            cell.delegate = self;
            __weak typeof(self) weak_self = self;
            [cell setCellFrame];
            [cell addClickEventForBtn];
            cell.ChangeRecordOrDetailsBlock = ^(NSInteger position){
                if (position == 10) {
                    weak_self.infoTypeOfCRM = InfoTypeRecord;
                    keyboardContainerView.hidden = NO;
                    btnEditDetails.hidden = YES;
                }else{
                    weak_self.infoTypeOfCRM = InfoTypeDetails;
                    keyboardContainerView.hidden = YES;
                    btnEditDetails.hidden = NO;
                }
                [weak_self.tableviewDetails reloadData];
            };
            return cell;
        }else{
            ///跟进记录
            if (self.infoTypeOfCRM == InfoTypeRecord) {
                ///判断stream类型 加载不同cell
                
                ///记录类型
                if ([[self.arrayRecordList objectAtIndex:indexPath.row-1] objectForKey:@"stream"]) {
                    DetailsRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailsRecordCellIdentify"];
                    if (!cell)
                    {
                        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"DetailsRecordCell" owner:self options:nil];
                        cell = (DetailsRecordCell*)[array objectAtIndex:0];
                        [cell awakeFromNib];
                    }
                    cell.delegate = self;
                    if (indexPath.row == 1 ) {
                        [cell setCellDetails:nil andCurItem:[self.arrayRecordList objectAtIndex:indexPath.row-1] indexPath:indexPath];
                    }else{
                        [cell setCellDetails:[self.arrayRecordList objectAtIndex:indexPath.row-2] andCurItem:[self.arrayRecordList objectAtIndex:indexPath.row-1] indexPath:indexPath];
                    }
                    
                    [cell addClickEvent:indexPath];
                    return cell;
                }else{
                    ///评论类型
                    DetailsReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailsReviewCellIdentify"];
                    if (!cell)
                    {
                        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"DetailsReviewCell" owner:self options:nil];
                        cell = (DetailsReviewCell*)[array objectAtIndex:0];
                        [cell awakeFromNib];
                    }
                    cell.delegate = self;
                    if (indexPath.row == 1 ) {
                        [cell setCellDetails:nil andCurItem:[self.arrayRecordList objectAtIndex:indexPath.row-1] indexPath:indexPath];
                    }else{
                        [cell setCellDetails:[self.arrayRecordList objectAtIndex:indexPath.row-2] andCurItem:[self.arrayRecordList objectAtIndex:indexPath.row-1] indexPath:indexPath];
                    }
                    //                [cell setCellDetails:[self.arrayDetails objectAtIndex:indexPath.row-1] indexPath:indexPath];
                    [cell setImageAddGestureEventForImageView:[self.arrayRecordList objectAtIndex:indexPath.row-1] withIndex:indexPath];
                    [cell addClickEventForCellView:indexPath];
                    
                    ///点击语音事件
                    [cell.btnVoice addTarget:self action:@selector(playVoice:) forControlEvents:UIControlEventTouchUpInside];
                    
                    return cell;
                }
            }else{
                NSDictionary *item = [self.arrayRecordDetails objectAtIndex:indexPath.row-1];
                NSInteger columnType = [[item safeObjectForKey:@"columnType"] integerValue];
                
                if (columnType == 9) {
                    ///Title
                    CommonDetailsCellD *cell = [tableView dequeueReusableCellWithIdentifier:@"CommonDetailsCellDIdentify"];
                    if (!cell)
                    {
                        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"CommonDetailsCellD" owner:self options:nil];
                        cell = (CommonDetailsCellD*)[array objectAtIndex:0];
                        [cell awakeFromNib];
                    }
                    [cell setCellDetails:item];
                    return cell;
                }else if (columnType == 1 || columnType == 7){
                    CommonDetailsCellA *cell = [tableView dequeueReusableCellWithIdentifier:@"CommonDetailsCellAIdentify"];
                    if (!cell)
                    {
                        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"CommonDetailsCellA" owner:self options:nil];
                        cell = (CommonDetailsCellA*)[array objectAtIndex:0];
                        [cell awakeFromNib];
                    }
                    return cell;
                }else{
                    CommonDetailsCellA *cell = [tableView dequeueReusableCellWithIdentifier:@"CommonDetailsCellAIdentify"];
                    if (!cell)
                    {
                        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"CommonDetailsCellA" owner:self options:nil];
                        cell = (CommonDetailsCellA*)[array objectAtIndex:0];
                        [cell awakeFromNib];
                    }
                    return cell;
                }
            }
        }
        
    }else if(tableView == tableviewHeadviewDetail4){
        ///团队成员
        DetailContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailContactCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"DetailContactCell" owner:self options:nil];
            cell = (DetailContactCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        cell.delegate = self;
        
        TeamMember *item = [TeamMember initWithDictionary:[self.arrayContacts objectAtIndex:indexPath.row]];
        
        [cell setCellConetnt:item];
        
        if (indexPath.row < [arrayOwnerMembers count]) {
            cell.imgOwner.hidden = NO;
        }else{
            cell.imgOwner.hidden = YES;
        }
        
        return cell;
    }
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (tableView == self.tableviewDetails) {
        
    }else if(tableView == tableviewHeadviewDetail4){
        TeamMembersViewController *controller = [[TeamMembersViewController alloc] init];
//        controller.arrayOwerTeamMembers = arrayOwnerMembers;
        controller.arrayTeamMembers = self.arrayContacts;
        controller.permission = permission;
        [self.navigationController pushViewController:controller animated:YES];
    }
}



#pragma mark - 详细资料cell

-(CGFloat)getHeightOfDetailsCell:(NSIndexPath *)indexPath{
    NSDictionary *item = [self.arrayRecordDetails objectAtIndex:indexPath.row-1];
    NSInteger columnType = [[item safeObjectForKey:@"columnType"] integerValue];
    
    switch (columnType) {
        case 9:
            return 50.0;
            break;
        case 1:
            return 60.0;
            break;
        case 7:
            return 60.0;
            break;
            
        default:
            return 60.0;
            break;
    }
    
    return 0;
}



#pragma maek - 跟进记录/详细资料
-(void)clickSegmentEvent:(NSInteger)tag{
    NSLog(@"clickSegmentEvent tag:%li",tag);
    if (tag == 10) {
        ///跟进记录
    }else if (tag == 11){
        ///详细资料
    }
}


#pragma mark - 团队成员管理页面
-(void)clickTeamMemberEvent{
    TeamMembersViewController *controller = [[TeamMembersViewController alloc] init];
//    controller.arrayOwerTeamMembers = arrayOwnerMembers;
    controller.arrayTeamMembers = self.arrayContacts;
    controller.permission = permission;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - 顶部view

-(void)xxxxxxxxx{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 180)];
    [imageView setImage:[UIImage imageNamed:@"image"]];
    
    //关键步骤 设置可变化背景view属性
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleWidth;
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
}

#pragma mark - 初始化顶部scrollview
- (void)initHeadScrollView
{
    NSLog(@"initHeadScrollView---->");
    ///客户
    if (self.typeOfDetail == 1) {
        kNumberOfPages = 2;
    }else if(self.typeOfDetail == 2){
        ///销售机会
        kNumberOfPages = 3;
    }else if(self.typeOfDetail == 3){
        ///联系人
        kNumberOfPages = 2;
    }else if(self.typeOfDetail == 4){
        ///销售线索
        kNumberOfPages = 2;
    }else if(self.typeOfDetail == 5){
        ///市场活动
        kNumberOfPages = 2;
    }
    
    self.headScrollview.frame = CGRectMake(0, 0, kScreen_Width, 130);
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 130)];
//    [imageView setImage:[UIImage imageNamed:@"image"]];
//    
//    //关键步骤 设置可变化背景view属性
//    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleWidth;
//    imageView.clipsToBounds = YES;
//    imageView.contentMode = UIViewContentModeScaleAspectFill;
//    
//    [self.headScrollview addSubview:imageView];
//    [self.headScrollview sendSubviewToBack:imageView];

    self.imgHeadViewBg.frame = CGRectMake(0, 0, kScreen_Width, 130);
    self.scrollView.frame = CGRectMake(0, 0, kScreen_Width, 130);
    self.pageControl.frame = CGRectMake((kScreen_Width-40)/2, 100, 40, 30);
    self.pageControl.enabled = NO;
    
    NSMutableArray *headdetails = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < kNumberOfPages; i++)
    {
        [headdetails addObject:[NSNull null]];
    }
    self.headviews = headdetails;
    
    // a page is the width of the scroll view
    self.scrollView.bounces = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(kScreen_Width * kNumberOfPages, self.scrollView.frame.size.height);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    self.pageControl.numberOfPages = kNumberOfPages;
    self.pageControl.currentPage = 0;
    
    NSInteger countContact = 0;
    if (self.arrayContacts) {
        countContact = [self.arrayContacts count];
    }

//    self.imgHeadViewBg.image = [UIImage imageNamed:@"common_headview_bg.png"];
    
    [self.headviewDetail1 setBackgroundColor:[UIColor clearColor]];
    [self.headviewDetail2 setBackgroundColor:[UIColor clearColor]];
    [self.headviewDetail3 setBackgroundColor:[UIColor clearColor]];
    [self.headviewDetail4 setBackgroundColor:[UIColor clearColor]];
    self.headScrollview.backgroundColor = [UIColor clearColor];
    
    [self initHeadValue];
    [self initHeadviewDetail4];
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

-(void)initHeadValue{
    [self initHeadviewDetail1];
    [self setHeadViewDetail2Value];
    [self setHeadViewDetail3Value];
    
}

- (void)loadScrollViewWithPage:(NSInteger)page
{
    if (page < 0)
        return;
    if (page >= kNumberOfPages)
        return;
    
    // replace the placeholder if necessary
    UIView *headview = [self.headviews objectAtIndex:page];
    if ((NSNull *)headview == [NSNull null])
    {
        headview = [self getHeadViewWithPageNumber:page andType:self.typeOfDetail];
        [self.headviews replaceObjectAtIndex:page withObject:headview];
    }
    
    // add the controller's view to the scroll view
    if (headview.superview == nil)
    {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = kScreen_Width * page;
        frame.origin.y = 0;
        headview.frame = frame;
        [self.scrollView addSubview:headview];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if (pageControlUsed)
    {
        return;
    }

    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    CGFloat y = sender.contentOffset.y;
    NSLog(@"y:%f",y);
    if (y < -64) {
        CGRect frame = _zoomImageView.frame;
        frame.origin.y = y;
        frame.size.height =  -y+140;
        _zoomImageView.frame = frame;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
    if (scrollView == self.tableviewDetails)
    {
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}


- (IBAction)changePage:(id)sender
{
    NSLog(@"--changePage--->");
    
     NSInteger page = self.pageControl.currentPage;
     NSLog(@"changePage---page:%li",page);
    
     [self loadScrollViewWithPage:page - 1];
     [self loadScrollViewWithPage:page];
     [self loadScrollViewWithPage:page + 1];
     
     // update the scroll view to the appropriate page
     CGRect frame = self.scrollView.frame;
     frame.origin.x = frame.size.width * page;
     frame.origin.y = 0;
     [self.scrollView scrollRectToVisible:frame animated:YES];
    
     pageControlUsed = YES;
     
}


///根据类型和页码 初始化详情view
/// type  1客户
/// type  2销售机会
/// type  3联系人
/// 销售线索4
/// 市场活动5
-(UIView *)getHeadViewWithPageNumber:(NSInteger)page andType:(NSInteger)type{
    NSLog(@"getHeadViewWithPageNumber----page:%li",page);
    if (type == 1 || type == 3) {
        if (page == 0) {
            return self.headviewDetail1;
        }else if(page == 1){
            return self.headviewDetail4;
        }
    }else if(type == 2){
        if (page == 0) {
            return self.headviewDetail2;
        }else if(page == 1){
            return self.headviewDetail3;
        }else if(page == 2){
            return self.headviewDetail4;
        }
    }else if (type == 4){
        if (page == 0) {
            return self.headviewDetail1;
        }else if(page == 1){
            return self.headviewDetail3;
        }
    }else if (type == 5){
        if (page == 0) {
            return self.headviewDetail2;
        }else if(page == 1){
            return self.headviewDetail4;
        }
    }
    return self.headviewDetail1;
}

#pragma mark - 根据type初始化headviewDetail1
-(void)initHeadviewDetail1{
    [self setHeadViewDetail1Value];
    ///联系人
    self.btnDetails1LeftName.hidden = YES;
    self.btnDetails1RightName.hidden = YES;
    self.imgDetails1Line.hidden = YES;
    
    ///客户
    self.labelDetails1Title.hidden = YES;
    self.btnDetails1TagIcon.hidden = YES;
    self.btnDetails1ExtraInfo.hidden = YES;
    self.btnDetails1ExtraIcon.hidden = YES;
    
    
    if (self.typeOfDetail == 1) {
        ///客户
        self.labelDetails1Title.hidden = NO;
        self.btnDetails1TagIcon.hidden = NO;
        self.btnDetails1ExtraInfo.hidden = NO;
        self.btnDetails1ExtraIcon.hidden = NO;
        
        [self.btnDetails1ExtraInfo setTitle:detail1StrExpireTime forState:UIControlStateNormal];
    }else if(self.typeOfDetail == 3){
        ///联系人
        self.btnDetails1LeftName.hidden = NO;
        self.btnDetails1RightName.hidden = NO;
        self.imgDetails1Line.hidden = NO;
        
        [self.btnDetails1LeftName setTitle:detail1Name forState:UIControlStateNormal];
        [self.btnDetails1RightName setTitle:detail1AccountName forState:UIControlStateNormal];
    }else if(self.typeOfDetail == 4){
        ///销售线索
        self.labelDetails1Title.hidden = NO;
        self.labelDetails1Title.text = detail1Name;
    }
    [self setHeadviewDetail1Frame];
    [self setCallMsgAddressViewFrame];
}


-(void)setHeadviewDetail1Frame{
    if (self.typeOfDetail == 1) {
        ///客户
        self.labelDetails1Title.frame = CGRectMake(20, 5, kScreen_Width-40, 20);
        
        NSString *content = detail1StrExpireTime;
        CGSize sizeContent = [CommonFuntion getSizeOfContents:content Font:[UIFont systemFontOfSize:11] withWidth:200 withHeight:20];
        self.btnDetails1ExtraInfo.frame = CGRectMake((kScreen_Width-sizeContent.width)/2, 35, sizeContent.width, 20);
        
        
        self.btnDetails1TagIcon.frame = CGRectMake(self.btnDetails1ExtraInfo.frame.origin.x-30, 35, 20, 20);
        self.btnDetails1ExtraIcon.frame = CGRectMake(self.btnDetails1ExtraInfo.frame.origin.x+sizeContent.width+10, 35, 20, 20);
        
    }else if (self.typeOfDetail == 3) {
        ///联系人
        NSString *contentleft = detail1Name;
        NSString *contentright = detail1AccountName;
        
        CGSize sizeContentLeft = [CommonFuntion getSizeOfContents:contentleft Font:[UIFont systemFontOfSize:14] withWidth:200 withHeight:20];
        CGSize sizeContentRight = [CommonFuntion getSizeOfContents:contentright Font:[UIFont systemFontOfSize:14] withWidth:200 withHeight:20];
        
        self.btnDetails1LeftName.frame = CGRectMake((kScreen_Width-sizeContentLeft.width-sizeContentRight.width-5)/2, 30, sizeContentLeft.width, 20);
        
        self.imgDetails1Line.frame = CGRectMake(self.btnDetails1LeftName.frame.origin.x+sizeContentLeft.width+2, 30, 1, 20);
        
        self.btnDetails1RightName.frame = CGRectMake(self.imgDetails1Line.frame.origin.x+3, 30, sizeContentRight.width, 20);
    }else if (self.typeOfDetail == 4){
        ///客户
        self.labelDetails1Title.frame = CGRectMake(20, 25, kScreen_Width-40, 20);
    }
}

#pragma mark - 根据联系人个数初始化headviewDetail4
-(void)initHeadviewDetail4{
    
    tableviewHeadviewDetail4 = [[UITableView alloc] initWithFrame:CGRectMake(15, 105, 40,1*40)];
    
    tableviewHeadviewDetail4.backgroundColor = [UIColor clearColor];
    tableviewHeadviewDetail4.backgroundView = nil;
    
    [tableviewHeadviewDetail4.layer setAnchorPoint:CGPointMake(0.0, 0.0)];
    tableviewHeadviewDetail4.transform = CGAffineTransformMakeRotation(M_PI/-2);
    tableviewHeadviewDetail4.showsVerticalScrollIndicator = NO;
    tableviewHeadviewDetail4.frame = CGRectMake(15, 105, 1*40, 40);
    tableviewHeadviewDetail4.rowHeight = 40.0;
    tableviewHeadviewDetail4.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableviewHeadviewDetail4.delegate = self;
    tableviewHeadviewDetail4.dataSource = self;
    
    [self.headviewDetail4 addSubview:tableviewHeadviewDetail4];
    
}

#pragma mark 刷新团队成员列表frame
-(void)notifyTableviewHeadDetails4{
    NSInteger count = 0;
    if (self.arrayContacts) {
        count = [self.arrayContacts count];
    }
    
    if (count >= 7) {
        count = 7;
    }
    
    tableviewHeadviewDetail4.frame = CGRectMake(15, 105, count*40, 40);
    
    
    if (count > 0) {
        UIImageView *imgM = [[UIImageView alloc] initWithFrame:CGRectMake(tableviewHeadviewDetail4.frame.origin.x+tableviewHeadviewDetail4.frame.size.width+5, 78, 6, 12)];
        imgM.image = [UIImage imageNamed:@"arrow_custom.png"];
        [self.headviewDetail4 addSubview:imgM];
    }
    
    [tableviewHeadviewDetail4 reloadData];
}

#pragma mark - 初始化顶部详情
-(void)setHeadViewDetail1Value{
    
    self.btnMsg.enabled = NO;
    self.btnCall.enabled = NO;
    self.btnAddress.enabled = NO;
    
    ///客户1   销售机会2  联系人3  销售线索4  市场活动5
    
    ///客户
    if (self.typeOfDetail == 1) {
        
        ///Name
        
        if ([self.itemDetails objectForKey:@"name"]) {
            detail1Name = [self.itemDetails objectForKey:@"name"];
        }
        
        /// 转换几天后回收
        long long expireTime = 0;
        if ([self.itemDetails objectForKey:@"expireTime"]) {
            expireTime = [[self.itemDetails objectForKey:@"expireTime"] longLongValue];
        }
        detail1StrExpireTime = [CommonFuntion getDateOfExpire:expireTime];
        
        self.labelDetails1Title.text = detail1Name;
        if (![detail1StrExpireTime isEqualToString:@""]) {
            self.btnDetails1ExtraInfo.hidden = NO;
            self.btnDetails1TagIcon.hidden = NO;
            self.btnDetails1ExtraIcon.hidden = NO;
            [self.btnDetails1ExtraInfo setTitle:detail1StrExpireTime forState:UIControlStateNormal];
        }else{
            self.btnDetails1ExtraInfo.hidden = YES;
            self.btnDetails1TagIcon.hidden = YES;
            self.btnDetails1ExtraIcon.hidden = YES;
        }
        
        ///拨号可点击
        if ([self.itemDetails objectForKey:@"phone"] && ![[self.itemDetails objectForKey:@"phone"] isEqualToString:@""]) {
            self.btnCall.enabled = YES;
        }
        ///地址可点击
        if ([self.itemDetails objectForKey:@"address"] && ![[self.itemDetails objectForKey:@"address"] isEqualToString:@""]) {
            self.btnAddress.enabled = YES;
        }
        
    }else if (self.typeOfDetail == 3){
        ///联系人
        
        ///left
        if ([self.itemDetails objectForKey:@"name"]) {
            detail1Name = [self.itemDetails objectForKey:@"name"];
        }
        ///right
        if ([self.itemDetails objectForKey:@"accountName"]) {
            detail1AccountName = [self.itemDetails objectForKey:@"accountName"];
        }
        
        ///短信可点击
        if ([self.itemDetails objectForKey:@"tel"] && ![[self.itemDetails objectForKey:@"tel"] isEqualToString:@""]) {
            self.btnMsg.enabled = YES;
        }
        ///拨号可点击
        if ([self.itemDetails objectForKey:@"mobile"] && ![[self.itemDetails objectForKey:@"mobile"] isEqualToString:@""]) {
            self.btnCall.enabled = YES;
        }
        ///地址可点击
        if ([self.itemDetails objectForKey:@"address"] && ![[self.itemDetails objectForKey:@"address"] isEqualToString:@""]) {
            self.btnAddress.enabled = YES;
        }

        
    }else if (self.typeOfDetail == 4){
        ///销售线索
        if ([self.itemDetails objectForKey:@"name"]) {
            detail1Name = [self.itemDetails objectForKey:@"name"];
            ///短信可点击
            if ([self.itemDetails objectForKey:@"phone"] && ![[self.itemDetails objectForKey:@"phone"] isEqualToString:@""]) {
                self.btnMsg.enabled = YES;
            }
            ///拨号可点击
            if ([self.itemDetails objectForKey:@"mobile"] && ![[self.itemDetails objectForKey:@"mobile"] isEqualToString:@""]) {
                self.btnCall.enabled = YES;
            }
            ///地址可点击
            if ([self.itemDetails objectForKey:@"address"] && ![[self.itemDetails objectForKey:@"address"] isEqualToString:@""]) {
                self.btnAddress.enabled = YES;
            }
        }
    }
    
    
}

///销售线索3（2page）
-(void)setHeadViewDetail3Value{
    self.labelDetails3Tiltle.hidden = YES;
    if (self.typeOfDetail == 4) {
        ///销售线索
        NSString *statusName = @"";
        statusName = [CommonModuleFuntion getSaleLeadStatusName:[[self.itemDetails objectForKey:@"status"] integerValue]];
        statusName = [NSString stringWithFormat:@"跟进状态: %@",statusName];
        
//        self.btnDetails3LeftIcon
//        self.btnDetails3Status
//        self.btnDetails3RightIcon
        NSLog(@"statusName:%@",statusName);
        
        CGSize sizeStatusName = [CommonFuntion getSizeOfContents:statusName Font:[UIFont systemFontOfSize:14.0] withWidth:kScreen_Width-100 withHeight:20];
        CGFloat width = kScreen_Width-(20+sizeStatusName.width + 10);
        self.btnDetails3LeftIcon.frame = CGRectMake(width/2, 52, 15, 15);
        self.btnDetails3Status.frame = CGRectMake(width/2+20, 50, sizeStatusName.width, 20);
        self.btnDetails3RightIcon.frame = CGRectMake(self.btnDetails3Status.frame.origin.x+sizeStatusName.width+5, 54, 6, 12);
        [self.btnDetails3Status setTitle:statusName forState:UIControlStateNormal];
    }else if (self.typeOfDetail == 2) {
        ///销售机会
        self.labelDetails3Tiltle.hidden = NO;
        self.labelDetails3Tiltle.frame = CGRectMake(15, 30, kScreen_Width-60, 20);
        self.labelDetails3Tiltle.text = @"所属客户";
        ///销售线索
        NSString *accountName = @"";
        if ([self.itemDetails objectForKey:@"accountName"]) {
            accountName = [self.itemDetails objectForKey:@"accountName"];
        }
        
        CGSize sizeAccountName = [CommonFuntion getSizeOfContents:accountName Font:[UIFont systemFontOfSize:14.0] withWidth:kScreen_Width-100 withHeight:20];
        
        self.btnDetails3LeftIcon.frame = CGRectMake(15, 70, 15, 15);
        self.btnDetails3Status.frame = CGRectMake(30+5, 68, sizeAccountName.width, 20);
        self.btnDetails3RightIcon.frame = CGRectMake(self.btnDetails3Status.frame.origin.x+sizeAccountName.width+5, 72, 6, 12);
        [self.btnDetails3Status setTitle:accountName forState:UIControlStateNormal];
    }
}


///销售机会2  市场活动5
-(void)setHeadViewDetail2Value{
    NSString *name = @"";
    
    NSString *info2 = @"";

   
    self.labelDetails2Title.frame = CGRectMake(15, 20, kScreen_Width-30, 20);
    self.labelDetails2Infos.frame = CGRectMake(15, 50, kScreen_Width-30, 20);
    
    self.btnDetails2Icon.frame = CGRectMake(15, 82, 15, 15);
    
    ///销售机会
    if (self.typeOfDetail == 2) {
        NSString *accountName = @"";
#warning 测试数据
        NSString *date = @"2015-07-10";
         NSString *salestages = [NSString stringWithFormat:@"销售阶段: %@",self.groupNameOfSaleOpportunity];
        CGSize sizeStages = [CommonFuntion getSizeOfContents:salestages Font:[UIFont systemFontOfSize:14.0] withWidth:kScreen_Width-100 withHeight:20];
        self.btnDetails2Status.frame = CGRectMake(35, 80, sizeStages.width, 20);
        self.btnDetails2RightIcon.frame = CGRectMake(self.btnDetails2Status.frame.origin.x+sizeStages.width+5, 84, 6, 12);
        
        if ([self.itemDetails objectForKey:@"name"]) {
            name = [self.itemDetails objectForKey:@"name"];
        }
        
        if ([self.itemDetails objectForKey:@"accountName"]) {
            accountName = [self.itemDetails objectForKey:@"accountName"];
        }
        
        long long money = 0;
        if ([self.itemDetails objectForKey:@"money"]) {
            money = [[self.itemDetails objectForKey:@"money"] longLongValue];
        }
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        //    formatter.numberStyle = kCFNumberFormatterCurrencyStyle;
        [formatter setPositiveFormat:@"###,##0;"];
        NSString *stringMoney = @"0";
        if (money > 0) {
            stringMoney = [NSString stringWithFormat:@"%@%@",[[formatter stringFromNumber:[NSNumber numberWithLongLong:money]] stringByReplacingOccurrencesOfString:@"￥" withString:@""],self.currencyUnit];
        }else{
            stringMoney = [NSString stringWithFormat:@"%@%@",@"0",self.currencyUnit];
        }
        info2 = [NSString stringWithFormat:@"预期金额: %@ 结单日期:%@",stringMoney,date];
        
        self.labelDetails2Title.text = name;
        self.labelDetails2Infos.text = info2;
        [self.btnDetails2Status setTitle:salestages forState:UIControlStateNormal];
        
    }else if (self.typeOfDetail == 5){
        NSString *status = @"";
        ///活动状态
        if ([self.dicRecordDetails objectForKey:@"activityState"]) {
            status = [[self.dicRecordDetails objectForKey:@"activityState"] safeObjectForKey:@"value"];
        }
//        status = [CommonModuleFuntion getCampaignStatusName:[[self.itemDetails objectForKey:@"status"] integerValue]];
        NSString *campaignStatu = [NSString stringWithFormat:@"活动状态: %@",status];
        CGSize sizeStatu = [CommonFuntion getSizeOfContents:campaignStatu Font:[UIFont systemFontOfSize:14.0] withWidth:kScreen_Width-100 withHeight:20];
        self.btnDetails2Status.frame = CGRectMake(35, 80, sizeStatu.width, 20);
        self.btnDetails2RightIcon.frame = CGRectMake(self.btnDetails2Status.frame.origin.x+sizeStatu.width+5, 84, 6, 12);
        
        ///市场活动
        if ([self.dicRecordDetails objectForKey:@"name"]) {
            name = [self.dicRecordDetails safeObjectForKey:@"name"];
        }
        
        self.labelDetails2Title.text = name;
        
        long long startTime = 0;
        if ([self.dicRecordDetails objectForKey:@"startTime"]) {
            startTime = [[self.dicRecordDetails objectForKey:@"startTime"] longLongValue];
        }
        NSString *dateS = @"";
        if (startTime > 0) {
            dateS = [CommonFuntion transDateWithTimeInterval:startTime withFormat:DATE_FORMAT_yyyyMMdd];
        }
        
        long long endTime = 0;
        if ([self.dicRecordDetails objectForKey:@"endTime"]) {
            endTime = [[self.dicRecordDetails objectForKey:@"endTime"] longLongValue];
        }
        NSString *dateE = @"";
        if (endTime > 0) {
            dateE = [CommonFuntion transDateWithTimeInterval:endTime withFormat:DATE_FORMAT_yyyyMMdd];
        }
        
        info2 = [NSString stringWithFormat:@"活动日期: %@ 至 %@",dateS,dateE];
        self.labelDetails2Infos.text = info2;
        
        [self.btnDetails2Status setTitle:campaignStatu forState:UIControlStateNormal];
    }
    
}


///团队成员
-(void)setHeadViewDetail4Value{
    ///客户
    if (self.typeOfDetail == 1) {
        
    }
}

#pragma mark - 顶部拨打电话、短信、地址view及事件

///根据返回类型
-(void)setCallMsgAddressViewFrame{
    if (self.typeOfDetail == 1) {
        ///客户
        self.btnMsg.hidden = YES;
        self.btnCall.frame = CGRectMake(kScreen_Width/2-20-25, self.btnCall.frame.origin.y, 25, 25);
        self.btnAddress.frame = CGRectMake(kScreen_Width/2+20, self.btnAddress.frame.origin.y, 25, 25);
    }else if (self.typeOfDetail == 3){
        ///联系人
        self.btnMsg.hidden = NO;
        self.btnMsg.frame = CGRectMake(kScreen_Width/2-25/2, self.btnMsg.frame.origin.y, 25, 25);
        self.btnCall.frame = CGRectMake(kScreen_Width/2-30-25, self.btnCall.frame.origin.y, 25, 25);
        self.btnAddress.frame = CGRectMake(kScreen_Width/2+30, self.btnAddress.frame.origin.y, 25, 25);
    }else if (self.typeOfDetail == 4){
        ///销售线索
        self.btnMsg.hidden = NO;
        self.btnMsg.frame = CGRectMake(kScreen_Width/2-25/2, self.btnMsg.frame.origin.y, 25, 25);
        self.btnCall.frame = CGRectMake(kScreen_Width/2-30-25, self.btnCall.frame.origin.y, 25, 25);
        self.btnAddress.frame = CGRectMake(kScreen_Width/2+30, self.btnAddress.frame.origin.y, 25, 25);
    }
}

#pragma mark - 电话、消息、地址点击事件
- (IBAction)eventOfCallMsgAddress:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    NSLog(@"tag:%li",tag);
    switch (tag) {
        case 101:
            [self showCallSheetMenu];
            break;
        case 102:
            
            break;
        case 103:
            
            break;
            
        default:
            break;
    }
}


#pragma mark details1客户 点击事件（2天后回收）
///图标 文字  图标
///以tag区分
- (IBAction)customerClickEvent:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    if (tag == 1) {
        ///左边
    }else if (tag ==2){
        ///中
    }else if (tag ==3){
        ///右边
    }
    
}

#pragma mark details1联系人 点击事件（2天后回收）
///联系人点击事件
///以tag区分
- (IBAction)contactClickEvent:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    if (tag == 1) {
        ///左边
    }else if (tag ==2){
        ///右边
    }
}


#pragma mark - details2 事件

- (IBAction)clickDetails2Status:(id)sender {
    if (self.typeOfDetail == 2) {
        ///销售机会
        SaleStageViewController *controller = [[SaleStageViewController alloc] init];
        controller.arrayLostReasons = arrayLostReasons;
        controller.arrayOldStages = arrayStages;
        controller.stageId = [[self.itemDetails objectForKey:@"stageId"] longLongValue];
        [self.navigationController pushViewController:controller animated:YES];
    }else if (self.typeOfDetail == 5){
        ///市场活动
        ///修改活动状态
        ///传活动状态列表过去
        
        NSArray *activityList = nil;
        if ([self.dicRecordDetails objectForKey:@"activityList"]) {
            activityList = [self.dicRecordDetails objectForKey:@"activityList"];
        }
        if (activityList && [activityList count]>0) {
            
            ChangeStatusViewController *controller = [[ChangeStatusViewController alloc] init];
            controller.typeOfStatus = @"campaign";
            if ([self.dicRecordDetails objectForKey:@"activityState"]) {
                controller.selectedIndex = [[[self.dicRecordDetails objectForKey:@"activityState"] safeObjectForKey:@"id"] integerValue];
            }else{
                controller.selectedIndex = -1;
            }
            controller.arrayChangeStatus = activityList;
            controller.title = @"修改活动状态";
            
            controller.notifyActivityStatusBlock = ^(NSString *value,NSInteger statusId){
                NSLog(@"status value:%@",value);
            };
            
            [self.navigationController pushViewController:controller animated:YES];
            
        }
        
    }
}


#pragma mark - details3 事件
- (IBAction)clickDetails3Status:(id)sender {
    NSLog(@"clickDetails3Status--->");
    ///销售线索
    if (self.typeOfDetail == 4) {
        ///修改销售状态
        ChangeStatusViewController *controller = [[ChangeStatusViewController alloc] init];
        controller.typeOfStatus = @"salelead";
        controller.selectedIndex = [[self.itemDetails objectForKey:@"status"] integerValue];
        
        [self.navigationController pushViewController:controller animated:YES];
    }
}


#pragma mark - tableview  headView

-(void)initHeadView{
    
    [self initHeadViewBtn];
    
    self.headview.frame = CGRectMake(0, 0, kScreen_Width, 50);
    self.groupHeadScrollview.frame = CGRectMake(0, 0, kScreen_Width, 50);
    ///根据不同的view from  添加对应的按钮
    
    NSInteger countBtn = 0;
    CGFloat width = 70;
    ///客户、销售机会、市场活动
    if (self.typeOfDetail == 1 || self.typeOfDetail == 2 || self.typeOfDetail == 5) {
        countBtn = 5;
        width = 80;
    }else if(self.typeOfDetail == 3){
        ///联系人
        countBtn = 3;
        width = kScreen_Width/countBtn;
    }else if(self.typeOfDetail == 4){
        ///销售线索
        countBtn = 2;
        width = kScreen_Width/countBtn;
    }
    [self setHeadViewBtnFrame:width];
    
    /*
    for (int i=0; i<countBtn; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(i*width, 0, width, height);
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.numberOfLines = 0;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        btn.tag = i;
        [btn addTarget:self action:@selector(headViewBtnClickEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        [btn setTitle:[NSString stringWithFormat:@"%i\n类型",i] forState:UIControlStateNormal];
        
        [self.groupHeadScrollview addSubview:btn];
    }
     */
    
    // a page is the width of the scroll view
    //    self.groupHeadScrollview.pagingEnabled = YES;
    self.groupHeadScrollview.contentSize = CGSizeMake(countBtn*width, self.groupHeadScrollview.frame.size.height);
    self.groupHeadScrollview.showsHorizontalScrollIndicator = YES;
    self.groupHeadScrollview.showsVerticalScrollIndicator = NO;
    //    self.groupHeadScrollview.scrollsToTop = NO;

    
    [self setHeadBtnContent];
}

-(void)setHeadBtnHide:(BOOL)isHide{
    self.btnGroupHead1.hidden = isHide;
    self.btnGroupHead2.hidden = isHide;
    self.btnGroupHead3.hidden = isHide;
    self.btnGroupHead4.hidden = isHide;
    self.btnGroupHead5.hidden = isHide;
}

///初始化HeadView按钮
-(void)initHeadViewBtn{
    [self setHeadBtnHide:YES];
    
    self.btnGroupHead1.titleLabel.numberOfLines = 0;
    self.btnGroupHead2.titleLabel.numberOfLines = 0;
    self.btnGroupHead3.titleLabel.numberOfLines = 0;
    self.btnGroupHead4.titleLabel.numberOfLines = 0;
    self.btnGroupHead5.titleLabel.numberOfLines = 0;
    
    self.btnGroupHead1.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.btnGroupHead2.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.btnGroupHead3.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.btnGroupHead4.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.btnGroupHead5.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.btnGroupHead1 addTarget:self action:@selector(headViewBtnClickEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnGroupHead2 addTarget:self action:@selector(headViewBtnClickEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnGroupHead3 addTarget:self action:@selector(headViewBtnClickEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnGroupHead4 addTarget:self action:@selector(headViewBtnClickEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnGroupHead5 addTarget:self action:@selector(headViewBtnClickEvent:) forControlEvents:UIControlEventTouchUpInside];
}



///设置btn frame
-(void)setHeadViewBtnFrame:(CGFloat)width{
    CGFloat height = 50;
    if (self.typeOfDetail == 1 || self.typeOfDetail == 2 || self.typeOfDetail == 5) {
        ///客户、销售机会、市场活动
        [self setHeadBtnHide:NO];
        
    }else if(self.typeOfDetail == 3){
        ///联系人
        self.btnGroupHead1.hidden = NO;
        self.btnGroupHead2.hidden = NO;
        self.btnGroupHead3.hidden = NO;
        
    }else if(self.typeOfDetail == 4){
        ///销售线索
        self.btnGroupHead1.hidden = NO;
        self.btnGroupHead2.hidden = NO;
        
    }
    
    self.btnGroupHead1.frame = CGRectMake(0, 0, width, height);
    self.btnGroupHead2.frame = CGRectMake(width*1, 0, width, height);
    self.btnGroupHead3.frame = CGRectMake(width*2, 0, width, height);
    self.btnGroupHead4.frame = CGRectMake(width*3, 0, width, height);
    self.btnGroupHead5.frame = CGRectMake(width*4, 0, width, height);
}

///销售机会 10 联系人11 日程任务12 审批13 文档14 销售线索15 产品16
///设置按钮内容
-(void)setHeadBtnContent{
    ///文档
    NSString *file = @"0";
    if ([self.dicGroupHeadSum objectForKey:@"file"]) {
        file = [self.dicGroupHeadSum objectForKey:@"file"];
    }
    file = [NSString stringWithFormat:@"%@\n文档",file];
    ///销售线索
    NSString *lead = @"0";
    if ([self.dicGroupHeadSum objectForKey:@"lead"]) {
        lead = [self.dicGroupHeadSum objectForKey:@"lead"];
    }
    lead = [NSString stringWithFormat:@"%@\n销售线索",lead];
    ///产品
    NSString *product = @"0";
    if ([self.dicGroupHeadSum objectForKey:@"product"]) {
        product = [self.dicGroupHeadSum objectForKey:@"product"];
    }
    product = [NSString stringWithFormat:@"%@\n产品",product];
    ///销售机会
    NSString *opportunity = @"0";
    if ([self.dicGroupHeadSum objectForKey:@"opportunity"]) {
        opportunity = [self.dicGroupHeadSum objectForKey:@"opportunity"];
    }
    opportunity = [NSString stringWithFormat:@"%@\n销售机会",opportunity];
    ///联系人
    NSString *contact = @"0";
    if ([self.dicGroupHeadSum objectForKey:@"contact"]) {
        contact = [self.dicGroupHeadSum objectForKey:@"contact"];
    }
    contact = [NSString stringWithFormat:@"%@\n联系人",contact];
    ///日程任务
    NSString *task = @"0";
    if ([self.dicGroupHeadSum objectForKey:@"task"]) {
        task = [self.dicGroupHeadSum objectForKey:@"task"];
    }
    task = [NSString stringWithFormat:@"%@\n日程任务",task];
    ///审批
    NSString *approval = @"0";
    if ([self.dicGroupHeadSum objectForKey:@"approval"]) {
        approval = [self.dicGroupHeadSum objectForKey:@"approval"];
    }
    approval = [NSString stringWithFormat:@"%@\n审批",approval];
    ///客户
    NSString *account = @"0";
    if ([self.dicGroupHeadSum objectForKey:@"account"]) {
        account = [self.dicGroupHeadSum objectForKey:@"account"];
    }
    account = [NSString stringWithFormat:@"%@\n客户",account];

    
    ///销售机会 10 联系人11 日程任务12 审批13 文档14 销售线索15 产品16 客户17
    ///客户
    if (self.typeOfDetail == 1) {
        self.btnGroupHead1.tag = 10;
        self.btnGroupHead2.tag = 11;
        self.btnGroupHead3.tag = 12;
        self.btnGroupHead4.tag = 13;
        self.btnGroupHead5.tag = 14;
        
        [self.btnGroupHead1 setTitle:opportunity forState:UIControlStateNormal];
        [self.btnGroupHead2 setTitle:contact forState:UIControlStateNormal];
        [self.btnGroupHead3 setTitle:task forState:UIControlStateNormal];
        [self.btnGroupHead4 setTitle:approval forState:UIControlStateNormal];
        [self.btnGroupHead5 setTitle:file forState:UIControlStateNormal];
    }else if(self.typeOfDetail == 2){
        ///销售机会
        self.btnGroupHead1.tag = 11;
        self.btnGroupHead2.tag = 12;
        self.btnGroupHead3.tag = 13;
        self.btnGroupHead4.tag = 16;
        self.btnGroupHead5.tag = 14;
        
        [self.btnGroupHead1 setTitle:contact forState:UIControlStateNormal];
        [self.btnGroupHead2 setTitle:task forState:UIControlStateNormal];
        [self.btnGroupHead3 setTitle:approval forState:UIControlStateNormal];
        [self.btnGroupHead4 setTitle:product forState:UIControlStateNormal];
        [self.btnGroupHead5 setTitle:file forState:UIControlStateNormal];

    }else if(self.typeOfDetail == 3){
        ///联系人
        self.btnGroupHead1.tag = 10;
        self.btnGroupHead2.tag = 12;
        self.btnGroupHead3.tag = 13;
        
        [self.btnGroupHead1 setTitle:opportunity forState:UIControlStateNormal];
        [self.btnGroupHead2 setTitle:task forState:UIControlStateNormal];
        [self.btnGroupHead3 setTitle:approval forState:UIControlStateNormal];
    }else if(self.typeOfDetail == 4){
        ///销售线索
        self.btnGroupHead1.tag = 12;
        self.btnGroupHead2.tag = 13;
        
        [self.btnGroupHead1 setTitle:task forState:UIControlStateNormal];
        [self.btnGroupHead2 setTitle:approval forState:UIControlStateNormal];
    }else if(self.typeOfDetail == 5){
        ///市场活动
        self.btnGroupHead1.tag = 15;
        self.btnGroupHead2.tag = 17;
        self.btnGroupHead3.tag = 12;
        self.btnGroupHead4.tag = 13;
        self.btnGroupHead5.tag = 14;
        
        [self.btnGroupHead1 setTitle:lead forState:UIControlStateNormal];
        [self.btnGroupHead2 setTitle:account forState:UIControlStateNormal];
        [self.btnGroupHead3 setTitle:task forState:UIControlStateNormal];
        [self.btnGroupHead4 setTitle:approval forState:UIControlStateNormal];
        [self.btnGroupHead5 setTitle:file forState:UIControlStateNormal];
    }
}

///tableview  headview 中按钮点击事件
#pragma mark  group headview  按钮点击事件(销售机会、联系人、日程任务等等)
-(void)headViewBtnClickEvent:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    NSLog(@"headViewBtnClickEvent tag:%ti",tag);
    ///销售机会 10 联系人11 日程任务12 审批13 文档14 销售线索15 产品16 客户17
    switch (tag) {
        case 10:
        {
            SalesOpportunityRelatedViewController *productController = [[SalesOpportunityRelatedViewController alloc] init];
            productController.title = @"销售机会";
            [self.navigationController pushViewController:productController animated:YES];
        }
            break;
        case 11:
        {
            ContactRelatedViewController *productController = [[ContactRelatedViewController alloc] init];
            productController.title = @"联系人";
            [self.navigationController pushViewController:productController animated:YES];
        }
            break;
        case 12:
            //日程任务
        {
            TaskViewController *controller = [[TaskViewController alloc] init];
            controller.flag_type = 1;
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 13:
            //审批
        {
            ExamineController *controller = [[ExamineController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 14:
        {
            [self gotoKnowledgeView];
        }
            break;
        case 15:
        {
            //销售线索
            SalesCluesController *controller = [[SalesCluesController alloc] init];
            controller.title = @"销售线索";
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 16:
        {
//            ProductRelatedViewController *productController = [[ProductRelatedViewController alloc] init];
//            productController.title = @"相关产品";
//            [self.navigationController pushViewController:productController animated:YES];
        }
            break;
        case 17:
        {
            [self gotoCustomerView];
        }
            break;
        default:
        break;
    }
}


#pragma mark 文档
-(void)gotoCustomerView{
    CustomerRelatedViewController *customerController = [[CustomerRelatedViewController alloc] init];
    customerController.title = @"客户";
    customerController.requestId = self.idOfDetails;
    [self.navigationController pushViewController:customerController animated:YES];
}

#pragma mark 文档
-(void)gotoKnowledgeView{
    KnowledgeFileViewController *fileController = [[KnowledgeFileViewController alloc] init];
    ///CMR-详情
    fileController.typeKnowledge = 3;
    fileController.typeKnowledgeRequest = 1;
    fileController.dirId = self.idOfDetails;
    fileController.typeKnowledgeSearchView = 1;
    fileController.typeKnowledgeSearchViewFirst = 1;
    fileController.title = @"市场活动文档";
    [self.navigationController pushViewController:fileController animated:YES];
}

#pragma mark - 创建底部view

-(void)creatBottomEditDetailsBtn{
    if(!btnEditDetails){
        btnEditDetails = [UIButton buttonWithType:UIButtonTypeCustom];
        btnEditDetails.frame = CGRectMake(0, kScreen_Height - 40, kScreen_Width, 40);
//        btnEditDetails.backgroundColor = [UIColor whiteColor];
        [btnEditDetails setTitle:@"编辑资料" forState:UIControlStateNormal];
        [btnEditDetails setTitleColor:LIGHT_BLUE_COLOR forState:UIControlStateNormal];
        [btnEditDetails.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
        [btnEditDetails setImage:[UIImage imageNamed:@"edit_doc.png"] forState:UIControlStateNormal];
        [btnEditDetails addTarget:self action:@selector(editDetailsEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnEditDetails];
        btnEditDetails.hidden = YES;
    }
}

-(void)editDetailsEvent:(id)sender{
    NSLog(@"editDetailsEvent---->");
    ///客户
    if (self.typeOfDetail == 1) {
        
    }else if(self.typeOfDetail == 2){
        ///销售机会
        
    }else if(self.typeOfDetail == 3){
        ///联系人
        
    }else if(self.typeOfDetail == 4){
        ///销售线索
        
    }else if(self.typeOfDetail == 5){
        ///市场活动
        
    }
}

-(void)creatBottomKeyboardView{
    keyboardContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height - 40, kScreen_Width, 40)];
    
    keyboardContainerView.backgroundColor = [UIColor colorWithRed:235.0f/255 green:235.0f/255 blue:235.0f/255 alpha:1.0f];
    keyboardContainerView.layer.borderColor = [UIColor colorWithRed:215.0f/255 green:215.0f/255 blue:215.0f/255 alpha:1.0f].CGColor;
    keyboardContainerView.layer.borderWidth = 1;
    
    
//    textViewReview = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(75, 8, kScreen_Width-115, 10)];
    textViewReview = [[HPGrowingTextView alloc] init];
    textViewReview.frame = CGRectMake(75, 5, kScreen_Width-115, 30);
    textViewReview.isScrollable = NO;
    textViewReview.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    textViewReview.minNumberOfLines = 1;
    textViewReview.maxNumberOfLines = 2;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
    textViewReview.returnKeyType = UIReturnKeySend;
    textViewReview.font = [UIFont systemFontOfSize:12.0f];
    textViewReview.internalTextView.font = [UIFont systemFontOfSize:12.0f];
    textViewReview.delegate = self;
//    textViewReview.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(8, 0, 8, 0);
    textViewReview.layer.borderWidth = 1;
    textViewReview.layer.borderColor = [UIColor grayColor].CGColor;
    textViewReview.layer.cornerRadius = 5;
    textViewReview.backgroundColor = [UIColor whiteColor];
//    textViewReview.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"quicksend_keybsend.png"]];
    textViewReview.placeholder = @"输入评论内容";
    textViewReview.keyboardType = UIKeyboardTypeDefault;
    
    /*
    ///bg
    imgTextView = [[UIImageView alloc]initWithFrame: CGRectMake(0, 3, textViewReview.frame.size.width, textViewReview.frame.size.height-6)];
    imgTextView.image = [UIImage imageNamed: @"quicksend_keybsend.png"];
    [textViewReview addSubview: imgTextView];
    [textViewReview sendSubviewToBack: imgTextView];
    textViewReview.backgroundColor = [UIColor clearColor];
    */
    
    btnSpeaking = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSpeaking.frame = CGRectMake(75, 5, kScreen_Width-115, 30);
    [btnSpeaking setTitle:@"按住说话" forState:UIControlStateNormal];
    [btnSpeaking setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnSpeaking.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [btnSpeaking setBackgroundImage:[UIImage imageNamed:@"quicksend_speak.png"] forState:UIControlStateNormal];
    
    
//    [btnSpeaking addTarget:self action:@selector(speakingEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    //添加长按手势
    UILongPressGestureRecognizer *longPrees = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(recordBtnLongPressed:)];
    longPrees.delegate = self;
    [btnSpeaking addGestureRecognizer:longPrees];
    
    

//    UIButton *btnAt = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnAt.frame = CGRectMake(10, 5, 30, 30);
//    [btnAt setBackgroundImage:[UIImage imageNamed:@"feed_comments_at.png"] forState:UIControlStateNormal];
//    [btnAt addTarget:self action:@selector(clickAtEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    
    ///活动类型
    UIButton *btnActivitylist = [UIButton buttonWithType:UIButtonTypeCustom];
    btnActivitylist.frame = CGRectMake(5, 5, 30, 30);
    [btnActivitylist setBackgroundImage:[UIImage imageNamed:@"quicksend_activitylist.png"] forState:UIControlStateNormal];
    [btnActivitylist setBackgroundImage:[UIImage imageNamed:@"quicksend_activitylist_press.png"] forState:UIControlStateHighlighted];
    [btnActivitylist addTarget:self action:@selector(clickActivitylistEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    
    ///选取照片
    UIButton *btnPhone = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPhone.frame = CGRectMake(40, 5, 30, 30);
    [btnPhone setBackgroundImage:[UIImage imageNamed:@"quicksend_img.png"] forState:UIControlStateNormal];
    [btnPhone setBackgroundImage:[UIImage imageNamed:@"quicksend_img_press.png"] forState:UIControlStateHighlighted];
    [btnPhone addTarget:self action:@selector(clickPhoneEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    
    ///语音
    btnVoice = [UIButton buttonWithType:UIButtonTypeCustom];
    btnVoice.frame = CGRectMake(kScreen_Width-30-5, 5, 30, 30);
    
    [btnVoice setBackgroundImage:[UIImage imageNamed:@"quicksend_voice.png"] forState:UIControlStateNormal];
    [btnVoice setBackgroundImage:[UIImage imageNamed:@"quicksend_voice_press.png"] forState:UIControlStateHighlighted];
    [btnVoice addTarget:self action:@selector(clickVoiceEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    
    ///键盘
    btnKeyBoard = [UIButton buttonWithType:UIButtonTypeCustom];
    btnKeyBoard.frame = CGRectMake(kScreen_Width-30-5, 5, 30, 30);
    [btnKeyBoard setBackgroundImage:[UIImage imageNamed:@"quicksend_keyb.png"] forState:UIControlStateNormal];
    [btnKeyBoard setBackgroundImage:[UIImage imageNamed:@"quicksend_keyb_press.png"] forState:UIControlStateHighlighted];
    [btnKeyBoard addTarget:self action:@selector(clickKeyBoardEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [keyboardContainerView addSubview:textViewReview];
    [keyboardContainerView addSubview:btnActivitylist];
    [keyboardContainerView addSubview:btnPhone];
    [keyboardContainerView addSubview:btnVoice];
    [keyboardContainerView addSubview:btnKeyBoard];
    [keyboardContainerView addSubview:btnSpeaking];
    
    [self.view addSubview:keyboardContainerView];
    
//    keyboardContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

    
    btnKeyBoard.hidden = YES;
    btnSpeaking.hidden = YES;
}

#pragma mark  类型
-(void)clickActivitylistEvent:(id)sender{
    NSLog(@"");
    [textViewReview resignFirstResponder];
    [self showActivitylistSheetMenu];
}

#pragma mark  选取照片/拍照
-(void)clickPhoneEvent:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles: @"拍照",@"相册",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}


#pragma mark - UIActionSheet
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex:%ti",buttonIndex);
    if (buttonIndex == 2) {
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;//设置可编辑
    
    if (buttonIndex == 0) {
        //        拍照
        [self paizhao];
    }else if (buttonIndex == 1){
        //        相册
        [self addPhoto];
    }
}


-(void)paizhao{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:pickerController animated:YES completion:nil]; //进入照相界面
}



#pragma mark - private method
- (void)addPhoto {
    __weak typeof(self) weak_self = self;
    self.assetLibraryController.confirmBtnClickedBlock = ^(NSArray *array) {
        [weak_self addPhotoImageView];
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.assetLibraryController];
    [self  presentViewController:nav animated:YES completion:^{
    }];
}

- (void)addPhotoImageView {
    
    NSMutableArray *arrayImgData = [[NSMutableArray alloc] init];
    for (int i = 0; i < _assetLibraryController.assetManager.selectedArray.count; i ++) {
        PhotoAssetModel *model = _assetLibraryController.assetManager.selectedArray[i];
        CGImageRef ref = [[model.asset  defaultRepresentation]fullScreenImage];
        UIImage *img = [[UIImage alloc]initWithCGImage:ref];
        
        NSData *imageData = UIImageJPEGRepresentation(img, 0.3);
        NSLog(@"imageData:%lu",imageData.length/1024);
        [arrayImgData addObject:imageData];
    }
    ///发送
    [self sendCmdPublishRecord:arrayImgData];
    
    _assetLibraryController = nil;
}

- (PhotoAssetLibraryViewController*)assetLibraryController {
    if (!_assetLibraryController) {
        _assetLibraryController = [[PhotoAssetLibraryViewController alloc] init];
        _assetLibraryController.maxCount = 9;
    }
    return _assetLibraryController;
}



#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    NSData *imageData = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], 0.2);
    NSLog(@"imageData:%lu",imageData.length/1024);
    ///发送
    [self sendCmdPublishRecord:[NSArray arrayWithObjects:imageData, nil]];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark  语音按钮
-(void)clickVoiceEvent:(id)sender{
    tagOfHideKeyBoard = 1;
    heightKeyBoard = keyboardContainerView.frame.size.height;
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    keyboardContainerView.frame = CGRectMake(0, kScreen_Height - 40, kScreen_Width, 40);
    [keyboardContainerView setNeedsDisplay];
    btnVoice.hidden = YES;
    btnKeyBoard.hidden = NO;
    btnSpeaking.hidden = NO;
    textViewReview.hidden = YES;
}

#pragma mark  键盘
-(void)clickKeyBoardEvent:(id)sender{
    [textViewReview becomeFirstResponder];
    
    btnVoice.hidden = NO;
    btnKeyBoard.hidden = YES;
    btnSpeaking.hidden = YES;
    textViewReview.hidden = NO;
}


#pragma mark  键盘事件监听
//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
//    [textViewReview refreshHeight];
//    [keyboardContainerView setNeedsDisplay];
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    
    // get a rect for the textView frame
    CGRect containerFrame = keyboardContainerView.frame;
    
    if (tagOfHideKeyBoard == 1) {
        tagOfHideKeyBoard = 0;
        containerFrame.size.height = heightKeyBoard;
    }
    
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    keyboardContainerView.frame = containerFrame;
    /*
    [self.tableviewDetails setContentOffset:CGPointMake(0, self.tableviewDetails.contentSize.height-containerFrame.origin.y) animated:YES];
     */
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = keyboardContainerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    keyboardContainerView.frame = containerFrame;
    // commit animations
    [UIView commitAnimations];
}

///编辑框事件监听
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    NSLog(@"growingTextView willChangeHeight:%f",height);
    float diff = (growingTextView.frame.size.height - height);
    CGRect r = keyboardContainerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    keyboardContainerView.frame = r;
}

#pragma mark  发送按钮事件
///return键事件
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView{
    NSLog(@"发送--->");
    [textViewReview resignFirstResponder];
    textViewReview.text = @"";
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];

    return NO;
}

#pragma mark 添加键盘事件监听
-(void)addObserverOfKeyBoard{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)removeObserverOfKeyBoard{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
}



#pragma mark -  长按录音

- (void)recordBtnLongPressed:(UILongPressGestureRecognizer*) longPressedRecognizer{
    //长按开始
    if(longPressedRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"长按开始");
        [self.view addSubview:self.voiceView];
        _voiceView.voiceIconName = @"sound.png";
        [self.recordVoice beginRecordingByFileName:@"recordvoice"];
        __weak typeof(self) weak_self = self;
        _recordVoice.StopRecordingBlock = ^(NSString *path,NSString *name, NSInteger voiceTime){
            NSLog(@"录音文件路径:%@",path);
            NSLog(@"录音文件名:%@",name);
            
            weak_self.pathFile = path;
            weak_self.nameFile = name;
            weak_self.recordVoice = nil;
            weak_self.voiceView = nil;
            
            if (weak_self.isSendVoice) {
                NSLog(@"发送");
                [weak_self sendCmd];
            }else{
                NSLog(@"删除");
                [weak_self removeFileFromLocal];
            }
        };
        
    }//长按结束
    else if(longPressedRecognizer.state == UIGestureRecognizerStateEnded || longPressedRecognizer.state == UIGestureRecognizerStateCancelled){
        NSLog(@"长按结束");
        if (self.voiceView) {
            [self.voiceView removeFromSuperview];
        }
        if (_recordVoice) {
            [_recordVoice stopRecording];
        }
        
        
    }else if ([longPressedRecognizer state]==UIGestureRecognizerStateChanged){
        
        CGPoint location=[longPressedRecognizer locationInView:self.view];
        
        if ((location.x > xPointVoice) && (location.x < xPointVoice + Voice_Size) && (location.y > yPointVoice) && (location.y < yPointVoice +Voice_Size)) {
            NSLog(@"取消发送");
            ///标记为
            _isSendVoice = FALSE;
            if (_voiceView) {
                _voiceView.voiceIconName = @"remove_allReply_clicked.png";
                _voiceView.capionTitleValue = @"松开取消发送";
                [_voiceView setVoiceSoundHide:YES];
            }
            
        }else{
            _isSendVoice = TRUE;
            if (_voiceView) {
                _voiceView.voiceIconName = @"sound.png";
                _voiceView.capionTitleValue = @"滑动至此取消发送";
                [_voiceView setVoiceSoundHide:NO];
            }
        }
    }
}

-(void)sendCmd{
    NSString *path = [NSString stringWithFormat:@"%@/%@",_pathFile,_nameFile];
    NSLog(@"path:%@",path);
    ///判断 size
    [self getFileByPath:path];
    
}

-(NSData *)getFileByPath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path]){
        NSLog(@"文件存在--->");
        NSData *data = [fileManager contentsAtPath:path];
        //        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:path]];
        NSLog(@"size:%lu",[data length]);
        NSLog(@"size:%lu",[data length]/1024);
        return data;
    }else{
        NSLog(@"文件不存在--->");
        return nil;
    }
}

-(void)removeFileFromLocal{
    NSString *path = [NSString stringWithFormat:@"%@/%@",_pathFile,_nameFile];
    NSLog(@"path:%@",path);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *err;
    [fileManager removeItemAtPath:path error:&err];
    NSLog(@"removeFileFromLocal--->");
}

- (VoiceToolView*)voiceView {
    if (!_voiceView) {
        xPointVoice = (kScreen_Width-Voice_Size)/2;
        yPointVoice = (kScreen_Height-Voice_Size)/2-40;
        NSLog(@"xPointVoice:%f",xPointVoice);
        NSLog(@"yPointVoice:%f",yPointVoice);
        _voiceView = [[VoiceToolView alloc] initWithFrame:CGRectMake(xPointVoice, yPointVoice, Voice_Size, Voice_Size)];
    }
    return _voiceView;
}

- (RecordVoice*)recordVoice {
    if (!_recordVoice) {
        _recordVoice = [[RecordVoice alloc] initWithVoiceToll:_voiceView];
    }
    return _recordVoice;
}


#pragma mark - 音频播放
-(void)playVoice:(id)sender{
    DetailsReviewCell *cell;
    if (isIOS8) {
        cell = (DetailsReviewCell *)[[sender superview] superview] ;
    }else{
        cell = (DetailsReviewCell *)[[[sender superview] superview] superview];
    }
    NSIndexPath* indexPath=[self.tableviewDetails indexPathForCell:cell];
    NSLog(@"indexPath row:%ti",indexPath.row);
    
//    cell.labelVoiceDuration.text = @"444'";
    
    NSDictionary *itemInfo = [self.arrayRecordList objectAtIndex:indexPath.row -1];
    NSLog(@"itemInfo:%@",itemInfo);
    NSString *soundUrl = @"";
    if ([itemInfo objectForKey:@"soundUrl"]) {
        soundUrl = [itemInfo safeObjectForKey:@"soundUrl"];
    }
    NSLog(@"soundUrl:%@",soundUrl);
    if ([soundUrl isEqualToString:@""]) {
        return;
    }
    
    if (_playback) {

        [_playback pause];
        _playback = nil;
        
        
        if (_preCell != nil) {
            NSLog(@"图片复位-----：%@",_preCell);
            _preCell.imgVoice.image = [UIImage imageNamed:@"voice_sign_other_3.png"];
        }else{
            _preCell = cell;
        }
    }
    
    __weak typeof(self) weak_self = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        AFSoundItem *item = [[AFSoundItem alloc] initWithStreamingURL:[NSURL URLWithString:soundUrl]];
        
        _playback = [[AFSoundPlayback alloc] initWithItem:item];
        [_playback play];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"----->");
            [_playback listenFeedbackUpdatesWithBlock:^(AFSoundItem *item) {
                NSLog(@"Item duration: %ld - time elapsed: %ld", (long)item.duration, (long)item.timePlayed);
                NSString *imgName = @"";
                NSInteger durationing = item.timePlayed;
                switch (durationing%3) {
                    case 0:
                    {
                        imgName = @"voice_sign_other_1.png";
                    }
                        break;
                    case 1:
                    {
                        imgName = @"voice_sign_other_2.png";
                    }
                        break;
                    case 2:
                    {
                        imgName = @"voice_sign_other_3.png";
                    }
                        break;
                        
                    default:
                    {
                        imgName = @"voice_sign_other_3.png";
                    }
                        break;
                }
                cell.imgVoice.image = [UIImage imageNamed:imgName];
                
            } andFinishedBlock:^(void){
                NSLog(@"andFinishedBlock");
                cell.imgVoice.image = [UIImage imageNamed:@"voice_sign_other_3.png"];
            }];
        });
        

    });
    
    
}


#pragma mark - 类型事件

-(void)showActivitylistSheetMenu{
    sheetMenuTag = @"1";
    SheetMenuView *sheet = [[SheetMenuView alloc]initWithlist:self.arrayActivitySheetMenu headTitle:@"请选择类型" footBtnTitle:@"取消" cellType:0];
    sheet.delegate = self;
    [sheet showInView:nil];
}

#pragma mark - 电话事件

-(void)showCallSheetMenu{
    
    SheetMenuModel *model;
    NSMutableArray *array = [[NSMutableArray  alloc] init];

    model = [[SheetMenuModel alloc]init];
    model.icon = @"";
    model.icon_selected = @"";
    model.iconLeft = @"entity_operation_contact.png";
    model.iconRight = @"select_contact_message.png";
    model.title = @"13918745346";
    model.btnNum = @"2";
    [array addObject:model];
    
    
    sheetMenuTag = @"2";
    SheetMenuView *sheet = [[SheetMenuView alloc]initWithlist:array headTitle:@"" footBtnTitle:@"取消" cellType:1];
    sheet.delegate = self;
    [sheet showInView:nil];
    
}

#pragma mark - sheetmenu 事件回调

-(void)didSelectSheetMenuIndex:(NSInteger)index{
    NSLog(@"didSelectSheetMenuIndex:%ti",index);
    if ([sheetMenuTag isEqualToString:@"1"]) {
        ///类型
    }else if ([sheetMenuTag isEqualToString:@"2"]) {
        ///电话
    }else if ([sheetMenuTag isEqualToString:@"3"]) {
        ///更多
    }
    
    __weak typeof(self) weak_self = self;
    ReleaseViewController *releaseController = [[ReleaseViewController alloc] init];
    releaseController.title = @"添加活动记录";
    
    releaseController.typeOfOptionDynamic = TypeOfOptionDynamicCRMRecord;
    releaseController.ReleaseSuccessNotifyData = ^(){
        ///重新请求数据
        
    };
    releaseController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:releaseController animated:YES];
}


-(void)callPhoneIndex:(NSInteger)index{
    NSLog(@"callPhoneIndex:%ti",index);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        NSLog(@"打电话--->");
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否呼叫" message:@"4000 880 880" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"呼叫", nil];
        alert.tag = 10101;
        [alert show];
         */
//        [self callToCurPhoneNum:@"13918745346"];
        [CommonFuntion callToCurPhoneNum:@"13918745346" atView:self.view];
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"当前设备不支持拨打电话" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)sendMsgIndex:(NSInteger)index{
    NSLog(@"sendMsgIndex:%ti",index);
    
#warning 测试数据发送短信
    MassMsgViewController *controller = [[MassMsgViewController alloc] init];
    controller.delegate = self;
    ///详情页面发送消息 直接传递name phone
    controller.typeContact = @"commondetailscall";
    controller.arrayAllContact = nil ;
    controller.contactName = @"赵军平";
    controller.contactPhone = @"13918745346";
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - DetailsRecordDelegate  系统记录 cell点击事件
-(void)clickDetailRecordEvent:(NSInteger)index{
    NSLog(@"clickDetailRecordEvent row：%ti",index);
    
}

#pragma mark - WorkGroupDelegate cell点击事件

///点击头像事件
-(void)clickUserIconEvent:(NSInteger)row{
    NSLog(@"clickUserIconEvent row：%li",row);
}


-(void)clickVoiceDataEvent:(NSInteger)row{
    NSLog(@"clickVoiceDataEvent row：%li",row);
    
}




///点击文件事件
-(void)clickFileEvent:(NSInteger)row{
    NSLog(@"clickFileEvent row：%li",row);
    
    NSDictionary *fileItem = nil;
     NSDictionary *item = [self.arrayRecordList objectAtIndex:row-1];
    
    if ([item objectForKey:@"file"]) {
        if ([[[item objectForKey:@"file"] objectForKey:@"type"] integerValue] == 0) {
            ///文件
            fileItem = [item objectForKey:@"file"];
        }
    }else if ([item objectForKey:@"recordNew"]) {
        if ([[item objectForKey:@"recordNew"] objectForKey:@"ftype"] && [[[item objectForKey:@"recordNew"] objectForKey:@"ftype"] integerValue] == 0) {
            fileItem = [[[item objectForKey:@"recordNew"] objectForKey:@"imageFiles"] objectAtIndex:0];
        }
    }
    
    KnowledgeFileDetailsViewController *controller = [[KnowledgeFileDetailsViewController alloc] init];
    controller.detailsOld = fileItem;
    controller.viewFrom = @"other";
    controller.isNeedRightNavBtn = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

///点击地址事件
-(void)clickAddressEvent:(NSInteger)row{
    NSLog(@"clickAddressEvent row：%li",row);
    
    NSDictionary *item = [self.arrayRecordList objectAtIndex:row-1];
    
    double latitude = 0;
    double longitude = 0;
    if ([item objectForKey:@"latitude"]) {
        latitude = [[item objectForKey:@"latitude"] doubleValue];
    }
    if ([item objectForKey:@"longitude"]) {
        longitude = [[item objectForKey:@"longitude"] doubleValue];
    }
    
    ///location
    NSString *location = @"";
    if ([item objectForKey:@"location"]) {
        location = [item objectForKey:@"location"];
    }
    NSString *locationDetail = @"";
    if ([item objectForKey:@"locationDetail"]) {
        locationDetail = [item objectForKey:@"locationDetail"];
    }
    
    if (latitude !=0 && longitude !=0) {
        MapViewViewController *controller = [[MapViewViewController alloc] init];
        controller.typeOfMap = @"show";
        controller.latitude = latitude;
        controller.longitude = longitude;
        controller.location = location;
        controller.locationDetail = locationDetail;
        [self.navigationController pushViewController:controller animated:YES];
    }
}


///点击内容中的@
-(void)clickContentCharType:(NSString *)type content:(NSString *)content atIndex:(NSIndexPath *)index{
    NSLog(@"clickContentCharType type:%@ content:%@ index:%li",type,content,index.row);
    
    NSDictionary *item = [self.arrayRecordList objectAtIndex:index.row-1];
    long long uid = [CommonModuleFuntion getUidByAtName:[[content substringFromIndex:1] stringByReplacingOccurrencesOfString:@" " withString:@
                                                         ""] fromAtList:[item objectForKey:@"ats"]];
    NSLog(@"uid:%lld",uid);
}


///点击图片事件
-(void)clickImageViewEvent:(NSIndexPath *)imgIndexPath{
    
    NSLog(@"clickImageViewEvent section：%li andImgIndex:%li",imgIndexPath.section,imgIndexPath.row);
    
    [PhotoBroswerVC show:self type:PhotoBroswerVCTypeZoom index:imgIndexPath.row photoModelBlock:^NSArray *{
        
        DetailsReviewCell *cell = (DetailsReviewCell *)[self.tableviewDetails cellForRowAtIndexPath:[NSIndexPath indexPathForItem:imgIndexPath.section inSection:0]];
        
        NSDictionary *item = [self.arrayRecordList objectAtIndex:imgIndexPath.section-1] ;
        //        NSLog(@"-----img  click--item:%@",item);
        
        NSArray *arrayImg;
        ///客户 recordNew  联系人 file
        if (([item objectForKey:@"recordNew"] && [[[item objectForKey:@"recordNew"] objectForKey:@"ftype"] integerValue] == 1 && [[item objectForKey:@"recordNew"] objectForKey:@"imageFiles"]) || ([item objectForKey:@"file"] && [[[item objectForKey:@"file"] objectForKey:@"type"] integerValue] == 1 && [[item objectForKey:@"file"] objectForKey:@"imageFiles"])) {
            
            ///联系人
            if([item objectForKey:@"file"] && [[[item objectForKey:@"file"] objectForKey:@"type"] integerValue] == 1 && [[item objectForKey:@"file"] objectForKey:@"imageFiles"]){
                arrayImg = [[item objectForKey:@"file"] objectForKey:@"imageFiles"];
            }else{
                arrayImg = [[item objectForKey:@"recordNew"] objectForKey:@"imageFiles"];
            }
        }

        
        NSLog(@"-----img  click--arrimg:%@",arrayImg);
        NSString *imgSizeType = @"lpic";
        
        
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


#pragma mark - 拨打电话
-(void)callToCurPhoneNum:(NSString *)phoneNum
{
    //---电话结束以后会返回
    UIWebView *callWebview = [[UIWebView alloc] init] ;
    
    NSMutableString *strNumber = [[NSMutableString alloc] init];
    [strNumber appendString:@"tel:"];
    [strNumber appendString:phoneNum];
    
    NSURL *telURL =[NSURL URLWithString:strNumber];
    [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
    //添加到view上
    [self.view addSubview:callWebview];
    
}


#pragma mark - 发送短信结果回调
-(void)resultOfMassMsg:(BOOL)isSuccess desc:(NSString *)desc{
    if (isSuccess) {
        NSLog(@"发送信息成功");
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


#pragma mark - 上拉下拉刷新相关事件
//集成刷新控件
- (void)setupRefresh
{
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [self.tableviewDetails addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"CommonDetailView"];
    //上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableviewDetails addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 自动刷新(一进入程序就下拉刷新)
    //    [self.tableviewCampaign headerBeginRefreshing];
}

// 结束加载
-(void)reloadRefeshView{
    // 刷新列表
//    [self.tableviewDetails reloadData];
    [self.tableviewDetails footerEndRefreshing];
    [self.tableviewDetails headerEndRefreshing];
}

// 下拉
- (void)headerRereshing
{
    NSLog(@"headerRereshing--下拉-->");
    
    if ([self.tableviewDetails isFooterRefreshing]) {
        [self.tableviewDetails headerEndRefreshing];
        return;
    }
    
    pageNo = 1;
    [self getRecordList];
}

// 上拉
- (void)footerRereshing
{
    NSLog(@"footerRereshing--上拉-->");
    
    if ([self.tableviewDetails isHeaderRefreshing]) {
        [self.tableviewDetails footerEndRefreshing];
        return;
    }
    [self getRecordList];
    
    ///客户
    if (self.typeOfDetail == 1) {
        
    }else if(self.typeOfDetail == 2){
        ///销售机会
        
    }else if(self.typeOfDetail == 3){
        ///联系人
        
    }else if(self.typeOfDetail == 4){
        ///销售线索
        
    }else if(self.typeOfDetail == 5){
        ///市场活动
        
    }
}


#pragma mark - 服务器请求
#pragma mark - 跟进记录
-(void)getRecordList{
    NSString *url = @"";
    NSString *type = @"";
    ///客户
    if (self.typeOfDetail == 1) {
        
    }else if(self.typeOfDetail == 2){
        ///销售机会

    }else if(self.typeOfDetail == 3){
        ///联系人

    }else if(self.typeOfDetail == 4){
        ///销售线索

    }else if(self.typeOfDetail == 5){
        ///市场活动
        url = GET_CAMPAIGN_DETAILS_FOLLOWRECORD;
        type = @"0";
    }
    
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    [params setObject:[NSNumber numberWithInteger:pageNo] forKey:@"pageNo"];
    [params setObject:[NSNumber numberWithInt:PageSize] forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithLongLong:self.idOfDetails] forKey:@"id"];
    [params setObject:type forKey:@"type"];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP,url] params:params success:^(id responseObj) {
        
        NSLog(@"记录 responseObj:%@",responseObj);
        //字典转模型
        NSDictionary *resultdic = responseObj;
        
        if (resultdic && [[resultdic objectForKey:@"status"] integerValue] == 0) {
            [self setViewRequestSusscess:resultdic];
        }else if (resultdic && [[resultdic objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getRecordList];
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
        NSLog(@"error:%@",error);
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
    
    if ([resultdic objectForKey:@"followRecords"] ) {
        array = [resultdic objectForKey:@"followRecords"] ;
    }
    NSLog(@"count:%ti",[array count]);
    
    ///有数据返回
    if (array && [array count] > 0) {
        if(pageNo == 1)
        {
//            [self.arrayRecordList removeAllObjects];
        }
        ///添加当前页数据到列表中...
//        [self.arrayDetails addObjectsFromArray:array];

        ///页码++
        if ([array count] == PageSize) {
            pageNo++;
            [self.tableviewDetails setFooterHidden:NO];
        }else
        {
            ///隐藏上拉刷新
            [self.tableviewDetails setFooterHidden:YES];
        }
        
    }else{
        ///返回为空
        ///隐藏上拉刷新
        [self.tableviewDetails setFooterHidden:YES];
        ///若是第一页 读取是否存在缓存
        if(pageNo == 1)
        {
//            [self.arrayDetails removeAllObjects];
        }
    }
}

// 请求失败时数据处理
-(void)setViewRequestFaild:(NSString *)desc
{
    ///若是第一页 读取是否存在缓存
    if(pageNo == 1)
    {
    }
    [CommonFuntion showToast:desc inView:self.view];
}



#pragma mark - 详情
-(void)getRecordDetails{
    NSString *url = @"";
    ///客户
    if (self.typeOfDetail == 1) {
        
    }else if(self.typeOfDetail == 2){
        ///销售机会
        
    }else if(self.typeOfDetail == 3){
        ///联系人
        
    }else if(self.typeOfDetail == 4){
        ///销售线索
        
    }else if(self.typeOfDetail == 5){
        ///市场活动
        url = GET_CAMPAIGN_DETAILS;
    }
    
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:[NSNumber numberWithLongLong:self.idOfDetails] forKey:@"id"];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP,url] params:params success:^(id responseObj) {
        
        NSLog(@"详情 responseObj:%@",responseObj);
        //字典转模型
        NSDictionary *resultdic = responseObj;
        
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            self.dicRecordDetails = responseObj;
            [self initHeadValue];
            ///详情
            if ([self.dicRecordDetails objectForKey:@"columns"]) {
                NSArray *array = [self.dicRecordDetails objectForKey:@"columns"];
                if (array && [array count]>0) {
                    [self.arrayRecordDetails addObjectsFromArray:array];
                }
            }
            ///团队成员
            if ([self.dicRecordDetails objectForKey:@"staffs"]) {
                self.arrayContacts =  [self.dicRecordDetails objectForKey:@"staffs"];
                if (self.arrayContacts) {
                    [self notifyTableviewHeadDetails4];
                }
            }
            NSLog(@"self.arrayContacts:%@",self.arrayContacts);
            NSLog(@"self.arrayRecordDetails:%@",self.arrayRecordDetails);
//
        }else if (resultdic && [[resultdic objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getRecordDetails];
            };
            [comRequest loginInBackground];
        }
        else{
            NSString *desc = [resultdic safeObjectForKey:@"desc"];
            ///加载失败 做相应处理
//            [self setViewRequestFaild:desc];
        }
        ///刷新UI
//        [self reloadRefeshView];
    } failure:^(NSError *error) {
        NSLog(@"error:%@",error);
        ///网络失败 做相应处理
        [self setViewRequestFaild:NET_ERROR];
        ///刷新UI
//        [self reloadRefeshView];
    }];
}


#pragma mark - 相册/拍照
-(void)sendCmdPublishRecord:(NSArray *)arrayImgData{
    
    [self getRecordList];
    
}


@end
