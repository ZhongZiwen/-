//
//  MRFileCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/1.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MRFileCell.h"

@interface MRFileCell ()

@property (nonatomic, strong) UIImageView *fileImageView;
@property (nonatomic, strong) UILabel *fileLabel;
@end

@implementation MRFileCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self.contentView addSubview:self.fileImageView];
        [self.contentView addSubview:self.fileLabel];
    }
    return self;
}

- (void)configWithFileType:(NSInteger)type andFileName:(NSString *)name {
    _fileImageView.image = [UIImage imageNamed:@"file_document_32"];
    _fileLabel.text = name;
}

+ (CGFloat)cellHeight {
    UIImage *image = [UIImage imageNamed:@"file_document_32"];
    return 20 + image.size.height;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UIImageView*)fileImageView {
    if (!_fileImageView) {
        UIImage *image = [UIImage imageNamed:@"file_document_32"];
        _fileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, image.size.width, image.size.height)];
    }
    return _fileImageView;
}

- (UILabel*)fileLabel {
    if (!_fileLabel) {
        _fileLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + CGRectGetWidth(_fileImageView.bounds) + 10, ([MRFileCell cellHeight]-30)/2.0, kScreen_Width - 15 - CGRectGetWidth(_fileImageView.bounds) - 10 - 30, 30)];
        _fileLabel.font = [UIFont systemFontOfSize:16];
        _fileLabel.textColor = [UIColor blackColor];
        _fileLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _fileLabel;
}
@end
