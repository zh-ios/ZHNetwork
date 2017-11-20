//
//  ZHTamperConfig.h
//  ZHNetWorking
//
//  Created by autohome on 2017/11/14.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZHTamperConfig : NSObject

/*!
 @property
 @abstract 是否允许 httpDns 
 */
@property(nonatomic, assign) BOOL enableHttpDns;
/*!
 @property
 @abstract 是否允许反向代理
 */
@property(nonatomic, assign) BOOL enableProxy;
/*!
 @property
 @abstract 是否允许反劫持
 */
@property(nonatomic, assign) BOOL enableTamperGuard;

+ (instancetype)sharedConfig;

@end
