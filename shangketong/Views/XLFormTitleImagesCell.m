//
//  XLFormTitleImagesCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormTitleImagesCell.h"
#import "User.h"
#import "ColumnModel.h"

#define kPaddingLeftWidth 15
#define kTextFont_title   [UIFont systemFontOfSize:16]
#define kTextFont_detail  [UIFont systemFontOfSize:16]

NSString *const XLFormRowDescriptorTypeTitleImages = @"XLFormRowDescriptorTypeTitleImages";

@interface XLFormTitleImagesCell ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@end

@implementation XLFormTitleImagesCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLFormTitleImagesCell class] forKey:XLFormRowDescriptorTypeTitleImages];
}

- (void)configure {
    [super configure];
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.detailLabel];
}

- (void)update {
    [super update];
    
    NSArray *array = self.rowDescriptor.value;
    
    if (!array.count) {
        _detailLabel.hidden = NO;
        _detailLabel.text = @"未选择";
        return;
    }
    
    _detailLabel.hidden = YES;
    for (int i = 0; i < array.count; i ++) {
        id obj = array[i];
        if ([obj isKindOfClass:[User class]]) {
            User *tempUser = obj;
            UIImageView *iconView = [[UIImageView alloc] init];
            [iconView setX:kPaddingLeftWidth + (30 + 10) * (i % 7)];
            [iconView setY:CGRectGetMaxY(_titleLabel.frame) + 10 + (30 + 10) * (i / 7)];
            [iconView setWidth:30];
            [iconView setHeight:30];
            [iconView sd_setImageWithURL:[NSURL URLWithString:tempUser.icon] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
            [self.contentView addSubview:iconView];
        }
        else if ([obj isKindOfClass:[ColumnModel class]]) {
            ColumnModel *tempColumn = obj;
            
            _titleLabel.text = tempColumn.name;
            
            UIImageView *iconView = [[UIImageView alloc] init];
            [iconView setX:kPaddingLeftWidth + (30 + 10) * (i % 7)];
            [iconView setY:CGRectGetMaxY(_titleLabel.frame) + 10 + (30 + 10) * (i / 7)];
            [iconView setWidth:30];
            [iconView setHeight:30];
            [iconView sd_setImageWithURL:[NSURL URLWithString:tempColumn.objectResult.icon] placeholderImage:[UIImage imageNamed:@"product_icon_default"]];
            [self.contentView addSubview:iconView];
        }
    }
}

- (void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    [self.formViewController.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    NSArray *array = rowDescriptor.value;
    return 10 + 20 + (30 + 10) * (array.count / 7 + 1) + 10;
}

#pragma mark - setters and getters
- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setX:kPaddingLeftWidth];
        [_titleLabel setY:10];
        [_titleLabel setWidth:kScreen_Width - 2 * kPaddingLeftWidth];
        [_titleLabel setHeight:20];
        _titleLabel.font = kTextFont_title;
        _titleLabel.textColor = [UIColor iOS7lightBlueColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UILabel*)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        [_detailLabel setX:CGRectGetMinX(_titleLabel.frame)];
        [_detailLabel setY:CGRectGetMaxY(_titleLabel.frame) + 10];
        [_detailLabel setWidth:CGRectGetWidth(_titleLabel.bounds)];
        [_detailLabel setHeight:30];
        _detailLabel.font = kTextFont_detail;
        _detailLabel.textColor = [UIColor iOS7lightGrayColor];
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _detailLabel.numberOfLines = 0;
        _detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _detailLabel;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
