//
//  MoreCustomerItemCell.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-7-6.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#define ICON_COLOR0 [UIColor colorWithRed:239.0f/255 green:239.0f/255 blue:244.0f/255 alpha:1.0f]
#define ICON_COLOR1 [UIColor colorWithRed:229.0f/255 green:229.0f/255 blue:234.0f/255 alpha:1.0f]

#import "MoreCustomerItemCell.h"
#import "CommonFunc.h"

@implementation MoreCustomerItemCell

- (void)awakeFromNib {
    
    self.btnName.transform = CGAffineTransformMakeRotation(M_PI/2);
    [self.btnName setBackgroundImage:[CommonFunc createImageWithColor:ICON_COLOR0] forState:UIControlStateNormal];
    [self.btnName setBackgroundImage:[CommonFunc createImageWithColor:ICON_COLOR1] forState:UIControlStateHighlighted];
    self.btnName.layer.cornerRadius = 5;
    [[self.btnName layer] setMasksToBounds:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetails:(NSString *)name indexPath:(NSIndexPath *)indexPath{
    self.index = indexPath.row;
    CGSize sizeCustomerName = [CommonFunc getSizeOfContents:name Font:[UIFont systemFontOfSize:17.0] withWidth:180 withHeight:20];
    self.btnName.frame = CGRectMake(15, 5, 30, sizeCustomerName.width+10);
    [self.btnName setTitle:name forState:UIControlStateNormal];
    
}

- (IBAction)btnNameAction:(id)sender {
    NSLog(@"btnNameAction index:%li",self.index);
    if (self.delegate && [self.delegate respondsToSelector:@selector(btnNameClickEvent:)]) {
        [self.delegate btnNameClickEvent:self.index];
    }
    
}



@end
