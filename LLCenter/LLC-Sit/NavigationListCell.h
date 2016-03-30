//
//  NavigationListCell.h
//  
//
//  Created by sungoin-zjp on 16/1/6.
//
//

#import <UIKit/UIKit.h>
#import "LLCenterSheetMenuModel.h"

@interface NavigationListCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UIImageView *imgIcon;

-(void)setCellDetail:(LLCenterSheetMenuModel *)model;

@end
