//
//  LogoutCell.h
//  shangketong
//  
//  Created by sungoin-zjp on 15-7-15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogoutCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;


-(void)setCellDetails:(NSString *)title;

@end
