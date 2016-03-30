//
//  ShowAndSaveController.m
//  shangketong
//
//  Created by 蒋 on 15/12/1.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ShowAndSaveController.h"
//#import <MBProgressHUD.h>
//#import <UIImageView+WebCache.h>
@interface ShowAndSaveController ()
@property (nonatomic, strong) UIImageView *imagView;

@end

@implementation ShowAndSaveController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    _imagView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 84, kScreen_Width - 40, kScreen_Height - 100)];
    _imagView.contentMode = UIViewContentModeScaleAspectFit;
    _imagView.image = _img_Show;
    _imagView.userInteractionEnabled = YES;
    [self.view addSubview:_imagView];
    //添加捏合手势
    [self addPinchGestureRecognizerForView:_imagView];

//    [_imagView sd_setImageWithURL:[NSURL URLWithString:_imgUrl] placeholderImage:[UIImage imageNamed:@"Expense_Detail_PhotoNoImageView"]];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveImageToiPhone)];
    self.navigationItem.rightBarButtonItem = rightItem;
    // Do any additional setup after loading the view from its nib.
}
- (void)saveImageToiPhone {
    UIImageWriteToSavedPhotosAlbum(_imagView.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}
- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = @"";
    if (!error) {
        kShowHUD(@"图片已成功保存到相册");
    }else
    {
        kShowHUD(@"出错了,图片不存在");
        message = [error description];
    }
    NSLog(@"message is %@",message);
}
- (void)addPinchGestureRecognizerForView:(UIImageView *)aView {
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [aView addGestureRecognizer:pinchGesture];
}
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)pinchGesture {
    pinchGesture.view.transform = CGAffineTransformScale(pinchGesture.view.transform, pinchGesture.scale, pinchGesture.scale);
    pinchGesture.scale = 1.0;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
