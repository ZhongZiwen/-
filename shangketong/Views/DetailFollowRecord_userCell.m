//
//  DetailFollowRecord_userCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "DetailFollowRecord_userCell.h"
#import "Record.h"
#import "RecordAudioPlayView.h"
#import "FileModel.h"
#import "PhotoBroswerVC.h"

#define kWidth_headerView 35
#define kWidth_imageView 80
#define kButtonBackgroundImage_normal [UIImage imageWithColor:[UIColor colorWithWhite:0.92 alpha:1.0]]
#define kButtonBackgroundImage_highlighted [UIImage imageWithColor:[UIColor colorWithWhite:0.87 alpha:1.0]]
#define kTag_imageView 35436

@interface DetailFollowRecord_userCell ()

//@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UIView *markedBGView;                 // 汇总视图
@property (strong, nonatomic) UIView *markedCirclecirView;          // 汇总白色圆
@property (strong, nonatomic) UILabel *markedLabel;                 // 汇总时间标题
@property (strong, nonatomic) UIView *lineView;                     // 竖线
@property (strong, nonatomic) UIButton *bgView;                     // 底图
@property (strong, nonatomic) UIImageView *headerView;              // 头像
@property (strong, nonatomic) UILabel *nameLabel;                   // 用户名
@property (strong, nonatomic) UIImageView *commentView;             // 评论图标
@property (strong, nonatomic) UILabel *commentCount;                // 评论数
@property (strong, nonatomic) UIImageView *activiyRecordImageView;  // 活动类型图片
@property (strong, nonatomic) UILabel *fromLabel;                   // 来源
@property (strong, nonatomic) UILabel *createLabel;                 // 创建时间 MM-dd

// 文档
@property (strong, nonatomic) UIButton *fileBgView;
@property (strong, nonatomic) UIImageView *fileHeadView;
@property (strong, nonatomic) UILabel *fileName;

// 音频
@property (strong, nonatomic) RecordAudioPlayView *audioView;

// 地理位置
@property (strong, nonatomic) UIButton *positionBgView;
@property (strong, nonatomic) UIImageView *positionHeadView;
@property (strong, nonatomic) UILabel *positionTitle;
@property (strong, nonatomic) UILabel *positionDetail;

// 图片
@property (strong, nonatomic) UIImageView *imageView0;
@property (strong, nonatomic) UIImageView *imageView1;
@property (strong, nonatomic) UIImageView *imageView2;
@property (strong, nonatomic) UIImageView *imageView3;
@property (strong, nonatomic) UIImageView *imageView4;
@property (strong, nonatomic) UIImageView *imageView5;
@property (strong, nonatomic) UIImageView *imageView6;
@property (strong, nonatomic) UIImageView *imageView7;
@property (strong, nonatomic) UIImageView *imageView8;

@property (strong, nonatomic) NSMutableArray *imageViewsArray;
@end

@implementation DetailFollowRecord_userCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"0xF8F8F8"];
        _imageViewsArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        [self.contentView addSubview:self.markedBGView];
        [self.contentView addSubview:self.lineView];
        [self.contentView addSubview:self.bgView];
        [_bgView addSubview:self.activiyRecordImageView];
        [_bgView addSubview:self.fromLabel];
        [_bgView addSubview:self.createLabel];
        [_bgView addSubview:self.headerView];
        [_bgView addSubview:self.nameLabel];
        [_bgView addSubview:self.contentLabel];
        [_bgView addSubview:self.commentView];
        [_bgView addSubview:self.commentCount];
        
        [_bgView addSubview:self.imageView0];
        [_bgView addSubview:self.imageView1];
        [_bgView addSubview:self.imageView2];
        [_bgView addSubview:self.imageView3];
        [_bgView addSubview:self.imageView4];
        [_bgView addSubview:self.imageView5];
        [_bgView addSubview:self.imageView6];
        [_bgView addSubview:self.imageView7];
        [_bgView addSubview:self.imageView8];
        
        CAShapeLayer *layer = [CAShapeLayer new];
        UIBezierPath *path = [UIBezierPath new];
        [path moveToPoint:CGPointMake(0, 20 - 0.5)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(_bgView.bounds), 20 - 0.5)];
        
        layer.path = path.CGPath;
        layer.lineWidth = 0.5;
        layer.strokeColor = [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
        [_bgView.layer addSublayer:layer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVoice) name:@"stopVoice" object:nil];
    }
    return self;
}

- (void)stopVoice {
    [_audioView stop];
}

- (void)configWithModel:(Record *)model {
    
    [_fileBgView removeFromSuperview];
    [_audioView removeFromSuperview];
    [_positionBgView removeFromSuperview];
    
    if (model.isShowMarkedTime) {
        
        CGFloat markedStrWidth = [model.markedTime getWidthWithFont:[UIFont systemFontOfSize:11] constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(_markedBGView.bounds))];
        [_markedBGView setWidth:14 + markedStrWidth + 8];
        _markedBGView.hidden = NO;
        [_markedLabel setWidth:markedStrWidth];
        _markedLabel.text = model.markedTime;
        
        [_lineView setY:CGRectGetMaxY(_markedBGView.frame)];
        [_bgView setY:CGRectGetMaxY(_markedBGView.frame) + 10];
    }
    else {
        
        _markedBGView.hidden = YES;
        
        [_lineView setY:0];
        [_bgView setY:10];
    }
    [_bgView setHeight:[DetailFollowRecord_userCell cellHeightWithObj:model] - CGRectGetMinY(_bgView.frame)];
    
    UIImage *typeImage;
    if ([model.activiyRecord.id isEqualToString:@"A001"]) {
        typeImage = [UIImage imageNamed:@"activity_feed_icon_notes"];
    }else if ([model.activiyRecord.id isEqualToString:@"A002"]) {
        typeImage = [UIImage imageNamed:@"activity_feed_type_icon_call"];
    }else if ([model.activiyRecord.id isEqualToString:@"A003"]) {
        typeImage = [UIImage imageNamed:@"activity_feed_type_icon_lbs"];
    }else {
        typeImage = [UIImage imageNamed:@"activity_select_other"];
    }
    _activiyRecordImageView.image = typeImage;
    
    _fromLabel.text = [NSString stringWithFormat:@"来源%@（%@）", model.from.sourceName, model.from.name];
    _createLabel.text = [model.created stringHourMinute];
    [_headerView sd_setImageWithURL:[NSURL URLWithString:model.user.icon] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
    _nameLabel.text = model.user.name;
    _commentCount.text = [NSString stringWithFormat:@"%@", model.commentCount ? model.commentCount : @"0"];
    [_contentLabel setWidth:CGRectGetWidth(_bgView.bounds) - CGRectGetMinX(_contentLabel.frame) * 2];
    _contentLabel.text = model.content;
    [_contentLabel sizeToFit];
    
    for (User *tempUser in model.altsArray) {
        
        // 找到重名的用户
        NSMutableArray *altUsersArray = [NSMutableArray arrayWithCapacity:0];
        for (User *altUser in model.altsArray) {
            if ([altUser.name rangeOfString:tempUser.name].location != NSNotFound) {
                [altUsersArray addObject:altUser];
            }
        }
        
        // 从内容中找到@人的range
        NSMutableArray *resultsArray = [NSMutableArray arrayWithCapacity:0];
        NSRange searchRange = NSMakeRange(0, [model.content length]);
        NSRange altRange;
        while ((altRange = [model.content rangeOfString:[NSString stringWithFormat:@"@%@", tempUser.name] options:0 range:searchRange]).location != NSNotFound) {
            [resultsArray addObject:[NSValue valueWithRange:altRange]];
            searchRange = NSMakeRange(NSMaxRange(altRange), [model.content length] - NSMaxRange(altRange));
        }
        
        NSInteger index = [altUsersArray indexOfObject:tempUser];
        if (index < resultsArray.count) {
            NSRange range = ((NSValue*)resultsArray[index]).rangeValue;
            [_contentLabel addLinkToTransitInformation:@{@"value" : tempUser} withRange:range];
        }
    }
    
    // 如果有文档，则只显示文档
    if ([model.fileType integerValue] == 2) {
        [_bgView addSubview:self.fileBgView];
        [_fileBgView setY:CGRectGetMaxY(_contentLabel.frame) + 10];
        _fileName.text = model.file.name;
        
        for (int i = 0; i < 9; i ++) {
            UIImageView *imageView = (UIImageView*)[_bgView viewWithTag:kTag_imageView + i];
            imageView.hidden = YES;
        }
        
        NSString *extension = [model.file.name pathExtension];
        if ([extension isEqualToString:@"png"] || [extension isEqualToString:@"jpg"]) {
            _fileHeadView.image = [UIImage imageNamed:@"S_Icon_Img"];
        }
        else if ([extension isEqualToString:@"pdf"]) {
            _fileHeadView.image = [UIImage imageNamed:@"S_Icon_PDF"];
        }
        else if ([extension isEqualToString:@"doc"] || [extension isEqualToString:@"docx"]) {
            _fileHeadView.image = [UIImage imageNamed:@"S_Icon_Word"];
        }
        else if ([extension isEqualToString:@"pages"]) {
            _fileHeadView.image = [UIImage imageNamed:@"S_Icon_Word"];
        }
        else if ([extension isEqualToString:@"ppt"] || [extension isEqualToString:@"pptx"]) {
            _fileHeadView.image = [UIImage imageNamed:@"S_Icon_PPT"];
        }
        else if ([extension isEqualToString:@"key"]) {
            _fileHeadView.image = [UIImage imageNamed:@"S_Icon_PPT"];
        }
        else if ([extension isEqualToString:@"xls"] || [extension isEqualToString:@"xlsx"]) {
            _fileHeadView.image = [UIImage imageNamed:@"S_Icon_Excel"];
        }
        else if ([extension isEqualToString:@"numbers"]) {
            _fileHeadView.image = [UIImage imageNamed:@"S_Icon_Excel"];
        }
        else {
            _fileHeadView.image = [UIImage imageNamed:@"S_Icon_noView"];
        }
        
        return;
    }
    
    // 显示音频
    if (model.audio) {
        [_bgView addSubview:self.audioView];
        [_audioView setY:CGRectGetMaxY(_contentLabel.frame) + 10];
        _audioView.second = model.audio.second;
        [_audioView setUrl:[NSURL URLWithString:model.audio.url]];
    }
    
    // 有地理信息，则显示地理信息
    if (model.position) {
        [_bgView addSubview:self.positionBgView];
        _positionTitle.text = model.position;
        _positionDetail.text = model.position;
        
        // 存在音频时，在下面显示
        if (model.audio) {
            [_positionBgView setY:CGRectGetMaxY(_audioView.frame) + 10];
        }else {
            [_positionBgView setY:CGRectGetMaxY(_contentLabel.frame) + 10];
        }
    }
    
    // 显示图片
    if ([model.fileType integerValue] == 1) {
        
        [_imageViewsArray removeAllObjects];
        
        CGFloat originY = CGRectGetMaxY(_contentLabel.frame) + 10;
        if (model.audio) {
            originY = CGRectGetMaxY(_audioView.frame) + 10;
        }
        if (model.position) {
            originY = CGRectGetMaxY(_positionBgView.frame) + 10;
        }
        
        for (int i = 0; i < 9; i ++) {
            UIImageView *imageView = (UIImageView*)[_bgView viewWithTag:kTag_imageView + i];
            if (i < model.imageFilesArray.count) {
                FileModel *file = model.imageFilesArray[i];
                [imageView setX:CGRectGetMinX(_headerView.frame) + (kWidth_imageView + 10) * (i % 3)];
                [imageView setY:originY + (kWidth_imageView + 10) * (i / 3)];
                imageView.hidden = NO;
                [imageView sd_setImageWithURL:[NSURL URLWithString:file.minUrl] placeholderImage:[UIImage imageNamed:@"user_icon_default_90"]];
                
                PhotoModel *pbModel=[[PhotoModel alloc] init];
                pbModel.mid = i+1;
                pbModel.image_HD_U =file.url;
                pbModel.sourceImageView = imageView;
                [_imageViewsArray addObject:pbModel];
                
                continue;
            }
            
            imageView.hidden = YES;
        }
    }else {
        for (int i = 0; i < 9; i ++) {
            UIImageView *imageView = (UIImageView*)[_bgView viewWithTag:kTag_imageView + i];
            imageView.hidden = YES;
        }
    }
}

+ (CGFloat)cellHeightWithObj:(Record *)obj {
    CGFloat cellHeight = 0;
    
    cellHeight += 10;       // 起始高度10
    
    if (obj.isShowMarkedTime) {
        cellHeight += 20 + 10;  // 汇总高度 + 竖线高度
    }
    
    cellHeight += 20;       // 来源高度
    cellHeight += 10;       // 来源到头像的间距
    cellHeight += 35;       // 头像高度
    cellHeight += 10;       // 头像到内容的间距
    cellHeight += [DetailFollowRecord_userCell contentLabelHeightWithString:obj.content];
    
    if ([obj.fileType integerValue] == 2) {
        cellHeight += 10;   // 内容到附件的间距
        cellHeight += 30;   // 附件高度
        cellHeight += 10;   // 收尾（高度为起始高度值）
    }else {
        cellHeight += 10;   // 内容到音频或定位或图片的间距
        cellHeight += [DetailFollowRecord_userCell audioButtonHeightWithModel:obj.audio];
        cellHeight += [DetailFollowRecord_userCell positionButtonHeightWithString:obj.position];
        cellHeight += [DetailFollowRecord_userCell imagesViewHeightWithArray:obj.imageFilesArray];
    }
    
    return cellHeight;
}

+ (CGFloat)contentLabelHeightWithString:(NSString*)str {
    return [str getHeightWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(kScreen_Width - 5*2 - 10*2, CGFLOAT_MAX)];
}

+ (CGFloat)audioButtonHeightWithModel:(AudioModel*)model {
    if (model) {
        UIImage *normalImage = [UIImage imageNamed:@"feed_voice_normal"];
        return normalImage.size.height + 10;
    }
    
    return 0;
}

+ (CGFloat)positionButtonHeightWithString:(NSString*)str {
    if (str) {
        UIImage *image = [UIImage imageNamed:@"lbsmap"];
        return 5 + image.size.height + 5 + 10;
    }
    return 0;
}

+ (CGFloat)imagesViewHeightWithArray:(NSArray*)imagesArray {
    if (imagesArray.count % 3 == 0) {
        return imagesArray.count / 3 * (kWidth_imageView + 10);
    }else {
        return (imagesArray.count / 3 + 1) * (kWidth_imageView + 10);
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
- (void)backgroundButtonPress {
    if (self.detailBtnClickedBlock) {
        self.detailBtnClickedBlock();
    }
}

- (void)fileButtonPress {
    if (self.fileBtnClickedBlock) {
        self.fileBtnClickedBlock();
    }
}

- (void)audioButtonPress {
    
}

- (void)positionButtonPress {
    if (self.positionBtnClickedBlock) {
        self.positionBtnClickedBlock();
    }
}

- (void)tapGesture:(UITapGestureRecognizer*)sender {
    UIImageView *selectedImageView = (UIImageView *)sender.view;
    //    PhotoItem *selectedItem = _imageViewsArray[selectedImageView.tag - kTag_imageView];
    //
    //    [PhotoBrowser sharedInstance].backgroundScale = 1.0;
    //    [[PhotoBrowser sharedInstance] showWithItems:_imageViewsArray selectedItem:selectedItem];
    [PhotoBroswerVC show:self.handleVC type:PhotoBroswerVCTypeUserInfo index:selectedImageView.tag - kTag_imageView photoModelBlock:^NSArray *{
        return _imageViewsArray;
    }];
}

- (void)tap {
    if (self.headerViewClickedBlock) {
        self.headerViewClickedBlock();
    }
}

#pragma mark - setters and getters
- (UIView *)markedBGView {
    if (!_markedBGView) {
        _markedBGView = [[UIView alloc] init];
        [_markedBGView setX:12];
        [_markedBGView setY:10];
        [_markedBGView setHeight:20];
        _markedBGView.backgroundColor = [UIColor iOS7yellowColor];
        _markedBGView.layer.cornerRadius = CGRectGetHeight(_markedBGView.bounds) / 2;
        _markedBGView.layer.masksToBounds = YES;
        _markedBGView.clipsToBounds = YES;
        
        [_markedBGView addSubview:self.markedCirclecirView];
        [_markedBGView addSubview:self.markedLabel];
    }
    return _markedBGView;
}

- (UIView *)markedCirclecirView {
    if (!_markedCirclecirView) {
        _markedCirclecirView = [[UIView alloc] init];
        [_markedCirclecirView setX:5];
        [_markedCirclecirView setWidth:6];
        [_markedCirclecirView setHeight:6];
        [_markedCirclecirView setCenterY:CGRectGetHeight(_markedBGView.bounds) / 2];
        _markedCirclecirView.backgroundColor = [UIColor whiteColor];
        _markedCirclecirView.layer.cornerRadius = CGRectGetHeight(_markedCirclecirView.bounds) / 2;
        _markedCirclecirView.layer.masksToBounds = YES;
        _markedCirclecirView.clipsToBounds = YES;
    }
    return _markedCirclecirView;
}

- (UILabel *)markedLabel {
    if (!_markedLabel) {
        _markedLabel = [[UILabel alloc] init];
        [_markedLabel setX:CGRectGetMaxX(_markedCirclecirView.frame) + 3];
        [_markedLabel setHeight:CGRectGetHeight(_markedBGView.bounds)];
        _markedLabel.font = [UIFont systemFontOfSize:11];
        _markedLabel.textColor = [UIColor whiteColor];
        _markedLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _markedLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        [_lineView setX:20];
        [_lineView setWidth:0.5];
        [_lineView setHeight:10];
        _lineView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    }
    return _lineView;
}

- (UIButton*)bgView {
    if (!_bgView) {
        _bgView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bgView setX:5];
        [_bgView setWidth:kScreen_Width - 10];
        [_bgView setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_bgView setBackgroundImage:kButtonBackgroundImage_highlighted forState:UIControlStateHighlighted];
        [_bgView addTarget:self action:@selector(backgroundButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bgView;
}

- (UIImageView*)activiyRecordImageView {
    if (!_activiyRecordImageView) {
        UIImage *image = [UIImage imageNamed:@"activity_feed_icon_notes"];
        _activiyRecordImageView = [[UIImageView alloc] init];
        [_activiyRecordImageView setX:10];
        [_activiyRecordImageView setWidth:image.size.width];
        [_activiyRecordImageView setHeight:image.size.height];
        [_activiyRecordImageView setCenterY:10];
    }
    return _activiyRecordImageView;
}

- (UILabel*)fromLabel {
    if (!_fromLabel) {
        _fromLabel = [[UILabel alloc] init];
        [_fromLabel setX:CGRectGetMaxX(_activiyRecordImageView.frame) + 5];
        [_fromLabel setWidth:240];
        [_fromLabel setHeight:20];
        _fromLabel.font = [UIFont systemFontOfSize:11];
        _fromLabel.textColor = [UIColor iOS7lightGrayColor];
        _fromLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _fromLabel;
}

- (UILabel*)createLabel {
    if (!_createLabel) {
        _createLabel = [[UILabel alloc] init];
        [_createLabel setX:CGRectGetWidth(_bgView.bounds) - 40 - 5];
        [_createLabel setY:0];
        [_createLabel setWidth:40];
        [_createLabel setHeight:20];
        _createLabel.font = [UIFont systemFontOfSize:11];
        _createLabel.textColor = [UIColor iOS7lightGrayColor];
        _createLabel.textAlignment = NSTextAlignmentRight;
    }
    return _createLabel;
}

- (UIImageView*)headerView {
    if (!_headerView) {
        _headerView = [[UIImageView alloc] init];
        [_headerView setX:10];
        [_headerView setY:30];
        [_headerView setWidth:kWidth_headerView];
        [_headerView setHeight:kWidth_headerView];
        _headerView.contentMode = UIViewContentModeScaleAspectFill;
        _headerView.clipsToBounds = YES;
        _headerView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [_headerView addGestureRecognizer:tap];
    }
    return _headerView;
}

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setX:CGRectGetMaxX(_headerView.frame) + 5];
        [_nameLabel setWidth:CGRectGetWidth(_bgView.bounds) - CGRectGetMinX(_nameLabel.frame) - 44];
        [_nameLabel setHeight:20];
        [_nameLabel setCenterY:CGRectGetMidY(_headerView.frame)];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}

- (TTTAttributedLabel*)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_headerView.frame), CGRectGetMaxY(_headerView.frame) + 10, CGRectGetWidth(_bgView.bounds) - CGRectGetMinX(_contentLabel.frame) * 2, 20)];
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
        _contentLabel.numberOfLines = 0;
        _contentLabel.linkAttributes = kLinkAttributes;
        _contentLabel.activeLinkAttributes = kLinkAttributesActive;
    }
    return _contentLabel;
}

- (UIImageView*)commentView {
    if (!_commentView) {
        UIImage *image = [UIImage imageNamed:@"feed_repost_review"];
        _commentView = [[UIImageView alloc] initWithImage:image];
        [_commentView setX:CGRectGetWidth(_bgView.bounds) - 34];
        [_commentView setY:CGRectGetMinY(_headerView.frame)];
        [_commentView setWidth:image.size.width];
        [_commentView setHeight:image.size.height];
    }
    return _commentView;
}

- (UILabel*)commentCount {
    if (!_commentCount) {
        _commentCount = [[UILabel alloc] init];
        [_commentCount setX:CGRectGetMaxX(_commentView.frame) + 5];
        [_commentCount setWidth:30];
        [_commentCount setHeight:20];
        [_commentCount setCenterY:CGRectGetMidY(_commentView.frame)];
        _commentCount.font = [UIFont systemFontOfSize:12];
        _commentCount.textAlignment = NSTextAlignmentLeft;
        _commentCount.textColor = [UIColor iOS7lightGrayColor];
    }
    return _commentCount;
}

- (UIButton*)fileBgView {
    if (!_fileBgView) {
        _fileBgView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fileBgView setX:CGRectGetMinX(_headerView.frame)];
        [_fileBgView setWidth:CGRectGetWidth(_bgView.bounds) - CGRectGetMinX(_fileBgView.frame) * 2];
        [_fileBgView setHeight:30];
        [_fileBgView setBackgroundImage:kButtonBackgroundImage_normal forState:UIControlStateNormal];
        [_fileBgView setBackgroundImage:kButtonBackgroundImage_highlighted forState:UIControlStateHighlighted];
        [_fileBgView addTarget:self action:@selector(fileButtonPress) forControlEvents:UIControlEventTouchUpInside];
        
        [_fileBgView addSubview:self.fileHeadView];
        [_fileBgView addSubview:self.fileName];
    }
    return _fileBgView;
}

- (UIImageView*)fileHeadView {
    if (!_fileHeadView) {
        UIImage *image = [UIImage imageNamed:@"S_Icon_PPT"];
        _fileHeadView = [[UIImageView alloc] init];
        [_fileHeadView setX:5];
        [_fileHeadView setWidth:image.size.width];
        [_fileHeadView setHeight:image.size.height];
        [_fileHeadView setCenterY:CGRectGetMidY(_fileBgView.frame)];
    }
    return _fileHeadView;
}

- (UILabel*)fileName {
    if (!_fileName) {
        _fileName = [[UILabel alloc] init];
        [_fileName setX:CGRectGetMaxX(_fileHeadView.frame) + 10];
        [_fileName setWidth:CGRectGetWidth(_fileBgView.bounds) - CGRectGetMinX(_fileName.frame) - 10];
        [_fileName setHeight:20];
        [_fileName setCenterY:CGRectGetMidY(_fileBgView.frame)];
        _fileName.font = [UIFont systemFontOfSize:12];
        _fileName.textAlignment = NSTextAlignmentLeft;
        _fileName.textColor = [UIColor lightGrayColor];
    }
    return _fileName;
}

- (RecordAudioPlayView*)audioView {
    if (!_audioView) {
        _audioView = [[RecordAudioPlayView alloc] init];
        [_audioView setX:CGRectGetMinX(_headerView.frame)];
    }
    return _audioView;
}

- (UIButton*)positionBgView {
    if (!_positionBgView) {
        UIImage *image = [UIImage imageNamed:@"lbsmap"];
        _positionBgView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_positionBgView setX:CGRectGetMinX(_headerView.frame)];
        [_positionBgView setWidth:CGRectGetWidth(_bgView.bounds) - CGRectGetMinX(_positionBgView.frame) * 2];
        [_positionBgView setHeight:image.size.height + 10];
        [_positionBgView setBackgroundImage:kButtonBackgroundImage_normal forState:UIControlStateNormal];
        [_positionBgView setBackgroundImage:kButtonBackgroundImage_highlighted forState:UIControlStateHighlighted];
        [_positionBgView addTarget:self action:@selector(positionButtonPress) forControlEvents:UIControlEventTouchUpInside];
        
        [_positionBgView addSubview:self.positionHeadView];
        [_positionBgView addSubview:self.positionTitle];
        [_positionBgView addSubview:self.positionDetail];
    }
    return _positionBgView;
}

- (UIImageView*)positionHeadView {
    if (!_positionHeadView) {
        UIImage *image = [UIImage imageNamed:@"lbsmap"];
        _positionHeadView = [[UIImageView alloc] initWithImage:image];
        [_positionHeadView setX:5];
        [_positionHeadView setWidth:image.size.width];
        [_positionHeadView setHeight:image.size.height];
        [_positionHeadView setCenterY:CGRectGetMidY(_positionBgView.frame)];
    }
    return _positionHeadView;
}

- (UILabel*)positionTitle {
    if (!_positionTitle) {
        _positionTitle = [[UILabel alloc] init];
        [_positionTitle setX:CGRectGetMaxX(_positionHeadView.frame) + 10];
        [_positionTitle setY:0];
        [_positionTitle setWidth:CGRectGetWidth(_positionBgView.bounds) - CGRectGetMinX(_positionTitle.frame) - 10];
        [_positionTitle setHeight:CGRectGetHeight(_positionBgView.bounds) / 2.0];
        _positionTitle.font = [UIFont systemFontOfSize:14];
        _positionTitle.textAlignment = NSTextAlignmentLeft;
        _positionTitle.textColor = [UIColor blackColor];
    }
    return _positionTitle;
}

- (UILabel*)positionDetail {
    if (!_positionDetail) {
        _positionDetail = [[UILabel alloc] init];
        [_positionDetail setX:CGRectGetMaxX(_positionHeadView.frame) + 10];
        [_positionDetail setY:CGRectGetMaxY(_positionTitle.frame)];
        [_positionDetail setWidth:CGRectGetWidth(_positionBgView.bounds) - CGRectGetMinX(_positionTitle.frame) - 10];
        [_positionDetail setHeight:CGRectGetHeight(_positionBgView.bounds) / 2.0];
        _positionDetail.font = [UIFont systemFontOfSize:14];
        _positionDetail.textAlignment = NSTextAlignmentLeft;
        _positionDetail.textColor = [UIColor lightGrayColor];
    }
    return _positionDetail;
}

- (UIImageView*)configImageView {
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setWidth:kWidth_imageView];
    [imageView setHeight:kWidth_imageView];
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [imageView addGestureRecognizer:tap];
    
    return imageView;
}

- (UIImageView*)imageView0 {
    if (!_imageView0) {
        _imageView0 = [self configImageView];
        _imageView0.tag = kTag_imageView;
    }
    return _imageView0;
}

- (UIImageView*)imageView1 {
    if (!_imageView1) {
        _imageView1 = [self configImageView];
        _imageView1.tag = kTag_imageView + 1;
    }
    return _imageView1;
}

- (UIImageView*)imageView2 {
    if (!_imageView2) {
        _imageView2 = [self configImageView];
        _imageView2.tag = kTag_imageView + 2;
    }
    return _imageView2;
}

- (UIImageView*)imageView3 {
    if (!_imageView3) {
        _imageView3 = [self configImageView];
        _imageView3.tag = kTag_imageView + 3;
    }
    return _imageView3;
}

- (UIImageView*)imageView4 {
    if (!_imageView4) {
        _imageView4 = [self configImageView];
        _imageView4.tag = kTag_imageView + 4;
    }
    return _imageView4;
}

- (UIImageView*)imageView5 {
    if (!_imageView5) {
        _imageView5 = [self configImageView];
        _imageView5.tag = kTag_imageView + 5;
    }
    return _imageView5;
}

- (UIImageView*)imageView6 {
    if (!_imageView6) {
        _imageView6 = [self configImageView];
        _imageView6.tag = kTag_imageView + 6;
    }
    return _imageView6;
}

- (UIImageView*)imageView7 {
    if (!_imageView7) {
        _imageView7 = [self configImageView];
        _imageView7.tag = kTag_imageView + 7;
    }
    return _imageView7;
}

- (UIImageView*)imageView8 {
    if (!_imageView8) {
        _imageView8 = [self configImageView];
        _imageView8.tag = kTag_imageView + 8;
    }
    return _imageView8;
}
@end
