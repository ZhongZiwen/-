//
//  NoAnswerViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-14.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "NoAnswerViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "NoAnSwerCell.h"
#import "NavDropView.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"
#import "LLcenterSheetMenuView.h"
#import "LLCenterSheetMenuModel.h"
#import "LLCenterPickerView.h"
#import "NSDate+Utils.h"
#import "CustomNarTitleView.h"
#import "CustomNarTitleModel.h"
#import "CommonNoDataView.h"

@interface NoAnswerViewController ()<UITableViewDataSource,UITableViewDelegate,LLCenterSheetMenuDelegate,UITextFieldDelegate>{
    
    LLCenterPickerView *sktPickView;
    UIDatePicker *datePickview;
    
    ///签名
    NSArray *arrayMsgSign;
    ///重复频率
    NSArray *arrayRepeat;
    ///开始时间 结束时间
    NSArray *arrayStartTime;
    NSMutableArray *arrayStopTime;
    
    ///所有短信
    NSArray *arrayAllMsg;
    ///换一批 每次换3条数据
    NSInteger indexOfMsg;
    ///当前选中的短信下标
    NSInteger selectMsgIndex;
    
    ///当前选择的发送时间
    NSString *startTime ;
    NSString *stopTime;
    ///结束时间的最小时间
    NSDate *minDate;
    
    ///签名、重复频率
    NSString *signSelected;
    NSString *repeatSelected;
    
    ///短信内容I的
    NSString *msgId;
    NSString *msgContent;
    
    Boolean isCheckWeekAll;
    Boolean isCheckWeek1;
    Boolean isCheckWeek2;
    Boolean isCheckWeek3;
    Boolean isCheckWeek4;
    Boolean isCheckWeek5;
    Boolean isCheckWeek6;
    Boolean isCheckWeek7;
    
    ///手机号码
    NSString *phoneNum;
    ///重复频率
    NSInteger notRepeatday;
    
    ///选择的短信
    NSDictionary *curDciMsg;
    NSDictionary *selectDicMsg;
    
    ///发送时间
    NSDictionary *useStrategy;
    
    ///是否处于编辑状态
    BOOL isEditing;
    
}

@property (nonatomic, assign) NSInteger curIndex;
@property(strong,nonatomic) UITableView *tableviewMsg;
@property(strong,nonatomic) NSMutableArray *arrayMsg;

@property (nonatomic, strong) CommonNoDataView *commonNoDataView;
@property (nonatomic, strong) CustomNarTitleView *customTitleView;
@end

@implementation NoAnswerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = COLOR_BG;
    [super customBackButton];
    [self addNarBar];
    [self addNarMenu];
    [self initViewFrame];
    [self initData];
    [self initTimeData];
    [self initRepeatData];
    [self initTableview];
    [self initTextFiledPhone];
    
    [self findSmsSet];
}


#pragma mark - Nar Bar
-(void)addNarBar{
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editBarButtonAction)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
}

-(void)editBarButtonAction{
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"编辑"]) {
        [self.navigationItem.rightBarButtonItem setTitle:@"保存"];
        isEditing = TRUE;
        [self setEditingStatus:isEditing];
        [self.tableviewMsg reloadData];
        
        [self.customTitleView setIndicatorViewHide:YES];
        self.navigationItem.titleView.userInteractionEnabled = NO;
        if (_curIndex == 1) {
            self.imgRepeatArrow.hidden = YES;
        }
    }else{
        
        NSLog(@"startTime:%@",startTime);
        NSLog(@"stopTime:%@",stopTime);
        NSLog(@"signSelected:%@",signSelected);
        NSLog(@"repeatSelected:%@",repeatSelected);
        NSLog(@"msgId:%@",msgId);
        
        NSLog(@"isCheckWeek1:%i",isCheckWeek1);
        NSLog(@"isCheckWeek2:%i",isCheckWeek2);
        NSLog(@"isCheckWeek3:%i",isCheckWeek3);
        NSLog(@"isCheckWeek4:%i",isCheckWeek4);
        NSLog(@"isCheckWeek5:%i",isCheckWeek5);
        NSLog(@"isCheckWeek6:%i",isCheckWeek6);
        NSLog(@"isCheckWeek7:%i",isCheckWeek7);
        NSLog(@"isCheckWeekAll:%i",isCheckWeekAll);
        
        phoneNum = self.textfieldPhone.text;
        NSLog(@"phoneNum:%@",phoneNum);
        
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        
        if (![CommonFunc checkNetworkState]) {
            [CommonFuntion showToast:@"无网络可用,加载失败" inView:self.view];
            return;
        }
        
        
        if (_curIndex == 1) {
            if (phoneNum.length == 0) {
                [CommonFuntion showToast:@"手机号码不能为空" inView:self.view];
                return;
            }
            
            if (![CommonFunc isValidatePhoneNumber:phoneNum]) {
                [CommonFuntion showToast:@"请输入正确的手机号" inView:self.view];
                return;
            }
        }
        
        [self saveSmsSet];
        
    }
    
    
    
    
    
}

///设置是否可编辑
-(void)setEditingStatus:(BOOL)canEditing{
    self.btnSelectSign.enabled = canEditing;
    self.btnStartTime.enabled = canEditing;
    self.btnStopTime.enabled = canEditing;
    self.btnRepeat.enabled = canEditing;
    self.btnWeek1.enabled = canEditing;
    self.btnWeek2.enabled = canEditing;
    self.btnWeek3.enabled = canEditing;
    self.btnWeek4.enabled = canEditing;
    self.btnWeek5.enabled = canEditing;
    self.btnWeek6.enabled = canEditing;
    self.btnWeek7.enabled = canEditing;
    self.btnWeekAll.enabled = canEditing;
    self.textfieldPhone.enabled = canEditing;
    
    [self setShowByEditStatus:canEditing];
}

///根据是否是编辑状态做显示隐藏控制
-(void)setShowByEditStatus:(BOOL)canEditing{
    self.imgSignArrow.hidden = !canEditing;
    self.imgStartArrow.hidden = !canEditing;
    self.imgStopArrow.hidden = !canEditing;
    self.imgRepeatArrow.hidden = !canEditing;
    
    if (_curIndex == 1) {
        self.imgRepeatArrow.hidden = YES;
    }
}

#pragma mark - Title 菜单
-(void)addNarMenu{
    
    /*
    __weak typeof(self) weak_self = self;
    [self customDownMenuWithType:TableViewCellTypeDefault andSource:@[@"挂机短信", @"漏接短信"] andDefaultIndex:_curIndex andBlock:^(NSInteger index) {
        _curIndex = index;
        indexOfMsg = 0;
        NSLog(@"");
        [weak_self notifyView];
        [weak_self findSmsSet];
    }];
     */
    
    
    NSMutableArray *arraySour = [[NSMutableArray alloc] init];
    CustomNarTitleModel *model1 = [[CustomNarTitleModel alloc] init];
    model1.name = @"挂机短信";
    [arraySour addObject:model1];
    
    CustomNarTitleModel *model2 = [[CustomNarTitleModel alloc] init];
    model2.name = @"漏接短信";
    [arraySour addObject:model2];
    
    _curIndex = 0;
    __weak typeof(self) weak_self = self;
    self.customTitleView.sourceArray = arraySour;
    self.customTitleView.index = 0;
    self.customTitleView.valueBlock = ^(NSInteger index) {
        weak_self.curIndex = index;
        NSLog(@"index:%ti",weak_self.curIndex);
        [weak_self notifyView];
        [weak_self findSmsSet];
    };
    self.navigationItem.titleView = self.customTitleView;
    
}


- (CustomNarTitleView*)customTitleView {
    if (!_customTitleView) {
        _customTitleView = [[CustomNarTitleView alloc] init];
        //        _customTitleView.defalutTitleString = @"黑名单";
        _customTitleView.superViewController = self;
    }
    return _customTitleView;
}



- (void)customDownMenuWithType:(TableViewCellType)type andSource:(NSArray *)sourceArray andDefaultIndex:(NSInteger)index andBlock:(void (^)(NSInteger))block {
    
    NavDropView *dropView = [[NavDropView alloc] initWithFrame:CGRectMake(0, 0, 200, 30) andType:type andSource:sourceArray andDefaultIndex:index andController:self];
    dropView.menuIndexClick = block;
    self.navigationItem.titleView = dropView;
}


-(void)notifyView{
    Boolean isHide = FALSE;
    if (_curIndex == 0) {
        isHide = FALSE;
    }else{
        isHide = TRUE;
    }
    
    ///重复频率
    self.labelRepeat.hidden = isHide;
    self.btnRepeat.hidden = isHide;
    self.imgRepeatArrow.hidden = isHide;
    
    ///手机号码
    self.labelPhone.hidden = !isHide;
    self.textfieldPhone.hidden = !isHide;
    
    [self setShowByEditStatus:isEditing];
}

#pragma mark - 手机号码
-(void)initTextFiledPhone{
    self.textfieldPhone.delegate = self;
    self.textfieldPhone.placeholder = @"请输入手机号码";
    self.textfieldPhone.keyboardType = UIKeyboardTypeNumberPad;
    self.textfieldPhone.clearButtonMode = UITextFieldViewModeWhileEditing;
//    [self.textfieldPhone addTarget:self action:@selector(textValueChanged:) forControlEvents:UIControlEventEditingChanged];
    
    self.textfieldPhone.frame = [CommonFunc setViewFrameOffset:self.textfieldPhone.frame byX:0 byY:0 ByWidth:DEVICE_BOUNDS_WIDTH-320 byHeight:0];
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    // Check for non-numeric characters
    NSUInteger lengthOfString = string.length;
    for (NSInteger loopIndex = 0; loopIndex < lengthOfString; loopIndex++) {
        //只允许数字输入
        unichar character = [string characterAtIndex:loopIndex];
        if (character < 48) return NO; // 48 unichar for 0
        if (character > 57) return NO; // 57 unichar for 9
    }
    // Check for total length
    NSUInteger proposedNewLength = textField.text.length - range.length + string.length;
    if (proposedNewLength > 11) return NO;//限制长度
    return YES;
}


#pragma mark - 创建datepicker
-(void)createDatePicker{
    datePickview = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, DEVICE_BOUNDS_HEIGHT, DEVICE_BOUNDS_WIDTH, 260)];
   
    datePickview.datePickerMode = UIDatePickerModeTime;
    datePickview.date = [NSDate date];
}


#pragma mark - 初始化数据
-(void)initData{
    isEditing = FALSE;
    [self setEditingStatus:isEditing];

    selectMsgIndex = 0;
    indexOfMsg = 0;
    _curIndex = 0;
    self.arrayMsg = [[NSMutableArray alloc] init];
    arrayStopTime = [[NSMutableArray alloc] init];
    
    notRepeatday = 0;
    startTime = @"00:00";
    stopTime = @"23:59";
    
    signSelected = @"";
    repeatSelected = @"";
    msgId = @"";
    
    [self.btnStartTime setTitle:startTime forState:UIControlStateNormal];
    [self.btnStopTime setTitle:stopTime forState:UIControlStateNormal];
    [self.btnSelectSign setTitle:signSelected forState:UIControlStateNormal];
    
    [self notifyView];
    
}

///初始化开始时间
-(void)initTimeData{
    NSArray *arrayStart = [[NSArray alloc] initWithObjects:@"00:00",@"00:30",@"01:00",@"01:30",@"02:00",@"02:30",@"03:00",@"03:30",@"04:00",@"04:30",@"05:00",@"05:30",@"06:00",@"06:30",@"07:00",@"07:30",@"08:00",@"08:30",@"09:00",@"09:30",@"10:00",@"10:30",@"11:00",@"11:30",@"12:00",@"12:30",@"13:00",@"13:30",@"14:00",@"14:30",@"15:00",@"15:30",@"16:00",@"16:30",@"17:00",@"17:30",@"18:00",@"18:30",@"19:00",@"19:30",@"20:00",@"20:30",@"21:00",@"21:30",@"22:00",@"22:30",@"23:00",@"23:30", nil];
    
    
    NSArray *arrayStop = [[NSArray alloc] initWithObjects:@"00:00",@"00:30",@"01:00",@"01:30",@"02:00",@"02:30",@"03:00",@"03:30",@"04:00",@"04:30",@"05:00",@"05:30",@"06:00",@"06:30",@"07:00",@"07:30",@"08:00",@"08:30",@"09:00",@"09:30",@"10:00",@"10:30",@"11:00",@"11:30",@"12:00",@"12:30",@"13:00",@"13:30",@"14:00",@"14:30",@"15:00",@"15:30",@"16:00",@"16:30",@"17:00",@"17:30",@"18:00",@"18:30",@"19:00",@"19:30",@"20:00",@"20:30",@"21:00",@"21:30",@"22:00",@"22:30",@"23:00",@"23:30", nil];
    
    
    NSMutableArray *arrStart = [[NSMutableArray alloc] init];
    for (int i=0; i<[arrayStart count]; i++) {
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = [NSString stringWithFormat:@"%i",i];
        model.title = [arrayStart objectAtIndex:i];
        model.selectedFlag = @"no";
        if (i==0) {
            model.selectedFlag = @"yes";
        }
        [arrStart addObject:model];
    }
    arrayStartTime = arrStart;
    
    for (int i=0; i<[arrayStop count]; i++) {
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = [NSString stringWithFormat:@"%i",i];
        model.title = [arrayStop objectAtIndex:i];
        model.selectedFlag = @"no";
        if (i==[arrayStop count]-1) {
            model.selectedFlag = @"yes";
        }
        [arrayStopTime addObject:model];
    }
    
}

-(void)initSignData:(NSDictionary *)arrSmsSignature  andSelectId:(NSInteger)smsSignIdSelect{
    
    /*
     smsSignIdSelect = 1;
     smsSignature =         {
     id = 1;
     name = "\U3010SUNGOIN\U3011";
     };
     */
    
    NSInteger count = 0;
    if (arrSmsSignature) {
        count = [arrSmsSignature count];
    }
    NSLog(@"arrSmsSignature:%@",arrSmsSignature);
    
    NSMutableArray *arrSign = [[NSMutableArray alloc] init];
    /*
    for (int i=0; i<count; i++) {
        SheetMenuModel *model = [[SheetMenuModel alloc] init];
        model.itmeId = [[arrSmsSignature objectAtIndex:i] safeObjectForKey:@"id"];
        model.title = [[arrSmsSignature objectAtIndex:i] safeObjectForKey:@"name"];
        model.selectedFlag = @"no";
        if ([model.itmeId integerValue] == smsSignIdSelect) {
            ///初始化
            signSelected = model.title;
            model.selectedFlag = @"yes";
        }
        [arrSign addObject:model];
    }
     */
    for (int i=0; i<1; i++) {
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = [arrSmsSignature safeObjectForKey:@"id"];
        model.title = [arrSmsSignature safeObjectForKey:@"name"];
        model.selectedFlag = @"no";
        if ([model.itmeId integerValue] == smsSignIdSelect) {
            ///初始化
            signSelected = model.title;
            model.selectedFlag = @"yes";
        }
        [arrSign addObject:model];
    }
    
    arrayMsgSign = arrSign;
    
    [self.btnSelectSign setTitle:signSelected forState:UIControlStateNormal];
}


///初始化重复频率数据
-(void)initRepeatData{
    NSMutableArray *arrRepeat = [[NSMutableArray alloc] init];
    for (int i=0; i<8; i++) {
        LLCenterSheetMenuModel *model = [[LLCenterSheetMenuModel alloc] init];
        model.itmeId = [NSString stringWithFormat:@"%i",i];
        model.title = [NSString stringWithFormat:@"%i天不重复",i];
        model.selectedFlag = @"no";
        if (i==0) {
            ///初始化
            model.selectedFlag = @"yes";
            model.title = @"所有都发";
            repeatSelected = model.title;
        }
        [arrRepeat addObject:model];
    }
    arrayRepeat = arrRepeat;
    
    [self.btnRepeat setTitle:repeatSelected forState:UIControlStateNormal];
}


-(void)addTestData{
    NSMutableDictionary *item;
    NSMutableArray *arrAll = [[NSMutableArray alloc] init];
    for (int i=0; i<9; i++) {
        item = [[NSMutableDictionary alloc] init];
        [item setObject:[NSString stringWithFormat:@"%i-亲爱的4008016161用户， {拨打时间}号码为{主叫号码}拨打您的电话",i] forKey:@"content"];
        [arrAll addObject:item];
    }
    arrayAllMsg = arrAll;
    
    [self changeMsg];
}


#pragma mark - 换一批
-(void)changeMsg{
    NSLog(@"----换一批---->");
    NSLog(@"indexOfMsg:%ti",indexOfMsg);
    [self.arrayMsg removeAllObjects];
    
    if (indexOfMsg == [arrayAllMsg count]) {
        indexOfMsg = 0;
    }
    
    NSInteger tmpIndex = 0;
    for (NSInteger i=indexOfMsg; tmpIndex<3 && i<[arrayAllMsg count]; i++) {
        [self.arrayMsg addObject:[arrayAllMsg objectAtIndex:i]];
        tmpIndex++;
    }
    indexOfMsg += tmpIndex;
    
    [self.tableviewMsg reloadData];
}

#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewMsg = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT) style:UITableViewStyleGrouped];
    self.tableviewMsg.delegate = self;
    self.tableviewMsg.dataSource = self;
    
    
    [self.view addSubview:self.tableviewMsg];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewMsg setTableFooterView:v];
}


-(UIView *)createHeadView{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, DEVICE_BOUNDS_WIDTH, 30)];
    
    headView.backgroundColor = COLOR_BG;
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, DEVICE_BOUNDS_WIDTH, 30)];
    labelTitle.backgroundColor = COLOR_BG;
    labelTitle.font = [UIFont systemFontOfSize:15.0];
    labelTitle.tintColor = [UIColor blackColor];
    labelTitle.text = @"  短信内容";
    
    [headView addSubview:labelTitle];
    
    NSLog(@"arrayAllMsg count:%ti",[arrayAllMsg count]);
    
    if (arrayAllMsg && [arrayAllMsg count] > 3) {
        UIButton *btnChangeMsg = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChangeMsg.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-70, 10, 70, 50);
        [btnChangeMsg setTitle:@"换一批" forState:UIControlStateNormal];
        btnChangeMsg.titleLabel.font = [UIFont systemFontOfSize:15.0];
        btnChangeMsg.titleLabel.textAlignment = NSTextAlignmentLeft;
        [btnChangeMsg setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnChangeMsg addTarget:self action:@selector(changeMsg) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_BOUNDS_WIDTH-80, 30, 13, 13)];
        icon.image = [UIImage imageNamed:@"common_refresh.png"];
        
        [headView addSubview:btnChangeMsg];
        [headView addSubview:icon];
    }
    
    
    return headView;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

#pragma mark - tableview delegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (arrayAllMsg && [arrayAllMsg count] > 0) {
        return 30;
    }
    return 0;
}

//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    
//    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, DEVICE_BOUNDS_WIDTH, 30)];
//    
//    headView.backgroundColor = COLOR_BG;
//    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, DEVICE_BOUNDS_WIDTH, 30)];
//    labelTitle.backgroundColor = COLOR_BG;
//    labelTitle.font = [UIFont systemFontOfSize:15.0];
//    labelTitle.tintColor = [UIColor blackColor];
//    labelTitle.text = @"  短信内容";
//    
//    
//    
//    UIButton *btnChangeMsg = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnChangeMsg.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-70, 20, 60, 30);
//    [btnChangeMsg setTitle:@"换一批" forState:UIControlStateNormal];
//    btnChangeMsg.titleLabel.font = [UIFont systemFontOfSize:15.0];
//    btnChangeMsg.titleLabel.textAlignment = NSTextAlignmentLeft;
//    [btnChangeMsg setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [btnChangeMsg addTarget:self action:@selector(changeMsg) forControlEvents:UIControlEventTouchUpInside];
//    
//    
//    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_BOUNDS_WIDTH-85, 30, 13, 13)];
//    icon.image = [UIImage imageNamed:@"common_refresh.png"];
//    
//    
//    
//    [headView addSubview:labelTitle];
//    [headView addSubview:btnChangeMsg];
//    [headView addSubview:icon];
//    
//    return headView;
//}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 500.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return self.viewFooter;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.arrayMsg) {
        return [self.arrayMsg count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [NoAnSwerCell getCellHeight:[self.arrayMsg objectAtIndex:indexPath.row]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NoAnSwerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoAnSwerCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"NoAnSwerCell" owner:self options:nil];
        cell = (NoAnSwerCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    
    [cell setCellDetails:[self.arrayMsg objectAtIndex:indexPath.row]];
    BOOL isSelect = [self isCurSelectMsg:[self.arrayMsg objectAtIndex:indexPath.row]];
    if (isSelect) {
        [cell.btnSelectIcon setBackgroundImage:[UIImage imageNamed:@"choose_selected.png"] forState:UIControlStateNormal];
        cell.labelMsgContent.textColor = COLOR_LIGHT_BLUE;
    }else{
        [cell.btnSelectIcon setBackgroundImage:[UIImage imageNamed:@"choose_select.png"] forState:UIControlStateNormal];
        cell.labelMsgContent.textColor = [UIColor blackColor];
    }
    
    if (isEditing) {
        cell.btnSelectIcon.enabled = YES;
    }else{
        cell.btnSelectIcon.enabled = NO;
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (isEditing) {
        ///标记 id content
        NSDictionary *item = [self.arrayMsg objectAtIndex:indexPath.row];
        msgContent = [item safeObjectForKey:@"SMSTEMPLATE"];
        
        [self.tableviewMsg reloadData];
    }
    
}


#pragma mark - 事件

///周一 - 周日
- (IBAction)selectSendWeekTime:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    
    if (tag == 0) {
        if (btn.selected) {
            [self setSelectedWeek:FALSE];
            [self setCheckWeek:FALSE];
            [self setWeekImgCheck:FALSE];
            [btn setImage:[UIImage imageNamed:@"img_select_unselect.png"] forState:UIControlStateNormal];
            
        }else{
            [self setSelectedWeek:TRUE];
            [self setCheckWeek:TRUE];
            [self setWeekImgCheck:TRUE];
            [btn setImage:[UIImage imageNamed:@"img_select_selected.png"] forState:UIControlStateNormal];
        }
    }else{
        if (btn.selected) {
            [btn setSelected:NO];
            [btn setImage:[UIImage imageNamed:@"img_select_unselect.png"] forState:UIControlStateNormal];
        }else{
            [btn setSelected:YES];
            [btn setImage:[UIImage imageNamed:@"img_select_selected.png"] forState:UIControlStateNormal];
        }
    }
    

    switch (tag) {
        case 0:
            isCheckWeekAll = !isCheckWeekAll;
            break;
        case 1:
            isCheckWeek1 = !isCheckWeek1;
            break;
        case 2:
            isCheckWeek2 = !isCheckWeek2;
            break;
        case 3:
            isCheckWeek3 = !isCheckWeek3;
            break;
        case 4:
            isCheckWeek4 = !isCheckWeek4;
            break;
        case 5:
            isCheckWeek5 = !isCheckWeek5;
            break;
        case 6:
            isCheckWeek6 = !isCheckWeek6;
            break;
        case 7:
            isCheckWeek7 = !isCheckWeek7;
            break;
            
        default:
            break;
    }
    
    [self notifyWeekSelect];
}

-(void)setCheckWeek:(Boolean)isCheck{
    isCheckWeek1 = isCheck;
    isCheckWeek2 = isCheck;
    isCheckWeek3 = isCheck;
    isCheckWeek4 = isCheck;
    isCheckWeek5 = isCheck;
    isCheckWeek6 = isCheck;
    isCheckWeek7 = isCheck;
    isCheckWeekAll = isCheck;
}

-(void)setSelectedWeek:(Boolean)isSelected{
    
    self.btnWeek1.selected = isSelected;
    self.btnWeek2.selected = isSelected;
    self.btnWeek3.selected = isSelected;
    self.btnWeek4.selected = isSelected;
    self.btnWeek5.selected = isSelected;
    self.btnWeek6.selected = isSelected;
    self.btnWeek7.selected = isSelected;
    self.btnWeekAll.selected = isSelected;
}

///设置初始选择状态
-(void)setBtnWeekStatus:(BOOL)isSelect withTag:(NSInteger)tag{
    UIButton *btn;
    switch (tag) {
        case 0:
            isCheckWeekAll = isSelect;
            self.btnWeekAll.selected = isSelect;
            btn = self.btnWeekAll;
            break;
        case 1:
            isCheckWeek1 = isSelect;
            self.btnWeek1.selected = isSelect;
            btn = self.btnWeek1;
            break;
        case 2:
            isCheckWeek2 = isSelect;
            self.btnWeek2.selected = isSelect;
            btn = self.btnWeek2;
            break;
        case 3:
            isCheckWeek3 = isSelect;
            self.btnWeek3.selected = isSelect;
            btn = self.btnWeek3;
            break;
        case 4:
            isCheckWeek4 = isSelect;
            self.btnWeek4.selected = isSelect;
            btn = self.btnWeek4;
            break;
        case 5:
            isCheckWeek5 = isSelect;
            self.btnWeek5.selected = isSelect;
            btn = self.btnWeek5;
            break;
        case 6:
            isCheckWeek6 = isSelect;
            self.btnWeek6.selected = isSelect;
            btn = self.btnWeek6;
            break;
        case 7:
            isCheckWeek7 = isSelect;
            self.btnWeek7.selected = isSelect;
            btn = self.btnWeek7;
            break;
            
        default:
            break;
    }
    
    NSString *imgName = @"";
    if (isSelect) {
        imgName = @"img_select_selected.png";
    }else{
        imgName = @"img_select_unselect.png";
    }
    [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
}


-(void)setWeekImgCheck:(Boolean)isCheck{
    NSString *imgName = @"";
    if (isCheck) {
        imgName = @"img_select_selected.png";
    }else{
        imgName = @"img_select_unselect.png";
    }
    UIImage *img = [UIImage imageNamed:imgName];
    [self.btnWeek1 setImage:img forState:UIControlStateNormal];
    [self.btnWeek2 setImage:img forState:UIControlStateNormal];
    [self.btnWeek3 setImage:img forState:UIControlStateNormal];
    [self.btnWeek4 setImage:img forState:UIControlStateNormal];
    [self.btnWeek5 setImage:img forState:UIControlStateNormal];
    [self.btnWeek6 setImage:img forState:UIControlStateNormal];
    [self.btnWeek7 setImage:img forState:UIControlStateNormal];
}

-(void)notifyWeekSelect{
    ///已全选中
    if (isCheckWeek1 && isCheckWeek2 && isCheckWeek3 && isCheckWeek4 && isCheckWeek5 && isCheckWeek6 && isCheckWeek7 ) {
        isCheckWeekAll = TRUE;
         [self.btnWeekAll setImage:[UIImage imageNamed:@"img_select_selected.png"] forState:UIControlStateNormal];
        [self.btnWeekAll setSelected:TRUE];
    }else{
        isCheckWeekAll = FALSE;
        [self.btnWeekAll setImage:[UIImage imageNamed:@"img_select_unselect.png"] forState:UIControlStateNormal];
        [self.btnWeekAll setSelected:FALSE];
    }
    
}


///开始时间-结束时间
- (IBAction)selectTime:(id)sender {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    __weak typeof(self) weak_self = self;
    if (tag == 0) {
//        [self showMenuByFlag:2];
        NSDate *date = [NSDate date];
        date = [NSDate setOneDate:date Hour:0 Minute:0];
        
        LLCenterPickerView *llsheet = [[LLCenterPickerView alloc]initWithCurDate:date andMinDate:nil headTitle:@"开始时间" dateType:0];
        llsheet.selectedDateBlock = ^(NSString *time,NSDate *date){
            NSLog(@"-----time:%@",time);
            if (time && date) {
                startTime = time;
                minDate = date;
            }
            
            [weak_self.btnStartTime setTitle:startTime forState:UIControlStateNormal];
        };
        [llsheet showInView:nil];
    }else if (tag == 1){
//        [self showMenuByFlag:3];
        LLCenterPickerView *llsheet;
        if (minDate == nil) {
            NSDate *date = [NSDate date];
            date = [NSDate setOneDate:date Hour:0 Minute:0];
            llsheet = [[LLCenterPickerView alloc]initWithCurDate:date andMinDate:nil headTitle:@"结束时间" dateType:0];
        }else{
            NSLog(@"minDate:%@",minDate);
            llsheet = [[LLCenterPickerView alloc]initWithCurDate:minDate andMinDate:minDate headTitle:@"结束时间" dateType:0];
        }
        
        llsheet.selectedDateBlock = ^(NSString *time,NSDate *date){
            NSLog(@"-----time:%@",time);
            if (time ) {
               stopTime = time;
            }
            
            [weak_self.btnStopTime setTitle:stopTime forState:UIControlStateNormal];
        };
        [llsheet showInView:nil];
    }
}



///短信签名
- (IBAction)selectMsgSign:(id)sender {
    [self showMenuByFlag:1];
}


///重复频率
- (IBAction)selectRepeat:(id)sender {
    [self showMenuByFlag:4];
}


#pragma mark - 弹框
///根据flag 弹框  1 签名 2开始时间  3结束时间 4重复频率
-(void)showMenuByFlag:(NSInteger)flag{
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    NSArray *array = nil;
    NSString *title = @"";
    /// 0单选  1多选
    NSInteger type = 0;
    LLcenterSheetMenuView *sheet;
    if (flag == 1) {
        title = @"短信签名";
        type = 0;
        array = arrayMsgSign;
    }else if (flag == 2){
        title = @"开始时间";
        type = 0;
        array = arrayStartTime;
    }else if (flag == 3){
        title = @"结束时间";
        type = 0;
        array = arrayStopTime;
    }else if (flag == 4){
        title = @"重复频率";
        type = 0;
        array = arrayRepeat;
    }
    
    if (array == nil || [array count] == 0) {
        NSLog(@"选择数据源为空");
        return;
    }
    sheet = [[LLcenterSheetMenuView alloc]initWithlist:array headTitle:title footBtnTitle:@"" cellType:type menuFlag:flag];
    sheet.delegate = self;
    [sheet showInView:nil];
}


-(void)didSelectSheetMenuIndex:(NSInteger)index menuType:(SheetMenuType)menuT menuFlag:(NSInteger)flag{
    
    NSLog(@"index:%ti",index);
    
    if (flag == 1){
        [self changeSelectedFlag:arrayMsgSign index:index withFlag:1];
    }else if (flag == 2){
        
        [arrayStopTime removeAllObjects];
        if (index == [arrayStartTime count]-1) {
            [arrayStopTime addObject:[arrayStartTime objectAtIndex:0]];
        }else{
            for (NSInteger i=index+1; i<[arrayStartTime count]; i++) {
                [arrayStopTime addObject:[arrayStartTime objectAtIndex:i]];
            }
        }
        [self changeSelectedFlag:arrayStartTime index:index withFlag:2];
        [self changeSelectedFlag:arrayStopTime index:[arrayStopTime count]-1 withFlag:3];
        
    }else if (flag == 3){
        [self changeSelectedFlag:arrayStopTime index:index withFlag:3];
    }else if (flag == 4){
        [self changeSelectedFlag:arrayRepeat index:index withFlag:4];
        notRepeatday = index;
    }
    
    
}

-(void)changeSelectedFlag:(NSArray *)array index:(NSInteger)index  withFlag:(NSInteger)flag{
    LLCenterSheetMenuModel *modelTmp;
    for (int i=0; i<[array count]; i++) {
        modelTmp = (LLCenterSheetMenuModel*)[array objectAtIndex:i];
        if (i==index) {
            modelTmp.selectedFlag = @"yes";
            
            if (flag == 1) {
                signSelected = modelTmp.title;
                [self.btnSelectSign setTitle:signSelected forState:UIControlStateNormal];
            }else if (flag == 2) {
                startTime = modelTmp.title;
                [self.btnStartTime setTitle:startTime forState:UIControlStateNormal];
            }else if (flag == 3) {
                stopTime = modelTmp.title;
                [self.btnStopTime setTitle:stopTime forState:UIControlStateNormal];
            }else if (flag == 4) {
                repeatSelected = modelTmp.title;
                [self.btnRepeat setTitle:repeatSelected forState:UIControlStateNormal];
            }
            
        }else{
            modelTmp.selectedFlag = @"no";
        }
    }
}


#pragma mark - 请求服务器数据
///获取当前短信设置状态
-(void)findSmsSet{
    self.tableviewMsg.tableHeaderView = nil;
    [self initDefaultTimeForNil];
    [self clearViewNoData];
    indexOfMsg = 0;
    NSString *requestAction = LLC_GET_SMS_SETINFO_ACTION;
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    ///传入：smsType（0,挂机短信；1,漏接短信）
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    [rDict setObject:[NSString stringWithFormat:@"%ti",_curIndex] forKey:@"smsType"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    
    NSLog(@"rParam:%@",rParam);
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_SMS_SETINFO_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"获取当前短信设置jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            ///所有短信
            if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"templateList"] != [NSNull null]) {
                arrayAllMsg = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"templateList"];
                
                if (arrayAllMsg && [arrayAllMsg count] > 0) {
                    msgContent = [[arrayAllMsg objectAtIndex:0] safeObjectForKey:@"SMSTEMPLATE"];
                }
                
                
                [self changeMsg];
                self.tableviewMsg.tableHeaderView = nil;
                self.tableviewMsg.tableHeaderView = [self createHeadView];
            }else{
                NSLog(@"data------>:<null>");
                [CommonFuntion showToast:@"获取短信异常异常" inView:self.view];
                self.tableviewMsg.tableHeaderView = nil;
            }
            
            ///当前选中的短信
            if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"useTemplate"] != [NSNull null]) {
                
                
                if (![[[jsonResponse objectForKey:@"resultMap"] objectForKey:@"useTemplate"] isKindOfClass:[NSString class]]) {
                    NSLog(@"---not string--->");
                    curDciMsg = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"useTemplate"];
                    msgContent = [curDciMsg safeObjectForKey:@"SMSTEMPLATE"];
                    msgId = [curDciMsg safeObjectForKey:@"ID"];
                }
                
            }
            
            ///发送时间
            if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"useStrategy"] != [NSNull null] ) {
                
                if (![ [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"useStrategy"] isKindOfClass:[NSString class]]) {
                    useStrategy = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"useStrategy"];
                    [self initDefaultTime];
                }
                
            }
            
            ///手机号
            if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"userPhone"] != [NSNull null]) {
                
                if (![[[jsonResponse objectForKey:@"resultMap"] objectForKey:@"userPhone"] isKindOfClass:[NSString class]]) {
                    phoneNum = [[[jsonResponse objectForKey:@"resultMap"] objectForKey:@"userPhone"] safeObjectForKey:@"PHONE"];
                    self.textfieldPhone.text = phoneNum;
                }
                
                
            }
            
            ///当前签名
            /*
             userPhone =         {
             PHONE = 15902180750;
             };
             */
            if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"smsSignature"] != [NSNull null]) {
#warning 应返回数组
                //                NSArray  *smsSignature = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"smsSignature"];
                
                if (![[[jsonResponse objectForKey:@"resultMap"] objectForKey:@"smsSignature"] isKindOfClass:[NSString class]]) {
                    NSDictionary  *smsSignature = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"smsSignature"];
                    NSLog(@"smsSignature:%@",smsSignature);
                    NSInteger smsSignIdSelect = [[[jsonResponse objectForKey:@"resultMap"] objectForKey:@"smsSignIdSelect"] integerValue];
                    [self initSignData:smsSignature andSelectId:smsSignIdSelect];
                }
                
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self findSmsSet];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            self.tableviewMsg.tableHeaderView = nil;
            [CommonFuntion showToast:desc inView:self.view];
            [self notifyNoDataView];
        }
        [self.tableviewMsg reloadData];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
        self.tableviewMsg.tableHeaderView = nil;
        [self.tableviewMsg reloadData];
        [self notifyNoDataView];
    }];
}


#pragma mark - 保存短信设置
-(void)saveSmsSet{
    
    if ([startTime compare:stopTime] == 1) {
        NSLog(@"开始时间大于结束时间");
    }
    
    ///传入：短信类型（挂机短信/漏接短信）,短信ID,短信签名ID,短信发送的起止时间以及设置的星期（以“,”分隔开）,重复频率类型（挂机短信时传入）,手机号码（漏接短信时传入）
    
    NSString *requestAction = LLC_EDID_SMS_SETINFO_ACTION;
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    ///传入：类型（黑名单还是白名单），号码（校验），备注信息[注：后台自动加上号码所在地]
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rDict setValue:[NSString stringWithFormat:@"%ti",_curIndex] forKey:@"smsType"];
    [rDict setValue:startTime forKey:@"startTime"];
    [rDict setValue:stopTime forKey:@"endTime"];
    [rDict setValue:[self getWeekSelected] forKey:@"week"];
    [rDict setValue:[useStrategy safeObjectForKey:@"ID"] forKey:@"strategyId"];
    [rDict setValue:msgContent forKey:@"templateContent"];
    
    ///短信签名ID
//    [rDict setValue:[self getMsgSignId] forKey:@""];
    
    
    ///挂机短信
    if (_curIndex == 0) {
        [rDict setValue:msgId forKey:@"templateId"];
        [rDict setValue:[NSString stringWithFormat:@"%ti",notRepeatday] forKey:@"notRepeatday"];
    }else{
        [rDict setValue:phoneNum forKey:@"phone"];
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    NSLog(@"rParam:%@",rParam);
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_EDID_SMS_SETINFO_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"保存短信设置jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            isEditing = FALSE;
            [self setEditingStatus:isEditing];
            
            [self.tableviewMsg reloadData];
            
            [self.navigationItem.rightBarButtonItem setTitle:@"编辑"];
            [CommonFuntion showToast:@"保存成功" inView:self.view];
            self.navigationItem.titleView.userInteractionEnabled = YES;
            [self.customTitleView setIndicatorViewHide:NO];
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self saveSmsSet];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"保存失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
    
}


///是否是选中项
-(BOOL)isCurSelectMsg:(NSDictionary *)curSelectItem{
    if ([[curSelectItem safeObjectForKey:@"SMSTEMPLATE"] isEqualToString:msgContent]) {
        return TRUE;
    }
    return FALSE;
}

///请求数据为空的情况
-(void)initDefaultTimeForNil{

    [self setBtnWeekStatus:0 withTag:1];
    [self setBtnWeekStatus:0 withTag:2];
    [self setBtnWeekStatus:0 withTag:3];
    [self setBtnWeekStatus:0 withTag:4];
    [self setBtnWeekStatus:0 withTag:5];
    [self setBtnWeekStatus:0 withTag:6];
    [self setBtnWeekStatus:0 withTag:7];
    
    ///刷新是否全选
    [self notifyWeekSelect];
    
    
    isEditing = FALSE;
    [self setEditingStatus:isEditing];
    
    selectMsgIndex = 0;
    indexOfMsg = 0;
    if (self.arrayMsg) {
        [self.arrayMsg removeAllObjects];
    }
    
    if (arrayStopTime) {
        [arrayStopTime removeAllObjects];
    }
    
    
    notRepeatday = 0;
    startTime = @"00:00";
    stopTime = @"23:59";
    
    signSelected = @"";
    repeatSelected = @"";
    msgId = @"";
    
    [self.btnStartTime setTitle:startTime forState:UIControlStateNormal];
    [self.btnStopTime setTitle:stopTime forState:UIControlStateNormal];
    [self.btnSelectSign setTitle:signSelected forState:UIControlStateNormal];
    
    
}
////初始化发送时间与重复频率手机号
-(void)initDefaultTime{

    NSInteger MONDAY = [[useStrategy safeObjectForKey:@"MONDAY"] integerValue];
    [self setBtnWeekStatus:MONDAY withTag:1];
    
    NSInteger TUESDAY = [[useStrategy safeObjectForKey:@"TUESDAY"] integerValue];
    [self setBtnWeekStatus:TUESDAY withTag:2];
    
    NSInteger WEDNESDAY = [[useStrategy safeObjectForKey:@"WEDNESDAY"] integerValue];
    [self setBtnWeekStatus:WEDNESDAY withTag:3];
    
    NSInteger THURSDAY = [[useStrategy safeObjectForKey:@"THURSDAY"] integerValue];
    [self setBtnWeekStatus:THURSDAY withTag:4];
    
    NSInteger FRIDAY = [[useStrategy safeObjectForKey:@"FRIDAY"] integerValue];
    [self setBtnWeekStatus:FRIDAY withTag:5];
    
    NSInteger SATURDAY = [[useStrategy safeObjectForKey:@"SATURDAY"] integerValue];
    [self setBtnWeekStatus:SATURDAY withTag:6];
    
    NSInteger SUNDAY = [[useStrategy safeObjectForKey:@"SUNDAY"] integerValue];
    [self setBtnWeekStatus:SUNDAY withTag:7];
    
    ///刷新是否全选
    [self notifyWeekSelect];
    
    ///重复频率
    NSInteger NOTREPEATDAY = [[useStrategy safeObjectForKey:@"NOTREPEATDAY"] integerValue];
    if (NOTREPEATDAY < [arrayRepeat count]) {
        ///刷新UI显示
        [self changeSelectedFlag:arrayRepeat index:NOTREPEATDAY withFlag:4];
    }
    
    if ([useStrategy safeObjectForKey:@"STARTTIME"] && [useStrategy safeObjectForKey:@"STARTTIME"].length > 0) {
        startTime = [useStrategy safeObjectForKey:@"STARTTIME"];
    }
    
    if ([useStrategy safeObjectForKey:@"ENDTIME"] && [useStrategy safeObjectForKey:@"ENDTIME"].length > 0) {
        stopTime = [useStrategy safeObjectForKey:@"ENDTIME"];
    }
    
    [self.btnStartTime setTitle:startTime forState:UIControlStateNormal];
    [self.btnStopTime setTitle:stopTime forState:UIControlStateNormal];
}

////获取已选择的发送时间--周几
-(NSString *)getWeekSelected{
    NSMutableString *strTags = [[NSMutableString alloc] init];
    [strTags appendString:@""];
    if (isCheckWeekAll) {
        [strTags appendString:@"1,1,1,1,1,1,1"];
    }else{
        if (isCheckWeek1) {
            [strTags appendString:@"1"];
        }else{
            [strTags appendString:@"0"];
        }
        
        if (isCheckWeek2) {
            [strTags appendString:@",1"];
        }else{
            [strTags appendString:@",0"];
        }
        
        if (isCheckWeek3) {
            [strTags appendString:@",1"];
        }else{
            [strTags appendString:@",0"];
        }
        
        if (isCheckWeek4) {
            [strTags appendString:@",1"];
        }else{
            [strTags appendString:@",0"];
        }
        
        if (isCheckWeek5) {
            [strTags appendString:@",1"];
        }else{
            [strTags appendString:@",0"];
        }
        
        if (isCheckWeek6) {
            [strTags appendString:@",1"];
        }else{
            [strTags appendString:@",0"];
        }
        
        if (isCheckWeek7) {
            [strTags appendString:@",1"];
        }else{
            [strTags appendString:@",0"];
        }
    }
    
    return strTags;
}

///获取短信签名ID
-(NSString *)getMsgSignId{
    NSString *signId = @"";
    
    NSInteger count = 0;
    LLCenterSheetMenuModel *model;
    for (int i=0; i<count; i++) {
        model = (LLCenterSheetMenuModel *)[arrayMsgSign objectAtIndex:i];
        if ([model.selectedFlag isEqualToString:@"yes"]) {
            signId = model.itmeId;
        }
    }
    
    return signId;
}



#pragma mark - 没有数据时的view

-(void)notifyNoDataView{
    [self setViewNoData:@"加载数据失败"];
    self.tableviewMsg.hidden = YES;
    self.navigationItem.rightBarButtonItem = nil;
}

-(void)setViewNoData:(NSString *)title{
    if (self.commonNoDataView == nil) {
        self.commonNoDataView = [CommonFunc commonNoDataViewIcon:@"list_empty.png" Title:title optionBtnTitle:@""];
    }
    
    [self.view addSubview:self.commonNoDataView];
}

-(void)clearViewNoData{
    if (self.commonNoDataView) {
        [self.commonNoDataView removeFromSuperview];
        self.commonNoDataView = nil;
    }
}

/*
 "useStrategy": {
 "ID": "8186b609-dfdc-43f4-acaf-f4e54f6bebf7",
 "USER_ID": "4008016161",
 "SMS_TYPE": 0,
 "MONDAY": 0,
 "TUESDAY": 0,
 "WEDNESDAY": 0,
 "THURSDAY": 1,
 "FRIDAY": 1,
 "SATURDAY": 1,
 "SUNDAY": 1,
 "STARTTIME": "00:00",
 "ENDTIME": "23:59",
 "NOTREPEATDAY": 1
 },
 "smsSignature": "【SUNGOIN】"
 */


#pragma mark - 初始化view frame
-(void)initViewFrame{
    NSInteger vX = DEVICE_BOUNDS_WIDTH-320;
    
    ///短信签名
    self.btnSelectSign.frame = [CommonFunc setViewFrameOffset:self.btnSelectSign.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    self.imgSignArrow.frame = [CommonFunc setViewFrameOffset:self.imgSignArrow.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    
    
    self.lableSignIntroTag.frame = [CommonFunc setViewFrameOffset:self.lableSignIntroTag.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    self.lableSignIntro.frame = [CommonFunc setViewFrameOffset:self.lableSignIntro.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    
    ///发送时间
    self.btnStartTime.frame = [CommonFunc setViewFrameOffset:self.btnStartTime.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    self.imgStartArrow.frame = [CommonFunc setViewFrameOffset:self.imgStartArrow.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    
    ///结束时间
    self.btnStopTime.frame = [CommonFunc setViewFrameOffset:self.btnStopTime.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    self.imgStopArrow.frame = [CommonFunc setViewFrameOffset:self.imgStopArrow.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    
    ///重复频率
    self.btnRepeat.frame = [CommonFunc setViewFrameOffset:self.btnRepeat.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    self.imgRepeatArrow.frame = [CommonFunc setViewFrameOffset:self.imgRepeatArrow.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    
    self.textfieldPhone.frame = [CommonFunc setViewFrameOffset:self.textfieldPhone.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
    
    ///周一至周日
    CGFloat width =  (DEVICE_BOUNDS_WIDTH-20)/4;
    CGFloat height = 30;
    CGFloat yPoint = 235;
    CGFloat xPoint = 10;
    self.btnWeekAll.frame = CGRectMake(xPoint, yPoint, width, height);
    xPoint += width;
    
    self.btnWeek1.frame = CGRectMake(xPoint, yPoint, width, height);
    xPoint += width;
    
    self.btnWeek2.frame = CGRectMake(xPoint, yPoint, width, height);
    xPoint += width;
    
    self.btnWeek3.frame = CGRectMake(xPoint, yPoint, width, height);
    xPoint += width;
    
    xPoint = 10;
    yPoint = 270;
    
    self.btnWeek4.frame = CGRectMake(xPoint, yPoint, width, height);
    xPoint += width;
    
    self.btnWeek5.frame = CGRectMake(xPoint, yPoint, width, height);
    xPoint += width;
    
    self.btnWeek6.frame = CGRectMake(xPoint, yPoint, width, height);
    xPoint += width;
    
    self.btnWeek7.frame = CGRectMake(xPoint, yPoint, width, height);
    xPoint += width;
    
}

@end
