//
//  SocketManager.h

//
//

#import <Foundation/Foundation.h>
#import "SocketData.h" 

NS_ASSUME_NONNULL_BEGIN 
@interface SocketManager : NSObject 

+ (instancetype)getInstance;
//注册回调
-(void)registReceiver:(NSArray<NSNumber *>*)msgArr queue:(dispatch_queue_t)queue callBack:(PHSocketMsgBlock)callBack; 
 
//链接socket
- (void)start;
//重连socket
- (void)reConnect;
- (void)reConnectWithLastInfo;
- (void)disConnect;
//前后台切换
-(void)onAppForeground;

 


//----------------------------订阅相关--------------------------------------
 
//
-(void)subscribeMarketsOfContract;
-(void)subscribeMarketsOfContract_Batch:(NSSet<NSString*>*)symbolIds;
-(void)unSubscribeMarketsOfContract_Batch:(NSSet<NSString*>*)symbolIds;
-(void)subScribeFundingRateOfContract:(NSString*) contractId;
-(void)subScribeLastTradeOfContract:(NSString*) contractId;
-(void)subScribeOrderBookOfContract:(NSString*) contractId;
-(void)subScribeKlineOfContract:(NSString*) contractId type:(NSString*) type interval:(NSString*) interval;
-(void)unSubscribeMarketsOfContract;
-(void)unSubScribeFundingRateOfContract:(NSString*) contractId;;
-(void)unSubScribeLastTradeOfContract:(NSString*) contractId;
-(void)unSubScribeOrderBookOfContract:(NSString*) contractId;
-(void)unSubScribeKlineOfContract:(NSString*) contractId type:(NSString*) type interval:(NSString*) interval;
-(void)subscribeCopyEventOfContract; 
//New spot
-(void)subscribeMarketsOfSpot;
-(void)subscribeMarketsOfSpot_Batch:(NSSet<NSString*>*)symbolIds;
-(void)unSubscribeMarketsOfSpot_Batch:(NSSet<NSString*>*)symbolIds;
-(void)subScribeKlineOfSpot:(NSString*) contractId type:(NSString*) type interval:(NSString*) interval;
-(void)unSubScribeKlineOfSpot:(NSString*) contractId type:(NSString*) type interval:(NSString*) interval;
-(void)subScribeLastTradeOfSpot:(NSString*) symbol;
-(void)unSubScribeLastTradeOfSpot:(NSString*) symbol;
-(void)subScribeOrderBookOfSpot:(NSString*) symbol
                       stepSize:(NSString *)stepSize;
-(void)unSubScribeOrderBookOfSpot:(NSString*) symbol
                         stepSize:(NSString *)stepSize;
-(void)subScribeTranscationRateOfSpot;
-(void)subScribeMainAsset:(NSString*) userToken;
-(void)subScribeSpotAsset:(NSString*) userToken;
-(void)subScribeSpotEarnAsset:(NSString*) userToken;
-(void)subScribeActiveOrdersOfSpot:(NSString*) userToken;
@end

NS_ASSUME_NONNULL_END
