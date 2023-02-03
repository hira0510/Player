//
//  ZFRippleEffectView.h
//  ZFPlayer
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZFRippleEffectType) {
    ZFRippleEffectTypeLeft,
    ZFRippleEffectTypeRight
};

@interface ZFRippleEffectView : UIView

/// second title
@property (nonatomic, strong, readonly) UILabel *titleLabel;
/// 控制点的弧度
@property (nonatomic, assign) CGFloat controlPointRadius;
/// Effect type
@property (nonatomic, assign) ZFRippleEffectType effectType;
/// Animated callback
@property (nonatomic, copy) void(^stopAnimatingCallback)(void);
/// effect color
@property (nonatomic, strong) UIColor *flashColor;
/// 动画的时长
@property (nonatomic, assign) NSTimeInterval animationDuration;
    
@property (nonatomic, assign, readonly) BOOL isAnimating;

- (void)showEffectViewWithLocation:(CGPoint)tapLocation title:(NSString *)title;

- (void)hideEffectView;

@end

