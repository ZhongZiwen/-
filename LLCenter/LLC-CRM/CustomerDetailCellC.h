//
//  CustomerDetailCellC.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-13.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayingProcessBar.h"

@interface CustomerDetailCellC : UITableViewCell

@property (strong, nonatomic) PlayingProcessBar *playingProcessBar;
@property (strong, nonatomic) IBOutlet UIButton *btnPlay;
@property (strong, nonatomic) IBOutlet UILabel *labelCurrentTime;
@property (strong, nonatomic) IBOutlet UILabel *labelTotleTime;


-(void)setCellDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath;
#pragma mark - 获取cell height
+(CGFloat)getCellContentHeight:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath;


- (void)stopPlay;
- (IBAction)btnAction:(id)sender;



@end
