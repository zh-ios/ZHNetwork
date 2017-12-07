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

@implementation ZHTamperGuard


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
        [self md5Judge:service request:request errorMsg:&errorMsg delegate:delegate];
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

@end
