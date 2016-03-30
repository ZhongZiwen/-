//
//  LasterContactCell.m
//  shangketong
//
//  Created by 蒋 on 15/9/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "LasterContactCell.h"
#import "UIButton+WebCache.h"
@implementation LasterContactCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setValueForCell:(NSArray *)array {
    [self allBntAndLableHidden];
    _contactArray = [NSMutableArray arrayWithCapacity:0];
    for (AddressBook *addBook in array) {
        [_contactArray addObject:addBook];
    }
    for (int i = 0; i < _contactArray.count; i++) {
        _item = _contactArray[i];
        switch (i) {
            case 0:
                [self.oneBtn sd_setImageWithURL:[NSURL URLWithString:_item.icon] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
                self.oneLable.text = _item.name;
                
                self.oneBtn.hidden = NO;
                self.oneLable.hidden = NO;
                break;
            case 1:
                [self.twoBtn sd_setImageWithURL:[NSURL URLWithString:_item.icon] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
                self.twoLabel.text = _item.name;
                
                self.twoBtn.hidden = NO;
                self.twoLabel.hidden = NO;
                break;
            case 2:
                [self.threeBtn sd_setImageWithURL:[NSURL URLWithString:_item.icon] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
                self.threeLabel.text = _item.name;
                
                self.threeBtn.hidden = NO;
                self.threeLabel.hidden = NO;
                break;
            case 3:
                [self.fourBtn sd_setImageWithURL:[NSURL URLWithString:_item.icon] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
                self.fourLabel.text = _item.name;
                
                self.fourBtn.hidden = NO;
                self.fourLabel.hidden = NO;
                break;
            case 4:
                [self.fiveBtn sd_setImageWithURL:[NSURL URLWithString:_item.icon] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
                self.fiveLabel.text = _item.name;
                
                self.fiveBtn.hidden = NO;
                self.fiveLabel.hidden = NO;
                break;
                
            default:
                break;
        }
    }
}
- (void)allBntAndLableHidden {
    
    self.oneBtn.layer.masksToBounds = YES;
    self.twoBtn.layer.masksToBounds = YES;
    self.threeBtn.layer.masksToBounds = YES;
    self.fourBtn.layer.masksToBounds = YES;
    self.fiveBtn.layer.masksToBounds = YES;
    self.oneBtn.layer.cornerRadius = self.twoBtn.layer.cornerRadius = self.threeBtn.layer.cornerRadius = self.fourBtn.layer.cornerRadius = self.fiveBtn.layer.cornerRadius = 5;
    
    self.oneBtn.hidden = YES;
    self.oneLable.hidden = YES;
    self.twoBtn.hidden = YES;
    self.twoLabel.hidden = YES;
    self.threeBtn.hidden = YES;
    self.threeLabel.hidden = YES;
    self.fourBtn.hidden = YES;
    self.fourLabel.hidden = YES;
    self.fiveBtn.hidden = YES;
    self.fiveLabel.hidden = YES;
}
- (IBAction)actionBtnForPush:(UIButton *)sender {
    _item = _contactArray[sender.tag];
    if (_BackContactIDBlock) {
        _BackContactIDBlock([_item.id integerValue]);
    }
}
@end

