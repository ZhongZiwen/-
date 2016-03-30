//
//  CommonNoDataView.m
//  shangketong
//
//  Created by sungoin-zjp on 15-8-6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CommonNoDataView.h"
#import "CommonFuntion.h"

@interface CommonNoDataView ()

@property (nonatomic, strong) UIImageView *imgIcon;
@property (nonatomic, strong) UILabel *labelInfos;
@property (nonatomic, strong) UIButton *optionBtn;

@property (nonatomic, strong) UIImageView *crmImgIcon;
@end

@implementation CommonNoDataView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.imgIcon];
        [self addSubview:self.labelInfos];
        [self addSubview:self.optionBtn];
        [self addSubview:self.crmImgIcon];
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

-(void)setImgName:(NSString *)imgName{
    if ([imgName isEqualToString:@""]) {
        _imgIcon.hidden = YES;
    } else {
        _imgIcon.hidden = NO;
        _imgIcon.image = [UIImage imageNamed:imgName];
    }
}
- (void)setCrmImgName:(NSString *)crmImgName {
    if ([crmImgName isEqualToString:@""]) {
        _crmImgIcon.hidden = YES;
    } else {
        _crmImgIcon.hidden = NO;
        _crmImgIcon.image = [UIImage imageNamed:crmImgName];
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
        _imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake((kScreen_Width-95)/2, 0, 95, 71)];
        
        _imgIcon.contentMode = UIViewContentModeScaleAspectFill;
        _imgIcon.clipsToBounds = YES;
    }
    return _imgIcon;
}
- (UIImageView *)crmImgIcon {
    if (!_crmImgIcon) {
        _crmImgIcon = [[UIImageView alloc] initWithFrame:CGRectMake((kScreen_Width-36)/2, 45, 36, 26)];
        _crmImgIcon.contentMode = UIViewContentModeScaleAspectFill;
        _crmImgIcon.clipsToBounds = YES;
    }
    return _crmImgIcon;
}

- (UILabel*)labelInfos {
    if (!_labelInfos) {
        _labelInfos = [[UILabel alloc] initWithFrame:CGRectMake(0, 85, kScreen_Width, 20)];
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
        [_optionBtn setTitleColor:COMMEN_LABEL_COROL forState:UIControlStateNormal];
        [_optionBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _optionBtn;
}

@end
