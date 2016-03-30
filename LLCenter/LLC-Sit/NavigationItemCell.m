//
//  NavigationItemCell.m
//  
//
//  Created by sungoin-zjp on 16/1/16.
//
//

#import "NavigationItemCell.h"

@implementation NavigationItemCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetail:(LLCenterSheetMenuModel *)model{
    self.labelName.text = model.title;
    self.accessoryType = UITableViewCellAccessoryNone;
    if([model.selectedFlag isEqualToString:@"yes"]){
        //        self.imgIcon.hidden = NO;
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

@end
