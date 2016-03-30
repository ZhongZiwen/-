//
//  SitHeadCell.m
//  
//
//  Created by sungoin-zjp on 16/1/6.
//
//

#import "SitHeadCell.h"

@implementation SitHeadCell

- (void)awakeFromNib {
    // Initialization code
    self.btnRight.frame = CGRectMake(kScreen_Width-60, 0, 60, 60);
    self.labelContent.frame = CGRectMake(110, 0, kScreen_Width-110-50-10, 60);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetail:(NSDictionary *)item{
    self.btnRight.hidden = NO;
    self.labelName.text = [item objectForKey:@"name"];
    self.labelContent.text = [item objectForKey:@"content"];
    if([[item objectForKey:@"tag"] isEqualToString:@"navNum"]){
        [self.btnRight setImage:[UIImage imageNamed:@"btn_to_right_gray.png"] forState:UIControlStateNormal];
    }else{
        if ([item safeObjectForKey:@"content"].length > 0 && [item safeObjectForKey:@"ringurl"].length > 0) {
            
        }else{
            self.btnRight.hidden = YES;
        }
        [self.btnRight setImage:[UIImage imageNamed:@"icon_listen.png"] forState:UIControlStateNormal];
    }
}

///右边按钮事件
- (IBAction)rightAction:(id)sender {
    if(self.RightBtnActionBlock){
        self.RightBtnActionBlock();
    }
}



@end
