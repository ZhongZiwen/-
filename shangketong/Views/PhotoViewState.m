//
//  PhotoViewState.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PhotoViewState.h"

@implementation PhotoViewState

+ (PhotoViewState *)viewStateForView:(UIImageView *)view {
    static NSMutableDictionary *dict = nil;
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    
    PhotoViewState *state = dict[@(view.hash)];
    if(state==nil){
        state = [[self alloc] init];
        dict[@(view.hash)] = state;
    }
    return state;
}

- (void)setStateWithView:(UIImageView *)view {
    CGAffineTransform trans = view.transform;
    view.transform = CGAffineTransformIdentity;
    
    self.superview = view.superview;
    self.minImage = view.image;
    self.frame     = view.frame;
    self.transform = trans;
    self.userInteratctionEnabled = view.userInteractionEnabled;
    
    view.transform = trans;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
