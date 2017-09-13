//
//  ZHRequestManager.h
//  ZHNetWorking
//
//  Created by autohome on 2017/9/12.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZHRequest;

@interface ZHRequestManager : NSObject

+ (instancetype)sharedManager;

- (void)addRequest:(ZHRequest *)request;

- (void)cancelAllRequest;

- (void)cancelRequest:(ZHRequest *)request;

@end
