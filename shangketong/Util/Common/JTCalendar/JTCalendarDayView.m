//
//  JTCalendarDayView.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarDayView.h"

#import "JTCircleView.h"
#import "CommonFuntion.h"
@interface JTCalendarDayView (){
    UIView *backgroundView;
    JTCircleView *circleView;
    UILabel *textLabel;
    UIImageView *imgBottom;
    JTCircleView *dotView;
    UIImageView *imgView;
    
    BOOL isSelected;
    
    int cacheIsToday;
    NSString *cacheCurrentDateText;
}
@end

static NSString *const kJTCalendarDaySelected = @"kJTCalendarDaySelected";

@implementation JTCalendarDayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
}

- (void)commonInit
{
    isSelected = NO;
    self.isOtherMonth = NO;

    {
        backgroundView = [UIView new];
        [self addSubview:backgroundView];
    }
    
    {
        circleView = [JTCircleView new];
        [self addSubview:circleView];
        circleView.hidden = YES;
    }
    {
        textLabel = [UILabel new];
        [self addSubview:textLabel];
        imgView = [UIImageView new];
        imgView.hidden = YES;
        [self addSubview:imgView];
    }
    
    {
        imgBottom = [UIImageView new];
        [self addSubview:imgBottom];
        imgBottom.hidden = YES;
    }
    
    {
        dotView = [JTCircleView new];
        [self addSubview:dotView];
        dotView.hidden = YES;
    }
    
    {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouch)];

        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:gesture];
    }
    
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDaySelected:) name:kJTCalendarDaySelected object:nil];
    }
}

- (void)layoutSubviews
{
    [self configureConstraintsForSubviews];
    
    // No need to call [super layoutSubviews]
}

// Avoid to calcul constraints (very expensive)
- (void)configureConstraintsForSubviews
{
    textLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    backgroundView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    CGFloat sizeCircle = MIN(self.frame.size.width, self.frame.size.height);
    CGFloat sizeDot = sizeCircle;
    
    sizeCircle = sizeCircle * self.calendarManager.calendarAppearance.dayCircleRatio;
    sizeDot = sizeDot * self.calendarManager.calendarAppearance.dayDotRatio;
    
    sizeCircle = roundf(sizeCircle);
    sizeDot = roundf(sizeDot);
    
    circleView.frame = CGRectMake(0, 0, sizeCircle, sizeCircle);
    circleView.center = CGPointMake(self.frame.size.width / 2., self.frame.size.height / 2.);
    circleView.layer.cornerRadius = sizeCircle / 2.;
    
    dotView.frame = CGRectMake(0, 0, sizeDot, sizeDot);
    dotView.center = CGPointMake(self.frame.size.width / 2., (self.frame.size.height / 2.) +sizeDot * 2.5);
    dotView.layer.cornerRadius = sizeDot / 2.;
    
    imgBottom.frame = CGRectMake((self.frame.size.width-sizeCircle)/2, textLabel.frame.size.height-5, sizeCircle, 2);
    imgView.frame = CGRectMake((self.frame.size.width - 2) / 2, textLabel.frame.size.height-5, 2, 2);
    imgView.layer.masksToBounds = YES;
    imgView.layer.cornerRadius = 1;
    imgView.backgroundColor = LIGHT_BLUE_COLOR;
}


- (void)setDate:(NSDate *)date
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.timeZone = self.calendarManager.calendarAppearance.calendar.timeZone;
        [dateFormatter setDateFormat:self.calendarManager.calendarAppearance.dayFormat];
    }
    
    
//    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init] ;
//    [outputFormatter setLocale:[NSLocale currentLocale]];
//    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSString *strD = [outputFormatter stringFromDate:date];
    
    self->_date = date;
    
//    NSLog(@"textLabel.text:%@",[dateFormatter stringFromDate:date]);
     NSString *dateStr = @"";
    textLabel.text = [dateFormatter stringFromDate:date];
    dateStr = [[CommonFuntion dateToString:self.date] substringToIndex:10];
//    NSLog(@"匹配日期------%@", dateStr);
    if ([appDelegateAccessor.moudle.arrayScheduleAndTask containsObject:dateStr]) {
//        NSLog(@"显示添加圆点");
        imgView.hidden = NO;
    } else {
        imgView.hidden = YES;
    }
    cacheIsToday = -1;
    cacheCurrentDateText = nil;
}

- (void)didTouch
{
//    NSLog(@"didTouch self.date:%@",self.date);
    if([self.calendarManager.dataSource respondsToSelector:@selector(calendar:canSelectDate:)]){
        if(![self.calendarManager.dataSource calendar:self.calendarManager canSelectDate:self.date]){
            return;
        }
    }
    
    [self setSelected:YES animated:YES];
    [self.calendarManager setCurrentDateSelected:self.date];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kJTCalendarDaySelected object:self.date];
    
    [self.calendarManager.dataSource calendarDidDateSelected:self.calendarManager date:self.date];
    
    if(!self.isOtherMonth || !self.calendarManager.calendarAppearance.autoChangeMonth){
        return;
    }
    
    NSInteger currentMonthIndex = [self monthIndexForDate:self.date];
    NSInteger calendarMonthIndex = [self monthIndexForDate:self.calendarManager.currentDate];
        
    currentMonthIndex = currentMonthIndex % 12;
    
    if(currentMonthIndex == (calendarMonthIndex + 1) % 12){
        [self.calendarManager loadNextPage];
    }
    else if(currentMonthIndex == (calendarMonthIndex + 12 - 1) % 12){
        [self.calendarManager loadPreviousPage];
    }
}

- (void)didDaySelected:(NSNotification *)notification
{
    NSDate *dateSelected = [notification object];
    
    [self.calendarManager setCurrentDateSelected:dateSelected];
    
    if([self isSameDate:dateSelected]){
        if(!isSelected){
            [self setSelected:YES animated:YES];
        }
    }
    else if(isSelected){
        [self setSelected:NO animated:YES];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    
    if(isSelected == selected){
        animated = NO;
    }
    
    isSelected = selected;
    
    imgBottom.transform = CGAffineTransformIdentity;
    circleView.transform = CGAffineTransformIdentity;
    CGAffineTransform tr = CGAffineTransformIdentity;
    CGFloat opacity = 1.;
    
    
    imgBottom.hidden = YES;
//    imgView.hidden = YES;
    if(selected){
        imgBottom.hidden = NO;
//        imgView.hidden = YES;
        if(!self.isOtherMonth){
            
//             NSLog(@"在当前月-----:%@",self.date);
            circleView.color = [self.calendarManager.calendarAppearance dayCircleColorSelected];
            textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorSelected];
            dotView.color = [self.calendarManager.calendarAppearance dayDotColorSelected];
            
            textLabel.textColor = [UIColor blackColor];
            imgBottom.backgroundColor = LIGHT_BLUE_COLOR;
        }
        else{
//            NSLog(@"不在当前月-----:%@",self.date);
            circleView.color = [self.calendarManager.calendarAppearance dayCircleColorSelectedOtherMonth];
            textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorSelectedOtherMonth];
            dotView.color = [self.calendarManager.calendarAppearance dayDotColorSelectedOtherMonth];
            textLabel.textColor = [UIColor grayColor];
            imgBottom.backgroundColor = LIGHT_BLUE_COLOR;
        }
        
        if([self isToday]){
            
            textLabel.textColor = LIGHT_BLUE_COLOR;
            
//            if(!self.isOtherMonth){
//                textLabel.textColor = LIGHT_BLUE_COLOR;
//            }
//            else{
//                textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorTodayOtherMonth];
//            }
        }
        imgBottom.transform = CGAffineTransformIdentity;
        circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
        tr = CGAffineTransformIdentity;
    }
    else if([self isToday]){
        imgBottom.hidden = YES;
        if(!self.isOtherMonth){
            circleView.color = [self.calendarManager.calendarAppearance dayCircleColorToday];
//            textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorToday];
            textLabel.textColor = LIGHT_BLUE_COLOR;
            dotView.color = [self.calendarManager.calendarAppearance dayDotColorToday];
            imgBottom.backgroundColor = LIGHT_BLUE_COLOR;
        }
        else{
            circleView.color = [self.calendarManager.calendarAppearance dayCircleColorTodayOtherMonth];
            textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorTodayOtherMonth];
            dotView.color = [self.calendarManager.calendarAppearance dayTextColorOtherMonth];
            textLabel.textColor = LIGHT_BLUE_COLOR;
            imgBottom.backgroundColor = LIGHT_BLUE_COLOR;
        }
        
        imgBottom.transform = CGAffineTransformIdentity;
        circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
        tr = CGAffineTransformIdentity;
    }else if([self isContainDay:self->_date]){
        ///用本地数据匹配默认选中的情况
        imgBottom.hidden = YES;
//        imgView.hidden = YES;
        if(!self.isOtherMonth){
            circleView.color = [self.calendarManager.calendarAppearance dayCircleColorSelected];
            textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorSelected];
            dotView.color = [self.calendarManager.calendarAppearance dayDotColorSelected];
            textLabel.textColor = [UIColor blackColor];
        }else{
            circleView.color = [self.calendarManager.calendarAppearance dayCircleColorSelectedOtherMonth];
            textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorSelectedOtherMonth];
            dotView.color = [self.calendarManager.calendarAppearance dayDotColorSelectedOtherMonth];
            
        }
        
        imgBottom.backgroundColor = [UIColor yellowColor];
    }
    else{
        if(!self.isOtherMonth){
            textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColor];
            dotView.color = [self.calendarManager.calendarAppearance dayDotColor];
            textLabel.textColor = [UIColor blackColor];
        }
        else{
            textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorOtherMonth];
            dotView.color = [self.calendarManager.calendarAppearance dayDotColorOtherMonth];
        }
        
        opacity = 0.;
    }
    
    if(animated){
        [UIView animateWithDuration:.3 animations:^{
            imgBottom.layer.opacity = opacity;
            imgBottom.transform = tr;
            circleView.layer.opacity = opacity;
            circleView.transform = tr;
        }];
    }
    else{
        circleView.layer.opacity = opacity;
        circleView.transform = tr;
        
        imgBottom.layer.opacity = opacity;
        imgBottom.transform = tr;
    }
}

- (void)setIsOtherMonth:(BOOL)isOtherMonth
{
    self->_isOtherMonth = isOtherMonth;
    [self setSelected:isSelected animated:NO];
}

-(BOOL)isContainDay:(NSDate *)date{
    return NO;
}
/*
 
-(BOOL)isContainDay:(NSDate *)date{
    BOOL isContain = NO;
    NSArray *arrayDate = [[NSArray alloc] initWithObjects:@"2015-05-13",@"2015-05-19",@"2015-05-23",@"2015-05-24",@"2015-05-25",@"2015-06-13",@"2015-06-14",@"2015-06-17",@"2015-06-19", nil];
    
    NSDateFormatter *formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
    [formatter setTimeZone:timeZone];
    NSString *dateFromData = [formatter stringFromDate:date];
    
    for (int i=0; !isContain && i<[arrayDate count]; i++) {
        if ([dateFromData isEqualToString:[arrayDate objectAtIndex:i]]) {
//            NSLog(@"dateFromData;%@",dateFromData);
            isContain = YES;
        }
    }
    return isContain;
}
*/

- (void)reloadData
{
    dotView.hidden = ![self.calendarManager.dataCache haveEvent:self.date];
    
    BOOL selected = [self isSameDate:[self.calendarManager currentDateSelected]];
    [self setSelected:selected animated:NO];
}

- (BOOL)isToday
{
    if(cacheIsToday == 0){
        return NO;
    }
    else if(cacheIsToday == 1){
        return YES;
    }
    else{
        if([self isSameDate:[NSDate date]]){
            cacheIsToday = 1;
            return YES;
        }
        else{
            cacheIsToday = 0;
            return NO;
        }
    }
}

- (BOOL)isSameDate:(NSDate *)date
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.timeZone = self.calendarManager.calendarAppearance.calendar.timeZone;
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    }
    
    if(!cacheCurrentDateText){
        cacheCurrentDateText = [dateFormatter stringFromDate:self.date];
    }
    
    NSString *dateText2 = [dateFormatter stringFromDate:date];
    
    if ([cacheCurrentDateText isEqualToString:dateText2]) {
        return YES;
    }
    
    return NO;
}

- (NSInteger)monthIndexForDate:(NSDate *)date
{
    NSCalendar *calendar = self.calendarManager.calendarAppearance.calendar;
    NSDateComponents *comps = [calendar components:NSCalendarUnitMonth fromDate:date];
    return comps.month;
}

- (void)reloadAppearance
{
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.font = self.calendarManager.calendarAppearance.dayTextFont;
    backgroundView.backgroundColor = self.calendarManager.calendarAppearance.dayBackgroundColor;
    backgroundView.layer.borderWidth = self.calendarManager.calendarAppearance.dayBorderWidth;
    backgroundView.layer.borderColor = self.calendarManager.calendarAppearance.dayBorderColor.CGColor;
    
    [self configureConstraintsForSubviews];
    [self setSelected:isSelected animated:NO];
}

@end
