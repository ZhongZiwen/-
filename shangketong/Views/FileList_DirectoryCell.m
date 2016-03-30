//
//  FileList_DirectoryCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/31.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "FileList_DirectoryCell.h"
#import "Directory.h"

@interface FileList_DirectoryCell ()

@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@end

@implementation FileList_DirectoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.detailLabel];
    }
    return self;
}

- (void)configWithObj:(id)obj {
    Directory *item = obj;
    
    _titleLabel.text = item.name;
    _detailLabel.text = [NSString stringWithFormat:@"%@个对象", item.child];
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
        UIImage *image = [UIImage imageNamed:@"file_floder"];
        _iconView = [[UIImageView alloc] initWithImage:image];
        [_iconView setX:15];
        [_iconView setWidth:image.size.width];
        [_iconView setHeight:image.size.height];
        [_iconView setCenterY:[FileList_DirectoryCell cellHeight] / 2];
    }
    return _iconView;
}

- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setX:CGRectGetMaxX(_iconView.frame) + 10];
        [_titleLabel setWidth:kScreen_Width - CGRectGetMinX(_titleLabel.frame) - 94];
        [_titleLabel setHeight:20];
        [_titleLabel setCenterY:CGRectGetMidY(_iconView.frame)];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UILabel*)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        [_detailLabel setX:kScreen_Width - 94];
        [_detailLabel setWidth:64];
        [_detailLabel setHeight:20];
        [_detailLabel setCenterY:CGRectGetMidY(_iconView.frame)];
        _detailLabel.font = [UIFont systemFontOfSize:14];
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.textColor = [UIColor iOS7lightGrayColor];
    }
    return _detailLabel;
}


@end
