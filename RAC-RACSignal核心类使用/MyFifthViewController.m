//
//  MyFifthViewController.m
//  RAC-RACSignal核心类使用
//
//  Created by 李亚军 on 17/7/30.
//  Copyright © 2017年 lyj. All rights reserved.
//

#import "MyFifthViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MyFifthViewController ()
@property (weak, nonatomic) IBOutlet UITextField *accountField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation MyFifthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"合并";
    
    [self combineLatest];
    [self zipWith];
    [self merge];
    [self then];
    [self concat];
}

// 把多个信号聚合成你想要的信号，使用场景------：比如当输入框都有值的时候按钮才可以点击。
// 思路：就是把输入框输入的值的信号都聚合成按钮是否能点击的信号。
- (void)combineLatest
{
    RACSignal *combinSignal = [RACSignal combineLatest:@[self.accountField.rac_textSignal,self.pwdField.rac_textSignal] reduce:^id(NSString *account,NSString *pwd){
        
        NSLog(@"%@ -- %@",account,pwd);
        return @(account.length && pwd.length);
    }];
    // 订阅信号
//    [combinSignal subscribeNext:^(id x) {
//        self.loginBtn.enabled = [x boolValue];
//    }];
    // 简写
    RAC(self.loginBtn, enabled) = combinSignal;
}

- (void)zipWith
{
    // zipWith : 把两个信号压缩成一个信号，只有当两个信号同时发出信号内容时，并且把两个信号的内容合并成一个元组，才会触发压缩流的next事件。
    // 创建信号A
    RACSubject *signalA = [RACSubject subject];
    RACSubject *signalB = [RACSubject subject];
    // 压缩成一个信号
    // ** zipWith ** : 当一个界面多个请求的时候，要等到所有请求完成才能更新UI
    // 等所有信号都发送内容的时候才会调用
    RACSignal *zipSignal = [signalA zipWith:signalB];
    [zipSignal subscribeNext:^(id x) {
        NSLog(@"%@ =====",x); // 所有的值都会被包装成了元组
    }];
    // 发送信号  交互顺序 ，元组内元素的顺序不会变，跟发送的顺序无关，而是跟压缩的顺序有关
    // [signalA zipWith:signalB] --------先是压缩A 后是B
    [signalA sendNext:@1];
    [signalB sendNext:@2];
}

// 任何一个信号请求完成都会被订阅到
// merge：多个信号合并成一个信号，任何一个信号有新值都会调用
- (void)merge
{
    RACSubject *signalA = [RACSubject subject];
    RACSubject *signalB = [RACSubject subject];
    RACSignal *mergeSignal = [signalA merge:signalB];
    // 订阅信号
    [mergeSignal subscribeNext:^(id x) {
        NSLog(@"%@=====+++",x);
    }];
    // 发送信号 --- 交换位置则数据结果也会交换
    [signalA sendNext:@"上部分"];
    [signalB sendNext:@"下部分"];
    [signalA sendNext:@"上xia部分"];

}
// then ----使用需求：有两部分数据：想让上部分先进行网络请求但是过滤掉数据，然后进行下部分的，拿到下部分数据
- (void)then
{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"----发送上部分请求");
        
        [subscriber sendNext:@"上部分数据"];
        [subscriber sendCompleted];// 必须调用sendCompleted方法
        return  nil;
    }];
    
    // 创建信号B
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"--发送下部分请求");
        [subscriber sendNext:@"发送下部分请求-----"];
        [subscriber sendCompleted];
        return  nil;
    }];
    // 创建组合信号
    // then : 忽略掉第一个信号的所有值
    
    RACSignal *thenSignal = [signalA then:^RACSignal *{
        // 返回的信号就是要组合的信号
        return signalB;
    }];
    // 订阅信号
    [thenSignal subscribeNext:^(id x) {
        NSLog(@"=====%@",x);
    }];
}

// concat ---使用需求：有两部分数据：想让上部分先执行，完啦了之后再让下部分执行（都可获取值）
- (void)concat
{
    // 组合
    // 创建信号
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"上部分数据"];
        [subscriber sendCompleted]; // 必须调用
        return  nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"下部分数据"];
//        [subscriber sendCompleted];
        return nil;
    }];
    
    // concat : 按顺序去链接
    // 注意：concat,第一个信号必须要调用 sendCompleted
    // 创建组合信号
    RACSignal *concatSignal = [signalA concat:signalB];
    // 订阅组合信号
    [concatSignal subscribeNext:^(id x) {
        NSLog(@"~~~~~~~%@",x);
    }];
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
