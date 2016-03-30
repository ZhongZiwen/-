//
//  HomeSearchOtherResultController.h
//  
//   查看更多结果
//  Created by sungoin-zjp on 15/12/25.
//
//

#import <UIKit/UIKit.h>

@interface HomeSearchOtherResultController : UIViewController

@property (nonatomic, strong) NSString *searchText; //接受传过来的文本，拼接，用来搜索
@property (nonatomic, strong) NSString *searchType; //搜索类型  客户、联系人、销售机会、销售线索
@property (nonatomic, strong) NSString *searchCount; //总个数
@end
