//
//  ActivityRecordCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ActivityRecordCell.h"
#import "AppDelegate.h"
#import "Record.h"
#import "ActivityRecordFileView.h"
#import "ActivityRecordAudioView.h"
#import "ActivityRecordPositionView.h"
#import "ActivityRecordImagesView.h"
#import "ActivityRecordToolView.h"

#define kWidth_headerView 35
#define kHeight_fileView 44
#define kHeight_toolView 44

@interface ActivityRecordCell ()

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIImageView *recordTypeIndicatorView;
@property (strong, nonatomic) UILabel *recordTypeLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIButton *moreButton;

@property (strong, nonatomic) ActivityRecordFileView *fileView;
@property (strong, nonatomic) ActivityRecordAudioView *audioView;
@property (strong, nonatomic) ActivityRecordPositionView *positionView;
@property (strong, nonatomic) ActivityRecordImagesView *imagesView;
@property (strong, nonatomic) ActivityRecordToolView *toolView;
@end

@implementation ActivityRecordCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        self.contentView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        
        [self.contentView addSubview:self.bgView];
        [_bgView addSubview:self.iconView];
        [_bgView addSubview:self.nameLabel];
        [_bgView addSubview:self.timeLabel];
        [_bgView addSubview:self.contentLabel];
        [_bgView addSubview:self.toolView];
        [_bgView addSubview:self.moreButton];
    }
    return self;
}

- (void)configWithObj:(Record *)obj {
    
    [_iconView sd_setImageWithURL:[NSURL URLWithString:obj.user.icon] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
    _nameLabel.text = obj.user.name;

    NSString *timeStr = [obj.created stringDisplay_HHmm];
    if (obj.from) {
        timeStr = [NSString stringWithFormat:@"%@ 来自%@(%@)", timeStr, obj.from.sourceName, obj.from.name];
    }
    _timeLabel.text = timeStr;
    
    CGFloat contentHeight = [obj.content getHeightWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(kScreen_Width - 2 * 10, CGFLOAT_MAX)];
    [_contentLabel setHeight:contentHeight];
    _contentLabel.text = obj.content;
    
    for (User *tempUser in obj.altsArray) {
        
        // 找到重名的用户
        NSMutableArray *altUsersArray = [NSMutableArray arrayWithCapacity:0];
        for (User *altUser in obj.altsArray) {
            if ([altUser.name rangeOfString:tempUser.name].location != NSNotFound) {
                [altUsersArray addObject:altUser];
            }
        }
        
        // 从内容中找到@人的range
        NSMutableArray *resultsArray = [NSMutableArray arrayWithCapacity:0];
        NSRange searchRange = NSMakeRange(0, [obj.content length]);
        NSRange altRange;
        while ((altRange = [obj.content rangeOfString:[NSString stringWithFormat:@"@%@", tempUser.name] options:0 range:searchRange]).location != NSNotFound) {
            [resultsArray addObject:[NSValue valueWithRange:altRange]];
            searchRange = NSMakeRange(NSMaxRange(altRange), [obj.content length] - NSMaxRange(altRange));
        }
        
        NSInteger index = [altUsersArray indexOfObject:tempUser];
        if (index < resultsArray.count) {
            NSRange range = ((NSValue*)resultsArray[index]).rangeValue;
            [_contentLabel addLinkToTransitInformation:@{@"value" : tempUser} withRange:range];
        }
    }
    
    CGFloat height = CGRectGetMaxY(_contentLabel.frame) +10;
    
    // 如果有文档，则只显示文档
    if ([obj.fileType integerValue] == 2) {
        [_audioView removeFromSuperview];
        [_positionView removeFromSuperview];
        [_imagesView removeFromSuperview];
        
        [_bgView addSubview:self.fileView];
        [_fileView setY:height];
        [_fileView configWithObj:obj.file];
        
        height += CGRectGetHeight(_fileView.bounds) + 10;
        
        [_toolView setY:height];
        height += CGRectGetHeight(_toolView.bounds) + 10;
        
        [_bgView setHeight:height];
        return;
    }else {
        [_fileView removeFromSuperview];
    }
    
    // 显示音频
    if (obj.audio) {
        [_bgView addSubview:self.audioView];
        [_audioView setY:height];
        _audioView.second = obj.audio.second;
        [_audioView setUrl:[NSURL URLWithString:obj.audio.url]];
        //        [_audioView setUrl:[NSURL URLWithString:@"https://rs.ingageapp.com/upload/f/151745/2015/10/15/0ee37c287561435cb3e055739a1bfca1.amr"]];
        
        height += CGRectGetHeight(_audioView.bounds) + 10;
    }else {
        [_audioView removeFromSuperview];
    }
    
    // 显示地理信息
    if (obj.position) {
        [_bgView addSubview:self.positionView];
        [_positionView setY:height];
        [_positionView configWithTitle:obj.position detail:obj.position];
        
        height += CGRectGetHeight(_positionView.bounds) + 10;
    }else {
        [_positionView removeFromSuperview];
    }
    
    // 显示图片
    if ([obj.fileType integerValue] == 1) {
        
        [_bgView addSubview:self.imagesView];
        [_imagesView setY:height];
        [_imagesView configWithArray:obj.imageFilesArray];
        
        height += CGRectGetHeight(_imagesView.bounds) + 5;
    }else {
        [_imagesView removeFromSuperview];
    }
    
    height += 10;
    
    [_toolView setY:height];
    [_toolView configWithModel:obj];
    height += CGRectGetHeight(_toolView.bounds);
    
    [_bgView setHeight:height];
}

+ (CGFloat)cellHeightWithObj:(Record *)obj {
    
    CGFloat cellHeight = 15;
    
    cellHeight += 10 + kWidth_headerView;
    cellHeight += 10 + [ActivityRecordCell contentHeightWithString:obj.content];
    
    if ([obj.fileType integerValue] == 2) {
        cellHeight += 10 + kHeight_fileView;
    }else {
        cellHeight += [ActivityRecordCell audioHeightWithObj:obj];
        cellHeight += [ActivityRecordCell positionHeightWithObj:obj];
        cellHeight += [ActivityRecordCell imagesViewHeightWithObj:obj];
        
        if (obj.imageFilesArray.count) {
            cellHeight += 5;
        }
    }
    
    cellHeight += kHeight_toolView + 10;
    cellHeight += 10;
    return cellHeight;
}

+ (CGFloat)contentHeightWithString:(NSString*)str {
    return [str getHeightWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(kScreen_Width - 10*2, CGFLOAT_MAX)];
}

+ (CGFloat)audioHeightWithObj:(Record*)obj {
    if (obj.audio) {
        UIImage *normalImage = [UIImage imageNamed:@"feed_voice_normal"];
        return normalImage.size.height + 10;
    }
    return 0;
}

+ (CGFloat)positionHeightWithObj:(Record*)obj {
    if (obj.position) {
        UIImage *image = [UIImage imageNamed:@"lbsmap"];
        return image.size.height + 10 + 10;
    }
    return 0;
}

+ (CGFloat)imagesViewHeightWithObj:(Record*)obj {
    if (obj.imageFilesArray.count % 3 == 0) {
        return obj.imageFilesArray.count / 3 * (kWidth_imageView + 10);
    }else {
        return (obj.imageFilesArray.count / 3 + 1) * (kWidth_imageView + 10);
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - event response
- (void)nameButtonPress {
    
}

- (void)moreButtonPress {
    if (self.moreBtnClickedBlock) {
        self.moreBtnClickedBlock();
    }
}

#pragma mark - setters and getters
- (UIView*)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        [_bgView setY:15];
        [_bgView setWidth:kScreen_Width];
        _bgView.backgroundColor = kView_BG_Color;
    }
    return _bgView;
}

- (UIImageView*)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        [_iconView setX:10];
        [_iconView setY:10];
        [_iconView setWidth:kWidth_headerView];
        [_iconView setHeight:kWidth_headerView];
    }
    return _iconView;
}

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setX:CGRectGetMaxX(_iconView.frame) + 10];
        [_nameLabel setY:CGRectGetMinY(_iconView.frame)];
        [_nameLabel setWidth:kScreen_Width - CGRectGetMinX(_nameLabel.frame) - 40];
        [_nameLabel setHeight:20];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = [UIColor colorWithHexString:@"0x3bbd79"];
    }
    return _nameLabel;
}

- (UILabel*)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        [_timeLabel setX:CGRectGetMinX(_nameLabel.frame)];
        [_timeLabel setY:CGRectGetMaxY(_nameLabel.frame)];
        [_timeLabel setWidth:kScreen_Width - CGRectGetMinX(_timeLabel.frame) - 15];
        [_timeLabel setHeight:15];
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.textColor = [UIColor iOS7lightGrayColor];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _timeLabel;
}

- (TTTAttributedLabel*)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_iconView.frame), CGRectGetMaxY(_iconView.frame) + 10, kScreen_Width - 2 * CGRectGetMinX(_contentLabel.frame), 20)];
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
        _contentLabel.numberOfLines = 0;
        _contentLabel.linkAttributes = kLinkAttributes;
        _contentLabel.activeLinkAttributes = kLinkAttributesActive;
    }
    return _contentLabel;
}

- (UIButton*)moreButton {
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreButton setX:kScreen_Width - 30];
        [_moreButton setWidth:30];
        [_moreButton setHeight:30];
        [_moreButton setCenterY:CGRectGetMidY(_nameLabel.frame)];
        [_moreButton setImage:[UIImage imageNamed:@"usernew_dashboard_list_screeningbutton"] forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(moreButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

- (ActivityRecordFileView*)fileView {
    if (!_fileView) {
        _fileView = [[ActivityRecordFileView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_iconView.frame), 0, kScreen_Width - CGRectGetMinX(_iconView.frame) * 2, kHeight_fileView)];
    }
    return _fileView;
}

- (ActivityRecordAudioView*)audioView {
    if (!_audioView) {
        _audioView = [[ActivityRecordAudioView alloc] init];
        [_audioView setX:CGRectGetMinX(_iconView.frame)];
    }
    return _audioView;
}

- (ActivityRecordPositionView*)positionView {
    if (!_positionView) {
        _positionView = [[ActivityRecordPositionView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_iconView.frame), 0, kScreen_Width - CGRectGetMinX(_iconView.frame) * 2, 0)];
    }
    return _positionView;
}

- (ActivityRecordImagesView*)imagesView {
    if (!_imagesView) {
        _imagesView = [[ActivityRecordImagesView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_iconView.frame), 0, kScreen_Width - CGRectGetMinX(_iconView.frame) * 2, 0)];
    }
    return _imagesView;
}

- (ActivityRecordToolView*)toolView {
    if (!_toolView) {
        _toolView = [[ActivityRecordToolView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kHeight_toolView)];
        @weakify(self);
        _toolView.commentBtnClickedBlock = ^{
            @strongify(self);
            if (self.commentBlock) {
                self.commentBlock();
            }
        };
        _toolView.transmitBtnClickedBlock = ^{
            @strongify(self);
            if (self.forwardBlock) {
                self.forwardBlock();
            }
        };
        _toolView.likeBtnClickedBlock = ^{
            @strongify(self);
            if (self.likeBlock) {
                self.likeBlock();
            }
        };
    }
    return _toolView;
}
@end
