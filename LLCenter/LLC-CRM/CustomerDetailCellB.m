//
//  CustomerDetailCellB.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-7-4.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "CustomerDetailCellB.h"
#import "CommonFunc.h"
#import "LLCenterUtility.h"

@implementation CustomerDetailCellB

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

///填充cell详情
-(void)setCellDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath{
    
    NSInteger vX = DEVICE_BOUNDS_WIDTH-320;
    
    ///业务信息
    //    labelType
    //    labelTypeName
    //    labelDate
    //    labelTagKeyWords
    //    labelKeyWords
    
    self.viewBusinessInfo.backgroundColor =  [UIColor colorWithRed:230.0f/255 green:230.0f/255 blue:230.0f/255 alpha:1.0f];
    self.viewBusinessInfo.layer.cornerRadius = 8;
    ///新增销售类型
    NSString *type = [self getTitleName:item];
    
    self.labelType.text = type;
    self.labelType.frame = CGRectMake(10, 10, 90, 20);
    
    ///Test
    NSString *typeName = @"";
    if ([item objectForKey:@"OPERATORNAME"]) {
        typeName = [item safeObjectForKey:@"OPERATORNAME"];
    }
    self.labelTypeName.text = typeName;
    self.labelTypeName.frame = CGRectMake(100, 10, 90+vX, 20);
    
    ///date
    NSString *date = @"";
    if ([item objectForKey:@"CREATETIME"]) {
        date = [item safeObjectForKey:@"CREATETIME"];
    }
    NSLog(@"date1:%@",date);
    
    if (date.length > 10) {
        date = [date substringToIndex:10];
    }
    /*
     if (![date isEqualToString:@""]) {
         NSDate *d = getDateFromString(@"yyyy-MM-dd HH:mm", date);
         NSLog(@"date2:%@",d);
         date = getStringFromDate(@"yyyy-MM-dd", d);
         NSLog(@"date3:%@",date);
     }
     */
    
    self.labelDate.text = date;
    self.labelDate.frame = CGRectMake(200+vX, 10, 80, 20);
    
    ///详情
    self.labelTagKeyWords.frame = CGRectMake(10, 40, 40, 20);
    
    NSString *keyWords = @"";
    if ([item objectForKey:@"DETAIL"]) {
        keyWords = [item safeObjectForKey:@"DETAIL"];
    }

    CGSize sizeKeyWords = [CommonFunc getSizeOfContents:keyWords Font:[UIFont systemFontOfSize:14.0] withWidth:225+vX withHeight:MAX_WIDTH_OR_HEIGHT];
    self.labelKeyWords.text = keyWords;
    self.labelKeyWords.frame = CGRectMake(50, 42, 225+vX, sizeKeyWords.height);
    
    
    self.viewBusinessInfo.frame = CGRectMake(15, 0, DEVICE_BOUNDS_WIDTH-30, 40+sizeKeyWords.height+15);
    
}

///获取日志title
-(NSString *)getTitleName:(NSDictionary *)item{
    NSString *operationType = @"";
    NSString *logType = @"";
    NSString *title = @"";
    
    if ([item objectForKey:@"OPERATIONTYPE"]) {
        operationType = [item safeObjectForKey:@"OPERATIONTYPE"];
    }
    
    if ([item objectForKey:@"LOGTYPE"]) {
        logType = [item safeObjectForKey:@"LOGTYPE"];
    }
    
    if ([operationType isEqualToString:@"fax"]) {
        title = @"传真";
    }else if ([operationType isEqualToString:@"mail"]) {
        title = @"邮件";
    }else if ([operationType isEqualToString:@"1"]) {
        
        title = [NSString stringWithFormat:@"新增%@",[self getLogTypeName:[logType integerValue]]];
        
    }else if ([operationType isEqualToString:@"2"]) {
        title = [NSString stringWithFormat:@"修改%@",[self getLogTypeName:[logType integerValue]]];
    }else if ([operationType isEqualToString:@"3"]) {
        title = [NSString stringWithFormat:@"删除%@",[self getLogTypeName:[logType integerValue]]];
    }
    return title;
}


///获取日志类型对应的name
-(NSString *)getLogTypeName:(NSInteger)logtype{
    NSString *typeName = @"";
    
    switch (logtype) {
        case 1:
            typeName = @"销售";
            break;
        case 2:
            typeName = @"售后";
            break;
        case 3:
            typeName = @"合同";
            break;
        case 4:
            typeName = @"订单";
            break;
            
        default:
            typeName = @"";
            break;
    }
    return typeName;
}


#pragma mark - 获取cell height
+(CGFloat)getCellContentHeight:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    
    ///显示业务信息部分
    NSString *keyWords = @"";
    if ([item objectForKey:@"DETAIL"]) {
        keyWords = [item safeObjectForKey:@"DETAIL"];
    }
    CGSize sizeKeyWords = [CommonFunc getSizeOfContents:keyWords Font:[UIFont systemFontOfSize:14.0] withWidth:(225+DEVICE_BOUNDS_WIDTH-320) withHeight:MAX_WIDTH_OR_HEIGHT];
    
    height = (sizeKeyWords.height+40+20);
    return height;
}

@end
