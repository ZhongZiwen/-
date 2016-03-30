//
//  AddressBookActionSheetCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressBookActionSheetCell : UITableViewCell

@property (copy, nonatomic) void(^msgBtnClickedBlock)(NSString*);
@property (copy, nonatomic) void(^phoneBtnClickedBlock)(NSString*);

- (void)configWithMobile:(NSString*)mobile;
- (void)configWithPhone:(NSString*)phone;
@end
