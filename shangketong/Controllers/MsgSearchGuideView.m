//
//  MsgSearchGuideView.m
//  shangketong
//  
//  Created by 蒋 on 15/12/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#define kImageIconWidth 35
#define kImageIconHeight 26
#define kImageIconSpaceBetween 15
#define kImageIconSpaceLeft (kScreen_Width - kImageIconWidth * 4 - kImageIconSpaceBetween * 3) / 2

#import "MsgSearchGuideView.h"
#import "CommonFuntion.h"

@interface MsgSearchGuideView ()

@property (nonatomic, strong) UILabel *labelInfos;
@property (nonatomic, strong) UIButton *optionBtn;

//一个大图
@property (nonatomic, strong) UIImageView *imgIcon;

//四个小图
@property (nonatomic, strong) UIImageView *imgIconOne;
@property (nonatomic, strong) UIImageView *imgIconTwo;
@property (nonatomic, strong) UIImageView *imgIconThree;
@property (nonatomic, strong) UIImageView *imgIconFour;

@end

@implementation MsgSearchGuideView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.imgIcon];
        
        [self addSubview:self.imgIconOne];
        [self addSubview:self.imgIconTwo];
        [self addSubview:self.imgIconThree];
        [self addSubview:self.imgIconFour];
        
        [self addSubview:self.labelInfos];
        [self addSubview:self.optionBtn];
    }
    return self;
}

-(void)btnClick{
    if (self.optionBtnClickBlock) {
        self.optionBtnClickBlock();
    }
}

-(void)setBtnTitle:(NSString *)btnTitle{
    if ([btnTitle isEqualToString:@""]) {
        _optionBtn.hidden = YES;
    }else{
        _optionBtn.hidden = NO;
    }
    [_optionBtn setTitle:btnTitle forState:UIControlStateNormal];
    CGSize sizeTitle = [CommonFuntion getSizeOfContents:btnTitle Font:[UIFont systemFontOfSize:13.0] withWidth:kScreen_Width withHeight:20];
    _optionBtn.frame = CGRectMake((kScreen_Width-sizeTitle.width)/2, 100, sizeTitle.width, 40);
}
//大图
-(void)setImgName:(NSString *)imgName{
    if ([imgName isEqualToString:@""]) {
        _imgIcon.hidden = YES;
    } else {
        _imgIcon.hidden = NO;
        _imgIcon.image = [UIImage imageNamed:imgName];
    }
}
//小图
- (void)setImgNameOne:(NSString *)imgNameOne {
    if ([imgNameOne isEqualToString:@""]) {
        _imgIconOne.hidden = YES;
    } else {
        _imgIconOne.hidden = NO;
        _imgIconOne.image = [UIImage imageNamed:imgNameOne];
    }
}
- (void)setImgNameTwo:(NSString *)imgNameTwo {
    if ([imgNameTwo isEqualToString:@""]) {
        _imgIconTwo.hidden = YES;
    } else {
        _imgIconTwo.hidden = NO;
        _imgIconTwo.image = [UIImage imageNamed:imgNameTwo];
    }
}
- (void)setImgNameThree:(NSString *)imgNameThree {
    if ([imgNameThree isEqualToString:@""]) {
        _imgIconThree.hidden = YES;
    } else {
        _imgIconThree.hidden = NO;
        _imgIconThree.image = [UIImage imageNamed:imgNameThree];
    }
}
- (void)setImgNameFour:(NSString *)imgNameFour {
    if ([imgNameFour isEqualToString:@""]) {
        _imgIconFour.hidden = YES;
    } else {
        _imgIconFour.hidden = NO;
        _imgIconFour.image = [UIImage imageNamed:imgNameFour];
    }
    
}

-(void)setLabelTitle:(NSString *)labelTitle{
    if ([labelTitle isEqualToString:@""]) {
        _labelInfos.hidden = YES;
    }else{
        _labelInfos.hidden = NO;
    }
    _labelInfos.text = labelTitle;
}

- (UIImageView*)imgIcon {
    if (!_imgIcon) {
        _imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake((kScreen_Width-159)/2, 0, 159, 24)];
        _imgIcon.clipsToBounds = YES;
    }
    return _imgIcon;
}

- (UILabel*)labelInfos {
    if (!_labelInfos) {
        _labelInfos = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, kScreen_Width, 20)];
        _labelInfos.font = [UIFont systemFontOfSize:12.0];
        _labelInfos.textColor = [UIColor lightGrayColor];
        _labelInfos.textAlignment = NSTextAlignmentCenter;
    }
    return _labelInfos;
}

- (UIButton*)optionBtn {
    if (!_optionBtn) {
        _optionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _optionBtn.frame = CGRectMake(0, 100, kScreen_Width, 40);
        _optionBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        _optionBtn.backgroundColor = [UIColor clearColor];
        [_optionBtn setTitleColor:LIGHT_BLUE_COLOR forState:UIControlStateNormal];
        [_optionBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _optionBtn;
}

- (UIImageView *)imgIconOne {
    if (!_imgIconOne) {
        _imgIconOne = [[UIImageView alloc] initWithFrame:CGRectMake(kImageIconSpaceLeft, 0, kImageIconWidth, kImageIconHeight)];
        _imgIconOne.clipsToBounds = YES;
    }
    return _imgIconOne;
}
- (UIImageView *)imgIconTwo {
    if (!_imgIconTwo) {
        _imgIconTwo = [[UIImageView alloc] initWithFrame:CGRectMake(kImageIconSpaceLeft + kImageIconWidth + kImageIconSpaceBetween, 0, kImageIconWidth, kImageIconHeight)];
        _imgIconTwo.clipsToBounds = YES;
    }
    return _imgIconTwo;
}
- (UIImageView *)imgIconThree {
    if (!_imgIconThree) {
        _imgIconThree = [[UIImageView alloc] initWithFrame:CGRectMake(kImageIconSpaceLeft + (kImageIconWidth + kImageIconSpaceBetween) * 2, 0, kImageIconWidth, kImageIconHeight)];
        _imgIconThree.clipsToBounds = YES;
    }
    return _imgIconThree;
}
- (UIImageView *)imgIconFour {
    if (!_imgIconFour) {
        _imgIconFour = [[UIImageView alloc] initWithFrame:CGRectMake(kImageIconSpaceLeft + (kImageIconWidth + kImageIconSpaceBetween) * 3, 0, kImageIconWidth, kImageIconHeight)];
        _imgIconFour.clipsToBounds = YES;
    }
    return _imgIconFour;
}
@end
