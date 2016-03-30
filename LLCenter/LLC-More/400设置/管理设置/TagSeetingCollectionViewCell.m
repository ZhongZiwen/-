//
//  TagSeetingCollectionViewCell.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-13.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "TagSeetingCollectionViewCell.h"

@implementation TagSeetingCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}


-(void)setCellFrame:(NSIndexPath *)indexPath{
    self.imgDeleteIcon.frame = CGRectMake(2, 0, 17, 17);
    self.btnTag.frame = CGRectMake(10, 5, self.frame.size.width-20, self.frame.size.height-10);
    self.btnTag.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    self.btnTag.tag = indexPath.row;
    [self.btnTag addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)deleteAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.DeleteTagBlock) {
        self.DeleteTagBlock(btn.tag);
    }
}

@end
