//
//  ActivityRecordToolView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ActivityRecordToolView.h"
#import "Record.h"

@interface ActivityRecordToolView ()

@property (strong, nonatomic) UIButton *transmitButton;     // 转发
@property (strong, nonatomic) UIButton *likeButton;
@property (strong, nonatomic) UIButton *commentButton;
@end

@implementation ActivityRecordToolView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addLineUp:YES andDown:NO];
        
        [self addSubview:self.transmitButton];
        [self addSubview:self.likeButton];
        [self addSubview:self.commentButton];
    }
    return self;
}

- (void)configWithModel:(Record *)record {
    CGFloat kButton_Width;
    if (![record.canForward integerValue]) {
        
        kButton_Width = kScreen_Width / 3.0f;
        
        _transmitButton.hidden = NO;
        [_transmitButton setX:0];
        [_transmitButton setWidth:kButton_Width];
        
        [_commentButton setX:CGRectGetMaxX(_transmitButton.frame)];
        [_commentButton setWidth:kButton_Width];
        
        [_likeButton setX:CGRectGetMaxX(_commentButton.frame)];
        [_likeButton setWidth:kButton_Width];
    }else {
        
        kButton_Width = kScreen_Width / 2.0f;
        
        _transmitButton.hidden = YES;
        [_commentButton setX:0];
        [_commentButton setWidth:kButton_Width];
        
        [_likeButton setX:CGRectGetMaxX(_commentButton.frame)];
        [_likeButton setWidth:kButton_Width];
    }
    
    if (![record.isFeedUp integerValue]) {
        [_likeButton setImage:[UIImage imageNamed:@"feed_praise_select"] forState:UIControlStateNormal];
        [_likeButton removeTarget:self action:@selector(likeButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }else {
        [_likeButton setImage:[UIImage imageNamed:@"feed_praise"] forState:UIControlStateNormal];
        [_likeButton addTarget:self action:@selector(likeButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if ([record.feedUpCount integerValue]) {
        [_likeButton setTitle:[NSString stringWithFormat:@"%@", record.feedUpCount] forState:UIControlStateNormal];
    }else {
        [_likeButton setTitle:@"赞" forState:UIControlStateNormal];
    }
    
    [_commentButton setTitle:[NSString stringWithFormat:@"%@", record.commentCount ? : @"评论"] forState:UIControlStateNormal];
}

#pragma mark - event response
- (void)transmitButtonPress {
    if (self.transmitBtnClickedBlock) {
        self.transmitBtnClickedBlock();
    }
}

- (void)commentButtonPress {
    if (self.commentBtnClickedBlock) {
        self.commentBtnClickedBlock();
    }
}

- (void)likeButtonPress {
    if (self.likeBtnClickedBlock) {
        self.likeBtnClickedBlock();
    }
}

#pragma mark - setters and getters
- (UIButton*)transmitButton {
    if (!_transmitButton) {
        _transmitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_transmitButton setHeight:CGRectGetHeight(self.bounds)];
        [_transmitButton setImage:[UIImage imageNamed:@"activity_btn_share"] forState:UIControlStateNormal];
        [_transmitButton setTitle:@"转发" forState:UIControlStateNormal];
        [_transmitButton setTitleColor:[UIColor iOS7darkGrayColor] forState:UIControlStateNormal];
        _transmitButton.titleLabel.font = [UIFont systemFontOfSize:13];
        _transmitButton.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2);
        _transmitButton.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, -2);
        [_transmitButton addTarget:self action:@selector(transmitButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _transmitButton;
}

- (UIButton*)likeButton {
    if (!_likeButton) {
        _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_likeButton setHeight:CGRectGetHeight(self.bounds)];
        [_likeButton setTitleColor:[UIColor iOS7darkGrayColor] forState:UIControlStateNormal];
        _likeButton.titleLabel.font = [UIFont systemFontOfSize:13];
        _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2);
        _likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, -2);
    }
    return _likeButton;
}

- (UIButton*)commentButton {
    if (!_commentButton) {
        _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_commentButton setHeight:CGRectGetHeight(self.bounds)];
        [_commentButton setImage:[UIImage imageNamed:@"activity_btn_comment"] forState:UIControlStateNormal];
        [_commentButton setTitleColor:[UIColor iOS7darkGrayColor] forState:UIControlStateNormal];
        _commentButton.titleLabel.font = [UIFont systemFontOfSize:13];
        _commentButton.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2);
        _commentButton.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, -2);
        [_commentButton addTarget:self action:@selector(commentButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commentButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
