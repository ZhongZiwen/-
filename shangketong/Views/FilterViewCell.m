//
//  FilterViewCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/17.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "FilterViewCell.h"
#import "FilterValue.h"
#import "AddressBook.h"

@interface FilterViewCell ()

@property (strong, nonatomic) UILabel *content;
@end

@implementation FilterViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont systemFontOfSize:14];
//        self.textLabel.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
        self.textLabel.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

- (void)configWithSearchType:(NSInteger)type model:(FilterValue *)model row:(NSInteger)row {
    switch (type) {
        case 0: {   // 单选
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            self.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
            self.textLabel.text = model.name;
            if (model.isSelected) {
                self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_filter_check"]];
            }else {
                self.accessoryView = nil;
            }
        }
            break;
        case 1: {   // 多选
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            self.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
            self.textLabel.text = model.name;
            if (model.isSelected) {
                self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"multi_graph_select"]];
            }else {
                self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_message_normal"]];
            }
        }
            break;
        case 4: {   // 浮点
            self.selectionStyle = UITableViewCellSelectionStyleDefault;
            self.accessoryView = nil;
            self.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
            self.textLabel.text = model.name;
        }
            break;
        default:
            break;
    }
}

- (void)configWithModel:(AddressBook *)addressBook {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    self.textLabel.text = addressBook.name;
    if (addressBook.isSelected) {
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"multi_graph_select"]];
    }else {
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_message_normal"]];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
