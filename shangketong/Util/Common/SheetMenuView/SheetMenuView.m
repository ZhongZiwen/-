//
//  SheetMenuView.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#define ROW_HEIGHT 45
#define MAX_NUM 5

#import "SheetMenuView.h"
#import "CommonConstant.h"
#import "SheetMenuCell.h"
#import "SheetmenuCellB.h"
#import "SheetmenuCellC.h"

@interface SheetMenuView ()<CallPhoneOrSendMsgDelegate> {
    
}
@end
@implementation SheetMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithlist:(NSArray *)list headTitle:(NSString *)headTitle footBtnTitle:(NSString *)footTitle cellType:(SheetMenuCellType)type{
    self = [super init];
    if(self){
        self.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
        self.backgroundColor = RGBACOLOR(160, 160, 160, 0);
        
        
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
        menuView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, height)];
        
        
        height = 0;
        if (headTitle && headTitle.length > 0) {
            UILabel *lableHeadTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, ROW_HEIGHT)];
            lableHeadTitle.backgroundColor = [UIColor whiteColor];
            lableHeadTitle.font = [UIFont systemFontOfSize:15.0];
            lableHeadTitle.textColor = [UIColor redColor];
            lableHeadTitle.textAlignment = NSTextAlignmentCenter;
            lableHeadTitle.text = headTitle;
            [menuView addSubview:lableHeadTitle];
            height += ROW_HEIGHT;
        }
        
        if ([list count] <= MAX_NUM) {
            tableviewMenu = [[UITableView alloc]initWithFrame:CGRectMake(0, height, kScreen_Width,ROW_HEIGHT*[list count]) style:UITableViewStylePlain];
            height += ROW_HEIGHT*[list count];
        }else
        {
            tableviewMenu = [[UITableView alloc]initWithFrame:CGRectMake(0, height, kScreen_Width,ROW_HEIGHT*MAX_NUM) style:UITableViewStylePlain];
            
            height += ROW_HEIGHT*MAX_NUM;
        }
        cellType = type;
        tableviewMenu.dataSource = self;
        tableviewMenu.delegate = self;
        listData = list;
        NSLog(@"listData:%@",listData);
        tableviewMenu.scrollEnabled = YES;
        tableviewMenu.showsVerticalScrollIndicator = NO;
        [menuView addSubview:tableviewMenu];
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        [tableviewMenu setTableFooterView:v];
        
        if (footTitle && footTitle.length > 0) {
            UIButton *btnFoot = [UIButton buttonWithType:UIButtonTypeCustom];
            btnFoot.frame = CGRectMake(0, height, kScreen_Width, ROW_HEIGHT);
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

-(void)animeData{
    //self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
    [self addGestureRecognizer:tapGesture];
    tapGesture.delegate = self;
    [UIView animateWithDuration:.25 animations:^{
        self.backgroundColor = RGBACOLOR(160, 160, 160, .4);
        [UIView animateWithDuration:.25 animations:^{
            [menuView setFrame:CGRectMake(menuView.frame.origin.x, kScreen_Height-menuView.frame.size.height, menuView.frame.size.width, menuView.frame.size.height)];
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
        [menuView setFrame:CGRectMake(0, kScreen_Height,kScreen_Width, 0)];
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
    
    if (cellType == SheetMenuCellTypeA) {
        ///title  icon
        SheetMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SheetMenuCellIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SheetMenuCell" owner:self options:nil];
            cell = (SheetMenuCell*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        [cell setCellFrame];
        [cell setCellDetails:[listData objectAtIndex:indexPath.row]];
        return cell;
    }else if (cellType == SheetMenuCellTypeB){
        ///title leftbtn  rightbtn
        SheetmenuCellB *cell = [tableView dequeueReusableCellWithIdentifier:@"SheetmenuCellBIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SheetmenuCellB" owner:self options:nil];
            cell = (SheetmenuCellB*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        [cell setCellDetails:[listData objectAtIndex:indexPath.row] indexPath:indexPath];
        return cell;
    }else if (cellType == SheetMenuCellTypeB){
        ///title
        SheetmenuCellC *cell = [tableView dequeueReusableCellWithIdentifier:@"SheetmenuCellCIdentify"];
        if (!cell)
        {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SheetmenuCellC" owner:self options:nil];
            cell = (SheetmenuCellC*)[array objectAtIndex:0];
            [cell awakeFromNib];
        }
        [cell setCellDetails:[listData objectAtIndex:indexPath.row]];
        return cell;
    }
    
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (cellType == SheetMenuCellTypeB){
    }else{
        [self tappedCancel];
        if(_delegate!=nil && [_delegate respondsToSelector:@selector(didSelectSheetMenuIndex:)]){
            [_delegate didSelectSheetMenuIndex:indexPath.row];
            return;
        }
    }
}




#pragma mark - cell clickevent
-(void)clickCallPhoneEvent:(NSInteger)index{
    NSLog(@"clickCallPhoneEvent :%ti",index);
    [self tappedCancel];
    if(_delegate!=nil && [_delegate respondsToSelector:@selector(callPhoneIndex:)]){
        [_delegate callPhoneIndex:index];
        return;
    }
}
-(void)clickSendMsgEvent:(NSInteger)index{
    NSLog(@"clickSendMsgEvent :%ti",index);
    [self tappedCancel];
    if(_delegate!=nil && [_delegate respondsToSelector:@selector(sendMsgIndex:)]){
        [_delegate sendMsgIndex:index];
        return;
    }
}


@end
