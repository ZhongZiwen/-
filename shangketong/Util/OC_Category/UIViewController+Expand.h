//
//  UIViewController+Expand.h
//  shangketong
//
//  Created by sungoin-zbs on 15/12/12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface UIViewController (Expand)<MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

- (void)takePhoneWithNumber:(NSString*)number;
- (void)sendMessageWithRecipients:(NSArray*)recipientsArray;
- (void)sendEmailWithRecipients:(NSArray*)recipientsArray;
@end
