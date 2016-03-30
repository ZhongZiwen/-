//
//  EditItemTypeCellRemarkShow.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-14.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "EditItemTypeCellRemarkShow.h"
#import "EditItemModel.h"
#import "CommonFunc.h"
#import "LLCenterUtility.h"

@implementation EditItemTypeCellRemarkShow

- (void)awakeFromNib {
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetail:(EditItemModel *)model{
    CGSize sizeTitle = [CommonFunc getSizeOfContents:model.title Font:[UIFont systemFontOfSize:15.0] withWidth:2999 withHeight:20];
    self.labelTitle.frame = CGRectMake(10, 10, sizeTitle.width, 20);
    self.labelTitle.text = model.title;
    
    NSString *content = model.content;
//    if (content.length > 150) {
//        content = [NSString stringWithFormat:@"%@...",[content substringToIndex:150]];
//    }
    
    CGSize sizeContent = [CommonFunc getSizeOfContents:content Font:[UIFont systemFontOfSize:15.0] withWidth:DEVICE_BOUNDS_WIDTH-60 withHeight:2999];
    NSLog(@"sizeContent %f",sizeContent.height);
    
    self.imgContentBg.frame = CGRectMake(10, 40, DEVICE_BOUNDS_WIDTH-20, sizeContent.height+50);
    
    self.labelContent.frame = CGRectMake(15, 45, DEVICE_BOUNDS_WIDTH-30, sizeContent.height);
    self.labelContent.text = content;
    
    
//    self.imgRepostBg.image = [CommonFuntion createImageWithColor:[UIColor colorWithRed:245.0f/255 green:245.0f/255 blue:247.0f/255 alpha:1.0f]];
    self.imgContentBg.layer.borderColor = [UIColor colorWithRed:220.0f/255 green:220.0f/255 blue:220.0f/255 alpha:1.0f].CGColor;
    self.imgContentBg.layer.borderWidth = 0.5;
}


+(CGFloat)getCellHeight:(EditItemModel *)model{
    
    CGSize sizeTitle = [CommonFunc getSizeOfContents:model.title Font:[UIFont systemFontOfSize:15.0] withWidth:2999 withHeight:20];
    
    NSString *content = model.content;
//    if (content.length > 150) {
//        content = [NSString stringWithFormat:@"%@...",[content substringToIndex:150]];
//    }
    CGSize sizeContent = [CommonFunc getSizeOfContents:content Font:[UIFont systemFontOfSize:15.0] withWidth:DEVICE_BOUNDS_WIDTH-60 withHeight:2999];
    
    return sizeContent.height+40+60;
}

@end
