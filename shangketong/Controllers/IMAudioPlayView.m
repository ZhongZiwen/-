//
//  IMAudioPlayView.m
//  
//
//  Created by sungoin-zjp on 16/2/18.
//
//

#import "IMAudioPlayView.h"

@interface IMAudioPlayView ()

//@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) UIImageView *playImageView;
@property (strong, nonatomic) UILabel *secondLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@end

@implementation IMAudioPlayView



- (instancetype)init {
    self = [super init];
    if (self) {
        
//        [self addSubview:self.bgImageView];
        [self setWidth:150];
        [self setHeight:50];
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
                [_activityView startAnimating];
        [self stopPlayingAnimation];
    }
    else {
        [_activityView stopAnimating];
        [self stopPlayingAnimation];
    }
}

#pragma mark - Animation
- (void)startPlayingAnimation {
//    NSString *imgNamePre = @"";
//    if (_leftOrRight) {
//        if ([_leftOrRight isEqualToString:@"left"]) {
//            imgNamePre = @"voice_sign_other_";
//        }else{
//            imgNamePre = @"voice_sign_mine_";
//        }
//    }
//    NSLog(@"startPlayingAnimation _leftOrRight:%@",_leftOrRight);
    _playImageView.image = nil;
    _playImageView.image = [UIImage animatedImageNamed:_leftOrRight duration:0.8];
    
    [_playImageView startAnimating];
}

- (void)stopPlayingAnimation {
//    NSString *imgNamePre = @"";
//    if (_leftOrRight) {
//        if ([_leftOrRight isEqualToString:@"voice_sign_other_"]) {
//            imgNamePre = @"voice_sign_other_2";
//        }else{
//            imgNamePre = @"voice_sign_mine_2";
//        }
//    }
    [_playImageView stopAnimating];
    _playImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@3",_leftOrRight]];
}

#pragma mark - touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refeshSelectCell" object:@(_index)];
//    _bgImageView.highlighted = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    //在TableViewCell中，快速点击不显示highlight状态
    [self performSelector:@selector(cancelHighlight) withObject:nil afterDelay:0.1f];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
//    _bgImageView.highlighted = NO;
}

- (void)cancelHighlight {
//    _bgImageView.highlighted = NO;
}

#pragma mark - setters and getters
//- (UIImageView*)bgImageView {
//    if (!_bgImageView) {
//        UIImage *normalImage = [UIImage imageNamed:@"feed_voice_normal"];
//        _bgImageView = [[UIImageView alloc] initWithImage:normalImage];
//        [_bgImageView setWidth:normalImage.size.width];
//        [_bgImageView setHeight:normalImage.size.height];
//        _bgImageView.highlightedImage = [UIImage imageNamed:@"feed_voice_select"];
//    }
//    return _bgImageView;
//}

- (UILabel*)secondLabel {
    if (!_secondLabel) {
        _secondLabel = [[UILabel alloc] init];
        [_secondLabel setX:15];
        [_secondLabel setY:-3];
        [_secondLabel setWidth:CGRectGetWidth(self.bounds) - 15 - 20];
        [_secondLabel setHeight:CGRectGetHeight(self.bounds)];
        _secondLabel.font = [UIFont systemFontOfSize:15];
        _secondLabel.textAlignment = NSTextAlignmentLeft;
        _secondLabel.textColor = [UIColor whiteColor];
    }
    return _secondLabel;
}

- (UIImageView*)playImageView {
    if (!_playImageView) {
        UIImage *image = [UIImage imageNamed:@"voice_sign_other_3"];
        _playImageView = [[UIImageView alloc] initWithImage:image];
        [_playImageView setX:_secondLabel.frame.origin.x+25];
//        [_playImageView setX:_secondLabel.frame.origin.x+25];
        [_playImageView setCenterY:CGRectGetHeight(self.bounds)/2-3];
        [_playImageView setWidth:image.size.width];
        [_playImageView setHeight:image.size.height];
    }
    return _playImageView;
}


-(void)setLeftOrRight:(NSString *)leftOrRight{
    _leftOrRight = leftOrRight;
//    NSLog(@"_leftOrRight:%@",_leftOrRight);
    _playImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@3",_leftOrRight]];
    if ([leftOrRight isEqualToString:@"voice_sign_other_"]) {
        [_playImageView setX:20];
        [_secondLabel setX:_playImageView.frame
         .size.width+40];
    }else{
        [_secondLabel setX:15];
        [_playImageView setX:_secondLabel.frame.origin.x+35];
    }
}

@end
