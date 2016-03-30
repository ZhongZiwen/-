//
//  RecordDetail_headCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "RecordDetail_headCell.h"
#import "Record.h"
#import "RecordAudioPlayView.h"
#import "FileModel.h"
//#import "PhotoBrowser.h"
//#import "PhotoItem.h"
#import "PhotoBroswerVC.h"

#define kWidth_headerView 35
#define kWidth_imageView 80
#define kButtonBackgroundImage_normal [UIImage imageWithColor:[UIColor colorWithWhite:0.92 alpha:1.0]]
#define kButtonBackgroundImage_highlighted [UIImage imageWithColor:[UIColor colorWithWhite:0.87 alpha:1.0]]
#define kTag_imageView 43654

@interface RecordDetail_headCell ()

@property (strong, nonatomic) UIImageView *headerView;              // 头像
@property (strong, nonatomic) UILabel *nameLabel;                   // 用户名
@property (strong, nonatomic) UILabel *commentLabel;                // 评论数

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

@implementation RecordDetail_headCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = kView_BG_Color;
        _imageViewsArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        [self.contentView addSubview:self.headerView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.contentLabel];
        //        [self.contentView addSubview:self.commentLabel];
        [self.contentView addSubview:self.timeAndfromLabel];
        
        [self.contentView addSubview:self.imageView0];
        [self.contentView addSubview:self.imageView1];
        [self.contentView addSubview:self.imageView2];
        [self.contentView addSubview:self.imageView3];
        [self.contentView addSubview:self.imageView4];
        [self.contentView addSubview:self.imageView5];
        [self.contentView addSubview:self.imageView6];
        [self.contentView addSubview:self.imageView7];
        [self.contentView addSubview:self.imageView8];
    }
    return self;
}

#pragma mark - event response
- (void)tapGesture:(UITapGestureRecognizer*)sender {
    UIImageView *selectedImageView = (UIImageView *)sender.view;
//    PhotoItem *selectedItem = _imageViewsArray[selectedImageView.tag - kTag_imageView];
//    
//    [PhotoBrowser sharedInstance].backgroundScale = 1.0;
//    [[PhotoBrowser sharedInstance] showWithItems:_imageViewsArray selectedItem:selectedItem];
    
    
    [PhotoBroswerVC show:self.handleVC type:PhotoBroswerVCTypeZoom index:selectedImageView.tag - kTag_imageView photoModelBlock:^NSArray *{
        return _imageViewsArray;
    }];
}

- (void)headerTap {
    if (self.headerViewTapBlock) {
        self.headerViewTapBlock();
    }
}

- (void)fileButtonPress {
    if (self.fileBlock) {
        self.fileBlock();
    }
}

- (void)positionButtonPress {
    if (self.positionBlock) {
        self.positionBlock();
    }
}

- (void)configWithModel:(Record *)model {
    [_fileBgView removeFromSuperview];
    [_audioView removeFromSuperview];
    [_positionBgView removeFromSuperview];
    
    [_headerView sd_setImageWithURL:[NSURL URLWithString:model.user.icon] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
    _nameLabel.text = model.user.name;
    _timeAndfromLabel.text = [NSString stringWithFormat:@"%@ 来自%@(%@)", [model.created stringTimestampWithoutYear], model.from.sourceName, model.from.name];
    NSRange fromRange = [_timeAndfromLabel.text rangeOfString:[NSString stringWithFormat:@"来自%@(%@)", model.from.sourceName, model.from.name]];
    [_timeAndfromLabel addLinkToTransitInformation:@{@"from" : model.from.id} withRange:fromRange];
    
    [_contentLabel setWidth:kScreen_Width - CGRectGetMinX(_contentLabel.frame) * 2];
    _contentLabel.text = model.content;
    [_contentLabel sizeToFit];
    
    // 显示@人
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
            [_contentLabel addLinkToTransitInformation:@{@"user" : tempUser} withRange:range];
        }
    }
    
    // 如果有文档，则只显示文档
    if ([model.fileType integerValue] == 2) {
        [self.contentView addSubview:self.fileBgView];
        [_fileBgView setY:CGRectGetMaxY(_contentLabel.frame) + 10];
        _fileName.text = model.file.name;
        
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
        [self.contentView addSubview:self.audioView];
        [_audioView setY:CGRectGetMaxY(_contentLabel.frame) + 10];
        _audioView.second = model.audio.second;
        [_audioView setUrl:[NSURL URLWithString:model.audio.url]];
        //        [_audioView setUrl:[NSURL URLWithString:@"https://rs.ingageapp.com/upload/f/151745/2015/10/15/0ee37c287561435cb3e055739a1bfca1.amr"]];
    }
    
    // 有地理信息，则显示地理信息
    if (model.position) {
        [self.contentView addSubview:self.positionBgView];
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
            UIImageView *imageView = (UIImageView*)[self.contentView viewWithTag:kTag_imageView + i];
            if (i < model.imageFilesArray.count) {
                FileModel *file = model.imageFilesArray[i];
                imageView.hidden = NO;
                [imageView sd_setImageWithURL:[NSURL URLWithString:file.minUrl] placeholderImage:[UIImage imageNamed:@"user_icon_default_90"]];
                [imageView setX:CGRectGetMinX(_headerView.frame) + (kWidth_imageView + 10) * (i % 3)];
                [imageView setY:originY + (kWidth_imageView + 10) * (i / 3)];
                [imageView setWidth:kWidth_imageView];
                [imageView setHeight:kWidth_imageView];
                
//                PhotoItem *item = [[PhotoItem alloc] init];
//                item.url = file.url;
//                item.minUrl = file.minUrl;
//                item.srcImageView = imageView;
//                [_imageViewsArray addObject:item];
                
                
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
            UIImageView *imageView = (UIImageView*)[self.contentView viewWithTag:kTag_imageView + i];
            imageView.hidden = YES;
        }
    }
}

+ (CGFloat)cellHeightWithObj:(Record *)obj {
    CGFloat cellHeight = 0;
    
    cellHeight += 10;
    cellHeight += kWidth_headerView;
    cellHeight += [RecordDetail_headCell contentLabelHeightWithString:obj.content] + 10;
    
    if ([obj.fileType integerValue] == 2) {
        cellHeight += 30;
        cellHeight += 10;
    }else {
        cellHeight += [RecordDetail_headCell audioButtonHeightWithModel:obj.audio];
        cellHeight += [RecordDetail_headCell positionButtonHeightWithString:obj.position];
        cellHeight += [RecordDetail_headCell imagesViewHeightWithArray:obj.imageFilesArray];
    }
    cellHeight += 10;
    
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
        return image.size.height + 10 + 10;
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

#pragma mark - setters and getters
- (UIImageView*)headerView {
    if (!_headerView) {
        _headerView = [[UIImageView alloc] init];
        [_headerView setX:15];
        [_headerView setY:10];
        [_headerView setWidth:kWidth_headerView];
        [_headerView setHeight:kWidth_headerView];
        _headerView.contentMode = UIViewContentModeScaleAspectFill;
        _headerView.clipsToBounds = YES;
        _headerView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTap)];
        [_headerView addGestureRecognizer:tap];
    }
    return _headerView;
}

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setX:CGRectGetMaxX(_headerView.frame) + 5];
        [_nameLabel setY:CGRectGetMinY(_headerView.frame)];
        [_nameLabel setWidth:kScreen_Width - CGRectGetMinX(_nameLabel.frame) - 20];
        [_nameLabel setHeight:20];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}

- (TTTAttributedLabel*)timeAndfromLabel {
    if (!_timeAndfromLabel) {
        _timeAndfromLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_nameLabel.frame), CGRectGetMaxY(_nameLabel.frame), kScreen_Width - CGRectGetMinX(_timeAndfromLabel.frame) - 10, 15)];
        _timeAndfromLabel.font = [UIFont systemFontOfSize:11];
        _timeAndfromLabel.textColor = [UIColor iOS7lightGrayColor];
        _timeAndfromLabel.textAlignment = NSTextAlignmentLeft;
        _timeAndfromLabel.linkAttributes = kLinkAttributes;
        _timeAndfromLabel.activeLinkAttributes = kLinkAttributesActive;
    }
    return _timeAndfromLabel;
}

- (TTTAttributedLabel*)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_headerView.frame), CGRectGetMaxY(_headerView.frame) + 10, kScreen_Width - CGRectGetMinX(_contentLabel.frame) * 2, 20)];
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
        _contentLabel.numberOfLines = 0;
        _contentLabel.linkAttributes = kLinkAttributes;
        _contentLabel.activeLinkAttributes = kLinkAttributesActive;
    }
    return _contentLabel;
}

- (UILabel*)commentLabel {
    if (!_commentLabel) {
        _commentLabel = [[UILabel alloc] init];
        [_commentLabel setX:CGRectGetMinX(_headerView.frame)];
        [_commentLabel setWidth:100];
        [_commentLabel setHeight:15];
        _commentLabel.font = [UIFont systemFontOfSize:11];
        _commentLabel.textColor = [UIColor iOS7lightGrayColor];
        _commentLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _commentLabel;
}

- (UIButton*)fileBgView {
    if (!_fileBgView) {
        _fileBgView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fileBgView setX:CGRectGetMinX(_headerView.frame)];
        [_fileBgView setWidth:kScreen_Width - CGRectGetMinX(_fileBgView.frame) * 2];
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
        _fileHeadView = [[UIImageView alloc] initWithImage:image];
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
        [_positionBgView setWidth:kScreen_Width - CGRectGetMinX(_positionBgView.frame) * 2];
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
