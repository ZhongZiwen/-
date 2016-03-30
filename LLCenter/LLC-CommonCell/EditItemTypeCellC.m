//
//  EditItemTypeCellC.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-10.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "EditItemTypeCellC.h"
#import "EditItemModel.h"
#import "CommonFunc.h"
#import "LLCenterUtility.h"

@implementation EditItemTypeCellC

- (void)awakeFromNib {
    // Initialization code
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetail:(EditItemModel *)model{
    CGSize sizeTitle = [CommonFunc getSizeOfContents:model.title Font:[UIFont systemFontOfSize:15.0] withWidth:2999 withHeight:20];
    self.labelTitle.frame = CGRectMake(10, 15, sizeTitle.width, 20);
    self.labelTitle.text = model.title;
    
    
    self.btnSelectTag.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-24, 16, 12, 18);
    
     ///标签
    self.scrollviewTag.frame = CGRectMake(sizeTitle.width+10+10, 5, DEVICE_BOUNDS_WIDTH-sizeTitle.width-20-40, 40);
    self.scrollviewTag.backgroundColor = [UIColor clearColor];
    self.scrollviewTag.showsHorizontalScrollIndicator = NO;
    
   
    NSArray *arrayTag = [model.content componentsSeparatedByString:@","];
    
    for(UIView *item in self.scrollviewTag.subviews){
        if([item isKindOfClass:[UILabel class]]){
            NSInteger tag = [item tag];
            if(tag>=1000){
                [item removeFromSuperview];
            }
        }
    }
    
    if (![model.content isEqualToString:@""]) {

        NSInteger count = 0;
        if (arrayTag) {
            count = [arrayTag count];
        }
        CGFloat x = 0.0;
        for (int i=0; i<count; i++) {
            CGSize sizeTag = [CommonFunc getSizeOfContents:[arrayTag objectAtIndex:i] Font:[UIFont systemFontOfSize:12.0] withWidth:200 withHeight:20];
            
            UILabel *labelTag = [[UILabel alloc] initWithFrame:CGRectMake(x, 5, sizeTag.width+5, 30)];
            labelTag.tag = i+1000;
            labelTag.text = [arrayTag objectAtIndex:i];
            labelTag.textAlignment = NSTextAlignmentCenter;
            labelTag.font = [UIFont systemFontOfSize:12.0];
            labelTag.layer.cornerRadius = 5;
            [[labelTag layer] setMasksToBounds:YES];
            labelTag.backgroundColor = [UIColor colorWithRed:89.0f/255 green:174.0f/255 blue:231.0f/255 alpha:1.0f];
            labelTag.textColor = [UIColor whiteColor];
            [self.scrollviewTag addSubview:labelTag];
            x += (sizeTag.width+10);
            
        }
        self.scrollviewTag.contentSize = CGSizeMake(x, 40);
    }
    

    [self.btnSelectTag addTarget:self action:@selector(selectTag:) forControlEvents:UIControlEventTouchUpInside];
}


-(void)selectTag:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
     
    if (self.SelectTagsBlock) {
        self.SelectTagsBlock();
    }
}

@end
