//
//  XLTotalCell.m
//  shangketong
//
//  Created by 蒋 on 15/12/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLTotalCell.h"
#import "CommentItem.h"
#import <UIImageView+WebCache.h>
#import "InfoViewController.h"
#import "CommonConstant.h"
#import "STTweetLabel.h"
#import "CommonModuleFuntion.h"

#import "OAComment.h"

NSString *const XLFormRowDescriptorTypeTotal = @"XLFormRowDescriptorTypeTotal";

@interface XLTotalCell ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *m_imageView;
@property (nonatomic, strong) UILabel *m_nameLabel;
@property (nonatomic, strong) UILabel *m_timeLabel;
@property (nonatomic, strong) STTweetLabel *m_contentLabel;
@end

@implementation XLTotalCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLTotalCell class] forKey:XLFormRowDescriptorTypeTotal];
}

- (void)configure {
    [super configure];
    
    [self.contentView addSubview:self.m_imageView];
    [self.contentView addSubview:self.m_nameLabel];
    [self.contentView addSubview:self.m_timeLabel];
    [self.contentView addSubview:self.contentLabel];
//    [self.contentView addSubview:self.m_contentLabel];
}

- (void)update {
    [super update];
    
    OAComment *item = (OAComment*)self.rowDescriptor.value;
//    CommentItem *item = (CommentItem*)self.rowDescriptor.value;
    
    [_m_imageView sd_setImageWithURL:[NSURL URLWithString:item.creator.icon] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
    _m_nameLabel.text = item.creator.name;
    
//    _m_timeLabel.text = [item.date stringTimestampWithoutYear];
    _m_timeLabel.text = [CommonFuntion commentOrTrendsDateCommonByDate:item.date];

    
    CGFloat contentHeight = [item.content getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGRectGetWidth(_contentLabel.bounds), CGFLOAT_MAX)];
    [_contentLabel setHeight:contentHeight];
    _contentLabel.text = item.content;
    
    for (User *tempUser in item.altsArray) {
        
        // 找到重名的用户
        NSMutableArray *altUsersArray = [NSMutableArray arrayWithCapacity:0];
        for (User *altUser in item.altsArray) {
            if ([altUser.name rangeOfString:tempUser.name].location != NSNotFound) {
                [altUsersArray addObject:altUser];
            }
        }
        
        // 从内容中找到@人的range
        NSMutableArray *resultsArray = [NSMutableArray arrayWithCapacity:0];
        NSRange searchRange = NSMakeRange(0, [item.content length]);
        NSRange altRange;
        while ((altRange = [item.content rangeOfString:[NSString stringWithFormat:@"@%@", tempUser.name] options:0 range:searchRange]).location != NSNotFound) {
            [resultsArray addObject:[NSValue valueWithRange:altRange]];
            searchRange = NSMakeRange(NSMaxRange(altRange), [item.content length] - NSMaxRange(altRange));
        }
        
        NSInteger index = [altUsersArray indexOfObject:tempUser];
        if (index < resultsArray.count) {
            NSRange range = ((NSValue*)resultsArray[index]).rangeValue;
            [_contentLabel addLinkToTransitInformation:@{@"altUser" : tempUser} withRange:range];
        }
    }
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    OAComment *item = (OAComment*)rowDescriptor.value;
    
    CGFloat contentHeight = [item.content getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(kScreen_Width - 64 - 10, CGFLOAT_MAX)];
    
    return contentHeight + 50;
}

- (void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    BOOL hasAction = self.rowDescriptor.action.formBlock || self.rowDescriptor.action.formSelector;
    if (hasAction) {
        if (self.rowDescriptor.action.formBlock) {
            self.rowDescriptor.action.formBlock(self.rowDescriptor);
        }
    }
    [controller.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - event response
- (void)pushToInfoController {
    OAComment *item = (OAComment *)self.rowDescriptor.value;
    InfoViewController *controller = [[InfoViewController alloc] init];
    controller.title = @"个人信息";
    if ([[NSString stringWithFormat:@"%@", item.creator.id] isEqualToString:appDelegateAccessor.moudle.userId]) {
        controller.infoTypeOfUser = InfoTypeMyself;
    }
    else {
        controller.infoTypeOfUser = InfoTypeOthers;
        controller.userId = [item.creator.id integerValue];
    }
    [self.formViewController.navigationController pushViewController:controller animated:YES];
}


#pragma mark- setters and getters
- (UIImageView*)m_imageView {
    if (!_m_imageView) {
        _m_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 44, 44)];
        _m_imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *Tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushToInfoController)];
        [_m_imageView addGestureRecognizer:Tap];
        
    }
    return _m_imageView;
}

- (UILabel*)m_nameLabel {
    if (!_m_nameLabel) {
        _m_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_m_imageView.frame.origin.x + CGRectGetWidth(_m_imageView.bounds) + 10, CGRectGetMinY(_m_imageView.frame), 100, 20)];
        _m_nameLabel.font = [UIFont systemFontOfSize:14];
        _m_nameLabel.textColor = [UIColor blackColor];
        _m_nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_nameLabel;
}

- (UILabel*)m_timeLabel {
    if (!_m_timeLabel) {
        _m_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - 100 - 10, CGRectGetMinY(_m_imageView.frame), 100, 20)];
        _m_timeLabel.font = [UIFont systemFontOfSize:12];
        _m_timeLabel.textColor = [UIColor lightGrayColor];
        _m_timeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _m_timeLabel;
}

- (TTTAttributedLabel*)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_m_nameLabel.frame), CGRectGetMaxY(_m_nameLabel.frame) + 10, kScreen_Width - CGRectGetMinX(_m_nameLabel.frame) - 10, 20)];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
        _contentLabel.numberOfLines = 0;
        _contentLabel.linkAttributes = kLinkAttributes;
        _contentLabel.activeLinkAttributes = kLinkAttributesActive;
    }
    return _contentLabel;
}

- (STTweetLabel*)m_contentLabel {
    if (!_m_contentLabel) {
        _m_contentLabel = [[STTweetLabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_m_nameLabel.frame), 10 + 20 + 10, kScreen_Width - CGRectGetMinX(_m_nameLabel.frame) - 10, 0)];
        _m_contentLabel.font = [UIFont systemFontOfSize:14];
        _m_contentLabel.textColor = [UIColor blackColor];
        _m_contentLabel.numberOfLines = 0;
        _m_contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _m_contentLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
