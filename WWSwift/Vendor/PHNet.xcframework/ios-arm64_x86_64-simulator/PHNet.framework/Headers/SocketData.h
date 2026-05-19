//
//  SocketData.h
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static const int TYPE_SOCKET_SPOT_MARKET = 101;//合约24小时行情
static const int TYPE_SOCKET_SPOT_KLINE = 102;
static const int TYPE_SOCKET_SPOT_TRADE_HISTORY = 103; //最后交易数据
static const int TYPE_SOCKET_SPOT_RATE_DATA = 104; //汇率
static const int TYPE_SOCKET_SPOT_ORDERBOOK = 105;
static const int TYPE_SOCKET_SPOT_ORDERS = 106; //order数据
static const int TYPE_SOCKET_MAIN_ASSETS = 107;//资金账户
static const int TYPE_SOCKET_SPOT_ASSETS = 108;//现货账户
static const int TYPE_SOCKET_SPOT_EARN_ASSETS = 109;//理财账户
static const int TYPE_SOCKET_SPOT_MARKET_SINGLE = 110;//合约24小时行情,单币订阅
 
static const int TYPE_SOCKET_CONTRACT_MARKET = 301;//合约24小时行情
static const int TYPE_SOCKET_CONTRACT_FUNDINGRATE = 302;
static const int TYPE_SOCKET_CONTRACT_TRADE_HISTORY = 303; //最后交易数据
static const int TYPE_SOCKET_CONTRACT_KLINE= 304;
static const int TYPE_SOCKET_CONTRACT_ORDERBOOK = 305;
static const int TYPE_SOCKET_CONTRACT_TRADEDATA = 306;
static const int TYPE_SOCKET_CONTRACT_COUPON_EVENT = 307;
static const int TYPE_SOCKET_CONTRACT_GIFT_EVENT = 308;
static const int TYPE_SOCKET_CONTRACT_COPY_EVENT = 309;
static const int TYPE_SOCKET_CONTRACT_MARKET_SINGLE = 310;//合约24小时行情,单币
/* 通知数据 */
static const int TYPE_SOCKET_SPOT_DEPLOY= 400; //新现货上币
static const int TYPE_SOCKET_EVENT_CONTRACT_MAINTAIN=401; //合约维护状态
static const int TYPE_SOCKET_EVENT_DOMAIN_CHANGE=402; //域名变更
static const int TYPE_SOCKET_EVENT_CONTRACT_CHANGE=403; //合约metadata变更
static const int TYPE_SOCKET_EVENT_CONTRACT_TRADFI_CHANGE=404; //tradfi变更
static const int TYPE_SOCKET_EVENT_SPOT_MARKET_CLOSE_CHANGE=405; //现货休市变更

//socket主动断开链接，可用于清楚数据
static const int TYPE_SOCKET_CONNECTED_SPOT = 500; //web socket 通道情况
static const int TYPE_SOCKET_DISCONNECT_SPOT = 501;
static const int TYPE_SOCKET_CONNECTED_CONTRACT_PUBLIC = 502;
static const int TYPE_SOCKET_CONNECTED_CONTRACT_PRIVATE = 503;
static const int TYPE_SOCKET_DISCONNECT_CONTRACT_PUBLIC = 504;
static const int TYPE_SOCKET_DISCONNECT_CONTRACT_PRIVATE = 505;
static const int TYPE_SOCKET_CONNECTED_EVENT = 506;
static const int TYPE_SOCKET_DISCONNECT_EVENT = 507;
/* web_socket通道延迟(long), 通过心跳延迟计算 */
static const int TYPE_SOCKET_DELAY_SPOT = 510; 
static const int TYPE_SOCKET_DELAY_CONTRACT_PUBLIC = 512;
static const int TYPE_SOCKET_DELAY_CONTRACT_PRIVATE = 513;
static const int TYPE_SOCKET_DELAY_EVENT = 514;
@interface SocketData : NSObject
@property(nonatomic,assign) int type;
@property(nonatomic,retain) NSString* data;

- (instancetype)initWithData:(int)type data:(NSString*)data;

@end

//回调
typedef void(^PHSocketMsgBlock)(SocketData* result); 

NS_ASSUME_NONNULL_END
