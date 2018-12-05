//
//  WXURLRewriteDefaultImpl.m
//  BindingX
//
//  Created by zhu zhe on 2018/12/5.
//

#import "WXURLRewriteImpl.h"

static NSString *const WXURLLocalScheme = @"local";

@implementation WXURLRewriteImpl

- (NSURL *)rewriteURL:(NSString *)url
     withResourceType:(WXResourceType)resourceType
         withInstance:(WXSDKInstance *)instance
{
    NSURL *completeURL = [NSURL URLWithString:url];
    if ([completeURL isFileURL]) {
        return completeURL;
    } else if ([self isLocalURL:completeURL]) {
        NSString *resourceName = [completeURL.path substringFromIndex:1];
        NSURL *resourceURL = [[NSBundle mainBundle] URLForResource:resourceName withExtension:@""];
        if (!resourceURL) {
            WXLogError(@"Invalid local resource URL:%@, no resouce found.", url);
        }
        
        return resourceURL;
    } else {
        return [instance completeURL:url];
    }
}

- (BOOL)isLocalURL:(NSURL *)url
{
    return[[[url scheme] lowercaseString] isEqualToString:WXURLLocalScheme];
}

@end
