//
//  ActivityRecordImagesView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kWidth_imageView 80

@interface ActivityRecordImagesView : UIView

@property (strong, nonatomic) UIViewController *handleVC;

- (void)configWithArray:(NSArray*)imagesArray;
@end
