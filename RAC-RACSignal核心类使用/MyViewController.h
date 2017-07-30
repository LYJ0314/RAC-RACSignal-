//
//  MyViewController.h
//  RAC-RACSignal核心类使用
//
//  Created by lyj on 17/7/28.
//  Copyright © 2017年 lyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MyViewController : UIViewController
@property (nonatomic, strong) RACSubject *subject;

@end
