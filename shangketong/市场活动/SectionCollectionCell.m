//
//  SectionCollectionCell.m
//  Test
//
//  Created by 钟必胜 on 15/10/1.
//  Copyright (c) 2015年 wendell. All rights reserved.
//

#import "SectionCollectionCell.h"

#define kViewWidth (kScreen_Width / 4.0)

@interface SectionCollectionCell ()

@property (strong, nonatomic) UILabel *numLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation SectionCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kView_BG_Color;
        
        [self.contentView addSubview:self.numLabel];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)configWithNum:(NSNumber *)num title:(NSString *)title {
    if (num) {
        _numLabel.text = [NSString stringWithFormat:@"%@", num];
    }else {
        _numLabel.text = @"0";
    }
    _titleLabel.text = title;
}

#pragma mark - setters and getters
- (UILabel*)numLabel {
    if (!_numLabel) {
        _numLabel = [[UILabel alloc] init];
        [_numLabel setY:10];
        [_numLabel setWidth:CGRectGetWidth(self.bounds)];
        [_numLabel setHeight:22];
        _numLabel.font = [UIFont systemFontOfSize:15];
        _numLabel.textColor = [UIColor blackColor];
        _numLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _numLabel;
}

- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setY:CGRectGetMaxY(_numLabel.frame)];
        [_titleLabel setWidth:CGRectGetWidth(self.bounds)];
        [_titleLabel setHeight:22];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

@end
