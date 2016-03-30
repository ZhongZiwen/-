//
//  XLScheduleDetailTitleCell.m
//  shangketong
//
//  Created by 蒋 on 15/12/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLScheduleDetailTitleCell.h"

#import "UIView+Common.h"
#import "NSString+Common.h"
#import "CommonFuntion.h"

NSString *const XLFormRowDescriptorTypeScheduleDetaileTitle = @"XLFormRowDescriptorTypeScheduleDetaileTitle";

@interface XLScheduleDetailTitleCell ()

@property (nonatomic, strong) UIImageView *colorTypeImageView;
@property (nonatomic, strong) UILabel *colorTypeLabel;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *detail;
@property (nonatomic, strong) UIImageView *privateImageView;
@property (nonatomic, strong) UIButton *editButton;
@end

@implementation XLScheduleDetailTitleCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLScheduleDetailTitleCell class] forKey:XLFormRowDescriptorTypeScheduleDetaileTitle];
}

- (void)configure {
    [super configure];
    
    [self.contentView addSubview:self.colorTypeImageView];
    [self.contentView addSubview:self.colorTypeLabel];
    [self.contentView addSubview:self.name];
    [self.contentView addSubview:self.detail];
    [self.contentView addSubview:self.privateImageView];
    [self.contentView addSubview:self.editButton];
}

- (void)update {
    [super update];
    
    NSDictionary *dict = (NSDictionary*)self.rowDescriptor.value;
    
    _colorTypeImageView.image = [CommonFuntion createImageWithColor:[CommonFuntion getColorValueByColorType:[dict[@"type"] integerValue]]];
    _colorTypeLabel.text = dict[@"typeName"];
    
    // 判断是否为私密
    if (![[dict objectForKey:@"isPrivate"] integerValue]) {
        CGFloat width = [dict[@"name"] getWidthWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:14] constrainedToSize:CGSizeMake(MAXFLOAT, 20)];
        [_name setWidth:width];
        _name.text = dict[@"name"];
        [_privateImageView setX:15 + width + 5];
    }else {
        _privateImageView.hidden = YES;
        _name.text = dict[@"name"];
    }
    
    _detail.text = dict[@"detail"];
    
    if ([[dict objectForKey:@"isEdit"] integerValue]) {
        _editButton.hidden = NO;
    }else {
        _editButton.hidden = YES;
    }
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 70;
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
- (UIImageView*)colorTypeImageView {
    if (!_colorTypeImageView) {
        _colorTypeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 10, 10)];
        _colorTypeImageView.layer.cornerRadius = 5;
        _colorTypeImageView.clipsToBounds = YES;
    }
    return _colorTypeImageView;
}

- (UILabel*)colorTypeLabel {
    if (!_colorTypeLabel) {
        _colorTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15+10+5, 0, 200, 20)];
        [_colorTypeLabel setCenterY:_colorTypeImageView.center.y];
        _colorTypeLabel.font = [UIFont systemFontOfSize:12];
        _colorTypeLabel.textAlignment = NSTextAlignmentLeft;
        _colorTypeLabel.textColor = [UIColor grayColor];
    }
    return _colorTypeLabel;
}

- (UILabel*)name {
    if (!_name) {
        _name = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreen_Width - 30, 20)];
        [_name setCenterY:70 / 2];
        _name.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        _name.textColor = [UIColor blackColor];
        _name.textAlignment = NSTextAlignmentLeft;
    }
    return _name;
}

- (UILabel*)detail {
    if (!_detail) {
        _detail = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreen_Width - 30, 20)];
        [_detail setCenterY:55];
        _detail.font = [UIFont systemFontOfSize:12];
        _detail.textColor = [UIColor lightGrayColor];
        _detail.textAlignment = NSTextAlignmentLeft;
    }
    return _detail;
}

- (UIImageView*)privateImageView {
    if (!_privateImageView) {
        UIImage *image = [UIImage imageNamed:@"file_private"];
        _privateImageView = [[UIImageView alloc] initWithImage:image];
        [_privateImageView setCenterY:_name.center.y];
        [_privateImageView setWidth:image.size.width];
        [_privateImageView setHeight:image.size.height];
    }
    return _privateImageView;
}

- (UIButton*)editButton {
    if (!_editButton) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _editButton.frame = CGRectMake(kScreen_Width - 64, 0, 64, 70);
        [_editButton setImage:[UIImage imageNamed:@"edit_doc"] forState:UIControlStateNormal];
        [_editButton addTarget:self action:@selector(editButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
