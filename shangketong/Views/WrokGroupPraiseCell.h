//
//  WrokGroupPraiseCell.h
//  shangketong
//
//  Created by sungoin-zjp on 15-7-10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WrokGroupPraiseCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UIButton *btnIcon;

-(void)setCellDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath;

@end
