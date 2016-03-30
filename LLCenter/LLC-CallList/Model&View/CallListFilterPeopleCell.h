//
//  CallListFilterPeopleCell.h
//  lianluozhongxin
//
//  Created by Vescky on 14-6-23.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallListFilterPeopleCell : UITableViewCell {
    IBOutlet UILabel *labelName,*labelWorkNo,*labelPhoneNum;
}

- (void)setCellDataInfo:(NSDictionary*)cInfo;

@end
