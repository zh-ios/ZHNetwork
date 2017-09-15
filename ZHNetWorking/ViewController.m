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
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
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

    
//    NSDictionary *dic = @{@"acount" : @"18809876543", @"password" : @"123456"};
//    NSString *urlStr = @"http://ebook.huakeyihui.com:8080/pod/mobile/user/login";
//    
//    ZHRequest *postRe = [[ZHRequest alloc] init];
//    postRe.urlString = urlStr;
//    postRe.params = dic;
//    postRe.requestType = ZHRequest_Type_POST;
//    [postRe start];

    for (int i= 1; i<2; i++) {
        ZHRequest *req = [[ZHRequest alloc] init];
        req.timeoutInterval = 20;
        req.requestType = ZHRequest_Type_GET;
        req.urlString = @"https://activity.app.autohome.com.cn/ugapi/api/guide/getNoticeRule";
        req.priority = ZHRequest_Priority_Low;
        if (i % 5 ==0) {
            req.priority = ZHRequest_Priority_High;
        }
        
        
        [req start];
        
        [req start];
    }
    
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    textView.text = @"sdfasdfasdfasdfasd234123412341234123412341234123423sdfkajskdfaskdfjhaskdfasdkjfas;ldkfjasl;djfkalsdjfa;klsdjflasdjflasjdfl;kasdjfklasdjfasdhgkjlad;slfjasdlfkjaslkdfj";
    [self.view addSubview:textView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
