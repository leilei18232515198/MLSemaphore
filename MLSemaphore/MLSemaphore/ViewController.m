//
//  ViewController.m
//  MLSemaphore
//
//  Created by 268Edu on 2018/9/7.
//  Copyright © 2018年 QRScan. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>
//此demo的用法，如果有两个接口A、B，我们如果先调用A接口获取数据然后再根据接口调用B接口的数据
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
//    接口A
    NSBlockOperation * operation1 = [NSBlockOperation blockOperationWithBlock:^{
        [self request1];
    }];
//   接口B
    NSBlockOperation * operation2 = [NSBlockOperation blockOperationWithBlock:^{
        [self request2];
    }];
//    接口B与接口A产生依赖关系（先调用A接口在调用B接口）
    [operation2 addDependency:operation1];
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    [queue addOperations:@[operation1,operation2] waitUntilFinished:NO];
}

- (void)request1{
    
//    添加信号量(信号量为)
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);//可以设置同时并发的个数
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setTimeoutInterval:10.f];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    NSDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@(471) forKey:@"userId"];
    
    [manager POST:@"http://sns.psyheart.org/app/group/whetherJoinGroupByUserId" parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_semaphore_signal(sema);
    }
    failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
//        增加信号量信号量+1
         dispatch_semaphore_signal(sema);
          }];
//    等待知道信号量大于0的时候进行下一个操作
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}


- (void)request2{
    
}


@end
