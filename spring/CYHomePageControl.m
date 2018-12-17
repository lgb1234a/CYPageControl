//
//  TTNHomePageControl.m
//  spring
//
//  Created by chenyn on 2018/12/11.
//  Copyright © 2018 chenyn. All rights reserved.
//

#import "CYHomePageControl.h"

#define contentOffset(A) (A - self.contentInsetOffsetHorzontal)

@interface SpringLayerAnimation : NSObject

@end

@implementation SpringLayerAnimation

- (CAKeyframeAnimation *)createSpringAnima:(NSString *)keypath
                                  duration:(CFTimeInterval)duration
                    usingSpringWithDamping:(CGFloat)damping
                     initialSpringVelocity:(CGFloat)velocity
                                 fromValue:(id)fromValue
                                   toValue:(id)toValue {
    
    CGFloat dampingFactor = 10.0;
    CGFloat velocityFactor = 10.0;
    NSMutableArray *values = [self springAnimationValues:fromValue
                                                 toValue:toValue
                                  usingSpringWithDamping:damping * dampingFactor
                                   initialSpringVelocity:velocity * velocityFactor
                                                duration:duration];
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:keypath];
    anim.values = values;
    anim.duration = duration;
    anim.fillMode = kCAFillModeForwards;
    anim.removedOnCompletion = NO;
    
    return anim;
}

- (NSMutableArray *)springAnimationValues:(id)fromValue
                                  toValue:(id)toValue
                   usingSpringWithDamping:(CGFloat)damping
                    initialSpringVelocity:(CGFloat)velocity
                                 duration:(CGFloat)duration {
    // 60个关键帧
    NSInteger numOfFrames = duration * 60;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:numOfFrames];
    for (NSInteger i = 0; i < numOfFrames; i++) {
        [values addObject:@(0.0)];
    }
    
    //差值
    CGFloat diff = [toValue floatValue] - [fromValue floatValue];
    for (NSInteger frame = 0; frame < numOfFrames; frame++) {
        CGFloat x = (CGFloat)frame / (CGFloat)numOfFrames;
        CGFloat value = [toValue floatValue] -
        diff * (pow(M_E, -damping * x) *
                cos(velocity * x)); // y = 1-e^{-5x} * cos(30x)
        values[frame] = @(value);
    }
    return values;
}

@end


// 带动画的当前索引
@interface AnimateIndicator()<CAAnimationDelegate>

@property (nonatomic, assign) CGSize indicatorSize;
@property (nonatomic, assign) CGSize normalIdctorSize;
@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic) CGColorRef indicatorColor;
@property (nonatomic,assign) CGFloat factor;
@property (nonatomic, assign) CGRect currentRect;
@property (nonatomic, assign) ScrollDirection scrollDirection;

@end

@implementation AnimateIndicator
{
    BOOL beginGooeyAnim;
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)initWithLayer:(AnimateIndicator *)layer {
    self = [super initWithLayer:layer];
    if (self) {
        self.indicatorSize = layer.indicatorSize;
        self.indicatorColor = layer.indicatorColor;
        self.factor = layer.factor;
        self.currentRect = layer.currentRect;
        self.scrollDirection = layer.scrollDirection;
        self.lastContentOffset = layer.lastContentOffset;
        self.normalIdctorSize = layer.normalIdctorSize;
        self.pageCount = layer.pageCount;
        self.contentInsetOffsetHorzontal = layer.contentInsetOffsetHorzontal;
    }
    return self;
}

//invoke when call setNeedDisplay
- (void)drawInContext:(CGContextRef)ctx
{
    CGFloat offset = CGRectGetHeight(self.currentRect)*0.5;
    
    /*
            A ************ C
             **************
          AB****************CD
             **************
            B ************ D
     */
    CGFloat distance = (self.frame.size.width - (self.pageCount-1)*self.normalIdctorSize.width - self.indicatorSize.width) / (self.pageCount - 1);
    CGFloat extra = distance * _factor; // 变化的长度
    
    CGFloat leftScrlExtra = self.scrollDirection == ScrollDirectionLeft? extra : 0;
//    CGPoint pointA = CGPointMake(CGRectGetMinX(self.currentRect)+offset-leftScrlExtra, CGRectGetMinY(self.currentRect));
    CGPoint centerAB = CGPointMake(CGRectGetMinX(self.currentRect)+offset-leftScrlExtra, CGRectGetMidY(self.currentRect));
    CGPoint pointB = CGPointMake(CGRectGetMinX(self.currentRect)+offset-leftScrlExtra, CGRectGetMaxY(self.currentRect));
    
    
    //
    CGFloat rightScrlExtra = self.scrollDirection == ScrollDirectionRight? extra : 0;
    CGPoint pointC = CGPointMake(CGRectGetMaxX(self.currentRect)-offset+rightScrlExtra, CGRectGetMinY(self.currentRect));
    CGPoint centerCD = CGPointMake(CGRectGetMaxX(self.currentRect)-offset+rightScrlExtra, CGRectGetMidY(self.currentRect));
//    CGPoint pointD = CGPointMake(CGRectGetMaxX(self.currentRect)-offset+rightScrlExtra, CGRectGetMaxY(self.currentRect));
    
    // 绘制当前的indicator
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:pointB];
    [path addArcWithCenter:centerAB radius:offset startAngle:M_PI_2 endAngle:M_PI_2*3 clockwise:YES];
    [path addLineToPoint:pointC];
    [path addArcWithCenter:centerCD radius:offset startAngle:M_PI_2*3 endAngle:M_PI_2 clockwise:YES]; // 绘制半圆
    [path addLineToPoint:pointB];
    
    [path closePath];
    
    CGContextAddPath(ctx, path.CGPath);
    CGContextSetFillColorWithColor(ctx, self.indicatorColor);
    CGContextFillPath(ctx);
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqual:@"factor"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

// 修改动画变量
- (void)animateIndicatorWithScrollView:(UIScrollView *)scrollView
                          andIndicator:(CYHomePageControl *)pgctl
{
    if(scrollView.contentOffset.x-self.lastContentOffset >= 0 &&
       scrollView.contentOffset.x-self.lastContentOffset <= scrollView.frame.size.width * 0.5)
    {
        self.scrollDirection = ScrollDirectionLeft;
    }
    
    if(scrollView.contentOffset.x-self.lastContentOffset <= 0 &&
       scrollView.contentOffset.x-self.lastContentOffset >= -scrollView.frame.size.width*0.5)
    {
        self.scrollDirection = ScrollDirectionRight;
    }
    
    if(!beginGooeyAnim) {
        if(contentOffset(scrollView.contentOffset.x) > scrollView.frame.size.width * (self.pageCount-1) || contentOffset(scrollView.contentOffset.x) < 0)
        {
            _factor = 0;
        }else
        {
            _factor = MIN(1, MAX(0, ABS(scrollView.contentOffset.x-self.lastContentOffset)/scrollView.frame.size.width));
        }
    }
    
    CGFloat distance = (self.frame.size.width - self.indicatorSize.width) / (self.pageCount - 1);
    CGFloat originX = (contentOffset(scrollView.contentOffset.x) / scrollView.frame.size.width) * distance;
    if (originX - self.indicatorSize.width*0.5 <= 0) {
        self.currentRect = CGRectMake(0, self.frame.size.height*0.5 - self.indicatorSize.height*0.5, self.indicatorSize.width, self.indicatorSize.height);
    } else if ((originX - self.indicatorSize.width*0.5) >= self.frame.size.width - self.indicatorSize.width)
    {
        self.currentRect = CGRectMake(self.frame.size.width - self.indicatorSize.width, self.frame.size.height*0.5 - self.indicatorSize.height*0.5, self.indicatorSize.width, self.indicatorSize.height);
    }else {
        self.currentRect = CGRectMake(originX, self.frame.size.height*0.5 - self.indicatorSize.height*0.5, self.indicatorSize.width, self.indicatorSize.height);
    }
    [self setNeedsDisplay];
}

// 恢复到原大小的弹性动画
- (void)restoreAnimation:(id)scrlDistance
{
    CAKeyframeAnimation *anim = [[SpringLayerAnimation alloc] createSpringAnima:@"factor"
                                                                       duration:0.8
                                                         usingSpringWithDamping:0.5
                                                          initialSpringVelocity:3
                                                                      fromValue:@([scrlDistance floatValue] + 0.5)
                                                                        toValue:@0];
    
    anim.delegate = self;
    self.factor = 0;
    [self addAnimation:anim forKey:@"restoreAnimation"];
}

#pragma mark-- CAAnimation Delegate
- (void)animationDidStart:(CAAnimation *)anim {
    beginGooeyAnim = YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        beginGooeyAnim = NO;
        [self removeAllAnimations];
    }
}

@end

// 非动画的索引
@interface PageCtrlIndicator()

@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, assign) CGSize indicatorSize;
@property (nonatomic, assign) CGSize crntIndicatorSize;
@property (nonatomic) CGColorRef indicatorColor;
@property (nonatomic, strong) NSMutableArray *ratios;
@property (nonatomic, assign) ScrollDirection scrollDirection;

@end

@implementation PageCtrlIndicator
{
    CGFloat distance;
    CGFloat offset;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 默认属性
        self.ratios = @[].mutableCopy;
    }
    return self;
}

- (id)initWithLayer:(PageCtrlIndicator *)layer {
    self = [super initWithLayer:layer];
    if (self) {
        self.pageCount = layer.pageCount;
        self.currentPage = layer.currentPage;
        self.indicatorColor = layer.indicatorColor;
        self.indicatorSize = layer.indicatorSize;
        self.crntIndicatorSize = layer.crntIndicatorSize;
        self.ratios = layer.ratios;
        self.lastContentOffset = layer.lastContentOffset;
        self.scrollDirection = layer.scrollDirection;
        self.contentInsetOffsetHorzontal = layer.contentInsetOffsetHorzontal;
        self.masksToBounds = layer.masksToBounds;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    if(self.pageCount <= 1) return;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, self.indicatorSize.height*0.5, self.frame.size.height * 0.5);
    //画pageCount个小圆
    distance = (self.frame.size.width - self.crntIndicatorSize.width) / (self.pageCount - 1);

    for (NSInteger i = 0; i < self.pageCount; i++) {
        CGFloat ratio = self.ratios.count > i ? [self.ratios[i] floatValue] : 0;
        CGRect circleRect = CGRectMake(i * distance + ratio, (self.frame.size.height - self.indicatorSize.height)*0.5, self.indicatorSize.height, self.indicatorSize.height);
        CGPathAddEllipseInRect(path, nil, circleRect);
    }
    CGContextAddPath(ctx, path);
    CGContextSetFillColorWithColor(ctx, self.indicatorColor);
    CGContextFillPath(ctx);
}

- (void)updateIndicatorDisplayWithScrollView:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.x-self.lastContentOffset >= 0 &&
       scrollView.contentOffset.x-self.lastContentOffset <= scrollView.frame.size.width)
    {
        self.scrollDirection = ScrollDirectionLeft;
        self.currentPage = MIN(contentOffset(scrollView.contentOffset.x) / scrollView.frame.size.width, self.pageCount-1);
    }
    else if(scrollView.contentOffset.x-self.lastContentOffset <= 0 &&
       scrollView.contentOffset.x-self.lastContentOffset >= -scrollView.frame.size.width)
    {
        self.scrollDirection = ScrollDirectionRight;
        self.currentPage = MIN(ceil(contentOffset(scrollView.contentOffset.x) / scrollView.frame.size.width*1.0), self.pageCount-1);
    }else
    {
        self.scrollDirection = ScrollDirectionNone;
        self.currentPage = MIN(contentOffset(scrollView.contentOffset.x) / scrollView.frame.size.width, self.pageCount-1);
    }
    
    if(ABS(scrollView.contentOffset.x-self.lastContentOffset) >= scrollView.frame.size.width * (self.pageCount - 1))
    {
        // 重置
        [self.ratios removeAllObjects];
    }
    
    CGFloat factor = MIN(1, MAX(0, ABS(contentOffset(scrollView.contentOffset.x)-scrollView.frame.size.width * self.currentPage)) / scrollView.frame.size.width*1.0);
    offset = self.crntIndicatorSize.width - self.indicatorSize.width;
    
    if(self.ratios.count == 0)
    {
        [self reConstructRatios];
    }
    
    // indicator点的偏移计算
    if(self.scrollDirection == ScrollDirectionLeft && self.currentPage + 1 < self.pageCount - 1)
    {
            [self.ratios replaceObjectAtIndex:self.currentPage + 1 withObject:@(offset * (1-factor))];
    }
    else if(self.scrollDirection == ScrollDirectionRight && (self.currentPage > 0 && self.currentPage < self.pageCount))
    {
        if(self.currentPage-1 > 0)
        {
            [self.ratios replaceObjectAtIndex:self.currentPage-1 withObject:@(offset * factor)];
        }
        [self.ratios replaceObjectAtIndex:self.currentPage withObject:@(offset * factor)];
    }
    
    [self setNeedsDisplay];
}


// 重置为结束状态
- (void)resetIndicatorDisplayWithScrollView:(UIScrollView *)scrollView
{
    [self reConstructRatios];
    [self setNeedsDisplay];
}


- (void)reConstructRatios
{
    [self.ratios removeAllObjects];
    for (int i = 0; i < self.pageCount-1; i++)
    {
        [self.ratios addObject:i>self.currentPage?@(offset):@0];
    }
    [self.ratios addObject:@(offset)];
}

@end


@interface CYHomePageControl ()

@property(nonatomic, strong) AnimateIndicator *animateIndicator;
@property(nonatomic, strong) PageCtrlIndicator *pageCtrlIndicator;

@end

@implementation CYHomePageControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(!CGPointEqualToPoint(self.frame.origin, self.pageCtrlIndicator.frame.origin))
    {
        _pageCtrlIndicator.frame = self.bounds;
        _animateIndicator.frame = self.bounds;
        [_pageCtrlIndicator setNeedsDisplay];
        [_animateIndicator setNeedsDisplay];
    }
}

// 添加图层
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self.layer addSublayer:self.pageCtrlIndicator];
    [self.layer insertSublayer:self.animateIndicator above:self.pageCtrlIndicator];
    [self.pageCtrlIndicator setNeedsDisplay];
}

- (PageCtrlIndicator *)pageCtrlIndicator
{
    if(!_pageCtrlIndicator)
    {
        _pageCtrlIndicator = [PageCtrlIndicator layer];
        _pageCtrlIndicator.frame = self.bounds;
        _pageCtrlIndicator.pageCount = self.pageCount;
        _pageCtrlIndicator.currentPage = self.currentPage;
        _pageCtrlIndicator.indicatorColor = self.normalCtrlColor.CGColor;
        _pageCtrlIndicator.indicatorSize = self.normalCtrlSize;
        _pageCtrlIndicator.crntIndicatorSize = self.currentCtrlSize;
        _pageCtrlIndicator.contentInsetOffsetHorzontal = self.contentInsetOffsetHorzontal;
        _pageCtrlIndicator.contentsScale = [UIScreen mainScreen].scale;
    }
    return _pageCtrlIndicator;
}

- (AnimateIndicator *)animateIndicator
{
    if(!_animateIndicator)
    {
        _animateIndicator = [AnimateIndicator layer];
        _animateIndicator.frame = self.bounds;
        _animateIndicator.indicatorColor = self.highlightCtrlColor.CGColor;
        _animateIndicator.indicatorSize = self.currentCtrlSize;
        _animateIndicator.normalIdctorSize = self.normalCtrlSize;
        _animateIndicator.pageCount = self.pageCount;
        _animateIndicator.contentInsetOffsetHorzontal = self.contentInsetOffsetHorzontal;
        _animateIndicator.contentsScale = [UIScreen mainScreen].scale;
    }
    return _animateIndicator;
}

- (void)setPageCount:(NSInteger)pageCount
{
    if(_pageCount != pageCount)
    {
        _pageCount = pageCount;
        _animateIndicator.pageCount = _pageCount;
        _pageCtrlIndicator.pageCount = _pageCount;
    }
}

- (void)setCurrentPage:(NSInteger)curntPage
{
    _pageCtrlIndicator.currentPage = curntPage;
    _currentPage = curntPage;
}

- (void)setHidden:(BOOL)hidden
{
    self.layer.hidden = hidden;
}

- (AnimateIndicator *)indicator
{
    return self.animateIndicator;
}

- (PageCtrlIndicator *)pageIndicators
{
    return self.pageCtrlIndicator;
}

@end
