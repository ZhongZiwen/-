//
//  SKTDropDownMenu.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/14.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SKTDropDownMenu.h"
#import "UIView+Common.h"
#import "UIImage+Common.h"
#import "SKTSelectedBackgroundView.h"
#import "SKTCustomTitleView.h"
#import "SKTCondition.h"
#import "SKTConditionView.h"
#import "SKTFilter.h"
#import "SKTFilterValue.h"

#define kTextFont   [UIFont systemFontOfSize:14]
#define kTextNormalColor    [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]
#define kTextSelectedCplor  [UIColor colorWithRed:70/255.0 green:154/255.0 blue:233/255.0 alpha:1]
#define kSeparatorLineColor [UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1]
#define kSelectedBackgroundViewColor [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1]

#define kTag_UITableView 235124
#define kTag_UIButton   345131
#define kTag_Indicator  325324

#define kTableViewSizeHeight    240
#define kToolBarSizeHeight      44

#define kCellIdentifier   @"UITableViewCell"

@interface SKTDropDownMenu ()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate> {
    struct {
        unsigned int heightForRowIndexPath :1;
        unsigned int numberOfItemsInRow :1;
        unsigned int numberOfRowsInType :1;
        unsigned int titleForRowAtIndexPath :1;
        unsigned int sourceForItemInRowAtIndexPath :1;
    }_dataSourceFlags;
}

@property (nonatomic, strong) UIViewController *superViewController;
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) SKTCustomTitleView *customTitleView;
@property (nonatomic, strong) UITableView *smartTableView;    // 导航栏一级视图
@property (nonatomic, strong) UITableView *otherTableView;    // 左按钮一级视图
@property (nonatomic, strong) UITableView *screeningLeftTableView;    // 筛选按钮一级视图
@property (nonatomic, strong) UITableView *screeningRightTableView;   // 筛选按钮二级视图
@property (nonatomic, strong) UIToolbar *toolBar;             // 功能栏
@property (nonatomic, strong) UIView *screeningBGView;        // 筛选视图的背景图
@property (nonatomic, strong) UIScrollView *conditionScrollView;    // 条件视图

@property (nonatomic, strong) UIButton *smartButton;

@property (nonatomic, assign) SKTIndexPathType selectedType;        // 下拉菜单类别
@property (nonatomic, assign) NSInteger currentSelectedRow;         // 一级视图当前选中行

@property (nonatomic, assign) BOOL isSelected;                      // 是否有选中项

- (void)configScrollCustomView;
@end

@implementation SKTDropDownMenu

- (instancetype)initWithFrame:(CGRect)frame andViewController:(UIViewController *)controller {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _backgroundView = [[UIView alloc] initWithFrame:self.frame];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        UIGestureRecognizer *backgroundGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewHide)];
        [_backgroundView addGestureRecognizer:backgroundGes];

        _superViewController = controller;

        _menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 44.0f)];
        _menuView.backgroundColor = [UIColor whiteColor];
        [_menuView addLineUp:NO andDown:YES];
        [self addSubview:_menuView];
        
        __weak __block SKTDropDownMenu *copy_self = self;
        _customTitleView = [[SKTCustomTitleView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
        [_customTitleView animateSmartViewWithBlock:^(BOOL isShow) {
            
            // 遍历 关掉打开的视图
            for (int i = 0; i < 2; i ++) {
                UIButton *button = (UIButton*)[copy_self viewWithTag:kTag_UIButton + i];
                if (button.selected) {
                    [copy_self animateTableViewWithType:i show:NO complete:^{
                        [copy_self animateIndicatorViewWithType:i show:NO complete:^{
                        }];
                    }];
                }
            }
            
            [copy_self animateBackgroundView:copy_self.backgroundView show:isShow complete:^{
                [copy_self animateTableViewWithType:SKTIndexPathTypeSmartView show:isShow complete:^{
                }];
            }];
            
        } andTapBlock:^{
            copy_self.selectedType = SKTIndexPathTypeSmartView;
        }];
        _superViewController.navigationItem.titleView = _customTitleView;
        
        _smartTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.frame.origin.y, CGRectGetWidth(self.bounds), kTableViewSizeHeight) style:UITableViewStylePlain];
        _smartTableView.dataSource = self;
        _smartTableView.delegate = self;
        _smartTableView.tableFooterView = [[UIView alloc] init];
        [_smartTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        _smartTableView.scrollEnabled = NO;
        
        _otherTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.frame.origin.y+CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds), kTableViewSizeHeight) style:UITableViewStylePlain];
        _otherTableView.backgroundColor = [UIColor whiteColor];
        _otherTableView.delegate = self;
        _otherTableView.dataSource = self;
        _otherTableView.tableHeaderView = [[UIView alloc] init];
        [_otherTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        
        _screeningBGView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.origin.y+CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds), kTableViewSizeHeight+kToolBarSizeHeight)];
        _screeningBGView.backgroundColor = [UIColor whiteColor];
        
        _conditionScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 53.5)];
        _conditionScrollView.backgroundColor = kView_BG_Color;
        _conditionScrollView.showsHorizontalScrollIndicator = NO;
        _conditionScrollView.showsVerticalScrollIndicator = NO;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 53.5, kScreen_Width, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [_screeningBGView addSubview:line];
        
        _screeningLeftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds)*4/9.0, kTableViewSizeHeight) style:UITableViewStylePlain];
        _screeningLeftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _screeningLeftTableView.delegate = self;
        _screeningLeftTableView.dataSource = self;
        _screeningLeftTableView.tableFooterView = [[UIView alloc] init];
        [_screeningLeftTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        [_screeningBGView addSubview:_screeningLeftTableView];
        
        _screeningRightTableView = [[UITableView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds)*4/9.0, 0, CGRectGetWidth(self.bounds)*5/9.0, kTableViewSizeHeight) style:UITableViewStylePlain];
        _screeningRightTableView.backgroundColor = kSelectedBackgroundViewColor;
        _screeningRightTableView.delegate = self;
        _screeningRightTableView.dataSource = self;
        _screeningRightTableView.tableFooterView = [[UIView alloc] init];
        [_screeningRightTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        [_screeningBGView addSubview:_screeningRightTableView];
        
        UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] initWithTitle:@"重置" style:UIBarButtonItemStylePlain target:self action:@selector(resetButtonPress)];
        [resetButton setTintColor:COMMEN_LABEL_COROL];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPress)];
        [doneButton setTintColor:COMMEN_LABEL_COROL];
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, kTableViewSizeHeight, CGRectGetWidth(self.bounds), kToolBarSizeHeight)];
        _toolBar.items = @[resetButton, spaceItem, doneButton];
        [_screeningBGView addSubview:_toolBar];
        
        _currentSelectedRow = 0;
    }
    return self;
}

- (void)setDataSource:(id<SKTDropDownMenuDataSource>)dataSource {
    
    // 获取screeningRightTableView的row类型
    _searchType = [self.delegate menu:self searchTypeForItemInRow:0];
    
    if (_dataSource == dataSource)
        return;

    _dataSource = dataSource;
    
    _dataSourceFlags.heightForRowIndexPath = [_dataSource respondsToSelector:@selector(menu:heightForRowIndexPath:)];
    _dataSourceFlags.numberOfItemsInRow = [_dataSource respondsToSelector:@selector(menu:numberOfItemsInRow:)];
    _dataSourceFlags.numberOfRowsInType = [_dataSource respondsToSelector:@selector(menu:numberOfRowsInType:)];
    _dataSourceFlags.titleForRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:titleForRowAtIndexPath:)];
    _dataSourceFlags.sourceForItemInRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:sourceForItemInRowAtIndexPath:)];
    
    // 设置导航栏标题
    _customTitleView.titleString = [_dataSource menu:self titleForRowAtIndexPath:[SKTIndexPath initIndexPathWithType:SKTIndexPathTypeSmartView andRow:_smartViewSelectRow]];

    NSArray *imageArray = @[@"sort", @"filter"];
    for (int i = 0; i < 2; i ++) {
        // 获取显示menuButton的title
        NSString *string = @"";
        if (i == 0) {
            string = [_dataSource menu:self titleForRowAtIndexPath:[SKTIndexPath initIndexPathWithType:SKTIndexPathTypeOther andRow:_selectRow]];
        }else if (i == 1) {
            string = @"筛选";
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0.5*CGRectGetWidth(self.bounds)*i, 0, CGRectGetWidth(self.bounds)*0.5, CGRectGetHeight(self.menuView.bounds));
        button.tag = kTag_UIButton + i;
        button.titleLabel.font = kTextFont;
        [button setTitleColor:kTextNormalColor forState:UIControlStateNormal];
        [button setTitleColor:COMMEN_LABEL_COROL forState:UIControlStateSelected];
        [button setTitle:string forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"entity_list_%@_normal", imageArray[i]]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"entity_list_%@_select", imageArray[i]]] forState:UIControlStateSelected];
        // UIEdgeInsetsMake(<#CGFloat top#向上偏移量>, <#CGFloat left#向左偏移量>, <#CGFloat bottom#向下偏移量>, <#CGFloat right#向右上偏移量>)];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0.0, -10, 0.0, 0.0)];
        [button addTarget:self action:@selector(menuButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [_menuView addSubview:button];
        
        // indicator 三角图标
        UIImage *indicatorImage = [UIImage imageNamed:@"entity_list_arrow_normal"];
        UIImageView *indicatorImageView = [[UIImageView alloc] initWithImage:indicatorImage];
        indicatorImageView.frame = CGRectMake(button.frame.origin.x+CGRectGetWidth(button.bounds)-18-indicatorImage.size.width, (CGRectGetHeight(self.menuView.bounds)-indicatorImage.size.height)/2.0, indicatorImage.size.width, indicatorImage.size.height);
        indicatorImageView.tag = kTag_Indicator + i;
        [_menuView addSubview:indicatorImageView];
        
        // separator 分割线
        CGPoint separatorPosition = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(_menuView.bounds)/2);
        CAShapeLayer *separator = [self createSeparatorLineWithColor:[UIColor lightGrayColor] andPosition:separatorPosition];
        [_menuView.layer addSublayer:separator];
    }
}

- (CAShapeLayer *)createSeparatorLineWithColor:(UIColor *)color andPosition:(CGPoint)point {
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(160,0)];
    [path addLineToPoint:CGPointMake(160, 20)];
    
    layer.path = path.CGPath;
    layer.lineWidth = 1;
    layer.strokeColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    CGPathRelease(bound);
    layer.position = point;
    //NSLog(@"separator position: %@",NSStringFromCGPoint(point));
    //NSLog(@"separator bounds: %@",NSStringFromCGRect(layer.bounds));
    return layer;
}

#pragma mark - event response
- (void)resetButtonPress {
    if ([_delegate respondsToSelector:@selector(resetCondition)]) {
        [_delegate resetCondition];
    }
}

- (void)doneButtonPress {
    if ([_delegate respondsToSelector:@selector(confirmCondition)]) {
        [_delegate confirmCondition];
    }
}
- (void)backgroundViewHide {
    [self backgroundTap];
    if ([self.delegate respondsToSelector:@selector(afreshGetDataSourceFromServer)]) {
        [_delegate afreshGetDataSourceFromServer];
    }
}
- (void)backgroundTap {
    [self animateTableViewWithType:_selectedType show:NO complete:^{
        [self animateBackgroundView:_backgroundView show:NO complete:^{
            [self animateIndicatorViewWithType:_selectedType show:NO complete:^{
                self.customTitleView.isShow = NO;
            }];
        }];
    }];
}

- (void)menuButtonPress:(UIButton*)sender {
    
    if ((sender.tag-kTag_UIButton) == 0) {
        _selectedType = SKTIndexPathTypeOther;
        
        // 关闭打开的筛选视图
        UIButton *button = (UIButton*)[self viewWithTag:kTag_UIButton + SKTIndexPathTypeScreening];
        if (button.selected) {
            [self animateIndicatorViewWithType:SKTIndexPathTypeScreening show:NO complete:^{
                [self animateTableViewWithType:SKTIndexPathTypeScreening show:NO complete:^{
                }];
            }];
        }
        
    }else {
        _selectedType = SKTIndexPathTypeScreening;
        if ([self.delegate respondsToSelector:@selector(didSelectAction)]) {
            [_delegate didSelectAction];
        }
        // 关闭打开other视图
        UIButton *button = (UIButton*)[self viewWithTag:kTag_UIButton + SKTIndexPathTypeOther];
        if (button.selected) {
            [self animateIndicatorViewWithType:SKTIndexPathTypeOther show:NO complete:^{
                [self animateTableViewWithType:SKTIndexPathTypeOther show:NO complete:^{
                }];
            }];
        }
    }
    
    sender.selected = !sender.selected;
    
    [self animateIndicatorViewWithType:_selectedType show:sender.selected complete:^{
        [self animateTableViewWithType:_selectedType show:sender.selected complete:^{
            [self animateBackgroundView:_backgroundView show:sender.selected complete:^{
                
            }];
        }];
    }];
}

#pragma mark - public method
- (void)reloadTableView {
    [_screeningLeftTableView reloadData];
    [_screeningRightTableView reloadData];
}

- (void)setConditionArray:(NSMutableArray *)conditionArray {
    
    _conditionArray = conditionArray;
    
    [self configScrollCustomView];
}

- (void)cancelButtonPress:(UIButton*)sender {
    SKTCondition *condition = _conditionArray[sender.tag - 400];
    
    [_conditionArray removeObjectAtIndex:sender.tag - 400];

    if ([_delegate respondsToSelector:@selector(menu:deleteConditionWithItem:)]) {
        [_delegate menu:self deleteConditionWithItem:condition];
    }
    [self configScrollCustomView];
}

#pragma mark - private method
- (void)configScrollCustomView {
    if (_conditionArray.count) {
        
        for (UIView *view in _conditionScrollView.subviews) {
            [view removeFromSuperview];
        }
        
        for (int i = 0; i < _conditionArray.count; i ++) {
            SKTCondition *condition = _conditionArray[i];
            SKTConditionView *conditionView = [SKTConditionView initWithFrame:CGRectMake(5 + (44 + 5) * i, 5, 44, 44) andConditionItem:condition];
            conditionView.tag = 400 + i;
            [conditionView addTarget:self action:@selector(cancelButtonPress:) forControlEvents:UIControlEventTouchUpInside];
            [_conditionScrollView addSubview:conditionView];
        }
        [_conditionScrollView setContentSize:CGSizeMake((44 + 5)*_conditionArray.count, 53.5)];
        [self animationConditionViewWithShow:YES];
    }else {
        [self animationConditionViewWithShow:NO];
    }
}

#pragma mark - Animation Method
- (void)animateTableViewWithType:(SKTIndexPathType)type show:(BOOL)show complete:(void(^)())complete {

    if (SKTIndexPathTypeSmartView == type) {
        
        CGFloat smartTableViewHeight = 0;
        if (_dataSourceFlags.numberOfRowsInType && _dataSourceFlags.heightForRowIndexPath) {
            smartTableViewHeight = [_dataSource menu:self numberOfRowsInType:SKTIndexPathTypeSmartView] * [_dataSource menu:self heightForRowIndexPath:[SKTIndexPath initIndexPathWithType:SKTIndexPathTypeSmartView andRow:0]];
        }

        if (show) {
            CGRect frame = _smartTableView.frame;
            frame.origin.y = 64-smartTableViewHeight;
            frame.size.height = smartTableViewHeight;
            _smartTableView.frame = frame;
            [_superViewController.view addSubview:_smartTableView];
            
            frame = _smartTableView.frame;
            frame.origin.y = 64;
            [UIView animateWithDuration:0.2 animations:^{
                _smartTableView.frame = frame;
            }];
        }else {
            CGRect frame = _smartTableView.frame;
            frame.origin.y = 64-smartTableViewHeight;
            [UIView animateWithDuration:0.2 animations:^{
                _smartTableView.frame = frame;
            } completion:^(BOOL finished) {
                [_smartTableView removeFromSuperview];
            }];
        }
    }
    
    if (SKTIndexPathTypeOther == type) {
        CGFloat tableViewHeight = 0;
        if (_dataSourceFlags.numberOfRowsInType && _dataSourceFlags.heightForRowIndexPath) {
            tableViewHeight = [_dataSource menu:self numberOfRowsInType:SKTIndexPathTypeOther] * [_dataSource menu:self heightForRowIndexPath:[SKTIndexPath initIndexPathWithType:SKTIndexPathTypeOther andRow:0]];
        }
        
        if (show) {
            CGRect frame = _otherTableView.frame;
            frame.origin.y = _menuView.frame.origin.y + CGRectGetHeight(_menuView.bounds) - tableViewHeight;
            frame.size.height = tableViewHeight;
            _otherTableView.frame = frame;
            [self addSubview:_otherTableView];
            
            // 交换图层
            NSInteger indexA = [[self subviews] indexOfObject:_menuView];
            NSInteger indexB = [[self subviews] indexOfObject:_otherTableView];
            [self exchangeSubviewAtIndex:indexA withSubviewAtIndex:indexB];
            
            frame = _otherTableView.frame;
            frame.origin.y = _menuView.frame.origin.y + CGRectGetHeight(_menuView.bounds);
            [UIView animateWithDuration:0.2 animations:^{
                _otherTableView.frame = frame;
            }];
        }else {
            CGRect frame = _otherTableView.frame;
            frame.origin.y = _menuView.frame.origin.y + CGRectGetHeight(_menuView.bounds) - tableViewHeight;
            [UIView animateWithDuration:0.2 animations:^{
                _otherTableView.frame = frame;
            } completion:^(BOOL finished) {
                [_otherTableView removeFromSuperview];
            }];
        }
    }
    
    if (SKTIndexPathTypeScreening == type) {
        if (show) {
            CGRect frame = _screeningBGView.frame;
            frame.origin.y = _menuView.frame.origin.y + CGRectGetHeight(_menuView.bounds) - frame.size.height;
            _screeningBGView.frame = frame;
            [self addSubview:_screeningBGView];
            
            // 交换图层
            NSInteger indexA = [[self subviews] indexOfObject:_menuView];
            NSInteger indexB = [[self subviews] indexOfObject:_screeningBGView];
            [self exchangeSubviewAtIndex:indexA withSubviewAtIndex:indexB];
            
            frame = _screeningBGView.frame;
            frame.origin.y = _menuView.frame.origin.y + CGRectGetHeight(_menuView.bounds);
            [UIView animateWithDuration:0.2 animations:^{
                _screeningBGView.frame = frame;
            }];
        }else {
            CGRect frame = _screeningBGView.frame;
            frame.origin.y = _menuView.frame.origin.y + CGRectGetHeight(_menuView.bounds) - frame.size.height;
            [UIView animateWithDuration:0.2 animations:^{
                _screeningBGView.frame = frame;
            } completion:^(BOOL finished) {
                [_screeningBGView removeFromSuperview];
            }];
        }
    }
    
    complete();
}

- (void)animateBackgroundView:(UIView*)view show:(BOOL)show complete:(void(^)())complete {
    if (show) {
        
        [_superViewController.view bringSubviewToFront:self];
        [self addSubview:view];
        [self sendSubviewToBack:view];
        
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } completion:^(BOOL finished) {
            [_superViewController.view sendSubviewToBack:self];
            [view removeFromSuperview];
        }];
    }
    complete();
}

// 三角形标识
- (void)animateIndicatorViewWithType:(SKTIndexPathType)type show:(BOOL)show complete:(void(^)())complete {

    UIButton *button = (UIButton*)[self viewWithTag:kTag_UIButton+type];
    button.selected = show;
    UIImageView *imageView = (UIImageView*)[self viewWithTag:kTag_Indicator+type];
    if (show) {
        imageView.image = [UIImage imageNamed:@"entity_list_arrow_select"];
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
        [UIView animateWithDuration:0.2 animations:^{
            [imageView setTransform:transform];
        }];
    }else {
        imageView.image = [UIImage imageNamed:@"entity_list_arrow_normal"];
        CGAffineTransform transform = CGAffineTransformMakeRotation(0);
        [UIView animateWithDuration:0.2 animations:^{
            [imageView setTransform:transform];
        }];
    }
    complete();
}

// 条件视图
- (void)animationConditionViewWithShow:(BOOL)show {
    if (show) {
        [_screeningBGView addSubview:_conditionScrollView];
        [_screeningBGView sendSubviewToBack:_conditionScrollView];

        [UIView animateWithDuration:0.2 animations:^{
            [_screeningBGView setHeight:54 + kTableViewSizeHeight+kToolBarSizeHeight];
            [_screeningLeftTableView setY:54];
            [_screeningRightTableView setY:54];
            [_toolBar setY: kTableViewSizeHeight + 54];
        }];
    }else {
        
        [UIView animateWithDuration:0.2 animations:^{
            [_screeningLeftTableView setY:0];
            [_screeningRightTableView setY:0];
            [_toolBar setY:kTableViewSizeHeight];
            [_screeningBGView setHeight:kTableViewSizeHeight+kToolBarSizeHeight];
        } completion:^(BOOL finished) {
            for (UIView *view in _conditionScrollView.subviews) {
                [view removeFromSuperview];
            }
            [_conditionScrollView removeFromSuperview];
        }];
    }
}

#pragma mark - UITableView_Md
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_smartTableView == tableView) {
        if (_dataSourceFlags.numberOfRowsInType) {
            return [_dataSource menu:self numberOfRowsInType:SKTIndexPathTypeSmartView];
        }
    }
    
    if (_otherTableView == tableView) {
        if (_dataSourceFlags.numberOfRowsInType) {
            return [_dataSource menu:self numberOfRowsInType:SKTIndexPathTypeOther];
        }
    }
    
    if (_screeningLeftTableView == tableView) {
        if (_dataSourceFlags.numberOfRowsInType) {
            return [_dataSource menu:self numberOfRowsInType:SKTIndexPathTypeScreening];
        }
    }
    
    if (_screeningRightTableView == tableView) {
        if (_dataSourceFlags.numberOfItemsInRow) {
            if (_searchType == 3) {
                return [_dataSource menu:self numberOfItemsInRow:_currentSelectedRow] + 1;
            }
            return [_dataSource menu:self numberOfItemsInRow:_currentSelectedRow];
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_dataSourceFlags.heightForRowIndexPath) {
        return [_dataSource menu:self heightForRowIndexPath:[SKTIndexPath initIndexPathWithType:_selectedType andRow:indexPath.row]];
    }
    return 44.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_smartTableView == tableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = kTextFont;
        cell.textLabel.textColor = kTextNormalColor;
        cell.textLabel.highlightedTextColor = COMMEN_LABEL_COROL;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame] ;
        cell.selectedBackgroundView.backgroundColor = FILTER_SELECTED_BG;
        NSString *string = [_dataSource menu:self titleForRowAtIndexPath:[SKTIndexPath initIndexPathWithType:_selectedType andRow:indexPath.row]];
        cell.textLabel.text = string;
        
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame] ;
        cell.selectedBackgroundView.backgroundColor = FILTER_SELECTED_BG;
        
        if ([_customTitleView.titleString isEqualToString:string]) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        
        return cell;
    }
    
    if (_otherTableView == tableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame] ;
        cell.selectedBackgroundView.backgroundColor = FILTER_SELECTED_BG;
        cell.textLabel.font = kTextFont;
        cell.textLabel.textColor = kTextNormalColor;
        cell.textLabel.highlightedTextColor = COMMEN_LABEL_COROL;
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:nil highlightedImage:[UIImage imageNamed:@"accessory_filter_check"]];
        
        NSString *string = [_dataSource menu:self titleForRowAtIndexPath:[SKTIndexPath initIndexPathWithType:_selectedType andRow:indexPath.row]];
        cell.textLabel.text = string;
        
        if ([string isEqualToString:((UIButton*)[self viewWithTag:_selectedType+kTag_UIButton]).titleLabel.text]) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        return cell;
    }
    
    if (_screeningLeftTableView == tableView) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
        
        // 自定义selectedBackgroundView，设置颜色和加边线
        SKTSelectedBackgroundView *selectedBackgroundView = [[SKTSelectedBackgroundView alloc] init];
        selectedBackgroundView.backgroundColor = kSelectedBackgroundViewColor;
        cell.selectedBackgroundView = selectedBackgroundView;
        cell.textLabel.textColor = kTextNormalColor;
        cell.textLabel.highlightedTextColor = COMMEN_LABEL_COROL;
        cell.textLabel.font = kTextFont;
        cell.textLabel.text = [_dataSource menu:self titleForRowAtIndexPath:[SKTIndexPath initIndexPathWithType:_selectedType andRow:indexPath.row]];
        if (indexPath.row == _currentSelectedRow) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        if ([_delegate menu:self isConditionInRow:indexPath.row]) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:[UIColor orangeColor] withFrame:CGRectMake(0, 0, 8, 8)]];
            imageView.layer.cornerRadius = 4;
            imageView.clipsToBounds = YES;
            cell.accessoryView = imageView;
        }else {
            cell.accessoryView = nil;
        }
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (_searchType) {
        case 0: {   // 单选
            SKTFilterValue *valueItem = [_dataSource menu:self sourceForItemInRowAtIndexPath:[SKTIndexPath initIndexPathWithType:_selectedType andRow:_currentSelectedRow andItem:indexPath.row]];
            cell.textLabel.font = kTextFont;
            cell.textLabel.textColor = kTextNormalColor;
            cell.textLabel.text = valueItem.m_name;
            if (valueItem.isSelected) {
                cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_filter_check"]];
            }else {
                cell.accessoryView = nil;
            }
        }
            break;
        case 1: {   // 多选
            SKTFilterValue *valueItem = [_dataSource menu:self sourceForItemInRowAtIndexPath:[SKTIndexPath initIndexPathWithType:_selectedType andRow:_currentSelectedRow andItem:indexPath.row]];
            cell.textLabel.font = kTextFont;
            cell.textLabel.textColor = kTextNormalColor;
            cell.textLabel.text = valueItem.m_name;
            if (valueItem.isSelected) {
                cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"multi_graph_select"]];
            }else {
                cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_message_normal"]];
            }
        }
            break;
        case 3: {   // 自定义
            if (indexPath.row == 0) {
                cell.accessoryView = nil;
                cell.textLabel.font = kTextFont;
                cell.textLabel.textColor = COMMEN_LABEL_COROL;
                cell.textLabel.text = @"＋选择常用提交人";
            }else {
                SKTFilterValue *valueItem = [_dataSource menu:self sourceForItemInRowAtIndexPath:[SKTIndexPath initIndexPathWithType:_selectedType andRow:_currentSelectedRow andItem:indexPath.row - 1]];
                cell.textLabel.font = kTextFont;
                cell.textLabel.textColor = kTextNormalColor;
                cell.textLabel.text = valueItem.m_name;
                if (valueItem.isSelected) {
                    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"multi_graph_select"]];
                }else {
                    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_message_normal"]];
                }
            }
        }
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_smartTableView == tableView) {
        
        _currentSelectedRow = 0;
        [self.delegate menu:self smartViewDidSelectRowAtRow:indexPath.row];
        
        NSString *string = [_dataSource menu:self titleForRowAtIndexPath:[SKTIndexPath initIndexPathWithType:SKTIndexPathTypeSmartView andRow:indexPath.row]];
        _customTitleView.titleString = string;
        
        [self backgroundTap];
    }
    
    if (_otherTableView == tableView) {
        
        [self.delegate menu:self didSelectRowAtIndexPath:[SKTIndexPath initIndexPathWithType:SKTIndexPathTypeOther andRow:indexPath.row]];
        NSString *string = [_dataSource menu:self titleForRowAtIndexPath:[SKTIndexPath initIndexPathWithType:SKTIndexPathTypeOther andRow:indexPath.row]];
        
        UIButton *button = (UIButton*)[self viewWithTag:kTag_UIButton + _selectedType];
        [button setTitle:string forState:UIControlStateNormal];
        
        [self backgroundTap];
    }
    
    if (_screeningLeftTableView == tableView) {
        
        _currentSelectedRow = indexPath.row;
        
        // 获取screeningRightTableView的row类型
        _searchType = [self.delegate menu:self searchTypeForItemInRow:indexPath.row];
        
        if (_dataSourceFlags.numberOfItemsInRow) {
            [_screeningRightTableView reloadData];
        }
    }
    
    if (_screeningRightTableView == tableView) {
        [self.delegate menu:self didSelectRowAtIndexPath:[SKTIndexPath initIndexPathWithType:SKTIndexPathTypeScreening andRow:_currentSelectedRow andItem:indexPath.row]];
        
        [self reloadTableView];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end