//
//  ZHTamperGuard.m
//  ZHNetWorking
//
//  Created by autohome on 2017/12/5.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import "ZHTamperGuard.h"
#import "ZHBaseService.h"
#import "ZHDNSHttpManager.h"
#import "ZHProxyManager.h"
#import "MD5Tools.h"
#import "ZHNetworkConst.h"

#define k_RETRY_RANDOM_PARAM   @"refreshparam"
#define k_RETRY_REQID          @"reqid"

@implementation ZHTamperGuard

static ZHTamperGuard *_tamper = nil;

+ (instancetype)sharedInstance {
    if (_tamper) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (!_tamper) {
                _tamper = [[self alloc] init];
            }
        });
    }
    return _tamper;
}

- (void)checkService:(ZHBaseService *)service request:(ZHRequest *)request delegate:(id<ZHTamperGuardDelegate>)delegate {
    /** 只对GET 请求对劫持校验   */
    if (request.requestType == ZHRequest_Type_POST) {
        [self completeWithResult:TamperGuardAction_NONE withService:service dropResponse:NO delegate:delegate];
        return;
    }
    
    /** 状态码为 500 系列时 不进行任何重试，需要放在最前面进行判断 */
    if (![self isValidateStatusCode:service request:request delegate:delegate]) {
        if (request.statusCode == 500 || (request.statusCode>=502 && request.statusCode<= 504)) {
            if (request.requestHostType == ZHRequest_HostType_DNSPOD && request.requestRetryType != ZHRequest_Retry_Type_Other) {
                [[ZHDNSHttpManager sharedManager] setIpInvalidate:service.reallyUrlStr requestUrlStr:request.requestUrlStr];
            }
            if (request.useProxy) {
                //置反向代理地址失效
//                [[ZHProxyManager sharedManager] setProxyAddressInvalidate:request];
            }
            [self completeWithResult:TamperGuardAction_STATUS_CODE_500 withService:service dropResponse:NO delegate:delegate];
            return;
        }
    }
    
    /** 在判断http返回码前，优先判断无响应或者有响应头无响应内容*/
    NSString *errorType = nil;
    if (request.allHeaderFields == nil || (request.allHeaderFields && [request.allHeaderFields.allValues count] == 0) ) {
        // 无响应头且无响应内容
        if (request.responseString == nil || (request.responseString && request.responseString.length == 0)) {
            errorType = @"no_response_header";
        }
    }
    if ([request.allHeaderFields.allValues count] > 0) {
        // you响应头但是无响应内容
        if (request.responseString == nil || ((request.responseString&&request.responseString.length== 0) && request.statusCode != 204)) {
            errorType = @"no_response_str";
        }
    }
    if ([errorType length] > 0) {
        if (request.requestHostType == ZHRequest_HostType_DNSPOD && request.requestRetryType != ZHRequest_Retry_Type_Other) {
            [[ZHDNSHttpManager sharedManager] setIpInvalidate:service.reallyUrlStr requestUrlStr:request.requestUrlStr];
        }
        
        if (request.useProxy) {
            // 如果已经使用了反向代理，则不再进行其他操作
            [self completeWithResult:TamperGuardAction_USE_PROXY withService:service dropResponse:NO delegate:delegate];
            // 设置反向代理地址失效
            //        [[ZHProxyManager sharedManager] setIpAddressInvaldate:request]
            return;
        }
        
        [self completeWithResult:TamperGuardAction_NONE_RESPONSE_HEADER withService:service dropResponse:NO delegate:delegate];
        return;
    }
    
    /** http 状态码校验 */
    if (![self isValidateStatusCode:service request:request delegate:delegate]) {
         /** 对302的情况，应该走requestRedirect，走到这儿，表示异常了，有可能是测试直接改的httpcode，改为直接return，什么都不做*/
        if (request.statusCode == 301 || request.statusCode == 302 || request.statusCode == 303|| request.statusCode == 307) {
            [self completeWithResult:TamperGuardAction_STATUS_CODE_302 withService:service dropResponse:NO delegate:delegate];
            return;
        }
        
        if (request.requestHostType == ZHRequest_HostType_DNSPOD && request.requestRetryType != ZHRequest_Retry_Type_Other) {
            [[ZHDNSHttpManager sharedManager] setIpInvalidate:service.reallyUrlStr requestUrlStr:request.requestUrlStr];
            return;
        }
        if (request.useProxy) {
//            [[ZHProxyManager sharedManager] setIpAddreInvalidate:request]
            [self completeWithResult:TamperGuardAction_USE_PROXY withService:service dropResponse:NO delegate:delegate];
            return;
        }
        [self completeWithResult:TamperGuardAction_STATUS_CODE_CHECK withService:service dropResponse:NO delegate:delegate];
        return;
    }
    
    ///////////////////////////////////////////////////////////
    
    if (service.enableMD5) {
        NSString *errorMsg = nil;
        BOOL ret = [self md5Judge:service request:request errorMsg:&errorMsg delegate:delegate];
        if (ret) {
            // MD5 校验通过
        } else {
            [ZHProxyManager sharedManager].useProxy = YES;
            // errorMsg 上报错误信息
            
            if (request.requestHostType == ZHRequest_HostType_DNSPOD && request.requestRetryType != ZHRequest_Retry_Type_Other) {
                [[ZHDNSHttpManager sharedManager] setIpInvalidate:service.reallyUrlStr requestUrlStr:request.requestUrlStr];
            }
            
            if (request.useProxy) {
                // 已经使用反向代理则不再进行后续操作
//                [[ZHProxyManager sharedManager] setIpAddressInvalidate]
                [self completeWithResult:TamperGuardAction_USE_PROXY withService:service dropResponse:NO delegate:delegate];
                return;
            }
            
            /// 请求失败，使用反向代理重发请求
            BOOL resend = NO;
            if (service.enableRetry && request.requestType == ZHRequest_Type_GET) {
                resend = [self reRequestThroughProxy:service request:request];
            }
            //当resend为YES的时候，说明需要重发，故drop参数同样也为YES
            [self completeWithResult:TamperGuardAction_MD5_CHECK withService:service dropResponse:request delegate:delegate];
            return;
        }
    }
    
    ////////////////////////////////缓存过期检测////////'
    NSString *expiredInfo = nil;
    if ([self isExpiredData:service req:request expiredInfo:&expiredInfo delegate:delegate]) {
        if ([expiredInfo length] > 0) {
            // 出现数据过期的情况 进行处理：如果日志上报等
        }
        
        if (request.requestHostType == ZHRequest_HostType_DNSPOD && request.requestRetryType != ZHRequest_Retry_Type_Other) {
            [[ZHDNSHttpManager sharedManager] setIpInvalidate:service.reallyUrlStr requestUrlStr:request.requestUrlStr];
        }
        if (request.useProxy) {
            // 如果已经使用了反向代理
//            [ZHProxyManager sharedManager] setIpAddressInvadate
            [self completeWithResult:TamperGuardAction_USE_PROXY withService:service dropResponse:NO delegate:delegate];
            return;
        }
        
        // 尝试使用添加随机串的方式重发
        BOOL resend = NO;
        if (service.enableRetry && service.exipredRertyTimes <= DATA_EXPIRED_RETRY_COUNT && request.requestType == ZHRequest_Type_GET) {
            resend = [self reRequestThroughRandomParam:service request:request];
        }
        [self completeWithResult:TamperGuardAction_EXPIRED_CHECK withService:service dropResponse:resend delegate:delegate];
        return;
    }
    
    //////////////////// JSON 校验/////////////////////////////
    if (service.enableJSONPrase) {
        BOOL success = NO;
        @try {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingAllowFragments error:nil];
            success = [NSJSONSerialization isValidJSONObject:dic];
        } @catch (NSException *e) {
            
        }
        
        if (!success) {
            // 上报日志
            
            if (request.requestHostType == ZHRequest_HostType_DNSPOD && request.requestRetryType != ZHRequest_Retry_Type_Other) {
                [[ZHDNSHttpManager sharedManager] setIpInvalidate:service.reallyUrlStr requestUrlStr:request.requestUrlStr];
            }
            if (request.useProxy) {
//                [ZHProxyManager sharedManager] setIpAddre
                [self completeWithResult:TamperGuardAction_JSON_CHECK withService:service dropResponse:NO delegate:delegate];
                return;
            }
        }
        [self completeWithResult:TamperGuardAction_JSON_CHECK withService:service dropResponse:NO delegate:delegate];
        return;
    }
    
    // 上报日志 NONE ERROR
    [self completeWithResult:TamperGuardAction_NONE withService:service dropResponse:NO delegate:delegate];
}

- (BOOL)reRequestThroughRandomParam:(ZHBaseService *)service request:(ZHRequest *)req {
    if (!service.enableRetry || req.requestType != ZHRequest_Type_GET || req.useProxy)  return NO;
    
    NSRange range = [req.requestUrlStr rangeOfString:k_RETRY_RANDOM_PARAM];
    if (range.location != NSNotFound) {
        // 已经重试过了
        return NO;
    } else {
        NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:req.allHeaderFields];
        [mDic setObject:@"reqid" forKey:k_RETRY_REQID];
        req.requestHeaders = [mDic copy];
        service.requestHeaderDic = [mDic copy];
        
        [self performSelector:@selector(dataOutofdateAddRandomNumForReRequest:) withObject:[self addRandomParam:req.requestUrlStr]];
        return YES;
    }
}

/*!
 @method
 @abstract   向url中添加随机查询参数
 */
- (NSString *)addRandomParam:(NSString *)urlStr {
    NSRange range = [urlStr rangeOfString:k_RETRY_RANDOM_PARAM];
    //已经有随机参数不再重复添加
    if (range.location != NSNotFound) {
        return urlStr;
    }
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSString *randomStr = [NSString stringWithFormat:@"%.0f",interval];
    NSString *pars = [[NSURL URLWithString:urlStr] query];
    if (nil == pars) {
       return [NSString stringWithFormat:@"%@?%@=%@",urlStr,k_RETRY_RANDOM_PARAM,randomStr];
    }else{
         return [NSString stringWithFormat:@"%@&%@=%@",urlStr,k_RETRY_RANDOM_PARAM,randomStr];
    }
}

/*!
 @method
 @abstract   通过反向代理的方式进行重试
 @return    是否已经重试
 */
- (BOOL)reRequestThroughProxy:(ZHBaseService *)service request:(ZHRequest *)req {
    if (!service.enableRetry || req.requestType != ZHRequest_Type_GET || req.useProxy)  return NO;

//    NSString *newProxyIpAddr = [ZHProxyManager sharedManager]  获取下一个可用的ip地址
    NSString *newProxyIpAddr = @"";
    NSString *avaiableProxyUrlStr = @"";
    if (!(avaiableProxyUrlStr && [avaiableProxyUrlStr isKindOfClass:[NSString class]] && [avaiableProxyUrlStr length] > 0)) return NO;
    NSURL *avaliableProxyUrl = @""; // 通过反向代理mgr 获取可用url
    // 判断当前的方向代理地址和传入进来的url 是否一样
    if (![[avaliableProxyUrl absoluteString] isEqualToString:service.requestUrlStr]) {
        NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:req.allHeaderFields];
        // 对于反向大力请求 header中 都添加 reqid 字段 。
        [mDic setObject:@"reqid" forKey:@"reqid"];
        //发送反向代理，设置Host头
        if ([[NSURL URLWithString:service.requestUrlStr] host]) {
            [mDic setObject:[[NSURL URLWithString:service.requestUrlStr] host] forKey:@"Host"];
        }
        req.requestHeaders = [mDic copy];
        req.useProxy = YES;
        
        service.requestHeaderDic = [mDic copy];
        [service performSelector:@selector(getDataByNoReallyURL:) withObject:[NSURL URLWithString:[avaliableProxyUrl absoluteString]]];
        return YES;
    } else {
        return NO;
    }
}



- (BOOL)md5Judge:(ZHBaseService *)service request:(ZHRequest *)req errorMsg:(NSString **)errorMsg delegate:(id<ZHTamperGuardDelegate>)delegate {
    // 正在进行MD5校验
    [self onChangeMonitorAction:TamperGuardAction_MD5_CHECK service:service delegate:delegate];
    *errorMsg = nil;
    NSString *md5StrFromHeader = @"";
    for (NSString *key in req.allHeaderFields.allKeys) {
        if ([[key lowercaseString] isEqualToString:@"content-hash"]) {
            md5StrFromHeader = req.allHeaderFields[@"content-hash"];
            break;
        }
    }
    if (!md5StrFromHeader) {
        md5StrFromHeader = @"";
    }
    //如果没有md5字段，检查响应头是否来自我们的服务器
    if ([md5StrFromHeader isEqualToString:@""]) {
        //来自我们服务器说明响应头中，本来就没有添加md5字段（如某些静态页面）
        if ([self isFromOurServier:service req:req]) {
            *errorMsg = @"success";
            return YES;
        } else {
            //可能头被篡改，丢失了md5值
            *errorMsg = @"nohash";
            return NO;
        }
    }
    
    /** 这里和服务端商定好加解密规则 ！！！！！！ 自定义*/
    md5StrFromHeader = [md5StrFromHeader lowercaseString];
    NSString *responseStrMD5 = [MD5Tools stringFromMD5:req.responseString];
    if ([md5StrFromHeader isEqualToString:responseStrMD5]) {
        *errorMsg = @"success";
        return YES;
    } else {
        *errorMsg = @"dismatch";
        return NO;
    }
}

- (BOOL)isExpiredData:(ZHBaseService *)service req:(ZHRequest *)req
          expiredInfo:(NSString **)info delegate:(id<ZHTamperGuardDelegate>)delegate {
    [self onChangeMonitorAction:TamperGuardAction_EXPIRED_CHECK service:service delegate:delegate];
    *info = nil;
    NSTimeInterval lastupdate = 0;
    for (NSString *key in req.allHeaderFields) {
        if ([key isEqualToString:@"lastupdate"]) {
            lastupdate = [[req.allHeaderFields objectForKey:key] doubleValue];
            break;
        }
    }
    // header中有这个字段才进行数据缓存过期校验
    if (lastupdate > 0) {
        NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
        BOOL ret = fabs(lastupdate-nowTime) > 60*60*12;
        // 间隔超过12个小时
        if (ret) {
            if ([self isRetryRequestForExpiredData:req]) {
                // 数据过期已经重试
                *info = @"EXPIRED_DATA_HAD_RETRY";
            } else {
                // 数据过期未重试
                *info = @"EXPIRED_DATA";
            }
            return YES;
        } else {
            return NO;
        }
    } else {
        /** 取lastupdate<=0，android校验这种情况是失败。应该return YES*/
        if ([self isRetryRequestForExpiredData:req]) {
            *info = @"EXPIRED_DATA_HAD_RETRY";
        }else {
            
            *info = @"EXPIRED_DATA";
        }
        return YES;
    }
}

/*!
 @method
 @abstract   是否是因为数据过期校验重试的请求
 */
- (BOOL)isRetryRequestForExpiredData:(ZHRequest *)req {
    NSRange range = [req.requestUrlStr rangeOfString:@"refreshParam"];
    if (range.location != NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)isFromOurServier:(ZHBaseService *)service req:(ZHRequest *)req {
    //通过响应头中包含的“AppServer”字段来标示响应是不是来自我们的服务器
    if (nil == req.allHeaderFields[@"AppServer"]) {
        return NO;
    }else{
        return YES;
    }
}

/*!
 状态码是否有效， 返回200 为有效
 */
- (BOOL)isValidateStatusCode:(ZHBaseService *)service request:(ZHRequest *)req delegate:(id<ZHTamperGuardDelegate>)delegate {
    [self onChangeMonitorAction:TamperGuardAction_STATUS_CODE_CHECK service:service delegate:delegate];
    if (req.statusCode != 200) {
        return NO;
    }
    return YES;
}

/** 监测状态变化的时候调用 ，比如：从状态码监测-MD5校验-JSON合法性校验*/
- (void)onChangeMonitorAction:(TamperGuardAction)action service:(ZHBaseService *)service delegate:(id<ZHTamperGuardDelegate>)delegate {
    if ([delegate respondsToSelector:@selector(tamperGuardActionOnChanged:service:)]) {
        [delegate tamperGuardActionOnChanged:action service:service];
    }
}

//监测完成回调
//drop 表示是否抛弃该次请求，由反劫持自动重发（数据被缓存，数据被篡改的时候会自动重发该值为YES）
- (void)completeWithResult:(TamperGuardAction)result withService:(ZHBaseService*)service dropResponse:(BOOL)drop delegate:(id<ZHTamperGuardDelegate>)aDelegate{
    if ([aDelegate respondsToSelector:@selector(tamperGuardResult:service:dropResponse:)]) {
    }
}



#pragma mark - reqid
//+ (NSString *)reqid {
//
//    long long time = (long long)((double)[[NSDate date] timeIntervalSince1970] * 1000);
//    /** reqId = deviceid+“/”+timestamp+"/"+100～999随机数 时间戳精确到毫秒 */
//    int randomNum = arc4random() % 900 + 100;
//    NSString *openUID = @"";
//    if ([AHTamperConfig sharedInstance].delegate && [[AHTamperConfig sharedInstance].delegate respondsToSelector:@selector(openUID)]) {
//        openUID = [[AHTamperConfig sharedInstance].delegate openUID];
//    }
//    NSString *result = [NSString stringWithFormat:@"%@/%lld/%d",openUID,time,randomNum];
//    if (result) {
//        return result;
//    }
//    return @"";
//}

@end
