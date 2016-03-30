//
//  UIImageViewBrowser.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "UIImageViewBrowser.h"

static UIImageView *orginImageView;
static UIImage *oldImage;
static UIButton *saveBtn;
@implementation UIImageViewBrowser

+(void)showImage:(UIImageView *)avatarImageView{
    UIImage *image=avatarImageView.image;
    orginImageView = avatarImageView;
    orginImageView.alpha = 0;
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    UIView *backgroundView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    CGRect oldframe=[avatarImageView convertRect:avatarImageView.bounds toView:window];
    backgroundView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.7];
    backgroundView.alpha=1;
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:oldframe];
    imageView.image=image;
    imageView.tag=1;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    
    oldImage = image;
    saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    saveBtn.frame = CGRectMake( kScreen_Width - 70, 64, 50, 50);
    saveBtn.backgroundColor = [UIColor redColor];
    UITapGestureRecognizer *saveTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveImageForPhone)];
    [saveBtn addGestureRecognizer:saveTap];
    [window addSubview:saveBtn];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer: tap];
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
        backgroundView.alpha=1;
    } completion:^(BOOL finished) {
        
    }];
}

+(void)hideImage:(UITapGestureRecognizer*)tap {
    UIView *backgroundView=tap.view;
    UIImageView *imageView=(UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.3 animations:^{
        [saveBtn removeFromSuperview];
        imageView.frame=[orginImageView convertRect:orginImageView.bounds toView:[UIApplication sharedApplication].keyWindow];
    } completion:^(BOOL finished) {
       
        [backgroundView removeFromSuperview];
        orginImageView.alpha = 1;
        backgroundView.alpha=0;
    }];
}
+ (void)saveImageForPhone {
    UIImageWriteToSavedPhotosAlbum(oldImage, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}
+ (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = @"";
    if (!error) {
        message = @"图片已成功保存到相册";
    }else
    {
        message = [error description];
    }
    NSLog(@"message is %@",message);
}
@end
