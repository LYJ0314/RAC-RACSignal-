//
//  MyThirdViewController.m
//  RAC-RACSignal核心类使用
//
//  Created by 李亚军 on 17/7/29.
//  Copyright © 2017年 lyj. All rights reserved.
/**
      Map使用步骤:
      1.传入一个block,类型是返回对象，参数是value
      2.value就是源信号的内容，直接拿到源信号的内容做处理
      3.把处理好的内容，直接返回就好了，不用包装成信号，返回的值，就是映射的值。
     
      Map底层实现:
      0.Map底层其实是调用flatternMap,Map中block中的返回的值会作为flatternMap中block中的值。
      1.当订阅绑定信号，就会生成bindBlock。
      3.当源信号发送内容，就会调用bindBlock(value, *stop)
      4.调用bindBlock，内部就会调用flattenMap的block
      5.flattenMap的block内部会调用Map中的block，把Map中的block返回的内容包装成返回的信号。
      5.返回的信号最终会作为bindBlock中的返回信号，当做bindBlock的返回信号。
      6.订阅bindBlock的返回信号，就会拿到绑定信号的订阅者，把处理完成的信号内容发送出来。
 */

#import "MyThirdViewController.h"
#import "RACReturnSignal.h"

@interface MyThirdViewController ()

@end

@implementation MyThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"thirdVC";
    
    [self map];
    [self flatMap];
    [self flattenMap2];
}

- (void)map
{
    // map作用：把源信号的值映射成一个新的值
    // 创建信号
    RACSubject *subject = [RACSubject subject];
    // 绑定信号
    RACSignal *bindSiganl = [subject map:^id(id value) {
        // 返回的类型就是你需要映射的值
        // 这里将源信号发送的“123” 前面拼接了ws
        return [NSString stringWithFormat:@"ws:%@",value];
    }];
    // 订阅绑定了信号
    [bindSiganl subscribeNext:^(id x) {
        NSLog(@"---%@",x);
    }];
    // 发送信号
    [subject sendNext:@"123"];
    
}
/*
     FlatternMap和Map的区别
     
     1.FlatternMap中的Block返回信号。
     2.Map中的Block返回对象。
     3.开发中，如果信号发出的值不是信号，映射一般使用Map
     4.开发中，如果信号发出的值是信号，映射一般使用FlatternMap。
 */
- (void)flatMap
{
    // 创建信号
    RACSubject *subject = [RACSubject subject];
    // 绑定信号
    RACSignal *bindSignal = [subject flattenMap:^RACStream *(id value) {
        // block: 只要源信号发送内容就会调用
        // value：就是源信号发送的内容
        // 返回信号用来包装成修改内容的值
        return [RACReturnSignal return: value];
    }];
    
    
    // flattenMap 中返回的是什么信号，订阅的就是什么信号（那么，x的值等于value的值，如果操作value的值那么x也会随之改变）
    // 订阅信号
    [bindSignal subscribeNext:^(id x) {
        NSLog(@"----%@",x);
    }];
    // 发送数据
    [subject sendNext:@"123"];
}

- (void)flattenMap2
{
    // flattenMap 主要用于信号中的信号
    //signalOfsignals用FlatternMap
    RACSubject *signalofSignals = [RACSubject subject];
    RACSubject *signal = [RACSubject subject];
    
    [[signalofSignals flattenMap:^RACStream *(id value) {
        return value;
    }] subscribeNext:^(id x) {
        // subscribeNext：调用bind 的@autoreleasepool{  } 会将subscribeNext：生成的subscriber 保存到RACSubject中
        NSLog(@"----%@",x);
    }];
    
    // 发送信号
    [signalofSignals sendNext:signal];
    [signal sendNext:@"1234"];
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
