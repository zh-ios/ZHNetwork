//
//  ZHRequestDelegate.h
//  ZHNetWorking
//
//  Created by autohome on 2017/9/15.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZHRequest;

@protocol ZHRequestDelegate <NSObject>


@optional;
- (void)requestWillStart;
- (void)requestFinished:(ZHRequest *)request responseObj:(id)responseObj;
- (void)requestFinished:(ZHRequest *)request responseStr:(NSString *)responseStr;
- (void)requestFailed:(NSError *)error;

@end
