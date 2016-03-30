//
//  SheetMenuView.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#define ROW_HEIGHT 50
#define MAX_NUM 5

#import "LLcenterSheetMenuView.h"
#import "LLCenterUtility.h"
#import "LLCenterSheetMenuModel.h"
#import "LLcenterSheetMenuCell.h"


@implementation LLcenterSheetMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithlist:(NSArray *)list headTitle:(NSString *)headTitle footBtnTitle:(NSString *)footTitle cellType:(SheetMenuType)type menuFlag:(NSInteger)flag{
    self = [super init];
    if(self){
        self.frame = CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, DEVICE_BOUNDS_HEIGHT);
        self.backgroundColor = RGBACOLOR(160, 160, 160, 0);
        ///类型
        menuType = type;
        menuFlag = flag;
        
        CGFloat height = 0;
        if (headTitle && headTitle.length > 0) {
            height += ROW_HEIGHT;
        }
        if ([list count] <= MAX_NUM) {
            height += ROW_HEIGHT*[list count];
        }else{
            height += ROW_HEIGHT*MAX_NUM;
        }
        if (footTitle && footTitle.length > 0) {
            height += ROW_HEIGHT;
        }
        menuView = [[UIView alloc] initWithFrame:CGRectMake(0, DEVICE_BOUNDS_HEIGHT, DEVICE_BOUNDS_WIDTH, height)];
        
        
        height = 0;
        if (headTitle && headTitle.length > 0) {
            UILabel *lableHeadTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, ROW_HEIGHT)];
            lableHeadTitle.backgroundColor = [UIColor whiteColor];
            lableHeadTitle.font = [UIFont systemFontOfSize:17.0];
            lableHeadTitle.textColor = COLOR_LIGHT_BLUE;
            lableHeadTitle.textAlignment = NSTextAlignmentCenter;
            lableHeadTitle.text = headTitle;
            [menuView addSubview:lableHeadTitle];
            height += ROW_HEIGHT;
        }
        
        ///如果是多选 则添加保存按钮
        if (menuType == SheetMenuTypeB) {
            UIButton *btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
            btnSave.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-80, 0, 80, ROW_HEIGHT);
            [btnSave setTitle:@"保存" forState:UIControlStateNormal];
            [btnSave setTitleColor:COLOR_LIGHT_BLUE forState:UIControlStateNormal];
            btnSave.titleLabel.font = [UIFont systemFontOfSize:17.0];
            [btnSave addTarget:self action:@selector(saveEvent) forControlEvents:UIControlEventTouchUpInside];
            [menuView addSubview:btnSave];
        }
        
        
        if ([list count] <= MAX_NUM) {
            tableviewMenu = [[UITableView alloc]initWithFrame:CGRectMake(0, height, DEVICE_BOUNDS_WIDTH,ROW_HEIGHT*[list count]) style:UITableViewStylePlain];
            height += ROW_HEIGHT*[list count];
        }else
        {
            tableviewMenu = [[UITableView alloc]initWithFrame:CGRectMake(0, height, DEVICE_BOUNDS_WIDTH,ROW_HEIGHT*MAX_NUM) style:UITableViewStylePlain];
            
            height += ROW_HEIGHT*MAX_NUM;
        }
        
        tableviewMenu.dataSource = self;
        tableviewMenu.delegate = self;
        listData = [[NSMutableArray alloc] init];
        [listData addObjectsFromArray:list];
        NSLog(@"listData address:%p",listData);
        
        NSLog(@"listData:%@",listData);
        tableviewMenu.scrollEnabled = YES;
        tableviewMenu.showsVerticalScrollIndicator = NO;
        [menuView addSubview:tableviewMenu];
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        [tableviewMenu setTableFooterView:v];
        
        
        
        if (footTitle && footTitle.length > 0) {
            UIButton *btnFoot = [UIButton buttonWithType:UIButtonTypeCustom];
            btnFoot.frame = CGRectMake(0, height, DEVICE_BOUNDS_WIDTH, ROW_HEIGHT);
            btnFoot.titleLabel.font = [UIFont systemFontOfSize:15.0];
            [btnFoot setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [btnFoot setTitle:footTitle forState:UIControlStateNormal];
            [btnFoot setBackgroundColor:[UIColor whiteColor]];
            [btnFoot addTarget:self action:@selector(eventOfFootBtn:) forControlEvents:UIControlEventTouchUpInside];
            [menuView addSubview:btnFoot];
        }
        
        [self addSubview:menuView];
        [self animeData];
    }
    return self;
}

-(NSInteger)getSelectedIndex{
    NSInteger sectedIndex = -1;
    NSInteger count = 0;
    LLCenterSheetMenuModel *mode = nil;
    BOOL isFound = FALSE;
    if (listData) {
        count = [listData count];
    }
    
    for (int i=0; !isFound && i<count; i++) {
        mode = [listData objectAtIndex:i];
        if ([mode.selectedFlag isEqualToString:@"yes"]) {
            sectedIndex = i;
            isFound = TRUE;
        }
    }
    NSLog(@"sectedIndex:%ti",sectedIndex);
    return sectedIndex;
}

-(void)animeData{
    //self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
    [self addGestureRecognizer:tapGesture];
    tapGesture.delegate = self;
    [UIView animateWithDuration:.25 animations:^{
        self.backgroundColor = RGBACOLOR(160, 160, 160, .4);
        [UIView animateWithDuration:.25 animations:^{
            [menuView setFrame:CGRectMake(menuView.frame.origin.x, DEVICE_BOUNDS_HEIGHT-menuView.frame.size.height, menuView.frame.size.width, menuView.frame.size.height)];
        }];
    } completion:^(BOOL finished) {
        
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if([touch.view isKindOfClass:[self class]]){
        return YES;
    }
    return NO;
}

-(void)tappedCancel{
    [UIView animateWithDuration:.25 animations:^{
        [menuView setFrame:CGRectMake(0, DEVICE_BOUNDS_HEIGHT,DEVICE_BOUNDS_WIDTH, 0)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

///底部按钮事件
-(void)eventOfFootBtn:(id)sender{
    [self tappedCancel];
}

- (void)showInView:(UIViewController *)Sview
{
    if(Sview==nil){
        [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:self];
    }else{
        //[view addSubview:self];
        [Sview.view addSubview:self];
    }
    NSInteger selectedIdx = [self getSelectedIndex];
    if (selectedIdx != -1) {
        [tableviewMenu scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIdx inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
}


#pragma mark - tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (listData) {
        return [listData count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ///title  icon
    LLcenterSheetMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LLCenterSheetMenuCellIdentify"];
    if (!cell)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"LLcenterSheetMenuCell" owner:self options:nil];
        cell = (LLcenterSheetMenuCell*)[array objectAtIndex:0];
        [cell awakeFromNib];
    }
    [cell setCellDetails:[listData objectAtIndex:indexPath.row]];
    return cell;
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (menuType == SheetMenuTypeA) {
        [self tappedCancel];
        if(_delegate!=nil && [_delegate respondsToSelector:@selector(didSelectSheetMenuIndex:menuType:menuFlag:)]){
            
            [_delegate didSelectSheetMenuIndex:indexPath.row menuType:SheetMenuTypeA menuFlag:menuFlag];
            return;
        }
    }else if (menuType == SheetMenuTypeB){
        LLCenterSheetMenuModel *mode = [listData objectAtIndex:indexPath.row];
      
        if ([mode.selectedFlag isEqualToString:@"yes"]) {
            mode.selectedFlag = @"no";
        }else{
            mode.selectedFlag = @"yes";
        }
        //修改数据
        [listData setObject: mode atIndexedSubscript:indexPath.row];
        
        ///刷新当前cell
        [tableviewMenu reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        NSLog(@"");
    }
    
}

#pragma mark - 多选保存操作
-(void)saveEvent{
    [self tappedCancel];
    
    NSInteger count = [listData count];
    NSMutableArray *arraySelect = [[NSMutableArray alloc] init];
    LLCenterSheetMenuModel *mode;
    for (int i=0; i<count; i++) {
        mode = [listData objectAtIndex:i];
        if ([mode.selectedFlag isEqualToString:@"yes"]) {
            [arraySelect addObject:mode];
        }
    }
    
    if (self.selectedMenuItemBlock) {
        self.selectedMenuItemBlock(arraySelect,menuFlag);
    }
}

@end
