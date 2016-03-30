//
//  ActivityRecHeaderView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ActivityRecHeaderView.h"
#import "AddressBook.h"

#define kHeight_iconView 50
#define kTag_iconView 39475
#define kTag_nameLabel 43564

@interface ActivityRecHeaderView ()

@property (assign, nonatomic) NSInteger curIndex;
@end

@implementation ActivityRecHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = kView_BG_Color;
        [self addLineUp:NO andDown:YES];
        
        _curIndex = 0;
        
        for (int i = 0; i < 4; i ++) {
            UIImageView *iconView = [[UIImageView alloc] init];
            [iconView setX:15 + (kHeight_iconView + 10) * i];
            [iconView setY:15];
            [iconView setWidth:kHeight_iconView];
            [iconView setHeight:kHeight_iconView];
            iconView.tag = kTag_iconView + i;
            iconView.userInteractionEnabled = YES;
            iconView.layer.cornerRadius = 5;
            iconView.layer.masksToBounds = YES;
            iconView.layer.borderColor = [UIColor iOS7lightBlueColor].CGColor;
            [self addSubview:iconView];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
            [iconView addGestureRecognizer:tap];
            
            UILabel *nameLabel = [[UILabel alloc] init];
            [nameLabel setX:CGRectGetMinX(iconView.frame)];
            [nameLabel setY:CGRectGetMaxY(iconView.frame) + 5];
            [nameLabel setWidth:kHeight_iconView];
            [nameLabel setHeight:20];
            nameLabel.tag = kTag_nameLabel + i;
            nameLabel.font = [UIFont systemFontOfSize:12];
            nameLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:nameLabel];
            
            if (i == 0) {
                iconView.layer.borderWidth = 3.0f;
            }
        }
        
        UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreButton setX:kScreen_Width - 5 - kHeight_iconView];
        [moreButton setY:15];
        [moreButton setWidth:kHeight_iconView];
        [moreButton setHeight:kHeight_iconView];
        moreButton.tag = 201;
        [moreButton setImage:[UIImage imageNamed:@"activity_user_more"] forState:UIControlStateNormal];
        [moreButton addTarget:self action:@selector(moreButtonPress) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:moreButton];
    }
    return self;
}

- (void)configWithArray:(NSArray *)sourceArray showMoreButton:(BOOL)isShow {
    for (int i = 0; i < sourceArray.count; i ++) {
        AddressBook *item = sourceArray[i];
        UIImageView *imageView = (UIImageView*)[self viewWithTag:kTag_iconView + i];
        UILabel *label = (UILabel*)[self viewWithTag:kTag_nameLabel + i];
        
        [imageView sd_setImageWithURL:[NSURL URLWithString:item.icon] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
        label.text = item.name;
    }
    
    UIButton *moreButton = (UIButton*)[self viewWithTag:201];
    moreButton.hidden = !isShow;
}

- (void)moreButtonPress {
    if (self.userMoreClickedBlock) {
        self.userMoreClickedBlock();
    }
}

- (void)tapGesture:(UITapGestureRecognizer*)sender {
    UIImageView *imageView = (UIImageView*)sender.view;
    
    self.curIndex = imageView.tag - kTag_iconView;
}

- (void)setCurIndex:(NSInteger)curIndex {
    if (_curIndex == curIndex) {
        if (self.iconViewClickedBlock) {
            self.iconViewClickedBlock(_curIndex);
        }
        return;
    }
    
    UIImageView *iconView = (UIImageView*)[self viewWithTag:_curIndex + kTag_iconView];
    iconView.layer.borderWidth = 0.0f;

    _curIndex = curIndex;
    
    iconView = (UIImageView*)[self viewWithTag:_curIndex + kTag_iconView];
    iconView.layer.borderWidth = 3.0f;
    
    if (self.iconViewClickedBlock) {
        self.iconViewClickedBlock(_curIndex);
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
