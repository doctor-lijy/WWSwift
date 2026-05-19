# #import <PHNet/PHNet.h>

一、外部操作一律引用 #import <PHNet/PHNet.h>

二、PHNet.xcframework为动态库，外部引入，需要设置framework为：Embed & Sign

三、PHNet.xcframework内部依赖了AFNetworking(4.0.1)，请在外部pod引用：'AFNetworking','4.0.1'

四、WeexHttpClient.WeexHttpClient为http接口
1、configHeader：使用前需要从外部通过设置http header参数；
    举例：
    [WeexHttpClient getInstance].configHeader = ^NSDictionary * _Nonnull{
        NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
        [params setValue:value forKey:@"key"];
        return params;
    };
2、updateUsrToken：http请求接口时，需要通知外部更新token；
    举例：
    [WeexHttpClient getInstance].updateUsrToken = ^(NSString * _Nonnull token) {
        [[UserManager getInstance] saveUserToken:token];
    };
3、tickoutCallback：当http回包，当response.statusCode == 401 || res.code == TIP_CLIENT_PWD_CHANGED || res.code == TIP_CLIENT_TOTP_CHANGED || res.code == TIP_SESSION_KICKEDOUT 时，需要通知外部action
    举例：
    [WeexHttpClient getInstance].tickoutCallback = ^(NSInteger statusCode, NSInteger code, NSString * _Nonnull url) {
        [[UserManager getInstance] logout];
        ......
    };

五、SocketManager.h SocketManager为socket接口
1、getUsrToken：使用前,需要从外部通过设置实时获取token的回调；
    举例：
    [SocketManager getInstance].getUsrToken = ^NSString * _Nonnull{
        NSString *token = @"12345";
        return token;
    };
2、getUsrId：http请求接口时，需要从外部通过设置实时获取usrId的回调；
    举例：
    [SocketManager getInstance].getUsrId = ^int{
        TUserInfo *userInfo= 123456;
        return usrId;
    };
3、sensorEventReport：神策日志打印
    举例：
    [SocketManager getInstance].sensorEventReport = ^(NSString * _Nonnull event, NSArray * _Nonnull values) {
        if (IsEmptyStringValue(event) || ![values isKindOfClass:[NSArray class]]) {
            return;
        }
        [[SensorService getInstance] event:event values:values];
    };

六、PrintLog.h 设置sdk的日志打印
    举例：打开日志打印：[PrintLog getInstance].isOpenLog = YES






---create by yanquwu，2022-06-28 
