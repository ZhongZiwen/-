//
//  MessageHeaderCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MessageHeaderCell.h"
#import "Lead.h"
#import "Customer.h"
#import "Contact.h"

@interface MessageHeaderCell ()

@property (strong, nonatomic) UILabel *headerLabel;
@end

@implementation MessageHeaderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];

        if (!_headerLabel) {
            _headerLabel = [[UILabel alloc] init];
            [_headerLabel setX:15];
            [_headerLabel setY:20];
            [_headerLabel setWidth:kScreen_Width - 30];
            _headerLabel.font = [UIFont systemFontOfSize:14];
            _headerLabel.textAlignment = NSTextAlignmentLeft;
            _headerLabel.textColor = [UIColor iOS7greenColor];
            _headerLabel.numberOfLines = 0;
            [self.contentView addSubview:_headerLabel];
        }
    }
    return self;
}

- (void)configWithArray:(NSArray *)array {
    NSString *string = @"收件人: ";
    for (int i = 0; i < array.count; i ++) {
        NSString *tempName;
        id obj = array[i];
        if ([obj isKindOfClass:[Lead class]]) {
            Lead *lead = obj;
            tempName = lead.name;
        }
        else if ([obj isKindOfClass:[Customer class]]) {
            Customer *customer = obj;
            tempName = customer.name;
        }
        else if ([obj isKindOfClass:[Contact class]]) {
            Contact *contact = obj;
            tempName = contact.name;
        }
        
        if (i == 0) {
            string = [NSString stringWithFormat:@"%@%@", string, tempName];
        }else {
            string = [NSString stringWithFormat:@"%@, %@", string, tempName];
        }
    }
    
    CGFloat height = [string getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(kScreen_Width - 30, CGFLOAT_MAX)];
    [_headerLabel setHeight:height];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:string];
    //设置：在0-4个单位长度内的内容显示成灰色
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, 4)];
    _headerLabel.attributedText = str;
}

+ (CGFloat)cellHeightWithArray:(NSArray *)array {
    
    NSString *string = @"收件人: ";
    for (int i = 0; i < array.count; i ++) {
        NSString *tempName;
        id obj = array[i];
        if ([obj isKindOfClass:[Lead class]]) {
            Lead *lead = obj;
            tempName = lead.name;
        }
        else if ([obj isKindOfClass:[Customer class]]) {
            Customer *customer = obj;
            tempName = customer.name;
        }
        else if ([obj isKindOfClass:[Contact class]]) {
            Contact *contact = obj;
            tempName = contact.name;
        }
        
        if (i == 0) {
            string = [NSString stringWithFormat:@"%@%@", string, tempName];
        }else {
            string = [NSString stringWithFormat:@"%@, %@", string, tempName];
        }
    }
    
    CGFloat height = [string getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(kScreen_Width - 30, CGFLOAT_MAX)];
    
    return height + 40;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
