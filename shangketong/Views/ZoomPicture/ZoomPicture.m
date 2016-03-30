//
//  ZoomPicture.m
//  SavePhotoAlbum
//
//  Created by 蒋 on 15/6/12.
//  Copyright (c) 2015年 蒋. All rights reserved.
//

#import "ZoomPicture.h"

static CGRect oldframe;
static UIImage *savaImage;


@interface ZoomPicture ()
@end
@implementation ZoomPicture

+ (void)showImage:(UIImageView *)avatarImageView{
    UIImage *image = avatarImageView.image;
    savaImage = image;
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    
    UIView *backgroundView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    oldframe = [avatarImageView convertRect:avatarImageView.bounds toView:window];
    backgroundView.backgroundColor=[UIColor blackColor];
    backgroundView.alpha = 0;
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer: tap];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:oldframe];
    imageView.image = image;
    NSLog(@"%@-%@", image, imageView.image);
    imageView.tag = 100;
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
        backgroundView.alpha=1;
    } completion:^(BOOL finished) {
        
    }];
    
    UITapGestureRecognizer *savePhoneTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(savePhotoToAblum:)];
    UIImageView *savePhoneView = [[UIImageView alloc] initWithFrame:CGRectMake(50, [UIScreen mainScreen].bounds.size.height - 50, 30, 30)];
    savePhoneView.userInteractionEnabled = YES;
    savePhoneView.image = [UIImage imageNamed:@"save_icon_highlighted"];
    [savePhoneView addGestureRecognizer:savePhoneTap];
    
    [backgroundView addSubview:imageView];
    [backgroundView addSubview:savePhoneView];
    [window addSubview:backgroundView];
    
    
}
+ (void)hideImage:(UITapGestureRecognizer*)tap{
    UIView *backgroundView = tap.view;
    UIImageView *imageView = (UIImageView *)[tap.view viewWithTag:100];
    NSLog(@"%@", imageView.image);
    [UIView animateWithDuration:1 animations:^{
        imageView.frame = oldframe;
        backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
    }];
}
+ (void)savePhotoToAblum:(UITapGestureRecognizer *)tap{
    NSLog(@"保存照片");
    UIImageWriteToSavedPhotosAlbum(savaImage, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}
+ (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = @"";
    if (!error) {
        message = @"图片已成功保存到相册";
        kShowHUD(message, nil);
    }else
    {
        message = [error description];
    }
    NSLog(@"message is %@",message);
}

@end
