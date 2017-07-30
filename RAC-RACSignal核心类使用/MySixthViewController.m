//
//  MySixthViewController.m
//  RAC-RACSignal核心类使用
//
//  Created by 李亚军 on 17/7/30.
//  Copyright © 2017年 lyj. All rights reserved.
//

#import "MySixthViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MySixthViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic,strong) RACSignal *signal;
@end

@implementation MySixthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"宏";
    
    
    
//    [self test];
//    [self test2];
    [self testAndTest2];
    [self test3];
    [self test4];
}
#pragma mark 宏
- (void)test
{
    // RAC ;把一个对象的某个属性绑定一个信号，只要发出信号，就会把信号的内容给对象的属性赋值
    // 给label 的text 属性绑定了文本框改变的信号
    
    RAC(self.label, text) = self.textField.rac_textSignal;
//    [self.textField.rac_textSignal subscribeNext:^(id x) {
//        self.label.text = x;
//    }];
    
}

#pragma mark KVO
/*
 RACObserveL:快速的监听某个对象的某个属性改变
 *  返回的是一个信号,对象的某个属性改变的信号
 */
- (void)test2

{
    [RACObserve(self.view, center) subscribeNext:^(id x) {
        NSLog(@"%@===",x);
    }];
}

- (void)testAndTest2
{
    RAC(self.label , text) = self.textField.rac_textSignal;
    [RACObserve(self.label, text) subscribeNext:^(id x) {
        NSLog(@"=====label的文字变化了");
    }];
}

// 循环引用问题
- (void)test3
{
    @weakify(self)
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        NSLog(@"%@22222222",self.view);
        return nil;
    }];
    _signal = signal;
}
// 元组
/*
    快速包装一个元组
    把包装的类型放在宏的参数里面，就会自动包装
 */
- (void)test4
{
    RACTuple *tuple = RACTuplePack(@1,@2,@3,@4);
    // 宏的参数类型要和元组中元素类型一致，右边为要解析的元组。
    RACTupleUnpack(NSNumber *num1, NSNumber *num2, NSNumber *num3,NSNumber *num4) = tuple; // 元组
    
    // 快速包装一个元组
    // 把包装的类型放在宏的参数里面，就会自动包装
    NSLog(@"%@   %@    %@   %@",num1, num2, num3, num4);
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
