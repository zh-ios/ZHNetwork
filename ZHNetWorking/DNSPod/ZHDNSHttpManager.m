//
//  ZHDNSHttpManager.m
//  ZHNetWorking
//
//  Created by autohome on 2017/9/29.
//  Copyright © 2017年 autohome. All rights reserved.
//
//{
//    message = "";
//    result =     {
//        intime = 300;
//        list =         (
//                        {
//                            host = "mobilenc.app.autohome.com.cn";
//                        },
//                        {
//                            host = "adnewnc.app.autohome.com.cn";
//                        }
//                        );
//        outtime = 1800;
//    };
//    returncode = 0;
//}

#import "ZHDNSHttpManager.h"
#import "ZHRequest.h"
#import "ZHRequestManager.h"
#import "ZHDNSIpService.h"
#import "ZHDNSResolveItem.h"

#import "AFNetworkReachabilityManager.h"

@interface ZHDNSHttpManager ()<ZHRequestDelegate>

@property(nonatomic, strong) NSArray *dnsIpServiceArr;

@end

@implementation ZHDNSHttpManager

+ (instancetype)sharedManager {
    static ZHDNSHttpManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_manager) {
            _manager = [[self alloc] init];
        }
    });
    return _manager;
}

- (instancetype)init {
    if (self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netDidChanged) name:AFNetworkingReachabilityDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginMonitorNetStatus) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)beginMonitorNetStatus {{
    [[AFNetworkReachabilityManager manager] startMonitoring];
}}


#warning ----此回调在网络变化的时候回执行，且会执行多次
 /**  这个回调会执行多次 !!!!!!!!! */
- (void)netDidChanged {
    AFNetworkReachabilityManager *netManager = [AFNetworkReachabilityManager manager];
    switch (netManager.networkReachabilityStatus) {
        case AFNetworkReachabilityStatusNotReachable:
            
        case AFNetworkReachabilityStatusReachableViaWWAN:
            // 传入的域名和当前已经存在的域名 取并集后重发
            [self addDomainsAndAllRefresh:nil cache:NO netChanged:YES];
        case AFNetworkReachabilityStatusReachableViaWiFi:
            // 传入的域名和当前已经存在的域名 取并集后重发
            [self addDomainsAndAllRefresh:nil cache:NO netChanged:YES];
        case AFNetworkReachabilityStatusUnknown:
            // 传入的域名和当前已经存在的域名 取并集后重发
            [self addDomainsAndAllRefresh:nil cache:NO netChanged:YES];
    }
}

- (void)getAllDomain {
    
    ZHRequest *domainRequest = [[ZHRequest alloc] init];
    domainRequest.requestType = ZHRequest_Type_GET;
    domainRequest.requestUrlStr = @"https://comm.app.autohome.com.cn/comm_v1.0.0/ashx/getappdomainname.json";
    domainRequest.responseSerilalizerType = ZHRequest_RequestSerializerType_JSON;
    domainRequest.delegate = self;
    [[ZHRequestManager sharedManager] addRequest:domainRequest];
}

- (NSArray *)getAllDomainList {
    NSMutableArray *domainArr = [NSMutableArray array];
    for (ZHDNSIpService *service in self.dnsIpServiceArr) {
        if (service.resolveItemArr.count > 0) {
            [domainArr addObject:service.domain];
        }
    }
    return [NSArray arrayWithArray:[domainArr copy]];
}

#pragma mark ----ZHRequestDelegate
//- (void)requestFinished:(ZHRequest *)request responseObj:(id)responseObj {
//
//}

- (void)requestFinished:(ZHRequest *)request responseStr:(NSString *)responseStr {
    id responseObj = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    if ([responseObj isKindOfClass:[NSDictionary class]]) {
        self.intime = [responseObj[@"result"][@"intime"] integerValue];
        self.outtime = [responseObj[@"result"][@"outtime"] integerValue];
        NSArray *domainDicArr = responseObj[@"result"][@"list"];
        NSMutableArray *domainArr = [NSMutableArray array];
        if (domainDicArr.count > 0) {
            for (NSDictionary *domainDic in domainDicArr) {
                NSString *domain = domainDic[@"host"];
                if (domain && domain.length > 0) {
                    [domainArr addObject:domain];
                }
            }
            [self addDomainsAndAllRefresh:domainArr cache:NO];
        }
    }
}

- (void)requestFailed:(NSError *)error {
    
}

/*!
 @method
 @abstract   对传入的新增域名进行重发
 @param      domainArr 新增域名数组
 */
- (void)addDomainAndRefresh:(NSArray *)domainArr {
    __block NSMutableArray *tempDnsIpService = [NSMutableArray arrayWithArray:self.dnsIpServiceArr];
    
    __block BOOL hasDomain = NO;
    [domainArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (![obj isKindOfClass:[NSString class]]) {
            *stop = YES;
            return;
        }
        if ([obj length] == 0) {
            *stop = YES;
            return;
        }
        
        NSString *domain = (NSString *)obj;
        
        for (int i = 0; i<tempDnsIpService.count; i++) {
            ZHDNSIpService *service = tempDnsIpService[i];
            if ([service.domain isEqualToString:domain]) {
                hasDomain = YES;
                // 如果不是解析已经完成同时解析结果的数组大于0，则重新解析
                // TODO 判断 service.domain 是不是ip地址
                if (service.resolveStatus != DNSResolveStatus_Done && service.resolveItemArr.count == 0) {
                    [service resolve];
                }
                break;
            }
        }

        
        if (!hasDomain) {
            ZHDNSResolveItem *item = [[ZHDNSResolveItem alloc] init];
            item.domain = domain;
            ZHDNSIpService *service = [[ZHDNSIpService alloc] initWithResolveItem:item];
//            TODO 判断 service.domain 是不是ip 地址，如果不是ip 才进行重发,然后加入到 tempDnsIpserviceArr 中
            [tempDnsIpService addObject:service];
            [service resolve];
        }
    }];
    self.dnsIpServiceArr = [tempDnsIpService copy];
}

/** 对所有域名进行重发 */
- (void)addDomainsAndAllRefresh:(NSArray *)domainArr cache:(BOOL)cache {
    [self addDomainsAndAllRefresh:domainArr cache:cache netChanged:NO];
}
- (void)addDomainsAndAllRefresh:(NSArray *)domainArr
                          cache:(BOOL)cache
                     netChanged:(BOOL)netChanged{
    
    NSLog(@"-------->全部重发");
    // 遍历现有的域名数组，如果已经在已经存在则不处理
    __block NSMutableArray *tempDnsIpServiceArr = [[NSMutableArray alloc] initWithArray:self.dnsIpServiceArr];
    
    __block BOOL isExist = NO;
    [domainArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        for (int i = 0; i<self.dnsIpServiceArr.count; i++) {
            ZHDNSIpService *service = (ZHDNSIpService *)self.dnsIpServiceArr[i];
            
            if ([obj isEqualToString:service.domain]) {
                isExist = YES;
                break;
            }
        }

        // 如果不存在这个域名 则将该域名加入到现有的域名列表中
        if (!isExist) {
            
            
            ZHDNSResolveItem *item = [[ZHDNSResolveItem alloc] init];
            item.domain = (NSString *)obj;
            ZHDNSIpService *service = [[ZHDNSIpService alloc] initWithResolveItem:item];
            /** 对于新增的域名，按照saveCache的值进行缓存*/
            service.saveCache = cache;
            [tempDnsIpServiceArr addObject:service];
        }
    }];
    
    self.dnsIpServiceArr = [[NSArray alloc] initWithArray:tempDnsIpServiceArr];
    // 对所有的域名进行重发
    for (ZHDNSIpService *ipService in self.dnsIpServiceArr) {
        // TODO ip地址合法性校验
        if (ipService.resolveStatus != DNSResolveStatus_Resolving) {
            if (netChanged) {
                ipService.isNetStatusChanged = YES;
            }
            [ipService resolve];
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (ZHDNSIpService *ser  in self.dnsIpServiceArr) {
            ZHDNSResolveItem *item = ser.resolveItemArr[0];
            
            NSLog(@"-------%@------->%@------ip个数%ld",ser.domain,item.ipAddr,ser.resolveItemArr.count);
            
        }
    });
}

- (NSString *)getIpUrlStrWithReallyUrlStr:(NSString *)reallyUrlStr requestUrlStr:(NSString *)requestUrlStr {
    NSString *resultStr = requestUrlStr;
    // 如果请求的url 地址不合法return nil
    if (!requestUrlStr || requestUrlStr.length == 0) return nil;
    NSString *ipAddr = [self getNextAvaiableIpAddressWithDomain:reallyUrlStr requestUrlStr:requestUrlStr];
    if (!ipAddr) {
        NSLog(@"----->没有找到可用的地址");
        // 进行重发
        [self addDomainAndRefresh:[NSArray arrayWithObjects:[[NSURL URLWithString:reallyUrlStr] host], nil]];
        return @"";
    }
    // 没有可用的ip地址
    if ([ipAddr isKindOfClass:[NSString class]] && [ipAddr length] == 0) {
        // 进行重发
        [self addDomainAndRefresh:[NSArray arrayWithObjects:[[NSURL URLWithString:reallyUrlStr] host], nil]];
        return @"";
    } else if ([ipAddr isKindOfClass:[NSString class]] && [ipAddr length] > 0) {
        NSString *originHost = [[NSURL URLWithString:requestUrlStr] host];
        requestUrlStr =  [requestUrlStr stringByReplacingOccurrencesOfString:originHost withString:ipAddr];
        return requestUrlStr;
    } else {
        return nil;
    }
    return resultStr;
}

/*!
 @method
 @abstract   设置dnsip失效
 @discussion  设置dnsip失效
 @param      reallyUrlStr 真实的请求地址   requestStr：当前请求地址
 */
- (void)setIpInvalidate:(NSString *)reallyUrlStr requestUrlStr:(NSString *)urlStr {
    if ([reallyUrlStr isKindOfClass:[NSString class]] && reallyUrlStr.length == 0) return;
    if ([urlStr isKindOfClass:[NSString class]] && urlStr.length == 0) return;
    // 如果当前实际请求的域名和原域名一样则不处理(这种情况说明走的是原始域名)
    if ([[[NSURL URLWithString:reallyUrlStr] host] isEqualToString:[[NSURL URLWithString:urlStr] host]]) return;
    // 防止遍历数组的时候数组被操作导致闪退
    NSArray *tempDnsIpService = [self.dnsIpServiceArr copy];
    for (ZHDNSIpService *service in tempDnsIpService) {
        if ([service.domain isEqualToString:[[NSURL URLWithString:reallyUrlStr] host]]) {
            for (int j = 0; j<service.resolveItemArr.count; j++) {
                ZHDNSResolveItem *item = service.resolveItemArr[j];
                if ([[[NSURL URLWithString:reallyUrlStr] host] isEqualToString:item.ipAddr]) {
                    item.resolveStatus = DNSResolveStatus_Failed;
                    NSLog(@"------>设置当前dnspod 地址失效 ip=%@",item.ipAddr);
                    break;
                }
            }
        }
        break;
    }
}

- (NSString *)getNextAvaiableIpAddressWithDomain:(NSString *)domain requestUrlStr:(NSString *)requestUrl {
    if (domain.length == 0 || requestUrl.length == 0 ) return nil;
    NSString *ipAddress = nil;
    NSArray *tempDnsIpServiceArr = [self.dnsIpServiceArr copy];
    for (ZHDNSIpService *service in tempDnsIpServiceArr) {
        if ([service.domain isEqualToString:[[NSURL URLWithString:domain] host]]) {
            NSArray *resolveItemArr = service.resolveItemArr;
            for (int i = 0; i<resolveItemArr.count; i++) {
                ipAddress = @"";
                ZHDNSResolveItem *item = resolveItemArr[i];
                // 如果解析完成且为有效的地址
                if (item.resolveStatus == DNSResolveStatus_Done) {
                    ipAddress = item.ipAddr;
                    break;
                } else {
                    //
                }
                NSLog(@"---------%@--%@--%d",item.domain,item.ipAddr,item.resolveStatus);
            }
        }
    }
    return ipAddress;
}

@end
