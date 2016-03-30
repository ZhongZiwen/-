//
//  EditTitleValueTableViewCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/5/5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TextValueChangedBlock) (NSString *valueStr);

@interface EditTitleValueTableViewCell : UITableViewCell

@property (nonatomic, weak) UITextField *m_textField;

@property (nonatomic, copy) TextValueChangedBlock textValueChangedBlock;

+ (CGFloat)cellHeight;
- (void)setTitleLabel:(NSString*)titleStr valueLabel:(NSString*)valueStr;
@end
