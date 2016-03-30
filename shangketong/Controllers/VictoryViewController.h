//
//  VictoryViewController.h
//  喜报
//
//  Created by sungoin-zjp on 15/12/25.
//
//

#import <UIKit/UIKit.h>

@interface VictoryViewController : UIViewController

///XXXX-XX-XX
@property(strong,nonatomic) NSString *strStartDate;
@property(strong,nonatomic) NSString *strEndDate;

@end


/*
 saleChance/getVictoryOpportunitys.do 获取喜报列表接口
 参数：startDate开始时间
 endDate结束时间
 都传空表示查看当天喜报。传时间即指定时间喜报：XXXX-XX-XX
*/