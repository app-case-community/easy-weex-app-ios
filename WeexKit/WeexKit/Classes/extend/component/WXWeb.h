//
//  WXWeb.h
//  BindingX
//
//  Created by zhu zhe on 2018/12/1.
//

#import <WeexSDK/WXComponent.h>

@interface WXWeb : WXComponent<UIWebViewDelegate>

- (void)notifyWebview:(NSDictionary *) data;

- (void)postMessage:(NSDictionary *) data;

- (void)reload;

- (void)goBack;

- (void)goForward;

@end

