//
//  SearchResultCell.m
//  SearchItem
//
//  Created by 蒋 on 15/7/9.
//  Copyright (c) 2015年 蒋. All rights reserved.
//

#import "SearchResultCell.h"
#import "CommonFuntion.h"
@implementation SearchResultCell

- (void)awakeFromNib {
    // Initialization code
    self.labelTitle.frame = CGRectMake(20, 10, kScreen_Width-40, 20);
    self.labelRowValue1.frame = CGRectMake(165, 40, kScreen_Width-160, 20);
    self.labelRowValue2.frame = CGRectMake(165, 65, kScreen_Width-160, 20);
    self.labelRowValue3.frame = CGRectMake(165, 90, kScreen_Width-160, 20);
    self.viewContentBg.frame = CGRectMake(10, 5, kScreen_Width-20, 110);
    self.viewContentBg.image = [CommonFuntion createImageWithColor:[UIColor colorWithRed:245.0f/255 green:245.0f/255 blue:247.0f/255 alpha:1.0f]];
    self.viewContentBg.layer.borderColor = [UIColor colorWithRed:220.0f/255 green:220.0f/255 blue:220.0f/255 alpha:1.0f].CGColor;
    self.viewContentBg.layer.borderWidth = 0.5;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}



-(void)setCellDetails:(NSDictionary *)item byCellType:(NSString *)cellType{
    
    self.labelTitle.text = [item safeObjectForKey:@"name"];
    
    ///联系人
    if ([cellType isEqualToString:@"contacts"]) {
        /*
         contacts
         id	联系人id
         name	联系人名字
         companyName	联系人所属客户名字
         job	联系人职务
         phone	联系人电话
         mobile	联系人手机
         position	联系人地址
         email	联系人邮箱地址
         */
        
        
        self.labelRowTitle1.text = @"公司名称";
        self.labelRowTitle2.text = @"职务";
        self.labelRowTitle3.text = @"手机";
        
        NSString *companyName = [item safeObjectForKey:@"companyName"];
        if ([companyName isEqualToString:@""]) {
            companyName = @"未填写";
        }
        
        NSString *job = [item safeObjectForKey:@"job"];
        if ([job isEqualToString:@""]) {
            job = @"未填写";
        }
        
        NSString *mobile = [item safeObjectForKey:@"mobile"];
        if ([mobile isEqualToString:@""]) {
            mobile = @"未填写";
        }

        self.labelRowValue1.text = companyName;
        self.labelRowValue2.text = job;
        self.labelRowValue3.text = mobile;
        
    }else if ([cellType isEqualToString:@"customers"]) {
        ///客户
            /*
             customers
             id	客户id
             name	客户名字
             createTime	客户创建时间
             expireDate	客户到期时间
             focus	是否已关注当前客户
             position	客户地址
             phone	客户电话
             level	客户级别
             ownerName	客户所有人名字
             */
            
        self.labelRowTitle1.text = @"客户级别";
        self.labelRowTitle2.text = @"客户所有人";
        self.labelRowTitle3.text = @"创建日期";
        
        NSString *level = [item safeObjectForKey:@"level"];
        if ([level isEqualToString:@""]) {
            level = @"未填写";
        }
        
        NSString *ownerName = [item safeObjectForKey:@"ownerName"];
        if ([ownerName isEqualToString:@""]) {
            ownerName = @"未填写";
        }
        
        NSString *expireDate = @"";
        if (![[item safeObjectForKey:@"expireDate"] isEqualToString:@""]) {
            expireDate = [CommonFuntion transDateWithTimeInterval:[[item safeObjectForKey:@"expireDate"] longLongValue] withFormat:@"yyyy-MM-dd HH:mm"];
        }
       
        
        self.labelRowValue1.text = level;
        self.labelRowValue2.text = ownerName;
        self.labelRowValue3.text = expireDate;
    }else if ([cellType isEqualToString:@"opportunitys"]) {
        /*
         opportunitys
         id	销售机会id
         name	销售机会名字
         customerName	销售机会所属客户名字
         money	销售机会金额
         focus	是否已关注当前销售机会
         ownerName	销售机会所有人名字
         */
        
        self.labelRowTitle1.text = @"客户名称";
        self.labelRowTitle2.text = @"销售金额";
        self.labelRowTitle3.text = @"销售机会所有人";
        
        
        NSString *customerName = [item safeObjectForKey:@"customerName"];
        if ([customerName isEqualToString:@""]) {
            customerName = @"未填写";
        }
        
        NSString *money = [item safeObjectForKey:@"money"];
        if (![money isEqualToString:@""]) {
            money = [NSString stringWithFormat:@"%@元",money];
        }
        
        NSString *ownerName = [item safeObjectForKey:@"ownerName"];
        if ([ownerName isEqualToString:@""]) {
            ownerName = @"未填写";
        }
        
        
        self.labelRowValue1.text = customerName;
        self.labelRowValue2.text = money;
        self.labelRowValue3.text = ownerName;
    }else if ([cellType isEqualToString:@"clues"]) {
        /*
         clues
         id	销售线索id
         name	销售线索名字
         companyName	销售线索所属公司名称
         position	销售线索地址
         phone	销售线索电话
         mobile	销售线索手机
         email	销售线索邮箱地址
         duty	销售线索职务
         ownerName	销售线索所有人名字
         createTime	销售线索创建时间
         expireDate	销售线索回收时间
         */
        self.labelRowTitle1.text = @"公司名称";
        self.labelRowTitle2.text = @"职务";
        self.labelRowTitle3.text = @"销售线索所有人";
        
        
        NSString *companyName = [item safeObjectForKey:@"companyName"];
        if ([companyName isEqualToString:@""]) {
            companyName = @"未填写";
        }
        
        NSString *duty = [item safeObjectForKey:@"duty"];
        if ([duty isEqualToString:@""]) {
            duty = @"未填写";
        }
        
        NSString *ownerName = [item safeObjectForKey:@"ownerName"];
        if ([ownerName isEqualToString:@""]) {
            ownerName = @"未填写";
        }
        
        self.labelRowValue1.text = companyName;
        self.labelRowValue2.text = duty;
        self.labelRowValue3.text = ownerName;
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
