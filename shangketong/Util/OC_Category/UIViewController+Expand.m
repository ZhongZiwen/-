//
//  UIViewController+Expand.m
//  shangketong
//
//  Created by sungoin-zbs on 15/12/12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "UIViewController+Expand.h"

@implementation UIViewController (Expand)

- (void)takePhoneWithNumber:(NSString *)number {
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@", number];
    UIWebView * callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    [self.view addSubview:callWebview];
}

- (void)sendMessageWithRecipients:(NSArray *)recipientsArray {
    // 判断设备是否支持发送短信
    if (![MFMessageComposeViewController canSendText]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"该设备不支持短信功能" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    [messageController.navigationBar setTintColor:[UIColor whiteColor]];
    // 设置短信代理
    messageController.messageComposeDelegate = self;
    messageController.recipients = recipientsArray;
    messageController.body = nil;
    [self presentViewController:messageController animated:YES completion:nil];
}

- (void)sendEmailWithRecipients:(NSArray *)recipientsArray {
    // 用户已设置邮件账户
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请设置邮件账户" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    // 邮件服务器
    MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
    [mailCompose.navigationBar setTintColor:[UIColor whiteColor]];
    // 设置邮件代理
    [mailCompose setMailComposeDelegate:self];
    
    // 设置邮件主题
    //    [mailCompose setSubject:@"title"];
    // 设置收件人
    [mailCompose setToRecipients:recipientsArray];
    // 设置抄送人
    //    [mailCompose setCcRecipients:@[@"425886069@qq.com"]];
    // 设置密抄送
    //    [mailCompose setBccRecipients:@[@"425886069@qq.com"]];
    
    // 设置邮件的正文内容
    //    NSString *emailContent = @"content";
    // 是否为HTML格式
    //    [mailCompose setMessageBody:emailContent isHTML:NO];
    // 如使用HTML格式，则为以下代码
    //    [mailCompose setMessageBody:@"<html><body><p>Hello</p><p>World！</p></body></html>" isHTML:YES];
    
    // 添加附件
    /** eg.
     UIImage *image = [UIImage imageNamed:@"image"];
     NSData *imageData = UIImagePNGRepresentation(image);
     [mailCompose addAttachmentData:imageData mimeType:@"" fileName:@"image.png"];
     
     NSString *file = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"pdf"];
     NSData *pdf = [NSData dataWithContentsOfFile:file];
     [mailCompose addAttachmentData:pdf mimeType:@"" fileName:@"xxxpdf"];
     */
    
    // 弹出邮件发送视图
    [self presentViewController:mailCompose animated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled: // 用户取消编辑
            NSLog(@"Mail send canceled...");
            break;
        case MFMailComposeResultSaved: // 用户保存邮件
            NSLog(@"Mail saved...");
            break;
        case MFMailComposeResultSent: // 用户点击发送
            NSLog(@"Mail sent...");
            break;
        case MFMailComposeResultFailed: // 用户尝试保存或发送邮件失败
            NSLog(@"Mail send errored: %@...", [error localizedDescription]);
            break;
    }
    
    // 关闭邮件发送视图
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultSent: {
            //信息传送成功
            [NSObject showHudTipStr:@"短信发送成功!"];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        case MessageComposeResultFailed: {
            //信息传送失败
            [NSObject showHudTipStr:@"短信发送失败"];
        }
            break;
        case MessageComposeResultCancelled: {
            //信息被用户取消传送
            NSLog(@"Msg send canceled...");
            [self dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        default:
            break;
    }
    
}
@end
