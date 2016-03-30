//
//  AddressBookActionSheetCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AddressBookActionSheetCell.h"

#define kRowHeight      48.0f

@interface AddressBookActionSheetCell ()

@property (nonatomic, strong) UILabel *m_title;
@property (nonatomic, strong) UIButton *msgButton;
@property (nonatomic, strong) UIButton *callButton;
@end

@implementation AddressBookActionSheetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.m_title];
        [self.contentView addSubview:self.msgButton];
        [self.contentView addSubview:self.callButton];
    }
    return self;
}

- (void)configWithMobile:(NSString *)mobile {
    _msgButton.hidden = NO;
    _callButton.tag  = 100;
    _m_title.text = mobile;
}

- (void)configWithPhone:(NSString *)phone {
    _msgButton.hidden = YES;
    _callButton.tag = 200;
    _m_title.text = phone;
}

- (void)msgButtonPress {
    
    if (self.msgBtnClickedBlock) {
        self.msgBtnClickedBlock(_m_title.text);
    }
}

- (void)callButtonPress:(UIButton*)sender {
    
    if (self.phoneBtnClickedBlock) {
        self.phoneBtnClickedBlock(_m_title.text);
    }
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
        _m_title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreen_Width - 15 - 2 * kRowHeight, kRowHeight)];
        _m_title.font = [UIFont systemFontOfSize:14];
        _m_title.textAlignment = NSTextAlignmentLeft;
        _m_title.textColor = [UIColor grayColor];
    }
    return _m_title;
}

- (UIButton*)msgButton {
    if (!_msgButton) {
        _msgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _msgButton.frame = CGRectMake(kScreen_Width - 2*kRowHeight, 0, kRowHeight, kRowHeight);
        [_msgButton setImage:[UIImage imageNamed:@"select_contact_message"] forState:UIControlStateNormal];
        [_msgButton addTarget:self action:@selector(msgButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _msgButton;
}

- (UIButton*)callButton {
    if (!_callButton) {
        _callButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _callButton.frame = CGRectMake(kScreen_Width - kRowHeight, 0, kRowHeight, kRowHeight);
        [_callButton setImage:[UIImage imageNamed:@"today_operation_contact"] forState:UIControlStateNormal];
        [_callButton addTarget:self action:@selector(callButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _callButton;
}

@end
