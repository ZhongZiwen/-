//
//  RecordSendTextCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "RecordSendTextCell.h"

@interface RecordSendTextCell ()<UITextViewDelegate>

@end

@implementation RecordSendTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (!_recordContentView) {
            _recordContentView = [[UIPlaceHolderTextView alloc] init];
            [_recordContentView setX:10];
            [_recordContentView setY:5];
            [_recordContentView setWidth:kScreen_Width - 2 * 10];
            [_recordContentView setHeight:[RecordSendTextCell cellHeight] - 2* 5];
            _recordContentView.font = [UIFont systemFontOfSize:16];
            _recordContentView.placeholder = @"请输入...";
            _recordContentView.returnKeyType = UIReturnKeyDefault;
            _recordContentView.delegate = self;
            [self.contentView addSubview:_recordContentView];
        }        
    }
    return self;
}

+ (CGFloat)cellHeight {

    return 95;
}

- (BOOL)becomeFirstResponder {
    [super becomeFirstResponder];
    [_recordContentView becomeFirstResponder];
    return YES;
}

- (BOOL)resignFirstResponder {
    [super resignFirstResponder];
    [_recordContentView resignFirstResponder];
    return YES;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    // 限制textView字数
    UITextRange *selectedRange = [textView markedTextRange];
    // 获取高亮部分
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    
    // 如果有高亮且当前字数开始位置小于最大限制时允许输入
    if (selectedRange && position) {
        NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.start];
        NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        
        if (offsetRange.location < MAX_LIMIT_TEXTVIEW) {
            return YES;
        }
        else {
            return NO;
        }
    }
    
    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    NSInteger caninputlen = MAX_LIMIT_TEXTVIEW - comcatstr.length;
    
    if (caninputlen >= 0) {
        return YES;
    }
    else {
        NSInteger len = text.length + caninputlen;
        // 防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};
        
        if (rg.length > 0)
        {
            NSString *s = [text substringWithRange:rg];
            
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
        }
        return NO;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    
    NSString  *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    
    if (existTextNum > MAX_LIMIT_TEXTVIEW)
    {
        //截取到最大位置的字符
        NSString *s = [nsTextContent substringToIndex:MAX_LIMIT_TEXTVIEW];
        
        [textView setText:s];
    }
}

@end
