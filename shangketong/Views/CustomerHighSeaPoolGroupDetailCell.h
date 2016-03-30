//
//  CustomerHighSeaPoolGroupDetailCell.h
//  shangketong
//  客户公海池
//  Created by sungoin-zjp on 15-6-4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomerHighSeaPoolGroupDetailDelegate;

@interface CustomerHighSeaPoolGroupDetailCell : UITableViewCell

@property (assign, nonatomic) id <CustomerHighSeaPoolGroupDetailDelegate>delegate;

@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelInfo;
@property (strong, nonatomic) IBOutlet UIButton *btnGet;


-(void)setCellFrame;
-(void)setCellContentDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath;
@end



@protocol CustomerHighSeaPoolGroupDetailDelegate<NSObject>
@required

///点击领取事件
- (void)clickGetEvent:(NSInteger)index;

@end
