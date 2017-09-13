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

    ZHRequest *req = [[ZHRequest alloc] init];
    req.timeoutInterval = 20;
    req.requestType = ZHRequest_Type_GET;
    req.requestSerializerType = ZHRequest_RequestSerializerType_JSON;
    req.urlString = @"https://activity.app.autohome.com.cn/ugapi/api/guide/getNoticeRule";
    
    [[ZHRequestManager sharedManager] addRequest:req];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
