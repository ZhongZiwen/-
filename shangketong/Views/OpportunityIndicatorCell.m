//
//  OpportunityIndicatorCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "OpportunityIndicatorCell.h"
#import "WRWorkResultHUD.h"
#import "IndexCondition.h"

@interface OpportunityIndicatorCell ()

@property (strong, nonatomic) WRWorkResultHUD *progressHud;
@end

@implementation OpportunityIndicatorCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = kView_BG_Color;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.progressHud];
    }
    return self;
}

- (void)beginLoadingWithNavIndex:(IndexCondition *)index stageId:(NSNumber *)stageId {
    [_progressHud startAnimationWith:@"加载中"];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
        [params setObject:index.id forKey:@"retrievalId"];   // 索引
        [params setObject:stageId forKey:@"stageId"];
//        sleep(5);
        [[Net_APIManager sharedManager] request_SaleChance_List_WithParams:params andBlock:^(id data, NSError *error) {
            @strongify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (data) {
                    self.valueBlock(data, nil);
                    [_progressHud stopAnimationWith:@"加载成功"];
                }else {
                    self.valueBlock(nil, error);
                    [_progressHud stopAnimationWith:@"加载失败"];
                }
            });
        }];
    });
}

+ (CGFloat)cellHeight {
    return 64.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (WRWorkResultHUD*)progressHud {
    if (!_progressHud) {
        _progressHud = [[WRWorkResultHUD alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, [OpportunityIndicatorCell cellHeight])];
        
    }
    return _progressHud;
}
@end
