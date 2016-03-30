//
//  XLFormFileCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormFileCell.h"
#import "Directory.h"

NSString *const XLFormRowDescriptorTypeFile = @"XLFormRowDescriptorTypeFile";

@interface XLFormFileCell ()

@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@end

@implementation XLFormFileCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLFormFileCell class] forKey:XLFormRowDescriptorTypeFile];
}

- (void)configure {
    [super configure];
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [self.contentView addSubview:self.iconView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.timeLabel];
}

- (void)update {
    [super update];
    
    Directory *item = self.rowDescriptor.value;
    
    if ([item.fileType isEqualToString:@"jpg"]) {
        [_iconView sd_setImageWithURL:[NSURL URLWithString:item.url] placeholderImage:[UIImage imageNamed:@"file_document_32"]];
    }
    else {
        _iconView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_file_%@", item.fileIcon]];
    }
    
    _nameLabel.text = item.name;
    _timeLabel.text = [NSString stringWithFormat:@"%@ %@", [item.createDate stringYearMonthDayForLine], item.fileSize];
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 54.0f;
}

#pragma mark - setters and getters
- (UIImageView*)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        [_iconView setX:15];
        [_iconView setWidth:35];
        [_iconView setHeight:35];
        [_iconView setCenterY:54 / 2];
    }
    return _iconView;
}

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setX:CGRectGetMaxX(_iconView.frame) + 10];
        [_nameLabel setY:CGRectGetMinY(_iconView.frame)];
        [_nameLabel setWidth:kScreen_Width - CGRectGetMinX(_nameLabel.frame) - 30];
        [_nameLabel setHeight:CGRectGetHeight(_iconView.bounds) * 3 / 5.0];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}

- (UILabel*)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        [_timeLabel setX:CGRectGetMinX(_nameLabel.frame)];
        [_timeLabel setY:CGRectGetMaxY(_nameLabel.frame)];
        [_timeLabel setWidth:CGRectGetWidth(_nameLabel.bounds)];
        [_timeLabel setHeight:CGRectGetHeight(_iconView.bounds) * 2 / 5.0];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.textColor = [UIColor iOS7lightGrayColor];
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
