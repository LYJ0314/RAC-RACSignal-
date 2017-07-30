//
//  MySecondViewController.m
//  RAC-RACSignal核心类使用
//
//  Created by lyj on 17/7/28.
//  Copyright © 2017年 lyj. All rights reserved.
/**
     RACMulticastConnection使用步骤:
     1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
     2.创建连接 RACMulticastConnection *connect = [signal publish];
     3.订阅信号,注意：订阅的不在是之前的信号，而是连接的信号。 [connect.signal subscribeNext:nextBlock]
     4.连接 [connect connect]
 
     RACMulticastConnection底层原理:
     1.创建connect，connect.sourceSignal -> RACSignal(原始信号)  connect.signal -> RACSubject
     2.订阅connect.signal，会调用RACSubject的subscribeNext，创建订阅者，而且把订阅者保存起来，不会执行block。
     3.[connect connect]内部会订阅RACSignal(原始信号)，并且订阅者是RACSubject
     3.1.订阅原始信号，就会调用原始信号中的didSubscribe
     3.2 didSubscribe，拿到订阅者调用sendNext，其实是调用RACSubject的sendNext
     4.RACSubject的sendNext,会遍历RACSubject所有订阅者发送信号。
     4.1 因为刚刚第二步，都是在订阅RACSubject，因此会拿到第二步所有的订阅者，调用他们的nextBlock
*/

#import "MySecondViewController.h"

@interface MySecondViewController ()

@end

@implementation MySecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"mySecond";
    [self test2];
}
#pragma mark 普通写法
// 缺点：每订阅一次信号就得重新创建并发送请求，这样很不好
- (void)test1
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送请求");
        [subscriber sendNext:@"wa"];
        return nil;
    }];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@-------1",x);
    }];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@-------2",x);
    }];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@-------3",x);
    }];
}
#pragma mark 改进法
//  使用RACMulticastConnection，无论有多少个订阅者，无论订阅多少次，只发送一次
- (void)test2
{
    // 1.发送请求，用一个信号内包装，不管有多少个订阅者，只发一次请求
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"发送请求啦");
        // 发送信号
        [subscriber sendNext:@"ws"];
        return nil;
    }];
    // 2.创建连接类
    RACMulticastConnection *connection = [signal publish];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"%@====1",x);
    }];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"%@=====2",x);
    }];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"%@====3",x);
    }];
    // 3.链接，只有链接了才会把信号源变为热信号
    [connection connect];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
