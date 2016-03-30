//
//  NavigationItemCell.h
//  
//
//  Created by sungoin-zjp on 16/1/16.
//
//

#import <UIKit/UIKit.h>
#import "LLCenterSheetMenuModel.h"

@interface NavigationItemCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *labelName;

-(void)setCellDetail:(LLCenterSheetMenuModel *)model;

@end
