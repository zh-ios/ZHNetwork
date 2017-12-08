//
//  ZHProxyManager.h
//  ZHNetWorking
//
//  Created by autohome on 2017/12/5.
//  Copyright © 2017年 autohome. All rights reserved.
//  反向代理管理类

#import <Foundation/Foundation.h>

@interface ZHProxyManager : NSObject

@property(nonatomic, assign) BOOL useProxy;

+ (instancetype)sharedManager;

@end
