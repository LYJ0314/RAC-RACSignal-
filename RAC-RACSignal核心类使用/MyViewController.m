
//
//  MyViewController.m
//  RAC-RACSignal核心类使用
//
//  Created by lyj on 17/7/28.
//  Copyright © 2017年 lyj. All rights reserved.
//

#import "MyViewController.h"

@interface MyViewController ()
@property (nonatomic, strong) UIButton *button;
@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor brownColor];
    self.title = @"myCtrl";
    [self buildUI];
    
    [self test5];
}
#pragma mark 叁
#pragma mark RACCommand -- 叁
// 2.使用场景:监听按钮点击，网络请求

#pragma mark 伍
// executing 监听事件有没有完成
- (void)test5
{
    RACCommand *command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        // block调用：执行命令的时候就会调用
        NSLog(@"%@======5",input);
        // 返回值不能为nil
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            // 发送数据
            [subscriber sendNext:@"执行命令产生的数据"];
            // 发送完成
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    // 监听事件有没有完成
    [command.executing subscribeNext:^(id x) {
        if ([x boolValue] == YES) {
            NSLog(@"当前正在执行%@",x);
        }else{
            NSLog(@"执行完成/没有执行");
        }
    }];
    
    // 执行命令
    [command execute:@5];
    
}

#pragma mark 肆
// switchToLatest 获取信号中信号发送的最新信号
- (void)test4
{
    // 创建信号中信号
    RACSubject *signalofsignals = [RACSubject subject];
    RACSubject *signalA = [RACSubject subject];
    [signalofsignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"%@===++",x);
    }];
    // 发送信号
    [signalofsignals sendNext:signalA];
    [signalA sendNext:@4];
}

// 一般做法
- (void)test2
{
    RACCommand *command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"%@=====",input);
        // 返回值不允许为nil
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"执行命令产生的数据"];
            return nil;
        }];
    }];
    
    // 必须是先订阅才能发送命令
    // executionSignals 信号源，信号中信号
    [command.executionSignals subscribeNext:^(id x) {
        [x subscribeNext:^(id x) {
            NSLog(@"====%@2",x);
        }];
    }];
    // 执行命令
    [command execute:@2];
}

// 高级做法
- (void)test3
{
    // 1.创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"%@======",input);
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"发送信号"];
            return nil;
        }];
    }];
    // switchToLatest 获取最新发送的信号，只能用于信号中的信号
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"%@====2",x);
    }];
    //执行命令
    [command execute:@3];
}

#pragma mark 贰
- (void)buildUI
{
    self.button.frame = CGRectMake(50, 100, 50, 30);
    self.button.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:self.button];
}
- (UIButton *)button
{
    if (!_button) {
        _button = [[UIButton alloc]init];
        [_button setBackgroundColor:[UIColor grayColor]];
        [_button setTitle:@"pop" forState:UIControlStateNormal];
        [[_button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [self.subject sendNext:@"ws"];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    return _button;
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
