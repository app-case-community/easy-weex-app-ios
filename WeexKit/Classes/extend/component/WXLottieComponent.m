//
//  WXLottieComponent.m
//  BindingX
//
//  Created by zhu zhe on 2018/11/30.
//

#import "WXLottieComponent.h"

@interface WXLottieView : UIView
@property (nonatomic, assign) BOOL loop;
@property (nonatomic, assign) CGFloat speed;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) NSDictionary *sourceJson;
@property (nonatomic, strong) NSString *sourceName;
@property (nonatomic, copy) void(^finishLoad)();

- (void)play;
- (void)pause;
- (void)reset;
//- (void)setValue:(NSString *)keyPath atFrame:(NSNumber *)frame withColor:(UIColor *)color;

@end

@implementation WXLottieView
{
    LOTAnimationView *_animationView;
}
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (_animationView != nil) {
        [_animationView setFrame:frame];
    }
}

- (void)play
{
    if (_animationView != nil) {
        [_animationView play];
    }
}

- (void)pause
{
    if (_animationView != nil) {
        [_animationView pause];
    }
}

- (void)reset
{
    if (_animationView) {
        _animationView.animationProgress = 0;
        [_animationView pause];
    }
}

//-(void)setValue:(NSString *)keyPath atFrame:(NSNumber *)frame withColor:(UIColor *)color{
//
//    if(_animationView != nil){
//
//        [_animationView setValue:color forKeypath:keyPath atFrame:frame];
//    }
//
//}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    if (_animationView != nil) {
        _animationView.animationProgress = progress;
    }
}

- (void)setLoop:(BOOL)loop
{
    _loop = loop;
    if (_animationView != nil) {
        _animationView.loopAnimation = loop;
    }
}

- (void)setSourceName:(NSString *)src
{
    if(!src) {
        return;
    }
    NSURL * url = [NSURL URLWithString:src];
    if (url.isFileURL) {
        // local url
        [self updateAnimationView:[LOTAnimationView animationWithFilePath:url.path]];
    } else {
        // remote url
        WXResourceRequest * resourceRequest = [WXResourceRequest requestWithURL:url resourceType:WXResourceTypeLink referrer:@"" cachePolicy:NSURLRequestUseProtocolCachePolicy];
        WXResourceLoader * loader = [[WXResourceLoader alloc] initWithRequest:resourceRequest];
        __weak typeof(self) weakSelf = self;
        loader.onFinished = ^(const WXResourceResponse * response, NSData * data) {
            NSError * error = nil;
            NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse*)response;
            if (200 == httpResponse.statusCode) {
                NSDictionary * dictionary = [WXUtility JSONObject:data error: &error];
                if (error) {
                    WXLogError(@"convert json object failed with error: %@", error.description);
                }
                [weakSelf setSourceJson:dictionary];
            } else {
                WXLogError(@"server return with status code: %ld", httpResponse.statusCode);
            }
        };

        loader.onFailed = ^(NSError * error) {
            WXLogError(@"download src %@ failed with error: %@", url, error.description);
        };

        [loader start];
    }
}

- (void)setSpeed:(CGFloat)speed
{
    _speed = speed;
    if (_animationView != nil) {
        _animationView.animationSpeed = speed;
    }
}

- (void)setSourceJson:(NSDictionary *)sourceJson
{
    [self updateAnimationView:[LOTAnimationView animationFromJSON:sourceJson]];
}

- (void)updateAnimationView:(LOTAnimationView *)newAnimationView
{
    if (_animationView != nil) {
        [_animationView removeFromSuperview];
    }
    _animationView = newAnimationView;
    [self addSubview: newAnimationView];
    [_animationView setFrame:self.bounds];
    [self applyAnimationProperties];
    self.finishLoad();
}

- (void)applyAnimationProperties
{
    _animationView.animationProgress = _progress;
    _animationView.animationSpeed = _speed;
    _animationView.loopAnimation = _loop;
}

@end

@interface WXLottieComponent()
@property (nonatomic, strong) NSDictionary *sourceJson;
@property (nonatomic) CGFloat progress;
@property (nonatomic) BOOL loop;
@property (nonatomic) CGFloat speed;
@property (nonatomic, strong) NSString *src;
@property (nonatomic) BOOL loaded;
@end

@implementation WXLottieComponent
WX_EXPORT_METHOD(@selector(play))
WX_EXPORT_METHOD(@selector(pause))
WX_EXPORT_METHOD(@selector(reset))

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    if (self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance]) {
        _loop = NO;
        _sourceJson = nil;
        _src = nil;
        _progress = 0;
        _speed = 1.0;
        [self fillLottieAttributes:attributes];
    }
    
    return self;
}

- (void)play
{
    if (self.isViewLoaded) {
        [(WXLottieView*)self.view play];
    }
}

- (void)pause
{
    if (self.isViewLoaded) {
        [(WXLottieView*)self.view pause];
    }
}

- (void)reset
{
    if (self.isViewLoaded) {
        [(WXLottieView*)self.view reset];
    }
}

//- (void)setValue:(NSDictionary *)options{
//
//    if(self.isViewLoaded){
//
//        if(options[@"keyPath"] && options[@"frame"] && options[@"color"]){
//
//            NSNumber *frame = @([WXConvert NSInteger:options[@"frame"]]);
//            NSString *keyPath = [WXConvert NSString:options[@"keyPath"]];
//            UIColor *color = [UIColor
//                              colorWithRed: [WXConvert CGFloat:options[@"color"][@"r"]]
//                              green: [WXConvert CGFloat:options[@"color"][@"g"]]
//                              blue: [WXConvert CGFloat:options[@"color"][@"b"]]
//                              alpha: 1.0
//                              ];
//            [(WXLottieView*)self.view setValue:keyPath atFrame:frame withColor:color];
//
//        }
//
//    }
//
//}

- (void)fillLottieAttributes:(NSDictionary*)attributes
{
    if (attributes[@"sourceJson"]) {
        _sourceJson = [attributes[@"sourceJson"] isKindOfClass:[NSDictionary class]]? attributes[@"sourceJson"] : nil;
    }
    if (attributes[@"src"]) {
        _src = [WXConvert NSString:attributes[@"src"]];
        NSString * newURL = _src;
        WX_REWRITE_URL(_src, WXResourceTypeLink, self.weexInstance);
        _src = newURL;
    }
    if (attributes[@"progress"]) {
        _progress = [WXConvert CGFloat:attributes[@"progress"]];
    }
    if (attributes[@"loop"]) {
        _loop = [WXConvert BOOL:attributes[@"loop"]];
    }
    if (attributes[@"speed"]) {
        _speed = [WXConvert CGFloat:attributes[@"speed"]];
    }
}

- (void)updateAttributes:(NSDictionary *)attributes
{
    [self fillLottieAttributes:attributes];
    WXLottieView * lottieView = (WXLottieView*)self.view;
    if (attributes[@"loop"]) {
        [lottieView setLoop:_loop];
    }
    if (attributes[@"sourceJson"]) {
        [lottieView setSourceJson:_sourceJson];
    }
    if (attributes[@"src"]) {
        NSString * newURL = _src;
        WX_REWRITE_URL(_src, WXResourceTypeLink, self.weexInstance);
        _src = newURL;
        [lottieView setSourceName:_src];
    }
    
    if (attributes[@"progress"]) {
        [lottieView setProgress:_progress];
    }
    if (attributes[@"speed"]) {
        [lottieView setSpeed:_speed];
    }
}

- (void)viewDidLoad
{
    WXLottieView * lottieView = (WXLottieView*)self.view;
    
    [lottieView setSourceName: _src];
    [lottieView setSpeed:_speed];
    [lottieView setProgress:_progress];
    [lottieView setSourceJson:_sourceJson];
    [lottieView setLoop:_loop];
}

- (UIView *)loadView
{
    WXLottieView* view = [WXLottieView new];
    view.finishLoad = ^() {
        if (_loaded) {
            [self fireEvent:@"loaded" params:nil];
        }
    };
    return view;
}

-(void)addEvent:(NSString *)eventName {
    if ([@"loaded" isEqualToString:eventName]) {
        _loaded = YES;
    }
}
-(void)removeEvent:(NSString *)eventName {
    if ([@"loaded" isEqualToString:eventName]) {
        _loaded = NO;
    }
}

@end
