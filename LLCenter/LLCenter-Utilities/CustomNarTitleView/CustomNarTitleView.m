//
//  CustomTitleView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CustomNarTitleView.h"
#import "CustomNarTitleModel.h"
#import "UIView+Common.h"
#import "NSString+Common.h"
#import "LLCenterUtility.h"

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

@interface CustomNarTitleView ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *indicatorView;
@property (strong, nonatomic) UIView *backgroundView;
@end

@implementation CustomNarTitleView

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
    if (_sourceArray.count > 6) {
        tableViewHeight = 6 * 44.0f;
        self.tableView.scrollEnabled = YES;
    }else {
        tableViewHeight = _sourceArray.count * 44.0f;
        self.tableView.scrollEnabled = NO;
    }
    
    if (show) {
        [_superViewController.view addSubview:self.tableView];
        [_tableView setY:0 - tableViewHeight];
        [_tableView setHeight:tableViewHeight];
        
        [UIView animateWithDuration:0.2 animations:^{
            [_tableView setY:0];
        }];
    }else {
        [UIView animateWithDuration:0.2 animations:^{
            [_tableView setY:0 - tableViewHeight];
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
    return 44.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = kTextNormalColor;
    cell.textLabel.highlightedTextColor = kTextSelectedCplor;
    
    CustomNarTitleModel *item = _sourceArray[indexPath.row];
    cell.textLabel.text = item.name;
    
    if (indexPath.row == _index) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.valueBlock) {
        self.valueBlock(indexPath.row);
    }
    
    self.index = indexPath.row;
    
    [self backgroundTap];
}

#pragma mark - setters and getters
- (void)setDefalutTitleString:(NSString *)defalutTitleString {
    
    
    _titleLabel.text = defalutTitleString;
    [_titleLabel sizeToFit];
    [_titleLabel setCenterX:CGRectGetWidth(self.bounds) / 2 -3];
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    
    _indicatorView.hidden = NO;

    CustomNarTitleModel *item = _sourceArray[_index];
    NSString *titleStr = @"";
    
    titleStr = item.name;
    
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
    }
    return _indicatorView;
}


-(void)setIndicatorViewHide:(BOOL)hide{
    _indicatorView.hidden = hide;
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
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_BOUNDS_WIDTH, 0) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
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
