//
//  XLFImageTextDetail.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFImageTextDetailCell.h"
#import "UIView+Common.h"
#import "NSString+Common.h"
#import "InfoViewController.h"

#define kPaddingLeftWidth 15
#define kTextFont       14
#define kDetailFont     12
#define kTextColor      [UIColor blackColor]
#define kDetailColor    [UIColor lightGrayColor]

NSString * const XLFormRowDescriptorTypeImageTextDetail = @"XLFormRowDescriptorTypeImageTextDetail";

@interface XLFImageTextDetailCell ()

@property (nonatomic, strong) UIImageView *m_imageView;
@property (nonatomic, strong) UILabel *m_textLabel;
@property (nonatomic, strong) UILabel *m_detailLabel;
@property (nonatomic, strong) UIView *m_remarkBGView;
@property (nonatomic, strong) UILabel *m_remarkLabel;
//@property (nonatomic, strong) UIButton *m_editButton;
@end

@implementation XLFImageTextDetailCell

+ (void)load {
    
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLFImageTextDetailCell class] forKey:XLFormRowDescriptorTypeImageTextDetail];
}

- (void)configure {
    
    [super configure];
    
    [self.contentView addSubview:self.m_imageView];
    [self.contentView addSubview:self.m_textLabel];
    [self.contentView addSubview:self.m_detailLabel];
    [self.contentView addSubview:self.m_remarkBGView];
    [_m_remarkBGView addSubview:self.m_remarkLabel];
    //    [self.contentView addSubview:self.m_editButton];
}

- (void)update {
    
    [super update];
    
    NSDictionary *sourceDict = (NSDictionary*)self.rowDescriptor.value;
    
    _m_textLabel.text = @"审批状态";
    _m_detailLabel.text = sourceDict[@"detail"];
    
    //只要有remark  就要显示remark中的内容--------除撤回之外
    if ([CommonFuntion checkNullForValue:sourceDict[@"remark"]]) {
        CGFloat height = [sourceDict[@"remark"] getHeightWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(CGRectGetWidth(_m_remarkBGView.bounds), MAXFLOAT)];
        [_m_remarkBGView setHeight:height + 20];
        [_m_remarkLabel setHeight:height];
        _m_remarkLabel.text = sourceDict[@"remark"];
        _m_remarkBGView.hidden = NO;
    } else {
        _m_remarkBGView.hidden = YES;
    }
    switch ([sourceDict[@"status"] integerValue]) {
        case 1: {   // 等待审批或审批中
//            _m_remarkBGView.hidden = YES;
//            _m_imageView.image = [UIImage imageNamed:@"approval_wait"];
            _m_imageView.image = [UIImage imageWithColor:SKT_OA_APPROVAL_STATUS_DEFAULT];
        }
            break;
        case 2: {   // 撤回
            _m_remarkBGView.hidden = YES;
//            _m_imageView.image = [UIImage imageNamed:@"approval_fail"];
            _m_imageView.image = [UIImage imageWithColor:SKT_OA_APPROVAL_STATUS_YELLOW];
        }
            break;
        case 3: {   // 通过审批
//            _m_remarkBGView.hidden = YES;
//            _m_imageView.image = [UIImage imageNamed:@"approval_sucess"];
            _m_imageView.image = [UIImage imageWithColor:SKT_OA_APPROVAL_STATUS_GREEN];
        }
            break;
        case 4: {   // 拒绝
//            _m_imageView.image = [UIImage imageNamed:@"approval_fail"];
            _m_imageView.image = [UIImage imageWithColor:SKT_OA_APPROVAL_STATUS_RED];
            
//            if ([sourceDict[@"remark"] length]) {
//                CGFloat height = [sourceDict[@"remark"] getHeightWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(CGRectGetWidth(_m_remarkBGView.bounds), MAXFLOAT)];
//                [_m_remarkBGView setHeight:height + 20];
//                [_m_remarkLabel setHeight:height];
//                _m_remarkLabel.text = sourceDict[@"remark"];
//                _m_remarkBGView.hidden = NO;
//
//                
//                
//            }else {
//                _m_remarkBGView.hidden = YES;
//            }
        }
            break;
        default:
            break;
    }
}

- (void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    if (self.rowDescriptor.action.formBlock){
        self.rowDescriptor.action.formBlock(self.rowDescriptor);
    }
    [self.formViewController.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    
    NSDictionary *sourceDict = rowDescriptor.value;
//    if ([sourceDict[@"status"] integerValue] == 4) {
        if ([sourceDict[@"remark"] length]) {
            CGFloat height = [sourceDict[@"remark"] getHeightWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(kScreen_Width - 50, MAXFLOAT)];
            return 50.f + height + 20 + 20;
        }else {
            return 50.f;
        }
//    }
//    return 50.0f;
}

#pragma mark - event response
//- (void)editButtonPress {
//    BOOL hasAction = self.rowDescriptor.action.formBlock || self.rowDescriptor.action.formSelector;
//
//    if (hasAction) {
//        if (self.rowDescriptor.action.formBlock) {
//            self.rowDescriptor.action.formBlock(self.rowDescriptor);
//        }
//    }
//}

#pragma mark - setters and getters
- (UIImageView*)m_imageView {
    if (!_m_imageView) {
        _m_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, (50 - 10)/2.0, 10, 10)];
        _m_imageView.layer.masksToBounds = YES;
        _m_imageView.layer.cornerRadius = 5;
        _m_imageView.clipsToBounds = YES;
        
    }
    return _m_imageView;
}

- (UILabel*)m_textLabel {
    if (!_m_textLabel) {
        _m_textLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, kScreen_Width, 50)];
        _m_textLabel.font = [UIFont systemFontOfSize:kTextFont];
        _m_textLabel.textColor = kTextColor;
        _m_textLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_textLabel;
}

- (UILabel*)m_detailLabel {
    if (!_m_detailLabel) {
        _m_detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width - 45, 50)];
        _m_detailLabel.font = [UIFont systemFontOfSize:kDetailFont];
        _m_detailLabel.textColor = kDetailColor;
        _m_detailLabel.textAlignment = NSTextAlignmentRight;
    }
    return _m_detailLabel;
}

- (UIView*)m_remarkBGView {
    if (!_m_remarkBGView) {
        _m_remarkBGView = [[UIView alloc] initWithFrame:CGRectMake(15, 50, kScreen_Width - 45, 0)];
        _m_remarkBGView.backgroundColor = [UIColor colorWithHexString:@"ffdad4"];
        _m_remarkBGView.layer.borderWidth = 1.0f;
        _m_remarkBGView.layer.borderColor = [UIColor colorWithHexString:@"ff9491"].CGColor;
    }
    return _m_remarkBGView;
}

- (UILabel*)m_remarkLabel {
    if (!_m_remarkLabel) {
        _m_remarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(_m_remarkBGView.bounds) - 20, 0)];
        _m_remarkLabel.numberOfLines = 0;
        _m_remarkLabel.font = [UIFont systemFontOfSize:13];
        _m_remarkLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _m_remarkLabel.textColor = [UIColor colorWithHexString:@"fb3a39"];;
    }
    return _m_remarkLabel;
}

//- (UIButton*)m_editButton {
//    if (!_m_editButton) {
//        _m_editButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _m_editButton.frame = CGRectMake(kScreen_Width - 44 - 10, (50-44)/2.0, 44, 44);
//        _m_editButton.hidden = YES;
//        [_m_editButton setImage:[UIImage imageNamed:@"edit_doc"] forState:UIControlStateNormal];
//        [_m_editButton addTarget:self action:@selector(editButtonPress) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _m_editButton;
//}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
