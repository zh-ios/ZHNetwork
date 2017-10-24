//
//  ZHDNSHttpManager.h
//  ZHNetWorking
//
//  Created by autohome on 2017/9/29.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import <Foundation/Foundation.h>

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
 @abstract   添加域名并且对所有的域名进行重发
 @discussion 要添加的域名如果已经存在则过滤掉，不添加。
 @param      cache 是否缓存域名
 */
- (void)addDomainsAndAllRefresh:(NSArray *)domainArr cache:(BOOL)cache;

/*!
 @method
 @abstract   根据请求的urlstr的domain 获取对应的dnsip
 @discussion 返回domain替换为ip后的url
 @param      reallyUrlStr 实际请求的urlStr urlStr原请求的urlStr
 */
- (NSString *)getIpUrlStrWithReallyUrlStr:(NSString *)reallyUrlStr requestUrlStr:(NSString *)urlStr;

/*!
 @method
 @abstract   设置ip地址无效
 @discussion 设置domain对应的ip地址无效
 @param     reallyUrlStr 实际的请求url urlStr 原请求url
 */
- (void)setIpInvalidate:(NSString *)reallyUrlStr requestUrlStr:(NSString *)urlStr;
@end
