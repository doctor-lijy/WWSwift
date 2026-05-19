//
//  SecurityManager.h
//  PHNet
//
//  Created by christ on 2025/5/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SecurityManager : NSObject
+ (instancetype)getInstance ;
- (NSString *)getSideCarSign:(NSString*) originStr;
@end

NS_ASSUME_NONNULL_END
