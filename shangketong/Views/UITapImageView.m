//
//  UITapImageView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "UITapImageView.h"

@implementation UITapImageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _index = NSUIntegerMax;
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTap:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)imageViewTap:(UITapGestureRecognizer*)tap {
    if (self.imageViewTapBlock) {
        self.imageViewTapBlock(self.tag);
    }
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
