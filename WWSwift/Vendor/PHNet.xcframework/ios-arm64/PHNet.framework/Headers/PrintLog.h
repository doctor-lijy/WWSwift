//
//  PrintLog.h
//  PHNet
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PrintLog : NSObject
//控制sdk是否打印日志
@property(nonatomic, assign) BOOL isOpenLog;

+ (instancetype)getInstance;

-(void)Log:(NSString *)log;

@end

NS_ASSUME_NONNULL_END
