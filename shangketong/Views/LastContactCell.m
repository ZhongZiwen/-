//
//  LastContactCell.m
//  shangketong
//
//  Created by 蒋 on 15/7/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "LastContactCell.h"
#import "UIButton+Create.h"
#import "AddressBook.h"
#import "InfoViewController.h"
#import "UIButton+WebCache.h"

@interface LastContactCell ()
@property (nonatomic, strong) AddressBook *item;
@end

@implementation LastContactCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)customCellForLastContact:(NSArray *)array {
    CGFloat width = 40;
    CGFloat betweenWidth = 15;
    NSInteger conutArr = 0;
    if ([array count] >= 5) {
        conutArr = 5;
    } else {
        conutArr = [array count];
    }
    
#warning 根据存储方式来确定怎么获取数组元素
    for (int i = 0; i < conutArr; i++) {
        _item = array[i];
        NSLog(@"name:%@",_item.name);
        UIButton *contactBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        contactBtn.frame = CGRectMake(betweenWidth * (i + 1) + width * i, 5, width, width);
        [contactBtn setImageWithURL:[NSURL URLWithString:_item.icon] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
        [contactBtn addTarget:self action:@selector(bottonAction:) forControlEvents:UIControlEventTouchUpInside];
        contactBtn.tag = i;
        contactBtn.layer.cornerRadius = 5;
        contactBtn.layer.masksToBounds = YES;
        UILabel *contactLabel = [[UILabel alloc] initWithFrame:CGRectMake(betweenWidth * (i + 1) + width * i, width + 5, width, 20)];
        contactLabel.text = _item.name;
        contactLabel.textAlignment = NSTextAlignmentCenter;
        contactLabel.font = [UIFont systemFontOfSize:11];
        [self.contentView addSubview:contactBtn];
        [self.contentView addSubview:contactLabel];
    }
}
- (void)bottonAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.clickLatelyContactBlock) {
        self.clickLatelyContactBlock(btn.tag);
    }
}
@end
