//
//  ZHDNSIpService.h
//  ZHNetWorking
//
//  Created by autohome on 2017/9/28.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHDNSResolveItem.h"

@interface ZHDNSIpService : NSObject


/// 一个service 可能 能解析出多个 resolveItem ！！！
/*!
 @property
 @abstract 是否缓存ip列表
 */
@property(nonatomic, assign) BOOL saveCache;

/*!
 @property
 @abstract 上一次更新的时间
 */
@property(nonatomic, assign) NSTimeInterval lastUpdateTime;
/*!
 @property
 @abstract 网络环境是否变化
 */
@property(nonatomic, assign) BOOL isNetStatusChanged;

/*!
 @property
 @abstract 可用的resolveItemArr 
 */
@property(nonatomic, strong) NSArray *resolveItemArr;

/*!
 @property
 @abstract  当前接口处理的域名
 */
@property(nonatomic, copy) NSString *domain;

/*!
 @property
 @abstract 解析状态
 */
@property(nonatomic, assign) DNSResolveStatus resolveStatus;

- (instancetype)initWithResolveItem:(ZHDNSResolveItem *)item;

/*!
 @method
 @abstract   开始解析
 */
- (void)resolve;


/*!
 @method
 @abstract   解析返回结果
 @discussion 解析返回结果字符串
 @param      isCache 是否从缓存中读取
 */
- (void)analysisResponseStr:(NSString *)responseStr isFromCache:(BOOL)isCache;



@end
