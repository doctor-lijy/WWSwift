//
//  RuntimeAPPEnv.h
//  PHNet
//
//  Created by christ on 2023/11/28.
//

#import <Foundation/Foundation.h>
#import "NetUrlBean.h"
NS_ASSUME_NONNULL_BEGIN
typedef NSArray* _Nonnull (^defaultArrayCallback)(void);
typedef NSDictionary* _Nonnull (^socketHeaderCallback)(void);
typedef Boolean (^loginCheckBlock)(void);
typedef void(^sensorEventReport)( NSString * _Nonnull event, NSDictionary * _Nullable values);
typedef SubDomainBean* _Nonnull (^defaultNetLineCallback)(Boolean);
@interface RuntimeAPPEnv : NSObject
+ (instancetype)getInstance;
@property(nonatomic,strong) sensorEventReport mSensorEventReport;
-(void)setUserLoginCheck:(loginCheckBlock)block;
-(void)setSocketHeader:(socketHeaderCallback)headerblock;
-(void)setDefaultCDNDomain:(defaultArrayCallback)CDNBlock;
-(void)setDefaultDomainList:(defaultArrayCallback)block;
-(void)setDefaultNetLineBlock:(defaultNetLineCallback)block;
-(SubDomainBean*)getDefalutNetLine:(Boolean )inCountry;
-(NSDictionary *)getSocketHeaders;
-(NSArray *)getDefaultCDNDomain;
-(NSArray *)getDefaultDomainList;
-(Boolean)isUserLogin;
-(void)onEvent:(NSString*)event value:(NSDictionary*)value;
@end

NS_ASSUME_NONNULL_END
