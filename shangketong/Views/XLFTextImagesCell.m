//
//  XLFTextImagesCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFTextImagesCell.h"
#import <UIImageView+WebCache.h>
#import "InfoViewController.h"
#import "CommonConstant.h"

NSString *const XLFormRowDescriptorTypeTextImages = @"XLFormRowDescriptorTypeTextImages";

@interface XLFTextImagesCell ()

@property (nonatomic, strong) UILabel *m_textLabel;
@property (nonatomic, strong) UILabel *m_valueLabel;
@property (nonatomic, strong) UIView *m_iViewBGView;
@property (nonatomic, strong) UIButton *m_editButton;
@property (nonatomic, assign) NSInteger userID;
@end

@implementation XLFTextImagesCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLFTextImagesCell class] forKey:XLFormRowDescriptorTypeTextImages];
}

- (void)configure {
    [super configure];
    
    [self.contentView addSubview:self.m_textLabel];
    [self.contentView addSubview:self.m_editButton];
}

- (void)update {
    
    [super update];
    
    NSDictionary *sourceDict = (NSDictionary*)self.rowDescriptor.value;
    
    // 是否能编辑
    if ([[sourceDict objectForKey:@"isEdit"] integerValue]) {
        _m_editButton.hidden = NO;
    }else {
        _m_editButton.hidden = YES;
    }
    
    _m_textLabel.text = [sourceDict objectForKey:@"text"];
    if ([[sourceDict objectForKey:@"images"] count]) {
        _m_valueLabel.hidden = YES;
        [self.contentView addSubview:self.m_iViewBGView];
        [self.m_valueLabel removeFromSuperview];
        for (UIView *view in _m_iViewBGView.subviews) {
            [view removeFromSuperview];
        }
        
        NSArray *sourceArray = [sourceDict objectForKey:@"images"];
        
        for (int i = 0; i < sourceArray.count; i ++) {
            NSDictionary *dict = sourceArray[i];
           UIImageView *contactImageView = [[UIImageView alloc] initWithFrame:CGRectMake((30 + 15)*(i%7) + 15, 40 + (30+10)*(i/7), 30, 30)];
            contactImageView.tag = i;
            if ([dict objectForKey:@"icon"] == [NSNull null]) {
                contactImageView.image = [UIImage imageNamed:@"user_icon_default"];
            }else {
                [contactImageView sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"icon"]] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
            }
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushToInfoController:)];
            [contactImageView addGestureRecognizer:tap];
            contactImageView.userInteractionEnabled = YES;
            
            contactImageView.contentMode = UIViewContentModeScaleAspectFill;
            contactImageView.clipsToBounds = YES;
            
            [self.contentView addSubview:contactImageView];
        }
    }else {
        for (UIImageView *view in self.contentView.subviews) {
            if([view isKindOfClass:[UIImageView class]]){
                [view removeFromSuperview];
            }
        }
        [self.contentView addSubview:self.m_valueLabel];
        _m_valueLabel.hidden = NO;
        _m_valueLabel.text = @"未填写";
    }
}
- (void)pushToInfoController:(UITapGestureRecognizer *)tap {
    NSInteger index = tap.view.tag;
    NSInteger userId = [[self.rowDescriptor.value objectForKey:@"images"][index][@"id"] integerValue];

    InfoViewController *controller = [[InfoViewController alloc] init];
    controller.title = @"个人信息";
    if ([appDelegateAccessor.moudle.userId integerValue] == userId) {
        controller.infoTypeOfUser = InfoTypeMyself;
    }else{
        controller.infoTypeOfUser = InfoTypeOthers;
        controller.userId = userId;
    }
    [self.formViewController.navigationController pushViewController:controller animated:YES];
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    NSDictionary *sourceDict = (NSDictionary*)rowDescriptor.value;
    NSArray *sourceArray = [sourceDict objectForKey:@"images"];
    return 40 + 40 * (sourceArray.count/7 + 1);
}

- (void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    [self.formViewController.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - event response
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
        _m_textLabel.font = [UIFont systemFontOfSize:15];
        _m_textLabel.textColor = [UIColor colorWithRed:(CGFloat)70/255.0 green:(CGFloat)154/255.0 blue:(CGFloat)234/255.0 alpha:1.0];
        _m_textLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_textLabel;
}

- (UILabel*)m_valueLabel {
    if (!_m_valueLabel) {
        _m_valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10+20+10, kScreen_Width - 2 * 15, 20)];
        _m_valueLabel.font = [UIFont systemFontOfSize:15];
        _m_valueLabel.textColor = [UIColor blackColor];
        _m_valueLabel.textAlignment = NSTextAlignmentLeft;
        _m_valueLabel.numberOfLines = 0;
        _m_valueLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _m_valueLabel;
}

- (UIView*)m_iViewBGView {
    if (!_m_iViewBGView) {
        _m_iViewBGView = [[UIView alloc] initWithFrame:CGRectMake(15, 40, kScreen_Width - 30, 0)];
        _m_iViewBGView.backgroundColor = [UIColor clearColor];
    }
    return _m_iViewBGView;
}

- (UIButton*)m_editButton {
    if (!_m_editButton) {
        _m_editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _m_editButton.frame = CGRectMake(kScreen_Width - 64, 0, 64, [XLFTextImagesCell formDescriptorCellHeightForRowDescriptor:self.rowDescriptor]);
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
