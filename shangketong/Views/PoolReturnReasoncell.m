//
//  PoolReturnReasoncell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PoolReturnReasoncell.h"
#import "UIPlaceHolderTextView.h"

@interface PoolReturnReasoncell ()<UITextViewDelegate>

@property (strong, nonatomic) UIPlaceHolderTextView *textView;
@end

@implementation PoolReturnReasoncell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        if (!_textView) {
            _textView = [[UIPlaceHolderTextView alloc] init];
            [_textView setX:15];
            [_textView setY:15];
            [_textView setWidth:kScreen_Width - 2 * 15];
            [_textView setHeight:[PoolReturnReasoncell cellHeight] - 15];
            _textView.delegate = self;
            _textView.font = [UIFont systemFontOfSize:16];
            _textView.placeholder = @"请输入退回理由...";
            _textView.returnKeyType = UIReturnKeyDefault;
            _textView.layer.cornerRadius = 5;
            _textView.layer.borderWidth = 0.5;
            _textView.layer.borderColor = [UIColor iOS7lightGrayColor].CGColor;
            [self.contentView addSubview:_textView];
        }
    }
    return self;
}

#pragma mark TextView Delegate
- (void)textViewDidChange:(UITextView *)textView{
    if (self.textValueChangedBlock) {
        self.textValueChangedBlock(textView.text);
    }
}

+ (CGFloat)cellHeight {
    return 200;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
