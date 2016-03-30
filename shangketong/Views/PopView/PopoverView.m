//
//  PopoverView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PopoverView.h"
#import "PopoverCell.h"
#import "PopoverItem.h"

#define kArrowHeight 8.f
#define kCellIdentifier @"PopoverCell"

@interface PopoverView ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIButton *backgroundButton;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *souceArray;
@property (strong, nonatomic) NSArray *titlesArray;
@property (strong, nonatomic) NSArray *imagesArray;
@property (assign, nonatomic) BOOL isShow;      // 0没有展开  1已经展开
@end

@implementation PopoverView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithImageItems:(NSArray *)imageItems titleItems:(NSArray *)titleItems {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.titlesArray = titleItems;
        self.imagesArray = imageItems;
        
        _isShow = YES;
        if (_titlesArray.count && _imagesArray.count) {
            _isShow = NO;
        }
        
        // 初始化宽度和高度
        [self configBounce];
        
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)configBounce {
    
    [self setWidth:kTableViewWidth];
    
    if (_isShow) {
        if (_titlesArray.count) {
            [self setHeight:_titlesArray.count * 44 + kArrowHeight];
        }else {
            [self setHeight:_imagesArray.count * 44 + kArrowHeight];
        }
    }else {
        [self setHeight:(_imagesArray.count + 1) * 44 + kArrowHeight];
    }
    
    [self setCenterX:kScreen_Width - 5 - 47 / 2.0];
    [self setCenterY:64];

}

- (void)show {
    [self.backgroundButton addSubview:self];
    [kKeyWindow addSubview:_backgroundButton];

    // frame.origin.x = position.x - anchorPoint.x * bounds.size.width

    CGFloat anchorPointX = (self.layer.position.x - (kScreen_Width - CGRectGetWidth(self.bounds) - 5)) / CGRectGetWidth(self.bounds);
    CGFloat anchorPointY = (self.layer.position.y - 66) / CGRectGetHeight(self.bounds);
    
    self.layer.anchorPoint = CGPointMake(anchorPointX, anchorPointY);
    
    self.alpha = 0.f;
    self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

- (void)dismiss {
    [self dismissWithAnimate:YES];
}

- (void)dismissWithAnimate:(BOOL)animate {
    if (!animate) {
        [_backgroundButton removeFromSuperview];
        return;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [_backgroundButton removeFromSuperview];
    }];
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (_isShow) {
        return _imagesArray.count + _titlesArray.count;
    }
    
    return _imagesArray.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [PopoverCell cellHeight];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PopoverCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    PopoverItem *item;
    if (!_isShow) {
        if (indexPath.row < _imagesArray.count) {
            item = _imagesArray[indexPath.row];
        }else {
            
            item = [PopoverItem initItemWithTitle:@"更多操作" image:[UIImage imageNamed:@"menu_showMore_active"] target:nil action:nil];
        }
    }else {
        if (indexPath.row < _imagesArray.count) {
            item = _imagesArray[indexPath.row];
        }else {
            item = _titlesArray[indexPath.row - _imagesArray.count];
        }
    }
    [cell configWithObj:item];
    [tableView addRadiusforCell:cell forRowAtIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PopoverItem *item;
    if (!_isShow) {
        if (indexPath.row == _imagesArray.count) {
            
            _isShow = YES;
            
            NSInteger count = _imagesArray.count + _titlesArray.count;
            [self setHeight:(count > 5 ? 5 : count) * 44 + kArrowHeight];
            [_tableView setHeight:CGRectGetHeight(self.bounds) - kArrowHeight];
            
            [_tableView reloadData];
            
            [self setNeedsDisplay];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(_imagesArray.count + _titlesArray.count - 1) inSection:0];
            [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            
            return;
        }
        item = _imagesArray[indexPath.row];
    }
    
    if (indexPath.row < _imagesArray.count) {
        item = _imagesArray[indexPath.row];
    }else {
        item = _titlesArray[indexPath.row - _imagesArray.count];
    }
    
    [item performAction];
    
    [self dismiss];
}

#pragma mark - setters and getters
- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setY:kArrowHeight];
        [_tableView setWidth:kTableViewWidth];
        [_tableView setHeight:CGRectGetHeight(self.bounds) - kArrowHeight];
        _tableView.backgroundColor = [UIColor colorWithHexString:@"0x28303b"];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[PopoverCell class] forCellReuseIdentifier:kCellIdentifier];
    }
    return _tableView;
}

- (UIButton*)backgroundButton {
    if (!_backgroundButton) {
        _backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backgroundButton setWidth:kScreen_Width];
        [_backgroundButton setHeight:kScreen_Height];
        [_backgroundButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backgroundButton;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    // 设置线条颜色
    [[UIColor clearColor] set];
    
    UIBezierPath *popoverPath = [UIBezierPath bezierPath];
    [popoverPath moveToPoint:CGPointMake(0, kArrowHeight)];
    [popoverPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - 25, kArrowHeight)];
    
    [popoverPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - 20, 0)];
    [popoverPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - 15, kArrowHeight)];
    
    [popoverPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds), kArrowHeight)];   // 右上角
    [popoverPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];   // 右下角
    [popoverPath addLineToPoint:CGPointMake(0, CGRectGetHeight(self.bounds))];  // 左下角
    
    // 设置填充色
    [[UIColor colorWithHexString:@"0x28303b"] setFill];
    [popoverPath fill];
    
    [popoverPath closePath];
    [popoverPath stroke];
}


@end
