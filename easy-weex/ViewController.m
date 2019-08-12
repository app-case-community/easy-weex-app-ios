//
//  ViewController.m
//  easy-weex
//
//  Created by zhu zhe on 2018/11/26.
//  Copyright © 2018 flyme. All rights reserved.
//

#import "ViewController.h"
#import <WeexKit/WXScannerVC.h>
#import <WeexKit/WXDemoViewController.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.urlField.text = @"https://snice.oss-cn-hangzhou.aliyuncs.com/dist/weex/js/index.js";
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)openScan:(id)sender {
    [self.navigationController pushViewController:[WXScannerVC new] animated:YES];
//    WXDemoViewController * controller = [[WXDemoViewController alloc] init];
//    controller.url = [NSURL URLWithString:@"http://oss.zhuzhe.wang/dist/weex/js/index.js"];
//    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)jumpWeex:(id)sender {
    if ([@"" isEqualToString:self.urlField.text]) {
        NSLog(@"请输入");
        return;
    }
    WXDemoViewController * controller = [[WXDemoViewController alloc] init];
    controller.url = [NSURL URLWithString:self.urlField.text];
    [self.navigationController pushViewController:controller animated:YES];
    
}


@end
