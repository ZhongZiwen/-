//
//  XLFormCommentCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormCommentCell.h"
#import "UITapImageView.h"
#import "Comment.h"

NSString *const XLFormRowDescriptorTypeComment = @"XLFormRowDescriptorTypeComment";

@interface XLFormCommentCell ()

@property (strong, nonatomic) UITapImageView *iconView;
@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@end

@implementation XLFormCommentCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLFormCommentCell class] forKey:XLFormRowDescriptorTypeComment];
}

- (void)configure {
    [super configure];
    
    [self.contentView addSubview:self.iconView];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.timeLabel];
}

- (void)update {
    [super update];
    
    Comment *item = self.rowDescriptor.value;
    
    [_iconView sd_setImageWithURL:[NSURL URLWithString:item.creator.icon] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
    
    CGFloat height = [item.content getHeightWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(CGRectGetWidth(_contentLabel.bounds), CGFLOAT_MAX)];
    [_contentLabel setHeight:height];
    _contentLabel.text = item.content;
    
    [_timeLabel setY:CGRectGetMaxY(_contentLabel.frame) + 5];
    _timeLabel.text = [NSString stringWithFormat:@"%@ 发布于 %@", item.creator.name, [item.date stringDisplay_HHmm]];
}

- (void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    if (self.rowDescriptor.action.formSelector) {
        [controller performFormSelector:self.rowDescriptor.action.formSelector withObject:self.rowDescriptor];
    }
    
    [self.formViewController.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    
    Comment *item = rowDescriptor.value;
    
    CGFloat height = [item.content getHeightWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(kScreen_Width - 15 - 35 - 10 - 15, CGFLOAT_MAX)];

    return height + 45;
}

#pragma mark - setters and getters
- (UITapImageView*)iconView {
    if (!_iconView) {
        _iconView = [[UITapImageView alloc] init];
        [_iconView setX:15];
        [_iconView setY:10];
        [_iconView setWidth:35];
        [_iconView setHeight:35];
    }
    return _iconView;
}

- (UILabel*)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        [_contentLabel setX:CGRectGetMaxX(_iconView.frame) + 10];
        [_contentLabel setY:CGRectGetMinY(_iconView.frame)];
        [_contentLabel setWidth:kScreen_Width - CGRectGetMinX(_contentLabel.frame) - 15];
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (UILabel*)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        [_timeLabel setX:CGRectGetMinX(_contentLabel.frame)];
        [_timeLabel setWidth:kScreen_Width - CGRectGetMinX(_timeLabel.frame) - 15];
        [_timeLabel setHeight:20];
        _timeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _timeLabel;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
