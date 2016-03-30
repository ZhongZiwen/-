//
//  ChargeRechargeCell.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-12-09.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "ChargeRechargeCell.h"
#import "CommonFunc.h"
#import "LLCenterUtility.h"

#define PNLightGrey     [UIColor colorWithRed:225.0 / 255.0 green:225.0 / 255.0 blue:225.0 / 255.0 alpha:1.0f]

@implementation ChargeRechargeCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    self.contentView.backgroundColor = COLOR_BG;
    self.backgroundColor=[UIColor clearColor];
    // Initialization code
    
    ///竖线
    self.imgLine.frame = CGRectMake(15, 0, 3, 19);
    self.imgLine.contentMode = UIViewContentModeScaleToFill;
    self.imgLine.image = [CommonFunc createImageWithColor:PNLightGrey];
    self.imgLine.layer.masksToBounds = YES;
    
    ///原点
    self.imgPoint.frame = CGRectMake(10, 18, 13, 13);
    self.imgPoint.contentMode = UIViewContentModeScaleToFill;
    self.imgPoint.image = [CommonFunc createImageWithColor:PNLightGrey];
    self.imgPoint.layer.masksToBounds = YES;
    self.imgPoint.layer.cornerRadius =  self.imgPoint.frame.size.width/2;
    
    ///竖线
    self.imgLineBottom.frame = CGRectMake(15, 31, 3, 19);
    self.imgLineBottom.contentMode = UIViewContentModeScaleToFill;
    self.imgLineBottom.image = [CommonFunc createImageWithColor:PNLightGrey];
    self.imgLineBottom.layer.masksToBounds = YES;
    
    NSInteger widthX = DEVICE_BOUNDS_WIDTH-320;
    self.labelDate.frame =  CGRectMake(50, 15, 130+widthX/2, 20);
    self.labelAmt.frame = CGRectMake(200+widthX/2, 15, 130+widthX/2, 20);
    
    self.imgBg.frame = CGRectMake(23, 5, DEVICE_BOUNDS_WIDTH-50, 40);
    self.imgBg.image = [UIImage imageNamed:@"img_recharge_content_bg.png"];
    self.imgBg.hidden = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetails:(NSDictionary *)item{
    NSString *strDate = [item safeObjectForKey:@"rechargedate"];
    NSString *strAmt = [item safeObjectForKey:@"rechargemonry"];
    self.labelDate.text = [NSString stringWithFormat:@"时间: %@",strDate];
    self.labelAmt.text = [NSString stringWithFormat:@"金额: %@元",strAmt];
}


///绘制三角形  正方形
- (void)drawRect:(CGRect)rect
{
    UIColor *colorContent = PNLightGrey;
    //设置背景颜色
    [[UIColor clearColor]set];
    UIRectFill([self bounds]);
    //拿到当前视图准备好的画板
    CGContextRef context = UIGraphicsGetCurrentContext();
    //利用path进行绘制三角形
    CGContextBeginPath(context);
    //标记
    CGContextMoveToPoint(context,23, 25);//设置起点
    CGContextAddLineToPoint(context,45, 5);
    CGContextAddLineToPoint(context,45, 45);
    CGContextClosePath(context);//路径结束标志，不写默认封闭
    [colorContent setFill];
    //设置填充色

    [colorContent setStroke];
    //设置边框颜色
    CGContextDrawPath(context, kCGPathFillStroke);//绘制路径path
    
    ///画正方形
    //矩形，填充颜色
    CGContextSetLineWidth(context, 0);//线的宽度
    CGContextSetFillColorWithColor(context, colorContent.CGColor);//填充颜色
    CGContextSetStrokeColorWithColor(context, colorContent.CGColor);//线框颜色
    CGContextAddRect(context,CGRectMake(45, 4.5, DEVICE_BOUNDS_WIDTH-55, 41));//画方框
    CGContextDrawPath(context, kCGPathFillStroke);//绘画路径
}


@end
