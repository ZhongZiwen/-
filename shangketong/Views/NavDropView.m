//
//  NavDropView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "NavDropView.h"
#import "NSString+Common.h"
#import "UIView+Common.h"
#import "NavDropAssetLibCell.h"

#define kTextFont   [UIFont systemFontOfSize:14]
#define kTextNormalColor    [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]
#define kTextSelectedCplor  [UIColor colorWithRed:70/255.0 green:154/255.0 blue:233/255.0 alpha:1]

#define kGroupLabelText     @"groupLabelText"
#define kGroupPhotoCounts   @"groupPhotoCounts"
#define kGroupURL           @"groupURL"
#define kGroupPosterImage   @"groupPosterImage"

#define kCellIdentifier @"UITableViewCell"
#define kCellIdentifier_AssetsLabrary @"NavDropAssetLibCell"

@interface NavDropView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UILabel *m_label;
@property (nonatomic, strong) UIImageView *m_imageView;
@property (nonatomic, strong) UIView *superView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *sourceArray;
@property (nonatomic, assign) NSInteger defaultIndex;
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, assign) TableViewCellType cellType;

// 根据index，显示相应菜单
- (void)configMenuWithIndex:(NSInteger)index;
// 显示或隐藏背景视图
- (void)animateBackgroundViewWithShow:(BOOL)show complete:(void(^)())complete;
// 三角形标识的旋转
- (void)animateIndicatorViewWithShow:(BOOL)show complete:(void(^)())complete;
// 显示或隐藏列表
- (void)animateTableViewWithShow:(BOOL)show complete:(void(^)())complete;
@end

@implementation NavDropView

- (id)initWithFrame:(CGRect)frame andType:(TableViewCellType)type andSource:(NSArray *)source andDefaultIndex:(NSInteger)index andController:(UIViewController *)controller {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _defaultIndex = index;
        _superView = controller.view;
        _isShow = NO;
        _cellType = type;
        
        _sourceArray = [NSMutableArray arrayWithArray:source];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenuTableView)];
        [self addGestureRecognizer:tap];
        
        [self addSubview:self.m_label];
        [self addSubview:self.m_imageView];
        
        [self configMenuWithIndex:_defaultIndex];
    }
    return self;
}

#pragma mark - private method
- (void)configMenuWithIndex:(NSInteger)index {
    if (TableViewCellTypeDefault == _cellType) {
        CGFloat width = [_sourceArray[index] getWidthWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(MAXFLOAT, CGRectGetHeight(self.bounds))];
        
        _m_label.text = _sourceArray[index];
        if (width >= CGRectGetWidth(_m_label.bounds)) {
            [_m_imageView setX:_m_label.frame.origin.x + _m_label.frame.size.width+8];
        }else {
            [_m_imageView setX:_m_label.frame.origin.x + _m_label.frame.size.width - (CGRectGetWidth(_m_label.bounds)-width)/2.0 + 8];
        }
    }else if (TableViewCellTypeAssetsLabrary == _cellType) {
        NSDictionary *groupDict = _sourceArray[index];
        
        CGFloat width = [[groupDict valueForKey:kGroupLabelText] getWidthWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(MAXFLOAT, CGRectGetHeight(self.bounds))];
        
        _m_label.text = [groupDict valueForKey:kGroupLabelText];
        if (width >= CGRectGetWidth(_m_label.bounds)) {
            [_m_imageView setX:_m_label.frame.origin.x + _m_label.frame.size.width+8];
        }else {
            [_m_imageView setX:_m_label.frame.origin.x + _m_label.frame.size.width - (CGRectGetWidth(_m_label.bounds)-width)/2.0 + 8];
        }
    }
}

#pragma mark - event response
- (void)showMenuTableView {
    __weak typeof(self) weak_self = self;
    if (!_isShow) { // 未显示
        _isShow = YES;
        [self animateIndicatorViewWithShow:_isShow complete:^{
            [weak_self animateBackgroundViewWithShow:weak_self.isShow complete:^{
                [weak_self animateTableViewWithShow:weak_self.isShow complete:^{
                    
                }];
            }];
        }];
        
    }else{  // 已经显示
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
    __weak __block typeof(self) weak_self = self;
    [self animateIndicatorViewWithShow:NO complete:^{
        [weak_self animateTableViewWithShow:NO complete:^{
            [weak_self animateBackgroundViewWithShow:NO complete:^{
                weak_self.isShow = NO;
            }];
        }];
    }];
}

- (void)animateBackgroundViewWithShow:(BOOL)show complete:(void(^)())complete {
    if (show) {
        [_superView addSubview:self.backgroundView];
        
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

// 三角形标识
- (void)animateIndicatorViewWithShow:(BOOL)show complete:(void(^)())complete {
    
    if (show) { // 显示
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
        [UIView animateWithDuration:0.2 animations:^{
            [_m_imageView setTransform:transform];
        }];
    }else{
        CGAffineTransform transform = CGAffineTransformMakeRotation(0);
        [UIView animateWithDuration:0.2 animations:^{
            [_m_imageView setTransform:transform];
        }];
    }
    complete();
}

- (void)animateTableViewWithShow:(BOOL)show complete:(void(^)())complete {
    
    CGFloat tableViewHeight = 0;
    if (TableViewCellTypeAssetsLabrary == _cellType) {
        tableViewHeight = _sourceArray.count * [NavDropAssetLibCell cellHeight];
    }else {
        tableViewHeight = _sourceArray.count * 44.0f;
    }
    
    if (show) {
        [_superView addSubview:self.tableView];
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
    if (TableViewCellTypeAssetsLabrary == _cellType) {
        return [NavDropAssetLibCell cellHeight];
    }
    return 44.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_cellType == TableViewCellTypeAssetsLabrary) {
        NavDropAssetLibCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_AssetsLabrary forIndexPath:indexPath];
        NSDictionary *groupDict = _sourceArray[indexPath.row];
        [cell configImageView:[groupDict valueForKey:kGroupPosterImage] Title:[groupDict valueForKey:kGroupLabelText] andDetail:[groupDict valueForKey:kGroupPhotoCounts]];
        return cell;
        
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];

    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = kTextFont;
    cell.textLabel.textColor = kTextNormalColor;
    cell.textLabel.highlightedTextColor = LIGHT_BLUE_COLOR;
    NSString *string = _sourceArray[indexPath.row];
    cell.textLabel.text = string;
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame] ;
    cell.selectedBackgroundView.backgroundColor = FILTER_SELECTED_BG;
    
    if ([[NSString stringWithFormat:@"%@", _sourceArray[_defaultIndex]] isEqualToString:string]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _menuIndexClick(indexPath.row);
    
    if (TableViewCellTypeAssetsLabrary == _cellType) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    [self configMenuWithIndex:indexPath.row];
    
    [self backgroundTap];
}

#pragma mark - setters and getters
- (UILabel*)m_label {
    if (!_m_label) {
        _m_label = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds)-160)/2.0, 0, 160, CGRectGetHeight(self.bounds))];
        _m_label.font = [UIFont systemFontOfSize:19];
        _m_label.textColor = [UIColor whiteColor];
        _m_label.textAlignment = NSTextAlignmentCenter;
    }
    return _m_label;
}

- (UIImageView*)m_imageView {
    if (!_m_imageView) {
        UIImage *image = [UIImage imageNamed:@"menu_selecter_arrow"];
        _m_imageView = [[UIImageView alloc] initWithImage:image];
        _m_imageView.frame = CGRectMake(0, (CGRectGetHeight(self.bounds)-image.size.height)/2.0, image.size.width, image.size.height);
    }
    return _m_imageView;
}

- (UIView*)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:_superView.bounds];
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
        [_tableView registerClass:[NavDropAssetLibCell class] forCellReuseIdentifier:kCellIdentifier_AssetsLabrary];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

@end
