//
//  PreviewFileViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PreviewFileViewController.h"
#import "UIView+Common.h"

@interface PreviewFileViewController ()

@property (nonatomic, strong) UIImageView *mImageView;
@property (nonatomic, strong) UILabel *mSizeLabel;
@property (nonatomic, strong) UILabel *mNameLabel;
@property (nonatomic, strong) UIButton *mPreviewBtn;
@end

@implementation PreviewFileViewController

- (void)loadView {
    [super loadView];
    
    [self.view addSubview:self.mImageView];
    [self.view addSubview:self.mSizeLabel];
    [self.view addSubview:self.mNameLabel];
    [self.view addSubview:self.mPreviewBtn];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setters and getters
- (UIImageView*)mImageView {
    if (!_mImageView) {
        UIImage *image = [UIImage imageNamed:@"file_document_large"];
        _mImageView = [[UIImageView alloc] initWithImage:image];
        _mImageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        [_mImageView setCenterX:kScreen_Width / 2];
        [_mImageView setCenterY:200];
    }
    return _mImageView;
}

- (UILabel*)mSizeLabel {
    if (!_mSizeLabel) {
        _mSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
        _mSizeLabel.font = [UIFont systemFontOfSize:12];
        _mSizeLabel.textColor = [UIColor lightGrayColor];
        _mSizeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _mSizeLabel;
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
