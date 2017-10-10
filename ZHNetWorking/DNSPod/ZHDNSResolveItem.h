//
//  ZHDNSResolveItem.h
//  ZHNetWorking
//
//  Created by autohome on 2017/9/28.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,DNSResolveStatus) {
    DNSResolveStatus_Init = 0,
    DNSResolveStatus_Resolving,
    DNSResolveStatus_Done,
    DNSResolveStatus_Failed
};

@interface ZHDNSResolveItem : NSObject

/*!
 @property
 @abstract 域名
 */
@property(nonatomic, copy) NSString *domain;

@property(nonatomic, copy) NSString *ipAddr;

@property(nonatomic, assign) DNSResolveStatus resolveStatus;
/*!
 @property
 @abstract ttl生命期
 */
@property(nonatomic, assign) NSInteger ttl;
/*!
 @property
 @abstract time连接用时
 */
@property(nonatomic, assign) NSTimeInterval useTime;

@end
