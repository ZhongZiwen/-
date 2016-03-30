//
//  ReportViewController.m
//  lianluozhongxin
//
//  Created by Vescky on 14-6-16.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "ReportViewController.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"
#import "ReportViewCell.h"

@interface ReportViewController ()<UITableViewDataSource,UITableViewDelegate> {
    float lastScrollOffSet;
    int lastClickedButtonFactor;
    int currentPage;
}
@end

@implementation ReportViewController

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
    // Do any additional setup after loading the view from its nib.
//    self.navigationController.navigationBar.hidden = YES;
    self.title = @"统计报表";
    [super customBackButton];
    [self setCurViewFrame];
//    return;
    lastScrollOffSet = 0;
    dataSource = [[NSMutableArray alloc] init];
    
    [self addSwipeGuestureToView:self.view mode:1];
    [self addSwipeGuestureToView:tbView mode:0];
    
    UIButton *btn1 = (UIButton*)[self.view viewWithTag:100];
    UIButton *btn2 = (UIButton*)[self.view viewWithTag:104];
//    UIButton *btn3 = (UIButton*)[self.view viewWithTag:201];
    UIButton *btn4 = (UIButton*)[self.view viewWithTag:303];
    btn1.selected = YES;
    btn2.selected = YES;
//    btn3.selected = YES;
    btn4.selected = YES;
    lastClickedButtonFactor = [self getSelectedButtonsFactor];
    
    currentPage = 100;
    
    CGRect tbRect = tbView.frame;
    tbRect.size.height = tbRect.size.height - 49.0f;//tabbar height
    
    if (DEVICE_IS_IPHONE6) {
        
    }else if(DEVICE_IS_IPHONE6_PLUS)
    {
       
    }else if(!DEVICE_IS_IPHONE5)
    {
        tbRect.size.height = tbRect.size.height - 88.0f;
        
    }else
    {
        
    }
    
    /*
    if (!iPhone5()) {
        tbRect.size.height = tbRect.size.height - 88.0f;
    }
     */
    tbView.frame = tbRect;
    
    [self getDataFromServer];
}

-(void)viewDidAppear:(BOOL)animated
{
    //
    NSLog(@"viewForNavigation.frame x:%f  y:%f",viewForNavigation.frame.origin.x,viewForNavigation.frame.origin.y);
    NSLog(@"bottomview.frame x:%f  y:%f",bottomView.frame.origin.x,bottomView.frame.origin.y);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//获取数据
- (void)getDataFromServer {
    
    NSDictionary *filterDict = [[NSDictionary alloc] initWithObjectsAndKeys:LLC_GET_REPORT_TIME_ACTION,@"100",
                                LLC_GET_REPORT_SIT_ACTION,@"101",
                                LLC_GET_REPORT_TIMEINTERVAL_ACTION,@"102",
                                LLC_GET_REPORT_AREA_ACTION,@"103",nil];
    
    NSDictionary *timeDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"today",@"200",
                              @"month",@"201",
                              @"quarter",@"202",
                              @"year",@"203",nil];
    
    NSString *requestAction = @"";
    NSMutableDictionary *params;
    for (int i = 100; i <= 103; i++) {
        UIButton *btnTmp = (UIButton*)[self.view viewWithTag:i];
        if (btnTmp.selected) {
            requestAction = [filterDict objectForKey:[NSString stringWithFormat:@"%d",i]];
        }
    }
    for (int i = 200; i <= 203; i++) {
        UIButton *btnTmp = (UIButton*)[self.view viewWithTag:i];
        UIButton *btnTmp100 = (UIButton*)[self.view viewWithTag:(i+100)];
        if (btnTmp.selected) {
            params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[timeDict objectForKey:[NSString stringWithFormat:@"%d",i]],@"timeType", nil];
            break;
        }
        if (btnTmp100 && btnTmp100.selected) {
            params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[timeDict objectForKey:[NSString stringWithFormat:@"%d",i]],@"timeType", nil];
            break;
        }
    }
    NSLog(@"requestAction:%@",requestAction);
    NSLog(@"params:%@",[params safeObjectForKey:@"timeType"]);
    
    if (!requestAction || !params) {
        NSLog(@"nil args");
        return;
    }
    //发送获取数据的请求
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,requestAction] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"%@",NSStringFromCGRect(viewForNavigation.frame));
        NSLog(@"%@",NSStringFromCGRect(self.view.frame));
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            //获取数据成功
            NSLog(@"统计报表:%@",[jsonResponse objectForKey:@"resultMap"]);
            NSArray *data = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"];
            if (data && [data respondsToSelector:@selector(count)] && [data count]) {
                //有数据
                labelNoContent.hidden = YES;
                if (currentPage == 100) {
                    labelTotalDuration.text = [[jsonResponse objectForKey:@"resultMap"] safeObjectForKey:@"totalCallTime"];
                    labelTotalTimes.text = [[jsonResponse objectForKey:@"resultMap"] safeObjectForKey:@"totalCallCount"];
                }
                
                dataSource = [[NSMutableArray alloc] init];
                for (int i = 0; i < [data count]; i++) {
                    CellDataInfo *cellDataInfo = [[CellDataInfo alloc] initWithCellDataInfo:[data objectAtIndex:i]];
                    if (cellDataInfo) {
                        [dataSource addObject:cellDataInfo];
                    }
                }
                [tbView reloadData];
                
                tbView.hidden = NO;
                tbView.alpha = 0.0;
                [UIView animateWithDuration:0.5 animations:^{
                    tbView.alpha = 1.0;
                }];
            }
            else {
                //无数据
                NSLog(@"无数据");
                tbView.hidden = YES;
                labelNoContent.hidden = NO;
            }
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getDataFromServer];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            NSLog(@"获取数据失败");
            tbView.hidden = YES;
            labelNoContent.hidden = NO;
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        tbView.hidden = YES;
        labelNoContent.hidden = NO;
    }];
}

- (int)getSelectedButtonsFactor {
    int factor = 0;
    for (int i = 100; i <= 106; i++) {
        UIButton *btnTmp = (UIButton*)[self.view viewWithTag:i];
        if (btnTmp.selected) {
            factor = factor + i;
        }
    }
    for (int i = 200; i <= 203; i++) {
        UIButton *btnTmp = (UIButton*)[self.view viewWithTag:i];
        if (btnTmp.selected) {
            factor = factor + i;
        }
    }
    for (int i = 301; i <= 303; i++) {
        UIButton *btnTmp = (UIButton*)[self.view viewWithTag:i];
        if (btnTmp.selected) {
            factor = factor + i - 100;
        }
    }
    
    return factor;
}

#pragma mark - 处理手势检测
- (void)addSwipeGuestureToView:(UIView*)v mode:(int)_mode {
    UISwipeGestureRecognizer *recognizer1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGuesture:)];
    recognizer1.direction = UISwipeGestureRecognizerDirectionRight;
    [v addGestureRecognizer:recognizer1];
    
    UISwipeGestureRecognizer *recognizer2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGuesture:)];
    recognizer2.direction = UISwipeGestureRecognizerDirectionLeft;
    [v addGestureRecognizer:recognizer2];
    
    if (_mode > 0) {
        UISwipeGestureRecognizer *recognizer3 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGuesture:)];
        recognizer3.direction = UISwipeGestureRecognizerDirectionUp;
        [v addGestureRecognizer:recognizer3];
        
        UISwipeGestureRecognizer *recognizer4 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGuesture:)];
        recognizer4.direction = UISwipeGestureRecognizerDirectionDown;
        [v addGestureRecognizer:recognizer4];
    }
}

- (void)handleSwipeGuesture:(UISwipeGestureRecognizer *)recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"left direction,界面右移");
        if (currentPage >= 103) {
            return;
        }
//        [self btnAction:[self.view viewWithTag:(currentPage+1)]];
        [self swipeTableViewAnimation:YES];
        
    }
    else if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"right direction,界面左移");
        if (currentPage <= 100) {
            return;
        }
//        [self btnAction:[self.view viewWithTag:(currentPage-1)]];
        [self swipeTableViewAnimation:NO];
    }
    else if (recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
//        [self hideTabBar:NO];
    }
    else if (recognizer.direction == UISwipeGestureRecognizerDirectionDown) {
//        [self hideTabBar:YES];
    }
}

#pragma mark - 自定义过渡的动画效果
- (void)swipeTableViewAnimation:(bool)direction {
    __block CGRect tbRect = tbView.frame;
    __block int isLeft = direction;
    labelNoContent.hidden = YES;
   
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
            [self btnAction:[self.view viewWithTag:(currentPage+1)]];
        }
        else {
            [self btnAction:[self.view viewWithTag:(currentPage-1)]];
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
- (IBAction)btnAction:(id)sender {
    UIButton *btn = (UIButton*)sender;
    int btnTag = btn.tag;
    
    //将按钮设置为选中状态，实现变色、变图
    btn.selected = YES;
    NSLog(@"btnTag:%i",btnTag);
    
    //忽略重复按的
    if ([self getSelectedButtonsFactor] == lastClickedButtonFactor) {
        NSLog(@"Old Old Old Old button!");
        return;
    }
    
    NSLog(@"New New New New button!");
    
    /*
    //换buttomview
    if (btnTag < 200) {
        if (btnTag == 100 || btnTag == 104) {
            bottomViewSecond.hidden = NO;
        }
        else {
            bottomViewSecond.hidden = YES;
        }
    }
    */
    bottomViewSecond.hidden = NO;
    
    if (btnTag > 300) {
        btnTag = btnTag - 100;
    }
    
    //反选其他按钮
    if (btnTag / 100 == 1) {
        
        NSLog(@"上部分菜单");
        
        currentPage = btnTag;
        
        //上部菜单
        for (int i = 100; i <= 107; i++) {
            if (btnTag == i) {
                continue;
            }
            if (btnTag + 4 == i) {
                //点击了图标，文字也需要设置为选中状态
                UIButton *btnTmp = (UIButton*)[self.view viewWithTag:i];
                btnTmp.selected = YES;
                continue;
            }
            if (btnTag - 4 == i) {
                //点击了文字，图标也需要设置为选中状态
                UIButton *btnTmp = (UIButton*)[self.view viewWithTag:i];
                btnTmp.selected = YES;
                continue;
            }
            UIButton *btnTmp = (UIButton*)[self.view viewWithTag:i];
            btnTmp.selected = NO;
        }
        
        //反选所有
        for (int i = 200; i <= 203; i++) {
            UIButton *btnTmp = (UIButton*)[self.view viewWithTag:i];
            UIButton *btnTmp2 = (UIButton*)[self.view viewWithTag:(i + 100)];
            btnTmp.selected = NO;
            if (btnTmp2) {
                btnTmp2.selected = NO;
            }
        }

        
        UIButton *btnTmp2 = (UIButton*)[self.view viewWithTag:303];
        btnTmp2.selected = YES;
        
        /*
        if (btnTag == 100 || btnTag == 104) {
            UIButton *btnTmp2 = (UIButton*)[self.view viewWithTag:301];
            btnTmp2.selected = YES;
        }
        else {
            UIButton *btnTmp = (UIButton*)[self.view viewWithTag:200];
            btnTmp.selected = YES;
        }
         */
        
//        //时段选项,不能选择今日
//        UIButton *btnToday= (UIButton*)[self.view viewWithTag:200];
//        if (btnTag == 102 || btnTag == 106) {
//            UIButton *btnWeek= (UIButton*)[self.view viewWithTag:201];
//            if (btnToday.selected) {
//                btnToday.selected = NO;
//                btnWeek.selected = YES;
//                btnTmp.selected = NO;
//            }
//            btnToday.enabled = NO;
//        }
//        else {
//            btnToday.enabled = YES;
//        }
        
    }
    else if (btnTag / 100 == 2) {
        NSLog(@"下部分菜单");
        //下部菜单
        for (int i = 201; i <= 203; i++) {
            
            if (btnTag == i) {
                if (btnTag == 201) {
                    UIButton *btn3 = (UIButton*)[self.view viewWithTag:301];
                    btn3.selected = YES;
                }
                else {
                    UIButton *btn3 = (UIButton*)[self.view viewWithTag:i+100];
                    btn3.selected = YES;
                }
                continue;
            }
            UIButton *btnTmp = (UIButton*)[self.view viewWithTag:i];
            UIButton *btnTmp2 = (UIButton*)[self.view viewWithTag:(i + 100)];
            btnTmp.selected = NO;
            btnTmp2.selected = NO;
        }
    }
    
    lastClickedButtonFactor = [self getSelectedButtonsFactor];
    [self getDataFromServer];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //时间行,加个总数,行数+1
    if (currentPage == 100 && [dataSource count] > 0) {
        return [dataSource count] + 1;
    }
    else {
        return [dataSource count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (currentPage == 100 && indexPath.row == [dataSource count]) {
        //统计行
        return cellTotalCount;
    }
    
    /*
    ReportViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReportViewCell"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ReportViewCell" owner:self options:nil];
        cell = (ReportViewCell*)[array objectAtIndex:0];
    }
    [cell setCellViewFrame];
    */
    
    static NSString *CellIdentifier = @"ReportViewCell";//cell重用标识
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];//设置这个cell的重用标识
    
    CellDataInfo *currentCellDataInfo = [dataSource objectAtIndex:indexPath.row];
    
    
    //若cell为nil，重新alloc一个cell
    if(!cell){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ReportViewCell" owner:self options:nil] objectAtIndex:0];
    }
    
    if([cell respondsToSelector:@selector(setCellViewFrame)]){
        [cell performSelector:@selector(setCellViewFrame) withObject:nil];
    }
    
    cell.tag = indexPath.row;
    
    
    
    if([cell respondsToSelector:@selector(setCellDataInfo:)]){
        [cell performSelector:@selector(setCellDataInfo:) withObject:currentCellDataInfo];
    }
    
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.f;
}

#pragma mark - hide/show tabbar
#define Scroll_Senser 0.0f
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    lastScrollOffSet = scrollView.contentOffset.y;
    NSLog(@"lastscrollview position:%f",lastScrollOffSet);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    /*
    BOOL isTabBarHidden = isCustomTabBarHidden();
    
    if ( scrollView.contentOffset.y < lastScrollOffSet - Scroll_Senser && isTabBarHidden) {//
        lastScrollOffSet = scrollView.contentOffset.y;
        //        setCustomTabBarHidden(NO, YES);
        [self hideTabBar:NO];
        return;
        //向上,底部栏和四键导航栏出现
        [UIView animateWithDuration:0 animations:^{
            [viewForNavigation setHidden:NO];
//            setCustomTabBarHidden(NO, YES);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0 animations:^{
                //重设此tabbar view的大小
                CGRect tRect = self.tabBarController.view.frame;
                tRect.size.height = tRect.size.height - 49.0f;
                self.tabBarController.view.frame = tRect;
                
                //重设此view的大小
                CGRect viewRect = self.view.frame;
                viewRect.size.height = viewRect.size.height - 44.0f;
                self.view.frame = viewRect;
                
                //重设tableview的大小
                CGRect tbRect = tbView.frame;
                tbRect.origin.y =  viewForNavigation.frame.origin.y + viewForNavigation.frame.size.height;
                tbRect.size.height = tbRect.size.height - viewForNavigation.frame.size.height - 49.0f;
                tbView.frame = tbRect;
            } completion:^(BOOL finished) {
                
            }];
        }];
        
    }
    else if (scrollView.contentOffset.y > lastScrollOffSet + Scroll_Senser && !isTabBarHidden){//
        lastScrollOffSet = scrollView.contentOffset.y;
        //        setCustomTabBarHidden(YES, YES);
        [self hideTabBar:YES];
        return;
        //向下,底部栏和四键导航栏消失
        [UIView animateWithDuration:0.5 animations:^{
            //上移头部
            CGRect nRect = viewForNavigation.frame;
            nRect.origin.y = [[UIScreen mainScreen] bounds].origin.y - nRect.size.height;
            viewForNavigation.frame = nRect;
            
            //            //重设此tabbar view的大小
            CGRect tRect = self.tabBarController.view.frame;
            tRect.size.height = tRect.size.height + 49.0f;
            self.tabBarController.view.frame = tRect;
            
            //重设此view的大小
            CGRect viewRect = self.view.frame;
            viewRect.size.height = viewRect.size.height + 44.0f;
            self.view.frame = viewRect;
            
            //重设tableview的大小
            CGRect tbRect = tbView.frame;
            tbRect.origin.y = viewForNavigation.frame.origin.y;
            if (!ios7OrLater()) {
                tbRect.origin.y = tbRect.origin.y + 20;
            }
            tbRect.size.height = tbRect.size.height + viewForNavigation.frame.size.height + 49.0f;
            tbView.frame = tbRect;
        } completion:^(BOOL finished) {
            //            [viewForNavigation setHidden:YES];
        }];
        
    }

     */
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)hideTabBar:(bool)isHidden {
    return;
    
}


#pragma mark - UI适配
-(void)setCurViewFrame
{
    NSInteger vX = DEVICE_BOUNDS_WIDTH - 320;
    NSInteger vHeight = 0;
    
    if (DEVICE_IS_IPHONE6) {
        vHeight = 90;
        [self setFrameByIphone6];
    }else if(DEVICE_IS_IPHONE6_PLUS)
    {
        vHeight = 128;
       [self setFrameByIphone6];
        
    }else if(!DEVICE_IS_IPHONE5)
    {
        //
        
    }else
    {
        
    }
    
    viewForNavigation.frame = CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 70);
    bottomView.frame = CGRectMake(0, 70, DEVICE_BOUNDS_WIDTH, 50);
    tbView.frame = [CommonFunc setViewFrameOffset:tbView.frame byX:0 byY:0 ByWidth:vX byHeight:vHeight];
    
}

-(void)setFrameByIphone6
{
    NSInteger vX = DEVICE_BOUNDS_WIDTH - 320;
    
    labelNoContent.frame = [CommonFunc setViewFrameOffset:labelNoContent.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
    
    NSInteger vHeadX = vX/4;
    
    btnHead10.frame = [CommonFunc setViewFrameOffset:btnHead10.frame byX:0 byY:0 ByWidth:0 byHeight:0];
    btnHead11.frame = [CommonFunc setViewFrameOffset:btnHead11.frame byX:vHeadX*2 byY:0 ByWidth:0 byHeight:0];
    btnHead12.frame = [CommonFunc setViewFrameOffset:btnHead12.frame byX:vHeadX*3.5 byY:0 ByWidth:0 byHeight:0];
    btnHead13.frame = [CommonFunc setViewFrameOffset:btnHead13.frame byX:vHeadX*4.5 byY:0 ByWidth:0 byHeight:0];
    
    btnHead20.frame = [CommonFunc setViewFrameOffset:btnHead20.frame byX:0 byY:0 ByWidth:0 byHeight:0];
    btnHead21.frame = [CommonFunc setViewFrameOffset:btnHead21.frame byX:vHeadX*2 byY:0 ByWidth:0 byHeight:0];
    btnHead22.frame = [CommonFunc setViewFrameOffset:btnHead22.frame byX:vHeadX*3.5 byY:0 ByWidth:0 byHeight:0];
    btnHead23.frame = [CommonFunc setViewFrameOffset:btnHead23.frame byX:vHeadX*4.5 byY:0 ByWidth:0 byHeight:0];
    
    
    bottomViewSecond.frame = [CommonFunc setViewFrameOffset:bottomViewSecond.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    // 本周  本季 本月 vX/3 未用
    // 本年  本季 本月  vX/3 现在使用
    BtnTWeek.frame = [CommonFunc setViewFrameOffset:BtnTWeek.frame byX:0 byY:0 ByWidth:vX/3 byHeight:0];
    btnTMonth.frame = [CommonFunc setViewFrameOffset:btnTMonth.frame byX:vX/3 byY:0 ByWidth:vX/3 byHeight:0];
    btnTYear.frame = [CommonFunc setViewFrameOffset:btnTYear.frame byX:vX/3+vX/3 byY:0 ByWidth:vX/3 byHeight:0];
    
    viewT.frame = [CommonFunc setViewFrameOffset:viewT.frame byX:10 byY:0 ByWidth:vX byHeight:0];
    viewT.hidden = YES;
    
    
    
    // 本日 本周  本月 本年 vX/4
    // 本年  本月 本周  vX/3 现在使用
    btnOToday.frame = [CommonFunc setViewFrameOffset:btnOToday.frame byX:0 byY:0 ByWidth:vX/4 byHeight:0];
    BtnOWeek.frame = [CommonFunc setViewFrameOffset:BtnOWeek.frame byX:vX/4 byY:0 ByWidth:vX/4 byHeight:0];
    btnOMonth.frame = [CommonFunc setViewFrameOffset:btnOMonth.frame byX:vX/4+vX/4 byY:0 ByWidth:vX/4 byHeight:0];
    btnOYear.frame = [CommonFunc setViewFrameOffset:btnOYear.frame byX:vX/4+vX/4+vX/4 byY:0 ByWidth:vX/4 byHeight:0];
    viewO.frame = [CommonFunc setViewFrameOffset:viewO.frame byX:-vX/2 byY:0 ByWidth:0 byHeight:0];
    viewO.hidden = YES;
    
}

// 隐藏底部按钮 今天  本月 本周  本年
-(void)setBottomBtnHide:(BOOL)isHide
{
    btnOToday.hidden = isHide;
    btnOMonth.hidden = isHide;
    BtnOWeek.hidden = isHide;
    btnOYear.hidden = isHide;
}
@end
