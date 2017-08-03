//
//  ZHHttpRequst.h
//  ZHNetWorking
//
//  Created by autohome on 2017/8/2.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ZHRequestType) {
    ZHRequestType_GET,
    ZHRequestType_POST,
    ZHRequestType_DELETE
};


@interface ZHBaseRequest : NSObject

/*!
 @property
 @abstract 请求的task
 */
@property(nonatomic, strong) NSURLSessionTask *requestTask;

/*!
 @property
 @abstract 返回的字符串
 */
@property(nonatomic, copy, readonly) NSString *responseString;

@property(nonatomic, strong, readonly) NSHTTPURLResponse *httpResponse;

/*!
 @property
 @abstract 返回的状态吗
 */
@property(nonatomic, assign, readonly) NSInteger responseStatusCode;
/*!
 @property
 @abstract 服务器返回的请求头
 */
@property(nonatomic, strong, readonly) NSDictionary *responseHeaders;
/*!
 @property
 @abstract 返回的错误信息
 */
@property(nonatomic, strong, readonly) NSError *error;
/*!
 @property
 @abstract 请求urlstr
 */
@property(nonatomic, copy, readonly) NSURLRequest *originRequest;

/* may differ from originalRequest due to http server redirection */
@property(nonatomic, copy, readonly) NSURLRequest *crtRequest;
/*!
 @property
 @abstract 请求的优先级
 */
@property(nonatomic, assign) NSOperationQueuePriority priority;
/*!
 @property
 @abstract 请求超时重试次数
 */
@property(nonatomic, assign) NSInteger timeoutRetryTimes;
/*!
 @property
 @abstract 请求超时时长，单位 s
 */
@property(nonatomic, assign) NSInteger timeoutSeconds;
/*!
 @property
 @abstract get 方式请求服务添加的请求头
 */
@property(nonatomic, strong) NSDictionary *requstHeaders;
/*!
 @property
 @abstract requsestType
 */
@property(nonatomic, assign) ZHRequestType requestType;

/*!
 @method
 @abstract   改变当前请求的优先级
 @discussion 改变当前请求的优先级
 */
- (void)changeCrtRequstPriority;

/*!
 @method
 @abstract   取消并清除请求
 */
- (void)stop;
/*!
 @method
 @abstract   开始请求
 */
- (void)start;
@end
