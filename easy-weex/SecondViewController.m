//
//  SecondViewController.m
//  easy-weex
//
//  Created by zhu zhe on 2018/12/4.
//  Copyright © 2018 flyme. All rights reserved.
//

#import "SecondViewController.h"
#import "Router.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

ROUTER_PATH(SCHEMA_EASY, ROUTE_PATH_SECOND)

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"second";
    NSLog(@"second %@", self.params);
}

@end
