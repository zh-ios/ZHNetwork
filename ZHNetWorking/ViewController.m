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

#define kUserToken          @"02b504cc5d6d4666be41e40f8946e1d6"

@interface ViewController ()<ZHRequestDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
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
//        req.urlString = @"https://activity.app.autohome.com.cn/ugapi/api/guide/getNoticeRule";
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
    
    
    
    
    ZHRequest *postRe = [[ZHRequest alloc] init];
    postRe.urlString = downloadStr;
    postRe.delegate = self;
//    postRe.params = dic;
    
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(100, 300, 200, 40)];
    la.backgroundColor = [UIColor greenColor];
    [self.view addSubview:la];
    
    postRe.downloadProcess = ^(NSProgress *process) {
        NSLog(@"--------->%.2f",process.completedUnitCount/(process.totalUnitCount*1.0));
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            la.text = [NSString stringWithFormat:@"----%.2f",process.completedUnitCount/(process.totalUnitCount*1.0)];
        });

    };
    postRe.downloadPath = documentPath;
    postRe.requestType = ZHRequest_Type_GET;
    [postRe start];
    
    
//    http://120.25.226.186:32812/resources/videos/minion_01.mp4
    
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    textView.text = @"sdfasdfasdfasdfasd234123412341234123412341234123423sdfkajskdfaskdfjhaskdfasdkjfas;ldkfjasl;djfkalsdjfa;klsdjflasdjflasjdfl;kasdjfklasdjfasdhgkjlad;slfjasdlfkjaslkdfj";
    [self.view addSubview:textView];
    
    
    
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager ];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadStr]];
    
    
    
    NSURLSessionDownloadTask *task = [mgr downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            la.text = [NSString stringWithFormat:@"----%.2f",downloadProgress.completedUnitCount/(downloadProgress.totalUnitCount*1.0)];
        });
        NSLog(@"-------------------->>>");
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL URLWithString:@"11"];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"----");
    }];
    
//    [task resume];
}


- (void)requestFailed:(NSError *)error {
    
}

- (void)requestFinished:(ZHRequest *)request responseStr:(NSString *)responseStr {
    
}
- (void)requestWillStart {
    
}


@end
