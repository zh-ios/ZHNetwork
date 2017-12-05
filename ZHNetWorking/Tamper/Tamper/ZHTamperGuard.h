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
    TamperGuardAction_INVALIDATE_RETURNCODE, // return code 无效，非200
    TamperGuardAction_STATUS_CODE_500, // 500 错误,这种情况不进行重试
    TamperGuardAction_STATUS_CODE_302, // 302 跳转
    TamperGuardAction_JSON_CHECK, // json 合法性校验
    TamperGuardAction_DATA_NULL, // response data 为空
    TamperGuardAction_NONE_RESPONSE_HEADER // 无响应头或者响应头无内容
};

@interface ZHTamperGuard : NSObject

@end
