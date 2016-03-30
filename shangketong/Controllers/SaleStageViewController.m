//
//  SaleStageViewController.m
//  shangketong
//
//  Created by sungoin-zjp on 15-7-9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SaleStageViewController.h"
#import "CommonConstant.h"
#import "CommonFuntion.h"
#import "SaleStagesCell.h"
@interface SaleStageViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>{
    NSMutableArray *arrayStages;
}

@end

@implementation SaleStageViewController

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = kView_BG_Color;
    self.title = @"修改销售阶段";
    [self addNarOkBtn];
    [self initTableview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self.tableviewStages reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

#pragma mark - Nar btn
-(void)addNarOkBtn{
    UIBarButtonItem *okButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain
                                                                target:self action:@selector(okBtnPressed)];
    self.navigationItem.rightBarButtonItem = okButton;
}

-(void)okBtnPressed{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 初始化数据
-(void)initData{
    NSLog(@"self.stageId:%lld",self.stageId);
    arrayStages = [[NSMutableArray alloc] init];
    [arrayStages addObjectsFromArray:self.arrayOldStages];
    ///初始化open标记
    NSInteger count = 0;
    if (arrayStages) {
        count = [arrayStages count];
    }
    NSDictionary *item;
    NSMutableDictionary *mutableItemNew;
    for (int i=0; i<count; i++) {
        item = [arrayStages objectAtIndex:i];
        mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:item];
        NSLog(@"%lld",[[item objectForKey:@"id"] longLongValue]);
        if (self.stageId == [[item objectForKey:@"id"] longLongValue]) {
            NSLog(@"self.stageId ==");
            [mutableItemNew setValue:@(YES) forKey:@"open"];
        }else{
            [mutableItemNew setValue:@(NO) forKey:@"open"];
        }
        
        [arrayStages setObject: mutableItemNew atIndexedSubscript:i];
    }
    
    NSLog(@"self.arrayStages:%@",arrayStages);
}


#pragma mark - 初始化tablview
-(void)initTableview{
    self.tableviewStages = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStyleGrouped];
    self.tableviewStages.delegate = self;
    self.tableviewStages.dataSource = self;
    self.tableviewStages.sectionFooterHeight = 0;
    self.tableviewStages.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableviewStages.backgroundColor = VIEW_BG_COLOR;
    [self.view addSubview:self.tableviewStages];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableviewStages setTableFooterView:v];
    
    self.tableviewStages.tableFooterView = [self creatFootView];
}


#pragma mark - 创建footerview
-(UIView *)creatFootView{
    UIView *footview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 80)];
    footview.backgroundColor = VIEW_BG_COLOR;
    
    
    UIView *faildView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, kScreen_Width, 30)];
    faildView.backgroundColor = [UIColor whiteColor];
    [footview addSubview:faildView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(footerViewTap:)];
    [faildView addGestureRecognizer:tap];
    
    ///圆点
    UIImageView *lineCircle = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 6, 6)];
    lineCircle.image = [CommonFuntion createImageWithColor:[UIColor colorWithRed:94.0f/255 green:151.0f/255 blue:246.0f/255 alpha:1.0f]];
    lineCircle.contentMode = UIViewContentModeScaleAspectFill;
    lineCircle.clipsToBounds = YES;
    lineCircle.layer.cornerRadius = lineCircle.frame.size.height/2;
    [faildView addSubview:lineCircle];
    
    ///title
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 200, 30)];
    labelTitle.font = [UIFont systemFontOfSize:15.0];
    labelTitle.textAlignment = NSTextAlignmentLeft;
    labelTitle.text = @"输单";
    [faildView addSubview:labelTitle];
    
    return footview;
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (arrayStages) {
        return [arrayStages count];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSDictionary *dict = [arrayStages objectAtIndex:section];
    if ([[dict objectForKey:@"open"] boolValue]) {
        return [[dict objectForKey:@"activitys"] count];
    }else {
        return 0;
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 50)];
    headview.backgroundColor = [UIColor whiteColor];
    headview.tag = section;
//    [headview addLineUp:NO andDown:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewTap:)];
    [headview addGestureRecognizer:tap];
    
    ///底部分割线
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(30, 49, kScreen_Width-15, 1)];
    line.image = [UIImage imageNamed:@"line.png"];
    [headview addSubview:line];
    
    ///竖线
    UIImageView *lineV = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, 1, 50)];
    lineV.image = [CommonFuntion createImageWithColor:[UIColor colorWithRed:239.0f/255 green:239.0f/255 blue:239.0f/255 alpha:1.0f]];
    [headview addSubview:lineV];
    
    ///圆点
    UIImageView *lineCircle = [[UIImageView alloc] initWithFrame:CGRectMake(12, 22, 6, 6)];
    lineCircle.image = [CommonFuntion createImageWithColor:[UIColor colorWithRed:94.0f/255 green:151.0f/255 blue:246.0f/255 alpha:1.0f]];
    lineCircle.contentMode = UIViewContentModeScaleAspectFill;
    lineCircle.clipsToBounds = YES;
    lineCircle.layer.cornerRadius = lineCircle.frame.size.height/2;
    [headview addSubview:lineCircle];
    
    ///title
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 200, 49)];
    labelTitle.font = [UIFont systemFontOfSize:15.0];
    labelTitle.textAlignment = NSTextAlignmentLeft;
    labelTitle.text = [self getHeadViewTitle:section];
    [headview addSubview:labelTitle];
    
    NSLog(@"---viewForHeaderInSection--->");
    ///icon
    UIImageView *icon = [[UIImageView alloc] init];
    icon.frame = CGRectMake(kScreen_Width-30, 17, 15, 15);
    
    NSDictionary *dict = [arrayStages objectAtIndex:headview.tag];
    BOOL isOpen = [[dict objectForKey:@"open"] boolValue];
    if (isOpen) {
        icon.image = [UIImage imageNamed:@"filter_slider_stage_select.png"];
    }else{
        icon.image = [UIImage imageNamed:@"filter_slider_stage_normal.png"];
    }
    
    icon.tag = 1001+section;
    [headview addSubview:icon];
    
    
    return headview;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SaleStagesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SaleStagesCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SaleStagesCell" owner:self options:nil];
        cell = (SaleStagesCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }

    [cell setCellDetails:[[[arrayStages objectAtIndex:indexPath.section] objectForKey:@"activitys"] objectAtIndex:indexPath.row] indexPath:indexPath andIsCanChecked:YES];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}


#pragma mark - headerViewTap
- (void)headerViewTap:(UITapGestureRecognizer*)sender {
    
    UIView *headview = sender.view;
    NSLog(@"headerViewTap---section:%li",headview.tag);
    NSDictionary *dict = [arrayStages objectAtIndex:headview.tag];
    BOOL isOpen = [[dict objectForKey:@"open"] boolValue];
    UIImageView *icon = (UIImageView*)[headview viewWithTag:headview.tag+1001];
    
    [UIView animateWithDuration:0.2 animations:^{
        icon.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:^(BOOL finished) {
        
        
    }];
    
    if (isOpen) {
        [self animationRowsWithSectionTag:headview.tag complete:^{
        }];
    }else {
        [self animationRowsWithSectionTag:headview.tag complete:^{
        }];
    }
}

- (void)animationRowsWithSectionTag:(NSInteger)tag complete:(void(^)())complete {
    
    // 更新数据源
    NSMutableDictionary *dict = [arrayStages objectAtIndex:tag];
    NSMutableDictionary *mutableItemNew = [NSMutableDictionary dictionaryWithDictionary:dict];
    [mutableItemNew setValue:@(!([[dict objectForKey:@"open"] boolValue])) forKey:@"open"];
    //修改数据
    [arrayStages setObject: mutableItemNew atIndexedSubscript:tag];
    
    
    // 刷新指定section
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:tag];
    [self.tableviewStages reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
    
    complete();
}

#pragma mark - footer view tap
-(void)footerViewTap:(UITapGestureRecognizer*)sender {
    NSLog(@"footerViewTap--->");
    [self showlostReasonsMenu];
}

#pragma mark - 获取headview title信息
-(NSString *)getHeadViewTitle:(NSInteger)section{
    ///stageName
    NSString *stageName = @"";
    if ([[arrayStages objectAtIndex:section] objectForKey:@"stageName"]) {
        stageName = [[arrayStages objectAtIndex:section] objectForKey:@"stageName"];
    }
#warning percent类型？
    NSInteger percent = 0;
    if ([[arrayStages objectAtIndex:section] objectForKey:@"percent"]) {
        percent = [[[arrayStages objectAtIndex:section] objectForKey:@"percent"] integerValue];
    }
    
    NSString *name_percent = [NSString stringWithFormat:@"%@(赢率%ti%%)",stageName,percent];
    return name_percent;
}


#pragma mark - 输单选项
-(void)showlostReasonsMenu{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"请选择输单理由"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles: nil,nil];
    for(NSDictionary *item in self.arrayLostReasons){
        [actionSheet addButtonWithTitle:[item objectForKey:@"name"]];
    }
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"actionSheet clicked index = %ti",buttonIndex);
    if (buttonIndex != 0) {
        NSLog(@"lostreason %@",[[self.arrayLostReasons objectAtIndex:buttonIndex-1] objectForKey:@"name"]);
    }
    
}

@end
