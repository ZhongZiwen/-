//
//  CommonUtility.h
//  SandBayCinema
//
//  Created by Rayco on 12-11-1.
//  Copyright (c) 2012年 Apps123. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegexKitLite.h"
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>
#import <CommonCrypto/CommonDigest.h>
#import "AppDelegate.h"

CG_INLINE NSString *toUTF8String(NSString* str) {
    NSData *responseData = [NSData dataWithBytes:[str UTF8String] length:str.length];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *resultStr = [[NSString alloc] initWithData:responseData encoding:enc];
    return resultStr;
}





CG_INLINE NSString* getWeatherIcon(NSString*w , bool isBig) {
    if (!w || w.length < 1) {
        return @"sunny_green.png";
        if (isBig) {
            return @"sunny_big.png";
        }
        return @"sunny.png";
    }
    NSString *str = @"";
    if ([w stringByMatching:@"晴"]) {
        return @"sunny_green.png";
        if (isBig) {
            return @"sunny_big.png";
        }
        str = @"sunny.png";
    }
    else if ([w stringByMatching:@"雨"]) {
        return @"rainny_green.png";
        if (isBig) {
            return @"rainny_big.png";
        }
        str = @"rainny.png";
    }
    else if ([w stringByMatching:@"雪"]) {
        return @"snowy_green.png";
        if (isBig) {
            return @"snowy_big.png";
        }
        str = @"snowy.png";
    }
    else {
        //阴天，包括多云，沙尘暴，灰霾等等
        return @"cloudy_green.png";
        if (isBig) {
            return @"cloudy_big.png";
        }
        str = @"cloudy.png";
    }
    return str;
}

//把天气简化成四种：晴、雨、雪、阴
CG_INLINE NSString*  simplifyWeather(NSString *w) {
    if (!w || w.length < 1) {
        return @"晴";
    }
    NSString *str = @"";
    if ([w stringByMatching:@"晴"]) {
        str = @"晴";
    }
    else if ([w stringByMatching:@"雨"]) {
        str = @"雨";
    }
    else if ([w stringByMatching:@"雪"]) {
        str = @"雪";
    }
    else {
        //阴天，包括多云，沙尘暴，灰霾等等
        str = @"阴";
    }
    return str;
}

CG_INLINE NSString*  getAvartaLinkFromId(NSString *tId,bool isTeam) {
    if (isTeam) {
        return [NSString stringWithFormat:@"http://golffriend-golffriend.stor.sinaapp.com/avatar/GolfTeams/%@.png",tId];
    }
    else {
        return [NSString stringWithFormat:@"http://golffriend-golffriend.stor.sinaapp.com/avatar/Users/%@.png",tId];
    }
}

CG_INLINE BOOL isSubViewOfMainView(UIView *mainView,UIView *aView) {
    for(UIView *view in mainView.subviews){
        if ([view isEqual:aView]) {
            return YES;
        }
    }
    return NO;
}


CG_INLINE NSString* getRandomStrings(int length) {
    if (length <= 0) {
        return @"0";
    }
    NSString *str = @"";
    for (int i = 0; i < length; i++) {
        int r = arc4random() % 10; //随机生成0-9 的数字
        str = [str stringByAppendingFormat:@"%d",r];
    }
    return str;
}

//纠正图片的方向
CG_INLINE UIImage* adjustPhotoOrientation(UIImage  *aImage) {
    
    if (aImage == nil)
    {
        return nil;
    }
    CGImageRef imgRef = aImage.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGFloat scaleRatio = 1;
    CGFloat boundHeight;
    UIImageOrientation orient = aImage.imageOrientation;
    switch(orient) {
        case UIImageOrientationUp: //EXIF = 1
        {
            transform = CGAffineTransformIdentity;
            break;
        }
        case UIImageOrientationUpMirrored: //EXIF = 2
        {
            transform = CGAffineTransformMakeTranslation(width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        }
        case UIImageOrientationDown: //EXIF = 3
        {
            transform = CGAffineTransformMakeTranslation(width, height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        }
        case UIImageOrientationDownMirrored: //EXIF = 4
        {
            transform = CGAffineTransformMakeTranslation(0.0, height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        }
        case UIImageOrientationLeftMirrored: //EXIF = 5
        {
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        }
        case UIImageOrientationLeft: //EXIF = 6
        {
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        }
        case UIImageOrientationRightMirrored: //EXIF = 7
        {
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        }
        case UIImageOrientationRight: //EXIF = 8
        {
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        }
        default:
        {
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            break;
        }
    }
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
    {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    } else
    {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageCopy;
}


//保存压缩后的图像，更适合网络传输.返回Document路径
CG_INLINE NSString* saveAndResizeImage(UIImage *_image,NSString *_sName) {
    CGSize newSize = CGSizeMake(640, 640 * _image.size.height / _image.size.width);
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [_image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* tmpImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    
    UIImage *newImage = adjustPhotoOrientation(tmpImage);
    
    //保存新图片到Document
    NSData *data;
    if (UIImagePNGRepresentation(newImage) == nil) {
        data = UIImageJPEGRepresentation(newImage, 0.5);
    } else {
        data = UIImagePNGRepresentation(newImage);
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *imgSavePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    imgSavePath = [imgSavePath stringByAppendingPathComponent:_sName];
    if ([fm fileExistsAtPath:imgSavePath]) {
        [fm removeItemAtPath:imgSavePath error:nil];
    }
    [fm createFileAtPath:imgSavePath contents:data attributes:nil];
    return imgSavePath;
}

/**
 * 计算两组经纬度坐标 之间的距离
 * params ：lat1 纬度1； lng1 经度1； lat2 纬度2； lng2 经度2； len_type （1:m or 2:km);
 * return m or km
 */
CG_INLINE double getDistance(double lat1, double lng1, double lat2, double lng2, double len_type)
{
    double EARTH_RADIUS=6378.137;
    double PI=3.1415926;
    double radLat1 = lat1 * PI / 180.0;
    double radLat2 = lat2 * PI / 180.0;
    double a = radLat1 - radLat2;
    double b = (lng1 * PI / 180.0) - (lng2 * PI / 180.0);
    double s = 2 * asin(sqrt(pow(sin(a/2),2) + cos(radLat1) * cos(radLat2) * pow(sin(b/2),2)));
    s = s * EARTH_RADIUS;
    s = round(s * 1000);
    if (len_type > 1)
    {
        s /= 1000;
    }
    return round(s);
}

//string:lon,lat
CG_INLINE CLLocation* getGfLocation(NSString* location) {
    NSArray *arr = [location componentsSeparatedByString:@","];
    if ([arr count] >= 2) {
        double lon = [[arr objectAtIndex:0] doubleValue];
        double lat = [[arr objectAtIndex:1] doubleValue];
        return [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    }
    return nil;
}


CG_INLINE NSString* getFormatedDistance(double dist) {
    NSString *resultString = @"";
    if (dist <= 100) {
        resultString = @"100米以内";
    }
    else if (dist <= 200) {
        resultString = @"200米以内";
    }
    else if (dist <= 500) {
        resultString = @"500米以内";
    }
    else if (dist <= 1000) {
        resultString = @"1000米以内";
    }
    else if (dist <= 2000) {
        resultString = @"2000米以内";
    }
    else if (dist <= 5000) {
        resultString = @"5000米以内";
    }
    else if (dist <= 10000) {
        resultString = @"10km以内";
    }
    else {
        resultString = @"大于10km";
    }
    
    return resultString;
}

CG_INLINE BOOL isValueSet(id obj) {
    if (!obj) {
        return NO;
    }
    if ([obj isKindOfClass:NSClassFromString(@"NSArray")] || [obj isKindOfClass:NSClassFromString(@"NSMutableArray")]) {
        if ([obj count] > 0) {
            return YES;
        }
    }
    else if ([obj isKindOfClass:NSClassFromString(@"NSDictionary")] || [obj isKindOfClass:NSClassFromString(@"NSMutableDictionary")]) {
        if ([obj count] > 0) {
            return YES;
        }
    }
    else if ([obj isKindOfClass:NSClassFromString(@"NSString")]) {
        if ([obj length] > 0) {
            return YES;
        }
    }
    return NO;
}


CG_INLINE NSString *combineArrayWithSeperator(NSArray *arr,NSString *sep) {
    if (!isValueSet(arr)) {
        return @"";
    }
    NSString *resultString = @"";
    for (int i = 0; i < [arr count]; i++) {
        NSString *msgIdString = [[arr objectAtIndex:i] objectForKey:@"msgId"];
        if (i == [arr count] - 1) {
            resultString = [resultString stringByAppendingString:msgIdString];
        }
        else {
            resultString = [resultString stringByAppendingFormat:@"%@%@",msgIdString,sep];
        }
        
    }
    return resultString;
}

CG_INLINE NSString *md5Encode(NSString *input)
{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02X",result[i]];
    }
    return [ret lowercaseString];
}


CG_INLINE BOOL iPhone5() {
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO);
}

CG_INLINE BOOL iPhone6() {
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO);
}

CG_INLINE BOOL iPhoneplus() {
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO);
}

CG_INLINE BOOL ios7OrLater() {
    return ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) ? YES : NO;
}

CG_INLINE UIColor *GetColorWithRGB(float r,float g,float b) {
    return [UIColor colorWithRed:(float)r/255.0 green:(float)g/255.0 blue:(float)b/255.0 alpha:1.0];
}

CG_INLINE NSString *GetDocumentPath() {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}

CG_INLINE NSString *getTmpPath() {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
}

CG_INLINE NSString *GetMainBundlePath() {
    return [[NSBundle mainBundle] bundlePath];
}

CG_INLINE AppDelegate* app_delegate() {
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}



CG_INLINE float getTextHeightForLabelWithLineHeight(NSString *textString,float labelWidth,float lineHeight,UIFont *textFont) {
    CGSize cSize;
    if (ios7OrLater()) {
        NSDictionary *attribute = [NSDictionary dictionaryWithObjectsAndKeys:textFont,NSFontAttributeName, nil];
        
        cSize = [textString boundingRectWithSize:CGSizeMake(labelWidth, 2000) options: NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    }
    
   
    /*
    cSize = [textString sizeWithFont:textFont constrainedToSize:CGSizeMake(labelWidth,2000) lineBreakMode:0];
     */
    
    
    NSDictionary *attribute = [NSDictionary dictionaryWithObjectsAndKeys:textFont,NSFontAttributeName, nil];
    
//    cSize = [textString boundingRectWithSize:CGSizeMake(labelWidth,2000) options: NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    cSize = [textString boundingRectWithSize:CGSizeMake(labelWidth, 2000) options: NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    
    
    cSize.height = (int)(cSize.height / lineHeight + 1) * lineHeight;//(cSize.height >= 30.0f ? cSize.height : 30.0f);
    return cSize.height;
}

CG_INLINE float getTextHeightForLabel(NSString *textString,float labelWidth,UIFont *textFont) {
    CGSize cSize;
    if (ios7OrLater()) {
        return getTextHeightForLabelWithLineHeight(textString,labelWidth,20.0,textFont);
    }
    else {
        
        NSDictionary *attribute = [NSDictionary dictionaryWithObjectsAndKeys:textFont,NSFontAttributeName, nil];
        
//        cSize = [textString boundingRectWithSize:CGSizeMake(labelWidth,2000) options: NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
        
        cSize = [textString boundingRectWithSize:CGSizeMake(labelWidth, 2000) options: NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        
        
        /*
        cSize = [textString sizeWithFont:textFont constrainedToSize:CGSizeMake(labelWidth,2000) lineBreakMode:0];
         */
    }
    return (cSize.height >= 30.0f ? cSize.height : 30.0f);
    
}