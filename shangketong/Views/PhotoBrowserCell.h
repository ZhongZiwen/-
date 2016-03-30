//
//  PhotoBrowserCell.h
//  
//
//  Created by sungoin-zbs on 15/12/27.
//
//

#import <UIKit/UIKit.h>

@class RecordImage;

@interface PhotoBrowserCell : UITableViewCell

@property (copy, nonatomic) void(^imageTapBlock)(void);

- (void)configWithItem:(RecordImage*)item;
@end
