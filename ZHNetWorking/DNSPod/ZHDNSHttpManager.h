//
//  ZHDNSHttpManager.h
//  ZHNetWorking
//
//  Created by autohome on 2017/9/29.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import <Foundation/Foundation.h>


/** reallyUrl 代表的是客户端传入的url ， requestUrl 则实际真正发请求的url
 该url有可能和reallyUrl相等 也有可能是将domain替换为ip后的请求 。
 
 反向代理的处理逻辑类似 ！！！ 当有可用ip 但是ip状态为失效时使用反向代理。
 
 */

@interface ZHDNSHttpManager : NSObject

/*!
 @property
 @abstract 网络环境是否发生变化，如果网络环境发生变化就需要重发
 */
@property(nonatomic, assign) BOOL isNetStatusChanged;
@property(nonatomic, assign) NSInteger intime;
@property(nonatomic, assign) NSInteger outtime;

+ (instancetype)sharedManager;

/*!
 @method
 @abstract   获取域名列表
 */
- (void)getAllDomain;
/*!
 @method
 @abstract   获取域名列表
 */
- (NSArray *)getAllDomainList;

/*!
 @method
 @abstract   对传入的新增域名进行重发
 @param      domainArr 新增域名数组
 */
- (void)addDomainAndRefresh:(NSArray *)domainArr;
/*!
 @method
 @abstract   添加域名并且对所有的域名进行重发
 @discussion 要添加的域名如果已经存在则过滤掉，不添加。
 @param      cache 是否缓存域名
 */
- (void)addDomainsAndAllRefresh:(NSArray *)domainArr cache:(BOOL)cache;

/*!
 @method
 @abstract
 根据请求的urlstr的domain 获取对应的dnsip， 在发起网络请求的时候调用这个方法，
 在改方法内部会根据传入的domain查到相应的ip 地址，如果有值，则使用 dnspod 请求 ，如果没有值则
 使用原始域名进行请求或者走反向代理 。
 @discussion 返回domain替换为ip后的url
 @param      reallyUrlStr 原请求的urlStr 实际原请求的urlStr
 */
- (NSString *)getIpUrlStrWithReallyUrlStr:(NSString *)reallyUrlStr requestUrlStr:(NSString *)urlStr;

/*!
 @method
 @abstract   设置ip地址无效
 @discussion 设置domain对应的ip地址无效
 @param     reallyUrlStr 原的请求url urlStr 实际请求url
 */
- (void)setIpInvalidate:(NSString *)reallyUrlStr requestUrlStr:(NSString *)urlStr;
@end
