//
//  MenuItemSwitchCell.h
//  
//
//  Created by sungoin-zjp on 16/1/20.
//
//

#import <UIKit/UIKit.h>

@interface MenuItemSwitchCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *lableTitle;

@property (strong, nonatomic) IBOutlet UISwitch *switchBtn;

-(void)setCellDetail:(NSDictionary *)item;
@property (nonatomic, copy) void (^NotifySwitchBlock)(void);
@end
