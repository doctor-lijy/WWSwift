//
//  DomainManager.h
//  PHNet
//
//  Created by christ on 2023/10/2.
//

#import <Foundation/Foundation.h>
#import "NetUrlBean.h"
NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    AppENV_TEST,
    AppENV_STG,
    AppENV_PROD,
    AppENV_GRAY,
    AppENV_IP
} AppENV;

@interface DomainManager : NSObject
+ (instancetype)getInstance;
 
-(void)switchENV:(AppENV)env;
-(void)pullNetConfigFile;
-(AppENV)getCurrentEnV;
-(NSString*) getShenCeURL;
-(NSString*) getSpotWSURL;
-(NSString*) getEventNotifyWSURL;
-(NSString*) getContractWSURL;
-(NSString*) getContractWSURL_Private;
+(NSString*) getRealUrlOfWidget:(NSString *)path; // 小组件域名
+(NSString*) getRealUrl:(NSString*) path;//老合约域名
+(NSString*) getRealUrl_New:(NSString*) path;//新合约域名
+(NSString*) getRealUrl_Spot:(NSString*) path;//新现货域名
-(NSArray<NSString*>*) getWebStationDomain;
-(NSArray<NSString*>*) getWebStationDomain_OverSea;
-(NSArray<NetUrlBean*>*)getMainLineConfig;
-(NetUrlBean*)getCurrentMainLine;
-(void) testDomainSpeed:(void (^)(NSDictionary<NSString*,NetUrlBean*> * data))callBack;
-(void)changeNetLine:(NSString*)subDomian;
-(Boolean)isAutoMode;
-(void)setAutoLine;
-(Boolean)isInChina;
-(void)startDetectDomainofPrd;
@end

NS_ASSUME_NONNULL_END
