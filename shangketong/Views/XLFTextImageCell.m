//
//  XLFTextImageCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFTextImageCell.h"
#import <UIImageView+WebCache.h>
#import "InfoViewController.h"
#import "CommonConstant.h"
NSString *const XLFormRowDescriptorTypeTextImage = @"XLFormRowDescriptorTypeTextImage";

@interface XLFTextImageCell ()

@property (nonatomic, strong) UILabel *m_textLabel;
@property (nonatomic, strong) UIImageView *m_imageView;
@property (nonatomic, strong) UIButton *m_editButton;
@end

@implementation XLFTextImageCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLFTextImageCell class] forKey:XLFormRowDescriptorTypeTextImage];
}

- (void)configure {
    [super configure];
    [self.contentView addSubview:self.m_textLabel];
    [self.contentView addSubview:self.m_imageView];
    [self.contentView addSubview:self.m_editButton];
}

- (void)update {
    [super update];
    
    NSDictionary *dict = (NSDictionary*)self.rowDescriptor.value;
    
    // 是否能编辑
    if ([[dict objectForKey:@"isEdit"] integerValue]) {
        _m_editButton.hidden = NO;
    }else {
        _m_editButton.hidden = YES;
    }
    
    _m_textLabel.text = [dict objectForKey:@"text"];
    [_m_imageView sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 80.0f;
}

- (void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    [self.formViewController.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - event respoonse
- (void)editButtonPress {
    BOOL hasAction = self.rowDescriptor.action.formBlock || self.rowDescriptor.action.formSelector;
    if (hasAction) {
        if (self.rowDescriptor.action.formBlock) {
            self.rowDescriptor.action.formBlock(self.rowDescriptor);
        }
    }
}

#pragma mark - setters and getters
- (UILabel*)m_textLabel {
    if (!_m_textLabel) {
        _m_textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 150, 20)];
        _m_textLabel.tag = 100;
        _m_textLabel.font = [UIFont systemFontOfSize:14];
        _m_textLabel.textColor = kTitleColor;
        _m_textLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_textLabel;
}

- (UIImageView*)m_imageView {
    if (!_m_imageView) {
        _m_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 40, 30, 30)];
        _m_imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushToInfoController)];
        [_m_imageView addGestureRecognizer:tap];
    }
    return _m_imageView;
}
- (void)pushToInfoController {
    NSDictionary *dict = self.rowDescriptor.value;
    InfoViewController *controller = [[InfoViewController alloc] init];
    controller.title = @"个人信息";
    if ([appDelegateAccessor.moudle.userId integerValue] == [[dict objectForKey:@"uid"] integerValue]) {
        controller.infoTypeOfUser = InfoTypeMyself;
    }else{
        controller.infoTypeOfUser = InfoTypeOthers;
        controller.userId = [[dict objectForKey:@"uid"] integerValue];
    }
    [self.formViewController.navigationController pushViewController:controller animated:YES];
}
- (UIButton*)m_editButton {
    if (!_m_editButton) {
        _m_editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _m_editButton.frame = CGRectMake(kScreen_Width - 44 - 10, (80-44)/2.0, 44, 44);
        [_m_editButton setImage:[UIImage imageNamed:@"edit_doc"] forState:UIControlStateNormal];
        [_m_editButton addTarget:self action:@selector(editButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _m_editButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
