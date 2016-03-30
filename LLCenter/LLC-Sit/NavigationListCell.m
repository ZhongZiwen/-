//
//  NavigationListCell.m
//  
//
//  Created by sungoin-zjp on 16/1/6.
//
//

#import "NavigationListCell.h"

@implementation NavigationListCell

- (void)awakeFromNib {
    // Initialization code
    self.imgIcon.frame = CGRectMake(kScreen_Width-35, 16, 18, 19);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetail:(LLCenterSheetMenuModel *)model{
    self.labelName.text = model.title;
    self.imgIcon.hidden = YES;
    self.accessoryType = UITableViewCellAccessoryNone;
    if([model.selectedFlag isEqualToString:@"yes"]){
//        self.imgIcon.hidden = NO;
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

@end
