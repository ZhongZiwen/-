//
//  XLFormCustomTextViewCell.m
//  shangketong
//
//  Created by sungoin-zbs on 16/2/23.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import "XLFormCustomTextViewCell.h"

NSString *const XLFormRowDescriptorTypeCustomTextView = @"XLFormRowDescriptorTypeCustomTextView";

@interface XLFormCustomTextViewCell ()<UITextViewDelegate>

@end

@implementation XLFormCustomTextViewCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLFormCustomTextViewCell class] forKey:XLFormRowDescriptorTypeCustomTextView];
}

- (void)configure {
    [super configure];
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.textView];
}

- (void)update {
    [super update];
    
    self.textView.text = self.rowDescriptor.value;
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 110.0 + 30.0;
}

- (void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    [self.formViewController.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - UITextViewDelegate
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.formViewController beginEditing:self.rowDescriptor];
    return [self.formViewController textViewDidBeginEditing:textView];
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if ([self.textView.text length] > 0) {
        self.rowDescriptor.value = self.textView.text;
    } else {
        self.rowDescriptor.value = nil;
    }
    [self.formViewController endEditing:self.rowDescriptor];
    [self.formViewController textViewDidEndEditing:textView];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return [self.formViewController textViewShouldBeginEditing:textView];
}

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

-(void)textViewDidChange:(UITextView *)textView{
    
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
    
    if ([self.textView.text length] > 0) {
        self.rowDescriptor.value = self.textView.text;
    } else {
        self.rowDescriptor.value = nil;
    }
}

#pragma mark - setters and getters
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setX:15];
        [_titleLabel setWidth:kScreen_Width - 30];
        [_titleLabel setHeight:30];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UIPlaceHolderTextView *)textView {
    if (!_textView) {
        _textView = [[UIPlaceHolderTextView alloc] init];
        [_textView setX:7];
        [_textView setY:CGRectGetMaxY(self.titleLabel.frame)];
        [_textView setWidth:kScreen_Width - 2 * 7];
        [_textView setHeight:100.0f];
        _textView.font = [UIFont systemFontOfSize:15];
        _textView.delegate = self;
    }
    return _textView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
