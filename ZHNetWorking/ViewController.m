//
//  ViewController.m
//  ZHNetWorking
//
//  Created by autohome on 2017/8/2.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import "ViewController.h"
#import "ZHRequest.h"
#import "ZHRequestManager.h"

#import "AFNetworking.h"
#import "ZHBatchRequest.h"
#import "ZHDNSHttpManager.h"

#import "ZHNetworkingManager.h"
#import "ZHTamperConfig.h"
#define kUserToken          @"02b504cc5d6d4666be41e40f8946e1d6"

@interface ViewController ()<ZHRequestDelegate,ZHBatchRequestDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *localpushurl = @"https://activity.app.autohome.com.cn/ugapi/api/localpush/getLocalPush?deviceid=sssssssssaas1sss3123sdfasssssdfasdf&flag=0&userid=0&version=8.5.1";
    
    ZHTamperConfig *config = [ZHTamperConfig sharedConfig] ;
    config.enableHttpDns = YES;
    
                        
                              
    ZHNetworkingManager *netmanager = [ZHNetworkingManager sharedManager];


    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *str = [netmanager getIpUrlStrWithReallyUrlStr:localpushurl requestUrlStr:localpushurl];
        NSLog(@"++++++++++++++++++++>%@",str);
        ZHRequest *req = [[ZHRequest alloc] init];
        req.requestUrlStr = localpushurl;
        [req start];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *str = [netmanager getIpUrlStrWithReallyUrlStr:localpushurl requestUrlStr:localpushurl];
        NSLog(@"++++++++++++++++++++>%@",str);
        ZHRequest *req = [[ZHRequest alloc] init];
        req.requestUrlStr = localpushurl;
        [req start];
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *str = [netmanager getIpUrlStrWithReallyUrlStr:localpushurl requestUrlStr:localpushurl];
        NSLog(@"++++++++++++++++++++>%@",str);
        ZHRequest *req = [[ZHRequest alloc] init];
        req.requestUrlStr = localpushurl;
        [req start];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *str = [netmanager getIpUrlStrWithReallyUrlStr:localpushurl requestUrlStr:localpushurl];
        NSLog(@"++++++++++++++++++++>%@",str);
        ZHRequest *req = [[ZHRequest alloc] init];
        req.requestUrlStr = localpushurl;
        [req start];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *str = [netmanager getIpUrlStrWithReallyUrlStr:localpushurl requestUrlStr:localpushurl];
        NSLog(@"++++++++++++++++++++>%@",str);
        ZHRequest *req = [[ZHRequest alloc] init];
        req.requestUrlStr = localpushurl;
        [req start];
    });

        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *str = [netmanager getIpUrlStrWithReallyUrlStr:localpushurl requestUrlStr:localpushurl];
            NSLog(@"++++++++++++++++++++>%@",str);
            ZHRequest *req = [[ZHRequest alloc] init];
            req.delegate = self;
            req.requestUrlStr = localpushurl;
            [req start];
            
            
            
        });

    
// get 请求
//    NSDictionary * dic = @{
//                 @"app" : @1,
//                 @"deviceid" : @"18896d567674dbd24457a8ecb483cd5c5695667d",
//                 @"did" : @"18896d567674dbd24457a8ecb483cd5c5695667d",
//                 @"ia" : @"ACF16DCD-307E-487B-AD40-6A37AB9BA2EB",
//                 @"m" : @"",
//                 @"platform" : @1,
//                 @"r" : @35763,
//                 @"version" : @"8.4.5",
//    } ;
//
//    
//    NSString *urlStr = [NSString stringWithFormat:@"%@mobile/newstartup.ashx",[NSString stringWithFormat:@"https://mobilenc.app.autohome.com.cn/mobile_v%@/",@"7.6.0"]];

//    for (int i= 1; i<2; i++) {
//        ZHRequest *req = [[ZHRequest alloc] init];
//        req.timeoutInterval = 20;
//        req.requestType = ZHRequest_Type_POST;
//        req.requestUrlStr = @"https://activity.app.autohome.com.cn/ugapi/api/guide/getNoticeRule";
//        req.priority = ZHRequest_Priority_Low;
//        if (i % 5 ==0) {
//            req.priority = ZHRequest_Priority_High;
//        }
//    req.delegate = self;
//        [req start];
//    }
    
    
    UIImage *imgData = [UIImage imageNamed:@"user_growth_gift"];
    
    NSMutableDictionary * dic =[NSMutableDictionary dictionaryWithCapacity:7];
    [dic setValue:kUserToken forKey:@"userId"];
    [dic setValue:UIImagePNGRepresentation(imgData) forKey:@"file"];
    
    [dic setValue:@"lisi" forKey:@"nickname"];
    
    
    NSString *urlStr =  @"http://ebook.huakeyihui.com:8080/pod/mobile/user/uploadHead";
    
    
    
    // post 请求登录
//    NSDictionary *dic = @{@"acount" : @"18809876543", @"password" : @"123456"};
//    NSString *urlStr = @"http://ebook.huakeyihui.com:8080/pod/mobile/user/login";

    
    NSString *downloadStr = @"http://120.25.226.186:32812/resources/videos/minion_01.mp4";
    
// 下载url
//    http://120.25.226.186:32812/resources/videos/minion_01.mp4
 
    [self batchRequest];
}


- (void)batchRequest {
    NSString *downloadStr = @"http://120.25.226.186:32812/resources/videos/minion_01.mp4";
    ZHRequest *postRe = [[ZHRequest alloc] init];
    postRe.requestUrlStr = downloadStr;
    postRe.delegate = self;

    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    postRe.downloadPath = documentPath;
    postRe.requestType = ZHRequest_Type_GET;
    
    ZHRequest *postRe1 = [[ZHRequest alloc] init];
    postRe1.requestUrlStr = downloadStr;
    postRe1.delegate = self;
    
    postRe1.downloadPath = documentPath;
    postRe1.requestType = ZHRequest_Type_GET;
    
    ZHBatchRequest *batchRE = [[ZHBatchRequest alloc] initWithRequestArray:@[postRe,postRe1]];
    
    postRe1.delegate = self;
    postRe.delegate = self;
    
    batchRE.delegate = self;
    
    postRe.downloadProcess = ^(NSProgress *process) {
        NSLog(@"--------->%.2f",process.completedUnitCount/(process.totalUnitCount*1.0));
    };
    postRe1.downloadProcess = ^(NSProgress *process) {
        NSLog(@"--------->%.2f",process.completedUnitCount/(process.totalUnitCount*1.0));
    };
    
    
    
    [batchRE start];
    
    
    
    
}


- (void)requestFailed:(NSError *)error {
    
}

- (void)requestFinished:(ZHRequest *)request responseStr:(NSString *)responseStr {
    
}
- (void)requestWillStart {
    
}


- (void)batchRequestFinished:(ZHBatchRequest *)batchRequest {
    
}
- (void)batchRequestFailed:(ZHBatchRequest *)batchRequest {
    
}
- (void)batchRequestWillStart:(ZHBatchRequest *)batchRequest {
    
}


@end
