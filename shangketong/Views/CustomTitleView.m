//
//  CustomTitleView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CustomTitleView.h"
#import "ActivityController.h"
#import "LeadViewController.h"
#import "CustomerViewController.h"
#import "ContactViewController.h"
#import "OpportunityViewController.h"

#import "AssetLibCell.h"
#import "IndexCondition.h"

#define kTextFont   [UIFont systemFontOfSize:18]
#define kTextNormalColor    [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]
#define kTextSelectedCplor  [UIColor colorWithRed:70/255.0 green:154/255.0 blue:233/255.0 alpha:1]
#define kTextMaxWidth 130

#define kGroupLabelText     @"groupLabelText"
#define kGroupPhotoCounts   @"groupPhotoCounts"
#define kGroupURL           @"groupURL"
#define kGroupPosterImage   @"groupPosterImage"

#define kCellIdentifier @"UITableViewCell"
#define kCellIdentifier_AssetsLabrary @"AssetLibCell"

@interface CustomTitleView ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *indicatorView;
@property (strong, nonatomic) UIView *backgroundView;
@end

@implementation CustomTitleView

- (id)init {
    self = [super init];
    if (self) {
        
        // 添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTableView)];
        [self addGestureRecognizer:tap];
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.indicatorView];
        
        [self setWidth:kTextMaxWidth + CGRectGetWidth(_indicatorView.bounds) + 5];
        [self setHeight:CGRectGetHeight(_titleLabel.bounds)];
    }
    return self;
}

#pragma mark - event response
- (void)showTableView {
    
    if ([_superViewController isKindOfClass:[ActivityController class]]) {
        ActivityController *controller = (ActivityController*)_superViewController;
        [controller hideFilterView];
    }
    else if ([_superViewController isKindOfClass:[LeadViewController class]]) {
        LeadViewController *leadController = (LeadViewController *)_superViewController;
        [leadController hideFilterView];
    }
    else if ([_superViewController isKindOfClass:[CustomerViewController class]]) {
        CustomerViewController *customerController = (CustomerViewController *)_superViewController;
        [customerController hideFilterView];
    }
    else if ([_superViewController isKindOfClass:[ContactViewController class]]) {
        ContactViewController *contactController = (ContactViewController *)_superViewController;
        [contactController hideFilterView];
    }
    else if ([_superViewController isKindOfClass:[OpportunityViewController class]]) {
        OpportunityViewController *opportunity = (OpportunityViewController *)_superViewController;
        [opportunity hideFilterView];
    }
    
    __weak typeof(self) weak_self = self;
    if (!_isShow) { // 未显示
        _isShow = YES;
        [self animateIndicatorViewWithShow:_isShow complete:^{
            [weak_self animateBackgroundViewWithShow:weak_self.isShow complete:^{
                [weak_self animateTableViewWithShow:weak_self.isShow complete:^{
                }];
            }];
        }];
        
    }else { // 已经显示
        _isShow = NO;
        [self animateIndicatorViewWithShow:_isShow complete:^{
            [weak_self animateTableViewWithShow:weak_self.isShow complete:^{
                [weak_self animateBackgroundViewWithShow:weak_self.isShow complete:^{
                    
                }];
            }];
        }];
    }
}

- (void)backgroundTap {
    __weak typeof(self) weak_self = self;
    [self animateIndicatorViewWithShow:NO complete:^{
        [weak_self animateTableViewWithShow:NO complete:^{
            [weak_self animateBackgroundViewWithShow:NO complete:^{
                weak_self.isShow = NO;
            }];
        }];
    }];
}

#pragma mark - private method
- (void)animateBackgroundViewWithShow:(BOOL)show complete:(void(^)())complete {
    if (show) {
        [_superViewController.view addSubview:self.backgroundView];
        
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

- (void)animateIndicatorViewWithShow:(BOOL)show complete:(void(^)())complete {
    if (show) { // 显示
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
        [UIView animateWithDuration:0.2 animations:^{
            [_indicatorView setTransform:transform];
        }];
    }else{
        CGAffineTransform transform = CGAffineTransformMakeRotation(0);
        [UIView animateWithDuration:0.2 animations:^{
            [_indicatorView setTransform:transform];
        }];
    }
    complete();
}

- (void)animateTableViewWithShow:(BOOL)show complete:(void(^)())complete {
    CGFloat tableViewHeight = 0;
    if (_cellType == CellTypeDefault) {
        if (_sourceArray.count > 6) {
            tableViewHeight = 6 * 44.0f;
            self.tableView.scrollEnabled = YES;
        }else {
            tableViewHeight = _sourceArray.count * 44.0f;
            self.tableView.scrollEnabled = NO;
        }
    }else if (_cellType == CellTypeOnlyName) {
        tableViewHeight = _sourceArray.count * 44.0f;
        self.tableView.scrollEnabled = NO;
    }else {
        tableViewHeight = _sourceArray.count * [AssetLibCell cellHeight];
        self.tableView.scrollEnabled = NO;
    }
    
    if (show) {
        [_superViewController.view addSubview:self.tableView];
        [_tableView setY:64 - tableViewHeight];
        [_tableView setHeight:tableViewHeight];
        
        [UIView animateWithDuration:0.2 animations:^{
            [_tableView setY:64];
        }];
    }else {
        [UIView animateWithDuration:0.2 animations:^{
            [_tableView setY:64 - tableViewHeight];
        } completion:^(BOOL finished) {
            [_tableView removeFromSuperview];
        }];
    }
    complete();
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_cellType == CellTypeAssetsLabrary) {
        return [AssetLibCell cellHeight];
    }
    
    return 44.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_cellType == CellTypeAssetsLabrary) {
        AssetLibCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_AssetsLabrary forIndexPath:indexPath];
        NSDictionary *groupDict = _sourceArray[indexPath.row];
        [cell configImageView:[groupDict valueForKey:kGroupPosterImage] Title:[groupDict valueForKey:kGroupLabelText] andDetail:[groupDict valueForKey:kGroupPhotoCounts]];
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = kTextNormalColor;
    cell.textLabel.highlightedTextColor = COMMEN_LABEL_COROL;
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame] ;
    cell.selectedBackgroundView.backgroundColor = FILTER_SELECTED_BG;
    
    if (_cellType == CellTypeOnlyName) {
        cell.textLabel.text = _sourceArray[indexPath.row];
        return cell;
    }
    
    IndexCondition *item = _sourceArray[indexPath.row];
    if (item.itemCount) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@(%@)", item.name, item.itemCount];
    }else {
        cell.textLabel.text = item.name;
    }
    if (indexPath.row == _index) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.valueBlock) {
        self.valueBlock(indexPath.row);
    }
    
    if (_cellType == CellTypeAssetsLabrary) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    self.index = indexPath.row;
    
    [self backgroundTap];
}

#pragma mark - setters and getters
- (void)setDefalutTitleString:(NSString *)defalutTitleString {
    
    _indicatorView.hidden = YES;
    
    _titleLabel.text = defalutTitleString;
    [_titleLabel sizeToFit];
    [_titleLabel setCenterX:CGRectGetWidth(self.bounds) / 2];
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    
    _indicatorView.hidden = NO;
    
    // 照片选择
    if (_cellType == CellTypeAssetsLabrary) {
        
        
        return;
    }
    
    NSString *titleStr = @"";
    if (_cellType == CellTypeOnlyName) {
        titleStr = _sourceArray[_index];
    }else {
        if (!_sourceArray.count) {
            return;
        }
        IndexCondition *item = _sourceArray[_index];
        if (item.itemCount) {
            titleStr = [NSString stringWithFormat:@"%@(%@)", item.name, item.itemCount];
        }else {
            titleStr = item.name;
        }
    }
    
    _titleLabel.text = titleStr;
    CGFloat width = [titleStr getWidthWithFont:kTextFont constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
    if (width > kTextMaxWidth) {
        [_titleLabel sizeToFit];
        [_titleLabel setX:0];
        [_titleLabel setWidth:kTextMaxWidth];
        
        [_indicatorView setX:CGRectGetMaxX(_titleLabel.frame) + 5];
        [_indicatorView setCenterY:CGRectGetHeight(_titleLabel.bounds) / 2];
        
    }else {
        [_titleLabel sizeToFit];
        
        [_titleLabel setCenterX:(CGRectGetWidth(self.bounds) - 5 - CGRectGetWidth(_indicatorView.bounds)) / 2];
        [_indicatorView setX:CGRectGetMaxX(_titleLabel.frame) + 5];
        [_indicatorView setCenterY:CGRectGetHeight(_titleLabel.bounds) / 2];
        
    }
}

- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setWidth:kTextMaxWidth];
        [_titleLabel setHeight:21.5];
        _titleLabel.font = kTextFont;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIImageView*)indicatorView {
    if (!_indicatorView) {
        UIImage *image = [UIImage imageNamed:@"menu_selecter_arrow"];
        _indicatorView = [[UIImageView alloc] initWithImage:image];
        [_indicatorView setWidth:image.size.width];
        [_indicatorView setHeight:image.size.height];
        _indicatorView.hidden = YES;
    }
    return _indicatorView;
}

- (UIView*)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:kScreen_Bounds];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        
        UIGestureRecognizer *backgroundGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap)];
        [_backgroundView addGestureRecognizer:backgroundGes];
    }
    return _backgroundView;
}

- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 0) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        [_tableView registerClass:[AssetLibCell class] forCellReuseIdentifier:kCellIdentifier_AssetsLabrary];
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
