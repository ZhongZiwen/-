//
//  FileList_fileCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/31.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "FileList_fileCell.h"
#import "Directory.h"
#import "FileManager.h"

@interface FileList_fileCell ()

@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UIImageView *downloadIconView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@end

@implementation FileList_fileCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.downloadIconView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.detailLabel];
    }
    return self;
}

- (void)configWithObj:(id)obj {
    Directory *item = obj;
    
    if ([item.fileType isEqualToString:@"jpg"]) {
        [_iconView sd_setImageWithURL:[NSURL URLWithString:item.url] placeholderImage:[UIImage imageNamed:@""]];
    }
    else {
        _iconView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_file_%@", item.fileIcon]];
    }
    _titleLabel.text = item.name;
    _detailLabel.text = item.fileSize;
    
    BOOL isExisted = [[FileManager sharedManager] isExistedForFileName:item.name];
    if (isExisted) {
        _downloadIconView.hidden = NO;
    }
    else {
        _downloadIconView.hidden = YES;
    }

}

+ (CGFloat)cellHeight {
    return 54.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UIImageView*)iconView {
    if (!_iconView) {
        UIImage *image = [UIImage imageNamed:@"icon_file_unknown"];
        _iconView = [[UIImageView alloc] init];
        [_iconView setX:15];
        [_iconView setWidth:image.size.width];
        [_iconView setHeight:image.size.height];
        [_iconView setCenterY:[FileList_fileCell cellHeight] / 2];
    }
    return _iconView;
}

- (UIImageView*)downloadIconView {
    if (!_downloadIconView) {
        UIImage *image = [UIImage imageNamed:@"file_downloaded"];
        _downloadIconView = [[UIImageView alloc] initWithImage:image];
        [_downloadIconView setWidth:image.size.width];
        [_downloadIconView setHeight:image.size.height];
        [_downloadIconView setCenterX:CGRectGetMaxX(_iconView.frame)];
        [_downloadIconView setCenterY:CGRectGetMaxY(_iconView.frame) - CGRectGetHeight(_downloadIconView.bounds) / 2.0];
    }
    return _downloadIconView;
}

- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setX:CGRectGetMaxX(_iconView.frame) + 10];
        [_titleLabel setY:10];
        [_titleLabel setWidth:kScreen_Width - CGRectGetMinX(_titleLabel.frame) - 30];
        [_titleLabel setHeight:17];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UILabel*)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        [_detailLabel setX:CGRectGetMinX(_titleLabel.frame)];
        [_detailLabel setY:CGRectGetMaxY(_titleLabel.frame)];
        [_detailLabel setWidth:CGRectGetWidth(_titleLabel.bounds)];
        [_detailLabel setHeight:17];
        _detailLabel.font = [UIFont systemFontOfSize:14];
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _detailLabel.textColor = [UIColor iOS7lightGrayColor];
    }
    return _detailLabel;
}
@end
