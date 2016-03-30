//
//  CustomActionSheet.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CustomActionSheet.h"
#import "CustomActionSheetCell.h"
#import "CustomActionSheetCell_activity.h"
#import "ColumnSelectModel.h"
#import "Reason.h"
#import "NameIdModel.h"

#define kTitleHeight    50.0f
#define kRowHeight      48.0f
#define kSeparatorHeight 5.0f
#define kCellIdentifier @"CustomActionSheetCell"
#define kCellIdentifier_activity @"CustomActionSheetCell_activity"

@interface CustomActionSheet ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *backgroudView;
@property (nonatomic, strong) UIView *actionSheetView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (strong, nonatomic) UIButton *cancelBtn;
@end

@implementation CustomActionSheet

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setWidth:kScreen_Width];
        [self setHeight:kScreen_Height];
        
        [self addSubview:self.backgroudView];
        [self addSubview:self.actionSheetView];
        [_actionSheetView addSubview:self.titleLabel];
        [_actionSheetView addSubview:self.tableView];
        [_actionSheetView addSubview:self.cancelBtn];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - Public Method
- (void)show {
    
    CGFloat originY = 0;
    if (_title && _title.length > 0) {
        originY += kTitleHeight;
        
        _titleLabel.hidden = NO;
        _titleLabel.text = _title;
    }else {
        _titleLabel.hidden = YES;
    }
    
    [_tableView setY:originY];
    if (_sourceArray.count <= 5) {
        [_tableView setHeight:kRowHeight * _sourceArray.count];
    }else {
        [_tableView setHeight:kRowHeight * 5 + kRowHeight / 2.0];
    }
    
    originY += CGRectGetHeight(_tableView.bounds);
    
    originY += kSeparatorHeight;
    
    [_cancelBtn setY:originY];
    
    originY += kRowHeight;
    
    [_actionSheetView setHeight:originY];
    
    [_tableView reloadData];
    
    [UIView animateWithDuration:0.35f delay:0 usingSpringWithDamping:0.9f initialSpringVelocity:0.7f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState |  UIViewAnimationOptionLayoutSubviews animations:^{
        
        [kKeyWindow addSubview:self];
        _backgroudView.alpha = 1.0;
        
        [_actionSheetView setY:CGRectGetHeight(self.bounds) - CGRectGetHeight(_actionSheetView.bounds)];
        
    } completion:NULL];
}

- (void)dismiss {
    
    __weak __block typeof(self) weak_self = self;
    [UIView animateWithDuration:0.35f delay:0 usingSpringWithDamping:0.9f initialSpringVelocity:0.7f options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionLayoutSubviews animations:^{
        
        weak_self.backgroudView.alpha = 0.0f;
        [weak_self.actionSheetView setY:CGRectGetHeight(weak_self.bounds)];
        
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
    CGPoint point = [touch locationInView:_backgroudView];
    if (!CGRectContainsPoint(_actionSheetView.frame, point)) {
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
    if (_actionType == ActionSheetTypeFromActivity) {
        CustomActionSheetCell_activity *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_activity forIndexPath:indexPath];
        ColumnSelectModel *item = _sourceArray[indexPath.row];
        [cell configWithModel:item];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:15];
        return cell;
    }
    
    if (_actionType == ActionSheetTypeFromReason) {
        CustomActionSheetCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
        Reason *item = _sourceArray[indexPath.row];
        [cell configWithString:item.reason];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:15];
        return cell;
    }
    
    if (_actionType == ActionSheetTypeFromNewContact) {
        CustomActionSheetCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
        NameIdModel *item = _sourceArray[indexPath.row];
        [cell configWithString:item.name];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:15];
        return cell;
    }
    
    CustomActionSheetCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    [cell configWithString:_sourceArray[indexPath.row]];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:15];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.selectedBlock) {
        if (_actionType == ActionSheetTypeFromActivity) {
            ColumnSelectModel *tempItem = _sourceArray[indexPath.row];
            self.selectedBlock(tempItem, _actionType);
        }
        else if (_actionType == ActionSheetTypeFromReason) {
            Reason *item = _sourceArray[indexPath.row];
            self.selectedBlock(item, _actionType);
        }
        else if (_actionType == ActionSheetTypeFromNewContact) {
            NameIdModel *item = _sourceArray[indexPath.row];
            self.selectedBlock(item, _actionType);
        }
        else {
            self.selectedBlock(@(indexPath.row), _actionType);
        }
    }
    [self dismiss];
}

#pragma mark - setters and getters
- (UIView*)backgroudView {
    if (!_backgroudView) {
        _backgroudView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        _backgroudView.alpha = 0.0f;
    }
    return _backgroudView;
}

- (UIView*)actionSheetView {
    if (!_actionSheetView) {
        _actionSheetView = [[UIView alloc] init];
        [_actionSheetView setY:CGRectGetHeight(self.bounds)];
        [_actionSheetView setWidth:kScreen_Width];
        [_actionSheetView setHeight:0];
        _actionSheetView.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
    }
    return _actionSheetView;
}

- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setWidth:kScreen_Width];
        [_titleLabel setHeight:kTitleHeight];
        _titleLabel.backgroundColor = kView_BG_Color;
        _titleLabel.textColor = [UIColor colorWithRed:111.0f/255.0f green:111.0f/255.0f blue:111.0f/255.0f alpha:1.0f];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:16];
        [_titleLabel addLineUp:NO andDown:YES];
    }
    return _titleLabel;
}

- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 0) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[CustomActionSheetCell class] forCellReuseIdentifier:kCellIdentifier];
        [_tableView registerClass:[CustomActionSheetCell_activity class] forCellReuseIdentifier:kCellIdentifier_activity];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.bounces = NO;
    }
    return _tableView;
}

- (UIButton*)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setWidth:kScreen_Width];
        [_cancelBtn setHeight:kRowHeight];
        _cancelBtn.backgroundColor = kView_BG_Color;
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}
@end
