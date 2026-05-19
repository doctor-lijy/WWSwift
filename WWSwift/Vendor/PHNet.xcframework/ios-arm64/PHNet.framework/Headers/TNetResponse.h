//
//  TNetResponse.h
//  基本的数据解析，初步解析网络返回的数据
//  Created  on 2021/10/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//网络错误编码
static const int ERRCode_OK=0;
static const int ERRCode_FAIL=-1;
static const int ERRCode_NETERR=-2;
static const int ERRCode_WAF_405=405;
static const int ERRCode_WAF_521=521;
static const int ERRCode_WAF_522=522;
static const int ERRCode_WAF_523=523;
static const int ERRCode_WAF_530=530;
static const int ERRCode_WAF_580=580;
static const int ERRCode_AUTH_FAIL= 401;//登录已过期，请重新登录
static const int ERRCode_TOKEN_EXPIRED= 4;//登录已过期，请重新登录
static const int ERRCode_ILLEGALITY_ACCESS = 83;//token失效，请重新登录
static const int ERRCode_TOKEN_FAILED = 20906;//Token已经过期请重新登录
static const int ERRCode_LOGIN_TIMEOUT = 20205;//登录超时，请重新登录
static const int ERRCode_SECURITY_LOGIN = 600;//请重新登录

@interface TNetResponse : NSObject

//最外层的code
@property(nonatomic,assign)long code;
//最外层的错误信息
@property(nonatomic,retain)NSString *msg;
//业务数据，需要业务自己解析
@property(nonatomic,retain)NSString *data;

@end

//网络回调block
typedef void (^ResponseCallback)(TNetResponse *resp);
typedef void (^PlainResponseCallback)(bool isSuccess,NSObject *resp);
NS_ASSUME_NONNULL_END
