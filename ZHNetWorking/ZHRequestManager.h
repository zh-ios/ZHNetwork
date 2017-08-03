//
//  ZHRequestManager.h
//  ZHNetWorking
//
//  Created by autohome on 2017/8/3.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ZHBaseRequest;
@interface ZHRequestManager : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (void)addRequest:(ZHBaseRequest *)request;
+ (void)cancelRequest:(ZHBaseRequest *)request;
+ (void)cancelAllRequests;

+ (instancetype)sharedManager;

NS_ASSUME_NONNULL_END

@end
