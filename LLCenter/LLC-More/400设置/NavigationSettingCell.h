//
//  NavigationSettingCell.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-20.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationSettingCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *labelNavigationName;
@property (strong, nonatomic) IBOutlet UILabel *labelNumKey;
@property (strong, nonatomic) IBOutlet UILabel *labelRingName;
@property (strong, nonatomic) IBOutlet UIButton *btnPlay;


-(void)setCellDetails:(NSDictionary *)item andIndexPath:(NSIndexPath *)indexPath;


@property (nonatomic, copy) void (^PlayRingBlock)(NSInteger index);


- (void)playSoundWithUrlString:(NSString*)urlString ;
- (void)stopPlay;




@end
