//
//  CommonDetailsCellA.h
//  shangketong
//
//  Created by sungoin-zjp on 15-8-25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonDetailsCellA : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelContent;
@property (strong, nonatomic) IBOutlet UIImageView *imgArrow;

@property (strong, nonatomic) IBOutlet UIImageView *imgLine;



///填充详情
-(void)setCellDetails:(NSDictionary *)item indexPath:(NSIndexPath *)index;

@end
