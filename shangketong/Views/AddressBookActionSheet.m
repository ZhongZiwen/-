//
//  AddressBookActionSheet.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AddressBookActionSheet.h"
#import "UIView+Common.h"
#import "AddressBookActionSheetCell.h"

#define kRowHeight      48.0f
#define kSeparatorHeight 5.0f
#define kCellIdentifier @"AddressBookActionSheetCell"

@interface AddressBookActionSheet ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *actionSheetBGView;

@property (nonatomic, copy) NSString *mobileString;
@property (nonatomic, copy) NSString *phoneString;
@end

@implementation AddressBookActionSheet

- (id)initWithCancelTitle:(NSString *)cancelTitle andMobile:(NSString *)mobile andPhone:(NSString *)photo {
    self = [super initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    if (self) {
        
        _mobileString = mobile;
        _phoneString = photo;
        
        [self addSubview:self.backgroundView];
        [self addSubview:self.actionSheetBGView];
        [_actionSheetBGView addSubview:self.tableView];
        
        if ([_mobileString length] && [_phoneString length]) {
            [_actionSheetBGView setHeight:kRowHeight * 3 + kSeparatorHeight];
            [_tableView setHeight:kRowHeight * 2];
        }else {
            [_actionSheetBGView setHeight:kRowHeight * 2 + kSeparatorHeight];
            [_tableView setHeight:kRowHeight];
        }
        
        // 添加取消按钮
        UIButton *cancelBtn = [[UIButton alloc] init];
        cancelBtn.frame = CGRectMake(0, CGRectGetHeight(_tableView.bounds) + kSeparatorHeight, kScreen_Width, kRowHeight);
        cancelBtn.backgroundColor = [UIColor whiteColor];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelBtn setTitle:cancelTitle forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelButtonPress) forControlEvents:UIControlEventTouchUpInside];
        [_actionSheetBGView addSubview:cancelBtn];
    }
    return self;
}

#pragma mark - Public Method
- (void)show {
    
    __weak typeof(self) weak_self = self;
    [UIView animateWithDuration:0.35f delay:0 usingSpringWithDamping:0.9f initialSpringVelocity:0.7f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState |  UIViewAnimationOptionLayoutSubviews animations:^{
        
        [kKeyWindow addSubview:weak_self];
        weak_self.backgroundView.alpha = 1.0;
        
        [weak_self.actionSheetBGView setY:CGRectGetHeight(weak_self.bounds) - CGRectGetHeight(weak_self.actionSheetBGView.bounds)];
        
    } completion:NULL];
}

- (void)dismiss {
    
    __weak __block typeof(self) weak_self = self;
    [UIView animateWithDuration:0.35f delay:0 usingSpringWithDamping:0.9f initialSpringVelocity:0.7f options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionLayoutSubviews animations:^{
        
        weak_self.backgroundView.alpha = 0.0f;
        [weak_self.actionSheetBGView setY:CGRectGetHeight(weak_self.bounds)];
        
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
    if ([_mobileString length] && [_phoneString length]) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self);
    AddressBookActionSheetCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.msgBtnClickedBlock = ^(NSString *tel) {
        @strongify(self);
        if (self.msgBlock) {
            self.msgBlock(tel);
        }
        
        [self dismiss];
    };
    cell.phoneBtnClickedBlock = ^(NSString *tel) {
        @strongify(self);
        if (self.phoneBlock) {
            self.phoneBlock(tel);
        }
        
        [self dismiss];
    };
    switch (indexPath.row) {
        case 0: {
            if ([_mobileString length]) {
                [cell configWithMobile:_mobileString];
            }else {
                [cell configWithPhone:_phoneString];
            }
        }
            break;
        case 1: {
            [cell configWithPhone:_phoneString];
        }
        default:
            break;
    }
    return cell;
}

#pragma mark - setters and getters
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
        _actionSheetBGView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, 0)];
        _actionSheetBGView.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
    }
    return _actionSheetBGView;
}

- (UITableView*)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 0) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[AddressBookActionSheetCell class] forCellReuseIdentifier:kCellIdentifier];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.bounces = NO;
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
