//
//  ZHBaseService.h
//  ZHNetWorking
//
//  Created by autohome on 2017/12/5.
//  Copyright © 2017年 autohome. All rights reserved.
//  网络请求基类

#import <Foundation/Foundation.h>
#import "ZHBaseServiceDelegate.h"
#import "ZHRequest.h"
typedef NS_ENUM(NSInteger, URLSessionRequestPriority) {
    // 对应着 NSURLSessionTaskPriorityDefault
    URLSessionRequestPriority_DEFAULT = 0,
    URLSessionRequestPriority_LOW,
    URLSessionRequestPriority_HIGH
};

@interface ZHBaseService : NSObject

@property(nonatomic, weak) id<ZHBaseServiceDelegate> delegate;

/*!
 @property
 @abstract 真是的url 如 https://www.baidu.com 而非ip
 */
@property(nonatomic, copy) NSString *reallyUrlStr;
/*!
 @property
 @abstract 网络请求服务的标示
 */
@property(nonatomic, assign) NSInteger handle;

/*!
 @property
 @abstract 请求对应的 urlsession 的优先级
 */
@property(nonatomic, assign) URLSessionRequestPriority priority;

/** 在 getData 之前进行设置 */
/*!
 @property
 @abstract 是否压缩请求体
 */
@property(nonatomic, assign) BOOL shouldCompressRequestBody;
/*!
 @property
 @abstract 是否使用dnspod 目前测试默认为no
 */
@property(nonatomic, assign) BOOL enableHttpDns;
/*!
 @property
 @abstract 是否使用反劫持
 */
@property(nonatomic, assign) BOOL enableTamperGuard;
/*!
 @property
 @abstract 是否允许走重试 , 默认是 YES
 */
@property(nonatomic, assign) BOOL enableRetry;
/*!
 @property
 @abstract 是否使用反向代理 ，默认no
 */
@property(nonatomic, assign) BOOL enableProxy;
/*!
 @property
 @abstract 是否使用MD5校验
 */
@property(nonatomic, assign) BOOL enableMD5;

/*!
 @property
 @abstract 超时重试此处 ，只针对get请求 ，post不重试
 */
@property(nonatomic, assign) NSUInteger timeoutRetryTimes;
/*!
 @property
 @abstract 超时时间
 */
@property(nonatomic, assign) NSTimeInterval timeoutSeconds;

/*!
 @property
 @abstract 当前数据过期 重试数量
 */
@property(nonatomic, assign, readonly) NSUInteger expiredRetryCount;
/*!
 @property
 @abstract 当前请求的类型 GET ，POST
 */
@property(nonatomic, copy, readonly) NSString *requestMethod;

@property(nonatomic, copy, readonly) NSString *requestUrlStr;

/*!
 @property
 @abstract 服务器返回的数据信息
 */
@property(nonatomic, copy, readonly) NSString *responseStr;

@property(nonatomic, strong, readonly) NSData *responseData;
/*!
 @property
 @abstract 是否允许打印日志，默认NO
 */
@property(nonatomic, assign) BOOL enableLog;

@property(nonatomic, copy) NSDictionary *requestHeaderDic;

@property(nonatomic, strong, readonly) ZHRequest *request;

///////////////////////缓存相关 暂未实现/////////////////////////////////////////
// TODO 读取缓存策略 ，写入缓存策略
/*!
 @property
 @abstract 写入缓存的keyword
 */
@property(nonatomic, copy) NSString *keyword;
/*!
 @property
 @abstract 缓存的表名
 */
@property(nonatomic, copy) NSString *keywordTableName;
/*!
 @property
 @abstract 最大缓存条数
 */
@property(nonatomic, assign) NSUInteger maxCacheCount;
/*!
 @property
 @abstract 是否是缓存数据
 */
@property(nonatomic, assign, readonly) BOOL isCacheData;
/*!
 @property
 @abstract 缓存有效时长
 */
@property(nonatomic, assign) NSTimeInterval effectiveCacheTime;
////////////////////////////////////////////////////////////////

@end
