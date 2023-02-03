//
//  ZFRippleEffectView.m
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


#import "ZFRippleEffectView.h"
#import "ZFUtilities.h"
#import "UIView+ZFFrame.h"

const CGFloat ZFRippleCircleInitialRaius = 10;

@interface ZFRippleEffectView() <CAAnimationDelegate>

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
/// 双击的次数
@property (nonatomic, assign) NSInteger doubleTapCount;
@property (nonatomic, assign) BOOL isAnimating;

@end

@implementation ZFRippleEffectView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _flashColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1];
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
        self.clipsToBounds = YES;
        self.userInteractionEnabled = NO;
        [self addSubview:self.iconImageView];
        [self addSubview:self.titleLabel];
        self.animationDuration = 0.7;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.controlPointRadius == 0) {
        self.controlPointRadius = self.frame.size.width / 3;
    }
    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 0;
    CGFloat min_h = 0;
    CGFloat min_view_w = self.frame.size.width;
    CGFloat min_view_h = self.frame.size.height;
    
    min_w = 42;
    min_h = 15;
    if (self.effectType == ZFRippleEffectTypeLeft) {
        min_x = (min_view_w - min_w - self.controlPointRadius) / 2;
    } else if (self.effectType == ZFRippleEffectTypeRight) {
        min_x = (min_view_w - min_w + self.controlPointRadius) / 2 ;
    }
    min_y = (min_view_h - min_h) / 2 - 20;
    self.iconImageView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_w = 100;
    min_h = 20;
    min_x = 0;
    min_y = CGRectGetMaxY(self.iconImageView.frame) + 5;
    self.titleLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.titleLabel.zf_centerX = self.iconImageView.zf_centerX;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGFloat radius = self.controlPointRadius > 0 ? self.controlPointRadius : width/3;

    UIBezierPath *circleSmallPath = [UIBezierPath bezierPath];
    if (self.effectType == ZFRippleEffectTypeLeft) {
        [circleSmallPath moveToPoint:CGPointMake(0, 0)];
        [circleSmallPath addLineToPoint:CGPointMake(width - radius, 0)];
        [circleSmallPath addQuadCurveToPoint:CGPointMake(width - radius, height) controlPoint:CGPointMake(width , height/2)];
        [circleSmallPath addLineToPoint:CGPointMake(0, height)];
        [circleSmallPath closePath];
        
    } else if (self.effectType == ZFRippleEffectTypeRight) {
        [circleSmallPath moveToPoint:CGPointMake(width, 0)];
        [circleSmallPath addLineToPoint:CGPointMake(radius, 0)];
        [circleSmallPath addQuadCurveToPoint:CGPointMake(radius, height) controlPoint:CGPointMake(0, height/2)];
        [circleSmallPath addLineToPoint:CGPointMake(width, height)];
        [circleSmallPath closePath];
    }
    self.shapeLayer.path = circleSmallPath.CGPath;
    self.layer.mask = self.shapeLayer; 
}

- (void)setEffectType:(ZFRippleEffectType)effectType {
    _effectType = effectType;
    [self setNeedsDisplay];
}

#pragma mark - Private

- (void)showEffectViewWithLocation:(CGPoint)tapLocation title:(NSString *)title {
    if (self.isAnimating) return;
    [self setNeedsDisplay];
    self.doubleTapCount++;
    /// 设置图片
    UIImage *iconImageView = nil;
    if (self.effectType == ZFRippleEffectTypeLeft) {
        if (self.doubleTapCount == 1) {
            // 加载所有的动画图片
            NSMutableArray *images = [NSMutableArray array];
            for (NSInteger i = 1; i <= 5; i++) {
                NSString *filename = [NSString stringWithFormat:@"leftseek%zd",i];
                UIImage *image = ZFPlayer_Image(filename);
                [images addObject:image];
            }
            // 设置动画图片
            self.iconImageView.animationImages = images;
            // 设置播放次数
            self.iconImageView.animationRepeatCount = 1;
            // 设置动画的时间
            self.iconImageView.animationDuration = self.animationDuration;
            // 开始动画
            [self.iconImageView startAnimating];
        } else {
            [self.iconImageView stopAnimating];
            iconImageView = ZFPlayer_Image(@"leftseek3");
        }
    } else if(self.effectType == ZFRippleEffectTypeRight) {
        if (self.doubleTapCount == 1) {
            // 加载所有的动画图片
            NSMutableArray *images = [NSMutableArray array];
            for (NSInteger i = 1; i <= 5; i++) {
                NSString *filename = [NSString stringWithFormat:@"rightSeek%zd",i];
                UIImage *image = ZFPlayer_Image(filename);
                [images addObject:image];
            }
            // 设置动画图片
            self.iconImageView.animationImages = images;
            // 设置播放次数
            self.iconImageView.animationRepeatCount = 1;
            // 设置动画的时间
            self.iconImageView.animationDuration = self.animationDuration;
            // 开始动画
            [self.iconImageView startAnimating];
        } else {
            [self.iconImageView stopAnimating];
            iconImageView = ZFPlayer_Image(@"rightSeek3");
        }
    }
    self.iconImageView.image = iconImageView;
    
    self.titleLabel.text = title;
    CAShapeLayer *circleShape = nil;
    CGFloat scale = 1.0f;
    CGFloat width = self.bounds.size.width, height = self.bounds.size.height;
    CGFloat biggerEdge = width > height ? width : height, smallerEdge = width > height ? height : width;
    CGFloat radius = smallerEdge / 2 > ZFRippleCircleInitialRaius ? ZFRippleCircleInitialRaius : smallerEdge / 2;
    scale = biggerEdge / radius + 0.5;
    circleShape = [self createCircleShapeWithPosition:CGPointMake(tapLocation.x, tapLocation.y)
                                             pathRect:CGRectMake(0, 0, radius * 2, radius * 2)
                                               radius:radius];
    [self.layer addSublayer:circleShape];
    [circleShape addAnimation:[self createFlashAnimationWithScale:scale duration:self.animationDuration] forKey:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideEffectView) object:nil];
    [self performSelector:@selector(hideEffectView) withObject:nil afterDelay:self.animationDuration];
}

- (CAShapeLayer *)createCircleShapeWithPosition:(CGPoint)position pathRect:(CGRect)rect radius:(CGFloat)radius {
    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.path = [self createCirclePathWithRadius:rect radius:radius];
    circleShape.position = position;
    circleShape.bounds = CGRectMake(0, 0, radius * 2, radius * 2);
    circleShape.fillColor = self.flashColor.CGColor;
    circleShape.opacity = 0;
    circleShape.lineWidth = 1;
    return circleShape;
}

- (CAAnimationGroup *)createFlashAnimationWithScale:(CGFloat)scale duration:(CGFloat)duration {
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1)];
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue = @0.3;
    
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = @[scaleAnimation, alphaAnimation];
    animation.duration = duration;
    animation.delegate = self;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    return animation;
}

- (CGPathRef)createCirclePathWithRadius:(CGRect)frame radius:(CGFloat)radius {
    return [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:radius].CGPath;
}
   
#pragma mark - CAAnimationDelegate
    
- (void)animationDidStart:(CAAnimation *)anim {
    NSLog(@"animationDidStart");
}
    
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSLog(@"animationDidStop");
}

- (void)hideEffectView {
    NSTimeInterval duration = 0.4;
    if (self.effectType == ZFRippleEffectTypeLeft) {
        if (self.doubleTapCount >= 2) {
            // 加载所有的动画图片
            NSMutableArray *images = [NSMutableArray array];
            for (NSInteger i = 3; i <= 5; i++) {
                NSString *filename = [NSString stringWithFormat:@"leftseek%zd",i];
                UIImage *image = ZFPlayer_Image(filename);
                [images addObject:image];
            }
            // 设置动画图片
            self.iconImageView.animationImages = images;
            // 设置播放次数
            self.iconImageView.animationRepeatCount = 1;
            // 设置动画的时间
            self.iconImageView.animationDuration = duration;
            // 开始动画
            [self.iconImageView startAnimating];
            self.iconImageView.image = nil;
        }
    } else if(self.effectType == ZFRippleEffectTypeRight) {
        if (self.doubleTapCount >= 2) {
            // 加载所有的动画图片
            NSMutableArray *images = [NSMutableArray array];
            for (NSInteger i = 3; i <= 5; i++) {
                NSString *filename = [NSString stringWithFormat:@"rightSeek%zd",i];
                UIImage *image = ZFPlayer_Image(filename);
                [images addObject:image];
            }
            // 设置动画图片
            self.iconImageView.animationImages = images;
            // 设置播放次数
            self.iconImageView.animationRepeatCount = 1;
            // 设置动画的时间
            self.iconImageView.animationDuration = duration;
            // 开始动画
            [self.iconImageView startAnimating];
            self.iconImageView.image = nil;
        }
    }
    self.isAnimating = YES;
    [UIView animateWithDuration:0.2 delay:duration-0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.titleLabel.alpha = 0;
        self.backgroundColor = [self.flashColor colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.doubleTapCount = 0;
        self.titleLabel.alpha = 1;
        self.backgroundColor = [self.flashColor colorWithAlphaComponent:0.3];
        self.isAnimating = NO;
        if (self.stopAnimatingCallback) self.stopAnimatingCallback();
    }];
}

#pragma mark - gtter

- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
    }
    return _shapeLayer;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
    }
    return _iconImageView;
}
    
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
    
- (void)setFlashColor:(UIColor *)flashColor {
    _flashColor = flashColor;
    self.backgroundColor = [flashColor colorWithAlphaComponent:0.3];
}
    
@end
