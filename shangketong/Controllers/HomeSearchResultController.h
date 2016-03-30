//
//  HomeSearchResultController.h
//  
//   首页搜索
//  Created by sungoin-zjp on 15/12/25.
//
//

#import <UIKit/UIKit.h>

@interface HomeSearchResultController : UIViewController

@property (nonatomic, strong) NSString *searchText; //接受传过来的文本，拼接，用来搜索
@property (nonatomic, assign) NSInteger flagFromWhere; // 0首页搜索  1知识库搜索

@end


/*
 通用设置
 url	universalarchCrmData.do
 是否需要登录	是
 
 传入参数
 name	搜索的关键字
 
 返回参数
 {
     status: 0,
     desc: null,
     contacts: [
         {
             id: 278,
             name: "The text I just want to ",
             companyName: "I'm not sure ",
             job: null,
             phone: "010-10000",
             mobile: null,
             position: null,
             email: null
         },
         {
             id: 277,
             name: "fjjcjc",
             companyName: "I'm not sure ",
             job: null,
             phone: "010-2435689",
             mobile: "15242311340",
             position: null,
             email: null
         }
     ],
     contactCount: 10,
     customers: [
         {
             id: 285,
             name: "依旧",
             createTime: 1450935832204,
             expireDate: 1451404799238,
             focus: 0,
             position: "辣木籽",
             phone: "56545558",
             level: null,
             ownerName: "夜月"
         }
     ],
     customerCount: 1,
     opportunitys: [
         {
             id: 229,
             name: "ijjjjc",
             customerName: "凌霄",
             money: 6777,
             focus: 0,
             ownerName: "夜月"
         },
         {
             id: 228,
             name: "ijjdhjndnnf",
             customerName: "一曲凌霄不知数",
             money: 7756,
             focus: 0,
             ownerName: "夜月"
         }
     ],
     opportunityCount: 8,
     clues: [
         {
             id: 265,
             name: "njfjjfjj",
             companyName: "hydyd",
             position: null,
             phone: null,
             mobile: null,
             email: null,
             duty: null,
             ownerName: "夜月",
             createTime: null,
             expireDate: null
         },
         {
             id: 253,
             name: "cjl",
             companyName: "陈磊",
             position: null,
             phone: null,
             mobile: null,
             email: null,
             duty: null,
             ownerName: "夜月",
             createTime: null,
             expireDate: null
         }
     ],
     clueCount: 2
 }
 参数解释
 status	返回状态标记：0成功，1失败
 desc	返回描述
 contacts	搜索到的联系人数据集合
 contactCount	搜索到的联系人总数量
 customers	搜索到的客户数据集合
 customerCount	搜索到的客户的总数量
 opportunitys	搜索到的销售机会数据集合
 opportunityCount	搜索到的销售机会总数量
 clues	搜索到的销售线索数据集合
 clueCount	搜索到的销售线索总数居
 
 contacts
 id	联系人id
 name	联系人名字
 companyName	联系人所属客户名字
 job	联系人职务
 phone	联系人电话
 mobile	联系人手机
 position	联系人地址
 email	联系人邮箱地址
 
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
 
 
 opportunitys
 id	销售机会id
 name	销售机会名字
 customerName	销售机会所属客户名字
 money	销售机会金额
 focus	是否已关注当前销售机会
 ownerName	销售机会所有人名字
 
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