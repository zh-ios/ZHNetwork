//
//  ZHNetworkConst.h
//  ZHNetWorking
//
//  Created by autohome on 2017/12/6.
//  Copyright © 2017年 autohome. All rights reserved.
//

#ifndef ZHNetworkConst_h
#define ZHNetworkConst_h

#define DATA_EXPIRED_RETRY_COUNT (1)

#define dispatch_main_queue_excute(block)\
        if ([NSThread isMainThread]) {\
        block();\
        } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
        }

#endif /* ZHNetworkConst_h */
