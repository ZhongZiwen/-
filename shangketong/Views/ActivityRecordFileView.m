//
//  ActivityRecordFileView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ActivityRecordFileView.h"
#import "FileModel.h"

@interface ActivityRecordFileView ()

@property (strong, nonatomic) UIButton *backgroundButton;
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) FileModel *item;
@end

@implementation ActivityRecordFileView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor iOS7lightGrayColor].CGColor;
        
        [self addSubview:self.backgroundButton];
        [self addSubview:self.iconView];
        [self addSubview:self.nameLabel];
    }
    return self;
}

- (void)configWithObj:(id)obj {
    _item = obj;
    _nameLabel.text = _item.name;
}

- (void)buttonPress {
    if (self.fileBtnClickBlock) {
        self.fileBtnClickBlock(_item);
    }
}

#pragma mark - setters and getters
- (UIButton*)backgroundButton {
    if (!_backgroundButton) {
        _backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backgroundButton.frame = self.bounds;
        [_backgroundButton addTarget:self action:@selector(buttonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backgroundButton;
}

- (UIImageView*)iconView {
    if (!_iconView) {
        UIImage *image = [UIImage imageNamed:@"file_document_32"];
        _iconView = [[UIImageView alloc] initWithImage:image];
        [_iconView setX:5];
        [_iconView setWidth:image.size.width];
        [_iconView setHeight:image.size.height];
        [_iconView setCenterY:CGRectGetHeight(self.bounds) / 2];
    }
    return _iconView;
}

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setX:CGRectGetMaxX(_iconView.frame) + 5];
        [_nameLabel setWidth:CGRectGetWidth(self.bounds) - CGRectGetMinX(_nameLabel.frame) - 10];
        [_nameLabel setHeight:CGRectGetHeight(self.bounds)];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.textColor = [UIColor lightGrayColor];
    }
    return _nameLabel;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
