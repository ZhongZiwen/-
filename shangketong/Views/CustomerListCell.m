//
//  CustomerListCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/2.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CustomerListCell.h"
#import "Customer.h"

@interface CustomerListCell ()

@property (strong, nonatomic) UILabel *m_title;
@property (strong, nonatomic) UILabel *m_detail;
@property (strong, nonatomic) UIButton *callButton;
@property (copy, nonatomic) NSString *phoneStr;
@end

@implementation CustomerListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.m_title];
        [self.contentView addSubview:self.m_detail];
        [self.contentView addSubview:self.callButton];
    }
    return self;
}

- (void)configWithObj:(id)obj {
    Customer *item = obj;
    _m_title.text = item.name;
    _m_detail.text = item.statusDesc;
    //    _m_detail.text = [item.createTime stringTimestampWithoutYear];
    
    if (item.phone) {
        _callButton.hidden = NO;
        _phoneStr = item.phone;
    }else {
        _callButton.hidden = YES;
    }
}

- (void)callButtonPress {
    if (self.photoBlock) {
        self.photoBlock();
    }
}

+ (CGFloat)cellHeight {
    return 64.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (UILabel*)m_title {
    if (!_m_title) {
        _m_title = [[UILabel alloc] init];
        [_m_title setX:15];
        [_m_title setY:10];
        [_m_title setWidth:kScreen_Width - 15 - 54];
        [_m_title setHeight:24];
        _m_title.font = [UIFont systemFontOfSize:16];
        _m_title.textAlignment = NSTextAlignmentLeft;
    }
    return _m_title;
}

- (UILabel*)m_detail {
    if (!_m_detail) {
        _m_detail = [[UILabel alloc] init];
        [_m_detail setX:CGRectGetMinX(_m_title.frame)];
        [_m_detail setY:CGRectGetMaxY(_m_title.frame)];
        [_m_detail setWidth:CGRectGetWidth(_m_title.bounds)];
        [_m_detail setHeight:20];
        _m_detail.font = [UIFont systemFontOfSize:14];
        _m_detail.textAlignment = NSTextAlignmentLeft;
        _m_detail.textColor = [UIColor lightGrayColor];
    }
    return _m_detail;
}

- (UIButton*)callButton {
    if (!_callButton) {
        _callButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_callButton setWidth:[CustomerListCell cellHeight]];
        [_callButton setHeight:[CustomerListCell cellHeight]];
        [_callButton setX:kScreen_Width - CGRectGetWidth(_callButton.bounds)];
        [_callButton setImage:[UIImage imageNamed:@"activity_header_call_green"] forState:UIControlStateNormal];
        [_callButton addTarget:self action:@selector(callButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _callButton;
}

@end
