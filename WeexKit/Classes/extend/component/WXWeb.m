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
        for (UIView *_aView in [m_webView subviews])
        {
            if ([_aView isKindOfClass:[UIScrollView class]])
            {
                [(UIScrollView *)_aView setShowsVerticalScrollIndicator:NO];
                //右侧的滚动条
                [(UIScrollView *)_aView setShowsHorizontalScrollIndicator:NO];
                [(UIScrollView *)_aView setAlwaysBounceHorizontal:NO];//禁止左右滑动
                //下侧的滚动条
                for (UIView *_inScrollview in _aView.subviews)
                {
                    if ([_inScrollview isKindOfClass:[UIImageView class]])
                    {
                        _inScrollview.hidden = YES;  //上下滚动出边界时的黑色的图片
                    }
                }
            }
        }

    }
    return view;
}

@end
