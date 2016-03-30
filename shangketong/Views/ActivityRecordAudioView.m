//
//  ActivityRecordAudioView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ActivityRecordAudioView.h"

@interface ActivityRecordAudioView ()

@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) UIImageView *playImageView;
@property (strong, nonatomic) UILabel *secondLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@end

@implementation ActivityRecordAudioView

- (instancetype)init {
    self = [super init];
    if (self) {
        
        [self addSubview:self.bgImageView];
        [self setWidth:CGRectGetWidth(_bgImageView.bounds)];
        [self setHeight:CGRectGetHeight(_bgImageView.bounds)];
        [self addSubview:self.secondLabel];
        [self addSubview:self.playImageView];
    }
    return self;
}

- (void)setSecond:(NSNumber *)second {
    _secondLabel.text = [NSString stringWithFormat:@"%d''", [second integerValue] / 1000];
}

- (void)setPlayState:(AudioPlayViewState)playState {
    [super setPlayState:playState];
    if (playState == AudioPlayViewStatePlaying) {
        [_activityView stopAnimating];
        [self startPlayingAnimation];
    }
    else if (playState == AudioPlayViewStateDownloading) {
        //        [_activityView startAnimating];
        [self stopPlayingAnimation];
    }
    else {
        [_activityView stopAnimating];
        [self stopPlayingAnimation];
    }
}

#pragma mark - Animation
- (void)startPlayingAnimation {
    _playImageView.image = nil;
    _playImageView.image = [UIImage animatedImageNamed:@"feed_sound_" duration:0.8];
    
    [_playImageView startAnimating];
}

- (void)stopPlayingAnimation {
    [_playImageView stopAnimating];
    _playImageView.image = [UIImage imageNamed:@"feed_sound_2"];
}

#pragma mark - touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    _bgImageView.highlighted = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    //在TableViewCell中，快速点击不显示highlight状态
    [self performSelector:@selector(cancelHighlight) withObject:nil afterDelay:0.1f];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    _bgImageView.highlighted = NO;
}

- (void)cancelHighlight {
    _bgImageView.highlighted = NO;
}

#pragma mark - setters and getters
- (UIImageView*)bgImageView {
    if (!_bgImageView) {
        UIImage *normalImage = [UIImage imageNamed:@"feed_voice_normal"];
        _bgImageView = [[UIImageView alloc] initWithImage:normalImage];
        [_bgImageView setWidth:normalImage.size.width];
        [_bgImageView setHeight:normalImage.size.height];
        _bgImageView.highlightedImage = [UIImage imageNamed:@"feed_voice_select"];
    }
    return _bgImageView;
}

- (UILabel*)secondLabel {
    if (!_secondLabel) {
        _secondLabel = [[UILabel alloc] init];
        [_secondLabel setX:15];
        [_secondLabel setWidth:CGRectGetWidth(self.bounds) - 15 - 20];
        [_secondLabel setHeight:CGRectGetHeight(self.bounds)];
        _secondLabel.font = [UIFont systemFontOfSize:15];
        _secondLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _secondLabel;
}

- (UIImageView*)playImageView {
    if (!_playImageView) {
        UIImage *image = [UIImage imageNamed:@"feed_sound_2"];
        _playImageView = [[UIImageView alloc] initWithImage:image];
        [_playImageView setX:CGRectGetWidth(self.bounds) - image.size.width - 15];
        [_playImageView setWidth:image.size.width];
        [_playImageView setHeight:image.size.height];
        [_playImageView setCenterY:CGRectGetMidY(self.frame)];
    }
    return _playImageView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
