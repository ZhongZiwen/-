//
//  AddressBookActionSheet.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressBookActionSheet : UIView

@property (copy, nonatomic) void(^msgBlock)(NSString*);
@property (copy, nonatomic) void(^phoneBlock)(NSString*);

- (id)initWithCancelTitle:(NSString*)cancelTitle andMobile:(NSString*)mobile andPhone:(NSString*)photo;
- (void)show;
@end
