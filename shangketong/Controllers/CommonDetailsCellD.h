//
//  CommonDetailsCellD.h
//  shangketong
//
//  Created by sungoin-zjp on 15-9-6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonDetailsCellD : UITableViewCell


@property (strong, nonatomic) IBOutlet UILabel *labelTitle;

-(void)setCellDetails:(NSDictionary *)item;
@end
