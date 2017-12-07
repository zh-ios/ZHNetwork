//
//  ZHTamperGuard.h
//  ZHNetWorking
//
//  Created by autohome on 2017/12/5.
//  Copyright © 2017年 autohome. All rights reserved.
//  劫持守卫类

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TamperGuardAction) {
    TamperGuardAction_NONE = 0,
    TamperGuardAction_STATUS_CODE_CHECK, // http状态码检验
    TamperGuardAction_MD5_CHECK, // MD5校验
    TamperGuardAction_EXPIRED_CHECK, // 过期检查
    TamperGuardAction_USE_PROXY, // 已经使用了反向代理
    TamperGuardAction_INVALIDATE_RETURNCODE, // return code 无效，非200
    TamperGuardAction_STATUS_CODE_500, // 500 错误,这种情况不进行重试
    TamperGuardAction_STATUS_CODE_302, // 302 跳转
    TamperGuardAction_JSON_CHECK, // json 合法性校验
    TamperGuardAction_DATA_NULL, // response data 为空
    TamperGuardAction_NONE_RESPONSE_HEADER // 无响应头或者响应头无内容
};

@class ZHBaseService;
@class ZHRequest;

@protocol ZHTamperGuardDelegate <NSObject>

/** 反劫持校验行为回调 ，记录当前进行的是那一项校验*/
- (void)tamperGuardActionOnChanged:(TamperGuardAction)action service:(ZHBaseService *)service;

/** 反劫持校验结果回调 记录校验的结果*/
- (void)tamperGuardResult:(TamperGuardAction)result service:(ZHBaseService *)service dropResponse:(BOOL)drop;

@end

@interface ZHTamperGuard : NSObject

+ (instancetype)sharedInstance;

/*!
 @method
 @abstract   监控入口函数
 @discussion 仅在baseService中使用
 @param      @service 要监控的service ， request，delegate
 */
- (void)checkService:(ZHBaseService *)service request:(ZHRequest *)request delegate:(id<ZHTamperGuardDelegate>)delegate;

@end
