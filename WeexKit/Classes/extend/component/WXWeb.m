//
//  WXWeb.m
//  BindingX
//
//  Created by zhu zhe on 2018/12/1.
//

#import "WXWeb.h"

@implementation WXWeb

-(UIView *)loadView {
    UIView *view = [super loadView];
    if ([view isKindOfClass:[UIWebView class]]) {
        UIWebView* m_webView = (UIWebView*)view;
        m_webView.scrollView.bounces = NO;
        m_webView.scrollView.scrollEnabled = NO;
    }
    return view;
}

@end
