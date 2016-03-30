//
//  DetailStaffCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "DetailStaffCell.h"
#import "DetailStaffModel.h"

@interface DetailStaffCell ()

@property (strong, nonatomic) UIImageView *headerView;
@property (strong, nonatomic) UIImageView *headerView_level;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIButton *showButton;
@property (strong, nonatomic) UILabel *detailLabel;
@end

@implementation DetailStaffCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.headerView];
        [self.contentView addSubview:self.headerView_level];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.showButton];
        [self.contentView addSubview:self.detailLabel];
    }
    return self;
}

- (void)configWithModel:(DetailStaffModel *)item codeStatus:(NSNumber *)status indexPath:(NSIndexPath *)path {
    [_headerView sd_setImageWithURL:[NSURL URLWithString:item.icon] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
    _nameLabel.text = item.name;
    
    if ([status isEqualToNumber:@0]) {
        if (path.section == 0) {
            _showButton.hidden = YES;
        }else {
            _showButton.hidden = NO;
            _showButton.tag = path.row;
        }
    }
    else {
        _showButton.hidden = YES;
    }
    
    if ([item.staffLevel integerValue] == 3) {
        _detailLabel.hidden = YES;
        _headerView_level.hidden = YES;
    }else {
        _detailLabel.hidden = NO;
        _headerView_level.hidden = NO;
    }
}

- (void)tapGesture {
    if (self.iconViewClickedBlock) {
        self.iconViewClickedBlock();
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

#pragma mark - event response
- (void)showButtonPress:(UIButton*)sender {
    if (self.showBtnClickedBlock) {
        self.showBtnClickedBlock(sender.tag);
    }
}

#pragma mark - setters and getters
- (UIImageView*)headerView {
    if (!_headerView) {
        _headerView = [[UIImageView alloc] init];
        [_headerView setX:10];
        [_headerView setY:10];
        [_headerView setWidth:[DetailStaffCell cellHeight] - 2 * CGRectGetMinY(_headerView.frame)];
        [_headerView setHeight:CGRectGetWidth(_headerView.bounds)];
        _headerView.contentMode = UIViewContentModeScaleAspectFill;
        _headerView.clipsToBounds = YES;
        _headerView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture)];
        [_headerView addGestureRecognizer:tap];
    }
    return _headerView;
}

- (UIImageView*)headerView_level {
    if (!_headerView_level) {
        UIImage *image = [UIImage imageNamed:@"member_owner"];
        _headerView_level = [[UIImageView alloc] initWithImage:image];
        [_headerView_level setWidth:image.size.width];
        [_headerView_level setHeight:image.size.height];
        [_headerView_level setCenterX:CGRectGetMaxX(_headerView.frame)];
        [_headerView_level setCenterY:CGRectGetMaxY(_headerView.frame)];
    }
    return _headerView_level;
}

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setX:CGRectGetMaxX(_headerView.frame) + 10];
        [_nameLabel setWidth:kScreen_Width - 190];
        [_nameLabel setHeight:20];
        [_nameLabel setCenterY:CGRectGetMidY(_headerView.frame)];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}

- (UILabel*)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        [_detailLabel setX:CGRectGetMinX(_showButton.frame) - 95];
        [_detailLabel setWidth:95];
        [_detailLabel setHeight:20];
        [_detailLabel setCenterY:CGRectGetMidY(_headerView.frame)];
        _detailLabel.font = [UIFont systemFontOfSize:13];
        _detailLabel.textColor = [UIColor iOS7lightGrayColor];
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.text = @"有修改资料权限";
    }
    return _detailLabel;
}

- (UIButton*)showButton {
    if (!_showButton) {
        _showButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_showButton setX:kScreen_Width - 40.0f];
        [_showButton setWidth:40.0f];
        [_showButton setHeight:[DetailStaffCell cellHeight]];
        [_showButton addTarget:self action:@selector(showButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        
        [_showButton addSubview:self.indicatorView];
    }
    return _showButton;
}

- (UIImageView*)indicatorView {
    if (!_indicatorView) {
        UIImage *image = [UIImage imageNamed:@"opportunity_stage_title_arrow_down"];
        _indicatorView = [[UIImageView alloc] initWithImage:image];
        [_indicatorView setWidth:image.size.width];
        [_indicatorView setHeight:image.size.height];
        [_indicatorView setCenterX:CGRectGetWidth(_showButton.bounds) / 2.0];
        [_indicatorView setCenterY:CGRectGetHeight(_showButton.bounds) / 2.0];
    }
    return _indicatorView;
}

@end
