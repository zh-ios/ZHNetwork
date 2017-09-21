//
//  ZHBatchRequestManager.h
//  ZHNetWorking
//
//  Created by autohome on 2017/9/20.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZHBatchRequest;

@interface ZHBatchRequestManager : NSObject



+ (instancetype)sharedManager;

- (void)addBatchRequest:(ZHBatchRequest *)batchRequest;

- (void)cancelBatchRequest:(ZHBatchRequest *)batchRequest;


@end
