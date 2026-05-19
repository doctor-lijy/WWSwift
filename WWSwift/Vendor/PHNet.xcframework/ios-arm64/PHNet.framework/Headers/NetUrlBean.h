//
//  NetUrlBean.h
//  PHNet
//
//  Created by christ on 2023/10/2.
//

#import <Foundation/Foundation.h>
#define MAX_CONN_TIME 1000000

NS_ASSUME_NONNULL_BEGIN
@interface SubDomainBean : NSObject
@property(nonatomic,retain) NSString * domain;//域名
@property(nonatomic,retain) NSString * alias;//供应商
@property(nonatomic,retain) NSString * type;//c 国内， w 国外,sc 神策
@property(nonatomic,retain) NSString * CAPTCHAKey;//waf 人机校验的Key
@property(nonatomic,retain) NSString * initialPort;//如果是IP线路，这个是起始端口
@property(nonatomic,retain) NSString * preOnline;//是否是预热线路，true
@property(nonatomic,assign) int index;//供应商的线路ID
-(instancetype)initWithString:(NSString *)str;
-(NSString*)convertToString;
-(instancetype)initWithData:(SubDomainBean *)oldDomain;
@end

@interface NetUrlBean : SubDomainBean
//新spot公有通道--未登录
@property(nonatomic,retain) NSString * fullUrl_NewSpot;
//新spot公有通道--登录
@property(nonatomic,retain) NSString * fullUrl_NewSpot_Auth; 
//新合约公有通道--未登录
@property(nonatomic,retain) NSString * fullUrl_Contract;
//新合约私有通道--未登录
@property(nonatomic,retain) NSString * fullUrl_Contract_Private;
//新合约公有通道--登录
@property(nonatomic,retain) NSString * fullUrl_Contract_Auth;
//新合约私有通道--登录
@property(nonatomic,retain) NSString * fullUrl_Contract_Auth_Private;
//notify通道--未登录
@property(nonatomic,retain) NSString * fullUrl_Event;
//notify通道--登录
@property(nonatomic,retain) NSString * fullUrl_Event_Auth;

//新合约API通道--未登录
@property(nonatomic,retain) NSString * fullUrl_API;
//新合约API通道--登录
@property(nonatomic,retain) NSString * fullUrl_API_Auth; 
//新合约API通道--未登录
@property(nonatomic,retain) NSString * fullUrl_API_Old;
//新合约API通道--登录
@property(nonatomic,retain) NSString * fullUrl_API_Old_Auth;
//新现货API通道--未登录
@property(nonatomic,retain) NSString * fullUrl_API_NewSpot;
//新现货API通道--登录
@property(nonatomic,retain) NSString * fullUrl_API_NewSpot_Auth;
@property(nonatomic,assign) Boolean isPrdEnv;

-(instancetype)initWithData:(SubDomainBean *)oldDomain; 

-(long)getApiAvgSpeed;
-(long)getSocketAvgSpeed;
//测试socket速度
-(void)doSocketSpeedTest:(void (^)(bool))callBack;
//测试http速度
-(void)doApiSpeedTest:(void (^)(bool))callBack;
@end



NS_ASSUME_NONNULL_END
