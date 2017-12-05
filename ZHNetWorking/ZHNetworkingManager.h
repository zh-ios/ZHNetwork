//
//  ZHNetworkingManager.h
//  ZHNetWorking
//
//  Created by autohome on 2017/11/20.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZHNetworkingManager : NSObject

+ (instancetype)sharedManager;


/*!
 @method
 @abstract   获取domainlist 列表
 @discussion 不是去发送请求的获取ip地址的方法，在该类初始化的时候就发请求获取domain对应的ip 了 。
 */
//- (NSArray *)getAllDomainList;

- (void)addDomainsAndRefresh:(NSArray *)domains;
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
