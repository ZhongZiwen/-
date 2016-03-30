//
//  SKTFilterView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/12/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SKTFilterView.h"
#import "SelectedBackgroundView.h"
#import "FilterViewCell.h"
#import "Filter.h"
#import "FilterValue.h"
#import "FilterCondition.h"
#import "FilterConditionCCell.h"
#import "IndexCondition.h"
#import "FilterSlider.h"

#define kTextFont   [UIFont systemFontOfSize:14]
#define kTextNormalColor    [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]
#define kTextSelectedCplor  [UIColor colorWithRed:70/255.0 green:154/255.0 blue:233/255.0 alpha:1]
#define kSeparatorLineColor [UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1]
#define kSelectedBackgroundViewColor [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1]

#define kTag_UITableView 235124
#define kTag_UIButton   345131
#define kTag_Indicator  325324

#define kTableViewHeight    240
#define kFilterViewHeight   CGRectGetHeight(self.bounds)
#define kToolBarHeight      44

#define kCellIdentifier   @"UITableViewCell"
#define kCellIdentifier_right @"FilterViewCell"
#define kCCellIdentifier @"FilterConditionCCell"

@interface SKTFilterView ()<UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate> {
    struct {
        unsigned int currentSortWithFilterView :1;
        unsigned int conditionArrayWithFilterView :1;
        unsigned int numberOfRowsInType :1;
        unsigned int numberOfItemsInRow :1;
        unsigned int sourceForRowAtIndexPath :1;
    }_dataSourceFlags;
}

@property (strong, nonatomic) UIView *backgroundView;           // 背景视图（用于点击收起筛选视图）
@property (strong, nonatomic) UIView *filterBackgroundView;     // 筛选视图的背景视图
@property (strong, nonatomic) UITableView *sortView;            // 排序视图
@property (strong, nonatomic) UIView *bottomView;               // 按钮功能栏（重置、确定按钮）
@property (strong, nonatomic) UICollectionView *conditionView;  // 选中筛选视图

@property (strong, nonatomic) UIButton *addFilterButton;        // 添加筛选项
@property (strong, nonatomic) UIView *addAddressBookView;       // 添加市场活动所有人
@property (strong, nonatomic) UIButton *addAddressBookButton;

@property (strong, nonatomic) UIButton *headerViewSlider;
@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) UIImageView *accessoryImageView;
@property (strong, nonatomic) UIView *footerViewSlider;
@property (strong, nonatomic) FilterSlider *filterSlider;

@property (strong, nonatomic) Filter *rightTableViewFilter;

@property (assign, nonatomic) NSInteger selectedTag;    // 区分排序和筛选按钮

@property (assign, nonatomic) BOOL isShow;
@end

@implementation SKTFilterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kView_BG_Color;
        
        _currentSelectedRow = -1;

        // 添加分割线（按钮之间的分线）
        CGPoint separatorPosition = CGPointMake(kScreen_Width / 2, kFilterViewHeight / 2);
        CAShapeLayer *separator = [self createSeparatorLineWithColor:[UIColor lightGrayColor] andPosition:separatorPosition];
        [self.layer addSublayer:separator];
        
        // 添加底边边线
        [self.layer addSublayer:[self createHorizontalLineWithColor:[UIColor colorWithHexString:@"0xc8c7cc"] height:kFilterViewHeight]];
    }
    return self;
}

- (void)setDataSource:(id<SKTFilterViewDataSource>)dataSource {
    if (_dataSource == dataSource) {
        return;
    }
    
    _dataSource = dataSource;
    
    _dataSourceFlags.currentSortWithFilterView = [_dataSource respondsToSelector:@selector(currentSortWithFilterView:)];
    _dataSourceFlags.conditionArrayWithFilterView = [_dataSource respondsToSelector:@selector(conditionArrayWithFilterView:)];
    _dataSourceFlags.numberOfRowsInType = [_dataSource respondsToSelector:@selector(filterView:numberOfRowsInType:)];
    _dataSourceFlags.numberOfItemsInRow = [_dataSource respondsToSelector:@selector(filterView:numberOfItemsInRow:)];
    _dataSourceFlags.sourceForRowAtIndexPath = [_dataSource respondsToSelector:@selector(filterView:sourceForRowAtIndexPath:)];

    if (_dataSourceFlags.currentSortWithFilterView) {
        IndexCondition *curSort = [_dataSource currentSortWithFilterView:self];
        NSArray *imageArray = @[@"sort", @"filter"];
        for (int i = 0; i < imageArray.count; i ++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setX:i * kScreen_Width / 2];
            [button setWidth:kScreen_Width / 2];
            [button setHeight:CGRectGetHeight(self.bounds)];
            button.tag = kTag_UIButton + i;
            button.titleLabel.font = kTextFont;
            [button setTitleColor:kTextNormalColor forState:UIControlStateNormal];
            [button setTitleColor:COMMEN_LABEL_COROL forState:UIControlStateSelected];
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"entity_list_%@_normal", imageArray[i]]] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"entity_list_%@_select", imageArray[i]]] forState:UIControlStateSelected];
            [button setImageEdgeInsets:UIEdgeInsetsMake(0.0, -10, 0.0, 0.0)];
            [button addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
            if (i) {
                [button setTitle:@"筛选" forState:UIControlStateNormal];
            }else {
                [button setTitle:curSort.name forState:UIControlStateNormal];
            }
            [self addSubview:button];
            
            // indicator 三角图标
            UIImage *indicatorImage = [UIImage imageNamed:@"entity_list_arrow_normal"];
            UIImageView *indicatorImageView = [[UIImageView alloc] initWithImage:indicatorImage];
            [indicatorImageView setX:CGRectGetMaxX(button.frame) - 18 - indicatorImage.size.width];
            [indicatorImageView setWidth:indicatorImage.size.width];
            [indicatorImageView setHeight:indicatorImage.size.height];
            [indicatorImageView setCenterY:kFilterViewHeight / 2];
            indicatorImageView.tag = kTag_Indicator + i;
            [self addSubview:indicatorImageView];
        }
    }
    
    if (_dataSourceFlags.conditionArrayWithFilterView) {
        NSArray *conditionArray = [_dataSource conditionArrayWithFilterView:self];
        _conditionCount = conditionArray.count;
        if (conditionArray && conditionArray.count) {
            [self addSubview:self.conditionView];
            [self setHeight:CGRectGetHeight(self.bounds) + CGRectGetHeight(_conditionView.bounds)];
            [_conditionView setY:44];
        }
        else {
            [_conditionView removeFromSuperview];
            [self setHeight:44.0f];
        }
    }
    
    // 改变父视图tableView坐标
    [_delegate changeTableViewFrameWithFilterView:self];
}

#pragma mark - event response
- (void)buttonPress:(UIButton*)sender {
    
    // 排序按钮
    if (sender.tag == kTag_UIButton) {
        _selectedTag = 0;

        UIButton *filterButton = (UIButton*)[self viewWithTag:kTag_UIButton + 1];
        if (filterButton.selected) {
            [self animateIndicatorViewWithTag:1 show:NO complete:^{
                [self animateTableViewWithTag:1 show:NO complete:^{
                    
                }];
            }];
        }
    }
    else {
        _selectedTag = 1;

        // 关闭打开的排序视图
        UIButton *sortButton = (UIButton*)[self viewWithTag:kTag_UIButton];
        if (sortButton.selected) {
            [self animateIndicatorViewWithTag:0 show:NO complete:^{
                [self animateTableViewWithTag:0 show:NO complete:^{
                    
                }];
            }];
        }
    }
    
    sender.selected = !sender.selected;

    [self animateIndicatorViewWithTag:_selectedTag show:sender.selected complete:^{
        [self animateTableViewWithTag:_selectedTag show:sender.selected complete:^{
            [self animateBackgroundViewWithTag:_selectedTag show:sender.selected complete:^{
                
            }];
        }];
    }];
}

- (void)backgroundTap {
    [self animateTableViewWithTag:_selectedTag show:NO complete:^{
        [self animateBackgroundViewWithTag:_selectedTag show:NO complete:^{
            [self animateIndicatorViewWithTag:_selectedTag show:NO complete:^{
                
            }];
        }];
    }];
}

- (void)headerViewSliderBtnPress {
    
    NSMutableArray *indexPathArray = [NSMutableArray arrayWithCapacity:_rightTableViewFilter.valuesArray.count];
    for (int i = 0; i < _rightTableViewFilter.valuesArray.count; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPathArray addObject:indexPath];
    }
    
    if (_rightTableViewFilter.isExpand) { // 关闭展开
        _rightTableViewFilter.isExpand = NO;
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(0);
        [UIView animateWithDuration:0.2 animations:^{
            [_accessoryImageView setTransform:transform];
        }];
        
        [_filterRightView beginUpdates];
        [_filterRightView deleteRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationAutomatic];
        [_filterRightView endUpdates];
        
        _filterRightView.tableFooterView = self.footerViewSlider;
        // 配置slider的thumb坐标
        [_filterSlider configWithLeftValue:_rightTableViewFilter.leftValue rightValue:_rightTableViewFilter.rightValue];
        
    }else {
        _rightTableViewFilter.isExpand = YES;
        _filterRightView.tableFooterView = [[UIView alloc] init];
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
        [UIView animateWithDuration:0.2 animations:^{
            [_accessoryImageView setTransform:transform];
        }];
        
        [_filterRightView beginUpdates];
        [_filterRightView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationAutomatic];
        [_filterRightView endUpdates];
    }
}

- (void)addFilterButtonPress {
    _currentSelectedRow = -1;
    [_delegate addFilterItemWithFilterView:self];
}

- (void)resetButtonPress {
    // 改变数据源
    NSArray *conditionArray = [_dataSource conditionArrayWithFilterView:self];
    for (FilterCondition *tempCondition in conditionArray) {
        Filter *tempFilter = [_delegate filterView:self filterItemAtId:tempCondition.itemId];
        switch ([tempFilter.searchType integerValue]) {
            case 0: {   // 单选
                tempFilter.isCondition = NO;
                for (int i = 0; i < tempFilter.valuesArray.count; i ++) {
                    FilterValue *tempValue = tempFilter.valuesArray[i];
                    if (i == 0) {
                        tempValue.isSelected = YES;
                    }else if (tempValue.isSelected) {
                        tempValue.isSelected = NO;
                        break;
                    }
                }
            }
                break;
            case 1:
            case 3: {   // 多选
                for (FilterValue *tempValue in tempFilter.valuesArray) {
                    if ([tempValue.id isEqualToString:tempCondition.value]) {
                        tempValue.isSelected = NO;
                        break;
                    }
                }
                
                // 决定filter是否存在被选条件
                tempFilter.isCondition = NO;
                for (FilterValue *tempValue in tempFilter.valuesArray) {
                    if (tempValue.isSelected) {
                        tempFilter.isCondition = YES;
                        break;
                    }
                }
                
                // 多选类型，第一行加上标识，选择员工则不用
                if (!tempFilter.isCondition && [tempFilter.searchType integerValue] == 1) {
                    FilterValue *firstFilter = tempFilter.valuesArray.firstObject;
                    firstFilter.isSelected = YES;
                }
                
            }
                break;
            case 4: {   // 浮点
                tempFilter.isCondition = NO;
                tempFilter.leftValue = 0;
                tempFilter.rightValue = 5;
            }
            default:
                break;
        }
    }
    
    // 清空数组
    [_delegate removeAllConditionItemsWithFilterView:self];
    
    self.conditionCount = 0;
    
    [_filterLeftView reloadData];
    [_filterRightView reloadData];
}

- (void)confireButtonPress {
    NSMutableArray *jsonArray = [NSMutableArray arrayWithCapacity:0];
    for (FilterCondition *tempItem in [_dataSource conditionArrayWithFilterView:self]) {
        BOOL isExist = NO;
        for (NSMutableDictionary *tempDict in jsonArray) {
            if ([tempDict[@"field"] isEqualToString:tempItem.itemId]) {
                isExist = YES;
                NSString *string = [NSString stringWithFormat:@"%@,%@", tempDict[@"value"], tempItem.value];
                [tempDict setObject:string forKey:@"value"];
                break;
            }
        }
        
        if (!isExist) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:tempItem.columnType forKey:@"columnType"];
            [dict setObject:tempItem.itemId forKey:@"field"];
            [dict setObject:tempItem.itemSearchType forKey:@"selectType"];
            [dict setObject:tempItem.value forKey:@"value"];
            [jsonArray addObject:dict];
        }
    }
    
    [self backgroundTap];
    
    if (!jsonArray.count) {
        [_delegate filterView:self conditionJsonArray:nil];
        return;
    }
    
    [_delegate filterView:self conditionJsonArray:jsonArray];
}

- (void)addAddressBookButtonPress:(UIButton*)sender {
    if ([_delegate respondsToSelector:@selector(filterView:addAddressBookAtCurIndex:)]) {
        [_delegate filterView:self addAddressBookAtCurIndex:_currentSelectedRow];
    }
}

- (void)sliderValueChanged:(FilterSlider*)sender {
    
    FilterValue *value = [_delegate filterView:self sliderValueAtCurrentSelectedRow:_currentSelectedRow];
    NSInteger unit = 0;
    NSString *unitName;
    NSString *sliderValue;
    NSString *sliderValueName;
    switch ([value.id integerValue]) {
        case 0: {
            unit = 1000;
            unitName = @"千";
        }
            break;
        case 1: {
            unit = 10000;
            unitName = @"万";
        }
            break;
        case 2: {
            unit = 100000;
            unitName = @"十万";
        }
            break;
        case 3: {
            unit = 1000000;
            unitName = @"百万";
        }
            break;
        default:
            break;
    }
    
    if (sender.rightValue == 5) {
        sliderValue = [NSString stringWithFormat:@"%ld", [sender.leftValueTitle integerValue] * unit];
        sliderValueName = [NSString stringWithFormat:@"%@%@-%@", sender.leftValueTitle, unitName, sender.rightValueTitle];
    }else if (sender.leftValue == 0) {
        sliderValue = [NSString stringWithFormat:@"0,%ld", [sender.rightValueTitle integerValue] * unit];
        sliderValueName = [NSString stringWithFormat:@"0-%@%@", sender.rightValueTitle, unitName];
    }else {
        sliderValue = [NSString stringWithFormat:@"%ld,%ld", [sender.leftValueTitle integerValue] * unit, [sender.rightValueTitle integerValue] * unit];
        sliderValueName = [NSString stringWithFormat:@"%@%@-%@%@", sender.leftValueTitle, unitName, sender.rightValueTitle, unitName];
    }
    
    _rightTableViewFilter.leftValue = sender.leftValue;
    _rightTableViewFilter.rightValue = sender.rightValue;

    FilterCondition *condition = [[FilterCondition alloc] init];
    condition.itemId = _rightTableViewFilter.id;
    condition.itemName = _rightTableViewFilter.itemName;
    condition.itemSearchType = _rightTableViewFilter.searchType;
    condition.columnType = _rightTableViewFilter.columnType;
    condition.value = sliderValue;
    condition.valueName = sliderValueName;
    condition.sliderValueId = value.id;
    condition.sliderLeftValue = @(sender.leftValue);
    condition.sliderRightValue = @(sender.rightValue);

    if (!sender.leftValue && sender.rightValue == 5) {
        _rightTableViewFilter.isCondition = NO;
        [self deleteConditionItem:condition];
    }else {
        _rightTableViewFilter.isCondition = YES;
        [self addConditionItem:condition];
    }
    
    [_filterLeftView reloadData];
}

#pragma mark - Animation Method
// 三角形标识
- (void)animateIndicatorViewWithTag:(NSInteger)tag show:(BOOL)show complete:(void(^)())complete {
    
    UIButton *button = (UIButton*)[self viewWithTag:kTag_UIButton+tag];
    button.selected = show;
    UIImageView *imageView = (UIImageView*)[self viewWithTag:kTag_Indicator+tag];
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

- (void)animateTableViewWithTag:(NSInteger)tag show:(BOOL)show complete:(void(^)())complete {
    
    if (tag == 0) {   // 排序tableview
        CGFloat tableViewHeight = 0;
        if (_dataSourceFlags.numberOfRowsInType) {
            tableViewHeight = [_dataSource filterView:self numberOfRowsInType:FilterTypeSort] * 44.0f;
        }
        
        if (show) {
            [self.superview insertSubview:self.sortView belowSubview:self];
            
            [_sortView setY:CGRectGetMaxY(self.frame) - tableViewHeight];
            [_sortView setHeight:tableViewHeight];
            [UIView animateWithDuration:0.2 animations:^{
                [_sortView setY:CGRectGetMaxY(self.frame)];
            }];
        }else {
            [UIView animateWithDuration:0.2 animations:^{
                [_sortView setY:CGRectGetMaxY(self.frame) - tableViewHeight];
            } completion:^(BOOL finished) {
                [_sortView removeFromSuperview];
            }];
        }
        
        complete();
        return;
    }
    
    if (show) {
        [self.superview insertSubview:self.filterBackgroundView belowSubview:self];
        
        [_filterBackgroundView setY:CGRectGetMaxY(self.frame) - CGRectGetHeight(_filterBackgroundView.bounds)];
        [UIView animateWithDuration:0.2 animations:^{
            [_filterBackgroundView setY:CGRectGetMaxY(self.frame)];
        } completion:^(BOOL finished) {
            _isShow = YES;
        }];
    }else {
        [UIView animateWithDuration:0.2 animations:^{
            [_filterBackgroundView setY:CGRectGetMaxY(self.frame) - CGRectGetHeight(_filterBackgroundView.bounds)];
        } completion:^(BOOL finished) {
            [_filterBackgroundView removeFromSuperview];
            _isShow = NO;
        }];
    }
    complete();
}

- (void)animateBackgroundViewWithTag:(NSInteger)tag show:(BOOL)show complete:(void(^)())complete {
    if (show) {
        [self.superview insertSubview:self.backgroundView belowSubview:(tag ? _filterBackgroundView : _sortView)];
        [UIView animateWithDuration:0.2 animations:^{
            _backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        }];
    }else {
        [UIView animateWithDuration:0.2 animations:^{
            _backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } completion:^(BOOL finished) {
            [_backgroundView removeFromSuperview];
        }];
    }
    complete();
}

// 显示或隐藏条件视图
- (void)animationConditionViewWithShow:(BOOL)show {
    if (show) {
        
        [self addSubview:self.conditionView];
        _conditionView.hidden = YES;
        [_conditionView setY:44.0f];
        
        [UIView animateWithDuration:0.2 animations:^{
            _conditionView.hidden = NO;
            [self setHeight:44.0f + CGRectGetHeight(_conditionView.bounds)];
            [_filterBackgroundView setY:CGRectGetMaxY(self.frame)];
            
            [_delegate changeTableViewFrameWithFilterView:self];
        }];
        
    }else {
        [UIView animateWithDuration:0.2 animations:^{
            
            [self setHeight:44];
            _conditionView.hidden = YES;
            [_filterBackgroundView setY:CGRectGetMaxY(self.frame)];
            
            [_delegate changeTableViewFrameWithFilterView:self];
            
        } completion:^(BOOL finished) {
            
            [_conditionView removeFromSuperview];
        }];
    }
}

#pragma mark - public method
- (void)reloadRightTableView {
    [self.filterRightView reloadData];
    
    _rightTableViewFilter = [_dataSource filterView:self sourceForRowAtIndexPath:[FilterIndexPath initIndexPathWithType:FilterTypeConditionLeft row:_currentSelectedRow]];
}

#pragma mark - private method
- (CAShapeLayer*)createHorizontalLineWithColor:(UIColor*)color height:(CGFloat)height {
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(0, height - 0.5)];
    [path addLineToPoint:CGPointMake(kScreen_Width, height - 0.5)];
    
    layer.path = path.CGPath;
    layer.lineWidth = 0.5;
    layer.strokeColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    CGPathRelease(bound);
    layer.position = CGPointMake(kScreen_Width / 2, height - 0.5 + 0.25);
    return layer;
}

- (CAShapeLayer*)createSeparatorLineWithColor:(UIColor *)color andPosition:(CGPoint)point {
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(0,0)];
    [path addLineToPoint:CGPointMake(0, 20)];
    
    layer.path = path.CGPath;
    layer.lineWidth = 1;
    layer.strokeColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    CGPathRelease(bound);
    layer.position = point;
    return layer;
}

- (void)addConditionItem:(FilterCondition*)item {
    [_delegate filterView:self addConditionItem:item];
    
    self.conditionCount = [_dataSource conditionArrayWithFilterView:self].count;
}

- (void)deleteConditionItem:(FilterCondition*)item {
    NSArray *conditionArray = [_dataSource conditionArrayWithFilterView:self];
    switch ([item.itemSearchType integerValue]) {
        case 0: {   // 单选
            for (int i = 0; i < conditionArray.count; i ++) {
                FilterCondition *tempCondition = conditionArray[i];
                if ([item.itemId isEqualToString:tempCondition.itemId]) {
                    [_delegate filterView:self deleteConditionItemAtIndex:i];
                    break;
                }
            }
        }
            break;
        case 1:
        case 3: {
            for (int i = 0; i < conditionArray.count; i ++) {
                FilterCondition *tempCondition = conditionArray[i];
                if ([item.itemId isEqualToString:tempCondition.itemId] && [item.value isEqualToString:tempCondition.value]) {
                    [_delegate filterView:self deleteConditionItemAtIndex:i];
                    break;
                }
            }
        }
            break;
        case 4: {
            for (int i = 0; i < conditionArray.count; i ++) {
                FilterCondition *tempCondition = conditionArray[i];
                if ([item.itemId isEqualToString:tempCondition.itemId]) {
                    [_delegate filterView:self deleteConditionItemAtIndex:i];
                    break;
                }
            }
        }
        default:
            break;
    }
    
    self.conditionCount = [_dataSource conditionArrayWithFilterView:self].count;
}

- (void)addAndDeleteConditionWithItem:(FilterCondition*)conditionItem {
    
    NSArray *conditionArray = [_dataSource conditionArrayWithFilterView:self];
    
    switch ([conditionItem.itemSearchType integerValue]) {
        case 0: {   // 单选
            // 因为是单选，先检查条件数组中是否存在单选项，有就先删除
            for (int i = 0; i < conditionArray.count; i ++) {
                FilterCondition *tempCondition = conditionArray[i];
                if ([tempCondition.itemId isEqualToString:conditionItem.itemId]) {
                    [_delegate filterView:self deleteConditionItemAtIndex:i];
                    break;
                }
            }
            
            // 单选不限的value = nil
            if (conditionItem.value) {
                [_delegate filterView:self addConditionItem:conditionItem];
            }
        }
            break;
        case 1:
        case 3: {   // 多选和选择员工
            int selectedIndex = -1;
            for (int i = 0; i < conditionArray.count; i ++) {
                FilterCondition *tempCondition = conditionArray[i];
                if ([tempCondition.itemId isEqualToString:conditionItem.itemId] && [tempCondition.value isEqualToString:conditionItem.value]) {
                    selectedIndex = i;
                    [_delegate filterView:self deleteConditionItemAtIndex:i];
                    break;
                }
            }
            
            if (selectedIndex == -1) {
                [_delegate filterView:self addConditionItem:conditionItem];
            }
        }
            break;
        case 4: {   // 浮点
            // 判断是否有该类型数据
            int selectedIndex = -1;
            for (int i = 0; i < conditionArray.count; i ++) {
                FilterCondition *tempCondition = conditionArray[i];
                if ([tempCondition.itemId isEqualToString:conditionItem.itemId]) {
                    selectedIndex = i;
                    if (conditionItem.value) {
                        tempCondition.value = conditionItem.value;
                        tempCondition.valueName = conditionItem.valueName;
                    }else {
                        _rightTableViewFilter.isCondition = NO;
                        [_delegate filterView:self deleteConditionItemAtIndex:i];
                    }
                    break;
                }
            }
            
            // 如果值还是等于-1，说明condition数据中没有该类型数据
            if (selectedIndex == -1 && conditionItem.value) {
                _rightTableViewFilter.isCondition = YES;
                [_delegate filterView:self addConditionItem:conditionItem];
            }
            
            [_filterLeftView reloadData];
        }
            break;
        default:
            break;
    }
    
    self.conditionCount = [_dataSource conditionArrayWithFilterView:self].count;
}

- (void)reloadTableView {
    [_filterLeftView reloadData];
    [_filterRightView reloadData];
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _sortView) {
        return [_dataSource filterView:self numberOfRowsInType:FilterTypeSort];
    }
    
    if (tableView == _filterLeftView) {
        return [_dataSource filterView:self numberOfRowsInType:FilterTypeConditionLeft];
    }
    
    if (tableView == _filterRightView) {
        return [_dataSource filterView:self numberOfItemsInRow:_currentSelectedRow];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _filterRightView) {
        
        FilterViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_right forIndexPath:indexPath];
        if ([_rightTableViewFilter.searchType integerValue] == 3) { // 选择员工
            AddressBook *bookItem = [_dataSource filterView:self sourceForRowAtIndexPath:[FilterIndexPath initIndexPathWithType:FilterTypeConditionRight row:_currentSelectedRow item:indexPath.row]];
            [cell configWithModel:bookItem];
        }else { // 非选择员工
            FilterValue *filterValue = [_dataSource filterView:self sourceForRowAtIndexPath:[FilterIndexPath initIndexPathWithType:FilterTypeConditionRight row:_currentSelectedRow item:indexPath.row]];
            [cell configWithSearchType:[_rightTableViewFilter.searchType integerValue] model:filterValue row:indexPath.row];
        }
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.textLabel.font = kTextFont;
    cell.textLabel.textColor = kTextNormalColor;
    cell.textLabel.highlightedTextColor = COMMEN_LABEL_COROL;//[UIColor iOS7lightBlueColor];
    
    // 顺序视图
    if (tableView == _sortView) {
        IndexCondition *curSort = [_dataSource currentSortWithFilterView:self];
        NSString *str = [_dataSource filterView:self sourceForRowAtIndexPath:[FilterIndexPath initIndexPathWithType:FilterTypeSort row:indexPath.row]];
        if ([str isEqualToString:curSort.name]) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame] ;
        cell.selectedBackgroundView.backgroundColor = FILTER_SELECTED_BG;
        cell.textLabel.text = str;
    }else if (tableView == _filterLeftView) {
        // 自定义selectedBackgroundView，设置颜色和加边线
        SelectedBackgroundView *cellSelectedBGView = [[SelectedBackgroundView alloc] init];
        cellSelectedBGView.backgroundColor = FILTER_SELECTED_BG;
        cell.selectedBackgroundView = cellSelectedBGView;
        Filter *filterItem = [_dataSource filterView:self sourceForRowAtIndexPath:[FilterIndexPath initIndexPathWithType:FilterTypeConditionLeft row:indexPath.row]];
        cell.textLabel.text = filterItem.itemName;
        if (filterItem.isCondition) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:[UIColor orangeColor] withFrame:CGRectMake(0, 0, 8, 8)]];
            imageView.layer.cornerRadius = 4;
            imageView.clipsToBounds = YES;
            cell.accessoryView = imageView;
        }else {
            cell.accessoryView = nil;
        }
        if (indexPath.row == _currentSelectedRow) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _sortView) {
        [_delegate filterView:self sortViewDidSelectedAtRow:indexPath.row];
        NSString *string = [_dataSource filterView:self sourceForRowAtIndexPath:[FilterIndexPath initIndexPathWithType:FilterTypeSort row:indexPath.row]];
        UIButton *button = (UIButton*)[self viewWithTag:kTag_UIButton];
        [button setTitle:string forState:UIControlStateNormal];
        
        [self backgroundTap];
        return;
    }
    
    if (tableView == _filterLeftView) {
        self.currentSelectedRow = indexPath.row;
        return;
    }
    
    switch ([_rightTableViewFilter.searchType integerValue]) {
        case 0: {   // 单选
            FilterValue *selectedValue = _rightTableViewFilter.valuesArray[indexPath.row];
            if (selectedValue.isSelected) {
                return;
            }
            
            if (indexPath.row == 0) {
                for (FilterValue *tempValue in _rightTableViewFilter.valuesArray) {
                    if (tempValue.isSelected) {
                        tempValue.isSelected = NO;
                        [self deleteConditionItem:[FilterCondition initWithFilter:_rightTableViewFilter filterValue:tempValue]];
                        break;
                    }
                }
                
                FilterValue *firstValue = _rightTableViewFilter.valuesArray.firstObject;
                firstValue.isSelected = YES;
                _rightTableViewFilter.isCondition = NO;
                break;
            }
            
            for (FilterValue *tempValue in _rightTableViewFilter.valuesArray) {
                tempValue.isSelected = NO;
            }
            _rightTableViewFilter.isCondition = YES;
            selectedValue.isSelected = YES;
            [self addConditionItem:[FilterCondition initWithFilter:_rightTableViewFilter filterValue:selectedValue]];
        }
            break;
        case 1: {   // 多选
            if (indexPath.row == 0) {   // 点击第0行时
                FilterValue *firstValue = _rightTableViewFilter.valuesArray.firstObject;
                if (firstValue.isSelected) {
                    return;
                }
                
                for (FilterValue *tempValue in _rightTableViewFilter.valuesArray) {
                    if (tempValue.isSelected) {
                        tempValue.isSelected = NO;
                        [self deleteConditionItem:[FilterCondition initWithFilter:_rightTableViewFilter filterValue:tempValue]];
                    }
                }
                
                _rightTableViewFilter.isCondition = NO;
                firstValue.isSelected = YES;
                
            }else {
                
                FilterValue *selectedValue = _rightTableViewFilter.valuesArray[indexPath.row];
                FilterCondition *condition = [FilterCondition initWithFilter:_rightTableViewFilter filterValue:selectedValue];
                if (selectedValue.isSelected) {
                    selectedValue.isSelected = NO;
                    [self deleteConditionItem:condition];
                }else {
                    selectedValue.isSelected = YES;
                    [self addConditionItem:condition];
                }
                
                // 检测是否还有选定项，如果没有，则改变第0行状态
                BOOL isCondition = NO;
                for (FilterValue *tempValue in _rightTableViewFilter.valuesArray) {
                    if (tempValue.isSelected) {
                        isCondition = YES;
                        break;
                    }else {
                        isCondition = NO;
                    }
                }
                
                selectedValue = _rightTableViewFilter.valuesArray.firstObject;
                if (isCondition) {
                    selectedValue.isSelected = NO;
                }else {
                    selectedValue.isSelected = YES;
                }
                _rightTableViewFilter.isCondition = isCondition;
            }
        }
            break;
        case 3: {   // 员工
            // 选择员工，就没有所谓的点击第一行全部取消条件
            FilterValue *selectedValue = _rightTableViewFilter.valuesArray[indexPath.row];
            FilterCondition *condition = [FilterCondition initWithFilter:_rightTableViewFilter filterValue:selectedValue];
            if (selectedValue.isSelected) {
                selectedValue.isSelected = NO;
                [self deleteConditionItem:condition];
            }else {
                selectedValue.isSelected = YES;
                [self addConditionItem:condition];
            }
            
            // 检测是否还有选定项，如果没有，则改变第0行状态
            BOOL isCondition = NO;
            for (FilterValue *tempValue in _rightTableViewFilter.valuesArray) {
                if (tempValue.isSelected) {
                    isCondition = YES;
                    break;
                }else {
                    isCondition = NO;
                }
            }
            _rightTableViewFilter.isCondition = isCondition;
        }
            break;
        case 4: {   // 浮点
            for (FilterValue *tempValue in _rightTableViewFilter.valuesArray) {
                tempValue.isSelected = NO;
            }
            
            FilterValue *selectedValue = _rightTableViewFilter.valuesArray[indexPath.row];
            selectedValue.isSelected = YES;
            _headerLabel.text = selectedValue.name;
            [_filterSlider sendActionsForControlEvents:UIControlEventValueChanged];
//            for (int i = 0; i < _rightTableViewFilter.valuesArray.count; i ++) {
//                FilterValue *valueItem = _rightTableViewFilter.valuesArray[i];
//                if (i == indexPath.row) {
//                    valueItem.isSelected = YES;
//                    _headerLabel.text = valueItem.name;
//                    _filterSlider.valueId = valueItem.id;
//                    [_filterSlider configValue];
//                }else {
//                    valueItem.isSelected = NO;
//                }
//            }
            
            [self headerViewSliderBtnPress];
        }
        default:
            break;
    }
    
    [self reloadTableView];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_dataSourceFlags.conditionArrayWithFilterView) {
        return [_dataSource conditionArrayWithFilterView:self].count;
    }
    return 0;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FilterConditionCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier forIndexPath:indexPath];
    NSArray *conditionArray = [_dataSource conditionArrayWithFilterView:self];
    FilterCondition *model = conditionArray[indexPath.row];
    [cell configWithModel:model];
    return cell;
}

#pragma mark - UICollectionViewDelegate
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *conditionArray = [_dataSource conditionArrayWithFilterView:self];
    FilterCondition *model = conditionArray[indexPath.row];
    CGFloat titleWidth = [model.itemName getWidthWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT, 20)];
    CGFloat detailWidth = [model.valueName getWidthWithFont:[UIFont systemFontOfSize:11] constrainedToSize:CGSizeMake(MAXFLOAT, 20)];
    
    CGFloat maxWidth = MAX(titleWidth, detailWidth);
    
    return CGSizeMake(maxWidth, 44);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!_isShow) {
        return;
    }
    
    NSArray *conditionArray = [_dataSource conditionArrayWithFilterView:self];
    // 找到要删除的该条件
    FilterCondition *condition = conditionArray[indexPath.row];
    // 从条件数组中删除数据
    [_delegate filterView:self deleteConditionItemAtIndex:indexPath.row];
    
    _conditionCount = [_dataSource conditionArrayWithFilterView:self].count;
    
    // 关闭collectionview
    if (![_dataSource conditionArrayWithFilterView:self].count) {
        [self animationConditionViewWithShow:NO];
    }
    
    // 改变数据源
    Filter *tempFilter = [_delegate filterView:self filterItemAtId:condition.itemId];
    
    switch ([tempFilter.searchType integerValue]) {
        case 0: {   // 单选
            tempFilter.isCondition = NO;
            for (int i = 0; i < tempFilter.valuesArray.count; i ++) {
                FilterValue *tempValue = tempFilter.valuesArray[i];
                if (i == 0) {
                    tempValue.isSelected = YES;
                }else if (tempValue.isSelected) {
                    tempValue.isSelected = NO;
                    break;
                }
            }
        }
            break;
        case 1:
        case 3: {   // 多选
            for (FilterValue *tempValue in tempFilter.valuesArray) {
                if ([tempValue.id isEqualToString:condition.value]) {
                    tempValue.isSelected = NO;
                    break;
                }
            }
            
            // 决定filter是否存在被选条件
            tempFilter.isCondition = NO;
            for (FilterValue *tempValue in tempFilter.valuesArray) {
                if (tempValue.isSelected) {
                    tempFilter.isCondition = YES;
                    break;
                }
            }
            
            // 多选类型，第一行加上标识，选择员工则不用
            if (!tempFilter.isCondition && [tempFilter.searchType integerValue] == 1) {
                FilterValue *firstFilter = tempFilter.valuesArray.firstObject;
                firstFilter.isSelected = YES;
            }
            
        }
            break;
        case 4: {   // 浮点
            tempFilter.isCondition = NO;
            tempFilter.leftValue = 0;
            tempFilter.rightValue = 5;
        }
        default:
            break;
    }
    
    [_filterLeftView reloadData];
    [_filterRightView reloadData];
    
    // 直接将cell删除
    [_conditionView deleteItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - setters and getters
- (void)setCurrentSelectedRow:(NSInteger)currentSelectedRow {
    if (_currentSelectedRow == currentSelectedRow)
        return;
    
    if (_currentSelectedRow == -1) {
        [self.filterLeftView reloadData];
    }
    
    _currentSelectedRow = currentSelectedRow;
    
    _rightTableViewFilter = [_dataSource filterView:self sourceForRowAtIndexPath:[FilterIndexPath initIndexPathWithType:FilterTypeConditionLeft row:_currentSelectedRow]];
    
    if ([_rightTableViewFilter.searchType integerValue] == 3) {
        self.filterRightView.tableHeaderView = self.addAddressBookView;
        [_addAddressBookButton setTitle:[NSString stringWithFormat:@"+选择常用%@", _rightTableViewFilter.itemName] forState:UIControlStateNormal];
        
        if ([_rightTableViewFilter.valuesArray count]) {
            self.filterRightView.tableFooterView = [[UIView alloc] init];
        }else {
            
            self.filterRightView.tableFooterView = self.addAddressBookFootView;
            
            NSString *str = [NSString stringWithFormat:@"您可以添加常用的%@，以便以后快速选择", _rightTableViewFilter.itemName];
            CGFloat height = [str getHeightWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(CGRectGetWidth(self.filterRightView.bounds), CGFLOAT_MAX)];
            
            _addAddressBookFootLabel.text = str;
            [_addAddressBookFootLabel setHeight:height];
            [_addAddressBookFootView setHeight:height];
        }
    }else if ([_rightTableViewFilter.searchType integerValue] == 4) {
        
        self.filterRightView.tableHeaderView = self.headerViewSlider;
        
        FilterValue *value = [_delegate filterView:self sliderValueAtCurrentSelectedRow:_currentSelectedRow];
        _headerLabel.text = value.name;
        
        if (_rightTableViewFilter.isExpand) { // 展开
            
            _filterRightView.tableFooterView = [[UIView alloc] init];
            
            CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
            [_accessoryImageView setTransform:transform];
            
        }else {
            CGAffineTransform transform = CGAffineTransformMakeRotation(0);
            [_accessoryImageView setTransform:transform];
            
            _filterRightView.tableFooterView = self.footerViewSlider;
            // 配置slider的thumb坐标
            [_filterSlider configWithLeftValue:_rightTableViewFilter.leftValue rightValue:_rightTableViewFilter.rightValue];
        }
        
    }else {
        self.filterRightView.tableHeaderView = nil;
        self.filterRightView.tableFooterView = [[UIView alloc] init];
    }
    
    [self.filterRightView reloadData];
}

- (void)setConditionCount:(NSInteger)conditionCount {
    // FilterSlider已经在0或不限时，还往边上滑动，为了防止改变tableview的frame
    if (!_conditionCount && _conditionCount == conditionCount) {
        return;
    }
    
    if (!conditionCount) {  // 为0的时候
        _conditionCount = conditionCount;
        [self animationConditionViewWithShow:NO];
        return;
    }
    
    [self.conditionView reloadData];
    
    if (!_conditionCount) {
        [self animationConditionViewWithShow:YES];
    }
    
    _conditionCount = conditionCount;
}

- (UIView*)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        [_backgroundView setY:64 + kFilterViewHeight];
        [_backgroundView setWidth:kScreen_Width];
        [_backgroundView setHeight:kScreen_Height - 64 - kFilterViewHeight];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        
        UIGestureRecognizer *backgroundGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap)];
        [_backgroundView addGestureRecognizer:backgroundGes];
    }
    return _backgroundView;
}

- (UIView*)filterBackgroundView {
    if (!_filterBackgroundView) {
        _filterBackgroundView = [[UIView alloc] init];
        [_filterBackgroundView setWidth:kScreen_Width];
        [_filterBackgroundView setHeight:kTableViewHeight + kToolBarHeight];
        _filterBackgroundView.backgroundColor = [UIColor whiteColor];
        
        [_filterBackgroundView addSubview:self.filterLeftView];
        [_filterBackgroundView addSubview:self.filterRightView];
        [_filterBackgroundView addSubview:self.bottomView];
    }
    return _filterBackgroundView;
}

- (UITableView*)sortView {
    if (!_sortView) {
        _sortView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_sortView setWidth:kScreen_Width];
        _sortView.backgroundColor = [UIColor whiteColor];
        _sortView.dataSource = self;
        _sortView.delegate = self;
        _sortView.tableFooterView = [[UIView alloc] init];
        [_sortView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        _sortView.scrollEnabled = NO;
    }
    return _sortView;
}

- (UITableView*)filterLeftView {
    if (!_filterLeftView) {
        _filterLeftView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_filterLeftView setWidth:kScreen_Width * 4 / 9.0];
        [_filterLeftView setHeight:kTableViewHeight];
        _filterLeftView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _filterLeftView.delegate = self;
        _filterLeftView.dataSource = self;
        _filterLeftView.tableFooterView = self.addFilterButton;
        [_filterLeftView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    }
    return _filterLeftView;
}

- (UIButton*)addFilterButton {
    if (!_addFilterButton) {
        _addFilterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addFilterButton setWidth:CGRectGetWidth(_filterLeftView.bounds)];
        [_addFilterButton setHeight:44];
        [_addFilterButton addTarget:self action:@selector(addFilterButtonPress) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *label = [[UILabel alloc] init];
        [label setX:15];
        [label setWidth:CGRectGetWidth(_addFilterButton.bounds)];
        [label setHeight:CGRectGetHeight(_addFilterButton.bounds)];
        label.font = kTextFont;
        label.textColor = [UIColor iOS7darkGrayColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"+添加筛选项";
        [_addFilterButton addSubview:label];
    }
    return _addFilterButton;
}

- (UITableView*)filterRightView {
    if (!_filterRightView) {
        _filterRightView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_filterRightView setX:kScreen_Width * 4 / 9.0];
        [_filterRightView setWidth:kScreen_Width * 5 / 9.0];
        [_filterRightView setHeight:kTableViewHeight];
        _filterRightView.backgroundColor = kSelectedBackgroundViewColor;
        _filterRightView.delegate = self;
        _filterRightView.dataSource = self;
        [_filterRightView registerClass:[FilterViewCell class] forCellReuseIdentifier:kCellIdentifier_right];
        _filterRightView.tableFooterView = [[UIView alloc] init];
    }
    return _filterRightView;
}

- (UIView*)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        [_bottomView setY:kTableViewHeight];
        [_bottomView setWidth:kScreen_Width];
        [_bottomView setHeight:kToolBarHeight];
        _bottomView.backgroundColor = kView_BG_Color;
        [_bottomView addLineUp:YES andDown:YES];
        
        UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [resetButton setWidth:54];
        [resetButton setHeight:kToolBarHeight];
        [resetButton setTitle:@"重置" forState:UIControlStateNormal];
//        [resetButton setTitleColor:[UIColor iOS7lightBlueColor] forState:UIControlStateNormal];
        [resetButton setTitleColor:COMMEN_LABEL_COROL forState:UIControlStateNormal];
        resetButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [resetButton addTarget:self action:@selector(resetButtonPress) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:resetButton];
        
        UIButton *confireButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [confireButton setX:kScreen_Width - 54];
        [confireButton setWidth:54];
        [confireButton setHeight:kToolBarHeight];
        [confireButton setTitle:@"确定" forState:UIControlStateNormal];
//        [confireButton setTitleColor:[UIColor iOS7lightBlueColor] forState:UIControlStateNormal];
        [confireButton setTitleColor:COMMEN_LABEL_COROL forState:UIControlStateNormal];
        confireButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [confireButton addTarget:self action:@selector(confireButtonPress) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:confireButton];
    }
    return _bottomView;
}

- (UICollectionView*)conditionView {
    if (!_conditionView) {
        // 创建布局
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        
        _conditionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _conditionView.backgroundColor = [UIColor whiteColor];
        [_conditionView setWidth:kScreen_Width];
        [_conditionView setHeight:54];
        _conditionView.dataSource = self;
        _conditionView.delegate = self;
        [_conditionView registerClass:[FilterConditionCCell class] forCellWithReuseIdentifier:kCCellIdentifier];
        
        // 添加底边边线
        [_conditionView.layer addSublayer:[self createHorizontalLineWithColor:[UIColor colorWithHexString:@"0xc8c7cc"] height:54]];
    }
    return _conditionView;
}

- (UIView*)addAddressBookView {
    if (!_addAddressBookView) {
        _addAddressBookView = [[UIView alloc] init];
        [_addAddressBookView setWidth:CGRectGetWidth(_filterRightView.bounds)];
        [_addAddressBookView setHeight:44.0f];
        
        [_addAddressBookView addSubview:self.addAddressBookButton];
    }
    return _addAddressBookView;
}

- (UIButton*)addAddressBookButton {
    if (!_addAddressBookButton) {
        _addAddressBookButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addAddressBookButton setX:15];
        [_addAddressBookButton setWidth:CGRectGetWidth(_addAddressBookView.bounds) - 30];
        [_addAddressBookButton setHeight:CGRectGetHeight(_addAddressBookView.bounds)];
        _addAddressBookButton.titleLabel.font = [UIFont systemFontOfSize:14];
//        [_addAddressBookButton setTitleColor:[UIColor iOS7lightBlueColor] forState:UIControlStateNormal];
         [_addAddressBookButton setTitleColor:COMMEN_LABEL_COROL forState:UIControlStateNormal];
        [_addAddressBookButton addTarget:self action:@selector(addAddressBookButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addAddressBookButton;
}

- (UIView*)addAddressBookFootView {
    if (!_addAddressBookFootView) {
        _addAddressBookFootView = [[UIView alloc] init];
        [_addAddressBookFootView setWidth:CGRectGetWidth(_filterRightView.bounds)];
        
        [_addAddressBookFootView addSubview:self.addAddressBookFootLabel];
    }
    return _addAddressBookFootView;
}

- (UILabel*)addAddressBookFootLabel {
    if (!_addAddressBookFootLabel) {
        _addAddressBookFootLabel = [[UILabel alloc] init];
        [_addAddressBookFootLabel setX:15];
        [_addAddressBookFootLabel setWidth:CGRectGetWidth(_addAddressBookFootView.bounds) - 30];
        _addAddressBookFootLabel.font = [UIFont systemFontOfSize:12];
        _addAddressBookFootLabel.numberOfLines = 0;
        _addAddressBookFootLabel.textColor = [UIColor iOS7darkGrayColor];
    }
    return _addAddressBookFootLabel;
}

- (UIButton*)headerViewSlider {
    if (!_headerViewSlider) {
        _headerViewSlider = [UIButton buttonWithType:UIButtonTypeCustom];
        [_headerViewSlider setWidth:CGRectGetWidth(_filterRightView.bounds)];
        [_headerViewSlider setHeight:44.0f];
        _headerViewSlider.backgroundColor = kSelectedBackgroundViewColor;
        [_headerViewSlider setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_headerViewSlider addTarget:self action:@selector(headerViewSliderBtnPress) forControlEvents:UIControlEventTouchUpInside];
        [_headerViewSlider addLineUp:NO andDown:YES];
        
        [_headerViewSlider addSubview:self.headerLabel];
        [_headerViewSlider addSubview:self.accessoryImageView];
    }
    return _headerViewSlider;
}

- (UILabel*)headerLabel {
    if (!_headerLabel) {
        _headerLabel = [[UILabel alloc] init];
        [_headerLabel setX:15];
        [_headerLabel setWidth:CGRectGetWidth(_headerViewSlider.bounds) - 15 - 44];
        [_headerLabel setHeight:44.0f];
        _headerLabel.font = [UIFont systemFontOfSize:14];
        _headerLabel.textAlignment = NSTextAlignmentLeft;
        _headerLabel.textColor = [UIColor blackColor];
    }
    return _headerLabel;
}

- (UIImageView*)accessoryImageView {
    if (!_accessoryImageView) {
        UIImage *image = [UIImage imageNamed:@"filter_slider_stage_normal"];
        _accessoryImageView = [[UIImageView alloc] initWithImage:image];
        [_accessoryImageView setWidth:image.size.width];
        [_accessoryImageView setHeight:image.size.height];
        [_accessoryImageView setX:CGRectGetWidth(_headerViewSlider.bounds) - image.size.width - 15];
        [_accessoryImageView setCenterY:CGRectGetHeight(_headerViewSlider.bounds) / 2];
    }
    return _accessoryImageView;
}

- (UIView*)footerViewSlider {
    if (!_footerViewSlider) {
        _footerViewSlider = [[UIView alloc] init];
        [_footerViewSlider setWidth:CGRectGetWidth(_filterRightView.bounds)];
        [_footerViewSlider setHeight:54.0f];
        
        [_footerViewSlider addSubview:self.filterSlider];
    }
    return _footerViewSlider;
}

- (FilterSlider*)filterSlider {
    if (!_filterSlider) {
        _filterSlider = [[FilterSlider alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_footerViewSlider.bounds), CGRectGetHeight(_footerViewSlider.bounds))];
        [_filterSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _filterSlider;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
