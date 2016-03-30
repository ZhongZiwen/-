//
//  CallListFilterViewController.m
//  lianluozhongxin
//
//  Created by Vescky on 14-6-23.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "CallListFilterViewController.h"
#import "NSString+JsonHandler.h"
#import "CommonFunc.h"
#import "LLCenterUtility.h"
#import "CommonStaticVar.h"

#define PANNEL_HEIGHT_WITH_TABLE 295.0
#define PANNEL_HEIGHT_WITH_PICKER 195.0

@interface CallListFilterViewController () {
    int currentPicking;
    NSDictionary *selectedSit,*selectedLocation;
    
    ///选中的下标
    NSInteger selectedIndexSit;
    NSInteger selectedIndexLocation;
}
@end

@implementation CallListFilterViewController
@synthesize delegate,filtType,defaultCondition;


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
    self.title = @"清单筛选";
//    self.view.backgroundColor = kView_BG_Color;
    [self setCurViewFrame];
    datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh"];
    selectedIndexSit = 0;
    selectedIndexLocation = 0;
    
    dataSourceForLocation = [[NSMutableArray alloc] init];
    dataSourceForPeople = [[NSMutableArray alloc] init];
    viewMask.frame = self.view.frame;
    [super customBackButton];
    [self getFilterData];
    
    
    if (self.filtType == FiltingAnsweredCall) {
        labelSitsTitle.text = @"接听坐席";
    } else if (self.filtType == FiltingNoAnswerCall) {
        labelSitsTitle.text = @"未接坐席";
    }else if (self.filtType == FiltingOutCall){
        labelSitsTitle.text = @"外呼坐席";
    }else if(self.filtType == FiltingVoiceBox){
        ///隐藏座席选择项
//        [self hideSitView];
        labelSitsTitle.text = @"语音坐席";
    }
    
    if ([[CommonStaticVar getAccountType] isEqualToString:@"boss"]) {
        
    }else{
        ///普通用户
        ///隐藏座席选择项
        [self hideSitView];
    }
}

///隐藏座席选项
-(void)hideSitView{
    CGRect bRect = viewBottom.frame;
    bRect.origin.y = bRect.origin.y - 62.0f;
    viewBottom.frame = bRect;
    
    viewSiteSelection.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Action
- (IBAction)btnAction:(id)sender {
    UIButton *btn = (UIButton*)sender;
    
    if (btn.tag <= 103) {
        currentPicking = btn.tag;
    }
    
    if (btn.tag == 100) {
        //来电区域
        NSInteger vHeight = 0;
        if (DEVICE_IS_IPHONE6) {
            vHeight = 100;
        }else if(DEVICE_IS_IPHONE6_PLUS)
        {
            vHeight = 160;
        }
        
        [self setPannelHeight:PANNEL_HEIGHT_WITH_TABLE+vHeight];
        [datePicker removeFromSuperview];
        if (![tbView isDescendantOfView:viewForPannel]) {
            [viewForPannel addSubview:tbView];
        }
        
        [tbView reloadData];
        
//        [[UIApplication sharedApplication].keyWindow addSubview:viewMask];
        [self setMaskViewHidden:NO];
        btnDoneForViewMask.hidden = YES;
        labelMaskName.text = @"区域";
    }
    else if (btn.tag == 101) {
        //接听坐席
        NSInteger vHeight = 0;
        if (DEVICE_IS_IPHONE6) {
            vHeight = 100;
        }else if(DEVICE_IS_IPHONE6_PLUS)
        {
            vHeight = 160;
        }
        [self setPannelHeight:PANNEL_HEIGHT_WITH_TABLE+vHeight];
        [datePicker removeFromSuperview];
        if (![tbView isDescendantOfView:viewForPannel]) {
            [viewForPannel addSubview:tbView];
        }
        
        [tbView reloadData];
        
//        [[UIApplication sharedApplication].keyWindow addSubview:viewMask];
        [self setMaskViewHidden:NO];
        btnDoneForViewMask.hidden = YES;
        
        labelMaskName.text = @"坐席";
    }
    else if (btn.tag == 102) {
        //起始时间
        NSInteger vHeight = 0;
        if (DEVICE_IS_IPHONE6) {
            vHeight = 50;
        }else if(DEVICE_IS_IPHONE6_PLUS)
        {
            vHeight = 80;
        }
        [self setPannelHeight:PANNEL_HEIGHT_WITH_PICKER+vHeight];
        [tbView removeFromSuperview];
        if (![datePicker isDescendantOfView:viewForPannel]) {
            [viewForPannel addSubview:datePicker];
        }
        
//        [[UIApplication sharedApplication].keyWindow addSubview:viewMask];
        [self setMaskViewHidden:NO];
        btnDoneForViewMask.hidden = NO;
        labelMaskName.text = @"时间";
    }
    else if (btn.tag == 103) {
        //结束时间
        NSInteger vHeight = 0;
        if (DEVICE_IS_IPHONE6) {
            vHeight = 50;
        }else if(DEVICE_IS_IPHONE6_PLUS)
        {
            vHeight = 80;
        }
        [self setPannelHeight:PANNEL_HEIGHT_WITH_PICKER+vHeight];
        [tbView removeFromSuperview];
        if (![datePicker isDescendantOfView:viewForPannel]) {
            [viewForPannel addSubview:datePicker];
        }
        
//        [[UIApplication sharedApplication].keyWindow addSubview:viewMask];
        [self setMaskViewHidden:NO];
        btnDoneForViewMask.hidden = NO;
        labelMaskName.text = @"时间";
    }
    else if (btn.tag == 104) {
        //返回
        if ([delegate respondsToSelector:@selector(filterComplete:)]) {
            NSDictionary *params = [self getFilterCondition];
            [delegate filterComplete:params];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (btn.tag == 105) {
        
        //取消
//        [viewMask removeFromSuperview];
        [self setMaskViewHidden:YES];
    }
    else if (btn.tag == 106) {
        //pannel完成按钮
        [viewMask removeFromSuperview];
        if (currentPicking == FiltingStartTime) {
            NSString *startDateString = getStringFromDate(@"yyyy-MM-dd", datePicker.date);
            NSString *endDateString = labelEndTime.text;
            NSDate *startDate = getDateFromString(@"yyyy-MM-dd", startDateString);
            NSDate *endDate = getDateFromString(@"yyyy-MM-dd", endDateString);
            if ([startDate isEqualToDate:[startDate laterDate:endDate]] && ![startDate isEqualToDate:endDate]) {
                //起始时间 > 结束时间
                [CommonFuntion showToast:@"起始时间不能大于结束时间!" inView:self.view];
                return;
            }
            labelStartTime.text = startDateString;
        }
        else if (currentPicking == FiltingEndTime) {
            NSString *startDateString = labelStartTime.text;
            NSString *endDateString = getStringFromDate(@"yyyy-MM-dd", datePicker.date);
            NSDate *startDate = getDateFromString(@"yyyy-MM-dd", startDateString);
            NSDate *endDate = getDateFromString(@"yyyy-MM-dd", endDateString);
            if ([startDate isEqualToDate:[startDate laterDate:endDate]] && ![startDate isEqualToDate:endDate]) {
                //起始时间 > 结束时间
                [CommonFuntion showToast:@"结束时间不能小于起始时间!" inView:self.view];
                return;
            }
            labelEndTime.text = endDateString;
        }
    }
    
}

- (void)setPannelHeight:(float)pHeight {
    CGRect pRect = viewForPannel.frame;
    pRect.origin.y = pRect.origin.y + pRect.size.height - pHeight;
    pRect.size.height = pHeight;
    viewForPannel.frame = pRect;
}

- (void)setMaskViewHidden:(bool)isHidden {
    if (isHidden) {
        __block CGRect pRect = viewForPannel.frame;
        pRect.origin.y = viewMask.frame.size.height;
        viewForPannel.frame = pRect;
        [UIView animateWithDuration:0.4 animations:^{
            pRect.origin.y = viewMask.frame.size.height;
            viewForPannel.frame = pRect;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                viewMask.alpha = 0.0;
            } completion:^(BOOL finished) {
                viewMask.hidden = YES;
                [viewMask removeFromSuperview];
            }];
        }];
    }
    else {
        [[UIApplication sharedApplication].keyWindow addSubview:viewMask];
        viewMask.hidden = NO;
        viewMask.alpha = 0.0;
        __block CGRect pRect = viewForPannel.frame;
        pRect.origin.y = viewMask.frame.size.height;
        viewForPannel.frame = pRect;
        [UIView animateWithDuration:0.1 animations:^{
            viewMask.alpha = 1.0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4 animations:^{
                pRect.origin.y = viewMask.frame.size.height - pRect.size.height;
                viewForPannel.frame = pRect;
            }];
        }];
    }
}

- (NSDictionary*)getFilterCondition {
    NSString *startTime = labelStartTime.text;
    NSString *endTime = labelEndTime.text;
    NSString *areaName = labelLocation.text;
    NSString *answeredUserCall,*username;
    NSString *areaId;
    
    id usernameId;
    
    if (selectedLocation) {
        areaId = [NSString stringWithFormat:@"%@",[selectedLocation safeObjectForKey:@"PROVINCE_ID"]];
    }
    else{
        areaId = @"0";
    }
    
    NSLog(@"selectedSit:%@",selectedSit);
    
    ///座席
    if (selectedSit) {
        ///未接座席
        if (filtType == FiltingNoAnswerCall) {
            if ([selectedSit objectForKey:@"ID"] && [[selectedSit objectForKey:@"ID"] isKindOfClass:NSClassFromString(@"NSString")]) {
                answeredUserCall = [NSString stringWithFormat:@"%@",[selectedSit safeObjectForKey:@"ID"]];
            }
            else {
                answeredUserCall = nil;
            }
        }
        else if (filtType == FiltingAnsweredCall) {
            answeredUserCall = nil;
            if ([selectedSit objectForKey:@"ID"]) {
                answeredUserCall = [NSString stringWithFormat:@"%@",[selectedSit safeObjectForKey:@"ID"]];
            }
        }else if (filtType == FiltingOutCall) {
            ///外呼座席
            answeredUserCall = nil;
            if ([selectedSit objectForKey:@"ID"]) {
                answeredUserCall = [NSString stringWithFormat:@"%@",[selectedSit safeObjectForKey:@"ID"]];
            }
        }
            
        username = [selectedSit safeObjectForKey:@"USERNAME"];
        usernameId = [selectedSit safeObjectForKey:@"USERNAME"];
    }
    else {
        answeredUserCall = nil;
        username = nil;
        usernameId = nil;
    }
    
//    NSLog(@"username1:%@",username);
    if (usernameId != [NSNull null]) {
//        NSLog(@"username11:%@",username);
        if (username != nil  && [username isEqualToString:@"<null>"]) {
//            NSLog(@"username111:%@",username);
            username = @"未知";
        }
    }else
    {
//        NSLog(@"username2:%@",username);
        username = @"未知";
    }
    
    
    
//    NSLog(@"username22:%@",username);
    
    NSLog(@"filtType:%i",filtType);
    NSLog(@"answeredUserCall:%@",answeredUserCall);
    
#warning 外呼座席
    //未接传 agentId  接听传 number
    NSString *keyAgentIdOrNum = @"";
    if (filtType == FiltingNoAnswerCall) {
        keyAgentIdOrNum = @"agentId";
    }else if (filtType == FiltingAnsweredCall) {
       keyAgentIdOrNum = @"agentId";
    }else if (filtType == FiltingOutCall) {
        keyAgentIdOrNum = @"agentId";
    }
    
    ///请求参数
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:startTime,@"beginTime",
                          endTime,@"endTime",
                          areaName,@"areaName",
                          areaId,@"areaId",
                          answeredUserCall,keyAgentIdOrNum,
                          username,@"username",nil];
    NSLog(@"dict--->:%@",dict);
    return dict;
}

- (void)getFilterData {
    
    NSString *action = LLC_GET_RECEIVED_CALL_FILTER_ACTION;
    if (filtType == FiltingAnsweredCall) {
        //已接来电
        action = LLC_GET_RECEIVED_CALL_FILTER_ACTION;
    }
    else if (filtType == FiltingNoAnswerCall) {
        //未接来电
        action = LLC_GET_NO_ANSWER_DETAIL_FILTER_ACTION;
    }
    else if (filtType == FiltingOutCall) {
        //外呼记录
        action = LLC_GET_VOIP_CALL_RECORD_FILTER_ACTION;
    }else if (filtType == FiltingVoiceBox) {
        //语音留言
        action = LLC_GET_VOICE_BOX_FILTER_ACTION;
    }
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,action] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [self parseForFilterData:[jsonResponse objectForKey:@"resultMap"]];
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getFilterData];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
}

- (void)parseForFilterData:(NSDictionary*)data {
    
//    NSLog(@"parseForFilterData:%@",data);
//    NSLog(@"defaultCondition:%@",defaultCondition);
    //解析去获取用户列表、区域列表、选择的时间范围
    NSString *startTimeString = [data safeObjectForKey:@"startTime"];
    NSString *endTimeString = [data safeObjectForKey:@"endTime"];
    dataSourceForLocation = [[NSMutableArray alloc] initWithArray:[data objectForKey:@"areaList"]];
    
    if ([data objectForKey:@"agentList"] && [[data objectForKey:@"agentList"] respondsToSelector:@selector(count)]) {
        dataSourceForPeople = [[NSMutableArray alloc] initWithArray:[data objectForKey:@"agentList"]];
    }
    //CALLEE_NO
    NSDictionary *allLocation = [[NSDictionary alloc] initWithObjectsAndKeys:@"全国",@"NAME",@"0",@"PROVINCE_ID", nil];
    NSDictionary *allSites = [[NSDictionary alloc] initWithObjectsAndKeys:@"全部",@"USERNAME",@"0",@"BIND_PHONENO",@"YES",@"all", nil];
    [dataSourceForLocation insertObject:allLocation atIndex:0];
    [dataSourceForPeople insertObject:allSites atIndex:0];
    
    NSDate *startTime = getDateFromString(@"yyyy-MM-dd", startTimeString);
    NSDate *endTime = getDateFromString(@"yyyy-MM-dd", endTimeString);
    
    datePicker.minimumDate = startTime;
    datePicker.maximumDate = endTime;
    labelStartTime.text = startTimeString;
    labelEndTime.text = endTimeString;
    
    if (defaultCondition) {

        labelStartTime.text = [defaultCondition safeObjectForKey:@"beginTime"];
        labelEndTime.text = [defaultCondition safeObjectForKey:@"endTime"];
        
        if ([defaultCondition objectForKey:@"username"]) {
            labelPeople.text = [defaultCondition safeObjectForKey:@"username"];
        }
        
        NSString *areaId = [defaultCondition safeObjectForKey:@"areaId"];
        for (int i = 0; i < [dataSourceForLocation count]; i++) {
            NSDictionary *dict = [dataSourceForLocation objectAtIndex:i];
            
            if ([[dict safeObjectForKey:@"PROVINCE_ID"] intValue] == [areaId intValue]) {
                labelLocation.text = [dict safeObjectForKey:@"NAME"];
                selectedLocation = dict;
                break;
            }
        }
        
        for (int i = 0; i < [dataSourceForPeople count]; i++) {
            NSDictionary *dict = [dataSourceForPeople objectAtIndex:i];
            
            
            if ([defaultCondition objectForKey:@"agentId"] && [dict objectForKey:@"ID"] && [[defaultCondition objectForKey:@"agentId"] isEqualToString:[dict objectForKey:@"ID"]]) {
                
//                labelPeople.text = [dict objectForKey:@"USERNAME"];
                selectedSit = dict;
                break;
            }
            else if ([defaultCondition objectForKey:@"number"]) {
                if ([dict objectForKey:@"BIND_PHONENO"] && [[defaultCondition objectForKey:@"number"] isEqualToString:[dict objectForKey:@"BIND_PHONENO"]]) {
                    NSLog(@"------2--->");
//                    labelPeople.text = [dict objectForKey:@"USERNAME"];
                    selectedSit = dict;
                    break;
                }
                else if ([dict objectForKey:@"BIND_PHONENO"] && [[defaultCondition objectForKey:@"number"] isEqualToString:[dict objectForKey:@"BIND_PHONENO"]]) {
                    NSLog(@"-----3--->");
//                    labelPeople.text = [dict objectForKey:@"USERNAME"];
                    selectedSit = dict;
                    break;
                }
            }
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //有个特殊行,行数+1
    if (currentPicking == FiltingLocation) {
       return [dataSourceForLocation count];
    }
    else {
       return [dataSourceForPeople count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CallListFilterPeopleCell";//cell重用标识
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];//设置这个cell的重用标识
    cell.tag = indexPath.row;
    
    
    if (currentPicking == FiltingPeople) {
        //若cell为nil，重新alloc一个cell
        if(!cell){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"CallListFilterPeopleCell" owner:self options:nil] objectAtIndex:0];
        }
        
        if([cell respondsToSelector:@selector(setCellDataInfo:)]){
            [cell performSelector:@selector(setCellDataInfo:) withObject:[dataSourceForPeople objectAtIndex:indexPath.row]];
            if (indexPath.row == selectedIndexSit) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }else{
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    else if (currentPicking == FiltingLocation) {
        if(!cell){
            cell = [[UITableViewCell alloc] init];
        }
        cell.textLabel.text = [[dataSourceForLocation objectAtIndex:indexPath.row] safeObjectForKey:@"NAME"];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        if (indexPath.row == selectedIndexLocation) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 51.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (currentPicking == FiltingLocation) {
        selectedIndexLocation = indexPath.row;
        selectedLocation = [dataSourceForLocation objectAtIndex:indexPath.row];
        NSString *lString = [NSString stringWithFormat:@"%@",[selectedLocation safeObjectForKey:@"NAME"]];
        labelLocation.text = lString;
    }
    else if (currentPicking == FiltingPeople) {
        selectedIndexSit = indexPath.row;
        selectedSit = [dataSourceForPeople objectAtIndex:indexPath.row];
        NSString *lString = [NSString stringWithFormat:@"%@",[selectedSit safeObjectForKey:@"USERNAME"]];
        if (lString == nil || [lString isEqualToString:@"<null>"]) {
            lString = @"未知";
        }
        labelPeople.text = lString;
    }
    [viewMask removeFromSuperview];
}



#pragma mark - UI适配
-(void)setCurViewFrame
{
    NSInteger vX = DEVICE_BOUNDS_WIDTH - 320;
    
    self.view.frame = CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT);
    
    NSInteger tbHeight = 0;

    if (DEVICE_IS_IPHONE6) {
        tbHeight = 100;
        [self setFrameByIphone6];
    }else if(DEVICE_IS_IPHONE6_PLUS)
    {
        tbHeight = 160;
        [self setFrameByIphone6];
    }else if(!DEVICE_IS_IPHONE5)
    {
        
        
    }else
    {
        
    }
    datePicker.frame = [CommonFunc setViewFrameOffset:datePicker.frame byX:0 byY:0 ByWidth:vX byHeight:tbHeight/2];
    
    tbView.frame = [CommonFunc setViewFrameOffset:tbView.frame byX:0 byY:0 ByWidth:vX byHeight:tbHeight];
}

-(void)setFrameByIphone6
{
    NSInteger vX = DEVICE_BOUNDS_WIDTH - 320;
    
    viewAreaBg.frame = [CommonFunc setViewFrameOffset:viewAreaBg.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    labelLocation.frame = [CommonFunc setViewFrameOffset:labelLocation.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    btnAreaClick.frame = [CommonFunc setViewFrameOffset:btnAreaClick.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    imgAreaArrow.frame = [CommonFunc setViewFrameOffset:imgAreaArrow.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    
    
    viewSiteSelection.frame = [CommonFunc setViewFrameOffset:viewSiteSelection.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    labelPeople.frame = [CommonFunc setViewFrameOffset:labelPeople.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    btnSiteClick.frame = [CommonFunc setViewFrameOffset:btnSiteClick.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    imgSiteArrow.frame = [CommonFunc setViewFrameOffset:imgSiteArrow.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    
    
    viewBottom.frame = [CommonFunc setViewFrameOffset:viewBottom.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    viewSDateBg.frame = [CommonFunc setViewFrameOffset:viewSDateBg.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    labelStartTime.frame = [CommonFunc setViewFrameOffset:labelStartTime.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    btnSDateClick.frame = [CommonFunc setViewFrameOffset:btnSDateClick.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    imgSDateArrow.frame = [CommonFunc setViewFrameOffset:imgSDateArrow.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    
    viewEDateBg.frame = [CommonFunc setViewFrameOffset:viewEDateBg.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    labelEndTime.frame = [CommonFunc setViewFrameOffset:labelEndTime.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    btnEDateClick.frame = [CommonFunc setViewFrameOffset:btnEDateClick.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    imgEDateArrow.frame = [CommonFunc setViewFrameOffset:imgEDateArrow.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    
    
    btnOk.frame = [CommonFunc setViewFrameOffset:btnOk.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
    
    viewForPannel.frame = [CommonFunc setViewFrameOffset:viewForPannel.frame byX:0 byY:0 ByWidth:vX byHeight:0];

    
}
@end
