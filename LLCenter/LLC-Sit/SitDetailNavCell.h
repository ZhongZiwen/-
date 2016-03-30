//
//  SitDetailNavCell.h
//  
//
//  Created by sungoin-zjp on 16/1/5.
//
//

#import <UIKit/UIKit.h>

@interface SitDetailNavCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *lableName;

-(void)setCellDetail:(NSDictionary *)item;
@end
