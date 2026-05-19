//
//  WeexHttpClient.h
//  http网络接口
//  Created  on 2021/10/8.
//

#import <Foundation/Foundation.h>
#import "TNetResponse.h"




NS_ASSUME_NONNULL_BEGIN

@interface WeexHttpClient : NSObject
@property(nonatomic, strong) NSDictionary *(^configHeader)(void); 
@property(nonatomic, strong) void(^errorCallback)(NSInteger statusCode, NSInteger code,NSString *msg, NSString *url); 

+ (instancetype)getInstance ;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
//下载文件
- (void)downLoadFileWithUrl:(NSString *)url
          progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
        destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                   callBack:(ResponseCallback)callBack;
//get请求，无get参数
- (void)get:(NSString *)url callBack:(ResponseCallback)callback;

- (void)getPlain:(NSString *)url callBack:(PlainResponseCallback)callback;
- (void)getCommonPlain:(NSString *)url callBack:(PlainResponseCallback)callback;
//带参数的get请求
- (void)get:(NSString *) url  params:(nullable NSDictionary<NSString*,NSObject *> *) params callBack:(ResponseCallback)callback;

//带参数的post请求
- (void)postJson:(NSString*) url params:(NSDictionary<NSString*,NSObject *> *) params callBack:(ResponseCallback)callback;
//带Form参数的post请求
- (void)postForm:(NSString*) url params:(NSDictionary<NSString*,NSObject *> *) params callBack:(ResponseCallback)callback;

//带get参数的post请求
- (void)postJsonWithQuery:(NSString*) url postParams:(NSDictionary<NSString*,NSObject *> *) postparams getParams:(NSDictionary<NSString*,NSString *> *)getParams callBack:(ResponseCallback)callback;

//put请求
-(void) put:(NSString*) url params:(NSDictionary<NSString*,NSObject *> *) params callBack:(ResponseCallback)callback;

//带get参数的put请求
- (void)put:(NSString*) url queryParams:(NSDictionary<NSString*,NSString *> *)queryParams params:(NSDictionary<NSString*,NSObject *> *) params callBack:(ResponseCallback)callback;

//文件上传
- (void)postMultiPart:(NSString*) url name:(NSString*) fileName data:(NSData*) data callBack:(ResponseCallback)callback;

// 文件上传 参数为 fileUrl, mimeType
- (void)postMultiPart:(NSString *)url fileUrl:(NSURL *)fileUrl mimeType:(NSString *)mimeType callBack:(ResponseCallback)callback;

//delete, params是query参数，data是body参数
- (void)delete:(NSString*)url params:(nullable NSDictionary *)params data:(nullable NSDictionary *)data callBack:(ResponseCallback)callback;

- (NSString*)addUrlParam:(NSString*) oldUrl getParams:(NSDictionary<NSString*,NSObject *> *)getData;

@end

NS_ASSUME_NONNULL_END
