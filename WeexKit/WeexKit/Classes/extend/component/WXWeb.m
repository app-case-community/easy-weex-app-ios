//
//  WXWeb.m
//  BindingX
//
//  Created by zhu zhe on 2018/12/1.
//

#import "WXWeb.h"

#import <WeexSDK/WXUtility.h>
#import <WeexSDK/WXHandlerFactory.h>
#import <WeexSDK/WXURLRewriteProtocol.h>
#import <WeexSDK/WXSDKEngine.h>
#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface WXWebView : UIWebView

@end

@implementation WXWebView

- (void)dealloc
{
    if (self) { //!OCLint
        //        self.delegate = nil;
    }
}

@end

@interface WXWeb ()

@property (nonatomic, strong) JSContext *jsContext;

@property (nonatomic, strong) WXWebView *webview;

@property (nonatomic, strong) NSString *url;

@property (nonatomic, strong) NSString *source;

// save source during this initialization
@property (nonatomic, strong) NSString *inInitsource;

@property (nonatomic, assign) BOOL startLoadEvent;

@property (nonatomic, assign) BOOL finishLoadEvent;

@property (nonatomic, assign) BOOL failLoadEvent;

@property (nonatomic, assign) BOOL notifyEvent;

@end

@implementation WXWeb

WX_EXPORT_METHOD(@selector(postMessage:))
WX_EXPORT_METHOD(@selector(goBack))
WX_EXPORT_METHOD(@selector(reload))
WX_EXPORT_METHOD(@selector(goForward))

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    if (self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance]) {
        self.url = attributes[@"src"];
        
        if(attributes[@"source"]){
            self.inInitsource = attributes[@"source"];
        }
        
    }
    return self;
}

- (UIView *)loadView
{
    WXWebView *view = [[WXWebView alloc] init];
    view.scrollView.bounces = NO;
    view.scrollView.scrollEnabled = NO;
    return view;
}

- (void)viewDidLoad
{
    _webview = (WXWebView *)self.view;
    _webview.delegate = self;
    _webview.allowsInlineMediaPlayback = YES;
    _webview.scalesPageToFit = YES;
    [_webview setBackgroundColor:[UIColor clearColor]];
    _webview.opaque = NO;
    _jsContext = [_webview valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    __weak typeof(self) weakSelf = self;
    
    // This method will be abandoned slowly.
    _jsContext[@"$notifyWeex"] = ^(JSValue *data) {
        if (weakSelf.notifyEvent) {
            [weakSelf fireEvent:@"notify" params:[data toDictionary]];
        }
    };
    
    //Weex catch postMessage event from web
    _jsContext[@"postMessage"] = ^() {
        
        NSArray *args = [JSContext currentArguments];
        
        if (args && args.count < 2) {
            return;
        }
        
        NSDictionary *data = [args[0] toDictionary];
        NSString *origin = [args[1] toString];
        
        if (data == nil) {
            return;
        }
        
        NSDictionary *initDic = @{ @"type" : @"message",
                                   @"data" : data,
                                   @"origin" : origin
                                   };
        
        [weakSelf fireEvent:@"message" params:initDic];
    };
    
    self.source = _inInitsource;
    if (_url) {
        [self loadURL:_url];
    }
}

- (void)updateAttributes:(NSDictionary *)attributes
{
    if (attributes[@"src"]) {
        self.url = attributes[@"src"];
    }
    
    if (attributes[@"source"]) {
        self.inInitsource = attributes[@"source"];
        self.source = self.inInitsource;
    }
}

- (void)addEvent:(NSString *)eventName
{
    if ([eventName isEqualToString:@"pagestart"]) {
        _startLoadEvent = YES;
    }
    else if ([eventName isEqualToString:@"pagefinish"]) {
        _finishLoadEvent = YES;
    }
    else if ([eventName isEqualToString:@"error"]) {
        _failLoadEvent = YES;
    }
}

- (void)setUrl:(NSString *)url
{
    NSString* newURL = [url copy];
    WX_REWRITE_URL(url, WXResourceTypeLink, self.weexInstance)
    if (!newURL) {
        return;
    }
    
    if (![newURL isEqualToString:_url]) {
        _url = newURL;
        if (_url) {
            [self loadURL:_url];
        }
    }
}

- (void) setSource:(NSString *)source
{
    NSString *newSource=[source copy];
    if(!newSource || _url){
        return;
    }
    if(![newSource isEqualToString:_source]){
        _source=newSource;
        if(_source){
            [_webview loadHTMLString:_source baseURL:nil];
        }
    }
    
}

- (void)loadURL:(NSString *)url
{
    if (self.webview) {
        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [self.webview loadRequest:request];
    }
}

- (void)reload
{
    [self.webview reload];
}

- (void)goBack
{
    if ([self.webview canGoBack]) {
        [self.webview goBack];
    }
}

- (void)goForward
{
    if ([self.webview canGoForward]) {
        [self.webview goForward];
    }
}

// This method will be abandoned slowly, use postMessage
- (void)notifyWebview:(NSDictionary *) data
{
    NSString *json = [WXUtility JSONString:data];
    NSString *code = [NSString stringWithFormat:@"(function(){var evt=null;var data=%@;if(typeof CustomEvent==='function'){evt=new CustomEvent('notify',{detail:data})}else{evt=document.createEvent('CustomEvent');evt.initCustomEvent('notify',true,true,data)}document.dispatchEvent(evt)}())", json];
    [_jsContext evaluateScript:code];
}

// Weex postMessage to web
- (void)postMessage:(NSDictionary *)data {
    WXSDKInstance *instance = [WXSDKEngine topInstance];
    
    NSString *bundleUrlOrigin = @"";
    
    if (instance.pageName) {
        NSString *bundleUrl = [instance.scriptURL absoluteString];
        NSURL *url = [NSURL URLWithString:bundleUrl];
        bundleUrlOrigin = [NSString stringWithFormat:@"%@://%@%@", url.scheme, url.host, url.port ? [NSString stringWithFormat:@":%@", url.port] : @""];
    }
    
    NSDictionary *initDic = @{
                              @"type" : @"message",
                              @"data" : data,
                              @"origin" : bundleUrlOrigin
                              };
    
    NSString *json = [WXUtility JSONString:initDic];
    
    NSString *code = [NSString stringWithFormat:@"(function (){window.dispatchEvent(new MessageEvent('message', %@));}())", json];
    [_jsContext evaluateScript:code];
}

#pragma mark Webview Delegate

- (NSMutableDictionary<NSString *, id> *)baseInfo
{
    NSMutableDictionary<NSString *, id> *info = [NSMutableDictionary new];
    [info setObject:self.webview.request.URL.absoluteString ?: @"" forKey:@"url"];
    [info setObject:[self.webview stringByEvaluatingJavaScriptFromString:@"document.title"] ?: @"" forKey:@"title"];
    [info setObject:@(self.webview.canGoBack) forKey:@"canGoBack"];
    [info setObject:@(self.webview.canGoForward) forKey:@"canGoForward"];
    return info;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (_finishLoadEvent) {
        NSDictionary *data = [self baseInfo];
        [self fireEvent:@"pagefinish" params:data domChanges:@{@"attrs": @{@"src":self.webview.request.URL.absoluteString}}];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (_failLoadEvent) {
        NSMutableDictionary *data = [self baseInfo];
        [data setObject:[error localizedDescription] forKey:@"errorMsg"];
        [data setObject:[NSString stringWithFormat:@"%ld", (long)error.code] forKey:@"errorCode"];
        
        NSString * urlString = error.userInfo[NSURLErrorFailingURLStringErrorKey];
        if (urlString) {
            // webview.request may not be the real error URL, must get from error.userInfo
            [data setObject:urlString forKey:@"url"];
            if (![urlString hasPrefix:@"http"]) {
                return;
            }
        }
        [self fireEvent:@"error" params:data];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (_startLoadEvent) {
        NSMutableDictionary<NSString *, id> *data = [NSMutableDictionary new];
        [data setObject:request.URL.absoluteString ?:@"" forKey:@"url"];
        [self fireEvent:@"pagestart" params:data];
    }
    return YES;
}

@end
