//
//  EditItemTypeCellRemarkEdit.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-14.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "EditItemTypeCellRemarkEdit.h"
#import "EditItemModel.h"
#import "CommonFunc.h"
#import "LLCenterUtility.h"

@interface EditItemTypeCellRemarkEdit ()<UITextViewDelegate>{
}

@end

@implementation EditItemTypeCellRemarkEdit

- (void)awakeFromNib {
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.textviewContent.textAlignment = NSTextAlignmentRight;
    
    self.textviewContent.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.textviewContent.layer.borderWidth =1.0;
    self.textviewContent.layer.cornerRadius =5.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetail:(EditItemModel *)model{
    
    CGSize sizeTitle = [CommonFunc getSizeOfContents:model.title Font:[UIFont systemFontOfSize:15.0] withWidth:2999 withHeight:20];
    self.labelTitle.frame = CGRectMake(10, 7, sizeTitle.width, 20);
    self.labelTitle.text = model.title;
    
    
    self.textviewContent.frame = CGRectMake(sizeTitle.width+10+10, 2, DEVICE_BOUNDS_WIDTH-sizeTitle.width-30, 60);
    self.textviewContent.text = model.content;
    
}


-(void)textViewDidChange:(UITextView *)textView{
    if (self.textValueChangedBlock) {
        self.textValueChangedBlock(textView.text);
    }
}




@end
