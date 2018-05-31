//
//  ZHChainRequest.h
//  ZHNetWorking
//
//  Created by autohome on 2017/9/21.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
   将一系列以来的请求按顺序放入数组中，从第一个开始请求，开始后将该请求从数组中请求，请求成功后再继续用数组的第一个对象发起请求，知道数组中没有对象了，所有请求都成功 。
   一旦有一个失败，则请求失败 。
 */
@interface ZHChainRequest : NSObject

@end
