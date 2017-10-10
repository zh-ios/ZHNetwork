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

- (void)getAllDomain {
    
    ZHRequest *domainRequest = [[ZHRequest alloc] init];
    domainRequest.requestType = ZHRequest_Type_GET;
    domainRequest.urlString = @"https://comm.app.autohome.com.cn/comm_v1.0.0/ashx/getappdomainname.json";
    domainRequest.delegate = self;
    [[ZHRequestManager sharedManager] addRequest:domainRequest];
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

- (void)addDomainsAndAllRefresh:(NSArray *)domainArr cache:(BOOL)cache {
    [self addDomainsAndAllRefresh:domainArr cache:cache netChanged:NO];
}
- (void)addDomainsAndAllRefresh:(NSArray *)domainArr
                          cache:(BOOL)cache
                     netChanged:(BOOL)netChanged{
    
    // 遍历现有的域名数组，如果已经在已经存在则不处理
    __block NSMutableArray *tempDnsIpServiceArr = [[NSMutableArray alloc] initWithArray:self.dnsIpServiceArr];
    
    __block BOOL isExist = NO;
    [domainArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        for (int i = 0; i<self.dnsIpServiceArr.count; i++) {
            ZHDNSIpService *service = (ZHDNSIpService *)self.dnsIpServiceArr[i];
            
            if ([obj isEqualToString:service.item.domain]) {
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
        if (ipService.item.resolveStatus != DNSResolveStatus_Resolving) {
            if (netChanged) {
                ipService.isNetStatusChanged = YES;
            }
            [ipService resolve];
        }
    }
}
@end
