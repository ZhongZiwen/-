//
//  EditItemTypeCellA.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-10.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "EditItemTypeCellA.h"
#import "EditItemModel.h"
#import "CommonFunc.h"
#import "LLCenterUtility.h"

@implementation EditItemTypeCellA

- (void)awakeFromNib {
    // Initialization code
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.textFieldContent.textAlignment = NSTextAlignmentRight;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetail:(EditItemModel *)model{
    self.textFieldContent.textColor = [UIColor blackColor];
    if ([model.title isEqualToString:@"手机:"] || [model.title isEqualToString:@"固话:"] || [model.title isEqualToString:@"QQ:"] || [model.title isEqualToString:@"分组按键:"]) {
        self.textFieldContent.keyboardType = UIKeyboardTypeNumberPad;
    }else if ([model.title isEqualToString:@"总金额:"] ) {
        self.textFieldContent.keyboardType = UIKeyboardTypeDecimalPad;
    }else if([model.keyStr isEqualToString:@"nextNavigationKey"]){
        self.textFieldContent.keyboardType = UIKeyboardTypeNumberPad;
    }
    else{
        self.textFieldContent.keyboardType = UIKeyboardTypeDefault;
    }
    
    CGSize sizeTitle = [CommonFunc getSizeOfContents:model.title Font:[UIFont systemFontOfSize:15.0] withWidth:2999 withHeight:20];
    self.labelTitle.frame = CGRectMake(10, 15, sizeTitle.width, 20);
    self.labelTitle.text = model.title;
    
    
    self.textFieldContent.frame = CGRectMake(sizeTitle.width+10+10, 0, DEVICE_BOUNDS_WIDTH-sizeTitle.width-30, 50);
    self.textFieldContent.text = model.content;
    
    
    if ([model.content isEqualToString:@""]) {
        self.textFieldContent.placeholder = model.placeholder;
    }
    
    self.textFieldContent.enabled = YES;
    if ([model.keyStr isEqualToString:@""]) {
        self.textFieldContent.enabled = NO;
        self.textFieldContent.textColor = [UIColor darkGrayColor];
        if ([model.title isEqualToString:@"分组名称:"] || [model.title isEqualToString:@"分组按键:"]) {
            self.textFieldContent.frame = CGRectMake(sizeTitle.width+10+10, 0, DEVICE_BOUNDS_WIDTH-sizeTitle.width-60, 50);
        }
    }
    
    self.textFieldContent.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.textFieldContent addTarget:self action:@selector(textValueChanged:) forControlEvents:UIControlEventEditingChanged];
}


- (void)textValueChanged:(id)sender
{
    if (self.textValueChangedBlock) {
        self.textValueChangedBlock(self.textFieldContent.text);
    }
}

@end
