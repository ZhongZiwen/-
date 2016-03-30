//
//  XLFSelectorTextDetailCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFSelectorTextDetailCell.h"

NSString * const XLFormRowDescriptorTypeSelectorTextDetail = @"XLFormRowDescriptorTypeSelectorTextDetail";

@interface XLFSelectorTextDetailCell ()

@property (nonatomic, strong) UILabel *m_textLabel;
@property (nonatomic, strong) UILabel *m_detailLabel;
@end

@implementation XLFSelectorTextDetailCell

+ (void)load {

    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLFSelectorTextDetailCell class] forKey:XLFormRowDescriptorTypeSelectorTextDetail];
}

- (void)configure {
    [super configure];
    
    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [self.contentView addSubview:self.m_textLabel];
    [self.contentView addSubview:self.m_detailLabel];
}

- (void)update {
    [super update];
    
    NSDictionary *dict = self.rowDescriptor.value;
    
    _m_textLabel.text = [dict objectForKey:@"text"];
    _m_detailLabel.text = [dict objectForKey:@"detail"];
}

- (void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    
    if (self.rowDescriptor.action.formBlock){
        self.rowDescriptor.action.formBlock(self.rowDescriptor);
    }
    [self.formViewController.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}

+(CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 44;
}

#pragma mark - setters and getters
- (UILabel*)m_textLabel {
    if (!_m_textLabel) {
        _m_textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 44)];
        _m_textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _m_textLabel.textColor = [UIColor blackColor];
        _m_textLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_textLabel;
}

- (UILabel*)m_detailLabel {
    if (!_m_detailLabel) {
        _m_detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width - 30, 44)];
        _m_detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _m_detailLabel.textAlignment = NSTextAlignmentRight;
        _m_detailLabel.textColor = [UIColor lightGrayColor];
    }
    return _m_detailLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
