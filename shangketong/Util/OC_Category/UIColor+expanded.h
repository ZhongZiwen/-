
/****
 VOORBEELDEN
 
 [UIColor colorWithRGBHex:0xff00ff];
 [UIColor colorWithHexString:@"0xff00ff"]
 *******/

#import <UIKit/UIKit.h>

#define SUPPORTS_UNDOCUMENTED_API	0

@interface UIColor (UIColor_Expanded)
@property (nonatomic, readonly) CGColorSpaceModel colorSpaceModel;
@property (nonatomic, readonly) BOOL canProvideRGBComponents;
@property (nonatomic, readonly) CGFloat red; // Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) CGFloat green; // Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) CGFloat blue; // Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) CGFloat white; // Only valid if colorSpaceModel == kCGColorSpaceModelMonochrome
@property (nonatomic, readonly) CGFloat alpha;
@property (nonatomic, readonly) UInt32 rgbHex;

- (NSString*)colorSpaceString;

- (NSArray*)arrayFromRGBAComponents;

- (BOOL)red:(CGFloat*)r green:(CGFloat*)g blue:(CGFloat*)b alpha:(CGFloat*)a;

- (UIColor*)colorByLuminanceMapping;

- (UIColor*)colorByMultiplyingByRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (UIColor*)colorByAddingRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (UIColor*)colorByLighteningToRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (UIColor*)colorByDarkeningToRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

- (UIColor*)colorByMultiplyingBy:(CGFloat)f;
- (UIColor*)colorByAdding:(CGFloat)f;
- (UIColor*)colorByLighteningTo:(CGFloat)f;
- (UIColor*)colorByDarkeningTo:(CGFloat)f;

- (UIColor*)colorByMultiplyingByColor:(UIColor *)color;
- (UIColor*)colorByAddingColor:(UIColor *)color;
- (UIColor*)colorByLighteningToColor:(UIColor *)color;
- (UIColor*)colorByDarkeningToColor:(UIColor *)color;

- (NSString*)stringFromColor;
- (NSString*)hexStringFromColor;

+ (instancetype)randomColor;
+ (instancetype)colorWithString:(NSString *)stringToConvert;
+ (instancetype)colorWithRGBHex:(UInt32)hex;
+ (instancetype)colorWithHexString:(NSString *)stringToConvert;
+ (instancetype)colorWithHexString:(NSString *)stringToConvert andAlpha:(CGFloat)alpha;

+ (UIColor*)colorWithName:(NSString *)cssColorName;

+ (instancetype)colorWithColorType:(NSNumber*)colorType;

// Plain Colors
+ (instancetype)iOS7redColor;
+ (instancetype)iOS7orangeColor;
+ (instancetype)iOS7yellowColor;
+ (instancetype)iOS7greenColor;
+ (instancetype)iOS7lightBlueColor;
+ (instancetype)iOS7darkBlueColor;
+ (instancetype)iOS7purpleColor;
+ (instancetype)iOS7pinkColor;
+ (instancetype)iOS7darkGrayColor;
+ (instancetype)iOS7lightGrayColor;

// Gradient Colors
+ (instancetype)iOS7redGradientStartColor;
+ (instancetype)iOS7redGradientEndColor;

+ (instancetype)iOS7orangeGradientStartColor;
+ (instancetype)iOS7orangeGradientEndColor;

+ (instancetype)iOS7yellowGradientStartColor;
+ (instancetype)iOS7yellowGradientEndColor;

+ (instancetype)iOS7greenGradientStartColor;
+ (instancetype)iOS7greenGradientEndColor;

+ (instancetype)iOS7tealGradientStartColor;
+ (instancetype)iOS7tealGradientEndColor;

+ (instancetype)iOS7blueGradientStartColor;
+ (instancetype)iOS7blueGradientEndColor;

+ (instancetype)iOS7violetGradientStartColor;
+ (instancetype)iOS7violetGradientEndColor;

+ (instancetype)iOS7magentaGradientStartColor;
+ (instancetype)iOS7magentaGradientEndColor;

+ (instancetype)iOS7blackGradientStartColor;
+ (instancetype)iOS7blackGradientEndColor;

+ (instancetype)iOS7silverGradientStartColor;
+ (instancetype)iOS7silverGradientEndColor;

@end

#if SUPPORTS_UNDOCUMENTED_API
// UIColor_Undocumented_Expanded
// Methods which rely on undocumented methods of UIColor
@interface UIColor (UIColor_Undocumented_Expanded)
- (NSString *)fetchStyleString;
- (UIColor *)rgbColor; // Via Poltras
@end
#endif // SUPPORTS_UNDOCUMENTED_API
