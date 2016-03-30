//
//  TypeActionSheet.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/21.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TypeActionSheet.h"
#import "TypeModel.h"

#define kTitleHeight    54.0f
#define kRowHeight      48.0f
#define kSeparatorHeight 5.0f
#define kCellIdentifier @"UITableViewCell"

@interface TypeActionSheet ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIView *actionSheetBGView;
@property (strong, nonatomic) UIButton *cancelBtn;
@end

@implementation TypeActionSheet

- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    if (self) {
        [self setWidth:kScreen_Width];
        [self setHeight:kScreen_Height];
        
        [self addSubview:self.backgroundView];
        [self addSubview:self.actionSheetBGView];
        [_actionSheetBGView addSubview:self.titleLabel];
        [_actionSheetBGView addSubview:self.tableView];
        [_actionSheetBGView addSubview:self.cancelBtn];

        _titleLabel.text = title;

    }
    return self;
}

#pragma mark - private method
- (void)show {
    [UIView animateWithDuration:0.35f delay:0 usingSpringWithDamping:0.9f initialSpringVelocity:0.7f options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionLayoutSubviews animations:^{
        
        [kKeyWindow addSubview:self];
        self.backgroundView.alpha = 1.0;
        [self.actionSheetBGView setY:kScreen_Height - CGRectGetHeight(_actionSheetBGView.bounds)];
        
    } completion:NULL];
}

- (void)dismiss {
    [UIView animateWithDuration:0.35f delay:0 usingSpringWithDamping:0.9f initialSpringVelocity:0.7f options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionLayoutSubviews animations:^{
        self.backgroundView.alpha = 0.0f;
        [self.actionSheetBGView setY:kScreen_Height];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - event response
- (void)cancelButtonPress {
    [self dismiss];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:_backgroundView];
    if (!CGRectContainsPoint(_actionSheetBGView.frame, point)) {
        [self dismiss];
    }
}

#pragma mark - UITableView_M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    TypeModel *item = _sourceArray[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = kTitleColor;
    cell.textLabel.text = item.name;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:15.0f];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TypeModel *item = _sourceArray[indexPath.row];
    
    if (self.valueBlock) {
        self.valueBlock(item);
    }
    
    [self dismiss];
}

#pragma mark - setters ang getters
- (void)setSourceArray:(NSArray *)sourceArray {
    _sourceArray = [NSArray arrayWithArray:sourceArray];
    
    [_tableView setY:CGRectGetMaxY(_titleLabel.frame)];
    [_tableView setHeight:kRowHeight * sourceArray.count];
    
    [_cancelBtn setY:CGRectGetMaxY(_tableView.frame) + kSeparatorHeight];
    
    [_actionSheetBGView setHeight:kTitleHeight + kRowHeight * sourceArray.count + kSeparatorHeight + kRowHeight];
}

- (UIView*)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        _backgroundView.alpha = 0.0f;
    }
    return _backgroundView;
}

- (UIView*)actionSheetBGView {
    if (!_actionSheetBGView) {
        _actionSheetBGView = [[UIView alloc] initWithFrame:CGRectZero];
        [_actionSheetBGView setY:kScreen_Height];
        [_actionSheetBGView setWidth:kScreen_Width];
        _actionSheetBGView.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
    }
    return _actionSheetBGView;
}

- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 0) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.bounces = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_titleLabel setWidth:kScreen_Width];
        [_titleLabel setHeight:kTitleHeight];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleLabel addLineUp:NO andDown:YES];
    }
    return _titleLabel;
}

- (UIButton*)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setWidth:kScreen_Width];
        [_cancelBtn setHeight:kRowHeight];
        _cancelBtn.backgroundColor = [UIColor whiteColor];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_cancelBtn setTitle:@"取 消" forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
