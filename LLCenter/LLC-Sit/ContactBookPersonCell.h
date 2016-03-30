//
//  ContactBookPersonCell.h
//  lianluozhongxin
//
//  Created by Vescky on 14-6-24.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactsInfo.h"

@interface ContactBookPersonCell : UITableViewCell {
    IBOutlet UILabel *labelUserName,*labelJobNumber,*labelPhoneNumber;
    
    IBOutlet UIView *view_line;
    IBOutlet UIImageView *img_info_icon;
}

- (void)setCellDataInfo:(ContactsInfo*)cInfo;

-(void)setCellViewFrame;

@end
