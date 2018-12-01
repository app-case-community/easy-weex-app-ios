//
//  WeexKit.m
//  Pods-easy-weex
//
//  Created by zhu zhe on 2018/11/26.
//

#import "WeexKit.h"
#import <WeexSDK/WeexSDK.h>
#import "WXStreamModule.h"
#import "WXEventModule.h"
#import "WXImgLoaderDefaultImpl.h"
#import "WXConfigCenterDefaultImpl.h"
#import "WXNavigationHandlerImpl.h"
#import "WXSyncTestModule.h"

#import "WXWeb.h"

#import <BindingX/EBWXModule.h>
#import <BindingX/EBWXOldModule.h>

#import <WeexGcanvas/WXGCanvasComponent.h>
#import <WeexGcanvas/WXGCanvasModule.h>

#import "WXLottieComponent.h"

@implementation WeexKit

+(void)initWeex {
    [WXAppConfiguration setAppGroup:@"AliApp"];
    [WXAppConfiguration setAppName:@"WeexDemo"];
    [WXAppConfiguration setExternalUserAgent:@"ExternalUA"];
    
    [WXSDKEngine initSDKEnvironment];
    
    [WXSDKEngine registerHandler:[WXImgLoaderDefaultImpl new] withProtocol:@protocol(WXImgLoaderProtocol)];
    [WXSDKEngine registerHandler:[WXEventModule new] withProtocol:@protocol(WXEventModuleProtocol)];
    [WXSDKEngine registerHandler:[WXConfigCenterDefaultImpl new] withProtocol:@protocol(WXConfigCenterProtocol)];
    [WXSDKEngine registerHandler:[WXNavigationHandlerImpl new] withProtocol:@protocol(WXNavigationProtocol)];
    
    [WXSDKEngine registerComponent:@"web" withClass:[WXWeb class]];
    
    [WXSDKEngine registerComponent:@"select" withClass:NSClassFromString(@"WXSelectComponent")];
    [WXSDKEngine registerModule:@"event" withClass:[WXEventModule class]];
    [WXSDKEngine registerModule:@"syncTest" withClass:[WXSyncTestModule class]];
    [WXSDKEngine registerModule:@"titleBar" withClass:NSClassFromString(@"WXTitleBarModule")];
    
    [WXSDKEngine registerModule:@"bindingx" withClass:[EBWXModule class]];
    [WXSDKEngine registerModule:@"binding" withClass:[EBWXModule class]];
    [WXSDKEngine registerModule:@"expressionBinding" withClass:[EBWXOldModule class]];

    [WXSDKEngine registerComponent:@"gcanvas" withClass:[WXGCanvasComponent class]];
    [WXSDKEngine registerModule:@"gcanvas" withClass:[WXGCanvasModule class]];
    
    [WXSDKEngine registerComponent:@"lottie" withClass:[WXLottieComponent class]];
}

@end
