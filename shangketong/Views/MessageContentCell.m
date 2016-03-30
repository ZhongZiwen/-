//
//  MessageContentCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MessageContentCell.h"
#import "UIPlaceHolderTextView.h"

@interface MessageContentCell ()<UITextViewDelegate>

@property (strong, nonatomic) UIPlaceHolderTextView *textView;
@end

@implementation MessageContentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (!_textView) {
            _textView = [[UIPlaceHolderTextView alloc] init];
            [_textView setX:10];
            [_textView setY:10];
            [_textView setWidth:kScreen_Width - 2 * 10];
            [_textView setHeight:[MessageContentCell cellHeight] - 2 * 10];
            _textView.delegate = self;
            _textView.font = [UIFont systemFontOfSize:16];
            _textView.placeholder = @"请输入...";
            _textView.returnKeyType = UIReturnKeyDefault;
            [self.contentView addSubview:_textView];
        }          
    }
    return self;
}

- (BOOL)becomeFirstResponder{
    [super becomeFirstResponder];
    [_textView becomeFirstResponder];
    return YES;
}

#pragma mark TextView Delegate
- (void)textViewDidChange:(UITextView *)textView{
    if (self.textValueChangedBlock) {
        self.textValueChangedBlock(textView.text);
    }
}

+ (CGFloat)cellHeight {
    return 320;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
