//
//  SitDetailNavCell.m
//  
//
//  Created by sungoin-zjp on 16/1/5.
//
//

#import "SitDetailNavCell.h"

@implementation SitDetailNavCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetail:(NSDictionary *)item{
    NSString *name = [item safeObjectForKey:@"name"];
    ///最多显示6个，多出部门用...表示
    if (name.length>6) {
        name = [NSString stringWithFormat:@"%@...",[name substringToIndex:6]];
    }
    self.lableName.text = name;
}

@end
