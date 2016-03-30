//
//  CallListViewController.m
//  lianluozhongxin
//
//  Created by Vescky on 14-6-16.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "CallListViewController.h"
#import "CallListFilterViewController.h"
#import "CallListCell.h"
#import "MJRefresh.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"
#import "AFSoundPlaybackHelper.h"

@interface CallListViewController ()<CallListFilterViewControllerDelegate,CallListCellDelegate> {
    
    NSInteger vScrolH;// 增加content size
    int  currentPage;
    int listPage,lastPosition;
    NSInteger pageCount;
    
    NSDictionary *filterDictionary;
    NSIndexPath *lastSelectIndexPath;
    
    UISwipeGestureRecognizer *recognizerFromRight,*recognizerFromLeft;
    
    BOOL isCurView;
}
@end

@implementation CallListViewController

#pragma mark - life-cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = kView_BG_Color;
    self.tabBarController.navigationItem.title = @"话单";
//    self.title = @"话单";
    
    [self setCurViewFrame];
    isCurView = YES;
    [self initView];
    [self initData];
    
    NSLog(@"rightBarButtonItem:%@",self.navigationItem.rightBarButtonItem);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //离开此页，停止播放
    [AFSoundPlaybackHelper stop_helper];
    isCurView = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [tbView reloadData];
    isCurView = YES;
    [self addNavBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private
- (void)initData {
    dataSource = [[NSMutableArray alloc] init];
    listPage = 1;
    lastPosition = 0;
    currentPage = 100;
    [self getDataFromServerWithParams:nil];
}

- (void)initView {
    UIButton *btn = (UIButton*)[self.view viewWithTag:100];
    btn.selected = YES;
    [self setupRefresh];
}

///导航按钮
-(void)addNavBar{

    UIButton *filterButton=[UIButton buttonWithType:UIButtonTypeCustom];
    filterButton.frame=CGRectMake(0, 0, 21, 20);
    [filterButton setBackgroundImage:[UIImage imageNamed:@"account_filter.png"] forState:UIControlStateNormal];
    [filterButton setBackgroundImage:[UIImage imageNamed:@"account_filter.png"] forState:UIControlStateHighlighted];
    [filterButton addTarget:self action:@selector(rightBarButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *filterBarButton = [[UIBarButtonItem alloc] initWithCustomView:filterButton];
    
    //    [self.navigationItem setRightBarButtonItem:filterBarButton];
    
//    self.navigationItem.rightBarButtonItem = filterBarButton;
    
    self.tabBarController.navigationItem.rightBarButtonItems = nil;
    self.tabBarController.navigationItem.rightBarButtonItem = filterBarButton;
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
}

- (void)rightBarButtonAction {
    NSLog(@"need to implement this methor");
    CallListFilterViewController *filterView = [[CallListFilterViewController alloc] init];
    filterView.delegate = self;
    filterView.filtType = currentPage - 100;
    filterView.defaultCondition = filterDictionary;

    filterView.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:filterView animated:YES];
    [self.tabBarController.navigationController pushViewController:filterView animated:YES];
}


-(void)getDataFromServivr{
    if (!isCurView) {
        return;
    }
    if (dataSource && dataSource.count > 0) {
        return;
    }
    [self getDataFromServerWithParams:nil];
}

- (void)getDataFromServerWithParams:(NSDictionary*)params {
    NSLog(@"getDataFromServerWithParams params:%@",params);
    NSString *requestAction;
    if (currentPage == 100) {
        //已接来电
        requestAction = LLC_GET_RECEIVED_CALL_ACTION;
    }
    else if (currentPage == 101) {
        //未接来电
        requestAction = LLC_GET_NO_ANSWER_DETAIL_ACTION;
    }
    else if (currentPage == 102) {
        //外呼记录
        requestAction = LLC_GET_VOIP_CALL_RECORD_ACTION;
    }else if (currentPage == 103) {
        //语音信箱
        requestAction = LLC_GET_VOICE_BOX_ACTION;
    }
    
    NSLog(@"requestAction :%@",requestAction);
    //获取新数据的时候，停掉
    [AFSoundPlaybackHelper stop_helper];
    lastSelectIndexPath = nil;
    
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:params];
    if ([rDict count] < 1) {
        [rDict setValue:@"0" forKey:@"areaId"];
        [rDict setValue:@"全国" forKey:@"areaName"];
    }
    [rDict setObject:[NSNumber numberWithInt:listPage] forKey:@"pageCount"];
    [rDict removeObjectForKey:@"username"];
    ///外呼记录不用传areaId
    if (currentPage == 102) {
        [rDict removeObjectForKey:@"areaId"];
    }
    
    
    NSLog(@"rDict :%@",rDict);
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,requestAction] params:rDict success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            [self setViewRequestSusscess:jsonResponse];
            /*
             id data = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"];
             if ([data respondsToSelector:@selector(count)] && [data count] > 0) {
             labelNoContent.hidden = YES;
             [self fillDataSource:data];
             lastPosition = dataSource.count;
             
             if (listPage <= 1) {
             tbView.hidden = NO;
             tbView.alpha = 0.0;
             [scView setContentOffset:CGPointMake(0, 0) animated:YES];
             [UIView animateWithDuration:0.5 animations:^{
             tbView.alpha = 1.0;
             }];
             }
             listPage++;
             
             }
             else {
             NSLog(@"无数据");
             if (!dataSource || dataSource.count < 1) {
             tbView.hidden = YES;
             labelNoContent.hidden = NO;
             }
             else {
             [CommonFuntion showToast:@"没有更多数据了~" inView:self.view];
             }
             
             }
             */
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getDataFromServerWithParams:params];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
            if (!dataSource || dataSource.count < 1) {
                tbView.hidden = YES;
                labelNoContent.hidden = NO;
            }
        }
        ///刷新UI
        [self reloadRefeshView];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        if (!dataSource || dataSource.count < 1) {
            tbView.hidden = YES;
            labelNoContent.hidden = NO;
        }
        ///刷新UI
        [self reloadRefeshView];
    }];
}


// 请求成功时数据处理
-(void)setViewRequestSusscess:(NSDictionary *)result
{
    id data = [[result objectForKey:@"resultMap"] objectForKey:@"data"];
    if ([data respondsToSelector:@selector(count)] && [data count] > 0) {
        labelNoContent.hidden = YES;
        
        if (listPage == 1) {
            [dataSource removeAllObjects];
        }
        
        [self fillDataSource:data];
        lastPosition = dataSource.count;
        
        if (listPage <= 1) {
            pageCount = dataSource.count;
            tbView.hidden = NO;
            tbView.alpha = 0.0;
            [scView setContentOffset:CGPointMake(0, 0) animated:YES];
            [UIView animateWithDuration:0.5 animations:^{
                tbView.alpha = 1.0;
            }];
        }
        if (pageCount == [data count]) {
            listPage++;
            [scView setFooterHidden:NO];
        }else{
            [scView setFooterHidden:YES];
        }
        
        
    }
    else {
        NSLog(@"无数据");
        [scView setFooterHidden:YES];
        if (!dataSource || dataSource.count < 1) {
            tbView.hidden = YES;
            labelNoContent.hidden = NO;
        }
        else {
            [CommonFuntion showToast:@"没有更多数据了~" inView:self.view];
        }
        
    }
}



- (void)fillDataSource:(NSArray*)data {
    
    for (int i = 0; i < [data count]; i++) {
        CellDataInfo *cInfo = [[CellDataInfo alloc] initWithCellDataInfo:[self parseForContent:[data objectAtIndex:i]] expandable:YES expanded:NO];
        [dataSource addObject:cInfo];
    }
    
    
    [tbView reloadData];
    
    CGRect tbRect = tbView.frame;
    tbRect.size.height = [self calculateContentHeight];
    tbView.frame = tbRect;
    
    
    scView.contentSize = CGSizeMake(scView.frame.size.width, tbRect.size.height + 20+vScrolH);
    
    if (listPage > 1 && lastPosition <= dataSource.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastPosition-1 inSection:0];
        [tbView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
    else {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [tbView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}

- (NSDictionary*)parseForContent:(NSDictionary*)dict {
    
    if (currentPage == 100) {
        ///已接来电
        id titleName = [dict safeObjectForKey:@"CONTACT_NAME"];
        id subTitleName = [dict safeObjectForKey:@"CUSTOMER_NAME"];
        if ([titleName isEqualToString:@""]) {
            titleName = [dict safeObjectForKey:@"CUSTOMER_PHONE"];
            subTitleName = [dict safeObjectForKey:@"CITY_NAME"];
        }
        
        ///联系人为空 则显示CUSTOMER_PHONE+归属地
        if ([titleName isEqualToString:@""]) {
            
        }else{
            ///CONTACT_NAME+CUSTOMER_NAME
            
        }
        
        
        NSMutableDictionary *rDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                      [NSNumber numberWithInt:currentPage],@"type",
                                      titleName,@"titleName",
                                      subTitleName,@"subTitleName", nil];
        if ([dict objectForKey:@"INCOMING_TIME"]) {
            [rDict setObject:[dict safeObjectForKey:@"INCOMING_TIME"] forKey:@"time"];
        }
        if ([dict objectForKey:@"CUSTOMER_PHONE"]) {
            [rDict setObject:[dict safeObjectForKey:@"CUSTOMER_PHONE"] forKey:@"customerPhone"];
        }
        if ([dict objectForKey:@"TALK_INTERVAL"]) {
            [rDict setObject:[dict safeObjectForKey:@"TALK_INTERVAL"] forKey:@"duration"];
        }
        if ([dict objectForKey:@"PLATFORM"]) {
            [rDict setObject:[dict safeObjectForKey:@"PLATFORM"] forKey:@"platform"];
        }
        if ([dict objectForKey:@"UQID"]) {
            [rDict setObject:[dict safeObjectForKey:@"UQID"] forKey:@"lsh"];
        }
        if ([dict objectForKey:@"USERNAME"]) {
            [rDict setObject:[dict safeObjectForKey:@"USERNAME"] forKey:@"sitName"];
        }
        
        return rDict;
    }
    else if (currentPage == 101) {
        //未接来电
        ///title
        id titleName = [dict safeObjectForKey:@"CONTACT_NAME"];
        ///subtitle
        id subTitleName = [dict safeObjectForKey:@"CUSTOMER_NAME"];
        if ([titleName isEqualToString:@""]) {
            titleName = [dict safeObjectForKey:@"CUSTOMER_PHONE"];
            subTitleName = [dict safeObjectForKey:@"CITYNAME"];
        }
        
        
        
        NSMutableDictionary *rDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                      [NSNumber numberWithInt:currentPage],@"type",
                                      titleName,@"titleName",
                                      subTitleName,@"subTitleName", nil];
        
        ///date
        if ([dict objectForKey:@"NOANSWER_TIME"]) {
            [rDict setObject:[dict safeObjectForKey:@"NOANSWER_TIME"] forKey:@"time"];
        }
        
        ///phone
        if ([dict objectForKey:@"CUSTOMER_PHONE"]) {
            [rDict setObject:[dict safeObjectForKey:@"CUSTOMER_PHONE"] forKey:@"customerPhone"];
        }
        
        if ([dict objectForKey:@"USERNAME"]) {
            [rDict setObject:[dict safeObjectForKey:@"USERNAME"] forKey:@"sitName"];
        }
        
        return rDict;
    }
    else if (currentPage == 102) {
        ///外呼记录
        id titleName = [dict safeObjectForKey:@"CONTACT_NAME"];
//        if ([titleName isEqualToString:@""]) {
//            titleName = [dict safeObjectForKey:@"CALLED"];
//        }
        
        id subTitleName = [dict safeObjectForKey:@"CUSTOMER_NAME"];
        
        NSMutableDictionary *rDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                      [NSNumber numberWithInt:currentPage],@"type",
                                      titleName,@"titleName",
                                      subTitleName,@"subTitleName", nil];
        
        if ([dict objectForKey:@"CALLED"]) {
            [rDict setObject:[dict safeObjectForKey:@"CALLED"] forKey:@"customerPhone"];
        }
        
//        NSLog(@"START_TIME:%@",[dict objectForKey:@"START_TIME"]);
        ///date
        if ([dict objectForKey:@"START_TIME"]) {
            [rDict setObject:[dict safeObjectForKey:@"START_TIME"] forKey:@"time"];
        }
        
        return rDict;
    }else if (currentPage == 103) {
        ///CONTACT_NAME+CUSTOMER_NAME
        ///语音
        id titleName = [dict safeObjectForKey:@"CONTACT_NAME"];
        id subTitleName = [dict safeObjectForKey:@"CUSTOMER_NAME"];
        
        if ([titleName isEqualToString:@""]) {
            titleName = [dict safeObjectForKey:@"CALLER_NO"];
            subTitleName = [dict safeObjectForKey:@"DISTRICT"];
        }
        
        
        
        NSMutableDictionary *rDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                      [NSNumber numberWithInt:currentPage],@"type",
                                      titleName,@"titleName",
                                      subTitleName,@"subTitleName", nil];
        if ([dict objectForKey:@"START_TIME"]) {
            [rDict setObject:[dict safeObjectForKey:@"START_TIME"] forKey:@"time"];
        }
        if ([dict objectForKey:@"CALLER_NO"]) {
            [rDict setObject:[dict safeObjectForKey:@"CALLER_NO"] forKey:@"customerPhone"];
        }
        if ([dict objectForKey:@"MESSAGE_INTERVAL"]) {
            [rDict setObject:[dict safeObjectForKey:@"MESSAGE_INTERVAL"] forKey:@"duration"];
        }
        if ([dict objectForKey:@"PLATFORM"]) {
            [rDict setObject:[dict safeObjectForKey:@"PLATFORM"] forKey:@"platform"];
        }
        if ([dict objectForKey:@"LSH"]) {
            [rDict setObject:[dict safeObjectForKey:@"LSH"] forKey:@"lsh"];
        }
        
        if ([dict objectForKey:@"USERNAME"]) {
            [rDict setObject:[dict safeObjectForKey:@"USERNAME"] forKey:@"sitName"];
        }
        
        return rDict;
    }
    return nil;
}

- (float)calculateContentHeight {
    float tHeight = 0.0f;
    for (int i = 0; i < dataSource.count; i++) {
        CellDataInfo *cInfo = [dataSource objectAtIndex:i];
        if (cInfo.expanded) {
            
            if (currentPage == 100){
                tHeight = tHeight + 180.f;
            }else if (currentPage == 101) {
                tHeight = tHeight + 180.f - 120.0f;
            }else if (currentPage == 102) {
                tHeight = tHeight + 180.f - 120.0f;
            }else if (currentPage == 103) {
                tHeight = tHeight + 180.f;
            }
        }
        else {
            tHeight = tHeight + 60.0f;
        }
    }
    return tHeight;
}

#pragma mark - 处理手势检测
- (void)addSwipeGuestureToView:(UIView*)v {
    if (!recognizerFromRight) {
        recognizerFromRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGuesture:)];
        recognizerFromRight.direction = UISwipeGestureRecognizerDirectionRight;
    }
    if (!recognizerFromLeft) {
        recognizerFromLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGuesture:)];
        recognizerFromLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    }

    [v addGestureRecognizer:recognizerFromRight];
    [v addGestureRecognizer:recognizerFromLeft];
}

- (void)removeSwipeGuestureForView:(UIView*)v {
    if (recognizerFromLeft) {
        [v removeGestureRecognizer:recognizerFromLeft];
    }
    if (recognizerFromRight) {
        [v removeGestureRecognizer:recognizerFromRight];
    }
}

- (void)handleSwipeGuesture:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"left direction,界面右移");
        NSLog(@"currentPage:%i",currentPage);
        if (currentPage >= 103) {
            return;
        }
        [self swipeTableViewAnimation:YES];
//        [self btnAction:[self.view viewWithTag:(currentPage+1)]];
    }
    else if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"right direction,界面左移");
        NSLog(@"currentPage:%i",currentPage);
        if (currentPage <= 100) {
            return;
        }
        [self swipeTableViewAnimation:NO];
//        [self btnAction:[self.view viewWithTag:(currentPage-1)]];
    }
}

#pragma mark - 自定义过渡的动画效果
- (void)swipeTableViewAnimation:(bool)direction {
    __block CGRect tbRect = tbView.frame;
    __block int isLeft = direction;
    labelNoContent.hidden = YES;
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    UIButton *btn1 = (UIButton*)[topView viewWithTag:(currentPage)];
    UIButton *btn2 = (UIButton*)[topView viewWithTag:(currentPage-1)];
    if (isLeft) {
        btn2 = (UIButton*)[topView viewWithTag:(currentPage+1)];
    }
    if (btn1) {
        btn1.selected = NO;
    }
    if (btn2) {
        btn2.selected = YES;
    }
    
    [UIView animateWithDuration:.5 animations:^{
        if (isLeft) {
            tbRect.origin.x = -tbRect.size.width;
        }
        else {
            tbRect.origin.x = tbRect.size.width;
        }
        tbView.frame = tbRect;
    } completion:^(BOOL finished) {
        tbView.hidden = YES;
        tbRect.origin.x = 0;
        tbView.frame = tbRect;
        if (isLeft) {
            [self btnAction:[self.view viewWithTag:(currentPage+1+100)]];
        }
        else {
            [self btnAction:[self.view viewWithTag:(currentPage-1+100)]];
        }
    }];
    
    return;
    [UIView animateWithDuration:.15 animations:^{
        if (isLeft) {
            tbRect.origin.x = -tbRect.size.width;
        }
        else {
            tbRect.origin.x = tbRect.size.width;
        }
        tbView.frame = tbRect;
    } completion:^(BOOL finished) {
        tbView.hidden = YES;
        [UIView animateWithDuration:0 animations:^{
            if (isLeft) {
                tbRect.origin.x = tbRect.size.width;
            }
            else {
                tbRect.origin.x = -tbRect.size.width;
            }
            tbView.frame = tbRect;
        } completion:^(BOOL finished) {
            tbView.hidden = NO;
            [UIView animateWithDuration:.5 animations:^{
                tbRect.origin.x = 0;
                tbView.frame = tbRect;
            }];
        }];
    }];
}

#pragma mark - button action
- (IBAction)btnAction:(UIButton*)sender {
    UIButton *btn = (UIButton*)[topView viewWithTag:(sender.tag-100)];
    if (btn.tag == currentPage) {
        return;
    }
    
    btn.selected = YES;
    currentPage = btn.tag;
    //清除已选的条件
    filterDictionary = nil;
    //选项，页码计数器归零
    listPage = 1;
    if (dataSource) {
        [dataSource removeAllObjects];
    }
    [scView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    for (int i = 100; i <= 103; i++) {
        if (i == btn.tag) {
            continue;
        }
        UIButton *btnTmp = (UIButton*)[self.view viewWithTag:i];
        btnTmp.selected = NO;
    }
    
    [self getDataFromServerWithParams:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
    static NSString *CellIdentifier = @"CallListCell";//cell重用标识
    CallListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];//设置这个cell的重用标识
    
    //若cell为nil，重新alloc一个cell
    if(!cell){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CallListCell" owner:self options:nil] objectAtIndex:0];
    }
     */
    
    CallListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CallListCellIdentifier"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"CallListCell" owner:self options:nil];
        cell = (CallListCell*)[array objectAtIndex:0];
       [cell setCellViewFrame];
    }
    
    CellDataInfo *currentCellDataInfo = [dataSource objectAtIndex:indexPath.row];
    cell.tag = indexPath.row;
    cell.cellType = currentPage - 100;
    [cell setCellDataInfo:currentCellDataInfo];
//    cell.delegate = self;
    cell.nvController = self.navigationController;
    cell.indexPath = indexPath;
    cell.delegate = self;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CellDataInfo *currentCellDataInfo = [dataSource objectAtIndex:indexPath.row];
    if (currentCellDataInfo.expanded) {//放大状态
        if (currentPage == 101) {
            return 180.f ;
        }else if (currentPage == 101) {
            return 180.f - 120.0f;
        }
        else if (currentPage == 102) {
            return 180.f-120.f ;
        }else if (currentPage == 103) {
            return 180.f ;
        }
        return 180.0;
    }
    else {//缩小状态
        return 60.f;
    }
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row >= dataSource.count) {
//        return;
//    }
//    
//    bool expanded = NO;
//    //同一时间，只能选中打开一个cell
//    for (int i = 0; i < [dataSource count]; i++) {
//        CellDataInfo *currentCellDataInfo = [dataSource objectAtIndex:i];
//        NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
//        CallListCell *currentCell = (CallListCell*)[tbView cellForRowAtIndexPath:currentIndexPath];
//        if (i == indexPath.row) {
//            currentCellDataInfo.expanded = !currentCellDataInfo.expanded;
//            expanded = currentCellDataInfo.expanded;
//            if (currentCellDataInfo.expanded) {
//                lastSelectIndexPath = indexPath;
//                [self removeSwipeGuestureForView:scView];
//                [self removeSwipeGuestureForView:tbView];
//            }
//            else {
//                lastSelectIndexPath = nil;
//                [self addSwipeGuestureToView:scView];
//                [self addSwipeGuestureToView:tbView];
//            }
//        }
//        else {
//            currentCellDataInfo.expanded = NO;
//        }
//        [currentCell setButtonSelected:currentCellDataInfo.expanded];
//    }
//    
//    float cHeight = 60.0f;
//    if (expanded) {//放大状态
//        [tbView beginUpdates];
//        [tbView endUpdates];
//        
//        CGRect tbRect = tbView.frame;
//        tbRect.size.height = [self calculateContentHeight];
//        tbView.frame = tbRect;
//        
//        scView.contentSize = CGSizeMake(scView.frame.size.width, tbRect.size.height + 20);
//        if (currentPage == 101) {
//            cHeight = 300.f - 110.0f;
//        }
//        else if (currentPage == 102) {
//            cHeight = 300.f - 40.0f;
//        }
//        else {
//            cHeight = 300.f;
//        }
//        [scView scrollRectToVisible:CGRectMake(0, indexPath.row * 60.0, 320, cHeight) animated:YES];
//    }
//    else {
//        [UIView animateWithDuration:0.5 animations:^{
//            [tbView beginUpdates];
//            [tbView endUpdates];
//            
//        } completion:^(BOOL finished) {
//            [UIView animateWithDuration:0.5 animations:^{
//                CGRect tbRect = tbView.frame;
//                tbRect.size.height = [self calculateContentHeight];
//                tbView.frame = tbRect;
//                scView.contentSize = CGSizeMake(scView.frame.size.width, tbRect.size.height + 20);
//            }];
//        }];
//    }
//    
//}

#pragma mark - CallListFilterViewControllerDelegate
- (void)filterComplete:(NSDictionary*)dict {
    filterDictionary = dict;
    listPage = 1;
    if (dataSource) {
        [dataSource removeAllObjects];
    }
    [self getDataFromServerWithParams:filterDictionary];
}






#pragma mark - 打电话
-(void)callPhone:(NSIndexPath*)_indexPath object:(CellDataInfo*)cInfo{
    ///已接来电、语音信箱
    if (currentPage == 100 || currentPage == 103) {
        if ([cInfo.cellDataInfo objectForKey:@"titleName"] && [[cInfo.cellDataInfo objectForKey:@"titleName"] isKindOfClass:[NSString class]]) {
            NSLog(@"phone:%@",[cInfo.cellDataInfo safeObjectForKey:@"customerPhone"]);
            NSString *phone = [cInfo.cellDataInfo safeObjectForKey:@"customerPhone"];
            if (phone && ![phone isEqualToString:@""]) {
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
                    [self callByPhoneNum:phone];
                    
                }else
                {
                    [CommonFuntion showToast:@"当前设备不支持拨打电话" inView:self.view];
                    return;
                }
                
            }else
            {
                [CommonFuntion showToast:@"获取电话号码失败" inView:self.view];

                return;
            }
        }
    }
}

-(void)callByPhoneNum:(NSString *)phoneNum
{
    //---电话结束以后会返回
    UIWebView*callWebview =[[UIWebView alloc] init] ;
    
    NSMutableString *strNumber = [[NSMutableString alloc] init];
    [strNumber appendString:@"tel:"];
    [strNumber appendString:phoneNum];
    
    NSURL *telURL =[NSURL URLWithString:strNumber];
    [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
    //记得添加到view上
    [self.view addSubview:callWebview];
}

#pragma mark - 展开，关闭cell
- (void)expandButtonAction:(NSIndexPath*)_indexPath object:(CellDataInfo*)cInfo {
    if (_indexPath.row >= dataSource.count) {
        return;
    }
    
    ///已接来电、语音信箱
    if (currentPage == 100 || currentPage == 103) {
        bool expanded = NO;
        //同一时间，只能选中打开一个cell
        for (int i = 0; i < [dataSource count]; i++) {
            CellDataInfo *currentCellDataInfo = [dataSource objectAtIndex:i];
            NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            CallListCell *currentCell = (CallListCell*)[tbView cellForRowAtIndexPath:currentIndexPath];
            if (i == _indexPath.row) {
                currentCellDataInfo.expanded = !currentCellDataInfo.expanded;
                expanded = currentCellDataInfo.expanded;
                if (currentCellDataInfo.expanded) {
                    lastSelectIndexPath = _indexPath;
                    [self removeSwipeGuestureForView:scView];
                    [self removeSwipeGuestureForView:tbView];
                }
                else {
                    lastSelectIndexPath = nil;
                    [self addSwipeGuestureToView:scView];
                    [self addSwipeGuestureToView:tbView];
                }
            }
            else {
                currentCellDataInfo.expanded = NO;
            }
            [currentCell setButtonSelected:currentCellDataInfo.expanded];
        }
        
        float cHeight = 60.0f;
        if (expanded) {//放大状态
            [tbView beginUpdates];
            [tbView endUpdates];
            
            CGRect tbRect = tbView.frame;
            tbRect.size.height = [self calculateContentHeight];
            tbView.frame = tbRect;
            
            
            scView.contentSize = CGSizeMake(scView.frame.size.width, tbRect.size.height + 20+vScrolH);
            if (currentPage == 101) {
                cHeight = 300.f - 110.0f;
            }
            else if (currentPage == 103) {
                cHeight = 300.f - 40.0f;
            }
            else if (currentPage == 100) {
                cHeight = 300.f;
            }else if (currentPage == 102) {
                cHeight = 300.f - 110.0f;
            }
            [scView scrollRectToVisible:CGRectMake(0, _indexPath.row * 60.0, DEVICE_BOUNDS_WIDTH, cHeight) animated:YES];
        }
        else {
            [UIView animateWithDuration:0.5 animations:^{
                [tbView beginUpdates];
                [tbView endUpdates];
                
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.5 animations:^{
                    CGRect tbRect = tbView.frame;
                    tbRect.size.height = [self calculateContentHeight];
                    tbView.frame = tbRect;
                    
                    scView.contentSize = CGSizeMake(scView.frame.size.width, tbRect.size.height + 20+vScrolH);
                }];
            }];
        }
    }else{
        NSLog(@"外呼----:%ti",_indexPath.row);
//        CALLED
        CellDataInfo *currentCellDataInfo = [dataSource objectAtIndex:_indexPath.row];
        NSLog(@"cellDataInfo:%@",currentCellDataInfo.cellDataInfo);
        NSString *phoneNum = [currentCellDataInfo.cellDataInfo safeObjectForKey:@"customerPhone"];
        NSLog(@"phoneNum:%@",phoneNum);
        
        
        
        if (![phoneNum isEqualToString:@""]) {
            UIAlertView *alertCall = [[UIAlertView alloc] initWithTitle:@"是否外呼?" message:phoneNum delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
            alertCall.tag = _indexPath.row;
            [alertCall show];
        }
        
    }
}

#pragma mark - 外呼
-(void)callOut:(NSString *)phoneNum{

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    [params setValue:phoneNum forKey:@"destPhoneNo"];
    NSLog(@"params:%@",params);
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_OUT_CALL_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"外呼jsonResponse:%@",jsonResponse);
        if (jsonResponse && [jsonResponse objectForKey:@"status"]) {
            if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
                [CommonFuntion showToast:@"呼叫成功" inView:self.view];
            }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
                __weak typeof(self) weak_self = self;
                CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
                comRequest.RequestAgainBlock = ^(){
                    [weak_self callOut:phoneNum];
                };
                [comRequest loginInBackgroundLLC];
            }
            else {
                NSString *desc = @"";
                if ([jsonResponse objectForKey:@"desc"]) {
                    desc = [jsonResponse safeObjectForKey:@"desc"];
                }
                NSLog(@"desc:%@",desc);
                if ([desc isEqualToString:@""]) {
                    desc = @"呼叫失败";
                }
                [CommonFuntion showToast:desc inView:self.view];
            }
        }else{
            [CommonFuntion showToast:@"呼叫失败" inView:self.view];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
    
}


#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //外呼
    if (buttonIndex == 1) {
        
        CellDataInfo *currentCellDataInfo = [dataSource objectAtIndex:alertView.tag];
        NSLog(@"cellDataInfo:%@",currentCellDataInfo.cellDataInfo);
        NSString *phoneNum = [currentCellDataInfo.cellDataInfo safeObjectForKey:@"customerPhone"];
        NSLog(@"phoneNum:%@",phoneNum);
        [self callOut:phoneNum];
    }
    
    
}




#pragma mark - 上拉下拉刷新相关事件
//集成刷新控件
- (void)setupRefresh
{
    NSString *dateKey = @"calllist";
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [scView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:dateKey];
    //上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [scView addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 自动刷新(一进入程序就下拉刷新)
    //    [self.tableviewCampaign headerBeginRefreshing];
}


// 结束加载
-(void)reloadRefeshView{
    // 刷新列表
    [tbView reloadData];
    [scView footerEndRefreshing];
    [scView headerEndRefreshing];
}

// 下拉
- (void)headerRereshing
{
    NSLog(@"headerRereshing--下拉-->");
    
    if ([scView isFooterRefreshing]) {
        [scView headerEndRefreshing];
        return;
    }
    
    listPage = 1;
    if (dataSource) {
        [dataSource removeAllObjects];
    }
    [scView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self getDataFromServerWithParams:filterDictionary];
}

// 上拉
- (void)footerRereshing
{
    NSLog(@"footerRereshing--上拉-->");
    
    if ([scView isHeaderRefreshing]) {
        [scView footerEndRefreshing];
        return;
    }
    
    if (lastSelectIndexPath) {
        [self expandButtonAction:lastSelectIndexPath object:nil];
    }
    
    [self getDataFromServerWithParams:filterDictionary];
}



//- (void)playStatus:(NSDictionary*)statusInfo sender:(CallListCell*)sender {
//    
//    if (sender.tag >= dataSource.count) {
//        return;
//    }
//    CellDataInfo *cInfo = [dataSource objectAtIndex:sender.tag];
//    
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:cInfo.cellDataInfo];
//    if (statusInfo) {
//        [dict setObject:statusInfo forKey:@"PlayInfo"];
//    }
//    else {
//        if ([dict objectForKey:@"PlayInfo"]) {
//            [dict removeObjectForKey:@"PlayInfo"];
//            return;
//        }
//    }
//    if (dict) {
//        NSDictionary *dt = [NSDictionary dictionaryWithDictionary:dict];
//        cInfo.cellDataInfo = dt;
//        [dataSource replaceObjectAtIndex:sender.tag withObject:cInfo];
//    }
//    
//}




#pragma mark - UI适配
-(void)setCurViewFrame
{
    if (DEVICE_IS_IPHONE6) {
        vScrolH = 10;
        [self setFrameByIphone6];
        NSInteger vX = DEVICE_BOUNDS_WIDTH - 320;
        tbView.frame = [CommonFunc setViewFrameOffset:tbView.frame byX:0 byY:0 ByWidth:vX byHeight:0];
        scView.frame = [CommonFunc setViewFrameOffset:scView.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    }else if(DEVICE_IS_IPHONE6_PLUS)
    {
        vScrolH = 10;
        [self setFrameByIphone6];
        NSInteger vX = DEVICE_BOUNDS_WIDTH - 320;
        tbView.frame = [CommonFunc setViewFrameOffset:tbView.frame byX:0 byY:0 ByWidth:vX byHeight:70];
        scView.frame = [CommonFunc setViewFrameOffset:scView.frame byX:0 byY:0 ByWidth:vX byHeight:70];
    }else if(!DEVICE_IS_IPHONE5)
    {
        vScrolH = 200;
    }else
    {
        vScrolH = 100;
    }
    
    
}

-(void)setFrameByIphone6
{
    NSInteger vX = DEVICE_BOUNDS_WIDTH - 320;
    
    topView.frame = [CommonFunc setViewFrameOffset:topView.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    view_top_line.frame = [CommonFunc setViewFrameOffset:view_top_line.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
    
    btnSeg10.frame = [CommonFunc setViewFrameOffset:btnSeg10.frame byX:0 byY:0 ByWidth:vX/4 byHeight:0];
    btnSeg11.frame = [CommonFunc setViewFrameOffset:btnSeg11.frame byX:vX/4 byY:0 ByWidth:vX/4 byHeight:0];
    btnSeg13.frame = [CommonFunc setViewFrameOffset:btnSeg13.frame byX:(vX/4)*2 byY:0 ByWidth:vX/4 byHeight:0];
    btnSeg12.frame = [CommonFunc setViewFrameOffset:btnSeg12.frame byX:(vX/4)*3 byY:0 ByWidth:vX/4 byHeight:0];
    
    
    btnSeg20.frame = [CommonFunc setViewFrameOffset:btnSeg20.frame byX:0 byY:0 ByWidth:vX/4 byHeight:0];
    btnSeg21.frame = [CommonFunc setViewFrameOffset:btnSeg21.frame byX:vX/4 byY:0 ByWidth:vX/4 byHeight:0];
    btnSeg23.frame = [CommonFunc setViewFrameOffset:btnSeg23.frame byX:(vX/4)*2 byY:0 ByWidth:vX/4 byHeight:0];
    btnSeg22.frame = [CommonFunc setViewFrameOffset:btnSeg22.frame byX:(vX/4)*3 byY:0 ByWidth:vX/4 byHeight:0];
    
    
    
    labelNoContent.frame = [CommonFunc setViewFrameOffset:labelNoContent.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
}

@end
