//
//  MeBusinessBehaviourCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MeBusinessBehaviourCell.h"

@implementation MeBusinessBehaviourCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
