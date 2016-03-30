//
//  ChatTableViewCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/26.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ChatTableViewCell.h"
#import "NSString+Common.h"
#import "EmotionMatchParser.h"
#import "UIImageViewBrowser.h"

#import "ChatMessage.h"
#import "EmotionLabel.h"
#import <UIImageView+WebCache.h>
#import "AFNHttp.h"
#import "CommonFuntion.h"
#import "IM_FMDB_FILE.h"
#import "IMAudioPlayView.h"
#import "CommonFunc.h"

#define kPaddingTopWidth        10
#define kPaddingLeftWidth       15
#define kTimeLabelHeight        20
#define kHeadImageViewWidth     44
#define kTextContentBGViewWidth (kScreen_Width - 2*(kPaddingLeftWidth + kHeadImageViewWidth) - 20)
#define kInformationLabelMaxSize (kScreen_Width - 2*44 - 30)

#define kTextBackgroundColor_Me [UIColor colorWithHexString:@"99e95b"]//[UIColor colorWithRed:(CGFloat)17/255.0 green:(CGFloat)117/255.0 blue:222/255.0 alpha:1.0]
#define kTextBackgroundColor_Other [UIColor colorWithRed:(CGFloat)236/255.0 green:(CGFloat)236/255.0 blue:236/255.0 alpha:1.0] //[UIColor colorWithHexString:@"ffffff"]
#define kInfoBackgroundColor [UIColor colorWithHexString:@"d1d1d1"]//[UIColor colorWithRed:(CGFloat)175/255.0 green:(CGFloat)175/255.0 blue:175/255.0 alpha:1.0]

@interface ChatTableViewCell ()

@property (nonatomic, strong) UILabel *contactNameLabel; //成员名字
@property (nonatomic, strong) UIImageView *headImageView;


@property (nonatomic, strong) UIView *mBackgroundView;  // 内容的背景视图

// ChatMessageTypeText
@property (nonatomic, strong) EmotionLabel *emotionLabel;


// ChatMessageTypeVoice
@property (nonatomic, strong) UILabel *voiceSecondLabel;

//ChatMessageTypeFile
@property (nonatomic, strong) UIImageView *fileImg; //文件图标
@property (nonatomic, strong) UILabel *titelLabel; //文件名
@property (nonatomic, strong) UILabel *sizeLabel; //文件大小
@property (nonatomic, strong) UILabel *downLable; //点击下载

// ChatMessageTypeInformation
@property (nonatomic, strong) UIView *informationBGView;
@property (nonatomic, strong) UILabel *informationLabel;

@property (nonatomic, strong) EmotionMatchParser *parser;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;   // 网络请求标识

@property (nonatomic, strong) ChatMessage *chatMsg;     // 数据源

@property (nonatomic, strong) UIImageView *imgSelect;

@property (nonatomic, strong) NSTimer *startTimer;
@property (nonatomic, assign) NSInteger sendTime;

// 音频
@property (strong, nonatomic) IMAudioPlayView *audioView;
// 未读标识
@property (nonatomic, strong) UIView *unReadView;

@end

@implementation ChatTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        // 创建时间
        [self.contentView addSubview:self.timeLabel];
        
        // 成员昵称
        [self.contentView addSubview:self.contactNameLabel];
        
        // 创建头像
        [self.contentView addSubview:self.headImageView];
        
        // 添加照片视图(不用添加到背景视图)
        [self.contentView addSubview:self.contentImageView];
        
        // 添加ActivityIndicatorView
        [self.contentView addSubview:self.indicatorView];
        
        // 添加内容背景视图
        [self.contentView addSubview:self.mBackgroundView];
//        [self.contentView addSubview:self.imgBgView];
        
        // 添加文本视图
        [self.mBackgroundView addSubview:self.emotionLabel];

        // 添加voice视图
        
        
        
//        [self.mBackgroundView addSubview:self.voiceSecondLabel];
//        [self.mBackgroundView addSubview:self.voiceIcon];
        
//        [self.mBackgroundView addSubview:self.audioView];
        
        
        // 添加information视图
        [self.contentView addSubview:self.informationBGView];
        [self.informationBGView addSubview:self.informationLabel];
        
        [self.contentView addSubview:self.imgSelect];
        //添加文件试图控件
        [self.mBackgroundView addSubview:self.fileImg];
        [self.mBackgroundView addSubview:self.titelLabel];
        [self.mBackgroundView addSubview:self.sizeLabel];
        [self.mBackgroundView addSubview:self.downLable];

        
//        if (!_parser) {
//            _parser = [[EmotionMatchParser alloc] init];
//        }
        
        [self.contentView addSubview:self.unReadView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVoice) name:@"stopVoice" object:nil];
        
//        UIImageView *ImageView01 = [[UIImageView alloc] init];
//        [ImageView01 setFrame:CGRectMake(90, self.headImageView.frame.origin.y, 120, 180)];
//        [ImageView01 setImage:[UIImage imageNamed:@"style.jpg"]];
//        [self.contentView addSubview:ImageView01];
//        
//        UIImage *bubble = [UIImage imageNamed:@"bubble_mine_normal"];
//        UIImageView *ImageView = [[UIImageView alloc] init];
//        [ImageView setFrame:ImageView01.frame];
//        //创建一个内容可拉伸，而边角不拉伸的图片，需要两个参数，第一个是左边不拉伸区域的宽度，第二个参数是上面不拉伸的高度。那么接下来的一个像素会被拉伸
//        [ImageView setImage:[bubble stretchableImageWithLeftCapWidth:15 topCapHeight:30]];
//        
//        CALayer *layer = ImageView.layer;
//        layer.frame = (CGRect){{0,0},ImageView.layer.frame.size};
//        ImageView01.layer.mask = layer;
//        [ImageView01 setNeedsDisplay];
        
    }
    return self;
}

- (void)configWithObject:(ChatMessage *)chatMsg withType:(NSString *)type withIsShow:(NSString *)showSting{
    if (_parser) {
        _parser = nil;
    }
    _parser = [[EmotionMatchParser alloc] init];
    
    [_audioView removeFromSuperview];
    if (chatMsg.isMe) {     // 本人
        [self.audioView setLeftOrRight:@"voice_sign_mine_"];
    }else{
        [self.audioView setLeftOrRight:@"voice_sign_other_"];
    }
    [self.mBackgroundView addSubview:_audioView];
    
    _audioView.second = [NSNumber numberWithInteger:chatMsg.msg_voiceDuration*1000];
    _audioView.index = _index;
    NSString *fileDirPath = [CommonFunc getDocumentsPathByDirName:@"AudioDownload"];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",fileDirPath,chatMsg.msg_voiceName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [_audioView setUrl:[NSURL URLWithString:filePath]];
    }else{
        [_audioView setUrl:[NSURL URLWithString:chatMsg.msg_voiceUrl]];
    }

    if (![CommonFuntion checkNullForValue:chatMsg.user_name]) {
       NSArray *contactArray = [NSArray arrayWithArray:[IM_FMDB_FILE result_IM_AddressBookOneContact:chatMsg.msg_uid]];
        if (contactArray.count > 0) {
            ContactModel *contaModel = contactArray[0];
            chatMsg.user_name = contaModel.contactName;
            chatMsg.user_uid = [NSString stringWithFormat:@"%ld", contaModel.userID];
            chatMsg.user_icon = contaModel.imgHeaderName;
//            chatMsg.user_uid = contaModel.imgHeaderName;
        }
    }
    self.timeLabel.text = [self changeTime:chatMsg.msg_time];//[NSString transDateWithTimeInterval:chatMsg.msg_time];
//    self.timeLabel.text = [CommonFuntion getStringForTime:[chatMsg.msg_time longLongValue]];
    CGRect frame;
    UIImage *bubble;
    UIImage *voiceIconImage;
    NSInteger selectWidth;
    NSInteger selectX;
    NSInteger mY; //下移高度
    if ([type isEqualToString:@"delete"]) {
        selectWidth = 15;
        selectX = 30;
    } else {
        selectWidth = 0;
        selectX = 0;
    }
    if ([showSting isEqualToString:@"show"] && !chatMsg.isMe) {
        mY = 25;
    } else {
        mY = 0;
    }
    
    for(UIView *item in self.contentView.subviews){
        if([item isKindOfClass:[UIActivityIndicatorView class]]){
            NSInteger tag = [item tag];
            if(tag==10000){
                [item removeFromSuperview];
            }
        }
        
        if([item isKindOfClass:[UIImageView class]]){
            NSInteger tag = [item tag];
            if(tag>=10001){
                [item removeFromSuperview];
            }
        }
    }
    
    
    //指示器
    UIActivityIndicatorView *actionView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
    actionView.hidesWhenStopped = YES;
    actionView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    actionView.tag = 10000;
    [self.contentView addSubview:actionView];
    
    //失败图标
    UIImageView *imgFail = [[UIImageView alloc] initWithFrame:CGRectZero];
    imgFail.image = [UIImage imageNamed:@"IM_message_fail"];
    imgFail.tag = 10001;
//    [self.contentView addSubview:imgFail];

    NSString *imgName = @"";
    if (chatMsg.isSelect) {
        imgName = @"multi_graph_select";
    } else {
       imgName = @"accessory_message_normal";
    }
    _imgSelect.image = [UIImage imageNamed:imgName];
    
    if (chatMsg.isMe) {     // 本人
        bubble = [UIImage imageNamed:@"bubble_mine_normal"];
        
        frame = _headImageView.frame;
        frame.origin.x = kScreen_Width - kPaddingLeftWidth - kHeadImageViewWidth - selectX;
        _headImageView.frame = frame;
        _mBackgroundView.backgroundColor = kTextBackgroundColor_Me;
        
        voiceIconImage = [UIImage imageNamed:@"voice_sign_mine_3"];
        _voiceIcon.image = voiceIconImage;
        _voiceIcon.animationImages = @[[UIImage imageNamed:@"voice_sign_mine_1"],
                                       [UIImage imageNamed:@"voice_sign_mine_2"],
                                       [UIImage imageNamed:@"voice_sign_mine_3"]];
        
        
    }else {     // 非本人
        
        bubble = [UIImage imageNamed:@"bubble_other_click"];

        frame = _headImageView.frame;
        frame.origin.x = kPaddingLeftWidth;
        _headImageView.frame = frame;
        _mBackgroundView.backgroundColor = kTextBackgroundColor_Other;
        
        voiceIconImage = [UIImage imageNamed:@"voice_sign_other_3"];
        _voiceIcon.image = voiceIconImage;
        _voiceIcon.animationImages = @[[UIImage imageNamed:@"voice_sign_other_1"],
                                       [UIImage imageNamed:@"voice_sign_other_2"],
                                       [UIImage imageNamed:@"voice_sign_other_3"]];
        
    }
    
    NSString *iconURL = @"";
    if ([chatMsg.user_icon hasPrefix:@"http://"] || [chatMsg.user_icon hasPrefix:@"https://"]) {
        iconURL = chatMsg.user_icon;
    } else {
        iconURL = [NSString stringWithFormat:@"%@%@", GET_IM_ICON_URL, chatMsg.user_icon];
    }
    
    [_headImageView sd_setImageWithURL:[NSURL URLWithString:iconURL] placeholderImage:[UIImage imageNamed:@"user_icon_default_90"]];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playVoice:)];
//    [_mBackgroundView addGestureRecognizer:tap];
    _unReadView.hidden = YES;
    if ([chatMsg.type isEqualToString:@"1"]) {
        _imgSelect.hidden = NO;
        //区分是不是单纯的文本
        if (chatMsg.hasResourceView) {
            
            if (chatMsg.msg_type == ChatMessageTypeFile) {
                _titelLabel.hidden = NO;
                _sizeLabel.hidden = NO;
                _fileImg.hidden = NO;
                _downLable.hidden = NO;
            } else {
                _titelLabel.hidden = YES;
                _sizeLabel.hidden = YES;
                _fileImg.hidden = YES;
                _downLable.hidden = YES;
            }
            switch (chatMsg.msg_type) {
                case ChatMessageTypeImage:
                {
                    _headImageView.hidden = NO;
                    _contentImageView.hidden = NO;
                    
                    _mBackgroundView.hidden = YES;
                    _emotionLabel.hidden = YES;
                    _voiceSecondLabel.hidden = YES;
                    _voiceIcon.hidden = YES;
                    _informationBGView.hidden = YES;
                    
                    _titelLabel.hidden = YES;
                    _sizeLabel.hidden = YES;
                    _fileImg.hidden = YES;
                    _downLable.hidden = YES;
                    
                    _audioView.hidden = YES;
                    
                    frame = _contentImageView.frame;
                    frame.origin.y = _headImageView.frame.origin.y;
                    frame.size.width = chatMsg.msg_imageWidth/2.0;
                    frame.size.height = chatMsg.msg_imageHeight/2.0;
                    if (chatMsg.isMe) {
                        frame.origin.x = kScreen_Width - kPaddingLeftWidth - kHeadImageViewWidth - 10 - chatMsg.msg_imageWidth/2.0 - selectX;
                        _imgSelect.frame = CGRectMake(kScreen_Width - selectX, frame.origin.y + (frame.size.height - selectWidth) / 2, selectWidth, selectWidth);
                        _contentImageView.frame = frame;
                            switch (chatMsg.msg_state) {
                                case MessageStateSend:
                                {
                                    actionView.frame = CGRectMake(_contentImageView.frame.origin.x - 24, frame.origin.y + (frame.size.height - 20) / 2, 20, 20);
                                    [actionView startAnimating];
                                    imgFail.hidden = YES;
                                    [imgFail removeFromSuperview];
                                    if (_BackMessageIdBlock) {
                                        _BackMessageIdBlock(chatMsg);
                                    }
                                }
                                    break;
                                case MessageStateFail:
                                {
                                    imgFail.frame = CGRectMake(_contentImageView.frame.origin.x - 24, frame.origin.y + (frame.size.height - 20) / 2, 20, 20);
                                    actionView = nil;
                                    [self.contentView addSubview:imgFail];
                                }
                                    break;
                                case MessageStateRecevied:
                                {
                                    imgFail.hidden = YES;
                                    actionView.hidden = YES;
                                    actionView = nil;
                                    [imgFail removeFromSuperview];
                                }
                                    break;
                                    
                                default:
                                    break;
                            }
                    }else {
                        frame.origin.x = kPaddingLeftWidth + kHeadImageViewWidth + 10;
                        _imgSelect.frame = CGRectMake(kScreen_Width - selectX, frame.origin.y + (frame.size.height - selectWidth) / 2, selectWidth, selectWidth);
                        
                        _contentImageView.frame = CGRectMake(frame.origin.x, frame.origin.y + mY, frame.size.width, frame.size.height);
                    }
                    [_contentImageView sd_setImageWithURL:[NSURL URLWithString:chatMsg.msg_imageUrl] placeholderImage:[UIImage imageNamed:@"Expense_Detail_PhotoNoImageView"]];

                    [self strechableViewWith:_contentImageView andBubbleImage:bubble];
                }
                    break;
                case ChatMessageTypeVoice:
                {
                    _headImageView.hidden = NO;
                    _mBackgroundView.hidden = NO;
                    _voiceSecondLabel.hidden = NO;
                    _voiceIcon.hidden = NO;
                    
                    _audioView.hidden = NO;
                    
                    _emotionLabel.hidden = YES;
                    _contentImageView.hidden = YES;
                    _informationBGView.hidden = YES;
                    
                    _titelLabel.hidden = YES;
                    _sizeLabel.hidden = YES;
                    _fileImg.hidden = YES;
                    _downLable.hidden = YES;
                    
                    frame = _mBackgroundView.frame;
                    frame.origin.y = _headImageView.frame.origin.y + mY;
                    frame.size.width = 80;
                    frame.size.height = kHeadImageViewWidth;
                    
                    
                    
                    
                    if (chatMsg.isMe) {
                        
                        frame.origin.x = kScreen_Width - kPaddingLeftWidth - kHeadImageViewWidth - 10 - 80 - selectX;
                        _mBackgroundView.frame = frame;
                        
                        _voiceIcon.frame = CGRectMake(CGRectGetWidth(_mBackgroundView.bounds) - 20 - voiceIconImage.size.width, (CGRectGetHeight(_mBackgroundView.bounds) - voiceIconImage.size.height)/2.0, voiceIconImage.size.width, voiceIconImage.size.height);
                        _voiceSecondLabel.frame = CGRectMake(_voiceIcon.frame.origin.x - 10 - 30, _voiceIcon.frame.origin.y, 30, voiceIconImage.size.height);
                        _voiceSecondLabel.textAlignment = NSTextAlignmentRight;
                        _voiceSecondLabel.textColor = [UIColor whiteColor];
                        _voiceSecondLabel.text = [NSString stringWithFormat:@"%ld", chatMsg.msg_voiceDuration];
                        _imgSelect.frame = CGRectMake(kScreen_Width - selectX, frame.origin.y + (frame.size.height - selectWidth) / 2, selectWidth, selectWidth);
                            switch (chatMsg.msg_state) {
                                case MessageStateSend:
                                {
                                    actionView.frame = CGRectMake(_mBackgroundView.frame.origin.x - 24, frame.origin.y + (frame.size.height - 20) / 2, 20, 20);
                                    [actionView startAnimating];
                                    imgFail.hidden = YES;
                                    [imgFail removeFromSuperview];
                                    if (_BackMessageIdBlock) {
                                        _BackMessageIdBlock(chatMsg);
                                    }
                                }
                                    break;
                                case MessageStateFail:
                                {
                                    imgFail.frame = CGRectMake(_mBackgroundView.frame.origin.x - 24, frame.origin.y + (frame.size.height - 20) / 2, 20, 20);
                                     actionView = nil;
                                    [self.contentView addSubview:imgFail];
                                }
                                    break;
                                case MessageStateRecevied:
                                {
                                    imgFail.hidden = YES;
                                    actionView.hidden = YES;
                                    actionView = nil;
                                    [imgFail removeFromSuperview];
                                }
                                    break;
                                default:
                                    break;
                            }
                    }else {
                        if (!chatMsg.isRead) {
                            _unReadView.hidden = NO;
                        }
                        frame.origin.x = kPaddingLeftWidth + kHeadImageViewWidth + 10;
                        _mBackgroundView.frame = frame;
                        _unReadView.frame = CGRectMake(frame.origin.x  + _mBackgroundView.frame.size.width + 10, frame.origin.y, 4, 4);
                        _voiceIcon.frame = CGRectMake( 20, (CGRectGetHeight(_mBackgroundView.bounds) - voiceIconImage.size.height)/2.0, voiceIconImage.size.width, voiceIconImage.size.height);
                        _voiceSecondLabel.frame = CGRectMake(_voiceIcon.frame.origin.x + voiceIconImage.size.width + 10, _voiceIcon.frame.origin.y, 30, voiceIconImage.size.height);
                        _voiceSecondLabel.textAlignment = NSTextAlignmentLeft;
                        _voiceSecondLabel.textColor = [UIColor blackColor];
                        _voiceSecondLabel.text = [NSString stringWithFormat:@"%ld''", chatMsg.msg_voiceDuration];
                        _imgSelect.frame = CGRectMake(kScreen_Width - selectX, frame.origin.y + (frame.size.height - selectWidth) / 2, selectWidth, selectWidth);
                    }
                    
                    [self strechableViewWith:_mBackgroundView andBubbleImage:bubble];
                }
                    break;
                case ChatMessageTypeFile:
                {
                    _headImageView.hidden = NO;
                    _mBackgroundView.hidden = NO;
                    _voiceSecondLabel.hidden = YES;
                    _voiceIcon.hidden = YES;
                    _emotionLabel.hidden = YES;
                    _contentImageView.hidden = YES;
                    _informationBGView.hidden = YES;
                    
                    _audioView.hidden = YES;
                    
                    _titelLabel.hidden = NO;
                    _sizeLabel.hidden = NO;
                    _fileImg.hidden = NO;
                    _downLable.hidden = NO;
                    
                    _titelLabel.text = chatMsg.msg_fileName;
                    _sizeLabel.text = [NSString stringWithFormat:@"%.2fKb", [chatMsg.msg_fileSize longLongValue] / 1000.0];
                    _downLable.text = @"点击下载";
                    _fileImg.image = [UIImage imageNamed:@"file_document_32"];
                    frame = _mBackgroundView.frame;
                    frame.origin.y = _headImageView.frame.origin.y + mY;
                    frame.size.width = 200;
                    frame.size.height = kHeadImageViewWidth + 20;
                    if (chatMsg.isMe) {
                        frame.origin.x = kScreen_Width - kPaddingLeftWidth - kHeadImageViewWidth - 10 - 200 - selectX;
                        _mBackgroundView.frame = frame;
                        _fileImg.frame = CGRectMake(kPaddingTopWidth * 2, kPaddingTopWidth, 34, 44);
                        _titelLabel.frame = CGRectMake(kPaddingTopWidth * 3 + 34, kPaddingTopWidth, frame.size.width - kPaddingTopWidth * 3 - 34, 20);
                        _sizeLabel.frame = CGRectMake(kPaddingTopWidth * 3 + 34, kPaddingTopWidth + 20, frame.size.width - kPaddingTopWidth * 3 + 24, 20);
                        _downLable.frame = CGRectMake(frame.size.width - 70, kPaddingTopWidth + 20, 60, 20);
                    } else {
                        frame.origin.x = kPaddingLeftWidth + kHeadImageViewWidth + 10;
                        _mBackgroundView.frame = frame;
                        _fileImg.frame = CGRectMake(kPaddingTopWidth * 2, kPaddingTopWidth, 34, 44);
                        _titelLabel.frame = CGRectMake(kPaddingTopWidth * 3 + 34, kPaddingTopWidth, frame.size.width - kPaddingTopWidth * 3 - 34, 20);
                        _sizeLabel.frame = CGRectMake(kPaddingTopWidth * 3 + 34, kPaddingTopWidth + 20, frame.size.width - kPaddingTopWidth * 3 + 24, 20);
                        _downLable.frame = CGRectMake(frame.size.width - 70, kPaddingTopWidth + 20, 60, 20);
                        }
                    [self strechableViewWith:_mBackgroundView andBubbleImage:bubble];
                }
                    break;
                default:
                    break;
            }
        } else {
            _headImageView.hidden = NO;
            _mBackgroundView.hidden = NO;
            _emotionLabel.hidden = NO;
            _contentImageView.hidden = YES;
            _voiceSecondLabel.hidden = YES;
            _voiceIcon.hidden = YES;
            _informationBGView.hidden = YES;
            
            _audioView.hidden = YES;
            
            _titelLabel.hidden = YES;
            _sizeLabel.hidden = YES;
            _fileImg.hidden = YES;
            _downLable.hidden = YES;
            
            // 设置表情文字内容最大宽度
            _parser.width = kTextContentBGViewWidth - 28;
            _parser.font = [UIFont systemFontOfSize:14];
            _parser.textColor = (chatMsg.isMe? [UIColor blackColor] : [UIColor blackColor]);
            [_parser match:[chatMsg.msg_content stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            _emotionLabel.emotionParser = _parser;
            frame = _mBackgroundView.frame;
            frame.origin.y = _headImageView.frame.origin.y + mY;
            frame.size.width = _parser.miniWidth + 28;
            frame.size.height = (_parser.numberOfTotalLines == 1 ? kHeadImageViewWidth : _parser.height + 20);
            if (chatMsg.isMe) {
                frame.origin.x = kScreen_Width - kPaddingLeftWidth - kHeadImageViewWidth - 10 - _parser.miniWidth - 20 - selectX; // 20为内容到父视图的边界10*2
                _imgSelect.frame = CGRectMake(kScreen_Width - selectX, frame.origin.y + (frame.size.height - selectWidth) / 2, selectWidth, selectWidth);
                _mBackgroundView.frame = frame;
                    switch (chatMsg.msg_state) {
                        case MessageStateSend:
                        {
                            actionView.frame = CGRectMake(_mBackgroundView.frame.origin.x - 24, frame.origin.y + (frame.size.height - 20) / 2, 20, 20);
                            [actionView startAnimating];
                            imgFail.hidden = YES;
                            [imgFail removeFromSuperview];
                            if (_BackMessageIdBlock) {
                                _BackMessageIdBlock(chatMsg);
                            }
                        }
                            break;
                        case MessageStateFail:
                        {
                            imgFail.frame = CGRectMake(_mBackgroundView.frame.origin.x - 24, frame.origin.y + (frame.size.height - 20) / 2, 20, 20);
                            actionView = nil;
                            [self.contentView addSubview:imgFail];
                        }
                            break;
                        case MessageStateRecevied:
                        {
                            imgFail.hidden = YES;
                            actionView.hidden = YES;
                            actionView = nil;
                            [imgFail removeFromSuperview];
                        }
                            break;
                            
                        default:
                            break;
                    }
            }else {
                frame.origin.x = kPaddingLeftWidth + kHeadImageViewWidth +10;
                _imgSelect.frame = CGRectMake(kScreen_Width - selectX, frame.origin.y + (frame.size.height - selectWidth) / 2, selectWidth, selectWidth);
                _mBackgroundView.frame = frame;
            }
            
            frame = _emotionLabel.frame;
            frame.origin.x = (chatMsg.isMe? 10 : 18);
            frame.origin.y = (CGRectGetHeight(_mBackgroundView.bounds) - _parser.height) / 2.0;
            frame.size.width = _parser.miniWidth;
            frame.size.height = _parser.height;
            _emotionLabel.frame = frame;
            [self strechableViewWith:_mBackgroundView andBubbleImage:bubble];
        }
    } else {
        _informationBGView.hidden = NO;
        _imgSelect.hidden = YES;
        
        _mBackgroundView.hidden = YES;
//        imgFail.hidden = YES;
        _headImageView.hidden = YES;
        _voiceSecondLabel.hidden = YES;
        _voiceIcon.hidden = YES;
        _emotionLabel.hidden = YES;
        _contentImageView.hidden = YES;
        
        _audioView.hidden = YES;
        
        _titelLabel.hidden = YES;
        _sizeLabel.hidden = YES;
        _fileImg.hidden = YES;
        _downLable.hidden = YES;
        
//        NSLog(@"%@---%@----%@", chatMsg.type, chatMsg.user_name, chatMsg.msg_content);
        NSString *infoString = @"";
        if ([chatMsg.type isEqualToString:@"4"]) {
            infoString = [NSString stringWithFormat:@"%@", chatMsg.msg_content];
        } else {
            infoString = [NSString stringWithFormat:@"%@把%@", chatMsg.user_name, chatMsg.msg_content];
        }
        
        CGSize size = [infoString getSizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(kInformationLabelMaxSize, MAXFLOAT)];
        
        frame = _informationBGView.frame;
        frame.origin.x = (kScreen_Width - size.width - 30) / 2.0;
        frame.origin.y = 2 * kPaddingTopWidth + CGRectGetHeight(_timeLabel.bounds);
        frame.size.width = size.width + 30;
        frame.size.height = size.height + 20;
        _informationBGView.frame = frame;
        
        frame = _informationLabel.frame;
        frame.size.width = size.width;
        frame.size.height = size.height;
        _informationLabel.frame = frame;
        _informationLabel.text = infoString;
    }
    _contactNameLabel.frame = CGRectMake(_headImageView.frame.origin.x + _headImageView.frame.size.width + 20, _headImageView.frame.origin.y, 80, 20);
    _contactNameLabel.textAlignment = NSTextAlignmentLeft;
    _contactNameLabel.text = chatMsg.user_name;
    if (chatMsg.isMe || ![chatMsg.type isEqualToString:@"1"] || ![showSting isEqualToString:@"show"]) {
        _contactNameLabel.hidden = YES;
    } else {
        _contactNameLabel.hidden = NO;
    }
}

- (void)strechableViewWith:(UIView*)view andBubbleImage:(UIImage*)bubble {
    UIImageView *bubbleImageView = [[UIImageView alloc] init];
    [bubbleImageView setFrame:view.frame];
    // 创建一个内容可拉伸，而边角不拉伸的图片，需要两个参数，第一个是左边不拉伸区域的宽度，第二个参数是上面不拉伸的高度。那么接下来的一个像素会被拉伸
    [bubbleImageView setImage:[bubble stretchableImageWithLeftCapWidth:15 topCapHeight:30]];
    
    CALayer *layer = bubbleImageView.layer;
    layer.frame = (CGRect){{0,0},bubbleImageView.layer.frame.size};
    view.layer.mask = layer;
    [view setNeedsDisplay];
}

+ (CGFloat)cellHeightWithObject:(ChatMessage *)chatMsg withIsShow:(NSString *)showSting{
    
    CGFloat cellHeight = 3 * kPaddingTopWidth + kTimeLabelHeight;
    if ([showSting isEqualToString:@"show"] && !chatMsg.isMe && [chatMsg.type isEqualToString:@"1"]) {
        cellHeight += 25;
    }
    
    if ([chatMsg.type isEqualToString:@"1"]) {
        if (chatMsg.hasResourceView) {
            switch (chatMsg.msg_type) {
                case ChatMessageTypeImage:
                    cellHeight += chatMsg.msg_imageHeight / 2.0f;
                    break;
                case ChatMessageTypeVoice:
                    cellHeight += kHeadImageViewWidth;
                    break;
                case ChatMessageTypeFile:
                    cellHeight += kHeadImageViewWidth + 20;
                    break;
                default:
                    break;
            }

        } else {
            EmotionMatchParser *parser = [[EmotionMatchParser alloc] init];
            parser.width = kTextContentBGViewWidth - 28;
            [parser match:[chatMsg.msg_content stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            cellHeight += (parser.numberOfTotalLines == 1 ? kHeadImageViewWidth : parser.height + 20);
        }
    } else {
        NSString *infoString = [NSString stringWithFormat:@"%@把%@", chatMsg.user_name, chatMsg.msg_content];
        CGSize size = [infoString getSizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(kInformationLabelMaxSize, MAXFLOAT)];
        cellHeight += size.height + 20;
    }
    return cellHeight;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
#pragma mark - event response
- (void)headImageViewClick {
    if (self.headImageViewClickBlock) {
        self.headImageViewClickBlock(self.chatMsg.user_uid);
    }
}

- (void)contentImageViewClick:(UITapGestureRecognizer*)tap {
    UIImageView *imgView = (UIImageView *)tap.view;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAndSaveImg" object:@(_index)];
  //  [UIImageViewBrowser showImage:(UIImageView *)tap.view];
}
- (void)playVoice:(UITapGestureRecognizer *)tap {
    if (_BackVoiceUrlBlock) {
        _BackVoiceUrlBlock();
    }
}
#pragma mark - setters and getters
- (UILabel*)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kPaddingTopWidth, kScreen_Width, kTimeLabelHeight)];
        _timeLabel.font = [UIFont systemFontOfSize:11];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor grayColor];
    }
    return _timeLabel;
}

- (UIImageView*)headImageView {
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2 * kPaddingTopWidth + kTimeLabelHeight, kHeadImageViewWidth, kHeadImageViewWidth)];
        _headImageView.layer.cornerRadius = 5;
        _headImageView.layer.masksToBounds = YES;
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headImageView.clipsToBounds = YES;
        _headImageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImageViewClick)];
        [_headImageView addGestureRecognizer:tap];
    }
    return _headImageView;
}

- (UIView*)mBackgroundView {
    if (!_mBackgroundView) {
        _mBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _mBackgroundView.opaque = YES;
        _mBackgroundView.userInteractionEnabled = YES;
    }
    return _mBackgroundView;
}
- (EmotionLabel*)emotionLabel {
    if (!_emotionLabel) {
        _emotionLabel = [[EmotionLabel alloc] initWithFrame:CGRectZero];
    }
    return _emotionLabel;
}

- (UIImageView*)contentImageView {
    if (!_contentImageView) {
        _contentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _contentImageView.userInteractionEnabled = YES;
        _contentImageView.contentMode = UIViewContentModeScaleAspectFill;
        _contentImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentImageViewClick:)];
        [_contentImageView addGestureRecognizer:tap];
    }
    return _contentImageView;
}

- (UILabel*)voiceSecondLabel {
    if (!_voiceSecondLabel) {
        _voiceSecondLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _voiceSecondLabel.font = [UIFont systemFontOfSize:14];
    }
    return _voiceSecondLabel;
}

- (UIImageView*)voiceIcon {
    if (!_voiceIcon) {
        _voiceIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        _voiceIcon.animationDuration = 1;
        _voiceIcon.animationRepeatCount = 0;
    }
    return _voiceIcon;
}

- (UIView*)informationBGView {
    if (!_informationBGView) {
        _informationBGView = [[UIView alloc] initWithFrame:CGRectZero];
        _informationBGView.backgroundColor = kInfoBackgroundColor;
        _informationBGView.layer.cornerRadius = 5;
        _informationBGView.layer.masksToBounds = YES;
        _informationBGView.clipsToBounds = YES;
    }
    return _informationBGView;
}

- (UILabel*)informationLabel {
    if (!_informationLabel) {
        _informationLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 0, 0)];
        _informationLabel.textColor = [UIColor whiteColor];
        _informationLabel.font = [UIFont systemFontOfSize:14];
        _informationLabel.textAlignment = NSTextAlignmentCenter;
        _informationLabel.numberOfLines = 0;
        _informationLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _informationLabel;
}

- (UIActivityIndicatorView*)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _indicatorView;
}
- (UIImageView *)imgSelect {
    if (!_imgSelect) {
        _imgSelect = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imgSelect.userInteractionEnabled = YES;
    }
    return _imgSelect;
}
- (UILabel *)titelLabel {
    if (!_titelLabel) {
        _titelLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titelLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titelLabel.font = [UIFont systemFontOfSize:13];
    }
    return _titelLabel;
}
- (UILabel *)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _sizeLabel.font = [UIFont systemFontOfSize:13];
    }
    return _sizeLabel;
}
- (UILabel *)downLable {
    if (!_downLable) {
        _downLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _downLable.font = [UIFont systemFontOfSize:13];
    }
    return _downLable;
}
- (UIImageView *)fileImg {
    if (!_fileImg) {
        _fileImg = [[UIImageView alloc] initWithFrame:CGRectZero];
        _fileImg.userInteractionEnabled = YES;
    }
    return _fileImg;
}
- (UILabel *)contactNameLabel {
    if (!_contactNameLabel) {
        _contactNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contactNameLabel.font = [UIFont systemFontOfSize:12];
        _contactNameLabel.textColor = [UIColor lightGrayColor];
    }
    return _contactNameLabel;
}
- (NSString *)changeTime:(NSString *)longTime{
    NSDate *lastDate = [[NSDate alloc] initWithTimeIntervalSince1970:[longTime longLongValue] / 1000.0];
    NSString *dateStr;      //年月日
    NSString *period;       // 时间段
    NSString *hour;         // 时
    
    NSString *messageStr = [CommonFuntion getStringForTime:[longTime longLongValue]];  //年月日时分秒
    if ([lastDate year] == [[NSDate date] year]) {  // 今年
        NSInteger days = [CommonFuntion getTimeDaysSinceToady:messageStr];
        if (days == 0) {
            dateStr = @"今天";
            hour = [messageStr substringWithRange:NSMakeRange(11, 5)];
            period = @" ";
        } else if (days == 1) {
            dateStr = @"昨天";
            hour = [messageStr substringWithRange:NSMakeRange(11, 5)];
            period = @" ";
        } else {     // 非今天或昨天 显示xx月xx日
            dateStr = [messageStr substringWithRange:NSMakeRange(5, 11)];
            hour = @"";
            period = @"";
        }
    }else { // 非今年
        dateStr = [messageStr substringToIndex:15];
        hour = @"";
    }
    
    return [NSString stringWithFormat:@"%@%@%@", dateStr, period, hour];
//    return [NSString stringWithFormat:@"%@ %@ %@:%02d",dateStr,period,hour,(int)[lastDate minute]];

}




#pragma mark - 音频view
- (IMAudioPlayView*)audioView {
    if (!_audioView) {
        _audioView = [[IMAudioPlayView alloc] init];
        [_audioView setX:0];
        [_audioView setHeight:CGRectGetHeight(self.bounds)];
    }
    return _audioView;
}
- (UIView *)unReadView {
    if (!_unReadView) {
        _unReadView = [[UIView alloc] init];
        _unReadView.backgroundColor = [UIColor redColor];
        _unReadView.layer.masksToBounds = YES;
        _unReadView.layer.cornerRadius = 2;
    }
    return _unReadView;
}
- (void)stopVoice {
    [_audioView stop];
}

@end
