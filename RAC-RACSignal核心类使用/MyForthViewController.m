//
//  MyForthViewController.m
//  RAC-RACSignal核心类使用
//
//  Created by 李亚军 on 17/7/30.
//  Copyright © 2017年 lyj. All rights reserved.
//

#import "MyForthViewController.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MyForthViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation MyForthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"过滤";
    // Do any additional setup after loading the view.
    
    [self skip];
    [self distinctUntilChanged];
    [self take];
    [self takeLast];
    [self takeUntil];
    [self ignore];
    [self fliter];
}

- (void)skip
{
    RACSubject *subject = [RACSubject subject];
    [[subject skip:2] subscribeNext:^(id x) {
        NSLog(@"%@=====",x);
    }];
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
}

// distinctUntilChanged ：当前的值跟上次的值一样，就不会被订阅到
- (void)distinctUntilChanged
{
    RACSubject *subject = [RACSubject subject];
    [[subject distinctUntilChanged] subscribeNext:^(id x) {
        NSLog(@"----%@",x);
    }];
    
    // 发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    
    [subject sendNext:@2];// 不会被订阅
}
// take : 可以屏蔽一些值，取前面几个值，======这里take 为2 ，只拿到前两个值
- (void)take
{
    RACSubject *subject = [RACSubject subject];
    [[subject take:2] subscribeNext:^(id x) {
        NSLog(@"%@  ****",x);
    }];
    
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
}
// takeLast : 和 take 的用法一样，不过他取的是最后几个值
// 注意：takeLast 一定要调用sendCompleted ，告诉他发送完成了，这样才能去到最后几个值
- (void)takeLast
{
    RACSubject *subject = [RACSubject subject];
    [[subject takeLast:2] subscribeNext:^(id x) {
        NSLog(@"&&&&& %@",x);
    }];
    
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
    [subject sendCompleted];
}
// takeUntil: ---给takeUntil 传的是哪个信号，那么当这个信号发送信号或者 sendCompleted，就不能再接受源信号的内容了
- (void)takeUntil
{
    RACSubject *subject = [RACSubject subject];
    RACSubject *subject2 = [RACSubject subject];
    
    [[subject takeUntil:subject2] subscribeNext:^(id x) {
        NSLog(@"%@$$$$",x);
    }];
    
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject2 sendNext:@3];
    [subject2 sendNext:@4];
    [subject2 sendCompleted];
    [subject sendNext:@5];
}
// ignore 忽略掉一些值
- (void)ignore
{
    // ignore 忽略掉一些值
    // ignoreValues 表示忽略所有的值
    
    RACSubject *subject = [RACSubject subject];
    RACSignal *ignoreSignal = [subject ignore:@2];
    
    [ignoreSignal subscribeNext:^(id x) {
        NSLog(@"#####%@",x);
    }];
    [subject sendNext:@2];
    [subject sendNext:@3];
}
// 一般和文本框一起 ，添加过滤条件
- (void)fliter
{
    // 只有当文本框的内容长度大于5，才能获取文本框里的内容
    [[self.textField.rac_textSignal filter:^BOOL(id value) {
        // value 源信号的内容
        return [value length] > 5;
        // 返回值就是过滤条件。只有当满足这个条件才能获取到内容
    }] subscribeNext:^(id x) {
        NSLog(@"!!!!!%@",x);
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
