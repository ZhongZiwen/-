//
//  FileDownloadView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "FileDownloadView.h"
#import "Directory.h"
#import "ASProgressPopUpView.h"
#import "YLImageView.h"

typedef NS_ENUM(NSInteger, DownloadState){
    DownloadStateDefault = 0,
    DownloadStateDownloading,
    DownloadStateDownloaded,
    DownloadStateFailure,
};

@interface FileDownloadView ()

@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) ASProgressPopUpView *progressView;
@property (strong, nonatomic) UILabel *nameLabel, *sizeLabel;
@property (strong, nonatomic) UIButton *stateButton;
@end

@implementation FileDownloadView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.iconView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.sizeLabel];
        [self addSubview:self.stateButton];
        [self addSubview:self.progressView];
        [_progressView setCenterY:CGRectGetMinY(_stateButton.frame) - 20];
    }
    return self;
}

- (void)reloadData {
    if ([_directory.fileType isEqualToString:@"jpg"]) {
        [_iconView sd_setImageWithURL:[NSURL URLWithString:_directory.url] placeholderImage:[UIImage imageNamed:@""]];
    }
    else {
        _iconView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_file_%@", _directory.fileType]];
    }
    _nameLabel.text = _directory.name;
    _sizeLabel.text = _directory.fileSize;
    
    BOOL isExisted = [[FileManager sharedManager] isExistedForFileName:_directory.name];
    if (isExisted) {
        [self changeToState:DownloadStateDownloaded];
    }
    else {
        [self changeToState:DownloadStateDefault];
    }
}

#pragma mark - event response
- (void)stateButtonPress {
    _progressView.hidden = NO;
    [_progressView showPopUpViewAnimated:YES];
    
    [[FileManager sharedManager] downloadFileWithOption:nil urlString:_directory.url fileName:_directory.name downloadSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [_progressView hidePopUpViewAnimated:YES];
        sleep(0.5);
        _progressView.hidden = YES;
        [self changeToState:DownloadStateDownloaded];
        if (self.completeBlock) {
            self.completeBlock();
        }
        
    } downloadFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self changeToState:DownloadStateFailure];
    } progress:^(float progress) {
        _progressView.progress = progress;
    }];
    
    [self changeToState:DownloadStateDownloading];
}

- (void)changeToState:(DownloadState)state {
    NSString *stateTitle;
    switch (state) {
        case DownloadStateDefault: {
            stateTitle = @"下载原文件";
            [_stateButton successStyle];
        }
            break;
        case DownloadStateDownloading: {
            stateTitle = @"取消下载";
            [_stateButton dangerStyle];
        }
            break;
        case DownloadStateDownloaded: {
            stateTitle = @"已下载";
            [_stateButton successStyle];
            _stateButton.enabled = NO;
        }
            break;
        case DownloadStateFailure: {
            stateTitle = @"下载失败";
            [_stateButton warningStyle];
        }
        default:
            break;
    }
    
    [_stateButton setTitle:stateTitle forState:UIControlStateNormal];
}

#pragma mark - setters and getters
- (UIImageView*)iconView {
    if (!_iconView) {
        UIImage *image = [UIImage imageNamed:@"icon_file_unknown"];
        _iconView = [[UIImageView alloc] init];
        [_iconView setY:64 * 2];
        [_iconView setWidth:image.size.width];
        [_iconView setHeight:image.size.height];
        [_iconView setCenterX:kScreen_Width / 2];
    }
    return _iconView;
}

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setX:15];
        [_nameLabel setY:CGRectGetMaxY(_iconView.frame) + 15];
        [_nameLabel setWidth:kScreen_Width - 30];
        [_nameLabel setHeight:30];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (UILabel*)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc] init];
        [_sizeLabel setX:CGRectGetMinX(_nameLabel.frame)];
        [_sizeLabel setY:CGRectGetMaxY(_nameLabel.frame) + 15];
        [_sizeLabel setWidth:CGRectGetWidth(_nameLabel.bounds)];
        [_sizeLabel setHeight:20];
        _sizeLabel.font = [UIFont systemFontOfSize:12];
        _sizeLabel.textAlignment = NSTextAlignmentCenter;
        _sizeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
    }
    return _sizeLabel;
}

- (UIButton*)stateButton {
    if (!_stateButton) {
        _stateButton = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"下载原文件" andFrame:CGRectMake(0, 0, kScreen_Width - 40, 45) target:self action:@selector(stateButtonPress)];
        [_stateButton setCenterX:kScreen_Width / 2];
        [_stateButton setY:CGRectGetMaxY(_sizeLabel.frame) + 44];
    }
    return _stateButton;
}

- (ASProgressPopUpView*)progressView {
    if (!_progressView) {
        _progressView = [[ASProgressPopUpView alloc] initWithFrame:CGRectZero];
        [_progressView setWidth:kScreen_Width - 40];
        [_progressView setHeight:40];
        [_progressView setCenterX:kScreen_Width / 2.0];
        _progressView.popUpViewCornerRadius = 12.0f;
        _progressView.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:12];
        [_progressView setTrackTintColor:[UIColor colorWithHexString:@"0xe6e6e6"]];
        _progressView.popUpViewAnimatedColors = @[[UIColor colorWithHexString:@"0x3bbd79"]];
        _progressView.hidden = YES;
        [_progressView hidePopUpViewAnimated:NO];
    }
    return _progressView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
