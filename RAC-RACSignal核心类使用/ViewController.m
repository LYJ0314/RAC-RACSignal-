//
//  ViewController.m
//  RAC-RACSignal核心类使用
//
//  Created by lyj on 17/7/28.
//  Copyright © 2017年 lyj. All rights reserved.


#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "MyViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"rootVC";
    [self myRACSubject];
    
}

#pragma mark RACSubject -- 贰
// 使用场景:通常用来代替代理，有了它，就不必要定义代理了。
/**
     RACSubject和RACReplaySubject的区别
     RACSubject必须要先订阅信号之后才能发送信号，而RACReplaySubject可以先发送信号后订阅.
     RACSubject 代码中体现为：先走TwoViewController的sendNext，后走ViewController的subscribeNext订阅
     RACReplaySubject 代码中体现为：先走ViewController的subscribeNext订阅，后走TwoViewController的sendNext
     可按实际情况各取所需
 */
- (void)myRACSubject
{
    self.button.frame = CGRectMake(100, 100, 80, 30);
    [self.view addSubview:self.button];
    
}
- (UIButton *)button
{
    if (!_button) {
        _button = [[UIButton alloc]init];
        [_button setBackgroundColor:[UIColor redColor]];
        [_button setTitle:@"push" forState:UIControlStateNormal];
        [[_button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            MyViewController *myVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MyViewController"];
            
            myVC.subject = [RACSubject subject];
            [myVC.subject subscribeNext:^(id x) {
                [self.button setTitle:x forState:UIControlStateNormal];
            }];
            [self.navigationController pushViewController:myVC animated:YES];
        }];
    }
    return _button;
}
#pragma mark RACSignal  -- 壹
- (void)myRACSignal
{
    /**
     RACSignal底层实现：
     1.创建信号，首先把didSubscribe保存到信号中，还不会触发。
     2.当信号被订阅，也就是调用signal的subscribeNext:nextBlock
     2.2 subscribeNext内部会创建订阅者subscriber，并且把nextBlock保存到subscriber中。
     2.1 subscribeNext内部会调用siganl的didSubscribe
     3.siganl的didSubscribe中调用[subscriber sendNext:@1];
     3.1 sendNext底层其实就是执行subscriber的nextBlock
     */
    
    // 创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        
        // block调用时刻：每当有订阅者订阅信号，就会调用block。
        // 发送信号
        [subscriber sendNext:@"ws"];
        // 如果不在发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅信号。
        [subscriber sendCompleted];
        
        // 取消信号，如果信号想要被取消，就必须返回一个RACDisposable
        // 信号什么时候被取消：1.自动取消，当一个信号的订阅者被销毁的时候机会自动取消订阅，2.手动取消，
        //block什么时候调用：一旦一个信号被取消订阅就会调用
        //block作用：当信号被取消时用于清空一些资源
        return [RACDisposable disposableWithBlock:^{
            
            // block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。
            
            // 执行完Block后，当前信号就不在被订阅了。
            NSLog(@"取消订阅");
        }];
    }];
    
    
    
    // 2. 订阅信号
    //subscribeNext
    // 把nextBlock保存到订阅者里面
    // 只要订阅信号就会返回一个取消订阅信号的类
    RACDisposable *disposable = [signal subscribeNext:^(id x) {
        
        // block调用时刻：每当有信号发出数据，就会调用block.
        NSLog(@"接收到数据:%@",x);
    }];
    // 取消订阅
    [disposable dispose];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
