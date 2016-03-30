//
//  LLCenterMenuPopView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "LLCenterMenuPopView.h"
#import "UIView+Common.h"
#import "NSString+Common.h"
#import "LLCenterUtility.h"
#import "LLCenterMenuPopCell.h"

#define kArrowHeight 6.f
#define kCellIdentifier @"LLCenterMenuPopCell"


@interface LLCenterMenuPopView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic) CGPoint showPoint;
@property (nonatomic, strong) UIButton *handerView;
@end

@implementation LLCenterMenuPopView

- (id)initWithPoint:(CGPoint)point titles:(NSArray *)titles {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0f];
        self.showPoint = point;
        self.titleArray = titles;
        
        [self configViewFrame];
        
        [self addSubview:self.tableView];
    }
    return self;
}

- (id)initWithPoint:(CGPoint)point titles:(NSArray *)titles imageNames:(NSArray *)images {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0f];
        self.showPoint = point;
        self.titleArray = titles;
        self.imageArray = images;
        
        [self configViewFrame];
        
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)show {
    [self.handerView addSubview:self];
    [kKeyWindow addSubview:_handerView];
    
    CGPoint arrowPoint = [self convertPoint:_showPoint fromView:_handerView];
    [self setX:DEVICE_BOUNDS_WIDTH - CGRectGetWidth(self.bounds) - 10 + (0.5 - 20.0 / CGRectGetWidth(self.bounds)) * CGRectGetWidth(self.bounds)];
//    [self setX:arrowPoint.x + (0.5 - 20.0 / CGRectGetWidth(self.bounds)) * CGRectGetWidth(self.bounds)];
    [self setY:arrowPoint.y - CGRectGetHeight(self.bounds) / 2 - 64];
    self.layer.anchorPoint = CGPointMake(1.0 - 20.0 / CGRectGetWidth(self.bounds), 0);
    self.alpha = 0.f;
    self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.3f animations:^{
        self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [_handerView removeFromSuperview];
    }];
}

- (void)layoutSubviews {

    UIImage *bubbleImage = [UIImage imageNamed:@"index_moreBackGroundView"];
    UIImageView *bubbleImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [bubbleImageView setImage:[bubbleImage stretchableImageWithLeftCapWidth:bubbleImage.size.width / 2 - 5 topCapHeight:bubbleImage.size.height / 2]];
    
    CALayer *layer = bubbleImageView.layer;
    layer.frame = (CGRect){{0,0},bubbleImageView.layer.frame.size};
    self.layer.mask = layer;
    
    [super layoutSubviews];
}

#pragma mark - Private Method
- (void)configViewFrame {
    [self setHeight:_titleArray.count * [LLCenterMenuPopCell cellHeight] + kArrowHeight];
    
    for (NSString *titleStr in _titleArray) {
        CGFloat width = [titleStr getWidthWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(MAXFLOAT, 20)];
        
        [self setWidth:MAX(width + 30 + 15, CGRectGetWidth(self.bounds))];
    }
    
    if (_imageArray && _imageArray.count) {
        [self setWidth:CGRectGetWidth(self.bounds) + 35];
    }
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LLCenterMenuPopCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0f];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.text = _titleArray[indexPath.row];
    
    if (_imageArray && _imageArray.count) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_imageArray[indexPath.row]]];
    }
     */
    
     LLCenterMenuPopCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    [cell configWithTitle:_titleArray[indexPath.row] andImageName:_imageArray[indexPath.row]];
    
    
    if (indexPath.row > 0) {
        [cell.contentView addSubview:({
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(_tableView.bounds) - 30, 0.5)];
            lineView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
            lineView;
        })];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.selectBlock) {
        self.selectBlock(indexPath.row);
    }
    
    [self dismiss];
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kArrowHeight, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - kArrowHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.scrollEnabled = NO;
        _tableView.alwaysBounceHorizontal = NO;
        _tableView.alwaysBounceVertical = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerClass:[LLCenterMenuPopCell class] forCellReuseIdentifier:kCellIdentifier];
    }
    return _tableView;
}

- (UIButton*)handerView {
    if (!_handerView) {
        _handerView = [UIButton buttonWithType:UIButtonTypeCustom];
        _handerView.frame = kScreen_Bounds;
        [_handerView setBackgroundColor:[UIColor clearColor]];
        [_handerView addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _handerView;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    
}


@end
