//
//  Hearder_View.m
//  HeaderView_Demo
//
//  Created by 蒋 on 15/10/12.
//  Copyright (c) 2015年 蒋. All rights reserved.
//

#import "Hearder_View.h"
#import <UIImageView+WebCache.h>
#import "AFNHttp.h"

@interface Hearder_View ()

@property (nonatomic, strong) UIView *bgView;
@end

@implementation Hearder_View

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:_bgView];
    }
    return self;
}
- (void)customImageViews:(NSArray *)imagesArray {
    NSInteger count = imagesArray.count;
    NSArray *newarray = [NSArray array];
    if (count > 9) {
        count = 9;
        newarray = [imagesArray subarrayWithRange:NSMakeRange(0, 9)];
    }
    NSInteger linesCount; //行数
    NSInteger firstLineCount;//第一行的个数
    if (count >= 3 && count <= 6) {
        linesCount = 2;
        if (count >= 5) {
            firstLineCount = count - (linesCount - 1) * 3;
        } else {
            firstLineCount = count - 2;
        }
    } else if (count > 6) {
        linesCount = 3; 
        firstLineCount = count - (linesCount - 1) * 3;
    }
    [self imageViewsWithArray:imagesArray withLines:linesCount wihtFirstLineCount:firstLineCount];
}
- (void)imageViewsWithArray:(NSArray *)imagesArray withLines:(NSInteger)lines wihtFirstLineCount:(NSInteger)firstLineCount {
    CGFloat space_first_width = 0.0; //第一行头像之间的间距
    CGFloat space_width = 2.0; //水平间距
    CGFloat space_height = 0.; //竖直间距
    CGFloat width = 0.;
    NSInteger othersLinesCount = 0;
    NSInteger count = 0;
    NSInteger index = 0; //标记当前数组的下标
    for (UIView *imgView in [self.bgView subviews]) {
        [imgView removeFromSuperview];
    }
    if (imagesArray && imagesArray.count >= 3) {
        for (int i = 1; i <= lines; i++) { //行数
            //其余行的个数（除第一行）
            if (lines < 3) {
                othersLinesCount = imagesArray.count - firstLineCount;
            } else {
                othersLinesCount = 3;
            }
            //每一个imgView的宽度（高度）
            width = (_bgView.frame.size.width - space_width * (othersLinesCount + 1)) / othersLinesCount;
            //计算出竖直间距
            if (lines < 3 && imagesArray.count >= 5) {
                space_height = width / 3;
            } else {
                space_height = 0.0;
            }
            
            if (i == 1) {
                //第一行的水平间距、imgView个数
                count = firstLineCount;
                if (firstLineCount < othersLinesCount) {
                    space_first_width = (_bgView.frame.size.width - space_width * (firstLineCount + 1) - width * firstLineCount) / (firstLineCount + 1);
                } else {
                    space_first_width = 0.0;
                }
            } else {
                //除第一行之外
                count = othersLinesCount;
                space_first_width = 0.0;
            }
            
            for (int j = 1; j <= count; j++) { //每行个数
                UIImageView *imgeView = [[UIImageView alloc] initWithFrame:CGRectMake((space_width + space_first_width) * j +  width * (j - 1), i * (space_width + space_height) + width * (i - 1), width, width)];
                if ([imagesArray[index] isEqualToString:@""]) {
                    imgeView.image = [UIImage imageNamed:@"user_icon_default"];
                } else {
//                    [imgeView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", GET_IM_ICON_URL, imagesArray[index]]] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
                    [imgeView sd_setImageWithURL:[NSURL URLWithString:imagesArray[index]] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
                }
                imgeView.contentMode = UIViewContentModeScaleAspectFill;
                imgeView.clipsToBounds = YES;
                [self.bgView addSubview:imgeView];
                index++;
            }
        }

    } else {
        width = self.bgView.frame.size.width;
        if (imagesArray && imagesArray.count == 2) {
            NSLog(@"此讨论组中只剩下两个人");
            for (int i = 1; i <= imagesArray.count; i++) {
                UIImageView *imgeView = [[UIImageView alloc] initWithFrame:CGRectMake(space_width * i +  (width - space_width * 3) / 2 * (i - 1), width / 4, (width - space_width * 3) / 2, (width - space_width * 3) / 2)];
                if ([imagesArray[i - 1] isEqualToString:@""]) {
                    imgeView.image = [UIImage imageNamed:@"user_icon_default"];
                } else {
//                    [imgeView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", GET_IM_ICON_URL, imagesArray[i - 1]]] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
                    [imgeView sd_setImageWithURL:[NSURL URLWithString:imagesArray[i - 1]] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
                }
                imgeView.contentMode = UIViewContentModeScaleAspectFill;
                imgeView.clipsToBounds = YES;
                [self.bgView addSubview:imgeView];
            }
        } else {
            NSLog(@"此讨论组中只剩下一个人");
            UIImageView *imgeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
            if (imagesArray && imagesArray.count > 0) {
                if ([imagesArray[0] isEqualToString:@""]) {
                    imgeView.image = [UIImage imageNamed:@"user_icon_default"];
                } else {
//                    [imgeView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", GET_IM_ICON_URL, imagesArray[0]]] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
                    [imgeView sd_setImageWithURL:[NSURL URLWithString:imagesArray[0]] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
                }
                imgeView.contentMode = UIViewContentModeScaleAspectFill;
                imgeView.clipsToBounds = YES;
                [self.bgView addSubview:imgeView];
            }
        }
    }
}
@end
