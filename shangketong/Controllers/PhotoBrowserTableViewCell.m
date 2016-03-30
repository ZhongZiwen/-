//
//  PhotoBrowserTableViewCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PhotoBrowserTableViewCell.h"
#import "PhotoAssetModel.h"

@interface PhotoBrowserTableViewCell ()

@property (nonatomic, strong) UIImageView *m_imageView;
@end

@implementation PhotoBrowserTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.m_imageView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)configWithModel:(PhotoAssetModel *)photoModel {
    
    @autoreleasepool {
        UIImage *thumbnail = [UIImage imageWithCGImage:photoModel.asset.thumbnail];
        [self.m_imageView setImage:thumbnail];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            ALAssetRepresentation* rep = [photoModel.asset defaultRepresentation];
            CGImageRef iref = CGImageRetain([rep fullScreenImage]);
            UIImage *fullScreenImage = [UIImage imageWithCGImage:iref];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.m_imageView setImage:fullScreenImage];
                CGImageRelease(iref);
            });
        });
    }

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
//        @autoreleasepool {
//            ALAssetRepresentation* rep = [photoModel.asset defaultRepresentation];
//            CGImageRef iref = CGImageRetain([rep fullScreenImage]);
//            UIImage *image = [UIImage imageWithCGImage:iref];
//            
//            dispatch_async(dispatch_get_main_queue(), ^(void) {
//                [self.m_imageView setImage:image];
//                
//                CGImageRelease(iref);
//            });
//        }
//    });
}

- (void)tapAction {
    if (self.cellTapBlock) {
        self.cellTapBlock();
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIImageView*)m_imageView {
    if (!_m_imageView) {
        _m_imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _m_imageView.userInteractionEnabled = YES;
        _m_imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
        _m_imageView.transform = transform;
        _m_imageView.frame = CGRectMake(0, 10, kScreen_Height, kScreen_Width);
    }
    return _m_imageView;
}
@end
